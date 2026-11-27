## task 0491-grep-spellpage (script)

**GREEN**


### begin_page("sizes")

addon/WoWFA/Panel.lua:1182
```
 1168         end, "spell")
 1169     panel.tlDesc.wfaSec, panel.tlDesc.showIf = "talents", own
 1170     if not own() then
 1171         panel.tlName:Hide()
 1172         panel.tlDesc:Hide()
 1173     end
 1174     -- the tests and the old ids
 1175     panel.dispTitle = { talents = panel.tlName }
 1176     panel.dispDesc = { talents = panel.tlDesc }
 1177     panel.dispCustom = { talents = panel.talentOwn }
 1178     panel.mods.spellbook, panel.mods.talents = panel.spName, panel.talentOwn
 1179     end_page()
 1180 
 1181     -- ===================================================== Font sizes
 1182     begin_page("sizes")
 1183     header(PN.h_size)
 1184     panel.fontSize = slider(PN.fontSize, 9, 20, 1,
 1185         function() return F.db.fontSize end,
 1186         function(v)
 1187             v = math.floor(v + 0.5)
 1188             if v ~= F.db.fontSize then
 1189                 F.db.fontSize = v
 1190                 if F.T and F.T.RefreshAll then
 1191                     F.T.RefreshAll()
 1192                 end
 1193                 F:Fire("options", "fontSize")
 1194             end
 1195         end)
 1196     panel.szList = pct_slider(PN.szList, "szList", 100, 70, 200)
```
- ok: begin_page("sizes"): 1 hits

### PANEL_SHIPPED = 

addon/WoWFA/Panel.lua:63
```
   49     bg:SetAllPoints()
   50     bg:SetColorTexture(oc[1], oc[2], oc[3], 0.28)
   51     local tx = UI.Text(f, 11, oc, "CENTER")
   52     tx:SetPoint("CENTER", f, "CENTER", 0, 0)
   53     tx:SetFa(PN.new_tag or " ", 32)
   54     f.text = tx
   55     return f
   56 end
   57 
   58 local function new_seen(id)
   59     local s = F.db and F.db.newSeen
   60     return type(s) == "table" and s[id] == NEWREL
   61 end
   62 
   63 F.PANEL_SHIPPED = SHIPPED
   64 F.PANEL_ROOM_KEYS = ROOM_KEYS
   65 F.PANEL_SECTIONS = SECTIONS
   66 
   67 -- v4: the presets the panel offers. "stats only" only switched item lines, and items are
   68 -- not in this version: on WoW Forever it was the same as English, so it is no choice any more
   69 -- (a saved "stats" room still works and shows as "custom").
   70 if F.Room then
   71     F.Room.PRESET_IDS = { "recommended", "fa", "story", "spells", "en" }
   72     -- the terms are plain words inside the Persian sentences (damage, pet, health): the story
   73     -- preset keeps them Persian, an English word mid-sentence read as a bug
   74     if F.Room.PRESETS and F.Room.PRESETS.story and F.Room.PRESETS.story.d then
   75         F.Room.PRESETS.story.d.terms = true
   76     end
   77     for id, s in pairs(PN.preset_lbl or {}) do
```
- ok: PANEL_SHIPPED = : 1 hits

### local SHIPPED

addon/WoWFA/Panel.lua:26
```
   12 -- No Persian literal in this file (every string lives in the Locale files, L.PN = Locale_Panel);
   13 -- plain (insecure) frames only, so it opens in combat; a build error is logged, never thrown.
   14 
   15 local F = WoWFAF
   16 local L = F.L
   17 local UI = F.UI
   18 local C = F.C
   19 local PN = L.PN or {}
   20 
   21 local W, H = 700 + (F.PREVIEW_W or 0), 600 -- the window (+ the live preview column)
   22 local NAVW = 164              -- the side menu
   23 local PW = 486                -- the scroll page width
   24 local panel, page, rows, health
   25 local pages, navbtns, active = {}, {}, nil
   26 local SHIPPED = { "quests", "tracker", "dungeons", "npc", "spellbook", "talents" }
   27 local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
   28 local SECTIONS = { "general", "quests", "map", "npc", "chat", "game", "spellbook", "sizes", "colors", "share", "health", "about" }
   29 -- the ids of the older panels still work (F.OpenPanel("health"), the tests)
   30 local ALIAS = { room = "general", mods = "general", display = "general", home = "general", welcome = "general",
   31     tracker = "quests", dialog = "npc", talents = "spellbook" }
   32 local STATE_L = { ok = "st_ok", warn = "st_warn", off = "st_off", master = "st_master", nodata = "st_nodata",
   33     schema = "st_schema", noapi = "st_noapi", update = "st_update", fault = "st_fault", locked = "st_off" }
   34 local STATE_C = { ok = "green", warn = "orange", update = "orange", fault = "red", noapi = "red", schema = "red", nodata = "red" }
   35 
   36 -- 1.2.0: "new" tags (the owner 27 Nov: a New tag on top of a section that is new). A page in
   37 -- NEW_PAGES shows a small orange pill in the side menu until the player has opened it once
   38 -- (db.newSeen[page] = NEWREL), and header(text, true) puts the same pill at the left end of a
   39 -- header. The next release removes the entries and the `true` flags.
   40 local NEWREL = "1.2.0"
```
- ok: local SHIPPED: 1 hits
