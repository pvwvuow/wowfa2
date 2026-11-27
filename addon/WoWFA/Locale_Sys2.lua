-- WoWFA Forever 1.2.1 - more system lines of the chat (the owner 27 Nov: "[item] has been added to your
-- appearance collection" and "Thunder seems to be sobering up" stayed English). Same format as
-- Locale_Sys.lua: { GlobalStrings name, Persian with {1} {2} for the values in the order of the English }.
-- The English is read from the game's own global at run time. Written as Persian people say it.

local L = WoWFAF_L

local function fa(s)
    return (string.gsub(s, "~", "\226\128\140"))
end

local ROWS = {
    -- collections
    { "ERR_LEARN_TRANSMOG_S", "{1} به مجموعهٔ ظاهرهای شما اضافه شد." },
    { "ERR_REVOKE_TRANSMOG_S", "{1} از مجموعهٔ ظاهرهای شما حذف شد." },
    { "ERR_LEARN_COMPANION_S", "پت {1} به مجموعهٔ شما اضافه شد." },
    { "ERR_LEARN_MOUNT_S", "مانت {1} به مجموعهٔ شما اضافه شد." },
    { "ERR_LEARN_TOY_S", "{1} به جعبهٔ اسباب~بازی~هایتان اضافه شد." },
    { "ERR_LEARN_HEIRLOOM_S", "{1} به مجموعهٔ یادگاری~هایتان اضافه شد." },
    { "ERR_LEARN_RECIPE_S", "یاد گرفتید چطور آیتم تازه~ای بسازید: {1}." },
    { "ERR_PET_LEARN_ABILITY_S", "پت شما توانایی تازه~ای یاد گرفت: {1}." },
    { "ERR_PET_LEARN_SPELL_S", "پت شما جادوی تازه~ای یاد گرفت: {1}." },
    { "NEW_TITLE_EARNED", "عنوان «{1}» را به~دست آوردید." },
    { "NEW_ACHIEVEMENT_EARNED", "دستاورد «{1}» را به~دست آوردید." },
    { "ACHIEVEMENT_BROADCAST", "{1} دستاورد {2} را به~دست آورد!" },
    { "ACHIEVEMENT_BROADCAST_SELF", "دستاورد {1} را به~دست آوردید!" },
    -- drunk
    { "DRUNK_MESSAGE_SELF1", "دوباره هوشیار شدید." },
    { "DRUNK_MESSAGE_SELF2", "کمی سرخوش شده~اید. هورا!" },
    { "DRUNK_MESSAGE_SELF3", "مست شده~اید. وای!" },
    { "DRUNK_MESSAGE_SELF4", "کاملاً مست و پاتیل شده~اید." },
    { "DRUNK_MESSAGE_OTHER1", "{1} دارد هوشیار می~شود." },
    { "DRUNK_MESSAGE_OTHER2", "{1} سرخوش به نظر می~رسد." },
    { "DRUNK_MESSAGE_OTHER3", "{1} مست به نظر می~رسد." },
    { "DRUNK_MESSAGE_OTHER4", "{1} کاملاً مست و پاتیل به نظر می~رسد." },
    { "DRUNK_MESSAGE_ITEM_SELF1", "بعد از {1} هوشیار شدید." },
    { "DRUNK_MESSAGE_ITEM_SELF2", "از {1} کمی سرخوش شده~اید." },
    { "DRUNK_MESSAGE_ITEM_SELF3", "از {1} مست شده~اید." },
    { "DRUNK_MESSAGE_ITEM_SELF4", "بعد از {1} کاملاً مست و پاتیل شدید." },
    { "DRUNK_MESSAGE_ITEM_OTHER1", "{1} بعد از {2} هوشیار به نظر می~رسد." },
    { "DRUNK_MESSAGE_ITEM_OTHER2", "{1} از {2} کمی سرخوش شده است." },
    { "DRUNK_MESSAGE_ITEM_OTHER3", "{1} از {2} مست شده است." },
    { "DRUNK_MESSAGE_ITEM_OTHER4", "{1} از {2} کاملاً مست و پاتیل شده است." },
    -- friends and ignore
    { "ERR_FRIEND_OFFLINE_S", "{1} آفلاین شد." },
    { "ERR_FRIEND_ADDED_S", "{1} به فهرست دوستان اضافه شد." },
    { "ERR_FRIEND_REMOVED_S", "{1} از فهرست دوستان حذف شد." },
    { "ERR_FRIEND_ALREADY_S", "{1} از قبل دوست شماست." },
    { "ERR_FRIEND_NOT_FOUND", "بازیکن پیدا نشد." },
    { "ERR_FRIEND_SELF", "نمی~توانید خودتان را به فهرست دوستان اضافه کنید." },
    { "ERR_FRIEND_LIST_FULL", "جایی برای دوست بیشتر ندارید." },
    { "ERR_IGNORE_ADDED_S", "{1} حالا نادیده گرفته می~شود." },
    { "ERR_IGNORE_REMOVED_S", "{1} دیگر نادیده گرفته نمی~شود." },
    { "ERR_IGNORE_ALREADY_S", "{1} از قبل نادیده گرفته می~شود." },
    { "ERR_IGNORE_SELF", "نمی~توانید خودتان را نادیده بگیرید." },
    { "ERR_IGNORE_FULL", "نمی~توانید بازیکن بیشتری را نادیده بگیرید." },
    -- guild
    { "ERR_GUILD_JOIN_S", "{1} به گیلد پیوست." },
    { "ERR_GUILD_LEAVE_S", "{1} گیلد را ترک کرد." },
    { "ERR_GUILD_LEAVE_RESULT", "گیلد را ترک کردید." },
    { "ERR_GUILD_QUIT_S", "دیگر عضو {1} نیستید." },
    { "ERR_GUILD_INVITE_S", "{1} را به گیلدتان دعوت کردید." },
    { "ERR_GUILD_PROMOTE_SSS", "{1} مقام {2} را به {3} ارتقا داد." },
    { "ERR_GUILD_DEMOTE_SSS", "{1} مقام {2} را به {3} تنزل داد." },
    { "ERR_GUILD_DEMOTE_SS", "مقام {1} به {2} تنزل یافت." },
    { "ERR_GUILD_FOUNDER_S", "تبریک، شما عضو مؤسس {1} هستید!" },
    -- duel and trade
    { "DUEL_REQUESTED", "{1} شما را به دوئل دعوت کرد." },
    { "ERR_DUEL_REQUESTED", "درخواست دوئل دادید." },
    { "ERR_DUEL_CANCELLED", "دوئل لغو شد." },
    { "DUEL_WINNER_KNOCKOUT", "{1} در دوئل {2} را شکست داد." },
    { "DUEL_WINNER_RETREAT", "{1} در دوئل از {2} گریخت." },
    { "DUEL_COUNTDOWN", "دوئل شروع می~شود: {1}" },
    { "ERR_TRADE_COMPLETE", "معامله انجام شد." },
    { "ERR_TRADE_CANCELLED", "معامله لغو شد." },
    { "ERR_TRADE_REQUEST_S", "{1} درخواست معامله با شما داد." },
    { "ERR_TRADE_BLOCKED_S", "{1} درخواست معامله داد و شما رد کردید." },
    { "ERR_TRADE_TOO_FAR", "طرف معامله خیلی دور است." },
    { "ERR_TRADE_SELF", "نمی~توانید با خودتان معامله کنید." },
    -- auction
    { "ERR_AUCTION_SOLD_S", "برای حراج {1} شما خریدار پیدا شد." },
    { "ERR_AUCTION_WON_S", "حراج {1} را بردید." },
    { "ERR_AUCTION_OUTBID_S", "کسی برای {1} پیشنهاد بالاتری داد." },
    { "ERR_AUCTION_EXPIRED_S", "حراج شما برای {1} منقضی شد." },
    -- group and instance
    { "ERR_PLAYER_DIED_S", "{1} مرد." },
    { "ERR_RAID_LEADER_READY_CHECK_START_S", "{1} بررسی آمادگی را شروع کرد." },
    { "INSTANCE_RESET_SUCCESS", "{1} ریست شد." },
    { "INSTANCE_RESET_FAILED", "{1} ریست نمی~شود. هنوز بازیکنانی داخل آن هستند." },
    { "ERR_PARTY_CONVERTED_TO_RAID", "گروه به رید تبدیل شد." },
    { "ERR_PARTY_LFG_BOOT_VOTE_SUCCEEDED", "رأی اخراج {1} تصویب شد." },
    { "ERR_PARTY_LFG_BOOT_VOTE_FAILED", "رأی اخراج {1} رد شد." },
    -- status
    { "MARKED_AFK_MESSAGE", "حالا AFK هستید: {1}" },
    { "MARKED_DND", "حالا مشغول هستید: {1}" },
    { "CLEARED_DND", "دیگر مشغول نیستید." },
    { "QUEST_FAILED", "تکمیل مأموریت ناموفق بود." },
    -- mounts
    { "ERR_MOUNT_ALREADYMOUNTED", "همین حالا سوار هستید." },
    { "ERR_MOUNT_LOOTING", "هنگام برداشتن غنیمت نمی~توانید سوار شوید!" },
    { "ERR_MOUNT_SHAPESHIFTED", "در این شکل نمی~توانید سوار شوید." },
    { "ERR_MOUNT_FORCEDDISMOUNT", "پیش از ادامه پیاده شدید." },
    { "ERR_TALENT_WIPE_ERROR", "هیچ استعدادی انتخاب نکرده~اید." },
}

L.SYSMSG = L.SYSMSG or {}
for _, e in ipairs(ROWS) do
    L.SYSMSG[#L.SYSMSG + 1] = { e[1], fa(e[2]) }
end
