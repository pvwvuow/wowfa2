-- WoWFA Forever - NPC talk and books (1.0.7, the owner 25 Nov: "look at what the other
-- translation addons have and start; stay future-proof: whatever the game changes we must
-- know at once, so the next update has it"). Four surfaces, all behind the room switch
-- «گفتگوی NPC» (npcSay) and one switch each on the «گفتگو و کتاب‌ها» page:
--   gossip  the text of the gossip window and the quest greeting (F.db.dlgGossip)
--   say     what NPCs say / yell / emote / whisper in the chat and in their bubbles (dlgSay)
--   book    books, letters, plaques (the ItemText frame, every page) (dlgBook)
-- Matching is the spell-template engine: the live English (player name -> $n, markup and
-- extra spaces dropped) becomes a key with the numbers as # (T.NumKey) and is looked up in
-- the template table, then refilled with the live numbers. A Persian text shows in a small
-- pane next to the game window (gossip / greeting / book) or replaces the chat line (say).
-- A text with no Persian is kept, in English, in the update watch (F:Miss, the status page)
-- AND in WoWFA_Harvest.x (the SavedVariables file the owner sends): the next build adds it.
-- Shift held (F.db.shiftEn, default on) = the game's English original everywhere we write
-- (this pane, the NPC chat lines, the spell / talent tooltips: Modules/Spells.lua).
-- Not a registered module: every handler runs in pcall and logs as "dialog".

local F = WoWFAF
local T = F.T
local D = {}
F.Dialog = D
D.MAXH = 2000 -- harvested texts kept at most (1.0.9: 2000 x 2000 letters, a full file stays small)

local function str(v)
    if type(v) == "string" and v ~= "" and F.Usable(v) then
        return v
    end
    return nil
end

local function has_fa(s)
    return type(s) == "string"
        and (string.find(s, "[\216-\219]") ~= nil or string.find(s, "\239[\173-\187]") ~= nil)
end

local function master()
    local db = F.db
    return db and db.enabled and F.Room and F.Room.On("npcSay") and true or false
end

local function on(key)
    return master() and F.db[key] ~= false
end
D.On = on

function F.ShiftEn()
    local db = F.db
    if not db or db.shiftEn == false or not IsShiftKeyDown then
        return false
    end
    local ok, v = pcall(IsShiftKeyDown)
    return ok and v and true or false
end

local function me()
    local ok, n = pcall(UnitName, "player")
    return ok and str(n) or nil
end

local function esc(s)
    return (string.gsub(s, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

-- the live text as the data keys it: the player's name -> $n, html / colour markup and
-- line breaks out, spaces collapsed. Returns the normal text, the key and the numbers.
function D.Norm(text)
    local s = tostring(text or "")
    s = string.gsub(s, "<[^<>]*>", " ")
    s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    s = string.gsub(s, "|n", " ")
    s = string.gsub(s, "%s+", " ")
    s = string.gsub(s, "^ ", "")
    s = string.gsub(s, " $", "")
    local n = me()
    if n and #n > 1 then
        s = string.gsub(s, "%f[%w]" .. esc(n) .. "%f[%W]", "$n")
    end
    if s == "" then
        return nil
    end
    local ok, key, nums = pcall(T.NumKey, s)
    if not ok or type(key) ~= "string" or key == "" then
        return nil
    end
    return s, key, nums
end

-- Persian for a live text (nil when the data has none) + the key (for the watch)
function D.Lookup(text)
    if not str(text) or has_fa(text) then
        return nil
    end
    local s, key, nums = D.Norm(text)
    if not key then
        return nil
    end
    local tpl = F.D and F.D.tpl
    local fa = type(tpl) == "table" and tpl[key] or nil
    if type(fa) ~= "string" or fa == "" then
        return nil, key, s
    end
    local okf, filled = pcall(T.Fill, fa, nums)
    if okf and type(filled) == "string" and filled ~= "" then
        fa = filled
    end
    return fa, key, s
end

-- ------------------------------------------------------------------ the watch
local function harvest(kind, key, text, ctx)
    local db = F.db
    if not db or db.enabled == false or db.harvest == false then
        return
    end
    if type(WoWFA_Harvest) ~= "table" then
        WoWFA_Harvest = {}
    end
    local h = WoWFA_Harvest
    if type(h.x) ~= "table" then
        h.x = {}
    end
    h.nx = tonumber(h.nx) or 0
    local id = kind .. ":" .. key
    local e = h.x[id]
    if e then
        e.n = (tonumber(e.n) or 1) + 1
        return
    end
    if h.nx >= D.MAXH then
        return
    end
    local okz, z = pcall(GetRealZoneText)
    h.x[id] = { k = kind, key = key, t = string.sub(text, 1, 2000), c = ctx and string.sub(tostring(ctx), 1, 120) or nil,
        z = okz and str(z) or nil, n = 1 }
    h.nx = h.nx + 1
    h.v = F.VERSION
    h.b = F.clientBuildText
end

local function missed(kind, key, text, ctx)
    if not key or type(text) ~= "string" or has_fa(text) then
        return
    end
    pcall(harvest, kind, key, text, ctx)
    F:Miss(kind, key, string.sub(text, 1, 300), ctx)
end
D.Missed = missed

-- ------------------------------------------------------------------ the pane
local pane

local function make_pane()
    if pane then
        return pane
    end
    local f = CreateFrame("Frame", "WoWFAF_DlgPane", UIParent)
    f:Hide()
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)
    f:SetSize(324, 80)
    F.UI.Glass(f, 0.94)
    f.text = F.UI.Text(f, 13, F.C.text)
    f.text:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -12)
    pane = f
    return f
end

local function hide(kind)
    if pane and (kind == nil or pane.kind == kind) then
        pane:Hide()
        pane.fa, pane.kind, pane.anchor = nil, nil, nil
    end
end
D.Hide = hide

local function visible_now()
    return pane and pane.fa and pane.anchor and pane.anchor.IsShown and pane.anchor:IsShown() and not F.ShiftEn()
end

local function show(anchor, fa, kind)
    if not anchor then
        return
    end
    local f = make_pane()
    f.kind, f.anchor, f.fa = kind, anchor, fa
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 4, -12)
    local size = (T.Size and T.Size() or 12) + 1
    if f.text.SetFont and F.FONT then
        pcall(f.text.SetFont, f.text, F.FONT, size, "")
    end
    local w = 300
    f.text:SetFa(T.Prepare(fa), w)
    local h = f.text.GetStringHeight and f.text:GetStringHeight()
    if not (F.Usable(h) and type(h) == "number" and h > 0) then
        h = 60
    end
    f:SetSize(w + 24, h + 26)
    if visible_now() then
        f:Show()
    else
        f:Hide()
    end
end

-- ------------------------------------------------------------------ gossip + greeting
local function call(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end
    local ok, v = pcall(fn, ...)
    if ok then
        return str(v)
    end
    return nil
end

local function npc()
    return call(UnitName, "npc")
end

local function talk(kind, text, anchor)
    if not text then
        hide("g")
        return
    end
    local fa, key, s = D.Lookup(text)
    if fa then
        show(anchor, fa, "g")
    else
        hide("g")
        missed(kind, key, s, npc())
    end
end

local function on_gossip()
    if not on("dlgGossip") then
        hide("g")
        return
    end
    local text = call(C_GossipInfo and C_GossipInfo.GetText) or call(GetGossipText)
    talk("dlg", text, GossipFrame)
end

local function on_greeting()
    if not on("dlgGossip") then
        hide("g")
        return
    end
    talk("dlg", call(GetGreetingText), QuestFrame)
end

-- ------------------------------------------------------------------ books
local function on_book()
    if not on("dlgBook") then
        hide("b")
        return
    end
    local text = call(ItemTextGetText)
    if not text then
        hide("b")
        return
    end
    local title = call(ItemTextGetItem) or "?"
    local okp, page = pcall(ItemTextGetPage)
    page = okp and tonumber(page) or 1
    local fa, key, s = D.Lookup(text)
    if fa then
        show(ItemTextFrame, fa, "b")
    else
        hide("b")
        missed("book", key, s, title .. " p" .. tostring(page))
    end
end

-- ------------------------------------------------------------------ NPC speech
local SAY = { "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_MONSTER_EMOTE", "CHAT_MSG_MONSTER_WHISPER",
    "CHAT_MSG_MONSTER_PARTY", "CHAT_MSG_RAID_BOSS_EMOTE", "CHAT_MSG_RAID_BOSS_WHISPER" }

local function say_on()
    return on("dlgSay") and F.db.chatFa ~= false and not F.ShiftEn()
end

-- the chat / bubble line: markers -> plain Persian, colour codes out, shaped
local function line_fa(fa)
    local line = T.Prepare(fa)
    line = string.gsub(line, "|c%x%x%x%x%x%x%x%x", "")
    line = string.gsub(line, "|r", "")
    local ok, shaped = pcall(T.ShapeLine, T.Digits(line), T.Mode())
    return ok and str(shaped) or nil
end

-- Bubbles.lua asks for the Persian of an English bubble (raw Persian: it shapes it itself)
function D.BubbleFa(text)
    if not say_on() then
        return nil
    end
    local fa = D.Lookup(text)
    if not fa then
        return nil
    end
    local line = T.Prepare(fa)
    line = string.gsub(line, "|c%x%x%x%x%x%x%x%x", "")
    line = string.gsub(line, "|r", "")
    return str(line)
end

local last -- one watch entry per line (the filter runs once per chat window)
local function filter(_, _, msg, sender, ...)
    if not say_on() or not str(msg) then
        return false
    end
    local ok, fa, key, s = pcall(D.Lookup, msg)
    if not ok then
        return false
    end
    if fa then
        local shaped = line_fa(fa)
        if shaped then
            return false, shaped, sender, ...
        end
        return false
    end
    if key and last ~= key then
        last = key
        missed("say", key, s, str(sender))
    end
    return false
end

-- ------------------------------------------------------------------ Shift = English
local function on_modifier(_, key)
    if key ~= "LSHIFT" and key ~= "RSHIFT" then
        return
    end
    if not F.db or F.db.shiftEn == false then
        return
    end
    if pane and pane.fa then
        if visible_now() then
            pane:Show()
        else
            pane:Hide()
        end
    end
    -- the tooltip under the mouse shows again (English while Shift is down); never in
    -- combat (another frame's OnEnter is not ours to run then)
    if InCombatLockdown and InCombatLockdown() then
        return
    end
    local tt = GameTooltip
    if not (tt and tt.IsShown and tt:IsShown() and tt.GetOwner) then
        return
    end
    local owner = tt:GetOwner()
    if owner and owner.IsMouseOver and owner:IsMouseOver() and owner.GetScript then
        local fn = owner:GetScript("OnEnter")
        if type(fn) == "function" then
            pcall(fn, owner)
        end
    end
end

-- ------------------------------------------------------------------ wiring
local function safe(fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            F:LogError("dialog", err)
        end
    end
end

F:On("GOSSIP_SHOW", nil, safe(on_gossip))
F:On("QUEST_GREETING", nil, safe(on_greeting))
F:On("ITEM_TEXT_READY", nil, safe(on_book))
F:On("MODIFIER_STATE_CHANGED", nil, safe(on_modifier))
for _, e in ipairs({ "GOSSIP_CLOSED", "QUEST_DETAIL", "QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_FINISHED" }) do
    F:On(e, nil, safe(function()
        hide("g")
    end))
end
F:On("ITEM_TEXT_CLOSED", nil, safe(function()
    hide("b")
end))

local installed = false
local function install()
    if installed then
        return
    end
    installed = true
    for _, pair in ipairs({ { GossipFrame, "g" }, { QuestFrame, "g" }, { ItemTextFrame, "b" } }) do
        local fr, kind = pair[1], pair[2]
        if fr and fr.HookScript then
            pcall(fr.HookScript, fr, "OnHide", function()
                if pane and pane.anchor == fr then
                    hide(kind)
                end
            end)
        end
    end
    local add = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter) or ChatFrame_AddMessageEventFilter
    if type(add) == "function" then
        for _, e in ipairs(SAY) do
            pcall(add, e, filter)
        end
    end
end

F:Listen("login", safe(install))
-- a switch turned off in the panel takes the pane away at once
F:Listen("options", safe(function()
    if pane and pane.fa then
        local k = pane.kind == "b" and "dlgBook" or "dlgGossip"
        if not on(k) then
            hide()
        end
    end
end))
F:Listen("room", safe(function()
    if pane and pane.fa and not master() then
        hide()
    end
end))
