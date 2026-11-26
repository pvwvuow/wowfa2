## task 0327-grep-taint (script)

**GREEN**


### .SetText =

- ok: .SetText =: 0 hits

### .SetFont =

tests/lua/wow_mock.lua:26
```
   25     if kind == "Button" then
   26         o.SetFont = false
   27         o._fontstring = new("FontString", nil, o)
```
- ok: .SetFont =: 1 hits

###  = function(self

addon/WoWFA/Panel.lua:442
```
  441         end)
  442         eb.SetFixed = function(self, s)
  443             self.wfaFixed = s or ""
```
addon/WoWFA/Panel.lua:542
```
  541     local base = pre.Update
  542     pre.Update = function(self)
  543         base(self)
```
addon/WoWFA/Panel.lua:796
```
  795         local base = row.Update
  796         row.Update = function(self)
  797             base(self)
```
addon/WoWFA/Panel.lua:943
```
  942         r.del:SetPoint("LEFT", r, "LEFT", 4, 0)
  943         r.Update = function(self)
  944             local n = F.Room.ProfileNames()[i]
```
addon/WoWFA/Panel.lua:964
```
  963     pe.text:SetPoint("TOPRIGHT", pe, "TOPRIGHT", -4, 0)
  964     pe.Update = function(self)
  965         if #F.Room.ProfileNames() == 0 then
```
addon/WoWFA/Panel.lua:1158
```
 1157     end)
 1158     eb.SetFixed = function(self, s)
 1159         self.wfaFixed = s or ""
```
addon/WoWFA/UI.lua:84
```
   83     fs:SetTextColor(color[1], color[2], color[3])
   84     fs.SetFa = function(self, text, width)
   85         T.Set(self, text, width)
```
addon/WoWFA/UI.lua:121
```
  120     b.label:SetPoint("CENTER")
  121     b.SetLabel = function(self, t)
  122         self.label:SetFa(t, (w or 120) - 8)
```
addon/WoWFA/UI.lua:162
```
  161     end
  162     row.Update = function(self)
  163         local on = get()
```
addon/WoWFA/UI.lua:202
```
  201     row.btn:SetPoint("LEFT", row, "LEFT", 0, 0)
  202     row.Update = function(self)
  203         self.btn:SetLabel(options[get()] or "?")
```
addon/WoWFA/UI.lua:289
```
  288     row.slider = slider
  289     row.Update = function(self)
  290         slider:SetValue(get() or min)
```
addon/WoWFA/UI.lua:320
```
  319     end
  320     sf.ScrollTo = function(self, v)
  321         scroll_to(v)
```
addon/WoWFA/UI.lua:375
```
  374     end)
  375     sf.UpdateBar = function(self)
  376         local h, ch = tonumber(self:GetHeight()) or 0, tonumber(child:GetHeight()) or 0
```
addon/WoWFA/UI.lua:400
```
  399     -- units, so a scaled child such as the preview tooltip measures right)
  400     sf.Fit = function(self, pad)
  401         local top = child:GetTop()
```
addon/WoWFA/UI.lua:550
```
  549     row.hair:SetPoint("BOTTOM", row, "BOTTOM", 0, 1)
  550     row.Update = function(self)
  551         local v = get()
```
- ok:  = function(self: 15 hits

### STANDARD_TEXT_FONT

addon/WoWFA/Text.lua:1112
```
 1111     if not (ok and type(font) == 'string' and type(size) == 'number') then
 1112         font, size, flags = STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF', 12, ''
 1113     end
```
- ok: STANDARD_TEXT_FONT: 1 hits

### _G[

addon/WoWFA/Core.lua:933
```
  932         for _, n in ipairs(names) do
  933             out[#out + 1] = n .. "=" .. (_G[n] ~= nil and "Y" or "N")
  934         end
```
addon/WoWFA/Dump.lua:112
```
  111     for i = 1, n do
  112         local l = _G["WoWFAF_ScanTipTextLeft" .. i]
  113         local r = _G["WoWFAF_ScanTipTextRight" .. i]
```
addon/WoWFA/Dump.lua:113
```
  112         local l = _G["WoWFAF_ScanTipTextLeft" .. i]
  113         local r = _G["WoWFAF_ScanTipTextRight" .. i]
  114         local lt = l and call(l.GetText, l)
```
addon/WoWFA/Modules/Alerts.lua:23
```
   22     for _, e in ipairs(L.ALERTS or {}) do
   23         local en = _G[e[1]]
   24         if en == nil and string.find(e[1], ' ', 1, true) then
```
addon/WoWFA/Modules/Chat.lua:81
```
   80     for i = 1, (NUM_CHAT_WINDOWS or 10) do
   81         local eb = _G["ChatFrame" .. i .. "EditBox"]
   82         if eb then
```
addon/WoWFA/Modules/Chat.lua:92
```
   91     for i = 1, (NUM_CHAT_WINDOWS or 10) do
   92         local cf = _G["ChatFrame" .. i]
   93         if cf then
```
addon/WoWFA/Modules/Chat.lua:157
```
  156     local name = eb.GetName and eb:GetName()
  157     local header = name and _G[name .. "Header"]
  158     if header and header.GetStringWidth then
```
addon/WoWFA/Modules/Font.lua:76
```
   75         for _, name in ipairs(NAMES) do
   76             local fo = _G[name]
   77             if not saved[name] and type(fo) == "table" and fo.GetFont then
```
addon/WoWFA/Modules/Font.lua:86
```
   85     for _, name in ipairs(NAMES) do
   86         local fo = _G[name]
   87         if type(fo) == "table" and fo.GetFont and fo.SetFont then
```
addon/WoWFA/Modules/Npc.lua:146
```
  145     end
  146     local fs = _G[(tt:GetName() or "GameTooltip") .. "TextLeft1"]
  147     if type(fs) ~= "table" or not fs.GetText then
```
addon/WoWFA/Modules/Questie.lua:103
```
  102     for i = 1, math.min(n, 40) do
  103         local l, r = _G[name .. "TextLeft" .. i], _G[name .. "TextRight" .. i]
  104         local okl, lt = pcall(function() return l and l:GetText() end)
```
addon/WoWFA/Modules/Quests.lua:87
```
   86     for _, name in ipairs({ "QuestFrame", "QuestLogFrame", "QuestLogDetailFrame", "QuestMapFrame" }) do
   87         local f = _G[name]
   88         if f and f.IsShown then
```
addon/WoWFA/Modules/Quests.lua:196
```
  195         local hn = host.GetName and host:GetName()
  196         hc = type(hn) == "string" and _G[hn .. "CloseButton"] or nil
  197     end
```
addon/WoWFA/Modules/Quests.lua:351
```
  350 local function game_text(fn)
  351     local f = _G[fn]
  352     if type(f) ~= "function" then
```
addon/WoWFA/Modules/Quests.lua:538
```
  537     for _, name in ipairs({ "QuestLogFrame", "QuestLogDetailFrame", "QuestMapFrame" }) do
  538         local f = _G[name]
  539         if vis(f) then
```
addon/WoWFA/Modules/Quests.lua:604
```
  603     for _, fn in ipairs({ "SelectQuestLogEntry", "QuestLog_SetSelection" }) do
  604         if type(_G[fn]) == "function" then
  605             hooksecurefunc(fn, wrapped)
```
addon/WoWFA/Modules/Quests.lua:618
```
  617         "QuestMapLogTitleButton_OnClick" }) do
  618         if type(_G[fn]) == "function" then
  619             pcall(hooksecurefunc, fn, after_select)
```
addon/WoWFA/Modules/Spells.lua:32
```
   31     for i = 1, tt:NumLines() do
   32         local fs = _G[name .. "TextLeft" .. i]
   33         local t = fs and fs:GetText()
```
addon/WoWFA/Modules/Spells.lua:117
```
  116     local function try(k)
  117         local fs = _G[name .. "TextLeft" .. k]
  118         if fs and fs.GetText then
```
addon/WoWFA/Modules/Spells.lua:447
```
  446     local tname = tt.GetName and tt:GetName()
  447     local fs = tname and _G[tname .. "TextLeft1"]
  448     local first = fs and fs:GetText()
```
addon/WoWFA/Modules/Sysmsg.lua:50
```
   49     for _, e in ipairs(L.SYSMSG or {}) do
   50         local en = _G[e[1]]
   51         if type(en) == 'string' and en ~= '' and type(e[2]) == 'string' then
```
addon/WoWFA/Modules/Taxi.lua:62
```
   61     local name = tt.GetName and tt:GetName()
   62     local fs = name and _G[name .. "TextLeft1"]
   63     if not fs then
```
addon/WoWFA/Modules/Tracker.lua:119
```
  118     for _, o in ipairs(OBJ_PATTERNS) do
  119         local fmt = _G[o.g]
  120         if type(fmt) ~= "string" or fmt == "" then
```
addon/WoWFA/Modules/Tracker.lua:420
```
  419     for i = 1, 75 do
  420         local fs = _G["QuestWatchLine" .. i]
  421         if not fs then
```
addon/WoWFA/Modules/Tracker.lua:537
```
  536     for i = 1, 40 do
  537         local b = _G["QuestLogTitle" .. i]
  538         if not b then
```
addon/WoWFA/Modules/Tracker.lua:566
```
  565         for i = 1, 32 do
  566             local b = _G[prefix .. i]
  567             if not b then
```
addon/WoWFA/Modules/Tracker.lua:600
```
  599     for _, fn in ipairs({ "QuestWatch_Update", "WatchFrame_Update" }) do
  600         if type(_G[fn]) == "function" then
  601             hooksecurefunc(fn, F:Wrap("tracker", update_watch))
```
addon/WoWFA/Modules/Tracker.lua:605
```
  604     -- modern: the global ObjectiveTracker_Update and the quest module Update
  605     if type(_G["ObjectiveTracker_Update"]) == "function" then
  606         hooksecurefunc("ObjectiveTracker_Update", F:Wrap("tracker", update_modern))
```
addon/WoWFA/Modules/Walk.lua:438
```
  437     for _, n in ipairs(kind == "spell" and SPELL_ROOTS or QUEST_ROOTS) do
  438         local f = _G[n]
  439         if type(f) == "table" and f.GetChildren and not seen[f] then
```
addon/WoWFA/Modules/Walk.lua:446
```
  445         for _, n in ipairs(QUESTIE_ROOTS) do
  446             local f = _G[n]
  447             if type(f) == "table" and f.GetChildren and not seen[f] then
```
addon/WoWFA/Text.lua:845
```
  844     end
  845     local fs = _G[name .. "Text" .. side .. tt:NumLines()]
  846     if not fs then
```
addon/WoWFA/Text.lua:1019
```
 1018         for _, side in ipairs({ "Left", "Right" }) do
 1019             local fs = _G[name .. "Text" .. side .. i]
 1020             local t = fs and fs:GetText()
```
addon/WoWFA/Text.lua:1186
```
 1185             'QuestWatch_Update', 'WatchFrame_Update' }) do
 1186             local fn = _G[name]
 1187             if type(fn) == 'function' then
```
tests/lua/wow_mock.lua:20
```
   19     local o = setmetatable({ _kind = kind, _name = name, _shown = true, _scripts = {}, _w = 0, _h = 0, _events = {}, _parent = parent }, mt)
   20     if name then _G[name] = o end
   21     frames[#frames + 1] = o
```
tests/lua/wow_mock.lua:224
```
  223     s._n = (s._n or 0) + 1
  224     local l = _G[s._name .. "TextLeft" .. s._n] or new("FontString", s._name .. "TextLeft" .. s._n)
  225     l._text = text
```
tests/lua/wow_mock.lua:226
```
  225     l._text = text
  226     local r = _G[s._name .. "TextRight" .. s._n] or new("FontString", s._name .. "TextRight" .. s._n)
  227     r._text = nil
```
tests/lua/wow_mock.lua:229
```
  228 end
  229 function Obj.AddDoubleLine(s, a, b) s:AddLine(a); _G[s._name .. "TextRight" .. s._n]._text = b end
  230 function Obj.ClearLines(s) s._n = 0; if s._scripts.OnTooltipCleared then s._scripts.OnTooltipCleared(s) end end
```
tests/lua/wow_mock.lua:237
```
  236     for i = 1, s._n or 0 do
  237         local l, r = _G[s._name .. "TextLeft" .. i], _G[s._name .. "TextRight" .. i]
  238         out[#out + 1] = tostring(l._text) .. (r._text and ("  ||  " .. r._text) or "") .. ((l._font or ""):find("Vazir") and "  [fa-font]" or "")
```
tests/lua/wow_mock.lua:399
```
  398     for i = 1, math.max(#MOCK.watchLines, watchCreated) do
  399         local fs = _G["QuestWatchLine" .. i] or new("FontString", "QuestWatchLine" .. i)
  400         watchCreated = math.max(watchCreated, i)
```
tests/lua/wow_mock.lua:410
```
  409     for i, b in ipairs(MOCK.otfBlocks) do
  410         local header = _G["OTFHeader" .. i] or new("FontString", "OTFHeader" .. i)
  411         header._text = b.header
```
- ok: _G[: 42 hits

### rawset

- ok: rawset: 0 hits

### OnUpdate

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
addon/WoWFA/Minimap.lua:100
```
   99     btn:SetScript("OnDragStart", function(self)
  100         self:SetScript("OnUpdate", function()
  101             local mx, my = Minimap:GetCenter()
```
addon/WoWFA/Minimap.lua:113
```
  112     btn:SetScript("OnDragStop", function(self)
  113         self:SetScript("OnUpdate", nil)
  114     end)
```
addon/WoWFA/Modules/Walk.lua:653
```
  652     local fixer = CreateFrame("Frame")
  653     fixer:SetScript("OnUpdate", function()
  654         if InCombatLockdown and InCombatLockdown() then
```
addon/WoWFA/Modules/Zones.lua:514
```
  513     frame.sub:SetPoint("TOP", frame.main, "BOTTOM", 0, -4)
  514     frame:SetScript("OnUpdate", toast_step)
  515     frame:Hide()
```
addon/WoWFA/Modules/Zones.lua:580
```
  579     local fixer = CreateFrame("Frame")
  580     fixer:SetScript("OnUpdate", function()
  581         -- rc18: every frame (the tables hold only the strings we wrote)
```
addon/WoWFA/UI.lua:364
```
  363         self.drag = nil
  364         self:SetScript("OnUpdate", nil)
  365     end
```
addon/WoWFA/UI.lua:368
```
  367         self.drag = { y = cursor_y(), v = tonumber(sf:GetVerticalScroll()) or 0 }
  368         self:SetScript("OnUpdate", on_drag)
  369     end)
```
addon/WoWFA/UI.lua:485
```
  484         toast.text:SetWidth(390)
  485         toast:SetScript("OnUpdate", function(self, el)
  486             self.t = self.t + el
```
- ok: OnUpdate: 12 hits

### NewTicker

addon/WoWFA/Modules/Walk.lua:609
```
  608     end
  609     if W.ticker or not (C_Timer and C_Timer.NewTicker) then
  610         return
```
addon/WoWFA/Modules/Walk.lua:612
```
  611     end
  612     W.ticker = C_Timer.NewTicker(1, function()
  613         local ok, err = pcall(W.Scan)
```
addon/WoWFA/Modules/Zones.lua:368
```
  367         end
  368         if C_Timer and C_Timer.NewTicker and not M.ticker then
  369             local n = 0
```
addon/WoWFA/Modules/Zones.lua:370
```
  369             local n = 0
  370             M.ticker = C_Timer.NewTicker(0.5, function()
  371                 if wm.IsShown and wm:IsShown() then
```
- ok: NewTicker: 4 hits

### NewTimer

- ok: NewTimer: 0 hits

### hooksecurefunc(

addon/WoWFA/Modules/Alerts.lua:145
```
  144     origAdd = ef.AddMessage -- the game's own function, called directly (never through the hook)
  145     hooksecurefunc(ef, "AddMessage", add)
  146 end
```
addon/WoWFA/Modules/Chat.lua:201
```
  200             f.wfaAddHooked = true
  201             hooksecurefunc(f, "AddMessage", function(self, text)
  202                 if need[self] or not on() or type(text) ~= "string" then
```
addon/WoWFA/Modules/Chat.lua:274
```
  273     if type(FCF_SetChatWindowFontSize) == "function" then
  274         hooksecurefunc("FCF_SetChatWindowFontSize", function()
  275             pcall(apply_font)
```
addon/WoWFA/Modules/Npc.lua:226
```
  225     if type(CompactUnitFrame_UpdateName) == "function" then
  226         hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
  227             local ok, err = pcall(plate, frame)
```
addon/WoWFA/Modules/Npc.lua:237
```
  236     if type(TargetFrame_Update) == "function" then
  237         hooksecurefunc("TargetFrame_Update", F:Wrap("npc", target))
  238     end
```
addon/WoWFA/Modules/Npc.lua:240
```
  239     if type(TargetFrame) == "table" and type(TargetFrame.Update) == "function" then
  240         hooksecurefunc(TargetFrame, "Update", F:Wrap("npc", target))
  241     end
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
addon/WoWFA/Modules/Spells.lua:338
```
  337         if GameTooltip[method] then
  338             hooksecurefunc(GameTooltip, method, function(tt)
  339                 fn(tt)
```
addon/WoWFA/Modules/Spells.lua:370
```
  369     if GameTooltip and GameTooltip.SetTalent then
  370         hooksecurefunc(GameTooltip, "SetTalent", F:Wrap("talents", function(tt)
  371             spell_tip("talents", tt)
```
addon/WoWFA/Modules/Tracker.lua:601
```
  600         if type(_G[fn]) == "function" then
  601             hooksecurefunc(fn, F:Wrap("tracker", update_watch))
  602         end
```
addon/WoWFA/Modules/Tracker.lua:606
```
  605     if type(_G["ObjectiveTracker_Update"]) == "function" then
  606         hooksecurefunc("ObjectiveTracker_Update", F:Wrap("tracker", update_modern))
  607     end
```
addon/WoWFA/Modules/Tracker.lua:612
```
  611             if mod and type(mod.Update) == "function" then
  612                 hooksecurefunc(mod, "Update", F:Wrap("tracker", update_modern))
  613             end
```
addon/WoWFA/Modules/Zones.lua:302
```
  301     fs.wfaHooked = true
  302     hooksecurefunc(fs, "SetText", function(self, text)
  303         local ok, err = pcall(on_inplace, self, text, kind)
```
tests/lua/wow_mock.lua:277
```
  276 tinsert = table.insert
  277 function hooksecurefunc(a, b, c)
  278     local tbl, name, fn = a, b, c
```
- ok: hooksecurefunc(: 15 hits
