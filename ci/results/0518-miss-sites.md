## task 0518-miss-sites (script)

**GREEN**


### F:Miss(

addon/WoWFA/Core.lua:642
```
  641 local TALK = { dlg = true, say = true, book = true }
  642 function F:Miss(kind, key, sample, ctx)
  643     local db = F.db
```
addon/WoWFA/Modules/Dialog.lua:146
```
  145     pcall(harvest, kind, key, text, ctx)
  146     F:Miss(kind, key, string.sub(text, 1, 300), ctx)
  147 end
```
addon/WoWFA/Modules/GameUI.lua:90
```
   89     missN = missN + 1
   90     F:Miss("ui", string.lower(text), text, scope)
   91 end
```
addon/WoWFA/Modules/Npc.lua:43
```
   42     if v == nil and not quiet and not string.find(name, "[\216-\219\239]") then
   43         F:Miss("npc", key, name)
   44     end
```
addon/WoWFA/Modules/Quests.lua:372
```
  371     if stale then
  372         F:Miss("qold", tostring(id), title, ctx)
  373     end
```
addon/WoWFA/Modules/Quests.lua:375
```
  374     if (entry.t or "") == "" then
  375         F:Miss("quest", tostring(id), title, ctx)
  376     end
```
addon/WoWFA/Modules/Quests.lua:384
```
  383         if en ~= "" and have == "" then
  384             F:Miss("qtext", tostring(id) .. ":" .. p[1], title .. " / " .. en, p[1])
  385         end
```
addon/WoWFA/Modules/Quests.lua:404
```
  403         if F.Usable(id) then
  404             F:Miss("quest", tostring(id), title_of(id, enTitle), ctx) -- 1.0.5
  405         end
```
addon/WoWFA/Modules/Spells.lua:328
```
  327     if faName == nil and not string.find(name, "^%d") and not has_fa(name) and not recipe(name) then
  328         F:Miss("spell", T.NameKey(name), name) -- rc3 update watch (Core F:Miss)
  329     end
```
addon/WoWFA/Modules/Spells.lua:354
```
  353                 -- rows are short; they belong to the in-place settings v2 work)
  354                 F:Miss("tpl", key, plain(text), name)
  355             end
```
addon/WoWFA/Modules/Spells.lua:598
```
  597         if inFrame then
  598             F:Miss("tip", path .. "|" .. T.NameKey(first), first, path)
  599         end
```
addon/WoWFA/Modules/Sysmsg.lua:174
```
  173     sysN = sysN + 1
  174     F:Miss('sys', key, k, 'system')
  175 end
```
addon/WoWFA/Modules/Tracker.lua:169
```
  168     if v == nil and tbl and fam ~= "it" and not string.find(en, "[\216-\219\239]") then
  169         F:Miss(fam == "npc" and "npc" or "object", T.NameKey(en), en, "objective")
  170     end
```
addon/WoWFA/Modules/Tracker.lua:404
```
  403                 elseif string.find(body, "%a") and not string.find(body, "[\216-\219\239]") then
  404                     F:Miss("obj", string.lower((string.gsub(body, "%d+", "#"))), body, e.qid and ("q" .. tostring(e.qid)) or "tracker") -- 1.0.5
  405                 end
```
addon/WoWFA/Modules/Tracker.lua:460
```
  459                     elseif F.Room.On("namesQuest") then
  460                         F:Miss("quest", tostring(qid), body, "tracker") -- 1.0.5
  461                     end
```
addon/WoWFA/Modules/Tracker.lua:484
```
  483                     elseif F.Room.On("questText") and string.find(body, "%a") and not string.find(body, "[\216-\219\239]") then
  484                         F:Miss("obj", string.lower((string.gsub(body, "%d+", "#"))), body, qid and ("q" .. tostring(qid)) or "tracker") -- 1.0.5
  485                     end
```
addon/WoWFA/Modules/Tracker.lua:544
```
  543                 elseif F.Room.On("namesQuest") then
  544                     F:Miss("quest", tostring(id), txt, "log") -- 1.0.5
  545                 end
```
addon/WoWFA/Modules/Tracker.lua:573
```
  572                     elseif F.Room.On("namesQuest") then
  573                         F:Miss("quest", tostring(id), txt, "gossip") -- 1.0.5
  574                     end
```
addon/WoWFA/Modules/Walk.lua:112
```
  111         if lid then
  112             F:Miss("quest", tostring(lid), title, "list")
  113         end
```
addon/WoWFA/Modules/Walk.lua:118
```
  117     if (p[2] or "") == "" then
  118         F:Miss("quest", tostring(id), title, "list") -- 1.0.5
  119         return nil
```
addon/WoWFA/Modules/Walk.lua:232
```
  231         if string.find(body, "%d+/%d+") and string.find(body, "%a") and not has_fa(body) then
  232             F:Miss("obj", string.lower((string.gsub(body, "%d+", "#"))), body, "objective")
  233         end
```
addon/WoWFA/Modules/Walk.lua:240
```
  239     if fa == nil and not has_fa(name) then
  240         F:Miss("npc", key, name, "objective") -- 1.0.5
  241     end
```
addon/WoWFA/Modules/Zones.lua:73
```
   72     if v == nil and not quiet and not string.find(name, "%d") and not string.find(name, "[\216-\219\239]") then
   73         F:Miss("zone", T.NameKey(name), name)
   74     end
```
tests/run.lua:293
```
  292     check("an older build's miss list is dropped", F.db.missN == 0 and next(F.db.miss) == nil, F.db.missN)
  293     F:Miss("zone", "zz fresh", "Zz Fresh")
  294     F:MissFresh()
```
tests/run.lua:640
```
  639     check("miss log starts empty", F.db.missN == 0, F.db.missN)
  640     F:Miss("tpl", "a totally unknown line #", "A totally unknown line 5.", "Test Spell")
  641     F:Miss("tpl", "a totally unknown line #", "A totally unknown line 6.", "Test Spell")
```
tests/run.lua:641
```
  640     F:Miss("tpl", "a totally unknown line #", "A totally unknown line 5.", "Test Spell")
  641     F:Miss("tpl", "a totally unknown line #", "A totally unknown line 6.", "Test Spell")
  642     local e = F.db.miss["tpl:a totally unknown line #"]
```
tests/run.lua:650
```
  649     check("status page lists the misses", txt:find("misses=1", 1, true) ~= nil and txt:find("A totally unknown line 5.", 1, true) ~= nil, txt)
  650     F:Miss("zone", "some new zone", "Some New Zone|x")
  651     txt = box and box:GetText() or ""
```
tests/run.lua:654
```
  653     for i = 1, F.MISS_CAP + 20 do
  654         F:Miss("zone", "zone " .. i, "Zone " .. i)
  655     end
```
tests/run.lua:1188
```
 1187     check("beacon: switching on shows the icon", B.IsOn() == true and ic ~= nil and ic:IsShown())
 1188     F:Miss("tpl", "zz beacon line #", "Zz beacon line 5.", "Test")
 1189     check("beacon: a new find makes the frame blink", B.Flashing() == true)
```
- ok: F:Miss(: 29 hits

### UnitAura

addon/WoWFA/Modules/Auras.lua:112
```
  111     end)
  112     for _, m in ipairs({ "SetUnitAura", "SetUnitBuff", "SetUnitDebuff", "SetUnitBuffByAuraInstanceID",
  113         "SetUnitDebuffByAuraInstanceID" }) do
```
addon/WoWFA/Modules/Auras.lua:120
```
  119     end
  120     F.TipPost("UnitAura", fn)
  121 end
```
- ok: UnitAura: 2 hits

### SetUnitAura

addon/WoWFA/Modules/Auras.lua:112
```
  111     end)
  112     for _, m in ipairs({ "SetUnitAura", "SetUnitBuff", "SetUnitDebuff", "SetUnitBuffByAuraInstanceID",
  113         "SetUnitDebuffByAuraInstanceID" }) do
```
- ok: SetUnitAura: 1 hits

### TipPost(

addon/WoWFA/Modules/Auras.lua:120
```
  119     end
  120     F.TipPost("UnitAura", fn)
  121 end
```
addon/WoWFA/Modules/Npc.lua:239
```
  238     -- 1.1.8: no post-call inside the game's tooltip build (see F.TipPost in Spells.lua)
  239     if not (F.TipPost and F.TipPost("Unit", F:Wrap("npc", tip))) and GameTooltip.HookScript then
  240         GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
```
addon/WoWFA/Modules/Spells.lua:75
```
   74 
   75 function F.TipPost(kind, fn)
   76     local gt = GameTooltip
```
addon/WoWFA/Modules/Spells.lua:459
```
  458     end)
  459     if F.TipPost("Spell", fn) then
  460         return
```
addon/WoWFA/Modules/Spells.lua:506
```
  505     -- (never a double line).
  506     F.TipPost("Spell", F:Wrap("talents", function(tt, data)
  507         if F:Active("spellbook") then
```
- ok: TipPost(: 5 hits
