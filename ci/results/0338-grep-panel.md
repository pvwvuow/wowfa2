## task 0338-grep-panel (script)

**GREEN**


### PANEL_SECTIONS

addon/WoWFA/Panel.lua:33
```
   32 F.PANEL_ROOM_KEYS = ROOM_KEYS
   33 F.PANEL_SECTIONS = SECTIONS
   34 
```
tests/run.lua:340
```
  339     local allNav = true
  340     for _, id in ipairs(F.PANEL_SECTIONS) do
  341         if not (PF.nav and PF.nav[id]) then
```
- ok: PANEL_SECTIONS: 2 hits

### OpenPanel(

addon/WoWFA/Core.lua:940
```
  939         local page = ({ test = "display", mode = "display", errors = "health", health = "health", welcome = "welcome" })[cmd]
  940         F.OpenPanel(page)
  941     end
```
addon/WoWFA/Core.lua:949
```
  948     elseif F.OpenPanel then
  949         F.OpenPanel()
  950     end
```
addon/WoWFA/Minimap.lua:94
```
   93         elseif IsShiftKeyDown and IsShiftKeyDown() then
   94             F.OpenPanel("health")
   95         else
```
addon/WoWFA/Minimap.lua:139
```
  138         end
  139         F.OpenPanel("home")
  140     end)
```
addon/WoWFA/Panel.lua:25
```
   24 local SECTIONS = { "general", "sizes", "quests", "tracker", "map", "npc", "dialog", "spellbook", "talents", "colors", "share", "health", "about" }
   25 -- the ids of the one-page panel still work (F.OpenPanel("health") from the toast, the tests)
   26 local ALIAS = { room = "general", mods = "general", display = "general", home = "general", welcome = "general" }
```
addon/WoWFA/Panel.lua:1247
```
 1246 -- of the old one-page ids (room / mods / display = General)
 1247 function F.OpenPanel(pageId)
 1248     if not ensure() then
```
addon/WoWFA/Panel.lua:1260
```
 1259     else
 1260         F.OpenPanel()
 1261     end
```
addon/WoWFA/UI.lua:504
```
  503             if F.OpenPanel then
  504                 F.OpenPanel("health")
  505             end
```
tests/run.lua:333
```
  332     F.db.disp = nil
  333     F.OpenPanel("spellbook")
  334     RunTimers()
```
tests/run.lua:337
```
  336     check("panel opens on the asked section", F.PanelPage() == "spellbook", F.PanelPage())
  337     F.OpenPanel("room")
  338     check("old page ids map to General", F.PanelPage() == "general", F.PanelPage())
```
tests/run.lua:399
```
  398 
  399     F.OpenPanel("colors")
  400     local PF = F.PanelFrame()
```
tests/run.lua:467
```
  466     -- the panel: the NPC and Share sections
  467     F.OpenPanel("npc")
  468     check("the panel opens the NPC section", F.PanelPage() == "npc")
```
tests/run.lua:473
```
  472     check("the NPC display choice cycles", F.NpcMode() == 3, F.NpcMode())
  473     F.OpenPanel("share")
  474     RunTimers()
```
tests/run.lua:622
```
  621     check("miss kept once, counted twice", e ~= nil and e.n == 2 and F.db.missN == 1, e and e.n)
  622     F.OpenPanel("health")
  623     RunTimers()
```
tests/run.lua:697
```
  696     check("panel API", type(F.OpenPanel) == "function" and type(F.TogglePanel) == "function")
  697     F.OpenPanel()
  698     RunTimers()
```
tests/run.lua:720
```
  719     check("/wowfa opens", PF:IsShown())
  720     F.OpenPanel("health")
  721     check("open on the status section", PF:IsShown())
```
- ok: OpenPanel(: 16 hits

### PanelPage

addon/WoWFA/Panel.lua:1268
```
 1267 
 1268 function F.PanelPage()
 1269     return active
```
tests/run.lua:336
```
  335     local PF = F.PanelFrame()
  336     check("panel opens on the asked section", F.PanelPage() == "spellbook", F.PanelPage())
  337     F.OpenPanel("room")
```
tests/run.lua:338
```
  337     F.OpenPanel("room")
  338     check("old page ids map to General", F.PanelPage() == "general", F.PanelPage())
  339     local allNav = true
```
tests/run.lua:347
```
  346     Click(PF.nav.map)
  347     check("the side menu switches the section", F.PanelPage() == "map", F.PanelPage())
  348     Click(PF.dispTitle.spellbook)
```
tests/run.lua:401
```
  400     local PF = F.PanelFrame()
  401     check("colours page opens", F.PanelPage() == "colors", F.PanelPage())
  402     F.db.col = nil
```
tests/run.lua:468
```
  467     F.OpenPanel("npc")
  468     check("the panel opens the NPC section", F.PanelPage() == "npc")
  469     local PF = F.PanelFrame()
```
- ok: PanelPage: 6 hits

### sec_

addon/WoWFA/Locale.lua:161
```
  160 L.h_miss_n = "متن‌های بدون ترجمه که دیدی: %d؛ روی کادر کلیک کن، Ctrl+C و برام بفرست"
  161 L.sec_general = "عمومی"
  162 L.sec_quests = "مأموریت‌ها"
```
addon/WoWFA/Locale.lua:162
```
  161 L.sec_general = "عمومی"
  162 L.sec_quests = "مأموریت‌ها"
  163 L.sec_tracker = "ردیاب مأموریت"
```
addon/WoWFA/Locale.lua:163
```
  162 L.sec_quests = "مأموریت‌ها"
  163 L.sec_tracker = "ردیاب مأموریت"
  164 L.sec_map = "نقشه و مناطق"
```
addon/WoWFA/Locale.lua:164
```
  163 L.sec_tracker = "ردیاب مأموریت"
  164 L.sec_map = "نقشه و مناطق"
  165 L.sec_spellbook = "کتاب جادو"
```
addon/WoWFA/Locale.lua:165
```
  164 L.sec_map = "نقشه و مناطق"
  165 L.sec_spellbook = "کتاب جادو"
  166 L.sec_talents = "استعدادها"
```
addon/WoWFA/Locale.lua:166
```
  165 L.sec_spellbook = "کتاب جادو"
  166 L.sec_talents = "استعدادها"
  167 L.sec_health = "وضعیت"
```
addon/WoWFA/Locale.lua:167
```
  166 L.sec_talents = "استعدادها"
  167 L.sec_health = "وضعیت"
  168 L.sec_about = "درباره"
```
addon/WoWFA/Locale.lua:168
```
  167 L.sec_health = "وضعیت"
  168 L.sec_about = "درباره"
  169 L.g_names = "نام‌ها و واژه‌ها در متن‌ها"
```
addon/WoWFA/Locale.lua:180
```
  179 L.n_disp = "تغییر نمایش از دفعهٔ بعدی که راهنمای اسپل را می‌بینی اعمال می‌شود."
  180 L.sec_colors = "رنگ‌ها"
  181 L.col_on = "رنگی کردن نام‌ها"
```
addon/WoWFA/Locale.lua:194
```
  193     purple = "بنفش", cyan = "فیروزه‌ای", pink = "صورتی", white = "سفید", class = "رنگ رسمی کلاس" }
  194 L.sec_npc = "شخصیت‌ها (NPC)"
  195 L.sec_share = "اشتراک‌گذاری"
```
addon/WoWFA/Locale.lua:195
```
  194 L.sec_npc = "شخصیت‌ها (NPC)"
  195 L.sec_share = "اشتراک‌گذاری"
  196 L.d_npcname = "نام شخصیت‌ها بالای سرشان"
```
addon/WoWFA/Locale_Dlg.lua:4
```
    3 local L = WoWFAF_L
    4 L.sec_dialog = "گفتگو و کتاب‌ها"
    5 L.dl_intro = "حرف‌های NPCها (متن پنجرهٔ گفتگو و خوش‌آمد، حرف‌هایی که در چت و بالای سرشان می‌زنند) و متن کتاب‌ها، نامه‌ها و تابلوها. هر متنی که هنوز فارسی ندارد 
```
addon/WoWFA/Locale_Opt.lua:16
```
   15 L.fa_size = fa("اندازه فونت متن~های بازی (درصد)")
   16 L.sec_sizes = fa("اندازه فونت~ها")
   17 L.sz_intro = fa("همه اسلایدرهای اندازه اینجا هستند. هر اسلایدر فقط یک گروه از متن~ها را عوض می~کند و با اسلایدر دیگر قاطی نمی~شود.")
```
addon/WoWFA/Panel.lua:501
```
  500     for i, id in ipairs(SECTIONS) do
  501         local b = UI.Button(panel, L["sec_" .. id], NAVW - 8, 30, function()
  502             select_page(id)
```
addon/WoWFA/Panel.lua:691
```
  690     mod_toggle("quests")
  691     header(L.sec_quests)
  692     room_toggle("namesQuest")
```
addon/WoWFA/Panel.lua:724
```
  723     mod_toggle("dungeons")
  724     header(L.sec_map)
  725     room_toggle("namesZone")
```
addon/WoWFA/Panel.lua:738
```
  737     mod_toggle("npc")
  738     header(L.sec_npc)
  739     room_toggle("namesNpc")
```
addon/WoWFA/Panel.lua:763
```
  762     mod_toggle("spellbook")
  763     header(L.sec_spellbook)
  764     room_toggle("namesSpell")
```
addon/WoWFA/Panel.lua:775
```
  774     mod_toggle("talents")
  775     header(L.sec_talents)
  776     room_toggle("namesSpell", true)
```
- ok: sec_: 19 hits

### pages.

addon/WoWFA/Panel.lua:882
```
  881         refresh()
  882         if pages.share then
  883             restack(pages.share)
```
addon/WoWFA/Panel.lua:883
```
  882         if pages.share then
  883             restack(pages.share)
  884         end
```
addon/WoWFA/Panel.lua:1207
```
 1206 
 1207     panel.page = pages.general
 1208     panel:SetScript("OnShow", function()
```
- ok: pages.: 3 hits

### panel.

addon/WoWFA/Locale.lua:386
```
  385     m_spellbook = "Spellbook", m_talents = "Talents", m_capture = "Site data helper",
  386     loaded = "WoWFA %s loaded (data build %s). Type /wowfa to open the panel.",
  387     tripped = "WoWFA: '%s' turned itself off after repeated errors. /wowfa > Status for details.",
```
addon/WoWFA/Panel.lua:240
```
  239         color(r.val, col)
  240         local s = panel.modState and panel.modState[id]
  241         if s then
```
addon/WoWFA/Panel.lua:334
```
  333     refresh_health()
  334     if panel.shareBox and F.Room.ShareExport then
  335         panel.shareBox:SetFixed(F.Room.ShareExport())
```
addon/WoWFA/Panel.lua:335
```
  334     if panel.shareBox and F.Room.ShareExport then
  335         panel.shareBox:SetFixed(F.Room.ShareExport())
  336     end
```
addon/WoWFA/Panel.lua:379
```
  378     if not nostore then
  379         panel.room[k] = t
  380     end
```
addon/WoWFA/Panel.lua:389
```
  388     t.dimOnMaster = true
  389     panel.mods[id] = place(t, L["m_" .. id .. "_d"] and 50 or 32, 2)
  390     panel.modState[id] = pair_row(L.h_state, false)
```
addon/WoWFA/Panel.lua:390
```
  389     panel.mods[id] = place(t, L["m_" .. id .. "_d"] and 50 or 32, 2)
  390     panel.modState[id] = pair_row(L.h_state, false)
  391 end
```
addon/WoWFA/Panel.lua:406
```
  405 local function disp_section(sec)
  406     panel.dispCustom[sec] = place(UI.Toggle(page.child, PW - 16, L.d_sep, L.d_sep_d,
  407         function() return F.DispCustom(sec) end,
```
addon/WoWFA/Panel.lua:409
```
  408         function(v) F.DispSetCustom(sec, v) end), 50, 2)
  409     panel.dispTitle[sec] = place(UI.Choice(page.child, PW - 16, L.d_title, nil, L.opt_title,
  410         function() return F.Disp(sec, "title") end,
```
addon/WoWFA/Panel.lua:412
```
  411         function(v) F.DispSet(sec, "title", v) end), 32, 2)
  412     panel.dispDesc[sec] = place(UI.Choice(page.child, PW - 16, L.d_desc, nil, L.opt_desc,
  413         function() return F.Disp(sec, "desc") end,
```
addon/WoWFA/Panel.lua:483
```
  482     sub:SetFa(L.subtitle, 300)
  483     panel.subtitle = sub
  484     local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
```
addon/WoWFA/Panel.lua:490
```
  489     end)
  490     panel.close = close
  491     local line = UI.Line(panel, false, 0.5)
```
addon/WoWFA/Panel.lua:499
```
  498     -- the side menu
  499     panel.nav = navbtns
  500     for i, id in ipairs(SECTIONS) do
```
addon/WoWFA/Panel.lua:515
```
  514     rows = {}
  515     panel.room, panel.mods, panel.modState = {}, {}, {}
  516     panel.dispCustom, panel.dispTitle, panel.dispDesc = {}, {}, {}
```
addon/WoWFA/Panel.lua:516
```
  515     panel.room, panel.mods, panel.modState = {}, {}, {}
  516     panel.dispCustom, panel.dispTitle, panel.dispDesc = {}, {}, {}
  517 
```
addon/WoWFA/Panel.lua:520
```
  519     begin_page("general")
  520     panel.master = place(UI.Toggle(page.child, PW - 16, L.master, L.master_d,
  521         function() return F.db.enabled end,
```
addon/WoWFA/Panel.lua:549
```
  548     pre.dimOnMaster = true
  549     panel.preset = place(pre, 50, 4)
  550     header(L.g_names)
```
addon/WoWFA/Panel.lua:555
```
  554     header(L.g_defaults)
  555     panel.dispTitleAll = place(UI.Choice(page.child, PW - 16, L.d_title, nil, L.opt_title,
  556         function() return F.Disp("*", "title") end,
```
addon/WoWFA/Panel.lua:558
```
  557         function(v) F.DispSetDefault("title", v) end), 32, 2)
  558     panel.dispDescAll = place(UI.Choice(page.child, PW - 16, L.d_desc, nil, L.opt_desc,
  559         function() return F.Disp("*", "desc") end,
```
addon/WoWFA/Panel.lua:562
```
  561     header(L.tab_display)
  562     panel.minimap = place(UI.Toggle(page.child, PW - 16, L.d_minimap, nil,
  563         function() return not F.db.minimap.hide end,
```
addon/WoWFA/Panel.lua:568
```
  567         end), 32, 2)
  568     panel.toast = opt_toggle("toast", L.d_toast, false)
  569     panel.share = opt_toggle("share", L.d_share, false)
```
addon/WoWFA/Panel.lua:569
```
  568     panel.toast = opt_toggle("toast", L.d_toast, false)
  569     panel.share = opt_toggle("share", L.d_share, false)
  570     panel.shiftEn = opt_toggle("shiftEn", L.dl_shift, false) -- 1.0.7 (Modules/Dialog.lua)
```
addon/WoWFA/Panel.lua:570
```
  569     panel.share = opt_toggle("share", L.d_share, false)
  570     panel.shiftEn = opt_toggle("shiftEn", L.dl_shift, false) -- 1.0.7 (Modules/Dialog.lua)
  571     panel.onUpdate = place(UI.Choice(page.child, PW - 16, L.d_update, nil, L.opt_update,
```
addon/WoWFA/Panel.lua:571
```
  570     panel.shiftEn = opt_toggle("shiftEn", L.dl_shift, false) -- 1.0.7 (Modules/Dialog.lua)
  571     panel.onUpdate = place(UI.Choice(page.child, PW - 16, L.d_update, nil, L.opt_update,
  572         function() return F.db.onUpdate end,
```
addon/WoWFA/Panel.lua:579
```
  578     header(L.al_hdr)
  579     panel.alerts = place(UI.Toggle(page.child, PW - 16, L.al_on, L.al_on_d,
  580         function() return F.db.alerts ~= false end,
```
addon/WoWFA/Panel.lua:586
```
  585     -- the system lines of the chat (Modules/Sysmsg.lua)
  586     panel.sysmsg = place(UI.Toggle(page.child, PW - 16, L.sy_on, L.sy_on_d,
  587         function() return F.db.sysmsg ~= false end,
```
addon/WoWFA/Panel.lua:601
```
  600     -- Persian in the game chat (Modules/Chat.lua)
  601     panel.chatFa = place(UI.Toggle(page.child, PW - 16, L.ch_on, L.ch_on_d,
  602         function() return F.db.chatFa ~= false end,
```
addon/WoWFA/Panel.lua:615
```
  614     header(L.sz_own_h)
  615     panel.fontSize = place(UI.Slider(page.child, PW - 16, L.d_size, 9, 20, 1,
  616         function() return F.db.fontSize end,
```
addon/WoWFA/Panel.lua:629
```
  628     header(L.sz_list_h)
  629     panel.szList = place(UI.Slider(page.child, PW - 16, L.ls_size, 70, 200, 5,
  630         function() return F.db.szList or 100 end,
```
addon/WoWFA/Panel.lua:640
```
  639     header(L.sz_all_h)
  640     panel.fontAll = place(UI.Toggle(page.child, PW - 16, L.fa_on, L.fa_on_d,
  641         function() return F.db.fontAll == true end,
```
addon/WoWFA/Panel.lua:646
```
  645         end), 50, 2)
  646     panel.szGame = place(UI.Slider(page.child, PW - 16, L.fa_size, 70, 160, 5,
  647         function() return F.db.szGame or 100 end,
```
addon/WoWFA/Panel.lua:657
```
  656     header(L.sz_other_h)
  657     panel.chatScale = place(UI.Slider(page.child, PW - 16, L.ch_size, 60, 120, 5,
  658         function() return F.db.chatScale or 90 end,
```
addon/WoWFA/Panel.lua:667
```
  666     note(L.sz_chat_d)
  667     panel.alertScale = place(UI.Slider(page.child, PW - 16, L.al_size, 70, 160, 5,
  668         function() return F.db.alertScale or 100 end,
```
addon/WoWFA/Panel.lua:677
```
  676     note(L.sz_alert_d)
  677     panel.scale = place(UI.Slider(page.child, PW - 16, L.d_scale, 0.8, 1.3, 0.05,
  678         function() return F.db.scale end,
```
addon/WoWFA/Panel.lua:695
```
  694     room_toggle("npcSay")
  695     panel.dock = place(UI.Choice(page.child, PW - 16, L.d_dock, nil, L.opt_dock,
  696         function() return F.db.questDock end,
```
addon/WoWFA/Panel.lua:701
```
  700         end), 32, 2)
  701     panel.questAuto = opt_toggle("questAuto", L.d_qauto, true)
  702     panel.listTitles = opt_toggle("listTitles", L.d_listtitles, true)
```
addon/WoWFA/Panel.lua:702
```
  701     panel.questAuto = opt_toggle("questAuto", L.d_qauto, true)
  702     panel.listTitles = opt_toggle("listTitles", L.d_listtitles, true)
  703     -- 1.1.0: Questie's tooltips and tracker (Modules/Questie.lua)
```
addon/WoWFA/Panel.lua:704
```
  703     -- 1.1.0: Questie's tooltips and tracker (Modules/Questie.lua)
  704     panel.questie = place(UI.Toggle(page.child, PW - 16, L.qz_on, L.qz_on_d,
  705         function() return F.db.questie ~= false end,
```
addon/WoWFA/Panel.lua:727
```
  726     -- the world-map zone label (Modules/Zones.lua map_mode): 1 fa / 2 fa + en / 3 off
  727     panel.zoneMap = place(UI.Choice(page.child, PW - 16, L.d_map, nil, L.opt_map,
  728         function() return F.db.zoneMap or 2 end,
```
addon/WoWFA/Panel.lua:741
```
  740     -- F.db.npcName: 1 Persian / 2 Persian + English under it / 3 English (Modules/Npc.lua)
  741     panel.npcName = place(UI.Choice(page.child, PW - 16, L.d_npcname, nil, L.opt_npc,
  742         function() return F.NpcMode and F.NpcMode() or 1 end,
```
addon/WoWFA/Panel.lua:754
```
  753     room_toggle("npcSay", true)
  754     panel.dlgGossip = opt_toggle("dlgGossip", L.dl_gossip, true)
  755     panel.dlgSay = opt_toggle("dlgSay", L.dl_say, true)
```
addon/WoWFA/Panel.lua:755
```
  754     panel.dlgGossip = opt_toggle("dlgGossip", L.dl_gossip, true)
  755     panel.dlgSay = opt_toggle("dlgSay", L.dl_say, true)
  756     panel.dlgBook = opt_toggle("dlgBook", L.dl_book, true)
```
addon/WoWFA/Panel.lua:756
```
  755     panel.dlgSay = opt_toggle("dlgSay", L.dl_say, true)
  756     panel.dlgBook = opt_toggle("dlgBook", L.dl_book, true)
  757     note(L.dl_note)
```
addon/WoWFA/Panel.lua:786
```
  785     begin_page("colors")
  786     panel.colOn = place(UI.Toggle(page.child, PW - 16, L.col_on, L.col_on_d,
  787         function() return F.db.col and F.db.col.on and true or false end,
```
addon/WoWFA/Panel.lua:790
```
  789     header(L.col_hdr)
  790     panel.col = {}
  791     for _, fam in ipairs(F.T.COL_FAMS) do
```
addon/WoWFA/Panel.lua:814
```
  813         row:Update()
  814         panel.col[fam] = place(row, 32, 2)
  815     end
```
addon/WoWFA/Panel.lua:821
```
  820     note(L.ol_note)
  821     panel.ol = {}
  822     for _, k in ipairs({ "npc", "zn", "qs", "sp", "text" }) do
```
addon/WoWFA/Panel.lua:823
```
  822     for _, k in ipairs({ "npc", "zn", "qs", "sp", "text" }) do
  823         panel.ol[k] = place(UI.Toggle(page.child, PW - 16, L["ol_" .. k] or k, nil,
  824             function() return F.OlOn(k) end,
```
addon/WoWFA/Panel.lua:835
```
  834     c1:SetSize(PW - 16, 26)
  835     panel.shareBox = code_box(c1, false)
  836     place(c1, 26, 8)
```
addon/WoWFA/Panel.lua:841
```
  840     c2:SetSize(PW - 16, 26)
  841     panel.shareIn = code_box(c2, true)
  842     place(c2, 26, 6)
```
addon/WoWFA/Panel.lua:845
```
  844     ab:SetSize(PW - 16, 30)
  845     panel.shareApply = UI.Button(ab, L.sh_apply, 150, 26, function()
  846         local txt = panel.shareIn:GetText() or ""
```
addon/WoWFA/Panel.lua:846
```
  845     panel.shareApply = UI.Button(ab, L.sh_apply, 150, 26, function()
  846         local txt = panel.shareIn:GetText() or ""
  847         local ok, why, note = F.Room.ShareImport(txt)
```
addon/WoWFA/Panel.lua:852
```
  851         end
  852         panel.shareMsg:SetFa(msg, PW - 30)
  853         if ok then
```
addon/WoWFA/Panel.lua:857
```
  856     end)
  857     panel.shareApply:SetPoint("RIGHT", ab, "RIGHT", -4, 0)
  858     place(ab, 30, 4)
```
addon/WoWFA/Panel.lua:861
```
  860     mf:SetSize(PW - 16, 30)
  861     panel.shareMsg = UI.Text(mf, 12, C.goldLight)
  862     panel.shareMsg:SetPoint("TOPRIGHT", mf, "TOPRIGHT", -4, 0)
```
addon/WoWFA/Panel.lua:862
```
  861     panel.shareMsg = UI.Text(mf, 12, C.goldLight)
  862     panel.shareMsg:SetPoint("TOPRIGHT", mf, "TOPRIGHT", -4, 0)
  863     panel.shareMsg:SetFa(" ", PW - 30)
```
addon/WoWFA/Panel.lua:863
```
  862     panel.shareMsg:SetPoint("TOPRIGHT", mf, "TOPRIGHT", -4, 0)
  863     panel.shareMsg:SetFa(" ", PW - 30)
  864     place(mf, 30, 2)
```
addon/WoWFA/Panel.lua:872
```
  871     pn:SetSize(PW - 16, 26)
  872     panel.pfName = code_box(pn, true)
  873     place(pn, 26, 4)
```
addon/WoWFA/Panel.lua:888
```
  887     pb:SetSize(PW - 16, 30)
  888     panel.pfSave = UI.Button(pb, L.pf_save, 150, 26, function()
  889         local ok, why, name = F.Room.ProfileSave(panel.pfName:GetText() or "")
```
addon/WoWFA/Panel.lua:889
```
  888     panel.pfSave = UI.Button(pb, L.pf_save, 150, 26, function()
  889         local ok, why, name = F.Room.ProfileSave(panel.pfName:GetText() or "")
  890         if ok then
```
- ok: panel.: 82 hits

### ROOM_ROWS

addon/WoWFA/Locale.lua:411
```
  410     share = "پروفایل و اشتراک‌گذاری" }
  411 L.ROOM_ROWS = {
  412     root = {
```
addon/WoWFA/Panel.lua:36
```
   35 local function room_label(key)
   36     for _, group in pairs(L.ROOM_ROWS or {}) do
   37         for _, r in ipairs(group) do
```
- ok: ROOM_ROWS: 2 hits

### dl_intro

addon/WoWFA/Locale_Dlg.lua:5
```
    4 L.sec_dialog = "گفتگو و کتاب‌ها"
    5 L.dl_intro = "حرف‌های NPCها (متن پنجرهٔ گفتگو و خوش‌آمد، حرف‌هایی که در چت و بالای سرشان می‌زنند) و متن کتاب‌ها، نامه‌ها و تابلوها. هر متنی که هنوز فارسی ندارد 
    6 L.dl_gossip = "متن پنجرهٔ گفتگو و خوش‌آمد NPC"
```
addon/WoWFA/Panel.lua:752
```
  751     begin_page("dialog")
  752     note(L.dl_intro)
  753     room_toggle("npcSay", true)
```
- ok: dl_intro: 2 hits

### npcSay

addon/WoWFA/Core.lua:267
```
  266 -- the NPC / object name tooltips belong to the NAME switches (namesNpc /
  267 -- namesObj), not to the gossip switch (npcSay)
  268 local SURF_ROOM = {
```
addon/WoWFA/Core.lua:269
```
  268 local SURF_ROOM = {
  269     questPane = "questText", questLog = "questText", gossip = "npcSay",
  270     trackerTitle = "questText", trackerObj = "questText", qobj = "questText",
```
addon/WoWFA/Locale.lua:438
```
  437         { k = "questText", lbl = "متن کوئست‌ها" },
  438         { k = "npcSay", lbl = "گفتگوی NPC" },
  439     },
```
addon/WoWFA/Locale.lua:459
```
  458     questText = "اهداف: ۰ از ۱ انجام شد",
  459     npcSay = "عنوان کوئست‌ها در پنجرهٔ گفتگوی NPC",
  460     faDigits = "۷۳ زره به‌جای 73 Armor",
```
addon/WoWFA/Modules/Dialog.lua:4
```
    3 -- know at once, so the next update has it"). Four surfaces, all behind the room switch
    4 -- «گفتگوی NPC» (npcSay) and one switch each on the «گفتگو و کتاب‌ها» page:
    5 --   gossip  the text of the gossip window and the quest greeting (F.db.dlgGossip)
```
addon/WoWFA/Modules/Dialog.lua:38
```
   37     local db = F.db
   38     return db and db.enabled and F.Room and F.Room.On("npcSay") and true or false
   39 end
```
addon/WoWFA/Modules/Tracker.lua:571
```
  570             local txt = b.GetText and b:GetText()
  571             if F.Usable(txt) and txt ~= "" and F.Room.On("npcSay") then -- inbox/29 D2
  572                 local id = title_id_of(txt)
```
addon/WoWFA/Panel.lua:23
```
   22 local SHIPPED = { "quests", "tracker", "dungeons", "npc", "spellbook", "talents" }
   23 local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
   24 local SECTIONS = { "general", "sizes", "quests", "tracker", "map", "npc", "dialog", "spellbook", "talents", "colors", "share", "health", "about" }
```
addon/WoWFA/Panel.lua:694
```
  693     room_toggle("questText")
  694     room_toggle("npcSay")
  695     panel.dock = place(UI.Choice(page.child, PW - 16, L.d_dock, nil, L.opt_dock,
```
addon/WoWFA/Panel.lua:753
```
  752     note(L.dl_intro)
  753     room_toggle("npcSay", true)
  754     panel.dlgGossip = opt_toggle("dlgGossip", L.dl_gossip, true)
```
addon/WoWFA/Room.lua:35
```
   34     "namesClass" } -- 15 FROZEN bits (bit 14 = namesClass, v4.1, never re-ordered)
   35 Room.GAME_KEYS = { "questText", "npcSay", "faDigits", "greyNotes", "namesSet", "textSet" } -- game only
   36 -- faPlace is a choice (1 = in place, 2 = below), never a share-code bit.
```
addon/WoWFA/Room.lua:38
```
   37 
   38 Room.GAME_DEFAULT = { questText = true, npcSay = true, faDigits = true, greyNotes = true,
   39     namesSet = true, textSet = true }
```
addon/WoWFA/Room.lua:228
```
  227     if m == "en" then
  228         r.d.questText, r.d.npcSay = false, false
  229     elseif m == "fa" then
```
addon/WoWFA/Room.lua:230
```
  229     elseif m == "fa" then
  230         r.d.questText, r.d.npcSay = true, true
  231     elseif m == 'story' then
```
addon/WoWFA/Room.lua:232
```
  231     elseif m == 'story' then
  232         r.d.questText, r.d.npcSay = true, true
  233     elseif m == 'spells' then
```
addon/WoWFA/Room.lua:234
```
  233     elseif m == 'spells' then
  234         r.d.questText, r.d.npcSay = false, false
  235     end
```
addon/WoWFA/Room.lua:381
```
  380     d.questText = surf.questPane ~= false and surf.questLog ~= false and surf.qobj ~= false
  381     d.npcSay = surf.gossip ~= false
  382     d.greyNotes = fdb.itemNotes ~= false
```
addon/WoWFA/Room.lua:888
```
  887     { "surf.questPane/questLog/qobj", "questText (AND)" },
  888     { "surf.gossip", "npcSay" },
  889     { "surf.npcTip/objTip", "namesNpc/namesObj (the name switches own the name tooltips)" },
```
- ok: npcSay: 18 hits
