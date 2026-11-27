-- WoWFA Forever - texts of the game alerts (the red messages in the middle of
-- the screen: "Out of range.", "Invalid target", ...). Each row is
-- { GlobalStrings name, Persian }: the English text is read from the game's own
-- global (so it is always the exact text this client shows) and the Persian is
-- drawn instead. %s / %d in the English become %s / %d in the Persian.
-- Lua 5.1 has no \u escape: the half-space (ZWNJ) is written as Z.

local L = WoWFAF_L
local Z = "\226\128\140"

L.al_hdr = "هشدارهای بازی"
L.al_on = "هشدارهای میان صفحه به فارسی"
L.al_on_d = "پیام" .. Z .. "هایی مثل «خارج از برد» و «هدف نامعتبر» که وسط صفحه ظاهر می" .. Z .. "شوند"

L.ch_on = "چت فارسی"
L.ch_on_d = "فونت چت فارسی می" .. Z .. "شود و پیام" .. Z .. "های فارسی درست دیده می" .. Z .. "شوند (مخاطب هم باید ادان داشته باشد)"

L.ch_size = "اندازه فونت چت (درصد)"

L.sh_newer = "این کد را کسی با نسخهٔ جدیدتر اددان ساخته؛ هر چه این نسخه می" .. Z .. "شناسد اعمال شد. برای بقیه" .. Z .. "اش اددان را آپدیت کن."
L.sh_upd = "این کد از نسخهٔ جدیدتر اددان است و این نسخه نمی" .. Z .. "تواند بخواندش. اددان را از wowfarsi.ir آپدیت کن."

L.fa_on = "فونت فارسی در کل بازی"
L.fa_on_d = "فونت همهٔ نوشته" .. Z .. "های بازی عوض می" .. Z .. "شود تا فارسی هیچ" .. Z .. "جا مربع نشود (چت، نام" .. Z .. "ها، نامه، دوستان). ظاهر نوشته" .. Z .. "های انگلیسی هم کمی فرق می" .. Z .. "کند."

L.ALERTS = {
    { "SPELL_FAILED_OUT_OF_RANGE", "خارج از برد." },
    { "ERR_OUT_OF_RANGE", "خارج از برد." },
    { "SPELL_FAILED_BAD_TARGETS", "هدف نامعتبر" },
    { "SPELL_FAILED_BAD_IMPLICIT_TARGETS", "هدف نامعتبر" },
    { "ERR_ABILITY_COOLDOWN", "توانایی هنوز آماده نیست." },
    { "ERR_SPELL_COOLDOWN", "جادو هنوز آماده نیست." },
    { "ERR_ITEM_COOLDOWN", "آیتم هنوز آماده نیست." },
    { "ERR_INVALID_ATTACK_TARGET", "نمی" .. Z .. "توانید به این هدف حمله کنید." },
    { "ERR_GENERIC_NO_TARGET", "هدفی ندارید." },
    { "SPELL_FAILED_UNIT_NOT_INFRONT", "هدف باید جلوی شما باشد." },
    { "ERR_BADATTACKFACING", "رو به سمت اشتباه هستید!" },
    { "ERR_BADATTACKPOS", "خیلی دور هستید!" },
    { "SPELL_FAILED_NOT_BEHIND", "باید پشت هدف باشید." },
    { "SPELL_FAILED_LINE_OF_SIGHT", "هدف در خط دید نیست" },
    { "SPELL_FAILED_TOO_CLOSE", "هدف خیلی نزدیک است" },
    { "ERR_OUT_OF_MANA", "مانا کافی نیست" },
    { "ERR_OUT_OF_RAGE", "خشم کافی نیست" },
    { "ERR_OUT_OF_ENERGY", "انرژی کافی نیست" },
    { "ERR_OUT_OF_FOCUS", "تمرکز کافی نیست" },
    { "SPELL_FAILED_MOVING", "هنگام حرکت نمی" .. Z .. "توانید این کار را انجام دهید." },
    { "SPELL_FAILED_AFFECTING_COMBAT", "در نبرد هستید" },
    { "SPELL_FAILED_TARGETS_DEAD", "هدف شما مرده است" },
    { "SPELL_FAILED_INTERRUPTED", "قطع شد" },
    { "SPELL_FAILED_SPELL_IN_PROGRESS", "کار دیگری در حال انجام است" },
    { "SPELL_FAILED_FIZZLE", "ناکام ماند" },
    { "ERR_INV_FULL", "کیف شما پر است." },
    { "ERR_LOOT_GONE", "این آیتم دیگر در دسترس نیست." },
    { "ERR_NOT_ENOUGH_MONEY", "پول کافی ندارید." },
    -- 1.0.8 (the owner's report + a sweep of the common ones): rows named by their English text
    { "The merchant doesn't want that item.", "فروشنده این آیتم را نمی" .. Z .. "خرد." },
    { "You are too full to eat more now.", "آن" .. Z .. "قدر سیر هستید که دیگر نمی" .. Z .. "توانید چیزی بخورید." },
    { "You can't do that when you're dead.", "وقتی مرده" .. Z .. "اید نمی" .. Z .. "توانید این کار را انجام دهید." },
    { "Can't do that while stunned", "وقتی گیج هستید نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "Can't do that while silenced", "وقتی ساکت شده" .. Z .. "اید نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "Can't do that while confused", "وقتی سردرگم هستید نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "Can't do that while fleeing", "هنگام فرار نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "Can't do that while asleep", "وقتی خواب هستید نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "Can't do that while charmed", "وقتی افسون شده" .. Z .. "اید نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "Can't do that while horrified", "وقتی وحشت" .. Z .. "زده هستید نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "You can't do that while in combat", "در نبرد نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "You can't do that yet", "هنوز نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "That bag is full.", "آن کیف پر است." },
    { "You can't carry any more of those items.", "دیگر نمی" .. Z .. "توانید از این آیتم بیشتر حمل کنید." },
    { "No path available", "راهی برای رسیدن نیست" },
    { "Target is friendly", "هدف دوست است" },
    { "Target is hostile", "هدف دشمن است" },
    { "Target is not dead", "هدف نمرده است" },
    { "Target is in combat", "هدف در نبرد است" },
    { "You must be standing to do that", "برای این کار باید ایستاده باشید" },
    { "That ability requires combo points", "این توانایی به امتیاز ترکیبی نیاز دارد" },
    { "You don't have permission to loot that corpse.", "اجازهٔ غارت این جسد را ندارید." },
    { "You are too far away to loot that corpse.", "برای غارت این جسد خیلی دور هستید." },
    { "That object is busy.", "آن شیء مشغول است." },
    { "Missing reagent: %s", "ماده" .. Z .. "ای که لازم است را ندارید: %s" },
    { "Requires %s", "نیاز به %s" },
    { "You are too far away.", "خیلی دور هستید." },
    { "You can't mount here.", "اینجا نمی" .. Z .. "توانید سوار مرکب شوید." },
    { "You are mounted.", "سوار مرکب هستید." },
    { "Can't attack while mounted.", "سوار بر مرکب نمی" .. Z .. "توانید حمله کنید." },
    { "You can't do that while mounted.", "سوار بر مرکب نمی" .. Z .. "توانید این کار را انجام دهید." },
    { "You are in shapeshift form", "در حالت تغییر شکل هستید" },
    { "Your pet is dead.", "پت شما مرده است." },
    { "You already have a pet.", "از قبل یک پت دارید." },
    { "You must have a target.", "باید هدف داشته باشید." },
    { "Target needs to be in front of you.", "هدف باید جلوی شما باشد." },
    { "You must be behind your target.", "باید پشت هدف باشید." },
    { "Your target is dead", "هدف شما مرده است" },
    { "Item is not ready yet.", "آیتم هنوز آماده نیست." },
    { "Not enough mana", "مانا کافی نیست" },
    { "Not enough rage", "خشم کافی نیست" },
    { "Not enough energy", "انرژی کافی نیست" },
    { "You have no target.", "هدفی ندارید." },
    { "Inventory is full.", "کیف شما پر است." },
    { "You don't have enough money.", "پول کافی ندارید." },
    { "You can't use that item.", "نمی" .. Z .. "توانید از این آیتم استفاده کنید." },
    { "You can't do that while swimming", "هنگام شنا نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "You can't do that while sitting", "وقتی نشسته" .. Z .. "اید نمی" .. Z .. "توانید این کار را انجام دهید" },
    { "You are unable to move", "نمی" .. Z .. "توانید حرکت کنید" },
    { "You are too far away!", "خیلی دور هستید!" },
    { "You can't loot while in combat.", "در نبرد نمی" .. Z .. "توانید غارت کنید." },
    { "You cannot do that while dead.", "وقتی مرده" .. Z .. "اید نمی" .. Z .. "توانید این کار را انجام دهید." },
    { "Your skill is not high enough.", "مهارت شما به اندازهٔ کافی بالا نیست." },
    { "You must be in a group to do that.", "برای این کار باید در گروه باشید." },
    { "That item is not ready yet.", "آن آیتم هنوز آماده نیست." },
    { "Can't do that while moving", "هنگام حرکت نمی" .. Z .. "توانید این کار را انجام دهید." },
    -- 1.0.9 (the owner's report 25 Nov)
    { "Objective Complete.", "هدف انجام شد." },
    { "Resisted", "مقاومت کرد" },
    { "%s slain: %d/%d", "%s کشته" .. Z .. "شده: %d/%d" },
    -- 1.1.0 (the owner's report 25 Nov + nearby ones)
    { "Item is locked.", "آیتم قفل است." },
    { "That item is locked.", "آن آیتم قفل است." },
    { "You can't do that right now.", "الان نمی" .. Z .. "توانید این کار را انجام دهید." },
    { "Another action is in progress", "کار دیگری در حال انجام است" },
    { "Interrupted", "قطع شد" },
    { "Invalid target", "هدف نامعتبر" },
    { "Not yet recovered", "هنوز آماده نیست" },
    { "You are facing the wrong way!", "رو به سمت اشتباه هستید!" },
    { "Target too close", "هدف خیلی نزدیک است" },
    { "Your target is out of range.", "هدف شما خارج از برد است." },
    { "Out of range.", "خارج از برد." },
    { "You don't have enough reagents", "مواد لازم را ندارید" },
    -- 1.1.3 (the owner's report 25 Nov, build 71091)
    { "New flight path discovered!", "مسیر پرواز تازه" .. Z .. "ای کشف شد!" },
    { "Your pet is not dead.", "حیوان همراه شما نمرده است." },
    -- 1.1.8 (the owner's report 27 Nov, build 71139)
    { "There is nothing to attack.", "چیزی برای حمله وجود ندارد." },
    { "Can't do that while in combat", "در نبرد نمی" .. Z .. "توانید این کار را انجام دهید" },
}
