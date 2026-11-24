-- WoWFA Forever - small helpers for the owner's testing (rc29).
-- /wowfa target : the English name of the target, the key the data uses for it
-- and the Persian name the data has (or a note that it has none), written in the
-- chat. Players are never translated. This is for reporting a wrong NPC name:
-- the line holds exactly what the data needs to find the row.

local F = WoWFAF
local T = F.T

function F.TargetInfo()
    if not (UnitExists and UnitExists('target')) then
        F.Chat('WoWFA: no target')
        return
    end
    local en = UnitName('target')
    if not F.Usable(en) or type(en) ~= 'string' or en == '' then
        F.Chat('WoWFA: the name of the target can not be read')
        return
    end
    local isp = UnitIsPlayer('target')
    if F.Usable(isp) and isp then
        F.Chat('WoWFA: the target is a player (players are never translated)')
        return
    end
    local key = T.NameKey(en)
    local names = (F.D and F.D.names) or {}
    local fa = (names.npc and names.npc[key]) or (names.boss and names.boss[key])
    F.Chat('WoWFA target: "' .. en .. '"  key: ' .. key)
    if fa then
        local ok, shaped = pcall(function()
            return T.ShapeLine(T.Digits(fa), T.Mode())
        end)
        F.Chat('WoWFA data: ' .. ((ok and type(shaped) == 'string' and shaped) or fa))
    else
        F.Chat('WoWFA data: no Persian name for this one (it stays English)')
    end
end
