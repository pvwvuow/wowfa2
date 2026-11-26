-- WoWFA Forever - 1.1.6: the game's own windows in Persian (the owner 26 Nov: the game menu,
-- character, bags, spellbook tabs, friends and group, mail, trade, auction house, bank,
-- merchant, trainer, loot, group finder ...).
-- The taint-safe way. Nothing of the game is written or replaced:
--   * NO GlobalStrings variable is ever assigned (secure code reads them; an addon write
--     taints every secure call that reads it). L.GAMEUI (Locale_UI.lua) holds the English
--     text itself, or a GlobalStrings NAME whose English is only READ at run time;
--   * a listed window's OnShow is post-hooked (HookScript); one frame later its text regions
--     are read, and a region whose text IS one of those English strings gets the shaped
--     Persian in our font. That region's SetText / SetFormattedText are post-hooked
--     (hooksecurefunc, the safe way), so the game's next write is swapped too;
--   * protected frames (action buttons, secure buttons) and everything under them are never
--     touched; edit boxes, chat frames, tooltips and models are skipped;
--   * nothing at all runs in combat: the swap waits for the end of the fight;
--   * the windows another module owns (quests, gossip, books, map, talents, the tracker) and
--     the popups (StaticPopup) are not on the list.
-- Only the fontstrings that matched once are hooked, and a hooked write costs one table
-- lookup (CPU). Switch: General > the game's windows (F.db.gameUi, default on); off puts
-- every English text and font back. Not a registered module: pcall everywhere.

local F = WoWFAF
local L = F.L
local T = F.T

local FRAMES = {
    "GameMenuFrame", "CharacterFrame", "PaperDollFrame", "PetPaperDollFrame", "ReputationFrame",
    "SkillFrame", "HonorFrame", "PVPFrame", "TokenFrame", "SpellBookFrame", "FriendsFrame",
    "FriendsListFrame", "IgnoreListFrame", "WhoFrame", "GuildFrame", "RaidFrame", "MailFrame",
    "InboxFrame", "SendMailFrame", "OpenMailFrame", "TradeFrame", "MerchantFrame", "BankFrame",
    "AuctionFrame", "AuctionFrameBrowse", "AuctionFrameBid", "AuctionFrameAuctions",
    "AuctionHouseFrame", "ClassTrainerFrame", "LootFrame", "TabardFrame", "GuildRegistrarFrame",
    "PetStableFrame", "DressUpFrame", "InspectFrame", "MacroFrame", "TimeManagerFrame",
    "LFGParentFrame", "PVEFrame", "GuildBankFrame", "TradeSkillFrame", "CraftFrame",
    "BattlefieldFrame", "ArenaFrame", "WorldStateScoreFrame", "ContainerFrameCombinedBags",
}
for i = 1, 13 do
    FRAMES[#FRAMES + 1] = "ContainerFrame" .. i
end

local SKIP_TYPE = {
    EditBox = true, ScrollingMessageFrame = true, MessageFrame = true, SimpleHTML = true,
    GameTooltip = true, Model = true, PlayerModel = true, DressUpModel = true, CinematicModel = true,
    Cooldown = true, Minimap = true, Browser = true, ColorSelect = true,
}
local SCALE = 0.92 -- Vazirmatn is drawn bigger than the game font at the same size (Font.lua)
local MAXN = 3000  -- regions + frames read in one window scan (CPU cap)

local exact, scoped, pats
local done = setmetatable({}, { __mode = "k" })      -- fontstring -> { en, fa, font, size, flags }
local hooked = setmetatable({}, { __mode = "k" })    -- fontstring -> scope (window name) or true
local pendingFs = setmetatable({}, { __mode = "k" }) -- written in combat: swapped after it
local pendingAll = false
local attached, queued = {}, {}
local busy = false -- our own SetText is running (the hooks must not re-enter)

local function on()
    local db = F.db
    return db and db.enabled and db.gameUi ~= false and true or false
end

local function combat()
    return InCombatLockdown and InCombatLockdown() and true or false
end

local function letters(s)
    local lit = string.gsub(s, "%%%d?%$?[sd]", "")
    lit = string.gsub(lit, "[%s%p%d]", "")
    return #lit
end

-- the English of every row: a plain text -> exact[en]; one with %s / %d -> a pattern
-- (%s -> (.-), %d -> (%d+)); the Persian takes the values as {1} {2} in their English order
local function build()
    exact, scoped, pats = {}, {}, {}
    for _, e in ipairs(L.GAMEUI or {}) do
        local en, fa, scope = e[1], e[2], e[3]
        if type(en) == "string" and string.find(en, "^[%u%d_]+$") then
            en = _G[en] -- a GlobalStrings NAME: read only, never written
        end
        if type(en) == "string" and en ~= "" and type(fa) == "string" and fa ~= ""
            and not string.find(en, "|", 1, true) then
            if string.find(en, "%", 1, true) then
                local n = 0
                local p = string.gsub(en, "%%%d?%$?([sd])", function(k)
                    n = n + 1
                    return k == "d" and "\2" or "\1"
                end)
                -- %.1f, %% and friends stay out; so does a row that is (almost) only values
                if n > 0 and not string.find(p, "%", 1, true) and letters(en) >= 3 then
                    p = string.gsub(p, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
                    p = string.gsub(p, "\1", "(.-)")
                    p = string.gsub(p, "\2", "(%%d+)")
                    pats[#pats + 1] = { "^" .. p .. "$", fa }
                end
            elseif type(scope) == "string" then
                scoped[scope] = scoped[scope] or {}
                scoped[scope][en] = fa
            elseif exact[en] == nil then
                exact[en] = fa
            end
        end
    end
end

local function lookup(text, scope)
    local s = scope and scoped[scope]
    return (s and s[text]) or exact[text]
end

local function translate(text, scope)
    if not exact then
        build()
    end
    local fa = lookup(text, scope)
    if fa then
        return fa
    end
    -- "Strength:" / "Subject:" - the game adds the colon itself
    local base = string.match(text, "^(.-)%s*:$")
    if base and base ~= "" then
        fa = lookup(base, scope)
        if fa then
            return fa .. ":"
        end
    end
    -- the patterns only for a text that can hold one (bag counts "5" cost nothing)
    if #text < 4 or string.find(text, "|", 1, true) or not string.find(text, "%a") then
        return nil
    end
    for i = 1, #pats do
        local caps = { string.match(text, pats[i][1]) }
        if caps[1] ~= nil then
            return (string.gsub(pats[i][2], "{(%d)}", function(d)
                return caps[tonumber(d)] or ""
            end))
        end
    end
    return nil
end

-- 1.1.6 (the owner: a long Persian text the game wraps by itself reads last-part-first): a
-- fontstring that wraps (CanWordWrap) and has a width gets its lines wrapped HERE, each one
-- shaped on its own (T.Lines); a one-line string keeps one shaped line as before
local function wrap_width(fs)
    if not fs then
        return nil
    end
    local okc, can = pcall(function()
        return fs.CanWordWrap and fs:CanWordWrap()
    end)
    if not (okc and F.Usable(can) and can == true) then
        return nil
    end
    local okw, w = pcall(fs.GetWidth, fs)
    if okw and F.Usable(w) and type(w) == "number" and w > 40 then
        return w
    end
    return nil
end

local function shape(fa, fs)
    local out = {}
    local w = wrap_width(fs)
    local size = 12
    if w then
        local okf, _, sz = pcall(fs.GetFont, fs)
        if okf and F.Usable(sz) and type(sz) == "number" and sz > 4 then
            size = sz
        end
    end
    for line in string.gmatch(fa .. "\n", "(.-)\n") do
        if w then
            local ls = T.Lines(T.Digits(line), w * 0.94, size, T.Mode())
            if type(ls) ~= "table" then
                return nil
            end
            if #ls == 0 then
                out[#out + 1] = ""
            end
            for _, s in ipairs(ls) do
                out[#out + 1] = s
            end
        else
            local s = T.ShapeLine(T.Digits(line), T.Mode())
            if type(s) ~= "string" then
                return nil
            end
            out[#out + 1] = s
        end
    end
    return table.concat(out, "\n")
end

-- the one place that writes: the shaped Persian + our font on ONE fontstring
local function swap(fs, text, scope)
    if busy or not F.Usable(text) or type(text) ~= "string" or text == "" then
        return false
    end
    if string.find(text, "[\216-\219\239]") then
        return false -- Persian already (ours, or another module's)
    end
    local okt, fa = pcall(translate, text, scope)
    local rec = done[fs]
    if not okt or not fa then
        if rec then
            rec.en = nil -- the game wrote a text we do not know: it stays as it is
            if rec.font and rec.size then
                -- ... and in the game's own font and size again (an English text left in our
                -- font, 0.92 smaller, was the owner's "English sometimes too small")
                busy = true
                pcall(fs.SetFont, fs, rec.font, rec.size, rec.flags or "")
                busy = false
            end
        end
        return false
    end
    local oks, shaped = pcall(shape, fa, fs)
    if not oks or type(shaped) ~= "string" or shaped == "" then
        return false
    end
    if not rec then
        rec = {}
        local okf, font, size, flags = pcall(fs.GetFont, fs)
        if okf and type(font) == "string" and type(size) == "number" then
            rec.font, rec.size, rec.flags = font, size, flags
        end
        done[fs] = rec
    end
    rec.en, rec.fa = text, shaped
    busy = true
    pcall(function()
        if rec.size then
            local size = rec.size
            if rec.font ~= F.FONT then
                size = math.max(8, math.floor(size * SCALE + 0.5))
            end
            fs:SetFont(F.FONT, size, rec.flags or "")
        end
        fs:SetText(shaped)
    end)
    busy = false
    return true
end

local function on_set(self, t)
    if busy or not on() then
        return
    end
    local scope = hooked[self]
    if scope == true then
        scope = nil
    end
    if combat() then
        pendingFs[self] = scope or true
        return
    end
    swap(self, t, scope)
end

local function on_fmt(self)
    if busy or not on() then
        return
    end
    local ok, t = pcall(self.GetText, self)
    if ok then
        on_set(self, t)
    end
end

local function hook(fs, scope)
    if hooked[fs] or type(hooksecurefunc) ~= "function" then
        return
    end
    hooked[fs] = scope or true
    pcall(hooksecurefunc, fs, "SetText", on_set)
    pcall(hooksecurefunc, fs, "SetFormattedText", on_fmt)
end

-- one fontstring: swapped (and hooked) if its text is known. true = it is Persian now
local function try(fs, scope)
    if not on() or type(fs) ~= "table" then
        return false
    end
    if combat() then
        pendingFs[fs] = scope or true
        return false
    end
    local ok, t = pcall(fs.GetText, fs)
    if not ok then
        return false
    end
    if swap(fs, t, scope) then
        hook(fs, scope)
        return true
    end
    return false
end

local function flag(f, method)
    local m = f[method]
    if type(m) ~= "function" then
        return false
    end
    local ok, v = pcall(m, f)
    return ok and v and true or false
end

local function walk(f, depth, budget, scope)
    if depth > 12 or budget.n > MAXN then
        return
    end
    budget.n = budget.n + 1
    if type(f.GetObjectType) == "function" then
        local okt, ty = pcall(f.GetObjectType, f)
        if okt and SKIP_TYPE[ty] then
            return
        end
    end
    if flag(f, "IsForbidden") or flag(f, "IsProtected") then
        return -- a secure frame and everything under it: never touched
    end
    if type(f.GetRegions) == "function" then
        local regs = { pcall(f.GetRegions, f) }
        if regs[1] then
            for i = 2, #regs do
                local r = regs[i]
                budget.n = budget.n + 1
                if type(r) == "table" and type(r.GetObjectType) == "function" and type(r.GetText) == "function" then
                    local okr, rt = pcall(r.GetObjectType, r)
                    if okr and rt == "FontString" then
                        try(r, scope)
                    end
                end
            end
        end
    end
    if type(f.GetChildren) == "function" then
        local kids = { pcall(f.GetChildren, f) }
        if kids[1] then
            for i = 2, #kids do
                if type(kids[i]) == "table" then
                    walk(kids[i], depth + 1, budget, scope)
                end
            end
        end
    end
end

-- the window name a frame belongs to (the scope of a row such as Mail in the skills list)
local function scope_of(f)
    local ok, n = pcall(f.GetName, f)
    return ok and type(n) == "string" and n or nil
end

local function scan(f)
    if not on() or type(f) ~= "table" then
        return
    end
    if combat() then
        pendingAll = true
        return
    end
    walk(f, 0, { n = 0 }, scope_of(f))
end

local function schedule(f)
    if queued[f] then
        return
    end
    queued[f] = true
    F.After(0.05, function()
        queued[f] = nil
        local ok, err = pcall(scan, f)
        if not ok then
            F:LogError("gameui", err)
        end
    end)
end

local function shown(f)
    return type(f) == "table" and flag(f, "IsShown")
end

-- a window that exists now gets its OnShow post-hook once (load-on-demand windows such as
-- the auction house come later: every ADDON_LOADED tries again)
local function attach()
    for _, name in ipairs(FRAMES) do
        local f = _G[name]
        if not attached[name] and type(f) == "table" and type(f.HookScript) == "function" then
            attached[name] = true
            pcall(f.HookScript, f, "OnShow", function(self)
                if on() then
                    schedule(self)
                end
            end)
            if on() and shown(f) then
                schedule(f)
            end
        end
    end
end

local function rescan()
    for _, name in ipairs(FRAMES) do
        local f = _G[name]
        if shown(f) then
            schedule(f)
        end
    end
end

-- off: every English text and font back
local function restore()
    if combat() then
        pendingAll = true
        return
    end
    busy = true
    for fs, rec in pairs(done) do
        pcall(function()
            if rec.en and rec.fa and fs:GetText() == rec.fa then
                fs:SetText(rec.en)
            end
            if rec.font and rec.size then
                fs:SetFont(rec.font, rec.size, rec.flags or "")
            end
        end)
    end
    busy = false
    for fs in pairs(done) do
        done[fs] = nil
    end
end

local function sync()
    if on() then
        rescan()
    elseif next(done) ~= nil then
        restore()
    end
end

local function after_combat()
    if not on() then
        pendingAll = false
        for fs in pairs(pendingFs) do
            pendingFs[fs] = nil
        end
        if next(done) ~= nil then
            restore()
        end
        return
    end
    for fs, scope in pairs(pendingFs) do
        pendingFs[fs] = nil
        try(fs, scope ~= true and scope or nil)
    end
    if pendingAll then
        pendingAll = false
        rescan()
    end
end

-- 1.1.6: the settings preview column asks for the Persian of one window text (nil = English)
local function preview(text, scope)
    if not on() or type(text) ~= "string" then
        return nil
    end
    local ok, fa = pcall(translate, text, scope)
    if not ok or not fa then
        return nil
    end
    local oks, s = pcall(shape, fa)
    return oks and type(s) == "string" and s ~= "" and s or nil
end

F.GameUI = { Try = try, Scan = scan, Attach = attach, Restore = restore, Preview = preview }

F:On("ADDON_LOADED", nil, function()
    pcall(attach)
end)
F:On("PLAYER_REGEN_ENABLED", nil, function()
    local ok, err = pcall(after_combat)
    if not ok then
        F:LogError("gameui", err)
    end
end)
F:Listen("login", function()
    pcall(attach)
    pcall(rescan)
end)
F:Listen("options", function(key)
    if key == "gameUi" then
        pcall(sync)
    end
end)
F:Listen("state", function()
    pcall(sync)
end)
