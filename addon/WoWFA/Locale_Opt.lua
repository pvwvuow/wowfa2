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
L.sy_sysLoot = fa("پیام~های غنیمت و پول")
L.sy_sysXp = fa("پیام~های تجربه، سطح و مأموریت~ها")
L.sy_sysRep = fa("پیام~های اعتبار، مهارت و جادوی تازه")
L.sy_sysGroup = fa("پیام~های گروه و AFK")

L.ALERTS = L.ALERTS or {}
L.ALERTS[#L.ALERTS + 1] = { "There is no loot.", fa("غنیمتی وجود ندارد.") }
