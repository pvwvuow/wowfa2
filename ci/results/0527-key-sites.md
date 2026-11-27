## task 0527-key-sites (script)

**GREEN**


### EnableKeyboard

addon/WoWFA/Core.lua:166
```
  160     end
  161     local function pass(self)
  162         if free() then
  163             pcall(self.SetPropagateKeyboardInput, self, true)
  164         end
  165     end
  166     pcall(f.EnableKeyboard, f, true)
  167     pass(f)
  168     pcall(f.HookScript, f, "OnShow", pass)
  169     pcall(f.HookScript, f, "OnKeyDown", function(self, key)
  170         if key == "ESCAPE" then
  171             if free() then
  172                 pcall(self.SetPropagateKeyboardInput, self, false)
```
- ok: EnableKeyboard: 1 hits

### PropagateKeyboardInput

addon/WoWFA/Core.lua:152
```
  146 -- reading global WoWFAF_Panel - UIParentPanelManager.lua:1109"): a frame name put in
  147 -- UISpecialFrames is a global WoWFA wrote, and the game's panel manager reads every name in that
  148 -- list on Esc and when a game window opens. From there the action bar layout ran tainted
  149 -- (MultiBarBottomLeft.snappedToFrame) and the bars were blocked in combat. So NO WoWFA frame is
  150 -- in UISpecialFrames: the frame takes Esc itself. Out of combat it keeps the key (the game menu
  151 -- does not open too); in combat it only closes and the key goes on to the game, because
  152 -- SetPropagateKeyboardInput is protected there.
  153 function F.EscClose(f)
  154     if not f or f.wfaEsc then
  155         return
  156     end
  157     f.wfaEsc = true
  158     local function free()
```
addon/WoWFA/Core.lua:163
```
  157     f.wfaEsc = true
  158     local function free()
  159         return not (InCombatLockdown and InCombatLockdown())
  160     end
  161     local function pass(self)
  162         if free() then
  163             pcall(self.SetPropagateKeyboardInput, self, true)
  164         end
  165     end
  166     pcall(f.EnableKeyboard, f, true)
  167     pass(f)
  168     pcall(f.HookScript, f, "OnShow", pass)
  169     pcall(f.HookScript, f, "OnKeyDown", function(self, key)
```
addon/WoWFA/Core.lua:172
```
  166     pcall(f.EnableKeyboard, f, true)
  167     pass(f)
  168     pcall(f.HookScript, f, "OnShow", pass)
  169     pcall(f.HookScript, f, "OnKeyDown", function(self, key)
  170         if key == "ESCAPE" then
  171             if free() then
  172                 pcall(self.SetPropagateKeyboardInput, self, false)
  173                 if C_Timer and C_Timer.After then
  174                     C_Timer.After(0, function()
  175                         pass(self)
  176                     end)
  177                 end
  178             end
```
- ok: PropagateKeyboardInput: 3 hits

### function F.EscClose

addon/WoWFA/Core.lua:153
```
  147 -- UISpecialFrames is a global WoWFA wrote, and the game's panel manager reads every name in that
  148 -- list on Esc and when a game window opens. From there the action bar layout ran tainted
  149 -- (MultiBarBottomLeft.snappedToFrame) and the bars were blocked in combat. So NO WoWFA frame is
  150 -- in UISpecialFrames: the frame takes Esc itself. Out of combat it keeps the key (the game menu
  151 -- does not open too); in combat it only closes and the key goes on to the game, because
  152 -- SetPropagateKeyboardInput is protected there.
  153 function F.EscClose(f)
  154     if not f or f.wfaEsc then
  155         return
  156     end
  157     f.wfaEsc = true
  158     local function free()
  159         return not (InCombatLockdown and InCombatLockdown())
```
- ok: function F.EscClose: 1 hits

### UISpecialFrames

addon/WoWFA/Core.lua:147
```
  141     qcache[raw] = out
  142     return out
  143 end
  144 
  145 -- 1.1.6 taint, the real cause (the owner's level-2 taint.log: "Execution tainted by WoWFA while
  146 -- reading global WoWFAF_Panel - UIParentPanelManager.lua:1109"): a frame name put in
  147 -- UISpecialFrames is a global WoWFA wrote, and the game's panel manager reads every name in that
  148 -- list on Esc and when a game window opens. From there the action bar layout ran tainted
  149 -- (MultiBarBottomLeft.snappedToFrame) and the bars were blocked in combat. So NO WoWFA frame is
  150 -- in UISpecialFrames: the frame takes Esc itself. Out of combat it keeps the key (the game menu
  151 -- does not open too); in combat it only closes and the key goes on to the game, because
  152 -- SetPropagateKeyboardInput is protected there.
  153 function F.EscClose(f)
```
addon/WoWFA/Core.lua:150
```
  144 
  145 -- 1.1.6 taint, the real cause (the owner's level-2 taint.log: "Execution tainted by WoWFA while
  146 -- reading global WoWFAF_Panel - UIParentPanelManager.lua:1109"): a frame name put in
  147 -- UISpecialFrames is a global WoWFA wrote, and the game's panel manager reads every name in that
  148 -- list on Esc and when a game window opens. From there the action bar layout ran tainted
  149 -- (MultiBarBottomLeft.snappedToFrame) and the bars were blocked in combat. So NO WoWFA frame is
  150 -- in UISpecialFrames: the frame takes Esc itself. Out of combat it keeps the key (the game menu
  151 -- does not open too); in combat it only closes and the key goes on to the game, because
  152 -- SetPropagateKeyboardInput is protected there.
  153 function F.EscClose(f)
  154     if not f or f.wfaEsc then
  155         return
  156     end
```
addon/WoWFA/Modules/Quests.lua:117
```
  111         if F.db.questDock == 3 then
  112             save_pos()
  113         end
  114     end)
  115     UI.Glass(pane)
  116     -- ESC closes the pane (inbox/29 B)
  117     F.EscClose(pane) -- never UISpecialFrames (taint, see Core)
  118     pane.title = UI.Text(pane, 15, C.gold)
  119     pane.title:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -PAD, -12)
  120     pane.title:SetWidth(PW - PAD * 2)
  121     pane.banner = UI.Text(pane, 10, C.orange)
  122     pane.banner:SetPoint("TOPRIGHT", pane.title, "BOTTOMRIGHT", 0, -4)
  123     pane.banner:SetWidth(PW - PAD * 2)
```
addon/WoWFA/Panel.lua:877
```
  871     end)
  872     panel:SetScript("OnDragStop", function(self)
  873         self:StopMovingOrSizing()
  874     end)
  875     panel:SetScale(F.db.scale or 1)
  876     UI.Glass(panel, 0.97)
  877     if UISpecialFrames then
  878         F.EscClose(panel) -- Esc closes it (never UISpecialFrames: taint, see Core)
  879     end
  880 
  881     local title = UI.Latin(panel, 20, C.gold, "LEFT")
  882     title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -14)
  883     title:SetText("WoWFA")
```
addon/WoWFA/Panel.lua:878
```
  872     panel:SetScript("OnDragStop", function(self)
  873         self:StopMovingOrSizing()
  874     end)
  875     panel:SetScale(F.db.scale or 1)
  876     UI.Glass(panel, 0.97)
  877     if UISpecialFrames then
  878         F.EscClose(panel) -- Esc closes it (never UISpecialFrames: taint, see Core)
  879     end
  880 
  881     local title = UI.Latin(panel, 20, C.gold, "LEFT")
  882     title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -14)
  883     title:SetText("WoWFA")
  884     local ver = UI.Latin(panel, 11, C.muted, "LEFT")
```
tests/lua/wow_mock.lua:262
```
  256 end
  257 QuestFrame = new("Frame", "QuestFrame"); QuestFrame:SetSize(384, 512); QuestFrame._shown = false
  258 QuestLogFrame = new("Frame", "QuestLogFrame"); QuestLogFrame:SetSize(384, 512); QuestLogFrame._shown = false
  259 SubZoneTextString = new("FontString", "SubZoneTextString")
  260 MinimapZoneTextButton = new("Button", "MinimapZoneTextButton")
  261 DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) print("CHAT: " .. m:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end }
  262 UISpecialFrames = {}
  263 SlashCmdList = {}
  264 function GameTooltip.SetTalent() end
  265 -- 96 B: the spell tooltip path. SetSpellByID builds the live tooltip (the game
  266 -- fills it from C_Spell.GetSpellDescription), then the secure hook translates.
  267 -- Tests seed MOCK.spellDesc[id] = { name, description... } - the live EN lines
  268 -- exactly as the client shows them (one description string per line, both
```
tests/run.lua:727
```
  721     local PF = F.PanelFrame and F.PanelFrame()
  722     check("panel built + shown", PF and PF:IsShown())
  723     if not PF then
  724         return
  725     end
  726     local esc = false
  727     for _, n in ipairs(UISpecialFrames) do
  728         if n == "WoWFAF_Panel" then
  729             esc = true
  730         end
  731     end
  732     check("panel closes on Esc by its own key, never UISpecialFrames (taint)", (not esc) and F.PanelFrame().wfaEsc == true)
  733 do
```
tests/run.lua:732
```
  726     local esc = false
  727     for _, n in ipairs(UISpecialFrames) do
  728         if n == "WoWFAF_Panel" then
  729             esc = true
  730         end
  731     end
  732     check("panel closes on Esc by its own key, never UISpecialFrames (taint)", (not esc) and F.PanelFrame().wfaEsc == true)
  733 do
  734     local hit = false
  735     for _, n in ipairs(UISpecialFrames) do
  736         if type(n) == "string" and string.find(n, "^WoWFA") then
  737             hit = true
  738         end
```
tests/run.lua:735
```
  729             esc = true
  730         end
  731     end
  732     check("panel closes on Esc by its own key, never UISpecialFrames (taint)", (not esc) and F.PanelFrame().wfaEsc == true)
  733 do
  734     local hit = false
  735     for _, n in ipairs(UISpecialFrames) do
  736         if type(n) == "string" and string.find(n, "^WoWFA") then
  737             hit = true
  738         end
  739     end
  740     check("no WoWFA frame name in UISpecialFrames (the panel manager reads them: taint)", not hit)
  741     local pf = F.PanelFrame()
```
tests/run.lua:740
```
  734     local hit = false
  735     for _, n in ipairs(UISpecialFrames) do
  736         if type(n) == "string" and string.find(n, "^WoWFA") then
  737             hit = true
  738         end
  739     end
  740     check("no WoWFA frame name in UISpecialFrames (the panel manager reads them: taint)", not hit)
  741     local pf = F.PanelFrame()
  742     local was = pf:IsShown()
  743     pf:Show()
  744     local kd = pf:GetScript("OnKeyDown")
  745     if kd then
  746         kd(pf, "ESCAPE")
```
- ok: UISpecialFrames: 10 hits

### MODIFIER_STATE

addon/WoWFA/Modules/Dialog.lua:379
```
  373     end
  374 end
  375 
  376 F:On("GOSSIP_SHOW", nil, safe(on_gossip))
  377 F:On("QUEST_GREETING", nil, safe(on_greeting))
  378 F:On("ITEM_TEXT_READY", nil, safe(on_book))
  379 F:On("MODIFIER_STATE_CHANGED", nil, safe(on_modifier))
  380 for _, e in ipairs({ "GOSSIP_CLOSED", "QUEST_DETAIL", "QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_FINISHED" }) do
  381     F:On(e, nil, safe(function()
  382         hide("g")
  383     end))
  384 end
  385 F:On("ITEM_TEXT_CLOSED", nil, safe(function()
```
- ok: MODIFIER_STATE: 1 hits
