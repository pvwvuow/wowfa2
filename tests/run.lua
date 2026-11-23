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

-- ------------------------------------------------------------- lock + slash
check("items module not installed (locked)", not (F.mods.items and F.mods.items.active))
local ok = pcall(SlashCmdList.WOWFAF, "status")
check("/wowfa status", ok)
check("no runtime errors logged", #(WoWFA_FDB.errors or {}) == 0, WoWFA_FDB.errors and WoWFA_FDB.errors[1] and WoWFA_FDB.errors[1].e)

print(string.format("%d passed, %d failed (%d files loaded)", passes, fails, nfiles))
os.exit(fails == 0 and 0 or 1)
