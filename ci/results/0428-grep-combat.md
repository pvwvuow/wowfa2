## task 0428-grep-combat (script)

**GREEN**


### PLAYER_REGEN

addon/WoWFA/Modules/GameUI.lua:482
```
  481 end)
  482 F:On("PLAYER_REGEN_ENABLED", nil, function()
  483     local ok, err = pcall(after_combat)
```
addon/WoWFA/Modules/Tracker.lua:365
```
  364 -- the modern tracker is taint-sensitive: never touch it in combat - queue and
  365 -- apply on PLAYER_REGEN_ENABLED. The classic QuestWatch is plain: direct.
  366 local pendingModern = false
```
addon/WoWFA/Modules/Tracker.lua:632
```
  631     F:On("QUEST_WATCH_UPDATE", "tracker", update_watch)
  632     F:On("PLAYER_REGEN_ENABLED", "tracker", function()
  633         if pendingModern then
```
addon/WoWFA/Modules/Walk.lua:578
```
  577 -- 1.1.1: the lines the game / Questie rewrote in combat get their Persian when it ends
  578 F:On("PLAYER_REGEN_ENABLED", nil, function()
  579     local list = {}
```
tests/run.lua:866
```
  865     MOCK.combat = false
  866     FireEvent("PLAYER_REGEN_ENABLED")
  867     check("gameui: the text written in combat is swapped after it", non_ascii(cb:GetText()), cb:GetText())
```
- ok: PLAYER_REGEN: 5 hits

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
- ok: hooksecurefunc: 29 hits

### CURSOR_CHANGED

- ok: CURSOR_CHANGED: 0 hits

### ACTIONBAR

- ok: ACTIONBAR: 0 hits

### UNIT_SPELLCAST

- ok: UNIT_SPELLCAST: 0 hits

### UpdateGrid

- ok: UpdateGrid: 0 hits

### securecall

- ok: securecall: 0 hits

### SetFont(

addon/WoWFA/Modules/Chat.lua:152
```
  151     if not set_chat_font(ov, fsz, "") then
  152         ov:SetFont(F.FONT, fsz, "")
  153     end
```
addon/WoWFA/Modules/Chat.lua:179
```
  178     local ov = eb:CreateFontString(nil, "OVERLAY")
  179     ov:SetFont(F.FONT, 14, "")
  180     ov:SetWordWrap(false)
```
addon/WoWFA/Modules/GameUI.lua:237
```
  236             end
  237             fs:SetFont(F.FONT, size, rec.flags or "")
  238         end
```
addon/WoWFA/Modules/GameUI.lua:425
```
  424             if rec.font and rec.size then
  425                 fs:SetFont(rec.font, rec.size, rec.flags or "")
  426             end
```
addon/WoWFA/Modules/Npc.lua:69
```
   68     local o = orig[fs]
   69     fs:SetFont(F.FONT, o.size or 12, F.Flags("npc", o.flags or "")) -- 1.1.0: the NPC outline switch
   70     local s = shaped(fa)
```
addon/WoWFA/Modules/Preview.lua:67
```
   66     local fs = parent:CreateFontString(nil, "OVERLAY")
   67     fs:SetFont(GAMEFONT, size, flags or "")
   68     fs:SetTextColor(color[1], color[2], color[3])
```
addon/WoWFA/Modules/Preview.lua:581
```
  580         else
  581             f.l:SetFont(GAMEFONT, 13, "")
  582         end
```
addon/WoWFA/Modules/Tracker.lua:253
```
  252     local sz = F.SizeOf(o.role)
  253     fs:SetFont(F.FONT, sz, F.Flags(o.role == "title" and "qs" or nil))
  254     -- the player's CURRENT display mode (Brain review #136-1); colour kept -
```
addon/WoWFA/Modules/Walk.lua:330
```
  329     local sz = F.SizeOf(mine[fs].role)
  330     fs:SetFont(F.FONT, sz, F.Flags(OLFAM[mine[fs].role]))
  331     fs:SetText(out)
```
addon/WoWFA/Modules/Zones.lua:173
```
  172     original[fs].kind = kind
  173     fs:SetFont(F.FONT, (original[fs].size or T.Size()), flags_of(original[fs]))
  174     guard_font(fs)
```
addon/WoWFA/Panel.lua:490
```
  489     eb:SetMaxLetters(0)
  490     eb:SetFont(F.FONT, 11, "")
  491     eb:SetTextColor(C.text[1], C.text[2], C.text[3])
```
addon/WoWFA/Panel.lua:1275
```
 1274     eb:SetAutoFocus(false)
 1275     eb:SetFont(F.FONT, 10, "")
 1276     eb:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
```
addon/WoWFA/Text.lua:592
```
  591     end
  592     measure:SetFont(F.FONT, size, "")
  593     measure:SetText(shaped)
```
addon/WoWFA/Text.lua:712
```
  711     local mode = fs.wfaMode or T.Mode()
  712     fs:SetFont(F.FONT, size, F.Flags())
  713     if width and width >= 40 then
```
addon/WoWFA/Text.lua:865
```
  864     table.insert(tt.wfaFonts, { fs = fs, font = font, size = size, flags = flags, justify = fs:GetJustifyH(), spacing = fs.GetSpacing and fs:GetSpacing() or nil
  865     fs:SetFont(F.FONT, T.Size(), F.Flags())
  866     -- inbox/29 C: the same line gap on the spell/talent (TipLine) strings
```
addon/WoWFA/Text.lua:951
```
  950     end
  951     fs:SetFont(F.FONT, size, F.Flags())
  952     fs:SetSpacing(T.Spacing(size))
```
addon/WoWFA/Text.lua:1067
```
 1066     local size = T.Size()
 1067     fs:SetFont(F.FONT, size, F.Flags(fam))
 1068     -- inbox/29 C: the same line gap on the multi-line in-place strings
```
addon/WoWFA/UI.lua:77
```
   76     local fs = parent:CreateFontString(nil, layer or "OVERLAY")
   77     fs:SetFont(F.FONT, size or T.Size(), "")
   78     -- inbox/44 D: Persian multi-line breathing room scales with the font
```
addon/WoWFA/UI.lua:93
```
   92     local fs = parent:CreateFontString(nil, "OVERLAY")
   93     fs:SetFont(F.FONT, size or 12, "")
   94     color = color or C.muted
```
tests/lua/wow_mock.lua:174
```
  173 end
  174 function Obj.SetFont(s, f, sz, flags)
  175     if flags and flags ~= "" then
```
tests/lua/wow_mock.lua:204
```
  203 function Obj.GetFont(s) return s._font or "Fonts\\FRIZQT__.TTF", s._fsize or 12, "" end
  204 function Obj.SetFont(s, f, sz) s._font, s._fsize = f, sz; return true end
  205 -- inbox/27: font objects + text colour - the in-place restore test asserts the
```
- ok: SetFont(: 21 hits

### RegisterEvent("

- ok: RegisterEvent(": 0 hits
