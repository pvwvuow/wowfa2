## task 0217-grepreset (script)

**GREEN**


### btn_reset

addon/WoWFA/Locale.lua:225
```
  221     "0.5.1: نام فارسی ۱٬۷۸۷ آیتم تازه و نام‌های کامل NPC.",
  222     "0.5.0: اولین نسخهٔ Forever با پنل جدید، صفحهٔ خوش‌آمد و محافظ آپدیت بازی.",
  223 }
  224 L.btn_welcome = "نمایش دوبارهٔ خوش‌آمد"
  225 L.btn_reset = "بازنشانی همهٔ تنظیمات"
  226 L.btn_reset_sure = "مطمئنی؟ دوباره بزن"
  227 
  228 L.w_title = "به WoWFA خوش اومدی"
  229 L.w_scope = "در نسخهٔ 1.0 کوئست‌ها، اسم مناطق، اسپل‌ها و تلنت‌ها فارسی می‌شوند. آیتم‌ها و بقیهٔ بخش‌ها به‌زودی می‌آیند."
```
addon/WoWFA/Locale.lua:226
```
  222     "0.5.0: اولین نسخهٔ Forever با پنل جدید، صفحهٔ خوش‌آمد و محافظ آپدیت بازی.",
  223 }
  224 L.btn_welcome = "نمایش دوبارهٔ خوش‌آمد"
  225 L.btn_reset = "بازنشانی همهٔ تنظیمات"
  226 L.btn_reset_sure = "مطمئنی؟ دوباره بزن"
  227 
  228 L.w_title = "به WoWFA خوش اومدی"
  229 L.w_scope = "در نسخهٔ 1.0 کوئست‌ها، اسم مناطق، اسپل‌ها و تلنت‌ها فارسی می‌شوند. آیتم‌ها و بقیهٔ بخش‌ها به‌زودی می‌آیند."
  230 L.w_choose = "چه چیزی ترجمه شود؟"
```
addon/WoWFA/Panel.lua:1045
```
 1041     place(site, 20, 4)
 1042     local resetRow = CreateFrame("Frame", nil, page.child)
 1043     resetRow:SetSize(PW - 16, 30)
 1044     local armed = false
 1045     panel.reset = UI.Button(resetRow, L.btn_reset, 200, 26, function(self)
 1046         if not armed then
 1047             armed = true
 1048             self:SetLabel(L.btn_reset_sure)
 1049             return
```
addon/WoWFA/Panel.lua:1048
```
 1044     local armed = false
 1045     panel.reset = UI.Button(resetRow, L.btn_reset, 200, 26, function(self)
 1046         if not armed then
 1047             armed = true
 1048             self:SetLabel(L.btn_reset_sure)
 1049             return
 1050         end
 1051         armed = false
 1052         self:SetLabel(L.btn_reset)
```
addon/WoWFA/Panel.lua:1052
```
 1048             self:SetLabel(L.btn_reset_sure)
 1049             return
 1050         end
 1051         armed = false
 1052         self:SetLabel(L.btn_reset)
 1053         F:ResetDB()
 1054         F.Chat(L.en.reset)
 1055         panel:SetScale(F.db.scale or 1)
 1056         refresh()
```
addon/WoWFA/Panel.lua:1062
```
 1058     panel.reset:SetPoint("RIGHT", resetRow, "RIGHT", -4, 0)
 1059     panel:HookScript("OnHide", function()
 1060         if armed then
 1061             armed = false
 1062             panel.reset:SetLabel(L.btn_reset)
 1063         end
 1064     end)
 1065     place(resetRow, 30, 8)
 1066     end_page()
```
- ok: btn_reset: 6 hits

### ResetAll

- ok: ResetAll: 0 hits

### function F:Reset

addon/WoWFA/Core.lua:347
```
  343     sanitize(db)
  344     F.db = db
  345 end
  346 
  347 function F:ResetDB()
  348     local keepAngle = F.db and F.db.minimap and F.db.minimap.angle
  349     WoWFA_FDB = {}
  350     F:InitDB()
  351     F.db.welcomed = true
```
- ok: function F:Reset: 1 hits

### F.Reset

- ok: F.Reset: 0 hits

### WoWFAF_DB

- ok: WoWFAF_DB: 0 hits

### WoWFA_DB

- ok: WoWFA_DB: 0 hits

### profiles

addon/WoWFA/Dump.lua:39
```
   35     end
   36 end
   37 
   38 local function now_ms()
   39     if debugprofilestop then
   40         return debugprofilestop()
   41     end
   42     return (GetTime and GetTime() or 0) * 1000
   43 end
```
addon/WoWFA/Dump.lua:40
```
   36 end
   37 
   38 local function now_ms()
   39     if debugprofilestop then
   40         return debugprofilestop()
   41     end
   42     return (GetTime and GetTime() or 0) * 1000
   43 end
   44 
```
addon/WoWFA/Panel.lua:788
```
  784     panel.shareMsg:SetFa(" ", PW - 30)
  785     place(mf, 30, 2)
  786 
  787     -- rc37 (the owner: save the profile I made and put it back later with one click):
  788     -- the named profiles of Room.lua (account-wide, at most 10), one row each
  789     header(L.pf_hdr)
  790     note(L.pf_d)
  791     local pn = CreateFrame("Frame", nil, page.child)
  792     pn:SetSize(PW - 16, 26)
```
addon/WoWFA/Room.lua:21
```
   17 --     on every preset, after that it is the user's;
   18 --   * textSet   = the set bonus lines "(2) Set: ..." - an extra gate on top
   19 --     of their text category (on by default: nothing changes until the user
   20 --     turns it off);
   21 --   * profiles  = named snapshots of the room + the modules + the display
   22 --     settings in WoWFA_FDB.profiles (account-wide), save / load / delete.
   23 
   24 local F = WoWFAF
   25 local Room = {}
```
addon/WoWFA/Room.lua:22
```
   18 --   * textSet   = the set bonus lines "(2) Set: ..." - an extra gate on top
   19 --     of their text category (on by default: nothing changes until the user
   20 --     turns it off);
   21 --   * profiles  = named snapshots of the room + the modules + the display
   22 --     settings in WoWFA_FDB.profiles (account-wide), save / load / delete.
   23 
   24 local F = WoWFAF
   25 local Room = {}
   26 F.Room = Room
```
addon/WoWFA/Room.lua:426
```
  422     end
  423     return d
  424 end
  425 
  426 -- ------------------------------------------------------------ profiles
  427 -- Brain 59 (the owner: "why can I not save a profile of my settings?").
  428 -- A profile = the room (every bit + faPlace + the preset name), the module
  429 -- switches (never the opt-in capture helper) and the display options. The
  430 -- SavedVariables are account-wide, so every character sees the same list.
```
addon/WoWFA/Room.lua:463
```
  459     return (table.concat(out):gsub("%s+$", ""))
  460 end
  461 Room.ProfileCleanName = clean_name
  462 
  463 local function profiles()
  464     local fdb = F.db
  465     if type(fdb.profiles) ~= "table" then
  466         fdb.profiles = {}
  467     end
```
addon/WoWFA/Room.lua:465
```
  461 Room.ProfileCleanName = clean_name
  462 
  463 local function profiles()
  464     local fdb = F.db
  465     if type(fdb.profiles) ~= "table" then
  466         fdb.profiles = {}
  467     end
  468     return fdb.profiles
  469 end
```
addon/WoWFA/Room.lua:466
```
  462 
  463 local function profiles()
  464     local fdb = F.db
  465     if type(fdb.profiles) ~= "table" then
  466         fdb.profiles = {}
  467     end
  468     return fdb.profiles
  469 end
  470 
```
addon/WoWFA/Room.lua:468
```
  464     local fdb = F.db
  465     if type(fdb.profiles) ~= "table" then
  466         fdb.profiles = {}
  467     end
  468     return fdb.profiles
  469 end
  470 
  471 function Room.ProfileNames()
  472     local out = {}
```
addon/WoWFA/Room.lua:473
```
  469 end
  470 
  471 function Room.ProfileNames()
  472     local out = {}
  473     for k, v in pairs(profiles()) do
  474         if type(k) == "string" and type(v) == "table" then
  475             out[#out + 1] = k
  476         end
  477     end
```
addon/WoWFA/Room.lua:488
```
  484     name = clean_name(name)
  485     if name == "" then
  486         return nil, "اول یک اسم برای پروفایل بنویس"
  487     end
  488     local ps = profiles()
  489     local existed = type(ps[name]) == "table"
  490     if not existed and #Room.ProfileNames() >= Room.PROFILE_MAX then
  491         return nil, "حداکثر ۱۰ پروفایل؛ اول یکی را حذف کن"
  492     end
```
addon/WoWFA/Room.lua:517
```
  513 end
  514 
  515 -- returns true + the room mode, or nil + a Persian reason
  516 function Room.ProfileLoad(name)
  517     local p = profiles()[name]
  518     if type(p) ~= "table" or type(p.room) ~= "table" then
  519         return nil, "این پروفایل پیدا نشد"
  520     end
  521     local fdb = F.db
```
addon/WoWFA/Room.lua:582
```
  578     return true, r.m
  579 end
  580 
  581 function Room.ProfileDelete(name)
  582     local ps = profiles()
  583     if ps[name] == nil then
  584         return nil
  585     end
  586     ps[name] = nil
```
- ok: profiles: 14 hits

### SavedVariables

addon/WoWFA/Core.lua:821
```
  817     end
  818 end)
  819 F:On("PLAYER_LOGIN", nil, function()
  820     if not F.db then
  821         F:InitDB() -- SavedVariables missing (beta clients sometimes drop them)
  822     end
  823     after_login()
  824 end)
  825 F:On("PLAYER_ENTERING_WORLD", nil, function()
```
addon/WoWFA/Dump.lua:10
```
    6 -- no Persian yet, for every class.
    7 --
    8 -- English game text only: no character, realm or account data is stored.
    9 -- Saved in its own variable (WoWFA_Dump): /reload after it finishes, send the
   10 -- file WTF\Account\<account>\SavedVariables\WoWFA.lua, then /wowfa dump clear.
   11 --
   12 --   /wowfa dump            scan spell ids 1..1500000 (time-budgeted, no freeze)
   13 --   /wowfa dump <max>      scan up to <max>
   14 --   /wowfa dump stop       stop (what was found so far stays saved)
```
addon/WoWFA/Dump.lua:160
```
  156     WoWFA_Dump.done = not stopped
  157     WoWFA_Dump.lastId = scan.id
  158     WoWFA_Dump.highest = scan.highest
  159     WoWFA_Dump.names = scan.seen
  160     chat(string.format("%s: %d spells with text, %d names, highest id %d. Type /reload, then send WTF\\Account\\<account>\\SavedVariables\\WoWFA.lua",
  161         stopped and "stopped" or "done", WoWFA_Dump.count or 0, scan.seen, scan.highest))
  162 end
  163 
  164 function D.Step()
```
addon/WoWFA/Locale.lua:53
```
   49 L.cap_counts = "ثبت‌شده‌ها: آیتم %d · فروشنده %d · غنیمت %d · کوئست %d · NPC %d"
   50 L.cap_size = "حجم حدود %s"
   51 L.cap_empty = "هنوز چیزی ثبت نشده."
   52 L.cap_clear = "پاک کردن همهٔ ثبت‌شده‌ها"
   53 L.cap_file = "محل ذخیره: WTF/Account/<account>/SavedVariables/WoWFA.lua — آپلود بعداً و فقط با خودت."
   54 L.cap_locale = "زبان بازی انگلیسی نیست؛ متن‌ها ذخیره نمی‌شن (فقط شناسه‌ها و قیمت‌ها)."
   55 L.w_capture = "این اددان به دیتای سایت هم کمک می‌کنه — فقط اگه خودت توی صفحهٔ «کمک به دیتا» روشنش کنی. پیش‌فرض خاموشه."
   56 
   57 L.st_ok = "سالم"
```
addon/WoWFA/Modules/Harvest.lua:7
```
    3 -- content is complete; what is left is WoW Forever's OWN content (Riverglades, Zephras Isle,
    4 -- Krol'dok, the new quests and their NPCs), whose English text exists only in the game.
    5 -- So while the player plays, every quest shown in the quest window or the quest log that has
    6 -- no Persian (or lacks a part), and every NPC name with no Persian, is saved IN ENGLISH to
    7 -- WoWFA_Harvest. Send WTF\Account\<account>\SavedVariables\WoWFA.lua and the next build
    8 -- has them in Persian.
    9 -- English game text only: nothing about the player, realm or account is stored.
   10 --   /wowfa harvest        counts       /wowfa harvest clear   empty it
   11 --   /wowfa harvest off    stop         /wowfa harvest on      start again (default on)
```
addon/WoWFA/Modules/Harvest.lua:298
```
  294         if F.db then F.db.harvest = true end
  295         chat("on")
  296     else
  297         local h = store()
  298         chat(string.format("%d quests and %d NPC names saved in English (%s). Send WTF\\Account\\<account>\\SavedVariables\\WoWFA.lua after /reload.",
  299             h.nq, h.nn, on() and "on" or "off"))
  300     end
  301 end
  302 
```
addon/WoWFA/Room.lua:430
```
  426 -- ------------------------------------------------------------ profiles
  427 -- Brain 59 (the owner: "why can I not save a profile of my settings?").
  428 -- A profile = the room (every bit + faPlace + the preset name), the module
  429 -- switches (never the opt-in capture helper) and the display options. The
  430 -- SavedVariables are account-wide, so every character sees the same list.
  431 local PROFILE_OPTS = { "fontSize", "scale", "questDock", "questAuto", "zoneToast", "onUpdate", "toast", "share",
  432     "szList", "szGame", "chatScale", "alertScale", "fontAll", "chatFa",
  433     "npcName", "zoneMap", "alerts", "sysmsg", "sysLoot", "sysXp", "sysRep", "sysGroup", "listTitles" }
  434 Room.PROFILE_MAX = 10
```
- ok: SavedVariables: 7 hits

### SizePct

addon/WoWFA/Modules/Font.lua:49
```
   45     return db and db.enabled and db.fontAll == true and true or false
   46 end
   47 
   48 local function game_pct()
   49     return (F.SizePct and F.SizePct("szGame", 100, 70, 160)) or 1
   50 end
   51 
   52 local function factor(name)
   53     local f = fa_on() and SCALE or 1
```
addon/WoWFA/Text.lua:1059
```
 1055 --   game         F.db.szGame 70-160 %    the game's own texts, English too (Font.lua)
 1056 --   chat, red alerts, settings window: their own sliders (chatScale, alertScale, scale)
 1057 F.SIZE_BASE = { title = 13, obj = 12 }
 1058 
 1059 function F.SizePct(key, def, lo, hi)
 1060     local v = tonumber(F.db and F.db[key]) or def
 1061     if v < lo or v > hi then
 1062         v = def
 1063     end
```
addon/WoWFA/Text.lua:1080
```
 1076 function F.SizeOf(role)
 1077     if role == 'own' or role == 'spell' then
 1078         return clamp_size(T.Size())
 1079     end
 1080     return clamp_size((F.SIZE_BASE[role] or F.SIZE_BASE.title) * F.SizePct('szList', 100, 70, 200))
 1081 end
 1082 
 1083 -- older callers: a role name, or a base size scaled by the list slider only
 1084 function F.ListSize(base)
```
addon/WoWFA/Text.lua:1088
```
 1084 function F.ListSize(base)
 1085     if type(base) == 'string' then
 1086         return F.SizeOf(base)
 1087     end
 1088     return clamp_size((tonumber(base) or 12) * F.SizePct('szList', 100, 70, 200))
 1089 end
 1090 
 1091 -- Persian template {0} {1} ... filled with live numbers
 1092 function T.Fill(fa, nums, force)
```
- ok: SizePct: 4 hits

### F:Signal(

- ok: F:Signal(: 0 hits

### F:Fire(

addon/WoWFA/Core.lua:331
```
  327         end
  328         return
  329     end
  330     F.db.surf[name] = on and true or false
  331     F:Fire("surf", name)
  332     F:Fire("options", "surf:" .. name)
  333 end
  334 
  335 function F:InitDB()
```
addon/WoWFA/Core.lua:332
```
  328         return
  329     end
  330     F.db.surf[name] = on and true or false
  331     F:Fire("surf", name)
  332     F:Fire("options", "surf:" .. name)
  333 end
  334 
  335 function F:InitDB()
  336     if type(WoWFA_FDB) ~= "table" then
```
addon/WoWFA/Core.lua:365
```
  361     F:Refresh()
  362     if F.T and F.T.RefreshAll then
  363         F.T.RefreshAll()
  364     end
  365     F:Fire("options", "questDock")
  366     F:Fire("options", "questAuto")
  367     F:Fire("minimap")
  368     F:Fire("surf")
  369 end
```
addon/WoWFA/Core.lua:366
```
  362     if F.T and F.T.RefreshAll then
  363         F.T.RefreshAll()
  364     end
  365     F:Fire("options", "questDock")
  366     F:Fire("options", "questAuto")
  367     F:Fire("minimap")
  368     F:Fire("surf")
  369 end
  370 
```
addon/WoWFA/Core.lua:367
```
  363         F.T.RefreshAll()
  364     end
  365     F:Fire("options", "questDock")
  366     F:Fire("options", "questAuto")
  367     F:Fire("minimap")
  368     F:Fire("surf")
  369 end
  370 
  371 -- ----------------------------------------------------------------- events
```
addon/WoWFA/Core.lua:368
```
  364     end
  365     F:Fire("options", "questDock")
  366     F:Fire("options", "questAuto")
  367     F:Fire("minimap")
  368     F:Fire("surf")
  369 end
  370 
  371 -- ----------------------------------------------------------------- events
  372 local ev = CreateFrame("Frame")
```
addon/WoWFA/Core.lua:413
```
  409 -- inbox/44 A1: per-signal re-entrancy guard. The panel's "errors" listener
  410 -- calls LogError -> Fire("errors") again; without the guard one bad listener
  411 -- loops Fire -> LogError -> Fire forever (the owner's stack overflow).
  412 local firing = {}
  413 function F:Fire(name, ...)
  414     if firing[name] then
  415         return
  416     end
  417     firing[name] = true
```
addon/WoWFA/Core.lua:440
```
  436     for _, e in ipairs(db.errors) do
  437         if e.m == modId and e.e == msg then
  438             e.n = (e.n or 1) + 1
  439             e.t = time and time() or 0
  440             F:Fire("errors")
  441             return
  442         end
  443     end
  444     table.insert(db.errors, 1, { m = modId, e = msg, n = 1, t = time and time() or 0, b = F.clientBuild or 0, v = F.VERSION })
```
addon/WoWFA/Core.lua:448
```
  444     table.insert(db.errors, 1, { m = modId, e = msg, n = 1, t = time and time() or 0, b = F.clientBuild or 0, v = F.VERSION })
  445     while #db.errors > 30 do
  446         table.remove(db.errors)
  447     end
  448     F:Fire("errors")
  449 end
  450 
  451 -- ------------------------------------------------------------- modules
  452 F.mods, F.order = {}, {}
```
addon/WoWFA/Core.lua:552
```
  548     end
  549     db.miss[id] = { k = tostring(kind), t = string.sub(tostring(sample or key), 1, 300),
  550         c = ctx and string.sub(tostring(ctx), 1, 80) or nil, n = 1, b = F.clientBuild or 0 }
  551     db.missN = (tonumber(db.missN) or 0) + 1
  552     F:Fire("miss")
  553 end
  554 
  555 -- rc7: a miss list written by an OLDER build of the addon is stale (the rc6 list
  556 -- still held our own rc3-rc5 output): a new addon version starts a fresh list.
```
addon/WoWFA/Core.lua:567
```
  563 
  564 function F:ClearMiss()
  565     if F.db then
  566         F.db.miss, F.db.missN = {}, 0
  567         F:Fire("miss")
  568     end
  569 end
  570 
  571 local function check_data()
```
addon/WoWFA/Core.lua:656
```
  652         if m.onState and was ~= m.active then
  653             pcall(m.onState, m, m.active)
  654         end
  655     end
  656     F:Fire("state")
  657 end
  658 
  659 function F:Active(modId)
  660     local m = F.mods[modId]
```
addon/WoWFA/Core.lua:764
```
  760             return
  761         end
  762         F.newerVersion = ver
  763         F:Notify("newver", string.format(L.t_newver, ver), ver)
  764         F:Fire("state")
  765     end
  766 end
  767 
  768 -- ------------------------------------------------------------- startup
```
addon/WoWFA/Core.lua:810
```
  806     if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
  807         pcall(C_ChatInfo.RegisterAddonMessagePrefix, PREFIX)
  808     end
  809     F:Refresh()
  810     F:Fire("login")
  811     F.Chat(string.format(L.en.loaded, F.VERSION, F.dataBuildText))
  812 end
  813 
  814 F:On("ADDON_LOADED", nil, function(_, name)
```
addon/WoWFA/Core.lua:877
```
  873         F:ResetDB()
  874         F.Chat(L.en.reset)
  875     elseif cmd == "minimap" or cmd == "mm" then
  876         F.db.minimap.hide = not F.db.minimap.hide
  877         F:Fire("minimap")
  878     elseif cmd == "quest" and F.QuestToggle then
  879         F.QuestToggle()
  880         -- inbox/29 B: with no quest window open the toggle must SAY so -
  881         -- F.QuestToggle answers through F.QuestToggled (nil = nothing open)
```
addon/WoWFA/Panel.lua:358
```
  354         function() return F.db[key] and true or false end,
  355         function(v)
  356             F.db[key] = v and true or false
  357             if signal then
  358                 F:Fire("options", key)
  359             end
  360         end), 32, 2)
  361 end
  362 
```
addon/WoWFA/Panel.lua:525
```
  521     panel.minimap = place(UI.Toggle(page.child, PW - 16, L.d_minimap, nil,
  522         function() return not F.db.minimap.hide end,
  523         function(v)
  524             F.db.minimap.hide = not v
  525             F:Fire("minimap")
  526         end), 32, 2)
  527     panel.toast = opt_toggle("toast", L.d_toast, false)
  528     panel.share = opt_toggle("share", L.d_share, false)
  529     panel.onUpdate = place(UI.Choice(page.child, PW - 16, L.d_update, nil, L.opt_update,
```
addon/WoWFA/Panel.lua:541
```
  537     panel.alerts = place(UI.Toggle(page.child, PW - 16, L.al_on, L.al_on_d,
  538         function() return F.db.alerts ~= false end,
  539         function(v)
  540             F.db.alerts = v and true or false
  541             F:Fire("options", "alerts")
  542         end), 50, 2)
  543     -- the system lines of the chat (Modules/Sysmsg.lua)
  544     panel.sysmsg = place(UI.Toggle(page.child, PW - 16, L.sy_on, L.sy_on_d,
  545         function() return F.db.sysmsg ~= false end,
```
addon/WoWFA/Panel.lua:548
```
  544     panel.sysmsg = place(UI.Toggle(page.child, PW - 16, L.sy_on, L.sy_on_d,
  545         function() return F.db.sysmsg ~= false end,
  546         function(v)
  547             F.db.sysmsg = v and true or false
  548             F:Fire('options', 'sysmsg')
  549         end), 50, 2)
  550     for _, k in ipairs({ 'sysLoot', 'sysXp', 'sysRep', 'sysGroup' }) do
  551         panel[k] = place(UI.Toggle(page.child, PW - 16, L['sy_' .. k], nil,
  552             function() return F.db[k] ~= false end,
```
addon/WoWFA/Panel.lua:555
```
  551         panel[k] = place(UI.Toggle(page.child, PW - 16, L['sy_' .. k], nil,
  552             function() return F.db[k] ~= false end,
  553             function(v)
  554                 F.db[k] = v and true or false
  555                 F:Fire('options', 'sysmsg')
  556             end), 32, 2)
  557     end
  558     -- Persian in the game chat (Modules/Chat.lua)
  559     panel.chatFa = place(UI.Toggle(page.child, PW - 16, L.ch_on, L.ch_on_d,
```
addon/WoWFA/Panel.lua:563
```
  559     panel.chatFa = place(UI.Toggle(page.child, PW - 16, L.ch_on, L.ch_on_d,
  560         function() return F.db.chatFa ~= false end,
  561         function(v)
  562             F.db.chatFa = v and true or false
  563             F:Fire("options", "chatFa")
  564         end), 50, 2)
  565     end_page()
  566 
  567     -- ===================================================== Font sizes
```
addon/WoWFA/Panel.lua:582
```
  578                 F.db.fontSize = v
  579                 if F.T and F.T.RefreshAll then
  580                     F.T.RefreshAll()
  581                 end
  582                 F:Fire("options", "fontSize")
  583             end
  584         end), 30, 4)
  585     note(L.sz_own_d)
  586     header(L.sz_list_h)
```
addon/WoWFA/Panel.lua:593
```
  589         function(v)
  590             v = math.floor(v + 0.5)
  591             if v ~= (F.db.szList or 100) then
  592                 F.db.szList = v
  593                 F:Fire('options', 'szList')
  594             end
  595         end), 30, 4)
  596     note(L.sz_list_d)
  597     header(L.sz_all_h)
```
addon/WoWFA/Panel.lua:602
```
  598     panel.fontAll = place(UI.Toggle(page.child, PW - 16, L.fa_on, L.fa_on_d,
  599         function() return F.db.fontAll == true end,
  600         function(v)
  601             F.db.fontAll = v and true or false
  602             F:Fire("options", "fontAll")
  603         end), 50, 2)
  604     panel.szGame = place(UI.Slider(page.child, PW - 16, L.fa_size, 70, 160, 5,
  605         function() return F.db.szGame or 100 end,
  606         function(v)
```
addon/WoWFA/Panel.lua:610
```
  606         function(v)
  607             v = math.floor(v + 0.5)
  608             if v ~= (F.db.szGame or 100) then
  609                 F.db.szGame = v
  610                 F:Fire("options", "szGame")
  611             end
  612         end), 30, 4)
  613     note(L.sz_all_d)
  614     header(L.sz_other_h)
```
addon/WoWFA/Panel.lua:621
```
  617         function(v)
  618             v = math.floor(v + 0.5)
  619             if v ~= (F.db.chatScale or 90) then
  620                 F.db.chatScale = v
  621                 F:Fire("options", "chatFa")
  622             end
  623         end), 30, 4)
  624     note(L.sz_chat_d)
  625     panel.alertScale = place(UI.Slider(page.child, PW - 16, L.al_size, 70, 160, 5,
```
addon/WoWFA/Panel.lua:631
```
  627         function(v)
  628             v = math.floor(v + 0.5)
  629             if v ~= (F.db.alertScale or 100) then
  630                 F.db.alertScale = v
  631                 F:Fire('options', 'alertScale')
  632             end
  633         end), 30, 4)
  634     note(L.sz_alert_d)
  635     panel.scale = place(UI.Slider(page.child, PW - 16, L.d_scale, 0.8, 1.3, 0.05,
```
addon/WoWFA/Panel.lua:657
```
  653     panel.dock = place(UI.Choice(page.child, PW - 16, L.d_dock, nil, L.opt_dock,
  654         function() return F.db.questDock end,
  655         function(v)
  656             F.db.questDock = v
  657             F:Fire("options", "questDock")
  658         end), 32, 2)
  659     panel.questAuto = opt_toggle("questAuto", L.d_qauto, true)
  660     panel.listTitles = opt_toggle("listTitles", L.d_listtitles, true)
  661     end_page()
```
addon/WoWFA/Panel.lua:679
```
  675     panel.zoneMap = place(UI.Choice(page.child, PW - 16, L.d_map, nil, L.opt_map,
  676         function() return F.db.zoneMap or 2 end,
  677         function(v)
  678             F.db.zoneMap = v
  679             F:Fire("options", "zoneMap")
  680         end), 32, 2)
  681     end_page()
  682 
  683     -- ===================================================== NPC names
```
addon/WoWFA/Panel.lua:693
```
  689     panel.npcName = place(UI.Choice(page.child, PW - 16, L.d_npcname, nil, L.opt_npc,
  690         function() return F.NpcMode and F.NpcMode() or 1 end,
  691         function(v)
  692             F.db.npcName = v
  693             F:Fire("npcname")
  694         end), 32, 2)
  695     note(L.n_npc)
  696     end_page()
  697 
```
- ok: F:Fire(: 60 hits

### Listen("state"

addon/WoWFA/Minimap.lua:167
```
  163     if not ok2 then
  164         F:LogError("ui", err2)
  165     end
  166 end)
  167 F:Listen("state", update_look)
  168 F:Listen("minimap", function()
  169     update_look()
  170     position()
  171 end)
```
addon/WoWFA/Modules/Walk.lua:540
```
  536     F.After(2, W.Start)
  537 end)
  538 F:Listen("names", refresh_all)
  539 F:Listen("disp", refresh_all)
  540 F:Listen("state", function()
  541     memo = {}
  542 end)
  543 F:Listen("options", function(key)
  544     if key == "listTitles" then
```
- ok: Listen("state": 2 hits

### chatFa

addon/WoWFA/Modules/Bubbles.lua:3
```
    1 -- WoWFA Forever - the speech bubbles above heads. The game draws them with its own font:
    2 -- a Persian line shows empty boxes. Behind the same switch as the Persian chat
    3 -- (F.db.chatFa, default on): a bubble whose text has raw Persian letters gets our font
    4 -- and the shaped text. Not a registered module: pcall everywhere, nothing in combat
    5 -- needs it (bubbles are plain font strings).
    6 
    7 local F = WoWFAF
```
addon/WoWFA/Modules/Bubbles.lua:12
```
    8 local T = F.T
    9 
   10 local function on()
   11     local db = F.db
   12     return db and db.enabled and db.chatFa ~= false and true or false
   13 end
   14 
   15 local function fix_fs(fs)
   16     local ok, txt = pcall(fs.GetText, fs)
```
addon/WoWFA/Modules/Chat.lua:1
```
    1 -- WoWFA Forever - Persian in the game chat. Behind F.db.chatFa (General > Persian
    2 -- chat, default on):
    3 --   1. our font on every chat window and its edit box (the game's chat font has
    4 --      no Persian letters). The size is the game's chat size times
    5 --      F.db.chatScale percent (default 90, a slider in General), because
```
addon/WoWFA/Modules/Chat.lua:37
```
   33 }
   34 
   35 local function on()
   36     local db = F.db
   37     return db and db.enabled and db.chatFa ~= false and true or false
   38 end
   39 
   40 local function scale()
   41     local v = F.db and tonumber(F.db.chatScale) or 90
```
addon/WoWFA/Modules/Sysmsg.lua:27
```
   23 local registered = false
   24 
   25 local function on()
   26     local db = F.db
   27     return db and db.enabled and db.sysmsg ~= false and db.chatFa ~= false and true or false
   28 end
   29 
   30 -- which switch of General a row belongs to
   31 local function category(name)
```
addon/WoWFA/Panel.lua:559
```
  555                 F:Fire('options', 'sysmsg')
  556             end), 32, 2)
  557     end
  558     -- Persian in the game chat (Modules/Chat.lua)
  559     panel.chatFa = place(UI.Toggle(page.child, PW - 16, L.ch_on, L.ch_on_d,
  560         function() return F.db.chatFa ~= false end,
  561         function(v)
  562             F.db.chatFa = v and true or false
  563             F:Fire("options", "chatFa")
```
addon/WoWFA/Panel.lua:560
```
  556             end), 32, 2)
  557     end
  558     -- Persian in the game chat (Modules/Chat.lua)
  559     panel.chatFa = place(UI.Toggle(page.child, PW - 16, L.ch_on, L.ch_on_d,
  560         function() return F.db.chatFa ~= false end,
  561         function(v)
  562             F.db.chatFa = v and true or false
  563             F:Fire("options", "chatFa")
  564         end), 50, 2)
```
addon/WoWFA/Panel.lua:562
```
  558     -- Persian in the game chat (Modules/Chat.lua)
  559     panel.chatFa = place(UI.Toggle(page.child, PW - 16, L.ch_on, L.ch_on_d,
  560         function() return F.db.chatFa ~= false end,
  561         function(v)
  562             F.db.chatFa = v and true or false
  563             F:Fire("options", "chatFa")
  564         end), 50, 2)
  565     end_page()
  566 
```
addon/WoWFA/Panel.lua:563
```
  559     panel.chatFa = place(UI.Toggle(page.child, PW - 16, L.ch_on, L.ch_on_d,
  560         function() return F.db.chatFa ~= false end,
  561         function(v)
  562             F.db.chatFa = v and true or false
  563             F:Fire("options", "chatFa")
  564         end), 50, 2)
  565     end_page()
  566 
  567     -- ===================================================== Font sizes
```
addon/WoWFA/Panel.lua:621
```
  617         function(v)
  618             v = math.floor(v + 0.5)
  619             if v ~= (F.db.chatScale or 90) then
  620                 F.db.chatScale = v
  621                 F:Fire("options", "chatFa")
  622             end
  623         end), 30, 4)
  624     note(L.sz_chat_d)
  625     panel.alertScale = place(UI.Slider(page.child, PW - 16, L.al_size, 70, 160, 5,
```
addon/WoWFA/Room.lua:432
```
  428 -- A profile = the room (every bit + faPlace + the preset name), the module
  429 -- switches (never the opt-in capture helper) and the display options. The
  430 -- SavedVariables are account-wide, so every character sees the same list.
  431 local PROFILE_OPTS = { "fontSize", "scale", "questDock", "questAuto", "zoneToast", "onUpdate", "toast", "share",
  432     "szList", "szGame", "chatScale", "alertScale", "fontAll", "chatFa",
  433     "npcName", "zoneMap", "alerts", "sysmsg", "sysLoot", "sysXp", "sysRep", "sysGroup", "listTitles" }
  434 Room.PROFILE_MAX = 10
  435 
  436 local function deep(v)
```
addon/WoWFA/Room.lua:568
```
  564     F:Fire("options", "questAuto")
  565     F:Fire("options", "szList")
  566     F:Fire("options", "szGame")
  567     F:Fire("options", "fontAll")
  568     F:Fire("options", "chatFa")
  569     F:Fire("options", "alertScale")
  570     F:Fire("options", "zoneMap")
  571     F:Fire("options", "alerts")
  572     F:Fire("options", "sysmsg")
```
- ok: chatFa: 12 hits

### chatScale

addon/WoWFA/Modules/Chat.lua:5
```
    1 -- WoWFA Forever - Persian in the game chat. Behind F.db.chatFa (General > Persian
    2 -- chat, default on):
    3 --   1. our font on every chat window and its edit box (the game's chat font has
    4 --      no Persian letters). The size is the game's chat size times
    5 --      F.db.chatScale percent (default 90, a slider in General), because
    6 --      Vazirmatn is drawn bigger than the game font at the same size;
    7 --   2. a chat filter that shapes an incoming message that holds Persian letters
    8 --      (same shaper as every other text), so a player who has the addon reads
    9 --      joined letters in the right order. A player without the addon sees the
```
addon/WoWFA/Modules/Chat.lua:41
```
   37     return db and db.enabled and db.chatFa ~= false and true or false
   38 end
   39 
   40 local function scale()
   41     local v = F.db and tonumber(F.db.chatScale) or 90
   42     if v < 50 then
   43         v = 50
   44     elseif v > 130 then
   45         v = 130
```
addon/WoWFA/Panel.lua:615
```
  611             end
  612         end), 30, 4)
  613     note(L.sz_all_d)
  614     header(L.sz_other_h)
  615     panel.chatScale = place(UI.Slider(page.child, PW - 16, L.ch_size, 60, 120, 5,
  616         function() return F.db.chatScale or 90 end,
  617         function(v)
  618             v = math.floor(v + 0.5)
  619             if v ~= (F.db.chatScale or 90) then
```
addon/WoWFA/Panel.lua:616
```
  612         end), 30, 4)
  613     note(L.sz_all_d)
  614     header(L.sz_other_h)
  615     panel.chatScale = place(UI.Slider(page.child, PW - 16, L.ch_size, 60, 120, 5,
  616         function() return F.db.chatScale or 90 end,
  617         function(v)
  618             v = math.floor(v + 0.5)
  619             if v ~= (F.db.chatScale or 90) then
  620                 F.db.chatScale = v
```
addon/WoWFA/Panel.lua:619
```
  615     panel.chatScale = place(UI.Slider(page.child, PW - 16, L.ch_size, 60, 120, 5,
  616         function() return F.db.chatScale or 90 end,
  617         function(v)
  618             v = math.floor(v + 0.5)
  619             if v ~= (F.db.chatScale or 90) then
  620                 F.db.chatScale = v
  621                 F:Fire("options", "chatFa")
  622             end
  623         end), 30, 4)
```
addon/WoWFA/Panel.lua:620
```
  616         function() return F.db.chatScale or 90 end,
  617         function(v)
  618             v = math.floor(v + 0.5)
  619             if v ~= (F.db.chatScale or 90) then
  620                 F.db.chatScale = v
  621                 F:Fire("options", "chatFa")
  622             end
  623         end), 30, 4)
  624     note(L.sz_chat_d)
```
addon/WoWFA/Room.lua:432
```
  428 -- A profile = the room (every bit + faPlace + the preset name), the module
  429 -- switches (never the opt-in capture helper) and the display options. The
  430 -- SavedVariables are account-wide, so every character sees the same list.
  431 local PROFILE_OPTS = { "fontSize", "scale", "questDock", "questAuto", "zoneToast", "onUpdate", "toast", "share",
  432     "szList", "szGame", "chatScale", "alertScale", "fontAll", "chatFa",
  433     "npcName", "zoneMap", "alerts", "sysmsg", "sysLoot", "sysXp", "sysRep", "sysGroup", "listTitles" }
  434 Room.PROFILE_MAX = 10
  435 
  436 local function deep(v)
```
addon/WoWFA/Text.lua:1056
```
 1052 --                                        talent texts, quest window, spellbook names)
 1053 --   title / obj  F.db.szList 70-200 %    quest list beside the map + the tracker:
 1054 --                                        title 13 pt, objective 12 pt at 100 %
 1055 --   game         F.db.szGame 70-160 %    the game's own texts, English too (Font.lua)
 1056 --   chat, red alerts, settings window: their own sliders (chatScale, alertScale, scale)
 1057 F.SIZE_BASE = { title = 13, obj = 12 }
 1058 
 1059 function F.SizePct(key, def, lo, hi)
 1060     local v = tonumber(F.db and F.db[key]) or def
```
- ok: chatScale: 8 hits

### fontAll

addon/WoWFA/Modules/Font.lua:2
```
    1 -- WoWFA Forever - one font with Persian letters for the whole game. Behind
    2 -- F.db.fontAll (General > Persian font in the whole game, default OFF).
    3 -- The game's own fonts have no Persian glyphs, so every text the game draws
    4 -- with them (chat, player names, mail, friends list, tooltips of other
    5 -- addons) shows empty boxes where a Persian letter should be. With the switch
    6 -- on, the standard font objects take our font (size and flags kept, size x 0.92
```
addon/WoWFA/Modules/Font.lua:45
```
   41 local KEEP = { ChatFontNormal = true, ChatFontSmall = true }
   42 
   43 local function fa_on()
   44     local db = F.db
   45     return db and db.enabled and db.fontAll == true and true or false
   46 end
   47 
   48 local function game_pct()
   49     return (F.SizePct and F.SizePct("szGame", 100, 70, 160)) or 1
```
addon/WoWFA/Panel.lua:598
```
  594             end
  595         end), 30, 4)
  596     note(L.sz_list_d)
  597     header(L.sz_all_h)
  598     panel.fontAll = place(UI.Toggle(page.child, PW - 16, L.fa_on, L.fa_on_d,
  599         function() return F.db.fontAll == true end,
  600         function(v)
  601             F.db.fontAll = v and true or false
  602             F:Fire("options", "fontAll")
```
addon/WoWFA/Panel.lua:599
```
  595         end), 30, 4)
  596     note(L.sz_list_d)
  597     header(L.sz_all_h)
  598     panel.fontAll = place(UI.Toggle(page.child, PW - 16, L.fa_on, L.fa_on_d,
  599         function() return F.db.fontAll == true end,
  600         function(v)
  601             F.db.fontAll = v and true or false
  602             F:Fire("options", "fontAll")
  603         end), 50, 2)
```
addon/WoWFA/Panel.lua:601
```
  597     header(L.sz_all_h)
  598     panel.fontAll = place(UI.Toggle(page.child, PW - 16, L.fa_on, L.fa_on_d,
  599         function() return F.db.fontAll == true end,
  600         function(v)
  601             F.db.fontAll = v and true or false
  602             F:Fire("options", "fontAll")
  603         end), 50, 2)
  604     panel.szGame = place(UI.Slider(page.child, PW - 16, L.fa_size, 70, 160, 5,
  605         function() return F.db.szGame or 100 end,
```
addon/WoWFA/Panel.lua:602
```
  598     panel.fontAll = place(UI.Toggle(page.child, PW - 16, L.fa_on, L.fa_on_d,
  599         function() return F.db.fontAll == true end,
  600         function(v)
  601             F.db.fontAll = v and true or false
  602             F:Fire("options", "fontAll")
  603         end), 50, 2)
  604     panel.szGame = place(UI.Slider(page.child, PW - 16, L.fa_size, 70, 160, 5,
  605         function() return F.db.szGame or 100 end,
  606         function(v)
```
addon/WoWFA/Room.lua:432
```
  428 -- A profile = the room (every bit + faPlace + the preset name), the module
  429 -- switches (never the opt-in capture helper) and the display options. The
  430 -- SavedVariables are account-wide, so every character sees the same list.
  431 local PROFILE_OPTS = { "fontSize", "scale", "questDock", "questAuto", "zoneToast", "onUpdate", "toast", "share",
  432     "szList", "szGame", "chatScale", "alertScale", "fontAll", "chatFa",
  433     "npcName", "zoneMap", "alerts", "sysmsg", "sysLoot", "sysXp", "sysRep", "sysGroup", "listTitles" }
  434 Room.PROFILE_MAX = 10
  435 
  436 local function deep(v)
```
addon/WoWFA/Room.lua:567
```
  563     F:Fire("options", "questDock")
  564     F:Fire("options", "questAuto")
  565     F:Fire("options", "szList")
  566     F:Fire("options", "szGame")
  567     F:Fire("options", "fontAll")
  568     F:Fire("options", "chatFa")
  569     F:Fire("options", "alertScale")
  570     F:Fire("options", "zoneMap")
  571     F:Fire("options", "alerts")
```
- ok: fontAll: 8 hits
