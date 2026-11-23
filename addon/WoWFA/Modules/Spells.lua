-- WoWFA Forever - spellbook and talents: Persian name + description in the
-- tooltip. Descriptions are matched as templates (numbers -> #) against the
-- live English text and refilled with the live numbers, so a rank change or a
-- number tweak in a patch still shows the right values. A text the game has
-- reworded simply does not match (and is counted for the update warning).

local F = WoWFAF
local T = F.T
local C = F.C
local DESC = { 1.0, 0.82, 0.0 }

local function tdp(kind)
    return TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType
        and Enum.TooltipDataType[kind] ~= nil
end

local function left_lines(tt, data)
    local out = {}
    if data and type(data.lines) == "table" then
        for _, ln in ipairs(data.lines) do
            out[#out + 1] = F.Usable(ln.leftText) and ln.leftText or ""
        end
        if #out > 0 then
            return out
        end
    end
    local name = tt:GetName()
    if not name then
        return out
    end
    for i = 1, tt:NumLines() do
        local fs = _G[name .. "TextLeft" .. i]
        local t = fs and fs:GetText()
        out[#out + 1] = (F.Usable(t) and t) or ""
    end
    return out
end

-- 0.5.7 (Brain audit B8): the live spell name can carry |c..|r or an icon /
-- hyperlink escape - strip before the Once key and the name lookup
local function plain(s)
    s = string.gsub(s or "", "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    s = string.gsub(s, "|T.-|t", "")
    s = string.gsub(s, "|H.-|h", "")
    s = string.gsub(s, "|h", "")
    return s
end

-- rc6 (rc4 miss list: 27 of 34 "misses" were our OWN Persian read back as a new
-- line): any line that already holds Arabic-script text is never matched and
-- never logged. UTF-8: U+0600-06FF = D8-DB xx, presentation forms = EF AD-BB xx.
local function has_fa(s)
    return type(s) == "string"
        and (string.find(s, "[\216-\219]") ~= nil or string.find(s, "\239[\173-\187]") ~= nil)
end

-- rc4 (the owner's miss list: "If the hunter takes damage, she will be dazed"):
-- the client fills the $g he/she choice with the PLAYER's gender while the data
-- was keyed from the male text. On a miss, retry the key with the male words.
local function gender_alts(key)
    if not string.find(key, "%f[%a]she%f[%A]") and not string.find(key, "%f[%a]her") then
        return nil
    end
    local k = string.gsub(key, "%f[%a]she%f[%A]", "he")
    k = string.gsub(k, "%f[%a]herself%f[%A]", "himself")
    local his = string.gsub(k, "%f[%a]her%f[%A]", "his")
    local him = string.gsub(k, "%f[%a]her%f[%A]", "him")
    return { his, him }
end

local function spell_tip(modId, tt, data)
    if tt and tt.wfaScan then
        return -- the /wowfa dump scanner tooltip: we export English, never translate it
    end
    if not tt or (tt.IsForbidden and tt:IsForbidden()) then
        return
    end
    local lines = left_lines(tt, data)
    local name = lines[1]
    if type(name) ~= "string" or name == "" then
        return
    end
    name = plain(name)
    if not T.Once(tt, "s" .. name) then
        return
    end
    local names = F.D.names and F.D.names.spell or {}
    local tpl = F.D.tpl or {}
    local faName = names[T.NameKey(name)] -- lane-28 §A3: NameKey on both sides
    -- rc4: a line 1 that starts with a digit is a cost row ("107 Mana"), never a name
    if faName == nil and not string.find(name, "^%d") and not has_fa(name) then
        F:Miss("spell", T.NameKey(name), name) -- rc3 update watch (Core F:Miss)
    end
    local found = {}
    for i = 2, #lines do
        local text = lines[i]
        if text ~= "" and #text > 8 and not has_fa(text) then
            local key, nums = T.NumKey(text)
            local fa = tpl[key]
            if not fa then
                local alts = gender_alts(key)
                if alts then
                    fa = tpl[alts[1]] or tpl[alts[2]]
                end
            end
            if fa then
                found[#found + 1] = T.Fill(fa, nums)
            elseif #text > 30 then
                -- rc4: description-sized lines only (cost / range / cast header
                -- rows are short; they belong to the in-place settings v2 work)
                F:Miss("tpl", key, plain(text), name)
            end
        end
    end
    F:Track(modId, faName ~= nil or #found > 0)
    -- lane-b16: the sp family switch off = the English name stays on the
    -- spell/talent tooltip. A hit still counts (the data matches the game).
    local showName = faName ~= nil and F.Room.On("namesSpell") -- 51-B
    -- Brain review: the descriptions are the room's «توضیحات و افکت‌ها» (they
    -- used to ride no switch at all, so «کاملاً انگلیسی» still showed Persian)
    local showDesc = #found > 0 and F.Room.On("textDesc")
    if showName then
        T.TipLine(tt, faName, C.gold)
    end
    if showDesc then
        for _, fa in ipairs(found) do
            T.TipLine(tt, T.Prepare(fa), DESC)
        end
    end
    T.Done(tt)
    if showName or showDesc then
        tt:Show()
    end
end

local function data_ok()
    local t = F.D.tpl
    local n = F.D.names and F.D.names.spell
    if type(t) == "table" and next(t) then
        return t
    end
    return n
end

-- --------------------------------------------------------------- spellbook
local S = { id = "spellbook", order = 5, risk = "high", nameKey = "m_spellbook", descKey = "m_spellbook_d", watchMiss = true }
S.data = data_ok

function S.api()
    return tdp("Spell") or (GameTooltip and (GameTooltip.SetSpellBookItem or GameTooltip.SetSpell or GameTooltip.SetSpellByID) ~= nil)
end

function S.install()
    local fn = F:Wrap("spellbook", function(tt, data)
        spell_tip("spellbook", tt, data)
    end)
    if tdp("Spell") then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, fn)
        return
    end
    for _, method in ipairs({ "SetSpellBookItem", "SetSpell", "SetSpellByID" }) do
        if GameTooltip[method] then
            hooksecurefunc(GameTooltip, method, function(tt)
                fn(tt)
            end)
        end
    end
end
F:RegisterModule(S)

-- ----------------------------------------------------------------- talents
local TL = { id = "talents", order = 6, risk = "high", nameKey = "m_talents", descKey = "m_talents_d", watchMiss = true }
TL.data = data_ok

function TL.api()
    if GetTalentInfo ~= nil and GameTooltip ~= nil and GameTooltip.SetTalent ~= nil then
        TL.okWhy = nil
        return true
    end
    -- lane-b12 (owner test of 0.5.4: Talents=noapi): this client has no
    -- GameTooltip.SetTalent - talent tooltips arrive as Spell tooltip data,
    -- which the spellbook module already hooks. Report ok with the
    -- "via spellbook" why and DO NOT add a second hook (never add the
    -- Persian text twice). Final wording after the owner's talent-hover test.
    if tdp("Spell") then
        TL.okWhy = "via_spellbook"
        return true
    end
    TL.okWhy = nil
    return false
end

function TL.install()
    if GameTooltip and GameTooltip.SetTalent then
        hooksecurefunc(GameTooltip, "SetTalent", F:Wrap("talents", function(tt)
            spell_tip("talents", tt)
        end))
        return
    end
    -- 0.5.7 (Brain audit B9): on this client talent tooltips arrive as Spell
    -- data. The spellbook hook covers them while spellbook is active; when the
    -- player turns Spellbook OFF and Talents ON, talents must still translate -
    -- so install a Spell post-call that only acts while spellbook is NOT active
    -- (never a double line).
    if not tdp("Spell") then
        return
    end
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, F:Wrap("talents", function(tt, data)
        if F:Active("spellbook") then
            return
        end
        spell_tip("talents", tt, data)
    end))
end
F:RegisterModule(TL)

-- --------------------------------------------- rc4: tooltips with no spell data
-- The owner's rc3 test: the Forever talent frame (Primary / Secondary, Apply
-- Changes) shows plain GameTooltip text with no Spell tooltip data, so no
-- post-call fires (Ferocity stayed English and never reached the miss list).
-- Fallback: on GameTooltip show, when line 1 is a KNOWN spell/talent name and
-- the tooltip is not an item or a unit, run the same spell_tip. T.Once (same
-- "s"..name key) keeps a tooltip the post-call already did from getting the
-- Persian twice. Unknown names under a talent/spell frame are logged (kind
-- "tip", with the owner frame path) so the next build can hook that frame.
local function owner_path(tt)
    local ok, path = pcall(function()
        local parts = {}
        local f = tt.GetOwner and tt:GetOwner()
        local n = 0
        while f and n < 6 do
            local nm = f.GetName and f:GetName()
            if type(nm) == "string" and F.Usable(nm) then
                parts[#parts + 1] = nm
            end
            f = f.GetParent and f:GetParent()
            n = n + 1
        end
        return table.concat(parts, "<")
    end)
    return (ok and type(path) == "string") and path or ""
end

local function is_item_or_unit(tt)
    local ok, r = pcall(function()
        if tt.GetItem then
            local _, link = tt:GetItem()
            if link then
                return true
            end
        end
        if tt.GetUnit then
            local _, unit = tt:GetUnit()
            if unit then
                return true
            end
        end
        return false
    end)
    return (not ok) or r
end

local function plain_tip(tt)
    if not tt or (tt.IsForbidden and tt:IsForbidden()) then
        return
    end
    local mod = (F:Active("spellbook") and "spellbook") or (F:Active("talents") and "talents") or nil
    if not mod then
        return
    end
    local tname = tt.GetName and tt:GetName()
    local fs = tname and _G[tname .. "TextLeft1"]
    local first = fs and fs:GetText()
    if not F.Usable(first) or type(first) ~= "string" or first == "" then
        return
    end
    first = plain(first)
    if has_fa(first) then
        return
    end
    local names = F.D.names and F.D.names.spell or {}
    if names[T.NameKey(first)] == nil then
        local path = owner_path(tt)
        local low = string.lower(path)
        local inFrame = string.find(low, "talent") or string.find(low, "spell")
        -- rc6: a spec tab tooltip is just the tree name ("Survival", "Beast Mastery")
        local trees = F.D.names and F.D.names.tree or {}
        local faTree = inFrame and trees[T.NameKey(first)] or nil
        if faTree and not is_item_or_unit(tt) then
            if T.Once(tt, "t" .. T.NameKey(first)) and F.Room.On("namesSpell") then
                T.TipLine(tt, faTree, C.gold)
                T.Done(tt)
                tt:Show()
            end
            return
        end
        if inFrame then
            F:Miss("tip", path .. "|" .. T.NameKey(first), first, path)
        end
        return
    end
    if is_item_or_unit(tt) then
        return
    end
    spell_tip(mod, tt, nil)
end

if GameTooltip and GameTooltip.HookScript then
    GameTooltip:HookScript("OnShow", function(tt)
        local ok, err = pcall(plain_tip, tt)
        if not ok then
            F:LogError("spellbook", err)
        end
    end)
end
