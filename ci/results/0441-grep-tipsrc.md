## task 0441-grep-tipsrc (script)

**GREEN**


### hooksecurefunc

addon/WoWFA/Modules/Alerts.lua:107
```
  106     -- (the action bars) in combat. The game's AddMessage now runs untouched; this is a post-hook
  107     -- (hooksecurefunc, the safe way): it swaps the line the game just drew for the Persian one.
  108     if busy or not active() then
```
addon/WoWFA/Modules/Alerts.lua:160
```
  159     origAdd = ef.AddMessage -- the game's own function, called directly (never through the hook)
  160     hooksecurefunc(ef, "AddMessage", add)
  161 end
```
addon/WoWFA/Modules/Chat.lua:201
```
  200             f.wfaAddHooked = true
  201             hooksecurefunc(f, "AddMessage", function(self, text)
  202                 if need[self] or not on() or type(text) ~= "string" then
```
addon/WoWFA/Modules/Chat.lua:276
```
  275     if type(FCF_SetChatWindowFontSize) == "function" then
  276         hooksecurefunc("FCF_SetChatWindowFontSize", function()
  277             pcall(apply_font)
```
addon/WoWFA/Modules/GameUI.lua:11
```
   10 --     Persian in our font. That region's SetText / SetFormattedText are post-hooked
   11 --     (hooksecurefunc, the safe way), so the game's next write is swapped too;
   12 --   * protected frames (action buttons, secure buttons) and everything under them are never
```
addon/WoWFA/Modules/GameUI.lua:271
```
  270 local function hook(fs, scope)
  271     if hooked[fs] or type(hooksecurefunc) ~= "function" then
  272         return
```
addon/WoWFA/Modules/GameUI.lua:275
```
  274     hooked[fs] = scope or true
  275     pcall(hooksecurefunc, fs, "SetText", on_set)
  276     pcall(hooksecurefunc, fs, "SetFormattedText", on_fmt)
```
addon/WoWFA/Modules/GameUI.lua:276
```
  275     pcall(hooksecurefunc, fs, "SetText", on_set)
  276     pcall(hooksecurefunc, fs, "SetFormattedText", on_fmt)
  277 end
```
addon/WoWFA/Modules/Npc.lua:243
```
  242     if type(CompactUnitFrame_UpdateName) == "function" then
  243         hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
  244             local ok, err = pcall(plate, frame)
```
addon/WoWFA/Modules/Npc.lua:254
```
  253     if type(TargetFrame_Update) == "function" then
  254         hooksecurefunc("TargetFrame_Update", F:Wrap("npc", target))
  255     end
```
addon/WoWFA/Modules/Npc.lua:257
```
  256     if type(TargetFrame) == "table" and type(TargetFrame.Update) == "function" then
  257         hooksecurefunc(TargetFrame, "Update", F:Wrap("npc", target))
  258     end
```
addon/WoWFA/Modules/Questie.lua:170
```
  169     tt.wfaQuestie = true
  170     hooksecurefunc(tt, "Show", function(self)
  171         local ok, changed = pcall(scan, self)
```
addon/WoWFA/Modules/Quests.lua:605
```
  604         if type(_G[fn]) == "function" then
  605             hooksecurefunc(fn, wrapped)
  606         end
```
addon/WoWFA/Modules/Quests.lua:619
```
  618         if type(_G[fn]) == "function" then
  619             pcall(hooksecurefunc, fn, after_select)
  620         end
```
addon/WoWFA/Modules/Quests.lua:623
```
  622     if type(C_QuestLog) == "table" and type(C_QuestLog.SetSelectedQuest) == "function" then
  623         pcall(hooksecurefunc, C_QuestLog, "SetSelectedQuest", after_select)
  624     end
```
addon/WoWFA/Modules/Spells.lua:363
```
  362         if GameTooltip[method] then
  363             hooksecurefunc(GameTooltip, method, function(tt)
  364                 fn(tt)
```
addon/WoWFA/Modules/Spells.lua:395
```
  394     if GameTooltip and GameTooltip.SetTalent then
  395         hooksecurefunc(GameTooltip, "SetTalent", F:Wrap("talents", function(tt)
  396             spell_tip("talents", tt)
```
addon/WoWFA/Modules/Tracker.lua:596
```
  595         if type(_G[fn]) == "function" then
  596             hooksecurefunc(fn, F:Wrap("tracker", update_watch))
  597         end
```
addon/WoWFA/Modules/Tracker.lua:601
```
  600     if type(_G["ObjectiveTracker_Update"]) == "function" then
  601         hooksecurefunc("ObjectiveTracker_Update", F:Wrap("tracker", update_modern))
  602     end
```
addon/WoWFA/Modules/Tracker.lua:607
```
  606             if mod and type(mod.Update) == "function" then
  607                 hooksecurefunc(mod, "Update", F:Wrap("tracker", update_modern))
  608             end
```
addon/WoWFA/Modules/Walk.lua:386
```
  385     hooked[fs] = kind
  386     if type(hooksecurefunc) == "function" then
  387         pcall(hooksecurefunc, fs, "SetText", function(self, text)
```
addon/WoWFA/Modules/Walk.lua:387
```
  386     if type(hooksecurefunc) == "function" then
  387         pcall(hooksecurefunc, fs, "SetText", function(self, text)
  388             local ok, err = pcall(process, self, text)
```
addon/WoWFA/Modules/Zones.lua:80
```
   79 -- The minimap zone text, the big arrival strings and the world-map label are
   80 -- Blizzard font strings; we intercept SetText AFTER the client (hooksecurefunc)
   81 -- with a re-entry flag, render Persian with our font at the ORIGINAL size (the
```
addon/WoWFA/Modules/Zones.lua:147
```
  146     fs.wfaFontGuard = true
  147     if type(hooksecurefunc) == "function" then
  148         pcall(hooksecurefunc, fs, "SetFontObject", function(self)
```
addon/WoWFA/Modules/Zones.lua:148
```
  147     if type(hooksecurefunc) == "function" then
  148         pcall(hooksecurefunc, fs, "SetFontObject", function(self)
  149             refont(self)
```
addon/WoWFA/Modules/Zones.lua:302
```
  301     fs.wfaHooked = true
  302     hooksecurefunc(fs, "SetText", function(self, text)
  303         local ok, err = pcall(on_inplace, self, text, kind)
```
addon/WoWFA/Modules/Zones.lua:362
```
  361         F.After(0.4, M.scan_map)
  362         if wm.OnMapChanged and not wm.wfaMapChanged and type(hooksecurefunc) == "function" then
  363             wm.wfaMapChanged = true
```
addon/WoWFA/Modules/Zones.lua:364
```
  363             wm.wfaMapChanged = true
  364             pcall(hooksecurefunc, wm, "OnMapChanged", function()
  365                 F.After(0.25, M.scan_map)
```
tests/lua/wow_mock.lua:286
```
  285 tinsert = table.insert
  286 function hooksecurefunc(a, b, c)
  287     local tbl, name, fn = a, b, c
```
- ok: hooksecurefunc: 29 hits

### HookScript

addon/WoWFA/Core.lua:168
```
  167     pass(f)
  168     pcall(f.HookScript, f, "OnShow", pass)
  169     pcall(f.HookScript, f, "OnKeyDown", function(self, key)
```
addon/WoWFA/Core.lua:169
```
  168     pcall(f.HookScript, f, "OnShow", pass)
  169     pcall(f.HookScript, f, "OnKeyDown", function(self, key)
  170         if key == "ESCAPE" then
```
addon/WoWFA/Modules/Chat.lua:175
```
  174 local function hook_box(eb)
  175     if eb.wfaOv or not eb.HookScript then
  176         return
```
addon/WoWFA/Modules/Chat.lua:184
```
  183     eb.wfaOv = ov
  184     eb:HookScript("OnTextChanged", function(self)
  185         pcall(refresh_box, self)
```
addon/WoWFA/Modules/Chat.lua:187
```
  186     end)
  187     eb:HookScript("OnShow", function(self)
  188         pcall(refresh_box, self)
```
addon/WoWFA/Modules/Chat.lua:190
```
  189     end)
  190     eb:HookScript("OnHide", function(self)
  191         pcall(show_plain, self)
```
addon/WoWFA/Modules/Dialog.lua:397
```
  396         local fr, kind = pair[1], pair[2]
  397         if fr and fr.HookScript then
  398             pcall(fr.HookScript, fr, "OnHide", function()
```
addon/WoWFA/Modules/Dialog.lua:398
```
  397         if fr and fr.HookScript then
  398             pcall(fr.HookScript, fr, "OnHide", function()
  399                 if pane and pane.anchor == fr then
```
addon/WoWFA/Modules/GameUI.lua:8
```
    7 --     text itself, or a GlobalStrings NAME whose English is only READ at run time;
    8 --   * a listed window's OnShow is post-hooked (HookScript); one frame later its text regions
    9 --     are read, and a region whose text IS one of those English strings gets the shaped
```
addon/WoWFA/Modules/GameUI.lua:389
```
  388         local f = _G[name]
  389         if not attached[name] and type(f) == "table" and type(f.HookScript) == "function" then
  390             attached[name] = true
```
addon/WoWFA/Modules/GameUI.lua:391
```
  390             attached[name] = true
  391             pcall(f.HookScript, f, "OnShow", function(self)
  392                 if on() then
```
addon/WoWFA/Modules/Npc.lua:239
```
  238         TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, F:Wrap("npc", tip))
  239     elseif GameTooltip.HookScript then
  240         GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
```
addon/WoWFA/Modules/Npc.lua:240
```
  239     elseif GameTooltip.HookScript then
  240         GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
  241     end
```
addon/WoWFA/Modules/Preview.lua:820
```
  819     end
  820     if row.HookScript then
  821         pcall(row.HookScript, row, "OnClick", show)
```
addon/WoWFA/Modules/Preview.lua:821
```
  820     if row.HookScript then
  821         pcall(row.HookScript, row, "OnClick", show)
  822     end
```
addon/WoWFA/Modules/Preview.lua:823
```
  822     end
  823     if row.pick and row.pick.HookScript then
  824         pcall(row.pick.HookScript, row.pick, "OnClick", show)
```
addon/WoWFA/Modules/Preview.lua:824
```
  823     if row.pick and row.pick.HookScript then
  824         pcall(row.pick.HookScript, row.pick, "OnClick", show)
  825     end
```
addon/WoWFA/Modules/Quests.lua:629
```
  628     for _, f in ipairs(hosts()) do
  629         if f.HookScript then
  630             -- Brain review (#139): NO OnShow hook on QuestFrame - on_log there
```
addon/WoWFA/Modules/Quests.lua:636
```
  635             if f ~= QuestFrame then
  636                 f:HookScript("OnShow", wrapped)
  637             end
```
addon/WoWFA/Modules/Quests.lua:638
```
  637             end
  638             f:HookScript("OnHide", F:Wrap("quests", function()
  639                 F.After(0.05, function()
```
addon/WoWFA/Modules/Quests.lua:650
```
  649             end))
  650             f:HookScript("OnDragStop", F:Wrap("quests", function()
  651                 if pane and pane:IsShown() and F.db.questDock ~= 3 then
```
addon/WoWFA/Modules/Spells.lua:510
```
  509 
  510 if GameTooltip and GameTooltip.HookScript then
  511     GameTooltip:HookScript("OnShow", function(tt)
```
addon/WoWFA/Modules/Spells.lua:511
```
  510 if GameTooltip and GameTooltip.HookScript then
  511     GameTooltip:HookScript("OnShow", function(tt)
  512         local ok, err = pcall(plain_tip, tt)
```
addon/WoWFA/Modules/Taxi.lua:82
```
   81 
   82 if GameTooltip and GameTooltip.HookScript then
   83     GameTooltip:HookScript("OnShow", function(tt)
```
addon/WoWFA/Modules/Taxi.lua:83
```
   82 if GameTooltip and GameTooltip.HookScript then
   83     GameTooltip:HookScript("OnShow", function(tt)
   84         local ok, err = pcall(on_show, tt)
```
addon/WoWFA/Modules/Walk.lua:602
```
  601     local wm = WorldMapFrame
  602     if type(wm) == "table" and wm.HookScript and not W.mapHooked then
  603         W.mapHooked = true
```
addon/WoWFA/Modules/Walk.lua:604
```
  603         W.mapHooked = true
  604         pcall(wm.HookScript, wm, "OnShow", function()
  605             soon()
```
addon/WoWFA/Modules/Zones.lua:342
```
  341     end
  342     if not wm.wfaMapHooked and wm.HookScript then
  343         wm.wfaMapHooked = true
```
addon/WoWFA/Modules/Zones.lua:344
```
  343         wm.wfaMapHooked = true
  344         wm:HookScript("OnShow", function()
  345             pcall(hook_map)
```
addon/WoWFA/Modules/Zones.lua:622
```
  621     end)
  622     if MinimapZoneTextButton and MinimapZoneTextButton.HookScript then
  623         MinimapZoneTextButton:HookScript("OnEnter", F:Wrap("dungeons", function()
```
addon/WoWFA/Modules/Zones.lua:623
```
  622     if MinimapZoneTextButton and MinimapZoneTextButton.HookScript then
  623         MinimapZoneTextButton:HookScript("OnEnter", F:Wrap("dungeons", function()
  624             if not F.Room.On("namesZone") then
```
addon/WoWFA/Panel.lua:1332
```
 1331     panel.reset:SetPoint("RIGHT", resetRow, "RIGHT", -4, 0)
 1332     panel:HookScript("OnHide", function()
 1333         if armed then
```
addon/WoWFA/Text.lua:825
```
  824 local function hook_tooltip(tt)
  825     if tt.wfaHooked or not tt.HookScript then
  826         return
```
addon/WoWFA/Text.lua:829
```
  828     tt.wfaHooked = true
  829     pcall(tt.HookScript, tt, "OnTooltipCleared", restore)
  830     pcall(tt.HookScript, tt, "OnHide", restore)
```
addon/WoWFA/Text.lua:830
```
  829     pcall(tt.HookScript, tt, "OnTooltipCleared", restore)
  830     pcall(tt.HookScript, tt, "OnHide", restore)
  831     pcall(tt.HookScript, tt, "OnSizeChanged", function(self)
```
addon/WoWFA/Text.lua:831
```
  830     pcall(tt.HookScript, tt, "OnHide", restore)
  831     pcall(tt.HookScript, tt, "OnSizeChanged", function(self)
  832         if self.wfaX and (self.wfaX.n or 0) > 0 and T.TipExtraLayout then
```
addon/WoWFA/UI.lua:372
```
  371     thumb:SetScript("OnHide", stop)
  372     sf:HookScript("OnHide", function()
  373         thumb:Hide()
```
tests/lua/wow_mock.lua:69
```
   68 function Obj.GetScript(s, ev) return s._scripts[ev] end
   69 function Obj.HookScript(s, ev, fn) local old = s._scripts[ev]; s._scripts[ev] = function(...) if old then old(...) end; fn(...) end end
   70 function Obj.HasScript() return true end
```
- ok: HookScript: 38 hits

### TooltipDataProcessor

addon/WoWFA/Core.lua:1013
```
 1012             "QuestLogFrame", "QuestMapFrame", "GossipFrame", "ZoneTextString", "SubZoneTextString",
 1013             "MinimapZoneText", "WorldMapFrame", "ItemRefShoppingTooltip1", "TooltipDataProcessor" }
 1014         local out = {}
```
addon/WoWFA/Modules/Npc.lua:236
```
  235 function M.install()
  236     if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType
  237         and Enum.TooltipDataType.Unit then
```
addon/WoWFA/Modules/Npc.lua:238
```
  237         and Enum.TooltipDataType.Unit then
  238         TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, F:Wrap("npc", tip))
  239     elseif GameTooltip.HookScript then
```
addon/WoWFA/Modules/Spells.lua:13
```
   12 local function tdp(kind)
   13     return TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType
   14         and Enum.TooltipDataType[kind] ~= nil
```
addon/WoWFA/Modules/Spells.lua:358
```
  357     if tdp("Spell") then
  358         TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, fn)
  359         return
```
addon/WoWFA/Modules/Spells.lua:408
```
  407     end
  408     TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, F:Wrap("talents", function(tt, data)
  409         if F:Active("spellbook") then
```
tests/lua/wow_mock.lua:292
```
  291 end
  292 TooltipDataProcessor = { cbs = {} }
  293 function TooltipDataProcessor.AddTooltipPostCall(t, fn) TooltipDataProcessor.cbs[t] = TooltipDataProcessor.cbs[t] or {}; table.insert(TooltipDataProcessor.cbs[t
```
tests/lua/wow_mock.lua:293
```
  292 TooltipDataProcessor = { cbs = {} }
  293 function TooltipDataProcessor.AddTooltipPostCall(t, fn) TooltipDataProcessor.cbs[t] = TooltipDataProcessor.cbs[t] or {}; table.insert(TooltipDataProcessor.cbs[t
  294 Enum = { TooltipDataType = { Item = 0, Spell = 1, Unit = 2, Object = 33 } }
```
tests/lua/wow_mock.lua:295
```
  294 Enum = { TooltipDataType = { Item = 0, Spell = 1, Unit = 2, Object = 33 } }
  295 function RunTip(kind, tt, data) for _, fn in ipairs(TooltipDataProcessor.cbs[Enum.TooltipDataType[kind]] or {}) do fn(tt, data) end end
  296 C_Timer = { After = function(s, fn) table.insert(timers, fn) end }
```
- ok: TooltipDataProcessor: 9 hits

### SetScript

addon/WoWFA/Core.lua:81
```
   80     local t = 0
   81     f:SetScript("OnUpdate", function(self, el)
   82         t = t + el
```
addon/WoWFA/Core.lua:84
```
   83         if t >= sec then
   84             self:SetScript("OnUpdate", nil)
   85             fn()
```
addon/WoWFA/Core.lua:491
```
  490 
  491 ev:SetScript("OnEvent", function(_, event, ...)
  492     local list = listeners[event]
```
addon/WoWFA/Dump.lua:154
```
  153     if frame then
  154         frame:SetScript("OnUpdate", nil)
  155     end
```
addon/WoWFA/Dump.lua:238
```
  237     end
  238     frame:SetScript("OnUpdate", function()
  239         local ok, err = pcall(D.Step)
```
addon/WoWFA/Minimap.lua:86
```
   85     btn.alert:SetVertexColor(C.orange[1], C.orange[2], C.orange[3])
   86     btn:SetScript("OnClick", function(_, button)
   87         if button == "RightButton" then
```
addon/WoWFA/Minimap.lua:99
```
   98     end)
   99     btn:SetScript("OnDragStart", function(self)
  100         self:SetScript("OnUpdate", function()
```
addon/WoWFA/Minimap.lua:100
```
   99     btn:SetScript("OnDragStart", function(self)
  100         self:SetScript("OnUpdate", function()
  101             local mx, my = Minimap:GetCenter()
```
addon/WoWFA/Minimap.lua:112
```
  111     end)
  112     btn:SetScript("OnDragStop", function(self)
  113         self:SetScript("OnUpdate", nil)
```
addon/WoWFA/Minimap.lua:113
```
  112     btn:SetScript("OnDragStop", function(self)
  113         self:SetScript("OnUpdate", nil)
  114     end)
```
addon/WoWFA/Minimap.lua:115
```
  114     end)
  115     btn:SetScript("OnEnter", function(self)
  116         F.MinimapTooltip(self)
```
addon/WoWFA/Minimap.lua:118
```
  117     end)
  118     btn:SetScript("OnLeave", function()
  119         GameTooltip:Hide()
```
addon/WoWFA/Modules/Blocked.lua:68
```
   67 pcall(ev.RegisterEvent, ev, "ADDON_ACTION_FORBIDDEN")
   68 ev:SetScript("OnEvent", function(_, event, addon, fn)
   69     if addon ~= F.ADDON then
```
addon/WoWFA/Modules/Harvest.lua:261
```
  260     end
  261     ev:SetScript("OnEvent", function(_, e, a1)
  262         local ok, err = pcall(function()
```
addon/WoWFA/Modules/Preview.lua:651
```
  650             f.blinking = true
  651             f:SetScript("OnUpdate", function(self, el)
  652                 if not self.outs then
```
addon/WoWFA/Modules/Preview.lua:712
```
  711         local tt = 0
  712         halo:SetScript("OnUpdate", function(self, el)
  713             tt = tt + (el or 0)
```
addon/WoWFA/Modules/Preview.lua:788
```
  787     b:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
  788     b:SetScript("OnClick", show)
  789     b:Hide()
```
addon/WoWFA/Modules/Quests.lua:104
```
  103     pane:RegisterForDrag("LeftButton")
  104     pane:SetScript("OnDragStart", function(self)
  105         if F.db.questDock == 3 then
```
addon/WoWFA/Modules/Quests.lua:109
```
  108     end)
  109     pane:SetScript("OnDragStop", function(self)
  110         self:StopMovingOrSizing()
```
addon/WoWFA/Modules/Quests.lua:137
```
  136     close.label:SetText("\195\151") -- the multiplication sign: a clear X glyph
  137     close:SetScript("OnClick", function()
  138         closedId = shownId -- suppressed until "فا" OR the frame is closed+reopened
```
addon/WoWFA/Modules/Quests.lua:171
```
  170     faBtn.label:SetFa("فا", 26)
  171     faBtn:SetScript("OnEnter", function(self)
  172         if not GameTooltip then
```
addon/WoWFA/Modules/Quests.lua:179
```
  178     end)
  179     faBtn:SetScript("OnLeave", function()
  180         if GameTooltip then
```
addon/WoWFA/Modules/Quests.lua:184
```
  183     end)
  184     faBtn:SetScript("OnClick", function()
  185         F.QuestToggle()
```
addon/WoWFA/Modules/Walk.lua:654
```
  653     local acc = 0
  654     fixer:SetScript("OnUpdate", function(_, el)
  655         -- 1.1.5: twenty times a second, not every frame (the CPU the owner saw, 26 Nov)
```
addon/WoWFA/Modules/Zones.lua:514
```
  513     frame.sub:SetPoint("TOP", frame.main, "BOTTOM", 0, -4)
  514     frame:SetScript("OnUpdate", toast_step)
  515     frame:Hide()
```
addon/WoWFA/Modules/Zones.lua:581
```
  580     local acc = 0
  581     fixer:SetScript("OnUpdate", function(_, el)
  582         -- rc18: every frame while the map is open (the tables hold only the strings we wrote).
```
addon/WoWFA/Panel.lua:494
```
  493     eb:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -2)
  494     eb:SetScript("OnEscapePressed", function(self)
  495         self:ClearFocus()
```
addon/WoWFA/Panel.lua:497
```
  496     end)
  497     eb:SetScript("OnEditFocusGained", function(self)
  498         self:HighlightText()
```
addon/WoWFA/Panel.lua:502
```
  501         eb.wfaFixed = ""
  502         eb:SetScript("OnTextChanged", function(self, user)
  503             if user then
```
addon/WoWFA/Panel.lua:563
```
  562     panel:RegisterForDrag("LeftButton")
  563     panel:SetScript("OnDragStart", function(self)
  564         self:StartMoving()
```
addon/WoWFA/Panel.lua:566
```
  565     end)
  566     panel:SetScript("OnDragStop", function(self)
  567         self:StopMovingOrSizing()
```
addon/WoWFA/Panel.lua:588
```
  587     close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -4)
  588     close:SetScript("OnClick", function()
  589         panel:Hide()
```
addon/WoWFA/Panel.lua:1173
```
 1172     health.svPath:SetCursorPosition(0)
 1173     health.svPath:SetScript("OnEnterPressed", function(self)
 1174         F.SvPathSet(self:GetText())
```
addon/WoWFA/Panel.lua:1280
```
 1279     eb.wfaFixed = ""
 1280     eb:SetScript("OnEscapePressed", function(self)
 1281         self:ClearFocus()
```
addon/WoWFA/Panel.lua:1283
```
 1282     end)
 1283     eb:SetScript("OnEditFocusGained", function(self)
 1284         self:HighlightText()
```
addon/WoWFA/Panel.lua:1286
```
 1285     end)
 1286     eb:SetScript("OnTextChanged", function(self, user)
 1287         if user then
```
addon/WoWFA/Panel.lua:1349
```
 1348     panel.page = pages.general
 1349     panel:SetScript("OnShow", function()
 1350         refresh()
```
addon/WoWFA/UI.lua:125
```
  124     b:SetLabel(text)
  125     b:SetScript("OnClick", function(self, button)
  126         if onClick then
```
addon/WoWFA/UI.lua:179
```
  178     end
  179     row:SetScript("OnClick", function(self)
  180         set(not get())
```
addon/WoWFA/UI.lua:273
```
  272     end
  273     slider:SetScript("OnValueChanged", function(self, v)
  274         v = snap(v)
```
addon/WoWFA/UI.lua:282
```
  281     end)
  282     slider:SetScript("OnMouseDown", function()
  283         dragging = true
```
addon/WoWFA/UI.lua:285
```
  284     end)
  285     slider:SetScript("OnMouseUp", flush)
  286     -- the window closed mid-drag: no OnMouseUp will come - apply now
```
addon/WoWFA/UI.lua:287
```
  286     -- the window closed mid-drag: no OnMouseUp will come - apply now
  287     slider:SetScript("OnHide", flush)
  288     row.slider = slider
```
addon/WoWFA/UI.lua:324
```
  323     sf:EnableMouseWheel(true)
  324     sf:SetScript("OnMouseWheel", function(self, delta)
  325         scroll_to((tonumber(self:GetVerticalScroll()) or 0) - delta * 36)
```
addon/WoWFA/UI.lua:364
```
  363         self.drag = nil
  364         self:SetScript("OnUpdate", nil)
  365     end
```
addon/WoWFA/UI.lua:366
```
  365     end
  366     thumb:SetScript("OnMouseDown", function(self)
  367         self.drag = { y = cursor_y(), v = tonumber(sf:GetVerticalScroll()) or 0 }
```
addon/WoWFA/UI.lua:368
```
  367         self.drag = { y = cursor_y(), v = tonumber(sf:GetVerticalScroll()) or 0 }
  368         self:SetScript("OnUpdate", on_drag)
  369     end)
```
addon/WoWFA/UI.lua:370
```
  369     end)
  370     thumb:SetScript("OnMouseUp", stop)
  371     thumb:SetScript("OnHide", stop)
```
addon/WoWFA/UI.lua:371
```
  370     thumb:SetScript("OnMouseUp", stop)
  371     thumb:SetScript("OnHide", stop)
  372     sf:HookScript("OnHide", function()
```
addon/WoWFA/UI.lua:439
```
  438     end
  439     sf:SetScript("OnVerticalScroll", function(self)
  440         self:UpdateBar()
```
addon/WoWFA/UI.lua:442
```
  441     end)
  442     sf:SetScript("OnScrollRangeChanged", function(self)
  443         self:UpdateBar()
```
addon/WoWFA/UI.lua:485
```
  484         toast.text:SetWidth(390)
  485         toast:SetScript("OnUpdate", function(self, el)
  486             self.t = self.t + el
```
addon/WoWFA/UI.lua:501
```
  500         end)
  501         toast:SetScript("OnClick", function(self)
  502             self:Hide()
```
addon/WoWFA/UI.lua:557
```
  556     end
  557     row:SetScript("OnClick", function(self)
  558         local v = get()
```
tests/lua/wow_mock.lua:67
```
   66 end
   67 function Obj.SetScript(s, ev, fn) s._scripts[ev] = fn end
   68 function Obj.GetScript(s, ev) return s._scripts[ev] end
```
- ok: SetScript: 55 hits

### GameTooltip

addon/WoWFA/Core.lua:364
```
  363 -- module (Modules/Spells.lua, id "spellbook", order 5: the spellbook + spell
  364 -- tooltips via GameTooltip.SetSpell) and the talents module (Modules/Spells.lua,
  365 -- id "talents", order 6: the talent tooltips via GameTooltip.SetTalent + the
```
addon/WoWFA/Core.lua:365
```
  364 -- tooltips via GameTooltip.SetSpell) and the talents module (Modules/Spells.lua,
  365 -- id "talents", order 6: the talent tooltips via GameTooltip.SetTalent + the
  366 -- talent frame text) plus the namesSpell kind (Text.lua MARKER_KEY sp).
```
addon/WoWFA/Core.lua:1043
```
 1042 function WoWFA_F_CompartmentLeave()
 1043     if GameTooltip then
 1044         GameTooltip:Hide()
```
addon/WoWFA/Core.lua:1044
```
 1043     if GameTooltip then
 1044         GameTooltip:Hide()
 1045     end
```
addon/WoWFA/Dump.lua:90
```
   89     if tip == nil then
   90         local ok, t = pcall(CreateFrame, "GameTooltip", "WoWFAF_ScanTip", nil, "GameTooltipTemplate")
   91         tip = (ok and type(t) == "table") and t or false
```
addon/WoWFA/Minimap.lua:45
```
   44     -- title) - the full health page lives in the panel's وضعیت tab
   45     GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
   46     GameTooltip:AddDoubleLine("WoWFA", "v" .. F.VERSION, C.gold[1], C.gold[2], C.gold[3], C.muted[1], C.muted[2], C.muted[3])
```
addon/WoWFA/Minimap.lua:46
```
   45     GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
   46     GameTooltip:AddDoubleLine("WoWFA", "v" .. F.VERSION, C.gold[1], C.gold[2], C.gold[3], C.muted[1], C.muted[2], C.muted[3])
   47     local line
```
addon/WoWFA/Minimap.lua:55
```
   54     end
   55     T.TipLine(GameTooltip, line, F.db.enabled and C.green or C.off)
   56     GameTooltip:Show()
```
addon/WoWFA/Minimap.lua:56
```
   55     T.TipLine(GameTooltip, line, F.db.enabled and C.green or C.off)
   56     GameTooltip:Show()
   57 end
```
addon/WoWFA/Minimap.lua:119
```
  118     btn:SetScript("OnLeave", function()
  119         GameTooltip:Hide()
  120     end)
```
addon/WoWFA/Modules/Blocked.lua:57
```
   56     end
   57     scan("GameTooltip", _G.GameTooltip)
   58     scan("UIErrorsFrame", _G.UIErrorsFrame)
```
addon/WoWFA/Modules/Dialog.lua:353
```
  352     end
  353     local tt = GameTooltip
  354     if not (tt and tt.IsShown and tt:IsShown() and tt.GetOwner) then
```
addon/WoWFA/Modules/Font.lua:28
```
   27     "GameFontDisable", "GameFontDisableSmall", "GameFontWhite", "GameFontRed", "GameFontGreen",
   28     "GameTooltipText", "GameTooltipTextSmall", "GameTooltipHeaderText",
   29     "ChatFontNormal", "ChatFontSmall",
```
addon/WoWFA/Modules/GameUI.lua:42
```
   41     EditBox = true, ScrollingMessageFrame = true, MessageFrame = true, SimpleHTML = true,
   42     GameTooltip = true, Model = true, PlayerModel = true, DressUpModel = true, CinematicModel = true,
   43     Cooldown = true, Minimap = true, Browser = true, ColorSelect = true,
```
addon/WoWFA/Modules/Npc.lua:20
```
   19 function M.api()
   20     return UnitName ~= nil and GameTooltip ~= nil
   21 end
```
addon/WoWFA/Modules/Npc.lua:122
```
  121 local function tip(tt)
  122     if tt ~= GameTooltip or not M.active then
  123         return
```
addon/WoWFA/Modules/Npc.lua:146
```
  145     end
  146     local fs = _G[(tt:GetName() or "GameTooltip") .. "TextLeft1"]
  147     if type(fs) ~= "table" or not fs.GetText then
```
addon/WoWFA/Modules/Npc.lua:239
```
  238         TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, F:Wrap("npc", tip))
  239     elseif GameTooltip.HookScript then
  240         GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
```
addon/WoWFA/Modules/Npc.lua:240
```
  239     elseif GameTooltip.HookScript then
  240         GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
  241     end
```
addon/WoWFA/Modules/Preview.lua:6
```
    5 -- windows use (the zone / NPC / quest / class tables, Walk, the NPC talk lookup, the system
    6 -- lines, the red alerts, the game-window texts) and the spell sample is a REAL GameTooltip
    7 -- the spell hooks translate, so what this column shows is what the game will show. Any switch
```
addon/WoWFA/Modules/Preview.lua:387
```
  386     build = function(f)
  387         f.tip = CreateFrame("GameTooltip", "WoWFAF_PreviewTip", f, "GameTooltipTemplate")
  388     end,
```
addon/WoWFA/Modules/Questie.lua:186
```
  185     local ok, err = pcall(function()
  186         hook(GameTooltip)
  187         hook(rawget(_G, "WorldMapTooltip"))
```
addon/WoWFA/Modules/Quests.lua:172
```
  171     faBtn:SetScript("OnEnter", function(self)
  172         if not GameTooltip then
  173             return
```
addon/WoWFA/Modules/Quests.lua:175
```
  174         end
  175         GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  176         T.TipLine(GameTooltip, L.q_fabtn_tip, C.gold)
```
addon/WoWFA/Modules/Quests.lua:176
```
  175         GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  176         T.TipLine(GameTooltip, L.q_fabtn_tip, C.gold)
  177         GameTooltip:Show()
```
addon/WoWFA/Modules/Quests.lua:177
```
  176         T.TipLine(GameTooltip, L.q_fabtn_tip, C.gold)
  177         GameTooltip:Show()
  178     end)
```
addon/WoWFA/Modules/Quests.lua:180
```
  179     faBtn:SetScript("OnLeave", function()
  180         if GameTooltip then
  181             GameTooltip:Hide()
```
addon/WoWFA/Modules/Quests.lua:181
```
  180         if GameTooltip then
  181             GameTooltip:Hide()
  182         end
```
addon/WoWFA/Modules/Spells.lua:350
```
  349 function S.api()
  350     return tdp("Spell") or (GameTooltip and (GameTooltip.SetSpellBookItem or GameTooltip.SetSpell or GameTooltip.SetSpellByID) ~= nil)
  351 end
```
addon/WoWFA/Modules/Spells.lua:362
```
  361     for _, method in ipairs({ "SetSpellBookItem", "SetSpell", "SetSpellByID" }) do
  362         if GameTooltip[method] then
  363             hooksecurefunc(GameTooltip, method, function(tt)
```
addon/WoWFA/Modules/Spells.lua:363
```
  362         if GameTooltip[method] then
  363             hooksecurefunc(GameTooltip, method, function(tt)
  364                 fn(tt)
```
addon/WoWFA/Modules/Spells.lua:376
```
  375 function TL.api()
  376     if GetTalentInfo ~= nil and GameTooltip ~= nil and GameTooltip.SetTalent ~= nil then
  377         TL.okWhy = nil
```
addon/WoWFA/Modules/Spells.lua:381
```
  380     -- lane-b12 (owner test of 0.5.4: Talents=noapi): this client has no
  381     -- GameTooltip.SetTalent - talent tooltips arrive as Spell tooltip data,
  382     -- which the spellbook module already hooks. Report ok with the
```
addon/WoWFA/Modules/Spells.lua:394
```
  393 function TL.install()
  394     if GameTooltip and GameTooltip.SetTalent then
  395         hooksecurefunc(GameTooltip, "SetTalent", F:Wrap("talents", function(tt)
```
addon/WoWFA/Modules/Spells.lua:395
```
  394     if GameTooltip and GameTooltip.SetTalent then
  395         hooksecurefunc(GameTooltip, "SetTalent", F:Wrap("talents", function(tt)
  396             spell_tip("talents", tt)
```
addon/WoWFA/Modules/Spells.lua:419
```
  418 -- The owner's rc3 test: the Forever talent frame (Primary / Secondary, Apply
  419 -- Changes) shows plain GameTooltip text with no Spell tooltip data, so no
  420 -- post-call fires (Ferocity stayed English and never reached the miss list).
```
addon/WoWFA/Modules/Spells.lua:421
```
  420 -- post-call fires (Ferocity stayed English and never reached the miss list).
  421 -- Fallback: on GameTooltip show, when line 1 is a KNOWN spell/talent name and
  422 -- the tooltip is not an item or a unit, run the same spell_tip. T.Once (same
```
addon/WoWFA/Modules/Spells.lua:510
```
  509 
  510 if GameTooltip and GameTooltip.HookScript then
  511     GameTooltip:HookScript("OnShow", function(tt)
```
addon/WoWFA/Modules/Spells.lua:511
```
  510 if GameTooltip and GameTooltip.HookScript then
  511     GameTooltip:HookScript("OnShow", function(tt)
  512         local ok, err = pcall(plain_tip, tt)
```
addon/WoWFA/Modules/Taxi.lua:82
```
   81 
   82 if GameTooltip and GameTooltip.HookScript then
   83     GameTooltip:HookScript("OnShow", function(tt)
```
addon/WoWFA/Modules/Taxi.lua:83
```
   82 if GameTooltip and GameTooltip.HookScript then
   83     GameTooltip:HookScript("OnShow", function(tt)
   84         local ok, err = pcall(on_show, tt)
```
addon/WoWFA/Modules/Zones.lua:627
```
  626             end
  627             if not GameTooltip:IsShown() then
  628                 return
```
addon/WoWFA/Modules/Zones.lua:634
```
  633             end
  634             if not T.Once(GameTooltip, "zone|" .. (z or "") .. "|" .. (s or "")) then
  635                 return
```
addon/WoWFA/Modules/Zones.lua:638
```
  637             if z then
  638                 T.TipLine(GameTooltip, z, C.gold)
  639             end
```
addon/WoWFA/Modules/Zones.lua:641
```
  640             if s and s ~= z then
  641                 T.TipLine(GameTooltip, s, C.text)
  642             end
```
addon/WoWFA/Modules/Zones.lua:643
```
  642             end
  643             T.Done(GameTooltip)
  644             GameTooltip:Show()
```
addon/WoWFA/Modules/Zones.lua:644
```
  643             T.Done(GameTooltip)
  644             GameTooltip:Show()
  645         end))
```
addon/WoWFA/Text.lua:873
```
  872 
  873 -- 1.1.6 taint fix (the owner's block report: the scan named GameTooltipTextLeft7/8 and
  874 -- MultiBar6Button1.action as tainted by WoWFA). The client creates a tooltip's line strings
```
addon/WoWFA/Text.lua:875
```
  874 -- MultiBar6Button1.action as tainted by WoWFA). The client creates a tooltip's line strings
  875 -- on demand: AddLine past the last existing one creates NEW GLOBALS (GameTooltipTextLeftN /
  876 -- RightN). Created from our code they stay tainted for the whole session, and the action
```
tests/lua/wow_mock.lua:15
```
   14 -- SetTalent is the one API the noop fallback must NOT fake: real clients
   15 -- either have it (then GameTooltip carries the instance field below) or do
   16 -- not (the 1.60.1 owner client, lane-b12) - a faked noop would make the
```
tests/lua/wow_mock.lua:51
```
   50 -- inbox/44 B: real frame types the client accepts (case-sensitive)
   51 -- 51-B (Brain review): GameTooltip is one of them - the room's hidden preview
   52 -- tooltip (CreateFrame("GameTooltip", ..., "GameTooltipTemplate")) errored
```
tests/lua/wow_mock.lua:52
```
   51 -- 51-B (Brain review): GameTooltip is one of them - the room's hidden preview
   52 -- tooltip (CreateFrame("GameTooltip", ..., "GameTooltipTemplate")) errored
   53 -- here, so the preview and the selftest item path never ran in CI
```
tests/lua/wow_mock.lua:58
```
   57     Model = true, ScrollingMessageFrame = true, MessageFrame = true, SimpleHTML = true,
   58     Browser = true, CinematicModel = true, FogOfWarFrame = true, GameTooltip = true,
   59 }
```
tests/lua/wow_mock.lua:246
```
  245 Minimap = new("Frame", "Minimap"); Minimap:SetSize(140, 140)
  246 GameTooltip = new("GameTooltip", "GameTooltip")
  247 ItemRefTooltip = new("GameTooltip", "ItemRefTooltip")
```
tests/lua/wow_mock.lua:247
```
  246 GameTooltip = new("GameTooltip", "GameTooltip")
  247 ItemRefTooltip = new("GameTooltip", "ItemRefTooltip")
  248 -- 1.1.6: the client creates tooltip line strings on demand (globals); the mock pre-creates
```
tests/lua/wow_mock.lua:251
```
  250 -- without them: the taint tests (WoWFA must never create them).
  251 for _, tn in ipairs({ "GameTooltip", "ItemRefTooltip" }) do
  252     for i = 1, 40 do
```
tests/lua/wow_mock.lua:264
```
  263 SlashCmdList = {}
  264 function GameTooltip.SetTalent() end
  265 -- 96 B: the spell tooltip path. SetSpellByID builds the live tooltip (the game
```
tests/lua/wow_mock.lua:270
```
  269 -- paragraphs included: the client hands the whole description as one leftText).
  270 function GameTooltip.SetSpellByID(s, id)
  271     s:ClearLines()
```
tests/lua/wow_mock.lua:278
```
  277 end
  278 function GameTooltip.SetSpell(s, id) return GameTooltip.SetSpellByID(s, id) end
  279 function GameTooltip.SetSpellBookItem(s, id) return GameTooltip.SetSpellByID(s, id) end
```
tests/lua/wow_mock.lua:279
```
  278 function GameTooltip.SetSpell(s, id) return GameTooltip.SetSpellByID(s, id) end
  279 function GameTooltip.SetSpellBookItem(s, id) return GameTooltip.SetSpellByID(s, id) end
  280 C_Spell = C_Spell or { GetSpellDescription = function(id)
```
tests/run.lua:152
```
  151 local live = tkey:gsub("#", "7")
  152 GameTooltip:ClearLines()
  153 GameTooltip:AddLine(skey)
```
tests/run.lua:153
```
  152 GameTooltip:ClearLines()
  153 GameTooltip:AddLine(skey)
  154 GameTooltip:AddLine(live)
```
tests/run.lua:154
```
  153 GameTooltip:AddLine(skey)
  154 GameTooltip:AddLine(live)
  155 RunTip("Spell", GameTooltip, nil)
```
tests/run.lua:155
```
  154 GameTooltip:AddLine(live)
  155 RunTip("Spell", GameTooltip, nil)
  156 local lines = GameTooltip:TipLines()
```
tests/run.lua:156
```
  155 RunTip("Spell", GameTooltip, nil)
  156 local lines = GameTooltip:TipLines()
  157 local anyFa = false
```
tests/run.lua:166
```
  165 D.tpl["zz test he will be dazed for # sec"] = "{0} ثانیه گیج"
  166 GameTooltip:ClearLines()
  167 GameTooltip:AddLine(skey)
```
tests/run.lua:167
```
  166 GameTooltip:ClearLines()
  167 GameTooltip:AddLine(skey)
  168 GameTooltip:AddLine("Zz test she will be dizzy for 4 sec.")
```
tests/run.lua:168
```
  167 GameTooltip:AddLine(skey)
  168 GameTooltip:AddLine("Zz test she will be dizzy for 4 sec.")
  169 RunTip("Spell", GameTooltip, nil)
```
tests/run.lua:169
```
  168 GameTooltip:AddLine("Zz test she will be dizzy for 4 sec.")
  169 RunTip("Spell", GameTooltip, nil)
  170 local nCtl = #GameTooltip:TipLines() -- control: no template for this line
```
tests/run.lua:170
```
  169 RunTip("Spell", GameTooltip, nil)
  170 local nCtl = #GameTooltip:TipLines() -- control: no template for this line
  171 GameTooltip:ClearLines()
```
- ok: GameTooltip: 139 hits
