-- WoWFA Forever - one font with Persian letters for the whole game. Behind
-- F.db.fontAll (General > Persian font in the whole game, default OFF).
-- The game's own fonts have no Persian glyphs, so every text the game draws
-- with them (chat, player names, mail, friends list, tooltips of other
-- addons) shows empty boxes where a Persian letter should be. With the switch
-- on, the standard font objects take our font (size and flags kept, size x 0.92
-- because Vazirmatn is drawn bigger than the game font at the same size).
-- Off puts every original font back. Not a registered module: pcall everywhere.

local F = WoWFAF

local saved = {} -- name -> { font, size, flags }

-- the game's own font of a font object we changed (nil while the switch is off)
function F.FontOriginal(name)
    return saved[name]
end

local NAMES = {
    "SystemFont_Tiny", "SystemFont_Small", "SystemFont_Med1", "SystemFont_Med2", "SystemFont_Med3",
    "SystemFont_Large", "SystemFont_Huge1",
    "SystemFont_Shadow_Small", "SystemFont_Shadow_Med1", "SystemFont_Shadow_Med2",
    "SystemFont_Shadow_Med3", "SystemFont_Shadow_Large", "SystemFont_Shadow_Huge1",
    "SystemFont_Outline_Small", "SystemFont_Outline",
    "GameFontNormal", "GameFontNormalSmall", "GameFontNormalLarge", "GameFontNormalHuge",
    "GameFontHighlight", "GameFontHighlightSmall", "GameFontHighlightLarge",
    "GameFontDisable", "GameFontDisableSmall", "GameFontWhite", "GameFontRed", "GameFontGreen",
    "GameTooltipText", "GameTooltipTextSmall", "GameTooltipHeaderText",
    "ChatFontNormal", "ChatFontSmall",
    "FriendsFont_Normal", "FriendsFont_Small", "FriendsFont_Large", "FriendsFont_UserText",
    "NumberFontNormal", "ChatBubbleFont", "QuestFont", "QuestFont_Large", "QuestFont_Huge",
    "MailTextFontNormal", "InvoiceTextFontNormal", "ItemTextFontNormal",
}

local SCALE = 0.92
-- rc33 (the owner: the size slider must reach every text, English game texts too):
-- the size of every font object is the game's size x 0.92 x (General font size / 12)
-- x (game text size percent / 100). The chat fonts keep 0.92 only: the chat has its
-- own size slider (Modules/Chat.lua).
local KEEP = { ChatFontNormal = true, ChatFontSmall = true }

local function factor(name)
    if KEEP[name] then
        return SCALE
    end
    local db = F.db
    local fsz = (db and tonumber(db.fontSize)) or 12
    local pct = (db and tonumber(db.fontAllScale)) or 100
    return SCALE * (fsz / 12) * (pct / 100)
end

local function on()
    local db = F.db
    return db and db.enabled and db.fontAll == true and true or false
end

local function apply()
    local want = on()
    for _, name in ipairs(NAMES) do
        local fo = _G[name]
        if type(fo) == "table" and fo.GetFont and fo.SetFont then
            if want then
                if not saved[name] then
                    local font, size, flags = fo:GetFont()
                    if type(font) == "string" and type(size) == "number" then
                        saved[name] = { font, size, flags }
                    end
                end
                local s = saved[name]
                if s then
                    pcall(fo.SetFont, fo, F.FONT, math.floor(math.max(6, math.min(48, s[2] * factor(name))) * 10 + 0.5) / 10, s[3] or "")
                end
            elseif saved[name] then
                local s = saved[name]
                pcall(fo.SetFont, fo, s[1], s[2], s[3] or "")
                saved[name] = nil
            end
        end
    end
end

F:Listen("login", function()
    pcall(apply)
end)
for _, sig in ipairs({ "options", "state" }) do
    F:Listen(sig, function()
        pcall(apply)
    end)
end
