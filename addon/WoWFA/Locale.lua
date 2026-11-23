-- WoWFA Forever - user-facing strings.
-- Persian strings are drawn only with our own font (Vazirmatn). The chat
-- frame of an English client has no Persian glyphs, so every chat line uses
-- the English table L.en instead.

local L = {}
WoWFAF_L = L

L.subtitle = "ترجمهٔ فارسی WoW Forever"
L.master = "WoWFA روشن باشه"
L.master_d = "کلید اصلی. وقتی خاموشه هیچ متن فارسی‌ای به بازی اضافه نمی‌شه."

L.tab_home = "خانه"
L.tab_room = "اتاق کاستوم ترجمه"
L.tab_surfaces = "چه چیزی ترجمه شود"
L.tab_mods = "بخش‌ها"
L.tab_names = "اسم‌ها"
L.tab_display = "نمایش"
L.tab_health = "وضعیت"
L.tab_about = "درباره"
L.tab_capture = "کمک به دیتا"
L.h_summary = "وضعیت بخش‌ها"
L.d_scale = "اندازهٔ پنجرهٔ تنظیمات"

L.m_items = "آیتم‌ها"
L.m_items_d = "نام و توضیح فارسی زیر تولتیپ آیتم‌ها."
L.m_quests = "کوئست‌ها"
L.m_quests_d = "متن کامل کوئست کنار پنجرهٔ کوئست و دفترچهٔ کوئست."
L.m_dungeons = "دانجن و مناطق"
L.m_dungeons_d = "نام فارسی منطقه و دانجن موقع ورود و روی نقشهٔ کوچک؛ حالت تازه: در خود متن."
L.m_tracker = "دنبال‌کنندهٔ کوئست"
L.m_tracker_d = "عنوان و اهداف کوئست‌های در حال انجام، عنوان‌های دفترچه و گفتگو، همه در خود متن بازی."
L.tracker_slain = "کشته‌شده"
L.tracker_complete = "تکمیل‌شده"
L.tracker_ready = "آمادهٔ تحویل"
L.m_npc = "NPC و اشیا"
L.m_npc_d = "نام فارسی NPCها، باس‌ها و اشیای دنیا روی تولتیپ."
L.m_spellbook = "اسپل‌بوک"
L.m_spellbook_d = "نام و توضیح فارسی اسپل‌ها در تولتیپ."
L.m_talents = "تلنت‌ها"
L.m_talents_d = "نام و توضیح فارسی تلنت‌ها در تولتیپ."
L.m_talents_shared = "در این کلاینت تولتیپ تلنت با تولتیپ اسپل‌بوک یکی است."
L.m_capture = "کمک به دیتا"
L.m_capture_d = "ذخیرهٔ اختیاری چیزهایی که در بازی می‌بینی برای دیتای سایت (غنیمت، فروشنده، کوئست). پیش‌فرض خاموش."

L.tab_capture = "کمک به دیتا"
L.cap_head = "اگه خودت بخوای، اددان چیزهایی که در بازی می‌بینی رو توی همون فایل تنظیمات ذخیره می‌کنه تا بعداً خودت برای دیتای سایت آپلودش کنی. هیچ چیز خودکار جایی ارسال نمی‌شه."
L.cap_toggle = "کمک به دیتای سایت: ذخیرهٔ چیزهایی که در بازی می‌بینی"
L.cap_counts = "ثبت‌شده‌ها: آیتم %d · فروشنده %d · غنیمت %d · کوئست %d · NPC %d"
L.cap_size = "حجم حدود %s"
L.cap_empty = "هنوز چیزی ثبت نشده."
L.cap_clear = "پاک کردن همهٔ ثبت‌شده‌ها"
L.cap_file = "محل ذخیره: WTF/Account/<account>/SavedVariables/WoWFA.lua — آپلود بعداً و فقط با خودت."
L.cap_locale = "زبان بازی انگلیسی نیست؛ متن‌ها ذخیره نمی‌شن (فقط شناسه‌ها و قیمت‌ها)."
L.w_capture = "این اددان به دیتای سایت هم کمک می‌کنه — فقط اگه خودت توی صفحهٔ «کمک به دیتا» روشنش کنی. پیش‌فرض خاموشه."

L.st_ok = "سالم"
L.st_warn = "هشدار"
L.st_off = "خاموش"
L.st_master = "کلید اصلی خاموشه"
L.st_nodata = "داده نداره"
L.st_schema = "داده ناسازگاره"
L.st_noapi = "خودکار خاموش شد"
L.st_update = "متوقف: آپدیت بازی"
L.st_fault = "خودکار خاموش شد: خطا"

L.why_nodata = "ترجمهٔ این بخش هنوز توی این نسخه نیست."
L.why_schema = "فرمت داده با این نسخهٔ اددان جور نیست. اددان رو کامل آپدیت کن."
L.why_noapi = "این بخش در این نسخهٔ بازی در دسترس نیست."
L.why_via_spellbook = "تولتیپ تلنت در این کلاینت از راه اسپل‌بوک پوشش داده می‌شود."
L.why_update = "بازی بعد از ساخت این ترجمه آپدیت شده و این بخش حساسه، پس موقتاً متوقفه. آپدیت اددان رو چک کن، یا اگه مشکلی نمی‌بینی روشنش کن."
L.why_warn_build = "بازی جدیدتر از داده‌های ترجمه‌ست؛ شاید بعضی متن‌ها قدیمی باشن."
L.why_warn_miss = "بیشتر متن‌های این بخش پیدا نشدن؛ احتمالاً بازی آپدیت شده. آپدیت اددان رو چک کن."
L.why_fault = "این بخش چند بار پشت هم خطا داد و برای اینکه بازیت به مشکل نخوره خاموش شد."
L.btn_resume = "با همین نسخه روشن کن"
L.btn_retry = "دوباره امتحان کن"

L.names_head = "مثل سایت: هر دسته‌ای که خاموش باشه، اون نام‌ها توی متن ترجمه انگلیسی می‌مونن."
L.n_npc = "NPCها"
L.n_npc_x = "مثلاً Hogger -> هاگر"
L.n_zn = "مناطق"
L.n_zn_x = "مثلاً Westfall -> وستفال"
L.n_it = "آیتم‌ها"
L.n_it_x = "مثلاً Tough Jerky -> گوشت تند"
L.n_sp = "اسپل و مهارت"
L.n_sp_x = "مثلاً Aspect of the Hawk -> شکل شاهین"
L.n_ob = "اشیا"
L.n_ob_x = "مثلاً Brazier of Marl -> آتشدان مارل"
L.n_qs = "عنوان کوئست‌ها"
L.n_qs_x = "مثلاً Shadumbra's Head -> سر شادمبرا"
L.n_cls = "کلاس‌ها"
L.n_cls_x = "مثلاً Hunter -> شکارچی"
L.n_tm = "اصطلاحات بازی"
L.n_tm_x = "مثلاً Hearthstone -> سنگ راهخانه"
L.all_on = "همه روشن"
L.all_off = "همه خاموش"

-- inbox/29 D2: the "چه چیزی ترجمه شود" page - grouped cards, one toggle + a
-- one-line description each. The descriptions say exactly WHAT is translated.
L.surf_head = "دقیقاً مشخص کن کدوم بخش‌ها فارسی بشن. هر کلید بی‌درنگ اثر می‌کنه؛ با خاموش‌کردنش همان انگلیسیِ بازی برمی‌گردد."
L.g_items = "آیتم‌ها"
L.g_quests = "کوئست‌ها"
L.g_zones = "مناطق"
L.g_npc = "NPC و اشیا"
L.g_spells = "اسپل و تلنت"
L.s_itemtip = "تولتیپ آیتم"
L.s_itemtip_d = "نام و توضیح فارسی روی تولتیپ آیتم‌ها."
L.s_questPane = "پنجرهٔ متن کوئست"
L.s_questPane_d = "پنجرهٔ فارسی متن کوئست کنار پنجرهٔ بازی."
L.s_questLog = "عنوان‌های دفترچه"
L.s_questLog_d = "عنوان فارسی کوئست‌ها توی فهرست دفترچه."
L.s_gossip = "دکمه‌های گفتگو"
L.s_gossip_d = "عنوان کوئست روی دکمه‌های گفتگو با NPC."
L.s_trackerTitle = "عنوان در ترکر"
L.s_trackerTitle_d = "عنوان فارسی کوئست‌های در حال انجام در دنبال‌کننده."
L.s_trackerObj = "هدف‌ها در ترکر"
L.s_trackerObj_d = "خط‌های هدف (کشته‌شده، آیتم جمع‌شده و ...) در دنبال‌کننده."
L.s_zoneArrival = "متن ورود وسط صفحه"
L.s_zoneArrival_d = "نام منطقه موقع ورود، وسط صفحه."
L.s_zoneMinimap = "اسم بالای نقشهٔ کوچک"
L.s_zoneMinimap_d = "نام منطقه بالای نقشهٔ کوچک، در خود متن."
L.s_zoneMap = "نقشهٔ بزرگ"
L.s_zoneMap_d = "نام منطقه روی نقشهٔ جهان و برچسب هاور."
L.s_zoneTip = "تولتیپ نقشهٔ کوچک"
L.s_zoneTip_d = "نام فارسی منطقه در تولتیپ نقشهٔ کوچک."
L.s_npcTip = "تولتیپ NPC"
L.s_npcTip_d = "نام فارسی NPCها و باس‌ها روی تولتیپ."
L.s_objTip = "تولتیپ اشیا"
L.s_objTip_d = "نام فارسی اشیای دنیا روی تولتیپ."

L.d_size = "اندازهٔ فونت"
L.d_item = "جزئیات آیتم"
L.opt_item = { "فقط نام", "نام و جلوه‌ها", "کامل" }
L.d_dock = "جای پنل کوئست"
L.opt_dock = { "سمت راست پنجره", "سمت چپ پنجره", "آزاد، جابه‌جاش کن" }
L.d_qauto = "پنل کوئست خودکار باز بشه"
L.d_zone = "اعلان نام منطقه"
L.opt_zone = { "همهٔ مناطق", "فقط دانجن و ریید", "خاموش", "در خود متن" }
L.d_update = "وقتی بازی آپدیت شد"
L.opt_update = { "فقط هشدار بده", "بخش‌های حساس رو متوقف کن", "همه رو متوقف کن" }
L.d_digits = "عددهای زنده فارسی باشن"
L.d_itemstyle = "شکل تولتیپ آیتم"
L.opt_itemstyle = { "خودِ تولتیپ فارسی شود (مثل سایت)", "فارسی زیر تولتیپ" }
L.d_minimap = "دکمهٔ کنار نقشهٔ کوچک"
L.d_toast = "پیام‌های اددان روی صفحه"
L.d_share = "خبر نسخهٔ جدید از هم‌گروهی‌ها"
L.d_itemnotes = "یادداشت‌های خاکستری روی آیتم‌ها"
L.d_resetpos = "بازنشانی جای پنجره‌ها"
L.d_preview = "پیش‌نمایش (حالت فعلی)"
L.d_preview_rows = { "+10 روح", "۱۰٪ بیشتر", "ادامهٔ داستان در Dreadmaul Rock..." }

L.h_client = "نسخهٔ بازی"
L.h_data = "نسخهٔ داده‌های ترجمه"
L.h_addon = "نسخهٔ اددان"
L.h_mem = "حافظه"
L.h_errors = "خطاهای اخیر؛ برای گزارش کپی کن و بفرست"
L.h_noerr = "خطایی ثبت نشده."
L.btn_recheck = "بررسی دوباره"
L.btn_clear = "پاک کردن خطاها"
L.h_miss_n = "متن‌های بدون ترجمه که دیدی: %d؛ روی کادر کلیک کن، Ctrl+C و برام بفرست"
L.sec_general = "عمومی"
L.sec_quests = "مأموریت‌ها"
L.sec_tracker = "ردیاب مأموریت"
L.sec_map = "نقشه و مناطق"
L.sec_spellbook = "کتاب جادو"
L.sec_talents = "استعدادها"
L.sec_health = "وضعیت"
L.sec_about = "درباره"
L.g_names = "نام‌ها و واژه‌ها در متن‌ها"
L.g_defaults = "نمایش پیش‌فرض همهٔ بخش‌ها"
L.d_title = "نام (عنوان)"
L.d_desc = "توضیحات"
L.opt_title = { "فقط فارسی", "فارسی و انگلیسی زیرش", "فقط انگلیسی" }
L.opt_desc = { "فارسی به جای انگلیسی", "فارسی زیر انگلیسی", "خاموش (انگلیسی)" }
L.d_sep = "تنظیم جدا برای این بخش"
L.d_sep_d = "خاموش یعنی این بخش از «عمومی» پیروی می‌کند"
L.h_state = "وضعیت این بخش"
L.n_tracker = "نام و هدف مأموریت‌ها در ردیاب با کلید «نام مأموریت‌ها» در بخش مأموریت‌ها ترجمه می‌شود."
L.n_disp = "تغییر نمایش از دفعهٔ بعدی که راهنمای اسپل را می‌بینی اعمال می‌شود."
L.sec_colors = "رنگ‌ها"
L.col_on = "رنگی کردن نام‌ها"
L.col_on_d = "نام منطقه، اسپل، شخصیت و ... در متن‌ها و راهنماها با رنگ انتخابی نشان داده می‌شود"
L.col_hdr = "رنگ هر نوع نام"
L.col_zn = "مناطق و نقشه"
L.col_sp = "اسپل‌ها و استعدادها"
L.col_npc = "شخصیت‌ها (NPC)"
L.col_cls = "کلاس‌ها"
L.col_it = "آیتم‌ها"
L.col_tm = "اصطلاحات"
L.col_ob = "اشیای دنیای بازی"
L.col_note = "رنگ فقط روی نام‌هایی اثر می‌گذارد که ترجمه شده‌اند."
L.col_id = { off = "خاموش", green = "سبز", blue = "آبی", gold = "طلایی", orange = "نارنجی", red = "قرمز",
    purple = "بنفش", cyan = "فیروزه‌ای", pink = "صورتی", white = "سفید", class = "رنگ رسمی کلاس" }
L.sec_npc = "شخصیت‌ها (NPC)"
L.sec_share = "اشتراک‌گذاری"
L.d_npcname = "نام شخصیت‌ها بالای سرشان"
L.opt_npc = { "فارسی", "فارسی و انگلیسی زیرش", "انگلیسی" }
L.n_npc = "نام بالای سر شخصیت‌ها وقتی دیده می‌شود که نمایش نام‌ها روشن باشد (کلید V). روی راهنمای شخصیت و نام هدف هم اثر می‌کند."
L.sh_mine = "کد تنظیمات من"
L.sh_mine_d = "این کد همهٔ انتخاب‌های تو را دارد: روی کادر کلیک کن، Ctrl+C بزن و به بقیه بده."
L.sh_use = "گذاشتن کد دیگران"
L.sh_use_d = "کدی که از کسی گرفته‌ای را اینجا بچسبان (Ctrl+V) و «اعمال کد» را بزن."
L.sh_apply = "اعمال کد"
L.sh_ok = "تنظیمات اعمال شد."
L.btn_miss_clear = "پاک کردن فهرست"
L.btn_select = "انتخاب برای کپی"

L.a_site = "سایت و آپدیت‌ها"
L.a_cmds = "دستورها: /wowfa پنل، /wowfa on یا off، /wowfa status، /wowfa reset"
L.a_new = "چه خبر"
L.changelog = {
    "0.6.1: پنجرهٔ تنظیمات حرفه‌ای با انتخاب دقیق «چه چیزی ترجمه شود»، پنجرهٔ کوئست با دکمهٔ «فا» (حذف زبانهٔ شناور)، خط‌های فاصله‌دار و مرتب، و فقط حالت ۳.",
    "0.6.0: تولتیپ آیتم خودِ تولتیپ فارسی می‌شود (مثل سایت)؛ کلید شکل تولتیپ، خط‌های حالت بازی (دوشاخته، سطح، ماندگاری) و دستور /wowfa probe. نام منطقه در خود متن (نقشهٔ کوچک، اعلام ورود، نقشهٔ بزرگ) + دنبال‌کنندهٔ کوئست فارسی با عنوان‌ها و اهداف.",
    "0.5.7: بازبینی کامل؛ نصب دوبارهٔ بخش‌ها، هٔ چسبیده، ترتیب +۱۰، پاک‌سازی آیکون و لینک از کلیدها و تنظیمات تازهٔ نمایش.",
    "0.5.6: رفع واقعی «...» کوئست (پیچش خط در پنل) + هر کلید روی همهٔ سطوح درست کار می‌کند.",
    "0.5.5: تأیید جزئیات آیتم با تولتیپ زندهٔ بازی، رفع «...» متن‌های بلند کوئست، تلنت از راه اسپل‌بوک.",
    "0.5.4: خط خاکستری صادقانه برای آیتم‌های تغییرکرده، مخفی و ناموجود.",
    "0.5.3: نسخهٔ آزمایشی ماژول کوئست (WoWFA_QuestData) برای بررسی درون‌بازی.",
    "0.5.2: دادهٔ بیلد ۷۰۷۹۰: پاس کلاس‌های آغازین و ۱۸۲۶ نام تازهٔ آیتم.",
    "0.5.1: نام فارسی ۱٬۷۸۷ آیتم تازه و نام‌های کامل NPC.",
    "0.5.0: اولین نسخهٔ Forever با پنل جدید، صفحهٔ خوش‌آمد و محافظ آپدیت بازی.",
}
L.btn_welcome = "نمایش دوبارهٔ خوش‌آمد"
L.btn_reset = "بازنشانی همهٔ تنظیمات"
L.btn_reset_sure = "مطمئنی؟ دوباره بزن"

L.w_title = "به WoWFA خوش اومدی"
L.w_scope = "در نسخهٔ 1.0 کوئست‌ها، اسم مناطق، اسپل‌ها و تلنت‌ها فارسی می‌شوند. آیتم‌ها و بقیهٔ بخش‌ها به‌زودی می‌آیند."
L.w_choose = "چه چیزی ترجمه شود؟"
L.p_all = "پیشنهادی"
L.p_all_d = "کوئست‌ها، اسم مناطق، اسپل‌ها و تلنت‌ها فارسی می‌شوند؛ بخش‌های دیگر به‌زودی باز می‌شوند."
L.p_qi = "فقط کوئست‌ها"
L.p_qi_d = "فقط متن کوئست‌ها و اسم مناطق فارسی می‌شود؛ اسپل‌ها و تلنت‌ها انگلیسی می‌مانند."
L.p_custom = "سفارشی"
L.p_custom_d = "خودت در صفحهٔ «چه چیزی ترجمه شود» تک‌تک انتخاب کن."
L.w_start = "شروع"
L.w_later = "بعداً"

L.mm_status = "همه‌چیز فارسه و سالم"
L.mm_left = "کلیک: باز کردن پنل"
L.mm_right = "راست‌کلیک: روشن یا خاموش"
L.mm_drag = "بکش تا جابه‌جا بشه"
L.mm_issue = "یک بخش نیاز به توجه داره"
L.open_panel = "باز کردن پنل WoWFA"

L.q_fabtn_tip = "متن فارسی کوئست"

L.t_tripped = "بخش «%s» به خاطر خطا خودکار خاموش شد. جزئیات توی پنل، بخش وضعیت."
L.t_update = "بازی آپدیت شده. بخش‌های حساس موقتاً متوقف شدن تا آپدیت اددان رو بگیری."
L.t_newver = "نسخهٔ جدید WoWFA منتشر شده: %s. از wowfarsi.ir بگیرش."
L.t_miss = "متن‌های بخش «%s» دیگه با بازی جور نیست؛ احتمالاً آپدیت اومده."
L.t_upgraded = "WoWFA به نسخهٔ %s آپدیت شد."
L.t_nodata = "داده‌های ترجمه پیدا نشد؛ اددان رو دوباره نصب کن."
L.t_on = "WoWFA روشن شد."
L.t_off = "WoWFA خاموش شد."

L.stale_item = "(!) آمار این آیتم توی بازی عوض شده؛ فقط نام نشون داده شد."
L.item_unverified = "جزئیات این آیتم در Forever تأیید نشده است"
L.item_unconfirmed = "برخی جزئیات تأیید نشده‌اند"
L.item_absent = "این آیتم در فایل‌های بازی Forever نیست"

-- inbox/27 (0.6.0): live client state lines the static item data does not
-- carry - EN exact or %s/%d pattern -> Persian. Every word comes from the
-- site's own bank (data/forever/glossary.json canonical + the fa-*.json tip
-- wording) - never a new term. %s fills from the live line; pure numbers get
-- Persian digits when the faDigits switch is on (same T.Digits rule).
-- inbox/47 C: the item/quest option rows (the surfaces page)
L.s_names_it = "اسم آیتم فارسی باشد"
L.s_names_it_d = "نام آیتم‌ها روی تولتیپ فارسی نوشته شود."
L.s_itemLines = "متن تولتیپ فارسی باشد"
L.s_itemLines_d = "خط‌های تولتیپ آیتم (زره، استت‌ها، ست و ...) فارسی شوند؛ خاموش = فقط اسم."
L.s_itemDetail = "میزان ترجمه"
L.s_itemDetail_d = "همه = تمام خط‌ها؛ فقط مهم = خط‌های اصلی؛ فقط اسم = تنها نام فارسی شود."
L.s_itemStyle = "جای فارسی"
L.s_itemStyle_d = "سر جای خودش = خط‌های خود تولتیپ فارسی می‌شوند؛ زیر تولتیپ = بلوک جدا."
L.s_itemNotes = "یادداشت خاکستری «تأیید نشده»"
L.s_itemNotes_d = "وقتی عددی با بازی نخواند، یادداشت صداقت نمایش داده شود."
L.s_qobj = "شرح مراحل کوئست"
L.s_qobj_d = "شرح فارسی هدف‌های کوئست در پنجرهٔ کوئست نمایش داده شود."
L.choice_on = "همه"
L.choice_important = "فقط مهم"
L.choice_name = "فقط اسم"
L.choice_inplace = "سر جای خودش"
L.choice_below = "زیر تولتیپ"
L.home_more = "تنظیمات بیشتر"
L.st_on = "روشن"
L.st_off = "خاموش"
L.home_items = "آیتم‌ها"
L.home_quests = "کوئست‌ها"
L.home_names = "اسم‌ها و منطقه‌ها"

-- Generated from wowfa-packs/out/text-strings-cooldown.json; do not hand-edit values.
L.cooldown = {
    tpl = "(کول‌داون: %s)",
    join = " و ",
    sec = "ثانیه",
    min = "دقیقه",
    hr = "ساعت",
    day = "روز",
}

L.tip = {
    ["Soulbound"] = "مقید به روح",
    ["Binds when picked up"] = "هنگام برداشتن قید می‌شود",
    ["Binds when equipped"] = "هنگام به‌تن‌کردن قید می‌شود",
    ["Binds when used"] = "هنگام استفاده قید می‌شود",
    ["Unique"] = "یکتا",
    ["Unique (%d)"] = "یکتا (%s)",
    ["Quest Item"] = "آیتم کوئست",
    ["Quest items"] = "آیتم‌های کوئست",
    ["This Item Begins a Quest"] = "این آیتم یک کوئست را آغاز می‌کند",
    ["Requires Level %d"] = "سطح مورد نیاز %s",
    ["Item Level %d"] = "سطح آیتم %s",
    ["Durability %d / %d"] = "دوام %s / %s",
    ["Durability %d/%d"] = "دوام %s/%s", -- inbox/47r2 R7: the no-space live shape
    ["Classes: %s"] = "کلاس‌ها: %s",
    ["Races: %s"] = "نژادها: %s",
    ["Requires %s (%d)"] = "نیازمند %s (%s)",
    ["Sell Price:"] = "قیمت فروش:",
    ["Cooldown remaining: %s"] = "کول‌داون باقی‌مانده: %s",
    ["<Right-click to read>"] = "برای خواندن کلیک راست کنید",
    ["<Right Click to Read>"] = "برای خواندن کلیک راست کنید",
    ["<Right Click to Open>"] = "برای باز کردن کلیک راست کنید",
    ["<Right-click to open>"] = "برای باز کردن کلیک راست کنید",
    ["Equipment Sets: %s"] = "ست‌های تجهیز: %s",
    ["Food & Drink"] = "خوراک و نوشیدنی",
    -- slot names (glossary canonical)
    ["Head"] = "سر", ["Neck"] = "گردن", ["Shoulder"] = "سرشانه", ["Back"] = "شنل",
    ["Chest"] = "سینه", ["Shirt"] = "پیراهن", ["Tabard"] = "شنل‌نشانه", ["Wrist"] = "مچ",
    ["Hands"] = "دستان", ["Waist"] = "کمر", ["Legs"] = "پاها", ["Feet"] = "پا",
    ["Finger"] = "انگشتر", ["Trinket"] = "آویز",
    ["One-Hand"] = "یک‌دستی", ["Two-Hand"] = "دودستی", ["Main Hand"] = "دست اصلی",
    ["Off Hand"] = "دست چپ", ["Held In Off-hand"] = "نگه‌داشته در دست چپ",
    ["Ranged"] = "دوربرد", ["Thrown"] = "پرتابی", ["Relic"] = "یادگار",
    ["Bag"] = "کیف", ["Projectile"] = "مهمات", ["Ammo"] = "مهمات",
    -- armor / weapon types (glossary canonical)
    ["Cloth"] = "پارچه", ["Leather"] = "چرم", ["Mail"] = "زره حلقه‌ای", ["Plate"] = "زره صفحه‌ای",
    ["Shield"] = "سپر", ["Axe"] = "تبر", ["Bow"] = "کمان", ["Crossbow"] = "کمانک",
    ["Dagger"] = "خنجر", ["Fist Weapon"] = "سلاح مشت‌زنی", ["Gun"] = "تفنگ",
    ["Mace"] = "گرز", ["Polearm"] = "نیزهٔ بلند", ["Staff"] = "عصا", ["Sword"] = "شمشیر",
    ["Wand"] = "واند", ["Fishing Pole"] = "چوب ماهیگیری",
    -- Brain 88 STEP 4: the missing state rows (whole-line flip, by design).
    -- Horde / Alliance have no glossary / names spelling yet - Brain's wording
    -- stands. The fa of the %d patterns uses %s like the existing rows.
    ["You haven't collected this appearance"] = "این ظاهر هنوز در کلکسیون شما نیست",
    ["Crafting Reagent"] = "مادهٔ ساخت",
    ["Unique-Equipped"] = "یکتا هنگام پوشیدن",
    ["Unique-Equipped: %s (%d)"] = "یکتا هنگام پوشیدن: %s (%s)",
    ["Unique: %s (%d)"] = "یکتا: %s (%s)",
    ["Binds to account"] = "متصل به حساب",
    ["Cosmetic"] = "ظاهری",
    ["Mount"] = "مرکب",
    ["Conjured Item"] = "آیتم احضاری",
    ["Toy"] = "اسباب‌بازی",
    ["Locked"] = "قفل",
    ["<Random Additional Stats>"] = "<ویژگی‌های تصادفیِ اضافه>",
    ["PTR Only"] = "فقط سرور آزمایشی",
    ["Horde Only"] = "فقط هورد",
    ["Alliance Only"] = "فقط اتحاد",
    ["<This item can be read>"] = "برای خواندن کلیک راست کنید", -- the same Persian as <Right-click to read>
}
L.stale_quest = "(!) متن این کوئست توی بازی عوض شده؛ ترجمه شاید قدیمی باشه."
L.q_obj = "هدف"
L.q_details = "شرح"
L.q_progress = "در جریان"
L.q_complete = "پایان"
L.zone_dungeon = "دانجن"
L.zone_raid = "ریید"
L.d_map = "اسم مناطق روی نقشهٔ بزرگ"
L.opt_map = { "فقط فارسی (جای انگلیسی)", "فارسی، انگلیسی زیرش", "ترجمه نشه (انگلیسی)" }

L.class = {
    WARRIOR = "جنگاور", PALADIN = "پالادین", HUNTER = "شکارچی", ROGUE = "راهزن", PRIEST = "روحانی",
    SHAMAN = "شمن", MAGE = "جادوگر", WARLOCK = "احضارکننده", DRUID = "دروئید",
}
L.race = {
    Human = "انسان", Dwarf = "دورف", NightElf = "نایت‌الف", Gnome = "گنوم",
    Orc = "اورک", Scourge = "آندد", Tauren = "تائورن", Troll = "ترول",
}

-- chat lines (English: the chat font has no Persian glyphs)
L.en = {
    m_items = "Items", m_quests = "Quests", m_dungeons = "Dungeons & zones", m_npc = "NPCs & objects", m_tracker = "Quest tracker",
    m_spellbook = "Spellbook", m_talents = "Talents", m_capture = "Site data helper",
    loaded = "WoWFA %s loaded (data build %s). Type /wowfa to open the panel.",
    tripped = "WoWFA: '%s' turned itself off after repeated errors. /wowfa > Status for details.",
    update = "WoWFA: the game was updated (build %s, translation data %s). Sensitive parts are paused until you update the addon or resume them in /wowfa.",
    build = "WoWFA: game build %s is newer than the translation data (%s). Texts may be slightly out of date; check wowfarsi.ir for an update.",
    iface = "WoWFA: the game interface (%d) is newer than this addon (%d). If something looks wrong, check wowfarsi.ir for an update.",
    newver = "WoWFA: a newer version (%s) is out. Get it from wowfarsi.ir",
    miss = "WoWFA: most '%s' texts no longer match the game. An addon update is probably needed.",
    item_unverified = "Details of this item are not confirmed for Forever.",
    item_unconfirmed = "Some details are not confirmed.",
    item_absent = "This item is not in the Forever game files.",
    nodata = "WoWFA: translation data not found. Please reinstall the addon.",
    schema = "WoWFA: translation data does not match this addon version. Please reinstall the addon.",
    on = "WoWFA enabled.", off = "WoWFA disabled.",
    reset = "WoWFA: all settings were reset.",
    noquest = "WoWFA: no quest window open",
    combat = "WoWFA: will open after combat.",
    status = "WoWFA %s | game %s | data %s | %s",
}
-- 101 PR 6 (B5): the room's user-facing tables moved here byte for byte from
-- Panel.lua by script (the strings moved, never retyped); the lint test
-- (tests/forever/panel_lint_persian.lua) keeps any new Persian literal out of
-- Panel.lua outside the QUEST_CARD / GOSSIP_CARD fixtures.

L.VIEW_TITLE = { vocab = "واژه‌نامهٔ بازی", texts = "خط‌های تولتیپ آیتم", quest = "کوئست و گفتگو",
    share = "پروفایل و اشتراک‌گذاری" }
L.ROOM_ROWS = {
    root = {
        { k = "faDigits", lbl = "اعداد فارسی" },
    },
    vocab = {
        { k = "namesItem", lbl = "اسم آیتم‌ها" },
        { k = "namesSet", lbl = "اسم ست‌ها و تکه‌های ست" },
        { k = "namesSpell", lbl = "اسم اسپل‌ها و استعدادها" },
        { k = "namesClass", lbl = "اسم کلاس‌ها و شاخه‌ها" },
        { k = "namesNpc", lbl = "اسم شخصیت‌ها و موجودها" },
        { k = "namesZone", lbl = "اسم مناطق و دانجن‌ها" },
        { k = "namesQuest", lbl = "عنوان کوئست‌ها" },
        { k = "namesObj", lbl = "اسم آبجکت‌ها" },
        { k = "terms", lbl = "اصطلاح‌های بازی" },
    },
    texts = {
        { k = "textDesc", lbl = "توضیحات و افکت‌ها" },
        { k = "textStats", lbl = "متن آمار (چابکی، استقامت و …)" },
        { k = "textReq", lbl = "نیازمندی‌ها" },
        { k = "textBind", lbl = "اتصال و یکتایی" },
        { k = "textDetail", lbl = "جزئیات آیتم" },
        { k = "textFlavor", lbl = "متن‌های تزئینی" },
        { k = "textSet", lbl = "بونوس‌های ست" },
        { k = "greyNotes", lbl = "یادداشت خاکستری" },
    },
    quest = {
        { k = "questText", lbl = "متن کوئست‌ها" },
        { k = "npcSay", lbl = "گفتگوی NPC" },
    },
}
L.ROOM_EX = {
    namesItem = "شلوار دیفیاس سیاه‌شده",
    namesSet = "ست چرم دیفیاس و فهرست تکه‌های ست",
    namesSpell = "گردباد، تشنگی خون",
    namesClass = "جنگاور، کیفر، استادی حیوان",
    namesNpc = "هایلرد دمیتریان، اژدهای برونزی",
    namesZone = "تاناریس، سکولومنس",
    namesQuest = "برخیز، تندرفوری!",
    namesObj = "صندوق گنج آتش‌خاک",
    terms = "hit rating، attack power، stamina",
    textDesc = "به هنگام پوشیدن: قدرت حملهٔ شما ۶۰۰ افزایش می‌یابد.",
    textStats = "+۸ استقامت · ۳۰۰ آسیب طبیعت",
    textReq = "نیازمند سطح ۶۰ · نیازمند جنگاور",
    textBind = "مقید به روح · هنگام برداشتن قید می‌شود · یکتا",
    textDetail = "شنل · چرم · دوام ۲۰ / ۲۵ · قیمت فروش",
    textFlavor = "هیچ‌کس ندانست این تیغه از کجا آمد…",
    textSet = "(۲) ست: +۵ مقاومت در برابر اسرار",
    questText = "اهداف: ۰ از ۱ انجام شد",
    npcSay = "عنوان کوئست‌ها در پنجرهٔ گفتگوی NPC",
    faDigits = "۷۳ زره به‌جای 73 Armor",
    greyNotes = "یادداشت خاکستری زیر خط‌های ترجمه‌نشده",
}
L.HINT_IDLE = "روی هر خط بایست تا کلیدش را ببینی؛ کلیک = رفتن به همان کلید"
L.PLACE_LBL = { "جایگزین انگلیسی", "زیر تولتیپ" }
L.ROOM_TAB_LBL = { item = "آیتم", set = "ست", quest = "کوئست", npc = "NPC" }


-- 101 PR 6 (B5): the stray Persian strings moved here byte for byte from
-- Panel.lua by script (the strings moved, never retyped).
L.PAGE_FAILED = "این صفحه ساخته نشد: "
L.NPC_EN = "Highlord Demitrian"
L.NPC_FA = "هایلرد دمیتریان"
L.preview_quests_off = "ترجمهٔ کوئست‌ها الان خاموش است (صفحهٔ خانه)؛ در بازی هم همین انگلیسی دیده می‌شود."
