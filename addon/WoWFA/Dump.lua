-- WoWFA Forever - /wowfa dump: export EVERY spell the live client knows (all
-- classes, every rank, talents, racials, professions, pet spells) as the exact
-- tooltip lines the addon will see in game. The owner (rc4): "we must cover all
-- classes and specs, not only my hunter, and stay up to date". Run it once per
-- game update on any character: the data side then lists every line that has
-- no Persian yet, for every class.
--
-- English game text only: no character, realm or account data is stored.
-- Saved in its own variable (WoWFA_Dump): /reload after it finishes, send the
-- file WTF\Account\<account>\SavedVariables\WoWFA.lua, then /wowfa dump clear.
--
--   /wowfa dump            scan spell ids 1..1500000 (time-budgeted, no freeze)
--   /wowfa dump <max>      scan up to <max>
--   /wowfa dump stop       stop (what was found so far stays saved)
--   /wowfa dump status     progress
--   /wowfa dump clear      delete the export

local F = WoWFAF

local D = {}
F.Dump = D
D.MAX = 1500000
D.BUDGET = 8          -- ms of work per frame
D.CAP_PER_STEP = 4000 -- hard cap of ids per frame (a clock that does not move can never hang it)
D.RETRY_WAIT = 4      -- seconds before the second pass over not-yet-loaded spells

local scan
local frame

local function chat(msg)
    if F.Chat then
        F.Chat("WoWFA dump: " .. msg)
    elseif print then
        print("WoWFA dump: " .. msg)
    end
end

local function now_ms()
    if debugprofilestop then
        return debugprofilestop()
    end
    return (GetTime and GetTime() or 0) * 1000
end

local function call(f, ...)
    if not f then
        return nil
    end
    local ok, a = pcall(f, ...)
    if ok and F.Usable(a) then
        return a
    end
    return nil
end

local function api_name(id)
    local n = call(C_Spell and C_Spell.GetSpellName, id)
    if n == nil then
        n = call(GetSpellInfo, id)
    end
    return n
end

local function api_exists(id)
    if C_Spell and C_Spell.DoesSpellExist then
        return call(C_Spell.DoesSpellExist, id) and true or false
    end
    return api_name(id) ~= nil
end

local function api_sub(id)
    return call((C_Spell and C_Spell.GetSpellSubtext) or GetSpellSubtext, id)
end

local function api_desc(id)
    return call((C_Spell and C_Spell.GetSpellDescription) or GetSpellDescription, id)
end

local function request(id)
    if C_Spell and C_Spell.RequestLoadSpellData then
        pcall(C_Spell.RequestLoadSpellData, id)
    end
end

-- a private hidden tooltip: the SAME line layout the player's tooltips get.
-- tt.wfaScan makes Spells.lua leave it alone (we export English, never Persian)
local tip
local function scan_tip()
    if tip == nil then
        local ok, t = pcall(CreateFrame, "GameTooltip", "WoWFAF_ScanTip", nil, "GameTooltipTemplate")
        tip = (ok and type(t) == "table") and t or false
        if tip then
            tip.wfaScan = true
        end
    end
    return tip or nil
end

local function tip_lines(id)
    local out = {}
    local tt = scan_tip()
    if not tt or not tt.SetSpellByID then
        return out
    end
    pcall(tt.SetOwner, tt, WorldFrame or UIParent, "ANCHOR_NONE")
    pcall(tt.ClearLines, tt)
    if not pcall(tt.SetSpellByID, tt, id) then
        return out
    end
    local n = call(tt.NumLines, tt) or 0
    for i = 1, n do
        local l = _G["WoWFAF_ScanTipTextLeft" .. i]
        local r = _G["WoWFAF_ScanTipTextRight" .. i]
        local lt = l and call(l.GetText, l)
        local rt = r and call(r.IsShown, r) and call(r.GetText, r)
        if type(lt) == "string" then
            if type(rt) == "string" and rt ~= "" then
                out[#out + 1] = lt .. "\t" .. rt
            else
                out[#out + 1] = lt
            end
        end
    end
    pcall(tt.Hide, tt)
    return out
end

-- true = stored with text; false = nothing to translate yet (not loaded)
local function record(id, name)
    local lines = tip_lines(id)
    local desc = api_desc(id)
    if type(desc) ~= "string" or desc == "" then
        desc = nil
    end
    if #lines <= 1 and not desc then
        return false
    end
    if desc then
        for _, l in ipairs(lines) do
            if l == desc then
                desc = nil -- already one of the tooltip lines
                break
            end
        end
    end
    WoWFA_Dump.s[id] = { n = name, r = api_sub(id), l = lines, d = desc }
    WoWFA_Dump.count = (WoWFA_Dump.count or 0) + 1
    return true
end

local function finish(stopped)
    scan.running = false
    if frame then
        frame:SetScript("OnUpdate", nil)
    end
    WoWFA_Dump.done = not stopped
    WoWFA_Dump.lastId = scan.id
    WoWFA_Dump.highest = scan.highest
    WoWFA_Dump.names = scan.seen
    chat(string.format("%s: %d spells with text, %d names, highest id %d. Type /reload, then send WTF\\Account\\<account>\\SavedVariables\\WoWFA.lua",
        stopped and "stopped" or "done", WoWFA_Dump.count or 0, scan.seen, scan.highest))
end

function D.Step()
    local S = scan
    if not S or not S.running then
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        return -- pause in combat, resume after
    end
    local t0 = now_ms()
    local done = 0
    while done < D.CAP_PER_STEP and now_ms() - t0 < D.BUDGET do
        done = done + 1
        if S.phase == 1 then
            S.id = S.id + 1
            if S.id > S.max then
                S.phase = 2
                S.wait = (GetTime and GetTime() or 0) + D.RETRY_WAIT
                S.ri = 0
                chat(string.format("scan done (%d names), second pass over %d not-yet-loaded spells...", S.seen, #S.retry))
                return
            end
            local id = S.id
            if api_exists(id) then
                local name = api_name(id)
                if type(name) == "string" and name ~= "" then
                    S.seen = S.seen + 1
                    S.highest = id
                    if not record(id, name) then
                        request(id)
                        S.retry[#S.retry + 1] = id
                    end
                end
            end
            local pct = math.floor(S.id * 100 / S.max)
            if pct >= S.pct + 10 then
                S.pct = pct
                chat(string.format("%d%% (%d spells with text)", pct, WoWFA_Dump.count or 0))
            end
        else
            if (GetTime and GetTime() or 0) < S.wait then
                return
            end
            S.ri = S.ri + 1
            local id = S.retry[S.ri]
            if not id then
                finish(false)
                return
            end
            local name = api_name(id)
            if not (name and record(id, name)) then
                WoWFA_Dump.s[id] = { n = name } -- exists, no text: a name-only row
            end
        end
    end
end

local function start(max)
    if scan and scan.running then
        chat("already running, /wowfa dump status")
        return
    end
    WoWFA_Dump = {
        v = F.VERSION,
        b = F.clientBuildText,
        cv = F.clientVersion,
        t = time and time() or 0,
        max = max,
        count = 0,
        s = {},
    }
    scan = { running = true, phase = 1, id = 0, max = max, retry = {}, seen = 0, highest = 0, pct = 0 }
    if not frame then
        frame = CreateFrame("Frame")
    end
    frame:SetScript("OnUpdate", function()
        local ok, err = pcall(D.Step)
        if not ok then
            F:LogError("dump", err)
            finish(true)
        end
    end)
    chat(string.format("started (spell ids 1-%d). Keep playing or stand still; it pauses in combat.", max))
end

function D.Command(arg)
    arg = arg or ""
    if arg == "stop" then
        if scan and scan.running then
            finish(true)
        else
            chat("not running")
        end
    elseif arg == "status" then
        if scan and scan.running then
            chat(string.format("phase %d, id %d / %d, %d spells with text", scan.phase, scan.id, scan.max, WoWFA_Dump.count or 0))
        elseif type(WoWFA_Dump) == "table" then
            chat(string.format("saved export: %d spells (build %s)%s", WoWFA_Dump.count or 0, tostring(WoWFA_Dump.b), WoWFA_Dump.done and "" or ", not finished"))
        else
            chat("no export saved")
        end
    elseif arg == "clear" then
        if scan and scan.running then
            finish(true)
        end
        WoWFA_Dump = nil
        chat("export deleted (gone from the file after /reload)")
    else
        local max = tonumber(arg)
        if not max or max < 1 then
            max = D.MAX
        end
        start(math.floor(max))
    end
end

-- /wowfa dump ...: wrap the Core slash handler (Core.lua loads first)
local orig = SlashCmdList and SlashCmdList["WOWFAF"]
if orig then
    SlashCmdList["WOWFAF"] = function(msg)
        local m = string.lower(tostring(msg or ""))
        local cmd, rest = string.match(m, "^%s*(%S*)%s*(.-)%s*$")
        if cmd == "dump" then
            local ok, err = pcall(D.Command, rest)
            if not ok then
                F:LogError("dump", err)
            end
            return
        end
        return orig(msg)
    end
end
