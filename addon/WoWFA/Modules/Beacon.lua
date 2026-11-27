-- WoWFA Forever 1.2.2 - the floating report icon (the owner 27 Nov): a small icon on the player's
-- screen with a counter and a thin frame. Every time the addon meets a text it can not translate
-- (a NEW row in the report list) the frame flashes green once. A click opens a SMALL page stuck to
-- the icon (not a window in the middle): what the report helps with ("2 NPC names, 3 quest texts"),
-- a box with the report and the buttons copy report / site address / clear. A right click opens a
-- tiny menu (open, settings, hide), a drag moves it. It is OFF until the player says yes in the
-- one-time intro (db.beacon.asked); the same switch is at the top of Settings > Status and report.
-- An addon can not write to the clipboard or open a web page, so "copy" selects the text in the box
-- and the player presses Ctrl+C (the same way the status page works).
-- Plain frames only (safe in combat). Nothing of the game is written or hooked. Not a registered
-- module: every call is wrapped in pcall. Every Persian text lives in Locale_Beacon.lua (L.BC).

local F = WoWFAF
local L = F.L
local T = F.T
local UI = F.UI
local C = F.C

local B = {}
F.Beacon = B

local SIZE = 36
local FLASH_SEC = 1.4 -- the green blink after a new find: about two pulses
local icon, win, menu, catcher, intro
local flash = 0
local lastN = 0

local function S(k)
    local t = L.BC
    return (t and t[k]) or " "
end

local function store()
    local d = F.db
    if not d then
        return nil
    end
    if type(d.beacon) ~= "table" then
        d.beacon = {}
    end
    return d.beacon
end

function B.IsOn()
    local s = store()
    return s ~= nil and s.on == true
end

local function total()
    if not F.db then
        return 0
    end
    F:MissFresh()
    return tonumber(F.db.missN) or 0
end

-- the same line the status page shows (kind :: text :: context :: xCount ;; errors ;; combat)
function B.ReportText()
    F:MissFresh()
    local d = F.db or {}
    local list = {}
    for _, e in pairs(type(d.miss) == "table" and d.miss or {}) do
        list[#list + 1] = e
    end
    table.sort(list, function(a, b)
        local x, y = tonumber(a.n) or 0, tonumber(b.n) or 0
        if x ~= y then
            return x > y
        end
        return tostring(a.t) < tostring(b.t)
    end)
    local errs = type(d.errors) == "table" and d.errors or {}
    local out = { string.format("WoWFA %s b%s misses=%d errors=%d", tostring(F.VERSION),
        tostring(F.clientBuildText or "?"), #list, #errs) }
    for i = 1, #list do
        local e = list[i]
        local t = string.gsub(tostring(e.t or ""), "|", "!")
        t = string.gsub(t, "%c+", " / ")
        out[#out + 1] = string.format("%s :: %s :: %s :: x%d", tostring(e.k), t, tostring(e.c or ""), tonumber(e.n) or 1)
    end
    for i = 1, math.min(5, #errs) do
        local e = errs[i]
        local msg = string.gsub(string.sub(tostring(e.e), 1, 160), "|", "!")
        msg = string.gsub(msg, "%c+", " / ")
        out[#out + 1] = string.format("err :: [%s] %s :: x%d", tostring(e.m), msg, tonumber(e.n) or 1)
    end
    for _, c in ipairs(type(d.combatDiff) == "table" and d.combatDiff or {}) do
        local cv = string.gsub(tostring(c.v), "|", "!")
        out[#out + 1] = string.format("combat :: %s :: %s :: x%d", tostring(c.k), cv, tonumber(c.n) or 1)
    end
    for k, n in pairs(type(d.combatSkip) == "table" and d.combatSkip or {}) do
        out[#out + 1] = string.format("combatskip :: %s :: x%d", tostring(k), tonumber(n) or 1)
    end
    for _, l in ipairs(F.DiagLines and F.DiagLines() or {}) do
        out[#out + 1] = l
    end
    return table.concat(out, " ;; ")
end

-- what the report is about, in the words a player knows: kind of the row -> a group
local GROUP = { npc = "npc", object = "npc", quest = "quest", qtext = "quest", qold = "quest", obj = "quest",
    spell = "spell", tpl = "spell", tip = "spell", zone = "zone", ui = "ui", sys = "sys", alert = "sys",
    dlg = "talk", say = "talk", book = "talk" }
local ORDER = { "npc", "quest", "spell", "zone", "ui", "sys", "talk", "other" }

-- group -> number of rows in the list
function B.Counts()
    F:MissFresh()
    local c = {}
    local miss = F.db and F.db.miss
    for _, e in pairs(type(miss) == "table" and miss or {}) do
        local g = GROUP[tostring(e.k)] or "other"
        c[g] = (c[g] or 0) + 1
    end
    return c
end

-- "2 NPC names, 3 quest texts, 11 spells and buffs" (the biggest four groups)
function B.Summary()
    local c = B.Counts()
    local list = {}
    for _, g in ipairs(ORDER) do
        if (c[g] or 0) > 0 then
            list[#list + 1] = { g, c[g] }
        end
    end
    if #list == 0 then
        return S("pop_none")
    end
    table.sort(list, function(a, b)
        if a[2] ~= b[2] then
            return a[2] > b[2]
        end
        return a[1] < b[1]
    end)
    local kinds = (L.BC and L.BC.kinds) or {}
    local parts = {}
    for i = 1, math.min(4, #list) do
        parts[#parts + 1] = string.format(S("pop_fmt"), list[i][2], kinds[list[i][1]] or "?")
    end
    local s = table.concat(parts, S("pop_sep"))
    if #list > 4 then
        s = s .. S("pop_sep") .. S("pop_more")
    end
    return s
end

-- ------------------------------------------------------------------ pieces
-- a frame of four lines around its parent look; Paint(r,g,b) colours it, SetA(a) fades it
local function make_edge(parent, thick)
    local f = CreateFrame("Frame", nil, parent)
    f:SetFrameLevel(parent:GetFrameLevel() + 6)
    local e = {}
    for i = 1, 4 do
        e[i] = f:CreateTexture(nil, "OVERLAY")
    end
    e[1]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    e[1]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    e[1]:SetHeight(thick)
    e[2]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    e[2]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    e[2]:SetHeight(thick)
    e[3]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    e[3]:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    e[3]:SetWidth(thick)
    e[4]:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    e[4]:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    e[4]:SetWidth(thick)
    function f:Paint(r, g, b)
        for i = 1, 4 do
            e[i]:SetColorTexture(r, g, b, 1)
        end
    end
    function f:SetA(a)
        for i = 1, 4 do
            e[i]:SetAlpha(a)
        end
    end
    f:Paint(C.gold[1], C.gold[2], C.gold[3])
    f:SetA(0.45)
    return f
end

-- the blink: always (the demo in the intro) or while `flash` has time left (the real icon)
local function pulse(edge, always)
    edge.t = 0
    edge.hot = false
    edge:SetScript("OnUpdate", function(self, el)
        local hot = always
        if not always and flash > 0 then
            flash = flash - el
            hot = true
        end
        if hot then
            self.t = self.t + el
            if not self.hot then
                self.hot = true
                self:Paint(0.35, 0.9, 0.4)
            end
            self:SetA(0.2 + 0.8 * math.abs(math.sin(self.t * 5)))
        elseif self.hot then
            self.hot = false
            self.t = 0
            self:Paint(C.gold[1], C.gold[2], C.gold[3])
            self:SetA(0.45)
        end
    end)
end

-- a read-only one-line box that selects its text on focus
local function code_box(parent, w)
    UI.Glass(parent, 0.6)
    local eb = CreateFrame("EditBox", nil, parent)
    eb:SetMultiLine(false)
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(0)
    eb:SetFont(F.FONT, 11, "")
    eb:SetTextColor(C.text[1], C.text[2], C.text[3])
    eb:SetSize(w - 14, 22)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -2)
    eb:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    eb:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    -- 1.2.2 (the owner 27 Nov: the character could not walk): a box that keeps the focus keeps every key. Ctrl+C
    -- is what the player came for: right after it the focus goes back to the game
    eb:SetScript("OnKeyDown", function(self, key)
        if key == "C" and IsControlKeyDown and IsControlKeyDown() then
            F.After(0.15, function()
                self:ClearFocus()
            end)
        end
    end)
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
    return eb
end

-- 1.2.2 (the owner 27 Nov: a page over the settings window let the settings show through): a solid
-- underlay, the glass over it is only the look
local function solid(f)
    local t = f:CreateTexture(nil, "BACKGROUND")
    t:SetAllPoints()
    t:SetColorTexture(C.bg1[1], C.bg1[2], C.bg1[3], 1)
end

local function glyph_icon(parent, size)
    local g = UI.Tex(parent, "ARTWORK", "icon")
    g:SetSize(size, size)
    g:SetPoint("CENTER", parent, "CENTER", 0, 0)
    return g
end

local function badge_on(parent)
    local badge = CreateFrame("Frame", nil, parent)
    badge:SetSize(20, 14)
    badge:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 7, -5)
    badge:SetFrameLevel(parent:GetFrameLevel() + 8)
    local bt = badge:CreateTexture(nil, "BACKGROUND")
    bt:SetAllPoints()
    bt:SetColorTexture(0.16, 0.5, 0.2, 0.95)
    badge.count = UI.Latin(badge, 10, { 1, 1, 1 }, "CENTER")
    badge.count:SetPoint("CENTER", badge, "CENTER", 0, 0)
    return badge
end

-- ------------------------------------------------------------------ the icon
local function save_pos(f)
    local s = store()
    if not s then
        return
    end
    local okc, x, y = pcall(f.GetCenter, f)
    local oku, ux, uy = pcall(UIParent.GetCenter, UIParent)
    if okc and oku and type(x) == "number" and type(y) == "number" and type(ux) == "number" and type(uy) == "number" then
        s.x, s.y = math.floor(x - ux + 0.5), math.floor(y - uy + 0.5)
    end
end

local function place(f)
    local s = store() or {}
    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "CENTER", tonumber(s.x) or 420, tonumber(s.y) or 250)
end

function B.Tip(owner)
    GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
    GameTooltip:AddDoubleLine("WoWFA", "v" .. tostring(F.VERSION), C.gold[1], C.gold[2], C.gold[3], C.muted[1], C.muted[2], C.muted[3])
    T.TipLine(GameTooltip, S("tip_title"), C.goldLight)
    local n = total()
    if n > 0 then
        T.TipLine(GameTooltip, string.format(S("tip_count"), n), C.green)
    else
        T.TipLine(GameTooltip, S("tip_none"), C.muted)
    end
    T.TipLine(GameTooltip, S("tip_click"), C.text)
    T.TipLine(GameTooltip, S("tip_right"), C.muted)
    T.TipLine(GameTooltip, S("tip_drag"), C.muted)
    GameTooltip:Show()
end

function B.Update()
    if not icon then
        return
    end
    local n = total()
    icon:SetShown(B.IsOn())
    icon.badge:SetShown(n > 0)
    icon.badge.count:SetText(n > 99 and "99+" or tostring(n))
    icon:SetAlpha(n > 0 and 1 or 0.7)
end

local function hide_menu()
    if menu then
        menu:Hide()
    end
    if catcher then
        catcher:Hide()
    end
end

local function build_icon()
    if icon then
        return icon
    end
    local b = CreateFrame("Button", nil, UIParent)
    b:SetSize(SIZE, SIZE)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(20)
    b:SetClampedToScreen(true)
    b:SetMovable(true)
    b:EnableMouse(true)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(C.bg1[1], C.bg1[2], C.bg1[3], 0.88)
    b.glyph = glyph_icon(b, SIZE - 10)
    b.edge = make_edge(b, 2)
    b.edge:SetPoint("TOPLEFT", b, "TOPLEFT", -2, 2)
    b.edge:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 2, -2)
    pulse(b.edge, false)
    b.badge = badge_on(b)
    b:SetScript("OnDragStart", function(self)
        if win then
            win:Hide() -- the page is stuck to the icon: it closes while the icon moves
        end
        self:StartMoving()
    end)
    b:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.movedAt = GetTime()
        save_pos(self)
    end)
    b:SetScript("OnClick", function(self, button)
        if self.movedAt and GetTime() - self.movedAt < 0.25 then
            return -- the mouse-up that ends a drag is no click
        end
        if button == "RightButton" then
            if win then
                win:Hide()
            end
            B.Menu(self)
        else
            hide_menu()
            B.TogglePage()
        end
    end)
    b:SetScript("OnEnter", function(self)
        local ok, err = pcall(B.Tip, self)
        if not ok then
            F:LogError("ui", err)
        end
    end)
    b:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    place(b)
    b:Hide()
    icon = b
    return b
end

-- the blink after a NEW find
function B.Flash()
    if icon and B.IsOn() then
        flash = FLASH_SEC
        if icon.edge then
            icon.edge.t = 0
        end
    end
end

function B.Flashing()
    return flash > 0
end

function B.Frame()
    return icon
end

function B.Set(v)
    local s = store()
    if not s then
        return
    end
    s.on = v and true or false
    if s.on then
        build_icon()
        lastN = total()
    else
        hide_menu()
        flash = 0
        if win then
            win:Hide()
        end
    end
    B.Update()
    if win and win:IsShown() then
        B.RefreshWindow()
    end
    F:Fire("options", "beacon")
end

-- ------------------------------------------------------------------ the right-click menu
local function build_menu()
    if menu then
        return
    end
    catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints(UIParent)
    catcher:SetFrameStrata("FULLSCREEN_DIALOG")
    catcher:SetFrameLevel(1)
    catcher:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    catcher:SetScript("OnClick", hide_menu)
    catcher:Hide()
    menu = CreateFrame("Frame", nil, UIParent)
    menu:SetSize(214, 108)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetFrameLevel(10)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
    solid(menu)
    UI.Glass(menu, 0.97)
    F.EscClose(menu)
    menu:SetScript("OnHide", function()
        if catcher then
            catcher:Hide()
        end
    end)
    local function item(i, key, fn)
        local b = UI.Button(menu, S(key), 198, 26, function()
            hide_menu()
            fn()
        end)
        b:SetPoint("TOP", menu, "TOP", 0, -8 - (i - 1) * 32)
        return b
    end
    menu.open = item(1, "menu_open", function()
        B.OpenWindow()
    end)
    menu.panel = item(2, "menu_panel", function()
        if F.OpenPanel then
            F.OpenPanel("health")
        end
    end)
    menu.hide = item(3, "menu_hide", function()
        B.Set(false)
        if F.Toast and F.db and F.db.toast then
            F.Toast(S("off_note"))
        end
    end)
    menu:Hide()
end

function B.Menu(owner)
    build_menu()
    menu:ClearAllPoints()
    menu:SetPoint("TOPRIGHT", owner or UIParent, "BOTTOMRIGHT", 0, -4)
    catcher:Show()
    menu:Show()
end

function B.MenuFrame()
    return menu
end

-- ------------------------------------------------------------------ the small page by the icon
function B.RefreshWindow()
    if not win then
        return
    end
    win.summary:SetFa(B.Summary(), 296)
    if win.mode ~= "site" then
        win.box:SetFixed(B.ReportText())
    end
end

-- beside the icon: to its right when the icon is in the left half of the screen, else to its left;
-- hanging from the icon's top edge in the upper half, standing on its bottom edge in the lower half
local function anchor_page(f)
    f:ClearAllPoints()
    if not (icon and icon:IsShown()) then
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
        return
    end
    local okc, x, y = pcall(icon.GetCenter, icon)
    local oku, ux, uy = pcall(UIParent.GetCenter, UIParent)
    local leftHalf = okc and oku and type(x) == "number" and type(ux) == "number" and x < ux
    local lowHalf = okc and oku and type(y) == "number" and type(uy) == "number" and y < uy
    local v = lowHalf and "BOTTOM" or "TOP"
    if leftHalf then
        f:SetPoint(v .. "LEFT", icon, v .. "RIGHT", 8, 0)
    else
        f:SetPoint(v .. "RIGHT", icon, v .. "LEFT", -8, 0)
    end
end

-- 1.2.2 (the owner 27 Nov: "it should copy by itself on a click"): when the client has a copy function the
-- text goes to the clipboard at once. Without one the box is selected and the player presses Ctrl+C.
function B.ToClipboard(text)
    if type(CopyToClipboard) ~= "function" or type(text) ~= "string" then
        return false
    end
    local ok = pcall(CopyToClipboard, text)
    return ok == true
end

local function build_window()
    if win then
        return win
    end
    local W = 320
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(W, 196)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    f:SetFrameStrata("FULLSCREEN_DIALOG") -- above the settings window
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    solid(f)
    UI.Glass(f, 0.97)
    F.EscClose(f)
    local x = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    x:SetSize(24, 24)
    x:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
    x:SetScript("OnClick", function()
        f:Hide()
    end)
    f.head = UI.Text(f, 12, C.goldLight)
    f.head:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -12)
    f.head:SetFa(S("pop_head"), 270)
    f.summary = UI.Text(f, 13, C.text)
    f.summary:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -52)
    f.summary:SetFa(S("pop_none"), 296)
    local bx = CreateFrame("Frame", nil, f)
    bx:SetSize(W - 24, 28)
    bx:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -102)
    f.box = code_box(bx, W - 24)
    f.copy = UI.Button(f, S("pop_copy"), 112, 28, function()
        f.mode = "report"
        B.RefreshWindow()
        local text = B.ReportText()
        f.box:SetFixed(text)
        local done = B.ToClipboard(text)
        if not done then
            f.box:SetFocus()
            f.box:HighlightText()
        end
        f.msg:SetFa(done and S("pop_done") or S("pop_copied"), 296)
    end)
    f.copy:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -136)
    f.site = UI.Button(f, S("pop_site"), 100, 28, function()
        f.mode = "site"
        local url = tostring(F.SITE) .. "/report"
        f.box:SetFixed(url)
        local done = B.ToClipboard(url)
        if not done then
            f.box:SetFocus()
            f.box:HighlightText()
        end
        f.msg:SetFa(done and S("pop_site_done") or S("pop_site_copied"), 296)
    end)
    f.site:SetPoint("RIGHT", f.copy, "LEFT", -6, 0)
    f.clear = UI.Button(f, S("pop_clear"), 72, 28, function()
        F:ClearMiss()
        lastN = 0
        f.mode = "report"
        B.Update()
        B.RefreshWindow()
        f.msg:SetFa(" ", 296)
    end)
    f.clear:SetPoint("RIGHT", f.site, "LEFT", -6, 0)
    f.msg = UI.Text(f, 11, C.green)
    f.msg:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -172)
    f.msg:SetFa(" ", 296)
    f:SetScript("OnShow", function()
        f.mode = "report"
        B.RefreshWindow()
        f.msg:SetFa(" ", 296)
    end)
    f:SetScript("OnHide", function()
        f.box:ClearFocus()
    end)
    f:Hide()
    win = f
    return f
end

function B.OpenWindow()
    local f = build_window()
    anchor_page(f)
    f:Show()
    B.RefreshWindow()
end

function B.TogglePage()
    if win and win:IsShown() then
        win:Hide()
    else
        B.OpenWindow()
    end
end

function B.Window()
    return win
end

-- ------------------------------------------------------------------ the one-time intro (3 slides)
local function build_intro()
    if intro then
        return intro
    end
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(420, 268)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 110)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    solid(f)
    UI.Glass(f, 0.97)
    F.EscClose(f) -- Esc = not now
    f.title = UI.Text(f, 16, C.gold)
    f.title:SetPoint("TOPRIGHT", f, "TOPRIGHT", -18, -16)
    f.body = UI.Text(f, 13, C.text)
    f.body:SetPoint("TOPRIGHT", f, "TOPRIGHT", -18, -50)
    f.count = UI.Latin(f, 11, C.muted, "LEFT")
    f.count:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -20)
    -- the demo of slide 2: the real icon look, blinking green all the time
    local demo = CreateFrame("Frame", nil, f)
    demo:SetSize(SIZE, SIZE)
    demo:SetPoint("TOP", f, "TOP", 0, -128)
    local dbg = demo:CreateTexture(nil, "BACKGROUND")
    dbg:SetAllPoints()
    dbg:SetColorTexture(C.bg1[1], C.bg1[2], C.bg1[3], 0.88)
    glyph_icon(demo, SIZE - 10)
    demo.edge = make_edge(demo, 2)
    demo.edge:SetPoint("TOPLEFT", demo, "TOPLEFT", -2, 2)
    demo.edge:SetPoint("BOTTOMRIGHT", demo, "BOTTOMRIGHT", 2, -2)
    pulse(demo.edge, true)
    demo.badge = badge_on(demo)
    demo.badge.count:SetText("3")
    demo:Hide()
    f.demo = demo
    f.dots = {}
    for i = 1, 3 do
        local d = f:CreateTexture(nil, "OVERLAY")
        d:SetSize(8, 8)
        d:SetPoint("BOTTOM", f, "BOTTOM", (i - 2) * 16, 58)
        d:SetColorTexture(C.gold[1], C.gold[2], C.gold[3], 0.3)
        f.dots[i] = d
    end
    f.note = UI.Text(f, 11, C.muted)
    f.note:SetPoint("TOPRIGHT", f, "TOPRIGHT", -18, -186)
    f.note:SetFa(" ", 384)
    f.pri = UI.Button(f, S("intro_next"), 170, 28, function()
        local slides = L.BC and L.BC.slides or {}
        if f.i < #slides then
            f.show(f.i + 1)
        else
            B.Set(true)
            f:Hide()
        end
    end)
    f.pri:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 14)
    f.back = UI.Button(f, S("intro_back"), 90, 28, function()
        f.show(f.i - 1)
    end)
    f.back:SetPoint("RIGHT", f.pri, "LEFT", -8, 0)
    f.later = UI.Button(f, S("intro_later"), 100, 28, function()
        f:Hide()
    end)
    f.later:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 14, 14)

    function f.show(i)
        local slides = L.BC and L.BC.slides or {}
        local n = #slides
        if n == 0 then
            return
        end
        f.i = math.max(1, math.min(n, i))
        local s = slides[f.i]
        f.title:SetFa(s.t or " ", 330)
        f.body:SetFa(s.b or " ", 384)
        f.count:SetText(tostring(f.i) .. " / " .. tostring(n))
        f.demo:SetShown(f.i == 2)
        for k = 1, 3 do
            f.dots[k]:SetColorTexture(C.gold[1], C.gold[2], C.gold[3], k == f.i and 1 or 0.3)
        end
        if f.i == n then
            f.pri:SetLabel(S("intro_enable"))
            f.note:SetFa(S("intro_note"), 384)
        else
            f.pri:SetLabel(S("intro_next"))
            f.note:SetFa(" ", 384)
        end
        f.back:SetShown(f.i > 1)
    end
    f:Hide()
    intro = f
    return f
end

-- once per player (db.beacon.asked); force = the test / a manual call
function B.ShowIntro(force)
    local s = store()
    if not s or (s.asked and not force) then
        return
    end
    s.asked = true
    local f = build_intro()
    f:Show()
    f.show(1)
end

function B.IntroFrame()
    return intro
end

local function try_intro(tries)
    local s = store()
    if not s or s.asked then
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        if tries < 12 then
            F.After(20, function()
                try_intro(tries + 1)
            end)
        end
        return
    end
    local ok, err = pcall(B.ShowIntro)
    if not ok then
        F:LogError("ui", err)
    end
end

-- ------------------------------------------------------------------ wiring
F:Listen("login", function()
    lastN = total()
    local ok, err = pcall(function()
        if B.IsOn() then
            build_icon()
            B.Update()
        end
    end)
    if not ok then
        F:LogError("ui", err)
    end
    F.After(25, function()
        try_intro(0)
    end)
end)

-- a NEW row in the report list: the frame blinks once; a clear of the list only updates the counter
F:Listen("miss", function()
    local n = total()
    if n > lastN then
        B.Flash()
    end
    lastN = n
    B.Update()
    if win and win:IsShown() then
        B.RefreshWindow()
    end
end)

F:Listen("state", function()
    B.Update()
end)

-- 1.2.2 (the owner 27 Nov: holding Shift over some things the tooltip went empty): a modifier key makes the
-- game rebuild the tooltip with the function that built it. Ours is built line by line (no such function), so
-- it came back empty: one frame after the key, our own build runs again
F:On("MODIFIER_STATE_CHANGED", nil, function()
    F.After(0, function()
        local ok, err = pcall(function()
            if icon and icon:IsShown() and GameTooltip and GameTooltip:IsShown() and GameTooltip:GetOwner() == icon then
                B.Tip(icon)
            end
        end)
        if not ok then
            F:LogError("ui", err)
        end
    end)
end)
