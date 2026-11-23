-- WoWFA Forever - widget kit in the site / retail panel style:
-- smoked glass, fading 1px gold lines, diamond toggles, sigil buttons.
-- Everything is plain (insecure) frames: safe to show in combat.

local F = WoWFAF
local T = F.T
local C = F.C
local UI = {}
F.UI = UI

local function tex(parent, layer, file)
    local t = parent:CreateTexture(nil, layer or "ARTWORK")
    if file then
        t:SetTexture(F.MEDIA .. file)
    end
    return t
end
UI.Tex = tex

local function gradient(t, dir, r1, g1, b1, a1, r2, g2, b2, a2)
    if CreateColor and t.SetGradient then
        local ok = pcall(t.SetGradient, t, dir, CreateColor(r1, g1, b1, a1), CreateColor(r2, g2, b2, a2))
        if ok then
            return
        end
    end
    if t.SetGradientAlpha then
        pcall(t.SetGradientAlpha, t, dir, r1, g1, b1, a1, r2, g2, b2, a2)
    end
end

-- gold hairline (horizontal or vertical), faded at the ends by the texture
function UI.Line(parent, vertical, alpha)
    local t = tex(parent, "BORDER", vertical and "line_v" or "line_h")
    t:SetVertexColor(C.gold[1], C.gold[2], C.gold[3], alpha or 0.45)
    if vertical then
        t:SetWidth(1)
    else
        t:SetHeight(1)
    end
    return t
end

function UI.Glass(f, alpha)
    local bg = tex(f, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(C.bg1[1], C.bg1[2], C.bg1[3], alpha or 0.94)
    local sheen = tex(f, "BACKGROUND")
    sheen:SetPoint("TOPLEFT")
    sheen:SetPoint("TOPRIGHT")
    sheen:SetHeight(120)
    sheen:SetColorTexture(1, 1, 1, 1)
    gradient(sheen, "VERTICAL", C.bg2[1], C.bg2[2], C.bg2[3], 0, 0.25, 0.20, 0.10, 0.22)
    local top = UI.Line(f, false, 0.6)
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    local bottom = UI.Line(f, false, 0.35)
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    local left = UI.Line(f, true, 0.35)
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOMLEFT")
    local right = UI.Line(f, true, 0.35)
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOMRIGHT")
    for _, p in ipairs({ "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" }) do
        local d = tex(f, "OVERLAY", "diamond")
        d:SetSize(7, 7)
        d:SetPoint("CENTER", f, p, 0, 0)
        d:SetVertexColor(C.gold[1], C.gold[2], C.gold[3], 0.8)
    end
end

-- Persian font string (re-rendered when mode / font size changes)
function UI.Text(parent, size, color, justify, layer)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY")
    fs:SetFont(F.FONT, size or T.Size(), "")
    -- inbox/44 D: Persian multi-line breathing room scales with the font
    fs:SetSpacing(T.Spacing(size))
    fs.wfaSize = size
    fs.wfaJustify = justify or "RIGHT"
    color = color or C.text
    fs:SetTextColor(color[1], color[2], color[3])
    fs.SetFa = function(self, text, width)
        T.Set(self, text, width)
    end
    return fs
end

-- Latin font string (numbers, builds, English notes)
function UI.Latin(parent, size, color, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(F.FONT, size or 12, "")
    color = color or C.muted
    fs:SetTextColor(color[1], color[2], color[3])
    fs:SetJustifyH(justify or "LEFT")
    return fs
end

local function hover(b)
    local h = tex(b, "HIGHLIGHT")
    h:SetAllPoints()
    h:SetColorTexture(C.gold[1], C.gold[2], C.gold[3], 0.07)
end

-- sigil button: framed label
function UI.Button(parent, text, w, h, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w or 120, h or 24)
    local bg = tex(b, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(C.bg2[1], C.bg2[2], C.bg2[3], 0.9)
    for _, side in ipairs({ "TOP", "BOTTOM" }) do
        local l = UI.Line(b, false, 0.55)
        l:SetPoint(side .. "LEFT")
        l:SetPoint(side .. "RIGHT")
    end
    hover(b)
    b.label = UI.Text(b, 13, C.goldLight, "CENTER")
    b.label:SetPoint("CENTER")
    b.SetLabel = function(self, t)
        self.label:SetFa(t, (w or 120) - 8)
    end
    b:SetLabel(text)
    b:SetScript("OnClick", function(self, button)
        if onClick then
            onClick(self, button)
        end
    end)
    return b
end

-- diamond toggle row: [desc / label] [diamond]  (right to left)
function UI.Toggle(parent, width, label, desc, get, set)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(width, desc and 50 or 32)
    hover(row)
    row.box = tex(row, "ARTWORK", "diamond_hollow")
    row.box:SetSize(14, 14)
    row.box:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -6)
    row.fill = tex(row, "OVERLAY", "diamond")
    row.fill:SetSize(8, 8)
    row.fill:SetPoint("CENTER", row.box, "CENTER")
    row.label = UI.Text(row, 14, C.text)
    row.label:SetPoint("TOPRIGHT", row, "TOPRIGHT", -26, -4)
    row.label:SetWidth(width - 160)
    row.label:SetFa(label, width - 160)
    -- inbox/47 D: the state also as text next to the diamond
    row.state = UI.Text(row, 12, C.muted)
    row.state:SetPoint("LEFT", row, "LEFT", 6, 0)
    row.state:SetWidth(80)
    row.hair = tex(row, "BACKGROUND", "solid")
    row.hair:SetColorTexture(C.hairline[1], C.hairline[2], C.hairline[3], 0.15)
    row.hair:SetSize(width - 20, 1)
    row.hair:SetPoint("BOTTOM", row, "BOTTOM", 0, 1)
    if desc then
        row.desc = UI.Text(row, 12, C.muted)
        row.desc:SetPoint("TOPRIGHT", row.label, "BOTTOMRIGHT", 0, -2)
        row.desc:SetWidth(width - 140)
        row.desc:SetFa(desc, width - 140)
    end
    row.Update = function(self)
        local on = get()
        local dim = self.dimmed
        local c = on and C.gold or C.off
        self.box:SetVertexColor(c[1], c[2], c[3], dim and 0.4 or 1)
        self.fill:SetShown(on and true or false)
        self.fill:SetVertexColor(C.goldLight[1], C.goldLight[2], C.goldLight[3], dim and 0.4 or 1)
        local t = (on and not dim) and C.text or C.muted
        self.label:SetTextColor(t[1], t[2], t[3])
        if self.state then
            local st = F.L and (on and F.L.st_on or F.L.st_off) or (on and "روشن" or "خاموش")
            -- Brain 51-A1: Persian ONLY through the shaper (a raw SetText of
            -- Persian renders reversed and unjoined in the client)
            self.state:SetFa(st, 80)
            self.state:SetTextColor((on and C.gold or C.muted)[1], (on and C.gold or C.muted)[2], (on and C.gold or C.muted)[3])
        end
    end
    row:SetScript("OnClick", function(self)
        set(not get())
        self:Update()
    end)
    row:Update()
    return row
end

-- option cycler: [button: current option] .... [label]
function UI.Cycler(parent, width, label, options, get, set)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(width, 32)
    row.n = #options -- Brain 51-A4: the tests click a full cycle
    row.label = UI.Text(row, 14, C.text)
    row.label:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    row.label:SetWidth(width - 200)
    row.label:SetFa(label, width - 200)
    row.btn = UI.Button(row, options[get()] or "?", 180, 22, function()
        local v = get() % #options + 1
        set(v)
        row:Update()
    end)
    row.btn:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.Update = function(self)
        self.btn:SetLabel(options[get()] or "?")
    end
    return row
end

-- inbox/29 D: a plain slider (no new art: a hairline track + the diamond thumb
-- via SetThumbTexture), label on the right (RTL), live value on the left.
-- Brain review (#139):
--   * a Lua-created Slider is VERTICAL and mouse-disabled by default (only the
--     XML templates set orientation / enableMouse) - a 150x16 vertical slider
--     can not be dragged sideways at all. Both are set explicitly.
--   * while the thumb is DRAGGED only the value label follows; set() runs once
--     on release. The panel's set() rescales the very window holding the
--     slider - live, the thumb would run away under the cursor (feedback).
--   * the label text is ONE argument (gsub returns two values).
function UI.Slider(parent, width, label, min, max, step, get, set)
    step = step or 0.05
    local function snap(v)
        v = math.floor(v / step + 0.5) * step
        return math.min(max, math.max(min, v))
    end
    local function fmt(v)
        return (string.gsub(string.format("%.2f", v), "0$", ""))
    end
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(width, 30)
    row.label = UI.Text(row, 14, C.text)
    row.label:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    row.label:SetWidth(width - 240)
    row.label:SetFa(label, width - 240)
    row.val = UI.Latin(row, 12, C.goldLight, "CENTER")
    row.val:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.val:SetWidth(44)
    local slider = CreateFrame("Slider", nil, row)
    slider:SetSize(150, 16)
    slider:SetPoint("LEFT", row, "LEFT", 52, 0)
    if slider.SetOrientation then
        pcall(slider.SetOrientation, slider, "HORIZONTAL")
    end
    if slider.EnableMouse then
        slider:EnableMouse(true)
    end
    slider:SetMinMaxValues(min, max)
    if slider.SetObeyStepOnDrag then
        pcall(slider.SetObeyStepOnDrag, slider, true)
    end
    if slider.SetValueStep then
        pcall(slider.SetValueStep, slider, step)
    end
    local track = UI.Tex(slider, "BACKGROUND")
    track:SetHeight(3)
    track:SetPoint("LEFT", slider, "LEFT", 2, 0)
    track:SetPoint("RIGHT", slider, "RIGHT", -2, 0)
    track:SetColorTexture(C.bg2[1], C.bg2[2], C.bg2[3], 1)
    local thumb = UI.Tex(slider, "ARTWORK", "diamond")
    thumb:SetSize(12, 12)
    thumb:SetVertexColor(C.gold[1], C.gold[2], C.gold[3])
    if slider.SetThumbTexture then
        pcall(slider.SetThumbTexture, slider, thumb)
    end
    slider:SetValue(get() or min)
    local dragging, pending = false, nil
    local function flush()
        dragging = false
        if pending ~= nil then
            local v = pending
            pending = nil
            set(v)
        end
    end
    slider:SetScript("OnValueChanged", function(self, v)
        v = snap(v)
        row.val:SetText(fmt(v))
        if dragging then
            pending = v
        else
            set(v)
        end
    end)
    slider:SetScript("OnMouseDown", function()
        dragging = true
    end)
    slider:SetScript("OnMouseUp", flush)
    -- the window closed mid-drag: no OnMouseUp will come - apply now
    slider:SetScript("OnHide", flush)
    row.slider = slider
    row.Update = function(self)
        slider:SetValue(get() or min)
        row.val:SetText(fmt(get() or min))
    end
    return row
end

-- vertical scroll page, content = page.child.
-- Brain 57 (the owner's r6 test: "many things in the settings window do not
-- scroll"):
--   * the bar used to be a picture only - it is a DRAG handle now (a 12 px
--     strip over the gold line, parented to the window so the scroll frame
--     never clips it; it hides with its page);
--   * sf:Fit() grows the child to the REAL laid-out content (the client knows
--     every region rect one frame after layout): a page whose builder
--     under-counted its height still scrolls to its last row. Fit only ever
--     grows; the mock has no layout (GetTop = nil) and skips it;
--   * the scroll offset clamps when the child shrinks (a shorter view).
function UI.ScrollPage(parent, width, height)
    local sf = CreateFrame("ScrollFrame", nil, parent)
    sf:SetSize(width, height)
    local child = CreateFrame("Frame", nil, sf)
    child:SetSize(width, height)
    sf:SetScrollChild(child)
    sf.child = child
    local function max_scroll()
        return math.max(0, (tonumber(child:GetHeight()) or 0) - (tonumber(sf:GetHeight()) or 0))
    end
    local function scroll_to(v)
        sf:SetVerticalScroll(math.min(max_scroll(), math.max(0, v)))
    end
    sf.ScrollTo = function(self, v)
        scroll_to(v)
    end
    sf:EnableMouseWheel(true)
    sf:SetScript("OnMouseWheel", function(self, delta)
        scroll_to((tonumber(self:GetVerticalScroll()) or 0) - delta * 36)
    end)
    local bar = tex(sf, "OVERLAY")
    bar:SetWidth(2)
    bar:SetColorTexture(C.gold[1], C.gold[2], C.gold[3], 0.35)
    sf.bar = bar
    local thumb = CreateFrame("Button", nil, parent)
    thumb:SetWidth(12)
    if thumb.EnableMouse then
        thumb:EnableMouse(true)
    end
    local grip = tex(thumb, "HIGHLIGHT")
    grip:SetAllPoints()
    grip:SetColorTexture(C.gold[1], C.gold[2], C.gold[3], 0.18)
    thumb:Hide()
    sf.thumb = thumb
    local function cursor_y()
        local _, y = GetCursorPosition()
        local s = tonumber(sf:GetEffectiveScale()) or 1
        if s <= 0 then
            s = 1
        end
        return (tonumber(y) or 0) / s
    end
    local function on_drag(self)
        local d = self.drag
        if not d then
            return
        end
        local h, ch = tonumber(sf:GetHeight()) or 0, tonumber(child:GetHeight()) or 0
        local range = h - (tonumber(self:GetHeight()) or 0)
        if range <= 0 or ch <= h then
            return
        end
        -- the cursor moving DOWN (smaller y) scrolls down
        scroll_to(d.v + (d.y - cursor_y()) * (ch - h) / range)
    end
    local function stop(self)
        self.drag = nil
        self:SetScript("OnUpdate", nil)
    end
    thumb:SetScript("OnMouseDown", function(self)
        self.drag = { y = cursor_y(), v = tonumber(sf:GetVerticalScroll()) or 0 }
        self:SetScript("OnUpdate", on_drag)
    end)
    thumb:SetScript("OnMouseUp", stop)
    thumb:SetScript("OnHide", stop)
    sf:HookScript("OnHide", function()
        thumb:Hide()
    end)
    sf.UpdateBar = function(self)
        local h, ch = tonumber(self:GetHeight()) or 0, tonumber(child:GetHeight()) or 0
        local v = tonumber(self:GetVerticalScroll()) or 0
        if v > max_scroll() then
            v = max_scroll()
            self:SetVerticalScroll(v)
        end
        if ch <= h + 1 then
            bar:Hide()
            thumb:Hide()
            return
        end
        bar:Show()
        local bh = math.max(20, h * h / ch)
        local off = (v / (ch - h)) * (h - bh)
        bar:ClearAllPoints()
        bar:SetHeight(bh)
        bar:SetPoint("TOPLEFT", self, "TOPLEFT", -6, -off)
        thumb:ClearAllPoints()
        thumb:SetHeight(bh)
        thumb:SetPoint("TOPLEFT", self, "TOPLEFT", -11, -off)
        thumb:SetShown(self:IsShown() and true or false)
    end
    -- grow the child to the lowest SHOWN region / frame under it (screen
    -- units, so a scaled child such as the preview tooltip measures right)
    sf.Fit = function(self, pad)
        local top = child:GetTop()
        local cs = tonumber(child:GetEffectiveScale()) or 1
        if type(top) ~= "number" or cs <= 0 then
            return -- no layout yet (the mock / a page never shown)
        end
        top = top * cs
        local low = top
        local function walk(f, depth)
            if depth > 12 then
                return
            end
            local fs = tonumber(f:GetEffectiveScale()) or cs
            for _, r in ipairs({ f:GetRegions() }) do
                if r.IsShown and r:IsShown() then
                    local b = r.GetBottom and r:GetBottom()
                    if type(b) == "number" and b * fs < low then
                        low = b * fs
                    end
                end
            end
            for _, k in ipairs({ f:GetChildren() }) do
                if k.IsShown and k:IsShown() then
                    local ks = tonumber(k:GetEffectiveScale()) or fs
                    local b = k.GetBottom and k:GetBottom()
                    if type(b) == "number" and b * ks < low then
                        low = b * ks
                    end
                    walk(k, depth + 1)
                end
            end
        end
        walk(child, 0)
        local need = math.floor((top - low) / cs + (pad or 14) + 0.5)
        if need > (tonumber(child:GetHeight()) or 0) + 1 then
            child:SetHeight(need)
        end
        self:UpdateBar()
    end
    sf:SetScript("OnVerticalScroll", function(self)
        self:UpdateBar()
    end)
    sf:SetScript("OnScrollRangeChanged", function(self)
        self:UpdateBar()
    end)
    return sf
end

-- section header: gold text + fading line
function UI.Header(parent, text, width)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(width, 28)
    f.text = UI.Text(f, 16, C.gold)
    f.text:SetPoint("RIGHT", f, "RIGHT", -2, 2)
    f.text:SetFa(text, width - 10)
    local l = UI.Line(f, false, 0.4)
    l:SetPoint("BOTTOMLEFT")
    l:SetPoint("BOTTOMRIGHT")
    return f
end

-- --------------------------------------------------------------- toast
local toast, queue = nil, {}
local function show_next()
    local msg = table.remove(queue, 1)
    if not msg then
        return
    end
    toast.text:SetFa(msg, 380)
    toast:SetHeight(math.max(36, toast.text:GetStringHeight() + 18))
    toast.t = 0
    toast:SetAlpha(0)
    toast:Show()
end

function F.Toast(msg)
    if not toast then
        toast = CreateFrame("Button", "WoWFAF_Toast", UIParent)
        toast:SetSize(420, 40)
        toast:SetPoint("TOP", UIParent, "TOP", 0, -140)
        toast:SetFrameStrata("HIGH")
        UI.Glass(toast, 0.9)
        toast.text = UI.Text(toast, 12, C.text, "CENTER")
        toast.text:SetPoint("CENTER")
        toast.text:SetWidth(390)
        toast:SetScript("OnUpdate", function(self, el)
            self.t = self.t + el
            if self.t < 0.3 then
                self:SetAlpha(self.t / 0.3)
            elseif self.t > 7 then
                local a = 1 - (self.t - 7) / 0.8
                if a <= 0 then
                    self:Hide()
                    show_next()
                else
                    self:SetAlpha(a)
                end
            else
                self:SetAlpha(1)
            end
        end)
        toast:SetScript("OnClick", function(self)
            self:Hide()
            if F.OpenPanel then
                F.OpenPanel("health")
            end
            show_next()
        end)
        toast:Hide()
    end
    for _, q in ipairs(queue) do
        if q == msg then
            return
        end
    end
    table.insert(queue, msg)
    if #queue > 5 then
        table.remove(queue, 1)
    end
    if not toast:IsShown() then
        show_next()
    end
end


-- inbox/47 C: a ranged setting row (itemDetail / itemStyle) - the click
-- cycles through the values; the current value renders as gold text
function UI.Choice(parent, width, label, desc, labels, get, set)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(width, desc and 50 or 32)
    hover(row)
    row.values = {}
    row.n = #labels -- Brain 51-A4: the tests click a full cycle
    row.label = UI.Text(row, 14, C.text)
    row.label:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -4)
    row.label:SetWidth(width - 160)
    row.label:SetFa(label, width - 160)
    if desc then
        row.desc = UI.Text(row, 12, C.muted)
        row.desc:SetPoint("TOPRIGHT", row.label, "BOTTOMRIGHT", 0, -2)
        row.desc:SetWidth(width - 160)
        row.desc:SetFa(desc, width - 160)
    end
    row.val = UI.Text(row, 13, C.gold)
    row.val:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -6)
    row.val:SetWidth(150)
    row.hair = tex(row, "BACKGROUND", "solid")
    row.hair:SetColorTexture(C.hairline[1], C.hairline[2], C.hairline[3], 0.15)
    row.hair:SetSize(width - 20, 1)
    row.hair:SetPoint("BOTTOM", row, "BOTTOM", 0, 1)
    row.Update = function(self)
        local v = get()
        -- Brain 51-A1 (the owner's r5 screenshot): the value went through a
        -- raw SetText, so the shaper never ran and the Persian value came out
        -- reversed and unjoined. Every Persian string goes through SetFa.
        self.val:SetFa(labels[v] or tostring(v), 150)
    end
    row:SetScript("OnClick", function(self)
        local v = get()
        local n = #labels
        -- the values are 1..n
        local nv = (v % n) + 1
        set(nv)
        self:Update()
    end)
    row:Update()
    return row
end
