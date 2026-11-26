## task 0374-grep-static (script)

**GREEN**


### staticTitle = {}

addon/WoWFA/Modules/Tracker.lua:307
```
  291     throttleT[key] = now
  292     return false
  293 end
  294 
  295 -- ------------------------------------------------------- quest title index
  296 -- Brain review #136-7: titleIndex holds ONLY the quest-log entries and is
  297 -- rebuilt on QUEST_LOG_UPDATE; the static EN-title map is built ONCE from the
  298 -- data's EN field (first id wins) and is used only as a fallback - no
  299 -- GetTitleForQuestID call per quest per update.
  300 local titleIndex = {}
  301 local staticTitle = nil
  302 
  303 local function static_titles()
  304     if staticTitle then
  305         return staticTitle
  306     end
  307     staticTitle = {}
  308     for id, row in pairs(F.D.quests or {}) do
  309         if type(row) == "string" then
  310             -- wowfa2: field 1 is the title hash (F.TitleHash), not the EN title
  311             local p = F.Split(row, SEP)
  312             local k = (type(p[1]) == "string" and p[1]) or ""
  313             if k ~= "" and not staticTitle[k] then
  314                 staticTitle[k] = id
  315             end
  316         end
  317     end
  318     return staticTitle
  319 end
  320 
  321 local function rebuild_titles()
  322     titleIndex = {}
  323     if not GetQuestLogTitle and C_QuestLog and C_QuestLog.GetInfo and C_QuestLog.GetNumQuestLogEntries then
```
- ok: staticTitle = {}: 1 hits

### local function get_quest(id)

addon/WoWFA/Modules/Tracker.lua:50
```
   34 -- inbox/29 D2: the surface flags this module renders (the "surf" listener key)
   35 local SURF_OWNED = { questLog = true, gossip = true, trackerTitle = true, trackerObj = true }
   36 
   37 function M.data()
   38     return F.D.quests
   39 end
   40 
   41 function M.api()
   42     -- rc16 (the owner: the tracker page said "turned itself off"): the modern client has
   43     -- no GetQuestLogTitle (C_QuestLog.GetInfo instead) and its quest list sits under the map
   44     local frames = QuestWatchFrame ~= nil or WatchFrame ~= nil or ObjectiveTrackerFrame ~= nil
   45         or QuestLogFrame ~= nil or QuestMapFrame ~= nil or WorldMapFrame ~= nil or C_QuestLog ~= nil
   46     return frames and (GetQuestLogTitle ~= nil or (C_QuestLog ~= nil and C_QuestLog.GetInfo ~= nil))
   47 end
   48 
   49 -- ------------------------------------------------------------- data helpers
   50 local function get_quest(id)
   51     local raw = id and F.D.quests[id]
   52     if type(raw) ~= "string" then
   53         return nil
   54     end
   55     local p = F.Split(raw, SEP)
   56     return { h = p[1] or "", t = p[2] or "" }
   57 end
   58 
   59 local function simple(s)
   60     return (string.gsub(string.lower(tostring(s or "")), "[^%w]", ""))
   61 end
   62 
   63 -- names.qs governs quest titles; an empty Persian title falls back to the
   64 -- English one (the B4 pattern) - nil here means "leave the line alone"
   65 local function title_fa(id)
   66     if not F.Room.On("namesQuest") then -- 51-B
```
- ok: local function get_quest(id): 1 hits

### local function get(id)

addon/WoWFA/Modules/Quests.lua:38
```
   22 local C = F.C
   23 local SEP = "\031"
   24 local PW, PH = 340, 440
   25 local PAD = 14                        -- inbox/29 C: side padding
   26 local BODY_W = PW - PAD * 2 - 4       -- minus the 2px anchor slack per side
   27 
   28 local M = { id = "quests", order = 2, risk = "low", nameKey = "m_quests", descKey = "m_quests_d", watchMiss = true }
   29 
   30 function M.data()
   31     return F.D.quests
   32 end
   33 
   34 function M.api()
   35     return GetQuestID ~= nil and (QuestFrame ~= nil or QuestLogFrame ~= nil or QuestMapFrame ~= nil)
   36 end
   37 
   38 local function get(id)
   39     local raw = id and F.D.quests[id]
   40     if type(raw) ~= "string" then
   41         return nil
   42     end
   43     local p = F.Split(raw, SEP)
   44     return { h = p[1] or "", t = p[2] or "", obj = p[3] or "", details = p[4] or "", progress = p[5] or "", completion = p[6] or "", desc = p[7] or "" }
   45 end
   46 
   47 local function simple(s)
   48     return (string.gsub(string.lower(tostring(s or "")), "[^%w]", ""))
   49 end
   50 
   51 -- Brain review (#139): "on screen" = VISIBLE, not just the own shown flag - a
   52 -- QuestMapFrame keeps IsShown() true inside a CLOSED world map, and the pane
   53 -- would dock to (and stay on screen for) an invisible host. IsVisible is used
   54 -- only when it answers a real boolean; anything else (a client without it, or
```
- ok: local function get(id): 1 hits

### local function have(id)

addon/WoWFA/Modules/Harvest.lua:59
```
   43     if type(v) == "string" and v ~= "" and (not F.Usable or F.Usable(v)) then
   44         return v
   45     end
   46     return nil
   47 end
   48 
   49 local function on()
   50     return F.db ~= nil and F.db.enabled ~= false and F.db.harvest ~= false
   51 end
   52 
   53 local function zone()
   54     local ok, z = pcall(GetRealZoneText)
   55     return (ok and str(z)) or nil
   56 end
   57 
   58 -- the Persian parts the data already has for a quest id (nil = no record at all)
   59 local function have(id)
   60     local raw = id and F.D and F.D.quests and F.D.quests[id]
   61     if type(raw) ~= "string" then
   62         return nil
   63     end
   64     local p = F.Split(raw, SEP)
   65     return { t = p[2] or "", obj = p[3] or "", det = p[4] or "", pro = p[5] or "", com = p[6] or "" }
   66 end
   67 
   68 -- keep the English parts the data lacks. parts = { t, obj, det, pro, com, o = { lines } }
   69 function H.Quest(id, parts, level)
   70     id = tonumber(id)
   71     if not on() or not id or id <= 0 or type(parts) ~= "table" then
   72         return
   73     end
   74     local fa = have(id)
   75     local need, any = {}, false
```
- ok: local function have(id): 1 hits

### function F.Split

addon/WoWFA/Core.lua:90
```
   74 function F.After(sec, fn)
   75     if C_Timer and C_Timer.After then
   76         C_Timer.After(sec, fn)
   77         return
   78     end
   79     local f = CreateFrame("Frame")
   80     local t = 0
   81     f:SetScript("OnUpdate", function(self, el)
   82         t = t + el
   83         if t >= sec then
   84             self:SetScript("OnUpdate", nil)
   85             fn()
   86         end
   87     end)
   88 end
   89 
   90 function F.Split(s, sep)
   91     local out, pos = {}, 1
   92     while true do
   93         local a = string.find(s, sep, pos, true)
   94         if not a then
   95             out[#out + 1] = string.sub(s, pos)
   96             return out
   97         end
   98         out[#out + 1] = string.sub(s, pos, a - 1)
   99         pos = a + #sep
  100     end
  101 end
  102 
  103 -- djb2 over the bytes of T.NameKey(title), mod 2^32, as 8 lowercase hex chars.
  104 -- Mirrors tools/wfa/core.py title_hash: the data stores this hash instead of
  105 -- the English quest title. h * 33 + byte stays below 2^38 (exact in doubles);
  106 -- the hex is built by hand because %x on a 32-bit client int would overflow.
```
- ok: function F.Split: 1 hits

### F.D = 

addon/WoWFA/Core.lua:605
```
  589 function F:MissFresh()
  590     local db = F.db
  591     if db and db.missV ~= F.VERSION then
  592         db.miss, db.missN, db.missV, db.missTN = {}, 0, F.VERSION, 0
  593     end
  594 end
  595 
  596 function F:ClearMiss()
  597     if F.db then
  598         F.db.miss, F.db.missN, F.db.missTN = {}, 0, 0
  599         F:Fire("miss")
  600     end
  601 end
  602 
  603 local function check_data()
  604     local D = WoWFA_FData
  605     F.D = type(D) == "table" and D or {}
  606     if type(D) ~= "table" or type(D.meta) ~= "table" then
  607         F.dataState = "nodata"
  608     elseif tonumber(D.meta.schema) ~= F.SCHEMA then
  609         F.dataState = "schema"
  610     else
  611         F.dataState = "ok"
  612     end
  613     F.dataBuild = (type(D) == "table" and type(D.meta) == "table" and tonumber(D.meta.buildNum)) or 0
  614     F.dataBuildText = (type(D) == "table" and type(D.meta) == "table" and D.meta.build) or "-"
  615     F.dataVersion = string.match(tostring(F.dataBuildText), "^(%d+%.%d+%.%d+)") or ""
  616     F.buildNewer = F.dataBuild > 0 and (F.clientBuild or 0) > F.dataBuild
  617     F.patchNewer = F.dataVersion ~= "" and F.CompareVersion(F.clientVersion or "", F.dataVersion) > 0
  618 end
  619 
  620 local function evaluate(m)
  621     local db = F.db
```
- ok: F.D = : 1 hits
