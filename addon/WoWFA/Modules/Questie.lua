-- WoWFA Forever - Questie (1.1.0, the owner 25 Nov: "if our translations also covered what
-- Questie shows, that would be great"). Questie draws its own map / minimap pin tooltips
-- ("Dustbelcher Lord" / "[40] Terror of the Desert Skies   (Available)"), adds quest lines
-- under mob and object tooltips and has its own quest tracker. Nothing of Questie is changed:
-- after a tooltip is shown its lines are read and the ones we know are written in Persian IN
-- PLACE (put back by the shared tooltip clear in Text.lua); the Questie tracker is walked like
-- the game's own lists (Modules/Walk.lua QUESTIE_ROOTS). Only lines that are surely Questie's
-- are touched:
--   * "[level] title" lines (+ the "(Available)" / "(Complete)" / "(Hold Shift)" right side),
--   * the NPC name lines of a tooltip that has such a line (a Questie pin tooltip),
--   * under a unit tooltip: a line that is the title of a quest IN THE PLAYER'S LOG, and the
--     objective lines below it.
-- Item names stay English (no item bank in v1.0); an item is never looked up as an NPC.
-- Switch: Quests > «Questie» (F.db.questie, default on). Without Questie nothing runs.

local F = WoWFAF
local L = F.L
local T = F.T
local Q = {}
F.Questie = Q

local function has_fa(s)
    return type(s) == "string" and string.find(s, "[\216-\219\239]") ~= nil
end

function Q.Loaded()
    local fn = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded
    if type(fn) == "function" then
        for _, n in ipairs({ "Questie", "Questie-Forever", "QuestieForever" }) do
            local ok, v = pcall(fn, n)
            if ok and v then
                return true
            end
        end
    end
    return rawget(_G, "QuestieLoader") ~= nil
end

local function on()
    local db = F.db
    return db and db.enabled and db.questie ~= false and F.Room and Q.Loaded() and true or false
end
Q.On = on

local RIGHT = { ["(available)"] = "qz_avail", ["(complete)"] = "qz_complete", ["(hold shift)"] = "qz_shift",
    ["(in progress)"] = "qz_progress", ["(repeatable)"] = "qz_repeat" }

local function plain(t)
    local c = string.match(t, "^(|c%x%x%x%x%x%x%x%x)")
    local p = string.gsub(t, "|c%x%x%x%x%x%x%x%x", "")
    p = string.gsub(p, "|r", "")
    return p, c
end

local function trim(s)
    return (string.match(s or "", "^%s*(.-)%s*$"))
end

local function shaped(s)
    return T.ShapeLine(T.Digits(s), T.Mode())
end

-- "[40] Terror of the Desert Skies" -> "[40] <Persian title>"
local function title_line(p)
    local lvl, title = string.match(p, "^(%[[^%]]+%])%s*(.+)$")
    if not title or not (F.Walk and F.Walk.TitleFa) then
        return nil
    end
    local fa = F.Walk.TitleFa(trim(title))
    if not fa then
        return nil
    end
    return lvl .. " " .. shaped(fa)
end

local function put(tt, fs, text, side, fam)
    if not fs then
        return
    end
    -- the original font / text / justify are recorded once by the shared in-place path
    T.TipSet(tt, fs, " ", nil, side, fam)
    fs:SetText(text)
end

local busy = false
local function scan(tt)
    if busy or not on() then
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        if F.CombatSkip then
            F.CombatSkip("questie-tip")
        end
        return false -- 1.1.1: no tooltip rewrite (and no second Show) in combat
    end
    local name = tt.GetName and tt:GetName()
    if type(name) ~= "string" then
        return false
    end
    local okn, n = pcall(tt.NumLines, tt)
    if not okn or not F.Usable(n) or type(n) ~= "number" or n < 1 then
        return false
    end
    local lines, pin = {}, false
    for i = 1, math.min(n, 40) do
        local l, r = _G[name .. "TextLeft" .. i], _G[name .. "TextRight" .. i]
        local okl, lt = pcall(function() return l and l:GetText() end)
        local okr, rt = pcall(function() return r and r:GetText() end)
        lt = (okl and F.Usable(lt) and type(lt) == "string") and lt or nil
        rt = (okr and F.Usable(rt) and type(rt) == "string") and rt or nil
        lines[i] = { l = l, r = r, lt = lt, rt = rt }
        if lt and string.find(plain(lt), "^%[[^%]]+%]%s*%S") then
            pin = true
        end
        if rt and RIGHT[string.lower(trim(plain(rt)))] then
            pin = true
        end
    end
    local names = (F.D and F.D.names) or {}
    local npcOn = F.Room.On("namesNpc")
    local inQuest, changed = false, false
    for i, e in ipairs(lines) do
        local lt = e.lt
        if lt and lt ~= "" and not has_fa(lt) then
            local p, c = plain(lt)
            local out, fam
            local tl = title_line(p)
            if tl then
                out, inQuest, fam = tl, true, "qs"
            elseif i >= 2 and F.Walk and F.Walk.LogId and F.Walk.LogId(trim(p)) then
                inQuest = true
                local fa = F.Walk.TitleFa and F.Walk.TitleFa(trim(p))
                if fa then
                    out, fam = (string.match(p, "^(%s*)") or "") .. shaped(fa), "qs"
                end
            elseif inQuest and string.find(p, "%d+/%d+") and F.Walk and F.Walk.Objective then
                local ind, body = string.match(p, "^(%s*)(.-)$")
                local o = F.Walk.Objective(body)
                if o then
                    out = (ind or "") .. o
                end
            elseif pin and npcOn and not string.find(p, "%d") then
                local k = T.NameKey(trim(p))
                local fa = (names.npc and names.npc[k]) or (names.boss and names.boss[k])
                if fa then
                    out, fam = shaped(fa), "npc"
                end
            end
            if out then
                put(tt, e.l, (c or "") .. out .. (c and "|r" or ""), "Left", fam)
                changed = true
            end
        end
        local rt = e.rt
        if rt and rt ~= "" and not has_fa(rt) then
            local p, c = plain(rt)
            local key = RIGHT[string.lower(trim(p))]
            if key and L[key] then
                put(tt, e.r, (c or "") .. shaped(L[key]) .. (c and "|r" or ""), "Right")
                changed = true
            end
        end
    end
    return changed
end
Q.Scan = scan

local function hook(tt)
    if type(tt) ~= "table" or tt.wfaQuestie or type(tt.Show) ~= "function" then
        return
    end
    tt.wfaQuestie = true
    hooksecurefunc(tt, "Show", function(self)
        local ok, changed = pcall(scan, self)
        busy = false
        if not ok then
            F:LogError("questie", changed)
        elseif changed then
            -- let the tooltip size itself to the Persian lines (our scan skips them now)
            busy = true
            pcall(self.Show, self)
            busy = false
        end
    end)
end

F:Listen("login", function()
    local ok, err = pcall(function()
        hook(GameTooltip)
        hook(rawget(_G, "WorldMapTooltip"))
    end)
    if not ok then
        F:LogError("questie", err)
    end
    if Q.Loaded() then
        F.Chat("WoWFA: Questie found - its quest titles, NPC names and objectives are drawn in Persian too")
    end
end)
