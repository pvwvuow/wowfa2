-- WoWFA Forever - 1.1.6: the texts of the game's own windows (Modules/GameUI.lua).
-- Each row is { English, Persian [, window] }: the English EXACTLY as the window shows it
-- (or a GlobalStrings NAME in CAPITALS, read at run time - never written). A row with %s / %d
-- takes the values as {1} {2} in the Persian, in their English order. A third field limits a
-- row to one window (Mail = armour in the skills list, the mail window everywhere else).
-- A text that is not here simply stays English. In the Persian text ~ is a half-space (ZWNJ).

local L = WoWFAF_L

local function fa(s)
    return (string.gsub(s, "~", "\226\128\140"))
end

L.gu_hdr = fa("پنجره~های خود بازی")
L.gu_on = fa("پنجره~های بازی به فارسی")
L.gu_on_d = fa("منوی بازی، کاراکتر، کیف و بانک، کتاب اسپل، دوستان و گروه، نامه، تجارت، حراج، فروشنده و مربی. در نبرد چیزی عوض نمی~شود؛ بعد از نبرد اعمال می~شود.")

local ROWS = {
    -- buttons and words every window uses
    { "Okay", "تأیید" }, { "Accept", "پذیرفتن" }, { "Decline", "رد کردن" }, { "Cancel", "لغو" },
    { "Close", "بستن" }, { "Yes", "بله" }, { "No", "نه" }, { "Done", "تمام" }, { "Continue", "ادامه" },
    { "Back", "بازگشت" }, { "Next", "بعدی" }, { "Prev", "قبلی" }, { "Previous", "قبلی" },
    { "Delete", "حذف" }, { "Reply", "پاسخ" }, { "Send", "ارسال" }, { "Open", "باز کردن" },
    { "Clear", "پاک کردن" }, { "Reset", "بازنشانی" }, { "Default", "پیش~فرض" }, { "Defaults", "پیش~فرض~ها" },
    { "Apply", "اعمال" }, { "Search", "جستجو" }, { "Refresh", "تازه~سازی" }, { "Remove", "حذف" },
    { "Add", "افزودن" }, { "Edit", "ویرایش" }, { "Rename", "تغییر نام" }, { "Save", "ذخیره" },
    { "New", "جدید" }, { "Exit", "خروج" }, { "Help", "راهنما" }, { "Options", "تنظیمات" },
    { "Settings", "تنظیمات" }, { "Loading...", "در حال بارگذاری..." }, { "Unknown", "نامعلوم" },
    { "None", "هیچ" }, { "All", "همه" }, { "Total", "مجموع" }, { "Other", "سایر" },
    { "Filter", "فیلتر" }, { "Filters", "فیلترها" }, { "Sort", "مرتب~سازی" }, { "Show", "نمایش" },
    { "Hide", "پنهان" }, { "Enable", "فعال" }, { "Disable", "غیرفعال" }, { "Enabled", "فعال" },
    { "Disabled", "غیرفعال" }, { "Confirm", "تأیید نهایی" },
    -- people, lists and columns
    { "Name", "نام" }, { "Level", "سطح" }, { "Class", "کلاس" }, { "Race", "نژاد" }, { "Zone", "منطقه" },
    { "Location", "مکان" }, { "Status", "وضعیت" }, { "Note", "یادداشت" }, { "Officer Note", "یادداشت افسر" },
    { "Public Note", "یادداشت عمومی" }, { "Rank", "رتبه" }, { "Online", "آنلاین" }, { "Offline", "آفلاین" },
    { "Away", "دور از بازی" }, { "Busy", "مشغول" }, { "Player", "بازیکن" }, { "Players", "بازیکنان" },
    { "Party", "گروه" }, { "Group", "گروه" }, { "Raid", "رید" }, { "Guild", "گیلد" }, { "Friend", "دوست" },
    { "Friends", "دوستان" }, { "Member", "عضو" }, { "Members", "اعضا" }, { "Leader", "رهبر" },
    { "Officer", "افسر" }, { "Guild Master", "رهبر گیلد" }, { "Assistant", "دستیار" },
    { "Main Tank", "تانک اصلی" }, { "Main Assist", "دستیار اصلی" }, { "Tank", "تانک" },
    { "Healer", "درمانگر" }, { "Damage", "آسیب" }, { "Role", "نقش" }, { "Roles", "نقش~ها" },
    { "Level %d", "سطح {1}" }, { "Requires Level %d", "نیازمند سطح {1}" },
    -- the game menu and its pages
    { "Game Menu", "منوی بازی" }, { "Shop", "فروشگاه" }, { "Store", "فروشگاه" }, { "What's New", "تازه~ها" },
    { "System", "سیستم" }, { "Interface", "رابط کاربری" }, { "Key Bindings", "کلیدهای میانبر" },
    { "Macros", "ماکروها" }, { "AddOns", "افزونه~ها" }, { "Edit Mode", "حالت ویرایش" },
    { "Support", "پشتیبانی" }, { "Log Out", "خروج از کاراکتر" }, { "Exit Game", "خروج از بازی" },
    { "Return to Game", "بازگشت به بازی" }, { "Video", "تصویر" }, { "Sound", "صدا" }, { "Audio", "صدا" },
    { "Graphics", "گرافیک" }, { "Social", "اجتماعی" }, { "Gameplay", "گیم~پلی" }, { "Controls", "کنترل~ها" },
    { "Accessibility", "دسترس~پذیری" }, { "Combat", "نبرد" }, { "Display", "نمایش" }, { "Camera", "دوربین" },
    { "Mouse", "ماوس" }, { "Language", "زبان" }, { "Languages", "زبان~ها" }, { "Advanced", "پیشرفته" },
    { "Names", "نام~ها" }, { "Chat", "چت" },
    -- the character window
    { "Character", "کاراکتر" }, { "Character Info", "اطلاعات کاراکتر" }, { "Pet", "پت" }, { "Pets", "پت~ها" },
    { "Reputation", "اعتبار" }, { "Skills", "مهارت~ها" }, { "Honor", "افتخار" }, { "Currency", "ارزها" },
    { "Titles", "عنوان~ها" }, { "Title", "عنوان" }, { "Equipment Manager", "مدیریت تجهیزات" },
    { "Equipment Sets", "مجموعه~های تجهیزات" }, { "Attributes", "ویژگی~ها" }, { "Stats", "آمار" },
    { "Character Stats", "آمار کاراکتر" }, { "Base Stats", "آمار پایه" }, { "Melee", "نبرد نزدیک" },
    { "Ranged", "دوربرد" }, { "Spell", "اسپل" }, { "Spells", "اسپل~ها" }, { "Defense", "دفاع" },
    { "Defenses", "دفاع" }, { "Resistance", "مقاومت" }, { "Resistances", "مقاومت~ها" },
    { "Enhancements", "ارتقاها" }, { "General", "عمومی" }, { "Attack", "حمله" }, { "Strength", "قدرت" },
    { "Agility", "چابکی" }, { "Stamina", "استقامت" }, { "Intellect", "هوش" }, { "Spirit", "روح" },
    { "Armor", "زره" }, { "Speed", "سرعت" }, { "Attack Power", "قدرت حمله" }, { "Attack Speed", "سرعت حمله" },
    { "Crit Chance", "احتمال ضربهٔ بحرانی" }, { "Critical Strike", "ضربهٔ بحرانی" },
    { "Hit Chance", "احتمال برخورد" }, { "Haste", "شتاب" }, { "Mastery", "تسلط" },
    { "Versatility", "تطبیق~پذیری" }, { "Dodge", "جاخالی" }, { "Parry", "دفع ضربه" }, { "Block", "دفع با سپر" },
    { "Health", "سلامتی" }, { "Mana", "مانا" }, { "Rage", "خشم" }, { "Energy", "انرژی" }, { "Focus", "تمرکز" },
    { "Runic Power", "قدرت رونی" }, { "Bonus Damage", "آسیب اضافه" }, { "Bonus Healing", "درمان اضافه" },
    { "Healing", "درمان" }, { "Spell Damage", "آسیب اسپل" }, { "Spell Power", "قدرت اسپل" },
    { "Mana Regen", "بازیابی مانا" }, { "Movement Speed", "سرعت حرکت" }, { "Item Level", "سطح آیتم" },
    { "Durability", "دوام" }, { "Experience", "تجربه" }, { "Rested", "استراحت~کرده" },
    { "Expertise", "مهارت سلاح" }, { "Armor Penetration", "نفوذ در زره" },
    { "Fire Resistance", "مقاومت در برابر آتش" }, { "Nature Resistance", "مقاومت در برابر طبیعت" },
    { "Frost Resistance", "مقاومت در برابر یخ" }, { "Shadow Resistance", "مقاومت در برابر سایه" },
    { "Arcane Resistance", "مقاومت در برابر آرکین" },
    -- reputation
    { "Hated", "منفور" }, { "Hostile", "دشمن" }, { "Unfriendly", "نامهربان" }, { "Neutral", "بی~طرف" },
    { "Friendly", "دوستانه" }, { "Honored", "محترم" }, { "Revered", "بسیار محترم" }, { "Exalted", "ستایش~شده" },
    { "At War", "در جنگ" }, { "Inactive", "غیرفعال" }, { "Move to Inactive", "انتقال به غیرفعال~ها" },
    { "Show as Experience Bar", "نمایش به~جای نوار تجربه" }, { "Alliance", "اتحاد" }, { "Horde", "هورد" },
    -- skills
    { "Class Skills", "مهارت~های کلاس" }, { "Professions", "حرفه~ها" }, { "Secondary Skills", "مهارت~های فرعی" },
    { "Weapon Skills", "مهارت~های سلاح" }, { "Armor Proficiencies", "مهارت در زره" }, { "Unlearn", "فراموش کردن" },
    { "Skill", "مهارت" }, { "Axes", "تبر" }, { "Two-Handed Axes", "تبر دودستی" }, { "Maces", "گرز" },
    { "Two-Handed Maces", "گرز دودستی" }, { "Swords", "شمشیر" }, { "Two-Handed Swords", "شمشیر دودستی" },
    { "Daggers", "خنجر" }, { "Staves", "عصا" }, { "Polearms", "نیزه" }, { "Bows", "کمان" }, { "Guns", "تفنگ" },
    { "Crossbows", "کمان صلیبی" }, { "Thrown", "پرتابی" }, { "Wands", "چوب~دستی جادویی" },
    { "Fist Weapons", "سلاح مشتی" }, { "Unarmed", "بی~سلاح" }, { "Fishing", "ماهیگیری" }, { "Cooking", "آشپزی" },
    { "First Aid", "کمک~های اولیه" }, { "Mining", "معدن~کاری" }, { "Herbalism", "گیاه~شناسی" },
    { "Skinning", "پوست~کنی" }, { "Blacksmithing", "آهنگری" }, { "Leatherworking", "چرم~سازی" },
    { "Tailoring", "خیاطی" }, { "Engineering", "مهندسی" }, { "Alchemy", "کیمیاگری" }, { "Enchanting", "افسون~گری" },
    { "Jewelcrafting", "جواهرسازی" }, { "Inscription", "کتیبه~نویسی" }, { "Riding", "سوارکاری" },
    { "Lockpicking", "قفل~بازکنی" }, { "Poisons", "زهرها" }, { "Cloth", "پارچه~ای" }, { "Leather", "چرمی" },
    { "Mail", "زنجیری", "SkillFrame" }, { "Plate", "صفحه~ای" }, { "Shield", "سپر" }, { "Shields", "سپر" },
    { "Orcish", "ارکی" }, { "Darnassian", "دارنسی" }, { "Dwarvish", "دورفی" }, { "Gnomish", "گنومی" },
    { "Taurahe", "تاوراهه" }, { "Gutterspeak", "گاترسپیک" }, { "Thalassian", "تالاسی" },
    -- honour and PvP
    { "Honorable Kills", "کشتارهای شرافتمندانه" }, { "Dishonorable Kills", "کشتارهای ناجوانمردانه" },
    { "Today", "امروز" }, { "Yesterday", "دیروز" }, { "This Week", "این هفته" }, { "Last Week", "هفتهٔ گذشته" },
    { "Lifetime", "کل دوران" }, { "Kills", "کشته~ها" }, { "Arena", "آرنا" }, { "Battlegrounds", "میدان~های نبرد" },
    { "Battleground", "میدان نبرد" }, { "Join Battle", "ورود به نبرد" }, { "Leave Queue", "ترک صف" },
    { "Honor Points", "امتیاز افتخار" }, { "Arena Points", "امتیاز آرنا" }, { "Standing", "جایگاه" },
    { "Contribution", "سهم" },
    -- the spellbook (the spell names themselves are the spellbook module's)
    { "Spellbook", "کتاب اسپل" }, { "Spellbook & Abilities", "کتاب اسپل و توانایی~ها" },
    { "Abilities", "توانایی~ها" }, { "Talents", "استعدادها" }, { "Page %d", "صفحهٔ {1}" },
    { "Show all spell ranks", "نمایش همهٔ رتبه~های اسپل" }, { "Companions", "همراهان" }, { "Mounts", "مرکب~ها" },
    -- bags and bank
    { "Backpack", "کوله~پشتی" }, { "Bag", "کیف" }, { "Bags", "کیف~ها" }, { "Bank", "بانک" },
    { "Purchase", "خرید" }, { "Cost", "هزینه" }, { "Key Ring", "حلقهٔ کلید" }, { "Keyring", "حلقهٔ کلید" },
    { "Empty", "خالی" }, { "Item", "آیتم" }, { "Items", "آیتم~ها" }, { "Reagents", "معرف~ها" },
    { "Reagent Bank", "بانک معرف" }, { "Deposit All Reagents", "سپردن همهٔ معرف~ها" }, { "Money", "پول" },
    { "Gold", "طلا" }, { "Silver", "نقره" }, { "Copper", "مس" },
    -- friends, who, guild, raid
    { "Who", "بازیکنان" }, { "Ignore", "نادیده گرفتن" }, { "Ignored", "نادیده~گرفته~ها" },
    { "Add Friend", "افزودن دوست" }, { "Remove Friend", "حذف دوست" }, { "Send Message", "ارسال پیام" },
    { "Invite", "دعوت" }, { "Group Invite", "دعوت به گروه" }, { "Whisper", "نجوا" },
    { "Ignore Player", "نادیده گرفتن بازیکن" }, { "Stop Ignoring", "دیگر نادیده نگیر" },
    { "Add to Friends", "افزودن به دوستان" }, { "Show Offline Members", "نمایش اعضای آفلاین" },
    { "Guild Information", "اطلاعات گیلد" }, { "Guild Info", "اطلاعات گیلد" }, { "Guild Control", "مدیریت گیلد" },
    { "Add Member", "افزودن عضو" }, { "Guild Status", "وضعیت گیلد" }, { "Last Online", "آخرین حضور" },
    { "Convert to Raid", "تبدیل به رید" }, { "Raid Info", "اطلاعات رید" }, { "Ready Check", "بررسی آمادگی" },
    { "Role Check", "بررسی نقش" }, { "Group %d", "گروه {1}" }, { "Leave Group", "ترک گروه" },
    { "Leave Party", "ترک گروه" }, { "Leave Raid", "ترک رید" }, { "Promote to Leader", "ارتقا به رهبر" },
    { "Uninvite", "اخراج از گروه" }, { "Remove from Group", "حذف از گروه" }, { "Achievements", "دستاوردها" },
    { "Calendar", "تقویم" },
    -- mail
    { "Mail", "نامه" }, { "Inbox", "صندوق نامه" }, { "Send Mail", "ارسال نامه" }, { "To", "گیرنده" },
    { "Subject", "موضوع" }, { "From", "فرستنده" }, { "Send Money", "ارسال پول" },
    { "C.O.D.", "پرداخت هنگام تحویل" }, { "Open All", "باز کردن همه" }, { "Postage", "هزینهٔ پست" },
    { "Auction successful: %s", "حراج موفق: {1}" }, { "Auction won: %s", "برندهٔ حراج شدید: {1}" },
    { "Outbid on %s", "کسی بیشتر از شما پیشنهاد داد: {1}" }, { "Auction expired: %s", "حراج تمام شد و فروش نرفت: {1}" },
    { "Auction cancelled: %s", "حراج لغو شد: {1}" }, { "Sale Pending: %s", "فروش در انتظار: {1}" },
    -- trade and merchant
    { "Trade", "تجارت" }, { "Will not be traded", "معامله نمی~شود" }, { "Merchant", "فروشنده" },
    { "Buyback", "بازخرید" }, { "Repair", "تعمیر" }, { "Repair All", "تعمیر همه" },
    { "Repair All Items", "تعمیر همهٔ آیتم~ها" }, { "Repair an Item", "تعمیر یک آیتم" },
    { "Sell All Junk", "فروش همهٔ خرده~ریزها" }, { "Buy", "خرید" }, { "Sell", "فروش" }, { "Price", "قیمت" },
    { "Quantity", "تعداد" },
    -- the auction house
    { "Auction House", "حراج~خانه" }, { "Browse", "مرور" }, { "Bids", "پیشنهادها" }, { "Auctions", "حراج~ها" },
    { "Bid", "پیشنهاد" }, { "Buyout", "خرید فوری" }, { "Buyout Price", "قیمت خرید فوری" },
    { "Starting Price", "قیمت شروع" }, { "Current Bid", "پیشنهاد فعلی" }, { "Time Left", "زمان باقی~مانده" },
    { "Duration", "مدت" }, { "Deposit", "ودیعه" }, { "Create Auction", "ایجاد حراج" },
    { "Cancel Auction", "لغو حراج" }, { "Level Range", "بازهٔ سطح" }, { "Rarity", "کمیابی" },
    { "Usable Items", "آیتم~های قابل استفاده" }, { "Short", "کوتاه" }, { "Medium", "متوسط" },
    { "Long", "طولانی" }, { "Very Long", "خیلی طولانی" }, { "High Bidder", "بالاترین پیشنهاد" },
    { "Seller", "فروشنده" }, { "Stack Size", "اندازهٔ دسته" }, { "Number of Stacks", "تعداد دسته~ها" },
    { "Unit Price", "قیمت واحد" }, { "Weapon", "سلاح" }, { "Container", "محفظه" }, { "Consumable", "مصرفی" },
    { "Trade Goods", "کالای تجاری" }, { "Recipe", "دستور ساخت" }, { "Reagent", "معرف" }, { "Gem", "جواهر" },
    { "Miscellaneous", "متفرقه" }, { "Quest", "کوئست" }, { "Projectile", "پرتابه" }, { "Quiver", "تیردان" },
    -- trainers
    { "Train", "آموختن" }, { "Available", "در دسترس" }, { "Unavailable", "در دسترس نیست" },
    { "Used", "آموخته~شده" }, { "Requires", "نیازمند" }, { "Trainer", "مربی" },
    -- loot
    { "Loot", "غنیمت" }, { "Need", "نیاز" }, { "Greed", "طمع" }, { "Pass", "صرف~نظر" }, { "Disenchant", "تجزیه" },
    -- the group finder
    { "Dungeon Finder", "یابندهٔ سیاه~چال" }, { "Group Finder", "یابندهٔ گروه" }, { "Find Group", "یافتن گروه" },
    { "Premade Groups", "گروه~های آماده" }, { "Raid Finder", "یابندهٔ رید" }, { "Dungeons", "سیاه~چال~ها" },
    { "Dungeon", "سیاه~چال" }, { "Looking for Group", "جستجوی گروه" }, { "Looking for More", "جستجوی عضو بیشتر" },
    { "Random Dungeon", "سیاه~چال تصادفی" }, { "Specific Dungeons", "سیاه~چال~های مشخص" },
    { "Heroic", "قهرمانی" }, { "Normal", "معمولی" },
    -- macros, clock, dressing room, inspect, stable
    { "General Macros", "ماکروهای عمومی" }, { "%s Specific Macros", "ماکروهای ویژهٔ {1}" },
    { "Change Name/Icon", "تغییر نام و آیکون" }, { "Macro", "ماکرو" }, { "Clock", "ساعت" },
    { "Stopwatch", "زمان~سنج" }, { "Alarm", "هشدار" }, { "Use Local Time", "استفاده از زمان محلی" },
    { "24 Hour Mode", "حالت 24 ساعته" }, { "Dressing Room", "اتاق پرو" }, { "Undress", "درآوردن لباس" },
    { "Inspect", "بازرسی" }, { "Stable", "اصطبل" }, { "Loyalty", "وفاداری" }, { "Diet", "رژیم غذایی" },
}

L.GAMEUI = {}
for _, e in ipairs(ROWS) do
    L.GAMEUI[#L.GAMEUI + 1] = { e[1], fa(e[2]), e[3] }
end
