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

L.ALERTS = L.ALERTS or {}
L.ALERTS[#L.ALERTS + 1] = { "There is no loot.", fa("غنیمتی وجود ندارد.") }
