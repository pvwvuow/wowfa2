-- WoWFA Forever - 1.1.6 settings panel v4 (the owner 26 Nov: "check every setting: no extra
-- explanations, simple, exact and complete; many buttons are useless, many texts point at
-- nothing the player can tell"). One control per real thing, a short label that says WHERE it
-- shows, a one-line note only when the label can not say it. Loaded after the other Locale
-- files, so the values set here win. In the Persian text ~ is a half-space (ZWNJ).

local L = WoWFAF_L
local function fa(s)
    return (string.gsub(s, "~", "\226\128\140"))
end

-- the side menu
L.sec_general = fa("عمومی")
L.sec_quests = fa("کوئست~ها")
L.sec_map = fa("نقشه و مناطق")
L.sec_npc = fa("NPCها و گفتگو")
L.sec_chat = fa("چت و پیام~ها")
L.sec_game = fa("پنجره~های بازی")
L.sec_spellbook = fa("اسپل~ها و تلنت~ها")
L.sec_sizes = fa("اندازهٔ فونت")
L.sec_colors = fa("رنگ و حاشیه")
L.sec_share = fa("پروفایل و اشتراک")
L.sec_health = fa("وضعیت و گزارش")
L.sec_about = fa("درباره")

L.PN = {
    -- General
    master = fa("WoWFA روشن"),
    master_d = fa("خاموش = همه~چیز مثل بازی انگلیسی"),
    h_mode = fa("چه چیزی فارسی شود"),
    mode = fa("حالت ترجمه"),
    preset_lbl = { recommended = fa("پیشنهادی"), fa = fa("کاملاً فارسی"), story = fa("داستان"),
        spells = fa("اسپل~ها"), en = fa("انگلیسی"), custom = fa("سفارشی") },
    preset_desc = {
        recommended = fa("متن~ها فارسی؛ اسم اسپل، NPC و منطقه انگلیسی"),
        fa = fa("هر چه ترجمه دارد فارسی"),
        story = fa("کوئست، NPC و منطقه فارسی؛ اسپل~ها انگلیسی"),
        spells = fa("فقط اسپل و تلنت فارسی"),
        en = fa("اسم~ها و متن~ها انگلیسی (منو، چت و هشدار جدا)"),
        custom = fa("ترکیب خودت؛ با هر حالت بالا عوض می~شود"),
    },
    h_words = fa("در همهٔ متن~ها"),
    namesClass = fa("اسم کلاس~ها"),
    namesClass_d = fa("مثلاً «شکارچی» به~جای Hunter"),
    terms = fa("اصطلاح~های بازی"),
    terms_d = fa("آسیب، پت، سلامتی و ...؛ خاموش = این کلمه~ها انگلیسی وسط متن"),
    faDigits = fa("عددهای فارسی"),
    faDigits_d = fa("۱۲ به~جای 12"),
    h_gameui = fa("منوها و پنجره~های بازی"),
    gameUi = fa("پنجره~های خود بازی به فارسی"),
    gameUi_d = fa("کاراکتر، کیف، کتاب اسپل، دوستان، نامه، فروشنده، حراج"),
    h_other = fa("سایر"),
    shiftEn = fa("نگه داشتن Shift = متن انگلیسی اصلی"),
    minimap = fa("دکمهٔ WoWFA کنار نقشهٔ کوچک"),
    toast = fa("اعلان~های WoWFA (خطا و آپدیت)"),
    share = fa("خبر نسخهٔ جدید WoWFA از هم~گروهی~ها"),
    -- Quests
    namesQuest = fa("عنوان کوئست~ها"),
    namesQuest_d = fa("پنجرهٔ کوئست، ردیاب، لیست کنار نقشه، گفتگو"),
    questText = fa("متن و هدف کوئست~ها"),
    questText_d = fa("متن کامل در پنل فارسی، هدف~ها در ردیاب"),
    h_pane = fa("پنل فارسی کوئست"),
    quests = fa("پنل فارسی کنار پنجرهٔ کوئست"),
    dock = fa("جای پنل"),
    dock_opt = { fa("راست پنجره"), fa("چپ پنجره"), fa("آزاد (با ماوس بکش)") },
    questAuto = fa("پنل خودکار باز شود"),
    questAuto_d = fa("خاموش = با دکمهٔ «فا» روی پنجرهٔ کوئست"),
    h_tracker = fa("ردیاب و لیست کوئست"),
    tracker = fa("ردیاب کوئست کنار صفحه"),
    listTitles = fa("لیست کوئست کنار نقشه (M)"),
    questie = fa("Questie هم فارسی شود"),
    questie_d = fa("راهنمای نقشه و ردیاب Questie، اگر نصب است"),
    -- Map
    namesZone = fa("اسم مناطق"),
    namesZone_d = fa("ورود به منطقه، نقشهٔ کوچک، مسیر پرواز"),
    zoneMap = fa("اسم منطقه روی نقشهٔ بزرگ"),
    three_name = { fa("فارسی"), fa("فارسی، انگلیسی زیرش"), fa("انگلیسی") },
    -- NPC
    npcName = fa("اسم NPCها"),
    npcName_d = fa("تولتیپ، بالای سر (کلید V)، قاب هدف، متن کوئست"),
    h_talk = fa("حرف~های NPCها"),
    dlgGossip = fa("متن پنجرهٔ گفتگو"),
    dlgSay = fa("حرف~ها در چت و بالای سرشان"),
    dlgSay_d = fa("«فارسی در چت» هم باید روشن باشد"),
    dlgBook = fa("کتاب~ها، نامه~ها و تابلوها"),
    -- Chat
    chatFa = fa("فارسی در چت"),
    chatFa_d = fa("فونت چت فارسی می~شود؛ لازم برای همهٔ پیام~های فارسی"),
    h_sys = fa("پیام~های سیستم در چت"),
    sysLoot = fa("غنیمت و پول"),
    sysXp = fa("تجربه، سطح و کوئست"),
    sysRep = fa("اعتبار، مهارت و اسپل تازه"),
    sysGroup = fa("گروه و AFK"),
    h_alerts = fa("هشدارها"),
    alerts = fa("هشدارهای قرمز وسط صفحه"),
    alerts_d = fa("مثلاً «خارج از برد»"),
    -- Spells
    spName = fa("اسم اسپل~ها"),
    spName_d = fa("تولتیپ، کتاب اسپل و متن کوئست~ها"),
    spDesc = fa("توضیح اسپل~ها"),
    desc_opt = { fa("فارسی"), fa("انگلیسی، فارسی زیرش"), fa("انگلیسی") },
    h_talents = fa("تلنت~ها"),
    talentOwn = fa("تلنت~ها تنظیم جدا داشته باشند"),
    talentOwn_d = fa("خاموش = مثل اسپل~ها"),
    tlName = fa("اسم تلنت~ها"),
    tlDesc = fa("توضیح تلنت~ها"),
    -- Sizes
    h_size = fa("اندازه"),
    fontSize = fa("فارسی WoWFA (تولتیپ و پنل~ها)"),
    szList = fa("ردیاب و لیست کوئست (٪)"),
    szGame = fa("متن~های خود بازی (٪)"),
    chatScale = fa("چت (٪)"),
    alertScale = fa("هشدارهای قرمز (٪)"),
    scale = fa("همین پنجره"),
    h_font = fa("فونت"),
    fontAll = fa("فونت فارسی در کل بازی"),
    fontAll_d = fa("اگر اسم یا پیام فارسی مربع دیده می~شود روشن کن"),
    -- Colours
    colOn = fa("اسم~ها رنگی باشند"),
    colOn_d = fa("در متن کوئست~ها و تولتیپ~ها"),
    h_col = fa("رنگ هر دسته"),
    col = { zn = fa("مناطق"), sp = fa("اسپل~ها"), npc = fa("NPCها"), fac = fa("گروه~ها و فکشن~ها"),
        cls = fa("کلاس~ها"), it = fa("آیتم~ها"), tm = fa("اصطلاح~ها"), ob = fa("اشیا") },
    col_pick = fa("انتخاب رنگ"),
    h_ol = fa("حاشیهٔ حروف"),
    ol_note = fa("یک خط تیرهٔ نازک دور حروف فارسی"),
    ol = { npc = fa("اسم NPCها"), zn = fa("اسم مناطق"), qs = fa("عنوان کوئست~ها"), sp = fa("اسم اسپل~ها"),
        text = fa("متن~ها (کوئست، توضیح، گفتگو)") },
    -- Status
    h_update = fa("وقتی بازی آپدیت شد"),
    onUpdate = fa("اگر بازی از ترجمه جدیدتر شد"),
    update_opt = { fa("فقط خبر بده"), fa("بخش~های حساس خاموش"), fa("همه خاموش") },
    -- 1.2.0
    new_tag = fa("جدید"),
    h_gwin = fa("هر دسته از پنجره~ها"),
    gu_menu = fa("منوی بازی، ماکرو و ساعت"),
    gu_char = fa("کاراکتر، اعتبار، مهارت~ها و کتاب اسپل"),
    gu_bags = fa("کیف~ها و بانک"),
    gu_social = fa("دوستان، گیلد و لیست بازیکنان"),
    gu_mail = fa("نامه و تجارت"),
    gu_shops = fa("فروشنده، حراج، مربی و حرفه~ها"),
    gu_finder = fa("یابندهٔ گروه، میدان نبرد و آرنا"),
    h_mods = fa("وضعیت بخش~ها"),
}

-- the status / share / profile texts (shorter)
L.rp2_hdr = fa("گزارش متن~های بدون ترجمه")
L.rp2_steps = fa("۱) «انتخاب متن گزارش»  ۲) Ctrl+C  ۳) در wowfarsi.ir/report بچسبان")
L.rp2_none = fa("هنوز متن بدون ترجمه~ای دیده نشده.")
L.rp2_box = fa("متن گزارش:")
L.rp2_copied = fa("انتخاب شد؛ حالا Ctrl+C.")
L.fl_steps = fa("۱) «ذخیرهٔ فایل» (یک /reload)  ۲) «انتخاب مسیر پوشه» و Ctrl+C  ۳) Win+R، بعد Ctrl+V و Enter")
L.fl_note = fa("بازی جای دیگری نصب است؟ مسیر درست را یک بار در کادر بنویس و Enter بزن.")
L.sh_mine = fa("کد تنظیمات من")
L.sh_mine_d = fa("روی کادر کلیک کن، Ctrl+C و به دوستت بده.")
L.sh_use = fa("وارد کردن کد")
L.sh_use_d = fa("کد را با Ctrl+V بچسبان و «اعمال کد» را بزن.")
L.pf_hdr = fa("پروفایل~ها")
L.pf_d = fa("اسم بنویس و «ذخیرهٔ پروفایل» را بزن؛ برای همهٔ کاراکترها، حداکثر ۱۰.")
L.col_pick = L.PN.col_pick
-- the module names on the status page, in the same words as the pages
L.m_quests = fa("پنل کوئست")
L.m_tracker = fa("ردیاب کوئست")
L.m_dungeons = fa("اسم مناطق")
L.m_npc = fa("اسم NPCها")
L.m_spellbook = fa("اسپل~ها")
L.m_talents = fa("تلنت~ها")

-- 1.1.8 (the owner 27 Nov): who makes WoWFA + the "how can I help" tour
L.PN.help_btn = fa("چطور می~توانم به پیشرفت WoWFarsi کمک کنم؟")
L.PN.a_made = fa("WoWFA را فقط یک نفر می~سازد و به~روز نگه می~دارد؛ رایگان است. اگر به کارتان می~آید، به سایت wowfarsi.ir سر بزنید و حمایت کنید؛ همین حمایت انرژی زیادی برای ادامهٔ کار می~دهد.")
L.PN.tour_next = fa("بعدی")
L.PN.tour_back = fa("قبلی")
L.PN.tour_close = fa("بستن")
L.PN.tour_done = fa("تمام")
L.PN.tour_pick = fa("انتخاب متن گزارش")
L.PN.tour_empty = fa("هنوز متن بدون ترجمه~ای ثبت نشده؛ کمی بازی کن و دوباره بیا.")
L.call_pet = fa("فراخوانی")
L.PN.tour = {
    { t = fa("با بازی کردن کمک کن"),
      b = fa("فقط با گشتن در دنیا، باز کردن نقشه و سر زدن به NPCها، بخش~های ترجمه~نشده خودکار ثبت می~شوند. شمارش همین خط بالا می~رود.") },
    { t = fa("ثبت خودکار"),
      b = fa("هر متن بدون ترجمه (اسم، حرف NPC، کتاب، هشدار) اینجا شمرده می~شود و دسته~اش زیرش نوشته می~شود. چیزی به جایی فرستاده نمی~شود.") },
    { t = fa("متن گزارش را کپی کن"),
      b = fa("روی دکمهٔ چشمک~زن زیر کادر بزن تا متن انتخاب شود، بعد Ctrl+C بزن.") },
    { t = fa("در سایت بفرست"),
      b = fa("حالا به آدرس زیر برو، متن را با Ctrl+V بچسبان و بفرست. ترجمهٔ همان متن~ها در نسخهٔ بعدی اضافه می~شود. ممنون که کمک می~کنی!") },
}
