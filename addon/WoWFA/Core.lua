-- WoWFA Forever - core: saved settings, module registry, version guard,
-- circuit breaker, error log, version sharing and slash commands.
--
-- Safety model (see docs/FOREVER_ADDON.md):
--   * every hook runs through F:Wrap -> a module that is not active costs one
--     table lookup, an error never reaches the game (pcall) and 3 errors in a
--     minute (or 10 per session) switch that module off for the session;
--   * a module is only installed (hooks created) after its API check passed;
--   * if the game PATCH (1.60.1 -> 1.61.0) is newer than the translation data,
--     sensitive modules (risk = "high") pause until the user resumes them or
--     updates the addon; a newer build of the same patch (weekly hotfix) only
--     shows a soft warning, so players are not nagged every week;
--   * if most lookups of a module miss (texts no longer match the game) the
--     user is warned once per session.

local ADDON = ...
local L = WoWFAF_L
local F = {}
WoWFAF = F

F.ADDON = ADDON
F.SCHEMA = 2 -- wowfa2 data (tools/wfa/build.py: Meta schema 2, quest field 1 = title hash)
F.TOC_INTERFACE = 16001
F.ROOT = "Interface\\AddOns\\" .. ADDON .. "\\"
F.FONT = F.ROOT .. "Fonts\\Vazirmatn.ttf"
F.MEDIA = F.ROOT .. "Media\\"
F.SITE = "https://wowfarsi.ir"
F.L = L

local function meta(field)
    local get = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    if not get then
        return nil
    end
    local ok, v = pcall(get, ADDON, field)
    if ok then
        return v
    end
end
F.VERSION = meta("Version") or "0.5.0"

-- palette shared with the retail panel and the site
F.C = {
    gold = { 0.941, 0.780, 0.369 },
    goldLight = { 1.0, 0.894, 0.592 },
    goldDark = { 0.545, 0.427, 0.165 },
    text = { 0.95, 0.93, 0.88 },  -- inbox/47 D: the body text on the cards
    muted = { 0.78, 0.76, 0.70 }, -- inbox/47 D: the descriptions (4.5:1 on bg2)
    off = { 0.45, 0.43, 0.40 },
    bg1 = { 0.075, 0.08, 0.10 },  -- inbox/47 D: the window (a 0.97)
    bg2 = { 0.12, 0.13, 0.17 },   -- inbox/47 D: the cards (a 0.92, gold border)
    content = { 0.095, 0.10, 0.13 }, -- inbox/47 D: the content area = one step lighter than the sidebar
    hairline = { 0.26, 0.25, 0.22 }, -- inbox/47 D: the row separators (a 0.15)
    green = { 0.45, 0.85, 0.45 },
    orange = { 1.0, 0.62, 0.25 },
    red = { 1.0, 0.38, 0.33 },
    blue = { 0.45, 0.70, 1.0 },
}

-- ------------------------------------------------------------------ helpers
local issecret = issecretvalue
function F.Secret(v)
    if v == nil or issecret == nil then
        return false
    end
    local ok, s = pcall(issecret, v)
    return (not ok) or s == true
end

function F.Usable(v)
    return v ~= nil and not F.Secret(v)
end

function F.After(sec, fn)
    if C_Timer and C_Timer.After then
        C_Timer.After(sec, fn)
        return
    end
    local f = CreateFrame("Frame")
    local t = 0
    f:SetScript("OnUpdate", function(self, el)
        t = t + el
        if t >= sec then
            self:SetScript("OnUpdate", nil)
            fn()
        end
    end)
end

function F.Split(s, sep)
    local out, pos = {}, 1
    while true do
        local a = string.find(s, sep, pos, true)
        if not a then
            out[#out + 1] = string.sub(s, pos)
            return out
        end
        out[#out + 1] = string.sub(s, pos, a - 1)
        pos = a + #sep
    end
end

-- djb2 over the bytes of T.NameKey(title), mod 2^32, as 8 lowercase hex chars.
-- Mirrors tools/wfa/core.py title_hash: the data stores this hash instead of
-- the English quest title. h * 33 + byte stays below 2^38 (exact in doubles);
-- the hex is built by hand because %x on a 32-bit client int would overflow.
local HEX = "0123456789abcdef"
function F.TitleHash(title)
    if type(title) ~= "string" or title == "" or not F.T or not F.T.NameKey then
        return ""
    end
    local s = F.T.NameKey(title)
    if s == "" then
        return ""
    end
    local h = 5381
    for i = 1, #s do
        h = (h * 33 + string.byte(s, i)) % 4294967296
    end
    local out = ""
    for _ = 1, 8 do
        local d = h % 16
        out = string.sub(HEX, d + 1, d + 1) .. out
        h = (h - d) / 16
    end
    return out
end

local function vparts(v)
    local t = {}
    for n in string.gmatch(tostring(v or ""), "%d+") do
        t[#t + 1] = tonumber(n)
    end
    return t
end

-- 1 if a > b, -1 if a < b, 0 if equal
function F.CompareVersion(a, b)
    local x, y = vparts(a), vparts(b)
    for i = 1, math.max(#x, #y) do
        local p, q = x[i] or 0, y[i] or 0
        if p ~= q then
            return p > q and 1 or -1
        end
    end
    return 0
end

function F.Chat(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cfff0c75e" .. tostring(msg) .. "|r")
    end
end

-- English chat line + Persian toast (the toast is drawn with our own font)
function F:Notify(enKey, faText, ...)
    local en = L.en[enKey]
    if en then
        local ok, s = pcall(string.format, en, ...)
        F.Chat(ok and s or en)
    end
    if faText and F.db and F.db.toast and F.Toast then
        F.Toast(faText)
    end
end

-- -------------------------------------------------------------- saved vars
local DEFAULTS = {
    schema = 2, -- db schema (NOT the data schema: F.SCHEMA stays the data's 1)
    enabled = true,
    welcomed = false,
    mode = 3, -- inbox/29 A: mode 3 only - the user-facing picker is gone
    fontSize = 12,
    faDigits = true,
    mods = { items = true, quests = true, dungeons = true, npc = true, tracker = true, spellbook = true, talents = true, capture = false },
    names = { npc = true, zn = true, it = true, sp = true, ob = true, qs = true, cls = true, tm = true },
    -- inbox/29 D2: the per-surface switches of the "چه چیزی ترجمه شود" page;
    -- a surface is live only if master AND its module AND this flag are on
    surf = {
        questPane = true, questLog = true, gossip = true, trackerTitle = true, trackerObj = true,
        zoneArrival = true, zoneMinimap = true, zoneMap = true, zoneTip = true,
        npcTip = true, objTip = true,
    },
    scale = 1, -- inbox/29 D: the panel scale slider (0.8 - 1.3)
    itemDetail = 3, -- inbox/47 B: full tooltip detail by default (the f lines
                    -- are the stats/slot/bind/req the owner read in English)
    itemNotes = true,
    itemStyle = 1, -- inbox/27: 1 = Persian in place (like the site), 2 = under the tooltip
    questDock = 1,
    questAuto = true,
    zoneToast = 4,
    onUpdate = 2,
    ack = {},
    noticed = {},
    minimap = { hide = false, angle = 200 },
    toast = true,
    listTitles = true, -- rc15: quest titles in the quest list of the modern UI are Persian
    share = true,
    dlgGossip = true, dlgSay = true, dlgBook = true, -- 1.0.7: NPC talk + books (Modules/Dialog.lua)
    shiftEn = true, -- 1.0.7: hold Shift = the game's English original
    questie = true, -- 1.1.0: Questie's tooltips + tracker in Persian (Modules/Questie.lua)
    fontOutline = 1, -- 1.1.0: outline of our Persian letters (1 none, 2 thin, 3 thick)
    errors = {},
    lastBuild = 0,
    lastVersion = "",
}
F.DEFAULTS = DEFAULTS

local function fill(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then
                dst[k] = {}
            end
            fill(dst[k], v)
        elseif type(dst[k]) ~= type(v) then
            dst[k] = v
        end
    end
end

local RANGES = { fontOutline = { 1, 3 }, mode = { 1, 3 }, fontSize = { 9, 20 }, itemDetail = { 1, 3 }, itemStyle = { 1, 2 }, questDock = { 1, 3 }, zoneToast = { 1, 4 }, onUpdate = { 1, 3 } }

local function sanitize(db)
    for k, r in pairs(RANGES) do
        local v = tonumber(db[k])
        if not v or v < r[1] or v > r[2] then
            db[k] = DEFAULTS[k]
        else
            db[k] = math.floor(v)
        end
    end
    -- the scale is a REAL number (never floored like the RANGES above)
    local sc = tonumber(db.scale)
    if not sc or sc < 0.8 or sc > 1.3 then
        db.scale = 1
    end
    if type(db.errors) ~= "table" or #db.errors > 30 then
        db.errors = {}
    end
end

local function migrate(db)
    -- db schema 1 = the first Forever schema (mode was user-picked 1/2/3);
    -- schema 2 (inbox/29 A): display mode 3 ONLY - every saved mode becomes 3
    -- in one silent migration. RANGES.mode stays {1,3} so the tests can pin
    -- 1/2 directly, but no user-facing path writes anything else any more.
    if (db.schema or 1) < 2 then
        db.mode = 3
    end
    db.schema = 2
end

-- ----------------------------------------------------- per-surface switches
-- inbox/29 D2: which module each surface flag belongs to; a surface is live
-- only if the master AND its module AND its own flag are on.
local SURF_MOD = {
    questPane = "quests", questLog = "tracker", gossip = "tracker",
    trackerTitle = "tracker", trackerObj = "tracker",
    zoneArrival = "dungeons", zoneMinimap = "dungeons", zoneMap = "dungeons", zoneTip = "dungeons",
    npcTip = "npc", objTip = "npc",
}
F.SURF_MOD = SURF_MOD

-- 51-B: the room owns WHAT translates; Surf survives only as the module gate
-- (db.mods) + the room switch the old surface name folded into. Brain review:
-- the NPC / object name tooltips belong to the NAME switches (namesNpc /
-- namesObj), not to the gossip switch (npcSay)
local SURF_ROOM = {
    questPane = "questText", questLog = "questText", gossip = "npcSay",
    trackerTitle = "questText", trackerObj = "questText", qobj = "questText",
    zoneArrival = "namesZone", zoneMinimap = "namesZone", zoneMap = "namesZone", zoneTip = "namesZone",
    npcTip = "namesNpc", objTip = "namesObj",
}

-- 104 STEP A (Brain/owner 19 Nov) + the 107 A scope fix: the v1.0 release
-- lock. ONE table; the name kinds ride in it too. The owner added SPELLS +
-- TALENTS to v1.0 (RELEASE_V1.md scope line, order 104b), so LOCKED in v1.0 =
-- items / npc / dungeons and the Names kinds item/npc ONLY. SHIPPING: quests,
-- tracker, zone names (namesZone), and the SPELL surfaces - the spellbook
-- module (Modules/Spells.lua, id "spellbook", order 5: the spellbook + spell
-- tooltips via GameTooltip.SetSpell) and the talents module (Modules/Spells.lua,
-- id "talents", order 6: the talent tooltips via GameTooltip.SetTalent + the
-- talent frame text) plus the namesSpell kind (Text.lua MARKER_KEY sp).
-- F:Active reads the state "locked" (never installed, the saved switch
-- untouched) and Room.On gates the kinds. /wowfa unlock <id> flips a
-- SESSION-only override (never saved; a reload restores the lock).
-- wowfa2: "dungeons" is the ONLY zone-name module (arrival text, minimap, map
-- labels), so locking it hid every zone name although zones ship in v1.0.
-- The lock now holds exactly the not-shipped surfaces.
F.RELEASE_LOCK = { items = true,
                   namesItem = true }
F.RELEASE_LABEL = "v1.0"
F.RELEASE_UNLOCK = {} -- session only; never written to the db

function F:Surf(name)
    local db = F.db
    if not db or not db.enabled then
        return false
    end
    local mod = SURF_MOD[name]
    if mod and not db.mods[mod] then
        return false
    end
    if not F.Room then
        return false -- Room boots on ADDON_LOADED; nothing renders before it
    end
    if name == "itemLines" then
        return F.Room.ItemLinesOn()
    end
    local key = SURF_ROOM[name]
    return key and F.Room.On(key) or false
end

function F:SetSurf(name, on)
    -- 51-B: the room owns the switch; the old surface name folds into its
    -- room key (itemLines has no room bit - the six categories replace it)
    if F.Room and name ~= "itemLines" then
        local key = SURF_ROOM[name]
        if key then
            F.Room.Set(key, on)
            return
        end
    end
    if name == "itemLines" then
        -- L1 (PANEL_V2 section 1): the old alias wrote a dead db.surf key
        -- while F:Surf("itemLines") reads Room.ItemLinesOn() - route to the
        -- Room text-role state (the six categories replaced the single bit).
        for _, k in ipairs({ "textDesc", "textStats", "textReq", "textBind", "textDetail", "textFlavor" }) do
            F.Room.Set(k, on and true or false)
        end
        return
    end
    F.db.surf[name] = on and true or false
    F:Fire("surf", name)
    F:Fire("options", "surf:" .. name)
end

function F:InitDB()
    if type(WoWFA_FDB) ~= "table" then
        WoWFA_FDB = {}
        F.freshDB = true
    end
    local db = WoWFA_FDB
    migrate(db)
    fill(db, DEFAULTS)
    sanitize(db)
    F.db = db
end

function F:ResetDB()
    local keepAngle = F.db and F.db.minimap and F.db.minimap.angle
    -- 1.0.7 (the owner: "reset all settings also deleted my saved profiles"): the named
    -- profiles are the player's own data, not a setting - they survive the reset
    local keepProfiles = F.db and type(F.db.profiles) == "table" and F.db.profiles or nil
    local keepSv = F.db and F.db.svPath -- 1.0.8: the WoWFA.lua folder path (status page)
    WoWFA_FDB = {}
    F:InitDB()
    if keepProfiles then
        F.db.profiles = keepProfiles
    end
    if type(keepSv) == "string" and keepSv ~= "" then
        F.db.svPath = keepSv
    end
    F.db.welcomed = true
    F.db.lastBuild = F.clientBuild or 0
    F.db.lastVersion = F.VERSION
    if keepAngle then
        F.db.minimap.angle = keepAngle
    end
    for _, m in ipairs(F.order) do
        m.tripped, m.faults, m.recent = nil, 0, nil
        m.hit, m.miss, m.stale, m.seen, m.health = 0, 0, 0, 0, nil
    end
    F:Refresh()
    if F.T and F.T.RefreshAll then
        F.T.RefreshAll()
    end
    F:Fire("options", "questDock")
    F:Fire("options", "questAuto")
    -- 1.0.7 (the owner: after a reset the game fonts kept their changed sizes): every
    -- option with a live effect is announced, so each module puts its own state back now
    for _, k in ipairs({ "fontSize", "szList", "szGame", "fontAll", "chatFa", "alertScale",
        "zoneMap", "alerts", "sysmsg", "listTitles", "fontOutline" }) do
        F:Fire("options", k)
    end
    F:Fire("minimap")
    F:Fire("surf")
end

-- ----------------------------------------------------------------- events
local ev = CreateFrame("Frame")
local listeners = {}

-- module events: handler only runs while the module is active, errors are caught
function F:On(event, modId, fn)
    if not listeners[event] then
        listeners[event] = {}
        local ok = pcall(ev.RegisterEvent, ev, event)
        if not ok then
            listeners[event] = nil
            return false
        end
    end
    table.insert(listeners[event], { id = modId, fn = modId and F:Wrap(modId, fn) or fn })
    return true
end

ev:SetScript("OnEvent", function(_, event, ...)
    local list = listeners[event]
    if not list then
        return
    end
    for i = 1, #list do
        local ok, err = pcall(list[i].fn, event, ...)
        if not ok then
            F:LogError(list[i].id or "core", err)
        end
    end
end)

-- internal signals (state changes -> panel / minimap button)
local signals = {}
function F:Listen(name, fn)
    signals[name] = signals[name] or {}
    table.insert(signals[name], fn)
end

-- inbox/44 A1: per-signal re-entrancy guard. The panel's "errors" listener
-- calls LogError -> Fire("errors") again; without the guard one bad listener
-- loops Fire -> LogError -> Fire forever (the owner's stack overflow).
local firing = {}
function F:Fire(name, ...)
    if firing[name] then
        return
    end
    firing[name] = true
    for _, fn in ipairs(signals[name] or {}) do
        local ok, err = pcall(fn, ...)
        if not ok then
            -- LogError itself fires "errors"; wrapped in pcall so the guard is
            -- ALWAYS cleared, whatever the listener chain does
            pcall(F.LogError, F, "ui", err)
        end
    end
    firing[name] = nil
end

-- -------------------------------------------------------------- error log
function F:LogError(modId, err)
    local db = F.db
    if not db then
        return
    end
    local msg = string.sub(tostring(err or "?"), 1, 400)
    for _, e in ipairs(db.errors) do
        if e.m == modId and e.e == msg then
            e.n = (e.n or 1) + 1
            e.t = time and time() or 0
            F:Fire("errors")
            return
        end
    end
    table.insert(db.errors, 1, { m = modId, e = msg, n = 1, t = time and time() or 0, b = F.clientBuild or 0, v = F.VERSION })
    while #db.errors > 30 do
        table.remove(db.errors)
    end
    F:Fire("errors")
end

-- ------------------------------------------------------------- modules
F.mods, F.order = {}, {}
local ACTIVE = { ok = true, warn = true, locked = false }

function F:RegisterModule(m)
    m.faults, m.hit, m.miss, m.stale, m.seen = 0, 0, 0, 0, 0
    m.state = "off"
    F.mods[m.id] = m
    table.insert(F.order, m)
    table.sort(F.order, function(a, b)
        return (a.order or 99) < (b.order or 99)
    end)
end

function F:Wrap(modId, fn)
    return function(...)
        local m = F.mods[modId]
        if m and not m.active then
            return
        end
        local ok, err = pcall(fn, ...)
        if not ok then
            F:Fault(modId, err)
        end
    end
end

function F:Fault(modId, err)
    F:LogError(modId, err)
    local m = F.mods[modId]
    if not m then
        return
    end
    m.faults = (m.faults or 0) + 1
    local now = GetTime and GetTime() or 0
    m.recent = m.recent or {}
    table.insert(m.recent, now)
    while #m.recent > 0 and now - m.recent[1] > 60 do
        table.remove(m.recent, 1)
    end
    if not m.tripped and (#m.recent >= 3 or m.faults >= 10) then
        m.tripped = true
        F:Refresh()
        F:Notify("tripped", string.format(L.t_tripped, L[m.nameKey] or m.id), L.en[m.nameKey] or m.id)
    end
end

-- lookup statistics: warn once when most lookups miss (game texts changed)
function F:Track(modId, hit, stale)
    local m = F.mods[modId]
    if not m then
        return
    end
    m.seen = m.seen + 1
    if hit then
        m.hit = m.hit + 1
    else
        m.miss = m.miss + 1
    end
    if stale then
        m.stale = m.stale + 1
    end
    if m.health or not m.watchMiss then
        return
    end
    local bad = (m.miss >= 15 and m.miss > m.seen * 0.7) or (m.stale >= 20 and m.stale > m.seen * 0.3)
    if bad then
        m.health = "miss"
        F:Refresh()
        F:Notify("miss", string.format(L.t_miss, L[m.nameKey] or m.id), L.en[m.nameKey] or m.id)
    end
end

-- rc3 update watch (the owner: "the game and the data will keep updating,
-- always watch for it"): every lookup that MISSES (a spell name, a tooltip
-- line, a zone the data has no Persian for) is remembered once, with a hit
-- counter, in the saved variables (capped). The status page shows the list in
-- a copy box; the next data update translates exactly what the live game
-- shows. The addon never sends it anywhere.
F.MISS_CAP = 400
-- 1.0.9 (the owner: "if the status list grows, does the addon get heavy?"): the list is
-- capped (400 rows, 300 letters each = well under 150 KB) and a known row only counts up.
-- NPC talk and books are many and long, so they get their own share (F.MISS_TALK) and never
-- push the names, alerts and quests out; their full texts are in WoWFA_Harvest anyway.
F.MISS_TALK = 150
local TALK = { dlg = true, say = true, book = true }
function F:Miss(kind, key, sample, ctx)
    local db = F.db
    if not db or type(key) ~= "string" or key == "" then
        return
    end
    F:MissFresh()
    if type(db.miss) ~= "table" then
        db.miss, db.missN = {}, 0
    end
    local id = tostring(kind) .. ":" .. key
    local e = db.miss[id]
    if e then
        e.n = (tonumber(e.n) or 1) + 1
        return
    end
    if (tonumber(db.missN) or 0) >= F.MISS_CAP then
        return
    end
    local talk = TALK[tostring(kind)]
    if talk and (tonumber(db.missTN) or 0) >= F.MISS_TALK then
        return
    end
    db.miss[id] = { k = tostring(kind), t = string.sub(tostring(sample or key), 1, 300),
        c = ctx and string.sub(tostring(ctx), 1, 80) or nil, n = 1, b = F.clientBuild or 0 }
    db.missN = (tonumber(db.missN) or 0) + 1
    if talk then
        db.missTN = (tonumber(db.missTN) or 0) + 1
    end
    F:Fire("miss")
end

-- rc7: a miss list written by an OLDER build of the addon is stale (the rc6 list
-- still held our own rc3-rc5 output): a new addon version starts a fresh list.
function F:MissFresh()
    local db = F.db
    if db and db.missV ~= F.VERSION then
        db.miss, db.missN, db.missV, db.missTN = {}, 0, F.VERSION, 0
    end
end

function F:ClearMiss()
    if F.db then
        F.db.miss, F.db.missN, F.db.missTN = {}, 0, 0
        F:Fire("miss")
    end
end

local function check_data()
    local D = WoWFA_FData
    F.D = type(D) == "table" and D or {}
    if type(D) ~= "table" or type(D.meta) ~= "table" then
        F.dataState = "nodata"
    elseif tonumber(D.meta.schema) ~= F.SCHEMA then
        F.dataState = "schema"
    else
        F.dataState = "ok"
    end
    F.dataBuild = (type(D) == "table" and type(D.meta) == "table" and tonumber(D.meta.buildNum)) or 0
    F.dataBuildText = (type(D) == "table" and type(D.meta) == "table" and D.meta.build) or "-"
    F.dataVersion = string.match(tostring(F.dataBuildText), "^(%d+%.%d+%.%d+)") or ""
    F.buildNewer = F.dataBuild > 0 and (F.clientBuild or 0) > F.dataBuild
    F.patchNewer = F.dataVersion ~= "" and F.CompareVersion(F.clientVersion or "", F.dataVersion) > 0
end

local function evaluate(m)
    local db = F.db
    if not db.enabled then
        return "master"
    end
    if not db.mods[m.id] then
        return "off"
    end
    if m.tripped then
        return "fault"
    end
    -- capture (W10c) is exempt: it collects the server data that fills the
    -- translation gaps, so it must run exactly when the data is incomplete
    if not m.noData and F.dataState ~= "ok" then
        return F.dataState
    end
    local okd, has = pcall(m.data)
    if not okd or type(has) ~= "table" or next(has) == nil then
        return "nodata"
    end
    local oka, api = pcall(m.api)
    if not oka or not api then
        return "noapi"
    end
    if F.patchNewer then
        local risky = (m.risk == "high" and db.onUpdate >= 2) or db.onUpdate >= 3
        if risky and db.ack[m.id] ~= F.clientVersion then
            return "update"
        end
        return "warn", "patch"
    end
    if m.health then
        return "warn", m.health
    end
    if F.buildNewer then
        return "warn", "build"
    end
    -- lane-b12: a module may carry an info why for the ok state (talents on a
    -- client without SetTalent report "via_spellbook")
    return "ok", m.okWhy
end

function F:Refresh()
    if not F.db then
        return
    end
    for _, m in ipairs(F.order) do
        local st, why = evaluate(m)
        -- 104 STEP A: the release lock wins over everything
        if F.RELEASE_LOCK[m.id] and not F.RELEASE_UNLOCK[m.id] then
            st, why = "locked", "release lock (" .. F.RELEASE_LABEL .. ")"
        end
        if ACTIVE[st] and not m.installed then
            local ok, err = pcall(m.install, m)
            m.installed = ok and true or false
            if not ok then
                F:LogError(m.id, err)
                m.tripped = true
                st, why = "fault", nil
            end
        end
        m.state, m.why = st, why
        local was = m.active
        m.active = ACTIVE[st] or false
        if m.onState and was ~= m.active then
            pcall(m.onState, m, m.active)
        end
    end
    F:Fire("state")
end

function F:Active(modId)
    local m = F.mods[modId]
    return m and m.active
end

function F:SetModule(modId, on)
    F.db.mods[modId] = on and true or false
    local m = F.mods[modId]
    if m and on then
        -- a manual switch-on also clears a tripped breaker and the update pause
        m.tripped, m.faults, m.recent = nil, 0, nil
        if m.state == "update" then
            F.db.ack[modId] = F.clientVersion
        end
    end
    F:Refresh()
end

function F:Resume(modId)
    F.db.ack[modId] = F.clientVersion
    local m = F.mods[modId]
    if m then
        m.tripped, m.faults, m.recent, m.health = nil, 0, nil, nil
        m.hit, m.miss, m.stale, m.seen = 0, 0, 0, 0
    end
    F:Refresh()
end

function F:SetEnabled(on)
    F.db.enabled = on and true or false
    F:Refresh()
end

function F:Issues()
    local n = 0
    for _, m in ipairs(F.order) do
        local s = m.state
        if s == "update" or s == "fault" or s == "noapi" or s == "schema" or (s == "warn" and m.why ~= "build") then
            n = n + 1
        end
    end
    if F.newerVersion then
        n = n + 1
    end
    return n
end

-- ------------------------------------------------------- version sharing
local PREFIX = "WoWFA"
local lastSend = {}

local function can_comm()
    return F.db and F.db.share and C_ChatInfo and C_ChatInfo.SendAddonMessage ~= nil
end

local function send_version(channel)
    if not can_comm() then
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        return
    end
    local now = GetTime and GetTime() or 0
    if lastSend[channel] and now - lastSend[channel] < 120 then
        return
    end
    lastSend[channel] = now
    pcall(C_ChatInfo.SendAddonMessage, PREFIX, "V1|" .. F.VERSION .. "|" .. tostring(F.dataBuild or 0), channel)
end

local function hello()
    local inInst = IsInInstance and IsInInstance()
    if F.Usable(inInst) and inInst then
        return
    end
    if IsInGuild and IsInGuild() then
        send_version("GUILD")
    end
    if IsInRaid and IsInRaid() then
        send_version("RAID")
    elseif IsInGroup and IsInGroup() then
        send_version("PARTY")
    end
end

local function on_addon_msg(_, prefix, text, _, sender)
    if prefix ~= PREFIX or not F.Usable(text) or not F.Usable(sender) then
        return
    end
    local me = UnitName and UnitName("player")
    if Ambiguate and F.Usable(me) and Ambiguate(sender, "short") == me then
        return
    end
    local tag, ver = string.match(text, "^(V%d)|([%d%.]+)|")
    if tag ~= "V1" or not ver then
        return
    end
    if F.CompareVersion(ver, F.VERSION) > 0 and (not F.newerVersion or F.CompareVersion(ver, F.newerVersion) > 0) then
        -- ignore absurd jumps (a broken or hostile client) above +5 major
        local a, b = vparts(ver)[1] or 0, vparts(F.VERSION)[1] or 0
        if a - b > 5 then
            return
        end
        F.newerVersion = ver
        F:Notify("newver", string.format(L.t_newver, ver), ver)
        F:Fire("state")
    end
end

-- ------------------------------------------------------------- startup
local function client_build()
    local version, build, _, iface = GetBuildInfo()
    return tonumber(build) or 0, tonumber(iface) or 0, tostring(build or "?"), tostring(version or "")
end

local function after_login()
    F.clientBuild, F.interface, F.clientBuildText, F.clientVersion = client_build()
    check_data()
    local db = F.db
    if F.dataState == "nodata" then
        F:Notify("nodata", L.t_nodata)
    elseif F.dataState == "schema" then
        F:Notify("schema", L.why_schema)
    end
    -- game newer than the data: a new patch pauses sensitive parts (toast),
    -- a hotfix build of the same patch is one quiet chat line
    local tag = tostring(F.clientVersion) .. "." .. tostring(F.clientBuild)
    if (F.patchNewer or F.buildNewer) and not db.noticed[tag] then
        db.noticed[tag] = true
        F.After(6, function()
            if F.patchNewer then
                F:Notify("update", L.t_update, F.clientVersion .. "." .. F.clientBuildText, F.dataBuildText)
            else
                F:Notify("build", nil, F.clientBuildText, F.dataBuildText)
            end
        end)
    end
    if F.interface > F.TOC_INTERFACE then
        F.Chat(string.format(L.en.iface, F.interface, F.TOC_INTERFACE))
    end
    if db.lastVersion ~= "" and F.CompareVersion(F.VERSION, db.lastVersion) > 0 then
        F.After(8, function()
            F:Notify(nil, string.format(L.t_upgraded, F.VERSION))
        end)
    end
    db.lastBuild = F.clientBuild
    db.lastVersion = F.VERSION
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        pcall(C_ChatInfo.RegisterAddonMessagePrefix, PREFIX)
    end
    F:Refresh()
    F:Fire("login")
    F.Chat(string.format(L.en.loaded, F.VERSION, F.dataBuildText))
end

F:On("ADDON_LOADED", nil, function(_, name)
    if name == ADDON then
        F:InitDB()
    end
end)
F:On("PLAYER_LOGIN", nil, function()
    if not F.db then
        F:InitDB() -- SavedVariables missing (beta clients sometimes drop them)
    end
    after_login()
end)
F:On("PLAYER_ENTERING_WORLD", nil, function()
    F.After(12, hello)
end)
F:On("GROUP_ROSTER_UPDATE", nil, function()
    F.After(5, hello)
end)
F:On("CHAT_MSG_ADDON", nil, on_addon_msg)

-- ---------------------------------------------------------------- slash
local function status_line()
    local parts = {}
    for _, m in ipairs(F.order) do
        parts[#parts + 1] = (L.en[m.nameKey] or m.id) .. "=" .. tostring(m.state)
    end
    return string.format(L.en.status, F.VERSION, tostring(F.clientBuildText), tostring(F.dataBuildText), table.concat(parts, ", "))
end
F.StatusLine = status_line

SLASH_WOWFAF1 = "/wowfa"
SLASH_WOWFAF2 = "/wfa"
SlashCmdList["WOWFAF"] = function(msg)
    if not F.db then
        return
    end
    local cmd = string.lower(string.match(msg or "", "^%s*(%S*)") or "")
    if cmd == "on" then
        F:SetEnabled(true)
        F.Chat(L.en.on)
    elseif cmd == "off" then
        F:SetEnabled(false)
        F.Chat(L.en.off)
    elseif cmd == "unlock" then
        -- 104 STEP A: the session-only dev unlock for the OWNER's testing
        local what = string.match(msg or "", "^%s*%S+%s+(%S+)") or ""
        if F.RELEASE_LOCK[what] then
            F.RELEASE_UNLOCK[what] = true
            F:Refresh()
            F.Chat("unlocked '" .. what .. "' for THIS session only (never saved; a reload restores the lock)")
        else
            F.Chat("usage: /wowfa unlock <locked module> - '" .. tostring(what) .. "' is not a locked module")
        end
    elseif cmd == "why" and F.Walk and F.Walk.Why then
        F.Walk.Why() -- rc18: why a quest list line stays English
    elseif cmd == "status" then
        F.Chat(status_line())
    elseif cmd == 'target' and F.TargetInfo then
        F.TargetInfo()
    elseif cmd == "reset" then
        F:ResetDB()
        F.Chat(L.en.reset)
    elseif cmd == "minimap" or cmd == "mm" then
        F.db.minimap.hide = not F.db.minimap.hide
        F:Fire("minimap")
    elseif cmd == "quest" and F.QuestToggle then
        F.QuestToggle()
        -- inbox/29 B: with no quest window open the toggle must SAY so -
        -- F.QuestToggle answers through F.QuestToggled (nil = nothing open)
        if not F.QuestToggled then
            F.Chat(L.en.noquest or "WoWFA: no quest window open")
        end
        F.QuestToggled = nil
    elseif cmd == "selftest" then
        -- 51-D3: every room switch through a real render (English chat line +
        -- the Persian result in the room)
        if F.RoomSelftest then
            F.RoomSelftest()
        end
    elseif cmd == "probe" then
        -- inbox/27 section 4: one English chat line for the owner to paste -
        -- which quest/watch/tooltip frames and functions exist on THIS client
        -- (lane 28 builds its quest surfaces from exactly this answer)
        local names = { "QuestWatchFrame", "QuestWatch_Update", "WatchFrame", "ObjectiveTrackerFrame",
            "QuestLogFrame", "QuestMapFrame", "GossipFrame", "ZoneTextString", "SubZoneTextString",
            "MinimapZoneText", "WorldMapFrame", "ItemRefShoppingTooltip1", "TooltipDataProcessor" }
        local out = {}
        for _, n in ipairs(names) do
            out[#out + 1] = n .. "=" .. (_G[n] ~= nil and "Y" or "N")
        end
        out[#out + 1] = "C_QuestLog.GetQuestObjectives=" .. ((C_QuestLog and C_QuestLog.GetQuestObjectives) and "Y" or "N")
        out[#out + 1] = "GetQuestLogLeaderBoard=" .. (GetQuestLogLeaderBoard and "Y" or "N")
        F.Chat("probe: " .. table.concat(out, " "))
    elseif F.OpenPanel then
        local page = ({ test = "display", mode = "display", errors = "health", health = "health", welcome = "welcome" })[cmd]
        F.OpenPanel(page)
    end
end

-- addon compartment (minimap addon menu on modern clients)
function WoWFA_F_Compartment(_, button)
    if button == "RightButton" then
        F:SetEnabled(not F.db.enabled)
    elseif F.OpenPanel then
        F.OpenPanel()
    end
end

function WoWFA_F_CompartmentEnter(_, frame)
    if F.MinimapTooltip then
        F.MinimapTooltip(frame)
    end
end

function WoWFA_F_CompartmentLeave()
    if GameTooltip then
        GameTooltip:Hide()
    end
end
