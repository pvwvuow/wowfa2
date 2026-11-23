-- WoWFA v1 - the settings panel: ONE scrolling page (RTL), built on first open.
-- wowfa2 replaces the old 95 KB multi-tab panel with the switches v1.0 ships:
--   master switch, room preset, the shipped name/text switches, the shipped
--   modules, display options, status (versions, module states, errors), about.
-- Rules: no Persian literal in this file (every string lives in Locale.lua);
-- every Persian string goes through the shaper (UI.Text / SetFa); plain
-- (insecure) frames only, so it opens in combat; a build error is logged and
-- reported once, it never reaches the game.

local F = WoWFAF
local L = F.L
local UI = F.UI
local C = F.C

local W, H = 520, 600         -- the window
local PW = W - 44             -- the scroll page width
local panel, page, rows, health
local sections = {}           -- page id -> scroll offset
local SHIPPED = { "quests", "tracker", "dungeons", "spellbook", "talents" }
local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits" }
local STATE_L = { ok = "st_ok", warn = "st_warn", off = "st_off", master = "st_master", nodata = "st_nodata",
    schema = "st_schema", noapi = "st_noapi", update = "st_update", fault = "st_fault", locked = "st_off" }
local STATE_C = { ok = "green", warn = "orange", update = "orange", fault = "red", noapi = "red", schema = "red", nodata = "red" }

F.PANEL_SHIPPED = SHIPPED
F.PANEL_ROOM_KEYS = ROOM_KEYS

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

local function place(f, h, gap)
    f:SetPoint("TOPRIGHT", page.child, "TOPRIGHT", -8, y)
    y = y - (h or 32) - (gap or 4)
    rows[#rows + 1] = f
    return f
end

local function header(id, text)
    y = y - 10
    sections[id] = -y
    local hd = UI.Header(page.child, text, PW - 16)
    place(hd, 28, 6)
    return hd
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

-- ------------------------------------------------------------------ refresh
local function refresh_health()
    if not health then
        return
    end
    health.addon.val:SetText("v" .. tostring(F.VERSION))
    health.client.val:SetText(tostring(F.clientVersion or "?") .. "." .. tostring(F.clientBuildText or "?"))
    health.data.val:SetText(tostring(F.dataBuildText or "-"))
    for _, id in ipairs(SHIPPED) do
        local r = health.mods[id]
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
        r.val:SetFa(lbl, 200)
        color(r.val, C[STATE_C[st] or "muted"])
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
            local x, y = tonumber(a.n) or 0, tonumber(b.n) or 0
            if x ~= y then
                return x > y
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
end
F.PanelRefresh = refresh

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

    page = UI.ScrollPage(panel, PW, H - 76)
    page:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -14, -64)
    panel.page = page
    rows, y = {}, -6

    -- master
    panel.master = place(UI.Toggle(page.child, PW - 16, L.master, L.master_d,
        function() return F.db.enabled end,
        function(v)
            F:SetEnabled(v)
            F.Chat(F.db.enabled and L.en.on or L.en.off)
        end), 50, 6)

    -- what translates: the room preset + the shipped switches
    header("room", L.tab_room)
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
    panel.room = {}
    for _, k in ipairs(ROOM_KEYS) do
        local t = UI.Toggle(page.child, PW - 16, room_label(k), L.ROOM_EX and L.ROOM_EX[k],
            function() return F.Room.On(k) end,
            function(v) F.Room.Set(k, v) end)
        t.dimOnMaster = true
        panel.room[k] = place(t, L.ROOM_EX and L.ROOM_EX[k] and 50 or 32, 2)
    end

    -- modules
    header("mods", L.tab_mods)
    panel.mods = {}
    for _, id in ipairs(SHIPPED) do
        local t = UI.Toggle(page.child, PW - 16, L["m_" .. id] or id, L["m_" .. id .. "_d"],
            function() return F.db.mods[id] and true or false end,
            function(v) F:SetModule(id, v) end)
        t.dimOnMaster = true
        panel.mods[id] = place(t, L["m_" .. id .. "_d"] and 50 or 32, 2)
    end

    -- display
    header("display", L.tab_display)
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
    panel.scale = place(UI.Slider(page.child, PW - 16, L.d_scale, 0.8, 1.3, 0.05,
        function() return F.db.scale end,
        function(v)
            if v ~= F.db.scale then
                F.db.scale = v
                panel:SetScale(v)
            end
        end), 30, 4)
    panel.dock = place(UI.Choice(page.child, PW - 16, L.d_dock, nil, L.opt_dock,
        function() return F.db.questDock end,
        function(v)
            F.db.questDock = v
            F:Fire("options", "questDock")
        end), 32, 2)
    -- the world-map zone label (Modules/Zones.lua map_mode): 1 fa / 2 fa + en / 3 off
    panel.zoneMap = place(UI.Choice(page.child, PW - 16, L.d_map, nil, L.opt_map,
        function() return F.db.zoneMap or 2 end,
        function(v)
            F.db.zoneMap = v
            F:Fire("options", "zoneMap")
        end), 32, 2)
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
    panel.questAuto = opt_toggle("questAuto", L.d_qauto, true)
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

    -- status
    header("health", L.tab_health)
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
    place(mbt, 30, 6)

    -- about
    header("about", L.tab_about)
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

    page.child:SetHeight(-y + 10)
    panel:SetScript("OnShow", function()
        refresh()
        F.After(0, function()
            if page.Fit then
                page:Fit()
            end
            page:UpdateBar()
        end)
    end)
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
        panel = nil
        return false
    end
    return true
end

-- page: nil / "home" = top; "health" / "display" / "room" / "mods" / "about"
-- ("welcome" from the old panel opens the top)
function F.OpenPanel(pageId)
    if not ensure() then
        return
    end
    panel:Show()
    refresh()
    page:ScrollTo(sections[pageId] or 0)
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

for _, sig in ipairs({ "state", "room", "errors", "minimap", "miss" }) do
    F:Listen(sig, function()
        if panel and panel:IsShown() then
            refresh()
        end
    end)
end
