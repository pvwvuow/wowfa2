-- WoWFA Forever - rc29 texts: the system lines in the chat (loot, experience,
-- level, reputation, skills, group), more game alerts and the two new presets.
-- Same idea as Locale_Alerts.lua: each row is { GlobalStrings name, Persian };
-- the English is read from the game's own global at run time, so it is always
-- the exact text this client shows (a name this client does not have is skipped).
-- In the Persian text ~ is a half-space (ZWNJ). The alerts use %s / %d like
-- Locale_Alerts.lua; the system lines use {1} {2} {3} for the values the
-- English line holds, in the order they stand in the English.

local L = WoWFAF_L

local function fa(s)
    return (string.gsub(s, "~", "\226\128\140"))
end

L.sy_on = fa("پیام~های سیستم به فارسی")
L.sy_on_d = fa("غنیمت، تجربه، سطح، اعتبار، مهارت و پیام~های گروه در چت فارسی نوشته می~شوند (چت فارسی هم باید روشن باشد)")

L.pr_story = fa("فقط داستان")
L.pr_story_d = fa("مأموریت~ها، اسم NPC و منطقه~ها فارسی؛ جادوها و آیتم~ها انگلیسی")
L.pr_spells = fa("فقط جادوها")
L.pr_spells_d = fa("جادوها و استعدادها فارسی؛ بقیه انگلیسی")

-- more of the red messages in the middle of the screen (added to L.ALERTS)
local MORE = {
    { "SPELL_FAILED_NOT_STANDING", "برای این کار باید ایستاده باشید" },
    { "SPELL_FAILED_ONLY_OUTDOORS", "این را فقط بیرون از ساختمان می~توانید به کار ببرید" },
    { "SPELL_FAILED_ONLY_INDOORS", "این را فقط داخل ساختمان می~توانید به کار ببرید" },
    { "SPELL_FAILED_NO_COMBO_POINTS", "این توانایی امتیاز ترکیبی لازم دارد" },
    { "SPELL_FAILED_TARGET_AURASTATE", "هنوز نمی~توانید این کار را بکنید" },
    { "SPELL_FAILED_CASTER_AURASTATE", "هنوز نمی~توانید این کار را بکنید" },
    { "SPELL_FAILED_ITEM_NOT_READY", "آیتم هنوز آماده نیست" },
    { "SPELL_FAILED_CASTER_DEAD", "شما مرده~اید" },
    { "SPELL_FAILED_STUNNED", "وقتی مبهوت هستید نمی~توانید این کار را بکنید" },
    { "SPELL_FAILED_SILENCED", "وقتی ساکت شده~اید نمی~توانید این کار را بکنید" },
    { "SPELL_FAILED_CONFUSED", "وقتی گیج هستید نمی~توانید این کار را بکنید" },
    { "SPELL_FAILED_FLEEING", "وقتی در حال فرار هستید نمی~توانید این کار را بکنید" },
    { "SPELL_FAILED_ALREADY_AT_FULL_HEALTH", "سلامتی شما کامل است" },
    { "SPELL_FAILED_ALREADY_AT_FULL_MANA", "مانای شما کامل است" },
    { "SPELL_FAILED_CANT_DO_THAT_RIGHT_NOW", "همین حالا نمی~توانید این کار را بکنید" },
    { "ERR_CLIENT_LOCKED_OUT", "همین حالا نمی~توانید این کار را بکنید" },
    { "SPELL_FAILED_NO_PET", "پت ندارید" },
    { "ERR_NOT_WHILE_MOUNTED", "سواره نمی~توانید این کار را بکنید" },
    { "ERR_NOT_WHILE_SHAPESHIFTED", "در این شکل نمی~توانید این کار را بکنید" },
    { "ERR_NOT_WHILE_FALLING", "در حال سقوط نمی~توانید این کار را بکنید" },
    { "ERR_ATTACK_PACIFIED", "وقتی آرام شده~اید نمی~توانید حمله کنید" },
    { "ERR_ATTACK_STUNNED", "وقتی مبهوت هستید نمی~توانید حمله کنید" },
    { "ERR_ATTACK_CONFUSED", "وقتی گیج هستید نمی~توانید حمله کنید" },
    { "ERR_ATTACK_FLEEING", "وقتی در حال فرار هستید نمی~توانید حمله کنید" },
    { "ERR_ATTACK_DEAD", "وقتی مرده~اید نمی~توانید حمله کنید" },
    { "ERR_ATTACK_MOUNTED", "سواره نمی~توانید حمله کنید" },
    { "ERR_ATTACK_CHARMED", "وقتی افسون شده~اید نمی~توانید حمله کنید" },
    { "ERR_PLAYER_DEAD", "وقتی مرده~اید نمی~توانید این کار را بکنید" },
    { "ERR_CANTATTACK_NOTSTANDING", "برای حمله باید ایستاده باشید!" },
    { "ERR_LOOT_NOTSTANDING", "برای برداشتن غنیمت باید ایستاده باشید!" },
    { "ERR_BAG_FULL", "این کیف پر است." },
    { "ERR_ITEM_MAX_COUNT", "بیشتر از این نمی~توانید از این آیتم همراه داشته باشید." },
    { "ERR_CANT_EQUIP_LEVEL_I", "برای استفاده از این آیتم باید به سطح %d برسید." },
    { "ERR_QUEST_LOG_FULL", "دفتر مأموریت~های شما پر است." },
    { "ERR_QUEST_ALREADY_DONE", "این مأموریت را قبلاً انجام داده~اید." },
    { "ERR_QUEST_ALREADY_ON", "این مأموریت را از قبل دارید." },
    { "ERR_QUEST_FAILED_LOW_LEVEL", "سطح شما برای این مأموریت کافی نیست." },
    { "ERR_GROUP_FULL", "گروه شما پر است." },
    { "ERR_NOT_LEADER", "شما رهبر گروه نیستید." },
    { "ERR_ALREADY_IN_GROUP_S", "%s از قبل در یک گروه است." },
    { "ERR_CHAT_PLAYER_NOT_FOUND_S", "بازیکنی به نام «%s» الان در بازی نیست." },
    { "ERR_TAXINOPATHS", "مسیر مستقیمی به آن مقصد وجود ندارد!" },
    { "ERR_SPELL_OUT_OF_RANGE", "خارج از برد." },
}
L.ALERTS = L.ALERTS or {}
for _, e in ipairs(MORE) do
    L.ALERTS[#L.ALERTS + 1] = { e[1], fa(e[2]) }
end

-- the system lines in the chat (Modules/Sysmsg.lua)
L.SYSMSG = {
    { "LOOT_ITEM_SELF", "غنیمت دریافت کردید: {1}" },
    { "LOOT_ITEM_SELF_MULTIPLE", "غنیمت دریافت کردید: {1} ({2} عدد)" },
    { "LOOT_ITEM_PUSHED_SELF", "آیتم دریافت کردید: {1}" },
    { "LOOT_ITEM_PUSHED_SELF_MULTIPLE", "آیتم دریافت کردید: {1} ({2} عدد)" },
    { "LOOT_ITEM_CREATED_SELF", "ساختید: {1}" },
    { "LOOT_ITEM_CREATED_SELF_MULTIPLE", "ساختید: {1} ({2} عدد)" },
    { "LOOT_ITEM", "{1} غنیمت دریافت کرد: {2}" },
    { "LOOT_ITEM_MULTIPLE", "{1} غنیمت دریافت کرد: {2} ({3} عدد)" },
    { "LOOT_ITEM_PUSHED", "{1} آیتم دریافت کرد: {2}" },
    { "LOOT_ITEM_PUSHED_MULTIPLE", "{1} آیتم دریافت کرد: {2} ({3} عدد)" },
    { "YOU_LOOT_MONEY", "{1} پول برداشتید" },
    { "LOOT_MONEY_SPLIT", "سهم شما از غنیمت: {1}" },
    { "COMBATLOG_XPGAIN_FIRSTPERSON", "{1} کشته شد؛ {2} امتیاز تجربه گرفتید." },
    { "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED", "{1} امتیاز تجربه گرفتید." },
    { "ERR_QUEST_REWARD_EXP_I", "تجربهٔ به~دست~آمده: {1}" },
    { "ERR_QUEST_REWARD_MONEY_S", "دریافت شد: {1}" },
    { "ERR_QUEST_REWARD_ITEM_S", "آیتم دریافت شد: {1}" },
    { "ERR_QUEST_ACCEPTED_S", "مأموریت پذیرفته شد: {1}" },
    { "ERR_QUEST_COMPLETE_S", "{1} تکمیل شد." },
    { "LEVEL_UP", "به سطح {1} رسیدید!" },
    { "ERR_SKILL_UP_SI", "مهارت شما در {1} به {2} رسید." },
    { "FACTION_STANDING_INCREASED", "اعتبار شما نزد {1} به اندازهٔ {2} افزایش یافت." },
    { "FACTION_STANDING_DECREASED", "اعتبار شما نزد {1} به اندازهٔ {2} کاهش یافت." },
    { "ERR_LEARN_SPELL_S", "جادوی تازه~ای یاد گرفتید: {1}" },
    { "ERR_LEARN_ABILITY_S", "توانایی تازه~ای یاد گرفتید: {1}" },
    { "ERR_LEARN_PASSIVE_S", "اثر پایدار تازه~ای یاد گرفتید: {1}" },
    { "ERR_SPELL_UNLEARNED_S", "{1} را فراموش کردید." },
    { "ERR_ZONE_EXPLORED", "{1} کشف شد" },
    { "ERR_ZONE_EXPLORED_XP", "{1} کشف شد: {2} امتیاز تجربه" },
    { "ERR_NEWTAXIPATH", "مسیر پرواز تازه~ای کشف شد!" },
    { "ERR_DEATHBIND_SUCCESS_S", "{1} حالا خانهٔ شماست." },
    { "ERR_JOINED_GROUP_S", "{1} به گروه پیوست." },
    { "ERR_LEFT_GROUP_S", "{1} گروه را ترک کرد." },
    { "ERR_LEFT_GROUP_YOU", "گروه را ترک کردید." },
    { "ERR_GROUP_DISBANDED", "گروه شما منحل شد." },
    { "ERR_RAID_MEMBER_ADDED_S", "{1} به گروه رید پیوست." },
    { "ERR_RAID_MEMBER_REMOVED_S", "{1} گروه رید را ترک کرد." },
    { "MARKED_AFK", "حالا AFK هستید." },
    { "CLEARED_AFK", "دیگر AFK نیستید." },
}
for _, e in ipairs(L.SYSMSG) do
    e[2] = fa(e[2])
end
