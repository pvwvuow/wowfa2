-- Room.lua - inbox/51 B: «اتاق کاستوم ترجمه» - the ONE source of truth for
-- what the addon translates (site parity: assets/js/tr.js WF4 v3.11 spec).
-- Every hook (tooltips, quest pane/log/tracker, gossip, nameplates, map,
-- minimap) reads Room.On(key) / Room.OnRole(letter); nothing reads the
-- pre-51 flags (names.*, surf.*, itemDetail, itemLines, itemStyle,
-- itemNotes) any more - those migrate into db.room exactly once.
--
-- The 15 site bits are FROZEN in WF4 share-code order (tr.js SHARE_KEYS).
-- The game-only bits are never in the share code; the site decoder ignores
-- them and a pasted code leaves them exactly as the user set them.
-- db.room = { v = 1, m = <preset id>, d = { [key] = true|false, faPlace = 1|2 } }
--
-- Brain 59 (the owner's r7 test):
--   * namesSet  = the set names (the set header + the piece list) - its own
--     switch, separate from the item names ("the item names and the set
--     names must be separate"); it follows namesItem once at the upgrade and
--     on every preset, after that it is the user's;
--   * textSet   = the set bonus lines "(2) Set: ..." - an extra gate on top
--     of their text category (on by default: nothing changes until the user
--     turns it off);
--   * profiles  = named snapshots of the room + the modules + the display
--     settings in WoWFA_FDB.profiles (account-wide), save / load / delete.

local F = WoWFAF
local Room = {}
F.Room = Room

local floor = math.floor
local T -- Text (F.T), bound lazily (Boot / Changed)

-- ------------------------------------------------------------ key layout
Room.SITE_KEYS = { "namesItem", "namesSpell", "namesNpc", "namesZone", "namesQuest", "namesObj",
    "terms", "textDesc", "textStats", "textReq", "textBind", "textDetail", "textFlavor", "uiLabels",
    "namesClass" } -- 15 FROZEN bits (bit 14 = namesClass, v4.1, never re-ordered)
Room.GAME_KEYS = { "questText", "npcSay", "faDigits", "greyNotes", "namesSet", "textSet" } -- game only
-- faPlace is a choice (1 = in place, 2 = below), never a share-code bit.

Room.GAME_DEFAULT = { questText = true, npcSay = true, faDigits = true, greyNotes = true,
    namesSet = true, textSet = true }

-- the site's exact preset bitmaps (tr.js REC / STATSONLY) + the game additions
local ALL_ON = { namesItem = true, namesSpell = true, namesNpc = true, namesZone = true, namesQuest = true,
    namesObj = true, terms = true, textDesc = true, textStats = true, textReq = true, textBind = true,
    textDetail = true, textFlavor = true, uiLabels = true, namesClass = true }
local ALL_OFF = {}
for k in pairs(ALL_ON) do ALL_OFF[k] = false end

local PRESETS = {
    recommended = { m = "recommended", d = { namesItem = false, namesSpell = false, namesClass = true,
        namesNpc = false, namesZone = false, namesQuest = true, namesObj = false, terms = true,
        textDesc = true, textStats = true, textReq = true, textBind = true, textDetail = true,
        textFlavor = false, uiLabels = true } },
    fa = { m = "fa", d = ALL_ON },
    stats = { m = "stats", d = { namesItem = false, namesSpell = false, namesClass = false, namesNpc = false,
        namesZone = false, namesQuest = false, namesObj = false, terms = false, textDesc = false,
        textStats = true, textReq = true, textBind = false, textDetail = false, textFlavor = false,
        uiLabels = false } },
    en = { m = "en", d = ALL_OFF },
}
Room.PRESETS = PRESETS
-- rc29: two more presets. story = quests, NPC names and talk, zones, classes;
-- spells = spells and talents (names, descriptions, terms) only
PRESETS.story = { m = 'story', d = { namesItem = false, namesSpell = false, namesClass = true,
    namesNpc = true, namesZone = true, namesQuest = true, namesObj = true, terms = false,
    textDesc = false, textStats = false, textReq = false, textBind = false, textDetail = false,
    textFlavor = false, uiLabels = false } }
PRESETS.spells = { m = 'spells', d = { namesItem = false, namesSpell = true, namesClass = true,
    namesNpc = false, namesZone = false, namesQuest = false, namesObj = false, terms = true,
    textDesc = true, textStats = false, textReq = false, textBind = false, textDetail = true,
    textFlavor = false, uiLabels = true } }
Room.PRESET_IDS = { "recommended", "fa", "stats", "en" }
Room.PRESET_LBL = { recommended = "پیشنهادی", fa = "کاملاً فارسی", stats = "فقط آمار",
    en = "کاملاً انگلیسی", custom = "سفارشی" }
Room.PRESET_DESC = { recommended = "اسمی انگلیسی می‌ماند؛ متن‌ها فارسی می‌شوند",
    fa = "هر چه ترجمه داشته باشد فارسی می‌شود", stats = "فقط آمار و نیازمندی‌ها فارسی",
    en = "همه‌چیز انگلیسی می‌ماند (مخصوص بازی)", custom = "ترکیب دلخواه تو — هر دسته جدا" }

Room.PRESET_IDS = { 'recommended', 'fa', 'story', 'spells', 'stats', 'en' }
Room.PRESET_LBL.story = F.L.pr_story or 'story'
Room.PRESET_LBL.spells = F.L.pr_spells or 'spells'
Room.PRESET_DESC.story = F.L.pr_story_d or ''
Room.PRESET_DESC.spells = F.L.pr_spells_d or ''

-- line role letter (the exporter ships it per line) -> the owning switch
Room.ROLE_KEY = { d = "textDesc", s = "textStats", r = "textReq", b = "textBind",
    t = "textDetail", f = "textFlavor" }

-- the engine's name family (T.FAMILIES) -> the room key
Room.FAM_KEY = { it = "namesItem", sp = "namesSpell", cls = "namesClass", npc = "namesNpc",
    zn = "namesZone", qs = "namesQuest", ob = "namesObj", tm = "terms", set = "namesSet" }

local listeners = {}

-- ------------------------------------------------------------ storage
local migrate -- forward: db() runs it when the room is missing

local function db()
    if not F.db then
        F.db = {}
    end
    local r = F.db.room
    if type(r) ~= "table" then
        -- Brain review: a missing room (the first run, or /wowfa reset wiping
        -- the saved settings) migrates RIGHT HERE from whatever flags exist.
        -- It used to start as {m = "recommended", d = {}}: the label said
        -- «پیشنهادی» while every switch read ON (= «کاملاً فارسی»).
        r = { d = {} }
        F.db.room = r
        migrate(r)
    end
    if type(r.d) ~= "table" then
        r.d = {}
    end
    return r
end

-- Brain 59: the two split bits are written explicitly once (an existing room
-- from 0.6.1 has neither): the set names follow the item names, the set
-- bonus gate starts on - the output is exactly what it was before the split
local function fill_split(d)
    if d.namesSet == nil then
        d.namesSet = d.namesItem ~= false
    end
    if d.textSet == nil then
        d.textSet = true
    end
end

function Room.Mode()
    return db().m
end

function Room.On(key) -- nil = ON for the name families + the text roles (the engine contract)
    -- 104 STEP A: the release lock gates the name kinds + the module keys
    if F.RELEASE_LOCK and F.RELEASE_LOCK[key] and not F.RELEASE_UNLOCK[key] then
        return false
    end
    local d = db().d
    local v = d[key]
    if v == nil then
        v = (Room.GAME_DEFAULT[key] ~= false) -- the game bits default on
    end
    return v ~= false
end

function Room.OnRole(letter) -- the exported line role (d/s/r/b/t/f); "" = treat as a description
    return Room.On(Room.ROLE_KEY[letter] or "textDesc")
end

function Room.FaPlace()
    return db().d.faPlace or 1 -- 1 = in place, 2 = below
end

function Room.ItemLinesOn() -- any text category on -> the tooltip body translates
    for _, k in ipairs({ "textDesc", "textStats", "textReq", "textBind", "textDetail", "textFlavor" }) do
        if Room.On(k) then
            return true
        end
    end
    -- Brain 59: every text category off = the body stays exactly the game's
    -- (the set names alone never open it: the old detail-1 promise "the name
    -- only" stays true)
    return false
end

-- Brain review: a missing (nil) site bit reads ON in Room.On, so it must
-- count as ON here too - the migration never writes uiLabels, and every
-- migrated user used to land on «سفارشی» instead of his real preset
local SITE_ONLY_BIT = { uiLabels = true } -- B7 (PANEL_V2 section 1): no game
-- consumer and no row - the game-side mode calculation drops it, so a pasted
-- code or a Set on that bit alone cannot flip the mode to custom.

local function mode_of(d)
    for _, id in ipairs(Room.PRESET_IDS) do
        local same = true
        for k, v in pairs(PRESETS[id].d) do
            if not SITE_ONLY_BIT[k] and (d[k] ~= false) ~= v then
                same = false
                break
            end
        end
        if same then
            return id
        end
    end
    return "custom"
end

function Room.Set(key, v) -- a site-bit toggle -> the mode follows the bits (the site rule)
    local r = db()
    if key == "faPlace" then
        -- a game-only choice, not a site bit: the preset name stays
        r.d.faPlace = (v == 2) and 2 or 1
    else
        r.d[key] = v and true or false
    end
    r.m = mode_of(r.d)
    Room.Changed()
    return r.m
end

function Room.Apply(m) -- a preset button
    local p = PRESETS[m]
    if not p then
        return
    end
    local r = db()
    local old = r.d or {}
    r.d = {}
    for k, v in pairs(p.d) do
        r.d[k] = v
    end
    -- Brain review: the presets speak for the SITE bits; the game-only bits
    -- and faPlace are the user's own and survive a preset (they used to reset
    -- to the defaults). The two exceptions keep the preset's promise:
    -- «کاملاً انگلیسی» turns the quest/NPC texts off, «کاملاً فارسی» on.
    for k, v in pairs(Room.GAME_DEFAULT) do
        if old[k] ~= nil then
            r.d[k] = old[k]
        else
            r.d[k] = v
        end
    end
    if old.faPlace then
        r.d.faPlace = old.faPlace
    end
    if m == "en" then
        r.d.questText, r.d.npcSay = false, false
    elseif m == "fa" then
        r.d.questText, r.d.npcSay = true, true
    elseif m == 'story' then
        r.d.questText, r.d.npcSay = true, true
    elseif m == 'spells' then
        r.d.questText, r.d.npcSay = false, false
    end
    -- Brain 59: the set names are a split of the item names - every preset
    -- sets them the way it sets the item names
    r.d.namesSet = p.d.namesItem and true or false
    r.m = m
    Room.Changed()
end

function Room.Reset() -- «بازگشت به پیشنهادی»: the site default AND the game defaults
    local r = db()
    r.d = {}
    Room.Apply("recommended")
end

function Room.OnChange(fn)
    listeners[#listeners + 1] = fn
end

function Room.Changed()
    -- D2: no reload - the open texts re-render right now through the same
    -- channels the old names page / SetSurf used
    local t = T or F.T
    F:Fire("room")
    F:Fire("options", "room")
    F:Fire("names")
    -- Brain review: the quest pane / tracker / zone listeners act on "surf"
    -- (the old SetSurf path) - without it a switch-off waited for the next open
    F:Fire("surf")
    if t and t.RefreshAll then
        t.RefreshAll()
    end
    for _, fn in ipairs(listeners) do
        local ok, err = pcall(fn)
        if not ok then
            geterrorhandler()(err)
        end
    end
end

-- ------------------------------------------------------------ WF4 share code
-- EXACT tr.js parity (the site's encodeCode/decodeCode/wf4check, v2):
--   payload = base36 of the 15-bit mask (bit i = SITE_KEYS[i], LSB first)
--   wf4check("WF4-"..payload): h1 = (sum v_i*(i+1)) % 37, h2 = (sum v_i*(i+3)) % 37
--     over that WHOLE string (the dash parses as 0 and SHIFTS the indices);
--   ccc = 3 base36 chars of h1*37 + h2.
local B36 = "0123456789abcdefghijklmnopqrstuvwxyz"
local B36I = {} -- parseInt(s,36) is case-insensitive: "WF4" contributes W=32, F=15
for i = 1, #B36 do
    B36I[B36:sub(i, i)] = i - 1
    B36I[B36:sub(i, i):upper()] = i - 1
end

local function b36num(n) -- like JS Number.toString(36); 0 -> "0"
    if n == 0 then
        return "0"
    end
    local out = {}
    while n > 0 do
        out[#out + 1] = B36:sub((n % 36) + 1, (n % 36) + 1)
        n = floor(n / 36)
    end
    return table.concat(out):reverse()
end

local function wf4check(s) -- over "WF4-"..payload, dash = 0, 0-based weights
    local h1, h2 = 0, 0
    for i = 0, #s - 1 do
        local v = B36I[s:sub(i + 1, i + 1)] or 0
        h1 = (h1 + v * (i + 1)) % 37
        h2 = (h2 + v * (i + 3)) % 37
    end
    local c = h1 * 37 + h2
    local ccc = b36num(c)
    while #ccc < 3 do
        ccc = "0" .. ccc
    end
    return ccc
end

function Room.Encode()
    local bits = 0
    for i = 1, #Room.SITE_KEYS do
        if Room.On(Room.SITE_KEYS[i]) then
            bits = bits + 2 ^ (i - 1)
        end
    end
    local payload = b36num(bits)
    return "WF4-" .. payload .. "-" .. wf4check("WF4-" .. payload)
end

function Room.Decode(code) -- returns true + the mode, or nil + a Persian reason
    if type(code) ~= "string" then
        return nil, "کد خالی است"
    end
    code = code:gsub("%s+", ""):gsub("،", ""):lower()
    local payload, cc = code:match("^wf4%-([0-9a-z]+)%-([0-9a-z][0-9a-z][0-9a-z])$")
    if not payload then
        return nil, "این کد شکل کد اتاق (WF4) نیست"
    end
    if wf4check("WF4-" .. payload) ~= cc then
        return nil, "رقم کنترل کد درست نیست — یک حرف جا افتاده یا عوض شده"
    end
    local n = 0
    for i = 1, #payload do
        n = n + (B36I[payload:sub(i, i)] or 0) * 36 ^ (#payload - i)
    end
    local r = db()
    local old = r.d or {}
    local d = {}
    for i = 1, #Room.SITE_KEYS do
        d[Room.SITE_KEYS[i]] = (floor(n / 2 ^ (i - 1)) % 2) == 1
    end
    -- Brain review: the game-only bits + faPlace are not in the code - they
    -- stay exactly as the user set them (they used to fall back to defaults)
    for _, k in ipairs(Room.GAME_KEYS) do
        d[k] = old[k]
    end
    d.faPlace = old.faPlace
    fill_split(d)
    r.d = d
    r.m = mode_of(d)
    Room.Changed()
    return true, r.m
end

-- ------------------------------------------------------------ migration (once)
-- the pre-51 flags map into the room; nothing the user set is lost. The old
-- flags stay in db (harmless) but no hook reads them after 51.
migrate = function(r)
    local fdb = F.db or {}
    local d = {}
    for k, v in pairs(Room.GAME_DEFAULT) do
        d[k] = v
    end
    local names = fdb.names or {}
    d.namesItem = names.it ~= false
    d.namesSpell = names.sp ~= false
    d.namesClass = names.cls ~= false
    d.namesNpc = names.npc ~= false
    d.namesZone = names.zn ~= false
    d.namesQuest = names.qs ~= false
    d.namesObj = names.ob ~= false
    d.terms = names.tm ~= false
    -- the game-only bits merge the old where-flags (AND inside each family)
    local surf = fdb.surf or {}
    d.questText = surf.questPane ~= false and surf.questLog ~= false and surf.qobj ~= false
    d.npcSay = surf.gossip ~= false
    d.greyNotes = fdb.itemNotes ~= false
    d.faDigits = fdb.faDigits ~= false
    d.faPlace = (fdb.itemStyle == 2) and 2 or 1
    -- itemDetail 1 = name only, 2 = the important (effect) lines, 3 = every line
    local det = tonumber(fdb.itemDetail) or 3
    local on = Room.ItemLinesFrom(det, fdb.itemLines ~= false)
    for k, v in pairs(on) do
        d[k] = v
    end
    d.namesSet = d.namesItem -- Brain 59: the split follows the item names
    d.textSet = true
    r.d = d
    r.m = mode_of(d)
    r.v = 1
    Room.migrated = true
    return r
end

-- the tests (and the migration) flip the whole detail level at once
function Room.SetDetail(detail, lines_on)
    -- lines_on defaults to true (SetDetail(3) = everything on; the itemLines
    -- off case passes SetDetail(3, false) explicitly)
    for k, v in pairs(Room.ItemLinesFrom(detail, lines_on ~= false)) do
        Room.Set(k, v)
    end
end

-- detail -> the text category bits (the OLD e/f split: e = spell/setb/flavor/
-- open/misc/classes, f = stats/slot/bind/req; detail 3 showed everything)
function Room.ItemLinesFrom(detail, lines_on)
    local d = { textDesc = false, textStats = false, textReq = false, textBind = false,
        textDetail = false, textFlavor = false }
    if not lines_on then
        return d -- itemLines off = the body never translated
    end
    if detail >= 3 then
        for k in pairs(d) do d[k] = true end
    elseif detail == 2 then
        d.textDesc = true -- the e lines: the effects (+ the flavor, also an e line)
        d.textFlavor = true
    end
    return d
end

-- ------------------------------------------------------------ profiles
-- Brain 59 (the owner: "why can I not save a profile of my settings?").
-- A profile = the room (every bit + faPlace + the preset name), the module
-- switches (never the opt-in capture helper) and the display options. The
-- SavedVariables are account-wide, so every character sees the same list.
local PROFILE_OPTS = { "fontSize", "scale", "questDock", "questAuto", "zoneToast", "onUpdate", "toast", "share",
    "szList", "szGame", "chatScale", "alertScale", "fontAll", "chatFa" }
Room.PROFILE_MAX = 10

local function deep(v)
    if type(v) ~= "table" then
        return v
    end
    local o = {}
    for k, x in pairs(v) do
        o[k] = deep(x)
    end
    return o
end

-- at most 24 characters (UTF-8 aware), no control / escape characters
local function clean_name(s)
    s = tostring(s or "")
    s = s:gsub("[%c|]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    local out, n = {}, 0
    for ch in s:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        n = n + 1
        if n > 24 then
            break
        end
        out[#out + 1] = ch
    end
    return (table.concat(out):gsub("%s+$", ""))
end
Room.ProfileCleanName = clean_name

local function profiles()
    local fdb = F.db
    if type(fdb.profiles) ~= "table" then
        fdb.profiles = {}
    end
    return fdb.profiles
end

function Room.ProfileNames()
    local out = {}
    for k, v in pairs(profiles()) do
        if type(k) == "string" and type(v) == "table" then
            out[#out + 1] = k
        end
    end
    table.sort(out)
    return out
end

-- returns true, "saved" | "updated", the clean name - or nil + a Persian reason
function Room.ProfileSave(name)
    name = clean_name(name)
    if name == "" then
        return nil, "اول یک اسم برای پروفایل بنویس"
    end
    local ps = profiles()
    local existed = type(ps[name]) == "table"
    if not existed and #Room.ProfileNames() >= Room.PROFILE_MAX then
        return nil, "حداکثر ۱۰ پروفایل؛ اول یکی را حذف کن"
    end
    local fdb = F.db
    local p = { v = 1, t = time and time() or 0, room = deep(db()), mods = {}, opt = {} }
    for k, v in pairs(fdb.mods or {}) do
        if k ~= "capture" then
            p.mods[k] = v and true or false
        end
    end
    for _, k in ipairs(PROFILE_OPTS) do
        p.opt[k] = fdb[k]
    end
    p.opt.minimapHide = (type(fdb.minimap) == "table" and fdb.minimap.hide) and true or false
    ps[name] = p
    return true, existed and "updated" or "saved", name
end

-- returns true + the room mode, or nil + a Persian reason
function Room.ProfileLoad(name)
    local p = profiles()[name]
    if type(p) ~= "table" or type(p.room) ~= "table" then
        return nil, "این پروفایل پیدا نشد"
    end
    local fdb = F.db
    local r = deep(p.room)
    if type(r.d) ~= "table" then
        r.d = {}
    end
    r.v = r.v or 1
    fill_split(r.d)
    if r.m ~= "custom" and not PRESETS[r.m] then
        r.m = mode_of(r.d)
    end
    fdb.room = r
    for k, v in pairs(type(p.mods) == "table" and p.mods or {}) do
        if k ~= "capture" and type(fdb.mods) == "table" and fdb.mods[k] ~= nil then
            fdb.mods[k] = v and true or false
        end
    end
    local opt = type(p.opt) == "table" and p.opt or {}
    for _, k in ipairs(PROFILE_OPTS) do
        local v = opt[k]
        -- Brain 59: an option the current settings lack (a fresh or reset
        -- db, e.g. scale = nil) takes the profile's value too; a value of a
        -- different type never lands
        if v ~= nil and (fdb[k] == nil or type(v) == type(fdb[k])) then
            fdb[k] = v
        end
    end
    if opt.minimapHide ~= nil and type(fdb.minimap) == "table" then
        fdb.minimap.hide = opt.minimapHide and true or false
    end
    if F.Refresh then
        F:Refresh()
    end
    local pf = F.PanelFrame and F.PanelFrame() -- rc36: the open window takes the loaded scale
    if pf and pf.SetScale then
        pf:SetScale(F.db.scale or 1)
    end
    F:Fire("options", "questDock")
    F:Fire("options", "questAuto")
    F:Fire("options", "szList")
    F:Fire("options", "szGame")
    F:Fire("options", "fontAll")
    F:Fire("options", "chatFa")
    F:Fire("options", "alertScale")
    F:Fire("minimap")
    Room.Changed() -- the open texts + the panel re-render now (RefreshAll included)
    return true, r.m
end

function Room.ProfileDelete(name)
    local ps = profiles()
    if ps[name] == nil then
        return nil
    end
    ps[name] = nil
    return true
end

-- ------------------------------------------------------------ rc8: per-section display
-- The NAME (title) and the DESCRIPTION of a spell / talent tooltip, per section:
--   title: 1 = Persian only (replaces the English), 2 = Persian + English below, 3 = English
--   desc : 1 = Persian replaces the English line, 2 = Persian below it, 3 = off (English)
-- F.db.disp = { title = 2, desc = 2, sec = { spellbook = { custom = true, title = 1, desc = 2 } } }
-- A section follows the General value until its own «custom» switch is on.
local function disp_db()
    local fdb = F.db
    if type(fdb) ~= "table" then
        return {}
    end
    if type(fdb.disp) ~= "table" then
        fdb.disp = {}
    end
    return fdb.disp
end

local function mode3(v)
    v = tonumber(v)
    if v == 1 or v == 2 or v == 3 then
        return v
    end
    return nil
end

function F.Disp(sec, what) -- what = "title" | "desc"; sec = "spellbook" | "talents" | "*" (General)
    local d = disp_db()
    local s = type(d.sec) == "table" and d.sec[sec] or nil
    if type(s) == "table" and s.custom then
        local v = mode3(s[what])
        if v then
            return v
        end
    end
    return mode3(d[what]) or 2
end

function F.DispCustom(sec)
    local d = disp_db()
    local s = type(d.sec) == "table" and d.sec[sec] or nil
    return type(s) == "table" and s.custom == true
end

function F.DispSetDefault(what, v)
    local d = disp_db()
    d[what] = mode3(v) or 2
    F:Fire("disp")
end

local function own(sec)
    local d = disp_db()
    if type(d.sec) ~= "table" then
        d.sec = {}
    end
    local s = d.sec[sec]
    if type(s) ~= "table" then
        -- a new own setting starts from what the section shows right now
        s = { title = F.Disp(sec, "title"), desc = F.Disp(sec, "desc") }
        d.sec[sec] = s
    end
    return s
end

function F.DispSet(sec, what, v)
    local s = own(sec)
    s.custom = true
    s[what] = mode3(v) or 2
    F:Fire("disp")
end

function F.DispSetCustom(sec, on)
    if on then
        own(sec).custom = true
    else
        local d = disp_db()
        local s = type(d.sec) == "table" and d.sec[sec] or nil
        if type(s) == "table" then
            s.custom = false
        end
    end
    F:Fire("disp")
end

-- ------------------------------------------------------------ rc11: share a whole setup
-- WFP1-<tokens>-<check>: everything the user customised as one short code that
-- others can paste into their own panel (the site's WF4 code only holds the 15
-- name / text bits; a WF4 code is still accepted by ShareImport).
-- The tokens are separated by "."; the first character is the key, the rest the value:
--   s = the 15 site bits (base36)   g = the game bits (base36)   p = faPlace (1 / 2)
--   t / e = General title / description display (1-3)
--   b / a = the spellbook / talents section: custom 0|1, title, description (3 digits)
--   n = the NPC name display (1-3)   c = colours on (0|1)
--   u v w x y q r = the colour index of zn / sp / npc / cls / it / tm / ob
local SHARE_COL = { u = "zn", v = "sp", w = "npc", x = "cls", y = "it", q = "tm", r = "ob" }
local SHARE_COL_ORDER = { "u", "v", "w", "x", "y", "q", "r" }
local SHARE_SEC = { { "b", "spellbook" }, { "a", "talents" } }
-- rc24: the format version of a WFP1 code (token z) and how many game bits the maker knew
-- (token h). A code from a NEWER version still works as far as this version understands
-- it (unknown tokens are skipped, the checksum covers the whole payload) and the player is
-- told to update; a code from an OLDER version leaves the game bits it did not know as they are.
Room.SHARE_V = 2

-- the colour ids of a family, in the order of the panel choice (Text.lua COL_PALETTE)
local function share_ids(fam)
    local ids = { "off" }
    for _, id in ipairs((F.T and F.T.COL_PALETTE) or {}) do
        ids[#ids + 1] = id
    end
    if fam == "cls" then
        ids[#ids + 1] = "class"
    end
    return ids
end

local function share_check(s)
    local a = 0
    for i = 1, #s do
        a = (a + string.byte(s, i) * (i % 89 + 1)) % 46656
    end
    local out = b36num(a)
    while #out < 3 do
        out = "0" .. out
    end
    return out
end

local function raw_on(k)
    local v = db().d[k]
    if v == nil then
        v = (Room.GAME_DEFAULT[k] ~= false)
    end
    return v ~= false
end

local function bits_of(keys)
    local n = 0
    for i, k in ipairs(keys) do
        if raw_on(k) then
            n = n + 2 ^ (i - 1)
        end
    end
    return n
end

function Room.ShareExport()
    local d = db().d
    local t = {}
    t[#t + 1] = "s" .. b36num(bits_of(Room.SITE_KEYS))
    t[#t + 1] = "g" .. b36num(bits_of(Room.GAME_KEYS))
    t[#t + 1] = "h" .. tostring(#Room.GAME_KEYS)
    t[#t + 1] = "z" .. tostring(Room.SHARE_V)
    t[#t + 1] = "p" .. tostring(d.faPlace == 2 and 2 or 1)
    t[#t + 1] = "t" .. tostring(F.Disp("*", "title"))
    t[#t + 1] = "e" .. tostring(F.Disp("*", "desc"))
    for _, e in ipairs(SHARE_SEC) do
        t[#t + 1] = e[1] .. (F.DispCustom(e[2]) and "1" or "0") .. tostring(F.Disp(e[2], "title")) .. tostring(F.Disp(e[2], "desc"))
    end
    t[#t + 1] = "n" .. tostring(F.NpcMode and F.NpcMode() or 1)
    local col = type(F.db.col) == "table" and F.db.col or {}
    t[#t + 1] = "c" .. (col.on and "1" or "0")
    for _, k in ipairs(SHARE_COL_ORDER) do
        t[#t + 1] = k .. tostring(F.ColIndex and F.ColIndex(SHARE_COL[k]) or 1)
    end
    local payload = table.concat(t, ".")
    return "WFP1-" .. payload .. "-" .. share_check(payload)
end

-- returns true + the mode, or nil + a Persian reason
function Room.ShareImport(code)
    if type(code) ~= "string" then
        return nil, "کد خالی است"
    end
    code = string.gsub(code, "%s+", "")
    if code == "" then
        return nil, "کد خالی است"
    end
    if string.lower(string.sub(code, 1, 4)) == "wf4-" then
        return Room.Decode(code)
    end
    local pv = string.match(code, "^[Ww][Ff][Pp](%d+)%-")
    if pv and tonumber(pv) > 1 and F.L and F.L.sh_upd then
        return nil, F.L.sh_upd -- a code format this version does not know: update the addon
    end
    local payload, cc = string.match(code, "^[Ww][Ff][Pp]1%-([%w%.]+)%-(%w%w%w)$")
    if not payload then
        return nil, "این کد شکل کد تنظیمات (WFP1) نیست"
    end
    if share_check(payload) ~= string.lower(cc) then
        return nil, "رقم کنترل کد درست نیست؛ یک حرف جا افتاده یا عوض شده"
    end
    local vals = {}
    for tok in string.gmatch(payload, "[^%.]+") do
        vals[string.sub(tok, 1, 1)] = string.sub(tok, 2)
    end
    local function num36(s)
        if s == nil or s == "" then
            return nil
        end
        local n = 0
        for i = 1, #s do
            local v = B36I[string.sub(s, i, i)]
            if v == nil then
                return nil
            end
            n = n * 36 + v
        end
        return n
    end
    local s, g = num36(vals.s), num36(vals.g)
    if not s or not g then
        return nil, "کد ناقص است"
    end
    local r = db()
    local d = {}
    for i, k in ipairs(Room.SITE_KEYS) do
        d[k] = (floor(s / 2 ^ (i - 1)) % 2) == 1
    end
    local known = tonumber(vals.h) or #Room.GAME_KEYS -- the game bits the maker knew
    for i, k in ipairs(Room.GAME_KEYS) do
        if i <= known then
            d[k] = (floor(g / 2 ^ (i - 1)) % 2) == 1
        else
            d[k] = raw_on(k) -- a bit the maker's version did not have: keep this player's own
        end
    end
    d.faPlace = (vals.p == "2") and 2 or 1
    r.d = d
    r.m = mode_of(d)
    local dd = disp_db()
    dd.title = mode3(vals.t) or 2
    dd.desc = mode3(vals.e) or 2
    dd.sec = {}
    for _, e in ipairs(SHARE_SEC) do
        local v = vals[e[1]]
        if v and #v == 3 then
            dd.sec[e[2]] = { custom = string.sub(v, 1, 1) == "1", title = mode3(string.sub(v, 2, 2)) or 2,
                desc = mode3(string.sub(v, 3, 3)) or 2 }
        end
    end
    local n = tonumber(vals.n)
    if n == 1 or n == 2 or n == 3 then
        F.db.npcName = n
    end
    if type(F.db.col) ~= "table" then
        F.db.col = {}
    end
    F.db.col.on = vals.c == "1"
    for _, k in ipairs(SHARE_COL_ORDER) do
        local idx = tonumber(vals[k])
        local ids = share_ids(SHARE_COL[k])
        if idx and ids[idx] then
            F.db.col[SHARE_COL[k]] = ids[idx]
        end
    end
    Room.Changed()
    F:Fire("disp")
    F:Fire("npcname")
    local note
    local z = tonumber(vals.z)
    if z and z > Room.SHARE_V and F.L then
        note = F.L.sh_newer
    end
    return true, r.m, note
end

-- ------------------------------------------------------------ boot
Room.Boot = function()
    T = F.T or T
    local r = db() -- a missing room migrates inside db()
    if not r.v then
        migrate(r)
    end
    fill_split(r.d)
    if r.m ~= "custom" and not PRESETS[r.m] then
        r.m = mode_of(r.d)
    end
end

F:On("ADDON_LOADED", "room_boot", function(_, name)
    if F.db and not Room.booted then
        Room.booted = true
        Room.Boot()
    end
end)
-- the tests / the early readers: the lazy boot keeps Room.On always valid
local _on = Room.On
Room.On = function(key)
    if not Room.booted and F.db then
        Room.booted = true
        Room.Boot()
    end
    return _on(key)
end

Room.MIGRATION_DOC = {
    { "names.it/sp/cls/npc/zn/qs/ob/tm", "namesItem/namesSpell/namesClass/namesNpc/namesZone/namesQuest/namesObj/terms" },
    { "surf.questPane/questLog/qobj", "questText (AND)" },
    { "surf.gossip", "npcSay" },
    { "surf.npcTip/objTip", "namesNpc/namesObj (the name switches own the name tooltips)" },
    { "surf.zone*", "namesZone (the family drives every zone surface)" },
    { "itemDetail 1/2/3", "the text roles off / d+f on / all on" },
    { "itemLines", "off = all six text roles off" },
    { "itemStyle 1/2", "faPlace 1/2" },
    { "itemNotes", "greyNotes" },
    { "(Brain 59) namesItem", "namesSet (once, at the upgrade)" },
}

return Room
