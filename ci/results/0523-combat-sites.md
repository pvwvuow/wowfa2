## task 0523-combat-sites (script)

**GREEN**


### InCombatLockdown

addon/WoWFA/Core.lua:159
```
  157     f.wfaEsc = true
  158     local function free()
  159         return not (InCombatLockdown and InCombatLockdown())
  160     end
  161     local function pass(self)
```
addon/WoWFA/Core.lua:836
```
  834         return
  835     end
  836     if InCombatLockdown and InCombatLockdown() then
  837         return
  838     end
```
addon/WoWFA/Dump.lua:169
```
  167         return
  168     end
  169     if InCombatLockdown and InCombatLockdown() then
  170         return -- pause in combat, resume after
  171     end
```
addon/WoWFA/Modules/Beacon.lua:717
```
  715         return
  716     end
  717     if InCombatLockdown and InCombatLockdown() then
  718         if tries < 12 then
  719             F.After(20, function()
```
addon/WoWFA/Modules/Blocked.lua:80
```
   78     end
   79     pcall(function()
   80         local combat = InCombatLockdown and InCombatLockdown() and "combat" or "no combat"
   81         -- 1.1.2: the event fires INSIDE the blocked call, so the stack names the game code that
   82         -- made it (the first 4 files:lines) - the next report says exactly where it came from
```
addon/WoWFA/Modules/Dialog.lua:350
```
  348     -- the tooltip under the mouse shows again (English while Shift is down); never in
  349     -- combat (another frame's OnEnter is not ours to run then)
  350     if InCombatLockdown and InCombatLockdown() then
  351         return
  352     end
```
addon/WoWFA/Modules/GameUI.lua:115
```
  113 
  114 local function combat()
  115     return InCombatLockdown and InCombatLockdown() and true or false
  116 end
  117 
```
addon/WoWFA/Modules/Questie.lua:90
```
   88         return false
   89     end
   90     if InCombatLockdown and InCombatLockdown() then
   91         return false -- 1.1.1: no tooltip rewrite (and no second Show) in combat
   92     end
```
addon/WoWFA/Modules/Tracker.lua:369
```
  367 
  368 local function in_combat_modern()
  369     if InCombatLockdown and InCombatLockdown() then
  370         pendingModern = true
  371         return true
```
addon/WoWFA/Modules/Walk.lua:356
```
  354     -- 1.1.1: never write to the game's / Questie's lines in combat (their rows hold protected
  355     -- buttons); the line is remembered and done when the combat ends
  356     if InCombatLockdown and InCombatLockdown() then
  357         pendC[fs] = true
  358         return
```
addon/WoWFA/Modules/Walk.lua:474
```
  472 
  473 function W.Scan()
  474     if InCombatLockdown and InCombatLockdown() then
  475         return -- rc36: never touch the tracker in combat; the ticker scans again after
  476     end
```
addon/WoWFA/Modules/Walk.lua:663
```
  661             acc = 0
  662         end
  663         if InCombatLockdown and InCombatLockdown() then
  664             return -- 1.1.1: nothing is touched in combat
  665         end
```
addon/WoWFA/Modules/Zones.lua:283
```
  281     -- (maplabel) are plain font strings and the quest list redraws on every kill - they
  282     -- follow it in combat too. Only the hover label keeps the old combat guard (lane-28 §B).
  283     if kind == "map" and InCombatLockdown and InCombatLockdown() then
  284         return
  285     end
```
addon/WoWFA/Panel.lua:1522
```
 1520     panel.svCopy:SetPoint("RIGHT", fb, "RIGHT", -4, 0)
 1521     panel.svSave = UI.Button(fb, L.fl_save, 170, 26, function()
 1522         if InCombatLockdown and InCombatLockdown() then
 1523             if health.svMsg then
 1524                 health.svMsg:SetFa(L.fl_combat, PW - 30)
```
addon/WoWFA/Text.lua:1321
```
 1319     F.After(0.15, function()
 1320         relayoutPending = false
 1321         if InCombatLockdown and InCombatLockdown() then
 1322             return
 1323         end
```
tests/lua/wow_mock.lua:373
```
  371 function GetSubZoneText() return MOCK.sub end
  372 function IsInInstance() return MOCK.inInst, MOCK.itype end
  373 function InCombatLockdown() return MOCK.combat or false end
  374 function GetTime() return MOCK.now or os.clock() end
  375 function time() return MOCK.now or os.time() end
```
- ok: InCombatLockdown: 16 hits

### PLAYER_REGEN

addon/WoWFA/CombatWatch.lua:117
```
  115 end
  116 
  117 F:On("PLAYER_REGEN_DISABLED", nil, function()
  118     local ok, res = pcall(take)
  119     snap = ok and res or nil
```
addon/WoWFA/CombatWatch.lua:121
```
  119     snap = ok and res or nil
  120 end)
  121 F:On("PLAYER_REGEN_ENABLED", nil, function()
  122     local ok, err = pcall(done)
  123     if not ok then
```
addon/WoWFA/Modules/GameUI.lua:596
```
  594     pcall(attach)
  595 end)
  596 F:On("PLAYER_REGEN_ENABLED", nil, function()
  597     local ok, err = pcall(after_combat)
  598     if not ok then
```
addon/WoWFA/Modules/Tracker.lua:365
```
  363 
  364 -- the modern tracker is taint-sensitive: never touch it in combat - queue and
  365 -- apply on PLAYER_REGEN_ENABLED. The classic QuestWatch is plain: direct.
  366 local pendingModern = false
  367 
```
addon/WoWFA/Modules/Tracker.lua:632
```
  630     F:On("QUEST_GREETING", "tracker", on_gossip)
  631     F:On("QUEST_WATCH_UPDATE", "tracker", update_watch)
  632     F:On("PLAYER_REGEN_ENABLED", "tracker", function()
  633         if pendingModern then
  634             pendingModern = false
```
addon/WoWFA/Modules/Walk.lua:578
```
  576 
  577 -- 1.1.1: the lines the game / Questie rewrote in combat get their Persian when it ends
  578 F:On("PLAYER_REGEN_ENABLED", nil, function()
  579     local list = {}
  580     for fs in pairs(pendC) do
```
tests/run.lua:868
```
  866     check("gameui: nothing changes in combat", G.Try(cb) == false and cb:GetText() == "Bank", cb:GetText())
  867     MOCK.combat = false
  868     FireEvent("PLAYER_REGEN_ENABLED")
  869     check("gameui: the text written in combat is swapped after it", non_ascii(cb:GetText()), cb:GetText())
  870     F.db.gameUi = false
```
tests/run.lua:943
```
  941     check("combat watch: the module loaded", type(W) == "table" and type(W.Snapshot) == "function")
  942     F.db.zzProbe = 1
  943     FireEvent("PLAYER_REGEN_DISABLED")
  944     F.db.zzProbe = 2
  945     FireEvent("PLAYER_REGEN_ENABLED")
```
tests/run.lua:945
```
  943     FireEvent("PLAYER_REGEN_DISABLED")
  944     F.db.zzProbe = 2
  945     FireEvent("PLAYER_REGEN_ENABLED")
  946     local hit
  947     for _, cd in ipairs(F.db.combatDiff or {}) do
```
tests/run.lua:954
```
  952     check("combat watch: a setting that changed in a fight is named", hit ~= nil and hit.v == "1 > 2", hit and hit.v)
  953     F.db.zzProbe, F.db.combatDiff = nil, nil
  954     FireEvent("PLAYER_REGEN_DISABLED")
  955     FireEvent("PLAYER_REGEN_ENABLED")
  956     check("combat watch: a quiet fight records nothing", F.db.combatDiff == nil or #F.db.combatDiff == 0, F.db.combatDiff and #F.db.combatDiff)
```
tests/run.lua:955
```
  953     F.db.zzProbe, F.db.combatDiff = nil, nil
  954     FireEvent("PLAYER_REGEN_DISABLED")
  955     FireEvent("PLAYER_REGEN_ENABLED")
  956     check("combat watch: a quiet fight records nothing", F.db.combatDiff == nil or #F.db.combatDiff == 0, F.db.combatDiff and #F.db.combatDiff)
  957     F.db.combatDiff = { { k = "db.zzProbe", v = "1 > 2", n = 1 } }
```
- ok: PLAYER_REGEN: 11 hits

### inCombat

- ok: inCombat: 0 hits

### UnitAffectingCombat

- ok: UnitAffectingCombat: 0 hits
