-- tiny WoW client mock (enough for WoWFA Forever); runs under Lua 5.1 AND 5.3
-- (WOWFA_LUA env in tests/forever/run.py; real WoW is 5.1-based, lane-a11)
unpack = unpack or table.unpack -- 5.1: global unpack already exists
math.atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
SECRET = setmetatable({}, { __tostring = function() return "<secret>" end })
issecretvalue = function(v) return v == SECRET end
local frames, timers = {}, {}
-- 47r5 D: panel_preview.py walks this registry to dump every page's widgets
-- (rects + colours + texts) for the owner PNGs. Read-only exposure.
_G.MOCK_FRAMES = frames
local function noop() end
Obj = {}
local mt = { __index = function(_, k) local v = Obj[k]; if v ~= nil then return v end; if k == "SetTalent" then return nil end; if type(k) == "string" and k:match("^%u") then return noop end end }
-- SetTalent is the one API the noop fallback must NOT fake: real clients
-- either have it (then GameTooltip carries the instance field below) or do
-- not (the 1.60.1 owner client, lane-b12) - a faked noop would make the
-- talents module's fallback detection impossible to test.
local function new(kind, name, parent)
    local o = setmetatable({ _kind = kind, _name = name, _shown = true, _scripts = {}, _w = 0, _h = 0, _events = {}, _parent = parent }, mt)
    if name then _G[name] = o end
    frames[#frames + 1] = o
    -- Brain review #136-6: real Buttons have NO SetFont - their text lives on
    -- the button's own font string (GetFontString); calling SetFont on a
    -- button must fail loudly here exactly like in the client
    if kind == "Button" then
        o.SetFont = false
        o._fontstring = new("FontString", nil, o)
        -- colon definitions add the implicit self already - an explicit self
        -- param here would shift every argument by one
        function o:SetText(t)
            self._fontstring._text = t
            self._text = t
        end
        function o:GetText()
            return self._fontstring._text -- like the real client: the label
        end
        function o:GetFontString()
            return self._fontstring
        end
    end
    return o
end
MOCK_CREATED = 0
MOCK_MEASURE = 0 -- lane-b13: every width measurement (the perf-test counter)
local function str_width(t)
    local t = tostring(t or "")
    local n = utf8 and (utf8.len(t) or #t) or select(2, t:gsub("[^\128-\191]", ""))
    return n * 6
end
-- inbox/44 B: real frame types the client accepts (case-sensitive)
-- 51-B (Brain review): GameTooltip is one of them - the room's hidden preview
-- tooltip (CreateFrame("GameTooltip", ..., "GameTooltipTemplate")) errored
-- here, so the preview and the selftest item path never ran in CI
local FRAME_KINDS = {
    Frame = true, Button = true, EditBox = true, ScrollFrame = true, Slider = true,
    CheckButton = true, StatusBar = true, ColorSelect = true, Cooldown = true,
    Model = true, ScrollingMessageFrame = true, MessageFrame = true, SimpleHTML = true,
    Browser = true, CinematicModel = true, FogOfWarFrame = true, GameTooltip = true,
}
function CreateFrame(kind, name, parent, template)
    if not FRAME_KINDS[kind] then
        error("Unknown frame type: " .. tostring(kind))
    end
    MOCK_CREATED = MOCK_CREATED + 1
    return new(kind, name, parent)
end
function Obj.SetScript(s, ev, fn) s._scripts[ev] = fn end
function Obj.GetScript(s, ev) return s._scripts[ev] end
function Obj.HookScript(s, ev, fn) local old = s._scripts[ev]; s._scripts[ev] = function(...) if old then old(...) end; fn(...) end end
function Obj.HasScript() return true end
function Obj.RegisterEvent(s, e) s._events[e] = true end
function Obj.Show(s) local was = s._shown; s._shown = true; if not was and s._scripts.OnShow then s._scripts.OnShow(s) end end
function Obj.Hide(s) local was = s._shown; s._shown = false; if was and s._scripts.OnHide then s._scripts.OnHide(s) end end
function Obj.IsShown(s) return s._shown end
function Obj.SetShown(s, v) if v then s:Show() else s:Hide() end end
function Obj.SetText(s, t) s._text = t end
function Obj.GetText(s) return s._text end
function Obj.GetStringWidth(s)
    MOCK_MEASURE = MOCK_MEASURE + 1
    local w = 0
    for seg in (tostring(s._text or "") .. "\n"):gmatch("([^\n]*)\n") do
        w = math.max(w, str_width(seg))
    end
    return w
end
function Obj.GetUnboundedStringWidth(s) return Obj.GetStringWidth(s) end
function Obj.GetStringHeight(s)
    local n = 1
    for _ in tostring(s._text or ""):gmatch("\n") do n = n + 1 end
    -- inbox/29 C: the line spacing grows the height like the real client
    local sp = s._spacing or 0
    return n * (14 + sp)
end
-- inbox/29 C: the line gap - recorded so tests can assert the spacing rule
function Obj.SetSpacing(s, sp) s._spacing = sp end
function Obj.GetSpacing(s) return s._spacing or 0 end
-- lane-b16: the real client rule this class of bug comes from - a font string
-- with word wrap OFF draws only the FIRST line of a multi-line text and
-- ellipsizes it; with wrap ON every "\n" line renders, and a line wider than
-- the string's fixed width RE-wraps (scrambling a manual RTL order).
function Obj.SetWordWrap(s, v) s._wrap = v end
function Obj.SetNonSpaceWrap(s, v) s._nsw = v end
function Obj.GetNumLines(s)
    local t = tostring(s._text or "")
    if s._wrap == false then
        return 1
    end
    local total = 0
    for seg in (t .. "\n"):gmatch("([^\n]*)\n") do
        local w = str_width(seg)
        if s._w and s._w > 0 and w > s._w then
            total = total + math.ceil(w / s._w)
        else
            total = total + 1
        end
    end
    return total
end
function Obj.IsTruncated(s)
    if s._wrap ~= false then
        return false -- wrap on: wide lines wrap instead of truncating
    end
    local first = tostring(s._text or ""):match("^([^\n]*)")
    if not (s._w and s._w > 0) then
        return false -- no fixed width: the string just grows
    end
    return str_width(first) > s._w
end
-- inbox/44 B: the client validates anchor points; the mock accepts any string
-- and hid the card() "LEFTTOP" bug from CI. Validate point AND relativePoint
-- against the 9 real points, case-sensitive, with the client's error text.
local REGION_POINTS = {
    TOPLEFT = true, TOP = true, TOPRIGHT = true,
    LEFT = true, CENTER = true, RIGHT = true,
    BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true,
}
local function check_point(p)
    if type(p) ~= "string" or not REGION_POINTS[p] then
        error("Unknown region point " .. tostring(p))
    end
end
-- lane-b16: record points so the harness can assert dock layouts (questDock)
function Obj.SetPoint(s, a, b, c, d, e)
    check_point(a)
    -- relativePoint is validated only when PRESENT with a region relativeTo:
    -- SetPoint("CENTER") and SetPoint("TOP", f) omit it (the client defaults
    -- it to the point) and SetPoint("TOP", x, y) passes numbers
    if c ~= nil and type(b) ~= "number" then
        check_point(c)
    end
    s._points = s._points or {}
    s._points[#s._points + 1] = { a, b, c, d, e }
    s._lastPoint = a
end
function Obj.SetAllPoints(s, rel)
    s._allPoints = rel or s._parent
end
-- inbox/44 B: the other cheap client-side validations
local JUSTIFY_H = { LEFT = true, CENTER = true, RIGHT = true }
local JUSTIFY_V = { TOP = true, MIDDLE = true, BOTTOM = true }
local FONT_FLAGS = { MONOCHROME = true, OUTLINE = true, THICKOUTLINE = true, GRAYOUT = true }
function Obj.SetJustifyH(s, j)
    if not JUSTIFY_H[j] then
        error("Unknown justifyh: " .. tostring(j))
    end
    s._just = j
end
function Obj.SetJustifyV(s, j)
    if not JUSTIFY_V[j] then
        error("Unknown justifyv: " .. tostring(j))
    end
    s._justv = j
end
function Obj.SetFont(s, f, sz, flags)
    if flags and flags ~= "" then
        for fl in flags:gmatch("[^,]+") do
            fl = fl:gsub("^%s+", ""):gsub("%s+$", "")
            if not FONT_FLAGS[fl] then
                error("Unknown font flag: " .. tostring(fl))
            end
        end
    end
    s._font, s._fsize, s._fflags = f, sz, flags
    return true
end
function Obj.SetSize(s, w, h) s._w, s._h = w, h end
function Obj.SetWidth(s, w) s._w = w end
function Obj.SetHeight(s, h) s._h = h end
function Obj.GetWidth(s) return s._w end
function Obj.GetHeight(s) return s._h end
-- inbox/29 D: the scale slider - the harness drives OnValueChanged directly,
-- but the bounds + value must be model-able for the tests
function Obj.SetMinMaxValues(s, a, b) s._min, s._max = a, b end
function Obj.SetValue(s, v) s._value = v end
function Obj.GetValue(s) return s._value end
function Obj.GetParent(s) return s._parent end
function Obj.SetParent(s, p) s._parent = p end -- the fā button re-parents per host
function Obj.GetFrameLevel(s) return s._level or 1 end
function Obj.SetFrameLevel(s, l) s._level = l end
function Obj.CreateTexture(s) return new("Texture", nil, s) end
function Obj.CreateFontString(s) return new("FontString", nil, s) end
function Obj.GetName(s) return s._name end
function Obj.GetFont(s) return s._font or "Fonts\\FRIZQT__.TTF", s._fsize or 12, "" end
function Obj.SetFont(s, f, sz) s._font, s._fsize = f, sz; return true end
-- inbox/27: font objects + text colour - the in-place restore test asserts the
-- ORIGINAL font object comes back, and the live quality colour is kept
function Obj.SetFontObject(s, f) s._fobj = f; s._font, s._fsize = nil, nil; return true end
function Obj.GetFontObject(s) return s._fobj end
function Obj.SetTextColor(s, r, g, b, a) s._tr, s._tg, s._tb, s._ta = r, g, b, a end
function Obj.GetTextColor(s) return s._tr or 1, s._tg or 1, s._tb or 1, s._ta or 1 end
function Obj.GetJustifyH(s) return s._just or "LEFT" end
function Obj.SetJustifyH(s, j) s._just = j end
function Obj.GetVerticalScroll() return 0 end
function Obj.GetCenter() return 100, 100 end
function Obj.GetEffectiveScale() return 1 end
function Obj.IsForbidden() return false end
function Obj.GetFrameLevel() return 1 end
function Obj.GetPoint() return "CENTER", nil, "CENTER", 10, 20 end
function Obj.GetRight() return 500 end
function Obj.SetScrollChild(s, c) s._child = c end
function Obj.NumLines(s) return s._n or 0 end
function Obj.AddLine(s, text)
    s._n = (s._n or 0) + 1
    local l = _G[s._name .. "TextLeft" .. s._n] or new("FontString", s._name .. "TextLeft" .. s._n)
    l._text = text
    local r = _G[s._name .. "TextRight" .. s._n] or new("FontString", s._name .. "TextRight" .. s._n)
    r._text = nil
end
function Obj.AddDoubleLine(s, a, b) s:AddLine(a); _G[s._name .. "TextRight" .. s._n]._text = b end
function Obj.ClearLines(s) s._n = 0; if s._scripts.OnTooltipCleared then s._scripts.OnTooltipCleared(s) end end
function Obj.SetOwner(s) s:ClearLines() end
function Obj.GetItem(s) return s._itemName, s._itemLink end
function Obj.GetUnit(s) return s._unitName, s._unit end
function Obj.TipLines(s)
    local out = {}
    for i = 1, s._n or 0 do
        local l, r = _G[s._name .. "TextLeft" .. i], _G[s._name .. "TextRight" .. i]
        out[#out + 1] = tostring(l._text) .. (r._text and ("  ||  " .. r._text) or "") .. ((l._font or ""):find("Vazir") and "  [fa-font]" or "")
    end
    return out
end

UIParent = new("Frame", "UIParent")
UIParent:SetSize(1920, 1080) -- inbox/44 D: the panel clamps in UIParent units
Minimap = new("Frame", "Minimap"); Minimap:SetSize(140, 140)
GameTooltip = new("GameTooltip", "GameTooltip")
ItemRefTooltip = new("GameTooltip", "ItemRefTooltip")
QuestFrame = new("Frame", "QuestFrame"); QuestFrame:SetSize(384, 512); QuestFrame._shown = false
QuestLogFrame = new("Frame", "QuestLogFrame"); QuestLogFrame:SetSize(384, 512); QuestLogFrame._shown = false
SubZoneTextString = new("FontString", "SubZoneTextString")
MinimapZoneTextButton = new("Button", "MinimapZoneTextButton")
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) print("CHAT: " .. m:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end }
UISpecialFrames = {}
SlashCmdList = {}
function GameTooltip.SetTalent() end
-- 96 B: the spell tooltip path. SetSpellByID builds the live tooltip (the game
-- fills it from C_Spell.GetSpellDescription), then the secure hook translates.
-- Tests seed MOCK.spellDesc[id] = { name, description... } - the live EN lines
-- exactly as the client shows them (one description string per line, both
-- paragraphs included: the client hands the whole description as one leftText).
function GameTooltip.SetSpellByID(s, id)
    s:ClearLines()
    local rec = MOCK.spellDesc and MOCK.spellDesc[id]
    if rec then
        s:AddLine(rec[1])
        for i = 2, #rec do s:AddLine(rec[i]) end
    end
end
function GameTooltip.SetSpell(s, id) return GameTooltip.SetSpellByID(s, id) end
function GameTooltip.SetSpellBookItem(s, id) return GameTooltip.SetSpellByID(s, id) end
C_Spell = C_Spell or { GetSpellDescription = function(id)
    local rec = MOCK.spellDesc and MOCK.spellDesc[id]
    return rec and rec[2] or nil
end }
function wipe(t) for k in pairs(t) do t[k] = nil end; return t end
tinsert = table.insert
function hooksecurefunc(a, b, c)
    local tbl, name, fn = a, b, c
    if type(a) == "string" then tbl, name, fn = _G, a, b end
    local orig = tbl[name]
    tbl[name] = function(...) local r = { orig(...) }; fn(...); return (unpack or table.unpack)(r) end
end
TooltipDataProcessor = { cbs = {} }
function TooltipDataProcessor.AddTooltipPostCall(t, fn) TooltipDataProcessor.cbs[t] = TooltipDataProcessor.cbs[t] or {}; table.insert(TooltipDataProcessor.cbs[t], fn) end
Enum = { TooltipDataType = { Item = 0, Spell = 1, Unit = 2, Object = 33 } }
function RunTip(kind, tt, data) for _, fn in ipairs(TooltipDataProcessor.cbs[Enum.TooltipDataType[kind]] or {}) do fn(tt, data) end end
C_Timer = { After = function(s, fn) table.insert(timers, fn) end }
function RunTimers() local n = 0; while #timers > 0 and n < 200 do local fn = table.remove(timers, 1); fn(); n = n + 1 end end
C_ChatInfo = { RegisterAddonMessagePrefix = function() return true end, SendAddonMessage = function(p, m, c) print("SEND", p, m, c) end }
MOCK = { build = "70800", questID = 0, title = "", zone = "Ashenvale", sub = "Splintertree Post", inInst = false, itype = "none", unitName = nil, guids = {}, merchant = {}, loot = {}, questTexts = {}, locale = "enUS" }
MOCK.itemNames = {} -- id -> client-side name; the client item lookups resolve only these (lane-a11 C)
function GetItemInfo(id) return MOCK.itemNames[id] end
C_Item = C_Item or {}
-- the real client answers this from its own item table (no cache); the mock knows only MOCK.itemNames
function C_Item.GetItemInfoInstant(id) if MOCK.itemNames[id] then return id end end
function GetBuildInfo() return MOCK.version or "1.60.1", MOCK.build, "Nov 4 2026", 16001 end
function GetAddOnMetadata(_, f) if f == "Version" then return "0.5.0" end end
function UnitName(u) if u == "player" then return MOCK.playerName or "Tester" end; return MOCK.unitName end
function UnitGUID(u) return MOCK.guids[u] end
function UnitLevel(u) return MOCK.unitLevel or 30 end
function UnitClassification(u) return MOCK.unitClass or "normal" end
function UnitIsPlayer(u) return MOCK.playerUnit == u end
function UnitPlayerControlled(u) return MOCK.controlledUnit == u end
function UnitIsDead(u) return MOCK.dead end
function IsFishingLoot() return MOCK.fishing or false end
function GetLocale() return MOCK.locale or "enUS" end
function GetMerchantNumItems() return #MOCK.merchant end
function GetMerchantItemID(i) return MOCK.merchant[i] and MOCK.merchant[i].id end
function GetMerchantItemInfo(i)
    -- REAL order (warcraft.wiki.gg API_GetMerchantItemInfo): name, texture,
    -- price, quantity, numAvailable, isPurchasable, isUsable, extendedCost
    local m = MOCK.merchant[i]
    if not m then return nil end
    return m.name or "Item", m.texture or 132353, m.price, m.stack, m.limited, true, true, m.ext
end
function GetNumLootItems() return #MOCK.loot end
function GetLootSlotInfo(slot)
    local m = MOCK.loot[slot]
    if MOCK.lootBoom and slot == 1 then error("loot api kaboom") end
    if not m then return nil end
    local link = m.link
    if not link and m.id then link = "|cff9d9de9|Hitem:" .. m.id .. ":0:0:0:0:0:0:0:0|h[Thing]|h|r" end
    return m.kind or "item", link, m.qty or 1 -- money slots: kind "money", no link
end
function GetLootSourceInfo(slot)
    -- REAL vararg: guid, quantity, guid, quantity, ...
    local m = MOCK.loot[slot]
    if not m then return nil end
    if type(m.src) == "table" then return unpack(m.src) end
    return m.src, m.sqty or 1
end
function GetQuestText() return MOCK.questTexts.d end
function GetObjectiveText() return MOCK.questTexts.o end
function GetProgressText() return MOCK.questTexts.p end
function GetRewardText() return MOCK.questTexts.c end
function GetNumQuestRewards() return MOCK.qRewards and #MOCK.qRewards or 0 end
function GetNumQuestChoices() return MOCK.qChoices and #MOCK.qChoices or 0 end
function GetQuestItemLink(what, i)
    local list = what == "reward" and MOCK.qRewards or MOCK.qChoices
    return list and list[i] and ("|cff007ddd|Hitem:" .. list[i] .. ":0:0:0:0:0:0:0:0|h[Reward]|h|r") or nil
end
function GetQuestItemInfo() return "Reward Item", nil, 1, 1, true end
function GetRewardMoney() return MOCK.qMoney end
function GetRewardXP() return MOCK.qXp end
C_Map = {
    GetBestMapForUnit = function(u) return MOCK.mapId or 141 end,
    GetPlayerMapPosition = function(m, u) return { x = MOCK.px or 0.1234, y = MOCK.py or 0.5678 } end,
}
function UnitClass() return "Hunter", "HUNTER" end
function UnitRace() return "Orc", "Orc" end
function UnitSex() return MOCK.sex or 2 end
function UnitIsPlayer() return false end
function GetQuestID() return MOCK.questID end
function GetTitleText() return MOCK.title end
function GetQuestLogSelection() return MOCK.logIdx or 0 end
function GetQuestLogTitle(i)
    local e = (MOCK.logList or {})[i or MOCK.logIdx or 0]
    if e then return e.title, 10, nil, e.isHeader and true or false, false, false, nil, e.id end
    return MOCK.logTitle, 10, nil, false, false, false, nil, MOCK.logQuest
end
function GetRealZoneText() return MOCK.zone end
function GetSubZoneText() return MOCK.sub end
function IsInInstance() return MOCK.inInst, MOCK.itype end
function InCombatLockdown() return MOCK.combat or false end
function GetTime() return MOCK.now or os.clock() end
function time() return MOCK.now or os.time() end
function IsInGuild() return true end
function IsInRaid() return false end
function IsInGroup() return false end
function Ambiguate(s) return s end
function GetCursorPosition() return 150, 100 end
function IsShiftKeyDown() return false end
function GetTalentInfo() return "Improved Aspect of the Hawk" end
function UpdateAddOnMemoryUsage() end
function GetAddOnMemoryUsage() return 20480 end
function CreateColor(r, g, b, a) return { r, g, b, a } end
Settings = { RegisterCanvasLayoutCategory = function() return {} end, RegisterAddOnCategory = function() end }
-- ------------------------------------------------- lane-28 tracker mocks
MOCK.minimapZone = ""
MOCK.watchLines = {}     -- QuestWatchLine%d contents (re-set by the client updates)
MOCK.otfBlocks = {}      -- ObjectiveTrackerFrame blocks { id, header, lines }
MOCK.logList = {}        -- GetQuestLogTitle(i) entries { title, isHeader, id }
MOCK.qObjectives = {}    -- questid -> { { type, text, numFulfilled, numRequired } }
MOCK.qTitles = {}        -- questid -> EN title (C_QuestLog.GetTitleForQuestID)
MOCK.gossipButtons = {}  -- QuestTitleButton%d texts
MinimapZoneText = new("FontString", "MinimapZoneText")
ZoneTextString = new("FontString", "ZoneTextString")
PVPInfoTextString = new("FontString", "PVPInfoTextString")
WorldMapFrameAreaLabel = new("FontString", "WorldMapFrameAreaLabel")
QuestWatchFrame = new("Frame", "QuestWatchFrame"); QuestWatchFrame._shown = false
WatchFrame = new("Frame", "WatchFrame"); WatchFrame._shown = false
ObjectiveTrackerFrame = new("Frame", "ObjectiveTrackerFrame"); ObjectiveTrackerFrame._shown = false
ObjectiveTrackerFrame.blocks = {}
ObjectiveTrackerFrame.Modules = { { id = "quest", Update = function() MOCK_SetOTF(MOCK.otfBlocks) end } }
local watchCreated, gossipCreated = 0, 0
function MOCK_SetWatchLines(list)
    MOCK.watchLines = list or {}
    for i = 1, math.max(#MOCK.watchLines, watchCreated) do
        local fs = _G["QuestWatchLine" .. i] or new("FontString", "QuestWatchLine" .. i)
        watchCreated = math.max(watchCreated, i)
        fs._text = MOCK.watchLines[i]
    end
end
function QuestWatch_Update() MOCK_SetWatchLines(MOCK.watchLines) end
function WatchFrame_Update() MOCK_SetWatchLines(MOCK.watchLines) end
function MOCK_SetOTF(blocks)
    MOCK.otfBlocks = blocks or {}
    ObjectiveTrackerFrame.blocks = {}
    for i, b in ipairs(MOCK.otfBlocks) do
        local header = _G["OTFHeader" .. i] or new("FontString", "OTFHeader" .. i)
        header._text = b.header
        local lines = {}
        for j, ln in ipairs(b.lines or {}) do
            local fs = _G["OTFLine" .. i .. "_" .. j] or new("FontString", "OTFLine" .. i .. "_" .. j)
            fs._text = ln
            lines[#lines + 1] = fs
        end
        ObjectiveTrackerFrame.blocks[i] = { id = b.id, HeaderText = header, lines = lines }
    end
end
function GetMinimapZoneText() return MOCK.minimapZone or "" end
function Minimap_Update() MinimapZoneText:SetText(GetMinimapZoneText()) end
function MOCK_SetGossip(list)
    MOCK.gossipButtons = list or {}
    for i = 1, math.max(#MOCK.gossipButtons, gossipCreated) do
        local b = _G["QuestTitleButton" .. i] or new("Button", "QuestTitleButton" .. i)
        gossipCreated = math.max(gossipCreated, i)
        -- set the label like the client does: through the button's font string
        -- (the addon itself only ever writes to GetFontString(), never to the
        -- button's own SetText)
        b._fontstring._text = MOCK.gossipButtons[i]
        b._text = b._fontstring._text
    end
end
C_QuestLog = C_QuestLog or {}
function C_QuestLog.GetQuestObjectives(id) return MOCK.qObjectives[id] end
function C_QuestLog.GetTitleForQuestID(id) return (MOCK.qTitles or {})[id] end
function C_QuestLog.GetSelectedQuest() return MOCK.selectedQuest end
QUEST_MONSTERS_KILLED = "%s slain: %d/%d"
QUEST_ITEMS_NEEDED = "%s: %d/%d"
QUEST_OBJECTS_FOUND = "%s: %d/%d"
QUEST_FACTION_NEEDED = "%s: %d/%d"
function Obj.GetJustifyV(s) return s._justv or "TOP" end

-- all FontStrings under `root` (inclusive), as { fs = o, x, y, w, h }, in the
-- root's own "from TOP-RIGHT corner" units: x = distance from the RIGHT edge
-- (leftward positive), y = distance from the TOP (downward positive). The
-- anchor chain resolves through parent frames; the root itself is the origin.
local function region_box(o, root)
    if o == root then
        return 0, 0, o._w or 0, o._h or 0
    end
    if o._allPoints then
        local x, y, w, h = region_box(o._allPoints, root)
        if x then
            return x, y, w, h
        end
    end
    if not o._points then
        return nil
    end
    local p = o._points[1]
    local w = o._w or 0
    local h = o._h or 0
    local rel = p[2]
    local relx, rely, relw, relh
    if type(rel) == "table" and rel ~= o then
        relx, rely, relw, relh = region_box(rel, root)
    elseif o._parent then
        relx, rely, relw, relh = region_box(o._parent, root)
    end
    if not relx then
        return nil
    end
    local a = p[1]
    local xoffs, yoffs = p[4] or 0, p[5] or 0
    local x, y
    if a:find("RIGHT") then
        x = relx + xoffs
    elseif a:find("LEFT") then
        x = relx + relw - xoffs - w
    elseif a == "CENTER" then
        x = relx + relw / 2 - w / 2
    else
        x = relx
    end
    if a:find("TOP") then
        y = rely + yoffs
    elseif a:find("BOTTOM") then
        y = rely + relh + yoffs - h
    else
        y = rely + relh / 2 - h / 2
    end
    return x, y, w, h
end

function MOCK_PageRects(root)
    local out = {}
    local function walk(o)
        if o._kind == "FontString" and o._text and o._text ~= "" then
            local x, y, w, h = region_box(o, root)
            if x and y then
                local ww = (o._w and o._w > 0) and o._w or o:GetStringWidth()
                out[#out + 1] = { fs = o, x = x, y = y, w = ww, h = h }
            end
        end
        for _, f in ipairs(frames) do
            if f._parent == o then
                walk(f)
            end
        end
    end
    walk(root)
    return out
end

function MOCK_Overlap(page)
    -- no two FontStrings on one page intersect (inbox/44 D)
    local rs = MOCK_PageRects(page.child or page)
    for i = 1, #rs do
        for j = i + 1, #rs do
            local a, b = rs[i], rs[j]
            if a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h then
                return ("overlap: [%s] and [%s] at %s/%s"):format(
                    tostring(a.fs._text):sub(1, 18), tostring(b.fs._text):sub(1, 18),
                    tostring(a.x) .. "," .. tostring(a.y), tostring(b.x) .. "," .. tostring(b.y))
            end
        end
    end
    return nil
end

function FireEvent(e, ...)
    for _, f in ipairs(frames) do if f._events[e] and f._scripts.OnEvent then f._scripts.OnEvent(f, e, ...) end end
    -- 104 STEP A: the legacy suites predate the v1.0 release lock - the mock
    -- unlocks the locked kinds by default so they test the pre-lock mechanics;
    -- a suite that tests the LOCK itself sets WOWFA_TEST_UNLOCK = false before
    -- its addon load (release_lock_a.lua).
    if e == "PLAYER_ENTERING_WORLD" and WOWFA_TEST_UNLOCK ~= false and WoWFAF and WoWFAF.RELEASE_LOCK then
        for k in pairs(WoWFAF.RELEASE_LOCK) do
            WoWFAF.RELEASE_UNLOCK[k] = true
        end
        WoWFAF:Refresh()
    end
end
function Click(b, button) assert(b and b._scripts.OnClick, "no OnClick"); b._scripts.OnClick(b, button or "LeftButton") end
function AllFrames() return frames end
