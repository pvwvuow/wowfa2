-- WoWFA Forever 1.2.2 - the window texts of the owner's report of 27 Nov (kind ui): the character
-- statistics page, the equipment icons, the reputation list, the game menu tag. Same format as
-- Locale_UI.lua: { English, Persian, window }. The window keeps a word such as Fire or Ratchet from
-- being swapped in a place it was not meant for. ~ is a half-space.

local L = WoWFAF_L

local function fa(s)
    return (string.gsub(s, "~", "\226\128\140"))
end

local ROWS = {
    -- equipment icons
    { "All Icons", "همهٔ آیکن~ها", "PaperDollFrame" },
    { "Choose an Icon", "یک آیکن انتخاب کنید", "PaperDollFrame" },
    { "Currently Selected", "انتخاب فعلی", "PaperDollFrame" },
    { "Drag an icon here to use it as your display", "برای استفاده به~عنوان نمایش، یک آیکن را به اینجا بکشید", "PaperDollFrame" },
    { "Equip", "تجهیز", "PaperDollFrame" },
    -- the game menu and the currency list
    { "NEW", "جدید", "GameMenuFrame" },
    { "Maximum", "حداکثر", "TokenFrame" },
    -- the character page: resistances, weapons, wealth and the statistics list
    { "Arcane", "اسرار", "CharacterFrame" },
    { "Fire", "آتش", "CharacterFrame" },
    { "Frost", "یخ", "CharacterFrame" },
    { "Nature", "طبیعت", "CharacterFrame" },
    { "Shadow", "سایه", "CharacterFrame" },
    { "Armor Piercing", "نفوذ در زره", "CharacterFrame" },
    { "Main Hand", "دست اصلی", "CharacterFrame" },
    { "Off Hand", "دست فرعی", "CharacterFrame" },
    { "Ranged Attack Power", "قدرت حملهٔ دوربرد", "CharacterFrame" },
    { "Primary Attributes", "ویژگی~های اصلی", "CharacterFrame" },
    { "Modifiers", "تغییردهنده~ها", "CharacterFrame" },
    { "Weapons", "سلاح~ها", "CharacterFrame" },
    { "Wealth", "ثروت", "CharacterFrame" },
    { "Civilian", "غیرنظامی", "CharacterFrame" },
    { "Auction purchases", "خریدهای حراج", "CharacterFrame" },
    { "Auctions posted", "حراج~های ثبت~شده", "CharacterFrame" },
    { "Average gold earned per day", "میانگین طلای کسب~شده در روز", "CharacterFrame" },
    { "Gold earned from auctions", "طلای کسب~شده از حراج", "CharacterFrame" },
    { "Gold from quest rewards", "طلا از پاداش مأموریت~ها", "CharacterFrame" },
    { "Gold from vendors", "طلا از فروشنده~ها", "CharacterFrame" },
    { "Gold looted", "طلای غنیمت~شده", "CharacterFrame" },
    { "Gold spent on travel", "طلای خرج~شده برای سفر", "CharacterFrame" },
    { "Most expensive auction sold", "گران~ترین حراج فروخته~شده", "CharacterFrame" },
    { "Most expensive bid on auction", "گران~ترین پیشنهاد در حراج", "CharacterFrame" },
    { "Talent tree respecs", "دفعات بازتخصیص استعدادها", "CharacterFrame" },
    { "Times camped", "دفعات خروج از بازی", "CharacterFrame" },
    { "Total gold acquired", "کل طلای به~دست~آمده", "CharacterFrame" },
    { "Show on Backpack", "نمایش روی کوله~پشتی", "CharacterFrame" },
    { "Transfer", "انتقال", "CharacterFrame" },
    { "Transfer Log", "گزارش انتقال", "CharacterFrame" },
    { "Unused", "استفاده~نشده", "CharacterFrame" },
    { "View Renown", "دیدن آوازه", "CharacterFrame" },
    { "Faction Tabard", "تابارد فکشن", "CharacterFrame" },
    -- the reputation list: the same names the zone table uses
    { "Stormwind", "استورم~ویند", "ReputationFrame" },
    { "Ironforge", "آیرون~فورج", "ReputationFrame" },
    { "Darnassus", "دارناسوس", "ReputationFrame" },
    { "Gnomeregan Exiles", "تبعیدیان گنومرگان", "ReputationFrame" },
    { "Booty Bay", "خلیج غنیمت", "ReputationFrame" },
    { "Ratchet", "راچت", "ReputationFrame" },
    { "Everlook", "ایورلوک", "ReputationFrame" },
    { "Gadgetzan", "گجتزان", "ReputationFrame" },
    { "Steamwheedle Cartel", "کارتل استیم~ویدل", "ReputationFrame" },
    { "Bloodsail Buccaneers", "دزدان دریایی بادبان~خونین", "ReputationFrame" },
    { "Powderfuse", "فتیلهٔ باروت", "ReputationFrame" },
    -- 1.2.3: the macro window (the owner's report of 28 Nov; the game adds the colon itself)
    { "All Icons", "همهٔ آیکن~ها", "MacroFrame" },
    { "Choose an Icon", "یک آیکن انتخاب کنید", "MacroFrame" },
    { "Create Macros", "ساخت ماکرو", "MacroFrame" },
    { "Currently Selected", "انتخاب فعلی", "MacroFrame" },
    { "Drag an icon here to use it as your display", "برای استفاده به~عنوان نمایش، یک آیکن را به اینجا بکشید", "MacroFrame" },
    { "Enter Macro Commands", "دستورهای ماکرو را وارد کنید", "MacroFrame" },
}

L.GAMEUI = L.GAMEUI or {}
for _, e in ipairs(ROWS) do
    L.GAMEUI[#L.GAMEUI + 1] = { e[1], fa(e[2]), e[3] }
end

-- a system line only the server sends (no GlobalStrings name): the row is named by its English text
L.SYSMSG = L.SYSMSG or {}
L.SYSMSG[#L.SYSMSG + 1] = { "You feel rested.", fa("احساس می~کنی استراحت کرده~ای.") }
L.ALERTS[#L.ALERTS + 1] = { "Only Reagents can be placed in Reagent Bags.", fa("فقط ریجنت را می~شود در کیف ریجنت گذاشت.") }
-- 1.2.3: the auction line as this server sends it (the owner's screenshot of 28 Nov; the GlobalStrings row of the same line stays)
L.SYSMSG[#L.SYSMSG + 1] = { "A buyer has been found for your auction of %s.", "برای حراج {1} شما خریدار پیدا شد." }
L.SYSMSG[#L.SYSMSG + 1] = { "You are no longer rested.", fa("دیگر در حالت استراحت نیستید.") }

-- the red line of the fishing hint
L.ALERTS = L.ALERTS or {}
L.ALERTS[#L.ALERTS + 1] = { "Must have a Fishing Pole equipped", fa("برای این کار باید چوب ماهیگیری در دست داشته باشید") }
