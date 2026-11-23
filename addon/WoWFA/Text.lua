-- WoWFA Forever - Persian text: name markers (like the site), quest tokens,
-- display modes, wrapping, and safe tooltip lines.
--
-- Display modes (same as the retail addon, picked on the welcome screen):
--   1 the client runs its own bidi pass: we only reshape letters
--   2 fully raw: the client shapes and orders
--   3 manual: we wrap, reshape and reorder every line ourselves

local F = WoWFAF
local L = F.L
local Shape = WoWFA_Shape
local T = {}
F.T = T

local RLM = "\226\128\143"
local LRM = "\226\128\142"
local FA_DIGITS = { "\219\176", "\219\177", "\219\178", "\219\179", "\219\180", "\219\181", "\219\182", "\219\183", "\219\184", "\219\185" }

T.FAMILIES = { "npc", "zn", "it", "sp", "ob", "qs", "cls", "tm" }

function T.Mode()
    local m = F.db and F.db.mode
    if m == 1 or m == 2 or m == 3 then
        return m
    end
    return 1
end

function T.Size()
    return (F.db and F.db.fontSize) or 12
end

function T.Digits(s, force)
    -- 51-B: the room owns the Persian-digits switch
    if not force and not F.Room.On("faDigits") then
        return s
    end
    return (string.gsub(s, "%d", function(d)
        return FA_DIGITS[tonumber(d) + 1]
    end))
end

-- {{fam:English|Persian}} -> Persian, or English when that family is off
-- Brain 59: the set names have their own switch (namesSet) - the owner: "the
-- item names and the set names must be separate"
local MARKER_KEY = { it = "namesItem", sp = "namesSpell", npc = "namesNpc", zn = "namesZone",
    qs = "namesQuest", ob = "namesObj", cls = "namesClass", tm = "terms", set = "namesSet" }

-- 72-A: the tm markers inside a line owned by a TEXT switch (roles
-- d/s/r/b/t/f + textSet) resolve with THAT line's switch - `terms` keeps
-- owning the glossary words in quest / NPC / spell texts. Without this, a
-- set / Equip line rendered by its own switch showed its marker words in
-- English whenever `terms` was off (the owner's "half/half" set bonuses).
local TEXT_OWNER = { textDesc = true, textStats = true, textReq = true,
    textBind = true, textDetail = true, textFlavor = true, textSet = true }

function T.Markers(s, owner)
    s = string.gsub(s, "{{(%a+):([^|{}]*)|([^{}]*)}}", function(fam, en, fa)
        -- 51-B: the room owns every name family + the terms
        local key = MARKER_KEY[fam] or "terms"
        if fam == "tm" and owner and TEXT_OWNER[owner] then
            key = owner -- 72-A: the line's own text switch owns the word
        end
        if not F.Room.On(key) then
            return en
        end
        if fa == "" and fam == "set" then
            local sets = F.D and F.D.names and F.D.names.set
            if sets then
                local hit = sets[T.NameKey(en)]
                if hit then
                    return hit
                end
            end
        end
        return fa
    end)
    -- any other marker left by older data: {{x:a|b}} -> b, {{x:a}} -> a
    s = string.gsub(s, "{{%a+:([^|{}]*)|([^{}]*)}}", "%2")
    s = string.gsub(s, "{{%a+:([^{}]*)}}", "%1")
    return s
end

local function class_fa()
    local _, file = UnitClass("player")
    if not F.Usable(file) then
        return nil
    end
    local loc = UnitClass("player")
    -- lane-b16: the cls family switch also governs the $C token - off means
    -- the English class name on every surface
    if not F.Room.On("namesClass") then -- 51-B: the room owns the cls family
        return F.Usable(loc) and loc or nil
    end
    local names = F.D and F.D.names and F.D.names.class
    if names and F.Usable(loc) then
        local fa = names[T.NameKey(loc)] -- lane-28 §A3: NameKey on both sides
        if fa then
            return fa
        end
    end
    return L.class[file]
end

local function race_fa()
    local loc, file = UnitRace("player")
    if not F.Usable(file) then
        return nil
    end
    return L.race[file] or (F.Usable(loc) and loc) or nil
end

-- quest tokens: $N name, $C class, $R race, $G male:female; , $B new line
function T.Tokens(s)
    local female = UnitSex and UnitSex("player") == 3
    s = string.gsub(s, "%$[Gg]%s*([^:;]*):([^;]*);", function(m, f)
        if female then
            return f
        end
        return m
    end)
    s = string.gsub(s, "%$([NnCcRrBb])", function(c)
        c = string.lower(c)
        if c == "n" then
            local n = UnitName("player")
            return F.Usable(n) and n or ""
        elseif c == "c" then
            return class_fa() or ""
        elseif c == "r" then
            return race_fa() or ""
        end
        return "\n"
    end)
    return s
end

function T.Clean(s)
    s = tostring(s or "")
    s = string.gsub(s, RLM, "")
    s = string.gsub(s, LRM, "")
    s = string.gsub(s, "\r", "")
    return s
end

-- lane-28 §A3: the shared lookup normalisation for every name table (export
-- and live side, fixture-locked by tests/forever/namekey_fixture.py):
-- curly quotes folded to "'", lower case, ONE leading "The " stripped, spaces
-- collapsed, trimmed. The exporter keys its name tables with the Python twin
-- name_key(), so "The Barrens" and "The  Barrens" resolve to the same row.
function T.NameKey(s)
    s = tostring(s or "")
    s = string.gsub(s, "\226\128\152", "'") -- U+2018 left single quote
    s = string.gsub(s, "\226\128\153", "'") -- U+2019 right single quote
    s = string.gsub(s, "\226\128\156", "'") -- U+201C left double quote
    s = string.gsub(s, "\226\128\157", "'") -- U+201D right double quote
    s = string.lower(s)
    s = string.gsub(s, "^%s*the%s+", "")
    s = string.gsub(s, "%s+", " ")
    s = string.gsub(s, "^ ", "")
    s = string.gsub(s, " $", "")
    return s
end

-- full pipeline for data text (owner = the line's owning TEXT switch, 72-A)
function T.Prepare(s, owner)
    return T.Clean(T.Tokens(T.Markers(s or "", owner)))
end

function T.ShapeLine(s, mode)
    mode = mode or T.Mode()
    if mode == 2 then
        return s
    elseif mode == 3 then
        return Shape.line(s)
    end
    return Shape.shape_only(s)
end

-- Brain 59 (the owner's r7 debug report: "Text.lua:495: attempt to perform
-- boolean test on a secret boolean value (execution tainted by 'WoWFA')"):
-- on this client a tooltip font string can answer IsTruncated / GetNumLines
-- with a SECRET value, and a boolean test or a comparison on it is an error.
-- Every such read goes through here: pcall + the secret check; anything we
-- can not read safely counts as "the client did not re-wrap".
local function rewrapped(fs, n)
    local ok, bad = pcall(function()
        local tr = fs.IsTruncated and fs:IsTruncated()
        if F.Usable(tr) and tr == true then
            return true
        end
        local nl = fs.GetNumLines and fs:GetNumLines()
        if F.Usable(nl) and type(nl) == "number" and nl > n then
            return true
        end
        return false
    end)
    return ok and bad == true
end
T.Rewrapped = rewrapped

-- Brain 63 (the owner's r9 recording: the set-bonus lines of the character
-- pane tooltip flip between two wraps every 0.2 s): the game rebuilds that
-- tooltip every 0.2 s, so every refresh wrote our first-guess wrap, the client
-- re-wrapped it, and TipRecheck corrected it a frame later - the correction
-- was visible each time. The wrap that finally fitted is remembered per text
-- (the narrowest one wins), so the NEXT refresh starts from it and the client
-- never re-wraps: only the very first render of a text can still correct once.
local wrapmemo, wrapmemo_n = {}, 0

function T.WrapMemoGet(text, wrap)
    local m = wrapmemo[text]
    if m and m < wrap then
        return m
    end
    return wrap
end

function T.WrapMemoPut(text, wrap)
    if type(text) ~= "string" or type(wrap) ~= "number" then
        return
    end
    if wrapmemo_n >= 3000 then
        wrapmemo, wrapmemo_n = {}, 0
    end
    local cur = wrapmemo[text]
    if cur == nil then
        wrapmemo_n = wrapmemo_n + 1
    end
    if cur == nil or wrap < cur then
        wrapmemo[text] = wrap
    end
end

-- --------------------------------------------------------------- wrapping
local measure
-- lane-b12: when the caller gives us the real target font string, measure on
-- IT (GetUnboundedStringWidth on the shaped candidate) - the separate hidden
-- measurer has different metrics and the real string then truncates lines
-- that "fitted" (the quest-pane "..."). Fall back to the hidden measurer.
-- lane-b13: measuring is expensive (SetText per candidate on the target) and
-- T.Set re-wraps up to 5 times, so widths are cached per measurer+size and
-- shared across passes and tooltips (capped; wiped when full).
local wcache, wcache_n = {}, 0
local function cache_width(key, size, shaped, w)
    if wcache_n >= 4000 then
        wcache = {}
        wcache_n = 0
    end
    local b = wcache[key]
    if not b or b.size ~= size then
        b = { size = size, m = {} }
        wcache[key] = b
    end
    b.m[shaped] = w
    wcache_n = wcache_n + 1
end
local measure
-- inbox/27: the measurer is created at LOAD (never in combat) so that the
-- in-place path, which can run while the player is in combat, only ever
-- touches font-string text.
measure = CreateFrame("Frame", nil, UIParent)
measure:SetSize(10, 10)
measure:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", -400, -400)
measure = measure:CreateFontString(nil, "ARTWORK")
measure:SetWordWrap(false)
measure:SetAlpha(0)
local function width_of(s, size, target)
    local shaped = Shape.shape_only(s)
    local key = target or "m"
    local b = wcache[key]
    if b and b.size == size then
        local hit = b.m[shaped]
        if hit then
            return hit
        end
    end
    local w
    if target and target.GetUnboundedStringWidth then
        target:SetText(shaped)
        w = target:GetUnboundedStringWidth()
        -- Brain 59: a secret width can not be compared - use the measurer
        if F.Usable(w) and type(w) == "number" and w > 0 then
            cache_width(key, size, shaped, w)
            return w
        end
        w = nil
    end
    measure:SetFont(F.FONT, size, "")
    measure:SetText(shaped)
    w = measure:GetStringWidth()
    if not F.Usable(w) or type(w) ~= "number" or w <= 0 then
        local _, chars = string.gsub(s, "[^\128-\191]", "")
        w = chars * size * 0.5
    end
    cache_width("m", size, shaped, w)
    return w
end

function T.Wrap(text, maxWidth, size, target)
    local lines = {}
    for para in string.gmatch(text .. "\n", "([^\n]*)\n") do
        if para == "" then
            lines[#lines + 1] = ""
        else
            local words = {}
            for w in string.gmatch(para, "%S+") do
                words[#words + 1] = w
            end
            -- lane-b13: galloping probe per line (1, 2, 4, ... words, then bisect
            -- the last step) finds the SAME break the old one-probe-per-word
            -- greedy loop found, but with ~log(line) short candidates instead of
            -- one probe per remaining word - and every probe is cached.
            local i, n = 1, #words
            while i <= n do
                if width_of(words[i], size, target) > maxWidth then
                    -- a single word wider than the line still gets its own line
                    lines[#lines + 1] = words[i]
                    i = i + 1
                else
                    local good, bad, j, step = i, nil, i, 1
                    while j < n do
                        local nxt = math.min(j + step, n)
                        if width_of(table.concat(words, " ", i, nxt), size, target) <= maxWidth then
                            good, j, step = nxt, nxt, step * 2
                        else
                            bad = nxt
                            break
                        end
                    end
                    while bad and good + 1 < bad do
                        local mid = math.floor((good + bad) / 2)
                        if width_of(table.concat(words, " ", i, mid), size, target) <= maxWidth then
                            good = mid
                        else
                            bad = mid
                        end
                    end
                    lines[#lines + 1] = table.concat(words, " ", i, good)
                    i = good + 1
                end
            end
        end
    end
    return lines
end

-- display lines for a text block in the current (or a forced) mode
function T.Lines(text, width, size, mode, target)
    mode = mode or T.Mode()
    size = size or T.Size()
    text = T.Clean(text)
    local out = {}
    if mode == 3 then
        for _, ln in ipairs(T.Wrap(text, width or 260, size, target)) do
            out[#out + 1] = (ln == "") and " " or Shape.line(ln)
        end
    else
        for para in string.gmatch(text .. "\n", "([^\n]*)\n") do
            out[#out + 1] = T.ShapeLine(para, mode)
        end
    end
    return out
end

-- ------------------------------------------------------- UI font strings
local registry = setmetatable({}, { __mode = "k" })

-- fs.wfaSize / fs.wfaMode / fs.wfaJustify may be set by the caller
function T.Set(fs, text, width)
    fs.wfaText, fs.wfaWidth = text or "", width
    registry[fs] = true
    local size = fs.wfaSize or T.Size()
    local mode = fs.wfaMode or T.Mode()
    fs:SetFont(F.FONT, size, "")
    if width and width >= 40 then
        fs:SetWidth(width)
    end
    local w = width or fs:GetWidth()
    if not F.Usable(w) or type(w) ~= "number" or w < 40 then
        w = 260
    end
    -- lane-b16: word wrap stays ON in every mode. In mode 3 the pre-wrapped
    -- block goes into ONE font string as "\n"-joined lines - with wrap off the
    -- client draws only the first line and ellipsizes it (the quest pane "...",
    -- owner screenshot 6 Nov; the b12 width theory was wrong). Our lines are
    -- wrapped at 4px under the width (inbox/29 C: the pre-wrap must measure
    -- with the SAME size as the font string and the width = GetWidth() - 4),
    -- so the client must never re-wrap them - but it must be free to RENDER
    -- the line breaks. Non-space wrap stays off (never break inside a word).
    fs:SetWordWrap(true)
    fs:SetNonSpaceWrap(false)
    -- lane-b12/inbox-29-C: wrap 4px inside the width, measured on the target
    -- string itself; if the real string STILL misbehaves, re-wrap at -6%
    -- steps, max 4 tries (same loop as the b12 IsTruncated guard).
    local wrap = math.max(w - 4, 40)
    local lines = T.Lines(fs.wfaText, wrap, size, mode, fs)
    fs:SetText(table.concat(lines, "\n"))
    if mode == 3 then
        local tries = 0
        -- two ways the client can disagree with our pre-wrap:
        --   IsTruncated  - a line was cut (should not happen with wrap on)
        --   GetNumLines > produced - the client RE-wrapped a line that was
        --   wider than the string (that scrambles our manual RTL order)
        -- Brain 59: both read through rewrapped() (secret-safe)
        while tries < 4 and rewrapped(fs, #lines) do
            wrap = wrap * 0.94
            tries = tries + 1
            lines = T.Lines(fs.wfaText, wrap, size, mode, fs)
            fs:SetText(table.concat(lines, "\n"))
        end
    end
    fs:SetJustifyH(fs.wfaJustify or "RIGHT")
end

function T.RefreshAll()
    for fs in pairs(registry) do
        if fs.wfaText then
            T.Set(fs, fs.wfaText, fs.wfaWidth)
        end
    end
    F:Fire("text")
end

-- 51-B (Brain review): a string that ALREADY went through the shaper - the
-- room preview mirrors the engine's own tooltip output line by line. It is
-- set as is (re-shaping shaped text scrambles it) and is never re-set by
-- RefreshAll (wfaText cleared: a pooled string that once held SetFa text
-- must not snap back to that stale text on the next refresh).
function T.SetShaped(fs, text)
    fs.wfaText = nil
    fs:SetText(text)
end

-- ---------------------------------------------------------------- tooltip
-- Lines we add get our font; the line objects are reused by the next tooltip,
-- so the original font is restored when the tooltip is cleared.
-- inbox/29 C: the line spacing (line gap) of every multi-line Persian string
-- we set: floor(size * 0.45 + 0.5) (inbox/44 D, was 0.55). Recorded and restored on clear like the
-- font (restore() below), so a reused tooltip string comes out 100% vanilla.
function T.Spacing(size)
    -- inbox/44 D: 0.45 of the size (was 0.55) - the Vazirmatn small sizes
    -- read better with the tighter leading
    return math.floor((size or T.Size()) * 0.45 + 0.5)
end

local function restore(tt)
    local list = tt.wfaFonts
    if list then
        for i = #list, 1, -1 do
            local r = list[i]
            -- inbox/27 in-place records also carry the original TEXT and the
            -- original font OBJECT: a spell / unit tooltip that reuses the same
            -- font string must look 100% vanilla after the clear.
            if r.text ~= nil then
                pcall(r.fs.SetText, r.fs, r.text)
            end
            if r.font then
                pcall(r.fs.SetFont, r.fs, r.font, r.size, r.flags or "")
            end
            if r.fobj then
                pcall(r.fs.SetFontObject, r.fs, r.fobj)
            end
            if r.justify then
                pcall(r.fs.SetJustifyH, r.fs, r.justify)
            end
            if r.spacing then
                pcall(r.fs.SetSpacing, r.fs, r.spacing)
            end
            list[i] = nil
        end
    end
    tt.wfaSeen = nil
    tt.wfaKey = nil
    tt.wfaOurs = nil -- Brain 59: the post-layout re-wrap records (T.TipRecheck)
end

local function hook_tooltip(tt)
    if tt.wfaHooked or not tt.HookScript then
        return
    end
    tt.wfaHooked = true
    pcall(tt.HookScript, tt, "OnTooltipCleared", restore)
    pcall(tt.HookScript, tt, "OnHide", restore)
end

-- true when this content was not added to this tooltip yet
function T.Once(tt, key)
    hook_tooltip(tt)
    if tt.wfaKey == key and tt.wfaLines and tt:NumLines() >= tt.wfaLines then
        return false
    end
    tt.wfaKey = key
    return true
end

function T.Done(tt)
    tt.wfaLines = tt:NumLines()
end

local function style(tt, side)
    hook_tooltip(tt)
    local name = tt:GetName()
    if not name then
        return
    end
    local fs = _G[name .. "Text" .. side .. tt:NumLines()]
    if not fs then
        return
    end
    tt.wfaFonts = tt.wfaFonts or {}
    local font, size, flags = fs:GetFont()
    table.insert(tt.wfaFonts, { fs = fs, font = font, size = size, flags = flags, justify = fs:GetJustifyH(), spacing = fs.GetSpacing and fs:GetSpacing() or nil })
    fs:SetFont(F.FONT, T.Size(), "")
    -- inbox/29 C: the same line gap on the spell/talent (TipLine) strings
    fs:SetSpacing(T.Spacing(T.Size()))
    if side == "Left" then
        fs:SetJustifyH("RIGHT")
    end
end

function T.TipLine(tt, text, color, wrapWidth)
    color = color or F.C.text
    local mode = T.Mode()
    local size = T.Size()
    -- lane-b12: tooltips keep size*22 as the width, but with the same 94%
    -- safety margin so the shaped lines never come out wider than the line
    local wrap = (wrapWidth or (size * 22)) * 0.94
    for _, ln in ipairs(T.Lines(text, wrap, size, mode)) do
        tt:AddLine(ln, color[1], color[2], color[3], mode ~= 3)
        style(tt, "Left")
    end
end

-- "left\tright" pairs: Persian reads right to left, so the first part goes right
function T.TipPair(tt, first, second, color)
    color = color or F.C.text
    local mode = T.Mode()
    tt:AddDoubleLine(T.ShapeLine(T.Clean(second), mode), T.ShapeLine(T.Clean(first), mode), color[1], color[2], color[3], color[1], color[2], color[3])
    style(tt, "Left")
    style(tt, "Right")
end

-- inbox/27 (0.6.0): IN-PLACE tooltip replacement - rewrite an EXISTING tooltip
-- font string with Persian text instead of adding lines under it. The touched
-- font string keeps its live colour (never re-coloured) and its original
-- text / font object / font file+size+flags / justify are recorded ONCE and
-- restored by the shared OnTooltipCleared/OnHide restore above. Font-string
-- text only - no frame creation (the restore list is plain tables).
--   width = the wrap width for T.Lines (mode 3 pre-wraps, modes 1/2 shape per
--   paragraph); side "Left" strings justify RIGHT (Persian reads right-to-left,
--   same rule as the additive lines in style()).
function T.TipSet(tt, fs, text, width, side)
    hook_tooltip(tt)
    tt.wfaFonts = tt.wfaFonts or {}
    local seen = tt.wfaSeen
    if not seen then
        seen = {}
        tt.wfaSeen = seen
    end
    if not seen[fs] then
        seen[fs] = true
        local font, size, flags = fs:GetFont()
        table.insert(tt.wfaFonts, {
            fs = fs,
            text = fs:GetText(),
            font = font,
            size = size,
            flags = flags,
            fobj = (fs.GetFontObject and fs:GetFontObject()) or nil,
            justify = fs:GetJustifyH(),
            spacing = fs.GetSpacing and fs:GetSpacing() or nil,
        })
    end
    local size = T.Size()
    fs:SetFont(F.FONT, size, "")
    -- inbox/29 C: the same line gap on the multi-line in-place strings
    fs:SetSpacing(T.Spacing(size))
    fs:SetWordWrap(true)
    fs:SetNonSpaceWrap(false)
    local wrap = (width or (size * 22)) * 0.94
    if T.Mode() == 3 then
        wrap = T.WrapMemoGet(text, wrap) -- Brain 63: start from the wrap that fitted last time
    end
    local lines = T.Lines(text, wrap, size)
    fs:SetText(table.concat(lines, "\n"))
    -- lane-b16 two-signal guard (same loop as T.Set): the client must never
    -- re-wrap our pre-wrapped lines (that scrambles the manual RTL order)
    -- nor truncate them - re-wrap at -6% steps, max 4 tries.
    -- Brain 59: secret-safe (the owner's Text.lua:495 taint error)
    if T.Mode() == 3 then
        local tries = 0
        while tries < 4 and rewrapped(fs, #lines) do
            wrap = wrap * 0.94
            tries = tries + 1
            lines = T.Lines(text, wrap, size)
            fs:SetText(table.concat(lines, "\n"))
        end
        if tries > 0 then
            T.WrapMemoPut(text, wrap)
        end
    end
    if side == "Left" then
        fs:SetJustifyH("RIGHT")
    end
    -- Brain 59: what we set, for the post-layout re-check (the tooltip sizes
    -- itself AFTER our rewrite: a narrower tooltip re-wraps a Persian line and
    -- the wrapped tail - the logical START of an RTL line - lands on a line of
    -- its own; the owner's r7 room preview showed "(4)" alone under its text)
    local ours = tt.wfaOurs
    if not ours then
        ours = setmetatable({}, { __mode = "k" })
        tt.wfaOurs = ours
    end
    ours[fs] = { text = text, wrap = wrap, n = #lines, set = table.concat(lines, "\n") }
end

-- Brain 59: one frame after the tooltip laid itself out, every string we
-- rewrote that the client re-wrapped after all is wrapped again, narrower.
-- Returns true when something changed (the caller re-checks once more).
function T.TipRecheck(tt)
    local ours = tt and tt.wfaOurs
    if not ours or T.Mode() ~= 3 then
        return false
    end
    local fixed = false
    for fs, o in pairs(ours) do
        local okt, cur = pcall(fs.GetText, fs)
        if okt and F.Usable(cur) and cur == o.set and rewrapped(fs, o.n) then
            local size = T.Size()
            local tries = 0
            repeat
                o.wrap = o.wrap * 0.94
                tries = tries + 1
                local lines = T.Lines(o.text, o.wrap, size)
                o.set, o.n = table.concat(lines, "\n"), #lines
                fs:SetText(o.set)
            until tries >= 4 or not rewrapped(fs, o.n)
            T.WrapMemoPut(o.text, o.wrap) -- Brain 63: the next refresh starts here
            fixed = true
        end
    end
    return fixed
end

-- plain text of every line (for stale checks); secret lines are skipped
function T.TipText(tt, data)
    local parts = {}
    if data and type(data.lines) == "table" then
        for _, ln in ipairs(data.lines) do
            if F.Usable(ln.leftText) then
                parts[#parts + 1] = ln.leftText
            end
            if F.Usable(ln.rightText) then
                parts[#parts + 1] = ln.rightText
            end
        end
        if #parts > 0 then
            return parts
        end
    end
    local name = tt:GetName()
    if not name then
        return parts
    end
    for i = 1, tt:NumLines() do
        for _, side in ipairs({ "Left", "Right" }) do
            local fs = _G[name .. "Text" .. side .. i]
            local t = fs and fs:GetText()
            if F.Usable(t) and t ~= "" then
                parts[#parts + 1] = t
            end
        end
    end
    return parts
end

-- numbers in order + text with every number replaced by "#"
-- (same rule as the exporter: 12, 1.5 -> #; "5." at a sentence end keeps the dot)
-- lane-b14: live lines can carry colour escapes (|cffRRGGBB ... |r) and Unicode
-- spaces the exported EN key never has (norm_tpl strips/collapses them before
-- numbering on the Python side). Both sides must key byte-identically, so
-- NumKey normalises the same things FIRST - the |cff hex digits would else be
-- keyed as numbers. Locked by tests/forever/numkey_fixture.py (both sides in CI).
function T.NumKey(s)
    s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")   -- |cffRRGGBB / |cAARRGGBB
    s = string.gsub(s, "|r", "")                   -- colour reset
    s = string.gsub(s, "|T.-|t", "")               -- texture/icon escapes (icon sizes)
    s = string.gsub(s, "|H.-|h", "")               -- hyperlink escapes (item ids)
    s = string.gsub(s, "|h", "")                   -- hyperlink text marker
    s = string.gsub(s, "\194\160", " ")            -- U+00A0 NBSP
    s = string.gsub(s, "\225\154\128", " ")        -- U+1680 Ogham space mark
    s = string.gsub(s, "\226\128[\128-\138]", " ") -- U+2000..U+200A en/em spaces
    s = string.gsub(s, "\226\128[\168-\169]", " ") -- U+2028/2029 line/para sep
    s = string.gsub(s, "\226\128\175", " ")        -- U+202F narrow NBSP
    s = string.gsub(s, "\226\129\159", " ")        -- U+205F medium math space
    s = string.gsub(s, "\227\128\128", " ")        -- U+3000 ideographic space
    -- Brain 80 part B: thousands separators - the modern client prints
    -- "1,308 Armor", the export EN keys never carry one, so the live key must
    -- drop every digit-commas group first ("1,308" -> "1308", loops for
    -- "1,308,000"); two-digit groups ("12,34") are left alone
    while string.find(s, "%d,%d%d%d") do
        s = string.gsub(s, "(%d),(%d%d%d)", "%1%2")
    end
    local nums, out, pos = {}, {}, 1
    while true do
        local a, b = string.find(s, "%d+", pos)
        if not a then
            out[#out + 1] = string.sub(s, pos)
            break
        end
        if string.sub(s, b + 1, b + 1) == "." and string.find(string.sub(s, b + 2, b + 2), "%d") then
            local _, b2 = string.find(s, "%d+", b + 2)
            b = b2
        end
        out[#out + 1] = string.sub(s, pos, a - 1)
        out[#out + 1] = "#"
        nums[#nums + 1] = string.sub(s, a, b)
        pos = b + 1
    end
    local key = table.concat(out)
    -- inbox/47 B: the safe word-level differences never decide a match again
    key = string.lower(key)
    key = string.gsub(key, " seconds", " sec")
    key = string.gsub(key, " minutes", " min")
    key = string.gsub(key, "%s+", " ")
    key = string.gsub(key, "^ ", "")
    key = string.gsub(key, " $", "")
    key = string.gsub(key, "%.$", "")
    return key, nums
end

-- Persian template {0} {1} ... filled with live numbers
function T.Fill(fa, nums, force)
    return (string.gsub(fa, "{(%d+)}", function(i)
        local v = nums[tonumber(i) + 1]
        if v then
            return T.Digits(v, force)
        end
        return "{" .. i .. "}"
    end))
end
