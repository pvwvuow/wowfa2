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
