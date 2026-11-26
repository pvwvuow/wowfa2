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
local busy = false -- 1.1.2: our own AddMessage call is running (the hook must not re-enter)
local origFont -- { font, size, flags } of the error frame before we changed it

local function build()
    map, pats = {}, {}
    for _, e in ipairs(L.ALERTS or {}) do
        local en = _G[e[1]]
        if en == nil and string.find(e[1], ' ', 1, true) then
            en = e[1] -- a row named by its English text (no global known for it)
        end
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
            -- rc37: a zone name in the message ("Discovered: %s") is drawn in Persian too
            local zn = F.D and F.D.names and F.D.names.zone
            if type(zn) == "table" then
                for j = 1, #caps do
                    local okk, key = pcall(T.NameKey, caps[j])
                    local z = okk and key and zn[key]
                    if type(z) == "string" and z ~= "" then
                        caps[j] = z
                    end
                end
            end
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
        pcall(ef.SetFont, ef, F.FONT, ((origFont and origFont[2]) or 16) * ((tonumber(F.db.alertScale) or 100) / 100), "OUTLINE")
    elseif origFont then
        pcall(ef.SetFont, ef, origFont[1], origFont[2], origFont[3] or "")
        origFont = nil
    end
end

local function add(self, text, ...)
    -- 1.1.2 (the owner 25 Nov: "the game blocked MultiBarBottomRightButtonContainer1:SetShown()
    -- (combat)"): this used to REPLACE UIErrorsFrame.AddMessage with our own function. Every red
    -- line the game's own secure code sent there ("Ability is not ready yet" ...) then ran OUR code
    -- inside its call, the call became tainted and the game blocked the next protected action
    -- (the action bars) in combat. The game's AddMessage now runs untouched; this is a post-hook
    -- (hooksecurefunc, the safe way): it swaps the line the game just drew for the Persian one.
    if busy or not active() then
        return
    end
    local ok, fa = pcall(translate, text)
    if ok and fa then
        local oks, shaped = pcall(function()
            return T.ShapeLine(T.Digits(fa), T.Mode())
        end)
        if oks and type(shaped) == "string" and shaped ~= "" then
            local a1, a2, a3, a4, a5 = ...
            busy = true
            pcall(function()
                if not origFont then
                    apply_font()
                end
                if self.Clear then
                    self:Clear()
                end
                origAdd(self, shaped, a1, a2, a3, a4, a5)
            end)
            busy = false
        end
    elseif ok and F.Usable(text) and type(text) == "string" and text ~= ""
        and not string.find(text, "[\216-\219\239]")
        -- 1.0.9: "Fang of Bhag'thera: 1/1" is an item's progress - the item name stays
        -- English by design, so it is not a miss
        and not string.find(text, ":%s*%d+/%d+$") then
        pcall(F.Miss, F, "alert", T.NameKey(text), text)
    end
end

-- 1.1.6: the settings preview column asks for the Persian of a red line (nil = English)
function F.AlertPreview(text)
    if not active() then
        return nil
    end
    local ok, fa = pcall(translate, text)
    if not ok or not fa then
        return nil
    end
    local oks, s = pcall(function()
        return T.ShapeLine(T.Digits(fa), T.Mode())
    end)
    return oks and type(s) == "string" and s ~= "" and s or nil
end

local function install()
    local ef = _G.UIErrorsFrame
    if origAdd or type(ef) ~= "table" or type(ef.AddMessage) ~= "function" then
        return
    end
    origAdd = ef.AddMessage -- the game's own function, called directly (never through the hook)
    hooksecurefunc(ef, "AddMessage", add)
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
