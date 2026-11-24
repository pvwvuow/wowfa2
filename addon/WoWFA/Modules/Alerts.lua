-- WoWFA Forever - game alerts: the red messages the game writes in the middle
-- of the screen (UIErrorsFrame: "Out of range.", "Invalid target", "Ability is
-- not ready yet." ...). The English text of each message is read from the
-- game's own GlobalStrings (L.ALERTS in Locale_Alerts.lua lists which ones);
-- when one is about to be shown, the Persian text is drawn instead, in our
-- font (the game's font has no Persian letters). A message that is not in the
-- list stays English and is remembered in the miss list, so the next data
-- update can add it. Switch: General > game alerts (F.db.alerts, default on).
-- Not a registered module: one hook, every call wrapped in pcall.

local F = WoWFAF
local L = F.L
local T = F.T

local map, pats
local origAdd
local origFont -- { font, size, flags } of the error frame before we changed it

local function build()
    map, pats = {}, {}
    for _, e in ipairs(L.ALERTS or {}) do
        local en = _G[e[1]]
        if type(en) == "string" and en ~= "" then
            if string.find(en, "%%[sd]") then
                local p = string.gsub(en, "%%[s]", "\1")
                p = string.gsub(p, "%%d", "\2")
                p = string.gsub(p, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
                p = string.gsub(p, "\1", "(.+)")
                p = string.gsub(p, "\2", "(%%d+)")
                pats[#pats + 1] = { "^" .. p .. "$", e[2] }
            else
                map[en] = e[2]
            end
        end
    end
end

local function active()
    local db = F.db
    return db and db.enabled and db.alerts ~= false and true or false
end

local function translate(text)
    if not F.Usable(text) or type(text) ~= "string" or text == "" then
        return nil
    end
    if not map then
        build()
    end
    local fa = map[text]
    if fa then
        return fa
    end
    for i = 1, #pats do
        local caps = { string.match(text, pats[i][1]) }
        if caps[1] ~= nil then
            local ok, s = pcall(string.format, pats[i][2], unpack(caps))
            if ok then
                return s
            end
        end
    end
    return nil
end

-- our font on the error frame while the switch is on (Vazirmatn also holds the
-- Latin letters, so an untranslated English line still reads fine); given back
-- when it is switched off
local function apply_font()
    local ef = _G.UIErrorsFrame
    if type(ef) ~= "table" or not ef.SetFont or not ef.GetFont then
        return
    end
    if active() then
        if not origFont then
            local font, size, flags = ef:GetFont()
            origFont = { font, size, flags }
        end
        pcall(ef.SetFont, ef, F.FONT, (origFont and origFont[2]) or 16, "OUTLINE")
    elseif origFont then
        pcall(ef.SetFont, ef, origFont[1], origFont[2], origFont[3] or "")
        origFont = nil
    end
end

local function add(self, text, ...)
    if active() then
        local ok, fa = pcall(translate, text)
        if ok and fa then
            local oks, shaped = pcall(function()
                return T.ShapeLine(T.Digits(fa), T.Mode())
            end)
            if oks and type(shaped) == "string" and shaped ~= "" then
                if not origFont then
                    apply_font()
                end
                return origAdd(self, shaped, ...)
            end
        elseif ok and F.Usable(text) and type(text) == "string" and text ~= ""
            and not string.find(text, "[\216-\219\239]") then
            pcall(F.Miss, F, "alert", T.NameKey(text), text)
        end
    end
    return origAdd(self, text, ...)
end

local function install()
    local ef = _G.UIErrorsFrame
    if origAdd or type(ef) ~= "table" or type(ef.AddMessage) ~= "function" then
        return
    end
    origAdd = ef.AddMessage
    ef.AddMessage = add
end

F:Listen("login", function()
    local ok, err = pcall(install)
    if not ok then
        F:LogError("alerts", err)
    end
    pcall(apply_font)
end)
for _, sig in ipairs({ "options", "state" }) do
    F:Listen(sig, function()
        pcall(apply_font)
    end)
end
