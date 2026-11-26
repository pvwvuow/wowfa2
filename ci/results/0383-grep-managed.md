## task 0383-grep-managed (script)

**GREEN**


### ObjectiveTracker

addon/WoWFA/Core.lua:970
```
  969         -- (lane 28 builds its quest surfaces from exactly this answer)
  970         local names = { "QuestWatchFrame", "QuestWatch_Update", "WatchFrame", "ObjectiveTrackerFrame",
  971             "QuestLogFrame", "QuestMapFrame", "GossipFrame", "ZoneTextString", "SubZoneTextString",
```
addon/WoWFA/Modules/Tracker.lua:11
```
   10 --   era 2    WatchFrame         WatchFrame_Update + the same line pattern
   11 --   modern   ObjectiveTrackerFrame (quest module Update + block header/lines)
   12 --   quest log   QuestLogFrame buttons QuestLogTitle%d (QUEST_LOG_UPDATE)
```
addon/WoWFA/Modules/Tracker.lua:44
```
   43     -- no GetQuestLogTitle (C_QuestLog.GetInfo instead) and its quest list sits under the map
   44     local frames = QuestWatchFrame ~= nil or WatchFrame ~= nil or ObjectiveTrackerFrame ~= nil
   45         or QuestLogFrame ~= nil or QuestMapFrame ~= nil or WorldMapFrame ~= nil or C_QuestLog ~= nil
```
addon/WoWFA/Modules/Tracker.lua:492
```
  491 
  492 -- modern: ObjectiveTrackerFrame blocks (block.id = questID, .HeaderText, .lines)
  493 local function update_modern()
```
addon/WoWFA/Modules/Tracker.lua:500
```
  499     end
  500     local otf = ObjectiveTrackerFrame
  501     if not otf or not otf.blocks then
```
addon/WoWFA/Modules/Tracker.lua:599
```
  598     end
  599     -- modern: the global ObjectiveTracker_Update and the quest module Update
  600     if type(_G["ObjectiveTracker_Update"]) == "function" then
```
addon/WoWFA/Modules/Tracker.lua:600
```
  599     -- modern: the global ObjectiveTracker_Update and the quest module Update
  600     if type(_G["ObjectiveTracker_Update"]) == "function" then
  601         hooksecurefunc("ObjectiveTracker_Update", F:Wrap("tracker", update_modern))
```
addon/WoWFA/Modules/Tracker.lua:601
```
  600     if type(_G["ObjectiveTracker_Update"]) == "function" then
  601         hooksecurefunc("ObjectiveTracker_Update", F:Wrap("tracker", update_modern))
  602     end
```
addon/WoWFA/Modules/Tracker.lua:603
```
  602     end
  603     local otf = ObjectiveTrackerFrame
  604     if otf and otf.Modules then
```
addon/WoWFA/Modules/Walk.lua:430
```
  429 
  430 local QUEST_ROOTS = { "WorldMapFrame", "QuestMapFrame", "QuestLogFrame", "ObjectiveTrackerFrame", "QuestWatchFrame", "WatchFrame" }
  431 -- 1.1.0: the Questie quest tracker (its own frames), walked only while the Questie switch is on
```
tests/lua/wow_mock.lua:390
```
  389 MOCK.watchLines = {}     -- QuestWatchLine%d contents (re-set by the client updates)
  390 MOCK.otfBlocks = {}      -- ObjectiveTrackerFrame blocks { id, header, lines }
  391 MOCK.logList = {}        -- GetQuestLogTitle(i) entries { title, isHeader, id }
```
tests/lua/wow_mock.lua:401
```
  400 WatchFrame = new("Frame", "WatchFrame"); WatchFrame._shown = false
  401 ObjectiveTrackerFrame = new("Frame", "ObjectiveTrackerFrame"); ObjectiveTrackerFrame._shown = false
  402 ObjectiveTrackerFrame.blocks = {}
```
tests/lua/wow_mock.lua:402
```
  401 ObjectiveTrackerFrame = new("Frame", "ObjectiveTrackerFrame"); ObjectiveTrackerFrame._shown = false
  402 ObjectiveTrackerFrame.blocks = {}
  403 ObjectiveTrackerFrame.Modules = { { id = "quest", Update = function() MOCK_SetOTF(MOCK.otfBlocks) end } }
```
tests/lua/wow_mock.lua:403
```
  402 ObjectiveTrackerFrame.blocks = {}
  403 ObjectiveTrackerFrame.Modules = { { id = "quest", Update = function() MOCK_SetOTF(MOCK.otfBlocks) end } }
  404 local watchCreated, gossipCreated = 0, 0
```
tests/lua/wow_mock.lua:417
```
  416     MOCK.otfBlocks = blocks or {}
  417     ObjectiveTrackerFrame.blocks = {}
  418     for i, b in ipairs(MOCK.otfBlocks) do
```
tests/lua/wow_mock.lua:427
```
  426         end
  427         ObjectiveTrackerFrame.blocks[i] = { id = b.id, HeaderText = header, lines = lines }
  428     end
```
tests/run.lua:916
```
  915     local keep = {}
  916     for _, n in ipairs({ "QuestWatch_Update", "WatchFrame_Update", "ObjectiveTracker_Update", "QuestMapFrame_UpdateAll",
  917         "QuestLogQuests_Update", "CompactUnitFrame_UpdateName", "ShowUIPanel", "HideUIPanel" }) do
```
tests/run.lua:927
```
  926     end
  927     for _, n in ipairs({ "QuestWatch_Update", "WatchFrame_Update", "ObjectiveTracker_Update", "QuestMapFrame_UpdateAll",
  928         "QuestLogQuests_Update", "CompactUnitFrame_UpdateName", "ShowUIPanel", "HideUIPanel" }) do
```
- ok: ObjectiveTracker: 18 hits

### QuestWatchFrame

addon/WoWFA/Core.lua:970
```
  969         -- (lane 28 builds its quest surfaces from exactly this answer)
  970         local names = { "QuestWatchFrame", "QuestWatch_Update", "WatchFrame", "ObjectiveTrackerFrame",
  971             "QuestLogFrame", "QuestMapFrame", "GossipFrame", "ZoneTextString", "SubZoneTextString",
```
addon/WoWFA/Modules/Tracker.lua:9
```
    8 -- Surfaces:
    9 --   classic  QuestWatchFrame    QuestWatch_Update + QuestWatchLine%d
   10 --   era 2    WatchFrame         WatchFrame_Update + the same line pattern
```
addon/WoWFA/Modules/Tracker.lua:44
```
   43     -- no GetQuestLogTitle (C_QuestLog.GetInfo instead) and its quest list sits under the map
   44     local frames = QuestWatchFrame ~= nil or WatchFrame ~= nil or ObjectiveTrackerFrame ~= nil
   45         or QuestLogFrame ~= nil or QuestMapFrame ~= nil or WorldMapFrame ~= nil or C_QuestLog ~= nil
```
addon/WoWFA/Modules/Tracker.lua:411
```
  410 
  411 -- classic / era-2: QuestWatchLine%d under QuestWatchFrame or WatchFrame
  412 local function watch_frames(root)
```
addon/WoWFA/Modules/Tracker.lua:433
```
  432     rebuild_titles()
  433     local frames = watch_frames(QuestWatchFrame or WatchFrame)
  434     if #frames == 0 then
```
addon/WoWFA/Modules/Walk.lua:430
```
  429 
  430 local QUEST_ROOTS = { "WorldMapFrame", "QuestMapFrame", "QuestLogFrame", "ObjectiveTrackerFrame", "QuestWatchFrame", "WatchFrame" }
  431 -- 1.1.0: the Questie quest tracker (its own frames), walked only while the Questie switch is on
```
tests/lua/wow_mock.lua:399
```
  398 WorldMapFrameAreaLabel = new("FontString", "WorldMapFrameAreaLabel")
  399 QuestWatchFrame = new("Frame", "QuestWatchFrame"); QuestWatchFrame._shown = false
  400 WatchFrame = new("Frame", "WatchFrame"); WatchFrame._shown = false
```
- ok: QuestWatchFrame: 7 hits

### WatchFrame

addon/WoWFA/Core.lua:970
```
  969         -- (lane 28 builds its quest surfaces from exactly this answer)
  970         local names = { "QuestWatchFrame", "QuestWatch_Update", "WatchFrame", "ObjectiveTrackerFrame",
  971             "QuestLogFrame", "QuestMapFrame", "GossipFrame", "ZoneTextString", "SubZoneTextString",
```
addon/WoWFA/Modules/Tracker.lua:9
```
    8 -- Surfaces:
    9 --   classic  QuestWatchFrame    QuestWatch_Update + QuestWatchLine%d
   10 --   era 2    WatchFrame         WatchFrame_Update + the same line pattern
```
addon/WoWFA/Modules/Tracker.lua:10
```
    9 --   classic  QuestWatchFrame    QuestWatch_Update + QuestWatchLine%d
   10 --   era 2    WatchFrame         WatchFrame_Update + the same line pattern
   11 --   modern   ObjectiveTrackerFrame (quest module Update + block header/lines)
```
addon/WoWFA/Modules/Tracker.lua:44
```
   43     -- no GetQuestLogTitle (C_QuestLog.GetInfo instead) and its quest list sits under the map
   44     local frames = QuestWatchFrame ~= nil or WatchFrame ~= nil or ObjectiveTrackerFrame ~= nil
   45         or QuestLogFrame ~= nil or QuestMapFrame ~= nil or WorldMapFrame ~= nil or C_QuestLog ~= nil
```
addon/WoWFA/Modules/Tracker.lua:411
```
  410 
  411 -- classic / era-2: QuestWatchLine%d under QuestWatchFrame or WatchFrame
  412 local function watch_frames(root)
```
addon/WoWFA/Modules/Tracker.lua:433
```
  432     rebuild_titles()
  433     local frames = watch_frames(QuestWatchFrame or WatchFrame)
  434     if #frames == 0 then
```
addon/WoWFA/Modules/Tracker.lua:593
```
  592 function M.install()
  593     -- classic: QuestWatch_Update global; era 2: WatchFrame_Update
  594     for _, fn in ipairs({ "QuestWatch_Update", "WatchFrame_Update" }) do
```
addon/WoWFA/Modules/Tracker.lua:594
```
  593     -- classic: QuestWatch_Update global; era 2: WatchFrame_Update
  594     for _, fn in ipairs({ "QuestWatch_Update", "WatchFrame_Update" }) do
  595         if type(_G[fn]) == "function" then
```
addon/WoWFA/Modules/Walk.lua:430
```
  429 
  430 local QUEST_ROOTS = { "WorldMapFrame", "QuestMapFrame", "QuestLogFrame", "ObjectiveTrackerFrame", "QuestWatchFrame", "WatchFrame" }
  431 -- 1.1.0: the Questie quest tracker (its own frames), walked only while the Questie switch is on
```
tests/lua/wow_mock.lua:399
```
  398 WorldMapFrameAreaLabel = new("FontString", "WorldMapFrameAreaLabel")
  399 QuestWatchFrame = new("Frame", "QuestWatchFrame"); QuestWatchFrame._shown = false
  400 WatchFrame = new("Frame", "WatchFrame"); WatchFrame._shown = false
```
tests/lua/wow_mock.lua:400
```
  399 QuestWatchFrame = new("Frame", "QuestWatchFrame"); QuestWatchFrame._shown = false
  400 WatchFrame = new("Frame", "WatchFrame"); WatchFrame._shown = false
  401 ObjectiveTrackerFrame = new("Frame", "ObjectiveTrackerFrame"); ObjectiveTrackerFrame._shown = false
```
tests/lua/wow_mock.lua:414
```
  413 function QuestWatch_Update() MOCK_SetWatchLines(MOCK.watchLines) end
  414 function WatchFrame_Update() MOCK_SetWatchLines(MOCK.watchLines) end
  415 function MOCK_SetOTF(blocks)
```
tests/run.lua:916
```
  915     local keep = {}
  916     for _, n in ipairs({ "QuestWatch_Update", "WatchFrame_Update", "ObjectiveTracker_Update", "QuestMapFrame_UpdateAll",
  917         "QuestLogQuests_Update", "CompactUnitFrame_UpdateName", "ShowUIPanel", "HideUIPanel" }) do
```
tests/run.lua:927
```
  926     end
  927     for _, n in ipairs({ "QuestWatch_Update", "WatchFrame_Update", "ObjectiveTracker_Update", "QuestMapFrame_UpdateAll",
  928         "QuestLogQuests_Update", "CompactUnitFrame_UpdateName", "ShowUIPanel", "HideUIPanel" }) do
```
- ok: WatchFrame: 14 hits

### MinimapCluster

- ok: MinimapCluster: 0 hits

### UIParent:

addon/WoWFA/Modules/Walk.lua:455
```
  454         local okc, kids = pcall(function()
  455             return { UIParent:GetChildren() }
  456         end)
```
tests/lua/wow_mock.lua:244
```
  243 UIParent = new("Frame", "UIParent")
  244 UIParent:SetSize(1920, 1080) -- inbox/44 D: the panel clamps in UIParent units
  245 Minimap = new("Frame", "Minimap"); Minimap:SetSize(140, 140)
```
- ok: UIParent:: 2 hits

### EditMode

- ok: EditMode: 0 hits

### ManagedFrame

- ok: ManagedFrame: 0 hits

### SetUserPlaced

- ok: SetUserPlaced: 0 hits

### SetParent(

addon/WoWFA/Modules/Quests.lua:215
```
  214     if host ~= faBtn:GetParent() then
  215         faBtn:SetParent(host)
  216         faBtn:SetFrameLevel(host.GetFrameLevel and (host:GetFrameLevel() + 10) or 10)
```
tests/lua/wow_mock.lua:197
```
  196 function Obj.GetParent(s) return s._parent end
  197 function Obj.SetParent(s, p) s._parent = p end -- the fā button re-parents per host
  198 function Obj.GetFrameLevel(s) return s._level or 1 end
```
- ok: SetParent(: 2 hits

### :SetScale(

addon/WoWFA/Panel.lua:569
```
  568     end)
  569     panel:SetScale(F.db.scale or 1)
  570     UI.Glass(panel, 0.97)
```
addon/WoWFA/Panel.lua:912
```
  911                 F.db.scale = v
  912                 panel:SetScale(v)
  913             end
```
addon/WoWFA/Panel.lua:1029
```
 1028             if ok then
 1029                 panel:SetScale(F.db.scale or 1)
 1030             end
```
addon/WoWFA/Panel.lua:1328
```
 1327         F.Chat(L.en.reset)
 1328         panel:SetScale(F.db.scale or 1)
 1329         refresh()
```
addon/WoWFA/Room.lua:562
```
  561     if pf and pf.SetScale then
  562         pf:SetScale(F.db.scale or 1)
  563     end
```
- ok: :SetScale(: 5 hits

### SetMovable

addon/WoWFA/Modules/Quests.lua:102
```
  101     pane:EnableMouse(true)
  102     pane:SetMovable(true)
  103     pane:RegisterForDrag("LeftButton")
```
addon/WoWFA/Panel.lua:561
```
  560     panel:EnableMouse(true)
  561     panel:SetMovable(true)
  562     panel:RegisterForDrag("LeftButton")
```
- ok: SetMovable: 2 hits

### StartMoving

addon/WoWFA/Modules/Quests.lua:106
```
  105         if F.db.questDock == 3 then
  106             self:StartMoving()
  107         end
```
addon/WoWFA/Panel.lua:564
```
  563     panel:SetScript("OnDragStart", function(self)
  564         self:StartMoving()
  565     end)
```
- ok: StartMoving: 2 hits

### PlayerFrame

- ok: PlayerFrame: 0 hits

### TargetFrame

addon/WoWFA/Modules/Npc.lua:171
```
  170     end
  171     add(_G.TargetFrameTextureFrameName)
  172     local tf = _G.TargetFrame
```
addon/WoWFA/Modules/Npc.lua:172
```
  171     add(_G.TargetFrameTextureFrameName)
  172     local tf = _G.TargetFrame
  173     if type(tf) == "table" then
```
addon/WoWFA/Modules/Npc.lua:175
```
  174         add(tf.name)
  175         local c = tf.TargetFrameContent
  176         if type(c) == "table" and type(c.TargetFrameContentMain) == "table" then
```
addon/WoWFA/Modules/Npc.lua:176
```
  175         local c = tf.TargetFrameContent
  176         if type(c) == "table" and type(c.TargetFrameContentMain) == "table" then
  177             add(c.TargetFrameContentMain.Name)
```
addon/WoWFA/Modules/Npc.lua:177
```
  176         if type(c) == "table" and type(c.TargetFrameContentMain) == "table" then
  177             add(c.TargetFrameContentMain.Name)
  178         end
```
addon/WoWFA/Modules/Npc.lua:253
```
  252     end)
  253     if type(TargetFrame_Update) == "function" then
  254         hooksecurefunc("TargetFrame_Update", F:Wrap("npc", target))
```
addon/WoWFA/Modules/Npc.lua:254
```
  253     if type(TargetFrame_Update) == "function" then
  254         hooksecurefunc("TargetFrame_Update", F:Wrap("npc", target))
  255     end
```
addon/WoWFA/Modules/Npc.lua:256
```
  255     end
  256     if type(TargetFrame) == "table" and type(TargetFrame.Update) == "function" then
  257         hooksecurefunc(TargetFrame, "Update", F:Wrap("npc", target))
```
addon/WoWFA/Modules/Npc.lua:257
```
  256     if type(TargetFrame) == "table" and type(TargetFrame.Update) == "function" then
  257         hooksecurefunc(TargetFrame, "Update", F:Wrap("npc", target))
  258     end
```
- ok: TargetFrame: 9 hits

### UIWidget

- ok: UIWidget: 0 hits

### QuestLogFrame:

tests/lua/wow_mock.lua:258
```
  257 QuestFrame = new("Frame", "QuestFrame"); QuestFrame:SetSize(384, 512); QuestFrame._shown = false
  258 QuestLogFrame = new("Frame", "QuestLogFrame"); QuestLogFrame:SetSize(384, 512); QuestLogFrame._shown = false
  259 SubZoneTextString = new("FontString", "SubZoneTextString")
```
- ok: QuestLogFrame:: 1 hits

### QuestMapFrame

addon/WoWFA/Core.lua:971
```
  970         local names = { "QuestWatchFrame", "QuestWatch_Update", "WatchFrame", "ObjectiveTrackerFrame",
  971             "QuestLogFrame", "QuestMapFrame", "GossipFrame", "ZoneTextString", "SubZoneTextString",
  972             "MinimapZoneText", "WorldMapFrame", "ItemRefShoppingTooltip1", "TooltipDataProcessor" }
```
addon/WoWFA/Modules/Quests.lua:35
```
   34 function M.api()
   35     return GetQuestID ~= nil and (QuestFrame ~= nil or QuestLogFrame ~= nil or QuestMapFrame ~= nil)
   36 end
```
addon/WoWFA/Modules/Quests.lua:52
```
   51 -- Brain review (#139): "on screen" = VISIBLE, not just the own shown flag - a
   52 -- QuestMapFrame keeps IsShown() true inside a CLOSED world map, and the pane
   53 -- would dock to (and stay on screen for) an invisible host. IsVisible is used
```
addon/WoWFA/Modules/Quests.lua:86
```
   85     local out = {}
   86     for _, name in ipairs({ "QuestFrame", "QuestLogFrame", "QuestLogDetailFrame", "QuestMapFrame" }) do
   87         local f = _G[name]
```
addon/WoWFA/Modules/Quests.lua:537
```
  536 local function log_frame()
  537     for _, name in ipairs({ "QuestLogFrame", "QuestLogDetailFrame", "QuestMapFrame" }) do
  538         local f = _G[name]
```
addon/WoWFA/Modules/Quests.lua:609
```
  608     -- rc9: the modern map quest log selects a quest through C_QuestLog.SetSelectedQuest /
  609     -- QuestMapFrame_ShowQuestDetails (none of the old functions run): re-read the
  610     -- selection right after the click AND once more a moment later (the selection
```
addon/WoWFA/Modules/Quests.lua:616
```
  615     end)
  616     for _, fn in ipairs({ "QuestMapFrame_ShowQuestDetails", "QuestMapFrame_OpenToQuestDetails",
  617         "QuestMapLogTitleButton_OnClick" }) do
```
addon/WoWFA/Modules/Tracker.lua:45
```
   44     local frames = QuestWatchFrame ~= nil or WatchFrame ~= nil or ObjectiveTrackerFrame ~= nil
   45         or QuestLogFrame ~= nil or QuestMapFrame ~= nil or WorldMapFrame ~= nil or C_QuestLog ~= nil
   46     return frames and (GetQuestLogTitle ~= nil or (C_QuestLog ~= nil and C_QuestLog.GetInfo ~= nil))
```
addon/WoWFA/Modules/Walk.lua:430
```
  429 
  430 local QUEST_ROOTS = { "WorldMapFrame", "QuestMapFrame", "QuestLogFrame", "ObjectiveTrackerFrame", "QuestWatchFrame", "WatchFrame" }
  431 -- 1.1.0: the Questie quest tracker (its own frames), walked only while the Questie switch is on
```
tests/run.lua:916
```
  915     local keep = {}
  916     for _, n in ipairs({ "QuestWatch_Update", "WatchFrame_Update", "ObjectiveTracker_Update", "QuestMapFrame_UpdateAll",
  917         "QuestLogQuests_Update", "CompactUnitFrame_UpdateName", "ShowUIPanel", "HideUIPanel" }) do
```
tests/run.lua:927
```
  926     end
  927     for _, n in ipairs({ "QuestWatch_Update", "WatchFrame_Update", "ObjectiveTracker_Update", "QuestMapFrame_UpdateAll",
  928         "QuestLogQuests_Update", "CompactUnitFrame_UpdateName", "ShowUIPanel", "HideUIPanel" }) do
```
- ok: QuestMapFrame: 11 hits

### WorldMapFrame:

- ok: WorldMapFrame:: 0 hits

### SetHeight(

addon/WoWFA/Modules/Preview.lua:121
```
  120         l:SetColorTexture(0.62, 0.62, 0.62, 0.9)
  121         l:SetHeight(1)
  122         l:SetPoint(side .. "LEFT")
```
addon/WoWFA/Modules/Preview.lua:708
```
  707             else
  708                 t:SetHeight(2)
  709             end
```
addon/WoWFA/Modules/Quests.lua:278
```
  277     end
  278     pane.scroll.child:SetHeight(math.max(y, 10))
  279     pane.scroll:UpdateBar()
```
addon/WoWFA/Modules/Quests.lua:330
```
  329     end
  330     pane.scroll.child:SetHeight(math.max(y, 10))
  331     pane.scroll:SetVerticalScroll(0)
```
addon/WoWFA/Panel.lua:110
```
  109             local h = math.max(it.h, math.ceil(need_of(it.f)))
  110             it.f:SetHeight(h)
  111             it.f:ClearAllPoints()
```
addon/WoWFA/Panel.lua:116
```
  115     end
  116     sf.child:SetHeight(-yy + 10)
  117     if sf.UpdateBar then
```
addon/WoWFA/Panel.lua:133
```
  132 local function end_page()
  133     page.child:SetHeight(-y + 10)
  134     restack(page)
```
addon/WoWFA/UI.lua:39
```
   38     else
   39         t:SetHeight(1)
   40     end
```
addon/WoWFA/UI.lua:51
```
   50     sheen:SetPoint("TOPRIGHT")
   51     sheen:SetHeight(120)
   52     sheen:SetColorTexture(1, 1, 1, 1)
```
addon/WoWFA/UI.lua:253
```
  252     local track = UI.Tex(slider, "BACKGROUND")
  253     track:SetHeight(3)
  254     track:SetPoint("LEFT", slider, "LEFT", 2, 0)
```
addon/WoWFA/UI.lua:391
```
  390         bar:ClearAllPoints()
  391         bar:SetHeight(bh)
  392         bar:SetPoint("TOPLEFT", self, "TOPLEFT", -6, -off)
```
addon/WoWFA/UI.lua:394
```
  393         thumb:ClearAllPoints()
  394         thumb:SetHeight(bh)
  395         thumb:SetPoint("TOPLEFT", self, "TOPLEFT", -11, -off)
```
addon/WoWFA/UI.lua:435
```
  434         if need > (tonumber(child:GetHeight()) or 0) + 1 then
  435             child:SetHeight(need)
  436         end
```
addon/WoWFA/UI.lua:469
```
  468     toast.text:SetFa(msg, 380)
  469     toast:SetHeight(math.max(36, toast.text:GetStringHeight() + 18))
  470     toast.t = 0
```
tests/lua/wow_mock.lua:188
```
  187 function Obj.SetWidth(s, w) s._w = w end
  188 function Obj.SetHeight(s, h) s._h = h end
  189 function Obj.GetWidth(s) return s._w end
```
- ok: SetHeight(: 15 hits

### Layout(

addon/WoWFA/Text.lua:833
```
  832         if self.wfaX and (self.wfaX.n or 0) > 0 and T.TipExtraLayout then
  833             T.TipExtraLayout(self)
  834         end
```
- ok: Layout(: 1 hits
