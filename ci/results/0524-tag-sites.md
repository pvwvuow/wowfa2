## task 0524-tag-sites (script)

**GREEN**


### newSeen

addon/WoWFA/CombatWatch.lua:13
```
   11 -- saved keys that change by themselves (counters, logs): not a setting
   12 local SKIP = { miss = true, missN = true, missV = true, errors = true, profiles = true, combatDiff = true,
   13     newSeen = true, harvest = true, lastBuild = true, lastVersion = true }
   14 local CVARS = { "uiScale", "useUiScale", "chatStyle", "UnitNameOwn", "nameplateShowEnemies", "Sound_EnableAllSound" }
   15 
```
addon/WoWFA/Panel.lua:38
```
   36 -- 1.2.0: "new" tags (the owner 27 Nov: a New tag on top of a section that is new). A page in
   37 -- NEW_PAGES shows a small orange pill in the side menu until the player has opened it once
   38 -- (db.newSeen[page] = NEWREL), and header(text, true) puts the same pill at the left end of a
   39 -- header. The next release removes the entries and the `true` flags.
   40 local NEWREL = "1.2.0"
```
addon/WoWFA/Panel.lua:59
```
   57 
   58 local function new_seen(id)
   59     local s = F.db and F.db.newSeen
   60     return type(s) == "table" and s[id] == NEW_PAGES[id]
   61 end
```
addon/WoWFA/Panel.lua:399
```
  397     active = id
  398     if NEW_PAGES[id] and F.db then
  399         if type(F.db.newSeen) ~= "table" then
  400             F.db.newSeen = {}
  401         end
```
addon/WoWFA/Panel.lua:400
```
  398     if NEW_PAGES[id] and F.db then
  399         if type(F.db.newSeen) ~= "table" then
  400             F.db.newSeen = {}
  401         end
  402         F.db.newSeen[id] = NEW_PAGES[id]
```
addon/WoWFA/Panel.lua:402
```
  400             F.db.newSeen = {}
  401         end
  402         F.db.newSeen[id] = NEW_PAGES[id]
  403         local nb = navbtns[id]
  404         if nb and nb.newPill then
```
tests/run.lua:885
```
  883     check("new tag: the game page has its pill in the side menu until it is opened", pill0 ~= nil and pill0:IsShown())
  884     F.OpenPanel("game")
  885     check("new tag: opening the page hides the pill for good", pill0 ~= nil and not pill0:IsShown() and F.db.newSeen and F.db.newSeen.game == "1.2.2")
  886     local PF = F.PanelFrame()
  887     check("gameui: the switch is on the game windows page", PF and PF.gameUi ~= nil)
```
- ok: newSeen: 7 hits

### newPill

addon/WoWFA/Panel.lua:171
```
  169         local pill = new_pill(hd)
  170         pill:SetPoint("LEFT", hd, "LEFT", 2, 3)
  171         hd.newPill = pill
  172     end
  173     place(hd, 28, 6)
```
addon/WoWFA/Panel.lua:404
```
  402         F.db.newSeen[id] = NEW_PAGES[id]
  403         local nb = navbtns[id]
  404         if nb and nb.newPill then
  405             nb.newPill:Hide()
  406         end
```
addon/WoWFA/Panel.lua:405
```
  403         local nb = navbtns[id]
  404         if nb and nb.newPill then
  405             nb.newPill:Hide()
  406         end
  407     end
```
addon/WoWFA/Panel.lua:890
```
  888                 pill:Show()
  889             end
  890             b.newPill = pill
  891         end
  892         navbtns[id] = b
```
tests/run.lua:882
```
  880     F.OpenPanel("spellbook")
  881     local pf0 = F.PanelFrame()
  882     local pill0 = pf0 and pf0.nav and pf0.nav.game and pf0.nav.game.newPill
  883     check("new tag: the game page has its pill in the side menu until it is opened", pill0 ~= nil and pill0:IsShown())
  884     F.OpenPanel("game")
```
- ok: newPill: 5 hits

### NEW_PAGES

addon/WoWFA/Panel.lua:37
```
   35 
   36 -- 1.2.0: "new" tags (the owner 27 Nov: a New tag on top of a section that is new). A page in
   37 -- NEW_PAGES shows a small orange pill in the side menu until the player has opened it once
   38 -- (db.newSeen[page] = NEWREL), and header(text, true) puts the same pill at the left end of a
   39 -- header. The next release removes the entries and the `true` flags.
```
addon/WoWFA/Panel.lua:41
```
   39 -- header. The next release removes the entries and the `true` flags.
   40 local NEWREL = "1.2.0"
   41 local NEW_PAGES = { game = "1.2.2", spellbook = "1.2.1", health = "1.2.2" } -- page -> the release that made it new
   42 
   43 local function new_pill(parent)
```
addon/WoWFA/Panel.lua:60
```
   58 local function new_seen(id)
   59     local s = F.db and F.db.newSeen
   60     return type(s) == "table" and s[id] == NEW_PAGES[id]
   61 end
   62 
```
addon/WoWFA/Panel.lua:398
```
  396     sf:ScrollTo(0)
  397     active = id
  398     if NEW_PAGES[id] and F.db then
  399         if type(F.db.newSeen) ~= "table" then
  400             F.db.newSeen = {}
```
addon/WoWFA/Panel.lua:402
```
  400             F.db.newSeen = {}
  401         end
  402         F.db.newSeen[id] = NEW_PAGES[id]
  403         local nb = navbtns[id]
  404         if nb and nb.newPill then
```
addon/WoWFA/Panel.lua:882
```
  880         mark:Hide()
  881         b.mark = mark
  882         if NEW_PAGES[id] then
  883             local pill = new_pill(b)
  884             pill:SetPoint("LEFT", b, "LEFT", 4, 0)
```
- ok: NEW_PAGES: 6 hits

### new_tag

addon/WoWFA/Locale_Panel.lua:134
```
  132     update_opt = { fa("فقط خبر بده"), fa("بخش~های حساس خاموش"), fa("همه خاموش") },
  133     -- 1.2.0
  134     new_tag = fa("جدید"),
  135     h_gwin = fa("هر دسته از پنجره~ها"),
  136     gu_menu = fa("منوی بازی، ماکرو و ساعت"),
```
addon/WoWFA/Panel.lua:53
```
   51     local tx = UI.Text(f, 11, oc, "CENTER")
   52     tx:SetPoint("CENTER", f, "CENTER", 0, 0)
   53     tx:SetFa(PN.new_tag or " ", 32)
   54     f.text = tx
   55     return f
```
- ok: new_tag: 2 hits

### wfaEye

addon/WoWFA/Modules/Preview.lua:864
```
  862     vl:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", F.PREVIEW_W + 2, 14)
  863     P.pane = pane
  864     -- the eyes: exactly the rows the panel marked (row.wfaEye = the sample that changes with it)
  865     for _, row in ipairs(panel.allRows or {}) do
  866         if type(row) == "table" and row.wfaEye and S[row.wfaEye] then
```
addon/WoWFA/Modules/Preview.lua:866
```
  864     -- the eyes: exactly the rows the panel marked (row.wfaEye = the sample that changes with it)
  865     for _, row in ipairs(panel.allRows or {}) do
  866         if type(row) == "table" and row.wfaEye and S[row.wfaEye] then
  867             eye(row, row.wfaEye)
  868         end
```
addon/WoWFA/Modules/Preview.lua:867
```
  865     for _, row in ipairs(panel.allRows or {}) do
  866         if type(row) == "table" and row.wfaEye and S[row.wfaEye] then
  867             eye(row, row.wfaEye)
  868         end
  869     end
```
addon/WoWFA/Panel.lua:11
```
    9 --   * a short label that says WHERE it shows; a one-line note only when the label can not.
   10 --   * an eye (Modules/Preview.lua) only on a row whose sample really changes with it:
   11 --     row.wfaEye = the sample id, row.wfaSec = the spell section the sample draws.
   12 -- No Persian literal in this file (every string lives in the Locale files, L.PN = Locale_Panel);
   13 -- plain (insecure) frames only, so it opens in combat; a build error is logged, never thrown.
```
addon/WoWFA/Panel.lua:452
```
  450     local t = UI.Toggle(page.child, PW - 16, label, desc, get, set)
  451     t.dimOnMaster = true
  452     t.wfaEye = eye
  453     return place(t, desc and 50 or 32, 2)
  454 end
```
addon/WoWFA/Panel.lua:459
```
  457     local c = dimmable(UI.Choice(page.child, PW - 16, label, desc, labels, get, set))
  458     c.dimOnMaster = true
  459     c.wfaEye = eye
  460     return place(c, desc and 50 or 32, 2)
  461 end
```
addon/WoWFA/Panel.lua:930
```
  928     end
  929     pr.dimOnMaster = true
  930     pr.wfaEye = "text"
  931     panel.preset = place(dimmable(pr), 50, 4)
  932     header(PN.h_words)
```
addon/WoWFA/Panel.lua:1257
```
 1255         row.dimOnMaster = true
 1256         row.dimIf = col_off
 1257         row.wfaEye = "text"
 1258         row.wfaHi = fam
 1259         row:Update()
```
addon/WoWFA/Panel.lua:1682
```
 1680     end_page()
 1681 
 1682     -- the live preview column + an eye on every row that has a sample (row.wfaEye)
 1683     if F.PreviewAttach then
 1684         local okp, errp = pcall(F.PreviewAttach, panel)
```
tests/run.lua:1072
```
 1070     local n, bad = 0, {}
 1071     for _, r in ipairs(PF.allRows or {}) do
 1072         if r.wfaEye then
 1073             n = n + 1
 1074             if not (r.eye and P.SAMPLES[r.wfaEye]) then
```
tests/run.lua:1074
```
 1072         if r.wfaEye then
 1073             n = n + 1
 1074             if not (r.eye and P.SAMPLES[r.wfaEye]) then
 1075                 bad[#bad + 1] = tostring(r.wfaEye)
 1076             end
```
tests/run.lua:1075
```
 1073             n = n + 1
 1074             if not (r.eye and P.SAMPLES[r.wfaEye]) then
 1075                 bad[#bad + 1] = tostring(r.wfaEye)
 1076             end
 1077         end
```
tests/run.lua:1168
```
 1166     local icons, eyes = 0, 0
 1167     for _, r in ipairs((PF and PF.allRows) or {}) do
 1168         if r.wfaEye then
 1169             eyes = eyes + 1
 1170             if r.wfaIcon then
```
- ok: wfaEye: 13 hits

### SAMPLES

addon/WoWFA/Modules/Preview.lua:195
```
  193 -- ------------------------------------------------------------ the samples
  194 local S = {}
  195 P.SAMPLES = S
  196 
  197 S.zone = {
```
tests/run.lua:1027
```
 1025     F.Room.Set("namesZone", wasZ)
 1026     local errs = #(F.db.errors or {})
 1027     for id in pairs(P.SAMPLES) do
 1028         P.Show(id, nil)
 1029     end
```
tests/run.lua:1074
```
 1072         if r.wfaEye then
 1073             n = n + 1
 1074             if not (r.eye and P.SAMPLES[r.wfaEye]) then
 1075                 bad[#bad + 1] = tostring(r.wfaEye)
 1076             end
```
- ok: SAMPLES: 3 hits
