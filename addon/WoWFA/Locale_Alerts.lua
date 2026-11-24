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
}
