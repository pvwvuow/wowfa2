## task 0199-grepmiss (script)

**GREEN**


### F:Miss(

addon/WoWFA/Core.lua:531
```
  528 -- a copy box; the next data update translates exactly what the live game
  529 -- shows. The addon never sends it anywhere.
  530 F.MISS_CAP = 400
  531 function F:Miss(kind, key, sample, ctx)
  532     local db = F.db
  533     if not db or type(key) ~= "string" or key == "" then
  534         return
```
addon/WoWFA/Modules/Npc.lua:43
```
   40     local key = T.NameKey(name)
   41     local v = (names.npc and names.npc[key]) or (names.boss and names.boss[key])
   42     if v == nil and not quiet and not string.find(name, "[\216-\219\239]") then
   43         F:Miss("npc", key, name)
   44     end
   45     return v
   46 end
```
addon/WoWFA/Modules/Spells.lua:201
```
  198     local faName = names[T.NameKey(name)] -- lane-28 §A3: NameKey on both sides
  199     -- rc4: a line 1 that starts with a digit is a cost row ("107 Mana"), never a name
  200     if faName == nil and not string.find(name, "^%d") and not has_fa(name) then
  201         F:Miss("spell", T.NameKey(name), name) -- rc3 update watch (Core F:Miss)
  202     end
  203     local found, srcOf = {}, {}
  204     for i = 2, #lines do
```
addon/WoWFA/Modules/Spells.lua:227
```
  224             elseif #text > 30 then
  225                 -- rc4: description-sized lines only (cost / range / cast header
  226                 -- rows are short; they belong to the in-place settings v2 work)
  227                 F:Miss("tpl", key, plain(text), name)
  228             end
  229         end
  230     end
```
addon/WoWFA/Modules/Spells.lua:472
```
  469             return
  470         end
  471         if inFrame then
  472             F:Miss("tip", path .. "|" .. T.NameKey(first), first, path)
  473         end
  474         return
  475     end
```
addon/WoWFA/Modules/Zones.lua:61
```
   58     -- rc3 update watch: a zone the data does not know (a label with digits is
   59     -- a level range / description line, never a zone name)
   60     if v == nil and not quiet and not string.find(name, "%d") and not string.find(name, "[\216-\219\239]") then
   61         F:Miss("zone", T.NameKey(name), name)
   62     end
   63     return v
   64 end
```
tests/run.lua:284
```
  281     F.db.missN, F.db.missV = 1, "0.0.0-old"
  282     F:MissFresh()
  283     check("an older build's miss list is dropped", F.db.missN == 0 and next(F.db.miss) == nil, F.db.missN)
  284     F:Miss("zone", "zz fresh", "Zz Fresh")
  285     F:MissFresh()
  286     check("the current build's misses are kept", F.db.missN == 1, F.db.missN)
  287     F:ClearMiss()
```
tests/run.lua:618
```
  615 local okMiss, errMiss = pcall(function()
  616     F:ClearMiss()
  617     check("miss log starts empty", F.db.missN == 0, F.db.missN)
  618     F:Miss("tpl", "a totally unknown line #", "A totally unknown line 5.", "Test Spell")
  619     F:Miss("tpl", "a totally unknown line #", "A totally unknown line 6.", "Test Spell")
  620     local e = F.db.miss["tpl:a totally unknown line #"]
  621     check("miss kept once, counted twice", e ~= nil and e.n == 2 and F.db.missN == 1, e and e.n)
```
tests/run.lua:619
```
  616     F:ClearMiss()
  617     check("miss log starts empty", F.db.missN == 0, F.db.missN)
  618     F:Miss("tpl", "a totally unknown line #", "A totally unknown line 5.", "Test Spell")
  619     F:Miss("tpl", "a totally unknown line #", "A totally unknown line 6.", "Test Spell")
  620     local e = F.db.miss["tpl:a totally unknown line #"]
  621     check("miss kept once, counted twice", e ~= nil and e.n == 2 and F.db.missN == 1, e and e.n)
  622     F.OpenPanel("health")
```
tests/run.lua:628
```
  625     local box = PF and PF.health and PF.health.missList
  626     local txt = box and box:GetText() or ""
  627     check("status page lists the misses", txt:find("misses=1", 1, true) ~= nil and txt:find("A totally unknown line 5.", 1, true) ~= nil, txt)
  628     F:Miss("zone", "some new zone", "Some New Zone|x")
  629     txt = box and box:GetText() or ""
  630     check("a new miss shows while the panel is open (pipe escaped)", txt:find("misses=2", 1, true) ~= nil and txt:find("Some New Zone!x", 1, true) ~= nil, txt)
  631     for i = 1, F.MISS_CAP + 20 do
```
tests/run.lua:632
```
  629     txt = box and box:GetText() or ""
  630     check("a new miss shows while the panel is open (pipe escaped)", txt:find("misses=2", 1, true) ~= nil and txt:find("Some New Zone!x", 1, true) ~= nil, txt)
  631     for i = 1, F.MISS_CAP + 20 do
  632         F:Miss("zone", "zone " .. i, "Zone " .. i)
  633     end
  634     check("miss log is capped", F.db.missN == F.MISS_CAP, F.db.missN)
  635     Click(PF.missClear)
```
- ok: F:Miss(: 11 hits

### F:Track(

addon/WoWFA/Core.lua:499
```
  496 end
  497 
  498 -- lookup statistics: warn once when most lookups miss (game texts changed)
  499 function F:Track(modId, hit, stale)
  500     local m = F.mods[modId]
  501     if not m then
  502         return
```
addon/WoWFA/Modules/Quests.lua:354
```
  351     end
  352     local entry = get(id)
  353     if not entry then
  354         F:Track("quests", false)
  355         pane:Hide()
  356         return
  357     end
```
addon/WoWFA/Modules/Quests.lua:365
```
  362     local stale = F.Usable(enTitle) and type(enTitle) == "string" and enTitle ~= "" and entry.h ~= ""
  363         and F.TitleHash(enTitle) ~= entry.h
  364     if shownId ~= id or shownCtx ~= ctx then
  365         F:Track("quests", true, stale)
  366     end
  367     pane.entry, pane.ctx, pane.anchor = entry, ctx, anchor
  368     shownId, shownCtx = id, ctx
```
addon/WoWFA/Modules/Spells.lua:231
```
  228             end
  229         end
  230     end
  231     F:Track(modId, faName ~= nil or #found > 0)
  232     -- lane-b16: the sp family switch off = the English name stays on the
  233     -- spell/talent tooltip. A hit still counts (the data matches the game).
  234     -- rc8: the section's own (or General's) display of the name and the description
```
addon/WoWFA/Modules/Zones.lua:544
```
  541         -- 51-B had this inverted (it fed the watch ONLY while the switch was
  542         -- off, i.e. only false misses, and never a real hit)
  543         if F.Room.On("namesZone") then
  544             F:Track("dungeons", zfa ~= nil)
  545         end
  546         if F.Room.On("namesZone") and (mode == 1 or (mode == 2 and dungeon)) then
  547             toast(zfa, sub ~= "" and sub ~= zone and fa(sub) or nil, zfa and kind or nil)
```
- ok: F:Track(: 5 hits

### missList

addon/WoWFA/Panel.lua:223
```
  220     -- rc3 update watch: the misses as ONE line (a single-line box never grows
  221     -- over the rows below; Ctrl+C copies all of it). Entries: kind :: text ::
  222     -- spell/context :: xCount, most seen first
  223     if health.missList then
  224         F:MissFresh()
  225         local list = {}
  226         for _, e in pairs(F.db and type(F.db.miss) == "table" and F.db.miss or {}) do
```
addon/WoWFA/Panel.lua:243
```
  240             t = string.gsub(t, "[\r\n]+", " / ")
  241             out[#out + 1] = string.format("%s :: %s :: %s :: x%d", tostring(e.k), t, tostring(e.c or ""), tonumber(e.n) or 1)
  242         end
  243         health.missList:SetFixed(table.concat(out, " ;; "))
  244         health.missHead:SetFa(string.format(L.h_miss_n, #list), PW - 30)
  245     end
  246 end
```
addon/WoWFA/Panel.lua:974
```
  971         self:SetText(self.wfaFixed)
  972         self:SetCursorPosition(0)
  973     end
  974     health.missList = mb
  975     place(ml, 24, 4)
  976     local mbt = CreateFrame("Frame", nil, page.child)
  977     mbt:SetSize(PW - 16, 30)
```
addon/WoWFA/Panel.lua:985
```
  982     panel.missClear:SetPoint("RIGHT", mbt, "RIGHT", -4, 0)
  983     -- 1.0.3: one click selects the whole line (the game can not write the clipboard itself)
  984     panel.missCopy = UI.Button(mbt, L.btn_miss_copy, 170, 26, function()
  985         if health.missList then
  986             health.missList:SetFocus()
  987             health.missList:HighlightText()
  988         end
```
addon/WoWFA/Panel.lua:986
```
  983     -- 1.0.3: one click selects the whole line (the game can not write the clipboard itself)
  984     panel.missCopy = UI.Button(mbt, L.btn_miss_copy, 170, 26, function()
  985         if health.missList then
  986             health.missList:SetFocus()
  987             health.missList:HighlightText()
  988         end
  989         F.Chat("WoWFA: Ctrl+C copies it. Send it at wowfarsi.ir/report or in the wowfarsi Discord.")
```
addon/WoWFA/Panel.lua:987
```
  984     panel.missCopy = UI.Button(mbt, L.btn_miss_copy, 170, 26, function()
  985         if health.missList then
  986             health.missList:SetFocus()
  987             health.missList:HighlightText()
  988         end
  989         F.Chat("WoWFA: Ctrl+C copies it. Send it at wowfarsi.ir/report or in the wowfarsi Discord.")
  990     end)
```
tests/run.lua:625
```
  622     F.OpenPanel("health")
  623     RunTimers()
  624     local PF = F.PanelFrame()
  625     local box = PF and PF.health and PF.health.missList
  626     local txt = box and box:GetText() or ""
  627     check("status page lists the misses", txt:find("misses=1", 1, true) ~= nil and txt:find("A totally unknown line 5.", 1, true) ~= nil, txt)
  628     F:Miss("zone", "some new zone", "Some New Zone|x")
```
- ok: missList: 7 hits

### h_miss_n

addon/WoWFA/Locale.lua:160
```
  157 L.h_noerr = "خطایی ثبت نشده."
  158 L.btn_recheck = "بررسی دوباره"
  159 L.btn_clear = "پاک کردن خطاها"
  160 L.h_miss_n = "متن‌های بدون ترجمه که دیدی: %d؛ روی کادر کلیک کن، Ctrl+C و برام بفرست"
  161 L.sec_general = "عمومی"
  162 L.sec_quests = "مأموریت‌ها"
  163 L.sec_tracker = "ردیاب مأموریت"
```
addon/WoWFA/Panel.lua:244
```
  241             out[#out + 1] = string.format("%s :: %s :: %s :: x%d", tostring(e.k), t, tostring(e.c or ""), tonumber(e.n) or 1)
  242         end
  243         health.missList:SetFixed(table.concat(out, " ;; "))
  244         health.missHead:SetFa(string.format(L.h_miss_n, #list), PW - 30)
  245     end
  246 end
  247 
```
addon/WoWFA/Panel.lua:944
```
  941     mh:SetSize(PW - 16, 40)
  942     health.missHead = UI.Text(mh, 12, C.muted)
  943     health.missHead:SetPoint("TOPRIGHT", mh, "TOPRIGHT", -4, 0)
  944     health.missHead:SetFa(string.format(L.h_miss_n, 0), PW - 30)
  945     place(mh, 40, 2)
  946     local ml = CreateFrame("Frame", nil, page.child)
  947     ml:SetSize(PW - 16, 24)
```
- ok: h_miss_n: 3 hits

### rp_d

addon/WoWFA/Locale_Opt.lua:46
```
   43 L.pf_none = fa("هنوز پروفایلی نساخته~ای. یک اسم بنویس و «ذخیرهٔ پروفایل» را بزن.")
   44 
   45 L.rp_hdr = fa("گزارش برای ما: چیزهایی که هنوز فارسی نیستند")
   46 L.rp_d = fa("خط پایین هر چیزی است که افزونه در بازی دید و فارسی~اش را نداشت (هشدار، اسم NPC، منطقه و...). «انتخاب برای کپی» را بزن، بعد Ctrl+C، و متن را در سایت
   47 L.btn_miss_copy = fa("انتخاب برای کپی")
   48 
   49 L.ALERTS = L.ALERTS or {}
```
addon/WoWFA/Panel.lua:937
```
  934     place(el, 90, 4)
  935     -- 1.0.3 (the owner: tell the player what the line below is and where to send it)
  936     header(L.rp_hdr)
  937     note(L.rp_d)
  938     -- rc3 update watch: what the live game showed that the data could not
  939     -- translate (Core F:Miss). One read-only line; click = select all.
  940     local mh = CreateFrame("Frame", nil, page.child)
```
- ok: rp_d: 2 hits

### btn_miss_copy

addon/WoWFA/Locale_Opt.lua:47
```
   44 
   45 L.rp_hdr = fa("گزارش برای ما: چیزهایی که هنوز فارسی نیستند")
   46 L.rp_d = fa("خط پایین هر چیزی است که افزونه در بازی دید و فارسی~اش را نداشت (هشدار، اسم NPC، منطقه و...). «انتخاب برای کپی» را بزن، بعد Ctrl+C، و متن را در سایت
   47 L.btn_miss_copy = fa("انتخاب برای کپی")
   48 
   49 L.ALERTS = L.ALERTS or {}
   50 L.ALERTS[#L.ALERTS + 1] = { "Internal mail database error.", fa("خطای داخلی پایگاه دادهٔ نامه~ها.") }
```
addon/WoWFA/Panel.lua:984
```
  981     end)
  982     panel.missClear:SetPoint("RIGHT", mbt, "RIGHT", -4, 0)
  983     -- 1.0.3: one click selects the whole line (the game can not write the clipboard itself)
  984     panel.missCopy = UI.Button(mbt, L.btn_miss_copy, 170, 26, function()
  985         if health.missList then
  986             health.missList:SetFocus()
  987             health.missList:HighlightText()
```
- ok: btn_miss_copy: 2 hits
