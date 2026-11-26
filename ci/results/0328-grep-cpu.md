## task 0328-grep-cpu (script)

**GREEN**


### fixer:SetScript

addon/WoWFA/Modules/Walk.lua:653
```
  627 end)
  628 F:Listen("options", function(key)
  629     if key == "listTitles" or key == "fontOutline" then
  630         refresh_all()
  631     elseif key == 'fontSize' or key == 'szList' then
  632         F.RelayoutQuests()
  633         for fs, o in pairs(mine) do
  634             writing[fs] = true
  635             local okt, txt = pcall(fs.GetText, fs)
  636             if okt and F.Usable(txt) and has_fa(txt) then
  637                 local sz = F.SizeOf(o.role)
  638                 pcall(fs.SetFont, fs, F.FONT, sz, F.Flags(OLFAM[o.role]))
  639                 F.FitLine(fs, sz)
  640             else
  641                 F.RestoreFont(fs, o) -- rc32: English keeps the game font
  642             end
  643             writing[fs] = nil
  644         end
  645     end
  646 end)
  647 
  648 -- rc15 (the owner: empty boxes instead of Persian): the game resets the font of its
  649 -- buttons without a Lua call we can hook, so the font of every line we wrote is
  650 -- checked ten times a second (the table holds only those lines)
  651 do
  652     local fixer = CreateFrame("Frame")
  653     fixer:SetScript("OnUpdate", function()
  654         if InCombatLockdown and InCombatLockdown() then
  655             return -- 1.1.1: nothing is touched in combat
  656         end
  657         if next(cand) ~= nil then
  658             local ok, err = pcall(W.Watch)
  659             if not ok then
  660                 F:LogError("tracker", err)
  661             end
  662         end
  663         for fs, o in pairs(mine) do
  664             local ok, cur = pcall(fs.GetFont, fs)
  665             if ok and cur ~= F.FONT then
  666                 local okt, txt = pcall(fs.GetText, fs)
  667                 writing[fs] = true
  668                 if okt and F.Usable(txt) and has_fa(txt) then
  669                     local sz = F.SizeOf(o.role)
  670                     pcall(fs.SetFont, fs, F.FONT, sz, F.Flags(OLFAM[o.role]))
  671                     F.FitLine(fs, sz)
  672                 else
  673                     mine[fs], last[fs] = nil, nil -- rc32: English text again: the game font stays
  674                 end
  675                 writing[fs] = nil
  676             end
  677         end
  678     end)
  679 end
```
addon/WoWFA/Modules/Zones.lua:580
```
  554     if zone ~= lastZone then
  555         lastZone, lastSub = zone, sub
  556         local zfa = fa(zone)
  557         -- lane-b16: with the zn family off the miss is the user's own switch,
  558         -- not a data gap - never feed it to the health watch. Brain review:
  559         -- 51-B had this inverted (it fed the watch ONLY while the switch was
  560         -- off, i.e. only false misses, and never a real hit)
  561         if F.Room.On("namesZone") then
  562             F:Track("dungeons", zfa ~= nil)
  563         end
  564         if F.Room.On("namesZone") and (mode == 1 or (mode == 2 and dungeon)) then
  565             toast(zfa, sub ~= "" and sub ~= zone and fa(sub) or nil, zfa and kind or nil)
  566         end
  567     elseif sub ~= lastSub then
  568         lastSub = sub
  569         if F.Room.On("namesZone") and mode == 1 and sub ~= "" then
  570             toast(fa(sub), nil, nil, true)
  571         end
  572     end
  573 end
  574 
  575 function M.install()
  576     -- rc15 (the owner: the zone headers of the quest list still showed empty boxes): the
  577     -- game resets the font of its buttons without a Lua call we can hook, so the font is
  578     -- checked ten times a second (the table holds only the strings we wrote)
  579     local fixer = CreateFrame("Frame")
  580     fixer:SetScript("OnUpdate", function()
  581         -- rc18: every frame (the tables hold only the strings we wrote)
  582         if M.active and next(zwatch) ~= nil then
  583             local ok, err = pcall(M.watch)
  584             if not ok then
  585                 F:LogError("dungeons", err)
  586             end
  587         end
  588         if M.active and next(original) ~= nil then
  589             M.fix_fonts()
  590         end
  591     end)
  592     -- rc18: a quest log change rebuilds the header rows - scan right after it
  593     local pend = false
  594     F:On("QUEST_LOG_UPDATE", "dungeons", function()
  595         local wm = WorldMapFrame
  596         if pend or type(wm) ~= "table" or not (wm.IsShown and wm:IsShown()) then
  597             return
  598         end
  599         pend = true
  600         F.After(0.05, function()
  601             pend = false
  602             pcall(M.scan_map)
  603         end)
  604     end)
  605     F:On("ZONE_CHANGED_NEW_AREA", "dungeons", update)
  606     F:On("ZONE_CHANGED", "dungeons", update)
```
- ok: fixer:SetScript: 2 hits

### function F:Wrap

addon/WoWFA/Core.lua:484
```
  458             e.t = time and time() or 0
  459             F:Fire("errors")
  460             return
  461         end
  462     end
  463     table.insert(db.errors, 1, { m = modId, e = msg, n = 1, t = time and time() or 0, b = F.clientBuild or 0, v = F.VERSION })
  464     while #db.errors > 30 do
  465         table.remove(db.errors)
  466     end
  467     F:Fire("errors")
  468 end
  469 
  470 -- ------------------------------------------------------------- modules
  471 F.mods, F.order = {}, {}
  472 local ACTIVE = { ok = true, warn = true, locked = false }
  473 
  474 function F:RegisterModule(m)
  475     m.faults, m.hit, m.miss, m.stale, m.seen = 0, 0, 0, 0, 0
  476     m.state = "off"
  477     F.mods[m.id] = m
  478     table.insert(F.order, m)
  479     table.sort(F.order, function(a, b)
  480         return (a.order or 99) < (b.order or 99)
  481     end)
  482 end
  483 
  484 function F:Wrap(modId, fn)
  485     return function(...)
  486         local m = F.mods[modId]
  487         if m and not m.active then
  488             return
  489         end
  490         local ok, err = pcall(fn, ...)
  491         if not ok then
  492             F:Fault(modId, err)
  493         end
  494     end
  495 end
  496 
  497 function F:Fault(modId, err)
  498     F:LogError(modId, err)
  499     local m = F.mods[modId]
  500     if not m then
  501         return
  502     end
  503     m.faults = (m.faults or 0) + 1
  504     local now = GetTime and GetTime() or 0
  505     m.recent = m.recent or {}
  506     table.insert(m.recent, now)
  507     while #m.recent > 0 and now - m.recent[1] > 60 do
  508         table.remove(m.recent, 1)
  509     end
  510     if not m.tripped and (#m.recent >= 3 or m.faults >= 10) then
```
- ok: function F:Wrap: 1 hits

### W.ticker = C_Timer

addon/WoWFA/Modules/Walk.lua:612
```
  586         if ok and F.Usable(txt) and type(txt) == "string" then
  587             pcall(process, fs, txt)
  588         end
  589     end
  590     soon()
  591 end)
  592 
  593 F:On("QUEST_LOG_UPDATE", nil, function()
  594     W.RebuildLog()
  595     memo = {}
  596     soon()
  597 end)
  598 
  599 function W.Start()
  600     W.RebuildLog()
  601     local wm = WorldMapFrame
  602     if type(wm) == "table" and wm.HookScript and not W.mapHooked then
  603         W.mapHooked = true
  604         pcall(wm.HookScript, wm, "OnShow", function()
  605             soon()
  606             F.After(0.3, soon)
  607         end)
  608     end
  609     if W.ticker or not (C_Timer and C_Timer.NewTicker) then
  610         return
  611     end
  612     W.ticker = C_Timer.NewTicker(1, function()
  613         local ok, err = pcall(W.Scan)
  614         if not ok then
  615             F:LogError("tracker", err)
  616         end
  617     end)
  618 end
  619 
  620 F:On("PLAYER_LOGIN", nil, function()
  621     F.After(2, W.Start)
  622 end)
  623 F:Listen("names", refresh_all)
  624 F:Listen("disp", refresh_all)
  625 F:Listen("state", function()
  626     memo = {}
  627 end)
  628 F:Listen("options", function(key)
  629     if key == "listTitles" or key == "fontOutline" then
  630         refresh_all()
  631     elseif key == 'fontSize' or key == 'szList' then
  632         F.RelayoutQuests()
  633         for fs, o in pairs(mine) do
  634             writing[fs] = true
  635             local okt, txt = pcall(fs.GetText, fs)
  636             if okt and F.Usable(txt) and has_fa(txt) then
  637                 local sz = F.SizeOf(o.role)
  638                 pcall(fs.SetFont, fs, F.FONT, sz, F.Flags(OLFAM[o.role]))
```
- ok: W.ticker = C_Timer: 1 hits

### M.ticker = C_Timer

addon/WoWFA/Modules/Zones.lua:370
```
  344         wm:HookScript("OnShow", function()
  345             pcall(hook_map)
  346         end)
  347     end
  348     local dps = wm.dataProviders
  349     if type(dps) == "table" then
  350         for dp in pairs(dps) do
  351             local lb = type(dp) == "table" and dp.Label
  352             if type(lb) == "table" then
  353                 hook_inplace(lb.Name, "map")
  354             end
  355         end
  356     end
  357     -- rc11: every other font string under the map (title, navigation bar, the
  358     -- zone headers of the quest log, the pin labels), now and when the map changes
  359     if M.scan_map then
  360         M.scan_map()
  361         F.After(0.4, M.scan_map)
  362         if wm.OnMapChanged and not wm.wfaMapChanged and type(hooksecurefunc) == "function" then
  363             wm.wfaMapChanged = true
  364             pcall(hooksecurefunc, wm, "OnMapChanged", function()
  365                 F.After(0.25, M.scan_map)
  366             end)
  367         end
  368         if C_Timer and C_Timer.NewTicker and not M.ticker then
  369             local n = 0
  370             M.ticker = C_Timer.NewTicker(0.5, function()
  371                 if wm.IsShown and wm:IsShown() then
  372                     n = n + 1
  373                     M.fix_fonts()
  374                     if n % 2 == 0 then
  375                         M.scan_map()
  376                     end
  377                 end
  378             end)
  379         end
  380     end
  381 end
  382 
  383 -- rc11 (the owner: "the zone names on the map: only the two continents work"):
  384 -- every font string under the world map (the title, the navigation bar, the zone
  385 -- headers of the quest log, the pin labels) gets the same in-place SetText hook;
  386 -- the walk repeats whenever the map changes because the map builds its pins
  387 -- lazily. A font string whose text is no zone name is left alone (and never
  388 -- logged as a miss).
  389 local function walk_map(frame, depth, budget)
  390     if budget.n <= 0 or depth > 10 then
  391         return
  392     end
  393     budget.n = budget.n - 1
  394     local okr, regions = pcall(function()
  395         return { frame:GetRegions() }
  396     end)
```
- ok: M.ticker = C_Timer: 1 hits

### function W.Scan

addon/WoWFA/Modules/Walk.lua:473
```
  447             if type(f) == "table" and f.GetChildren and not seen[f] then
  448                 seen[f] = true
  449                 out[#out + 1] = f
  450             end
  451         end
  452     end
  453     if kind == "spell" and UIParent and UIParent.GetChildren then
  454         local okc, kids = pcall(function()
  455             return { UIParent:GetChildren() }
  456         end)
  457         if okc then
  458             for _, k in ipairs(kids) do
  459                 local okn, nm = pcall(function()
  460                     return k.GetName and k:GetName()
  461                 end)
  462                 if okn and type(nm) == "string" and not seen[k]
  463                     and (string.find(nm, "SpellBook", 1, true) or string.find(nm, "PlayerSpells", 1, true)) then
  464                     seen[k] = true
  465                     out[#out + 1] = k
  466                 end
  467             end
  468         end
  469     end
  470     return out
  471 end
  472 
  473 function W.Scan()
  474     if InCombatLockdown and InCombatLockdown() then
  475         return -- rc36: never touch the tracker in combat; the ticker scans again after
  476     end
  477     for _, kind in ipairs({ "quest", "spell" }) do
  478         if kind_active(kind) then
  479             for _, root in ipairs(roots_for(kind)) do
  480                 local ok, shown = pcall(root.IsShown, root)
  481                 if ok and shown then
  482                     pcall(walk, root, kind, 0, { n = 2500 })
  483                 end
  484             end
  485         end
  486     end
  487 end
  488 
  489 -- a switch changed: every line we wrote goes back to the English the client sent,
  490 -- then the scan writes again what is still allowed
  491 local function refresh_all()
  492     memo = {}
  493     local list = {}
  494     for fs in pairs(mine) do
  495         list[#list + 1] = fs
  496     end
  497     for _, fs in ipairs(list) do
  498         local o = mine[fs]
  499         writing[fs] = true
```
- ok: function W.Scan: 1 hits
