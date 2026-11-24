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
    local h = F.TitleHash(title)
    local id = h ~= "" and byHash[h] or nil
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
    if not F.Room.On("namesQuest") then
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
local writing = {}
local memo = {}

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
        memo[key] = v
    end
    return v or nil
end

local function put(fs, out, english)
    if not mine[fs] then
        local font, size, flags = fs:GetFont()
        mine[fs] = { font = font, size = size, flags = flags }
    end
    eng[fs] = english
    writing[fs] = true
    fs:SetFont(F.FONT, mine[fs].size or T.Size(), "")
    fs:SetText(out)
    writing[fs] = nil
    last[fs] = out
end

local function font_back(fs)
    local o = mine[fs]
    if not o then
        return
    end
    writing[fs] = true
    if o.font then
        pcall(fs.SetFont, fs, o.font, o.size, o.flags or "")
    end
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
        if o and o.font then
            pcall(fs.SetFont, fs, o.font, o.size, o.flags or "")
        end
        if eng[fs] then
            pcall(fs.SetText, fs, eng[fs])
        end
        writing[fs] = nil
        mine[fs], last[fs] = nil, nil
    end
    W.Scan()
end
W.Refresh = refresh_all

function W.Start()
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
