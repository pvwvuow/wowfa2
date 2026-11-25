-- WoWFA Forever - the strings of the NPC talk / books page (1.0.7, Modules/Dialog.lua).
-- Loaded after Locale_Opt.lua; Panel.lua has no Persian literal of its own.
local L = WoWFAF_L
L.sec_dialog = "گفتگو و کتاب‌ها"
L.dl_intro = "حرف‌های NPCها (متن پنجرهٔ گفتگو و خوش‌آمد، حرف‌هایی که در چت و بالای سرشان می‌زنند) و متن کتاب‌ها، نامه‌ها و تابلوها. هر متنی که هنوز فارسی ندارد به انگلیسی در گزارش صفحهٔ «وضعیت» ثبت می‌شود تا در آپدیت بعدی فارسی شود."
L.dl_gossip = "متن پنجرهٔ گفتگو و خوش‌آمد NPC"
L.dl_say = "حرف‌های NPC در چت و بالای سرشان"
L.dl_book = "کتاب‌ها، نامه‌ها و تابلوها"
L.dl_note = "ترجمه کنار پنجرهٔ خود بازی نشان داده می‌شود. هر وقت Shift را نگه داری، متن اصلی انگلیسی را می‌بینی."
L.dl_shift = "با نگه‌داشتن Shift متن اصلی انگلیسی دیده شود"
if type(L.MISS_KIND) == "table" then
    L.MISS_KIND.dlg = "گفتگوی NPC"
    L.MISS_KIND.say = "حرف NPC"
    L.MISS_KIND.book = "کتاب و نامه"
end
-- 1.0.8: the WoWFA.lua folder (status page, Panel.lua F.SvPath)
L.fl_hdr = "پوشهٔ فایل WoWFA.lua"
L.fl_steps = "۱) «ذخیرهٔ فایل» را بزن تا بازی فایل را همین الان بنویسد (یک /reload است).  ۲) «انتخاب مسیر» را بزن و Ctrl+C.  ۳) در ویندوز Win+R، بعد Ctrl+V و Enter: پوشه مستقیم باز می‌شود. در مک: Finder، بعد Cmd+Shift+G و Cmd+V."
L.fl_btn = "انتخاب مسیر پوشه"
L.fl_save = "ذخیرهٔ فایل (/reload)"
L.fl_copied = "مسیر انتخاب شد: Ctrl+C، بعد Win+R و Ctrl+V و Enter."
L.fl_saved = "مسیر ذخیره شد؛ دفعهٔ بعد همین باز می‌شود."
L.fl_combat = "وسط نبرد نمی‌شود؛ بعد از نبرد دوباره بزن."
L.fl_note = "این مسیرِ نصب پیش‌فرض است و تا پوشهٔ Account می‌رود؛ آنجا پوشهٔ اکانتت را باز کن و بعد SavedVariables. اگر بازی جای دیگری نصب است، یا می‌خواهی مستقیم به SavedVariables برسی، یک بار مسیر درست را در جعبه بنویس یا Paste کن و Enter بزن؛ همیشه می‌ماند (جعبهٔ خالی + Enter = مسیر پیش‌فرض)."
