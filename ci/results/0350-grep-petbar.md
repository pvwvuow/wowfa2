## task 0350-grep-petbar (script)

**GREEN**


### SetCVar

- ok: SetCVar: 0 hits

### C_CVar

- ok: C_CVar: 0 hits

### ShowUIPanel

addon/WoWFA/Text.lua:295
```
  293         end
  294         cpf:Hide()
  295         if ShowUIPanel then
  296             pcall(ShowUIPanel, cpf)
  297         else
```
addon/WoWFA/Text.lua:296
```
  294         cpf:Hide()
  295         if ShowUIPanel then
  296             pcall(ShowUIPanel, cpf)
  297         else
  298             cpf:Show()
```
- ok: ShowUIPanel: 2 hits

### HideUIPanel

addon/WoWFA/Minimap.lua:133
```
  131     title:SetText("WoWFA " .. F.VERSION)
  132     local b = UI.Button(f, L.open_panel, 200, 28, function()
  133         if SettingsPanel and SettingsPanel.IsShown and SettingsPanel:IsShown() and HideUIPanel then
  134             pcall(HideUIPanel, SettingsPanel)
  135         end
```
addon/WoWFA/Minimap.lua:134
```
  132     local b = UI.Button(f, L.open_panel, 200, 28, function()
  133         if SettingsPanel and SettingsPanel.IsShown and SettingsPanel:IsShown() and HideUIPanel then
  134             pcall(HideUIPanel, SettingsPanel)
  135         end
  136         if InterfaceOptionsFrame and InterfaceOptionsFrame.IsShown and InterfaceOptionsFrame:IsShown() and HideUIPanel then
```
addon/WoWFA/Minimap.lua:136
```
  134             pcall(HideUIPanel, SettingsPanel)
  135         end
  136         if InterfaceOptionsFrame and InterfaceOptionsFrame.IsShown and InterfaceOptionsFrame:IsShown() and HideUIPanel then
  137             pcall(HideUIPanel, InterfaceOptionsFrame)
  138         end
```
addon/WoWFA/Minimap.lua:137
```
  135         end
  136         if InterfaceOptionsFrame and InterfaceOptionsFrame.IsShown and InterfaceOptionsFrame:IsShown() and HideUIPanel then
  137             pcall(HideUIPanel, InterfaceOptionsFrame)
  138         end
  139         F.OpenPanel("home")
```
- ok: HideUIPanel: 4 hits

### pcall(fn)

addon/WoWFA/Room.lua:267
```
  265     end
  266     for _, fn in ipairs(listeners) do
  267         local ok, err = pcall(fn)
  268         if not ok then
  269             geterrorhandler()(err)
```
addon/WoWFA/Text.lua:1188
```
 1186             local fn = _G[name]
 1187             if type(fn) == 'function' then
 1188                 pcall(fn)
 1189             end
 1190         end
```
- ok: pcall(fn): 2 hits

### _Update

addon/WoWFA/Core.lua:928
```
  926         -- which quest/watch/tooltip frames and functions exist on THIS client
  927         -- (lane 28 builds its quest surfaces from exactly this answer)
  928         local names = { "QuestWatchFrame", "QuestWatch_Update", "WatchFrame", "ObjectiveTrackerFrame",
  929             "QuestLogFrame", "QuestMapFrame", "GossipFrame", "ZoneTextString", "SubZoneTextString",
  930             "MinimapZoneText", "WorldMapFrame", "ItemRefShoppingTooltip1", "TooltipDataProcessor" }
```
addon/WoWFA/Modules/Npc.lua:85
```
   83 end
   84 
   85 -- the name above a unit: the client calls CompactUnitFrame_UpdateName every
   86 -- time it writes the name; we write ours right after it
   87 local function plate(frame)
```
addon/WoWFA/Modules/Npc.lua:205
```
  203 -- the name family or the display changed: the plates and the target frame again
  204 local function redo()
  205     if C_NamePlate and C_NamePlate.GetNamePlates and CompactUnitFrame_UpdateName then
  206         local okp, plates = pcall(C_NamePlate.GetNamePlates)
  207         if okp and type(plates) == "table" then
```
addon/WoWFA/Modules/Npc.lua:210
```
  208             for _, np in ipairs(plates) do
  209                 if type(np) == "table" and np.UnitFrame then
  210                     pcall(CompactUnitFrame_UpdateName, np.UnitFrame)
  211                 end
  212             end
```
addon/WoWFA/Modules/Npc.lua:225
```
  223         GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
  224     end
  225     if type(CompactUnitFrame_UpdateName) == "function" then
  226         hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
  227             local ok, err = pcall(plate, frame)
```
addon/WoWFA/Modules/Npc.lua:226
```
  224     end
  225     if type(CompactUnitFrame_UpdateName) == "function" then
  226         hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
  227             local ok, err = pcall(plate, frame)
  228             if not ok then
```
addon/WoWFA/Modules/Npc.lua:236
```
  234         F.After(0, F:Wrap("npc", target))
  235     end)
  236     if type(TargetFrame_Update) == "function" then
  237         hooksecurefunc("TargetFrame_Update", F:Wrap("npc", target))
  238     end
```
addon/WoWFA/Modules/Npc.lua:237
```
  235     end)
  236     if type(TargetFrame_Update) == "function" then
  237         hooksecurefunc("TargetFrame_Update", F:Wrap("npc", target))
  238     end
  239     if type(TargetFrame) == "table" and type(TargetFrame.Update) == "function" then
```
addon/WoWFA/Modules/Tracker.lua:9
```
    7 --
    8 -- Surfaces:
    9 --   classic  QuestWatchFrame    QuestWatch_Update + QuestWatchLine%d
   10 --   era 2    WatchFrame         WatchFrame_Update + the same line pattern
   11 --   modern   ObjectiveTrackerFrame (quest module Update + block header/lines)
```
addon/WoWFA/Modules/Tracker.lua:10
```
    8 -- Surfaces:
    9 --   classic  QuestWatchFrame    QuestWatch_Update + QuestWatchLine%d
   10 --   era 2    WatchFrame         WatchFrame_Update + the same line pattern
   11 --   modern   ObjectiveTrackerFrame (quest module Update + block header/lines)
   12 --   quest log   QuestLogFrame buttons QuestLogTitle%d (QUEST_LOG_UPDATE)
```
addon/WoWFA/Modules/Tracker.lua:279
```
  277     end
  278     -- Brain review #136-3: let the client redraw its own English right away
  279     if QuestWatch_Update then
  280         pcall(QuestWatch_Update)
  281     end
```
addon/WoWFA/Modules/Tracker.lua:280
```
  278     -- Brain review #136-3: let the client redraw its own English right away
  279     if QuestWatch_Update then
  280         pcall(QuestWatch_Update)
  281     end
  282     if WatchFrame_Update then
```
addon/WoWFA/Modules/Tracker.lua:282
```
  280         pcall(QuestWatch_Update)
  281     end
  282     if WatchFrame_Update then
  283         pcall(WatchFrame_Update)
  284     end
```
addon/WoWFA/Modules/Tracker.lua:283
```
  281     end
  282     if WatchFrame_Update then
  283         pcall(WatchFrame_Update)
  284     end
  285     if ObjectiveTracker_Update and not (InCombatLockdown and InCombatLockdown()) then -- rc36: no taint in combat
```
addon/WoWFA/Modules/Tracker.lua:285
```
  283         pcall(WatchFrame_Update)
  284     end
  285     if ObjectiveTracker_Update and not (InCombatLockdown and InCombatLockdown()) then -- rc36: no taint in combat
  286         pcall(ObjectiveTracker_Update)
  287     end
```
addon/WoWFA/Modules/Tracker.lua:286
```
  284     end
  285     if ObjectiveTracker_Update and not (InCombatLockdown and InCombatLockdown()) then -- rc36: no taint in combat
  286         pcall(ObjectiveTracker_Update)
  287     end
  288 end
```
addon/WoWFA/Modules/Tracker.lua:598
```
  596 
  597 function M.install()
  598     -- classic: QuestWatch_Update global; era 2: WatchFrame_Update
  599     for _, fn in ipairs({ "QuestWatch_Update", "WatchFrame_Update" }) do
  600         if type(_G[fn]) == "function" then
```
addon/WoWFA/Modules/Tracker.lua:599
```
  597 function M.install()
  598     -- classic: QuestWatch_Update global; era 2: WatchFrame_Update
  599     for _, fn in ipairs({ "QuestWatch_Update", "WatchFrame_Update" }) do
  600         if type(_G[fn]) == "function" then
  601             hooksecurefunc(fn, F:Wrap("tracker", update_watch))
```
addon/WoWFA/Modules/Tracker.lua:604
```
  602         end
  603     end
  604     -- modern: the global ObjectiveTracker_Update and the quest module Update
  605     if type(_G["ObjectiveTracker_Update"]) == "function" then
  606         hooksecurefunc("ObjectiveTracker_Update", F:Wrap("tracker", update_modern))
```
addon/WoWFA/Modules/Tracker.lua:605
```
  603     end
  604     -- modern: the global ObjectiveTracker_Update and the quest module Update
  605     if type(_G["ObjectiveTracker_Update"]) == "function" then
  606         hooksecurefunc("ObjectiveTracker_Update", F:Wrap("tracker", update_modern))
  607     end
```
addon/WoWFA/Modules/Tracker.lua:606
```
  604     -- modern: the global ObjectiveTracker_Update and the quest module Update
  605     if type(_G["ObjectiveTracker_Update"]) == "function" then
  606         hooksecurefunc("ObjectiveTracker_Update", F:Wrap("tracker", update_modern))
  607     end
  608     local otf = ObjectiveTrackerFrame
```
addon/WoWFA/Modules/Zones.lua:232
```
  230     end
  231     -- the client's own update redraws the minimap zone text in English
  232     if Minimap_Update then
  233         pcall(Minimap_Update)
  234     end
```
addon/WoWFA/Modules/Zones.lua:233
```
  231     -- the client's own update redraws the minimap zone text in English
  232     if Minimap_Update then
  233         pcall(Minimap_Update)
  234     end
  235 end
```
addon/WoWFA/Text.lua:1184
```
 1182             return
 1183         end
 1184         for _, name in ipairs({ 'QuestMapFrame_UpdateAll', 'QuestLogQuests_Update', 'ObjectiveTracker_Update',
 1185             'QuestWatch_Update', 'WatchFrame_Update' }) do
 1186             local fn = _G[name]
```
addon/WoWFA/Text.lua:1185
```
 1183         end
 1184         for _, name in ipairs({ 'QuestMapFrame_UpdateAll', 'QuestLogQuests_Update', 'ObjectiveTracker_Update',
 1185             'QuestWatch_Update', 'WatchFrame_Update' }) do
 1186             local fn = _G[name]
 1187             if type(fn) == 'function' then
```
tests/lua/wow_mock.lua:404
```
  402     end
  403 end
  404 function QuestWatch_Update() MOCK_SetWatchLines(MOCK.watchLines) end
  405 function WatchFrame_Update() MOCK_SetWatchLines(MOCK.watchLines) end
  406 function MOCK_SetOTF(blocks)
```
tests/lua/wow_mock.lua:405
```
  403 end
  404 function QuestWatch_Update() MOCK_SetWatchLines(MOCK.watchLines) end
  405 function WatchFrame_Update() MOCK_SetWatchLines(MOCK.watchLines) end
  406 function MOCK_SetOTF(blocks)
  407     MOCK.otfBlocks = blocks or {}
```
tests/lua/wow_mock.lua:422
```
  420 end
  421 function GetMinimapZoneText() return MOCK.minimapZone or "" end
  422 function Minimap_Update() MinimapZoneText:SetText(GetMinimapZoneText()) end
  423 function MOCK_SetGossip(list)
  424     MOCK.gossipButtons = list or {}
```
tests/run.lua:488
```
  486 MOCK.logList = { { title = "Live Title Of The Quest", id = qid } }
  487 MOCK_SetWatchLines({ "Live Title Of The Quest", " - Kobold Vermin slain: 3/10" })
  488 QuestWatch_Update()
  489 local l1, l2 = QuestWatchLine1:GetText(), QuestWatchLine2:GetText()
  490 check("tracker title in Persian", non_ascii(l1), l1)
```
- ok: _Update: 29 hits

### :Update(

addon/WoWFA/Panel.lua:335
```
  333         if r.Update then
  334             r.dimmed = off and r.dimOnMaster or nil
  335             r:Update()
  336         end
  337     end
```
addon/WoWFA/Panel.lua:827
```
  825         row.val:ClearAllPoints()
  826         row.val:SetPoint("TOPLEFT", row, "TOPLEFT", 96, -6)
  827         row:Update()
  828         panel.col[fam] = place(row, 32, 2)
  829     end
```
addon/WoWFA/Panel.lua:972
```
  970         end
  971         panel.pfRows[i] = place(r, 30, 2)
  972         r:Update()
  973     end
  974     local pe = CreateFrame("Frame", nil, page.child)
```
addon/WoWFA/Panel.lua:987
```
  985     end
  986     place(pe, 24, 2)
  987     pe:Update()
  988     end_page()
  989 
```
addon/WoWFA/UI.lua:181
```
  179     row:SetScript("OnClick", function(self)
  180         set(not get())
  181         self:Update()
  182     end)
  183     row:Update()
```
addon/WoWFA/UI.lua:183
```
  181         self:Update()
  182     end)
  183     row:Update()
  184     return row
  185 end
```
addon/WoWFA/UI.lua:199
```
  197         local v = get() % #options + 1
  198         set(v)
  199         row:Update()
  200     end)
  201     row.btn:SetPoint("LEFT", row, "LEFT", 0, 0)
```
addon/WoWFA/UI.lua:563
```
  561         local nv = (v % n) + 1
  562         set(nv)
  563         self:Update()
  564     end)
  565     row:Update()
```
addon/WoWFA/UI.lua:565
```
  563         self:Update()
  564     end)
  565     row:Update()
  566     return row
  567 end
```
- ok: :Update(: 9 hits

### MarkDirty

- ok: MarkDirty: 0 hits

### ManageFramePositions

- ok: ManageFramePositions: 0 hits

### EditMode

- ok: EditMode: 0 hits

### UIPanelWindows

- ok: UIPanelWindows: 0 hits

### SetAttribute

- ok: SetAttribute: 0 hits

### RegisterStateDriver

- ok: RegisterStateDriver: 0 hits

### SetParent(

addon/WoWFA/Modules/Quests.lua:215
```
  213     end
  214     if host ~= faBtn:GetParent() then
  215         faBtn:SetParent(host)
  216         faBtn:SetFrameLevel(host.GetFrameLevel and (host:GetFrameLevel() + 10) or 10)
  217     end
```
tests/lua/wow_mock.lua:197
```
  195 function Obj.GetValue(s) return s._value end
  196 function Obj.GetParent(s) return s._parent end
  197 function Obj.SetParent(s, p) s._parent = p end -- the fā button re-parents per host
  198 function Obj.GetFrameLevel(s) return s._level or 1 end
  199 function Obj.SetFrameLevel(s, l) s._level = l end
```
- ok: SetParent(: 2 hits

### SetFrameStrata(

addon/WoWFA/Minimap.lua:62
```
   60     btn = CreateFrame("Button", "WoWFAF_MinimapButton", Minimap)
   61     btn:SetSize(31, 31)
   62     btn:SetFrameStrata("MEDIUM")
   63     btn:SetFrameLevel(8)
   64     btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
```
addon/WoWFA/Modules/Dialog.lua:159
```
  157     local f = CreateFrame("Frame", "WoWFAF_DlgPane", UIParent)
  158     f:Hide()
  159     f:SetFrameStrata("HIGH")
  160     f:SetClampedToScreen(true)
  161     f:SetSize(324, 80)
```
addon/WoWFA/Modules/Quests.lua:98
```
   96     pane = CreateFrame("Frame", "WoWFAF_QuestPane", UIParent)
   97     pane:SetSize(PW, PH)
   98     pane:SetFrameStrata("MEDIUM")
   99     pane:SetToplevel(true)
  100     pane:SetClampedToScreen(true)
```
addon/WoWFA/Modules/Quests.lua:158
```
  156     faBtn = CreateFrame("Button", "WoWFAF_QuestFaBtn", UIParent)
  157     faBtn:SetSize(30, 20)
  158     faBtn:SetFrameStrata("MEDIUM")
  159     local fbg = UI.Tex(faBtn, "BACKGROUND")
  160     fbg:SetAllPoints()
```
addon/WoWFA/Modules/Zones.lua:501
```
  499     frame = CreateFrame("Frame", "WoWFAF_ZoneText", UIParent)
  500     frame:SetSize(520, 80)
  501     frame:SetFrameStrata("LOW")
  502     frame:EnableMouse(false)
  503     if SubZoneTextString then
```
addon/WoWFA/Panel.lua:462
```
  460     panel:SetSize(W, H)
  461     panel:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
  462     panel:SetFrameStrata("DIALOG")
  463     panel:SetClampedToScreen(true)
  464     panel:EnableMouse(true)
```
addon/WoWFA/UI.lua:480
```
  478         toast:SetSize(420, 40)
  479         toast:SetPoint("TOP", UIParent, "TOP", 0, -140)
  480         toast:SetFrameStrata("HIGH")
  481         UI.Glass(toast, 0.9)
  482         toast.text = UI.Text(toast, 12, C.text, "CENTER")
```
- ok: SetFrameStrata(: 7 hits

### Settings.

addon/WoWFA/Minimap.lua:145
```
  143     en:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 0, -8)
  144     en:SetText("Open the WoWFA panel  (/wowfa)")
  145     if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
  146         local ok, cat = pcall(Settings.RegisterCanvasLayoutCategory, f, "WoWFA")
  147         if ok and cat then
```
addon/WoWFA/Minimap.lua:146
```
  144     en:SetText("Open the WoWFA panel  (/wowfa)")
  145     if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
  146         local ok, cat = pcall(Settings.RegisterCanvasLayoutCategory, f, "WoWFA")
  147         if ok and cat then
  148             pcall(Settings.RegisterAddOnCategory, cat)
```
addon/WoWFA/Minimap.lua:148
```
  146         local ok, cat = pcall(Settings.RegisterCanvasLayoutCategory, f, "WoWFA")
  147         if ok and cat then
  148             pcall(Settings.RegisterAddOnCategory, cat)
  149             return
  150         end
```
- ok: Settings.: 3 hits

### UIDropDownMenu

- ok: UIDropDownMenu: 0 hits

### tinsert(

addon/WoWFA/Modules/Quests.lua:117
```
  115     UI.Glass(pane)
  116     -- ESC closes the pane (inbox/29 B)
  117     tinsert(UISpecialFrames, "WoWFAF_QuestPane")
  118     pane.title = UI.Text(pane, 15, C.gold)
  119     pane.title:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -PAD, -12)
```
- ok: tinsert(: 1 hits

### table.insert(UI

addon/WoWFA/Panel.lua:476
```
  474     UI.Glass(panel, 0.97)
  475     if UISpecialFrames then
  476         table.insert(UISpecialFrames, "WoWFAF_Panel") -- Esc closes it
  477     end
  478 
```
- ok: table.insert(UI: 1 hits
