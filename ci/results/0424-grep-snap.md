## task 0424-grep-snap (script)

**GREEN**


### snappedToFrame

addon/WoWFA/Core.lua:149
```
  146 -- reading global WoWFAF_Panel - UIParentPanelManager.lua:1109"): a frame name put in
  147 -- UISpecialFrames is a global WoWFA wrote, and the game's panel manager reads every name in that
  148 -- list on Esc and when a game window opens. From there the action bar layout ran tainted
  149 -- (MultiBarBottomLeft.snappedToFrame) and the bars were blocked in combat. So NO WoWFA frame is
  150 -- in UISpecialFrames: the frame takes Esc itself. Out of combat it keeps the key (the game menu
  151 -- does not open too); in combat it only closes and the key goes on to the game, because
  152 -- SetPropagateKeyboardInput is protected there.
```
- ok: snappedToFrame: 1 hits

### MultiBar

addon/WoWFA/Core.lua:149
```
  146 -- reading global WoWFAF_Panel - UIParentPanelManager.lua:1109"): a frame name put in
  147 -- UISpecialFrames is a global WoWFA wrote, and the game's panel manager reads every name in that
  148 -- list on Esc and when a game window opens. From there the action bar layout ran tainted
  149 -- (MultiBarBottomLeft.snappedToFrame) and the bars were blocked in combat. So NO WoWFA frame is
  150 -- in UISpecialFrames: the frame takes Esc itself. Out of combat it keeps the key (the game menu
  151 -- does not open too); in combat it only closes and the key goes on to the game, because
  152 -- SetPropagateKeyboardInput is protected there.
```
addon/WoWFA/Modules/Alerts.lua:102
```
   99 end
  100 
  101 local function add(self, text, ...)
  102     -- 1.1.2 (the owner 25 Nov: "the game blocked MultiBarBottomRightButtonContainer1:SetShown()
  103     -- (combat)"): this used to REPLACE UIErrorsFrame.AddMessage with our own function. Every red
  104     -- line the game's own secure code sent there ("Ability is not ready yet" ...) then ran OUR code
  105     -- inside its call, the call became tainted and the game blocked the next protected action
```
addon/WoWFA/Modules/Blocked.lua:17
```
   14     return total
   15 end
   16 
   17 -- 1.1.6 (the block came back on MultiBarBottomLeft buttons): WHICH variable did WoWFA write?
   18 -- issecurevariable names the addon that last wrote a key. The frame the game blocked, its
   19 -- parent, the game tooltip, the error frame and every global are checked once per kind of
   20 -- block, and the keys WoWFA wrote (not its own wfa* fields) are named in the report line.
```
addon/WoWFA/Modules/Tracker.lua:278
```
  275     for fs in pairs(original) do
  276         unapply(fs)
  277     end
  278     -- 1.1.6 (the owner's b71139 list: PetActionBar / MultiBar SetShown blocked in combat):
  279     -- never call the client's own quest updaters from addon code. Classic QuestWatch_Update
  280     -- runs UIParent_ManageFramePositions, so an addon call taints the bar layout and the
  281     -- pet / action bars are blocked in the next fight. unapply above already wrote the
```
addon/WoWFA/Text.lua:874
```
  871 end
  872 
  873 -- 1.1.6 taint fix (the owner's block report: the scan named GameTooltipTextLeft7/8 and
  874 -- MultiBar6Button1.action as tainted by WoWFA). The client creates a tooltip's line strings
  875 -- on demand: AddLine past the last existing one creates NEW GLOBALS (GameTooltipTextLeftN /
  876 -- RightN). Created from our code they stay tainted for the whole session, and the action
  877 -- bars' secure tooltip code reads them in combat -> "MultiBar...:SetShown() blocked". So a
```
addon/WoWFA/Text.lua:877
```
  874 -- MultiBar6Button1.action as tainted by WoWFA). The client creates a tooltip's line strings
  875 -- on demand: AddLine past the last existing one creates NEW GLOBALS (GameTooltipTextLeftN /
  876 -- RightN). Created from our code they stay tainted for the whole session, and the action
  877 -- bars' secure tooltip code reads them in combat -> "MultiBar...:SetShown() blocked". So a
  878 -- line goes into a NAMED game tooltip only when its strings already exist; past that our
  879 -- lines go into a plain box of ours glued under the tooltip (same font), never a new global.
  880 local function can_add(tt)
```
- ok: MultiBar: 6 hits

### UIParent_ManageFramePositions

addon/WoWFA/Modules/Tracker.lua:280
```
  277     end
  278     -- 1.1.6 (the owner's b71139 list: PetActionBar / MultiBar SetShown blocked in combat):
  279     -- never call the client's own quest updaters from addon code. Classic QuestWatch_Update
  280     -- runs UIParent_ManageFramePositions, so an addon call taints the bar layout and the
  281     -- pet / action bars are blocked in the next fight. unapply above already wrote the
  282     -- original English back byte-exact; the client's next own update redraws the rest.
  283 end
```
- ok: UIParent_ManageFramePositions: 1 hits

### SetCVar

- ok: SetCVar: 0 hits

### UIPARENT_MANAGED

- ok: UIPARENT_MANAGED: 0 hits

### ActionBar

addon/WoWFA/Modules/Tracker.lua:278
```
  275     for fs in pairs(original) do
  276         unapply(fs)
  277     end
  278     -- 1.1.6 (the owner's b71139 list: PetActionBar / MultiBar SetShown blocked in combat):
  279     -- never call the client's own quest updaters from addon code. Classic QuestWatch_Update
  280     -- runs UIParent_ManageFramePositions, so an addon call taints the bar layout and the
  281     -- pet / action bars are blocked in the next fight. unapply above already wrote the
```
- ok: ActionBar: 1 hits

### SetScale

addon/WoWFA/Panel.lua:569
```
  566     panel:SetScript("OnDragStop", function(self)
  567         self:StopMovingOrSizing()
  568     end)
  569     panel:SetScale(F.db.scale or 1)
  570     UI.Glass(panel, 0.97)
  571     if UISpecialFrames then
  572         F.EscClose(panel) -- Esc closes it (never UISpecialFrames: taint, see Core)
```
addon/WoWFA/Panel.lua:912
```
  909         function(v)
  910             if v ~= F.db.scale then
  911                 F.db.scale = v
  912                 panel:SetScale(v)
  913             end
  914         end)
  915     header(PN.h_font)
```
addon/WoWFA/Panel.lua:1029
```
 1026             local ok, why = F.Room.ProfileLoad(nm)
 1027             pf_say(ok and string.format(L.pf_loaded, nm) or tostring(why))
 1028             if ok then
 1029                 panel:SetScale(F.db.scale or 1)
 1030             end
 1031             pf_redo()
 1032         end)
```
addon/WoWFA/Panel.lua:1328
```
 1325         self:SetLabel(L.btn_reset)
 1326         F:ResetDB()
 1327         F.Chat(L.en.reset)
 1328         panel:SetScale(F.db.scale or 1)
 1329         refresh()
 1330     end)
 1331     panel.reset:SetPoint("RIGHT", resetRow, "RIGHT", -4, 0)
```
addon/WoWFA/Room.lua:561
```
  558         F:Refresh()
  559     end
  560     local pf = F.PanelFrame and F.PanelFrame() -- rc36: the open window takes the loaded scale
  561     if pf and pf.SetScale then
  562         pf:SetScale(F.db.scale or 1)
  563     end
  564     F:Fire("options", "questDock")
```
addon/WoWFA/Room.lua:562
```
  559     end
  560     local pf = F.PanelFrame and F.PanelFrame() -- rc36: the open window takes the loaded scale
  561     if pf and pf.SetScale then
  562         pf:SetScale(F.db.scale or 1)
  563     end
  564     F:Fire("options", "questDock")
  565     F:Fire("options", "questAuto")
```
addon/WoWFA/Text.lua:927
```
  924     else
  925         x:SetPoint("TOPLEFT", tt, "BOTTOMLEFT", 0, 1)
  926     end
  927     pcall(x.SetScale, x, tonumber(tt.GetScale and tt:GetScale()) or 1)
  928     x:Show()
  929 end
  930 T.TipExtraLayout = extra_layout
```
- ok: SetScale: 7 hits

### UIParent

addon/WoWFA/Core.lua:146
```
  143 end
  144 
  145 -- 1.1.6 taint, the real cause (the owner's level-2 taint.log: "Execution tainted by WoWFA while
  146 -- reading global WoWFAF_Panel - UIParentPanelManager.lua:1109"): a frame name put in
  147 -- UISpecialFrames is a global WoWFA wrote, and the game's panel manager reads every name in that
  148 -- list on Esc and when a game window opens. From there the action bar layout ran tainted
  149 -- (MultiBarBottomLeft.snappedToFrame) and the bars were blocked in combat. So NO WoWFA frame is
```
addon/WoWFA/Dump.lua:105
```
  102     if not tt or not tt.SetSpellByID then
  103         return out
  104     end
  105     pcall(tt.SetOwner, tt, WorldFrame or UIParent, "ANCHOR_NONE")
  106     pcall(tt.ClearLines, tt)
  107     if not pcall(tt.SetSpellByID, tt, id) then
  108         return out
```
addon/WoWFA/Modules/Dialog.lua:157
```
  154     if pane then
  155         return pane
  156     end
  157     local f = CreateFrame("Frame", "WoWFAF_DlgPane", UIParent)
  158     f:Hide()
  159     f:SetFrameStrata("HIGH")
  160     f:SetClampedToScreen(true)
```
addon/WoWFA/Modules/Quests.lua:96
```
   93 end
   94 
   95 local function build()
   96     pane = CreateFrame("Frame", "WoWFAF_QuestPane", UIParent)
   97     pane:SetSize(PW, PH)
   98     pane:SetFrameStrata("MEDIUM")
   99     pane:SetToplevel(true)
```
addon/WoWFA/Modules/Quests.lua:156
```
  153     -- the attached "فا" button (inbox/29 B): one shared button, re-parented
  154     -- onto whichever quest frame is open; anchored INSIDE the title bar, just
  155     -- left of the host's own close button (fa_show below)
  156     faBtn = CreateFrame("Button", "WoWFAF_QuestFaBtn", UIParent)
  157     faBtn:SetSize(30, 20)
  158     faBtn:SetFrameStrata("MEDIUM")
  159     local fbg = UI.Tex(faBtn, "BACKGROUND")
```
addon/WoWFA/Modules/Quests.lua:239
```
  236     if d == 3 or not okA then
  237         local p = F.db.questPos
  238         if type(p) == "table" and type(p[1]) == "string" and tonumber(p[2]) and tonumber(p[3]) then
  239             f:SetPoint(p[1], UIParent, p[1], p[2], p[3])
  240         else
  241             f:SetPoint("CENTER", UIParent, "CENTER", 320, 40)
  242         end
```
addon/WoWFA/Modules/Quests.lua:241
```
  238         if type(p) == "table" and type(p[1]) == "string" and tonumber(p[2]) and tonumber(p[3]) then
  239             f:SetPoint(p[1], UIParent, p[1], p[2], p[3])
  240         else
  241             f:SetPoint("CENTER", UIParent, "CENTER", 320, 40)
  242         end
  243         return
  244     end
```
addon/WoWFA/Modules/Tracker.lua:280
```
  277     end
  278     -- 1.1.6 (the owner's b71139 list: PetActionBar / MultiBar SetShown blocked in combat):
  279     -- never call the client's own quest updaters from addon code. Classic QuestWatch_Update
  280     -- runs UIParent_ManageFramePositions, so an addon call taints the bar layout and the
  281     -- pet / action bars are blocked in the next fight. unapply above already wrote the
  282     -- original English back byte-exact; the client's next own update redraws the rest.
  283 end
```
addon/WoWFA/Modules/Walk.lua:453
```
  450             end
  451         end
  452     end
  453     if kind == "spell" and UIParent and UIParent.GetChildren then
  454         local okc, kids = pcall(function()
  455             return { UIParent:GetChildren() }
  456         end)
```
addon/WoWFA/Modules/Walk.lua:455
```
  452     end
  453     if kind == "spell" and UIParent and UIParent.GetChildren then
  454         local okc, kids = pcall(function()
  455             return { UIParent:GetChildren() }
  456         end)
  457         if okc then
  458             for _, k in ipairs(kids) do
```
addon/WoWFA/Modules/Zones.lua:499
```
  496 
  497 local frame
  498 local function build()
  499     frame = CreateFrame("Frame", "WoWFAF_ZoneText", UIParent)
  500     frame:SetSize(520, 80)
  501     frame:SetFrameStrata("LOW")
  502     frame:EnableMouse(false)
```
addon/WoWFA/Modules/Zones.lua:506
```
  503     if SubZoneTextString then
  504         frame:SetPoint("TOP", SubZoneTextString, "BOTTOM", 0, -8)
  505     else
  506         frame:SetPoint("TOP", UIParent, "TOP", 0, -330)
  507     end
  508     frame.kind = UI.Text(frame, 11, C.muted, "CENTER")
  509     frame.kind:SetPoint("TOP", frame, "TOP", 0, 0)
```
addon/WoWFA/Panel.lua:554
```
  551 -- ------------------------------------------------------------------ build
  552 local function build()
  553     pcall(migrate_disp)
  554     panel = CreateFrame("Frame", "WoWFAF_Panel", UIParent)
  555     panel:Hide()
  556     panel:SetSize(W, H)
  557     panel:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
```
addon/WoWFA/Panel.lua:557
```
  554     panel = CreateFrame("Frame", "WoWFAF_Panel", UIParent)
  555     panel:Hide()
  556     panel:SetSize(W, H)
  557     panel:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
  558     panel:SetFrameStrata("DIALOG")
  559     panel:SetClampedToScreen(true)
  560     panel:EnableMouse(true)
```
addon/WoWFA/Text.lua:565
```
  562 -- inbox/27: the measurer is created at LOAD (never in combat) so that the
  563 -- in-place path, which can run while the player is in combat, only ever
  564 -- touches font-string text.
  565 measure = CreateFrame("Frame", nil, UIParent)
  566 measure:SetSize(10, 10)
  567 measure:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", -400, -400)
  568 measure = measure:CreateFontString(nil, "ARTWORK")
```
addon/WoWFA/Text.lua:567
```
  564 -- touches font-string text.
  565 measure = CreateFrame("Frame", nil, UIParent)
  566 measure:SetSize(10, 10)
  567 measure:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", -400, -400)
  568 measure = measure:CreateFontString(nil, "ARTWORK")
  569 measure:SetWordWrap(false)
  570 measure:SetAlpha(0)
```
addon/WoWFA/Text.lua:935
```
  932 local function extra_add(tt, text, color, size)
  933     local x = tt.wfaX
  934     if not x then
  935         x = CreateFrame("Frame", nil, UIParent)
  936         x:SetFrameStrata("TOOLTIP")
  937         local bg = x:CreateTexture(nil, "BACKGROUND")
  938         bg:SetAllPoints()
```
addon/WoWFA/UI.lua:477
```
  474 
  475 function F.Toast(msg)
  476     if not toast then
  477         toast = CreateFrame("Button", "WoWFAF_Toast", UIParent)
  478         toast:SetSize(420, 40)
  479         toast:SetPoint("TOP", UIParent, "TOP", 0, -140)
  480         toast:SetFrameStrata("HIGH")
```
addon/WoWFA/UI.lua:479
```
  476     if not toast then
  477         toast = CreateFrame("Button", "WoWFAF_Toast", UIParent)
  478         toast:SetSize(420, 40)
  479         toast:SetPoint("TOP", UIParent, "TOP", 0, -140)
  480         toast:SetFrameStrata("HIGH")
  481         UI.Glass(toast, 0.9)
  482         toast.text = UI.Text(toast, 12, C.text, "CENTER")
```
tests/lua/wow_mock.lua:243
```
  240     return out
  241 end
  242 
  243 UIParent = new("Frame", "UIParent")
  244 UIParent:SetSize(1920, 1080) -- inbox/44 D: the panel clamps in UIParent units
  245 Minimap = new("Frame", "Minimap"); Minimap:SetSize(140, 140)
  246 GameTooltip = new("GameTooltip", "GameTooltip")
```
tests/lua/wow_mock.lua:244
```
  241 end
  242 
  243 UIParent = new("Frame", "UIParent")
  244 UIParent:SetSize(1920, 1080) -- inbox/44 D: the panel clamps in UIParent units
  245 Minimap = new("Frame", "Minimap"); Minimap:SetSize(140, 140)
  246 GameTooltip = new("GameTooltip", "GameTooltip")
  247 ItemRefTooltip = new("GameTooltip", "ItemRefTooltip")
```
tests/run.lua:582
```
  579 -- ------------------------------------------------------------------ world map label (zoneMap)
  580 local okMap, errMap = pcall(function()
  581     local zk = next(F.D.names.zone)
  582     local wmf = CreateFrame("Frame", "WorldMapFrame", UIParent)
  583     WorldMapFrame = wmf
  584     local lab = CreateFrame("Frame", nil, wmf)
  585     lab.Name = lab:CreateFontString(nil, "OVERLAY")
```
tests/run.lua:833
```
  830 local okGu, errGu = pcall(function()
  831     local G = F.GameUI
  832     check("gameui: the module loaded", type(G) == "table" and type(G.Try) == "function")
  833     local host = CreateFrame("Frame", "ZzGameUiHost", UIParent)
  834     local fs = host:CreateFontString(nil, "OVERLAY")
  835     fs:SetText("Reputation")
  836     check("gameui: a known window text turns Persian", G.Try(fs) == true and non_ascii(fs:GetText()), fs:GetText())
```
tests/run.lua:1028
```
 1025 end)
 1026 check("panel v4 tests ran", okV4, errV4)
 1027 local okTx, errTx = pcall(function()
 1028     local zt = CreateFrame("GameTooltip", "ZzTaintTip", UIParent, "GameTooltipTemplate")
 1029     zt:AddLine("Zz first line")
 1030     F.T.TipLine(zt, "این یک خط فارسی بلند برای آزمودن تولتیپ است که باید زیر آن بیاید", F.C.text)
 1031     check("taint: WoWFA creates no new tooltip line global", _G["ZzTaintTipTextLeft2"] == nil and zt:NumLines() == 1, zt:NumLines())
```
- ok: UIParent: 24 hits
