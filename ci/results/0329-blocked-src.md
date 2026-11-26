## task 0329-blocked-src (script)

**GREEN**


### ADDON_ACTION

addon/WoWFA/Modules/Blocked.lua:2
```
    1 -- WoWFA Forever - what the game blocked (1.1.1; the owner 25 Nov: the addon list said
    2 -- "Interface actions failed because of this AddOn: 534"). The game fires ADDON_ACTION_BLOCKED /
    3 -- ADDON_ACTION_FORBIDDEN with the addon name and the protected function. We count the ones that
    4 -- are ours, keep the first of each in the error list (Status page) and say it once in chat, so
    5 -- the NEXT report names the exact call instead of a number. Nothing here touches any frame.
    6 
    7 local F = WoWFAF
    8 
    9 local total = 0
   10 local seen = {}
   11 F.BlockedSeen = seen
   12 
   13 function F.BlockedTotal()
   14     return total
   15 end
   16 
```
addon/WoWFA/Modules/Blocked.lua:3
```
    1 -- WoWFA Forever - what the game blocked (1.1.1; the owner 25 Nov: the addon list said
    2 -- "Interface actions failed because of this AddOn: 534"). The game fires ADDON_ACTION_BLOCKED /
    3 -- ADDON_ACTION_FORBIDDEN with the addon name and the protected function. We count the ones that
    4 -- are ours, keep the first of each in the error list (Status page) and say it once in chat, so
    5 -- the NEXT report names the exact call instead of a number. Nothing here touches any frame.
    6 
    7 local F = WoWFAF
    8 
    9 local total = 0
   10 local seen = {}
   11 F.BlockedSeen = seen
   12 
   13 function F.BlockedTotal()
   14     return total
   15 end
   16 
   17 local ev = CreateFrame("Frame")
```
addon/WoWFA/Modules/Blocked.lua:18
```
    4 -- are ours, keep the first of each in the error list (Status page) and say it once in chat, so
    5 -- the NEXT report names the exact call instead of a number. Nothing here touches any frame.
    6 
    7 local F = WoWFAF
    8 
    9 local total = 0
   10 local seen = {}
   11 F.BlockedSeen = seen
   12 
   13 function F.BlockedTotal()
   14     return total
   15 end
   16 
   17 local ev = CreateFrame("Frame")
   18 pcall(ev.RegisterEvent, ev, "ADDON_ACTION_BLOCKED")
   19 pcall(ev.RegisterEvent, ev, "ADDON_ACTION_FORBIDDEN")
   20 ev:SetScript("OnEvent", function(_, event, addon, fn)
   21     if addon ~= F.ADDON then
   22         return
   23     end
   24     total = total + 1
   25     local key = tostring(fn)
   26     local n = (seen[key] or 0) + 1
   27     seen[key] = n
   28     if n > 1 then
   29         return
   30     end
   31     pcall(function()
   32         local combat = InCombatLockdown and InCombatLockdown() and "combat" or "no combat"
```
addon/WoWFA/Modules/Blocked.lua:19
```
    5 -- the NEXT report names the exact call instead of a number. Nothing here touches any frame.
    6 
    7 local F = WoWFAF
    8 
    9 local total = 0
   10 local seen = {}
   11 F.BlockedSeen = seen
   12 
   13 function F.BlockedTotal()
   14     return total
   15 end
   16 
   17 local ev = CreateFrame("Frame")
   18 pcall(ev.RegisterEvent, ev, "ADDON_ACTION_BLOCKED")
   19 pcall(ev.RegisterEvent, ev, "ADDON_ACTION_FORBIDDEN")
   20 ev:SetScript("OnEvent", function(_, event, addon, fn)
   21     if addon ~= F.ADDON then
   22         return
   23     end
   24     total = total + 1
   25     local key = tostring(fn)
   26     local n = (seen[key] or 0) + 1
   27     seen[key] = n
   28     if n > 1 then
   29         return
   30     end
   31     pcall(function()
   32         local combat = InCombatLockdown and InCombatLockdown() and "combat" or "no combat"
   33         -- 1.1.2: the event fires INSIDE the blocked call, so the stack names the game code that
```
- ok: ADDON_ACTION: 4 hits

### debugstack

addon/WoWFA/Modules/Blocked.lua:36
```
   22         return
   23     end
   24     total = total + 1
   25     local key = tostring(fn)
   26     local n = (seen[key] or 0) + 1
   27     seen[key] = n
   28     if n > 1 then
   29         return
   30     end
   31     pcall(function()
   32         local combat = InCombatLockdown and InCombatLockdown() and "combat" or "no combat"
   33         -- 1.1.2: the event fires INSIDE the blocked call, so the stack names the game code that
   34         -- made it (the first 4 files:lines) - the next report says exactly where it came from
   35         local where = ""
   36         if debugstack then
   37             local okd, stack = pcall(debugstack, 2, 8, 0)
   38             if okd and type(stack) == "string" then
   39                 local parts = {}
   40                 for file, line in string.gmatch(stack, "([%w_%-%./\\]+%.lua):(%d+)") do
   41                     parts[#parts + 1] = (string.match(file, "([^/\\]+)$") or file) .. ":" .. line
   42                     if #parts >= 4 then
   43                         break
   44                     end
   45                 end
   46                 where = table.concat(parts, " < ")
   47             end
   48         end
   49         F:LogError("blocked", string.sub(tostring(event) .. " " .. key .. " (" .. combat .. ") " .. where, 1, 400))
   50         if total <= 4 then
```
addon/WoWFA/Modules/Blocked.lua:37
```
   23     end
   24     total = total + 1
   25     local key = tostring(fn)
   26     local n = (seen[key] or 0) + 1
   27     seen[key] = n
   28     if n > 1 then
   29         return
   30     end
   31     pcall(function()
   32         local combat = InCombatLockdown and InCombatLockdown() and "combat" or "no combat"
   33         -- 1.1.2: the event fires INSIDE the blocked call, so the stack names the game code that
   34         -- made it (the first 4 files:lines) - the next report says exactly where it came from
   35         local where = ""
   36         if debugstack then
   37             local okd, stack = pcall(debugstack, 2, 8, 0)
   38             if okd and type(stack) == "string" then
   39                 local parts = {}
   40                 for file, line in string.gmatch(stack, "([%w_%-%./\\]+%.lua):(%d+)") do
   41                     parts[#parts + 1] = (string.match(file, "([^/\\]+)$") or file) .. ":" .. line
   42                     if #parts >= 4 then
   43                         break
   44                     end
   45                 end
   46                 where = table.concat(parts, " < ")
   47             end
   48         end
   49         F:LogError("blocked", string.sub(tostring(event) .. " " .. key .. " (" .. combat .. ") " .. where, 1, 400))
   50         if total <= 4 then
   51             F.Chat("WoWFA: the game blocked " .. key .. " (" .. combat .. ") " .. where .. " - please send this line")
```
- ok: debugstack: 2 hits
