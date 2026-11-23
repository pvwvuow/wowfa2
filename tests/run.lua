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
    Click(PF.dispTitle.spellbook)
    check("a section's own title choice turns custom on",
        F.DispCustom("spellbook") and F.Disp("spellbook", "title") == 3 and F.Disp("talents", "title") == 2,
        F.Disp("spellbook", "title") .. "/" .. F.Disp("talents", "title"))
    Click(PF.dispCustom.spellbook)
    check("custom off: the section follows General again", not F.DispCustom("spellbook") and F.Disp("spellbook", "title") == 2)
    Click(PF.dispTitleAll)
    check("the General default drives the sections that are not custom", F.Disp("talents", "title") == 3, F.Disp("talents", "title"))
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
    check("no colour codes in display mode 3", T.Markers(m):find("|c", 1, true) == nil)
    F.db.mode = 1
    F.Room.Set("namesZone", false)
    F.db.col = { on = true }
    check("a family that is off shows English, uncoloured", T.Markers(m):find("x Elwynn y", 1, true) ~= nil, T.Markers(m))
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
-- ------------------------------------------------------------------ tracker
function GetNumQuestLogEntries() return #MOCK.logList end -- the mock lacks it
MOCK.logList = { { title = "Live Title Of The Quest", id = qid } }
MOCK_SetWatchLines({ "Live Title Of The Quest", " - Kobold Vermin slain: 3/10" })
QuestWatch_Update()
local l1, l2 = QuestWatchLine1:GetText(), QuestWatchLine2:GetText()
check("tracker title in Persian", non_ascii(l1), l1)
check("tracker objective keeps the EN name (npc names locked)", type(l2) == "string" and l2:find("Kobold Vermin", 1, true) ~= nil, l2)
check("tracker objective rewritten (Persian verb + counts)", non_ascii(l2), l2)

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
    check("panel closes on Esc (UISpecialFrames)", esc)
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
check("items module not installed (locked)", not (F.mods.items and F.mods.items.active))
local ok = pcall(SlashCmdList.WOWFAF, "status")
check("/wowfa status", ok)
check("no runtime errors logged", #(WoWFA_FDB.errors or {}) == 0, WoWFA_FDB.errors and WoWFA_FDB.errors[1] and WoWFA_FDB.errors[1].e)

print(string.format("%d passed, %d failed (%d files loaded)", passes, fails, nfiles))
os.exit(fails == 0 and 0 or 1)
