local ROOT, DATA, BUILD, VERSION = ...
if BUILD == "0" then BUILD = nil end
dofile(MOCK_PATH)
if BUILD then MOCK.build = BUILD end
MOCK.version = VERSION
local function load_toc()
    for line in io.lines(ROOT .. "/WoWFA_Forever.toc") do
        if line ~= "" and not line:find("^##") then
            local p = ROOT .. "/" .. line:gsub("\\", "/")
            if DATA and p:find("/Data/") then p = DATA .. "/" .. p:match("Data/(.*)") end
            local f, err = loadfile(p)
            if not f then error("LOAD " .. p .. ": " .. err) end
            f("WoWFA", {})
        end
    end
end

-- Shape.lua lives in the retail folder: test copy
load_toc()
local F = WoWFAF
local function states() local t = {} for _, m in ipairs(F.order) do t[#t+1] = m.id .. "=" .. tostring(m.state) .. (m.why and ("(" .. m.why .. ")") or "") end return table.concat(t, " ") end
local function show(tt, title) print("--- " .. title); for _, l in ipairs(tt:TipLines()) do print("   " .. l) end end
FireEvent("ADDON_LOADED", "WoWFA")
FireEvent("PLAYER_LOGIN")
FireEvent("PLAYER_ENTERING_WORLD")
RunTimers()
print("STATES:", states())
print("welcome shown:", WoWFAF_Panel and WoWFAF_Panel:IsShown())
if F.dataState ~= "ok" then
    for _, id in ipairs({ "welcome", "mods", "names", "display", "capture", "health", "about" }) do F.OpenPanel(id) end
    GameTooltip:ClearLines(); GameTooltip:AddLine("x"); RunTip("Item", GameTooltip, { id = 25, lines = {} })
    MOCK.questID = 24; QuestFrame:Show(); FireEvent("QUEST_DETAIL"); FireEvent("ZONE_CHANGED_NEW_AREA")
    print("no data: every module idle, lines", GameTooltip:NumLines())
    print("ALL DONE")
    return
end
-- ------------------------------------------------ items
local function item(id, lines)
    GameTooltip:ClearLines()
    local data = { id = id, lines = {} }
    for _, l in ipairs(lines) do GameTooltip:AddLine(l[1]); if l[2] then _G["GameTooltipTextRight" .. GameTooltip:NumLines()]._text = l[2] end; data.lines[#data.lines + 1] = { leftText = l[1], rightText = l[2] } end
    RunTip("Item", GameTooltip, data)
end
item(25, { { "Worn Shortsword" }, { "Main Hand", "Sword" }, { "1 - 3 Damage", "Speed 1.90" }, { "(1.1 damage per second)" } })
show(GameTooltip, "item 25 ok")
RunTip("Item", GameTooltip, { id = 25, lines = {} }) -- refresh without clear: no duplicates
print("lines after refresh:", GameTooltip:NumLines())
item(25, { { "Worn Shortsword" }, { "Main Hand", "Sword" }, { "2 - 5 Damage", "Speed 2.20" }, { "(1.6 damage per second)" } })
show(GameTooltip, "item 25 stale")
F.Room.SetDetail(3)
item(10032, { { "x" }, { "Head", "Cloth" }, { "51 Armor" }, { "+10 Spirit" }, { "+10 Intellect" }, { "Equip: Increases healing done by spells and effects by up to 24 and damage by up to 8." } })
show(GameTooltip, "item 10032 full")
GameTooltip:ClearLines()
print("font restored on line 2:", GameTooltipTextLeft2:GetFont())
-- ------------------------------------------------ npc
GameTooltip:ClearLines(); GameTooltip:AddLine("Kilrogg"); GameTooltip._unitName, GameTooltip._unit = "Kilrogg", "mouseover"; MOCK.unitName = "Kilrogg"
RunTip("Unit", GameTooltip, {}); show(GameTooltip, "unit")
MOCK.unitName = SECRET; GameTooltip:ClearLines(); RunTip("Unit", GameTooltip, {}); print("secret unit lines:", GameTooltip:NumLines())
-- ------------------------------------------------ spells
GameTooltip:ClearLines(); GameTooltip:AddLine("Aspect of the Hawk"); GameTooltip:AddLine("The hunter takes on the aspects of a hawk, increasing Ranged Attack Power by 20. Only one Aspect can be active at a time.")
RunTip("Spell", GameTooltip, nil); show(GameTooltip, "spell (state " .. F.mods.spellbook.state .. ")")
F:Resume("spellbook"); print("after resume:", F.mods.spellbook.state)
GameTooltip:ClearLines(); GameTooltip:AddLine("Aspect of the Hawk"); GameTooltip:AddLine("The hunter takes on the aspects of a hawk, increasing Ranged Attack Power by 35. Only one Aspect can be active at a time.")
RunTip("Spell", GameTooltip, nil); show(GameTooltip, "spell resumed")
F:Resume("talents")
GameTooltip:ClearLines(); GameTooltip:AddLine("Aspect of the Hawk"); GameTooltip:AddLine("Rank 1/5"); GameTooltip:AddLine("The hunter takes on the aspects of a hawk, increasing Ranged Attack Power by 7. Only one Aspect can be active at a time.")
GameTooltip:SetTalent(1, 1); show(GameTooltip, "talent hook")
-- ------------------------------------------------ quests
MOCK.questID, MOCK.title = 24, "Shadumbra's Head"; QuestFrame:Show()
FireEvent("QUEST_DETAIL"); RunTimers()
local P = WoWFAF_QuestPane
print("quest pane shown:", P:IsShown(), "title:", P.title:GetText())
print("sec1:", P.sec[1].h:GetText(), "|", (P.sec[1].b:GetText() or ""):sub(1, 160))
print("banner shown:", P.banner:IsShown())
MOCK.title = "Some Other Title"; FireEvent("QUEST_PROGRESS"); print("stale banner:", P.banner:IsShown(), P.sec[1].h:GetText())
QuestFrame:Hide(); print("pane hidden with frame:", not P:IsShown())
MOCK.logIdx, MOCK.logQuest, MOCK.logTitle = 3, 504, "Crushridge Warmongers"; QuestLogFrame:Show(); SelectQuestLogEntry = SelectQuestLogEntry or nil
FireEvent("QUEST_LOG_UPDATE"); print("log pane:", P:IsShown(), P.title:GetText())
-- ------------------------------------------------ zone
FireEvent("ZONE_CHANGED_NEW_AREA"); print("zone toast:", WoWFAF_ZoneText and WoWFAF_ZoneText:IsShown(), WoWFAF_ZoneText and WoWFAF_ZoneText.main:GetText())
-- ------------------------------------------------ panel
F.OpenPanel("welcome"); print("panel:", WoWFAF_Panel:IsShown())
for _, tabid in ipairs({ "mods", "names", "display", "health", "about" }) do F.OpenPanel(tabid) end
print("PANEL OK, created frames:", MOCK_CREATED)
-- names off -> quest text keeps English names
F.OpenPanel("names")
F.Room.Set("namesNpc", false); F.Room.Set("namesZone", false); F:Fire("names")
print("markers off:", F.T.Markers("{{npc:Senani Thunderheart|سنانی}} در {{zn:Ashenvale|اشن‌ویل}}"))
F.Room.Set("namesNpc", true); F.Room.Set("namesZone", true)
print("tokens:", F.T.Tokens("درود $N، $C $R! $Gبرادر:خواهر;$Bخط"))
MOCK.sex = 3; print("tokens f:", F.T.Tokens("$Gبرادر:خواهر;")); MOCK.sex = 2
-- module toggle through the welcome page rows
F.OpenPanel("welcome")
local wp = WoWFAF_Panel and nil
F:SetModule("items", false); print("items off:", F.mods.items.state); F:SetModule("items", true); print("items on:", F.mods.items.state)
-- a cycler click
WoWFA_FDB.questDock = 3; F:Fire("options", "questDock"); print("dock free ok")
-- toggle master off/on via minimap right click
Click(WoWFAF_MinimapButton, "RightButton"); print("after right click:", WoWFA_FDB.enabled, states())
Click(WoWFAF_MinimapButton, "RightButton"); print("after 2nd:", WoWFA_FDB.enabled)
-- mode 3 + font size
WoWFA_FDB.mode = 3; F.T.RefreshAll(); print("mode3 sample:", F.T.Lines("سلام دنیا Fireball ۱۰٪", 200)[1])
-- breaker
F:RegisterModule({ id = "boom", order = 9, nameKey = "m_items", descKey = "m_items_d", data = function() return { 1 } end, api = function() return true end, install = function() end })
WoWFA_FDB.mods.boom = true; F:Refresh()
local bad = F:Wrap("boom", function() error("kaboom") end)
for i = 1, 4 do bad() end
print("breaker:", F.mods.boom.state, #WoWFA_FDB.errors, WoWFA_FDB.errors[1] and WoWFA_FDB.errors[1].e)
SlashCmdList.WOWFAF("status")
-- version share
FireEvent("CHAT_MSG_ADDON", "WoWFA", "V1|0.6.1|70900", "GUILD", "Other-Realm"); print("newer seen:", F.newerVersion)
RunTimers()
-- reset
SlashCmdList.WOWFAF("reset"); print("after reset:", states())
print("ALL DONE")
