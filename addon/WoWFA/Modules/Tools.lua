-- WoWFA Forever - small helpers for the owner's testing (rc29).
-- /wowfa target : the English name of the target, the key the data uses for it
-- and the Persian name the data has (or a note that it has none), written in the
-- chat. Players are never translated. This is for reporting a wrong NPC name:
-- the line holds exactly what the data needs to find the row.
-- F.ListSize: the size of a Persian line we draw over a game font string.

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

-- The size of a Persian line we draw over a game font string (the quest list, the
-- quest tracker): the game's own size x the size slider of General (12 = 100%) x
-- the quest list slider of Quests (default 110%), so a slider the player moves is
-- never ignored. Steps of half a point, never below 8 or above 36.
function F.ListSize(base)
    base = tonumber(base) or 12
    local db = F.db or {}
    local v = base * ((tonumber(db.fontSize) or 12) / 12) * ((tonumber(db.listScale) or 110) / 100)
    if v < 8 then
        v = 8
    elseif v > 36 then
        v = 36
    end
    return math.floor(v * 2 + 0.5) / 2
end
