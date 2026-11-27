## task 0458-grep-npcmiss (script)

**GREEN**


### NpcLookup

addon/WoWFA/Modules/Npc.lua:47
```
   41     local v = (names.npc and names.npc[key]) or (names.boss and names.boss[key])
   42     if v == nil and not quiet and not string.find(name, "[\216-\219\239]") then
   43         F:Miss("npc", key, name)
   44     end
   45     return v
   46 end
   47 F.NpcLookup = lookup
   48 
   49 local memo = {}
   50 local function shaped(fa)
   51     local key = fa .. "\1" .. tostring(T.Mode()) .. tostring(F.Room.On("faDigits"))
   52     local s = memo[key]
   53     if not s then
```
addon/WoWFA/Modules/Preview.lua:261
```
  255         f.lvl = en_fs(f.tip, 12, WHITE)
  256         f.lvl:SetPoint("TOPLEFT", f.tip, "TOPLEFT", 8, -52)
  257         f.lvl:SetText("Level 30")
  258     end,
  259     update = function(f)
  260         local en, _, k = pick("npc", { "Marshal Dughan", "Hogger", "Innkeeper Farley", "Gornek", "Thrall" })
  261         local v = active("npc") and F.NpcLookup and F.NpcLookup(k) or nil
  262         local mode = F.NpcMode and F.NpcMode() or 1
  263         if v then
  264             f.name:Set(v, true)
  265             if mode == 2 then
  266                 f.name2:Set(en, false)
  267             else
```
tests/run.lua:454
```
  448     check("namesNpc is no longer release-locked", F.RELEASE_LOCK.namesNpc == nil and F.RELEASE_LOCK.npc == nil)
  449     check("the npc module is registered", F.mods.npc ~= nil)
  450     local k, v = next(F.D.names.npc or {})
  451     check("npc names ship", k ~= nil and v ~= nil)
  452     if k then
  453         F.db.npcName = nil
  454         check("an NPC name resolves to Persian", F.NpcLookup(k) == v, tostring(F.NpcLookup(k)))
  455         F.db.npcName = 3
  456         check("npcName 3 = English: no lookup", F.NpcLookup(k) == nil)
  457         F.db.npcName = 1
  458         F.Room.Set("namesNpc", false)
  459         check("the namesNpc switch off = English", F.NpcLookup(k) == nil)
  460         F.Room.Set("namesNpc", true)
```
tests/run.lua:456
```
  450     local k, v = next(F.D.names.npc or {})
  451     check("npc names ship", k ~= nil and v ~= nil)
  452     if k then
  453         F.db.npcName = nil
  454         check("an NPC name resolves to Persian", F.NpcLookup(k) == v, tostring(F.NpcLookup(k)))
  455         F.db.npcName = 3
  456         check("npcName 3 = English: no lookup", F.NpcLookup(k) == nil)
  457         F.db.npcName = 1
  458         F.Room.Set("namesNpc", false)
  459         check("the namesNpc switch off = English", F.NpcLookup(k) == nil)
  460         F.Room.Set("namesNpc", true)
  461     end
  462     -- the share code: a round trip of a customised setup
```
tests/run.lua:459
```
  453         F.db.npcName = nil
  454         check("an NPC name resolves to Persian", F.NpcLookup(k) == v, tostring(F.NpcLookup(k)))
  455         F.db.npcName = 3
  456         check("npcName 3 = English: no lookup", F.NpcLookup(k) == nil)
  457         F.db.npcName = 1
  458         F.Room.Set("namesNpc", false)
  459         check("the namesNpc switch off = English", F.NpcLookup(k) == nil)
  460         F.Room.Set("namesNpc", true)
  461     end
  462     -- the share code: a round trip of a customised setup
  463     F.Room.Set("namesZone", false)
  464     F.DispSetDefault("title", 3)
  465     F.DispSet("talents", "desc", 1)
```
- ok: NpcLookup: 5 hits

### Miss("npc"

addon/WoWFA/Modules/Npc.lua:43
```
   37         return nil
   38     end
   39     local names = F.D.names or {}
   40     local key = T.NameKey(name)
   41     local v = (names.npc and names.npc[key]) or (names.boss and names.boss[key])
   42     if v == nil and not quiet and not string.find(name, "[\216-\219\239]") then
   43         F:Miss("npc", key, name)
   44     end
   45     return v
   46 end
   47 F.NpcLookup = lookup
   48 
   49 local memo = {}
```
addon/WoWFA/Modules/Walk.lua:240
```
  234         return nil
  235     end
  236     local names = (F.D and F.D.names) or {}
  237     local key = T.NameKey(name)
  238     local fa = (names.npc and names.npc[key]) or (names.boss and names.boss[key])
  239     if fa == nil and not has_fa(name) then
  240         F:Miss("npc", key, name, "objective") -- 1.0.5
  241     end
  242     fa = fa or name
  243     local line = T.Digits(T.Prepare(string.format("{{npc:%s|%s}} %s: %d/%d", name, fa, L.tracker_slain or "", tonumber(got), tonumber(need))))
  244     return (c or "") .. dash .. T.ShapeLine(line .. (done or ""), T.Mode()) .. (c and "|r" or "")
  245 end
  246 
```
- ok: Miss("npc": 2 hits

### Call %s

- ok: Call %s: 0 hits

### call_pet

- ok: call_pet: 0 hits

### "Resisted"

addon/WoWFA/Locale_Alerts.lua:114
```
  108     { "Your skill is not high enough.", "مهارت شما به اندازهٔ کافی بالا نیست." },
  109     { "You must be in a group to do that.", "برای این کار باید در گروه باشید." },
  110     { "That item is not ready yet.", "آن آیتم هنوز آماده نیست." },
  111     { "Can't do that while moving", "هنگام حرکت نمی" .. Z .. "توانید این کار را انجام دهید." },
  112     -- 1.0.9 (the owner's report 25 Nov)
  113     { "Objective Complete.", "هدف انجام شد." },
  114     { "Resisted", "مقاومت کرد" },
  115     { "%s slain: %d/%d", "%s کشته" .. Z .. "شده: %d/%d" },
  116     -- 1.1.0 (the owner's report 25 Nov + nearby ones)
  117     { "Item is locked.", "آیتم قفل است." },
  118     { "That item is locked.", "آن آیتم قفل است." },
  119     { "You can't do that right now.", "الان نمی" .. Z .. "توانید این کار را انجام دهید." },
  120     { "Another action is in progress", "کار دیگری در حال انجام است" },
```
- ok: "Resisted": 1 hits
