-- WoWFA Forever - what the game blocked (1.1.1; the owner 25 Nov: the addon list said
-- "Interface actions failed because of this AddOn: 534"). The game fires ADDON_ACTION_BLOCKED /
-- ADDON_ACTION_FORBIDDEN with the addon name and the protected function. We count the ones that
-- are ours, keep the first of each in the error list (Status page) and say it once in chat, so
-- the NEXT report names the exact call instead of a number. Nothing here touches any frame.

local F = WoWFAF

local total = 0
local seen = {}
F.BlockedSeen = seen

function F.BlockedTotal()
    return total
end

local ev = CreateFrame("Frame")
pcall(ev.RegisterEvent, ev, "ADDON_ACTION_BLOCKED")
pcall(ev.RegisterEvent, ev, "ADDON_ACTION_FORBIDDEN")
ev:SetScript("OnEvent", function(_, event, addon, fn)
    if addon ~= F.ADDON then
        return
    end
    total = total + 1
    local key = tostring(fn)
    local n = (seen[key] or 0) + 1
    seen[key] = n
    if n > 1 then
        return
    end
    pcall(function()
        local combat = InCombatLockdown and InCombatLockdown() and "combat" or "no combat"
        F:LogError("blocked", string.sub(tostring(event) .. " " .. key .. " (" .. combat .. ")", 1, 200))
        if total <= 4 then
            F.Chat("WoWFA: the game blocked " .. key .. " (" .. combat .. ") - please send this line")
        end
    end)
end)
