-- WoWFA v1 - the settings panel v2 (rc8): a side menu (RIGHT, the RTL side) and
-- one page per section: General, Quests, Quest tracker, Map and zones, Spellbook,
-- Talents, Status, About. Each page is its own scroll page, built once on the
-- first open. Spellbook and Talents carry a per-section «name» and «description»
-- display (Persian only / Persian + English below / English) that either follows
-- General or is the section's own (F.Disp / F.DispSet in Room.lua).
-- Rules: no Persian literal in this file (every string lives in Locale.lua);
-- every Persian string goes through the shaper (UI.Text / SetFa); plain
-- (insecure) frames only, so it opens in combat; a build error is logged and
-- reported once, it never reaches the game.

local F = WoWFAF
local L = F.L
local UI = F.UI
local C = F.C

local W, H = 700, 600         -- the window
local NAVW = 164              -- the side menu
local PW = 486                -- the scroll page width
local panel, page, rows, health
local pages, navbtns, active = {}, {}, nil
local SHIPPED = { "quests", "tracker", "dungeons", "npc", "spellbook", "talents" }
local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
local SECTIONS = { "general", "sizes", "quests", "tracker", "map", "npc", "spellbook", "talents", "colors", "share", "health", "about" }
-- the ids of the one-page panel still work (F.OpenPanel("health") from the toast, the tests)
local ALIAS = { room = "general", mods = "general", display = "general", home = "general", welcome = "general" }
local STATE_L = { ok = "st_ok", warn = "st_warn", off = "st_off", master = "st_master", nodata = "st_nodata",
    schema = "st_schema", noapi = "st_noapi", update = "st_update", fault = "st_fault", locked = "st_off" }
local STATE_C = { ok = "green", warn = "orange", update = "orange", fault = "red", noapi = "red", schema = "red", nodata = "red" }

F.PANEL_SHIPPED = SHIPPED
F.PANEL_ROOM_KEYS = ROOM_KEYS
F.PANEL_SECTIONS = SECTIONS

local function room_label(key)
    for _, group in pairs(L.ROOM_ROWS or {}) do
        for _, r in ipairs(group) do
            if r.k == key then
                return r.lbl
            end
        end
    end
    return key
end

local function color(fs, c)
    c = c or C.text
    fs:SetTextColor(c[1], c[2], c[3])
end

-- ------------------------------------------------------------------ layout
local y -- the running offset inside page.child (negative = down)

local pre = 0 -- the gap a section header asked for above the next row

local function place(f, h, gap)
    f:SetPoint("TOPRIGHT", page.child, "TOPRIGHT", -8, y)
    y = y - (h or 32) - (gap or 4)
    rows[#rows + 1] = f
    page.items[#page.items + 1] = { f = f, h = h or 32, gap = gap or 4, pre = pre }
    pre = 0
    return f
end

-- rc33 (the owner's screenshots: rows run into each other): the row heights above are
-- guesses. A label that wraps to two lines or a two-line description needs more, so
-- every page is stacked again from the REAL height of its texts (rows only ever grow).
local function sh(fs)
    local h = fs and fs.GetStringHeight and fs:GetStringHeight()
    if F.Usable(h) and type(h) == "number" then
        return h
    end
    return 0
end

local function need_of(f)
    if f.label and f.label.GetStringHeight then
        local n = sh(f.label) + 10
        if f.desc then
            n = n + 2 + sh(f.desc)
        end
        return n
    end
    if f.text and f.text.GetStringHeight then
        return sh(f.text) + 4
    end
    return 0
end

local function restack(sf)
    if not sf or not sf.items or not sf.child then
        return
    end
    local yy = -6
    for _, it in ipairs(sf.items) do
        -- rc37: a hidden row (an empty profile slot) takes no room
        if not (it.f.IsShown and not it.f:IsShown()) then
            yy = yy - (it.pre or 0)
            local h = math.max(it.h, math.ceil(need_of(it.f)))
            it.f:SetHeight(h)
            it.f:ClearAllPoints()
            it.f:SetPoint("TOPRIGHT", sf.child, "TOPRIGHT", -8, yy)
            yy = yy - h - it.gap
        end
    end
    sf.child:SetHeight(-yy + 10)
    if sf.UpdateBar then
        sf:UpdateBar()
    end
end

local function begin_page(id)
    local sf = UI.ScrollPage(panel, PW, H - 76)
    sf:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -64)
    sf:Hide()
    pages[id] = sf
    sf.items = {}
    page, y = sf, -6
    pre = 0
end

local function end_page()
    page.child:SetHeight(-y + 10)
    restack(page)
end

local function header(text)
    y = y - 10
    pre = pre + 10
    local hd = UI.Header(page.child, text, PW - 16)
    place(hd, 28, 6)
    return hd
end

local function note(text)
    local f = CreateFrame("Frame", nil, page.child)
    f:SetSize(PW - 16, 40)
    f.text = UI.Text(f, 12, C.muted)
    f.text:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, 0)
    f.text:SetFa(text, PW - 30)
    return place(f, 40, 2)
end

-- [Persian label ......... value]  value = Latin (versions) or Persian (states)
local function pair_row(label, latin)
    local f = CreateFrame("Frame", nil, page.child)
    f:SetSize(PW - 16, 24)
    f.label = UI.Text(f, 13, C.text)
    f.label:SetPoint("RIGHT", f, "RIGHT", -4, 0)
    f.label:SetFa(label, 220)
    if latin then
        f.val = UI.Latin(f, 12, C.goldLight, "LEFT")
    else
        f.val = UI.Text(f, 12, C.muted, "LEFT")
    end
    f.val:SetPoint("LEFT", f, "LEFT", 6, 0)
    f.val:SetWidth(200)
    return place(f, 24, 2)
end

local function preset_index()
    local m = F.Room.Mode()
    for i, id in ipairs(F.Room.PRESET_IDS) do
        if id == m then
            return i
        end
    end
    return #F.Room.PRESET_IDS + 1 -- custom
end

local function state_of(id)
    local m = F.mods[id]
    local st = m and m.state or "off"
    local lbl = L[STATE_L[st] or "st_off"] or tostring(st)
    -- rc4: the reason next to the state, so a warn / auto-off is never a
    -- guess ("build" = the game is newer than the data, "miss" = most
    -- texts did not match, xN = faults that tripped the breaker)
    if m and m.why then
        lbl = lbl .. " (" .. tostring(m.why) .. ")"
    elseif m and st == "fault" then
        lbl = lbl .. " (x" .. tostring(m.faults or 0) .. ")"
    end
    return lbl, C[STATE_C[st] or "muted"]
end

-- ------------------------------------------------------------------ refresh
local function refresh_health()
    if not health then
        return
    end
    health.addon.val:SetText("v" .. tostring(F.VERSION))
    health.client.val:SetText(tostring(F.clientVersion or "?") .. "." .. tostring(F.clientBuildText or "?"))
    health.data.val:SetText(tostring(F.dataBuildText or "-"))
    for _, id in ipairs(SHIPPED) do
        local lbl, col = state_of(id)
        local r = health.mods[id]
        r.val:SetFa(lbl, 200)
        color(r.val, col)
        local s = panel.modState and panel.modState[id]
        if s then
            s.val:SetFa(lbl, 200)
            color(s.val, col)
        end
    end
    local errs = F.db and F.db.errors or {}
    if #errs == 0 then
        health.errHead:SetFa(L.h_noerr, PW - 30)
        health.errList:SetFixed("")
    else
        health.errHead:SetFa(L.h_errors, PW - 30)
        local out = {}
        for i = 1, math.min(5, #errs) do
            local e = errs[i]
            local msg = (string.gsub(string.sub(tostring(e.e), 1, 160), "|", "||"))
            out[#out + 1] = string.format("[%s] %s (x%d) v%s b%s", tostring(e.m), msg, tonumber(e.n) or 1,
                tostring(e.v or "?"), tostring(e.b or "?"))
        end
        health.errList:SetFixed(table.concat(out, "\n"))
    end
    -- rc3 update watch: the misses as ONE line (a single-line box never grows
    -- over the rows below; Ctrl+C copies all of it). Entries: kind :: text ::
    -- spell/context :: xCount, most seen first
    if health.missList then
        F:MissFresh()
        local list = {}
        for _, e in pairs(F.db and type(F.db.miss) == "table" and F.db.miss or {}) do
            list[#list + 1] = e
        end
        table.sort(list, function(a, b)
            local x, y2 = tonumber(a.n) or 0, tonumber(b.n) or 0
            if x ~= y2 then
                return x > y2
            end
            return tostring(a.t) < tostring(b.t)
        end)
        local out = { string.format("WoWFA %s b%s misses=%d", tostring(F.VERSION), tostring(F.clientBuildText or "?"), #list) }
        for i = 1, #list do
            local e = list[i]
            local t = string.gsub(tostring(e.t or ""), "|", "!")
            t = string.gsub(t, "[\r\n]+", " / ")
            out[#out + 1] = string.format("%s :: %s :: %s :: x%d", tostring(e.k), t, tostring(e.c or ""), tonumber(e.n) or 1)
        end
        health.missList:SetFixed(table.concat(out, " ;; "))
        health.missHead:SetFa(string.format(L.h_miss_n, #list), PW - 30)
    end
end

local function refresh()
    if not panel then
        return
    end
    local off = not (F.db and F.db.enabled)
    for _, r in ipairs(rows) do
        if r.Update then
            r.dimmed = off and r.dimOnMaster or nil
            r:Update()
        end
    end
    refresh_health()
    if panel.shareBox and F.Room.ShareExport then
        panel.shareBox:SetFixed(F.Room.ShareExport())
    end
end
F.PanelRefresh = refresh

-- ------------------------------------------------------------------ pages
local function select_page(id)
    id = ALIAS[id] or id
    if not pages[id] then
        id = "general"
    end
    for pid, sf in pairs(pages) do
        if pid ~= id then
            sf:Hide()
        end
    end
    local sf = pages[id]
    sf:Show()
    sf:ScrollTo(0)
    active = id
    for nid, b in pairs(navbtns) do
        local on = nid == id
        local c = on and C.gold or C.muted
        b.label:SetTextColor(c[1], c[2], c[3])
        if b.mark then
            b.mark:SetShown(on)
        end
    end
    F.After(0, function()
        restack(sf)
        if sf.Fit then
            sf:Fit()
        end
        sf:UpdateBar()
    end)
end

-- ------------------------------------------------------------------ row builders
local function room_toggle(k, nostore)
    local t = UI.Toggle(page.child, PW - 16, room_label(k), L.ROOM_EX and L.ROOM_EX[k],
        function() return F.Room.On(k) end,
        function(v) F.Room.Set(k, v) end)
    t.dimOnMaster = true
    if not nostore then
        panel.room[k] = t
    end
    return place(t, L.ROOM_EX and L.ROOM_EX[k] and 50 or 32, 2)
end

local function mod_toggle(id)
    local t = UI.Toggle(page.child, PW - 16, L["m_" .. id] or id, L["m_" .. id .. "_d"],
        function() return F.db.mods[id] and true or false end,
        function(v) F:SetModule(id, v) end)
    t.dimOnMaster = true
    panel.mods[id] = place(t, L["m_" .. id .. "_d"] and 50 or 32, 2)
    panel.modState[id] = pair_row(L.h_state, false)
end

local function opt_toggle(key, label, signal)
    return place(UI.Toggle(page.child, PW - 16, label, nil,
        function() return F.db[key] and true or false end,
        function(v)
            F.db[key] = v and true or false
            if signal then
                F:Fire("options", key)
            end
        end), 32, 2)
end

-- the per-section name / description display: follows General until «custom» is on
local function disp_section(sec)
    panel.dispCustom[sec] = place(UI.Toggle(page.child, PW - 16, L.d_sep, L.d_sep_d,
        function() return F.DispCustom(sec) end,
        function(v) F.DispSetCustom(sec, v) end), 50, 2)
    panel.dispTitle[sec] = place(UI.Choice(page.child, PW - 16, L.d_title, nil, L.opt_title,
        function() return F.Disp(sec, "title") end,
        function(v) F.DispSet(sec, "title", v) end), 32, 2)
    panel.dispDesc[sec] = place(UI.Choice(page.child, PW - 16, L.d_desc, nil, L.opt_desc,
        function() return F.Disp(sec, "desc") end,
        function(v) F.DispSet(sec, "desc", v) end), 32, 2)
end

-- a one-line code box: read-only (the text can only be selected and copied) or editable
local function code_box(parent, editable)
    UI.Glass(parent, 0.6)
    local eb = CreateFrame("EditBox", nil, parent)
    eb:SetMultiLine(false)
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(0)
    eb:SetFont(F.FONT, 11, "")
    eb:SetTextColor(C.text[1], C.text[2], C.text[3])
    eb:SetSize(PW - 30, 22)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -2)
    eb:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    eb:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    if not editable then
        eb.wfaFixed = ""
        eb:SetScript("OnTextChanged", function(self, user)
            if user then
                self:SetText(self.wfaFixed or "")
                self:HighlightText()
            end
        end)
        eb.SetFixed = function(self, s)
            self.wfaFixed = s or ""
            self:SetText(self.wfaFixed)
            self:SetCursorPosition(0)
        end
    end
    return eb
end

-- ------------------------------------------------------------------ build
local function build()
    panel = CreateFrame("Frame", "WoWFAF_Panel", UIParent)
    panel:Hide()
    panel:SetSize(W, H)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    panel:SetScale(F.db.scale or 1)
    UI.Glass(panel, 0.97)
    if UISpecialFrames then
        table.insert(UISpecialFrames, "WoWFAF_Panel") -- Esc closes it
    end

    local title = UI.Latin(panel, 20, C.gold, "LEFT")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -14)
    title:SetText("WoWFA")
    local ver = UI.Latin(panel, 11, C.muted, "LEFT")
    ver:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    ver:SetText("v" .. tostring(F.VERSION))
    local sub = UI.Text(panel, 14, C.goldLight)
    sub:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -40, -18)
    sub:SetFa(L.subtitle, 300)
    panel.subtitle = sub
    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetSize(28, 28)
    close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function()
        panel:Hide()
    end)
    panel.close = close
    local line = UI.Line(panel, false, 0.5)
    line:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -58)
    line:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -12, -58)
    local vline = UI.Line(panel, true, 0.35)
    vline:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -(NAVW + 18), -64)
    vline:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -(NAVW + 18), 14)

    -- the side menu
    panel.nav = navbtns
    for i, id in ipairs(SECTIONS) do
        local b = UI.Button(panel, L["sec_" .. id], NAVW - 8, 30, function()
            select_page(id)
        end)
        b:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -14, -68 - (i - 1) * 36)
        local mark = UI.Tex(b, "OVERLAY", "diamond")
        mark:SetSize(8, 8)
        mark:SetPoint("RIGHT", b, "RIGHT", -4, 0)
        mark:SetVertexColor(C.gold[1], C.gold[2], C.gold[3], 0.9)
        mark:Hide()
        b.mark = mark
        navbtns[id] = b
    end

    rows = {}
    panel.room, panel.mods, panel.modState = {}, {}, {}
    panel.dispCustom, panel.dispTitle, panel.dispDesc = {}, {}, {}

    -- ===================================================== General
    begin_page("general")
    panel.master = place(UI.Toggle(page.child, PW - 16, L.master, L.master_d,
        function() return F.db.enabled end,
        function(v)
            F:SetEnabled(v)
            F.Chat(F.db.enabled and L.en.on or L.en.off)
        end), 50, 6)
    header(L.tab_room)
    local labels = {}
    for i, id in ipairs(F.Room.PRESET_IDS) do
        labels[i] = F.Room.PRESET_LBL[id]
    end
    labels[#labels + 1] = F.Room.PRESET_LBL.custom
    local npre = #F.Room.PRESET_IDS
    local pre = UI.Choice(page.child, PW - 16, L.w_choose, F.Room.PRESET_DESC[F.Room.Mode()] or "", labels,
        preset_index,
        function(v)
            if v > npre then
                v = 1 -- "custom" is a result, never a choice: the cycle skips it
            end
            F.Room.Apply(F.Room.PRESET_IDS[v])
        end)
    local base = pre.Update
    pre.Update = function(self)
        base(self)
        if self.desc then
            self.desc:SetFa(F.Room.PRESET_DESC[F.Room.Mode()] or "", PW - 16 - 160)
        end
    end
    pre.dimOnMaster = true
    panel.preset = place(pre, 50, 4)
    header(L.g_names)
    room_toggle("namesClass")
    room_toggle("terms")
    room_toggle("faDigits")
    header(L.g_defaults)
    panel.dispTitleAll = place(UI.Choice(page.child, PW - 16, L.d_title, nil, L.opt_title,
        function() return F.Disp("*", "title") end,
        function(v) F.DispSetDefault("title", v) end), 32, 2)
    panel.dispDescAll = place(UI.Choice(page.child, PW - 16, L.d_desc, nil, L.opt_desc,
        function() return F.Disp("*", "desc") end,
        function(v) F.DispSetDefault("desc", v) end), 32, 2)
    header(L.tab_display)
    panel.minimap = place(UI.Toggle(page.child, PW - 16, L.d_minimap, nil,
        function() return not F.db.minimap.hide end,
        function(v)
            F.db.minimap.hide = not v
            F:Fire("minimap")
        end), 32, 2)
    panel.toast = opt_toggle("toast", L.d_toast, false)
    panel.share = opt_toggle("share", L.d_share, false)
    panel.onUpdate = place(UI.Choice(page.child, PW - 16, L.d_update, nil, L.opt_update,
        function() return F.db.onUpdate end,
        function(v)
            F.db.onUpdate = v
            F:Refresh()
        end), 32, 2)
    -- the red messages in the middle of the screen (Modules/Alerts.lua)
    header(L.al_hdr)
    panel.alerts = place(UI.Toggle(page.child, PW - 16, L.al_on, L.al_on_d,
        function() return F.db.alerts ~= false end,
        function(v)
            F.db.alerts = v and true or false
            F:Fire("options", "alerts")
        end), 50, 2)
    -- the system lines of the chat (Modules/Sysmsg.lua)
    panel.sysmsg = place(UI.Toggle(page.child, PW - 16, L.sy_on, L.sy_on_d,
        function() return F.db.sysmsg ~= false end,
        function(v)
            F.db.sysmsg = v and true or false
            F:Fire('options', 'sysmsg')
        end), 50, 2)
    for _, k in ipairs({ 'sysLoot', 'sysXp', 'sysRep', 'sysGroup' }) do
        panel[k] = place(UI.Toggle(page.child, PW - 16, L['sy_' .. k], nil,
            function() return F.db[k] ~= false end,
            function(v)
                F.db[k] = v and true or false
                F:Fire('options', 'sysmsg')
            end), 32, 2)
    end
    -- Persian in the game chat (Modules/Chat.lua)
    panel.chatFa = place(UI.Toggle(page.child, PW - 16, L.ch_on, L.ch_on_d,
        function() return F.db.chatFa ~= false end,
        function(v)
            F.db.chatFa = v and true or false
            F:Fire("options", "chatFa")
        end), 50, 2)
    end_page()

    -- ===================================================== Font sizes
    -- rc34 (the owner: two sliders moved one thing and one moved nothing): EVERY size
    -- slider lives on this page and each one moves exactly ONE group of texts
    begin_page("sizes")
    note(L.sz_intro)
    header(L.sz_own_h)
    panel.fontSize = place(UI.Slider(page.child, PW - 16, L.d_size, 9, 20, 1,
        function() return F.db.fontSize end,
        function(v)
            v = math.floor(v + 0.5)
            if v ~= F.db.fontSize then
                F.db.fontSize = v
                if F.T and F.T.RefreshAll then
                    F.T.RefreshAll()
                end
                F:Fire("options", "fontSize")
            end
        end), 30, 4)
    note(L.sz_own_d)
    header(L.sz_list_h)
    panel.szList = place(UI.Slider(page.child, PW - 16, L.ls_size, 70, 200, 5,
        function() return F.db.szList or 100 end,
        function(v)
            v = math.floor(v + 0.5)
            if v ~= (F.db.szList or 100) then
                F.db.szList = v
                F:Fire('options', 'szList')
            end
        end), 30, 4)
    note(L.sz_list_d)
    header(L.sz_all_h)
    panel.fontAll = place(UI.Toggle(page.child, PW - 16, L.fa_on, L.fa_on_d,
        function() return F.db.fontAll == true end,
        function(v)
            F.db.fontAll = v and true or false
            F:Fire("options", "fontAll")
        end), 50, 2)
    panel.szGame = place(UI.Slider(page.child, PW - 16, L.fa_size, 70, 160, 5,
        function() return F.db.szGame or 100 end,
        function(v)
            v = math.floor(v + 0.5)
            if v ~= (F.db.szGame or 100) then
                F.db.szGame = v
                F:Fire("options", "szGame")
            end
        end), 30, 4)
    note(L.sz_all_d)
    header(L.sz_other_h)
    panel.chatScale = place(UI.Slider(page.child, PW - 16, L.ch_size, 60, 120, 5,
        function() return F.db.chatScale or 90 end,
        function(v)
            v = math.floor(v + 0.5)
            if v ~= (F.db.chatScale or 90) then
                F.db.chatScale = v
                F:Fire("options", "chatFa")
            end
        end), 30, 4)
    note(L.sz_chat_d)
    panel.alertScale = place(UI.Slider(page.child, PW - 16, L.al_size, 70, 160, 5,
        function() return F.db.alertScale or 100 end,
        function(v)
            v = math.floor(v + 0.5)
            if v ~= (F.db.alertScale or 100) then
                F.db.alertScale = v
                F:Fire('options', 'alertScale')
            end
        end), 30, 4)
    note(L.sz_alert_d)
    panel.scale = place(UI.Slider(page.child, PW - 16, L.d_scale, 0.8, 1.3, 0.05,
        function() return F.db.scale end,
        function(v)
            if v ~= F.db.scale then
                F.db.scale = v
                panel:SetScale(v)
            end
        end), 30, 4)
    note(L.sz_win_d)
    end_page()

    -- ===================================================== Quests
    begin_page("quests")
    mod_toggle("quests")
    header(L.sec_quests)
    room_toggle("namesQuest")
    room_toggle("questText")
    room_toggle("npcSay")
    panel.dock = place(UI.Choice(page.child, PW - 16, L.d_dock, nil, L.opt_dock,
        function() return F.db.questDock end,
        function(v)
            F.db.questDock = v
            F:Fire("options", "questDock")
        end), 32, 2)
    panel.questAuto = opt_toggle("questAuto", L.d_qauto, true)
    panel.listTitles = opt_toggle("listTitles", L.d_listtitles, true)
    end_page()

    -- ===================================================== Quest tracker
    begin_page("tracker")
    mod_toggle("tracker")
    note(L.n_tracker)
    end_page()

    -- ===================================================== Map and zones
    begin_page("map")
    mod_toggle("dungeons")
    header(L.sec_map)
    room_toggle("namesZone")
    -- the world-map zone label (Modules/Zones.lua map_mode): 1 fa / 2 fa + en / 3 off
    panel.zoneMap = place(UI.Choice(page.child, PW - 16, L.d_map, nil, L.opt_map,
        function() return F.db.zoneMap or 2 end,
        function(v)
            F.db.zoneMap = v
            F:Fire("options", "zoneMap")
        end), 32, 2)
    end_page()

    -- ===================================================== NPC names
    begin_page("npc")
    mod_toggle("npc")
    header(L.sec_npc)
    room_toggle("namesNpc")
    -- F.db.npcName: 1 Persian / 2 Persian + English under it / 3 English (Modules/Npc.lua)
    panel.npcName = place(UI.Choice(page.child, PW - 16, L.d_npcname, nil, L.opt_npc,
        function() return F.NpcMode and F.NpcMode() or 1 end,
        function(v)
            F.db.npcName = v
            F:Fire("npcname")
        end), 32, 2)
    note(L.n_npc)
    end_page()

    -- ===================================================== Spellbook
    begin_page("spellbook")
    mod_toggle("spellbook")
    header(L.sec_spellbook)
    room_toggle("namesSpell")
    if room_label("textDesc") ~= "textDesc" then
        room_toggle("textDesc")
    end
    disp_section("spellbook")
    note(L.n_disp)
    end_page()

    -- ===================================================== Talents
    begin_page("talents")
    mod_toggle("talents")
    header(L.sec_talents)
    room_toggle("namesSpell", true)
    if room_label("textDesc") ~= "textDesc" then
        room_toggle("textDesc", true)
    end
    disp_section("talents")
    note(L.n_disp)
    end_page()

    -- ===================================================== Colours
    begin_page("colors")
    panel.colOn = place(UI.Toggle(page.child, PW - 16, L.col_on, L.col_on_d,
        function() return F.db.col and F.db.col.on and true or false end,
        function(v) F.ColSetOn(v) end), 50, 6)
    header(L.col_hdr)
    panel.col = {}
    for _, fam in ipairs(F.T.COL_FAMS) do
        local row = UI.Choice(page.child, PW - 16, L["col_" .. fam], nil, F.ColLabels(fam),
            function() return F.ColIndex(fam) end,
            function(v) F.ColSet(fam, v) end)
        local base = row.Update
        row.Update = function(self)
            base(self)
            local hex = F.ColHex(fam)
            if hex then
                self.val:SetTextColor(tonumber(string.sub(hex, 1, 2), 16) / 255,
                    tonumber(string.sub(hex, 3, 4), 16) / 255, tonumber(string.sub(hex, 5, 6), 16) / 255)
            else
                self.val:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
            end
        end
        row:Update()
        panel.col[fam] = place(row, 32, 2)
    end
    note(L.col_note)
    end_page()

    -- ===================================================== Share
    begin_page("share")
    header(L.sh_mine)
    note(L.sh_mine_d)
    local c1 = CreateFrame("Frame", nil, page.child)
    c1:SetSize(PW - 16, 26)
    panel.shareBox = code_box(c1, false)
    place(c1, 26, 8)
    header(L.sh_use)
    note(L.sh_use_d)
    local c2 = CreateFrame("Frame", nil, page.child)
    c2:SetSize(PW - 16, 26)
    panel.shareIn = code_box(c2, true)
    place(c2, 26, 6)
    local ab = CreateFrame("Frame", nil, page.child)
    ab:SetSize(PW - 16, 30)
    panel.shareApply = UI.Button(ab, L.sh_apply, 150, 26, function()
        local txt = panel.shareIn:GetText() or ""
        local ok, why, note = F.Room.ShareImport(txt)
        local msg = ok and L.sh_ok or tostring(why)
        if ok and note then
            msg = msg .. " " .. note
        end
        panel.shareMsg:SetFa(msg, PW - 30)
        if ok then
            refresh()
        end
    end)
    panel.shareApply:SetPoint("RIGHT", ab, "RIGHT", -4, 0)
    place(ab, 30, 4)
    local mf = CreateFrame("Frame", nil, page.child)
    mf:SetSize(PW - 16, 30)
    panel.shareMsg = UI.Text(mf, 12, C.goldLight)
    panel.shareMsg:SetPoint("TOPRIGHT", mf, "TOPRIGHT", -4, 0)
    panel.shareMsg:SetFa(" ", PW - 30)
    place(mf, 30, 2)

    -- rc37 (the owner: save the profile I made and put it back later with one click):
    -- the named profiles of Room.lua (account-wide, at most 10), one row each
    header(L.pf_hdr)
    note(L.pf_d)
    local pn = CreateFrame("Frame", nil, page.child)
    pn:SetSize(PW - 16, 26)
    panel.pfName = code_box(pn, true)
    place(pn, 26, 4)
    local pmsg
    local function pf_say(s)
        if pmsg then
            pmsg.text:SetFa(s or " ", PW - 30)
        end
    end
    local function pf_redo()
        refresh()
        if pages.share then
            restack(pages.share)
        end
    end
    local pb = CreateFrame("Frame", nil, page.child)
    pb:SetSize(PW - 16, 30)
    panel.pfSave = UI.Button(pb, L.pf_save, 150, 26, function()
        local ok, why, name = F.Room.ProfileSave(panel.pfName:GetText() or "")
        if ok then
            pf_say(string.format(why == "updated" and L.pf_updated or L.pf_saved, tostring(name)))
            panel.pfName:SetText("")
            panel.pfName:ClearFocus()
        else
            pf_say(tostring(why))
        end
        pf_redo()
    end)
    panel.pfSave:SetPoint("RIGHT", pb, "RIGHT", -4, 0)
    place(pb, 30, 4)
    pmsg = CreateFrame("Frame", nil, page.child)
    pmsg:SetSize(PW - 16, 24)
    pmsg.text = UI.Text(pmsg, 12, C.goldLight)
    pmsg.text:SetPoint("TOPRIGHT", pmsg, "TOPRIGHT", -4, 0)
    pmsg.text:SetFa(" ", PW - 30)
    place(pmsg, 24, 4)
    panel.pfRows = {}
    for i = 1, (F.Room.PROFILE_MAX or 10) do
        local r = CreateFrame("Frame", nil, page.child)
        r:SetSize(PW - 16, 30)
        r.name = UI.Text(r, 13, C.text)
        r.name:SetPoint("RIGHT", r, "RIGHT", -4, 0)
        r.load = UI.Button(r, L.pf_load, 110, 24, function()
            if not r.pname then
                return
            end
            local nm = r.pname
            local ok, why = F.Room.ProfileLoad(nm)
            pf_say(ok and string.format(L.pf_loaded, nm) or tostring(why))
            if ok then
                panel:SetScale(F.db.scale or 1)
            end
            pf_redo()
        end)
        r.load:SetPoint("LEFT", r, "LEFT", 96, 0)
        r.del = UI.Button(r, L.pf_del, 86, 24, function(self)
            if not r.pname then
                return
            end
            if not r.armed then
                r.armed = true
                self:SetLabel(L.pf_del_sure)
                return
            end
            r.armed = false
            self:SetLabel(L.pf_del)
            local nm = r.pname
            F.Room.ProfileDelete(nm)
            pf_say(string.format(L.pf_deleted, nm))
            pf_redo()
        end)
        r.del:SetPoint("LEFT", r, "LEFT", 4, 0)
        r.Update = function(self)
            local n = F.Room.ProfileNames()[i]
            if self.pname ~= n and self.armed then
                self.armed = false
                self.del:SetLabel(L.pf_del)
            end
            self.pname = n
            if n then
                self.name:SetFa(n, PW - 260)
                self:Show()
            else
                self:Hide()
            end
        end
        panel.pfRows[i] = place(r, 30, 2)
        r:Update()
    end
    local pe = CreateFrame("Frame", nil, page.child)
    pe:SetSize(PW - 16, 24)
    pe.text = UI.Text(pe, 12, C.muted)
    pe.text:SetPoint("TOPRIGHT", pe, "TOPRIGHT", -4, 0)
    pe.Update = function(self)
        if #F.Room.ProfileNames() == 0 then
            self.text:SetFa(L.pf_none, PW - 30)
            self:Show()
        else
            self:Hide()
        end
    end
    place(pe, 24, 2)
    pe:Update()
    end_page()

    -- ===================================================== Status
    begin_page("health")
    header(L.tab_health)
    health = { mods = {} }
    panel.health = health
    health.addon = pair_row(L.h_addon, true)
    health.client = pair_row(L.h_client, true)
    health.data = pair_row(L.h_data, true)
    for _, id in ipairs(SHIPPED) do
        health.mods[id] = pair_row(L["m_" .. id] or id, false)
    end
    local btns = CreateFrame("Frame", nil, page.child)
    btns:SetSize(PW - 16, 30)
    panel.recheck = UI.Button(btns, L.btn_recheck, 150, 26, function()
        for _, id in ipairs(SHIPPED) do
            local m = F.mods[id]
            if m and (m.state == "fault" or m.state == "update" or m.state == "noapi") then
                F:Resume(id)
            end
        end
        F:Refresh()
        refresh()
    end)
    panel.recheck:SetPoint("RIGHT", btns, "RIGHT", -4, 0)
    panel.clear = UI.Button(btns, L.btn_clear, 150, 26, function()
        if F.db and type(F.db.errors) == "table" then
            for i = #F.db.errors, 1, -1 do
                F.db.errors[i] = nil
            end
        end
        F:Fire("errors")
        refresh()
    end)
    panel.clear:SetPoint("RIGHT", panel.recheck, "LEFT", -8, 0)
    place(btns, 30, 6)
    local eh = CreateFrame("Frame", nil, page.child)
    eh:SetSize(PW - 16, 24)
    health.errHead = UI.Text(eh, 12, C.muted)
    health.errHead:SetPoint("RIGHT", eh, "RIGHT", -4, 0)
    health.errHead:SetFa(L.h_noerr, PW - 30)
    place(eh, 24, 2)
    -- the error list is a read-only EditBox: click = select all, Ctrl+C copies
    -- it for a report (a font string can not be copied)
    local el = CreateFrame("Frame", nil, page.child)
    el:SetSize(PW - 16, 90)
    local eb = CreateFrame("EditBox", nil, el)
    eb:SetMultiLine(true)
    eb:SetAutoFocus(false)
    eb:SetFont(F.FONT, 10, "")
    eb:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
    eb:SetSize(PW - 24, 90)
    eb:SetPoint("TOPLEFT", el, "TOPLEFT", 4, 0)
    eb.wfaFixed = ""
    eb:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    eb:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    eb:SetScript("OnTextChanged", function(self, user)
        if user then
            self:SetText(self.wfaFixed or "")
            self:HighlightText()
        end
    end)
    eb.SetFixed = function(self, s)
        self.wfaFixed = s or ""
        self:SetText(self.wfaFixed)
    end
    health.errList = eb
    place(el, 90, 4)
    -- 1.0.3 (the owner: tell the player what the line below is and where to send it)
    header(L.rp_hdr)
    note(L.rp_d)
    -- rc3 update watch: what the live game showed that the data could not
    -- translate (Core F:Miss). One read-only line; click = select all.
    local mh = CreateFrame("Frame", nil, page.child)
    mh:SetSize(PW - 16, 40)
    health.missHead = UI.Text(mh, 12, C.muted)
    health.missHead:SetPoint("TOPRIGHT", mh, "TOPRIGHT", -4, 0)
    health.missHead:SetFa(string.format(L.h_miss_n, 0), PW - 30)
    place(mh, 40, 2)
    local ml = CreateFrame("Frame", nil, page.child)
    ml:SetSize(PW - 16, 24)
    local mb = CreateFrame("EditBox", nil, ml)
    mb:SetMultiLine(false)
    mb:SetAutoFocus(false)
    mb:SetMaxLetters(0)
    mb:SetFont(F.FONT, 10, "")
    mb:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
    mb:SetSize(PW - 24, 22)
    mb:SetPoint("TOPLEFT", ml, "TOPLEFT", 4, 0)
    mb.wfaFixed = ""
    mb:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    mb:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    mb:SetScript("OnTextChanged", function(self, user)
        if user then
            self:SetText(self.wfaFixed or "")
            self:HighlightText()
        end
    end)
    mb.SetFixed = function(self, s)
        self.wfaFixed = s or ""
        self:SetText(self.wfaFixed)
        self:SetCursorPosition(0)
    end
    health.missList = mb
    place(ml, 24, 4)
    local mbt = CreateFrame("Frame", nil, page.child)
    mbt:SetSize(PW - 16, 30)
    panel.missClear = UI.Button(mbt, L.btn_miss_clear, 150, 26, function()
        F:ClearMiss()
        refresh()
    end)
    panel.missClear:SetPoint("RIGHT", mbt, "RIGHT", -4, 0)
    -- 1.0.3: one click selects the whole line (the game can not write the clipboard itself)
    panel.missCopy = UI.Button(mbt, L.btn_miss_copy, 170, 26, function()
        if health.missList then
            health.missList:SetFocus()
            health.missList:HighlightText()
        end
        F.Chat("WoWFA: Ctrl+C copies it. Send it at wowfarsi.ir/report or in the wowfarsi Discord.")
    end)
    panel.missCopy:SetPoint("RIGHT", panel.missClear, "LEFT", -8, 0)
    place(mbt, 30, 6)
    end_page()

    -- ===================================================== About
    begin_page("about")
    header(L.tab_about)
    local ab = CreateFrame("Frame", nil, page.child)
    ab:SetSize(PW - 16, 40)
    ab.text = UI.Text(ab, 12, C.muted)
    ab.text:SetPoint("TOPRIGHT", ab, "TOPRIGHT", -4, 0)
    ab.text:SetFa(L.a_cmds, PW - 30)
    place(ab, 40, 2)
    local site = CreateFrame("Frame", nil, page.child)
    site:SetSize(PW - 16, 20)
    site.text = UI.Latin(site, 11, C.goldLight, "LEFT")
    site.text:SetPoint("LEFT", site, "LEFT", 4, 0)
    site.text:SetText(tostring(F.SITE) .. "  |  Data from ForeverDB.net")
    place(site, 20, 4)
    local resetRow = CreateFrame("Frame", nil, page.child)
    resetRow:SetSize(PW - 16, 30)
    local armed = false
    panel.reset = UI.Button(resetRow, L.btn_reset, 200, 26, function(self)
        if not armed then
            armed = true
            self:SetLabel(L.btn_reset_sure)
            return
        end
        armed = false
        self:SetLabel(L.btn_reset)
        F:ResetDB()
        F.Chat(L.en.reset)
        panel:SetScale(F.db.scale or 1)
        refresh()
    end)
    panel.reset:SetPoint("RIGHT", resetRow, "RIGHT", -4, 0)
    panel:HookScript("OnHide", function()
        if armed then
            armed = false
            panel.reset:SetLabel(L.btn_reset)
        end
    end)
    place(resetRow, 30, 8)
    end_page()

    panel.page = pages.general
    panel:SetScript("OnShow", function()
        refresh()
        local sf = pages[active or "general"]
        F.After(0, function()
            restack(sf)
            if sf and sf.Fit then
                sf:Fit()
            end
            if sf then
                sf:UpdateBar()
            end
        end)
    end)
    select_page("general")
end

local function ensure()
    if panel then
        return true
    end
    if not F.db then
        return false
    end
    local ok, err = pcall(build)
    if not ok then
        F:LogError("ui", err)
        F.Chat("WoWFA: the settings panel could not be built (" .. string.sub(tostring(err), 1, 160) .. ")")
        if panel then
            panel:Hide()
        end
        panel, pages, navbtns, active = nil, {}, {}, nil
        return false
    end
    return true
end

-- page: nil = the section that was open last (General the first time); a section id
-- (general / quests / tracker / map / spellbook / talents / health / about) or one
-- of the old one-page ids (room / mods / display = General)
function F.OpenPanel(pageId)
    if not ensure() then
        return
    end
    panel:Show()
    select_page(pageId or active or "general")
    refresh()
end

function F.TogglePanel()
    if panel and panel:IsShown() then
        panel:Hide()
    else
        F.OpenPanel()
    end
end

function F.PanelFrame()
    return panel
end

function F.PanelPage()
    return active
end

F:Listen("text", function()
    if panel and panel:IsShown() and active and pages[active] then
        restack(pages[active])
    end
end)
for _, sig in ipairs({ "state", "room", "errors", "minimap", "miss", "disp" }) do
    F:Listen(sig, function()
        if panel and panel:IsShown() then
            refresh()
        end
    end)
end
