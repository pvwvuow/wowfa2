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
