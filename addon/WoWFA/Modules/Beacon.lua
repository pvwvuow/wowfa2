-- WoWFA Forever 1.2.2 - the floating report icon (the owner 27 Nov): a small icon on the player's
-- screen with a counter and a thin frame. Every time the addon meets a text it can not translate
-- (a NEW row in the report list) the frame flashes green once. A click opens a small window with
-- the report text ready to copy and send to wowfarsi.ir/report, a right click opens a tiny menu
-- (open, settings, hide), a drag moves it. It is OFF until the player says yes in the one-time
-- intro (db.beacon.asked); the same switch is at the top of Settings > Status and report.
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
    return table.concat(out, " ;; ")
end

-- ------------------------------------------------------------------ pieces
-- a frame of four lines around its parent; Paint(r,g,b) colours it, SetA(a) fades it
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

-- a read-only (or editable) one-line box that selects its text on focus
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
            B.Menu(self)
        else
            B.OpenWindow()
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
    catcher:SetFrameStrata("DIALOG")
    catcher:SetFrameLevel(1)
    catcher:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    catcher:SetScript("OnClick", hide_menu)
    catcher:Hide()
    menu = CreateFrame("Frame", nil, UIParent)
    menu:SetSize(214, 108)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel(10)
    menu:SetClampedToScreen(true)
    menu:EnableMouse(true)
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

-- ------------------------------------------------------------------ the report window
function B.RefreshWindow()
    if not win then
        return
    end
    local n = total()
    local on = B.IsOn()
    win.status:SetFa(on and S("win_on") or S("win_off"), 250)
    local c = on and C.green or C.orange
    win.status:SetTextColor(c[1], c[2], c[3])
    win.toggle:SetLabel(on and S("win_turn_off") or S("win_turn_on"))
    win.count:SetFa(n > 0 and string.format(S("win_count"), n) or S("win_none"), 430)
    win.box:SetFixed(B.ReportText())
end

local function build_window()
    if win then
        return win
    end
    local W = 470
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(W, 350)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    f:SetFrameStrata("DIALOG")
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
    UI.Glass(f, 0.97)
    F.EscClose(f)
    local x = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    x:SetSize(28, 28)
    x:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    x:SetScript("OnClick", function()
        f:Hide()
    end)
    f.title = UI.Text(f, 15, C.gold)
    f.title:SetPoint("TOPRIGHT", f, "TOPRIGHT", -40, -16)
    f.title:SetFa(S("win_title"), 380)
    -- the switch, big and readable at the top: the player sees at once it can be turned off
    f.status = UI.Text(f, 14, C.green)
    f.status:SetPoint("TOPRIGHT", f, "TOPRIGHT", -18, -56)
    f.status:SetFa(S("win_on"), 250)
    f.toggle = UI.Button(f, S("win_turn_off"), 170, 26, function()
        B.Set(not B.IsOn())
    end)
    f.toggle:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -52)
    f.count = UI.Text(f, 13, C.goldLight)
    f.count:SetPoint("TOPRIGHT", f, "TOPRIGHT", -18, -96)
    f.count:SetFa(S("win_none"), 430)
    local bx = CreateFrame("Frame", nil, f)
    bx:SetSize(W - 32, 28)
    bx:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -126)
    f.box = code_box(bx, W - 32)
    f.pick = UI.Button(f, S("win_select"), 200, 28, function()
        B.RefreshWindow()
        f.box:SetFocus()
        f.box:HighlightText()
        f.msg:SetFa(S("win_copied"), 430)
    end)
    f.pick:SetPoint("TOPRIGHT", f, "TOPRIGHT", -18, -166)
    f.clear = UI.Button(f, S("win_clear"), 150, 28, function()
        F:ClearMiss()
        lastN = 0
        B.Update()
        B.RefreshWindow()
        f.msg:SetFa(" ", 430)
    end)
    f.clear:SetPoint("RIGHT", f.pick, "LEFT", -8, 0)
    f.msg = UI.Text(f, 12, C.green)
    f.msg:SetPoint("TOPRIGHT", f, "TOPRIGHT", -18, -204)
    f.msg:SetFa(" ", 430)
    f.steps = UI.Text(f, 12, C.muted)
    f.steps:SetPoint("TOPRIGHT", f, "TOPRIGHT", -18, -232)
    f.steps:SetFa(S("win_steps"), 430)
    local ub = CreateFrame("Frame", nil, f)
    ub:SetSize(W - 32, 28)
    ub:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 16)
    f.url = code_box(ub, W - 32)
    f.url:SetFixed(tostring(F.SITE) .. "/report")
    f:SetScript("OnShow", function()
        B.RefreshWindow()
        f.msg:SetFa(" ", 430)
    end)
    f:Hide()
    win = f
    return f
end

function B.OpenWindow()
    local f = build_window()
    f:Show()
    B.RefreshWindow()
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
    f:SetFrameStrata("DIALOG")
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
