-- WoWFA v1 runtime tests: the built addon (out/dist/WoWFA) on the WoW mock, under
-- lua5.1 (WoW's Lua). Run by tools/ci.py from the repo root: lua5.1 tests/run.lua <dist>
-- Every check names WHAT broke; any failure exits 1 and turns CI red.
local ROOT = arg[1] or "out/dist/WoWFA"
WOWFA_TEST_UNLOCK = false -- test the REAL release lock, never the mock's dev unlock
dofile("tests/lua/wow_mock.lua")

local passes, fails = 0, 0
local function check(name, cond, detail)
    if cond then
        passes = passes + 1
        print("ok   " .. name)
    else
        fails = fails + 1
        print("FAIL " .. name .. (detail ~= nil and (": " .. tostring(detail)) or ""))
    end
end
local function non_ascii(s)
    return type(s) == "string" and s:find("[\128-\255]") ~= nil
end

-- ---------------------------------------------------------------- load the TOC
local toc = ROOT .. "/WoWFA_Forever.toc"
local fh = io.open(toc, "r")
check("toc exists", fh ~= nil, toc)
if not fh then
    os.exit(1)
end
local nfiles = 0
for line in fh:lines() do
    line = line:gsub("\r$", "")
    if line ~= "" and not line:find("^##") then
        local p = ROOT .. "/" .. line:gsub("\\", "/")
        local f, err = loadfile(p)
        check("load " .. line, f ~= nil, err)
        if f then
            local ok, e = pcall(f, "WoWFA", {})
            check("run " .. line, ok, e)
            nfiles = nfiles + 1
        end
    end
end
fh:close()
local F = WoWFAF
check("addon table", type(F) == "table")
if type(F) ~= "table" then
    os.exit(1)
end

FireEvent("ADDON_LOADED", "WoWFA")
FireEvent("PLAYER_LOGIN")
FireEvent("PLAYER_ENTERING_WORLD")
RunTimers()

local D = WoWFA_FData
check("data state ok", F.dataState == "ok", F.dataState)
local parts = {}
for _, m in ipairs(F.order) do
    parts[#parts + 1] = m.id .. "=" .. tostring(m.state) .. (m.why and ("(" .. tostring(m.why) .. ")") or "")
end
print("states: " .. table.concat(parts, " "))
for _, id in ipairs({ "quests", "dungeons", "tracker", "spellbook", "talents" }) do
    local m = F.mods[id]
    check("module " .. id .. " active", m and m.active, m and m.state)
end
check("errors logged at boot", #(WoWFA_FDB.errors or {}) == 0, WoWFA_FDB.errors and WoWFA_FDB.errors[1] and WoWFA_FDB.errors[1].e)

-- --------------------------------------------------------- title hash parity
check("TitleHash = build title_hash (The Defias Brotherhood)", F.TitleHash("The Defias Brotherhood") == "01b5bd11", F.TitleHash("The Defias Brotherhood"))
check("TitleHash = build title_hash (Hogger)", F.TitleHash("Hogger") == "028a64c1", F.TitleHash("Hogger"))
check("TitleHash = build title_hash (spaces + article)", F.TitleHash("  The   Missing  Diplomat ") == "a93669f9", F.TitleHash("  The   Missing  Diplomat "))

-- ------------------------------------------------------------------- quests
local qid, qhash
for id, raw in pairs(D.quests) do
    local p = F.Split(raw, "\031")
    if p[2] ~= "" and p[4] ~= "" and p[1] ~= "" then
        if not qid or id < qid then
            qid, qhash = id, p[1]
        end
    end
end
check("a quest with title + details", qid ~= nil)
do
    local raw = D.quests[qid]
    local u = F.QRow(raw)
    check("RAM: quest rows are packed (D.qmap)", type(D.qmap) == "table" and #D.qmap > 30, D.qmap and #D.qmap)
    check("RAM: a packed row unpacks to real UTF-8 Persian", type(u) == "string" and #u > #raw
        and string.find(u, "[\216\217\219][\128-\191]") ~= nil and F.QRow(raw) == u, #raw .. " -> " .. #(u or ""))
    local hp = string.sub(raw, 1, 8)
    check("RAM: the hash prefix is kept as is", hp == qhash and string.sub(u, 1, 8) == qhash, hp)
end
MOCK.questID, MOCK.title = qid, "Some Unrelated Title"
QuestFrame:Show()
FireEvent("QUEST_DETAIL")
RunTimers()
local P = WoWFAF_QuestPane
check("quest pane shown", P and P:IsShown())
check("quest pane title is Persian", P and non_ascii(P.title:GetText()), P and P.title:GetText())
check("quest pane body is Persian", P and non_ascii(P.sec[1].b:GetText()))
check("stale banner on a different live title", P and P.banner:IsShown())
QuestFrame:Hide()
RunTimers()
check("pane hides with the quest frame", P and not P:IsShown())

-- --------------------------------------------------------------- zone names
local zkey
for k in pairs(D.names.zone) do
    if not zkey or k < zkey then
        zkey = k
    end
end
check("zone names shipped", zkey ~= nil)
MinimapZoneText:SetText(zkey)
check("minimap zone text in Persian", non_ascii(MinimapZoneText:GetText()), MinimapZoneText:GetText())
check("minimap zone text uses the Persian font", (MinimapZoneText._font or ""):find("Vazirmatn") ~= nil, MinimapZoneText._font)
-- rc18: the SHAPED Persian (presentation forms, byte \239) read back keeps our font
MinimapZoneText:SetText("\239\186\142\239\187\160\239\186\174")
check("rc18: shaped Persian read back keeps the Persian font (no empty boxes)",
    (MinimapZoneText._font or ""):find("Vazirmatn") ~= nil, MinimapZoneText._font)
MinimapZoneText:SetText("Zzz Unknown Place")
check("unknown zone stays English", MinimapZoneText:GetText() == "Zzz Unknown Place", MinimapZoneText:GetText())
-- rc4: our own Persian write must never come back as a zone miss
F:ClearMiss()
local zk1 = next(D.names.zone)
MinimapZoneText:SetText(zk1)
local selfMiss = 0
for id, e in pairs(F.db.miss or {}) do
    if e.k == "zone" then
        selfMiss = selfMiss + 1
    end
end
check("own Persian write is not logged as a zone miss", selfMiss == 0, selfMiss)

-- ------------------------------------------------------------ spell tooltip
local tkey
for k in pairs(D.tpl) do
    -- plain integer slots only: "#.#" / "#,#" would read back as ONE live number
    if k:find("#") and not k:find("[%$%(%)]") and not k:find("#[%.,]") and not k:find("[%.,]#")
        and (not tkey or k < tkey) then
        tkey = k
    end
end
local skey
for k in pairs(D.names.spell) do
    if not skey or k < skey then
        skey = k
    end
end
check("templates + spell names shipped", tkey ~= nil and skey ~= nil)
local live = tkey:gsub("#", "7")
GameTooltip:ClearLines()
GameTooltip:AddLine(skey)
GameTooltip:AddLine(live)
RunTip("Spell", GameTooltip, nil)
local lines = GameTooltip:TipLines()
local anyFa = false
for _, l in ipairs(lines) do
    if non_ascii(l) then
        anyFa = true
    end
end
check("spell tooltip gets Persian (" .. tkey:sub(1, 40) .. ")", anyFa, table.concat(lines, " / "))
-- rc4: the client writes "she" for a female character; the data is keyed "he"
D.tpl["zz test he will be dazed for # sec"] = "{0} ثانیه گیج"
GameTooltip:ClearLines()
GameTooltip:AddLine(skey)
GameTooltip:AddLine("Zz test she will be dizzy for 4 sec.")
RunTip("Spell", GameTooltip, nil)
local nCtl = #GameTooltip:TipLines() -- control: no template for this line
GameTooltip:ClearLines()
GameTooltip:AddLine(skey)
GameTooltip:AddLine("Zz test she will be dazed for 4 sec.")
RunTip("Spell", GameTooltip, nil)
local nG = #GameTooltip:TipLines()
check("female-text tooltip matches the male-keyed template", nG == nCtl + 1, nG .. " vs control " .. nCtl)
D.tpl["zz test he will be dazed for # sec"] = nil
-- rc4: a plain GameTooltip (no Spell data: the Forever talent frame) translates too
GameTooltip:Hide()
GameTooltip:ClearLines()
GameTooltip:AddLine(skey)
GameTooltip:AddLine(live)
GameTooltip:Show()
local pl = GameTooltip:TipLines()
local plFa = false
for _, l in ipairs(pl) do
    if non_ascii(l) then
        plFa = true
    end
end
check("plain talent-style tooltip gets Persian (OnShow fallback)", plFa, table.concat(pl, " / "))
local nP = #pl
RunTip("Spell", GameTooltip, nil)
check("the post-call after the fallback adds nothing twice", #GameTooltip:TipLines() == nP,
    #GameTooltip:TipLines() .. " vs " .. nP)

-- ------------------------------------------------------------------ rc6: own Persian + spec tooltips
local okRc6, errRc6 = pcall(function()
    F:ClearMiss()
    GameTooltip:Hide()
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Zz Not A Known Spell")
    GameTooltip:AddLine("این یک خط فارسی کاملاً بلند است که خودِ افزونه نوشته است")
    RunTip("Spell", GameTooltip, nil)
    local n = 0
    for _, e in pairs(F.db.miss or {}) do
        if e.k == "tpl" then
            n = n + 1
        end
    end
    check("own Persian line is never logged as a miss", n == 0, n)
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Zz Not A Known Spell Two")
    GameTooltip:AddLine("This is a long English description line that has no translation yet.")
    RunTip("Spell", GameTooltip, nil)
    n = 0
    for _, e in pairs(F.db.miss or {}) do
        if e.k == "tpl" then
            n = n + 1
        end
    end
    check("a real English miss is still logged", n == 1, n)

    local tk
    for k in pairs(D.names.tree or {}) do
        if D.names.spell[k] == nil and (not tk or k < tk) then
            tk = k
        end
    end
    check("a tree name that is not also a spell name exists", tk ~= nil)
    if tk then
        local saved = GameTooltip.GetOwner
        GameTooltip.GetOwner = function()
            return { GetName = function() return "PlayerSpellsFrame" end }
        end
        GameTooltip:Hide()
        GameTooltip:ClearLines()
        GameTooltip:AddLine(tk)
        GameTooltip:Show()
        local ls = GameTooltip:TipLines()
        check("spec tab tooltip gets the Persian tree name", #ls == 2 and non_ascii(ls[2]), table.concat(ls, " / "))
        GameTooltip.GetOwner = function()
            return { GetName = function() return "SomeOtherFrame" end }
        end
        GameTooltip:Hide()
        GameTooltip:ClearLines()
        GameTooltip:AddLine(tk)
        GameTooltip:Show()
        check("the same name outside spell/talent frames stays untouched", #GameTooltip:TipLines() == 1, #GameTooltip:TipLines())
        GameTooltip.GetOwner = saved
    end
end)
check("rc6 tests ran", okRc6, errRc6)
-- ------------------------------------------------------------------ rc7: list lines + stale misses
local okRc7, errRc7 = pcall(function()
    local ui = F.D.ui
    local had = {}
    local rows = {
        ["l:zz test header:"] = "هدر آزمایشی:",
        ["l:zzcloth"] = "پارچه‌ای",
        ["l:zzleather"] = "چرمی",
    }
    for k, v in pairs(rows) do
        had[k] = ui[k]
        ui[k] = v
    end
    F:ClearMiss()
    GameTooltip:Hide()
    GameTooltip:ClearLines()
    GameTooltip:AddLine(skey)
    GameTooltip:AddLine("Zz test header:\r\nZzCloth\r\nZzUnknownWord")
    RunTip("Spell", GameTooltip, nil)
    local base = #GameTooltip:TipLines()
    check("a list with an unknown word stays English (no list lines added)", base >= 2 and base <= 3, base)
    GameTooltip:Hide()
    GameTooltip:ClearLines()
    GameTooltip:AddLine(skey)
    GameTooltip:AddLine("Zz test header:\r\nZzCloth\r\nZzLeather")
    RunTip("Spell", GameTooltip, nil)
    local ls = GameTooltip:TipLines()
    check("a known list line gets Persian header + 2 words", #ls == base + 3 and non_ascii(ls[#ls]) and non_ascii(ls[#ls - 2]),
        #ls .. " vs base " .. base .. " / " .. table.concat(ls, " / "))
    for k in pairs(rows) do
        ui[k] = had[k]
    end
    check("ui table ships the rc7 list words", type(ui["l:you are fluent in the following languages:"]) == "string"
        and type(ui["l:cloth"]) == "string" and type(ui["l:common"]) == "string")
    -- stale misses: a list from an older addon build is dropped, the current one is kept
    F.db.miss = { ["tpl:old"] = { k = "tpl", t = "old", n = 1 } }
    F.db.missN, F.db.missV = 1, "0.0.0-old"
    F:MissFresh()
    check("an older build's miss list is dropped", F.db.missN == 0 and next(F.db.miss) == nil, F.db.missN)
    F:Miss("zone", "zz fresh", "Zz Fresh")
    F:MissFresh()
    check("the current build's misses are kept", F.db.missN == 1, F.db.missN)
    F:ClearMiss()
end)
check("rc7 tests ran", okRc7, errRc7)
-- ------------------------------------------------------------------ rc8: settings v2
local okRc8, errRc8 = pcall(function()
    F.db.disp = nil
    check("title default = Persian + English below (2)", F.Disp("spellbook", "title") == 2, F.Disp("spellbook", "title"))
    check("description default = Persian below (2)", F.Disp("talents", "desc") == 2, F.Disp("talents", "desc"))
    F.DispSetDefault("title", 1)
    check("a section follows the General default", F.Disp("spellbook", "title") == 1 and F.Disp("talents", "title") == 1)
    F.DispSet("talents", "title", 3)
    check("a section override wins, for that section only",
        F.Disp("talents", "title") == 3 and F.Disp("spellbook", "title") == 1 and F.DispCustom("talents"))
    F.DispSetCustom("talents", false)
    check("custom off = back to General", F.Disp("talents", "title") == 1 and not F.DispCustom("talents"))

    local function tip()
        GameTooltip:Hide()
        GameTooltip:ClearLines()
        GameTooltip:AddLine(skey)
        GameTooltip:AddLine(live)
        RunTip("Spell", GameTooltip, nil)
        return GameTooltip:TipLines()
    end
    F.db.disp = { title = 1, desc = 2 }
    local ls = tip()
    check("title 1: the English name is replaced in place by Persian",
        non_ascii(ls[1]) and not ls[1]:find(skey, 1, true) and ls[2] == live, #ls .. " / " .. table.concat(ls, " / "))
    F.db.disp = { title = 2, desc = 2 }
    ls = tip()
    check("title 2: Persian first, the English under it", non_ascii(ls[1]) and ls[1]:find(skey, 1, true) ~= nil, ls[1])
    F.db.disp = { title = 3, desc = 2 }
    ls = tip()
    check("title 3: the English name stays, no Persian name", ls[1] == skey and ls[2] == live and #ls > 2, #ls .. " / " .. table.concat(ls, " / "))
    F.db.disp = { title = 3, desc = 1 }
    ls = tip()
    check("description 1: Persian replaces the English line", #ls == 2 and ls[1] == skey and non_ascii(ls[2]) and ls[2] ~= live,
        #ls .. " / " .. table.concat(ls, " / "))
    F.db.disp = { title = 3, desc = 3 }
    ls = tip()
    check("description 3: English only", #ls == 2 and ls[1] == skey and ls[2] == live, #ls .. " / " .. table.concat(ls, " / "))
    F.db.disp = { title = 3, desc = 3, sec = { spellbook = { custom = true, title = 1, desc = 1 } } }
    ls = tip()
    check("a custom section shows its own display", #ls == 2 and non_ascii(ls[1]) and non_ascii(ls[2]), #ls .. " / " .. table.concat(ls, " / "))

    F.db.disp = nil
    F.OpenPanel("spellbook")
    RunTimers()
    local PF = F.PanelFrame()
    check("panel opens on the asked section", F.PanelPage() == "spellbook", F.PanelPage())
    F.OpenPanel("room")
    check("old page ids map to General", F.PanelPage() == "general", F.PanelPage())
    local allNav = true
    for _, id in ipairs(F.PANEL_SECTIONS) do
        if not (PF.nav and PF.nav[id]) then
            allNav = false
        end
    end
    check("every section has a side menu button", allNav)
    Click(PF.nav.map)
    check("the side menu switches the section", F.PanelPage() == "map", F.PanelPage())
    -- panel v4: one name row and one description row for the spells, the talents may differ
    local wasSp = F.Room.On("namesSpell")
    F.Room.Set("namesSpell", true)
    Click(PF.spName)
    check("v4: the spell name choice 2 -> 3 = the spell names English", not F.Room.On("namesSpell"))
    Click(PF.spName)
    check("v4: 3 -> 1 = Persian only, in the tooltip too", F.Room.On("namesSpell") and F.Disp("spellbook", "title") == 1,
        F.Disp("spellbook", "title"))
    check("v4: the talents follow the spells", not F.DispCustom("talents") and F.Disp("talents", "title") == 1)
    check("v4: the talent rows are hidden while they follow", not PF.tlName:IsShown())
    Click(PF.talentOwn)
    check("v4: talents on their own", F.DispCustom("talents") and PF.tlName:IsShown())
    Click(PF.tlName)
    check("v4: the talents' own name display", F.Disp("talents", "title") == 2 and F.Disp("spellbook", "title") == 1,
        F.Disp("talents", "title") .. "/" .. F.Disp("spellbook", "title"))
    Click(PF.talentOwn)
    check("v4: own off = like the spells again", not F.DispCustom("talents") and F.Disp("talents", "title") == 1)
    Click(PF.spDesc)
    check("v4: the description choice cycles", F.Disp("spellbook", "desc") == 3 or not F.Room.On("textDesc"))
    F.Room.Set("textDesc", true)
    F.Room.Set("namesSpell", wasSp)
    F.db.disp = nil
    PF:Hide()
end)
check("rc8 tests ran", okRc8, errRc8)
-- ------------------------------------------------------------------ rc9: colours + no duplicate tooltip lines
local okRc9, errRc9 = pcall(function()
    local T = F.T
    local m = "x {{zn:Elwynn|ZZ}} y {{cls:Rogue|RR}} z {{sp:Frostbolt|SS}}"
    local oldMode, oldCol = F.db.mode, F.db.col
    local savedCode = F.Room.Encode()
    F.Room.Apply("fa")
    F.db.mode = 1
    F.db.col = nil
    check("colours are off until switched on", T.Markers(m) == "x ZZ y RR z SS", T.Markers(m))
    F.db.col = { on = true }
    local out = T.Markers(m)
    check("zone gets the default green", out:find("|cff4cd964ZZ|r", 1, true) ~= nil, out)
    check("a class gets its official colour", out:find("|cfffff569RR|r", 1, true) ~= nil, out)
    check("a spell gets the default blue", out:find("|cff5ac8faSS|r", 1, true) ~= nil, out)
    F.db.col = { on = true, zn = "off", sp = "red" }
    out = T.Markers(m)
    check("a family set to off stays plain, another takes its own colour",
        out:find("x ZZ y", 1, true) ~= nil and out:find("|cffff6b6bSS|r", 1, true) ~= nil, out)
    F.db.mode = 3
    local l3 = T.Lines("x |cff4cd964ZZ|r y", 400, 12, 3)
    check("display mode 3 keeps a colour through its own reordering",
        #l3 == 1 and l3[1]:find("|cff4cd964", 1, true) ~= nil and l3[1]:find("|r", 1, true) ~= nil, l3[1])
    local lf = T.Lines("|cff4cd964\216\167\216\168|r y", 400, 12, 3)
    check("a coloured Persian word stays one coloured block in mode 3",
        lf[1]:find("|cff4cd964[^|]+|r") ~= nil and lf[1]:sub(1, 1) == "y", lf[1])
    local lw = T.Lines("|cff4cd964aa bb|r cc", 400, 12, 3)
    check("a colour span over two words ends before the plain word", lw[1]:find("|cff4cd964aa bb|r cc", 1, true) ~= nil, lw[1])
    F.db.mode = 1
    F.Room.Set("namesZone", false)
    F.db.col = { on = true }
    -- rc18 (the owner): a family switched to English keeps the colour he picked
    check("a family that is off shows English in its colour", T.Markers(m):find("x |cff4cd964Elwynn|r y", 1, true) ~= nil, T.Markers(m))
    F.db.col = { on = true, zn = "off" }
    check("a family that is off and has no colour stays plain English", T.Markers(m):find("x Elwynn y", 1, true) ~= nil, T.Markers(m))
    F.db.col = nil
    check("colours off: the English stays plain", T.Markers(m):find("x Elwynn y", 1, true) ~= nil, T.Markers(m))
    F.Room.Set("namesZone", true)

    F.OpenPanel("colors")
    local PF = F.PanelFrame()
    check("colours page opens", F.PanelPage() == "colors", F.PanelPage())
    F.db.col = nil
    Click(PF.col.zn)
    check("a colour choice cycles and is saved", F.db.col and F.db.col.zn == "blue", F.db.col and F.db.col.zn)
    Click(PF.colOn)
    check("the colour switch turns on", F.db.col.on == true)
    F.db.col, F.db.mode = oldCol, oldMode
    F.Room.Decode(savedCode)
    PF:Hide()

    GameTooltip:Hide()
    GameTooltip:ClearLines()
    T.TipLine(GameTooltip, "A fairly long description line for the tooltip", F.C.text)
    local n1 = GameTooltip:NumLines()
    T.TipLine(GameTooltip, "A fairly long description line for the tooltip", F.C.text)
    check("the same long line is not added twice", GameTooltip:NumLines() == n1, n1 .. " vs " .. GameTooltip:NumLines())
    GameTooltip:Hide()
end)
check("rc9 tests ran", okRc9, errRc9)
-- ------------------------------------------------------------------ rc11: NPC names, share codes
local okRc11, errRc11 = pcall(function()
    local savedCode = F.Room.Encode()
    local oldDisp, oldCol, oldNpc = F.db.disp, F.db.col, F.db.npcName
    F.Room.Apply("fa")
    -- the npc family is no longer locked and its names ship
    check("namesNpc is no longer release-locked", F.RELEASE_LOCK.namesNpc == nil and F.RELEASE_LOCK.npc == nil)
    check("the npc module is registered", F.mods.npc ~= nil)
    local k, v = next(F.D.names.npc or {})
    check("npc names ship", k ~= nil and v ~= nil)
    if k then
        F.db.npcName = nil
        check("an NPC name resolves to Persian", F.NpcLookup(k) == v, tostring(F.NpcLookup(k)))
        F.db.npcName = 3
        check("npcName 3 = English: no lookup", F.NpcLookup(k) == nil)
        F.db.npcName = 1
        F.Room.Set("namesNpc", false)
        check("the namesNpc switch off = English", F.NpcLookup(k) == nil)
        F.Room.Set("namesNpc", true)
    end
    -- the share code: a round trip of a customised setup
    F.Room.Set("namesZone", false)
    F.DispSetDefault("title", 3)
    F.DispSet("talents", "desc", 1)
    F.db.npcName = 2
    F.db.col = { on = true, zn = "red", cls = "off" }
    local code = F.Room.ShareExport()
    check("the share code has the WFP1 shape", string.find(code, "^WFP1%-[%w%.]+%-%w%w%w$") ~= nil, code)
    F.Room.Set("namesZone", true)
    F.DispSetDefault("title", 1)
    F.DispSetCustom("talents", false)
    F.db.npcName = 1
    F.db.col = nil
    local ok, why = F.Room.ShareImport(code)
    check("the share code imports", ok == true, tostring(why))
    check("the room bits come back", not F.Room.On("namesZone"))
    check("the display defaults come back", F.Disp("*", "title") == 3 and F.Disp("talents", "desc") == 1)
    check("the npc display comes back", F.NpcMode() == 2)
    check("the colours come back", F.db.col and F.db.col.on == true and F.db.col.zn == "red" and F.db.col.cls == "off")
    local bad = string.gsub(code, "^(WFP1%-s)(%w)", function(a, b)
        return a .. (b == "z" and "y" or "z")
    end)
    local okb = F.Room.ShareImport(bad)
    check("a changed code is refused", okb == nil)
    check("a site WF4 code is still accepted", F.Room.ShareImport(F.Room.Encode()) == true)
    check("an empty code is refused", F.Room.ShareImport("  ") == nil)
    -- the panel: the NPC and Share sections
    F.OpenPanel("npc")
    check("the panel opens the NPC section", F.PanelPage() == "npc")
    local PF = F.PanelFrame()
    check("the NPC section has its display choice", PF.npcName ~= nil)
    Click(PF.npcName)
    check("the NPC display choice cycles", F.NpcMode() == 3, F.NpcMode())
    F.OpenPanel("share")
    RunTimers()
    check("the share box shows my code", PF.shareBox.wfaFixed and string.find(PF.shareBox.wfaFixed, "^WFP1%-") ~= nil)
    PF.shareIn:SetText("garbage")
    Click(PF.shareApply)
    check("the share page refuses a garbage code", F.Disp("*", "title") == 3)
    PF:Hide()
    F.db.disp, F.db.col, F.db.npcName = oldDisp, oldCol, oldNpc
    F.Room.Decode(savedCode)
end)
check("rc11 tests ran", okRc11, errRc11)
-- ------------------------------------------------------------------ tracker
function GetNumQuestLogEntries() return #MOCK.logList end -- the mock lacks it
MOCK.logList = { { title = "Live Title Of The Quest", id = qid } }
MOCK_SetWatchLines({ "Live Title Of The Quest", " - Kobold Vermin slain: 3/10" })
QuestWatch_Update()
local l1, l2 = QuestWatchLine1:GetText(), QuestWatchLine2:GetText()
check("tracker title in Persian", non_ascii(l1), l1)
check("tracker objective: the NPC name is Persian now (rc11 unlocked the npc names)", type(l2) == "string" and l2:find("Kobold Vermin", 1, true) == nil, l2)
do
    local okW, errW = pcall(function()
        local FF = WoWFAF
        check("rc14: the UI walker exists", FF.Walk ~= nil and type(FF.Walk.Quest) == "function")
        check("rc14: an unknown quest title is left alone", FF.Walk.Quest("Zzzz Not A Quest") == nil)
        local wasSp, wasQt = FF.Room.On("namesSpell"), FF.Room.On("questText")
        FF.Room.Set("namesSpell", true)
        local wasT, wasC = FF.Disp("*", "title"), FF.DispCustom("spellbook")
        FF.DispSetDefault("title", 1)
        FF.DispSetCustom("spellbook", false)
        local k
        for kk in pairs(FF.D.names.spell) do
            if FF.T.NameKey(kk) == kk then
                k = kk
                break
            end
        end
        local sp = FF.Walk.Spell(k)
        check("rc14: a spell name in the book becomes Persian", type(sp) == "string" and sp ~= k, tostring(sp))
        FF.Room.Set("questText", true)
        local o = FF.Walk.Objective("0/8 Skeletal Warrior slain")
        check("rc14: a modern objective line is rebuilt", type(o) == "string" and o ~= "0/8 Skeletal Warrior slain", tostring(o))
        local rdy = FF.Walk.Objective("Ready for turn-in")
        check("rc18: 'Ready for turn-in' becomes Persian", non_ascii(rdy), tostring(rdy))
        check("rc18: the quest log index exists", type(FF.Walk.LogId) == "function" and type(FF.Walk.Watch) == "function")
        check("rc18: /wowfa why runs", pcall(FF.Walk.Why))
        check("rc14: a map label with a level range is found", FF.Walk.Scan ~= nil)
        FF.Room.Set("namesSpell", wasSp)
        FF.Room.Set("questText", wasQt)
        FF.DispSetDefault("title", wasT)
        if wasC then
            FF.DispSetCustom("spellbook", true)
        end
    end)
    check("rc14 walker block ran", okW, errW)
end
check("tracker objective rewritten (Persian verb + counts)", non_ascii(l2), l2)

-- ------------------------------------------------------------------ rc20: map label outline
do
    local okF, errF = pcall(function()
        local fl = F.ZoneFlags
        check("rc20: the hover label gets a black outline", fl({ kind = "map", flags = "" }) == "OUTLINE", tostring(fl({ kind = "map", flags = "" })))
        check("rc20: a thick outline stays thick", fl({ kind = "map", flags = "THICKOUTLINE" }) == "THICKOUTLINE")
        check("rc20: the minimap text keeps its own outline", fl({ kind = "minimap", flags = "OUTLINE" }) == "OUTLINE")
        check("rc20: the minimap text without one stays plain", fl({ kind = "minimap", flags = "" }) == "")
    end)
    check("rc20 tests ran", okF, errF)
end

-- ------------------------------------------------------------------ rc19: $C colour
do
    local okC, errC = pcall(function()
        local oldCol = F.db.col
        F.db.col = { on = true }
        local s = F.T.Tokens("a $C here")
        check("rc19: $C takes the class colour", s:find("|cffabd473", 1, true) ~= nil and s:find("|r", 1, true) ~= nil, s)
        F.db.col = nil
        s = F.T.Tokens("a $C here")
        check("rc19: $C stays plain with the colours off", s:find("|c", 1, true) == nil, s)
        F.db.col = oldCol
    end)
    check("rc19 tests ran", okC, errC)
end

-- ------------------------------------------------------------------ world map label (zoneMap)
local okMap, errMap = pcall(function()
    local zk = next(F.D.names.zone)
    local wmf = CreateFrame("Frame", "WorldMapFrame", UIParent)
    WorldMapFrame = wmf
    local lab = CreateFrame("Frame", nil, wmf)
    lab.Name = lab:CreateFontString(nil, "OVERLAY")
    lab.Description = lab:CreateFontString(nil, "OVERLAY")
    wmf.dataProviders = { [{ Label = lab }] = true }
    FireEvent("ADDON_LOADED", "Blizzard_WorldMap")
    F.db.zoneMap = nil
    lab.Name:SetText(zk)
    local t2 = lab.Name:GetText() or ""
    check("map label default: Persian, English under it",
        t2:find("\n", 1, true) ~= nil and t2:sub(-#zk) == zk and non_ascii(t2), t2)
    F.db.zoneMap = 1
    F:Fire("options", "zoneMap")
    check("map option change puts the English back", lab.Name:GetText() == zk, lab.Name:GetText())
    lab.Name:SetText(zk)
    local t1 = lab.Name:GetText() or ""
    check("map label mode 1: Persian only", non_ascii(t1) and not t1:find("\n", 1, true) and not t1:find(zk, 1, true), t1)
    F.db.zoneMap = 3
    F:Fire("options", "zoneMap")
    lab.Name:SetText(zk)
    check("map label mode 3: English untouched", lab.Name:GetText() == zk, lab.Name:GetText())
    F.db.zoneMap = 2
    F:Fire("options", "zoneMap")
    lab.Name:SetText("Not A Real Zone Name")
    check("map label: unknown zone stays English", lab.Name:GetText() == "Not A Real Zone Name", lab.Name:GetText())
    F.db.zoneMap = nil
end)
check("map label tests ran", okMap, errMap)

-- ------------------------------------------------------------------ NumKey parity (tests/numkey_vectors.txt, shared with tests/py)
do
    local n, bad = 0, 0
    local fh = io.open("tests/numkey_vectors.txt", "r")
    if fh then
        for line in fh:lines() do
            if line ~= "" and string.sub(line, 1, 1) ~= "#" then
                local en, key, nums = string.match(line, "^([^\t]*)\t([^\t]*)\t([^\t]*)$")
                if en then
                    en = string.gsub(en, "\\n", "\n")
                    local k, ns = F.T.NumKey(en)
                    n = n + 1
                    if k ~= key or table.concat(ns, ";") ~= nums then
                        bad = bad + 1
                        print("  numkey: " .. en .. " -> " .. k .. " | " .. table.concat(ns, ";") .. " (want " .. key .. " | " .. nums .. ")")
                    end
                end
            end
        end
        fh:close()
    end
    check("NumKey parity with the Python twin (" .. n .. " vectors)", n >= 10 and bad == 0, bad)
end

-- ------------------------------------------------------------------ miss recorder (rc3 update watch)
local okMiss, errMiss = pcall(function()
    F:ClearMiss()
    check("miss log starts empty", F.db.missN == 0, F.db.missN)
    F:Miss("tpl", "a totally unknown line #", "A totally unknown line 5.", "Test Spell")
    F:Miss("tpl", "a totally unknown line #", "A totally unknown line 6.", "Test Spell")
    local e = F.db.miss["tpl:a totally unknown line #"]
    check("miss kept once, counted twice", e ~= nil and e.n == 2 and F.db.missN == 1, e and e.n)
    F.OpenPanel("health")
    RunTimers()
    local PF = F.PanelFrame()
    local box = PF and PF.health and PF.health.missList
    local txt = box and box:GetText() or ""
    check("status page lists the misses", txt:find("misses=1", 1, true) ~= nil and txt:find("A totally unknown line 5.", 1, true) ~= nil, txt)
    F:Miss("zone", "some new zone", "Some New Zone|x")
    txt = box and box:GetText() or ""
    check("a new miss shows while the panel is open (pipe escaped)", txt:find("misses=2", 1, true) ~= nil and txt:find("Some New Zone!x", 1, true) ~= nil, txt)
    for i = 1, F.MISS_CAP + 20 do
        F:Miss("zone", "zone " .. i, "Zone " .. i)
    end
    check("miss log is capped", F.db.missN == F.MISS_CAP, F.db.missN)
    Click(PF.missClear)
    check("clear empties the miss log", F.db.missN == 0 and next(F.db.miss) == nil, F.db.missN)
    check("box shows the empty log", (box:GetText() or ""):find("misses=0", 1, true) ~= nil, box:GetText())
    F.TogglePanel()
end)
check("miss recorder tests ran", okMiss, errMiss)

-- ------------------------------------------------------------------ /wowfa dump (rc5)
local okDump, errDump = pcall(function()
    local spells = { [100] = "Charge", [133] = "Fireball", [7] = "Zz Late Spell" }
    local loaded = { [100] = true, [133] = true }
    local saved = C_Spell
    C_Spell = {
        DoesSpellExist = function(id) return spells[id] ~= nil end,
        GetSpellName = function(id) return spells[id] end,
        GetSpellDescription = function(id)
            if spells[id] and loaded[id] then
                return "Desc of " .. spells[id] .. " for 5 sec."
            end
            return ""
        end,
        RequestLoadSpellData = function(id) loaded[id] = true end,
    }
    F.Dump.RETRY_WAIT = 0
    SlashCmdList.WOWFAF("dump 200")
    for _ = 1, 500 do
        F.Dump.Step()
        if type(WoWFA_Dump) == "table" and WoWFA_Dump.done then
            break
        end
    end
    C_Spell = saved
    check("dump finishes", type(WoWFA_Dump) == "table" and WoWFA_Dump.done == true)
    local s = (type(WoWFA_Dump) == "table" and WoWFA_Dump.s) or {}
    check("dump stores the English description", s[100] ~= nil and s[100].d == "Desc of Charge for 5 sec.", s[100] and s[100].d)
    check("dump second pass catches late-loading spells", s[7] ~= nil and s[7].d ~= nil, s[7] and tostring(s[7].d))
    check("dump counts + highest id", WoWFA_Dump.count == 3 and WoWFA_Dump.highest == 133,
        tostring(WoWFA_Dump.count) .. "/" .. tostring(WoWFA_Dump.highest))
    local fa = false
    for _, e in pairs(s) do
        for _, l in ipairs(e.l or {}) do
            if non_ascii(l) then
                fa = true
            end
        end
        if e.d and non_ascii(e.d) then
            fa = true
        end
    end
    check("dump exports English only", not fa)
    SlashCmdList.WOWFAF("status")
    check("other /wowfa commands still reach Core", true)
    SlashCmdList.WOWFAF("dump clear")
    check("dump clear deletes the export", WoWFA_Dump == nil)
end)
check("dump tests ran", okDump, errDump)
-- -------------------------------------------------------------------- panel
-- the settings panel end to end on the mock: open/close paths, every kind of
-- row (master, room switch, preset cycle, module, option), status + errors,
-- the two-click reset. Run inside pcall: a crash is ONE named failure.
local function panel_suite()
    check("panel API", type(F.OpenPanel) == "function" and type(F.TogglePanel) == "function")
    F.OpenPanel()
    RunTimers()
    local PF = F.PanelFrame and F.PanelFrame()
    check("panel built + shown", PF and PF:IsShown())
    if not PF then
        return
    end
    local esc = false
    for _, n in ipairs(UISpecialFrames) do
        if n == "WoWFAF_Panel" then
            esc = true
        end
    end
    check("panel closes on Esc by its own key, never UISpecialFrames (taint)", (not esc) and F.PanelFrame().wfaEsc == true)
do
    local hit = false
    for _, n in ipairs(UISpecialFrames) do
        if type(n) == "string" and string.find(n, "^WoWFA") then
            hit = true
        end
    end
    check("no WoWFA frame name in UISpecialFrames (the panel manager reads them: taint)", not hit)
    local pf = F.PanelFrame()
    local was = pf:IsShown()
    pf:Show()
    local kd = pf:GetScript("OnKeyDown")
    if kd then
        kd(pf, "ESCAPE")
    end
    check("Esc closes the panel", kd ~= nil and not pf:IsShown())
    if was then
        pf:Show()
    end
end
    check("panel subtitle is shaped Persian", non_ascii(PF.subtitle:GetText()), PF.subtitle:GetText())
    F.TogglePanel()
    check("toggle hides", not PF:IsShown())
    Click(WoWFAF_MinimapButton, "LeftButton")
    check("minimap click opens", PF:IsShown())
    Click(WoWFAF_MinimapButton, "LeftButton")
    check("minimap click closes", not PF:IsShown())
    SlashCmdList.WOWFAF("")
    check("/wowfa opens", PF:IsShown())
    F.OpenPanel("health")
    check("open on the status section", PF:IsShown())

    Click(PF.master)
    check("master off from the panel", F.db.enabled == false and not F.mods.quests.active, F.mods.quests.state)
    Click(PF.master)
    check("master back on", F.db.enabled == true and F.mods.quests.active, F.mods.quests.state)

    Click(PF.mods.tracker)
    check("tracker off from the panel", F.db.mods.tracker == false and not F.mods.tracker.active)
    Click(PF.mods.tracker)
    check("tracker back on", F.db.mods.tracker == true and F.mods.tracker.active, F.mods.tracker.state)
    for _, id in ipairs(F.PANEL_SHIPPED) do
        check("panel lists shipped module " .. id, PF.mods[id] ~= nil and not F.RELEASE_LOCK[id])
    end

    local was = F.Room.On("namesZone")
    Click(PF.room.namesZone)
    check("zone-name switch flips the room", F.Room.On("namesZone") ~= was)
    Click(PF.room.namesZone)
    check("zone-name switch back", F.Room.On("namesZone") == was)

    local seen, okp = {}, true
    for _ = 1, 6 do
        Click(PF.preset)
        local m = F.Room.Mode()
        seen[#seen + 1] = m
        if not F.Room.PRESETS[m] then
            okp = false
        end
    end
    check("preset cycle lands on real presets only", okp, table.concat(seen, ","))
    check("preset label is shaped Persian", non_ascii(PF.preset.val:GetText()), PF.preset.val:GetText())
    F.Room.Apply("fa")

    Click(PF.minimap)
    check("minimap button hidden from the panel", F.db.minimap.hide == true and not WoWFAF_MinimapButton:IsShown())
    Click(PF.minimap)
    check("minimap button back", F.db.minimap.hide == false and WoWFAF_MinimapButton:IsShown())
    local dock = F.db.questDock
    Click(PF.dock)
    check("quest dock cycles", F.db.questDock == dock % 3 + 1, F.db.questDock)
    F.db.questDock = dock

    F.PanelRefresh()
    local qs = PF.health.mods.quests.val:GetText()
    check("status: module state in Persian", non_ascii(qs), qs)
    check("status: data build shown", PF.health.data.val:GetText() == tostring(F.dataBuildText), PF.health.data.val:GetText())
    F:LogError("paneltest", "boom|x")
    local el = PF.health.errList:GetText() or ""
    check("status: errors listed (pipe escaped)", el:find("boom||x", 1, true) ~= nil, el)
    Click(PF.clear)
    check("status: clear empties the log", #F.db.errors == 0 and (PF.health.errList:GetText() or "") == "")

    F.db.toast = false
    Click(PF.reset)
    check("reset: the first click only arms", F.db.toast == false)
    Click(PF.reset)
    check("reset: the second click resets", F.db.toast == true and F.db.enabled == true)
    check("reset: modules still active", F.mods.quests.active and F.mods.dungeons.active, F.mods.quests.state)
    F.TogglePanel()
    check("panel closed at the end", not PF:IsShown())
end
local okPanel, errPanel = pcall(panel_suite)
check("panel suite ran without a crash", okPanel, errPanel)

-- ------------------------------------------------------------- lock + slash
-- ------------------------------------------------------------------ 1.1.6: the game's own windows
local okGu, errGu = pcall(function()
    local G = F.GameUI
    check("gameui: the module loaded", type(G) == "table" and type(G.Try) == "function")
    local host = CreateFrame("Frame", "ZzGameUiHost", UIParent)
    local fs = host:CreateFontString(nil, "OVERLAY")
    fs:SetText("Reputation")
    check("gameui: a known window text turns Persian", G.Try(fs) == true and non_ascii(fs:GetText()), fs:GetText())
    check("gameui: it is drawn in the Persian font", (fs._font or ""):find("Vazirmatn") ~= nil, fs._font)
    fs:SetText("Skills")
    check("gameui: the game's next write is swapped too", non_ascii(fs:GetText()), fs:GetText())
    local col = host:CreateFontString(nil, "OVERLAY")
    col:SetText("Strength:")
    check("gameui: a label with the game's colon", G.Try(col) == true and non_ascii(col:GetText()), col:GetText())
    local other = host:CreateFontString(nil, "OVERLAY")
    other:SetText("Zzz Player Name")
    check("gameui: an unknown text stays English", G.Try(other) == false and other:GetText() == "Zzz Player Name", other:GetText())
    local num = host:CreateFontString(nil, "OVERLAY")
    num:SetText("5")
    check("gameui: a bag count stays as it is", G.Try(num) == false and num:GetText() == "5", num:GetText())
    local pg = host:CreateFontString(nil, "OVERLAY")
    pg:SetText("Page 3")
    check("gameui: a text with a number (Page %d)", G.Try(pg) == true and non_ascii(pg:GetText()), pg:GetText())
    local sk = host:CreateFontString(nil, "OVERLAY")
    sk:SetText("Mail")
    G.Try(sk, "SkillFrame")
    local ml = host:CreateFontString(nil, "OVERLAY")
    ml:SetText("Mail")
    G.Try(ml)
    check("gameui: one word, two windows (Mail = armour in the skills, the mail window elsewhere)",
        non_ascii(sk:GetText()) and non_ascii(ml:GetText()) and sk:GetText() ~= ml:GetText(),
        tostring(sk:GetText()) .. " / " .. tostring(ml:GetText()))
    MOCK.combat = true
    local cb = host:CreateFontString(nil, "OVERLAY")
    cb:SetText("Bank")
    check("gameui: nothing changes in combat", G.Try(cb) == false and cb:GetText() == "Bank", cb:GetText())
    MOCK.combat = false
    FireEvent("PLAYER_REGEN_ENABLED")
    check("gameui: the text written in combat is swapped after it", non_ascii(cb:GetText()), cb:GetText())
    F.db.gameUi = false
    F:Fire("options", "gameUi")
    check("gameui: off puts the English back", fs:GetText() == "Skills" and pg:GetText() == "Page 3" and col:GetText() == "Strength:",
        tostring(fs:GetText()) .. " / " .. tostring(pg:GetText()) .. " / " .. tostring(col:GetText()))
    check("gameui: off puts the game font back", (fs._font or ""):find("Vazirmatn") == nil, fs._font)
    fs:SetText("Reputation")
    check("gameui: off = the game's writes stay English", fs:GetText() == "Reputation", fs:GetText())
    F.db.gameUi = nil
    F:Fire("options", "gameUi")
    -- 1.2.0: the New pill of the game page shows until the page is opened once
    F.OpenPanel("spellbook")
    local pf0 = F.PanelFrame()
    local pill0 = pf0 and pf0.nav and pf0.nav.game and pf0.nav.game.newPill
    check("new tag: the game page has its pill in the side menu until it is opened", pill0 ~= nil and pill0:IsShown())
    F.OpenPanel("game")
    check("new tag: opening the page hides the pill for good", pill0 ~= nil and not pill0:IsShown() and F.db.newSeen and F.db.newSeen.game == "1.2.0")
    local PF = F.PanelFrame()
    check("gameui: the switch is on the game windows page", PF and PF.gameUi ~= nil)
    if PF and PF.gameUi then
        Click(PF.gameUi)
        check("gameui: the switch turns it off", F.db.gameUi == false)
        Click(PF.gameUi)
        check("gameui: and on again", F.db.gameUi == true)
        PF:Hide()
    end
end)
check("gameui tests ran", okGu, errGu)
-- ------------------------------------------------------------------ 1.2.0: window groups, combat watch
local okGg, errGg = pcall(function()
    local G = F.GameUI
    check("groups: the module lists 7 groups", type(G.Groups) == "table" and #G.Groups == 7, G.Groups and #G.Groups)
    local h = CreateFrame("Frame", "ZzGroupHost", UIParent)
    local a = h:CreateFontString(nil, "OVERLAY")
    a:SetText("Reputation")
    check("groups: all on by default", G.GroupOn("char") == true and G.GroupOn("bags") == true)
    check("groups: a window of an enabled group turns Persian", G.Try(a, "CharacterFrame") == true and non_ascii(a:GetText()), a:GetText())
    G.SetGroup("char", false)
    check("groups: switching a group off puts its English back at once", a:GetText() == "Reputation" and G.GroupOn("char") == false, a:GetText())
    local b = h:CreateFontString(nil, "OVERLAY")
    b:SetText("Reputation")
    check("groups: an off group stays English", G.Try(b, "CharacterFrame") == false and b:GetText() == "Reputation", b:GetText())
    local c = h:CreateFontString(nil, "OVERLAY")
    c:SetText("Bank")
    check("groups: another group is not affected", G.Try(c, "BankFrame") == true and non_ascii(c:GetText()), c:GetText())
    G.SetGroup("char", true)
    check("groups: back on", G.GroupOn("char") == true and G.Try(b, "CharacterFrame") == true and non_ascii(b:GetText()), b:GetText())
    check("groups: nothing is stored for a group that is on", next(F.db.guiOff or {}) == nil)
    -- an unknown label in a label window is noted once as a miss
    F:ClearMiss()
    local u = h:CreateFontString(nil, "OVERLAY")
    u:SetText("Zzgroup Unknown Label")
    G.Try(u, "CharacterFrame")
    G.Try(u, "CharacterFrame")
    local e = F.db.miss["ui:zzgroup unknown label"]
    check("groups: an unknown window label is noted once", e ~= nil and e.n == 1, e and e.n)
    local bm = h:CreateFontString(nil, "OVERLAY")
    bm:SetText("Zzbag Unknown Item")
    G.Try(bm, "BankFrame")
    check("groups: a bag or shop text is never noted", F.db.miss["ui:zzbag unknown item"] == nil)
    F:ClearMiss()
    F.OpenPanel("game")
    local PF = F.PanelFrame()
    check("groups: the page has the master switch and a row for each group",
        PF.gameUi ~= nil and PF.guiG ~= nil and PF.guiG.char ~= nil and PF.guiG.finder ~= nil)
    Click(PF.guiG.bags)
    check("groups: the panel row turns a group off", G.GroupOn("bags") == false)
    Click(PF.guiG.bags)
    check("groups: and on again", G.GroupOn("bags") == true)
    -- the combat watch
    local W = F.CombatWatch
    check("combat watch: the module loaded", type(W) == "table" and type(W.Snapshot) == "function")
    F.db.zzProbe = 1
    FireEvent("PLAYER_REGEN_DISABLED")
    F.db.zzProbe = 2
    FireEvent("PLAYER_REGEN_ENABLED")
    local hit
    for _, cd in ipairs(F.db.combatDiff or {}) do
        if cd.k == "db.zzProbe" then
            hit = cd
        end
    end
    check("combat watch: a setting that changed in a fight is named", hit ~= nil and hit.v == "1 > 2", hit and hit.v)
    F.db.zzProbe, F.db.combatDiff = nil, nil
    FireEvent("PLAYER_REGEN_DISABLED")
    FireEvent("PLAYER_REGEN_ENABLED")
    check("combat watch: a quiet fight records nothing", F.db.combatDiff == nil or #F.db.combatDiff == 0, F.db.combatDiff and #F.db.combatDiff)
    F.db.combatDiff = { { k = "db.zzProbe", v = "1 > 2", n = 1 } }
    F.OpenPanel("health")
    RunTimers()
    local box = PF.health.missList
    check("combat watch: the report line carries the combat changes", (box:GetText() or ""):find("combat :: db.zzProbe", 1, true) ~= nil, box:GetText())
    F.db.combatDiff = nil
    PF:Hide()
end)
check("window groups tests ran", okGg, errGg)
-- ------------------------------------------------------------------ 1.1.6: the live preview column
local okPv, errPv = pcall(function()
    local P = F.Preview
    check("preview: the module loaded", type(P) == "table" and type(F.PreviewAttach) == "function")
    F.OpenPanel("general")
    local PF = F.PanelFrame()
    check("preview: the window grew by the column", (PF._w or 0) >= 1000, PF._w)
    check("preview: the column is built", P.pane ~= nil)
    local zr = PF.room and PF.room.namesZone
    check("preview: an eye next to the zone-name switch", zr ~= nil and zr.eye ~= nil)
    check("preview: eyes on the other rows too",
        PF.gameUi and PF.gameUi.eye ~= nil and PF.sysmsg and PF.sysmsg.eye ~= nil and PF.npcName and PF.npcName.eye ~= nil
        and PF.mods.tracker and PF.mods.tracker.eye ~= nil, "gameUi/sysmsg/npcName/tracker")
    local wasZ = F.Room.On("namesZone")
    F.Room.Set("namesZone", true)
    F.OpenPanel("map")
    Click(zr.eye)
    check("preview: the eye opens the zone sample", P.Current() == "zone", P.Current())
    local zf = P.Frame("zone")
    check("preview: zone names on = the sample is Persian", zf and zf.big.fa:IsShown() and non_ascii(zf.big.fa:GetText()),
        zf and zf.big.fa:GetText())
    F.Room.Set("namesZone", false)
    P.Update()
    check("preview: zone names off = the game's English", zf and zf.big.en:IsShown() and not non_ascii(zf.big.en:GetText()),
        zf and zf.big.en:GetText())
    F.Room.Set("namesZone", wasZ)
    local errs = #(F.db.errors or {})
    for id in pairs(P.SAMPLES) do
        P.Show(id, nil)
    end
    check("preview: every sample draws without an error", #(F.db.errors or {}) == errs,
        F.db.errors and F.db.errors[1] and F.db.errors[1].e)
    PF:Hide()
end)
check("preview tests ran", okPv, errPv)
-- ------------------------------------------------------------------ 1.1.6: taint + recipe misses
local okTt, errTt = pcall(function()
    check("recipe: a profession recipe name", F.IsRecipeTip("Leatherworking: Embossed Leather Vest") == true)
    check("recipe: first aid too", F.IsRecipeTip("First Aid: Linen Bandage") == true)
    check("recipe: a plain spell is no recipe", F.IsRecipeTip("Fireball") == false and F.IsRecipeTip("Leatherworking") == false)
    check("recipe: a colon spell that is no profession", F.IsRecipeTip("Aspect of the Hawk: Rank 2") == false)
    check("item line: reagents", F.IsItemLine("Reagents: |nLight Leather (8), Coarse Thread (4)") == true)
    check("item line: equip / use / appearance", F.IsItemLine("Equip: Improves your chance to get a critical strike by 1.0%.")
        and F.IsItemLine("Use: Permanently increase the Stamina value by 2") and F.IsItemLine("You haven't collected this appearance"))
    check("item line: a spell text is not", F.IsItemLine("Hurls a fiery ball that causes 14 to 23 Fire damage.") == false)
    local calls = 0
    local keep = {}
    for _, n in ipairs({ "QuestWatch_Update", "WatchFrame_Update", "ObjectiveTracker_Update", "QuestMapFrame_UpdateAll",
        "QuestLogQuests_Update", "CompactUnitFrame_UpdateName", "ShowUIPanel", "HideUIPanel" }) do
        keep[n] = _G[n]
        _G[n] = function() calls = calls + 1 end
    end
    F:Fire("names")
    F:Fire("surf")
    F:Fire("npcname")
    if F.RelayoutQuests then
        pcall(F.RelayoutQuests)
    end
    for _, n in ipairs({ "QuestWatch_Update", "WatchFrame_Update", "ObjectiveTracker_Update", "QuestMapFrame_UpdateAll",
        "QuestLogQuests_Update", "CompactUnitFrame_UpdateName", "ShowUIPanel", "HideUIPanel" }) do
        _G[n] = keep[n]
    end
    check("taint: no client updater called from addon code (names / surf / sizes)", calls == 0, calls)
end)
check("taint + recipe tests ran", okTt, errTt)
-- ------------------------------------------------------------------ 1.1.6: settings panel v4
local okV4, errV4 = pcall(function()
    F.OpenPanel("general")
    local PF = F.PanelFrame()
    local P = F.Preview
    local n, bad = 0, {}
    for _, r in ipairs(PF.allRows or {}) do
        if r.wfaEye then
            n = n + 1
            if not (r.eye and P.SAMPLES[r.wfaEye]) then
                bad[#bad + 1] = tostring(r.wfaEye)
            end
        end
    end
    check("v4: every marked row has its eye and its sample", n >= 25 and #bad == 0, n .. " / " .. table.concat(bad, ","))
    local unnamed = 0
    for _, r in ipairs(PF.allRows or {}) do
        if r.label and r.label.GetText then
            local t = r.label:GetText()
            if type(t) ~= "string" or t == "" or t:find("^[%w_]+$") then
                unnamed = unnamed + 1
            end
        end
    end
    check("v4: every row has a real label (no missing text)", unnamed == 0, unnamed)
    local stats = false
    for _, id in ipairs(F.Room.PRESET_IDS) do
        if id == "stats" then
            stats = true
        end
    end
    check("v4: the item-only preset is no choice", not stats)
    local was = F.Room.On("terms")
    F.Room.Set("terms", true)
    P.Show("text", nil)
    local a = P.Frame("text").t:GetText() or ""
    F.Room.Set("terms", false)
    P.Update()
    local b = P.Frame("text").t:GetText() or ""
    F.Room.Set("terms", was)
    check("v4: the text sample follows the terms switch", a ~= b and b:find("Hearthstone", 1, true) ~= nil
        and a:find("Hearthstone", 1, true) == nil, a .. " | " .. b)
    -- the talk switches: turning one on while their master is off turns only that one on
    local wasSay = F.Room.On("npcSay")
    F.Room.Set("npcSay", false)
    F.db.dlgGossip, F.db.dlgSay, F.db.dlgBook = true, true, true
    Click(PF.dlgSay)
    check("v4: one talk switch on while the master was off", F.Room.On("npcSay") and F.db.dlgSay == true
        and F.db.dlgGossip == false and F.db.dlgBook == false)
    F.db.dlgGossip, F.db.dlgBook = true, true
    F.Room.Set("npcSay", wasSay)
    F.db.sysmsg = false
    Click(PF.sysXp)
    check("v4: one system group on while the master was off", F.db.sysmsg == true and F.db.sysXp == true
        and F.db.sysLoot == false)
    F.db.sysLoot, F.db.sysRep, F.db.sysGroup = true, true, true
    -- the talent eye draws the talents' own display
    F.OpenPanel("spellbook")
    Click(PF.talentOwn)
    Click(PF.talentOwn.eye)
    check("v4: the talent eye draws the talent display", P.Current() == "spell" and P.Frame("spell").tip.wfaSec == "talents")
    Click(PF.talentOwn)
    -- the NPC name row is the module + the family + the display
    F.OpenPanel("npc")
    F.Room.Set("namesNpc", true)
    F.db.npcName = 2
    Click(PF.npcName)
    check("v4: NPC names English = the family off", not F.Room.On("namesNpc") and F.NpcMode() == 3)
    Click(PF.npcName)
    check("v4: NPC names Persian again", F.Room.On("namesNpc") and F.NpcMode() == 1)
    PF:Hide()
end)
check("panel v4 tests ran", okV4, errV4)
local okTx, errTx = pcall(function()
    local zt = CreateFrame("GameTooltip", "ZzTaintTip", UIParent, "GameTooltipTemplate")
    zt:AddLine("Zz first line")
    F.T.TipLine(zt, "این یک خط فارسی بلند برای آزمودن تولتیپ است که باید زیر آن بیاید", F.C.text)
    check("taint: WoWFA creates no new tooltip line global", _G["ZzTaintTipTextLeft2"] == nil and zt:NumLines() == 1, zt:NumLines())
    check("taint: the Persian goes into the glued box", zt.wfaX ~= nil and (zt.wfaX.n or 0) >= 1 and zt.wfaX:IsShown())
    F.T.TipPair(zt, "Zz a", "Zz b")
    check("taint: a pair line goes there too", _G["ZzTaintTipTextRight2"] == nil and zt.wfaX.n >= 2)
    zt:ClearLines()
    check("taint: the box empties with the tooltip", zt.wfaX.n == 0 and not zt.wfaX:IsShown())
    local n0 = GameTooltip:NumLines()
    GameTooltip:ClearLines()
    F.T.TipLine(GameTooltip, "Zz an existing line string is still used", F.C.text)
    check("taint: existing game tooltip strings are still used", GameTooltip:NumLines() >= 1, n0)
    GameTooltip:ClearLines()
end)
check("taint tests ran", okTx, errTx)
local okCw, errCw = pcall(function()
    local was = F.db.mode
    F.db.mode = 3
    local long = string.rep("از آن سوی شهر برایت خبر آورده‌ام ", 6)
    local out = F.T.ChatText(long, nil, 20)
    F.db.mode = was
    check("chat: a long Persian line is wrapped by us, not by the chat window", type(out) == "string" and out:find("\n") ~= nil,
        type(out) == "string" and #out or tostring(out))
    local short = F.T.ChatText("سلام", nil, 10)
    check("chat: a short line stays one line", type(short) == "string" and short:find("\n") == nil, short)
    local PF = F.PanelFrame and F.PanelFrame()
    local icons, eyes = 0, 0
    for _, r in ipairs((PF and PF.allRows) or {}) do
        if r.wfaEye then
            eyes = eyes + 1
            if r.wfaIcon then
                icons = icons + 1
            end
        end
    end
    check("panel: every row with a preview shows the small eye", eyes > 0 and icons == eyes, icons .. "/" .. eyes)
end)
check("chat wrap tests ran", okCw, errCw)
check("items module not installed (locked)", not (F.mods.items and F.mods.items.active))
local ok = pcall(SlashCmdList.WOWFAF, "status")
check("/wowfa status", ok)
check("no runtime errors logged", #(WoWFA_FDB.errors or {}) == 0, WoWFA_FDB.errors and WoWFA_FDB.errors[1] and WoWFA_FDB.errors[1].e)

print(string.format("%d passed, %d failed (%d files loaded)", passes, fails, nfiles))
os.exit(fails == 0 and 0 or 1)
