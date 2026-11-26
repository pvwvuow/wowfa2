## task 0362-grep-cvar (script)

**GREEN**


### SetCVar

- ok: SetCVar: 0 hits

### C_CVar

- ok: C_CVar: 0 hits

### GetCVar

- ok: GetCVar: 0 hits

### ClearCursor

- ok: ClearCursor: 0 hits

### Pickup

- ok: Pickup: 0 hits

### SetBinding

- ok: SetBinding: 0 hits

### Override

- ok: Override: 0 hits

### _Update(

tests/lua/wow_mock.lua:404
```
  404 function QuestWatch_Update() MOCK_SetWatchLines(MOCK.watchLines) end
```
tests/lua/wow_mock.lua:405
```
  405 function WatchFrame_Update() MOCK_SetWatchLines(MOCK.watchLines) end
```
tests/lua/wow_mock.lua:422
```
  422 function Minimap_Update() MinimapZoneText:SetText(GetMinimapZoneText()) end
```
tests/run.lua:501
```
  501 QuestWatch_Update()
```
- ok: _Update(: 4 hits

### Settings

addon/WoWFA/Locale_UI.lua:28
```
   28     { "Settings", "تنظیمات" }, { "Loading...", "در حال بارگذاری..." }, { "Unknown", "نامعلوم" },
```
addon/WoWFA/Minimap.lua:2
```
    2 -- game's Settings entry and the hover summary. The button is created after
```
addon/WoWFA/Minimap.lua:125
```
  125 -- game Settings entry (Esc > Options > AddOns): a button that opens our panel
```
addon/WoWFA/Minimap.lua:133
```
  133         if SettingsPanel and SettingsPanel.IsShown and SettingsPanel:IsShown() and HideUIPanel then
```
addon/WoWFA/Minimap.lua:134
```
  134             pcall(SettingsPanel.Hide, SettingsPanel) -- 1.1.6: no HideUIPanel (taint)
```
addon/WoWFA/Minimap.lua:145
```
  145     if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
```
addon/WoWFA/Minimap.lua:146
```
  146         local ok, cat = pcall(Settings.RegisterCanvasLayoutCategory, f, "WoWFA")
```
addon/WoWFA/Minimap.lua:148
```
  148             pcall(Settings.RegisterAddOnCategory, cat)
```
tests/lua/wow_mock.lua:377
```
  377 Settings = { RegisterCanvasLayoutCategory = function() return {} end, RegisterAddOnCategory = function() end }
```
- ok: Settings: 9 hits

### EditMode

- ok: EditMode: 0 hits

### ActionBar

addon/WoWFA/Modules/Tracker.lua:278
```
  278     -- 1.1.6 (the owner's b71139 list: PetActionBar / MultiBar SetShown blocked in combat):
```
- ok: ActionBar: 1 hits

### MultiBar

addon/WoWFA/Modules/Alerts.lua:102
```
  102     -- 1.1.2 (the owner 25 Nov: "the game blocked MultiBarBottomRightButtonContainer1:SetShown()
```
addon/WoWFA/Modules/Tracker.lua:278
```
  278     -- 1.1.6 (the owner's b71139 list: PetActionBar / MultiBar SetShown blocked in combat):
```
- ok: MultiBar: 2 hits

### SetAttribute

- ok: SetAttribute: 0 hits

### UIParent

addon/WoWFA/Dump.lua:105
```
  105     pcall(tt.SetOwner, tt, WorldFrame or UIParent, "ANCHOR_NONE")
```
addon/WoWFA/Modules/Dialog.lua:157
```
  157     local f = CreateFrame("Frame", "WoWFAF_DlgPane", UIParent)
```
addon/WoWFA/Modules/Quests.lua:96
```
   96     pane = CreateFrame("Frame", "WoWFAF_QuestPane", UIParent)
```
addon/WoWFA/Modules/Quests.lua:156
```
  156     faBtn = CreateFrame("Button", "WoWFAF_QuestFaBtn", UIParent)
```
addon/WoWFA/Modules/Quests.lua:239
```
  239             f:SetPoint(p[1], UIParent, p[1], p[2], p[3])
```
addon/WoWFA/Modules/Quests.lua:241
```
  241             f:SetPoint("CENTER", UIParent, "CENTER", 320, 40)
```
addon/WoWFA/Modules/Tracker.lua:280
```
  280     -- runs UIParent_ManageFramePositions, so an addon call taints the bar layout and the
```
addon/WoWFA/Modules/Walk.lua:453
```
  453     if kind == "spell" and UIParent and UIParent.GetChildren then
```
addon/WoWFA/Modules/Walk.lua:455
```
  455             return { UIParent:GetChildren() }
```
addon/WoWFA/Modules/Zones.lua:499
```
  499     frame = CreateFrame("Frame", "WoWFAF_ZoneText", UIParent)
```
addon/WoWFA/Modules/Zones.lua:506
```
  506         frame:SetPoint("TOP", UIParent, "TOP", 0, -330)
```
addon/WoWFA/Panel.lua:551
```
  551     panel = CreateFrame("Frame", "WoWFAF_Panel", UIParent)
```
addon/WoWFA/Panel.lua:554
```
  554     panel:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
```
addon/WoWFA/Text.lua:565
```
  565 measure = CreateFrame("Frame", nil, UIParent)
```
addon/WoWFA/Text.lua:567
```
  567 measure:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", -400, -400)
```
addon/WoWFA/UI.lua:477
```
  477         toast = CreateFrame("Button", "WoWFAF_Toast", UIParent)
```
addon/WoWFA/UI.lua:479
```
  479         toast:SetPoint("TOP", UIParent, "TOP", 0, -140)
```
tests/lua/wow_mock.lua:243
```
  243 UIParent = new("Frame", "UIParent")
```
tests/lua/wow_mock.lua:244
```
  244 UIParent:SetSize(1920, 1080) -- inbox/44 D: the panel clamps in UIParent units
```
tests/run.lua:573
```
  573     local wmf = CreateFrame("Frame", "WorldMapFrame", UIParent)
```
tests/run.lua:804
```
  804     local host = CreateFrame("Frame", "ZzGameUiHost", UIParent)
```
- ok: UIParent: 21 hits

### SecureHandler

- ok: SecureHandler: 0 hits

### RegisterStateDriver

- ok: RegisterStateDriver: 0 hits

### UISpecialFrames

addon/WoWFA/Modules/Quests.lua:117
```
  117     tinsert(UISpecialFrames, "WoWFAF_QuestPane")
```
addon/WoWFA/Panel.lua:568
```
  568     if UISpecialFrames then
```
addon/WoWFA/Panel.lua:569
```
  569         table.insert(UISpecialFrames, "WoWFAF_Panel") -- Esc closes it
```
tests/lua/wow_mock.lua:253
```
  253 UISpecialFrames = {}
```
tests/run.lua:718
```
  718     for _, n in ipairs(UISpecialFrames) do
```
tests/run.lua:723
```
  723     check("panel closes on Esc (UISpecialFrames)", esc)
```
- ok: UISpecialFrames: 6 hits

### ToggleFrame

- ok: ToggleFrame: 0 hits

### CloseSpecialWindows

- ok: CloseSpecialWindows: 0 hits

### SetScript("OnShow

addon/WoWFA/Panel.lua:1343
```
 1343     panel:SetScript("OnShow", function()
```
- ok: SetScript("OnShow: 1 hits

### SetPoint("

addon/WoWFA/Minimap.lua:29
```
   29     btn:SetPoint("CENTER", Minimap, "CENTER", x * w, y * h)
```
addon/WoWFA/Minimap.lua:73
```
   73     bg:SetPoint("CENTER", btn, "TOPLEFT", 17, -15)
```
addon/WoWFA/Minimap.lua:77
```
   77     btn.icon:SetPoint("CENTER", btn, "TOPLEFT", 17, -15)
```
addon/WoWFA/Minimap.lua:80
```
   80     border:SetPoint("TOPLEFT")
```
addon/WoWFA/Minimap.lua:84
```
   84     btn.alert:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -4, -4)
```
addon/WoWFA/Minimap.lua:130
```
  130     title:SetPoint("TOPLEFT", 16, -16)
```
addon/WoWFA/Minimap.lua:141
```
  141     b:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
```
addon/WoWFA/Minimap.lua:143
```
  143     en:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 0, -8)
```
addon/WoWFA/Modules/Chat.lua:165
```
  165     ov:SetPoint("LEFT", eb, "LEFT", left, 0)
```
addon/WoWFA/Modules/Chat.lua:166
```
  166     ov:SetPoint("RIGHT", eb, "RIGHT", -10, 0)
```
addon/WoWFA/Modules/Dialog.lua:164
```
  164     f.text:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -12)
```
addon/WoWFA/Modules/Dialog.lua:188
```
  188     f:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 4, -12)
```
addon/WoWFA/Modules/Preview.lua:129
```
  129         l:SetPoint("TOP" .. side)
```
addon/WoWFA/Modules/Preview.lua:130
```
  130         l:SetPoint("BOTTOM" .. side)
```
addon/WoWFA/Modules/Preview.lua:137
```
  137     f:SetPoint("TOPLEFT", parent, "TOPLEFT", x or 0, y or 0)
```
addon/WoWFA/Modules/Preview.lua:256
```
  256         f.lvl:SetPoint("TOPLEFT", f.tip, "TOPLEFT", 8, -52)
```
addon/WoWFA/Modules/Preview.lua:313
```
  313         f.qt:SetPoint("TOPLEFT", f.qf, "TOPLEFT", 10, -8)
```
addon/WoWFA/Modules/Preview.lua:316
```
  316         f.qb:SetPoint("TOPLEFT", f.qf, "TOPLEFT", 10, -30)
```
addon/WoWFA/Modules/Preview.lua:322
```
  322         f.ft:SetPoint("TOPRIGHT", f.fp, "TOPRIGHT", -10, -10)
```
addon/WoWFA/Modules/Preview.lua:325
```
  325         f.fb:SetPoint("TOPRIGHT", f.fp, "TOPRIGHT", -10, -34)
```
addon/WoWFA/Modules/Preview.lua:379
```
  379         tip:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
```
addon/WoWFA/Modules/Preview.lua:415
```
  415         f.gt:SetPoint("TOPLEFT", f.gp, "TOPLEFT", 10, -10)
```
addon/WoWFA/Modules/Preview.lua:420
```
  420         f.ft:SetPoint("TOPRIGHT", f.fp, "TOPRIGHT", -10, -12)
```
addon/WoWFA/Modules/Preview.lua:566
```
  566         f.l:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -16)
```
addon/WoWFA/Modules/Preview.lua:583
```
  583         f.t:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -14)
```
- ok: SetPoint(": 146 hits
