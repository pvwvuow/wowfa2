## task 0367-grep-addline (script)

**GREEN**


### AddLine

addon/WoWFA/Text.lua:881
```
  878         seen[text] = true
  879     end
  880     for _, ln in ipairs(T.Lines(text, wrap, size, mode)) do
  881         tt:AddLine(ln, color[1], color[2], color[3], mode ~= 3)
  882         style(tt, "Left")
  883     end
  884 end
```
tests/lua/wow_mock.lua:222
```
  219 function Obj.GetRight() return 500 end
  220 function Obj.SetScrollChild(s, c) s._child = c end
  221 function Obj.NumLines(s) return s._n or 0 end
  222 function Obj.AddLine(s, text)
  223     s._n = (s._n or 0) + 1
  224     local l = _G[s._name .. "TextLeft" .. s._n] or new("FontString", s._name .. "TextLeft" .. s._n)
  225     l._text = text
```
tests/lua/wow_mock.lua:229
```
  226     local r = _G[s._name .. "TextRight" .. s._n] or new("FontString", s._name .. "TextRight" .. s._n)
  227     r._text = nil
  228 end
  229 function Obj.AddDoubleLine(s, a, b) s:AddLine(a); _G[s._name .. "TextRight" .. s._n]._text = b end
  230 function Obj.ClearLines(s) s._n = 0; if s._scripts.OnTooltipCleared then s._scripts.OnTooltipCleared(s) end end
  231 function Obj.SetOwner(s) s:ClearLines() end
  232 function Obj.GetItem(s) return s._itemName, s._itemLink end
```
tests/lua/wow_mock.lua:265
```
  262     s:ClearLines()
  263     local rec = MOCK.spellDesc and MOCK.spellDesc[id]
  264     if rec then
  265         s:AddLine(rec[1])
  266         for i = 2, #rec do s:AddLine(rec[i]) end
  267     end
  268 end
```
tests/lua/wow_mock.lua:266
```
  263     local rec = MOCK.spellDesc and MOCK.spellDesc[id]
  264     if rec then
  265         s:AddLine(rec[1])
  266         for i = 2, #rec do s:AddLine(rec[i]) end
  267     end
  268 end
  269 function GameTooltip.SetSpell(s, id) return GameTooltip.SetSpellByID(s, id) end
```
tests/run.lua:144
```
  141 check("templates + spell names shipped", tkey ~= nil and skey ~= nil)
  142 local live = tkey:gsub("#", "7")
  143 GameTooltip:ClearLines()
  144 GameTooltip:AddLine(skey)
  145 GameTooltip:AddLine(live)
  146 RunTip("Spell", GameTooltip, nil)
  147 local lines = GameTooltip:TipLines()
```
tests/run.lua:145
```
  142 local live = tkey:gsub("#", "7")
  143 GameTooltip:ClearLines()
  144 GameTooltip:AddLine(skey)
  145 GameTooltip:AddLine(live)
  146 RunTip("Spell", GameTooltip, nil)
  147 local lines = GameTooltip:TipLines()
  148 local anyFa = false
```
tests/run.lua:158
```
  155 -- rc4: the client writes "she" for a female character; the data is keyed "he"
  156 D.tpl["zz test he will be dazed for # sec"] = "{0} ثانیه گیج"
  157 GameTooltip:ClearLines()
  158 GameTooltip:AddLine(skey)
  159 GameTooltip:AddLine("Zz test she will be dizzy for 4 sec.")
  160 RunTip("Spell", GameTooltip, nil)
  161 local nCtl = #GameTooltip:TipLines() -- control: no template for this line
```
tests/run.lua:159
```
  156 D.tpl["zz test he will be dazed for # sec"] = "{0} ثانیه گیج"
  157 GameTooltip:ClearLines()
  158 GameTooltip:AddLine(skey)
  159 GameTooltip:AddLine("Zz test she will be dizzy for 4 sec.")
  160 RunTip("Spell", GameTooltip, nil)
  161 local nCtl = #GameTooltip:TipLines() -- control: no template for this line
  162 GameTooltip:ClearLines()
```
tests/run.lua:163
```
  160 RunTip("Spell", GameTooltip, nil)
  161 local nCtl = #GameTooltip:TipLines() -- control: no template for this line
  162 GameTooltip:ClearLines()
  163 GameTooltip:AddLine(skey)
  164 GameTooltip:AddLine("Zz test she will be dazed for 4 sec.")
  165 RunTip("Spell", GameTooltip, nil)
  166 local nG = #GameTooltip:TipLines()
```
tests/run.lua:164
```
  161 local nCtl = #GameTooltip:TipLines() -- control: no template for this line
  162 GameTooltip:ClearLines()
  163 GameTooltip:AddLine(skey)
  164 GameTooltip:AddLine("Zz test she will be dazed for 4 sec.")
  165 RunTip("Spell", GameTooltip, nil)
  166 local nG = #GameTooltip:TipLines()
  167 check("female-text tooltip matches the male-keyed template", nG == nCtl + 1, nG .. " vs control " .. nCtl)
```
tests/run.lua:172
```
  169 -- rc4: a plain GameTooltip (no Spell data: the Forever talent frame) translates too
  170 GameTooltip:Hide()
  171 GameTooltip:ClearLines()
  172 GameTooltip:AddLine(skey)
  173 GameTooltip:AddLine(live)
  174 GameTooltip:Show()
  175 local pl = GameTooltip:TipLines()
```
tests/run.lua:173
```
  170 GameTooltip:Hide()
  171 GameTooltip:ClearLines()
  172 GameTooltip:AddLine(skey)
  173 GameTooltip:AddLine(live)
  174 GameTooltip:Show()
  175 local pl = GameTooltip:TipLines()
  176 local plFa = false
```
tests/run.lua:193
```
  190     F:ClearMiss()
  191     GameTooltip:Hide()
  192     GameTooltip:ClearLines()
  193     GameTooltip:AddLine("Zz Not A Known Spell")
  194     GameTooltip:AddLine("این یک خط فارسی کاملاً بلند است که خودِ افزونه نوشته است")
  195     RunTip("Spell", GameTooltip, nil)
  196     local n = 0
```
tests/run.lua:194
```
  191     GameTooltip:Hide()
  192     GameTooltip:ClearLines()
  193     GameTooltip:AddLine("Zz Not A Known Spell")
  194     GameTooltip:AddLine("این یک خط فارسی کاملاً بلند است که خودِ افزونه نوشته است")
  195     RunTip("Spell", GameTooltip, nil)
  196     local n = 0
  197     for _, e in pairs(F.db.miss or {}) do
```
tests/run.lua:204
```
  201     end
  202     check("own Persian line is never logged as a miss", n == 0, n)
  203     GameTooltip:ClearLines()
  204     GameTooltip:AddLine("Zz Not A Known Spell Two")
  205     GameTooltip:AddLine("This is a long English description line that has no translation yet.")
  206     RunTip("Spell", GameTooltip, nil)
  207     n = 0
```
tests/run.lua:205
```
  202     check("own Persian line is never logged as a miss", n == 0, n)
  203     GameTooltip:ClearLines()
  204     GameTooltip:AddLine("Zz Not A Known Spell Two")
  205     GameTooltip:AddLine("This is a long English description line that has no translation yet.")
  206     RunTip("Spell", GameTooltip, nil)
  207     n = 0
  208     for _, e in pairs(F.db.miss or {}) do
```
tests/run.lua:229
```
  226         end
  227         GameTooltip:Hide()
  228         GameTooltip:ClearLines()
  229         GameTooltip:AddLine(tk)
  230         GameTooltip:Show()
  231         local ls = GameTooltip:TipLines()
  232         check("spec tab tooltip gets the Persian tree name", #ls == 2 and non_ascii(ls[2]), table.concat(ls, " / "))
```
tests/run.lua:238
```
  235         end
  236         GameTooltip:Hide()
  237         GameTooltip:ClearLines()
  238         GameTooltip:AddLine(tk)
  239         GameTooltip:Show()
  240         check("the same name outside spell/talent frames stays untouched", #GameTooltip:TipLines() == 1, #GameTooltip:TipLines())
  241         GameTooltip.GetOwner = saved
```
tests/run.lua:261
```
  258     F:ClearMiss()
  259     GameTooltip:Hide()
  260     GameTooltip:ClearLines()
  261     GameTooltip:AddLine(skey)
  262     GameTooltip:AddLine("Zz test header:\r\nZzCloth\r\nZzUnknownWord")
  263     RunTip("Spell", GameTooltip, nil)
  264     local base = #GameTooltip:TipLines()
```
tests/run.lua:262
```
  259     GameTooltip:Hide()
  260     GameTooltip:ClearLines()
  261     GameTooltip:AddLine(skey)
  262     GameTooltip:AddLine("Zz test header:\r\nZzCloth\r\nZzUnknownWord")
  263     RunTip("Spell", GameTooltip, nil)
  264     local base = #GameTooltip:TipLines()
  265     check("a list with an unknown word stays English (no list lines added)", base >= 2 and base <= 3, base)
```
tests/run.lua:268
```
  265     check("a list with an unknown word stays English (no list lines added)", base >= 2 and base <= 3, base)
  266     GameTooltip:Hide()
  267     GameTooltip:ClearLines()
  268     GameTooltip:AddLine(skey)
  269     GameTooltip:AddLine("Zz test header:\r\nZzCloth\r\nZzLeather")
  270     RunTip("Spell", GameTooltip, nil)
  271     local ls = GameTooltip:TipLines()
```
tests/run.lua:269
```
  266     GameTooltip:Hide()
  267     GameTooltip:ClearLines()
  268     GameTooltip:AddLine(skey)
  269     GameTooltip:AddLine("Zz test header:\r\nZzCloth\r\nZzLeather")
  270     RunTip("Spell", GameTooltip, nil)
  271     local ls = GameTooltip:TipLines()
  272     check("a known list line gets Persian header + 2 words", #ls == base + 3 and non_ascii(ls[#ls]) and non_ascii(ls[#ls - 2]),
```
tests/run.lua:306
```
  303     local function tip()
  304         GameTooltip:Hide()
  305         GameTooltip:ClearLines()
  306         GameTooltip:AddLine(skey)
  307         GameTooltip:AddLine(live)
  308         RunTip("Spell", GameTooltip, nil)
  309         return GameTooltip:TipLines()
```
tests/run.lua:307
```
  304         GameTooltip:Hide()
  305         GameTooltip:ClearLines()
  306         GameTooltip:AddLine(skey)
  307         GameTooltip:AddLine(live)
  308         RunTip("Spell", GameTooltip, nil)
  309         return GameTooltip:TipLines()
  310     end
```
- ok: AddLine: 25 hits

### AddDoubleLine

addon/WoWFA/Minimap.lua:46
```
   43     -- inbox/29 D: the minimap button tooltip is ONE status line (plus the
   44     -- title) - the full health page lives in the panel's وضعیت tab
   45     GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
   46     GameTooltip:AddDoubleLine("WoWFA", "v" .. F.VERSION, C.gold[1], C.gold[2], C.gold[3], C.muted[1], C.muted[2], C.muted[3])
   47     local line
   48     if not F.db.enabled then
   49         line = L.st_master
```
addon/WoWFA/Text.lua:890
```
  887 function T.TipPair(tt, first, second, color)
  888     color = color or F.C.text
  889     local mode = T.Mode()
  890     tt:AddDoubleLine(T.ShapeLine(T.Clean(second), mode), T.ShapeLine(T.Clean(first), mode), color[1], color[2], color[3], color[1], color[2], color[3])
  891     style(tt, "Left")
  892     style(tt, "Right")
  893 end
```
tests/lua/wow_mock.lua:229
```
  226     local r = _G[s._name .. "TextRight" .. s._n] or new("FontString", s._name .. "TextRight" .. s._n)
  227     r._text = nil
  228 end
  229 function Obj.AddDoubleLine(s, a, b) s:AddLine(a); _G[s._name .. "TextRight" .. s._n]._text = b end
  230 function Obj.ClearLines(s) s._n = 0; if s._scripts.OnTooltipCleared then s._scripts.OnTooltipCleared(s) end end
  231 function Obj.SetOwner(s) s:ClearLines() end
  232 function Obj.GetItem(s) return s._itemName, s._itemLink end
```
- ok: AddDoubleLine: 3 hits

### TextLeft

addon/WoWFA/Dump.lua:112
```
  109     end
  110     local n = call(tt.NumLines, tt) or 0
  111     for i = 1, n do
  112         local l = _G["WoWFAF_ScanTipTextLeft" .. i]
  113         local r = _G["WoWFAF_ScanTipTextRight" .. i]
  114         local lt = l and call(l.GetText, l)
  115         local rt = r and call(r.IsShown, r) and call(r.GetText, r)
```
addon/WoWFA/Modules/Npc.lua:146
```
  143     if not T.Once(tt, "n|" .. tostring(name)) then
  144         return
  145     end
  146     local fs = _G[(tt:GetName() or "GameTooltip") .. "TextLeft1"]
  147     if type(fs) ~= "table" or not fs.GetText then
  148         return
  149     end
```
addon/WoWFA/Modules/Questie.lua:103
```
  100     end
  101     local lines, pin = {}, false
  102     for i = 1, math.min(n, 40) do
  103         local l, r = _G[name .. "TextLeft" .. i], _G[name .. "TextRight" .. i]
  104         local okl, lt = pcall(function() return l and l:GetText() end)
  105         local okr, rt = pcall(function() return r and r:GetText() end)
  106         lt = (okl and F.Usable(lt) and type(lt) == "string") and lt or nil
```
addon/WoWFA/Modules/Spells.lua:32
```
   29         return out
   30     end
   31     for i = 1, tt:NumLines() do
   32         local fs = _G[name .. "TextLeft" .. i]
   33         local t = fs and fs:GetText()
   34         out[#out + 1] = (F.Usable(t) and t) or ""
   35     end
```
addon/WoWFA/Modules/Spells.lua:142
```
  139     end
  140     local want = plain(expect)
  141     local function try(k)
  142         local fs = _G[name .. "TextLeft" .. k]
  143         if fs and fs.GetText then
  144             local ok, t = pcall(fs.GetText, fs)
  145             if ok and F.Usable(t) and type(t) == "string" and plain(t) == want then
```
addon/WoWFA/Modules/Spells.lua:472
```
  469         return
  470     end
  471     local tname = tt.GetName and tt:GetName()
  472     local fs = tname and _G[tname .. "TextLeft1"]
  473     local first = fs and fs:GetText()
  474     if not F.Usable(first) or type(first) ~= "string" or first == "" then
  475         return
```
addon/WoWFA/Modules/Taxi.lua:62
```
   59         return
   60     end
   61     local name = tt.GetName and tt:GetName()
   62     local fs = name and _G[name .. "TextLeft1"]
   63     if not fs then
   64         return
   65     end
```
tests/lua/wow_mock.lua:224
```
  221 function Obj.NumLines(s) return s._n or 0 end
  222 function Obj.AddLine(s, text)
  223     s._n = (s._n or 0) + 1
  224     local l = _G[s._name .. "TextLeft" .. s._n] or new("FontString", s._name .. "TextLeft" .. s._n)
  225     l._text = text
  226     local r = _G[s._name .. "TextRight" .. s._n] or new("FontString", s._name .. "TextRight" .. s._n)
  227     r._text = nil
```
tests/lua/wow_mock.lua:237
```
  234 function Obj.TipLines(s)
  235     local out = {}
  236     for i = 1, s._n or 0 do
  237         local l, r = _G[s._name .. "TextLeft" .. i], _G[s._name .. "TextRight" .. i]
  238         out[#out + 1] = tostring(l._text) .. (r._text and ("  ||  " .. r._text) or "") .. ((l._font or ""):find("Vazir") and "  [fa-font]" or "")
  239     end
  240     return out
```
- ok: TextLeft: 9 hits

### TextRight

addon/WoWFA/Dump.lua:113
```
  110     local n = call(tt.NumLines, tt) or 0
  111     for i = 1, n do
  112         local l = _G["WoWFAF_ScanTipTextLeft" .. i]
  113         local r = _G["WoWFAF_ScanTipTextRight" .. i]
  114         local lt = l and call(l.GetText, l)
  115         local rt = r and call(r.IsShown, r) and call(r.GetText, r)
  116         if type(lt) == "string" then
```
addon/WoWFA/Modules/Questie.lua:103
```
  100     end
  101     local lines, pin = {}, false
  102     for i = 1, math.min(n, 40) do
  103         local l, r = _G[name .. "TextLeft" .. i], _G[name .. "TextRight" .. i]
  104         local okl, lt = pcall(function() return l and l:GetText() end)
  105         local okr, rt = pcall(function() return r and r:GetText() end)
  106         lt = (okl and F.Usable(lt) and type(lt) == "string") and lt or nil
```
tests/lua/wow_mock.lua:226
```
  223     s._n = (s._n or 0) + 1
  224     local l = _G[s._name .. "TextLeft" .. s._n] or new("FontString", s._name .. "TextLeft" .. s._n)
  225     l._text = text
  226     local r = _G[s._name .. "TextRight" .. s._n] or new("FontString", s._name .. "TextRight" .. s._n)
  227     r._text = nil
  228 end
  229 function Obj.AddDoubleLine(s, a, b) s:AddLine(a); _G[s._name .. "TextRight" .. s._n]._text = b end
```
tests/lua/wow_mock.lua:229
```
  226     local r = _G[s._name .. "TextRight" .. s._n] or new("FontString", s._name .. "TextRight" .. s._n)
  227     r._text = nil
  228 end
  229 function Obj.AddDoubleLine(s, a, b) s:AddLine(a); _G[s._name .. "TextRight" .. s._n]._text = b end
  230 function Obj.ClearLines(s) s._n = 0; if s._scripts.OnTooltipCleared then s._scripts.OnTooltipCleared(s) end end
  231 function Obj.SetOwner(s) s:ClearLines() end
  232 function Obj.GetItem(s) return s._itemName, s._itemLink end
```
tests/lua/wow_mock.lua:237
```
  234 function Obj.TipLines(s)
  235     local out = {}
  236     for i = 1, s._n or 0 do
  237         local l, r = _G[s._name .. "TextLeft" .. i], _G[s._name .. "TextRight" .. i]
  238         out[#out + 1] = tostring(l._text) .. (r._text and ("  ||  " .. r._text) or "") .. ((l._font or ""):find("Vazir") and "  [fa-font]" or "")
  239     end
  240     return out
```
- ok: TextRight: 5 hits

### NumLines

addon/WoWFA/Dump.lua:110
```
  107     if not pcall(tt.SetSpellByID, tt, id) then
  108         return out
  109     end
  110     local n = call(tt.NumLines, tt) or 0
  111     for i = 1, n do
  112         local l = _G["WoWFAF_ScanTipTextLeft" .. i]
  113         local r = _G["WoWFAF_ScanTipTextRight" .. i]
```
addon/WoWFA/Modules/Questie.lua:97
```
   94     if type(name) ~= "string" then
   95         return false
   96     end
   97     local okn, n = pcall(tt.NumLines, tt)
   98     if not okn or not F.Usable(n) or type(n) ~= "number" or n < 1 then
   99         return false
  100     end
```
addon/WoWFA/Modules/Spells.lua:31
```
   28     if not name then
   29         return out
   30     end
   31     for i = 1, tt:NumLines() do
   32         local fs = _G[name .. "TextLeft" .. i]
   33         local t = fs and fs:GetText()
   34         out[#out + 1] = (F.Usable(t) and t) or ""
```
addon/WoWFA/Modules/Spells.lua:155
```
  152     if fs then
  153         return fs
  154     end
  155     local n = (tt.NumLines and tt:NumLines()) or 0
  156     for k = 1, n do
  157         fs = try(k)
  158         if fs then
```
addon/WoWFA/Text.lua:485
```
  482 
  483 -- Brain 59 (the owner's r7 debug report: "Text.lua:495: attempt to perform
  484 -- boolean test on a secret boolean value (execution tainted by 'WoWFA')"):
  485 -- on this client a tooltip font string can answer IsTruncated / GetNumLines
  486 -- with a SECRET value, and a boolean test or a comparison on it is an error.
  487 -- Every such read goes through here: pcall + the secret check; anything we
  488 -- can not read safely counts as "the client did not re-wrap".
```
addon/WoWFA/Text.lua:495
```
  492         if F.Usable(tr) and tr == true then
  493             return true
  494         end
  495         local nl = fs.GetNumLines and fs:GetNumLines()
  496         if F.Usable(nl) and type(nl) == "number" and nl > n then
  497             return true
  498         end
```
addon/WoWFA/Text.lua:740
```
  737         local tries = 0
  738         -- two ways the client can disagree with our pre-wrap:
  739         --   IsTruncated  - a line was cut (should not happen with wrap on)
  740         --   GetNumLines > produced - the client RE-wrapped a line that was
  741         --   wider than the string (that scrambles our manual RTL order)
  742         -- Brain 59: both read through rewrapped() (secret-safe)
  743         while tries < 4 and rewrapped(fs, #lines) do
```
addon/WoWFA/Text.lua:828
```
  825 -- true when this content was not added to this tooltip yet
  826 function T.Once(tt, key)
  827     hook_tooltip(tt)
  828     if tt.wfaKey == key and tt.wfaLines and tt:NumLines() >= tt.wfaLines then
  829         return false
  830     end
  831     tt.wfaKey = key
```
addon/WoWFA/Text.lua:836
```
  833 end
  834 
  835 function T.Done(tt)
  836     tt.wfaLines = tt:NumLines()
  837 end
  838 
  839 local function style(tt, side)
```
addon/WoWFA/Text.lua:845
```
  842     if not name then
  843         return
  844     end
  845     local fs = _G[name .. "Text" .. side .. tt:NumLines()]
  846     if not fs then
  847         return
  848     end
```
addon/WoWFA/Text.lua:1017
```
 1014     if not name then
 1015         return parts
 1016     end
 1017     for i = 1, tt:NumLines() do
 1018         for _, side in ipairs({ "Left", "Right" }) do
 1019             local fs = _G[name .. "Text" .. side .. i]
 1020             local t = fs and fs:GetText()
```
tests/lua/wow_mock.lua:103
```
  100 -- the string's fixed width RE-wraps (scrambling a manual RTL order).
  101 function Obj.SetWordWrap(s, v) s._wrap = v end
  102 function Obj.SetNonSpaceWrap(s, v) s._nsw = v end
  103 function Obj.GetNumLines(s)
  104     local t = tostring(s._text or "")
  105     if s._wrap == false then
  106         return 1
```
tests/lua/wow_mock.lua:221
```
  218 function Obj.GetPoint() return "CENTER", nil, "CENTER", 10, 20 end
  219 function Obj.GetRight() return 500 end
  220 function Obj.SetScrollChild(s, c) s._child = c end
  221 function Obj.NumLines(s) return s._n or 0 end
  222 function Obj.AddLine(s, text)
  223     s._n = (s._n or 0) + 1
  224     local l = _G[s._name .. "TextLeft" .. s._n] or new("FontString", s._name .. "TextLeft" .. s._n)
```
tests/run.lua:427
```
  424     GameTooltip:Hide()
  425     GameTooltip:ClearLines()
  426     T.TipLine(GameTooltip, "A fairly long description line for the tooltip", F.C.text)
  427     local n1 = GameTooltip:NumLines()
  428     T.TipLine(GameTooltip, "A fairly long description line for the tooltip", F.C.text)
  429     check("the same long line is not added twice", GameTooltip:NumLines() == n1, n1 .. " vs " .. GameTooltip:NumLines())
  430     GameTooltip:Hide()
```
tests/run.lua:429
```
  426     T.TipLine(GameTooltip, "A fairly long description line for the tooltip", F.C.text)
  427     local n1 = GameTooltip:NumLines()
  428     T.TipLine(GameTooltip, "A fairly long description line for the tooltip", F.C.text)
  429     check("the same long line is not added twice", GameTooltip:NumLines() == n1, n1 .. " vs " .. GameTooltip:NumLines())
  430     GameTooltip:Hide()
  431 end)
  432 check("rc9 tests ran", okRc9, errRc9)
```
- ok: NumLines: 15 hits

### SetAction

- ok: SetAction: 0 hits

### .action

- ok: .action: 0 hits
