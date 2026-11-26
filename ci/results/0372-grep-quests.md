## task 0372-grep-quests (script)

**GREEN**


### D.quests

addon/WoWFA/Modules/Harvest.lua:60
```
   58 -- the Persian parts the data already has for a quest id (nil = no record at all)
   59 local function have(id)
   60     local raw = id and F.D and F.D.quests and F.D.quests[id]
   61     if type(raw) ~= "string" then
   62         return nil
```
addon/WoWFA/Modules/Preview.lua:280
```
  278 local function quest_row(title)
  279     local h = F.TitleHash(title)
  280     for id, row in pairs((F.D and F.D.quests) or {}) do
  281         if type(row) == "string" and string.sub(row, 1, #h) == h and h ~= "" then
  282             local p = F.Split(row, "\031")
```
addon/WoWFA/Modules/Quests.lua:31
```
   29 
   30 function M.data()
   31     return F.D.quests
   32 end
   33 
```
addon/WoWFA/Modules/Quests.lua:39
```
   37 
   38 local function get(id)
   39     local raw = id and F.D.quests[id]
   40     if type(raw) ~= "string" then
   41         return nil
```
addon/WoWFA/Modules/Tracker.lua:38
```
   36 
   37 function M.data()
   38     return F.D.quests
   39 end
   40 
```
addon/WoWFA/Modules/Tracker.lua:51
```
   49 -- ------------------------------------------------------------- data helpers
   50 local function get_quest(id)
   51     local raw = id and F.D.quests[id]
   52     if type(raw) ~= "string" then
   53         return nil
```
addon/WoWFA/Modules/Tracker.lua:308
```
  306     end
  307     staticTitle = {}
  308     for id, row in pairs(F.D.quests or {}) do
  309         if type(row) == "string" then
  310             -- wowfa2: field 1 is the title hash (F.TitleHash), not the EN title
```
addon/WoWFA/Modules/Walk.lua:93
```
   91     if not byHash then
   92         byHash = {}
   93         for id, row in pairs((F.D and F.D.quests) or {}) do
   94             if type(row) == "string" then
   95                 local h = string.match(row, "^([^" .. SEP .. "]*)")
```
addon/WoWFA/Modules/Walk.lua:103
```
  101     end
  102     local id = W.LogId(title)
  103     if not id or type(F.D.quests[id]) ~= "string" then
  104         local h = F.TitleHash(title)
  105         id = h ~= "" and byHash[h] or nil
```
addon/WoWFA/Modules/Walk.lua:107
```
  105         id = h ~= "" and byHash[h] or nil
  106     end
  107     local row = id and F.D.quests[id]
  108     if type(row) ~= "string" then
  109         -- 1.0.5: a quest of the player's log we have no row for goes to the Status list
```
addon/WoWFA/Modules/Walk.lua:552
```
  550                     local h = F.TitleHash(title)
  551                     F.Chat(string.format("  '%s' id=%s data=%s hash=%s", p, tostring(id),
  552                         tostring(id and type(F.D.quests[id]) == "string"), h))
  553                     shown = shown + 1
  554                 end
```
tests/run.lua:75
```
   73 -- ------------------------------------------------------------------- quests
   74 local qid, qhash
   75 for id, raw in pairs(D.quests) do
   76     local p = F.Split(raw, "\031")
   77     if p[2] ~= "" and p[4] ~= "" and p[1] ~= "" then
```
- ok: D.quests: 12 hits

### D.qobj

addon/WoWFA/Modules/Tracker.lua:21
```
   19 --   item    "%s: %d/%d"        ->  {{it:EN|fa}}: %d/%d      (names.itn)
   20 --   object  "%s: %d/%d"        ->  {{ob:EN|fa}}: %d/%d
   21 --   reputation / event / log  ->  the Persian objective text from D.qobj
   22 -- The EN side is parsed with the client's own GlobalStrings turned into
   23 -- patterns (English constants as the fallback); C_QuestLog.GetQuestObjectives
```
addon/WoWFA/Modules/Tracker.lua:186
```
  184 -- reputation / event / log objectives: the Persian text we already have
  185 local function line_from_qobj(qid, idx)
  186     local list = F.Room.On("questText") and F.D.qobj and F.D.qobj[qid] -- 51-B
  187     local fa = list and list[idx]
  188     if type(fa) ~= "string" or fa == "" then
```
- ok: D.qobj: 2 hits

### .quests

addon/WoWFA/Modules/Harvest.lua:60
```
   58 -- the Persian parts the data already has for a quest id (nil = no record at all)
   59 local function have(id)
   60     local raw = id and F.D and F.D.quests and F.D.quests[id]
   61     if type(raw) ~= "string" then
   62         return nil
```
addon/WoWFA/Modules/Preview.lua:280
```
  278 local function quest_row(title)
  279     local h = F.TitleHash(title)
  280     for id, row in pairs((F.D and F.D.quests) or {}) do
  281         if type(row) == "string" and string.sub(row, 1, #h) == h and h ~= "" then
  282             local p = F.Split(row, "\031")
```
addon/WoWFA/Modules/Quests.lua:31
```
   29 
   30 function M.data()
   31     return F.D.quests
   32 end
   33 
```
addon/WoWFA/Modules/Quests.lua:39
```
   37 
   38 local function get(id)
   39     local raw = id and F.D.quests[id]
   40     if type(raw) ~= "string" then
   41         return nil
```
addon/WoWFA/Modules/Tracker.lua:38
```
   36 
   37 function M.data()
   38     return F.D.quests
   39 end
   40 
```
addon/WoWFA/Modules/Tracker.lua:51
```
   49 -- ------------------------------------------------------------- data helpers
   50 local function get_quest(id)
   51     local raw = id and F.D.quests[id]
   52     if type(raw) ~= "string" then
   53         return nil
```
addon/WoWFA/Modules/Tracker.lua:308
```
  306     end
  307     staticTitle = {}
  308     for id, row in pairs(F.D.quests or {}) do
  309         if type(row) == "string" then
  310             -- wowfa2: field 1 is the title hash (F.TitleHash), not the EN title
```
addon/WoWFA/Modules/Walk.lua:93
```
   91     if not byHash then
   92         byHash = {}
   93         for id, row in pairs((F.D and F.D.quests) or {}) do
   94             if type(row) == "string" then
   95                 local h = string.match(row, "^([^" .. SEP .. "]*)")
```
addon/WoWFA/Modules/Walk.lua:103
```
  101     end
  102     local id = W.LogId(title)
  103     if not id or type(F.D.quests[id]) ~= "string" then
  104         local h = F.TitleHash(title)
  105         id = h ~= "" and byHash[h] or nil
```
addon/WoWFA/Modules/Walk.lua:107
```
  105         id = h ~= "" and byHash[h] or nil
  106     end
  107     local row = id and F.D.quests[id]
  108     if type(row) ~= "string" then
  109         -- 1.0.5: a quest of the player's log we have no row for goes to the Status list
```
addon/WoWFA/Modules/Walk.lua:552
```
  550                     local h = F.TitleHash(title)
  551                     F.Chat(string.format("  '%s' id=%s data=%s hash=%s", p, tostring(id),
  552                         tostring(id and type(F.D.quests[id]) == "string"), h))
  553                     shown = shown + 1
  554                 end
```
addon/WoWFA/Panel.lua:682
```
  680     room_tog("questText", "quest")
  681     header(PN.h_pane)
  682     panel.mods.quests = tog(PN.quests, nil,
  683         function() return mods_on("quests") end,
  684         function(v) F:SetModule("quests", v) end, "quest")
```
addon/WoWFA/Panel.lua:691
```
  689             F:Fire("options", "questDock")
  690         end)
  691     panel.mods.quests.wfaHi = "qpane"
  692     panel.dock.dimIf = function() return not mods_on("quests") end
  693     panel.questAuto = opt_tog("questAuto", PN.questAuto, PN.questAuto_d, true)
```
tests/run.lua:75
```
   73 -- ------------------------------------------------------------------- quests
   74 local qid, qhash
   75 for id, raw in pairs(D.quests) do
   76     local p = F.Split(raw, "\031")
   77     if p[2] ~= "" and p[4] ~= "" and p[1] ~= "" then
```
tests/run.lua:737
```
  735 
  736     Click(PF.master)
  737     check("master off from the panel", F.db.enabled == false and not F.mods.quests.active, F.mods.quests.state)
  738     Click(PF.master)
  739     check("master back on", F.db.enabled == true and F.mods.quests.active, F.mods.quests.state)
```
tests/run.lua:739
```
  737     check("master off from the panel", F.db.enabled == false and not F.mods.quests.active, F.mods.quests.state)
  738     Click(PF.master)
  739     check("master back on", F.db.enabled == true and F.mods.quests.active, F.mods.quests.state)
  740 
  741     Click(PF.mods.tracker)
```
tests/run.lua:778
```
  776 
  777     F.PanelRefresh()
  778     local qs = PF.health.mods.quests.val:GetText()
  779     check("status: module state in Persian", non_ascii(qs), qs)
  780     check("status: data build shown", PF.health.data.val:GetText() == tostring(F.dataBuildText), PF.health.data.val:GetText())
```
tests/run.lua:792
```
  790     Click(PF.reset)
  791     check("reset: the second click resets", F.db.toast == true and F.db.enabled == true)
  792     check("reset: modules still active", F.mods.quests.active and F.mods.dungeons.active, F.mods.quests.state)
  793     F.TogglePanel()
  794     check("panel closed at the end", not PF:IsShown())
```
- ok: .quests: 18 hits

### .qobj

addon/WoWFA/Modules/Tracker.lua:21
```
   19 --   item    "%s: %d/%d"        ->  {{it:EN|fa}}: %d/%d      (names.itn)
   20 --   object  "%s: %d/%d"        ->  {{ob:EN|fa}}: %d/%d
   21 --   reputation / event / log  ->  the Persian objective text from D.qobj
   22 -- The EN side is parsed with the client's own GlobalStrings turned into
   23 -- patterns (English constants as the fallback); C_QuestLog.GetQuestObjectives
```
addon/WoWFA/Modules/Tracker.lua:186
```
  184 -- reputation / event / log objectives: the Persian text we already have
  185 local function line_from_qobj(qid, idx)
  186     local list = F.Room.On("questText") and F.D.qobj and F.D.qobj[qid] -- 51-B
  187     local fa = list and list[idx]
  188     if type(fa) ~= "string" or fa == "" then
```
addon/WoWFA/Room.lua:380
```
  378     -- the game-only bits merge the old where-flags (AND inside each family)
  379     local surf = fdb.surf or {}
  380     d.questText = surf.questPane ~= false and surf.questLog ~= false and surf.qobj ~= false
  381     d.npcSay = surf.gossip ~= false
  382     d.greyNotes = fdb.itemNotes ~= false
```
- ok: .qobj: 3 hits

### \031

addon/WoWFA/Modules/Harvest.lua:15
```
   13 local F = WoWFAF
   14 local T = F.T
   15 local SEP = "\031"
   16 local H = {}
   17 F.Harvest = H
```
addon/WoWFA/Modules/Preview.lua:282
```
  280     for id, row in pairs((F.D and F.D.quests) or {}) do
  281         if type(row) == "string" and string.sub(row, 1, #h) == h and h ~= "" then
  282             local p = F.Split(row, "\031")
  283             if (p[2] or "") ~= "" then
  284                 return p
```
addon/WoWFA/Modules/Quests.lua:23
```
   21 local UI = F.UI
   22 local C = F.C
   23 local SEP = "\031"
   24 local PW, PH = 340, 440
   25 local PAD = 14                        -- inbox/29 C: side padding
```
addon/WoWFA/Modules/Tracker.lua:30
```
   28 local T = F.T
   29 local C = F.C
   30 local SEP = "\031"
   31 
   32 local M = { id = "tracker", order = 7, risk = "low", nameKey = "m_tracker", descKey = "m_tracker_d" }
```
addon/WoWFA/Modules/Walk.lua:19
```
   17 F.Walk = W
   18 
   19 local SEP = "\031"
   20 -- 1.1.0: the outline family of a line by its role (titles = quest names, spell = spell names)
   21 local OLFAM = { title = "qs", spell = "sp" }
```
tests/run.lua:76
```
   74 local qid, qhash
   75 for id, raw in pairs(D.quests) do
   76     local p = F.Split(raw, "\031")
   77     if p[2] ~= "" and p[4] ~= "" and p[1] ~= "" then
   78         if not qid or id < qid then
```
- ok: \031: 6 hits
