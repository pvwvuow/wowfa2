## task 0353-dump-panel (script)

**GREEN**


### Locale.lua

```
    4 -- the English table L.en instead.
    6 local L = {}
    9 L.subtitle = "ترجمهٔ فارسی WoW Forever"
   10 L.master = "WoWFA روشن باشه"
   11 L.master_d = "کلید اصلی. وقتی خاموشه هیچ متن فارسی~ای به بازی اضافه نمی~شه."
   13 L.tab_home = "خانه"
   14 L.tab_room = "اتاق کاستوم ترجمه"
   15 L.tab_surfaces = "چه چیزی ترجمه شود"
   16 L.tab_mods = "بخش~ها"
   17 L.tab_names = "اسم~ها"
   18 L.tab_display = "نمایش"
   19 L.tab_health = "وضعیت"
   20 L.tab_about = "درباره"
   21 L.tab_capture = "کمک به دیتا"
   22 L.h_summary = "وضعیت بخش~ها"
   23 L.d_scale = "اندازهٔ پنجرهٔ تنظیمات"
   25 L.m_items = "آیتم~ها"
   26 L.m_items_d = "نام و توضیح فارسی زیر تولتیپ آیتم~ها."
   27 L.m_quests = "کوئست~ها"
   28 L.m_quests_d = "متن کامل کوئست کنار پنجرهٔ کوئست و دفترچهٔ کوئست."
   29 L.m_dungeons = "دانجن و مناطق"
   30 L.m_dungeons_d = "نام فارسی منطقه و دانجن موقع ورود و روی نقشهٔ کوچک؛ حالت تازه: در خود متن."
   31 L.m_tracker = "دنبال~کنندهٔ کوئست"
   32 L.m_tracker_d = "عنوان و اهداف کوئست~های در حال انجام، عنوان~های دفترچه و گفتگو، همه در خود متن بازی."
   33 L.tracker_slain = "کشته~شده"
   34 L.tracker_complete = "تکمیل~شده"
   35 L.tracker_ready = "آمادهٔ تحویل"
   36 L.m_npc = "NPC و اشیا"
   37 L.m_npc_d = "نام فارسی NPCها، باس~ها و اشیای دنیا روی تولتیپ."
   38 L.m_spellbook = "اسپل~بوک"
   39 L.m_spellbook_d = "نام و توضیح فارسی اسپل~ها در تولتیپ."
   40 L.m_talents = "تلنت~ها"
   41 L.m_talents_d = "نام و توضیح فارسی تلنت~ها در تولتیپ."
   42 L.m_talents_shared = "در این کلاینت تولتیپ تلنت با تولتیپ اسپل~بوک یکی است."
   43 L.m_capture = "کمک به دیتا"
   44 L.m_capture_d = "ذخیرهٔ اختیاری چیزهایی که در بازی می~بینی برای دیتای سایت (غنیمت، فروشنده، کوئست). پیش~فرض خاموش."
   46 L.tab_capture = "کمک به دیتا"
   47 L.cap_head = "اگه خودت بخوای، اددان چیزهایی که در بازی می~بینی رو توی همون فایل تنظیمات ذخیره می~کنه تا بعداً خودت برای دیتای سایت آپلودش کنی. هیچ چیز خودکار جایی ارسال نمی~شه."
   48 L.cap_toggle = "کمک به دیتای سایت: ذخیرهٔ چیزهایی که در بازی می~بینی"
   49 L.cap_counts = "ثبت~شده~ها: آیتم %d · فروشنده %d · غنیمت %d · کوئست %d · NPC %d"
   50 L.cap_size = "حجم حدود %s"
   51 L.cap_empty = "هنوز چیزی ثبت نشده."
   52 L.cap_clear = "پاک کردن همهٔ ثبت~شده~ها"
   53 L.cap_file = "محل ذخیره: WTF/Account/<account>/SavedVariables/WoWFA.lua — آپلود بعداً و فقط با خودت."
   54 L.cap_locale = "زبان بازی انگلیسی نیست؛ متن~ها ذخیره نمی~شن (فقط شناسه~ها و قیمت~ها)."
   55 L.w_capture = "این اددان به دیتای سایت هم کمک می~کنه — فقط اگه خودت توی صفحهٔ «کمک به دیتا» روشنش کنی. پیش~فرض خاموشه."
   57 L.st_ok = "سالم"
   58 L.st_warn = "هشدار"
   59 L.st_off = "خاموش"
   60 L.st_master = "کلید اصلی خاموشه"
   61 L.st_nodata = "داده نداره"
   62 L.st_schema = "داده ناسازگاره"
   63 L.st_noapi = "خودکار خاموش شد"
   64 L.st_update = "متوقف: آپدیت بازی"
   65 L.st_fault = "خودکار خاموش شد: خطا"
   67 L.why_nodata = "ترجمهٔ این بخش هنوز توی این نسخه نیست."
   68 L.why_schema = "فرمت داده با این نسخهٔ اددان جور نیست. اددان رو کامل آپدیت کن."
   69 L.why_noapi = "این بخش در این نسخهٔ بازی در دسترس نیست."
   70 L.why_via_spellbook = "تولتیپ تلنت در این کلاینت از راه اسپل~بوک پوشش داده می~شود."
   71 L.why_update = "بازی بعد از ساخت این ترجمه آپدیت شده و این بخش حساسه، پس موقتاً متوقفه. آپدیت اددان رو چک کن، یا اگه مشکلی نمی~بینی روشنش کن."
   72 L.why_warn_build = "بازی جدیدتر از داده~های ترجمه~ست؛ شاید بعضی متن~ها قدیمی باشن."
   73 L.why_warn_miss = "بیشتر متن~های این بخش پیدا نشدن؛ احتمالاً بازی آپدیت شده. آپدیت اددان رو چک کن."
   74 L.why_fault = "این بخش چند بار پشت هم خطا داد و برای اینکه بازیت به مشکل نخوره خاموش شد."
   75 L.btn_resume = "با همین نسخه روشن کن"
   76 L.btn_retry = "دوباره امتحان کن"
   78 L.names_head = "مثل سایت: هر دسته~ای که خاموش باشه، اون نام~ها توی متن ترجمه انگلیسی می~مونن."
   79 L.n_npc = "NPCها"
   80 L.n_npc_x = "مثلاً Hogger -> هاگر"
   81 L.n_zn = "مناطق"
   82 L.n_zn_x = "مثلاً Westfall -> وستفال"
   83 L.n_it = "آیتم~ها"
   84 L.n_it_x = "مثلاً Tough Jerky -> گوشت تند"
   85 L.n_sp = "اسپل و مهارت"
   86 L.n_sp_x = "مثلاً Aspect of the Hawk -> شکل شاهین"
   87 L.n_ob = "اشیا"
   88 L.n_ob_x = "مثلاً Brazier of Marl -> آتشدان مارل"
   89 L.n_qs = "عنوان کوئست~ها"
   90 L.n_qs_x = "مثلاً Shadumbra's Head -> سر شادمبرا"
   91 L.n_cls = "کلاس~ها"
   92 L.n_cls_x = "مثلاً Hunter -> شکارچی"
   93 L.n_tm = "اصطلاحات بازی"
   94 L.n_tm_x = "مثلاً Hearthstone -> سنگ راهخانه"
   95 L.all_on = "همه روشن"
   96 L.all_off = "همه خاموش"
   99 -- one-line description each. The descriptions say exactly WHAT is translated.
  100 L.surf_head = "دقیقاً مشخص کن کدوم بخش~ها فارسی بشن. هر کلید بی~درنگ اثر می~کنه؛ با خاموش~کردنش همان انگلیسیِ بازی برمی~گردد."
  101 L.g_items = "آیتم~ها"
  102 L.g_quests = "کوئست~ها"
  103 L.g_zones = "مناطق"
  104 L.g_npc = "NPC و اشیا"
  105 L.g_spells = "اسپل و تلنت"
  106 L.s_itemtip = "تولتیپ آیتم"
  107 L.s_itemtip_d = "نام و توضیح فارسی روی تولتیپ آیتم~ها."
  108 L.s_questPane = "پنجرهٔ متن کوئست"
  109 L.s_questPane_d = "پنجرهٔ فارسی متن کوئست کنار پنجرهٔ بازی."
  110 L.s_questLog = "عنوان~های دفترچه"
  111 L.s_questLog_d = "عنوان فارسی کوئست~ها توی فهرست دفترچه."
  112 L.s_gossip = "دکمه~های گفتگو"
  113 L.s_gossip_d = "عنوان کوئست روی دکمه~های گفتگو با NPC."
  114 L.s_trackerTitle = "عنوان در ترکر"
  115 L.s_trackerTitle_d = "عنوان فارسی کوئست~های در حال انجام در دنبال~کننده."
  116 L.s_trackerObj = "هدف~ها در ترکر"
  117 L.s_trackerObj_d = "خط~های هدف (کشته~شده، آیتم جمع~شده و ...) در دنبال~کننده."
  118 L.s_zoneArrival = "متن ورود وسط صفحه"
  119 L.s_zoneArrival_d = "نام منطقه موقع ورود، وسط صفحه."
  120 L.s_zoneMinimap = "اسم بالای نقشهٔ کوچک"
  121 L.s_zoneMinimap_d = "نام منطقه بالای نقشهٔ کوچک، در خود متن."
  122 L.s_zoneMap = "نقشهٔ بزرگ"
  123 L.s_zoneMap_d = "نام منطقه روی نقشهٔ جهان و برچسب هاور."
  124 L.s_zoneTip = "تولتیپ نقشهٔ کوچک"
  125 L.s_zoneTip_d = "نام فارسی منطقه در تولتیپ نقشهٔ کوچک."
  126 L.s_npcTip = "تولتیپ NPC"
  127 L.s_npcTip_d = "نام فارسی NPCها و باس~ها روی تولتیپ."
  128 L.s_objTip = "تولتیپ اشیا"
  129 L.s_objTip_d = "نام فارسی اشیای دنیا روی تولتیپ."
  131 L.d_size = "اندازهٔ فونت"
  132 L.d_item = "جزئیات آیتم"
  133 L.opt_item = { "فقط نام", "نام و جلوه~ها", "کامل" }
  134 L.d_dock = "جای پنل کوئست"
  135 L.opt_dock = { "سمت راست پنجره", "سمت چپ پنجره", "آزاد، جابه~جاش کن" }
  136 L.d_qauto = "پنل کوئست خودکار باز بشه"
  137 L.d_zone = "اعلان نام منطقه"
  138 L.opt_zone = { "همهٔ مناطق", "فقط دانجن و ریید", "خاموش", "در خود متن" }
  139 L.d_update = "وقتی بازی آپدیت شد"
  140 L.opt_update = { "فقط هشدار بده", "بخش~های حساس رو متوقف کن", "همه رو متوقف کن" }
  141 L.d_digits = "عددهای زنده فارسی باشن"
  142 L.d_itemstyle = "شکل تولتیپ آیتم"
  143 L.opt_itemstyle = { "خودِ تولتیپ فارسی شود (مثل سایت)", "فارسی زیر تولتیپ" }
  144 L.d_minimap = "دکمهٔ کنار نقشهٔ کوچک"
  145 L.d_toast = "پیام~های اددان روی صفحه"
  146 L.d_share = "خبر نسخهٔ جدید از هم~گروهی~ها"
  147 L.d_itemnotes = "یادداشت~های خاکستری روی آیتم~ها"
  148 L.d_resetpos = "بازنشانی جای پنجره~ها"
  149 L.d_preview = "پیش~نمایش (حالت فعلی)"
  150 L.d_preview_rows = { "+10 روح", "۱۰٪ بیشتر", "ادامهٔ داستان در Dreadmaul Rock..." }
  152 L.h_client = "نسخهٔ بازی"
  153 L.h_data = "نسخهٔ داده~های ترجمه"
  154 L.h_addon = "نسخهٔ اددان"
  155 L.h_mem = "حافظه"
  156 L.h_errors = "خطاهای اخیر؛ برای گزارش کپی کن و بفرست"
  157 L.h_noerr = "خطایی ثبت نشده."
  158 L.btn_recheck = "بررسی دوباره"
  159 L.btn_clear = "پاک کردن خطاها"
  160 L.h_miss_n = "متن~های بدون ترجمه که دیدی: %d؛ روی کادر کلیک کن، Ctrl+C و برام بفرست"
  161 L.sec_general = "عمومی"
  162 L.sec_quests = "مأموریت~ها"
  163 L.sec_tracker = "ردیاب مأموریت"
  164 L.sec_map = "نقشه و مناطق"
  165 L.sec_spellbook = "کتاب جادو"
  166 L.sec_talents = "استعدادها"
  167 L.sec_health = "وضعیت"
  168 L.sec_about = "درباره"
  169 L.g_names = "نام~ها و واژه~ها در متن~ها"
  170 L.g_defaults = "نمایش پیش~فرض همهٔ بخش~ها"
  171 L.d_title = "نام (عنوان)"
  172 L.d_desc = "توضیحات"
  173 L.opt_title = { "فقط فارسی", "فارسی و انگلیسی زیرش", "فقط انگلیسی" }
  174 L.opt_desc = { "فارسی به جای انگلیسی", "فارسی زیر انگلیسی", "خاموش (انگلیسی)" }
  175 L.d_sep = "تنظیم جدا برای این بخش"
  176 L.d_sep_d = "خاموش یعنی این بخش از «عمومی» پیروی می~کند"
  177 L.h_state = "وضعیت این بخش"
  178 L.n_tracker = "نام و هدف مأموریت~ها در ردیاب با کلید «نام مأموریت~ها» در بخش مأموریت~ها ترجمه می~شود."
  179 L.n_disp = "تغییر نمایش از دفعهٔ بعدی که راهنمای اسپل را می~بینی اعمال می~شود."
  180 L.sec_colors = "رنگ~ها"
  181 L.col_on = "رنگی کردن نام~ها"
  182 L.col_on_d = "نام منطقه، اسپل، شخصیت و ... در متن~ها و راهنماها با رنگ انتخابی نشان داده می~شود"
  183 L.col_hdr = "رنگ هر نوع نام"
  184 L.col_zn = "مناطق و نقشه"
  185 L.col_sp = "اسپل~ها و استعدادها"
  186 L.col_npc = "شخصیت~ها (NPC)"
  187 L.col_cls = "کلاس~ها"
  188 L.col_it = "آیتم~ها"
  189 L.col_tm = "اصطلاحات"
  190 L.col_ob = "اشیای دنیای بازی"
  191 L.col_note = "رنگ فقط روی نام~هایی اثر می~گذارد که ترجمه شده~اند."
  192 L.col_id = { off = "خاموش", green = "سبز", blue = "آبی", gold = "طلایی", orange = "نارنجی", red = "قرمز",
  193     purple = "بنفش", cyan = "فیروزه~ای", pink = "صورتی", white = "سفید", class = "رنگ رسمی کلاس" }
  194 L.sec_npc = "شخصیت~ها (NPC)"
  195 L.sec_share = "اشتراک~گذاری"
  196 L.d_npcname = "نام شخصیت~ها بالای سرشان"
  197 L.opt_npc = { "فارسی", "فارسی و انگلیسی زیرش", "انگلیسی" }
  198 L.n_npc = "نام بالای سر شخصیت~ها وقتی دیده می~شود که نمایش نام~ها روشن باشد (کلید V). روی راهنمای شخصیت و نام هدف هم اثر می~کند."
  199 L.sh_mine = "کد تنظیمات من"
  200 L.sh_mine_d = "این کد همهٔ انتخاب~های تو را دارد: روی کادر کلیک کن، Ctrl+C بزن و به بقیه بده."
  201 L.sh_use = "گذاشتن کد دیگران"
  202 L.sh_use_d = "کدی که از کسی گرفته~ای را اینجا بچسبان (Ctrl+V) و «اعمال کد» را بزن."
  203 L.sh_apply = "اعمال کد"
  204 L.sh_ok = "تنظیمات اعمال شد."
  205 L.d_listtitles = "عنوان کوئست~ها در لیست «همهٔ هدف~ها» کنار نقشه فارسی باشد"
  206 L.btn_miss_clear = "پاک کردن فهرست"
  207 L.btn_select = "انتخاب برای کپی"
  209 L.a_site = "سایت و آپدیت~ها"
  210 L.a_cmds = "دستورها: /wowfa پنل، /wowfa on یا off، /wowfa status، /wowfa reset"
  211 L.a_new = "چه خبر"
  212 L.changelog = {
  223 }
  224 L.btn_welcome = "نمایش دوبارهٔ خوش~آمد"
  225 L.btn_reset = "بازنشانی همهٔ تنظیمات"
  226 L.btn_reset_sure = "مطمئنی؟ دوباره بزن"
  228 L.w_title = "به WoWFA خوش اومدی"
  229 L.w_scope = "در نسخهٔ 1.0 کوئست~ها، اسم مناطق، اسپل~ها و تلنت~ها فارسی می~شوند. آیتم~ها و بقیهٔ بخش~ها به~زودی می~آیند."
  230 L.w_choose = "چه چیزی ترجمه شود؟"
  231 L.p_all = "پیشنهادی"
  232 L.p_all_d = "کوئست~ها، اسم مناطق، اسپل~ها و تلنت~ها فارسی می~شوند؛ بخش~های دیگر به~زودی باز می~شوند."
  233 L.p_qi = "فقط کوئست~ها"
  234 L.p_qi_d = "فقط متن کوئست~ها و اسم مناطق فارسی می~شود؛ اسپل~ها و تلنت~ها انگلیسی می~مانند."
  235 L.p_custom = "سفارشی"
  236 L.p_custom_d = "خودت در صفحهٔ «چه چیزی ترجمه شود» تک~تک انتخاب کن."
  237 L.w_start = "شروع"
  238 L.w_later = "بعداً"
  240 L.mm_status = "همه~چیز فارسیه و سالم"
  241 L.mm_left = "کلیک: باز کردن پنل"
  242 L.mm_right = "راست~کلیک: روشن یا خاموش"
  243 L.mm_drag = "بکش تا جابه~جا بشه"
  244 L.mm_issue = "یک بخش نیاز به توجه داره"
  245 L.open_panel = "باز کردن پنل WoWFA"
  247 L.q_fabtn_tip = "متن فارسی کوئست"
  249 L.t_tripped = "بخش «%s» به خاطر خطا خودکار خاموش شد. جزئیات توی پنل، بخش وضعیت."
  250 L.t_update = "بازی آپدیت شده. بخش~های حساس موقتاً متوقف شدن تا آپدیت اددان رو بگیری."
  251 L.t_newver = "نسخهٔ جدید WoWFA منتشر شده: %s. از wowfarsi.ir بگیرش."
  252 L.t_miss = "متن~های بخش «%s» دیگه با بازی جور نیست؛ احتمالاً آپدیت اومده."
  253 L.t_upgraded = "WoWFA به نسخهٔ %s آپدیت شد."
  254 L.t_nodata = "داده~های ترجمه پیدا نشد؛ اددان رو دوباره نصب کن."
  255 L.t_on = "WoWFA روشن شد."
  256 L.t_off = "WoWFA خاموش شد."
  258 L.stale_item = "(!) آمار این آیتم توی بازی عوض شده؛ فقط نام نشون داده شد."
  259 L.item_unverified = "جزئیات این آیتم در Forever تأیید نشده است"
  260 L.item_unconfirmed = "برخی جزئیات تأیید نشده~اند"
  261 L.item_absent = "این آیتم در فایل~های بازی Forever نیست"
  264 -- carry - EN exact or %s/%d pattern -> Persian. Every word comes from the
  269 L.s_names_it = "اسم آیتم فارسی باشد"
  270 L.s_names_it_d = "نام آیتم~ها روی تولتیپ فارسی نوشته شود."
  271 L.s_itemLines = "متن تولتیپ فارسی باشد"
  272 L.s_itemLines_d = "خط~های تولتیپ آیتم (زره، استت~ها، ست و ...) فارسی شوند؛ خاموش = فقط اسم."
  273 L.s_itemDetail = "میزان ترجمه"
  274 L.s_itemDetail_d = "همه = تمام خط~ها؛ فقط مهم = خط~های اصلی؛ فقط اسم = تنها نام فارسی شود."
  275 L.s_itemStyle = "جای فارسی"
  276 L.s_itemStyle_d = "سر جای خودش = خط~های خود تولتیپ فارسی می~شوند؛ زیر تولتیپ = بلوک جدا."
  277 L.s_itemNotes = "یادداشت خاکستری «تأیید نشده»"
  278 L.s_itemNotes_d = "وقتی عددی با بازی نخواند، یادداشت صداقت نمایش داده شود."
  279 L.s_qobj = "شرح مراحل کوئست"
  280 L.s_qobj_d = "شرح فارسی هدف~های کوئست در پنجرهٔ کوئست نمایش داده شود."
  281 L.choice_on = "همه"
  282 L.choice_important = "فقط مهم"
  283 L.choice_name = "فقط اسم"
  284 L.choice_inplace = "سر جای خودش"
  285 L.choice_below = "زیر تولتیپ"
  286 L.home_more = "تنظیمات بیشتر"
  287 L.st_on = "روشن"
  288 L.st_off = "خاموش"
  289 L.home_items = "آیتم~ها"
  290 L.home_quests = "کوئست~ها"
  291 L.home_names = "اسم~ها و منطقه~ها"
  293 -- Generated from wowfa-packs/out/text-strings-cooldown.json; do not hand-edit values.
  294 L.cooldown = {
  301 }
  303 L.tip = {
  345     -- stands. The fa of the %d patterns uses %s like the existing rows.
  362 }
  363 L.stale_quest = "(!) متن این کوئست توی بازی عوض شده؛ ترجمه شاید قدیمی باشه."
  364 L.q_obj = "هدف"
  365 L.q_details = "شرح"
  366 L.q_progress = "در جریان"
  367 L.q_complete = "پایان"
  368 L.zone_dungeon = "دانجن"
  369 L.zone_raid = "ریید"
  370 L.d_map = "اسم مناطق روی نقشهٔ بزرگ"
  371 L.opt_map = { "فقط فارسی (جای انگلیسی)", "فارسی، انگلیسی زیرش", "ترجمه نشه (انگلیسی)" }
  373 L.class = {
  376 }
  377 L.race = {
  380 }
  383 L.en = {
  385     m_spellbook = "Spellbook", m_talents = "Talents", m_capture = "Site data helper",
  389     build = "WoWFA: game build %s is newer than the translation data (%s). Texts may be slightly out of date; check wowfarsi.ir for an update.",
  392     miss = "WoWFA: most '%s' texts no longer match the game. An addon update is probably needed.",
  403 }
  409 L.VIEW_TITLE = { vocab = "واژه~نامهٔ بازی", texts = "خط~های تولتیپ آیتم", quest = "کوئست و گفتگو",
  410     share = "پروفایل و اشتراک~گذاری" }
  411 L.ROOM_ROWS = {
  412     root = {
  413         { k = "faDigits", lbl = "اعداد فارسی" },
  414     },
  415     vocab = {
  416         { k = "namesItem", lbl = "اسم آیتم~ها" },
  417         { k = "namesSet", lbl = "اسم ست~ها و تکه~های ست" },
  418         { k = "namesSpell", lbl = "اسم اسپل~ها و استعدادها" },
  419         { k = "namesClass", lbl = "اسم کلاس~ها و شاخه~ها" },
  420         { k = "namesNpc", lbl = "اسم شخصیت~ها و موجودها" },
  421         { k = "namesZone", lbl = "اسم مناطق و دانجن~ها" },
  422         { k = "namesQuest", lbl = "عنوان کوئست~ها" },
  423         { k = "namesObj", lbl = "اسم آبجکت~ها" },
  424         { k = "terms", lbl = "اصطلاح~های بازی" },
  425     },
  426     texts = {
  427         { k = "textDesc", lbl = "توضیحات و افکت~ها" },
  428         { k = "textStats", lbl = "متن آمار (چابکی، استقامت و …)" },
  429         { k = "textReq", lbl = "نیازمندی~ها" },
  430         { k = "textBind", lbl = "اتصال و یکتایی" },
  431         { k = "textDetail", lbl = "جزئیات آیتم" },
  432         { k = "textFlavor", lbl = "متن~های تزئینی" },
  433         { k = "textSet", lbl = "بونوس~های ست" },
  434         { k = "greyNotes", lbl = "یادداشت خاکستری" },
  435     },
  436     quest = {
  437         { k = "questText", lbl = "متن کوئست~ها" },
  438         { k = "npcSay", lbl = "گفتگوی NPC" },
  439     },
  440 }
  441 L.ROOM_EX = {
  451     textDesc = "به هنگام پوشیدن: قدرت حملهٔ شما ۶۰۰ افزایش می~یابد.",
  452     textStats = "+۸ استقامت · ۳۰۰ آسیب طبیعت",
  453     textReq = "نیازمند سطح ۶۰ · نیازمند جنگاور",
  454     textBind = "مقید به روح · هنگام برداشتن قید می~شود · یکتا",
  455     textDetail = "شنل · چرم · دوام ۲۰ / ۲۵ · قیمت فروش",
  456     textFlavor = "هیچ~کس ندانست این تیغه از کجا آمد…",
  457     textSet = "(۲) ست: +۵ مقاومت در برابر اسرار",
  458     questText = "اهداف: ۰ از ۱ انجام شد",
  462 }
  463 L.HINT_IDLE = "روی هر خط بایست تا کلیدش را ببینی؛ کلیک = رفتن به همان کلید"
  464 L.PLACE_LBL = { "جایگزین انگلیسی", "زیر تولتیپ" }
  465 L.ROOM_TAB_LBL = { item = "آیتم", set = "ست", quest = "کوئست", npc = "NPC" }
  470 L.PAGE_FAILED = "این صفحه ساخته نشد: "
  471 L.NPC_EN = "Highlord Demitrian"
  472 L.NPC_FA = "هایلرد دمیتریان"
  473 L.preview_quests_off = "ترجمهٔ کوئست~ها الان خاموش است (صفحهٔ خانه)؛ در بازی هم همین انگلیسی دیده می~شود."
```
- ok: Locale.lua: 326 lines

### Locale_Opt.lua

```
    1 -- WoWFA Forever - rc30 texts: the switches and sliders of the new things
    3 -- named by their English text (the client has no global name we know for them;
    4 -- a row whose first field holds a space is the English text itself).
   13 L.ls_size = fa("اندازهٔ فونت لیست مأموریت~ها و ردیاب (درصد)")
   14 L.al_size = fa("اندازهٔ هشدارهای میان صفحه (درصد)")
   15 L.fa_size = fa("اندازه فونت متن~های بازی (درصد)")
   16 L.sec_sizes = fa("اندازه فونت~ها")
   17 L.sz_intro = fa("همه اسلایدرهای اندازه اینجا هستند. هر اسلایدر فقط یک گروه از متن~ها را عوض می~کند و با اسلایدر دیگر قاطی نمی~شود.")
   18 L.sz_own_h = fa("متن~های فارسی خود ادآن")
   19 L.sz_own_d = fa("تولتیپ~ها، توضیح اسپل~ها و تلنت~ها، پنجره مأموریت و اسم اسپل~ها در کتاب اسپل. لیست مأموریت و متن~های بازی را عوض نمی~کند.")
   20 L.sz_list_h = fa("لیست مأموریت~ها و ردیاب")
   21 L.sz_list_d = fa("فقط خط~های فارسی لیست مأموریت کنار نقشه (کلید M) و ردیاب. در ۱۰۰ درصد عنوان ۱۳ و هدف ۱۲ است. خطی که از ردیف بلندتر شود خودش کوچک می~شود تا توی هم نرود.")
   22 L.sz_all_h = fa("متن~های خود بازی (انگلیسی هم)")
   23 L.sz_all_d = fa("اندازه متن~های خود بازی، انگلیسی هم. ۱۰۰ درصد = اندازه خود بازی. با کلید بالا خاموش یا روشن کار می~کند. چت و هشدارها اسلایدر جدا دارند.")
   24 L.sz_other_h = fa("چت، هشدارها و پنجره تنظیمات")
   25 L.sz_chat_d = fa("فقط پنجره~های چت و کادر نوشتن.")
   26 L.sz_alert_d = fa("فقط پیام~های قرمز وسط صفحه.")
   27 L.sz_win_d = fa("فقط خود پنجره تنظیمات.")
   28 L.sy_sysLoot = fa("پیام~های غنیمت و پول")
   29 L.sy_sysXp = fa("پیام~های تجربه، سطح و مأموریت~ها")
   30 L.sy_sysRep = fa("پیام~های اعتبار، مهارت و جادوی تازه")
   31 L.sy_sysGroup = fa("پیام~های گروه و AFK")
   33 L.pf_hdr = fa("پروفایل~های من")
   34 L.pf_d = fa("تنظیمات فعلی (بخش~ها، نمایش، رنگ~ها، اندازه~ها و هشدارها) را با یک اسم ذخیره کن و بعداً با یک کلیک «اعمال» برگردان. اسم را در کادر زیر بنویس. پروفایل~ها برای همهٔ کاراکترهای این اکانت مشترک~اند (حداکثر ۱۰).")
   35 L.pf_save = fa("ذخیرهٔ پروفایل")
   36 L.pf_load = fa("اعمال")
   37 L.pf_del = fa("حذف")
   38 L.pf_del_sure = fa("مطمئنی؟")
   39 L.pf_saved = fa("پروفایل «%s» ذخیره شد.")
   40 L.pf_updated = fa("پروفایل «%s» به~روز شد.")
   41 L.pf_loaded = fa("پروفایل «%s» اعمال شد.")
   42 L.pf_deleted = fa("پروفایل «%s» حذف شد.")
   43 L.pf_none = fa("هنوز پروفایلی نساخته~ای. یک اسم بنویس و «ذخیرهٔ پروفایل» را بزن.")
   45 L.rp_hdr = fa("گزارش برای ما: چیزهایی که هنوز فارسی نیستند")
   46 L.rp_d = fa("خط پایین هر چیزی است که افزونه در بازی دید و فارسی~اش را نداشت (هشدار، اسم NPC، منطقه و...). «انتخاب برای کپی» را بزن، بعد Ctrl+C، و متن را در سایت wowfarsi.ir/report یا در سرور دیسکورد wowfarsi برای ما بفرست تا در نسخهٔ بعد فارسی شود. کوئست~ها و NPC~های تازه هم خودکار جمع می~شوند (/wowfa harvest). اسم بازیکن~ها و پت~ها هیچ~وقت ترجمه نمی~شود.")
   47 L.btn_miss_copy = fa("انتخاب برای کپی")
   50 L.rp2_hdr = fa("گزارش برای ما")
   51 L.rp2_steps = fa("هر چیزی که افزونه در بازی می~بیند و هنوز فارسی~اش را ندارد (مأموریت، متن و هدف مأموریت، اسم NPC، منطقه، اسپل، هشدار و...) خودکار اینجا جمع می~شود. برای فرستادن: ۱) دکمهٔ «انتخاب متن گزارش» را بزن. ۲) Ctrl+C را بزن. ۳) در سایت wowfarsi.ir/report بچسبان (Ctrl+V) و «ارسال گزارش» را بزن.")
   52 L.rp2_count = fa("%d مورد بدون ترجمه پیدا شد:")
   53 L.rp2_none = fa("هنوز چیز بدون ترجمه~ای پیدا نشده. بازی کن؛ هر متن انگلیسی خودکار اینجا اضافه می~شود.")
   54 L.rp2_box = fa("متن گزارش (همین را کپی کن):")
   55 L.rp2_btn = fa("انتخاب متن گزارش")
   56 L.rp2_copied = fa("انتخاب شد. حالا Ctrl+C را بزن و در wowfarsi.ir/report بچسبان.")
   57 L.rp2_sep = "، "
   58 L.MISS_KIND = {
   60     qtext = fa("متن مأموریت"),
   70 }
   72 L.ALERTS = L.ALERTS or {}
   73 L.ALERTS[#L.ALERTS + 1] = { "Internal mail database error.", fa("خطای داخلی پایگاه دادهٔ نامه~ها.") }
   74 L.ALERTS[#L.ALERTS + 1] = { "The item was not found.", fa("آیتم پیدا نشد.") }
   75 L.ALERTS[#L.ALERTS + 1] = { "You are mounted.", fa("شما سوار مرکب هستید.") }
   76 L.ALERTS[#L.ALERTS + 1] = { "Your pet is dead. Use Revive Pet.", fa("پت شما مرده است. از Revive Pet استفاده کنید.") }
   77 L.ALERTS[#L.ALERTS + 1] = { "You do not have a pet to summon.", fa("پتی برای احضار ندارید.") }
   78 L.ALERTS[#L.ALERTS + 1] = { "Discovered: %s", fa("کشف شد: %s") }
   79 L.ALERTS[#L.ALERTS + 1] = { "There is no loot.", fa("غنیمتی وجود ندارد.") }
   81 L.ALERTS[#L.ALERTS + 1] = { "You are too far away.", fa("خیلی دور هستید.") }
   82 L.ALERTS[#L.ALERTS + 1] = { "Must have ammo equipped in the ammo slot.", fa("باید مهمات را در جایگاه مهمات بگذارید.") }
   84 L.ALERTS[#L.ALERTS + 1] = { "You need to be closer to interact with that target.", fa("برای تعامل با این هدف باید نزدیک~تر بروید.") }
   85 L.ALERTS[#L.ALERTS + 1] = { "You don't have a pet!", fa("پت ندارید!") }
   86 L.ALERTS[#L.ALERTS + 1] = { "Thank you for your report!", fa("از گزارش شما سپاسگزاریم!") }
   90 -- { Lua pattern of the English line, replacement } - read by Modules/Zones.lua fa().
   91 L.MAP_LINES = {
   92     { "^Fishing: (%d+)$", fa("ماهیگیری: %1") },
   93     { "^Quests: (%d+)/(%d+)$", fa("کوئست~ها: %1/%2") },
   94     { "^(%(?)Dungeon(%)?)$", "%1" .. fa("دانجن") .. "%2" },
   95     { "^(%(?)Raid(%)?)$", "%1" .. fa("ریید") .. "%2" },
   96     { "^(%(?)Elite(%)?)$", "%1" .. fa("نخبه") .. "%2" },
   97     { "^(%(?)Group(%)?)$", "%1" .. fa("گروهی") .. "%2" },
   98     { "^(%(?)Complete(%)?)$", "%1" .. fa("تکمیل~شده") .. "%2" },
   99     { "^(%(?)Failed(%)?)$", "%1" .. fa("ناموفق") .. "%2" },
  100 }
```
- ok: Locale_Opt.lua: 71 lines

### Locale_Dlg.lua

```
    4 L.sec_dialog = "گفتگو و کتاب~ها"
    5 L.dl_intro = "حرف~های NPCها (متن پنجرهٔ گفتگو و خوش~آمد، حرف~هایی که در چت و بالای سرشان می~زنند) و متن کتاب~ها، نامه~ها و تابلوها. هر متنی که هنوز فارسی ندارد به انگلیسی در گزارش صفحهٔ «وضعیت» ثبت می~شود تا در آپدیت بعدی فارسی شود."
    6 L.dl_gossip = "متن پنجرهٔ گفتگو و خوش~آمد NPC"
    7 L.dl_say = "حرف~های NPC در چت و بالای سرشان"
    8 L.dl_book = "کتاب~ها، نامه~ها و تابلوها"
    9 L.dl_note = "ترجمه کنار پنجرهٔ خود بازی نشان داده می~شود. هر وقت Shift را نگه داری، متن اصلی انگلیسی را می~بینی."
   10 L.dl_shift = "با نگه~داشتن Shift متن اصلی انگلیسی دیده شود"
   11 if type(L.MISS_KIND) == "table" then
   12     L.MISS_KIND.dlg = "گفتگوی NPC"
   13     L.MISS_KIND.say = "حرف NPC"
   14     L.MISS_KIND.book = "کتاب و نامه"
   17 L.fl_hdr = "پوشهٔ فایل WoWFA.lua"
   18 L.fl_steps = "۱) «ذخیرهٔ فایل» را بزن تا بازی فایل را همین الان بنویسد (یک /reload است).  ۲) «انتخاب مسیر» را بزن و Ctrl+C.  ۳) در ویندوز Win+R، بعد Ctrl+V و Enter: پوشه مستقیم باز می~شود. در مک: Finder، بعد Cmd+Shift+G و Cmd+V."
   19 L.fl_btn = "انتخاب مسیر پوشه"
   20 L.fl_save = "ذخیرهٔ فایل (/reload)"
   21 L.fl_copied = "مسیر انتخاب شد: Ctrl+C، بعد Win+R و Ctrl+V و Enter."
   22 L.fl_saved = "مسیر ذخیره شد؛ دفعهٔ بعد همین باز می~شود."
   23 L.fl_combat = "وسط نبرد نمی~شود؛ بعد از نبرد دوباره بزن."
   24 -- 1.1.0: factions, exact colours, the letter outline, Questie
   25 L.col_fac = "فکشن~ها و گروه~ها"
   26 if type(L.col_id) == "table" then
   27     L.col_id.custom = "دلخواه"
   29 L.col_pick = "رنگ دلخواه"
   30 L.col_pick_note = "دکمهٔ «رنگ دلخواه» کنار هر ردیف پنجرهٔ انتخاب رنگ بازی را باز می~کند: هر رنگی را دقیق انتخاب کن، تغییرش همان لحظه دیده می~شود و Cancel رنگ قبلی را برمی~گرداند. رنگ انتخاب~شده در فهرست همان ردیف با نام «دلخواه» می~ماند."
   31 L.ol_hdr = "حاشیهٔ حروف"
   32 L.ol_note = "هر ردیفی را روشن کنی، دور حروف فارسی همان دسته یک خط تیرهٔ نازک می~آید؛ خاموش یعنی همان شکل همیشگی. اسمی که وسط یک جمله است از ردیف «متن~ها» پیروی می~کند، چون بازی برای هر خط فقط یک حاشیه می~کشد. اسم آیتم~ها فعلاً انگلیسی و به شکل خود بازی هستند."
   33 L.ol_npc = "اسم NPCها (بالای سر، راهنما، قاب هدف، Questie)"
   34 L.ol_zn = "اسم مکان~ها (نقشه، مینی~مپ، ورود به منطقه)"
   35 L.ol_qs = "عنوان کوئست~ها (لیست کوئست، ترکر، Questie)"
   36 L.ol_sp = "اسم طلسم~ها (کتاب طلسم)"
   37 L.ol_text = "متن~ها (متن کوئست، توضیح طلسم، هدف~ها، گفتگو)"
   38 L.qz_on = "هماهنگی با Questie"
   39 L.qz_on_d = "عنوان کوئست~ها، اسم NPCها و هدف~ها در راهنمای نشانه~های نقشه، زیر راهنمای موجودات و در ترکرِ Questie هم فارسی می~شوند."
   40 L.qz_avail = "(در دسترس)"
   41 L.qz_complete = "(تکمیل~شده)"
   42 L.qz_shift = "(Shift را نگه دار)"
   43 L.qz_progress = "(در حال انجام)"
   44 L.qz_repeat = "(تکرارشونده)"
   45 L.fl_note = "این مسیرِ نصب پیش~فرض است و تا پوشهٔ Account می~رود؛ آنجا پوشهٔ اکانتت را باز کن و بعد SavedVariables. اگر بازی جای دیگری نصب است، یا می~خواهی مستقیم به SavedVariables برسی، یک بار مسیر درست را در جعبه بنویس یا Paste کن و Enter بزن؛ همیشه می~ماند (جعبهٔ خالی + Enter = مسیر پیش~فرض)."
```
- ok: Locale_Dlg.lua: 39 lines

### Locale_Sys.lua

```
    1 -- WoWFA Forever - rc29 texts: the system lines in the chat (loot, experience,
    3 -- Same idea as Locale_Alerts.lua: each row is { GlobalStrings name, Persian };
    5 -- the exact text this client shows (a name this client does not have is skipped).
    6 -- In the Persian text ~ is a half-space (ZWNJ). The alerts use %s / %d like
    7 -- Locale_Alerts.lua; the system lines use {1} {2} {3} for the values the
   16 L.sy_on = fa("پیام~های سیستم به فارسی")
   17 L.sy_on_d = fa("غنیمت، تجربه، سطح، اعتبار، مهارت و پیام~های گروه در چت فارسی نوشته می~شوند (چت فارسی هم باید روشن باشد)")
   19 L.pr_story = fa("فقط داستان")
   20 L.pr_story_d = fa("مأموریت~ها، اسم NPC و منطقه~ها فارسی؛ جادوها و آیتم~ها انگلیسی")
   21 L.pr_spells = fa("فقط جادوها")
   22 L.pr_spells_d = fa("جادوها و استعدادها فارسی؛ بقیه انگلیسی")
   24 -- more of the red messages in the middle of the screen (added to L.ALERTS)
   25 local MORE = {
   26     { "SPELL_FAILED_NOT_STANDING", "برای این کار باید ایستاده باشید" },
   27     { "SPELL_FAILED_ONLY_OUTDOORS", "این را فقط بیرون از ساختمان می~توانید به کار ببرید" },
   28     { "SPELL_FAILED_ONLY_INDOORS", "این را فقط داخل ساختمان می~توانید به کار ببرید" },
   29     { "SPELL_FAILED_NO_COMBO_POINTS", "این توانایی امتیاز ترکیبی لازم دارد" },
   30     { "SPELL_FAILED_TARGET_AURASTATE", "هنوز نمی~توانید این کار را بکنید" },
   31     { "SPELL_FAILED_CASTER_AURASTATE", "هنوز نمی~توانید این کار را بکنید" },
   32     { "SPELL_FAILED_ITEM_NOT_READY", "آیتم هنوز آماده نیست" },
   33     { "SPELL_FAILED_CASTER_DEAD", "شما مرده~اید" },
   34     { "SPELL_FAILED_STUNNED", "وقتی مبهوت هستید نمی~توانید این کار را بکنید" },
   35     { "SPELL_FAILED_SILENCED", "وقتی ساکت شده~اید نمی~توانید این کار را بکنید" },
   36     { "SPELL_FAILED_CONFUSED", "وقتی گیج هستید نمی~توانید این کار را بکنید" },
   37     { "SPELL_FAILED_FLEEING", "وقتی در حال فرار هستید نمی~توانید این کار را بکنید" },
   38     { "SPELL_FAILED_ALREADY_AT_FULL_HEALTH", "سلامتی شما کامل است" },
   39     { "SPELL_FAILED_ALREADY_AT_FULL_MANA", "مانای شما کامل است" },
   40     { "SPELL_FAILED_CANT_DO_THAT_RIGHT_NOW", "همین حالا نمی~توانید این کار را بکنید" },
   41     { "ERR_CLIENT_LOCKED_OUT", "همین حالا نمی~توانید این کار را بکنید" },
   42     { "SPELL_FAILED_NO_PET", "پت ندارید" },
   43     { "ERR_NOT_WHILE_MOUNTED", "سواره نمی~توانید این کار را بکنید" },
   44     { "ERR_NOT_WHILE_SHAPESHIFTED", "در این شکل نمی~توانید این کار را بکنید" },
   45     { "ERR_NOT_WHILE_FALLING", "در حال سقوط نمی~توانید این کار را بکنید" },
   46     { "ERR_ATTACK_PACIFIED", "وقتی آرام شده~اید نمی~توانید حمله کنید" },
   47     { "ERR_ATTACK_STUNNED", "وقتی مبهوت هستید نمی~توانید حمله کنید" },
   48     { "ERR_ATTACK_CONFUSED", "وقتی گیج هستید نمی~توانید حمله کنید" },
   49     { "ERR_ATTACK_FLEEING", "وقتی در حال فرار هستید نمی~توانید حمله کنید" },
   50     { "ERR_ATTACK_DEAD", "وقتی مرده~اید نمی~توانید حمله کنید" },
   51     { "ERR_ATTACK_MOUNTED", "سواره نمی~توانید حمله کنید" },
   52     { "ERR_ATTACK_CHARMED", "وقتی افسون شده~اید نمی~توانید حمله کنید" },
   53     { "ERR_PLAYER_DEAD", "وقتی مرده~اید نمی~توانید این کار را بکنید" },
   54     { "ERR_CANTATTACK_NOTSTANDING", "برای حمله باید ایستاده باشید!" },
   55     { "ERR_LOOT_NOTSTANDING", "برای برداشتن غنیمت باید ایستاده باشید!" },
   56     { "ERR_BAG_FULL", "این کیف پر است." },
   57     { "ERR_ITEM_MAX_COUNT", "بیشتر از این نمی~توانید از این آیتم همراه داشته باشید." },
   58     { "ERR_CANT_EQUIP_LEVEL_I", "برای استفاده از این آیتم باید به سطح %d برسید." },
   59     { "ERR_QUEST_LOG_FULL", "دفتر مأموریت~های شما پر است." },
   60     { "ERR_QUEST_ALREADY_DONE", "این مأموریت را قبلاً انجام داده~اید." },
   61     { "ERR_QUEST_ALREADY_ON", "این مأموریت را از قبل دارید." },
   62     { "ERR_QUEST_FAILED_LOW_LEVEL", "سطح شما برای این مأموریت کافی نیست." },
   63     { "ERR_GROUP_FULL", "گروه شما پر است." },
   64     { "ERR_NOT_LEADER", "شما رهبر گروه نیستید." },
   65     { "ERR_ALREADY_IN_GROUP_S", "%s از قبل در یک گروه است." },
   66     { "ERR_CHAT_PLAYER_NOT_FOUND_S", "بازیکنی به نام «%s» الان در بازی نیست." },
   67     { "ERR_TAXINOPATHS", "مسیر مستقیمی به آن مقصد وجود ندارد!" },
   68     { "ERR_SPELL_OUT_OF_RANGE", "خارج از برد." },
   69 }
   70 L.ALERTS = L.ALERTS or {}
   72     L.ALERTS[#L.ALERTS + 1] = { e[1], fa(e[2]) }
   76 L.SYSMSG = {
   77     { "LOOT_ITEM_SELF", "غنیمت دریافت کردید: {1}" },
   78     { "LOOT_ITEM_SELF_MULTIPLE", "غنیمت دریافت کردید: {1} ({2} عدد)" },
   79     { "LOOT_ITEM_PUSHED_SELF", "آیتم دریافت کردید: {1}" },
   80     { "LOOT_ITEM_PUSHED_SELF_MULTIPLE", "آیتم دریافت کردید: {1} ({2} عدد)" },
   81     { "LOOT_ITEM_CREATED_SELF", "ساختید: {1}" },
   82     { "LOOT_ITEM_CREATED_SELF_MULTIPLE", "ساختید: {1} ({2} عدد)" },
   83     { "LOOT_ITEM", "{1} غنیمت دریافت کرد: {2}" },
   84     { "LOOT_ITEM_MULTIPLE", "{1} غنیمت دریافت کرد: {2} ({3} عدد)" },
   85     { "LOOT_ITEM_PUSHED", "{1} آیتم دریافت کرد: {2}" },
   86     { "LOOT_ITEM_PUSHED_MULTIPLE", "{1} آیتم دریافت کرد: {2} ({3} عدد)" },
   87     { "YOU_LOOT_MONEY", "{1} پول برداشتید" },
   88     { "LOOT_MONEY_SPLIT", "سهم شما از غنیمت: {1}" },
   89     { "COMBATLOG_XPGAIN_FIRSTPERSON", "{1} کشته شد؛ {2} امتیاز تجربه گرفتید." },
   90     { "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED", "{1} امتیاز تجربه گرفتید." },
   91     { "ERR_QUEST_REWARD_EXP_I", "تجربهٔ به~دست~آمده: {1}" },
   92     { "ERR_QUEST_REWARD_MONEY_S", "دریافت شد: {1}" },
   93     { "ERR_QUEST_REWARD_ITEM_S", "آیتم دریافت شد: {1}" },
   94     { "ERR_QUEST_ACCEPTED_S", "مأموریت پذیرفته شد: {1}" },
   95     { "ERR_QUEST_COMPLETE_S", "{1} تکمیل شد." },
   96     { "LEVEL_UP", "به سطح {1} رسیدید!" },
   97     { "ERR_SKILL_UP_SI", "مهارت شما در {1} به {2} رسید." },
   98     { "FACTION_STANDING_INCREASED", "اعتبار شما نزد {1} به اندازهٔ {2} افزایش یافت." },
   99     { "FACTION_STANDING_DECREASED", "اعتبار شما نزد {1} به اندازهٔ {2} کاهش یافت." },
  100     { "ERR_LEARN_SPELL_S", "جادوی تازه~ای یاد گرفتید: {1}" },
  101     { "ERR_LEARN_ABILITY_S", "توانایی تازه~ای یاد گرفتید: {1}" },
  102     { "ERR_LEARN_PASSIVE_S", "اثر پایدار تازه~ای یاد گرفتید: {1}" },
  103     { "ERR_SPELL_UNLEARNED_S", "{1} را فراموش کردید." },
  104     { "ERR_ZONE_EXPLORED", "{1} کشف شد" },
  105     { "ERR_ZONE_EXPLORED_XP", "{1} کشف شد: {2} امتیاز تجربه" },
  106     { "ERR_NEWTAXIPATH", "مسیر پرواز تازه~ای کشف شد!" },
  107     { "ERR_DEATHBIND_SUCCESS_S", "{1} حالا خانهٔ شماست." },
  108     { "ERR_JOINED_GROUP_S", "{1} به گروه پیوست." },
  109     { "ERR_LEFT_GROUP_S", "{1} گروه را ترک کرد." },
  110     { "ERR_LEFT_GROUP_YOU", "گروه را ترک کردید." },
  111     { "ERR_GROUP_DISBANDED", "گروه شما منحل شد." },
  112     { "ERR_RAID_MEMBER_ADDED_S", "{1} به گروه رید پیوست." },
  113     { "ERR_RAID_MEMBER_REMOVED_S", "{1} گروه رید را ترک کرد." },
  114     { "MARKED_AFK", "حالا AFK هستید." },
  115     { "CLEARED_AFK", "دیگر AFK نیستید." },
  116 }
  117 for _, e in ipairs(L.SYSMSG) do
```
- ok: Locale_Sys.lua: 101 lines

### Locale_Alerts.lua

```
    1 -- WoWFA Forever - texts of the game alerts (the red messages in the middle of
    3 -- { GlobalStrings name, Persian }: the English text is read from the game's own
    4 -- global (so it is always the exact text this client shows) and the Persian is
   11 L.al_hdr = "هشدارهای بازی"
   12 L.al_on = "هشدارهای میان صفحه به فارسی"
   13 L.al_on_d = "پیام" .. Z .. "هایی مثل «خارج از برد» و «هدف نامعتبر» که وسط صفحه ظاهر می" .. Z .. "شوند"
   15 L.ch_on = "چت فارسی"
   16 L.ch_on_d = "فونت چت فارسی می" .. Z .. "شود و پیام" .. Z .. "های فارسی درست دیده می" .. Z .. "شوند (مخاطب هم باید ادان داشته باشد)"
   18 L.ch_size = "اندازه فونت چت (درصد)"
   20 L.sh_newer = "این کد را کسی با نسخهٔ جدیدتر اددان ساخته؛ هر چه این نسخه می" .. Z .. "شناسد اعمال شد. برای بقیه" .. Z .. "اش اددان را آپدیت کن."
   21 L.sh_upd = "این کد از نسخهٔ جدیدتر اددان است و این نسخه نمی" .. Z .. "تواند بخواندش. اددان را از wowfarsi.ir آپدیت کن."
   23 L.fa_on = "فونت فارسی در کل بازی"
   24 L.fa_on_d = "فونت همهٔ نوشته" .. Z .. "های بازی عوض می" .. Z .. "شود تا فارسی هیچ" .. Z .. "جا مربع نشود (چت، نام" .. Z .. "ها، نامه، دوستان). ظاهر نوشته" .. Z .. "های انگلیسی هم کمی فرق می" .. Z .. "کند."
   26 L.ALERTS = {
   27     { "SPELL_FAILED_OUT_OF_RANGE", "خارج از برد." },
   28     { "ERR_OUT_OF_RANGE", "خارج از برد." },
   29     { "SPELL_FAILED_BAD_TARGETS", "هدف نامعتبر" },
   30     { "SPELL_FAILED_BAD_IMPLICIT_TARGETS", "هدف نامعتبر" },
   31     { "ERR_ABILITY_COOLDOWN", "توانایی هنوز آماده نیست." },
   32     { "ERR_SPELL_COOLDOWN", "جادو هنوز آماده نیست." },
   33     { "ERR_ITEM_COOLDOWN", "آیتم هنوز آماده نیست." },
   34     { "ERR_INVALID_ATTACK_TARGET", "نمی" .. Z .. "توانید به این هدف حمله کنید." },
   35     { "ERR_GENERIC_NO_TARGET", "هدفی ندارید." },
   36     { "SPELL_FAILED_UNIT_NOT_INFRONT", "هدف باید جلوی شما باشد." },
   37     { "ERR_BADATTACKFACING", "رو به سمت اشتباه هستید!" },
   38     { "ERR_BADATTACKPOS", "خیلی دور هستید!" },
   39     { "SPELL_FAILED_NOT_BEHIND", "باید پشت هدف باشید." },
   40     { "SPELL_FAILED_LINE_OF_SIGHT", "هدف در خط دید نیست" },
   41     { "SPELL_FAILED_TOO_CLOSE", "هدف خیلی نزدیک است" },
   42     { "ERR_OUT_OF_MANA", "مانا کافی نیست" },
   43     { "ERR_OUT_OF_RAGE", "خشم کافی نیست" },
   44     { "ERR_OUT_OF_ENERGY", "انرژی کافی نیست" },
   45     { "ERR_OUT_OF_FOCUS", "تمرکز کافی نیست" },
   46     { "SPELL_FAILED_MOVING", "هنگام حرکت نمی" .. Z .. "توانید این کار را انجام دهید." },
   47     { "SPELL_FAILED_AFFECTING_COMBAT", "در نبرد هستید" },
   48     { "SPELL_FAILED_TARGETS_DEAD", "هدف شما مرده است" },
   49     { "SPELL_FAILED_INTERRUPTED", "قطع شد" },
   50     { "SPELL_FAILED_SPELL_IN_PROGRESS", "کار دیگری در حال انجام است" },
   51     { "SPELL_FAILED_FIZZLE", "ناکام ماند" },
   52     { "ERR_INV_FULL", "کیف شما پر است." },
   53     { "ERR_LOOT_GONE", "این آیتم دیگر در دسترس نیست." },
   54     { "ERR_NOT_ENOUGH_MONEY", "پول کافی ندارید." },
   55     -- 1.0.8 (the owner's report + a sweep of the common ones): rows named by their English text
   56     { "The merchant doesn't want that item.", "فروشنده این آیتم را نمی" .. Z .. "خرد." },
   57     { "You are too full to eat more now.", "آن" .. Z .. "قدر سیر هستید که دیگر نمی" .. Z .. "توانید چیزی بخورید." },
   58     { "You can't do that when you're dead.", "وقتی مرده" .. Z .. "اید نمی" .. Z .. "توانید این کار را انجام دهید." },
   59     { "Can't do that while stunned", "وقتی گیج هستید نمی" .. Z .. "توانید این کار را انجام دهید" },
   60     { "Can't do that while silenced", "وقتی ساکت شده" .. Z .. "اید نمی" .. Z .. "توانید این کار را انجام دهید" },
   61     { "Can't do that while confused", "وقتی سردرگم هستید نمی" .. Z .. "توانید این کار را انجام دهید" },
   62     { "Can't do that while fleeing", "هنگام فرار نمی" .. Z .. "توانید این کار را انجام دهید" },
   63     { "Can't do that while asleep", "وقتی خواب هستید نمی" .. Z .. "توانید این کار را انجام دهید" },
   64     { "Can't do that while charmed", "وقتی افسون شده" .. Z .. "اید نمی" .. Z .. "توانید این کار را انجام دهید" },
   65     { "Can't do that while horrified", "وقتی وحشت" .. Z .. "زده هستید نمی" .. Z .. "توانید این کار را انجام دهید" },
   66     { "You can't do that while in combat", "در نبرد نمی" .. Z .. "توانید این کار را انجام دهید" },
   67     { "You can't do that yet", "هنوز نمی" .. Z .. "توانید این کار را انجام دهید" },
   68     { "That bag is full.", "آن کیف پر است." },
   69     { "You can't carry any more of those items.", "دیگر نمی" .. Z .. "توانید از این آیتم بیشتر حمل کنید." },
   70     { "No path available", "راهی برای رسیدن نیست" },
   71     { "Target is friendly", "هدف دوست است" },
   72     { "Target is hostile", "هدف دشمن است" },
   73     { "Target is not dead", "هدف نمرده است" },
   74     { "Target is in combat", "هدف در نبرد است" },
   75     { "You must be standing to do that", "برای این کار باید ایستاده باشید" },
   76     { "That ability requires combo points", "این توانایی به امتیاز ترکیبی نیاز دارد" },
   77     { "You don't have permission to loot that corpse.", "اجازهٔ غارت این جسد را ندارید." },
   78     { "You are too far away to loot that corpse.", "برای غارت این جسد خیلی دور هستید." },
   79     { "That object is busy.", "آن شیء مشغول است." },
   80     { "Missing reagent: %s", "ماده" .. Z .. "ای که لازم است را ندارید: %s" },
   81     { "Requires %s", "نیاز به %s" },
   82     { "You are too far away.", "خیلی دور هستید." },
   83     { "You can't mount here.", "اینجا نمی" .. Z .. "توانید سوار مرکب شوید." },
   84     { "You are mounted.", "سوار مرکب هستید." },
   85     { "Can't attack while mounted.", "سوار بر مرکب نمی" .. Z .. "توانید حمله کنید." },
   86     { "You can't do that while mounted.", "سوار بر مرکب نمی" .. Z .. "توانید این کار را انجام دهید." },
   87     { "You are in shapeshift form", "در حالت تغییر شکل هستید" },
   88     { "Your pet is dead.", "پت شما مرده است." },
   89     { "You already have a pet.", "از قبل یک پت دارید." },
   90     { "You must have a target.", "باید هدف داشته باشید." },
   91     { "Target needs to be in front of you.", "هدف باید جلوی شما باشد." },
   92     { "You must be behind your target.", "باید پشت هدف باشید." },
   93     { "Your target is dead", "هدف شما مرده است" },
   94     { "Item is not ready yet.", "آیتم هنوز آماده نیست." },
   95     { "Not enough mana", "مانا کافی نیست" },
   96     { "Not enough rage", "خشم کافی نیست" },
   97     { "Not enough energy", "انرژی کافی نیست" },
   98     { "You have no target.", "هدفی ندارید." },
   99     { "Inventory is full.", "کیف شما پر است." },
  100     { "You don't have enough money.", "پول کافی ندارید." },
  101     { "You can't use that item.", "نمی" .. Z .. "توانید از این آیتم استفاده کنید." },
  102     { "You can't do that while swimming", "هنگام شنا نمی" .. Z .. "توانید این کار را انجام دهید" },
  103     { "You can't do that while sitting", "وقتی نشسته" .. Z .. "اید نمی" .. Z .. "توانید این کار را انجام دهید" },
  104     { "You are unable to move", "نمی" .. Z .. "توانید حرکت کنید" },
  105     { "You are too far away!", "خیلی دور هستید!" },
  106     { "You can't loot while in combat.", "در نبرد نمی" .. Z .. "توانید غارت کنید." },
  107     { "You cannot do that while dead.", "وقتی مرده" .. Z .. "اید نمی" .. Z .. "توانید این کار را انجام دهید." },
  108     { "Your skill is not high enough.", "مهارت شما به اندازهٔ کافی بالا نیست." },
  109     { "You must be in a group to do that.", "برای این کار باید در گروه باشید." },
  110     { "That item is not ready yet.", "آن آیتم هنوز آماده نیست." },
  111     { "Can't do that while moving", "هنگام حرکت نمی" .. Z .. "توانید این کار را انجام دهید." },
  113     { "Objective Complete.", "هدف انجام شد." },
  114     { "Resisted", "مقاومت کرد" },
  115     { "%s slain: %d/%d", "%s کشته" .. Z .. "شده: %d/%d" },
  117     { "Item is locked.", "آیتم قفل است." },
  118     { "That item is locked.", "آن آیتم قفل است." },
  119     { "You can't do that right now.", "الان نمی" .. Z .. "توانید این کار را انجام دهید." },
  120     { "Another action is in progress", "کار دیگری در حال انجام است" },
  121     { "Interrupted", "قطع شد" },
  122     { "Invalid target", "هدف نامعتبر" },
  123     { "Not yet recovered", "هنوز آماده نیست" },
  124     { "You are facing the wrong way!", "رو به سمت اشتباه هستید!" },
  125     { "Target too close", "هدف خیلی نزدیک است" },
  126     { "Your target is out of range.", "هدف شما خارج از برد است." },
  127     { "Out of range.", "خارج از برد." },
  128     { "You don't have enough reagents", "مواد لازم را ندارید" },
  130     { "New flight path discovered!", "مسیر پرواز تازه" .. Z .. "ای کشف شد!" },
  131     { "Your pet is not dead.", "حیوان همراه شما نمرده است." },
  132     { "Can't do that while in combat", "در نبرد نمی" .. Z .. "توانید این کار را انجام دهید" },
  133 }
```
- ok: Locale_Alerts.lua: 118 lines

### Locale_UI.lua

```
    1 -- WoWFA Forever - 1.1.6: the texts of the game's own windows (Modules/GameUI.lua).
    2 -- Each row is { English, Persian [, window] }: the English EXACTLY as the window shows it
    4 -- takes the values as {1} {2} in the Persian, in their English order. A third field limits a
    6 -- A text that is not here simply stays English. In the Persian text ~ is a half-space (ZWNJ).
   14 L.gu_hdr = fa("پنجره~های خود بازی")
   15 L.gu_on = fa("پنجره~های بازی به فارسی")
   16 L.gu_on_d = fa("منوی بازی، کاراکتر، کیف و بانک، کتاب اسپل، دوستان و گروه، نامه، تجارت، حراج، فروشنده و مربی. در نبرد چیزی عوض نمی~شود؛ بعد از نبرد اعمال می~شود.")
   18 local ROWS = {
   20     { "Okay", "تأیید" }, { "Accept", "پذیرفتن" }, { "Decline", "رد کردن" }, { "Cancel", "لغو" },
   21     { "Close", "بستن" }, { "Yes", "بله" }, { "No", "نه" }, { "Done", "تمام" }, { "Continue", "ادامه" },
   22     { "Back", "بازگشت" }, { "Next", "بعدی" }, { "Prev", "قبلی" }, { "Previous", "قبلی" },
   23     { "Delete", "حذف" }, { "Reply", "پاسخ" }, { "Send", "ارسال" }, { "Open", "باز کردن" },
   24     { "Clear", "پاک کردن" }, { "Reset", "بازنشانی" }, { "Default", "پیش~فرض" }, { "Defaults", "پیش~فرض~ها" },
   25     { "Apply", "اعمال" }, { "Search", "جستجو" }, { "Refresh", "تازه~سازی" }, { "Remove", "حذف" },
   26     { "Add", "افزودن" }, { "Edit", "ویرایش" }, { "Rename", "تغییر نام" }, { "Save", "ذخیره" },
   27     { "New", "جدید" }, { "Exit", "خروج" }, { "Help", "راهنما" }, { "Options", "تنظیمات" },
   28     { "Settings", "تنظیمات" }, { "Loading...", "در حال بارگذاری..." }, { "Unknown", "نامعلوم" },
   29     { "None", "هیچ" }, { "All", "همه" }, { "Total", "مجموع" }, { "Other", "سایر" },
   30     { "Filter", "فیلتر" }, { "Filters", "فیلترها" }, { "Sort", "مرتب~سازی" }, { "Show", "نمایش" },
   31     { "Hide", "پنهان" }, { "Enable", "فعال" }, { "Disable", "غیرفعال" }, { "Enabled", "فعال" },
   32     { "Disabled", "غیرفعال" }, { "Confirm", "تأیید نهایی" },
   34     { "Name", "نام" }, { "Level", "سطح" }, { "Class", "کلاس" }, { "Race", "نژاد" }, { "Zone", "منطقه" },
   35     { "Location", "مکان" }, { "Status", "وضعیت" }, { "Note", "یادداشت" }, { "Officer Note", "یادداشت افسر" },
   36     { "Public Note", "یادداشت عمومی" }, { "Rank", "رتبه" }, { "Online", "آنلاین" }, { "Offline", "آفلاین" },
   37     { "Away", "دور از بازی" }, { "Busy", "مشغول" }, { "Player", "بازیکن" }, { "Players", "بازیکنان" },
   38     { "Party", "گروه" }, { "Group", "گروه" }, { "Raid", "رید" }, { "Guild", "گیلد" }, { "Friend", "دوست" },
   39     { "Friends", "دوستان" }, { "Member", "عضو" }, { "Members", "اعضا" }, { "Leader", "رهبر" },
   40     { "Officer", "افسر" }, { "Guild Master", "رهبر گیلد" }, { "Assistant", "دستیار" },
   41     { "Main Tank", "تانک اصلی" }, { "Main Assist", "دستیار اصلی" }, { "Tank", "تانک" },
   42     { "Healer", "درمانگر" }, { "Damage", "آسیب" }, { "Role", "نقش" }, { "Roles", "نقش~ها" },
   43     { "Level %d", "سطح {1}" }, { "Requires Level %d", "نیازمند سطح {1}" },
   45     { "Game Menu", "منوی بازی" }, { "Shop", "فروشگاه" }, { "Store", "فروشگاه" }, { "What's New", "تازه~ها" },
   46     { "System", "سیستم" }, { "Interface", "رابط کاربری" }, { "Key Bindings", "کلیدهای میانبر" },
   47     { "Macros", "ماکروها" }, { "AddOns", "افزونه~ها" }, { "Edit Mode", "حالت ویرایش" },
   48     { "Support", "پشتیبانی" }, { "Log Out", "خروج از کاراکتر" }, { "Exit Game", "خروج از بازی" },
   49     { "Return to Game", "بازگشت به بازی" }, { "Video", "تصویر" }, { "Sound", "صدا" }, { "Audio", "صدا" },
   50     { "Graphics", "گرافیک" }, { "Social", "اجتماعی" }, { "Gameplay", "گیم~پلی" }, { "Controls", "کنترل~ها" },
   51     { "Accessibility", "دسترس~پذیری" }, { "Combat", "نبرد" }, { "Display", "نمایش" }, { "Camera", "دوربین" },
   52     { "Mouse", "ماوس" }, { "Language", "زبان" }, { "Languages", "زبان~ها" }, { "Advanced", "پیشرفته" },
   53     { "Names", "نام~ها" }, { "Chat", "چت" },
   55     { "Character", "کاراکتر" }, { "Character Info", "اطلاعات کاراکتر" }, { "Pet", "پت" }, { "Pets", "پت~ها" },
   56     { "Reputation", "اعتبار" }, { "Skills", "مهارت~ها" }, { "Honor", "افتخار" }, { "Currency", "ارزها" },
   57     { "Titles", "عنوان~ها" }, { "Title", "عنوان" }, { "Equipment Manager", "مدیریت تجهیزات" },
   58     { "Equipment Sets", "مجموعه~های تجهیزات" }, { "Attributes", "ویژگی~ها" }, { "Stats", "آمار" },
   59     { "Character Stats", "آمار کاراکتر" }, { "Base Stats", "آمار پایه" }, { "Melee", "نبرد نزدیک" },
   60     { "Ranged", "دوربرد" }, { "Spell", "اسپل" }, { "Spells", "اسپل~ها" }, { "Defense", "دفاع" },
   61     { "Defenses", "دفاع" }, { "Resistance", "مقاومت" }, { "Resistances", "مقاومت~ها" },
   62     { "Enhancements", "ارتقاها" }, { "General", "عمومی" }, { "Attack", "حمله" }, { "Strength", "قدرت" },
   63     { "Agility", "چابکی" }, { "Stamina", "استقامت" }, { "Intellect", "هوش" }, { "Spirit", "روح" },
   64     { "Armor", "زره" }, { "Speed", "سرعت" }, { "Attack Power", "قدرت حمله" }, { "Attack Speed", "سرعت حمله" },
   65     { "Crit Chance", "احتمال ضربهٔ بحرانی" }, { "Critical Strike", "ضربهٔ بحرانی" },
   66     { "Hit Chance", "احتمال برخورد" }, { "Haste", "شتاب" }, { "Mastery", "تسلط" },
   67     { "Versatility", "تطبیق~پذیری" }, { "Dodge", "جاخالی" }, { "Parry", "دفع ضربه" }, { "Block", "دفع با سپر" },
   68     { "Health", "سلامتی" }, { "Mana", "مانا" }, { "Rage", "خشم" }, { "Energy", "انرژی" }, { "Focus", "تمرکز" },
   69     { "Runic Power", "قدرت رونی" }, { "Bonus Damage", "آسیب اضافه" }, { "Bonus Healing", "درمان اضافه" },
   70     { "Healing", "درمان" }, { "Spell Damage", "آسیب اسپل" }, { "Spell Power", "قدرت اسپل" },
   71     { "Mana Regen", "بازیابی مانا" }, { "Movement Speed", "سرعت حرکت" }, { "Item Level", "سطح آیتم" },
   72     { "Durability", "دوام" }, { "Experience", "تجربه" }, { "Rested", "استراحت~کرده" },
   73     { "Expertise", "مهارت سلاح" }, { "Armor Penetration", "نفوذ در زره" },
   74     { "Fire Resistance", "مقاومت در برابر آتش" }, { "Nature Resistance", "مقاومت در برابر طبیعت" },
   75     { "Frost Resistance", "مقاومت در برابر یخ" }, { "Shadow Resistance", "مقاومت در برابر سایه" },
   76     { "Arcane Resistance", "مقاومت در برابر آرکین" },
   78     { "Hated", "منفور" }, { "Hostile", "دشمن" }, { "Unfriendly", "نامهربان" }, { "Neutral", "بی~طرف" },
   79     { "Friendly", "دوستانه" }, { "Honored", "محترم" }, { "Revered", "بسیار محترم" }, { "Exalted", "ستایش~شده" },
   80     { "At War", "در جنگ" }, { "Inactive", "غیرفعال" }, { "Move to Inactive", "انتقال به غیرفعال~ها" },
   81     { "Show as Experience Bar", "نمایش به~جای نوار تجربه" }, { "Alliance", "اتحاد" }, { "Horde", "هورد" },
   83     { "Class Skills", "مهارت~های کلاس" }, { "Professions", "حرفه~ها" }, { "Secondary Skills", "مهارت~های فرعی" },
   84     { "Weapon Skills", "مهارت~های سلاح" }, { "Armor Proficiencies", "مهارت در زره" }, { "Unlearn", "فراموش کردن" },
   85     { "Skill", "مهارت" }, { "Axes", "تبر" }, { "Two-Handed Axes", "تبر دودستی" }, { "Maces", "گرز" },
   86     { "Two-Handed Maces", "گرز دودستی" }, { "Swords", "شمشیر" }, { "Two-Handed Swords", "شمشیر دودستی" },
   87     { "Daggers", "خنجر" }, { "Staves", "عصا" }, { "Polearms", "نیزه" }, { "Bows", "کمان" }, { "Guns", "تفنگ" },
   88     { "Crossbows", "کمان صلیبی" }, { "Thrown", "پرتابی" }, { "Wands", "چوب~دستی جادویی" },
   89     { "Fist Weapons", "سلاح مشتی" }, { "Unarmed", "بی~سلاح" }, { "Fishing", "ماهیگیری" }, { "Cooking", "آشپزی" },
   90     { "First Aid", "کمک~های اولیه" }, { "Mining", "معدن~کاری" }, { "Herbalism", "گیاه~شناسی" },
   91     { "Skinning", "پوست~کنی" }, { "Blacksmithing", "آهنگری" }, { "Leatherworking", "چرم~سازی" },
   92     { "Tailoring", "خیاطی" }, { "Engineering", "مهندسی" }, { "Alchemy", "کیمیاگری" }, { "Enchanting", "افسون~گری" },
   93     { "Jewelcrafting", "جواهرسازی" }, { "Inscription", "کتیبه~نویسی" }, { "Riding", "سوارکاری" },
   94     { "Lockpicking", "قفل~بازکنی" }, { "Poisons", "زهرها" }, { "Cloth", "پارچه~ای" }, { "Leather", "چرمی" },
   95     { "Mail", "زنجیری", "SkillFrame" }, { "Plate", "صفحه~ای" }, { "Shield", "سپر" }, { "Shields", "سپر" },
   96     { "Orcish", "ارکی" }, { "Darnassian", "دارنسی" }, { "Dwarvish", "دورفی" }, { "Gnomish", "گنومی" },
   97     { "Taurahe", "تاوراهه" }, { "Gutterspeak", "گاترسپیک" }, { "Thalassian", "تالاسی" },
   99     { "Honorable Kills", "کشتارهای شرافتمندانه" }, { "Dishonorable Kills", "کشتارهای ناجوانمردانه" },
  100     { "Today", "امروز" }, { "Yesterday", "دیروز" }, { "This Week", "این هفته" }, { "Last Week", "هفتهٔ گذشته" },
  101     { "Lifetime", "کل دوران" }, { "Kills", "کشته~ها" }, { "Arena", "آرنا" }, { "Battlegrounds", "میدان~های نبرد" },
  102     { "Battleground", "میدان نبرد" }, { "Join Battle", "ورود به نبرد" }, { "Leave Queue", "ترک صف" },
  103     { "Honor Points", "امتیاز افتخار" }, { "Arena Points", "امتیاز آرنا" }, { "Standing", "جایگاه" },
  104     { "Contribution", "سهم" },
  106     { "Spellbook", "کتاب اسپل" }, { "Spellbook & Abilities", "کتاب اسپل و توانایی~ها" },
  107     { "Abilities", "توانایی~ها" }, { "Talents", "استعدادها" }, { "Page %d", "صفحهٔ {1}" },
  108     { "Show all spell ranks", "نمایش همهٔ رتبه~های اسپل" }, { "Companions", "همراهان" }, { "Mounts", "مرکب~ها" },
  110     { "Backpack", "کوله~پشتی" }, { "Bag", "کیف" }, { "Bags", "کیف~ها" }, { "Bank", "بانک" },
  111     { "Purchase", "خرید" }, { "Cost", "هزینه" }, { "Key Ring", "حلقهٔ کلید" }, { "Keyring", "حلقهٔ کلید" },
  112     { "Empty", "خالی" }, { "Item", "آیتم" }, { "Items", "آیتم~ها" }, { "Reagents", "معرف~ها" },
  113     { "Reagent Bank", "بانک معرف" }, { "Deposit All Reagents", "سپردن همهٔ معرف~ها" }, { "Money", "پول" },
  114     { "Gold", "طلا" }, { "Silver", "نقره" }, { "Copper", "مس" },
  116     { "Who", "بازیکنان" }, { "Ignore", "نادیده گرفتن" }, { "Ignored", "نادیده~گرفته~ها" },
  117     { "Add Friend", "افزودن دوست" }, { "Remove Friend", "حذف دوست" }, { "Send Message", "ارسال پیام" },
  118     { "Invite", "دعوت" }, { "Group Invite", "دعوت به گروه" }, { "Whisper", "نجوا" },
  119     { "Ignore Player", "نادیده گرفتن بازیکن" }, { "Stop Ignoring", "دیگر نادیده نگیر" },
  120     { "Add to Friends", "افزودن به دوستان" }, { "Show Offline Members", "نمایش اعضای آفلاین" },
  121     { "Guild Information", "اطلاعات گیلد" }, { "Guild Info", "اطلاعات گیلد" }, { "Guild Control", "مدیریت گیلد" },
  122     { "Add Member", "افزودن عضو" }, { "Guild Status", "وضعیت گیلد" }, { "Last Online", "آخرین حضور" },
  123     { "Convert to Raid", "تبدیل به رید" }, { "Raid Info", "اطلاعات رید" }, { "Ready Check", "بررسی آمادگی" },
  124     { "Role Check", "بررسی نقش" }, { "Group %d", "گروه {1}" }, { "Leave Group", "ترک گروه" },
  125     { "Leave Party", "ترک گروه" }, { "Leave Raid", "ترک رید" }, { "Promote to Leader", "ارتقا به رهبر" },
  126     { "Uninvite", "اخراج از گروه" }, { "Remove from Group", "حذف از گروه" }, { "Achievements", "دستاوردها" },
  127     { "Calendar", "تقویم" },
  129     { "Mail", "نامه" }, { "Inbox", "صندوق نامه" }, { "Send Mail", "ارسال نامه" }, { "To", "گیرنده" },
  130     { "Subject", "موضوع" }, { "From", "فرستنده" }, { "Send Money", "ارسال پول" },
  131     { "C.O.D.", "پرداخت هنگام تحویل" }, { "Open All", "باز کردن همه" }, { "Postage", "هزینهٔ پست" },
  132     { "Auction successful: %s", "حراج موفق: {1}" }, { "Auction won: %s", "برندهٔ حراج شدید: {1}" },
  133     { "Outbid on %s", "کسی بیشتر از شما پیشنهاد داد: {1}" }, { "Auction expired: %s", "حراج تمام شد و فروش نرفت: {1}" },
  134     { "Auction cancelled: %s", "حراج لغو شد: {1}" }, { "Sale Pending: %s", "فروش در انتظار: {1}" },
  136     { "Trade", "تجارت" }, { "Will not be traded", "معامله نمی~شود" }, { "Merchant", "فروشنده" },
  137     { "Buyback", "بازخرید" }, { "Repair", "تعمیر" }, { "Repair All", "تعمیر همه" },
  138     { "Repair All Items", "تعمیر همهٔ آیتم~ها" }, { "Repair an Item", "تعمیر یک آیتم" },
  139     { "Sell All Junk", "فروش همهٔ خرده~ریزها" }, { "Buy", "خرید" }, { "Sell", "فروش" }, { "Price", "قیمت" },
  140     { "Quantity", "تعداد" },
  142     { "Auction House", "حراج~خانه" }, { "Browse", "مرور" }, { "Bids", "پیشنهادها" }, { "Auctions", "حراج~ها" },
  143     { "Bid", "پیشنهاد" }, { "Buyout", "خرید فوری" }, { "Buyout Price", "قیمت خرید فوری" },
  144     { "Starting Price", "قیمت شروع" }, { "Current Bid", "پیشنهاد فعلی" }, { "Time Left", "زمان باقی~مانده" },
  145     { "Duration", "مدت" }, { "Deposit", "ودیعه" }, { "Create Auction", "ایجاد حراج" },
  146     { "Cancel Auction", "لغو حراج" }, { "Level Range", "بازهٔ سطح" }, { "Rarity", "کمیابی" },
  147     { "Usable Items", "آیتم~های قابل استفاده" }, { "Short", "کوتاه" }, { "Medium", "متوسط" },
  148     { "Long", "طولانی" }, { "Very Long", "خیلی طولانی" }, { "High Bidder", "بالاترین پیشنهاد" },
  149     { "Seller", "فروشنده" }, { "Stack Size", "اندازهٔ دسته" }, { "Number of Stacks", "تعداد دسته~ها" },
  150     { "Unit Price", "قیمت واحد" }, { "Weapon", "سلاح" }, { "Container", "محفظه" }, { "Consumable", "مصرفی" },
  151     { "Trade Goods", "کالای تجاری" }, { "Recipe", "دستور ساخت" }, { "Reagent", "معرف" }, { "Gem", "جواهر" },
  152     { "Miscellaneous", "متفرقه" }, { "Quest", "کوئست" }, { "Projectile", "پرتابه" }, { "Quiver", "تیردان" },
  154     { "Train", "آموختن" }, { "Available", "در دسترس" }, { "Unavailable", "در دسترس نیست" },
  155     { "Used", "آموخته~شده" }, { "Requires", "نیازمند" }, { "Trainer", "مربی" },
  157     { "Loot", "غنیمت" }, { "Need", "نیاز" }, { "Greed", "طمع" }, { "Pass", "صرف~نظر" }, { "Disenchant", "تجزیه" },
  159     { "Dungeon Finder", "یابندهٔ سیاه~چال" }, { "Group Finder", "یابندهٔ گروه" }, { "Find Group", "یافتن گروه" },
  160     { "Premade Groups", "گروه~های آماده" }, { "Raid Finder", "یابندهٔ رید" }, { "Dungeons", "سیاه~چال~ها" },
  161     { "Dungeon", "سیاه~چال" }, { "Looking for Group", "جستجوی گروه" }, { "Looking for More", "جستجوی عضو بیشتر" },
  162     { "Random Dungeon", "سیاه~چال تصادفی" }, { "Specific Dungeons", "سیاه~چال~های مشخص" },
  163     { "Heroic", "قهرمانی" }, { "Normal", "معمولی" },
  165     { "General Macros", "ماکروهای عمومی" }, { "%s Specific Macros", "ماکروهای ویژهٔ {1}" },
  166     { "Change Name/Icon", "تغییر نام و آیکون" }, { "Macro", "ماکرو" }, { "Clock", "ساعت" },
  167     { "Stopwatch", "زمان~سنج" }, { "Alarm", "هشدار" }, { "Use Local Time", "استفاده از زمان محلی" },
  168     { "24 Hour Mode", "حالت 24 ساعته" }, { "Dressing Room", "اتاق پرو" }, { "Undress", "درآوردن لباس" },
  169     { "Inspect", "بازرسی" }, { "Stable", "اصطبل" }, { "Loyalty", "وفاداری" }, { "Diet", "رژیم غذایی" },
  170 }
  172 L.GAMEUI = {}
  174     L.GAMEUI[#L.GAMEUI + 1] = { e[1], fa(e[2]), e[3] }
```
- ok: Locale_UI.lua: 145 lines
