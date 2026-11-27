## task 0463-grep-runtip (script)

**GREEN**


### RunTip

tests/lua/wow_mock.lua:295
```
  293 function TooltipDataProcessor.AddTooltipPostCall(t, fn) TooltipDataProcessor.cbs[t] = TooltipDataProcessor.cbs[t] or {}; table.insert(TooltipDataProcessor.cbs[t
  294 Enum = { TooltipDataType = { Item = 0, Spell = 1, Unit = 2, Object = 33 } }
  295 function RunTip(kind, tt, data) for _, fn in ipairs(TooltipDataProcessor.cbs[Enum.TooltipDataType[kind]] or {}) do fn(tt, data) end end
  296 C_Timer = { After = function(s, fn) table.insert(timers, fn) end }
  297 function RunTimers() local n = 0; while #timers > 0 and n < 200 do local fn = table.remove(timers, 1); fn(); n = n + 1 end end
```
tests/run.lua:155
```
  153 GameTooltip:AddLine(skey)
  154 GameTooltip:AddLine(live)
  155 RunTip("Spell", GameTooltip, nil)
  156 local lines = GameTooltip:TipLines()
  157 local anyFa = false
```
tests/run.lua:169
```
  167 GameTooltip:AddLine(skey)
  168 GameTooltip:AddLine("Zz test she will be dizzy for 4 sec.")
  169 RunTip("Spell", GameTooltip, nil)
  170 local nCtl = #GameTooltip:TipLines() -- control: no template for this line
  171 GameTooltip:ClearLines()
```
tests/run.lua:174
```
  172 GameTooltip:AddLine(skey)
  173 GameTooltip:AddLine("Zz test she will be dazed for 4 sec.")
  174 RunTip("Spell", GameTooltip, nil)
  175 local nG = #GameTooltip:TipLines()
  176 check("female-text tooltip matches the male-keyed template", nG == nCtl + 1, nG .. " vs control " .. nCtl)
```
tests/run.lua:193
```
  191 check("plain talent-style tooltip gets Persian (OnShow fallback)", plFa, table.concat(pl, " / "))
  192 local nP = #pl
  193 RunTip("Spell", GameTooltip, nil)
  194 check("the post-call after the fallback adds nothing twice", #GameTooltip:TipLines() == nP,
  195     #GameTooltip:TipLines() .. " vs " .. nP)
```
tests/run.lua:204
```
  202     GameTooltip:AddLine("Zz Not A Known Spell")
  203     GameTooltip:AddLine("این یک خط فارسی کاملاً بلند است که خودِ افزونه نوشته است")
  204     RunTip("Spell", GameTooltip, nil)
  205     local n = 0
  206     for _, e in pairs(F.db.miss or {}) do
```
tests/run.lua:215
```
  213     GameTooltip:AddLine("Zz Not A Known Spell Two")
  214     GameTooltip:AddLine("This is a long English description line that has no translation yet.")
  215     RunTip("Spell", GameTooltip, nil)
  216     n = 0
  217     for _, e in pairs(F.db.miss or {}) do
```
tests/run.lua:272
```
  270     GameTooltip:AddLine(skey)
  271     GameTooltip:AddLine("Zz test header:\r\nZzCloth\r\nZzUnknownWord")
  272     RunTip("Spell", GameTooltip, nil)
  273     local base = #GameTooltip:TipLines()
  274     check("a list with an unknown word stays English (no list lines added)", base >= 2 and base <= 3, base)
```
tests/run.lua:279
```
  277     GameTooltip:AddLine(skey)
  278     GameTooltip:AddLine("Zz test header:\r\nZzCloth\r\nZzLeather")
  279     RunTip("Spell", GameTooltip, nil)
  280     local ls = GameTooltip:TipLines()
  281     check("a known list line gets Persian header + 2 words", #ls == base + 3 and non_ascii(ls[#ls]) and non_ascii(ls[#ls - 2]),
```
tests/run.lua:317
```
  315         GameTooltip:AddLine(skey)
  316         GameTooltip:AddLine(live)
  317         RunTip("Spell", GameTooltip, nil)
  318         return GameTooltip:TipLines()
  319     end
```
- ok: RunTip: 10 hits

### OnShow

addon/WoWFA/Core.lua:168
```
  166     pcall(f.EnableKeyboard, f, true)
  167     pass(f)
  168     pcall(f.HookScript, f, "OnShow", pass)
  169     pcall(f.HookScript, f, "OnKeyDown", function(self, key)
  170         if key == "ESCAPE" then
```
addon/WoWFA/Modules/Chat.lua:187
```
  185         pcall(refresh_box, self)
  186     end)
  187     eb:HookScript("OnShow", function(self)
  188         pcall(refresh_box, self)
  189     end)
```
addon/WoWFA/Modules/GameUI.lua:8
```
    6 --     taints every secure call that reads it). L.GAMEUI (Locale_UI.lua) holds the English
    7 --     text itself, or a GlobalStrings NAME whose English is only READ at run time;
    8 --   * a listed window's OnShow is post-hooked (HookScript); one frame later its text regions
    9 --     are read, and a region whose text IS one of those English strings gets the shaped
   10 --     Persian in our font. That region's SetText / SetFormattedText are post-hooked
```
addon/WoWFA/Modules/GameUI.lua:384
```
  382 end
  383 
  384 -- a window that exists now gets its OnShow post-hook once (load-on-demand windows such as
  385 -- the auction house come later: every ADDON_LOADED tries again)
  386 local function attach()
```
addon/WoWFA/Modules/GameUI.lua:391
```
  389         if not attached[name] and type(f) == "table" and type(f.HookScript) == "function" then
  390             attached[name] = true
  391             pcall(f.HookScript, f, "OnShow", function(self)
  392                 if on() then
  393                     schedule(self)
```
addon/WoWFA/Modules/Quests.lua:630
```
  628     for _, f in ipairs(hosts()) do
  629         if f.HookScript then
  630             -- Brain review (#139): NO OnShow hook on QuestFrame - on_log there
  631             -- found no log open and ran host_gone(), so whenever the client
  632             -- showed QuestFrame AFTER our QUEST_DETAIL handler the fresh pane
```
addon/WoWFA/Modules/Quests.lua:636
```
  634             -- driven by the QUEST_* events alone, exactly as in 0.6.0.
  635             if f ~= QuestFrame then
  636                 f:HookScript("OnShow", wrapped)
  637             end
  638             f:HookScript("OnHide", F:Wrap("quests", function()
```
addon/WoWFA/Modules/Spells.lua:523
```
  521 
  522 if GameTooltip and GameTooltip.HookScript then
  523     GameTooltip:HookScript("OnShow", function(tt)
  524         local ok, err = pcall(plain_tip, tt)
  525         if not ok then
```
addon/WoWFA/Modules/Taxi.lua:83
```
   81 
   82 if GameTooltip and GameTooltip.HookScript then
   83     GameTooltip:HookScript("OnShow", function(tt)
   84         local ok, err = pcall(on_show, tt)
   85         if not ok then
```
addon/WoWFA/Modules/Walk.lua:604
```
  602     if type(wm) == "table" and wm.HookScript and not W.mapHooked then
  603         W.mapHooked = true
  604         pcall(wm.HookScript, wm, "OnShow", function()
  605             soon()
  606             F.After(0.3, soon)
```
addon/WoWFA/Modules/Zones.lua:344
```
  342     if not wm.wfaMapHooked and wm.HookScript then
  343         wm.wfaMapHooked = true
  344         wm:HookScript("OnShow", function()
  345             pcall(hook_map)
  346         end)
```
addon/WoWFA/Panel.lua:1605
```
 1603     end
 1604     panel.page = pages.general
 1605     panel:SetScript("OnShow", function()
 1606         refresh()
 1607         local sf = pages[active or "general"]
```
tests/lua/wow_mock.lua:72
```
   70 function Obj.HasScript() return true end
   71 function Obj.RegisterEvent(s, e) s._events[e] = true end
   72 function Obj.Show(s) local was = s._shown; s._shown = true; if not was and s._scripts.OnShow then s._scripts.OnShow(s) end end
   73 function Obj.Hide(s) local was = s._shown; s._shown = false; if was and s._scripts.OnHide then s._scripts.OnHide(s) end end
   74 function Obj.IsShown(s) return s._shown end
```
tests/run.lua:191
```
  189     end
  190 end
  191 check("plain talent-style tooltip gets Persian (OnShow fallback)", plFa, table.concat(pl, " / "))
  192 local nP = #pl
  193 RunTip("Spell", GameTooltip, nil)
```
- ok: OnShow: 14 hits

### HookScript

addon/WoWFA/Core.lua:168
```
  166     pcall(f.EnableKeyboard, f, true)
  167     pass(f)
  168     pcall(f.HookScript, f, "OnShow", pass)
  169     pcall(f.HookScript, f, "OnKeyDown", function(self, key)
  170         if key == "ESCAPE" then
```
addon/WoWFA/Core.lua:169
```
  167     pass(f)
  168     pcall(f.HookScript, f, "OnShow", pass)
  169     pcall(f.HookScript, f, "OnKeyDown", function(self, key)
  170         if key == "ESCAPE" then
  171             if free() then
```
addon/WoWFA/Modules/Chat.lua:175
```
  173 
  174 local function hook_box(eb)
  175     if eb.wfaOv or not eb.HookScript then
  176         return
  177     end
```
addon/WoWFA/Modules/Chat.lua:184
```
  182     ov:Hide()
  183     eb.wfaOv = ov
  184     eb:HookScript("OnTextChanged", function(self)
  185         pcall(refresh_box, self)
  186     end)
```
addon/WoWFA/Modules/Chat.lua:187
```
  185         pcall(refresh_box, self)
  186     end)
  187     eb:HookScript("OnShow", function(self)
  188         pcall(refresh_box, self)
  189     end)
```
addon/WoWFA/Modules/Chat.lua:190
```
  188         pcall(refresh_box, self)
  189     end)
  190     eb:HookScript("OnHide", function(self)
  191         pcall(show_plain, self)
  192     end)
```
addon/WoWFA/Modules/Dialog.lua:397
```
  395     for _, pair in ipairs({ { GossipFrame, "g" }, { QuestFrame, "g" }, { ItemTextFrame, "b" } }) do
  396         local fr, kind = pair[1], pair[2]
  397         if fr and fr.HookScript then
  398             pcall(fr.HookScript, fr, "OnHide", function()
  399                 if pane and pane.anchor == fr then
```
addon/WoWFA/Modules/Dialog.lua:398
```
  396         local fr, kind = pair[1], pair[2]
  397         if fr and fr.HookScript then
  398             pcall(fr.HookScript, fr, "OnHide", function()
  399                 if pane and pane.anchor == fr then
  400                     hide(kind)
```
addon/WoWFA/Modules/GameUI.lua:8
```
    6 --     taints every secure call that reads it). L.GAMEUI (Locale_UI.lua) holds the English
    7 --     text itself, or a GlobalStrings NAME whose English is only READ at run time;
    8 --   * a listed window's OnShow is post-hooked (HookScript); one frame later its text regions
    9 --     are read, and a region whose text IS one of those English strings gets the shaped
   10 --     Persian in our font. That region's SetText / SetFormattedText are post-hooked
```
addon/WoWFA/Modules/GameUI.lua:389
```
  387     for _, name in ipairs(FRAMES) do
  388         local f = _G[name]
  389         if not attached[name] and type(f) == "table" and type(f.HookScript) == "function" then
  390             attached[name] = true
  391             pcall(f.HookScript, f, "OnShow", function(self)
```
addon/WoWFA/Modules/GameUI.lua:391
```
  389         if not attached[name] and type(f) == "table" and type(f.HookScript) == "function" then
  390             attached[name] = true
  391             pcall(f.HookScript, f, "OnShow", function(self)
  392                 if on() then
  393                     schedule(self)
```
addon/WoWFA/Modules/Npc.lua:241
```
  239         and Enum.TooltipDataType.Unit then
  240         TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, F:Wrap("npc", tip))
  241     elseif GameTooltip.HookScript then
  242         GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
  243     end
```
addon/WoWFA/Modules/Npc.lua:242
```
  240         TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, F:Wrap("npc", tip))
  241     elseif GameTooltip.HookScript then
  242         GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
  243     end
  244     if type(CompactUnitFrame_UpdateName) == "function" then
```
addon/WoWFA/Modules/Preview.lua:820
```
  818         row.wfaIcon = ic
  819     end
  820     if row.HookScript then
  821         pcall(row.HookScript, row, "OnClick", show)
  822     end
```
addon/WoWFA/Modules/Preview.lua:821
```
  819     end
  820     if row.HookScript then
  821         pcall(row.HookScript, row, "OnClick", show)
  822     end
  823     if row.pick and row.pick.HookScript then
```
addon/WoWFA/Modules/Preview.lua:823
```
  821         pcall(row.HookScript, row, "OnClick", show)
  822     end
  823     if row.pick and row.pick.HookScript then
  824         pcall(row.pick.HookScript, row.pick, "OnClick", show)
  825     end
```
addon/WoWFA/Modules/Preview.lua:824
```
  822     end
  823     if row.pick and row.pick.HookScript then
  824         pcall(row.pick.HookScript, row.pick, "OnClick", show)
  825     end
  826 end
```
addon/WoWFA/Modules/Quests.lua:629
```
  627     -- of the host re-docks the pane to it
  628     for _, f in ipairs(hosts()) do
  629         if f.HookScript then
  630             -- Brain review (#139): NO OnShow hook on QuestFrame - on_log there
  631             -- found no log open and ran host_gone(), so whenever the client
```
addon/WoWFA/Modules/Quests.lua:636
```
  634             -- driven by the QUEST_* events alone, exactly as in 0.6.0.
  635             if f ~= QuestFrame then
  636                 f:HookScript("OnShow", wrapped)
  637             end
  638             f:HookScript("OnHide", F:Wrap("quests", function()
```
addon/WoWFA/Modules/Quests.lua:638
```
  636                 f:HookScript("OnShow", wrapped)
  637             end
  638             f:HookScript("OnHide", F:Wrap("quests", function()
  639                 F.After(0.05, function()
  640                     if not (QuestFrame and vis(QuestFrame)) and not log_frame() then
```
addon/WoWFA/Modules/Quests.lua:650
```
  648                 end)
  649             end))
  650             f:HookScript("OnDragStop", F:Wrap("quests", function()
  651                 if pane and pane:IsShown() and F.db.questDock ~= 3 then
  652                     dock(pane, log_frame() or (QuestFrame and vis(QuestFrame) and QuestFrame) or f)
```
addon/WoWFA/Modules/Spells.lua:522
```
  520 end
  521 
  522 if GameTooltip and GameTooltip.HookScript then
  523     GameTooltip:HookScript("OnShow", function(tt)
  524         local ok, err = pcall(plain_tip, tt)
```
addon/WoWFA/Modules/Spells.lua:523
```
  521 
  522 if GameTooltip and GameTooltip.HookScript then
  523     GameTooltip:HookScript("OnShow", function(tt)
  524         local ok, err = pcall(plain_tip, tt)
  525         if not ok then
```
addon/WoWFA/Modules/Taxi.lua:82
```
   80 end
   81 
   82 if GameTooltip and GameTooltip.HookScript then
   83     GameTooltip:HookScript("OnShow", function(tt)
   84         local ok, err = pcall(on_show, tt)
```
addon/WoWFA/Modules/Taxi.lua:83
```
   81 
   82 if GameTooltip and GameTooltip.HookScript then
   83     GameTooltip:HookScript("OnShow", function(tt)
   84         local ok, err = pcall(on_show, tt)
   85         if not ok then
```
addon/WoWFA/Modules/Walk.lua:602
```
  600     W.RebuildLog()
  601     local wm = WorldMapFrame
  602     if type(wm) == "table" and wm.HookScript and not W.mapHooked then
  603         W.mapHooked = true
  604         pcall(wm.HookScript, wm, "OnShow", function()
```
addon/WoWFA/Modules/Walk.lua:604
```
  602     if type(wm) == "table" and wm.HookScript and not W.mapHooked then
  603         W.mapHooked = true
  604         pcall(wm.HookScript, wm, "OnShow", function()
  605             soon()
  606             F.After(0.3, soon)
```
addon/WoWFA/Modules/Zones.lua:342
```
  340         return
  341     end
  342     if not wm.wfaMapHooked and wm.HookScript then
  343         wm.wfaMapHooked = true
  344         wm:HookScript("OnShow", function()
```
addon/WoWFA/Modules/Zones.lua:344
```
  342     if not wm.wfaMapHooked and wm.HookScript then
  343         wm.wfaMapHooked = true
  344         wm:HookScript("OnShow", function()
  345             pcall(hook_map)
  346         end)
```
addon/WoWFA/Modules/Zones.lua:622
```
  620         F.After(1, F:Wrap("dungeons", update))
  621     end)
  622     if MinimapZoneTextButton and MinimapZoneTextButton.HookScript then
  623         MinimapZoneTextButton:HookScript("OnEnter", F:Wrap("dungeons", function()
  624             if not F.Room.On("namesZone") then
```
addon/WoWFA/Modules/Zones.lua:623
```
  621     end)
  622     if MinimapZoneTextButton and MinimapZoneTextButton.HookScript then
  623         MinimapZoneTextButton:HookScript("OnEnter", F:Wrap("dungeons", function()
  624             if not F.Room.On("namesZone") then
  625                 return -- inbox/29 D2: the minimap zone tooltip surface
```
addon/WoWFA/Panel.lua:671
```
  669         end
  670     end)
  671     panel:HookScript("OnHide", function()
  672         t:Hide()
  673     end)
```
addon/WoWFA/Panel.lua:1588
```
 1586     end)
 1587     panel.reset:SetPoint("RIGHT", resetRow, "RIGHT", -4, 0)
 1588     panel:HookScript("OnHide", function()
 1589         if armed then
 1590             armed = false
```
addon/WoWFA/Text.lua:825
```
  823 
  824 local function hook_tooltip(tt)
  825     if tt.wfaHooked or not tt.HookScript then
  826         return
  827     end
```
addon/WoWFA/Text.lua:829
```
  827     end
  828     tt.wfaHooked = true
  829     pcall(tt.HookScript, tt, "OnTooltipCleared", restore)
  830     pcall(tt.HookScript, tt, "OnHide", restore)
  831     pcall(tt.HookScript, tt, "OnSizeChanged", function(self)
```
addon/WoWFA/Text.lua:830
```
  828     tt.wfaHooked = true
  829     pcall(tt.HookScript, tt, "OnTooltipCleared", restore)
  830     pcall(tt.HookScript, tt, "OnHide", restore)
  831     pcall(tt.HookScript, tt, "OnSizeChanged", function(self)
  832         if self.wfaX and (self.wfaX.n or 0) > 0 and T.TipExtraLayout then
```
addon/WoWFA/Text.lua:831
```
  829     pcall(tt.HookScript, tt, "OnTooltipCleared", restore)
  830     pcall(tt.HookScript, tt, "OnHide", restore)
  831     pcall(tt.HookScript, tt, "OnSizeChanged", function(self)
  832         if self.wfaX and (self.wfaX.n or 0) > 0 and T.TipExtraLayout then
  833             T.TipExtraLayout(self)
```
addon/WoWFA/UI.lua:372
```
  370     thumb:SetScript("OnMouseUp", stop)
  371     thumb:SetScript("OnHide", stop)
  372     sf:HookScript("OnHide", function()
  373         thumb:Hide()
  374     end)
```
tests/lua/wow_mock.lua:69
```
   67 function Obj.SetScript(s, ev, fn) s._scripts[ev] = fn end
   68 function Obj.GetScript(s, ev) return s._scripts[ev] end
   69 function Obj.HookScript(s, ev, fn) local old = s._scripts[ev]; s._scripts[ev] = function(...) if old then old(...) end; fn(...) end end
   70 function Obj.HasScript() return true end
   71 function Obj.RegisterEvent(s, e) s._events[e] = true end
```
- ok: HookScript: 39 hits
