## task 0471-grep-combat (script)

**GREEN**


### InCombatLockdown

addon/WoWFA/Core.lua:159
```
  155         return
  156     end
  157     f.wfaEsc = true
  158     local function free()
  159         return not (InCombatLockdown and InCombatLockdown())
  160     end
  161     local function pass(self)
  162         if free() then
  163             pcall(self.SetPropagateKeyboardInput, self, true)
```
addon/WoWFA/Core.lua:835
```
  831 local function send_version(channel)
  832     if not can_comm() then
  833         return
  834     end
  835     if InCombatLockdown and InCombatLockdown() then
  836         return
  837     end
  838     local now = GetTime and GetTime() or 0
  839     if lastSend[channel] and now - lastSend[channel] < 120 then
```
addon/WoWFA/Dump.lua:169
```
  165     local S = scan
  166     if not S or not S.running then
  167         return
  168     end
  169     if InCombatLockdown and InCombatLockdown() then
  170         return -- pause in combat, resume after
  171     end
  172     local t0 = now_ms()
  173     local done = 0
```
addon/WoWFA/Modules/Blocked.lua:80
```
   76     if n > 1 then
   77         return
   78     end
   79     pcall(function()
   80         local combat = InCombatLockdown and InCombatLockdown() and "combat" or "no combat"
   81         -- 1.1.2: the event fires INSIDE the blocked call, so the stack names the game code that
   82         -- made it (the first 4 files:lines) - the next report says exactly where it came from
   83         local where = ""
   84         if debugstack then
```
addon/WoWFA/Modules/Dialog.lua:350
```
  346         end
  347     end
  348     -- the tooltip under the mouse shows again (English while Shift is down); never in
  349     -- combat (another frame's OnEnter is not ours to run then)
  350     if InCombatLockdown and InCombatLockdown() then
  351         return
  352     end
  353     local tt = GameTooltip
  354     if not (tt and tt.IsShown and tt:IsShown() and tt.GetOwner) then
```
addon/WoWFA/Modules/GameUI.lua:62
```
   58     return db and db.enabled and db.gameUi ~= false and true or false
   59 end
   60 
   61 local function combat()
   62     return InCombatLockdown and InCombatLockdown() and true or false
   63 end
   64 
   65 local function letters(s)
   66     local lit = string.gsub(s, "%%%d?%$?[sd]", "")
```
addon/WoWFA/Modules/Questie.lua:90
```
   86 local function scan(tt)
   87     if busy or not on() then
   88         return false
   89     end
   90     if InCombatLockdown and InCombatLockdown() then
   91         return false -- 1.1.1: no tooltip rewrite (and no second Show) in combat
   92     end
   93     local name = tt.GetName and tt:GetName()
   94     if type(name) ~= "string" then
```
addon/WoWFA/Modules/Tracker.lua:369
```
  365 -- apply on PLAYER_REGEN_ENABLED. The classic QuestWatch is plain: direct.
  366 local pendingModern = false
  367 
  368 local function in_combat_modern()
  369     if InCombatLockdown and InCombatLockdown() then
  370         pendingModern = true
  371         return true
  372     end
  373     return false
```
addon/WoWFA/Modules/Walk.lua:356
```
  352         return
  353     end
  354     -- 1.1.1: never write to the game's / Questie's lines in combat (their rows hold protected
  355     -- buttons); the line is remembered and done when the combat ends
  356     if InCombatLockdown and InCombatLockdown() then
  357         pendC[fs] = true
  358         return
  359     end
  360     if last[fs] == text then
```
addon/WoWFA/Modules/Walk.lua:474
```
  470     return out
  471 end
  472 
  473 function W.Scan()
  474     if InCombatLockdown and InCombatLockdown() then
  475         return -- rc36: never touch the tracker in combat; the ticker scans again after
  476     end
  477     for _, kind in ipairs({ "quest", "spell" }) do
  478         if kind_active(kind) then
```
addon/WoWFA/Modules/Walk.lua:663
```
  659                 return
  660             end
  661             acc = 0
  662         end
  663         if InCombatLockdown and InCombatLockdown() then
  664             return -- 1.1.1: nothing is touched in combat
  665         end
  666         if next(cand) ~= nil then
  667             local ok, err = pcall(W.Watch)
```
addon/WoWFA/Modules/Zones.lua:283
```
  279     end
  280     -- rc19 (the owner: some texts turn English when a fight starts): the quest list headers
  281     -- (maplabel) are plain font strings and the quest list redraws on every kill - they
  282     -- follow it in combat too. Only the hover label keeps the old combat guard (lane-28 §B).
  283     if kind == "map" and InCombatLockdown and InCombatLockdown() then
  284         return
  285     end
  286     local faText, lbl
  287     if enText ~= "" then
```
addon/WoWFA/Panel.lua:1437
```
 1433         end
 1434     end)
 1435     panel.svCopy:SetPoint("RIGHT", fb, "RIGHT", -4, 0)
 1436     panel.svSave = UI.Button(fb, L.fl_save, 170, 26, function()
 1437         if InCombatLockdown and InCombatLockdown() then
 1438             if health.svMsg then
 1439                 health.svMsg:SetFa(L.fl_combat, PW - 30)
 1440                 color(health.svMsg, C.orange)
 1441             end
```
addon/WoWFA/Text.lua:1321
```
 1317     end
 1318     relayoutPending = true
 1319     F.After(0.15, function()
 1320         relayoutPending = false
 1321         if InCombatLockdown and InCombatLockdown() then
 1322             return
 1323         end
 1324         -- 1.1.6: no client quest updater is called from addon code any more (taint: the
 1325         -- pet / action bars were blocked in combat); our own font strings take the new
```
tests/lua/wow_mock.lua:373
```
  369 end
  370 function GetRealZoneText() return MOCK.zone end
  371 function GetSubZoneText() return MOCK.sub end
  372 function IsInInstance() return MOCK.inInst, MOCK.itype end
  373 function InCombatLockdown() return MOCK.combat or false end
  374 function GetTime() return MOCK.now or os.clock() end
  375 function time() return MOCK.now or os.time() end
  376 function IsInGuild() return true end
  377 function IsInRaid() return false end
```
- ok: InCombatLockdown: 15 hits

### PLAYER_REGEN

addon/WoWFA/Modules/GameUI.lua:482
```
  478 
  479 F:On("ADDON_LOADED", nil, function()
  480     pcall(attach)
  481 end)
  482 F:On("PLAYER_REGEN_ENABLED", nil, function()
  483     local ok, err = pcall(after_combat)
  484     if not ok then
  485         F:LogError("gameui", err)
  486     end
```
addon/WoWFA/Modules/Tracker.lua:365
```
  361     return nil, bare ~= txt
  362 end
  363 
  364 -- the modern tracker is taint-sensitive: never touch it in combat - queue and
  365 -- apply on PLAYER_REGEN_ENABLED. The classic QuestWatch is plain: direct.
  366 local pendingModern = false
  367 
  368 local function in_combat_modern()
  369     if InCombatLockdown and InCombatLockdown() then
```
addon/WoWFA/Modules/Tracker.lua:632
```
  628     F:On("QUEST_LOG_UPDATE", "tracker", on_log_update)
  629     F:On("GOSSIP_SHOW", "tracker", on_gossip)
  630     F:On("QUEST_GREETING", "tracker", on_gossip)
  631     F:On("QUEST_WATCH_UPDATE", "tracker", update_watch)
  632     F:On("PLAYER_REGEN_ENABLED", "tracker", function()
  633         if pendingModern then
  634             pendingModern = false
  635             F:Wrap("tracker", update_modern)()
  636         end
```
addon/WoWFA/Modules/Walk.lua:578
```
  574 end
  575 W.Soon = soon
  576 
  577 -- 1.1.1: the lines the game / Questie rewrote in combat get their Persian when it ends
  578 F:On("PLAYER_REGEN_ENABLED", nil, function()
  579     local list = {}
  580     for fs in pairs(pendC) do
  581         list[#list + 1] = fs
  582     end
```
tests/run.lua:866
```
  862     local cb = host:CreateFontString(nil, "OVERLAY")
  863     cb:SetText("Bank")
  864     check("gameui: nothing changes in combat", G.Try(cb) == false and cb:GetText() == "Bank", cb:GetText())
  865     MOCK.combat = false
  866     FireEvent("PLAYER_REGEN_ENABLED")
  867     check("gameui: the text written in combat is swapped after it", non_ascii(cb:GetText()), cb:GetText())
  868     F.db.gameUi = false
  869     F:Fire("options", "gameUi")
  870     check("gameui: off puts the English back", fs:GetText() == "Skills" and pg:GetText() == "Page 3" and col:GetText() == "Strength:",
```
- ok: PLAYER_REGEN: 5 hits

### combat()

addon/WoWFA/Modules/GameUI.lua:61
```
   57     local db = F.db
   58     return db and db.enabled and db.gameUi ~= false and true or false
   59 end
   60 
   61 local function combat()
   62     return InCombatLockdown and InCombatLockdown() and true or false
   63 end
   64 
   65 local function letters(s)
```
addon/WoWFA/Modules/GameUI.lua:253
```
  249     local scope = hooked[self]
  250     if scope == true then
  251         scope = nil
  252     end
  253     if combat() then
  254         pendingFs[self] = scope or true
  255         return
  256     end
  257     swap(self, t, scope)
```
addon/WoWFA/Modules/GameUI.lua:284
```
  280 local function try(fs, scope)
  281     if not on() or type(fs) ~= "table" then
  282         return false
  283     end
  284     if combat() then
  285         pendingFs[fs] = scope or true
  286         return false
  287     end
  288     local ok, t = pcall(fs.GetText, fs)
```
addon/WoWFA/Modules/GameUI.lua:359
```
  355 local function scan(f)
  356     if not on() or type(f) ~= "table" then
  357         return
  358     end
  359     if combat() then
  360         pendingAll = true
  361         return
  362     end
  363     walk(f, 0, { n = 0 }, scope_of(f))
```
addon/WoWFA/Modules/GameUI.lua:414
```
  410 end
  411 
  412 -- off: every English text and font back
  413 local function restore()
  414     if combat() then
  415         pendingAll = true
  416         return
  417     end
  418     busy = true
```
addon/WoWFA/Modules/GameUI.lua:443
```
  439         restore()
  440     end
  441 end
  442 
  443 local function after_combat()
  444     if not on() then
  445         pendingAll = false
  446         for fs in pairs(pendingFs) do
  447             pendingFs[fs] = nil
```
- ok: combat(): 6 hits

### in_combat

addon/WoWFA/Modules/Tracker.lua:368
```
  364 -- the modern tracker is taint-sensitive: never touch it in combat - queue and
  365 -- apply on PLAYER_REGEN_ENABLED. The classic QuestWatch is plain: direct.
  366 local pendingModern = false
  367 
  368 local function in_combat_modern()
  369     if InCombatLockdown and InCombatLockdown() then
  370         pendingModern = true
  371         return true
  372     end
```
addon/WoWFA/Modules/Tracker.lua:494
```
  490 end
  491 
  492 -- modern: ObjectiveTrackerFrame blocks (block.id = questID, .HeaderText, .lines)
  493 local function update_modern()
  494     if in_combat_modern() then
  495         return
  496     end
  497     if throttled("otf") then
  498         return
```
- ok: in_combat: 2 hits

### UNIT_FLAGS

- ok: UNIT_FLAGS: 0 hits
