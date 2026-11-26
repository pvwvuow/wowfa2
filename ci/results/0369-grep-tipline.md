## task 0369-grep-tipline (script)

**GREEN**


### local function hook_tooltip

addon/WoWFA/Text.lua:816
```
  771 
  772 -- ---------------------------------------------------------------- tooltip
  773 -- Lines we add get our font; the line objects are reused by the next tooltip,
  774 -- so the original font is restored when the tooltip is cleared.
  775 -- inbox/29 C: the line spacing (line gap) of every multi-line Persian string
  776 -- we set: floor(size * 0.45 + 0.5) (inbox/44 D, was 0.55). Recorded and restored on clear like the
  777 -- font (restore() below), so a reused tooltip string comes out 100% vanilla.
  778 function T.Spacing(size)
  779     -- inbox/44 D: 0.45 of the size (was 0.55) - the Vazirmatn small sizes
  780     -- read better with the tighter leading
  781     return math.floor((size or T.Size()) * 0.45 + 0.5)
  782 end
  783 
  784 local function restore(tt)
  785     local list = tt.wfaFonts
  786     if list then
  787         for i = #list, 1, -1 do
  788             local r = list[i]
  789             -- inbox/27 in-place records also carry the original TEXT and the
  790             -- original font OBJECT: a spell / unit tooltip that reuses the same
  791             -- font string must look 100% vanilla after the clear.
  792             if r.text ~= nil then
  793                 pcall(r.fs.SetText, r.fs, r.text)
  794             end
  795             if r.font then
  796                 pcall(r.fs.SetFont, r.fs, r.font, r.size, r.flags or "")
  797             end
  798             if r.fobj then
  799                 pcall(r.fs.SetFontObject, r.fs, r.fobj)
  800             end
  801             if r.justify then
  802                 pcall(r.fs.SetJustifyH, r.fs, r.justify)
  803             end
  804             if r.spacing then
  805                 pcall(r.fs.SetSpacing, r.fs, r.spacing)
  806             end
  807             list[i] = nil
  808         end
  809     end
  810     tt.wfaSeen = nil
  811     tt.wfaKey = nil
  812     tt.wfaOurs = nil -- Brain 59: the post-layout re-wrap records (T.TipRecheck)
  813     tt.wfaAdded = nil -- rc9: the lines TipLine added
  814 end
  815 
  816 local function hook_tooltip(tt)
  817     if tt.wfaHooked or not tt.HookScript then
  818         return
  819     end
  820     tt.wfaHooked = true
  821     pcall(tt.HookScript, tt, "OnTooltipCleared", restore)
  822     pcall(tt.HookScript, tt, "OnHide", restore)
  823 end
  824 
  825 -- true when this content was not added to this tooltip yet
  826 function T.Once(tt, key)
  827     hook_tooltip(tt)
  828     if tt.wfaKey == key and tt.wfaLines and tt:NumLines() >= tt.wfaLines then
  829         return false
  830     end
  831     tt.wfaKey = key
  832     return true
  833 end
  834 
  835 function T.Done(tt)
  836     tt.wfaLines = tt:NumLines()
  837 end
  838 
  839 local function style(tt, side)
  840     hook_tooltip(tt)
  841     local name = tt:GetName()
  842     if not name then
  843         return
  844     end
  845     local fs = _G[name .. "Text" .. side .. tt:NumLines()]
  846     if not fs then
  847         return
  848     end
  849     tt.wfaFonts = tt.wfaFonts or {}
  850     local font, size, flags = F.GameFontTriple(fs)
  851     table.insert(tt.wfaFonts, { fs = fs, font = font, size = size, flags = flags, justify = fs:GetJustifyH(), spacing = fs.GetSpacing and fs:GetSpacing() or nil
  852     fs:SetFont(F.FONT, T.Size(), F.Flags())
  853     -- inbox/29 C: the same line gap on the spell/talent (TipLine) strings
  854     fs:SetSpacing(T.Spacing(T.Size()))
  855     if side == "Left" then
  856         fs:SetJustifyH("RIGHT")
  857     end
  858 end
  859 
  860 function T.TipLine(tt, text, color, wrapWidth)
  861     color = color or F.C.text
```
- ok: local function hook_tooltip: 1 hits

### function T.TipLine

addon/WoWFA/Text.lua:860
```
  815 
  816 local function hook_tooltip(tt)
  817     if tt.wfaHooked or not tt.HookScript then
  818         return
  819     end
  820     tt.wfaHooked = true
  821     pcall(tt.HookScript, tt, "OnTooltipCleared", restore)
  822     pcall(tt.HookScript, tt, "OnHide", restore)
  823 end
  824 
  825 -- true when this content was not added to this tooltip yet
  826 function T.Once(tt, key)
  827     hook_tooltip(tt)
  828     if tt.wfaKey == key and tt.wfaLines and tt:NumLines() >= tt.wfaLines then
  829         return false
  830     end
  831     tt.wfaKey = key
  832     return true
  833 end
  834 
  835 function T.Done(tt)
  836     tt.wfaLines = tt:NumLines()
  837 end
  838 
  839 local function style(tt, side)
  840     hook_tooltip(tt)
  841     local name = tt:GetName()
  842     if not name then
  843         return
  844     end
  845     local fs = _G[name .. "Text" .. side .. tt:NumLines()]
  846     if not fs then
  847         return
  848     end
  849     tt.wfaFonts = tt.wfaFonts or {}
  850     local font, size, flags = F.GameFontTriple(fs)
  851     table.insert(tt.wfaFonts, { fs = fs, font = font, size = size, flags = flags, justify = fs:GetJustifyH(), spacing = fs.GetSpacing and fs:GetSpacing() or nil
  852     fs:SetFont(F.FONT, T.Size(), F.Flags())
  853     -- inbox/29 C: the same line gap on the spell/talent (TipLine) strings
  854     fs:SetSpacing(T.Spacing(T.Size()))
  855     if side == "Left" then
  856         fs:SetJustifyH("RIGHT")
  857     end
  858 end
  859 
  860 function T.TipLine(tt, text, color, wrapWidth)
  861     color = color or F.C.text
  862     local mode = T.Mode()
  863     local size = T.Size()
  864     -- lane-b12: tooltips keep size*22 as the width, but with the same 94%
  865     -- safety margin so the shaped lines never come out wider than the line
  866     local wrap = (wrapWidth or (size * 22)) * 0.94
  867     -- rc9: the same long line is never added twice to one tooltip content (the
  868     -- owner saw talent descriptions twice in Persian); reset when the tooltip clears
  869     local seen = tt.wfaAdded
  870     if not seen then
  871         seen = {}
  872         tt.wfaAdded = seen
  873     end
  874     if #text >= 14 then
  875         if seen[text] then
  876             return
  877         end
  878         seen[text] = true
  879     end
  880     for _, ln in ipairs(T.Lines(text, wrap, size, mode)) do
  881         tt:AddLine(ln, color[1], color[2], color[3], mode ~= 3)
  882         style(tt, "Left")
  883     end
  884 end
  885 
  886 -- "left\tright" pairs: Persian reads right to left, so the first part goes right
  887 function T.TipPair(tt, first, second, color)
  888     color = color or F.C.text
  889     local mode = T.Mode()
  890     tt:AddDoubleLine(T.ShapeLine(T.Clean(second), mode), T.ShapeLine(T.Clean(first), mode), color[1], color[2], color[3], color[1], color[2], color[3])
  891     style(tt, "Left")
  892     style(tt, "Right")
  893 end
  894 
  895 -- inbox/27 (0.6.0): IN-PLACE tooltip replacement - rewrite an EXISTING tooltip
  896 -- font string with Persian text instead of adding lines under it. The touched
  897 -- font string keeps its live colour (never re-coloured) and its original
  898 -- text / font object / font file+size+flags / justify are recorded ONCE and
  899 -- restored by the shared OnTooltipCleared/OnHide restore above. Font-string
  900 -- text only - no frame creation (the restore list is plain tables).
  901 --   width = the wrap width for T.Lines (mode 3 pre-wraps, modes 1/2 shape per
  902 --   paragraph); side "Left" strings justify RIGHT (Persian reads right-to-left,
  903 --   same rule as the additive lines in style()).
  904 function T.TipSet(tt, fs, text, width, side, fam)
  905     hook_tooltip(tt)
```
- ok: function T.TipLine: 1 hits

### function T.Once

addon/WoWFA/Text.lua:826
```
  781     return math.floor((size or T.Size()) * 0.45 + 0.5)
  782 end
  783 
  784 local function restore(tt)
  785     local list = tt.wfaFonts
  786     if list then
  787         for i = #list, 1, -1 do
  788             local r = list[i]
  789             -- inbox/27 in-place records also carry the original TEXT and the
  790             -- original font OBJECT: a spell / unit tooltip that reuses the same
  791             -- font string must look 100% vanilla after the clear.
  792             if r.text ~= nil then
  793                 pcall(r.fs.SetText, r.fs, r.text)
  794             end
  795             if r.font then
  796                 pcall(r.fs.SetFont, r.fs, r.font, r.size, r.flags or "")
  797             end
  798             if r.fobj then
  799                 pcall(r.fs.SetFontObject, r.fs, r.fobj)
  800             end
  801             if r.justify then
  802                 pcall(r.fs.SetJustifyH, r.fs, r.justify)
  803             end
  804             if r.spacing then
  805                 pcall(r.fs.SetSpacing, r.fs, r.spacing)
  806             end
  807             list[i] = nil
  808         end
  809     end
  810     tt.wfaSeen = nil
  811     tt.wfaKey = nil
  812     tt.wfaOurs = nil -- Brain 59: the post-layout re-wrap records (T.TipRecheck)
  813     tt.wfaAdded = nil -- rc9: the lines TipLine added
  814 end
  815 
  816 local function hook_tooltip(tt)
  817     if tt.wfaHooked or not tt.HookScript then
  818         return
  819     end
  820     tt.wfaHooked = true
  821     pcall(tt.HookScript, tt, "OnTooltipCleared", restore)
  822     pcall(tt.HookScript, tt, "OnHide", restore)
  823 end
  824 
  825 -- true when this content was not added to this tooltip yet
  826 function T.Once(tt, key)
  827     hook_tooltip(tt)
  828     if tt.wfaKey == key and tt.wfaLines and tt:NumLines() >= tt.wfaLines then
  829         return false
  830     end
  831     tt.wfaKey = key
  832     return true
  833 end
  834 
  835 function T.Done(tt)
  836     tt.wfaLines = tt:NumLines()
  837 end
  838 
  839 local function style(tt, side)
  840     hook_tooltip(tt)
  841     local name = tt:GetName()
  842     if not name then
  843         return
  844     end
  845     local fs = _G[name .. "Text" .. side .. tt:NumLines()]
  846     if not fs then
  847         return
  848     end
  849     tt.wfaFonts = tt.wfaFonts or {}
  850     local font, size, flags = F.GameFontTriple(fs)
  851     table.insert(tt.wfaFonts, { fs = fs, font = font, size = size, flags = flags, justify = fs:GetJustifyH(), spacing = fs.GetSpacing and fs:GetSpacing() or nil
  852     fs:SetFont(F.FONT, T.Size(), F.Flags())
  853     -- inbox/29 C: the same line gap on the spell/talent (TipLine) strings
  854     fs:SetSpacing(T.Spacing(T.Size()))
  855     if side == "Left" then
  856         fs:SetJustifyH("RIGHT")
  857     end
  858 end
  859 
  860 function T.TipLine(tt, text, color, wrapWidth)
  861     color = color or F.C.text
  862     local mode = T.Mode()
  863     local size = T.Size()
  864     -- lane-b12: tooltips keep size*22 as the width, but with the same 94%
  865     -- safety margin so the shaped lines never come out wider than the line
  866     local wrap = (wrapWidth or (size * 22)) * 0.94
  867     -- rc9: the same long line is never added twice to one tooltip content (the
  868     -- owner saw talent descriptions twice in Persian); reset when the tooltip clears
  869     local seen = tt.wfaAdded
  870     if not seen then
  871         seen = {}
```
- ok: function T.Once: 1 hits

### GameTooltip = 

addon/WoWFA/Modules/GameUI.lua:42
```
    1 -- WoWFA Forever - 1.1.6: the game's own windows in Persian (the owner 26 Nov: the game menu,
    2 -- character, bags, spellbook tabs, friends and group, mail, trade, auction house, bank,
    3 -- merchant, trainer, loot, group finder ...).
    4 -- The taint-safe way. Nothing of the game is written or replaced:
    5 --   * NO GlobalStrings variable is ever assigned (secure code reads them; an addon write
    6 --     taints every secure call that reads it). L.GAMEUI (Locale_UI.lua) holds the English
    7 --     text itself, or a GlobalStrings NAME whose English is only READ at run time;
    8 --   * a listed window's OnShow is post-hooked (HookScript); one frame later its text regions
    9 --     are read, and a region whose text IS one of those English strings gets the shaped
   10 --     Persian in our font. That region's SetText / SetFormattedText are post-hooked
   11 --     (hooksecurefunc, the safe way), so the game's next write is swapped too;
   12 --   * protected frames (action buttons, secure buttons) and everything under them are never
   13 --     touched; edit boxes, chat frames, tooltips and models are skipped;
   14 --   * nothing at all runs in combat: the swap waits for the end of the fight;
   15 --   * the windows another module owns (quests, gossip, books, map, talents, the tracker) and
   16 --     the popups (StaticPopup) are not on the list.
   17 -- Only the fontstrings that matched once are hooked, and a hooked write costs one table
   18 -- lookup (CPU). Switch: General > the game's windows (F.db.gameUi, default on); off puts
   19 -- every English text and font back. Not a registered module: pcall everywhere.
   20 
   21 local F = WoWFAF
   22 local L = F.L
   23 local T = F.T
   24 
   25 local FRAMES = {
   26     "GameMenuFrame", "CharacterFrame", "PaperDollFrame", "PetPaperDollFrame", "ReputationFrame",
   27     "SkillFrame", "HonorFrame", "PVPFrame", "TokenFrame", "SpellBookFrame", "FriendsFrame",
   28     "FriendsListFrame", "IgnoreListFrame", "WhoFrame", "GuildFrame", "RaidFrame", "MailFrame",
   29     "InboxFrame", "SendMailFrame", "OpenMailFrame", "TradeFrame", "MerchantFrame", "BankFrame",
   30     "AuctionFrame", "AuctionFrameBrowse", "AuctionFrameBid", "AuctionFrameAuctions",
   31     "AuctionHouseFrame", "ClassTrainerFrame", "LootFrame", "TabardFrame", "GuildRegistrarFrame",
   32     "PetStableFrame", "DressUpFrame", "InspectFrame", "MacroFrame", "TimeManagerFrame",
   33     "LFGParentFrame", "PVEFrame", "GuildBankFrame", "TradeSkillFrame", "CraftFrame",
   34     "BattlefieldFrame", "ArenaFrame", "WorldStateScoreFrame", "ContainerFrameCombinedBags",
   35 }
   36 for i = 1, 13 do
   37     FRAMES[#FRAMES + 1] = "ContainerFrame" .. i
   38 end
   39 
   40 local SKIP_TYPE = {
   41     EditBox = true, ScrollingMessageFrame = true, MessageFrame = true, SimpleHTML = true,
   42     GameTooltip = true, Model = true, PlayerModel = true, DressUpModel = true, CinematicModel = true,
   43     Cooldown = true, Minimap = true, Browser = true, ColorSelect = true,
   44 }
   45 local SCALE = 0.92 -- Vazirmatn is drawn bigger than the game font at the same size (Font.lua)
   46 local MAXN = 3000  -- regions + frames read in one window scan (CPU cap)
   47 
   48 local exact, scoped, pats
   49 local done = setmetatable({}, { __mode = "k" })      -- fontstring -> { en, fa, font, size, flags }
   50 local hooked = setmetatable({}, { __mode = "k" })    -- fontstring -> scope (window name) or true
   51 local pendingFs = setmetatable({}, { __mode = "k" }) -- written in combat: swapped after it
   52 local pendingAll = false
   53 local attached, queued = {}, {}
   54 local busy = false -- our own SetText is running (the hooks must not re-enter)
   55 
   56 local function on()
   57     local db = F.db
   58     return db and db.enabled and db.gameUi ~= false and true or false
   59 end
   60 
   61 local function combat()
   62     return InCombatLockdown and InCombatLockdown() and true or false
   63 end
   64 
   65 local function letters(s)
   66     local lit = string.gsub(s, "%%%d?%$?[sd]", "")
   67     lit = string.gsub(lit, "[%s%p%d]", "")
   68     return #lit
   69 end
   70 
   71 -- the English of every row: a plain text -> exact[en]; one with %s / %d -> a pattern
   72 -- (%s -> (.-), %d -> (%d+)); the Persian takes the values as {1} {2} in their English order
   73 local function build()
   74     exact, scoped, pats = {}, {}, {}
   75     for _, e in ipairs(L.GAMEUI or {}) do
   76         local en, fa, scope = e[1], e[2], e[3]
   77         if type(en) == "string" and string.find(en, "^[%u%d_]+$") then
   78             en = _G[en] -- a GlobalStrings NAME: read only, never written
   79         end
   80         if type(en) == "string" and en ~= "" and type(fa) == "string" and fa ~= ""
   81             and not string.find(en, "|", 1, true) then
   82             if string.find(en, "%", 1, true) then
   83                 local n = 0
   84                 local p = string.gsub(en, "%%%d?%$?([sd])", function(k)
   85                     n = n + 1
   86                     return k == "d" and "\2" or "\1"
   87                 end)
```
tests/lua/wow_mock.lua:58
```
   13 local mt = { __index = function(_, k) local v = Obj[k]; if v ~= nil then return v end; if k == "SetTalent" then return nil end; if type(k) == "string" and k:mat
   14 -- SetTalent is the one API the noop fallback must NOT fake: real clients
   15 -- either have it (then GameTooltip carries the instance field below) or do
   16 -- not (the 1.60.1 owner client, lane-b12) - a faked noop would make the
   17 -- talents module's fallback detection impossible to test.
   18 local function new(kind, name, parent)
   19     local o = setmetatable({ _kind = kind, _name = name, _shown = true, _scripts = {}, _w = 0, _h = 0, _events = {}, _parent = parent }, mt)
   20     if name then _G[name] = o end
   21     frames[#frames + 1] = o
   22     -- Brain review #136-6: real Buttons have NO SetFont - their text lives on
   23     -- the button's own font string (GetFontString); calling SetFont on a
   24     -- button must fail loudly here exactly like in the client
   25     if kind == "Button" then
   26         o.SetFont = false
   27         o._fontstring = new("FontString", nil, o)
   28         -- colon definitions add the implicit self already - an explicit self
   29         -- param here would shift every argument by one
   30         function o:SetText(t)
   31             self._fontstring._text = t
   32             self._text = t
   33         end
   34         function o:GetText()
   35             return self._fontstring._text -- like the real client: the label
   36         end
   37         function o:GetFontString()
   38             return self._fontstring
   39         end
   40     end
   41     return o
   42 end
   43 MOCK_CREATED = 0
   44 MOCK_MEASURE = 0 -- lane-b13: every width measurement (the perf-test counter)
   45 local function str_width(t)
   46     local t = tostring(t or "")
   47     local n = utf8 and (utf8.len(t) or #t) or select(2, t:gsub("[^\128-\191]", ""))
   48     return n * 6
   49 end
   50 -- inbox/44 B: real frame types the client accepts (case-sensitive)
   51 -- 51-B (Brain review): GameTooltip is one of them - the room's hidden preview
   52 -- tooltip (CreateFrame("GameTooltip", ..., "GameTooltipTemplate")) errored
   53 -- here, so the preview and the selftest item path never ran in CI
   54 local FRAME_KINDS = {
   55     Frame = true, Button = true, EditBox = true, ScrollFrame = true, Slider = true,
   56     CheckButton = true, StatusBar = true, ColorSelect = true, Cooldown = true,
   57     Model = true, ScrollingMessageFrame = true, MessageFrame = true, SimpleHTML = true,
   58     Browser = true, CinematicModel = true, FogOfWarFrame = true, GameTooltip = true,
   59 }
   60 function CreateFrame(kind, name, parent, template)
   61     if not FRAME_KINDS[kind] then
   62         error("Unknown frame type: " .. tostring(kind))
   63     end
   64     MOCK_CREATED = MOCK_CREATED + 1
   65     return new(kind, name, parent)
   66 end
   67 function Obj.SetScript(s, ev, fn) s._scripts[ev] = fn end
   68 function Obj.GetScript(s, ev) return s._scripts[ev] end
   69 function Obj.HookScript(s, ev, fn) local old = s._scripts[ev]; s._scripts[ev] = function(...) if old then old(...) end; fn(...) end end
   70 function Obj.HasScript() return true end
   71 function Obj.RegisterEvent(s, e) s._events[e] = true end
   72 function Obj.Show(s) local was = s._shown; s._shown = true; if not was and s._scripts.OnShow then s._scripts.OnShow(s) end end
   73 function Obj.Hide(s) local was = s._shown; s._shown = false; if was and s._scripts.OnHide then s._scripts.OnHide(s) end end
   74 function Obj.IsShown(s) return s._shown end
   75 function Obj.SetShown(s, v) if v then s:Show() else s:Hide() end end
   76 function Obj.SetText(s, t) s._text = t end
   77 function Obj.GetText(s) return s._text end
   78 function Obj.GetStringWidth(s)
   79     MOCK_MEASURE = MOCK_MEASURE + 1
   80     local w = 0
   81     for seg in (tostring(s._text or "") .. "\n"):gmatch("([^\n]*)\n") do
   82         w = math.max(w, str_width(seg))
   83     end
   84     return w
   85 end
   86 function Obj.GetUnboundedStringWidth(s) return Obj.GetStringWidth(s) end
   87 function Obj.GetStringHeight(s)
   88     local n = 1
   89     for _ in tostring(s._text or ""):gmatch("\n") do n = n + 1 end
   90     -- inbox/29 C: the line spacing grows the height like the real client
   91     local sp = s._spacing or 0
   92     return n * (14 + sp)
   93 end
   94 -- inbox/29 C: the line gap - recorded so tests can assert the spacing rule
   95 function Obj.SetSpacing(s, sp) s._spacing = sp end
   96 function Obj.GetSpacing(s) return s._spacing or 0 end
   97 -- lane-b16: the real client rule this class of bug comes from - a font string
   98 -- with word wrap OFF draws only the FIRST line of a multi-line text and
   99 -- ellipsizes it; with wrap ON every "\n" line renders, and a line wider than
  100 -- the string's fixed width RE-wraps (scrambling a manual RTL order).
  101 function Obj.SetWordWrap(s, v) s._wrap = v end
  102 function Obj.SetNonSpaceWrap(s, v) s._nsw = v end
  103 function Obj.GetNumLines(s)
```
tests/lua/wow_mock.lua:246
```
  201 function Obj.CreateFontString(s) return new("FontString", nil, s) end
  202 function Obj.GetName(s) return s._name end
  203 function Obj.GetFont(s) return s._font or "Fonts\\FRIZQT__.TTF", s._fsize or 12, "" end
  204 function Obj.SetFont(s, f, sz) s._font, s._fsize = f, sz; return true end
  205 -- inbox/27: font objects + text colour - the in-place restore test asserts the
  206 -- ORIGINAL font object comes back, and the live quality colour is kept
  207 function Obj.SetFontObject(s, f) s._fobj = f; s._font, s._fsize = nil, nil; return true end
  208 function Obj.GetFontObject(s) return s._fobj end
  209 function Obj.SetTextColor(s, r, g, b, a) s._tr, s._tg, s._tb, s._ta = r, g, b, a end
  210 function Obj.GetTextColor(s) return s._tr or 1, s._tg or 1, s._tb or 1, s._ta or 1 end
  211 function Obj.GetJustifyH(s) return s._just or "LEFT" end
  212 function Obj.SetJustifyH(s, j) s._just = j end
  213 function Obj.GetVerticalScroll() return 0 end
  214 function Obj.GetCenter() return 100, 100 end
  215 function Obj.GetEffectiveScale() return 1 end
  216 function Obj.IsForbidden() return false end
  217 function Obj.GetFrameLevel() return 1 end
  218 function Obj.GetPoint() return "CENTER", nil, "CENTER", 10, 20 end
  219 function Obj.GetRight() return 500 end
  220 function Obj.SetScrollChild(s, c) s._child = c end
  221 function Obj.NumLines(s) return s._n or 0 end
  222 function Obj.AddLine(s, text)
  223     s._n = (s._n or 0) + 1
  224     local l = _G[s._name .. "TextLeft" .. s._n] or new("FontString", s._name .. "TextLeft" .. s._n)
  225     l._text = text
  226     local r = _G[s._name .. "TextRight" .. s._n] or new("FontString", s._name .. "TextRight" .. s._n)
  227     r._text = nil
  228 end
  229 function Obj.AddDoubleLine(s, a, b) s:AddLine(a); _G[s._name .. "TextRight" .. s._n]._text = b end
  230 function Obj.ClearLines(s) s._n = 0; if s._scripts.OnTooltipCleared then s._scripts.OnTooltipCleared(s) end end
  231 function Obj.SetOwner(s) s:ClearLines() end
  232 function Obj.GetItem(s) return s._itemName, s._itemLink end
  233 function Obj.GetUnit(s) return s._unitName, s._unit end
  234 function Obj.TipLines(s)
  235     local out = {}
  236     for i = 1, s._n or 0 do
  237         local l, r = _G[s._name .. "TextLeft" .. i], _G[s._name .. "TextRight" .. i]
  238         out[#out + 1] = tostring(l._text) .. (r._text and ("  ||  " .. r._text) or "") .. ((l._font or ""):find("Vazir") and "  [fa-font]" or "")
  239     end
  240     return out
  241 end
  242 
  243 UIParent = new("Frame", "UIParent")
  244 UIParent:SetSize(1920, 1080) -- inbox/44 D: the panel clamps in UIParent units
  245 Minimap = new("Frame", "Minimap"); Minimap:SetSize(140, 140)
  246 GameTooltip = new("GameTooltip", "GameTooltip")
  247 ItemRefTooltip = new("GameTooltip", "ItemRefTooltip")
  248 QuestFrame = new("Frame", "QuestFrame"); QuestFrame:SetSize(384, 512); QuestFrame._shown = false
  249 QuestLogFrame = new("Frame", "QuestLogFrame"); QuestLogFrame:SetSize(384, 512); QuestLogFrame._shown = false
  250 SubZoneTextString = new("FontString", "SubZoneTextString")
  251 MinimapZoneTextButton = new("Button", "MinimapZoneTextButton")
  252 DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) print("CHAT: " .. m:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end }
  253 UISpecialFrames = {}
  254 SlashCmdList = {}
  255 function GameTooltip.SetTalent() end
  256 -- 96 B: the spell tooltip path. SetSpellByID builds the live tooltip (the game
  257 -- fills it from C_Spell.GetSpellDescription), then the secure hook translates.
  258 -- Tests seed MOCK.spellDesc[id] = { name, description... } - the live EN lines
  259 -- exactly as the client shows them (one description string per line, both
  260 -- paragraphs included: the client hands the whole description as one leftText).
  261 function GameTooltip.SetSpellByID(s, id)
  262     s:ClearLines()
  263     local rec = MOCK.spellDesc and MOCK.spellDesc[id]
  264     if rec then
  265         s:AddLine(rec[1])
  266         for i = 2, #rec do s:AddLine(rec[i]) end
  267     end
  268 end
  269 function GameTooltip.SetSpell(s, id) return GameTooltip.SetSpellByID(s, id) end
  270 function GameTooltip.SetSpellBookItem(s, id) return GameTooltip.SetSpellByID(s, id) end
  271 C_Spell = C_Spell or { GetSpellDescription = function(id)
  272     local rec = MOCK.spellDesc and MOCK.spellDesc[id]
  273     return rec and rec[2] or nil
  274 end }
  275 function wipe(t) for k in pairs(t) do t[k] = nil end; return t end
  276 tinsert = table.insert
  277 function hooksecurefunc(a, b, c)
  278     local tbl, name, fn = a, b, c
  279     if type(a) == "string" then tbl, name, fn = _G, a, b end
  280     local orig = tbl[name]
  281     tbl[name] = function(...) local r = { orig(...) }; fn(...); return (unpack or table.unpack)(r) end
  282 end
  283 TooltipDataProcessor = { cbs = {} }
  284 function TooltipDataProcessor.AddTooltipPostCall(t, fn) TooltipDataProcessor.cbs[t] = TooltipDataProcessor.cbs[t] or {}; table.insert(TooltipDataProcessor.cbs[t
  285 Enum = { TooltipDataType = { Item = 0, Spell = 1, Unit = 2, Object = 33 } }
  286 function RunTip(kind, tt, data) for _, fn in ipairs(TooltipDataProcessor.cbs[Enum.TooltipDataType[kind]] or {}) do fn(tt, data) end end
  287 C_Timer = { After = function(s, fn) table.insert(timers, fn) end }
  288 function RunTimers() local n = 0; while #timers > 0 and n < 200 do local fn = table.remove(timers, 1); fn(); n = n + 1 end end
  289 C_ChatInfo = { RegisterAddonMessagePrefix = function() return true end, SendAddonMessage = function(p, m, c) print("SEND", p, m, c) end }
  290 MOCK = { build = "70800", questID = 0, title = "", zone = "Ashenvale", sub = "Splintertree Post", inInst = false, itype = "none", unitName = nil, guids = {}, me
  291 MOCK.itemNames = {} -- id -> client-side name; the client item lookups resolve only these (lane-a11 C)
```
- ok: GameTooltip = : 3 hits
