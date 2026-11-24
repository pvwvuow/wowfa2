-- WoWFA Forever - the modern UI walker (rc14). The game's own modern windows (the
-- quest log list docked to the map, the objective tracker, the spellbook pages) are
-- not the classic frames the other modules know and have no global to hook. Every
-- font string under those windows gets the same in-place SetText hook the zone names
-- use:
--   quest log / tracker: "[38] Panther Mastery" -> the Persian title (the level tag stays),
--                        "0/8 Skeletal Warrior slain" -> the Persian objective line
--   spellbook:           the spell names, "Rank 3", the tree titles
-- Text we do not know is left alone and never logged as a miss. Our own output is
-- remembered, so a re-scan never reads it back as English.

local F = WoWFAF
local L = F.L
local T = F.T

local W = {}
F.Walk = W

local SEP = "\031"

local SUFFIX = { complete = "تکمیل‌شده", dungeon = "دانجن", raid = "رید", elite = "ایلیت",
    group = "گروهی", daily = "روزانه", pvp = "پی‌وی‌پی" }

-- a wrapped colour code is kept: "|cffffd200[38] Title|r"
local function plain_of(t)
    if string.find(t, "|T", 1, true) or string.find(t, "|A", 1, true) or string.find(t, "|H", 1, true) then
        return nil
    end
    local c = string.match(t, "^(|c%x%x%x%x%x%x%x%x)")
    local p = (string.gsub(t, "|c%x%x%x%x%x%x%x%x", ""))
    p = (string.gsub(p, "|r", ""))
    return p, c
end

local function shaped(s)
    return T.ShapeLine(T.Digits(s), T.Mode())
end

-- Persian bytes (plain \216-\219, the shaped presentation forms \239)
local function has_fa(s)
    return type(s) == "string" and string.find(s, "[\216-\219\239]") ~= nil
end

-- rc18 (the owner's screenshot: the quest list titles stayed English): the quest log
-- names the quest id of every title (the tracker reads it the same way); the title
-- hash of the data is only the fallback
local logIdx = {}
local function simple(s)
    return (string.gsub(string.lower(tostring(s or "")), "[^%w]", ""))
end

function W.RebuildLog()
    logIdx = {}
    if C_QuestLog and C_QuestLog.GetInfo and C_QuestLog.GetNumQuestLogEntries then
        local okn, n = pcall(C_QuestLog.GetNumQuestLogEntries)
        if not okn or not F.Usable(n) or type(n) ~= "number" then
            return
        end
        for i = 1, n do
            local ok, info = pcall(C_QuestLog.GetInfo, i)
            if ok and type(info) == "table" and F.Usable(info.questID) and type(info.questID) == "number"
                and info.questID > 0 and F.Usable(info.title) and type(info.title) == "string" and info.title ~= "" then
                logIdx[simple(info.title)] = info.questID
            end
        end
    elseif GetNumQuestLogEntries and GetQuestLogTitle then
        local okn, n = pcall(GetNumQuestLogEntries)
        if not okn or not F.Usable(n) or type(n) ~= "number" then
            return
        end
        for i = 1, n do
            local ok, title, _, _, _, _, _, _, qid = pcall(GetQuestLogTitle, i)
            if ok and F.Usable(qid) and type(qid) == "number" and qid > 0 and F.Usable(title)
                and type(title) == "string" and title ~= "" then
                logIdx[simple(title)] = qid
            end
        end
    end
end

function W.LogId(title)
    local k = simple(title)
    return k ~= "" and logIdx[k] or nil
end

-- ------------------------------------------------------------ quest titles
local byHash
local function quest_row(title)
    if not byHash then
        byHash = {}
        for id, row in pairs((F.D and F.D.quests) or {}) do
            if type(row) == "string" then
                local h = string.match(row, "^([^" .. SEP .. "]*)")
                if h and h ~= "" and not byHash[h] then
                    byHash[h] = id
                end
            end
        end
    end
    local id = W.LogId(title)
    if not id or type(F.D.quests[id]) ~= "string" then
        local h = F.TitleHash(title)
        id = h ~= "" and byHash[h] or nil
    end
    local row = id and F.D.quests[id]
    if type(row) ~= "string" then
        return nil
    end
    local p = F.Split(row, SEP)
    if (p[2] or "") == "" then
        return nil
    end
    return T.Prepare(p[2])
end

function W.Quest(text)
    if not F.Room.On("namesQuest") or (F.db and F.db.listTitles == false) then
        return nil
    end
    local plain, c = plain_of(text)
    if not plain or plain == "" then
        return nil
    end
    local lvl, title = string.match(plain, "^(%[[^%]]*%])%s*(.+)$")
    title = title or plain
    local fa = quest_row(title)
    local suffix
    if not fa then
        local base, word = string.match(title, "^(.-)%s*%((%a+)%)$")
        if base and base ~= "" then
            fa = quest_row(base)
            suffix = word
        end
    end
    if not fa then
        return nil
    end
    local tail = ""
    if suffix then
        tail = " (" .. (SUFFIX[string.lower(suffix)] or suffix) .. ")"
    end
    local out = (lvl and (lvl .. " ") or "") .. shaped(fa .. tail)
    return (c or "") .. out .. (c and "|r" or "")
end

-- "0/8 Skeletal Warrior slain" / "Skeletal Warrior slain: 0/8"
function W.Objective(text)
    if not F.Room.On("questText") then
        return nil
    end
    local plain, c = plain_of(text)
    if not plain or plain == "" then
        return nil
    end
    local dash, body = string.match(plain, "^(%s*%-+%s*)(.+)$")
    body = body or plain
    dash = dash or ""
    -- rc18: the status line of a finished quest
    local st = string.lower(string.match(body, "^%s*(.-)%s*$") or "")
    if st == "ready for turn-in" or st == "complete" or st == "(complete)" then
        local word = (st == "ready for turn-in") and (L.tracker_ready or "آمادهٔ تحویل")
            or (L.tracker_complete or SUFFIX.complete)
        if st == "(complete)" then
            word = "(" .. word .. ")"
        end
        return (c or "") .. dash .. shaped(word) .. (c and "|r" or "")
    end
    local got, need, name = string.match(body, "^(%d+)/(%d+)%s+(.-)%s+slain$")
    if not got then
        name, got, need = string.match(body, "^(.-)%s+slain:%s*(%d+)/(%d+)$")
    end
    if not got or not name or name == "" or string.find(name, "[|{}]") then
        return nil
    end
    local names = (F.D and F.D.names) or {}
    local key = T.NameKey(name)
    local fa = (names.npc and names.npc[key]) or (names.boss and names.boss[key]) or name
    local line = T.Digits(T.Prepare(string.format("{{npc:%s|%s}} %s: %d/%d", name, fa, L.tracker_slain or "", tonumber(got), tonumber(need))))
    return (c or "") .. dash .. T.ShapeLine(line, T.Mode()) .. (c and "|r" or "")
end

-- ------------------------------------------------------------ the spellbook
function W.Spell(text)
    if not F.Room.On("namesSpell") or F.Disp("spellbook", "title") == 3 then
        return nil
    end
    local plain, c = plain_of(text)
    if not plain or plain == "" then
        return nil
    end
    local names = (F.D and F.D.names) or {}
    local out
    local rk = string.match(plain, "^Rank%s+(%d+)$")
    if rk then
        out = shaped("رتبه " .. rk)
    else
        local key = T.NameKey(plain)
        local fa = (names.spell and names.spell[key]) or (names.tree and names.tree[key])
        if not fa then
            return nil
        end
        out = shaped(fa)
    end
    return (c or "") .. out .. (c and "|r" or "")
end

-- ------------------------------------------------------------ hooks
local hooked = setmetatable({}, { __mode = "k" }) -- fs -> kind
local eng = setmetatable({}, { __mode = "k" })    -- fs -> the English text before we wrote
local mine = setmetatable({}, { __mode = "k" })   -- fs -> { font, size, flags }
local last = setmetatable({}, { __mode = "k" })   -- fs -> the text we wrote
local cand = setmetatable({}, { __mode = "k" })   -- rc18: fs -> true once we wrote it (the watch list)
local seenT = setmetatable({}, { __mode = "k" })  -- rc18: fs -> the text the watch read last
local writing = {}
local memo = {}
local memo_n = 0 -- rc36: the memo is emptied past 4000 lines (live counts make new keys)

local function kind_active(kind)
    local m = F.mods and F.mods[kind == "spell" and "spellbook" or "tracker"]
    return (m and m.active) and true or false
end

local function translate(kind, text)
    local key = kind .. "\1" .. text
    local v = memo[key]
    if v == nil then
        if kind == "quest" then
            v = W.Objective(text) or W.Quest(text) or false
        else
            v = W.Spell(text) or false
        end
        if memo_n >= 4000 then
            memo, memo_n = {}, 0
        end
        memo[key] = v
        memo_n = memo_n + 1
    end
    return v or nil
end

-- rc35: the size of a line comes from its ROLE (F.SizeOf) - never from the font the
-- string shows right now (that read our own size back: the titles grew on every redraw)
local function role_of(kind, english)
    if kind == "spell" then
        return "spell"
    end
    local p = plain_of(english or "") or ""
    if string.find(p, "^%s*%[") then
        return "title"
    end
    local lp = string.lower(p)
    if string.find(p, "%d+/%d+") or string.find(lp, "turn%-in") or string.find(lp, "complete") then
        return "obj"
    end
    return "title"
end

local function put(fs, out, english)
    local g = F.GameFont(fs) -- rc32: the game's own font, never ours read back as the original
    mine[fs] = { font = g.font, size = g.size, flags = g.flags, fobj = g.fobj, role = role_of(hooked[fs], english) }
    eng[fs] = english
    writing[fs] = true
    local sz = F.SizeOf(mine[fs].role)
    fs:SetFont(F.FONT, sz, "")
    fs:SetText(out)
    F.FitLine(fs, sz)
    writing[fs] = nil
    last[fs] = out
    cand[fs] = true
    seenT[fs] = out
end

local function font_back(fs)
    local o = mine[fs]
    if not o then
        return
    end
    writing[fs] = true
    F.RestoreFont(fs, o)
    writing[fs] = nil
    mine[fs], last[fs] = nil, nil
end

local function process(fs, text)
    if writing[fs] or not F.Usable(text) or type(text) ~= "string" or text == "" then
        return
    end
    if last[fs] == text then
        return -- our own output read back
    end
    if has_fa(text) then
        -- rc18: Persian another module wrote here (the zone headers): never ours to
        -- undo - putting the game font back under it drew the empty boxes
        mine[fs], last[fs] = nil, nil
        return
    end
    local kind = hooked[fs]
    if not kind or not kind_active(kind) then
        return
    end
    local out = translate(kind, text)
    if out and out ~= text then
        put(fs, out, text)
    elseif mine[fs] then
        font_back(fs) -- the client wrote text we do not translate: only the font returns
    end
end

local function hook(fs, kind)
    if hooked[fs] then
        return
    end
    hooked[fs] = kind
    if type(hooksecurefunc) == "function" then
        pcall(hooksecurefunc, fs, "SetText", function(self, text)
            local ok, err = pcall(process, self, text)
            if not ok then
                F:LogError("tracker", err)
            end
        end)
    end
end

local function walk(frame, kind, depth, budget)
    if budget.n <= 0 or depth > 12 then
        return
    end
    budget.n = budget.n - 1
    local okr, regions = pcall(function()
        return { frame:GetRegions() }
    end)
    if okr then
        for _, r in ipairs(regions) do
            if type(r) == "table" and r.GetObjectType and r.SetText and r.GetText and r.GetFont then
                local okt, ot = pcall(r.GetObjectType, r)
                if okt and ot == "FontString" then
                    hook(r, kind)
                    local okx, txt = pcall(r.GetText, r)
                    if okx then
                        process(r, txt)
                    end
                end
            end
        end
    end
    local okc, kids = pcall(function()
        return { frame:GetChildren() }
    end)
    if okc then
        for _, k in ipairs(kids) do
            if type(k) == "table" and k.GetRegions then
                walk(k, kind, depth + 1, budget)
            end
        end
    end
end

local QUEST_ROOTS = { "WorldMapFrame", "QuestMapFrame", "QuestLogFrame", "ObjectiveTrackerFrame", "QuestWatchFrame", "WatchFrame" }
local SPELL_ROOTS = { "SpellBookFrame", "PlayerSpellsFrame", "SpellbookFrame" }

local function roots_for(kind)
    local out, seen = {}, {}
    for _, n in ipairs(kind == "spell" and SPELL_ROOTS or QUEST_ROOTS) do
        local f = _G[n]
        if type(f) == "table" and f.GetChildren and not seen[f] then
            seen[f] = true
            out[#out + 1] = f
        end
    end
    if kind == "spell" and UIParent and UIParent.GetChildren then
        local okc, kids = pcall(function()
            return { UIParent:GetChildren() }
        end)
        if okc then
            for _, k in ipairs(kids) do
                local okn, nm = pcall(function()
                    return k.GetName and k:GetName()
                end)
                if okn and type(nm) == "string" and not seen[k]
                    and (string.find(nm, "SpellBook", 1, true) or string.find(nm, "PlayerSpells", 1, true)) then
                    seen[k] = true
                    out[#out + 1] = k
                end
            end
        end
    end
    return out
end

function W.Scan()
    if InCombatLockdown and InCombatLockdown() then
        return -- rc36: never touch the tracker in combat; the ticker scans again after
    end
    for _, kind in ipairs({ "quest", "spell" }) do
        if kind_active(kind) then
            for _, root in ipairs(roots_for(kind)) do
                local ok, shown = pcall(root.IsShown, root)
                if ok and shown then
                    pcall(walk, root, kind, 0, { n = 2500 })
                end
            end
        end
    end
end

-- a switch changed: every line we wrote goes back to the English the client sent,
-- then the scan writes again what is still allowed
local function refresh_all()
    memo = {}
    local list = {}
    for fs in pairs(mine) do
        list[#list + 1] = fs
    end
    for _, fs in ipairs(list) do
        local o = mine[fs]
        writing[fs] = true
        F.RestoreFont(fs, o)
        if eng[fs] then
            pcall(fs.SetText, fs, eng[fs])
        end
        writing[fs] = nil
        mine[fs], last[fs] = nil, nil
    end
    W.Scan()
end
W.Refresh = refresh_all

-- rc18: the client also rewrites these lines through paths no hook sees
-- (Button:SetText, SetFormattedText): every line we once wrote is read back every
-- frame and translated again the moment it changed
function W.Watch()
    for fs in pairs(cand) do
        local ok, txt = pcall(fs.GetText, fs)
        if ok and F.Usable(txt) and type(txt) == "string" and txt ~= seenT[fs] then
            seenT[fs] = txt
            if txt ~= last[fs] then
                process(fs, txt)
            end
        end
    end
end

-- /wowfa why: one chat report for the owner when a quest list line stays English
function W.Why()
    local n, w, li = 0, 0, 0
    for _ in pairs(hooked) do
        n = n + 1
    end
    for _ in pairs(mine) do
        w = w + 1
    end
    for _ in pairs(logIdx) do
        li = li + 1
    end
    F.Chat(string.format("WoWFA why: tracker=%s listTitles=%s namesQuest=%s questText=%s hooked=%d written=%d log=%d",
        kind_active("quest") and "on" or "off", tostring(F.db and F.db.listTitles),
        tostring(F.Room.On("namesQuest")), tostring(F.Room.On("questText")), n, w, li))
    local shown = 0
    for fs, kind in pairs(hooked) do
        if kind == "quest" and shown < 6 then
            local ok, txt = pcall(fs.GetText, fs)
            if ok and F.Usable(txt) and type(txt) == "string" and txt ~= "" and not has_fa(txt) then
                local p = plain_of(txt) or ""
                local _, title = string.match(p, "^(%[[^%]]*%])%s*(.+)$")
                if title then
                    local id = W.LogId(title)
                    local h = F.TitleHash(title)
                    F.Chat(string.format("  '%s' id=%s data=%s hash=%s", p, tostring(id),
                        tostring(id and type(F.D.quests[id]) == "string"), h))
                    shown = shown + 1
                end
            end
        end
    end
end

-- rc18: scan right after the quest log changed / the map opened (not a second later)
local pend = false
local function soon()
    if pend then
        return
    end
    pend = true
    F.After(0.05, function()
        pend = false
        local ok, err = pcall(W.Scan)
        if not ok then
            F:LogError("tracker", err)
        end
    end)
end
W.Soon = soon

F:On("QUEST_LOG_UPDATE", nil, function()
    W.RebuildLog()
    memo = {}
    soon()
end)

function W.Start()
    W.RebuildLog()
    local wm = WorldMapFrame
    if type(wm) == "table" and wm.HookScript and not W.mapHooked then
        W.mapHooked = true
        pcall(wm.HookScript, wm, "OnShow", function()
            soon()
            F.After(0.3, soon)
        end)
    end
    if W.ticker or not (C_Timer and C_Timer.NewTicker) then
        return
    end
    W.ticker = C_Timer.NewTicker(1, function()
        local ok, err = pcall(W.Scan)
        if not ok then
            F:LogError("tracker", err)
        end
    end)
end

F:On("PLAYER_LOGIN", nil, function()
    F.After(2, W.Start)
end)
F:Listen("names", refresh_all)
F:Listen("disp", refresh_all)
F:Listen("state", function()
    memo = {}
end)
F:Listen("options", function(key)
    if key == "listTitles" then
        refresh_all()
    elseif key == 'fontSize' or key == 'szList' then
        F.RelayoutQuests()
        for fs, o in pairs(mine) do
            writing[fs] = true
            local okt, txt = pcall(fs.GetText, fs)
            if okt and F.Usable(txt) and has_fa(txt) then
                local sz = F.SizeOf(o.role)
                pcall(fs.SetFont, fs, F.FONT, sz, '')
                F.FitLine(fs, sz)
            else
                F.RestoreFont(fs, o) -- rc32: English keeps the game font
            end
            writing[fs] = nil
        end
    end
end)

-- rc15 (the owner: empty boxes instead of Persian): the game resets the font of its
-- buttons without a Lua call we can hook, so the font of every line we wrote is
-- checked ten times a second (the table holds only those lines)
do
    local fixer = CreateFrame("Frame")
    fixer:SetScript("OnUpdate", function()
        if next(cand) ~= nil then
            local ok, err = pcall(W.Watch)
            if not ok then
                F:LogError("tracker", err)
            end
        end
        for fs, o in pairs(mine) do
            local ok, cur = pcall(fs.GetFont, fs)
            if ok and cur ~= F.FONT then
                local okt, txt = pcall(fs.GetText, fs)
                writing[fs] = true
                if okt and F.Usable(txt) and has_fa(txt) then
                    local sz = F.SizeOf(o.role)
                    pcall(fs.SetFont, fs, F.FONT, sz, "")
                    F.FitLine(fs, sz)
                else
                    mine[fs], last[fs] = nil, nil -- rc32: English text again: the game font stays
                end
                writing[fs] = nil
            end
        end
    end)
end
