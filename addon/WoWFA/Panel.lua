-- WoWFA v1 - the settings panel v4 (1.1.6, the owner 26 Nov: "check every setting exactly: no
-- extra explanations, simple, exact and complete; many buttons do nothing you can see, many texts
-- point at something the player can not tell"). A side menu (RIGHT, the RTL side) and one scroll
-- page per topic. Rules of v4:
--   * ONE control per real thing. A module switch, its room family and its display choice that
--     all did the same thing are one row now (e.g. "NPC names: Persian / Persian + English /
--     English" = the npc module + namesNpc + npcName). A combined row reads the real state, so it
--     never shows "on" while the game shows English.
--   * a short label that says WHERE it shows; a one-line note only when the label can not.
--   * an eye (Modules/Preview.lua) only on a row whose sample really changes with it:
--     row.wfaEye = the sample id, row.wfaSec = the spell section the sample draws.
-- No Persian literal in this file (every string lives in the Locale files, L.PN = Locale_Panel);
-- plain (insecure) frames only, so it opens in combat; a build error is logged, never thrown.

local F = WoWFAF
local L = F.L
local UI = F.UI
local C = F.C
local PN = L.PN or {}

local W, H = 700 + (F.PREVIEW_W or 0), 600 -- the window (+ the live preview column)
local NAVW = 164              -- the side menu
local PW = 486                -- the scroll page width
local panel, page, rows, health
local pages, navbtns, active = {}, {}, nil
local SHIPPED = { "quests", "tracker", "dungeons", "npc", "spellbook", "talents" }
local ROOM_KEYS = { "namesZone", "namesSpell", "namesClass", "namesQuest", "terms", "questText", "npcSay", "faDigits", "namesNpc" }
local SECTIONS = { "general", "quests", "map", "npc", "chat", "game", "spellbook", "sizes", "colors", "share", "health", "about" }
-- the ids of the older panels still work (F.OpenPanel("health"), the tests)
local ALIAS = { room = "general", mods = "general", display = "general", home = "general", welcome = "general",
    tracker = "quests", dialog = "npc", talents = "spellbook" }
local STATE_L = { ok = "st_ok", warn = "st_warn", off = "st_off", master = "st_master", nodata = "st_nodata",
    schema = "st_schema", noapi = "st_noapi", update = "st_update", fault = "st_fault", locked = "st_off" }
local STATE_C = { ok = "green", warn = "orange", update = "orange", fault = "red", noapi = "red", schema = "red", nodata = "red" }

-- 1.2.0: "new" tags (the owner 27 Nov: a New tag on top of a section that is new). A page in
-- NEW_PAGES shows a small orange pill in the side menu until the player has opened it once
-- (db.newSeen[page] = NEWREL), and header(text, true) puts the same pill at the left end of a
-- header. The next release removes the entries and the `true` flags.
local NEWREL = "1.2.0"
local NEW_PAGES = { game = true }

local function new_pill(parent)
    local oc = C.orange or { 1, 0.6, 0.15 }
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(34, 16)
    f:SetFrameLevel(parent:GetFrameLevel() + 3)
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(oc[1], oc[2], oc[3], 0.28)
    local tx = UI.Text(f, 11, oc, "CENTER")
    tx:SetPoint("CENTER", f, "CENTER", 0, 0)
    tx:SetFa(PN.new_tag or " ", 32)
    f.text = tx
    return f
end

local function new_seen(id)
    local s = F.db and F.db.newSeen
    return type(s) == "table" and s[id] == NEWREL
end

F.PANEL_SHIPPED = SHIPPED
F.PANEL_ROOM_KEYS = ROOM_KEYS
F.PANEL_SECTIONS = SECTIONS

-- v4: the presets the panel offers. "stats only" only switched item lines, and items are
-- not in this version: on WoW Forever it was the same as English, so it is no choice any more
-- (a saved "stats" room still works and shows as "custom").
if F.Room then
    F.Room.PRESET_IDS = { "recommended", "fa", "story", "spells", "en" }
    -- the terms are plain words inside the Persian sentences (damage, pet, health): the story
    -- preset keeps them Persian, an English word mid-sentence read as a bug
    if F.Room.PRESETS and F.Room.PRESETS.story and F.Room.PRESETS.story.d then
        F.Room.PRESETS.story.d.terms = true
    end
    for id, s in pairs(PN.preset_lbl or {}) do
        F.Room.PRESET_LBL[id] = s
    end
    for id, s in pairs(PN.preset_desc or {}) do
        F.Room.PRESET_DESC[id] = s
    end
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

-- every page is stacked again from the REAL height of its texts (rows only ever grow)
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
        -- a hidden row (an empty profile slot, the talent rows while they follow the spells)
        -- takes no room
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
    sf:SetPoint("TOPLEFT", panel, "TOPLEFT", 14 + (F.PREVIEW_W or 0), -64)
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

local function header(text, isNew)
    y = y - 10
    pre = pre + 10
    local hd = UI.Header(page.child, text, PW - 16)
    if isNew then
        local pill = new_pill(hd)
        pill:SetPoint("LEFT", hd, "LEFT", 2, 3)
        hd.newPill = pill
    end
    place(hd, 28, 6)
    return hd
end

local function note(text)
    local f = CreateFrame("Frame", nil, page.child)
    f:SetSize(PW - 16, 22)
    f.text = UI.Text(f, 12, C.muted)
    f.text:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, 0)
    f.text:SetFa(text, PW - 30)
    return place(f, 22, 2)
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
    if m and m.why then
        lbl = lbl .. " (" .. tostring(m.why) .. ")"
    elseif m and st == "fault" then
        lbl = lbl .. " (x" .. tostring(m.faults or 0) .. ")"
    end
    return lbl, C[STATE_C[st] or "muted"]
end

-- ------------------------------------------------------------------ the folder of WoWFA.lua
-- the game can not open a Windows folder or write the clipboard: the status page shows the
-- full path in a box, one click selects it; the player can fix it ONCE (F.db.svPath).
local function sv_default()
    local okm, mac = pcall(function() return IsMacClient and IsMacClient() end)
    if okm and mac then
        return "/Applications/World of Warcraft/_forever_/WTF/Account"
    end
    return "C:\\Program Files (x86)\\World of Warcraft\\_forever_\\WTF\\Account"
end

function F.SvPath()
    local p = F.db and F.db.svPath
    if type(p) == "string" and p ~= "" then
        return p
    end
    return sv_default()
end

function F.SvPathSet(p)
    if not F.db then
        return
    end
    p = tostring(p or "")
    p = string.gsub(p, "^%s+", "")
    p = string.gsub(p, "%s+$", "")
    p = string.gsub(p, '^"(.*)"$', "%1")
    if p == "" or p == sv_default() then
        F.db.svPath = nil
    else
        F.db.svPath = string.sub(p, 1, 400)
    end
end

local function refresh_health()
    if not health then
        return
    end
    if health.svPath and not (health.svPath.HasFocus and health.svPath:HasFocus()) then
        health.svPath:SetText(F.SvPath())
        health.svPath:SetCursorPosition(0)
    end
    health.addon.val:SetText("v" .. tostring(F.VERSION))
    health.client.val:SetText(tostring(F.clientVersion or "?") .. "." .. tostring(F.clientBuildText or "?"))
    health.data.val:SetText(tostring(F.dataBuildText or "-"))
    for _, id in ipairs(SHIPPED) do
        local lbl, col = state_of(id)
        local r = health.mods[id]
        r.val:SetFa(lbl, 200)
        color(r.val, col)
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
    -- ONE line holds everything a report needs: the misses (kind :: text :: context :: xCount,
    -- most seen first) and the last errors
    if health.missList then
        F:MissFresh()
        local list, kinds, order = {}, {}, {}
        for _, e in pairs(F.db and type(F.db.miss) == "table" and F.db.miss or {}) do
            list[#list + 1] = e
            local k = tostring(e.k or "?")
            if not kinds[k] then
                kinds[k] = 0
                order[#order + 1] = k
            end
            kinds[k] = kinds[k] + 1
        end
        table.sort(list, function(a, b)
            local x, y2 = tonumber(a.n) or 0, tonumber(b.n) or 0
            if x ~= y2 then
                return x > y2
            end
            return tostring(a.t) < tostring(b.t)
        end)
        local out = { string.format("WoWFA %s b%s misses=%d errors=%d", tostring(F.VERSION), tostring(F.clientBuildText or "?"), #list, #errs) }
        for i = 1, #list do
            local e = list[i]
            local t = string.gsub(tostring(e.t or ""), "|", "!")
            t = string.gsub(t, "[\r\n]+", " / ")
            out[#out + 1] = string.format("%s :: %s :: %s :: x%d", tostring(e.k), t, tostring(e.c or ""), tonumber(e.n) or 1)
        end
        for i = 1, math.min(5, #errs) do
            local e = errs[i]
            local msg = string.gsub(string.sub(tostring(e.e), 1, 160), "|", "!")
            msg = string.gsub(msg, "[\r\n]+", " / ")
            out[#out + 1] = string.format("err :: [%s] %s :: x%d", tostring(e.m), msg, tonumber(e.n) or 1)
        end
        -- 1.2.0: what changed during the last fights (CombatWatch.lua)
        for _, c in ipairs(F.db and type(F.db.combatDiff) == "table" and F.db.combatDiff or {}) do
            local cv = string.gsub(tostring(c.v), "|", "!")
            out[#out + 1] = string.format("combat :: %s :: %s :: x%d", tostring(c.k), cv, tonumber(c.n) or 1)
        end
        local line = table.concat(out, " ;; ")
        if health.missList.wfaFixed ~= line and health.copyMsg then
            health.copyMsg:SetFa(" ", PW - 30)
        end
        health.missList:SetFixed(line)
        if #list == 0 then
            health.missHead:SetFa(L.rp2_none, PW - 30)
            health.missKinds:SetFa(" ", PW - 30)
        else
            health.missHead:SetFa(string.format(L.rp2_count, #list), PW - 30)
            table.sort(order, function(a, b)
                if kinds[a] ~= kinds[b] then
                    return kinds[a] > kinds[b]
                end
                return a < b
            end)
            local parts = {}
            for _, k in ipairs(order) do
                parts[#parts + 1] = string.format("%s: %d", (L.MISS_KIND and L.MISS_KIND[k]) or k, kinds[k])
            end
            health.missKinds:SetFa(table.concat(parts, L.rp2_sep or ", "), PW - 30)
        end
    end
end

local function refresh()
    if not panel then
        return
    end
    local off = not (F.db and F.db.enabled)
    for _, r in ipairs(rows) do
        if r.showIf then
            if r.showIf() then
                r:Show()
            else
                r:Hide()
            end
        end
        if r.Update then
            r.dimmed = (off and r.dimOnMaster) or (r.dimIf and r.dimIf()) or nil
            r:Update()
        end
    end
    refresh_health()
    if panel.shareBox and F.Room.ShareExport then
        panel.shareBox:SetFixed(F.Room.ShareExport())
    end
    if active and pages[active] then
        restack(pages[active])
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
    if NEW_PAGES[id] and F.db then
        if type(F.db.newSeen) ~= "table" then
            F.db.newSeen = {}
        end
        F.db.newSeen[id] = NEWREL
        local nb = navbtns[id]
        if nb and nb.newPill then
            nb.newPill:Hide()
        end
    end
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
local function mods_on(id)
    return not (F.db and type(F.db.mods) == "table" and F.db.mods[id] == false)
end

local function ensure_mod(id)
    if not mods_on(id) then
        F:SetModule(id, true)
    end
end

-- a Choice shows its dimmed state too (UI.Toggle does it itself)
local function dimmable(row)
    local base = row.Update
    row.Update = function(self)
        base(self)
        local t = self.dimmed and C.muted or C.text
        if self.label then
            self.label:SetTextColor(t[1], t[2], t[3])
        end
    end
    return row
end

local function tog(label, desc, get, set, eye)
    local t = UI.Toggle(page.child, PW - 16, label, desc, get, set)
    t.dimOnMaster = true
    t.wfaEye = eye
    return place(t, desc and 50 or 32, 2)
end

local function choice(label, desc, labels, get, set, eye)
    local c = dimmable(UI.Choice(page.child, PW - 16, label, desc, labels, get, set))
    c.dimOnMaster = true
    c.wfaEye = eye
    return place(c, desc and 50 or 32, 2)
end

local function opt_tog(key, label, desc, signal, eye)
    return tog(label, desc,
        function() return F.db[key] and true or false end,
        function(v)
            F.db[key] = v and true or false
            if signal then
                F:Fire("options", key)
            end
        end, eye)
end

-- a room switch (one of the name / text families)
-- what the red pulse of the preview marks for a row (Preview.lua: a word family / a quest part)
local ROOM_HI = { namesClass = "cls", terms = "tm", faDigits = "dig", namesQuest = "qtitle", questText = "qobj" }
local function room_tog(k, eye)
    local t = tog(PN[k] or k, PN[k .. "_d"],
        function() return F.Room.On(k) end,
        function(v) F.Room.Set(k, v) end, eye)
    t.wfaHi = ROOM_HI[k]
    panel.room[k] = t
    return t
end

-- the NPC talk switches: npcSay (the room bit, also set by the presets) is their master; a
-- row reads on only when both are on, and turning one on while the master is off turns ONLY
-- that one on
local DLG = { "dlgGossip", "dlgSay", "dlgBook" }
local function dlg_tog(k, eye)
    local t = tog(PN[k], PN[k .. "_d"],
        function() return F.Room.On("npcSay") and F.db[k] ~= false end,
        function(v)
            if v and not F.Room.On("npcSay") then
                for _, o in ipairs(DLG) do
                    F.db[o] = false
                end
                F.db[k] = true
                F.Room.Set("npcSay", true)
            else
                F.db[k] = v and true or false
            end
            F:Fire("options", k)
        end, eye)
    panel[k] = t
    return t
end

-- the system-line groups: db.sysmsg is their master (same rule as the talk switches); they
-- need the Persian chat font, so they are dimmed while the Persian chat switch is off
local SYS = { "sysLoot", "sysXp", "sysRep", "sysGroup" }
local function sys_tog(k)
    local t = tog(PN[k], nil,
        function() return F.db.sysmsg ~= false and F.db[k] ~= false end,
        function(v)
            if v and F.db.sysmsg == false then
                for _, o in ipairs(SYS) do
                    F.db[o] = false
                end
                F.db.sysmsg = true
            end
            F.db[k] = v and true or false
            F:Fire("options", "sysmsg")
        end, "sys")
    t.dimIf = function() return F.db.chatFa == false end
    panel[k] = t
    return t
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

-- 1.1.8 (the owner 27 Nov: "the slide must not sit in the middle; it has to move next to the part
-- it talks about and a blinking red frame must show what we mean"): the "how can I help" tour.
-- A small card moves NEXT TO the part of the report page a step is about, the page scrolls to
-- it and a blinking red frame marks it. The frame never takes the mouse, so the real buttons
-- (select the report text) are clicked on the page itself. Plain frames only (works in combat).
-- Every text is in Locale_Panel.lua (PN.tour).
local TOUR_STEPS = {
    { tg = { "head" }, below = true },
    { tg = { "head", "kinds" }, below = true },
    { tg = { "list", "copy" }, below = false },
    { tg = { "steps" }, below = true, url = true },
}

-- a blinking frame of four lines around a target (parent = the frame it lives in)
local function make_border(parent, r, g, b, thick)
    local hl = CreateFrame("Frame", nil, parent)
    hl:SetFrameLevel(parent:GetFrameLevel() + 60)
    local e = {}
    for i = 1, 4 do
        local tx = hl:CreateTexture(nil, "OVERLAY")
        if tx.SetColorTexture then
            tx:SetColorTexture(r, g, b, 1)
        else
            tx:SetTexture(r, g, b, 1)
        end
        e[i] = tx
    end
    e[1]:SetPoint("TOPLEFT", hl, "TOPLEFT", 0, 0)
    e[1]:SetPoint("TOPRIGHT", hl, "TOPRIGHT", 0, 0)
    e[1]:SetHeight(thick)
    e[2]:SetPoint("BOTTOMLEFT", hl, "BOTTOMLEFT", 0, 0)
    e[2]:SetPoint("BOTTOMRIGHT", hl, "BOTTOMRIGHT", 0, 0)
    e[2]:SetHeight(thick)
    e[3]:SetPoint("TOPLEFT", hl, "TOPLEFT", 0, 0)
    e[3]:SetPoint("BOTTOMLEFT", hl, "BOTTOMLEFT", 0, 0)
    e[3]:SetWidth(thick)
    e[4]:SetPoint("TOPRIGHT", hl, "TOPRIGHT", 0, 0)
    e[4]:SetPoint("BOTTOMRIGHT", hl, "BOTTOMRIGHT", 0, 0)
    e[4]:SetWidth(thick)
    hl.t = 0
    hl:SetScript("OnUpdate", function(self, el)
        self.t = self.t + el
        local a = 0.9
        if not (self.steadyIf and self.steadyIf()) then
            a = 0.25 + 0.75 * math.abs(math.sin(self.t * 4))
        end
        for i = 1, 4 do
            e[i]:SetAlpha(a)
        end
        if self.view then
            self:SetAlpha(self.view(self.target) and 1 or 0)
        end
    end)

    function hl:Around(target, pad)
        self.target = target
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", target, "TOPLEFT", -pad, pad)
        self:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", pad, -pad)
    end

    return hl
end

-- the "how can I help" button stands out: a gold label and an orange blinking frame (the frame
-- keeps blinking until the player has opened the tour once, then it stays lit)
local function style_help(btn)
    if btn.label and btn.label.SetTextColor then
        btn.label:SetTextColor(1, 0.86, 0.3)
    end
    local hl = make_border(btn, 1, 0.5, 0.1, 2)
    hl:Around(btn, 3)
    hl.steadyIf = function()
        return F.db and F.db.tourSeen == true
    end
    return hl
end

local function tour_target(name)
    if name == "copy" then
        return panel.missCopy
    end
    return health and health["f" .. name]
end

-- is the target inside the visible part of the report page?
local function in_view(target)
    local sf = pages.health
    if not (target and sf) then
        return false
    end
    local ok, res = pcall(function()
        local top, bot = target:GetTop(), target:GetBottom()
        local pt, pb = sf:GetTop(), sf:GetBottom()
        return top and bot and pt and pb and top <= pt and bot >= pb
    end)
    return ok and res and true or false
end

local function build_tour()
    if panel.tour then
        return panel.tour
    end
    local slides = PN.tour
    if type(slides) ~= "table" or #slides == 0 then
        return nil
    end
    local t = CreateFrame("Frame", nil, panel)
    t:SetSize(330, 215)
    t:SetFrameLevel(panel:GetFrameLevel() + 70)
    t:EnableMouse(true)
    UI.Glass(t, 1)
    t:Hide()
    panel.tour = t
    t.hl = {}
    for k = 1, 2 do
        local hl = make_border(panel, 1, 0.12, 0.12, 3)
        hl.view = in_view
        hl:Hide()
        t.hl[k] = hl
    end
    t.title = UI.Text(t, 15, C.gold)
    t.title:SetPoint("TOPRIGHT", t, "TOPRIGHT", -14, -12)
    t.body = UI.Text(t, 13, C.text)
    t.body:SetPoint("TOPRIGHT", t, "TOPRIGHT", -14, -40)
    t.count = UI.Latin(t, 11, C.muted, "LEFT")
    t.count:SetPoint("TOPLEFT", t, "TOPLEFT", 14, -14)
    t.urlf = CreateFrame("Frame", nil, t)
    t.urlf:SetSize(300, 26)
    t.urlf:SetPoint("BOTTOM", t, "BOTTOM", 0, 48)
    local ub = code_box(t.urlf, false)
    ub:SetSize(288, 22)
    ub:SetFixed(tostring(F.SITE) .. "/report")
    t.close = UI.Button(t, PN.tour_close, 90, 24, function()
        t:Hide()
    end)
    t.close:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", -12, 12)
    t.next = UI.Button(t, PN.tour_next, 90, 24, function()
        if t.i >= #slides then
            t:Hide()
        else
            t.show(t.i + 1)
        end
    end)
    t.next:SetPoint("BOTTOMLEFT", t, "BOTTOMLEFT", 12, 12)
    t.back = UI.Button(t, PN.tour_back, 90, 24, function()
        t.show(t.i - 1)
    end)
    t.back:SetPoint("LEFT", t.next, "RIGHT", 8, 0)
    t:SetScript("OnHide", function()
        for k = 1, 2 do
            t.hl[k]:Hide()
        end
    end)
    panel:HookScript("OnHide", function()
        t:Hide()
    end)

    -- put the card next to the first target and frame every target of the step
    local function settle(i)
        if not t:IsShown() or t.i ~= i then
            return
        end
        local st = TOUR_STEPS[i] or TOUR_STEPS[1]
        local main
        for k = 1, 2 do
            local tg = st.tg[k] and tour_target(st.tg[k])
            if tg then
                t.hl[k]:Around(tg, 4)
                t.hl[k]:Show()
                main = main or tg
            else
                t.hl[k]:Hide()
            end
        end
        t:ClearAllPoints()
        if not main then
            t:SetPoint("CENTER", panel, "CENTER", 0, 0)
            t:SetAlpha(1)
            return
        end
        local sf = pages.health
        local ct, tt = sf and sf.child and sf.child:GetTop(), main:GetTop()
        if ct and tt and sf.ScrollTo then
            sf:ScrollTo(math.max(0, ct - tt - (st.below and 60 or 250)))
        end
        if st.below then
            t:SetPoint("TOP", main, "BOTTOM", 0, -12)
        else
            t:SetPoint("BOTTOM", main, "TOP", 0, 12)
        end
        t:SetAlpha(1)
    end

    function t.show(i)
        local n = #slides
        t.i = math.max(1, math.min(n, i))
        local s = slides[t.i]
        local st = TOUR_STEPS[t.i] or TOUR_STEPS[1]
        t.title:SetFa(s.t or " ", 300)
        t.body:SetFa(s.b or " ", 300)
        t.count:SetText(tostring(t.i) .. " / " .. tostring(n))
        t.next:SetLabel(t.i < n and PN.tour_next or PN.tour_done)
        if t.i > 1 then
            t.back:Show()
        else
            t.back:Hide()
        end
        if st.url then
            t.urlf:Show()
        else
            t.urlf:Hide()
        end
        t:SetAlpha(0)
        local at = t.i
        F.After(0.1, function()
            settle(at)
        end)
    end

    return t
end

local function slider(label, lo, hi, step, get, set)
    return place(UI.Slider(page.child, PW - 16, label, lo, hi, step, get, set), 30, 4)
end

local function pct_slider(label, key, def, lo, hi, signal, sigKey)
    return slider(label, lo, hi, 5,
        function() return F.db[key] or def end,
        function(v)
            v = math.floor(v + 0.5)
            if v ~= (F.db[key] or def) then
                F.db[key] = v
                F:Fire(signal or "options", sigKey or key)
            end
        end)
end

-- v4: the spellbook has no "own" display any more (the spellbook IS the default; only the
-- talents can differ). An older saved spellbook display becomes the default, and the talents
-- keep exactly what they showed.
local function migrate_disp()
    if not (F.DispCustom and F.DispCustom("spellbook")) then
        return
    end
    local ot, od = F.Disp("*", "title"), F.Disp("*", "desc")
    local st, sd = F.Disp("spellbook", "title"), F.Disp("spellbook", "desc")
    if not F.DispCustom("talents") and (ot ~= st or od ~= sd) then
        F.DispSet("talents", "title", ot)
        F.DispSet("talents", "desc", od)
    end
    F.DispSetDefault("title", st)
    F.DispSetDefault("desc", sd)
    F.DispSetCustom("spellbook", false)
end

-- ------------------------------------------------------------------ build
local function build()
    pcall(migrate_disp)
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
        F.EscClose(panel) -- Esc closes it (never UISpecialFrames: taint, see Core)
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
        local b = UI.Button(panel, L["sec_" .. id] or id, NAVW - 8, 30, function()
            select_page(id)
        end)
        b:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -14, -68 - (i - 1) * 36)
        local mark = UI.Tex(b, "OVERLAY", "diamond")
        mark:SetSize(8, 8)
        mark:SetPoint("RIGHT", b, "RIGHT", -4, 0)
        mark:SetVertexColor(C.gold[1], C.gold[2], C.gold[3], 0.9)
        mark:Hide()
        b.mark = mark
        if NEW_PAGES[id] then
            local pill = new_pill(b)
            pill:SetPoint("LEFT", b, "LEFT", 4, 0)
            if new_seen(id) then
                pill:Hide()
            else
                pill:Show()
            end
            b.newPill = pill
        end
        navbtns[id] = b
    end

    rows = {}
    panel.allRows = rows
    panel.room, panel.mods = {}, {}

    -- ===================================================== General
    begin_page("general")
    panel.master = place(UI.Toggle(page.child, PW - 16, PN.master, PN.master_d,
        function() return F.db.enabled end,
        function(v)
            F:SetEnabled(v)
            F.Chat(F.db.enabled and L.en.on or L.en.off)
        end), 50, 6)
    header(PN.h_mode)
    local labels = {}
    for i, id in ipairs(F.Room.PRESET_IDS) do
        labels[i] = F.Room.PRESET_LBL[id]
    end
    labels[#labels + 1] = F.Room.PRESET_LBL.custom
    local npre = #F.Room.PRESET_IDS
    local pr = UI.Choice(page.child, PW - 16, PN.mode, F.Room.PRESET_DESC[F.Room.Mode()] or " ", labels,
        preset_index,
        function(v)
            if v > npre then
                v = 1 -- "custom" is a result, never a choice: the cycle skips it
            end
            F.Room.Apply(F.Room.PRESET_IDS[v])
        end)
    local base = pr.Update
    pr.Update = function(self)
        base(self)
        if self.desc then
            self.desc:SetFa(F.Room.PRESET_DESC[F.Room.Mode()] or " ", PW - 16 - 160)
        end
    end
    pr.dimOnMaster = true
    pr.wfaEye = "text"
    panel.preset = place(dimmable(pr), 50, 4)
    header(PN.h_words)
    room_tog("namesClass", "text")
    room_tog("terms", "text")
    room_tog("faDigits", "text")
    header(PN.h_other)
    panel.shiftEn = tog(PN.shiftEn, nil,
        function() return F.db.shiftEn ~= false end,
        function(v) F.db.shiftEn = v and true or false end)
    panel.minimap = tog(PN.minimap, nil,
        function() return not F.db.minimap.hide end,
        function(v)
            F.db.minimap.hide = not v
            F:Fire("minimap")
        end)
    panel.toast = opt_tog("toast", PN.toast, nil, false)
    panel.share = opt_tog("share", PN.share, nil, false)
    end_page()

    -- ===================================================== Quests
    begin_page("quests")
    room_tog("namesQuest", "quest")
    room_tog("questText", "quest")
    header(PN.h_pane)
    panel.mods.quests = tog(PN.quests, nil,
        function() return mods_on("quests") end,
        function(v) F:SetModule("quests", v) end, "quest")
    panel.dock = choice(PN.dock, nil, PN.dock_opt,
        function() return F.db.questDock end,
        function(v)
            F.db.questDock = v
            F:Fire("options", "questDock")
        end)
    panel.mods.quests.wfaHi = "qpane"
    panel.dock.dimIf = function() return not mods_on("quests") end
    panel.questAuto = opt_tog("questAuto", PN.questAuto, PN.questAuto_d, true)
    panel.questAuto.dimIf = function() return not mods_on("quests") end
    header(PN.h_tracker)
    panel.mods.tracker = tog(PN.tracker, nil,
        function() return mods_on("tracker") end,
        function(v) F:SetModule("tracker", v) end, "quest")
    panel.mods.tracker.wfaHi = "qtrack"
    panel.listTitles = tog(PN.listTitles, nil,
        function() return F.db.listTitles ~= false end,
        function(v)
            F.db.listTitles = v and true or false
            F:Fire("options", "listTitles")
        end)
    panel.questie = tog(PN.questie, PN.questie_d,
        function() return F.db.questie ~= false end,
        function(v)
            F.db.questie = v and true or false
            F:Fire("options", "questie")
            if F.Walk and F.Walk.Refresh then
                F.Walk.Refresh()
            end
        end)
    end_page()

    -- ===================================================== Map and zones
    begin_page("map")
    -- one row = the zone family + the zones module (off either way showed English)
    local function zone_on()
        return F.Room.On("namesZone") and mods_on("dungeons")
    end
    local zr = tog(PN.namesZone, PN.namesZone_d, zone_on,
        function(v)
            F.Room.Set("namesZone", v)
            if v then
                ensure_mod("dungeons")
            end
        end, "zone")
    panel.room.namesZone = zr
    panel.mods.dungeons = zr
    panel.zoneMap = choice(PN.zoneMap, nil, PN.three_name,
        function() return F.db.zoneMap or 2 end,
        function(v)
            F.db.zoneMap = v
            F:Fire("options", "zoneMap")
        end, "map")
    panel.zoneMap.dimIf = function() return not zone_on() end
    end_page()

    -- ===================================================== NPCs and talk
    begin_page("npc")
    -- one row = the npc module + the namesNpc family + the display (1 fa / 2 fa + en / 3 en)
    panel.npcName = choice(PN.npcName, PN.npcName_d, PN.three_name,
        function()
            if not F.Room.On("namesNpc") or not mods_on("npc") then
                return 3
            end
            return F.NpcMode and F.NpcMode() or 1
        end,
        function(v)
            F.db.npcName = v
            if v == 3 then
                F.Room.Set("namesNpc", false)
            else
                if not F.Room.On("namesNpc") then
                    F.Room.Set("namesNpc", true)
                end
                ensure_mod("npc")
            end
            F:Fire("npcname")
        end, "npc")
    panel.mods.npc = panel.npcName
    header(PN.h_talk)
    dlg_tog("dlgGossip", "gossip")
    dlg_tog("dlgSay", "say")
    panel.dlgSay.dimIf = function() return F.db.chatFa == false end
    dlg_tog("dlgBook")
    end_page()

    -- ===================================================== Chat and messages
    begin_page("chat")
    panel.chatFa = tog(PN.chatFa, PN.chatFa_d,
        function() return F.db.chatFa ~= false end,
        function(v)
            F.db.chatFa = v and true or false
            F:Fire("options", "chatFa")
        end, "chat")
    header(PN.h_sys)
    for _, k in ipairs(SYS) do
        sys_tog(k)
    end
    panel.sysmsg = panel.sysLoot
    header(PN.h_alerts)
    panel.alerts = tog(PN.alerts, PN.alerts_d,
        function() return F.db.alerts ~= false end,
        function(v)
            F.db.alerts = v and true or false
            F:Fire("options", "alerts")
        end, "alert")
    end_page()

    -- ===================================================== The game's own windows (1.2.0)
    begin_page("game")
    header(PN.h_gameui, true)
    panel.gameUi = tog(PN.gameUi, PN.gameUi_d,
        function() return F.db.gameUi ~= false end,
        function(v)
            F.db.gameUi = v and true or false
            F:Fire("options", "gameUi")
        end, "gameui")
    header(PN.h_gwin, true)
    panel.guiG = {}
    for _, gid in ipairs(F.GameUI and F.GameUI.Groups or {}) do
        local gt = tog(PN["gu_" .. gid] or gid, nil,
            function() return F.GameUI.GroupOn(gid) end,
            function(v) F.GameUI.SetGroup(gid, v) end)
        gt.dimIf = function() return F.db.gameUi == false end
        panel.guiG[gid] = gt
    end
    end_page()

    -- ===================================================== Spells and talents
    -- the name: namesSpell (every surface, also inside the quest texts) + the tooltip display;
    -- the description: textDesc + the tooltip display. 3 = English = the family off.
    begin_page("spellbook")
    local function spells_off()
        return not mods_on("spellbook") and not mods_on("talents")
    end
    panel.spName = choice(PN.spName, PN.spName_d, PN.three_name,
        function()
            if not F.Room.On("namesSpell") or spells_off() then
                return 3
            end
            return F.Disp("*", "title")
        end,
        function(v)
            if v == 3 then
                F.Room.Set("namesSpell", false)
            else
                if not F.Room.On("namesSpell") then
                    F.Room.Set("namesSpell", true)
                end
                F.DispSetDefault("title", v)
                ensure_mod("spellbook")
                ensure_mod("talents")
            end
        end, "spell")
    panel.spDesc = choice(PN.spDesc, nil, PN.desc_opt,
        function()
            if not F.Room.On("textDesc") or spells_off() then
                return 3
            end
            return F.Disp("*", "desc")
        end,
        function(v)
            if v == 3 then
                F.Room.Set("textDesc", false)
            else
                if not F.Room.On("textDesc") then
                    F.Room.Set("textDesc", true)
                end
                F.DispSetDefault("desc", v)
                ensure_mod("spellbook")
                ensure_mod("talents")
            end
        end, "spell")
    header(PN.h_talents)
    panel.talentOwn = tog(PN.talentOwn, PN.talentOwn_d,
        function() return F.DispCustom("talents") end,
        function(v) F.DispSetCustom("talents", v) end, "spell")
    panel.talentOwn.wfaSec = "talents"
    local function own() return F.DispCustom("talents") end
    panel.tlName = choice(PN.tlName, nil, PN.three_name,
        function()
            if not F.Room.On("namesSpell") then
                return 3
            end
            return F.Disp("talents", "title")
        end,
        function(v)
            if v ~= 3 and not F.Room.On("namesSpell") then
                -- the talents in Persian while the spells stay English
                F.DispSetDefault("title", 3)
                F.Room.Set("namesSpell", true)
            end
            F.DispSet("talents", "title", v)
            ensure_mod("talents")
        end, "spell")
    panel.tlName.wfaSec, panel.tlName.showIf = "talents", own
    panel.tlDesc = choice(PN.tlDesc, nil, PN.desc_opt,
        function()
            if not F.Room.On("textDesc") then
                return 3
            end
            return F.Disp("talents", "desc")
        end,
        function(v)
            if v ~= 3 and not F.Room.On("textDesc") then
                F.DispSetDefault("desc", 3)
                F.Room.Set("textDesc", true)
            end
            F.DispSet("talents", "desc", v)
            ensure_mod("talents")
        end, "spell")
    panel.tlDesc.wfaSec, panel.tlDesc.showIf = "talents", own
    if not own() then
        panel.tlName:Hide()
        panel.tlDesc:Hide()
    end
    -- the tests and the old ids
    panel.dispTitle = { talents = panel.tlName }
    panel.dispDesc = { talents = panel.tlDesc }
    panel.dispCustom = { talents = panel.talentOwn }
    panel.mods.spellbook, panel.mods.talents = panel.spName, panel.talentOwn
    end_page()

    -- ===================================================== Font sizes
    begin_page("sizes")
    header(PN.h_size)
    panel.fontSize = slider(PN.fontSize, 9, 20, 1,
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
        end)
    panel.szList = pct_slider(PN.szList, "szList", 100, 70, 200)
    panel.szGame = pct_slider(PN.szGame, "szGame", 100, 70, 160)
    panel.chatScale = pct_slider(PN.chatScale, "chatScale", 90, 60, 120, "options", "chatFa")
    panel.alertScale = pct_slider(PN.alertScale, "alertScale", 100, 70, 160)
    panel.scale = slider(PN.scale, 0.8, 1.3, 0.05,
        function() return F.db.scale end,
        function(v)
            if v ~= F.db.scale then
                F.db.scale = v
                panel:SetScale(v)
            end
        end)
    header(PN.h_font)
    panel.fontAll = tog(PN.fontAll, PN.fontAll_d,
        function() return F.db.fontAll == true end,
        function(v)
            F.db.fontAll = v and true or false
            F:Fire("options", "fontAll")
        end, "font")
    end_page()

    -- ===================================================== Colours and outline
    begin_page("colors")
    panel.colOn = tog(PN.colOn, PN.colOn_d,
        function() return F.db.col and F.db.col.on and true or false end,
        function(v) F.ColSetOn(v) end, "text")
    header(PN.h_col)
    panel.col = {}
    local function col_off()
        return not (F.db.col and F.db.col.on)
    end
    for _, fam in ipairs(F.T.COL_FAMS) do
        local row = dimmable(UI.Choice(page.child, PW - 16, (PN.col and PN.col[fam]) or L["col_" .. fam] or fam, nil,
            F.ColLabels(fam),
            function() return F.ColIndex(fam) end,
            function(v) F.ColSet(fam, v) end))
        local cbase = row.Update
        row.Update = function(self)
            cbase(self)
            local hex = F.ColHex(fam)
            if hex and not self.dimmed then
                self.val:SetTextColor(tonumber(string.sub(hex, 1, 2), 16) / 255,
                    tonumber(string.sub(hex, 3, 4), 16) / 255, tonumber(string.sub(hex, 5, 6), 16) / 255)
            else
                self.val:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
            end
        end
        -- any colour, exactly (the game's colour picker)
        row.pick = UI.Button(row, PN.col_pick or L.col_pick, 84, 22, function()
            F.ColPick(fam)
        end)
        row.pick:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -4)
        row.val:ClearAllPoints()
        row.val:SetPoint("TOPLEFT", row, "TOPLEFT", 96, -6)
        row.dimOnMaster = true
        row.dimIf = col_off
        row.wfaEye = "text"
        row.wfaHi = fam
        row:Update()
        panel.col[fam] = place(row, 32, 2)
    end
    header(PN.h_ol)
    note(PN.ol_note)
    panel.ol = {}
    for _, k in ipairs({ "npc", "zn", "qs", "sp", "text" }) do
        panel.ol[k] = tog((PN.ol and PN.ol[k]) or k, nil,
            function() return F.OlOn(k) end,
            function(v) F.OlSet(k, v) end, k == "text" and "text" or nil)
    end
    end_page()

    -- ===================================================== Profiles and share
    begin_page("share")
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
        local ok, why, nt = F.Room.ShareImport(txt)
        local msg = ok and L.sh_ok or tostring(why)
        if ok and nt then
            msg = msg .. " " .. nt
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
    end_page()

    -- ===================================================== Status and report
    begin_page("health")
    health = { mods = {} }
    panel.health = health
    do
        -- 1.1.8: the first thing on the report page: how a player can help (the tour)
        local hb = CreateFrame("Frame", nil, page.child)
        hb:SetSize(PW - 16, 36)
        panel.helpBtn = UI.Button(hb, PN.help_btn or " ", PW - 40, 30, function()
            F.OpenTour()
        end)
        panel.helpBtn:SetPoint("CENTER", hb, "CENTER", 0, 0)
        style_help(panel.helpBtn)
        place(hb, 36, 6)
    end
    header(L.rp2_hdr)
    health.fSteps = note(L.rp2_steps)
    local mh = CreateFrame("Frame", nil, page.child)
    mh:SetSize(PW - 16, 24)
    health.missHead = UI.Text(mh, 13, C.goldLight)
    health.missHead:SetPoint("TOPRIGHT", mh, "TOPRIGHT", -4, 0)
    health.missHead:SetFa(L.rp2_none, PW - 30)
    health.fHead = place(mh, 24, 2)
    local mk = CreateFrame("Frame", nil, page.child)
    mk:SetSize(PW - 16, 22)
    health.missKinds = UI.Text(mk, 12, C.muted)
    health.missKinds:SetPoint("TOPRIGHT", mk, "TOPRIGHT", -4, 0)
    health.missKinds:SetFa(" ", PW - 30)
    health.fKinds = place(mk, 22, 4)
    local ml = CreateFrame("Frame", nil, page.child)
    ml:SetSize(PW - 16, 28)
    health.missList = code_box(ml, false)
    health.fList = place(ml, 28, 4)
    local mbt = CreateFrame("Frame", nil, page.child)
    mbt:SetSize(PW - 16, 30)
    panel.missCopy = UI.Button(mbt, L.rp2_btn, 190, 26, function()
        if health.missList then
            health.missList:SetFocus()
            health.missList:HighlightText()
        end
        if health.copyMsg then
            health.copyMsg:SetFa(L.rp2_copied, PW - 30)
            color(health.copyMsg, C.green)
        end
    end)
    panel.missCopy:SetPoint("RIGHT", mbt, "RIGHT", -4, 0)
    panel.missClear = UI.Button(mbt, L.btn_miss_clear, 150, 26, function()
        F:ClearMiss()
        refresh()
    end)
    panel.missClear:SetPoint("RIGHT", panel.missCopy, "LEFT", -8, 0)
    place(mbt, 30, 2)
    local cm = CreateFrame("Frame", nil, page.child)
    cm:SetSize(PW - 16, 24)
    health.copyMsg = UI.Text(cm, 12, C.green)
    health.copyMsg:SetPoint("TOPRIGHT", cm, "TOPRIGHT", -4, 0)
    health.copyMsg:SetFa(" ", PW - 30)
    place(cm, 24, 6)

    header(L.fl_hdr)
    note(L.fl_steps)
    local fp = CreateFrame("Frame", nil, page.child)
    fp:SetSize(PW - 16, 28)
    health.svPath = code_box(fp, true)
    health.svPath:SetText(F.SvPath())
    health.svPath:SetCursorPosition(0)
    health.svPath:SetScript("OnEnterPressed", function(self)
        F.SvPathSet(self:GetText())
        self:ClearFocus()
        self:SetText(F.SvPath())
        self:SetCursorPosition(0)
        if health.svMsg then
            health.svMsg:SetFa(L.fl_saved, PW - 30)
            color(health.svMsg, C.green)
        end
    end)
    place(fp, 28, 4)
    local fb = CreateFrame("Frame", nil, page.child)
    fb:SetSize(PW - 16, 30)
    panel.svCopy = UI.Button(fb, L.fl_btn, 190, 26, function()
        local box = health.svPath
        if box then
            local t = box:GetText() or ""
            if t ~= F.SvPath() then
                F.SvPathSet(t)
            end
            box:SetFocus()
            box:HighlightText()
        end
        if health.svMsg then
            health.svMsg:SetFa(L.fl_copied, PW - 30)
            color(health.svMsg, C.green)
        end
    end)
    panel.svCopy:SetPoint("RIGHT", fb, "RIGHT", -4, 0)
    panel.svSave = UI.Button(fb, L.fl_save, 170, 26, function()
        if InCombatLockdown and InCombatLockdown() then
            if health.svMsg then
                health.svMsg:SetFa(L.fl_combat, PW - 30)
                color(health.svMsg, C.orange)
            end
            return
        end
        if ReloadUI then
            ReloadUI()
        end
    end)
    panel.svSave:SetPoint("RIGHT", panel.svCopy, "LEFT", -8, 0)
    place(fb, 30, 2)
    local fm = CreateFrame("Frame", nil, page.child)
    fm:SetSize(PW - 16, 24)
    health.svMsg = UI.Text(fm, 12, C.green)
    health.svMsg:SetPoint("TOPRIGHT", fm, "TOPRIGHT", -4, 0)
    health.svMsg:SetFa(" ", PW - 30)
    place(fm, 24, 2)
    note(L.fl_note)

    header(PN.h_update)
    panel.onUpdate = choice(PN.onUpdate, nil, PN.update_opt,
        function() return F.db.onUpdate end,
        function(v)
            F.db.onUpdate = v
            F:Refresh()
        end)

    header(PN.h_mods or L.tab_health)
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
    -- the error list is a read-only EditBox (the same errors also ride in the report line)
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
    end_page()

    -- ===================================================== About
    begin_page("about")
    header(L.tab_about)
    local abt = CreateFrame("Frame", nil, page.child)
    abt:SetSize(PW - 16, 40)
    abt.text = UI.Text(abt, 12, C.muted)
    abt.text:SetPoint("TOPRIGHT", abt, "TOPRIGHT", -4, 0)
    abt.text:SetFa(L.a_cmds, PW - 30)
    place(abt, 40, 2)
    local site = CreateFrame("Frame", nil, page.child)
    site:SetSize(PW - 16, 20)
    site.text = UI.Latin(site, 11, C.goldLight, "LEFT")
    site.text:SetPoint("LEFT", site, "LEFT", 4, 0)
    site.text:SetText(tostring(F.SITE) .. "  |  Data from ForeverDB.net")
    place(site, 20, 4)
    do
        -- 1.1.8 (the owner 27 Nov): who makes WoWFA, and how to support it
        local made = CreateFrame("Frame", nil, page.child)
        made:SetSize(PW - 16, 70)
        made.text = UI.Text(made, 12, C.text)
        made.text:SetPoint("TOPRIGHT", made, "TOPRIGHT", -4, 0)
        made.text:SetFa(PN.a_made or " ", PW - 30)
        place(made, 70, 4)
        local urlh = CreateFrame("Frame", nil, page.child)
        urlh:SetSize(PW - 16, 26)
        local ub = code_box(urlh, false)
        ub:SetFixed(tostring(F.SITE))
        place(urlh, 26, 4)
        local hb2 = CreateFrame("Frame", nil, page.child)
        hb2:SetSize(PW - 16, 34)
        panel.helpBtn2 = UI.Button(hb2, PN.help_btn or " ", PW - 60, 28, function()
            F.OpenTour()
        end)
        panel.helpBtn2:SetPoint("CENTER", hb2, "CENTER", 0, 0)
        style_help(panel.helpBtn2)
        place(hb2, 34, 6)
    end
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

    -- the live preview column + an eye on every row that has a sample (row.wfaEye)
    if F.PreviewAttach then
        local okp, errp = pcall(F.PreviewAttach, panel)
        if not okp then
            F:LogError("ui", errp)
        end
    end
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

-- page: nil = the section that was open last (General the first time); a section id or one of
-- the older ids (room / mods / display = General, tracker = Quests, talents = Spells)
function F.OpenPanel(pageId)
    if not ensure() then
        return
    end
    panel:Show()
    select_page(pageId or active or "general")
    refresh()
end

-- the "how can I help" tour (the report page and the About page open it)
function F.OpenTour()
    if not ensure() then
        return
    end
    panel:Show()
    select_page("health")
    if F.db then
        F.db.tourSeen = true
    end
    local t = build_tour()
    if t then
        t:Show()
        t.show(1)
    end
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
for _, sig in ipairs({ "state", "room", "errors", "minimap", "miss", "disp", "options", "npcname" }) do
    F:Listen(sig, function()
        if panel and panel:IsShown() then
            refresh()
        end
    end)
end
