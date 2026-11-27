## task 0462-grep-postcall (script)

**GREEN**


### AddTooltipPostCall

addon/WoWFA/Modules/Npc.lua:238
```
  234     target()
  235 end
  236 
  237 function M.install()
  238     if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType
  239         and Enum.TooltipDataType.Unit then
  240         TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, F:Wrap("npc", tip))
  241     elseif GameTooltip.HookScript then
  242         GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
```
addon/WoWFA/Modules/Npc.lua:240
```
  236 
  237 function M.install()
  238     if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType
  239         and Enum.TooltipDataType.Unit then
  240         TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, F:Wrap("npc", tip))
  241     elseif GameTooltip.HookScript then
  242         GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
  243     end
  244     if type(CompactUnitFrame_UpdateName) == "function" then
```
addon/WoWFA/Modules/Spells.lua:13
```
    9 local C = F.C
   10 local DESC = { 1.0, 0.82, 0.0 }
   11 
   12 local function tdp(kind)
   13     return TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType
   14         and Enum.TooltipDataType[kind] ~= nil
   15 end
   16 
   17 local function left_lines(tt, data)
```
addon/WoWFA/Modules/Spells.lua:370
```
  366     local fn = F:Wrap("spellbook", function(tt, data)
  367         spell_tip("spellbook", tt, data)
  368     end)
  369     if tdp("Spell") then
  370         TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, fn)
  371         return
  372     end
  373     for _, method in ipairs({ "SetSpellBookItem", "SetSpell", "SetSpellByID" }) do
  374         if GameTooltip[method] then
```
addon/WoWFA/Modules/Spells.lua:420
```
  416     -- (never a double line).
  417     if not tdp("Spell") then
  418         return
  419     end
  420     TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, F:Wrap("talents", function(tt, data)
  421         if F:Active("spellbook") then
  422             return
  423         end
  424         spell_tip("talents", tt, data)
```
tests/lua/wow_mock.lua:293
```
  289     local orig = tbl[name]
  290     tbl[name] = function(...) local r = { orig(...) }; fn(...); return (unpack or table.unpack)(r) end
  291 end
  292 TooltipDataProcessor = { cbs = {} }
  293 function TooltipDataProcessor.AddTooltipPostCall(t, fn) TooltipDataProcessor.cbs[t] = TooltipDataProcessor.cbs[t] or {}; table.insert(TooltipDataProcessor.cbs[t
  294 Enum = { TooltipDataType = { Item = 0, Spell = 1, Unit = 2, Object = 33 } }
  295 function RunTip(kind, tt, data) for _, fn in ipairs(TooltipDataProcessor.cbs[Enum.TooltipDataType[kind]] or {}) do fn(tt, data) end end
  296 C_Timer = { After = function(s, fn) table.insert(timers, fn) end }
  297 function RunTimers() local n = 0; while #timers > 0 and n < 200 do local fn = table.remove(timers, 1); fn(); n = n + 1 end end
```
- ok: AddTooltipPostCall: 6 hits
