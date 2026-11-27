-- WoWFA Forever - the system lines of the chat (rc29): loot, experience, level
-- up, reputation, skills, new spells, group changes. Like the game alerts
-- (Alerts.lua) the English text of each line is read from the game's own
-- GlobalStrings (L.SYSMSG in Locale_Sys.lua); a chat filter swaps a line that
-- matches for the Persian text, shaped with our shaper. Item links and money
-- (anything with a | in it) are kept out of the shaper under a Latin
-- placeholder and put back after it, so a link is never touched. A line that
-- does not match stays English. Switch: General > system lines (F.db.sysmsg,
-- default on) and one switch per group (F.db.sysLoot / sysXp / sysRep / sysGroup,
-- default on); it needs the Persian chat switch too (the chat font).
-- Not a registered module: one filter, every call wrapped in pcall.

local F = WoWFAF
local L = F.L
local T = F.T

local EVENTS = {
    'CHAT_MSG_LOOT', 'CHAT_MSG_MONEY', 'CHAT_MSG_COMBAT_XP_GAIN', 'CHAT_MSG_SYSTEM',
    'CHAT_MSG_SKILL', 'CHAT_MSG_COMBAT_FACTION_CHANGE', 'CHAT_MSG_TEXT_EMOTE',
}

local rules, exact
local registered = false

local function on()
    local db = F.db
    return db and db.enabled and db.sysmsg ~= false and db.chatFa ~= false and true or false
end

-- which switch of General a row belongs to
local function category(name)
    if string.find(name, '^LOOT_') or string.find(name, '^YOU_LOOT') or name == 'ERR_QUEST_REWARD_MONEY_S'
        or name == 'ERR_QUEST_REWARD_ITEM_S' then
        return 'sysLoot'
    end
    if string.find(name, '^FACTION_') or string.find(name, '^ERR_SKILL') or string.find(name, '^ERR_LEARN')
        or name == 'ERR_SPELL_UNLEARNED_S' or string.find(name, '^ERR_REVOKE') or string.find(name, '^NEW_')
        or string.find(name, '^ACHIEVEMENT_') or string.find(name, '^ERR_PET_LEARN') then
        return 'sysRep'
    end
    if string.find(name, 'GROUP', 1, true) or string.find(name, 'RAID', 1, true) or string.find(name, 'AFK', 1, true) then
        return 'sysGroup'
    end
    -- 1.2.1: friends, guild, duel, trade, auction, instance resets (the social lines)
    for _, p in ipairs({ '^ERR_FRIEND', '^ERR_IGNORE', '^ERR_GUILD', '^ERR_TRADE', '^ERR_DUEL', '^DUEL_', '^ERR_AUCTION',
        '^ERR_PARTY', '^INSTANCE_RESET', '^MARKED_', '^CLEARED_', '^ERR_PLAYER_DIED', '^ERR_MOUNT' }) do
        if string.find(name, p) then
            return 'sysGroup'
        end
    end
    return 'sysXp'
end

-- the English of every row becomes a Lua pattern: %s -> (.-)  %d -> (%d+)
local function build()
    rules, exact = {}, {}
    for _, e in ipairs(L.SYSMSG or {}) do
        local en = _G[e[1]]
        if en == nil and string.find(e[1], ' ', 1, true) then
            en = e[1] -- a row named by its English text (a line only the server sends: no global for it)
        end
        if type(en) == 'string' and en ~= '' and type(e[2]) == 'string' then
            local n = 0
            local p = string.gsub(en, '%%(%d*)%$?([sd])', function(_, kind)
                n = n + 1
                if kind == 'd' then
                    return '\2'
                end
                return '\1'
            end)
            if n == 0 then
                exact[en] = { e[2], category(e[1]) }
            else
                p = string.gsub(p, '([%^%$%(%)%%%.%[%]%*%+%-%?])', '%%%1')
                p = string.gsub(p, '\1', '(.-)')
                p = string.gsub(p, '\2', '(%%d+)')
                rules[#rules + 1] = { '^' .. p .. '$', e[2], category(e[1]) }
            end
        end
    end
end

local function render(tpl, caps, frame)
    local vals, holds = {}, {}
    for i = 1, #caps do
        local v = caps[i]
        if string.find(v, '|', 1, true) then
            local ph = 'QX' .. string.char(64 + i) .. 'Z'
            holds[ph] = v
            vals[i] = ph
        else
            vals[i] = v
        end
    end
    local line = string.gsub(tpl, '{(%d)}', function(d)
        return vals[tonumber(d)] or ''
    end)
    -- a captured value the Persian text does not use needs no placeholder
    local need = {}
    for ph, v in pairs(holds) do
        if string.find(line, ph, 1, true) then
            need[ph] = v
        end
    end
    local shaped = T.ChatText(T.Digits(line), frame, 0) -- 1.1.6: wrapped by us
    if type(shaped) ~= 'string' or shaped == '' then
        return nil
    end
    local found = {}
    shaped = string.gsub(shaped, 'QX%uZ', function(ph)
        local v = need[ph]
        if v then
            found[ph] = true
            return v
        end
    end)
    for ph in pairs(need) do
        if not found[ph] then
            return nil -- the shaper changed a placeholder: leave the line English
        end
    end
    return shaped
end

local function translate(text, frame)
    if not rules then
        build()
    end
    local row = exact[text]
    if row then
        if F.db[row[2]] == false then
            return nil
        end
        return render(row[1], {}, frame)
    end
    for i = 1, #rules do
        local caps = { string.match(text, rules[i][1]) }
        if caps[1] ~= nil then
            if F.db[rules[i][3]] == false then
                return nil
            end
            return render(rules[i][2], caps, frame)
        end
    end
    return nil
end

-- 1.2.1 (the owner 27 Nov: such lines were not in the report): a system line no row matches is noted once
-- as a miss of kind sys (item and player links become %s, numbers #), 60 at most, so the next build
-- can translate it. Only CHAT_MSG_SYSTEM: player emotes would flood the list.
local sysSeen, sysN = {}, 0

local function note(msg)
    local lo, hi = string.char(216), string.char(219)
    if sysN >= 60 or #msg < 8 or #msg > 220 or string.find(msg, '[' .. lo .. '-' .. hi .. ']') then
        return
    end
    local k = msg
    k = string.gsub(k, '|c%x%x%x%x%x%x%x%x', '')
    k = string.gsub(k, '|r', '')
    k = string.gsub(k, '|H.-|h%b[]|h', '%%s')
    k = string.gsub(k, '|T.-|t', '')
    k = string.gsub(k, '^%s+', '')
    k = string.gsub(k, '%s+$', '')
    if #k < 8 then
        return
    end
    local ok, key = pcall(T.NumKey, k)
    if not ok or type(key) ~= 'string' or key == '' or sysSeen[key] then
        return
    end
    sysSeen[key] = true
    sysN = sysN + 1
    F:Miss('sys', key, k, 'system')
end

local function filter(cf, event, msg, ...)
    if not on() or not F.Usable(msg) or type(msg) ~= 'string' or msg == '' then
        return false
    end
    local ok, shaped = pcall(translate, msg, cf)
    if ok and type(shaped) == 'string' and shaped ~= '' then
        return false, shaped, ...
    end
    if event == 'CHAT_MSG_SYSTEM' then
        pcall(note, msg)
    end
    return false
end

-- 1.1.6: the settings preview column asks for the Persian of a system line (nil = English)
function F.SysmsgPreview(text)
    if not on() then
        return nil
    end
    local ok, s = pcall(translate, text)
    return ok and type(s) == "string" and s ~= "" and s or nil
end

local function install()
    if registered then
        return
    end
    local add = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter) or ChatFrame_AddMessageEventFilter
    if type(add) ~= 'function' then
        return
    end
    for _, ev in ipairs(EVENTS) do
        pcall(add, ev, filter)
    end
    registered = true
end

F:Listen('login', function()
    local ok, err = pcall(install)
    if not ok then
        F:LogError('sysmsg', err)
    end
end)
