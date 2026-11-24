-- WoWFA Forever - Persian in the game chat (the owner: typing Persian in the chat
-- shows squares). Two parts, both behind F.db.chatFa (General > Persian chat,
-- default on):
--   1. our font on every chat window and its edit box (the game's chat font has
--      no Persian letters, so typed and received Persian came out as squares);
--   2. a chat filter that shapes an incoming message that holds Persian letters
--      (same shaper as every other text), so a player who has the addon reads
--      joined letters in the right order. A player without the addon sees the
--      raw letters, the filter only changes what THIS client draws.
-- Not a registered module: every call is wrapped in pcall.

local F = WoWFAF
local T = F.T

local saved = {} -- frame -> { font, size, flags } of the game's own chat font
local registered = false

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

local function chat_frames()
    local out = {}
    local n = NUM_CHAT_WINDOWS or 10
    for i = 1, n do
        local cf = _G["ChatFrame" .. i]
        if cf then
            out[#out + 1] = cf
        end
        local eb = _G["ChatFrame" .. i .. "EditBox"]
        if eb then
            out[#out + 1] = eb
        end
    end
    return out
end

local function apply_font()
    for _, f in ipairs(chat_frames()) do
        if f.GetFont and f.SetFont then
            local font, size, flags = f:GetFont()
            if type(font) == "string" and type(size) == "number" then
                if on() then
                    if not saved[f] then
                        saved[f] = { font, size, flags }
                    end
                    pcall(f.SetFont, f, F.FONT, size, flags or "")
                elseif saved[f] then
                    pcall(f.SetFont, f, saved[f][1], size, flags or saved[f][3] or "")
                    saved[f] = nil
                end
            end
        end
    end
end

local function filter(_, _, msg, ...)
    if not on() then
        return false
    end
    if not F.Usable(msg) or type(msg) ~= "string" then
        return false
    end
    -- raw Persian / Arabic letters only; text we shaped already (presentation forms) is left alone
    if not string.find(msg, "[\216-\219]") or string.find(msg, "\239[\173-\187]") then
        return false
    end
    local ok, shaped = pcall(function()
        return T.ShapeLine(T.Clean(msg), T.Mode())
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
