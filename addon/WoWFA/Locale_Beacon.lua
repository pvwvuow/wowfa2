-- WoWFA Forever 1.2.2 - texts of the floating report icon (Modules/Beacon.lua) and of its switch
-- on the status page. Short, friendly, no pressure: the icon is a choice and says how to turn it off.
-- ~ is a half-space (ZWNJ).

local L = WoWFAF_L
local function fa(s)
    return (string.gsub(s, "~", "\226\128\140"))
end

L.BC = {
    tip_title = fa("گزارش ترجمه"),
    tip_count = fa("%d متن بدون ترجمه ثبت شده"),
    tip_none = fa("هنوز متن بدون ترجمه~ای ثبت نشده"),
    tip_click = fa("کلیک: کپی و ارسال گزارش"),
    tip_right = fa("راست~کلیک: منو"),
    tip_drag = fa("کشیدن: جابه~جایی"),
    menu_open = fa("باز کردن گزارش"),
    menu_panel = fa("تنظیمات WoWFA"),
    menu_hide = fa("پنهان کردن آیکن"),
    off_note = fa("آیکن گزارش پنهان شد. هر وقت خواستی از تنظیمات، بخش «وضعیت و گزارش»، دوباره روشنش کن."),
    win_title = fa("گزارش متن~های بدون ترجمه"),
    win_on = fa("آیکن معلق: روشن"),
    win_off = fa("آیکن معلق: خاموش"),
    win_turn_off = fa("خاموش کردن آیکن"),
    win_turn_on = fa("روشن کردن آیکن"),
    win_count = fa("%d مورد ثبت شده است"),
    win_none = fa("هنوز چیزی ثبت نشده؛ کمی بازی کن."),
    win_select = fa("انتخاب متن گزارش"),
    win_clear = fa("پاک کردن فهرست"),
    win_copied = fa("انتخاب شد؛ حالا Ctrl+C بزن."),
    win_steps = fa("۱) «انتخاب متن گزارش»  ۲) Ctrl+C  ۳) در آدرس زیر بچسبان و بفرست. بعد از ارسال، فهرست را پاک کن."),
    intro_later = fa("الان نه"),
    intro_next = fa("بعدی"),
    intro_back = fa("قبلی"),
    intro_enable = fa("فعال کردن آیکن"),
    intro_note = fa("هر وقت خواستی خاموشش کنی: تنظیمات، «وضعیت و گزارش»."),
    slides = {
        { t = fa("به WoWFarsi کمک کن"),
          b = fa("هر متنی که هنوز فارسی نشده، خودکار ثبت می~شود. اگر گزارشش را بفرستی، ترجمهٔ آن زودتر به نسخهٔ بعدی می~رسد.") },
        { t = fa("آیکن کوچک چطور کار می~کند؟"),
          b = fa("هر بار قاب سبز چشمک زد، یعنی متن تازه~ای پیدا شده. عدد روی آیکن می~گوید چند مورد ثبت شده.") },
        { t = fa("ارسال در یک دقیقه"),
          b = fa("روی آیکن کلیک کن، متن گزارش را کپی کن و در wowfarsi.ir/report بفرست. با راست~کلیک می~توانی آیکن را پنهان کنی.") },
    },
}

-- the switch at the top of the status page
if type(L.PN) == "table" then
    L.PN.h_beacon = fa("آیکن گزارش")
    L.PN.beacon = fa("آیکن معلق گزارش متن~های بدون ترجمه")
    L.PN.beacon_d = fa("هر بار چشمک بزند یعنی متن تازه~ای پیدا شده؛ با کلیک، کپی و ارسال می~شود. خاموش = آیکن پنهان، ثبت متن~ها ادامه دارد.")
end
