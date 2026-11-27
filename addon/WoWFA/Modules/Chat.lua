-- WoWFA Forever - Persian in the game chat. Behind F.db.chatFa (General > Persian
-- chat, default on):
--   1. our font on every chat window and its edit box (the game's chat font has
--      no Persian letters). The size is the game's chat size times
--      F.db.chatScale percent (default 90, a slider in General), because
--      Vazirmatn is drawn bigger than the game font at the same size;
--   2. a chat filter that shapes an incoming message that holds Persian letters
--      (same shaper as every other text), so a player who has the addon reads
--      joined letters in the right order. A player without the addon sees the
--      raw letters, the filter only changes what THIS client draws;
--   3. rc24 (the owner: typed Persian is not joined and runs backwards): the edit
--      box draws raw letters one by one, left to right. While the line holds
--      Persian, the raw text of the edit box is made invisible and a font string
--      on top of it draws the SAME text shaped and in reading order. What is sent
--      is untouched (the edit box still holds the plain letters). The caret stays
--      where the edit box keeps it.
-- Not a registered module: every call is wrapped in pcall.

local F = WoWFAF
local T = F.T

-- 1.0.7 (the owner's two screenshots: with Persian chat on, the English lines looked stretched
-- and low quality): a chat window that shows Persian takes WoWFA Chat (Fonts/WoWFAChat.ttf,
-- built by the font_chat job): the Latin of Liberation Sans 2 narrowed to the Arial Narrow width
-- of the game's chat, with the game's line height, plus the Persian letters of Vazirmatn. English
-- keeps the game's look at the game's own size (no chatScale shrink). A client that can not load
-- the file falls back to Vazirmatn at chatScale, as before.
local CHAT_FONT = F.ROOT .. "Fonts\\WoWFAChat.ttf"
local chatFontOk = nil -- nil = not tried yet; true / false after the first try

local function set_chat_font(f, size, flags)
    if chatFontOk == false then
        return false
    end
    local ok = pcall(f.SetFont, f, CHAT_FONT, size, flags or "")
    local cur = ok and f.GetFont and f:GetFont()
    local good = type(cur) == "string" and string.find(string.lower(cur), "wowfachat", 1, true) ~= nil
    if chatFontOk == nil then
        chatFontOk = good
    end
    return good
end
F.ChatFontPath = CHAT_FONT

local saved = {} -- frame -> { font, size, flags } of the game's own chat font
local ours = {} -- frame -> the size we set last (to tell our size from a size the player picked)
local color = {} -- edit box -> { r, g, b, a } of its own text colour
local registered = false
-- 1.0.7 (the owner: "with Persian chat on, the other chat texts look different, ugly and
-- blurry"): a chat window keeps the game's own font until a line with Persian letters
-- really shows in it; the edit box never takes our font (the overlay draws typed
-- Persian); sizes are whole points (a fractional size is drawn blurred)
local need = setmetatable({}, { __mode = "k" }) -- chat window -> true once Persian showed in it

local EVENTS = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE", "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING", "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER", "CHAT_MSG_CHANNEL", "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM",
}

local function on()
    local db = F.db
    return db and db.enabled and db.chatFa ~= false and true or false
end

local function scale()
    local v = F.db and tonumber(F.db.chatScale) or 90
    if v < 50 then
        v = 50
    elseif v > 130 then
        v = 130
    end
    return v / 100
end

local function edit_boxes()
    local out = {}
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        local eb = _G["ChatFrame" .. i .. "EditBox"]
        if eb then
            out[#out + 1] = eb
        end
    end
    return out
end

local function chat_frames()
    local out = {}
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        local cf = _G["ChatFrame" .. i]
        if cf then
            out[#out + 1] = cf
        end
    end
    for _, eb in ipairs(edit_boxes()) do
        out[#out + 1] = eb
    end
    return out
end

-- the size the game (or the player) wants: ours is told apart by the value we set
local function base_size(f, size)
    if saved[f] and ours[f] and math.abs(size - ours[f]) < 0.05 then
        return saved[f][2]
    end
    return size
end

-- ---------------------------------------------------------- the typing overlay
local function has_raw_fa(s)
    return type(s) == "string" and string.find(s, "[\216-\219]") ~= nil
end

local function show_plain(eb)
    local ov = eb.wfaOv
    if ov then
        ov:Hide()
    end
    local c = color[eb]
    if c and eb.wfaHidden then
        eb:SetTextColor(c[1], c[2], c[3], c[4] or 1)
    end
    eb.wfaHidden = nil
end

local function refresh_box(eb)
    local ov = eb.wfaOv
    if not ov then
        return
    end
    local text = eb:GetText()
    if not on() or not F.Usable(text) or not has_raw_fa(text) then
        show_plain(eb)
        return
    end
    local ok, shaped = pcall(function()
        return T.ShapeLine(T.Clean(text), T.Mode())
    end)
    if not ok or type(shaped) ~= "string" or shaped == "" then
        show_plain(eb)
        return
    end
    if not color[eb] then
        local r, g, b, a = eb:GetTextColor()
        color[eb] = { r or 1, g or 1, b or 1, a or 1 }
    end
    local _, size = eb:GetFont()
    local fsz = (type(size) == "number" and size) or 14
    if not set_chat_font(ov, fsz, "") then
        ov:SetFont(F.FONT, fsz, "")
    end
    -- start after the channel word ("Say:") the edit box keeps on its left
    local left = 14
    local name = eb.GetName and eb:GetName()
    local header = name and _G[name .. "Header"]
    if header and header.GetStringWidth then
        local w = header:GetStringWidth()
        if F.Usable(w) and type(w) == "number" then
            left = w + 18
        end
    end
    ov:ClearAllPoints()
    ov:SetPoint("LEFT", eb, "LEFT", left, 0)
    ov:SetPoint("RIGHT", eb, "RIGHT", -10, 0)
    ov:SetJustifyH("RIGHT")
    ov:SetText(shaped)
    ov:Show()
    eb:SetTextColor(color[eb][1], color[eb][2], color[eb][3], 0)
    eb.wfaHidden = true
end

local function hook_box(eb)
    if eb.wfaOv or not eb.HookScript then
        return
    end
    local ov = eb:CreateFontString(nil, "OVERLAY")
    ov:SetFont(F.FONT, 14, "")
    ov:SetWordWrap(false)
    ov:SetTextColor(1, 1, 1, 1)
    ov:Hide()
    eb.wfaOv = ov
    eb:HookScript("OnTextChanged", function(self)
        pcall(refresh_box, self)
    end)
    eb:HookScript("OnShow", function(self)
        pcall(refresh_box, self)
    end)
    eb:HookScript("OnHide", function(self)
        pcall(show_plain, self)
    end)
end

-- 1.2.2 (the owner's 27 Nov report: the chat font of a window went back and forth between the game's and
-- ours in fights): when the game puts its own font back on a window that shows Persian, ours is set again one
-- frame later (and never while we set it ourselves)
local reapply, guarding = nil, false
local function guard_font(f)
    if f.wfaFontGuard or type(f.SetFont) ~= "function" then
        return
    end
    f.wfaFontGuard = true
    hooksecurefunc(f, "SetFont", function(self, font)
        if guarding or not need[self] or not on() or type(font) ~= "string" then
            return
        end
        if string.find(string.lower(font), "wowfachat", 1, true) or font == F.FONT then
            return
        end
        F.After(0, function()
            if reapply then
                guarding = true
                pcall(reapply)
                guarding = false
            end
        end)
    end)
end

local function apply_font()
    for _, f in ipairs(chat_frames()) do
        local nm = f.GetName and f:GetName()
        local isBox = type(nm) == "string" and string.find(nm, "EditBox", 1, true) ~= nil
        if not isBox and not f.wfaAddHooked and type(f.AddMessage) == "function" then
            f.wfaAddHooked = true
            hooksecurefunc(f, "AddMessage", function(self, text)
                if need[self] or not on() or type(text) ~= "string" then
                    return
                end
                if string.find(text, "[\216-\219]") or string.find(text, "\239[\173-\187]") then
                    need[self] = true
                    pcall(apply_font)
                end
            end)
        end
        if not isBox then
            pcall(guard_font, f)
        end
        if f.GetFont and f.SetFont then
            local font, size, flags = f:GetFont()
            if type(font) == "string" and type(size) == "number" then
                local base = base_size(f, size)
                if on() and not isBox and need[f] then
                    if not saved[f] then
                        saved[f] = { font, base, flags }
                    else
                        saved[f][2] = base
                    end
                    local target = math.max(6, math.floor(base + 0.5))
                    if not set_chat_font(f, target, flags) then
                        target = math.max(6, math.floor(base * scale() + 0.5))
                        pcall(f.SetFont, f, F.FONT, target, flags or "")
                    end
                    ours[f] = target
                elseif saved[f] then
                    pcall(f.SetFont, f, saved[f][1], base, flags or saved[f][3] or "")
                    saved[f], ours[f] = nil, nil
                end
            end
        end
    end
    for _, eb in ipairs(edit_boxes()) do
        pcall(hook_box, eb)
        pcall(refresh_box, eb)
    end
end

reapply = apply_font

local function filter(cf, _, msg, ...)
    if not on() then
        return false
    end
    if not F.Usable(msg) or type(msg) ~= "string" then
        return false
    end
    -- raw Persian / Arabic letters only; text we shaped already (presentation forms) is left alone
    if not has_raw_fa(msg) or string.find(msg, "\239[\173-\187]") then
        return false
    end
    local who = select(1, ...)
    local plen = #(type(who) == "string" and who or "") + 4
    local ok, shaped = pcall(function()
        return T.ChatText(T.Clean(msg), cf, plen) -- 1.1.6: wrapped by us, never by the window
    end)
    if ok and type(shaped) == "string" and shaped ~= "" then
        return false, shaped, ...
    end
    return false
end

local function install()
    if registered then
        return
    end
    local add = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter) or ChatFrame_AddMessageEventFilter
    if type(add) ~= "function" then
        return
    end
    for _, ev in ipairs(EVENTS) do
        pcall(add, ev, filter)
    end
    registered = true
    -- the chat window font size is set by the game with its own font: put ours back
    if type(FCF_SetChatWindowFontSize) == "function" then
        hooksecurefunc("FCF_SetChatWindowFontSize", function()
            pcall(apply_font)
        end)
    end
end

F:Listen("login", function()
    local ok, err = pcall(install)
    if not ok then
        F:LogError("chat", err)
    end
    pcall(apply_font)
end)
for _, sig in ipairs({ "options", "state" }) do
    F:Listen(sig, function()
        pcall(apply_font)
    end)
end
