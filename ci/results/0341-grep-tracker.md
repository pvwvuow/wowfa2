## task 0341-grep-tracker (script)

**GREEN**


### inbox/29 D2

addon/WoWFA/Core.lua:177
```
  163         F.Toast(faText)
  164     end
  165 end
  166 
  167 -- -------------------------------------------------------------- saved vars
  168 local DEFAULTS = {
  169     schema = 2, -- db schema (NOT the data schema: F.SCHEMA stays the data's 1)
  170     enabled = true,
  171     welcomed = false,
  172     mode = 3, -- inbox/29 A: mode 3 only - the user-facing picker is gone
  173     fontSize = 12,
  174     faDigits = true,
  175     mods = { items = true, quests = true, dungeons = true, npc = true, tracker = true, spellbook = true, talents = true, capture = false },
  176     names = { npc = true, zn = true, it = true, sp = true, ob = true, qs = true, cls = true, tm = true },
  177     -- inbox/29 D2: the per-surface switches of the "چه چیزی ترجمه شود" page;
  178     -- a surface is live only if master AND its module AND this flag are on
  179     surf = {
  180         questPane = true, questLog = true, gossip = true, trackerTitle = true, trackerObj = true,
  181         zoneArrival = true, zoneMinimap = true, zoneMap = true, zoneTip = true,
  182         npcTip = true, objTip = true,
  183     },
  184     scale = 1, -- inbox/29 D: the panel scale slider (0.8 - 1.3)
  185     itemDetail = 3, -- inbox/47 B: full tooltip detail by default (the f lines
  186                     -- are the stats/slot/bind/req the owner read in English)
  187     itemNotes = true,
  188     itemStyle = 1, -- inbox/27: 1 = Persian in place (like the site), 2 = under the tooltip
  189     questDock = 1,
  190     questAuto = true,
  191     zoneToast = 4,
```
addon/WoWFA/Core.lua:254
```
  240 end
  241 
  242 local function migrate(db)
  243     -- db schema 1 = the first Forever schema (mode was user-picked 1/2/3);
  244     -- schema 2 (inbox/29 A): display mode 3 ONLY - every saved mode becomes 3
  245     -- in one silent migration. RANGES.mode stays {1,3} so the tests can pin
  246     -- 1/2 directly, but no user-facing path writes anything else any more.
  247     if (db.schema or 1) < 2 then
  248         db.mode = 3
  249     end
  250     db.schema = 2
  251 end
  252 
  253 -- ----------------------------------------------------- per-surface switches
  254 -- inbox/29 D2: which module each surface flag belongs to; a surface is live
  255 -- only if the master AND its module AND its own flag are on.
  256 local SURF_MOD = {
  257     questPane = "quests", questLog = "tracker", gossip = "tracker",
  258     trackerTitle = "tracker", trackerObj = "tracker",
  259     zoneArrival = "dungeons", zoneMinimap = "dungeons", zoneMap = "dungeons", zoneTip = "dungeons",
  260     npcTip = "npc", objTip = "npc",
  261 }
  262 F.SURF_MOD = SURF_MOD
  263 
  264 -- 51-B: the room owns WHAT translates; Surf survives only as the module gate
  265 -- (db.mods) + the room switch the old surface name folded into. Brain review:
  266 -- the NPC / object name tooltips belong to the NAME switches (namesNpc /
  267 -- namesObj), not to the gossip switch (npcSay)
  268 local SURF_ROOM = {
```
addon/WoWFA/Locale.lua:98
```
   84 L.n_it_x = "مثلاً Tough Jerky -> گوشت تند"
   85 L.n_sp = "اسپل و مهارت"
   86 L.n_sp_x = "مثلاً Aspect of the Hawk -> شکل شاهین"
   87 L.n_ob = "اشیا"
   88 L.n_ob_x = "مثلاً Brazier of Marl -> آتشدان مارل"
   89 L.n_qs = "عنوان کوئست‌ها"
   90 L.n_qs_x = "مثلاً Shadumbra's Head -> سر شادمبرا"
   91 L.n_cls = "کلاس‌ها"
   92 L.n_cls_x = "مثلاً Hunter -> شکارچی"
   93 L.n_tm = "اصطلاحات بازی"
   94 L.n_tm_x = "مثلاً Hearthstone -> سنگ راهخانه"
   95 L.all_on = "همه روشن"
   96 L.all_off = "همه خاموش"
   97 
   98 -- inbox/29 D2: the "چه چیزی ترجمه شود" page - grouped cards, one toggle + a
   99 -- one-line description each. The descriptions say exactly WHAT is translated.
  100 L.surf_head = "دقیقاً مشخص کن کدوم بخش‌ها فارسی بشن. هر کلید بی‌درنگ اثر می‌کنه؛ با خاموش‌کردنش همان انگلیسیِ بازی برمی‌گردد."
  101 L.g_items = "آیتم‌ها"
  102 L.g_quests = "کوئست‌ها"
  103 L.g_zones = "مناطق"
  104 L.g_npc = "NPC و اشیا"
  105 L.g_spells = "اسپل و تلنت"
  106 L.s_itemtip = "تولتیپ آیتم"
  107 L.s_itemtip_d = "نام و توضیح فارسی روی تولتیپ آیتم‌ها."
  108 L.s_questPane = "پنجرهٔ متن کوئست"
  109 L.s_questPane_d = "پنجرهٔ فارسی متن کوئست کنار پنجرهٔ بازی."
  110 L.s_questLog = "عنوان‌های دفترچه"
  111 L.s_questLog_d = "عنوان فارسی کوئست‌ها توی فهرست دفترچه."
  112 L.s_gossip = "دکمه‌های گفتگو"
```
addon/WoWFA/Modules/Quests.lua:657
```
  643                         -- Brain review (#139): was F.Wrap("quests", on_log)() -
  644                         -- a dot call of the METHOD, so on_log never ran and every
  645                         -- dialog close with the log open logged a junk error
  646                         wrapped()
  647                     end
  648                 end)
  649             end))
  650             f:HookScript("OnDragStop", F:Wrap("quests", function()
  651                 if pane and pane:IsShown() and F.db.questDock ~= 3 then
  652                     dock(pane, log_frame() or (QuestFrame and vis(QuestFrame) and QuestFrame) or f)
  653                 end
  654             end))
  655         end
  656     end
  657     -- inbox/29 D2: the surface switch hides the pane NOW (and the button);
  658     -- switching it back on re-shows for the quest still on screen
  659     F:Listen("surf", function(name)
  660         if name and name ~= "questPane" then
  661             return -- only the pane surface belongs to this module
  662         end
  663         if not F.Room.On("questText") then -- 51-B: the room owns the quest text
  664             if pane then
  665                 pane:Hide()
  666             end
  667             if faBtn then
  668                 faBtn:Hide()
  669             end
  670         elseif shownId then
  671             show(shownId, pane and pane.enTitle, shownCtx, pane and pane.anchor)
```
- ok: inbox/29 D2: 16 hits

### L.ROOM_EX = 

addon/WoWFA/Locale.lua:441
```
  427         { k = "textDesc", lbl = "توضیحات و افکت‌ها" },
  428         { k = "textStats", lbl = "متن آمار (چابکی، استقامت و …)" },
  429         { k = "textReq", lbl = "نیازمندی‌ها" },
  430         { k = "textBind", lbl = "اتصال و یکتایی" },
  431         { k = "textDetail", lbl = "جزئیات آیتم" },
  432         { k = "textFlavor", lbl = "متن‌های تزئینی" },
  433         { k = "textSet", lbl = "بونوس‌های ست" },
  434         { k = "greyNotes", lbl = "یادداشت خاکستری" },
  435     },
  436     quest = {
  437         { k = "questText", lbl = "متن کوئست‌ها" },
  438         { k = "npcSay", lbl = "گفتگوی NPC" },
  439     },
  440 }
  441 L.ROOM_EX = {
  442     namesItem = "شلوار دیفیاس سیاه‌شده",
  443     namesSet = "ست چرم دیفیاس و فهرست تکه‌های ست",
  444     namesSpell = "گردباد، تشنگی خون",
  445     namesClass = "جنگاور، کیفر، استادی حیوان",
  446     namesNpc = "هایلرد دمیتریان، اژدهای برونزی",
  447     namesZone = "تاناریس، سکولومنس",
  448     namesQuest = "برخیز، تندرفوری!",
  449     namesObj = "صندوق گنج آتش‌خاک",
  450     terms = "hit rating، attack power، stamina",
  451     textDesc = "به هنگام پوشیدن: قدرت حملهٔ شما ۶۰۰ افزایش می‌یابد.",
  452     textStats = "+۸ استقامت · ۳۰۰ آسیب طبیعت",
  453     textReq = "نیازمند سطح ۶۰ · نیازمند جنگاور",
  454     textBind = "مقید به روح · هنگام برداشتن قید می‌شود · یکتا",
  455     textDetail = "شنل · چرم · دوام ۲۰ / ۲۵ · قیمت فروش",
```
- ok: L.ROOM_EX = : 1 hits

### L.ROOM_ROWS = {

addon/WoWFA/Locale.lua:411
```
  397     schema = "WoWFA: translation data does not match this addon version. Please reinstall the addon.",
  398     on = "WoWFA enabled.", off = "WoWFA disabled.",
  399     reset = "WoWFA: all settings were reset.",
  400     noquest = "WoWFA: no quest window open",
  401     combat = "WoWFA: will open after combat.",
  402     status = "WoWFA %s | game %s | data %s | %s",
  403 }
  404 -- 101 PR 6 (B5): the room's user-facing tables moved here byte for byte from
  405 -- Panel.lua by script (the strings moved, never retyped); the lint test
  406 -- (tests/forever/panel_lint_persian.lua) keeps any new Persian literal out of
  407 -- Panel.lua outside the QUEST_CARD / GOSSIP_CARD fixtures.
  408 
  409 L.VIEW_TITLE = { vocab = "واژه‌نامهٔ بازی", texts = "خط‌های تولتیپ آیتم", quest = "کوئست و گفتگو",
  410     share = "پروفایل و اشتراک‌گذاری" }
  411 L.ROOM_ROWS = {
  412     root = {
  413         { k = "faDigits", lbl = "اعداد فارسی" },
  414     },
  415     vocab = {
  416         { k = "namesItem", lbl = "اسم آیتم‌ها" },
  417         { k = "namesSet", lbl = "اسم ست‌ها و تکه‌های ست" },
  418         { k = "namesSpell", lbl = "اسم اسپل‌ها و استعدادها" },
  419         { k = "namesClass", lbl = "اسم کلاس‌ها و شاخه‌ها" },
  420         { k = "namesNpc", lbl = "اسم شخصیت‌ها و موجودها" },
  421         { k = "namesZone", lbl = "اسم مناطق و دانجن‌ها" },
  422         { k = "namesQuest", lbl = "عنوان کوئست‌ها" },
  423         { k = "namesObj", lbl = "اسم آبجکت‌ها" },
  424         { k = "terms", lbl = "اصطلاح‌های بازی" },
  425     },
```
- ok: L.ROOM_ROWS = {: 1 hits

### L.al_hdr

addon/WoWFA/Locale_Alerts.lua:11
```
    1 -- WoWFA Forever - texts of the game alerts (the red messages in the middle of
    2 -- the screen: "Out of range.", "Invalid target", ...). Each row is
    3 -- { GlobalStrings name, Persian }: the English text is read from the game's own
    4 -- global (so it is always the exact text this client shows) and the Persian is
    5 -- drawn instead. %s / %d in the English become %s / %d in the Persian.
    6 -- Lua 5.1 has no \u escape: the half-space (ZWNJ) is written as Z.
    7 
    8 local L = WoWFAF_L
    9 local Z = "\226\128\140"
   10 
   11 L.al_hdr = "هشدارهای بازی"
   12 L.al_on = "هشدارهای میان صفحه به فارسی"
   13 L.al_on_d = "پیام" .. Z .. "هایی مثل «خارج از برد» و «هدف نامعتبر» که وسط صفحه ظاهر می" .. Z .. "شوند"
   14 
   15 L.ch_on = "چت فارسی"
   16 L.ch_on_d = "فونت چت فارسی می" .. Z .. "شود و پیام" .. Z .. "های فارسی درست دیده می" .. Z .. "شوند (مخاطب هم باید ادان داشته باشد)"
   17 
   18 L.ch_size = "اندازه فونت چت (درصد)"
   19 
   20 L.sh_newer = "این کد را کسی با نسخهٔ جدیدتر اددان ساخته؛ هر چه این نسخه می" .. Z .. "شناسد اعمال شد. برای بقیه" .. Z .. "اش اددان را آپدیت کن."
   21 L.sh_upd = "این کد از نسخهٔ جدیدتر اددان است و این نسخه نمی" .. Z .. "تواند بخواندش. اددان را از wowfarsi.ir آپدیت کن."
   22 
   23 L.fa_on = "فونت فارسی در کل بازی"
   24 L.fa_on_d = "فونت همهٔ نوشته" .. Z .. "های بازی عوض می" .. Z .. "شود تا فارسی هیچ" .. Z .. "جا مربع نشود (چت، نام" .. Z .. "ها، نامه، دوستان). ظاهر نوشته" .. Z 
   25 
```
addon/WoWFA/Panel.lua:578
```
  564         function(v)
  565             F.db.minimap.hide = not v
  566             F:Fire("minimap")
  567         end), 32, 2)
  568     panel.toast = opt_toggle("toast", L.d_toast, false)
  569     panel.share = opt_toggle("share", L.d_share, false)
  570     panel.shiftEn = opt_toggle("shiftEn", L.dl_shift, false) -- 1.0.7 (Modules/Dialog.lua)
  571     panel.onUpdate = place(UI.Choice(page.child, PW - 16, L.d_update, nil, L.opt_update,
  572         function() return F.db.onUpdate end,
  573         function(v)
  574             F.db.onUpdate = v
  575             F:Refresh()
  576         end), 32, 2)
  577     -- the red messages in the middle of the screen (Modules/Alerts.lua)
  578     header(L.al_hdr)
  579     panel.alerts = place(UI.Toggle(page.child, PW - 16, L.al_on, L.al_on_d,
  580         function() return F.db.alerts ~= false end,
  581         function(v)
  582             F.db.alerts = v and true or false
  583             F:Fire("options", "alerts")
  584         end), 50, 2)
  585     -- the system lines of the chat (Modules/Sysmsg.lua)
  586     panel.sysmsg = place(UI.Toggle(page.child, PW - 16, L.sy_on, L.sy_on_d,
  587         function() return F.db.sysmsg ~= false end,
  588         function(v)
  589             F.db.sysmsg = v and true or false
  590             F:Fire('options', 'sysmsg')
  591         end), 50, 2)
  592     for _, k in ipairs({ 'sysLoot', 'sysXp', 'sysRep', 'sysGroup' }) do
```
- ok: L.al_hdr: 2 hits

### L.sy_on 

addon/WoWFA/Locale_Sys.lua:16
```
    2 -- level, reputation, skills, group), more game alerts and the two new presets.
    3 -- Same idea as Locale_Alerts.lua: each row is { GlobalStrings name, Persian };
    4 -- the English is read from the game's own global at run time, so it is always
    5 -- the exact text this client shows (a name this client does not have is skipped).
    6 -- In the Persian text ~ is a half-space (ZWNJ). The alerts use %s / %d like
    7 -- Locale_Alerts.lua; the system lines use {1} {2} {3} for the values the
    8 -- English line holds, in the order they stand in the English.
    9 
   10 local L = WoWFAF_L
   11 
   12 local function fa(s)
   13     return (string.gsub(s, "~", "\226\128\140"))
   14 end
   15 
   16 L.sy_on = fa("پیام~های سیستم به فارسی")
   17 L.sy_on_d = fa("غنیمت، تجربه، سطح، اعتبار، مهارت و پیام~های گروه در چت فارسی نوشته می~شوند (چت فارسی هم باید روشن باشد)")
   18 
   19 L.pr_story = fa("فقط داستان")
   20 L.pr_story_d = fa("مأموریت~ها، اسم NPC و منطقه~ها فارسی؛ جادوها و آیتم~ها انگلیسی")
   21 L.pr_spells = fa("فقط جادوها")
   22 L.pr_spells_d = fa("جادوها و استعدادها فارسی؛ بقیه انگلیسی")
   23 
   24 -- more of the red messages in the middle of the screen (added to L.ALERTS)
   25 local MORE = {
   26     { "SPELL_FAILED_NOT_STANDING", "برای این کار باید ایستاده باشید" },
   27     { "SPELL_FAILED_ONLY_OUTDOORS", "این را فقط بیرون از ساختمان می~توانید به کار ببرید" },
   28     { "SPELL_FAILED_ONLY_INDOORS", "این را فقط داخل ساختمان می~توانید به کار ببرید" },
   29     { "SPELL_FAILED_NO_COMBO_POINTS", "این توانایی امتیاز ترکیبی لازم دارد" },
   30     { "SPELL_FAILED_TARGET_AURASTATE", "هنوز نمی~توانید این کار را بکنید" },
```
- ok: L.sy_on : 1 hits

### L.ch_on 

addon/WoWFA/Locale_Alerts.lua:15
```
    1 -- WoWFA Forever - texts of the game alerts (the red messages in the middle of
    2 -- the screen: "Out of range.", "Invalid target", ...). Each row is
    3 -- { GlobalStrings name, Persian }: the English text is read from the game's own
    4 -- global (so it is always the exact text this client shows) and the Persian is
    5 -- drawn instead. %s / %d in the English become %s / %d in the Persian.
    6 -- Lua 5.1 has no \u escape: the half-space (ZWNJ) is written as Z.
    7 
    8 local L = WoWFAF_L
    9 local Z = "\226\128\140"
   10 
   11 L.al_hdr = "هشدارهای بازی"
   12 L.al_on = "هشدارهای میان صفحه به فارسی"
   13 L.al_on_d = "پیام" .. Z .. "هایی مثل «خارج از برد» و «هدف نامعتبر» که وسط صفحه ظاهر می" .. Z .. "شوند"
   14 
   15 L.ch_on = "چت فارسی"
   16 L.ch_on_d = "فونت چت فارسی می" .. Z .. "شود و پیام" .. Z .. "های فارسی درست دیده می" .. Z .. "شوند (مخاطب هم باید ادان داشته باشد)"
   17 
   18 L.ch_size = "اندازه فونت چت (درصد)"
   19 
   20 L.sh_newer = "این کد را کسی با نسخهٔ جدیدتر اددان ساخته؛ هر چه این نسخه می" .. Z .. "شناسد اعمال شد. برای بقیه" .. Z .. "اش اددان را آپدیت کن."
   21 L.sh_upd = "این کد از نسخهٔ جدیدتر اددان است و این نسخه نمی" .. Z .. "تواند بخواندش. اددان را از wowfarsi.ir آپدیت کن."
   22 
   23 L.fa_on = "فونت فارسی در کل بازی"
   24 L.fa_on_d = "فونت همهٔ نوشته" .. Z .. "های بازی عوض می" .. Z .. "شود تا فارسی هیچ" .. Z .. "جا مربع نشود (چت، نام" .. Z .. "ها، نامه، دوستان). ظاهر نوشته" .. Z 
   25 
   26 L.ALERTS = {
   27     { "SPELL_FAILED_OUT_OF_RANGE", "خارج از برد." },
   28     { "ERR_OUT_OF_RANGE", "خارج از برد." },
   29     { "SPELL_FAILED_BAD_TARGETS", "هدف نامعتبر" },
```
- ok: L.ch_on : 1 hits

### L.tab_display

addon/WoWFA/Locale.lua:18
```
    4 -- the English table L.en instead.
    5 
    6 local L = {}
    7 WoWFAF_L = L
    8 
    9 L.subtitle = "ترجمهٔ فارسی WoW Forever"
   10 L.master = "WoWFA روشن باشه"
   11 L.master_d = "کلید اصلی. وقتی خاموشه هیچ متن فارسی‌ای به بازی اضافه نمی‌شه."
   12 
   13 L.tab_home = "خانه"
   14 L.tab_room = "اتاق کاستوم ترجمه"
   15 L.tab_surfaces = "چه چیزی ترجمه شود"
   16 L.tab_mods = "بخش‌ها"
   17 L.tab_names = "اسم‌ها"
   18 L.tab_display = "نمایش"
   19 L.tab_health = "وضعیت"
   20 L.tab_about = "درباره"
   21 L.tab_capture = "کمک به دیتا"
   22 L.h_summary = "وضعیت بخش‌ها"
   23 L.d_scale = "اندازهٔ پنجرهٔ تنظیمات"
   24 
   25 L.m_items = "آیتم‌ها"
   26 L.m_items_d = "نام و توضیح فارسی زیر تولتیپ آیتم‌ها."
   27 L.m_quests = "کوئست‌ها"
   28 L.m_quests_d = "متن کامل کوئست کنار پنجرهٔ کوئست و دفترچهٔ کوئست."
   29 L.m_dungeons = "دانجن و مناطق"
   30 L.m_dungeons_d = "نام فارسی منطقه و دانجن موقع ورود و روی نقشهٔ کوچک؛ حالت تازه: در خود متن."
   31 L.m_tracker = "دنبال‌کنندهٔ کوئست"
   32 L.m_tracker_d = "عنوان و اهداف کوئست‌های در حال انجام، عنوان‌های دفترچه و گفتگو، همه در خود متن بازی."
```
addon/WoWFA/Panel.lua:561
```
  547     end
  548     pre.dimOnMaster = true
  549     panel.preset = place(pre, 50, 4)
  550     header(L.g_names)
  551     room_toggle("namesClass")
  552     room_toggle("terms")
  553     room_toggle("faDigits")
  554     header(L.g_defaults)
  555     panel.dispTitleAll = place(UI.Choice(page.child, PW - 16, L.d_title, nil, L.opt_title,
  556         function() return F.Disp("*", "title") end,
  557         function(v) F.DispSetDefault("title", v) end), 32, 2)
  558     panel.dispDescAll = place(UI.Choice(page.child, PW - 16, L.d_desc, nil, L.opt_desc,
  559         function() return F.Disp("*", "desc") end,
  560         function(v) F.DispSetDefault("desc", v) end), 32, 2)
  561     header(L.tab_display)
  562     panel.minimap = place(UI.Toggle(page.child, PW - 16, L.d_minimap, nil,
  563         function() return not F.db.minimap.hide end,
  564         function(v)
  565             F.db.minimap.hide = not v
  566             F:Fire("minimap")
  567         end), 32, 2)
  568     panel.toast = opt_toggle("toast", L.d_toast, false)
  569     panel.share = opt_toggle("share", L.d_share, false)
  570     panel.shiftEn = opt_toggle("shiftEn", L.dl_shift, false) -- 1.0.7 (Modules/Dialog.lua)
  571     panel.onUpdate = place(UI.Choice(page.child, PW - 16, L.d_update, nil, L.opt_update,
  572         function() return F.db.onUpdate end,
  573         function(v)
  574             F.db.onUpdate = v
  575             F:Refresh()
```
- ok: L.tab_display: 2 hits

### L.n_tracker

addon/WoWFA/Locale.lua:178
```
  164 L.sec_map = "نقشه و مناطق"
  165 L.sec_spellbook = "کتاب جادو"
  166 L.sec_talents = "استعدادها"
  167 L.sec_health = "وضعیت"
  168 L.sec_about = "درباره"
  169 L.g_names = "نام‌ها و واژه‌ها در متن‌ها"
  170 L.g_defaults = "نمایش پیش‌فرض همهٔ بخش‌ها"
  171 L.d_title = "نام (عنوان)"
  172 L.d_desc = "توضیحات"
  173 L.opt_title = { "فقط فارسی", "فارسی و انگلیسی زیرش", "فقط انگلیسی" }
  174 L.opt_desc = { "فارسی به جای انگلیسی", "فارسی زیر انگلیسی", "خاموش (انگلیسی)" }
  175 L.d_sep = "تنظیم جدا برای این بخش"
  176 L.d_sep_d = "خاموش یعنی این بخش از «عمومی» پیروی می‌کند"
  177 L.h_state = "وضعیت این بخش"
  178 L.n_tracker = "نام و هدف مأموریت‌ها در ردیاب با کلید «نام مأموریت‌ها» در بخش مأموریت‌ها ترجمه می‌شود."
  179 L.n_disp = "تغییر نمایش از دفعهٔ بعدی که راهنمای اسپل را می‌بینی اعمال می‌شود."
  180 L.sec_colors = "رنگ‌ها"
  181 L.col_on = "رنگی کردن نام‌ها"
  182 L.col_on_d = "نام منطقه، اسپل، شخصیت و ... در متن‌ها و راهنماها با رنگ انتخابی نشان داده می‌شود"
  183 L.col_hdr = "رنگ هر نوع نام"
  184 L.col_zn = "مناطق و نقشه"
  185 L.col_sp = "اسپل‌ها و استعدادها"
  186 L.col_npc = "شخصیت‌ها (NPC)"
  187 L.col_cls = "کلاس‌ها"
  188 L.col_it = "آیتم‌ها"
  189 L.col_tm = "اصطلاحات"
  190 L.col_ob = "اشیای دنیای بازی"
  191 L.col_note = "رنگ فقط روی نام‌هایی اثر می‌گذارد که ترجمه شده‌اند."
  192 L.col_id = { off = "خاموش", green = "سبز", blue = "آبی", gold = "طلایی", orange = "نارنجی", red = "قرمز",
```
addon/WoWFA/Panel.lua:718
```
  704     panel.questie = place(UI.Toggle(page.child, PW - 16, L.qz_on, L.qz_on_d,
  705         function() return F.db.questie ~= false end,
  706         function(v)
  707             F.db.questie = v and true or false
  708             F:Fire("options", "questie")
  709             if F.Walk and F.Walk.Refresh then
  710                 F.Walk.Refresh()
  711             end
  712         end), 50, 2)
  713     end_page()
  714 
  715     -- ===================================================== Quest tracker
  716     begin_page("tracker")
  717     mod_toggle("tracker")
  718     note(L.n_tracker)
  719     end_page()
  720 
  721     -- ===================================================== Map and zones
  722     begin_page("map")
  723     mod_toggle("dungeons")
  724     header(L.sec_map)
  725     room_toggle("namesZone")
  726     -- the world-map zone label (Modules/Zones.lua map_mode): 1 fa / 2 fa + en / 3 off
  727     panel.zoneMap = place(UI.Choice(page.child, PW - 16, L.d_map, nil, L.opt_map,
  728         function() return F.db.zoneMap or 2 end,
  729         function(v)
  730             F.db.zoneMap = v
  731             F:Fire("options", "zoneMap")
  732         end), 32, 2)
```
- ok: L.n_tracker: 2 hits
