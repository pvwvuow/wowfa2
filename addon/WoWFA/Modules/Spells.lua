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

local function spell_tip(modId, tt, data)
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
    if faName == nil then
        F:Miss("spell", T.NameKey(name), name) -- rc3 update watch (Core F:Miss)
    end
    local found = {}
    for i = 2, #lines do
        local text = lines[i]
        if text ~= "" and #text > 8 then
            local key, nums = T.NumKey(text)
            local fa = tpl[key]
            if fa then
                found[#found + 1] = T.Fill(fa, nums)
            else
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
