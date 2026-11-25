-- WoWFA Forever - quests: a Persian pane docked next to the quest window and
-- the quest log. We never rewrite Blizzard's own font strings, so a changed
-- quest UI can not break the game: if a frame is missing the pane just floats.
--
-- inbox/29 B: the pane exists ONLY while a quest UI is on screen. The
-- free-floating "Quests" tab is GONE - a small attached "فا" button sits on
-- the open quest frame's title bar (inside the frame, clear of the close
-- button), visible only while that frame is shown. Click = show / hide the
-- pane. X closes the pane until the player clicks "فا" again OR the quest
-- frame is closed and reopened. ESC closes the pane.
--
-- inbox/29 C: the pane typography - body = the fontSize setting, title +3 in
-- gold, SetSpacing line gap = floor(size * 0.55 + 0.5), 14 px side padding,
-- 10 px between paragraphs, section headers with a 12 px top margin and 6 px
-- under them; the scroll-child height is re-measured ONE frame after layout
-- (C_Timer.After(0)) so nothing clips and no stale gaps remain.

local F = WoWFAF
local L = F.L
local T = F.T
local UI = F.UI
local C = F.C
local SEP = "\031"
local PW, PH = 340, 440
local PAD = 14                        -- inbox/29 C: side padding
local BODY_W = PW - PAD * 2 - 4       -- minus the 2px anchor slack per side

local M = { id = "quests", order = 2, risk = "low", nameKey = "m_quests", descKey = "m_quests_d", watchMiss = true }

function M.data()
    return F.D.quests
end

function M.api()
    return GetQuestID ~= nil and (QuestFrame ~= nil or QuestLogFrame ~= nil or QuestMapFrame ~= nil)
end

local function get(id)
    local raw = id and F.D.quests[id]
    if type(raw) ~= "string" then
        return nil
    end
    local p = F.Split(raw, SEP)
    return { h = p[1] or "", t = p[2] or "", obj = p[3] or "", details = p[4] or "", progress = p[5] or "", completion = p[6] or "", desc = p[7] or "" }
end

local function simple(s)
    return (string.gsub(string.lower(tostring(s or "")), "[^%w]", ""))
end

-- Brain review (#139): "on screen" = VISIBLE, not just the own shown flag - a
-- QuestMapFrame keeps IsShown() true inside a CLOSED world map, and the pane
-- would dock to (and stay on screen for) an invisible host. IsVisible is used
-- only when it answers a real boolean; anything else (a client without it, or
-- the test mock whose unknown methods are no-ops returning nil) falls back to
-- IsShown - a nil must never read as "invisible" (CI e666898: 6 fails).
local function vis(f)
    if not f then
        return false
    end
    if f.IsVisible then
        local v = f:IsVisible()
        if v == true or v == false then
            return v
        end
    end
    return f.IsShown and f:IsShown() and true or false
end

-- ------------------------------------------------------------------ pane
-- (no tab any more - inbox/29 B deleted the free-floating "Quests" tab)
local pane, faBtn
local shownId, shownCtx, closedId
local frame_quest, log_quest -- forward (F.QuestToggle below uses both)

local function save_pos()
    local point, _, _, x, y = pane:GetPoint(1)
    if point then
        F.db.questPos = { point, x, y }
    end
end

-- the quest frames the pane can dock to (whichever exist on THIS client)
local function hosts()
    local out = {}
    for _, name in ipairs({ "QuestFrame", "QuestLogFrame", "QuestLogDetailFrame", "QuestMapFrame" }) do
        local f = _G[name]
        if f and f.IsShown then
            out[#out + 1] = f
        end
    end
    return out
end

local function build()
    pane = CreateFrame("Frame", "WoWFAF_QuestPane", UIParent)
    pane:SetSize(PW, PH)
    pane:SetFrameStrata("MEDIUM")
    pane:SetToplevel(true)
    pane:SetClampedToScreen(true)
    pane:EnableMouse(true)
    pane:SetMovable(true)
    pane:RegisterForDrag("LeftButton")
    pane:SetScript("OnDragStart", function(self)
        if F.db.questDock == 3 then
            self:StartMoving()
        end
    end)
    pane:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if F.db.questDock == 3 then
            save_pos()
        end
    end)
    UI.Glass(pane)
    -- ESC closes the pane (inbox/29 B)
    tinsert(UISpecialFrames, "WoWFAF_QuestPane")
    pane.title = UI.Text(pane, 15, C.gold)
    pane.title:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -PAD, -12)
    pane.title:SetWidth(PW - PAD * 2)
    pane.banner = UI.Text(pane, 10, C.orange)
    pane.banner:SetPoint("TOPRIGHT", pane.title, "BOTTOMRIGHT", 0, -4)
    pane.banner:SetWidth(PW - PAD * 2)
    -- X close: top-LEFT (RTL), small and clear (inbox/29 B: 20 px)
    local close = CreateFrame("Button", nil, pane)
    close:SetSize(20, 20)
    close:SetPoint("TOPLEFT", pane, "TOPLEFT", 4, -4)
    local cbg = UI.Tex(close, "BACKGROUND")
    cbg:SetAllPoints()
    cbg:SetColorTexture(C.bg2[1], C.bg2[2], C.bg2[3], 0.9)
    local chl = UI.Tex(close, "HIGHLIGHT")
    chl:SetAllPoints()
    chl:SetColorTexture(C.gold[1], C.gold[2], C.gold[3], 0.14)
    close.label = UI.Latin(close, 14, C.muted, "CENTER")
    close.label:SetPoint("CENTER")
    close.label:SetText("\195\151") -- the multiplication sign: a clear X glyph
    close:SetScript("OnClick", function()
        closedId = shownId -- suppressed until "فا" OR the frame is closed+reopened
        pane:Hide()
    end)
    pane.close = close
    pane.scroll = UI.ScrollPage(pane, PW - PAD * 2, PH - 84)
    pane.scroll:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -PAD, -66)
    pane.sec = {}
    for i = 1, 3 do
        local h = UI.Text(pane.scroll.child, 13, C.gold)
        local b = UI.Text(pane.scroll.child)
        b:SetTextColor(C.text[1], C.text[2], C.text[3])
        pane.sec[i] = { h = h, b = b }
    end
    pane:Hide()

    -- the attached "فا" button (inbox/29 B): one shared button, re-parented
    -- onto whichever quest frame is open; anchored INSIDE the title bar, just
    -- left of the host's own close button (fa_show below)
    faBtn = CreateFrame("Button", "WoWFAF_QuestFaBtn", UIParent)
    faBtn:SetSize(30, 20)
    faBtn:SetFrameStrata("MEDIUM")
    local fbg = UI.Tex(faBtn, "BACKGROUND")
    fbg:SetAllPoints()
    fbg:SetColorTexture(C.bg2[1], C.bg2[2], C.bg2[3], 0.94)
    local fhl = UI.Tex(faBtn, "HIGHLIGHT")
    fhl:SetAllPoints()
    fhl:SetColorTexture(C.gold[1], C.gold[2], C.gold[3], 0.14)
    local fline = UI.Line(faBtn, false, 0.55)
    fline:SetPoint("BOTTOMLEFT")
    fline:SetPoint("BOTTOMRIGHT")
    faBtn.label = UI.Text(faBtn, 12, C.goldLight, "CENTER")
    faBtn.label:SetPoint("CENTER")
    faBtn.label:SetFa("فا", 26)
    faBtn:SetScript("OnEnter", function(self)
        if not GameTooltip then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        T.TipLine(GameTooltip, L.q_fabtn_tip, C.gold)
        GameTooltip:Show()
    end)
    faBtn:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    faBtn:SetScript("OnClick", function()
        F.QuestToggle()
    end)
    faBtn:Hide()
end

-- the host's own close button, if it is a real frame (never trust a field
-- just because it exists: an unknown key can be a function, e.g. the mock)
local function host_close(host)
    local hc = rawget(host, "CloseButton")
    if type(hc) ~= "table" then
        local hn = host.GetName and host:GetName()
        hc = type(hn) == "string" and _G[hn .. "CloseButton"] or nil
    end
    if type(hc) ~= "table" or type(hc.IsShown) ~= "function" or type(hc.GetLeft) ~= "function" then
        return nil
    end
    if hc:IsShown() and hc:GetLeft() then
        return hc
    end
end

-- the "فا" button rides on the host that is currently open
local function fa_show(host)
    if not faBtn then
        if not pane then
            return -- nothing built yet (no quest shown at all)
        end
        build()
    end
    if host ~= faBtn:GetParent() then
        faBtn:SetParent(host)
        faBtn:SetFrameLevel(host.GetFrameLevel and (host:GetFrameLevel() + 10) or 10)
    end
    faBtn:ClearAllPoints()
    -- Brain review (#139): the classic quest frames carry ~30px of transparent
    -- art on the right, so their close button sits at about -30 and a fixed
    -- -44 offset would land ON it. Anchor just left of the host's own close
    -- button when it can be found; the fixed offset is only the fallback.
    local hc = host_close(host)
    if hc then
        faBtn:SetPoint("RIGHT", hc, "LEFT", -2, 0)
    else
        faBtn:SetPoint("TOPRIGHT", host, "TOPRIGHT", -44, -8)
    end
    faBtn:Show()
end

local function dock(f, anchor)
    f:ClearAllPoints()
    local d = F.db.questDock
    local okA = anchor and vis(anchor) and anchor:GetRight() ~= nil
    if d == 3 or not okA then
        local p = F.db.questPos
        if type(p) == "table" and type(p[1]) == "string" and tonumber(p[2]) and tonumber(p[3]) then
            f:SetPoint(p[1], UIParent, p[1], p[2], p[3])
        else
            f:SetPoint("CENTER", UIParent, "CENTER", 320, 40)
        end
        return
    end
    -- the classic quest frames carry ~30px of transparent art on the edges
    local inset = (anchor:GetWidth() or 0) >= 380 and 30 or 0
    if d == 2 then
        f:SetPoint("TOPRIGHT", anchor, "TOPLEFT", inset > 0 and 10 or -4, -inset * 0.5)
    else
        f:SetPoint("TOPLEFT", anchor, "TOPRIGHT", -inset + 4, -inset * 0.5)
    end
end

local SECTIONS = {
    detail = { { "q_details", "details" }, { "q_obj", "obj" } },
    progress = { { "q_progress", "progress" } },
    complete = { { "q_complete", "completion" } },
    log = { { "q_obj", "obj" }, { "q_details", "details" } },
}

-- inbox/29 C: heights AFTER layout - one frame later every GetStringHeight is
-- final (font + spacing settled), re-measure and fix the scroll child height
local function fix_heights(ctx)
    if not pane or not pane:IsShown() then
        return
    end
    local y = 0
    for i, s in ipairs(SECTIONS[ctx] or SECTIONS.log) do
        local sec = pane.sec[i]
        if sec and sec.h:IsShown() then
            if y > 0 then
                y = y + 12 -- section header top margin
            end
            y = y + 20 + 6 -- header line + the 6px under it
            y = y + (sec.b:GetStringHeight() or 40) + 10
        end
    end
    pane.scroll.child:SetHeight(math.max(y, 10))
    pane.scroll:UpdateBar()
end

local function layout(entry, ctx)
    -- lane-b16: the qs family switch off = the English quest title on the
    -- pane (the bodies keep their own per-family marker handling)
    -- wowfa2: the data carries no English title any more (only its hash); the
    -- English fallback is the live client title the source handed in
    local en = (pane and F.Usable(pane.enTitle) and type(pane.enTitle) == "string") and pane.enTitle or ""
    local title = (entry.t ~= "" and entry.t) or (en ~= "" and en) or "?"
    if not F.Room.On("namesQuest") and en ~= "" then -- 51-B
        title = en
    end
    -- inbox/29 C: title = fontSize + 3 in gold (the body strings = fontSize)
    pane.title.wfaSize = T.Size() + 3
    pane.title:SetFa(T.Prepare(title), PW - PAD * 2)
    local y = 0
    local used = 0
    for i, s in ipairs(SECTIONS[ctx] or SECTIONS.log) do
        local text = entry[s[2]]
        if (not text or text == "") and s[2] == "obj" then
            text = entry.desc
        end
        local sec = pane.sec[i]
        if text and text ~= "" then
            used = used + 1
            if used > 1 then
                y = y + 12 -- section header top margin (inbox/29 C)
            end
            sec.h:ClearAllPoints()
            sec.h:SetPoint("TOPRIGHT", pane.scroll.child, "TOPRIGHT", -2, -y)
            sec.h:SetWidth(BODY_W)
            sec.h:SetFa(L[s[1]], BODY_W)
            y = y + 20 + 6 -- header + 6px under it
            sec.b:ClearAllPoints()
            sec.b:SetPoint("TOPRIGHT", pane.scroll.child, "TOPRIGHT", -2, -y)
            sec.b.wfaSize = T.Size() -- the body follows the fontSize setting
            sec.b:SetFa(T.Prepare(text), BODY_W)
            -- the line gap: floor(size * 0.55 + 0.5), AFTER the (re)wrap
            sec.b:SetSpacing(T.Spacing(T.Size()))
            y = y + (sec.b:GetStringHeight() or 40) + 10 -- 10px between paragraphs
            sec.h:Show()
            sec.b:Show()
        end
    end
    for i = 1, 3 do
        if i > used then
            pane.sec[i].h:Hide()
            pane.sec[i].b:Hide()
        end
    end
    pane.scroll.child:SetHeight(math.max(y, 10))
    pane.scroll:SetVerticalScroll(0)
    pane.scroll:UpdateBar()
    -- inbox/29 C: re-measure one frame later (heights AFTER layout)
    F.After(0, function()
        if pane and pane.entry == entry then
            fix_heights(ctx)
        end
    end)
end

-- 1.0.5 (the owner: the Status page must catch EVERY untranslated thing): a quest whose
-- window shows a text our row has no Persian for, or whose title changed since the
-- translation was made, goes to the Status page list (Core F:Miss)
local PART_SRC = {
    detail = { { "details", "GetQuestText" }, { "obj", "GetObjectiveText" } },
    progress = { { "progress", "GetProgressText" } },
    complete = { { "completion", "GetRewardText" } },
}

local function game_text(fn)
    local f = _G[fn]
    if type(f) ~= "function" then
        return ""
    end
    local ok, v = pcall(f)
    if ok and F.Usable(v) and type(v) == "string" then
        return v
    end
    return ""
end

local function title_of(id, enTitle)
    if F.Usable(enTitle) and type(enTitle) == "string" and enTitle ~= "" then
        return enTitle
    end
    return "quest " .. tostring(id)
end

local function part_miss(id, entry, ctx, enTitle, stale)
    local title = title_of(id, enTitle)
    if stale then
        F:Miss("qold", tostring(id), title, ctx)
    end
    if (entry.t or "") == "" then
        F:Miss("quest", tostring(id), title, ctx)
    end
    for _, p in ipairs(PART_SRC[ctx] or {}) do
        local en = game_text(p[2])
        local have = entry[p[1]] or ""
        if p[1] == "obj" and have == "" then
            have = entry.desc or ""
        end
        if en ~= "" and have == "" then
            F:Miss("qtext", tostring(id) .. ":" .. p[1], title .. " / " .. en, p[1])
        end
    end
end

local function show(id, enTitle, ctx, anchor)
    if not pane then
        build()
    end
    if not F.Room.On("questText") then -- 51-B: the room owns the quest text
        pane:Hide()
        if faBtn then
            faBtn:Hide()
        end
        return
    end
    local entry = get(id)
    if not entry then
        F:Track("quests", false)
        if F.Usable(id) then
            F:Miss("quest", tostring(id), title_of(id, enTitle), ctx) -- 1.0.5
        end
        pane:Hide()
        return
    end
    enTitle = enTitle or (pane.entry == entry and pane.enTitle) or nil
    pane.enTitle = enTitle
    -- wowfa2: stale = the live title hashes differently from the title the
    -- translation was made for (F.TitleHash mirrors the build's title_hash)
    local stale = F.Usable(enTitle) and type(enTitle) == "string" and enTitle ~= "" and entry.h ~= ""
        and F.TitleHash(enTitle) ~= entry.h
    if shownId ~= id or shownCtx ~= ctx then
        F:Track("quests", true, stale)
        part_miss(id, entry, ctx, enTitle, stale) -- 1.0.5
    end
    pane.entry, pane.ctx, pane.anchor = entry, ctx, anchor
    shownId, shownCtx = id, ctx
    layout(entry, ctx)
    if stale then
        pane.banner:SetFa(L.stale_quest, PW - PAD * 2)
        pane.banner:Show()
        pane.scroll:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -PAD, -84)
    else
        pane.banner:Hide()
        pane.scroll:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -PAD, -66)
    end
    dock(pane, anchor)
    if anchor then
        fa_show(anchor)
    end
    if closedId == id then
        pane:Hide()
    elseif F.db.questAuto then
        pane:Show()
    else
        pane:Hide()
    end
end

local function hide(ctxFilter)
    if pane and (not ctxFilter or pane.src == ctxFilter) then
        pane:Hide()
        shownId, shownCtx = nil, nil
    end
end

-- every quest frame gone -> pane AND the "فا" button go with it; the X latch
-- is forgotten (the next open quest shows the pane again per questAuto)
local function host_gone()
    if pane then
        pane:Hide()
    end
    if faBtn then
        faBtn:Hide()
    end
    closedId = nil
    shownId, shownCtx = nil, nil
end

F.QuestToggle = function()
    -- inbox/29 B: toggle for what is on screen only; the slash command answers
    -- "nothing open" through F.QuestToggled (Core.lua prints the chat line)
    local host
    for _, f in ipairs(hosts()) do
        if vis(f) then
            host = f
            break
        end
    end
    if not host then
        F.QuestToggled = nil
        return
    end
    F.QuestToggled = true
    if not pane then
        build()
    end
    if pane:IsShown() then
        pane:Hide()
        return
    end
    -- nothing laid out yet: run the source for the open frame once
    if not pane.entry or not shownId then
        if host == QuestFrame then
            local id, title = frame_quest()
            if id then
                show(id, title, "detail", host)
                pane.src = "frame"
            end
        else
            local id, title = log_quest()
            if id then
                show(id, title, "log", host)
                pane.src = "log"
            end
        end
    end
    if pane.entry then
        closedId = nil
        pane:Show()
    end
end

-- ------------------------------------------------------------- sources
function frame_quest() -- (assigned to the forward local declared above)
    local id = GetQuestID and GetQuestID()
    local title = GetTitleText and GetTitleText()
    if not F.Usable(id) or type(id) ~= "number" or id <= 0 then
        return nil
    end
    return id, title
end

function log_quest() -- (assigned to the forward local declared above)
    if GetQuestLogSelection and GetQuestLogTitle then
        local idx = GetQuestLogSelection()
        if F.Usable(idx) and idx and idx > 0 then
            local title, _, _, isHeader, _, _, _, qid = GetQuestLogTitle(idx)
            if not isHeader and F.Usable(qid) and type(qid) == "number" and qid > 0 then
                return qid, title
            end
        end
    end
    if C_QuestLog and C_QuestLog.GetSelectedQuest then
        local qid = C_QuestLog.GetSelectedQuest()
        if F.Usable(qid) and type(qid) == "number" and qid > 0 then
            local title = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(qid)
            return qid, title
        end
    end
end

local function log_frame()
    for _, name in ipairs({ "QuestLogFrame", "QuestLogDetailFrame", "QuestMapFrame" }) do
        local f = _G[name]
        if vis(f) then
            return f
        end
    end
end

local function on_frame(ctx)
    return function()
        local id, title = frame_quest()
        if id then
            show(id, title, ctx, QuestFrame)
            pane.src = "frame"
        end
    end
end

local function on_log()
    local f = log_frame()
    if not f then
        host_gone()
        return
    end
    if QuestFrame and vis(QuestFrame) then
        return -- the open quest dialog wins
    end
    local id, title = log_quest()
    if id then
        show(id, title, "log", f)
        pane.src = "log"
    end
end

function M.install()
    F:On("QUEST_DETAIL", "quests", on_frame("detail"))
    F:On("QUEST_PROGRESS", "quests", on_frame("progress"))
    F:On("QUEST_COMPLETE", "quests", on_frame("complete"))
    F:On("QUEST_FINISHED", "quests", function()
        F.After(0.1, function()
            if not (QuestFrame and vis(QuestFrame)) and not log_frame() then
                host_gone()
            end
        end)
    end)
    local throttle, pending = 0, false
    F:On("QUEST_LOG_UPDATE", "quests", function()
        local now = GetTime()
        if now - throttle > 0.3 and log_frame() then
            throttle = now
            on_log()
        elseif not pending and log_frame() then
            -- rc9: an update inside the throttle used to be dropped for good, so a quick
            -- second click on the map quest log kept showing the first quest's text:
            -- run once more when the window is over
            pending = true
            F.After(0.35, function()
                pending = false
                if log_frame() then
                    throttle = GetTime()
                    on_log()
                end
            end)
        end
    end)
    local wrapped = F:Wrap("quests", on_log)
    for _, fn in ipairs({ "SelectQuestLogEntry", "QuestLog_SetSelection" }) do
        if type(_G[fn]) == "function" then
            hooksecurefunc(fn, wrapped)
        end
    end
    -- rc9: the modern map quest log selects a quest through C_QuestLog.SetSelectedQuest /
    -- QuestMapFrame_ShowQuestDetails (none of the old functions run): re-read the
    -- selection right after the click AND once more a moment later (the selection
    -- settles a frame after the call)
    local after_select = F:Wrap("quests", function()
        F.After(0, wrapped)
        F.After(0.2, wrapped)
    end)
    for _, fn in ipairs({ "QuestMapFrame_ShowQuestDetails", "QuestMapFrame_OpenToQuestDetails",
        "QuestMapLogTitleButton_OnClick" }) do
        if type(_G[fn]) == "function" then
            pcall(hooksecurefunc, fn, after_select)
        end
    end
    if type(C_QuestLog) == "table" and type(C_QuestLog.SetSelectedQuest) == "function" then
        pcall(hooksecurefunc, C_QuestLog, "SetSelectedQuest", after_select)
    end
    -- inbox/29 B: the pane and the button LIVE on the quest frames - show
    -- re-anchors, hide removes everything (pane + button + X latch), a drag
    -- of the host re-docks the pane to it
    for _, f in ipairs(hosts()) do
        if f.HookScript then
            -- Brain review (#139): NO OnShow hook on QuestFrame - on_log there
            -- found no log open and ran host_gone(), so whenever the client
            -- showed QuestFrame AFTER our QUEST_DETAIL handler the fresh pane
            -- was hidden again (event-order dependent). QuestFrame content is
            -- driven by the QUEST_* events alone, exactly as in 0.6.0.
            if f ~= QuestFrame then
                f:HookScript("OnShow", wrapped)
            end
            f:HookScript("OnHide", F:Wrap("quests", function()
                F.After(0.05, function()
                    if not (QuestFrame and vis(QuestFrame)) and not log_frame() then
                        host_gone()
                    else
                        -- Brain review (#139): was F.Wrap("quests", on_log)() -
                        -- a dot call of the METHOD, so on_log never ran and every
                        -- dialog close with the log open logged a junk error
                        wrapped()
                    end
                end)
            end))
            f:HookScript("OnDragStop", F:Wrap("quests", function()
                if pane and pane:IsShown() and F.db.questDock ~= 3 then
                    dock(pane, log_frame() or (QuestFrame and vis(QuestFrame) and QuestFrame) or f)
                end
            end))
        end
    end
    -- inbox/29 D2: the surface switch hides the pane NOW (and the button);
    -- switching it back on re-shows for the quest still on screen
    F:Listen("surf", function(name)
        if name and name ~= "questPane" then
            return -- only the pane surface belongs to this module
        end
        if not F.Room.On("questText") then -- 51-B: the room owns the quest text
            if pane then
                pane:Hide()
            end
            if faBtn then
                faBtn:Hide()
            end
        elseif shownId then
            show(shownId, pane and pane.enTitle, shownCtx, pane and pane.anchor)
        end
    end)
    F:Listen("options", function(key)
        if pane and pane.entry and shownId and (key == "questDock" or key == "questAuto") then
            show(shownId, pane.enTitle, shownCtx, pane.anchor)
        end
    end)
    F:Listen("names", function()
        if pane and pane:IsShown() and pane.entry then
            layout(pane.entry, pane.ctx)
        end
    end)
    F:Listen("text", function()
        if pane and pane:IsShown() and pane.entry then
            layout(pane.entry, pane.ctx)
        end
    end)
end

function M.onState(_, active)
    if not active then
        host_gone()
    end
end

F:RegisterModule(M)
