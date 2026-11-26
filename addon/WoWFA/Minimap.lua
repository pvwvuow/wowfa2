-- WoWFA Forever - minimap button (drag around the map, angle saved), the
-- game's Settings entry and the hover summary. The button is created after
-- PLAYER_LOGIN, when the saved settings are known.

local F = WoWFAF
local L = F.L
local T = F.T
local UI = F.UI
local C = F.C

local btn

local function position()
    if not btn then
        return
    end
    local angle = math.rad(F.db.minimap.angle or 200)
    local x, y = math.cos(angle), math.sin(angle)
    local w = (Minimap:GetWidth() or 140) / 2 + 6
    local h = (Minimap:GetHeight() or 140) / 2 + 6
    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    if shape == "SQUARE" then
        -- push the button onto the square edge
        local m = math.max(math.abs(x), math.abs(y))
        x, y = x / m, y / m
        w, h = w - 4, h - 4
    end
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", x * w, y * h)
end

local function update_look()
    if not btn then
        return
    end
    btn:SetShown(not F.db.minimap.hide)
    btn.icon:SetDesaturated(not F.db.enabled)
    btn.icon:SetAlpha(F.db.enabled and 1 or 0.6)
    btn.alert:SetShown(F.db.enabled and F:Issues() > 0)
end

function F.MinimapTooltip(owner)
    -- inbox/29 D: the minimap button tooltip is ONE status line (plus the
    -- title) - the full health page lives in the panel's وضعیت tab
    GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
    GameTooltip:AddDoubleLine("WoWFA", "v" .. F.VERSION, C.gold[1], C.gold[2], C.gold[3], C.muted[1], C.muted[2], C.muted[3])
    local line
    if not F.db.enabled then
        line = L.st_master
    elseif F:Issues() > 0 then
        line = L.mm_issue
    else
        line = L.mm_status
    end
    T.TipLine(GameTooltip, line, F.db.enabled and C.green or C.off)
    GameTooltip:Show()
end

local function build()
    btn = CreateFrame("Button", "WoWFAF_MinimapButton", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    -- The round MiniMap-TrackingBorder (53x53, anchored TOPLEFT) has its hole
    -- centred at (17, -15) from the button's top-left corner, i.e. 1.5 px right
    -- of and 0.5 px above the button centre. The disc and the icon must sit in
    -- THAT hole, not on the frame centre, or the icon looks pushed off-centre.
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(20, 20)
    bg:SetPoint("CENTER", btn, "TOPLEFT", 17, -15)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    btn.icon = UI.Tex(btn, "ARTWORK", "icon")
    btn.icon:SetSize(18, 18)
    btn.icon:SetPoint("CENTER", btn, "TOPLEFT", 17, -15)
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    btn.alert = UI.Tex(btn, "OVERLAY", "dot")
    btn.alert:SetSize(9, 9)
    btn.alert:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -4, -4)
    btn.alert:SetVertexColor(C.orange[1], C.orange[2], C.orange[3])
    btn:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            F:SetEnabled(not F.db.enabled)
            F.Chat(F.db.enabled and L.en.on or L.en.off)
            if F.Toast and F.db.toast then
                F.Toast(F.db.enabled and L.t_on or L.t_off)
            end
        elseif IsShiftKeyDown and IsShiftKeyDown() then
            F.OpenPanel("health")
        else
            F.TogglePanel()
        end
    end)
    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            if not (mx and px and scale and scale > 0) then
                return
            end
            px, py = px / scale, py / scale
            F.db.minimap.angle = math.deg(math.atan2(py - my, px - mx)) % 360
            position()
        end)
    end)
    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    btn:SetScript("OnEnter", function(self)
        F.MinimapTooltip(self)
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    position()
    update_look()
end

-- game Settings entry (Esc > Options > AddOns): a button that opens our panel
local function register_settings()
    local f = CreateFrame("Frame")
    f.name = "WoWFA"
    local title = UI.Latin(f, 20, C.gold, "LEFT")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("WoWFA " .. F.VERSION)
    local b = UI.Button(f, L.open_panel, 200, 28, function()
        if SettingsPanel and SettingsPanel.IsShown and SettingsPanel:IsShown() and HideUIPanel then
            pcall(SettingsPanel.Hide, SettingsPanel) -- 1.1.6: no HideUIPanel (taint)
        end
        if InterfaceOptionsFrame and InterfaceOptionsFrame.IsShown and InterfaceOptionsFrame:IsShown() and HideUIPanel then
            pcall(InterfaceOptionsFrame.Hide, InterfaceOptionsFrame) -- 1.1.6: no HideUIPanel (taint)
        end
        F.OpenPanel("home")
    end)
    b:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    local en = UI.Latin(f, 11, C.muted, "LEFT")
    en:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 0, -8)
    en:SetText("Open the WoWFA panel  (/wowfa)")
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local ok, cat = pcall(Settings.RegisterCanvasLayoutCategory, f, "WoWFA")
        if ok and cat then
            pcall(Settings.RegisterAddOnCategory, cat)
            return
        end
    end
    if InterfaceOptions_AddCategory then
        pcall(InterfaceOptions_AddCategory, f)
    end
end

F:Listen("login", function()
    local ok, err = pcall(build)
    if not ok then
        F:LogError("ui", err)
    end
    local ok2, err2 = pcall(register_settings)
    if not ok2 then
        F:LogError("ui", err2)
    end
end)
F:Listen("state", update_look)
F:Listen("minimap", function()
    update_look()
    position()
end)
