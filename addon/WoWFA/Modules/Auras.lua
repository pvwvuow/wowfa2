-- WoWFA Forever 1.2.1 - buffs and debuffs (the owner 27 Nov: "lots of buffs are not translated").
-- The name and the description of an aura are the same data as a spell's (names.spell + the
-- description templates, so the markers, the colours and the display choice of the spell page apply
-- as they are). This module only (1) puts an aura tooltip through the same function as a spell
-- tooltip, with short lines allowed ("Stunned."), and (2) translates the two lines an aura adds that
-- no spell has: the dispel type (Magic, Curse...) and the time left ("5 min remaining").
-- Hooks: hooksecurefunc on the tooltip setters (they run after the game's function, so no taint) and
-- the same TipPost path the spells use. Nothing of the game is written.

local F = WoWFAF
local T = F.T
local L = F.L

local function plain(s)
    s = string.gsub(s or "", "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    return s
end

local function has_fa(s)
    return type(s) == "string"
        and (string.find(s, "[\216-\219]") ~= nil or string.find(s, "\239[\173-\187]") ~= nil)
end

-- the Persian of an aura-only line, or nil
local function extra_fa(text)
    local t = plain(text)
    t = string.gsub(t, "^%s+", "")
    t = string.gsub(t, "%s+$", "")
    local low = string.lower(t)
    local d = L.AURA_DISPEL and L.AURA_DISPEL[low]
    if d then
        return d
    end
    local n, unit = string.match(low, "^([%d%.]+) (%a+) remaining$")
    if n and unit and L.AURA_UNIT and L.AURA_LEFT then
        local u = L.AURA_UNIT[unit]
        if u then
            return string.format(L.AURA_LEFT, n, u)
        end
    end
    return nil
end

local function extra_lines(tt)
    local name = tt.GetName and tt:GetName()
    if not name then
        return
    end
    local n = (tt.NumLines and tt:NumLines()) or 0
    local changed = false
    for i = 2, n do
        local fs = _G[name .. "TextLeft" .. i]
        if fs and fs.GetText then
            local ok, text = pcall(fs.GetText, fs)
            if ok and F.Usable(text) and type(text) == "string" and text ~= "" and not has_fa(text) then
                local fa = extra_fa(text)
                if fa and pcall(T.TipSet, tt, fs, T.Prepare(fa), nil, "Left") then
                    changed = true
                end
            end
        end
    end
    if changed then
        T.Done(tt)
        tt:Show()
    end
end

local function aura_tip(tt, data)
    if not tt or (tt.IsForbidden and tt:IsForbidden()) then
        return
    end
    if F.ShiftEn and F.ShiftEn() then
        return -- Shift held = the game's English
    end
    if F.SpellTip then
        -- an aura description can be as short as "Stunned.": short lines are matched and noted here
        tt.wfaMin, tt.wfaMiss = 2, 12
        local ok, err = pcall(F.SpellTip, "auras", tt, data)
        tt.wfaMin, tt.wfaMiss = nil, nil
        if not ok then
            error(err, 0)
        end
    end
    extra_lines(tt)
end
F.AuraTip = aura_tip

local A = { id = "auras", order = 7, risk = "high", nameKey = "m_auras", descKey = "m_auras_d" }

function A.data()
    local t = F.D.tpl
    if type(t) == "table" and next(t) then
        return t
    end
    return F.D.names and F.D.names.spell
end

function A.api()
    return GameTooltip ~= nil
end

function A.install()
    local fn = F:Wrap("auras", function(tt, data)
        aura_tip(tt, data)
    end)
    for _, m in ipairs({ "SetUnitAura", "SetUnitBuff", "SetUnitDebuff", "SetUnitBuffByAuraInstanceID",
        "SetUnitDebuffByAuraInstanceID" }) do
        if GameTooltip and type(GameTooltip[m]) == "function" then
            pcall(hooksecurefunc, GameTooltip, m, function(tt)
                fn(tt)
            end)
        end
    end
    F.TipPost("UnitAura", fn)
end
F:RegisterModule(A)
