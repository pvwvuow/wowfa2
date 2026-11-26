## task 0354-grep-opts (script)

**GREEN**


### db.toast

addon/WoWFA/Core.lua:162
```
  162     if faText and F.db and F.db.toast and F.Toast then
```
addon/WoWFA/Minimap.lua:90
```
   90             if F.Toast and F.db.toast then
```
tests/run.lua:774
```
  774     F.db.toast = false
```
tests/run.lua:776
```
  776     check("reset: the first click only arms", F.db.toast == false)
```
tests/run.lua:778
```
  778     check("reset: the second click resets", F.db.toast == true and F.db.enabled == true)
```
- ok: db.toast: 5 hits

### db.share

addon/WoWFA/Core.lua:743
```
  743     return F.db and F.db.share and C_ChatInfo and C_ChatInfo.SendAddonMessage ~= nil
```
- ok: db.share: 1 hits

### db.onUpdate

addon/WoWFA/Core.lua:645
```
  645         local risky = (m.risk == "high" and db.onUpdate >= 2) or db.onUpdate >= 3
```
addon/WoWFA/Panel.lua:587
```
  587         function() return F.db.onUpdate end,
```
addon/WoWFA/Panel.lua:589
```
  589             F.db.onUpdate = v
```
- ok: db.onUpdate: 3 hits

### db.shiftEn

addon/WoWFA/Modules/Dialog.lua:14
```
   14 -- Shift held (F.db.shiftEn, default on) = the game's English original everywhere we write
```
addon/WoWFA/Modules/Dialog.lua:48
```
   48     if not db or db.shiftEn == false or not IsShiftKeyDown then
```
addon/WoWFA/Modules/Dialog.lua:337
```
  337     if not F.db or F.db.shiftEn == false then
```
- ok: db.shiftEn: 3 hits

### db.questAuto

addon/WoWFA/Modules/Quests.lua:436
```
  436     elseif F.db.questAuto then
```
- ok: db.questAuto: 1 hits

### db.questDock

addon/WoWFA/Modules/Quests.lua:105
```
  105         if F.db.questDock == 3 then
```
addon/WoWFA/Modules/Quests.lua:111
```
  111         if F.db.questDock == 3 then
```
addon/WoWFA/Modules/Quests.lua:234
```
  234     local d = F.db.questDock
```
addon/WoWFA/Modules/Quests.lua:651
```
  651                 if pane and pane:IsShown() and F.db.questDock ~= 3 then
```
addon/WoWFA/Panel.lua:718
```
  718         function() return F.db.questDock end,
```
addon/WoWFA/Panel.lua:720
```
  720             F.db.questDock = v
```
tests/run.lua:759
```
  759     local dock = F.db.questDock
```
tests/run.lua:761
```
  761     check("quest dock cycles", F.db.questDock == dock % 3 + 1, F.db.questDock)
```
tests/run.lua:762
```
  762     F.db.questDock = dock
```
- ok: db.questDock: 9 hits

### db.listTitles

addon/WoWFA/Modules/Tracker.lua:539
```
  539             if id and F.db.listTitles ~= false then -- rc36: the list title switch
```
addon/WoWFA/Modules/Walk.lua:125
```
  125     if not F.Room.On("namesQuest") or (F.db and F.db.listTitles == false) then
```
addon/WoWFA/Modules/Walk.lua:539
```
  539         kind_active("quest") and "on" or "off", tostring(F.db and F.db.listTitles),
```
- ok: db.listTitles: 3 hits

### dlgBook

addon/WoWFA/Core.lua:199
```
  199     dlgGossip = true, dlgSay = true, dlgBook = true, -- 1.0.7: NPC talk + books (Modules/Dialog.lua)
```
addon/WoWFA/Modules/Dialog.lua:7
```
    7 --   book    books, letters, plaques (the ItemText frame, every page) (dlgBook)
```
addon/WoWFA/Modules/Dialog.lua:256
```
  256     if not on("dlgBook") then
```
addon/WoWFA/Modules/Dialog.lua:416
```
  416         local k = pane.kind == "b" and "dlgBook" or "dlgGossip"
```
addon/WoWFA/Modules/Preview.lua:611
```
  611     preset = "col", listTitles = "quest", dlgGossip = "gossip", dlgSay = "say", dlgBook = "gossip",
```
addon/WoWFA/Panel.lua:776
```
  776     panel.dlgBook = opt_toggle("dlgBook", L.dl_book, true)
```
addon/WoWFA/Room.lua:434
```
  434     "dlgGossip", "dlgSay", "dlgBook", "shiftEn" }
```
- ok: dlgBook: 7 hits

### dlgSay

addon/WoWFA/Core.lua:199
```
  199     dlgGossip = true, dlgSay = true, dlgBook = true, -- 1.0.7: NPC talk + books (Modules/Dialog.lua)
```
addon/WoWFA/Modules/Dialog.lua:6
```
    6 --   say     what NPCs say / yell / emote / whisper in the chat and in their bubbles (dlgSay)
```
addon/WoWFA/Modules/Dialog.lua:282
```
  282     return on("dlgSay") and F.db.chatFa ~= false and not F.ShiftEn()
```
addon/WoWFA/Modules/Preview.lua:467
```
  467         local okon = v and F.Dialog.On("dlgSay") and F.db.chatFa ~= false
```
addon/WoWFA/Modules/Preview.lua:611
```
  611     preset = "col", listTitles = "quest", dlgGossip = "gossip", dlgSay = "say", dlgBook = "gossip",
```
addon/WoWFA/Panel.lua:775
```
  775     panel.dlgSay = opt_toggle("dlgSay", L.dl_say, true)
```
addon/WoWFA/Room.lua:434
```
  434     "dlgGossip", "dlgSay", "dlgBook", "shiftEn" }
```
- ok: dlgSay: 7 hits

### dlgGossip

addon/WoWFA/Core.lua:199
```
  199     dlgGossip = true, dlgSay = true, dlgBook = true, -- 1.0.7: NPC talk + books (Modules/Dialog.lua)
```
addon/WoWFA/Modules/Dialog.lua:5
```
    5 --   gossip  the text of the gossip window and the quest greeting (F.db.dlgGossip)
```
addon/WoWFA/Modules/Dialog.lua:238
```
  238     if not on("dlgGossip") then
```
addon/WoWFA/Modules/Dialog.lua:247
```
  247     if not on("dlgGossip") then
```
addon/WoWFA/Modules/Dialog.lua:416
```
  416         local k = pane.kind == "b" and "dlgBook" or "dlgGossip"
```
addon/WoWFA/Modules/Preview.lua:444
```
  444         if v and F.Dialog.On("dlgGossip") then
```
addon/WoWFA/Modules/Preview.lua:611
```
  611     preset = "col", listTitles = "quest", dlgGossip = "gossip", dlgSay = "say", dlgBook = "gossip",
```
addon/WoWFA/Panel.lua:774
```
  774     panel.dlgGossip = opt_toggle("dlgGossip", L.dl_gossip, true)
```
addon/WoWFA/Room.lua:434
```
  434     "dlgGossip", "dlgSay", "dlgBook", "shiftEn" }
```
- ok: dlgGossip: 9 hits

### db.fontAll

addon/WoWFA/Modules/Font.lua:2
```
    2 -- F.db.fontAll (General > Persian font in the whole game, default OFF).
```
addon/WoWFA/Modules/Font.lua:45
```
   45     return db and db.enabled and db.fontAll == true and true or false
```
addon/WoWFA/Panel.lua:663
```
  663         function() return F.db.fontAll == true end,
```
addon/WoWFA/Panel.lua:665
```
  665             F.db.fontAll = v and true or false
```
- ok: db.fontAll: 4 hits

### db.questie

addon/WoWFA/Modules/Questie.lua:14
```
   14 -- Switch: Quests > «Questie» (F.db.questie, default on). Without Questie nothing runs.
```
addon/WoWFA/Modules/Questie.lua:41
```
   41     return db and db.enabled and db.questie ~= false and F.Room and Q.Loaded() and true or false
```
addon/WoWFA/Panel.lua:728
```
  728         function() return F.db.questie ~= false end,
```
addon/WoWFA/Panel.lua:730
```
  730             F.db.questie = v and true or false
```
- ok: db.questie: 4 hits

### sysLoot

addon/WoWFA/Locale_Opt.lua:28
```
   28 L.sy_sysLoot = fa("پیام~های غنیمت و پول")
```
addon/WoWFA/Modules/Preview.lua:609
```
  609     chatFa = "chat", sysmsg = "sys", sysLoot = "sys", sysXp = "sys", sysRep = "sys", sysGroup = "sys",
```
addon/WoWFA/Modules/Sysmsg.lua:9
```
    9 -- default on) and one switch per group (F.db.sysLoot / sysXp / sysRep / sysGroup,
```
addon/WoWFA/Modules/Sysmsg.lua:34
```
   34         return 'sysLoot'
```
addon/WoWFA/Panel.lua:613
```
  613     for _, k in ipairs({ 'sysLoot', 'sysXp', 'sysRep', 'sysGroup' }) do
```
addon/WoWFA/Room.lua:433
```
  433     "npcName", "zoneMap", "alerts", "sysmsg", "sysLoot", "sysXp", "sysRep", "sysGroup", "listTitles",
```
- ok: sysLoot: 6 hits

### "textDesc"

addon/WoWFA/Core.lua:328
```
  328         for _, k in ipairs({ "textDesc", "textStats", "textReq", "textBind", "textDetail", "textFlavor" }) do
```
addon/WoWFA/Locale.lua:427
```
  427         { k = "textDesc", lbl = "توضیحات و افکت‌ها" },
```
addon/WoWFA/Modules/Spells.lua:273
```
  273     local showDesc = #found > 0 and F.Room.On("textDesc") and dmode ~= 3
```
addon/WoWFA/Panel.lua:785
```
  785     if room_label("textDesc") ~= "textDesc" then
```
addon/WoWFA/Panel.lua:786
```
  786         room_toggle("textDesc")
```
addon/WoWFA/Room.lua:33
```
   33     "terms", "textDesc", "textStats", "textReq", "textBind", "textDetail", "textFlavor", "uiLabels",
```
addon/WoWFA/Room.lua:85
```
   85 Room.ROLE_KEY = { d = "textDesc", s = "textStats", r = "textReq", b = "textBind",
```
addon/WoWFA/Room.lua:147
```
  147     return Room.On(Room.ROLE_KEY[letter] or "textDesc")
```
addon/WoWFA/Room.lua:155
```
  155     for _, k in ipairs({ "textDesc", "textStats", "textReq", "textBind", "textDetail", "textFlavor" }) do
```
- ok: "textDesc": 9 hits

### "terms"

addon/WoWFA/Locale.lua:424
```
  424         { k = "terms", lbl = "اصطلاح‌های بازی" },
```
addon/WoWFA/Panel.lua:23
```
   23 local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
```
addon/WoWFA/Panel.lua:557
```
  557     room_toggle("terms")
```
addon/WoWFA/Room.lua:33
```
   33     "terms", "textDesc", "textStats", "textReq", "textBind", "textDetail", "textFlavor", "uiLabels",
```
addon/WoWFA/Room.lua:90
```
   90     zn = "namesZone", qs = "namesQuest", ob = "namesObj", tm = "terms", set = "namesSet" }
```
addon/WoWFA/Text.lua:330
```
  330     qs = "namesQuest", ob = "namesObj", cls = "namesClass", tm = "terms", set = "namesSet" }
```
addon/WoWFA/Text.lua:343
```
  343         local key = MARKER_KEY[fam] or "terms"
```
- ok: "terms": 7 hits

### "namesClass"

addon/WoWFA/Locale.lua:419
```
  419         { k = "namesClass", lbl = "اسم کلاس‌ها و شاخه‌ها" },
```
addon/WoWFA/Panel.lua:23
```
   23 local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
```
addon/WoWFA/Panel.lua:556
```
  556     room_toggle("namesClass")
```
addon/WoWFA/Room.lua:34
```
   34     "namesClass" } -- 15 FROZEN bits (bit 14 = namesClass, v4.1, never re-ordered)
```
addon/WoWFA/Room.lua:89
```
   89 Room.FAM_KEY = { it = "namesItem", sp = "namesSpell", cls = "namesClass", npc = "namesNpc",
```
addon/WoWFA/Text.lua:330
```
  330     qs = "namesQuest", ob = "namesObj", cls = "namesClass", tm = "terms", set = "namesSet" }
```
addon/WoWFA/Text.lua:385
```
  385     if not F.Room.On("namesClass") then -- 51-B: the room owns the cls family
```
- ok: "namesClass": 7 hits

### "faDigits"

addon/WoWFA/Locale.lua:413
```
  413         { k = "faDigits", lbl = "اعداد فارسی" },
```
addon/WoWFA/Modules/Npc.lua:51
```
   51     local key = fa .. "\1" .. tostring(T.Mode()) .. tostring(F.Room.On("faDigits"))
```
addon/WoWFA/Modules/Zones.lua:177
```
  177     local mkey = faText .. "\1" .. tostring(T.Mode()) .. tostring(F.Room.On("faDigits"))
```
addon/WoWFA/Panel.lua:23
```
   23 local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
```
addon/WoWFA/Panel.lua:558
```
  558     room_toggle("faDigits")
```
addon/WoWFA/Room.lua:35
```
   35 Room.GAME_KEYS = { "questText", "npcSay", "faDigits", "greyNotes", "namesSet", "textSet" } -- game only
```
addon/WoWFA/Text.lua:100
```
  100     if not force and not F.Room.On("faDigits") then
```
- ok: "faDigits": 7 hits

### "questText"

addon/WoWFA/Core.lua:269
```
  269     questPane = "questText", questLog = "questText", gossip = "npcSay",
```
addon/WoWFA/Core.lua:270
```
  270     trackerTitle = "questText", trackerObj = "questText", qobj = "questText",
```
addon/WoWFA/Locale.lua:437
```
  437         { k = "questText", lbl = "متن کوئست‌ها" },
```
addon/WoWFA/Modules/Preview.lua:348
```
  348         if p and active("quests") and on("questText") then
```
addon/WoWFA/Modules/Quests.lua:393
```
  393     if not F.Room.On("questText") then -- 51-B: the room owns the quest text
```
addon/WoWFA/Modules/Quests.lua:663
```
  663         if not F.Room.On("questText") then -- 51-B: the room owns the quest text
```
addon/WoWFA/Modules/Tracker.lua:186
```
  186     local list = F.Room.On("questText") and F.D.qobj and F.D.qobj[qid] -- 51-B
```
addon/WoWFA/Modules/Tracker.lua:452
```
  452                 if F.Room.On("questText") then -- 51-B
```
addon/WoWFA/Modules/Tracker.lua:466
```
  466                     if F.Room.On("questText") then -- 51-B -- a status line belongs to the title surface
```
addon/WoWFA/Modules/Tracker.lua:472
```
  472                     if F.Room.On("questText") then -- inbox/29 D2: the objective surface
```
addon/WoWFA/Modules/Tracker.lua:483
```
  483                     elseif F.Room.On("questText") and string.find(body, "%a") and not string.find(body, "[\216-\219\239]") then
```
addon/WoWFA/Modules/Tracker.lua:510
```
  510             if id and F.Room.On("questText") then -- inbox/29 D2
```
addon/WoWFA/Modules/Tracker.lua:517
```
  517         if block.lines and F.Room.On("questText") then -- inbox/29 D2
```
addon/WoWFA/Modules/Tracker.lua:537
```
  537         if F.Usable(txt) and txt ~= "" and txt ~= "..." and F.Room.On("questText") then -- inbox/29 D2
```
- ok: "questText": 22 hits

### "npcSay"

addon/WoWFA/Core.lua:269
```
  269     questPane = "questText", questLog = "questText", gossip = "npcSay",
```
addon/WoWFA/Locale.lua:438
```
  438         { k = "npcSay", lbl = "گفتگوی NPC" },
```
addon/WoWFA/Locale_Panel.lua:37
```
   37         if r.k == "npcSay" then
```
addon/WoWFA/Modules/Dialog.lua:38
```
   38     return db and db.enabled and F.Room and F.Room.On("npcSay") and true or false
```
addon/WoWFA/Panel.lua:23
```
   23 local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
```
addon/WoWFA/Panel.lua:773
```
  773     room_toggle("npcSay")
```
addon/WoWFA/Room.lua:35
```
   35 Room.GAME_KEYS = { "questText", "npcSay", "faDigits", "greyNotes", "namesSet", "textSet" } -- game only
```
addon/WoWFA/Room.lua:888
```
  888     { "surf.gossip", "npcSay" },
```
- ok: "npcSay": 8 hits

### "namesQuest"

addon/WoWFA/Locale.lua:422
```
  422         { k = "namesQuest", lbl = "عنوان کوئست‌ها" },
```
addon/WoWFA/Modules/Quests.lua:289
```
  289     if not F.Room.On("namesQuest") and en ~= "" then -- 51-B
```
addon/WoWFA/Modules/Tracker.lua:66
```
   66     if not F.Room.On("namesQuest") then -- 51-B
```
addon/WoWFA/Modules/Tracker.lua:459
```
  459                     elseif F.Room.On("namesQuest") then
```
addon/WoWFA/Modules/Tracker.lua:543
```
  543                 elseif F.Room.On("namesQuest") then
```
addon/WoWFA/Modules/Tracker.lua:566
```
  566             if F.Usable(txt) and txt ~= "" and F.Room.On("namesQuest") then -- 1.1.6: quest titles follow «quest titles», not the NPC talk switch
```
addon/WoWFA/Modules/Tracker.lua:572
```
  572                     elseif F.Room.On("namesQuest") then
```
addon/WoWFA/Modules/Walk.lua:125
```
  125     if not F.Room.On("namesQuest") or (F.db and F.db.listTitles == false) then
```
addon/WoWFA/Modules/Walk.lua:156
```
  156     if not F.Room.On("namesQuest") or type(title) ~= "string" or title == "" then
```
addon/WoWFA/Modules/Walk.lua:540
```
  540         tostring(F.Room.On("namesQuest")), tostring(F.Room.On("questText")), n, w, li))
```
addon/WoWFA/Panel.lua:23
```
   23 local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
```
addon/WoWFA/Panel.lua:715
```
  715     room_toggle("namesQuest")
```
addon/WoWFA/Room.lua:32
```
   32 Room.SITE_KEYS = { "namesItem", "namesSpell", "namesNpc", "namesZone", "namesQuest", "namesObj",
```
addon/WoWFA/Room.lua:90
```
   90     zn = "namesZone", qs = "namesQuest", ob = "namesObj", tm = "terms", set = "namesSet" }
```
- ok: "namesQuest": 15 hits

### "namesSpell"

addon/WoWFA/Locale.lua:418
```
  418         { k = "namesSpell", lbl = "اسم اسپل‌ها و استعدادها" },
```
addon/WoWFA/Modules/Spells.lua:270
```
  270     local showName = faName ~= nil and F.Room.On("namesSpell") and tmode ~= 3 -- 51-B
```
addon/WoWFA/Modules/Spells.lua:492
```
  492             if T.Once(tt, "t" .. T.NameKey(first)) and F.Room.On("namesSpell") then
```
addon/WoWFA/Modules/Walk.lua:249
```
  249     if not F.Room.On("namesSpell") or F.Disp("spellbook", "title") == 3 then
```
addon/WoWFA/Panel.lua:23
```
   23 local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
```
addon/WoWFA/Panel.lua:784
```
  784     room_toggle("namesSpell")
```
addon/WoWFA/Room.lua:32
```
   32 Room.SITE_KEYS = { "namesItem", "namesSpell", "namesNpc", "namesZone", "namesQuest", "namesObj",
```
addon/WoWFA/Room.lua:89
```
   89 Room.FAM_KEY = { it = "namesItem", sp = "namesSpell", cls = "namesClass", npc = "namesNpc",
```
addon/WoWFA/Text.lua:329
```
  329 local MARKER_KEY = { it = "namesItem", sp = "namesSpell", npc = "namesNpc", zn = "namesZone", fac = "namesNpc",
```
tests/run.lua:497
```
  497         local wasSp, wasQt = FF.Room.On("namesSpell"), FF.Room.On("questText")
```
tests/run.lua:498
```
  498         FF.Room.Set("namesSpell", true)
```
tests/run.lua:519
```
  519         FF.Room.Set("namesSpell", wasSp)
```
- ok: "namesSpell": 12 hits

### "namesZone"

addon/WoWFA/Core.lua:271
```
  271     zoneArrival = "namesZone", zoneMinimap = "namesZone", zoneMap = "namesZone", zoneTip = "namesZone",
```
addon/WoWFA/Locale.lua:421
```
  421         { k = "namesZone", lbl = "اسم مناطق و دانجن‌ها" },
```
addon/WoWFA/Modules/Preview.lua:212
```
  212         local ok = on("namesZone") and active("dungeons")
```
addon/WoWFA/Modules/Preview.lua:231
```
  231         local ok = on("namesZone") and active("dungeons") and mode ~= 3 and v ~= nil
```
addon/WoWFA/Modules/Taxi.lua:10
```
   10     return db and db.enabled and F.Room and F.Room.On("namesZone") and true or false
```
addon/WoWFA/Modules/Zones.lua:30
```
   30     if not F.Room.On("namesZone") then -- 51-B
```
addon/WoWFA/Modules/Zones.lua:269
```
  269     if kind == "minimap" and not F.Room.On("namesZone") then
```
addon/WoWFA/Modules/Zones.lua:271
```
  271     elseif kind == "arrival" and not F.Room.On("namesZone") then
```
addon/WoWFA/Modules/Zones.lua:273
```
  273     elseif (kind == "map" or kind == "maplabel") and (not F.Room.On("namesZone") or map_mode() == 3) then
```
addon/WoWFA/Modules/Zones.lua:316
```
  316     if not M.active or not F.Room.On("namesZone") then
```
addon/WoWFA/Modules/Zones.lua:425
```
  425     if type(wm) ~= "table" or not M.active or not F.Room.On("namesZone") then
```
addon/WoWFA/Modules/Zones.lua:561
```
  561         if F.Room.On("namesZone") then
```
addon/WoWFA/Modules/Zones.lua:564
```
  564         if F.Room.On("namesZone") and (mode == 1 or (mode == 2 and dungeon)) then
```
addon/WoWFA/Modules/Zones.lua:569
```
  569         if F.Room.On("namesZone") and mode == 1 and sub ~= "" then
```
- ok: "namesZone": 32 hits

### "namesNpc"

addon/WoWFA/Core.lua:272
```
  272     npcTip = "namesNpc", objTip = "namesObj",
```
addon/WoWFA/Locale.lua:420
```
  420         { k = "namesNpc", lbl = "اسم شخصیت‌ها و موجودها" },
```
addon/WoWFA/Modules/Npc.lua:36
```
   36     if not F.Room.On("namesNpc") or mode() == 3 then
```
addon/WoWFA/Modules/Questie.lua:117
```
  117     local npcOn = F.Room.On("namesNpc")
```
addon/WoWFA/Panel.lua:23
```
   23 local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
```
addon/WoWFA/Panel.lua:761
```
  761     room_toggle("namesNpc")
```
addon/WoWFA/Room.lua:32
```
   32 Room.SITE_KEYS = { "namesItem", "namesSpell", "namesNpc", "namesZone", "namesQuest", "namesObj",
```
addon/WoWFA/Room.lua:89
```
   89 Room.FAM_KEY = { it = "namesItem", sp = "namesSpell", cls = "namesClass", npc = "namesNpc",
```
addon/WoWFA/Text.lua:329
```
  329 local MARKER_KEY = { it = "namesItem", sp = "namesSpell", npc = "namesNpc", zn = "namesZone", fac = "namesNpc",
```
tests/run.lua:436
```
  436         F.Room.Set("namesNpc", false)
```
tests/run.lua:438
```
  438         F.Room.Set("namesNpc", true)
```
- ok: "namesNpc": 11 hits

### RELEASE_LOCK

addon/WoWFA/Core.lua:290
```
  290 F.RELEASE_LOCK = { items = true,
```
addon/WoWFA/Core.lua:669
```
  669         if F.RELEASE_LOCK[m.id] and not F.RELEASE_UNLOCK[m.id] then
```
addon/WoWFA/Core.lua:891
```
  891         if F.RELEASE_LOCK[what] then
```
addon/WoWFA/Room.lua:135
```
  135     if F.RELEASE_LOCK and F.RELEASE_LOCK[key] and not F.RELEASE_UNLOCK[key] then
```
tests/lua/wow_mock.lua:539
```
  539     if e == "PLAYER_ENTERING_WORLD" and WOWFA_TEST_UNLOCK ~= false and WoWFAF and WoWFAF.RELEASE_LOCK then
```
tests/lua/wow_mock.lua:540
```
  540         for k in pairs(WoWFAF.RELEASE_LOCK) do
```
tests/run.lua:426
```
  426     check("namesNpc is no longer release-locked", F.RELEASE_LOCK.namesNpc == nil and F.RELEASE_LOCK.npc == nil)
```
tests/run.lua:733
```
  733         check("panel lists shipped module " .. id, PF.mods[id] ~= nil and not F.RELEASE_LOCK[id])
```
- ok: RELEASE_LOCK: 8 hits

### F:Active("

addon/WoWFA/Modules/Spells.lua:409
```
  409         if F:Active("spellbook") then
```
addon/WoWFA/Modules/Spells.lua:467
```
  467     local mod = (F:Active("spellbook") and "spellbook") or (F:Active("talents") and "talents") or nil
```
- ok: F:Active(": 2 hits

### mods.dungeons

tests/run.lua:779
```
  779     check("reset: modules still active", F.mods.quests.active and F.mods.dungeons.active, F.mods.quests.state)
```
- ok: mods.dungeons: 1 hits

### db.gameUi

addon/WoWFA/Modules/GameUI.lua:18
```
   18 -- lookup (CPU). Switch: General > the game's windows (F.db.gameUi, default on); off puts
```
addon/WoWFA/Modules/GameUI.lua:58
```
   58     return db and db.enabled and db.gameUi ~= false and true or false
```
addon/WoWFA/Panel.lua:570
```
  570             function() return F.db.gameUi ~= false end,
```
addon/WoWFA/Panel.lua:572
```
  572                 F.db.gameUi = v and true or false
```
tests/run.lua:826
```
  826     F.db.gameUi = false
```
tests/run.lua:833
```
  833     F.db.gameUi = nil
```
tests/run.lua:840
```
  840         check("gameui: the switch turns it off", F.db.gameUi == false)
```
tests/run.lua:842
```
  842         check("gameui: and on again", F.db.gameUi == true)
```
- ok: db.gameUi: 8 hits

### F.db.mode

addon/WoWFA/Text.lua:22
```
   22     local m = F.db and F.db.mode
```
tests/run.lua:364
```
  364     local oldMode, oldCol = F.db.mode, F.db.col
```
tests/run.lua:367
```
  367     F.db.mode = 1
```
tests/run.lua:379
```
  379     F.db.mode = 3
```
tests/run.lua:388
```
  388     F.db.mode = 1
```
tests/run.lua:407
```
  407     F.db.col, F.db.mode = oldCol, oldMode
```
- ok: F.db.mode: 6 hits

### zoneToast

addon/WoWFA/Core.lua:191
```
  191     zoneToast = 4,
```
addon/WoWFA/Core.lua:221
```
  221 local RANGES = { mode = { 1, 3 }, fontSize = { 9, 20 }, itemDetail = { 1, 3 }, itemStyle = { 1, 2 }, questDock = { 1, 3 }, zoneToast = { 1, 4 }, onUpdate = { 1,
```
addon/WoWFA/Modules/Zones.lua:276
```
  276     -- zoneToast 1-3 own the arrival toast in their own way; only 4 = in place
```
addon/WoWFA/Modules/Zones.lua:277
```
  277     if kind == "arrival" and (not F.db or F.db.zoneToast ~= 4) then
```
addon/WoWFA/Modules/Zones.lua:547
```
  547     local mode = F.db.zoneToast
```
addon/WoWFA/Modules/Zones.lua:649
```
  649     -- the big arrival strings: zoneToast 4 = "in place" (the 1-3 toast values
```
addon/WoWFA/Modules/Zones.lua:664
```
  664         if a == "zoneMap" or b == "zoneMap" or a == "zoneToast" or b == "zoneToast" or a == "fontOutline" then -- rc36
```
addon/WoWFA/Room.lua:431
```
  431 local PROFILE_OPTS = { "fontSize", "scale", "questDock", "questAuto", "zoneToast", "onUpdate", "toast", "share",
```
- ok: zoneToast: 8 hits
