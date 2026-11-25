-- WoWFA Forever - rc30 texts: the switches and sliders of the new things
-- (system lines per group, alert size, quest list size) and two more alerts
-- named by their English text (the client has no global name we know for them;
-- a row whose first field holds a space is the English text itself).
-- ~ is a half-space (ZWNJ).

local L = WoWFAF_L

local function fa(s)
    return (string.gsub(s, "~", "\226\128\140"))
end

L.ls_size = fa("اندازهٔ فونت لیست مأموریت~ها و ردیاب (درصد)")
L.al_size = fa("اندازهٔ هشدارهای میان صفحه (درصد)")
L.fa_size = fa("اندازه فونت متن~های بازی (درصد)")
L.sec_sizes = fa("اندازه فونت~ها")
L.sz_intro = fa("همه اسلایدرهای اندازه اینجا هستند. هر اسلایدر فقط یک گروه از متن~ها را عوض می~کند و با اسلایدر دیگر قاطی نمی~شود.")
L.sz_own_h = fa("متن~های فارسی خود ادآن")
L.sz_own_d = fa("تولتیپ~ها، توضیح اسپل~ها و تلنت~ها، پنجره مأموریت و اسم اسپل~ها در کتاب اسپل. لیست مأموریت و متن~های بازی را عوض نمی~کند.")
L.sz_list_h = fa("لیست مأموریت~ها و ردیاب")
L.sz_list_d = fa("فقط خط~های فارسی لیست مأموریت کنار نقشه (کلید M) و ردیاب. در ۱۰۰ درصد عنوان ۱۳ و هدف ۱۲ است. خطی که از ردیف بلندتر شود خودش کوچک می~شود تا توی هم نرود.")
L.sz_all_h = fa("متن~های خود بازی (انگلیسی هم)")
L.sz_all_d = fa("اندازه متن~های خود بازی، انگلیسی هم. ۱۰۰ درصد = اندازه خود بازی. با کلید بالا خاموش یا روشن کار می~کند. چت و هشدارها اسلایدر جدا دارند.")
L.sz_other_h = fa("چت، هشدارها و پنجره تنظیمات")
L.sz_chat_d = fa("فقط پنجره~های چت و کادر نوشتن.")
L.sz_alert_d = fa("فقط پیام~های قرمز وسط صفحه.")
L.sz_win_d = fa("فقط خود پنجره تنظیمات.")
L.sy_sysLoot = fa("پیام~های غنیمت و پول")
L.sy_sysXp = fa("پیام~های تجربه، سطح و مأموریت~ها")
L.sy_sysRep = fa("پیام~های اعتبار، مهارت و جادوی تازه")
L.sy_sysGroup = fa("پیام~های گروه و AFK")

L.pf_hdr = fa("پروفایل~های من")
L.pf_d = fa("تنظیمات فعلی (بخش~ها، نمایش، رنگ~ها، اندازه~ها و هشدارها) را با یک اسم ذخیره کن و بعداً با یک کلیک «اعمال» برگردان. اسم را در کادر زیر بنویس. پروفایل~ها برای همهٔ کاراکترهای این اکانت مشترک~اند (حداکثر ۱۰).")
L.pf_save = fa("ذخیرهٔ پروفایل")
L.pf_load = fa("اعمال")
L.pf_del = fa("حذف")
L.pf_del_sure = fa("مطمئنی؟")
L.pf_saved = fa("پروفایل «%s» ذخیره شد.")
L.pf_updated = fa("پروفایل «%s» به~روز شد.")
L.pf_loaded = fa("پروفایل «%s» اعمال شد.")
L.pf_deleted = fa("پروفایل «%s» حذف شد.")
L.pf_none = fa("هنوز پروفایلی نساخته~ای. یک اسم بنویس و «ذخیرهٔ پروفایل» را بزن.")

L.rp_hdr = fa("گزارش برای ما: چیزهایی که هنوز فارسی نیستند")
L.rp_d = fa("خط پایین هر چیزی است که افزونه در بازی دید و فارسی~اش را نداشت (هشدار، اسم NPC، منطقه و...). «انتخاب برای کپی» را بزن، بعد Ctrl+C، و متن را در سایت wowfarsi.ir/report یا در سرور دیسکورد wowfarsi برای ما بفرست تا در نسخهٔ بعد فارسی شود. کوئست~ها و NPC~های تازه هم خودکار جمع می~شوند (/wowfa harvest). اسم بازیکن~ها و پت~ها هیچ~وقت ترجمه نمی~شود.")
L.btn_miss_copy = fa("انتخاب برای کپی")

L.ALERTS = L.ALERTS or {}
L.ALERTS[#L.ALERTS + 1] = { "Internal mail database error.", fa("خطای داخلی پایگاه دادهٔ نامه~ها.") }
L.ALERTS[#L.ALERTS + 1] = { "The item was not found.", fa("آیتم پیدا نشد.") }
L.ALERTS[#L.ALERTS + 1] = { "You are mounted.", fa("شما سوار مرکب هستید.") }
L.ALERTS[#L.ALERTS + 1] = { "Your pet is dead. Use Revive Pet.", fa("پت شما مرده است. از Revive Pet استفاده کنید.") }
L.ALERTS[#L.ALERTS + 1] = { "You do not have a pet to summon.", fa("پتی برای احضار ندارید.") }
L.ALERTS[#L.ALERTS + 1] = { "Discovered: %s", fa("کشف شد: %s") }
L.ALERTS[#L.ALERTS + 1] = { "There is no loot.", fa("غنیمتی وجود ندارد.") }
