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

-- 1.1.6 (the block came back on MultiBarBottomLeft buttons): WHICH variable did WoWFA write?
-- issecurevariable names the addon that last wrote a key. The frame the game blocked, its
-- parent, the game tooltip, the error frame and every global are checked once per kind of
-- block, and the keys WoWFA wrote (not its own wfa* fields) are named in the report line.
local function ours(t, k)
    local ok, sec, by = pcall(issecurevariable, t, k)
    return ok and not sec and by == F.ADDON
end

local function taint_scan(fn)
    if type(issecurevariable) ~= "function" then
        return ""
    end
    local hits, seen = {}, {}
    local function scan(label, t)
        if type(t) ~= "table" or seen[t] then
            return
        end
        seen[t] = true
        for k in pairs(t) do
            if #hits >= 12 then
                return
            end
            if type(k) == "string" and not string.find(k, "^wfa") and ours(t, k) then
                hits[#hits + 1] = label .. "." .. k
            end
        end
    end
    local fname = string.match(tostring(fn), "^([%w_]+)[:%.]")
    local f = fname and _G[fname]
    if type(f) == "table" then
        scan(fname, f)
        if type(f.GetParent) == "function" then
            local okp, p = pcall(f.GetParent, f)
            if okp and type(p) == "table" then
                local okn, pn = pcall(p.GetName, p)
                scan(okn and type(pn) == "string" and pn or "parent", p)
            end
        end
    end
    scan("GameTooltip", _G.GameTooltip)
    scan("UIErrorsFrame", _G.UIErrorsFrame)
    -- no sweep over every global any more: with the game's taint log on it wrote one line per
    -- global read (40 MB in a minute, the owner's crash); the frame, its bar and the tooltip
    -- are enough to name the cause
    return #hits > 0 and (" | tainted: " .. table.concat(hits, ", ")) or " | tainted: none found"
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
        -- 1.1.2: the event fires INSIDE the blocked call, so the stack names the game code that
        -- made it (the first 4 files:lines) - the next report says exactly where it came from
        local where = ""
        if debugstack then
            local okd, stack = pcall(debugstack, 2, 8, 0)
            if okd and type(stack) == "string" then
                local parts = {}
                for file, line in string.gmatch(stack, "([%w_%-%./\\]+%.lua):(%d+)") do
                    parts[#parts + 1] = (string.match(file, "([^/\\]+)$") or file) .. ":" .. line
                    if #parts >= 4 then
                        break
                    end
                end
                where = table.concat(parts, " < ")
            end
        end
        local okw, who = true, ""
        if total <= 2 then
            okw, who = pcall(taint_scan, key)
        end
        who = okw and type(who) == "string" and who or ""
        F:LogError("blocked", string.sub(tostring(event) .. " " .. key .. " (" .. combat .. ") " .. where .. who, 1, 400))
        if total <= 4 then
            F.Chat("WoWFA: the game blocked " .. key .. " (" .. combat .. ") " .. where .. who .. " - please send this line")
        end
    end)
end)
