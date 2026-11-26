-- WoWFA Forever - dungeons and zones: Persian zone / dungeon name under the
-- game's own zone text when you arrive, and on the minimap zone tooltip.

local F = WoWFAF
local L = F.L
local T = F.T
local UI = F.UI
local C = F.C

local M = { id = "dungeons", order = 3, risk = "low", nameKey = "m_dungeons", descKey = "m_dungeons_d" }

-- inbox/29 D2: the surface flags this module renders (the "surf" listener key)
local SURF_OWNED = { zoneArrival = true, zoneMinimap = true, zoneMap = true, zoneTip = true }

function M.data()
    return F.D.names and F.D.names.zone
end

function M.api()
    return GetRealZoneText ~= nil and GetSubZoneText ~= nil
end

local function fa(name, quiet)
    if not F.Usable(name) or type(name) ~= "string" or name == "" then
        return nil
    end
    -- lane-b16: the zn family switch off = the zone/subzone stays English on
    -- every surface (toasts, minimap tooltip, in-place text) - fa() is the
    -- single lookup point for all of them
    if not F.Room.On("namesZone") then -- 51-B
        return nil
    end
    -- lane-28 §A3: the shared name-key normalisation (the export side keys the
    -- same way), so "The Barrens" resolves even when the client adds the article
    local v = F.D.names.zone[T.NameKey(name)]
    if v == nil then
        -- rc14 (the owner: the map label said "Wetlands (20-30)" in English): the
        -- hover label adds the level range after the zone name
        -- rc16 (the owner: "Hillsbrad Foothills (20-30)" still English): the client
        -- colours the level range, so the colour codes go first
        local plain = (string.gsub(name, "|c%x%x%x%x%x%x%x%x", ""))
        plain = (string.gsub(plain, "|r", ""))
        plain = string.match(plain, "^%s*(.-)%s*$") or plain
        if plain ~= name then
            local pv = F.D.names.zone[T.NameKey(plain)]
            if pv then
                return pv
            end
        end
        -- 1.0.6 (the owner: "Fishing: 1" under the map title and "(Dungeon)" in the quest
        -- list stayed English): fixed label lines (L.MAP_LINES); the second value tells the
        -- caller it is a label, so no English line is added under it
        local LL = L.MAP_LINES
        if type(LL) == "table" then
            for _, row in ipairs(LL) do
                local okg, s, n = pcall(string.gsub, plain, row[1], row[2])
                if okg and n and n > 0 and s ~= plain then
                    return s, true
                end
            end
        end
        local base, lv = string.match(plain, "^(.-)%s*(%(%s*%d+[%s%-%d]*%))$")
        if base and base ~= "" then
            local bv = F.D.names.zone[T.NameKey(base)]
            if bv then
                return bv .. " " .. lv
            end
        end
    end
    -- rc3 update watch: a zone the data does not know (a label with digits is
    -- a level range / description line, never a zone name)
    if v == nil and not quiet and not string.find(name, "%d") and not string.find(name, "[\216-\219\239]") then
        F:Miss("zone", T.NameKey(name), name)
    end
    return v
end

-- ------------------------------------------------- in-place zone text (lane-28 §B)
-- The minimap zone text, the big arrival strings and the world-map label are
-- Blizzard font strings; we intercept SetText AFTER the client (hooksecurefunc)
-- with a re-entry flag, render Persian with our font at the ORIGINAL size (the
-- client keeps its own colour - SetText never touches it) and restore the
-- original font + English on switch off / module off / an unknown name.
-- zoneMap (the owner, rc2): how the WORLD-MAP zone label shows.
-- 1 = Persian only (replaces the English), 2 = Persian with the client's English
-- under it (default), 3 = off (the English stays untouched)
local function map_mode()
    local v = F.db and F.db.zoneMap
    if v ~= 1 and v ~= 3 then
        v = 2
    end
    return v
end

local shapeMemo = {} -- rc4: Persian zone text -> shaped string (per display mode)
local writing = {}  -- fs -> true while WE are inside SetText (re-entry flag)
local original = setmetatable({}, { __mode = "k" }) -- fs -> { font, size, flags, text } of the state to restore (rc36: weak)
local zwatch = setmetatable({}, { __mode = "k" }) -- rc18: fs -> kind of every string we wrote
local zseen = setmetatable({}, { __mode = "k" })  -- rc18: fs -> the text read back last time

local function hookable(fs)
    return fs and type(fs) == "table" and fs.SetText and fs.GetFont
end

-- rc14 (the owner: the breadcrumb above the map showed empty boxes): a button
-- gives its text a new font object after we wrote - the Persian then has no glyphs.
-- The font comes back at once (SetFontObject hook) and every half second.
-- rc20 (the owner: the Persian hover label of the map is hard to read on the parchment): the
-- font flags of the in-place text. The hover label always gets a black outline; the other
-- surfaces keep the outline their own game font had (the arrival text, the minimap text).
local function flags_of(o)
    if F.OlOn and F.OlOn("zn") then
        return "OUTLINE" -- 1.1.0: the zone-name outline switch (Colours page)
    end
    local f = o and o.flags
    if type(f) ~= "string" then
        f = ""
    end
    if string.find(f, "THICKOUTLINE", 1, true) then
        return "THICKOUTLINE"
    end
    if string.find(f, "OUTLINE", 1, true) or (o and o.kind == "map") then
        return "OUTLINE"
    end
    return ""
end
F.ZoneFlags = flags_of

local function refont(fs)
    local o = original[fs]
    if not o or writing[fs] or not M.active then
        return
    end
    local ok, cur = pcall(fs.GetFont, fs)
    if ok and cur ~= F.FONT then
        writing[fs] = true
        pcall(fs.SetFont, fs, F.FONT, o.size or T.Size(), flags_of(o))
        writing[fs] = nil
    end
end

local function guard_font(fs)
    if fs.wfaFontGuard then
        return
    end
    fs.wfaFontGuard = true
    if type(hooksecurefunc) == "function" then
        pcall(hooksecurefunc, fs, "SetFontObject", function(self)
            refont(self)
        end)
    end
end

function M.fix_fonts()
    for fs in pairs(original) do
        refont(fs)
    end
end

local function apply_inplace(fs, faText, enText, kind, noEn)
    if writing[fs] then
        return
    end
    writing[fs] = true
    if not original[fs] then
        local font, size, flags = fs:GetFont()
        original[fs] = { font = font, size = size, flags = flags, text = enText }
    end
    -- Brain review #136-3: the client just set enText - keep the RESTORE text
    -- fresh, so a switch-off later restores what is on screen NOW, not a stale zone
    original[fs].text = enText
    original[fs].kind = kind
    fs:SetFont(F.FONT, (original[fs].size or T.Size()), flags_of(original[fs]))
    guard_font(fs)
    -- Brain review #136-1: the player's CURRENT display mode, never a hardcoded 3
    -- rc4: the map label is re-set by the client every frame: shape once per text
    local mkey = faText .. "\1" .. tostring(T.Mode()) .. tostring(F.Room.On("faDigits"))
    local shown = shapeMemo[mkey]
    if not shown then
        shown = T.ShapeLine(T.Digits(faText), T.Mode())
        shapeMemo[mkey] = shown
    end
    -- zoneMap 2: ONE font string, two lines (Persian, then the English), so the
    -- label's own description line keeps anchoring below it (no overlap)
    if kind == "map" and not noEn and map_mode() == 2 and type(enText) == "string" and enText ~= "" then
        shown = shown .. "\n" .. enText
    end
    fs:SetText(shown)
    original[fs].shown = shown
    writing[fs] = nil
    zwatch[fs] = kind
    zseen[fs] = shown
end

local function unapply_inplace(fs)
    -- the FULL restore (font + the stored English text): switch / module off only
    local o = original[fs]
    if not o or writing[fs] then
        return
    end
    writing[fs] = true
    if o.font then
        pcall(fs.SetFont, fs, o.font, o.size, o.flags or "")
    end
    fs:SetText(o.text)
    original[fs] = nil
    writing[fs] = nil
end

local function font_only_restore(fs)
    -- Brain review #136-2: a MISS from the SetText hook (an unknown zone the
    -- client just wrote) must NOT overwrite the client's text with a stale
    -- stored one - restore the font only, keep the text, forget the frame
    local o = original[fs]
    if not o or writing[fs] then
        return
    end
    if o.font then
        pcall(fs.SetFont, fs, o.font, o.size, o.flags or "")
    end
    original[fs] = nil
end

local function restore_all()
    for fs in pairs(zwatch) do
        zwatch[fs] = nil
    end
    for fs in pairs(original) do
        unapply_inplace(fs)
    end
    -- the client's own update redraws the minimap zone text in English
    if Minimap_Update then
        pcall(Minimap_Update)
    end
end

local function on_inplace(fs, enText, kind)
    -- Brain review #136-4: NO throttle here - a second client SetText within
    -- 0.1 s would be skipped and the English would stay; the re-entry flag is
    -- the guard (throttles live on the tracker walkers only)
    if not hookable(fs) then
        return
    end
    -- rc4 (the owner's miss list: "<Persian> / Eastern Kingdoms" x1755): our OWN
    -- SetText re-enters this hook; never look our Persian output up as a zone
    if writing[fs] then
        return
    end
    -- rc16 (the owner: the zone headers of the quest list flip between Persian, empty
    -- boxes and English): the map scan read our OWN Persian back, found no zone of that
    -- name and put the game font back under the Persian text = empty boxes. Persian text
    -- is never English input: only its font is kept right.
    -- rc18: the SHAPED Persian (display mode 3) is all Arabic presentation forms
    -- (UTF-8 lead byte \239) - the rc16 guard missed it, so the scan still read our own
    -- header back as "no zone" and put the game font under it (the empty boxes)
    if type(enText) == "string" and string.find(enText, "[\216-\219\239]") then
        if original[fs] then
            refont(fs)
        end
        return
    end
    -- the hooks are raw (not F:Wrap): after switch/module OFF they must stop
    -- re-applying and leave the client's own text alone
    if not M.active then
        return
    end
    -- inbox/29 D2: the per-surface switches - the hook for a switched-off
    -- surface never applies (and restore_all on the switch undid the old text)
    if kind == "minimap" and not F.Room.On("namesZone") then
        return
    elseif kind == "arrival" and not F.Room.On("namesZone") then
        return
    elseif (kind == "map" or kind == "maplabel") and (not F.Room.On("namesZone") or map_mode() == 3) then
        return
    end
    -- zoneToast 1-3 own the arrival toast in their own way; only 4 = in place
    if kind == "arrival" and (not F.db or F.db.zoneToast ~= 4) then
        return
    end
    -- rc19 (the owner: some texts turn English when a fight starts): the quest list headers
    -- (maplabel) are plain font strings and the quest list redraws on every kill - they
    -- follow it in combat too. Only the hover label keeps the old combat guard (lane-28 §B).
    if kind == "map" and InCombatLockdown and InCombatLockdown() then
        return
    end
    local faText, lbl
    if enText ~= "" then
        faText, lbl = fa(enText, kind == "maplabel")
    end
    if faText then
        apply_inplace(fs, faText, enText, kind, lbl)
    else
        font_only_restore(fs)
    end
end

local function hook_inplace(fs, kind)
    if not hookable(fs) or fs.wfaHooked then
        return
    end
    fs.wfaHooked = true
    hooksecurefunc(fs, "SetText", function(self, text)
        local ok, err = pcall(on_inplace, self, text, kind)
        if not ok then
            F:LogError("dungeons", err)
        end
    end)
end

-- rc18 (the owner: the quest list zone headers still flip English / Persian / boxes):
-- the header rows are buttons and the client writes them through Button:SetText on the
-- C side, so the FontString hook never fires and the English stayed until the next
-- scan. Every string we once wrote is read back every frame and translated again the
-- moment the client changed it.
function M.watch()
    if not M.active or not F.Room.On("namesZone") then
        return
    end
    for fs, kind in pairs(zwatch) do
        local ok, txt = pcall(fs.GetText, fs)
        if ok and F.Usable(txt) and type(txt) == "string" and txt ~= zseen[fs] then
            zseen[fs] = txt
            if txt ~= "" then
                on_inplace(fs, txt, kind)
            end
        end
    end
end

-- the world-map hover label. Old-style clients have the WorldMapFrameAreaLabel
-- globals; the modern map (Classic-era UI) draws it through an area-label data
-- provider whose frame carries .Name / .Description font strings. The map is
-- load-on-demand: this runs at install, on Blizzard_WorldMap load and on every
-- map open (hook_inplace is idempotent per font string).
local function hook_map()
    hook_inplace(WorldMapFrameAreaLabel, "map")
    hook_inplace(WorldMapFrameAreaDescription, "map")
    local wm = WorldMapFrame
    if type(wm) ~= "table" then
        return
    end
    if not wm.wfaMapHooked and wm.HookScript then
        wm.wfaMapHooked = true
        wm:HookScript("OnShow", function()
            pcall(hook_map)
        end)
    end
    local dps = wm.dataProviders
    if type(dps) == "table" then
        for dp in pairs(dps) do
            local lb = type(dp) == "table" and dp.Label
            if type(lb) == "table" then
                hook_inplace(lb.Name, "map")
            end
        end
    end
    -- rc11: every other font string under the map (title, navigation bar, the
    -- zone headers of the quest log, the pin labels), now and when the map changes
    if M.scan_map then
        M.scan_map()
        F.After(0.4, M.scan_map)
        if wm.OnMapChanged and not wm.wfaMapChanged and type(hooksecurefunc) == "function" then
            wm.wfaMapChanged = true
            pcall(hooksecurefunc, wm, "OnMapChanged", function()
                F.After(0.25, M.scan_map)
            end)
        end
        if C_Timer and C_Timer.NewTicker and not M.ticker then
            local n = 0
            M.ticker = C_Timer.NewTicker(0.5, function()
                if wm.IsShown and wm:IsShown() then
                    n = n + 1
                    M.fix_fonts()
                    if n % 2 == 0 then
                        M.scan_map()
                    end
                end
            end)
        end
    end
end

-- rc11 (the owner: "the zone names on the map: only the two continents work"):
-- every font string under the world map (the title, the navigation bar, the zone
-- headers of the quest log, the pin labels) gets the same in-place SetText hook;
-- the walk repeats whenever the map changes because the map builds its pins
-- lazily. A font string whose text is no zone name is left alone (and never
-- logged as a miss).
local function walk_map(frame, depth, budget)
    if budget.n <= 0 or depth > 10 then
        return
    end
    budget.n = budget.n - 1
    local okr, regions = pcall(function()
        return { frame:GetRegions() }
    end)
    if okr then
        for _, r in ipairs(regions) do
            if type(r) == "table" and r.GetObjectType and r.SetText and r.GetText then
                local okt, ot = pcall(r.GetObjectType, r)
                if okt and ot == "FontString" then
                    hook_inplace(r, "maplabel")
                    local okx, txt = pcall(r.GetText, r)
                    if okx and F.Usable(txt) and type(txt) == "string" and txt ~= "" then
                        on_inplace(r, txt, "maplabel")
                    end
                end
            end
        end
    end
    local okc, kids = pcall(function()
        return { frame:GetChildren() }
    end)
    if okc then
        for _, k in ipairs(kids) do
            if type(k) == "table" and k.GetRegions then
                walk_map(k, depth + 1, budget)
            end
        end
    end
end

function M.scan_map()
    local wm = WorldMapFrame
    if type(wm) ~= "table" or not M.active or not F.Room.On("namesZone") then
        return
    end
    pcall(walk_map, wm, 0, { n = 1500 })
end

-- Brain 64 (the owner: "the Persian zone title fades out on its own timer, make
-- it follow the English one"): the toast used to run its own timeline (0.4 s in,
-- hold to 5 s, 1.2 s out) while the client's own zone text (ZoneTextFrame /
-- SubZoneTextFrame, a fading frame) fades on ITS timeline. The toast now MIRRORS
-- the alpha of the client frame it belongs to, so both appear, hold and
-- disappear together whatever the client's timings are. Fallback to the old
-- timeline when the client frame is missing, unreadable (secret) or never
-- shows within 0.6 s (the player turned the game's zone text off).
local function client_frame(sub_only)
    local fs = sub_only and SubZoneTextString or ZoneTextString
    local ok, p = pcall(function()
        return fs and fs.GetParent and fs:GetParent()
    end)
    if ok and type(p) == "table" and p.GetAlpha and p.IsShown then
        return p
    end
    return nil
end

-- (shown, alpha) of the client's zone text frame; nil when it can not be read
local function client_state(src)
    local ok, shown, a = pcall(function()
        return src:IsShown(), src:GetAlpha()
    end)
    if not ok or not F.Usable(shown) or not F.Usable(a) or type(a) ~= "number" then
        return nil
    end
    return shown and true or false, a
end

local function toast_step(self, el)
    self.t = (self.t or 0) + el
    local src = self.src
    if src then
        local shown, a = client_state(src)
        if shown ~= nil then
            if shown then
                self.seen = true
                self:SetAlpha(a)
                return
            elseif self.seen then
                self:Hide()
                return
            elseif self.t < 0.6 then
                self:SetAlpha(0)
                return
            end
        end
        self.src = nil -- the client text never showed (or can not be read): own timeline
        self.t = 0
    end
    if self.t < 0.4 then
        self:SetAlpha(self.t / 0.4)
    elseif self.t > 5 then
        local a = 1 - (self.t - 5) / 1.2
        if a <= 0 then
            self:Hide()
        else
            self:SetAlpha(a)
        end
    else
        self:SetAlpha(1)
    end
end
F.ZoneToastStep = toast_step

local frame
local function build()
    frame = CreateFrame("Frame", "WoWFAF_ZoneText", UIParent)
    frame:SetSize(520, 80)
    frame:SetFrameStrata("LOW")
    frame:EnableMouse(false)
    if SubZoneTextString then
        frame:SetPoint("TOP", SubZoneTextString, "BOTTOM", 0, -8)
    else
        frame:SetPoint("TOP", UIParent, "TOP", 0, -330)
    end
    frame.kind = UI.Text(frame, 11, C.muted, "CENTER")
    frame.kind:SetPoint("TOP", frame, "TOP", 0, 0)
    frame.main = UI.Text(frame, 22, C.gold, "CENTER")
    frame.main:SetPoint("TOP", frame.kind, "BOTTOM", 0, -2)
    frame.sub = UI.Text(frame, 15, C.text, "CENTER")
    frame.sub:SetPoint("TOP", frame.main, "BOTTOM", 0, -4)
    frame:SetScript("OnUpdate", toast_step)
    frame:Hide()
end

local function toast(main, sub, kind, sub_only)
    if not main and not sub then
        return
    end
    if not frame then
        build()
    end
    frame.kind:SetFa(kind or "", 500)
    frame.kind:SetShown(kind ~= nil)
    frame.main:SetFa(main or sub, 500)
    if main and sub then
        frame.sub:SetFa(sub, 500)
        frame.sub:Show()
    else
        frame.sub:Hide()
    end
    frame.t = 0
    frame.seen = false
    frame.src = client_frame(sub_only) -- Brain 64: follow the client's own fade
    frame:SetAlpha(frame.src and 0 or 0)
    frame:Show()
end

local lastZone, lastSub
local function update()
    local zone, sub = GetRealZoneText(), GetSubZoneText()
    if not F.Usable(zone) or not F.Usable(sub) then
        return
    end
    local mode = F.db.zoneToast
    local inInst, itype
    if IsInInstance then
        inInst, itype = IsInInstance()
    end
    local dungeon = F.Usable(inInst) and inInst and F.Usable(itype) and (itype == "party" or itype == "raid") or false
    local kind = dungeon and (itype == "raid" and L.zone_raid or L.zone_dungeon) or nil
    if zone ~= lastZone then
        lastZone, lastSub = zone, sub
        local zfa = fa(zone)
        -- lane-b16: with the zn family off the miss is the user's own switch,
        -- not a data gap - never feed it to the health watch. Brain review:
        -- 51-B had this inverted (it fed the watch ONLY while the switch was
        -- off, i.e. only false misses, and never a real hit)
        if F.Room.On("namesZone") then
            F:Track("dungeons", zfa ~= nil)
        end
        if F.Room.On("namesZone") and (mode == 1 or (mode == 2 and dungeon)) then
            toast(zfa, sub ~= "" and sub ~= zone and fa(sub) or nil, zfa and kind or nil)
        end
    elseif sub ~= lastSub then
        lastSub = sub
        if F.Room.On("namesZone") and mode == 1 and sub ~= "" then
            toast(fa(sub), nil, nil, true)
        end
    end
end

function M.install()
    -- rc15 (the owner: the zone headers of the quest list still showed empty boxes): the
    -- game resets the font of its buttons without a Lua call we can hook, so the font is
    -- checked ten times a second (the table holds only the strings we wrote)
    local fixer = CreateFrame("Frame")
    local acc = 0
    fixer:SetScript("OnUpdate", function(_, el)
        -- rc18: every frame while the map is open (the tables hold only the strings we wrote).
        -- 1.1.5: with the map closed only five times a second (the CPU the owner saw, 26 Nov)
        local wm = WorldMapFrame
        if el and not (type(wm) == "table" and wm.IsShown and wm:IsShown()) then
            acc = acc + el
            if acc < 0.2 then
                return
            end
            acc = 0
        end
        if M.active and next(zwatch) ~= nil then
            local ok, err = pcall(M.watch)
            if not ok then
                F:LogError("dungeons", err)
            end
        end
        if M.active and next(original) ~= nil then
            M.fix_fonts()
        end
    end)
    -- rc18: a quest log change rebuilds the header rows - scan right after it
    local pend = false
    F:On("QUEST_LOG_UPDATE", "dungeons", function()
        local wm = WorldMapFrame
        if pend or type(wm) ~= "table" or not (wm.IsShown and wm:IsShown()) then
            return
        end
        pend = true
        F.After(0.05, function()
            pend = false
            pcall(M.scan_map)
        end)
    end)
    F:On("ZONE_CHANGED_NEW_AREA", "dungeons", update)
    F:On("ZONE_CHANGED", "dungeons", update)
    F:On("ZONE_CHANGED_INDOORS", "dungeons", update)
    F:On("PLAYER_ENTERING_WORLD", "dungeons", function()
        lastZone = nil
        F.After(1, F:Wrap("dungeons", update))
    end)
    if MinimapZoneTextButton and MinimapZoneTextButton.HookScript then
        MinimapZoneTextButton:HookScript("OnEnter", F:Wrap("dungeons", function()
            if not F.Room.On("namesZone") then
                return -- inbox/29 D2: the minimap zone tooltip surface
            end
            if not GameTooltip:IsShown() then
                return
            end
            local z, s = fa(GetRealZoneText()), fa(GetSubZoneText())
            if not z and not s then
                return
            end
            if not T.Once(GameTooltip, "zone|" .. (z or "") .. "|" .. (s or "")) then
                return
            end
            if z then
                T.TipLine(GameTooltip, z, C.gold)
            end
            if s and s ~= z then
                T.TipLine(GameTooltip, s, C.text)
            end
            T.Done(GameTooltip)
            GameTooltip:Show()
        end))
    end
    -- lane-28 §B: the minimap zone text IN PLACE (re-entry flag in the hook)
    hook_inplace(MinimapZoneText, "minimap")
    -- the big arrival strings: zoneToast 4 = "in place" (the 1-3 toast values
    -- keep working untouched; the hook itself checks the option)
    for _, fs in ipairs({ ZoneTextString, SubZoneTextString, PVPInfoTextString }) do
        hook_inplace(fs, "arrival")
    end
    -- world map: hover label + map title when the frames exist (probe from
    -- lane 27; a 1.60.1 client without them just no-ops). Combat-guarded.
    hook_map()
    F:On("ADDON_LOADED", "dungeons", function(a, b)
        if a == "Blizzard_WorldMap" or b == "Blizzard_WorldMap" then
            hook_map()
        end
    end)
    -- a new zoneMap choice: put the English back now, the next hover re-applies
    F:Listen("options", function(a, b)
        if a == "zoneMap" or b == "zoneMap" or a == "zoneToast" or b == "zoneToast" or a == "fontOutline" then -- rc36
            restore_all()
        end
    end)
    -- any switch change may have turned us off: restore everything, the next
    -- client SetText re-applies what is still allowed
    F:Listen("names", restore_all)
    -- inbox/29 D2: the surface switches of THIS module - a switch-off must put
    -- the English back RIGHT NOW (restore_all = font + the stored text; the
    -- next client SetText re-applies only the surfaces still allowed)
    F:Listen("surf", function(name)
        if name == nil or SURF_OWNED[name] then
            restore_all()
        end
    end)
end

function M.onState(_, active)
    if not active and frame then
        frame:Hide()
    end
    if not active then
        restore_all()
    end
end

F:RegisterModule(M)
