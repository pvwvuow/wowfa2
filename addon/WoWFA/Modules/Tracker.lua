-- WoWFA Forever - quest tracker: Persian titles and objective lines rendered
-- IN PLACE on the game's own tracker (lane-28 §C), plus the quest log list
-- titles and the gossip / quest-greeting buttons. Risk low: every UI
-- generation is guarded (a missing frame is a no-op), font strings only (plain
-- writes, safe in combat), and every original byte + font is restored when the
-- module or a family switch goes off.
--
-- Surfaces:
--   classic  QuestWatchFrame    QuestWatch_Update + QuestWatchLine%d
--   era 2    WatchFrame         WatchFrame_Update + the same line pattern
--   modern   ObjectiveTrackerFrame (quest module Update + block header/lines)
--   quest log   QuestLogFrame buttons QuestLogTitle%d (QUEST_LOG_UPDATE)
--   gossip      GossipTitleButton%d / QuestTitleButton%d (GOSSIP_SHOW,
--               QUEST_GREETING)
--
-- Objective lines are rebuilt with MARKERS and run through T.Prepare, so every
-- family switch works exactly like everywhere else:
--   monster "%s slain: %d/%d"  ->  {{npc:EN|fa}} کشته‌شده: %d/%d
--   item    "%s: %d/%d"        ->  {{it:EN|fa}}: %d/%d      (names.itn)
--   object  "%s: %d/%d"        ->  {{ob:EN|fa}}: %d/%d
--   reputation / event / log  ->  the Persian objective text from D.qobj
-- The EN side is parsed with the client's own GlobalStrings turned into
-- patterns (English constants as the fallback); C_QuestLog.GetQuestObjectives
-- is used when the client has it, GetQuestLogLeaderBoard as the fallback.

local F = WoWFAF
local L = F.L
local T = F.T
local C = F.C
local SEP = "\031"

local M = { id = "tracker", order = 7, risk = "low", nameKey = "m_tracker", descKey = "m_tracker_d" }

-- inbox/29 D2: the surface flags this module renders (the "surf" listener key)
local SURF_OWNED = { questLog = true, gossip = true, trackerTitle = true, trackerObj = true }

function M.data()
    return F.D.quests
end

function M.api()
    return (QuestWatchFrame ~= nil or WatchFrame ~= nil or ObjectiveTrackerFrame ~= nil or QuestLogFrame ~= nil)
        and GetQuestLogTitle ~= nil
end

-- ------------------------------------------------------------- data helpers
local function get_quest(id)
    local raw = id and F.D.quests[id]
    if type(raw) ~= "string" then
        return nil
    end
    local p = F.Split(raw, SEP)
    return { h = p[1] or "", t = p[2] or "" }
end

local function simple(s)
    return (string.gsub(string.lower(tostring(s or "")), "[^%w]", ""))
end

-- names.qs governs quest titles; an empty Persian title falls back to the
-- English one (the B4 pattern) - nil here means "leave the line alone"
local function title_fa(id)
    if not F.Room.On("namesQuest") then -- 51-B
        return nil
    end
    local q = get_quest(id)
    if not q or q.t == "" then
        return nil
    end
    return T.Prepare(q.t)
end

-- ------------------------------------------------------ objective line build
-- the client's GlobalStrings turned into Lua patterns; the plain English
-- constants are the fallback when the client does not carry them
local OBJ_PATTERNS = {
    { fam = "npc", g = "QUEST_MONSTERS_KILLED", plain = "%s slain: %d/%d", verb = true },
    { fam = "it", g = "QUEST_ITEMS_NEEDED", plain = "%s: %d/%d" },
    { fam = "ob", g = "QUEST_OBJECTS_FOUND", plain = "%s: %d/%d" },
    { fam = "rep", g = "QUEST_FACTION_NEEDED", plain = "%s: %d/%d" },
}

local MAGIC = "()%.[]%+-*?^$"
local function pattern_of(fmt)
    -- walk the GlobalString format: %s -> (.-), %d -> (%d+), every other
    -- literal character escaped (escaping FIRST would break the %%s/%%d
    -- placeholders themselves)
    local out, i = {}, 1
    while i <= #fmt do
        local c = string.sub(fmt, i, i)
        if c == "%" then
            local n = string.sub(fmt, i + 1, i + 1)
            if n == "s" then
                out[#out + 1] = "(.-)"
            elseif n == "d" then
                out[#out + 1] = "(%d+)"
            else
                out[#out + 1] = "%" .. (n == "" and "" or n)
            end
            i = i + 2
        else
            if string.find(MAGIC, c, 1, true) then
                out[#out + 1] = "%" .. c
            else
                out[#out + 1] = c
            end
            i = i + 1
        end
    end
    return "^" .. table.concat(out) .. "$"
end

-- "Young Stranglethorn Tiger slain: 0/8" -> npc, "Young Stranglethorn Tiger", 0, 8
local function parse_obj_line(en)
    for _, o in ipairs(OBJ_PATTERNS) do
        local fmt = _G[o.g]
        if type(fmt) ~= "string" or fmt == "" then
            fmt = o.plain
        end
        local name, got, need = string.match(tostring(en or ""), pattern_of(fmt))
        if name and string.match(name, "^%s*(.-)%s*$") ~= "" then
            return o.fam, string.match(name, "^%s*(.-)%s*$"), tonumber(got), tonumber(need)
        end
    end
end

local function name_fa(fam, en)
    local names = F.D.names or {}
    local tbl
    if fam == "npc" then
        tbl = names.npc
    elseif fam == "it" then
        tbl = names.itn
    elseif fam == "ob" then
        tbl = names.obj
    else
        return nil
    end
    -- wowfa2: v1.0 ships no npc / item / object name tables (locked kinds), so
    -- the English name rides in the marker: the line still gets the Persian
    -- verb and the live counts, exactly what the v0 lock showed in game
    return (tbl and tbl[T.NameKey(en)]) or en
end

-- monster "%s slain: %d/%d" -> {{npc:EN|fa}} کشته‌شده: %d/%d   (lane-28 §C)
local function line_from_obj(fam, en, got, need)
    local fa = name_fa(fam, en)
    if not fa then
        return nil
    end
    local verb = (fam == "npc" and (" " .. L.tracker_slain) or "")
    return T.Digits(T.Prepare(string.format("{{%s:%s|%s}}%s: %d/%d", fam, en, fa, verb, got or 0, need or 0)))
end

-- reputation / event / log objectives: the Persian text we already have
local function line_from_qobj(qid, idx)
    local list = F.Room.On("questText") and F.D.qobj and F.D.qobj[qid] -- 51-B
    local fa = list and list[idx]
    if type(fa) ~= "string" or fa == "" then
        return nil
    end
    return T.Digits(T.Prepare(fa))
end

-- "(Complete)" / "Ready for turn-in" -> Persian (lane-28 §C)
local STATUS = {
    { en = "(complete)", fa = "(%s)" },
    { en = "complete", fa = "%s" },
    { en = "ready for turn-in", fa = "%s" },
}

local function status_fa(en)
    local t = string.lower(string.match(en, "^%s*(.-)%s*$") or "")
    for _, s in ipairs(STATUS) do
        if t == s.en then
            local fa = (s.en == "ready for turn-in" and L.tracker_ready) or L.tracker_complete or "تکمیل‌شده"
            return string.format(s.fa, fa)
        end
    end
    return nil
end

-- ----------------------------------------------------- in-place rendering
-- one registry for every Blizzard font string we rewrote; the original font
-- (size + flags) and the original text are kept so the restore is byte-exact.
local original = {} -- fs -> { font, size, flags, text }

local function remember(fs)
    local o = original[fs]
    if not o then
        local font, size, flags = fs:GetFont()
        o = { font = font, size = size, flags = flags, text = fs:GetText() }
        original[fs] = o
    end
    return o
end

-- Brain review #136-6: the log/gossip surfaces are BUTTONS (no SetFont in the
-- real client) - the text lives on the button's own font string
local function fs_of(b)
    if b.GetFontString then
        local fs = b:GetFontString()
        if fs then
            return fs
        end
    end
    return b
end

local function apply(fs, fa, prefix)
    if not fs or not fs.SetFont or not fa or fa == "" then
        return
    end
    local o = remember(fs)
    -- Brain review #136-3: the walker reads what the client JUST re-rendered -
    -- keep the restore text fresh so a switch-off never writes stale bytes
    o.text = fs.GetText and fs:GetText() or o.text
    fs:SetFont(F.FONT, o.size or T.Size(), "")
    -- the player's CURRENT display mode (Brain review #136-1); colour kept -
    -- SetText never touches the vertex colour
    -- the player's CURRENT display mode (Brain review #136-1); colour kept -
    -- SetText never touches the vertex colour. The classic dash prefix
    -- (#136-8) is client chrome: prepended AFTER the shaping so a manual
    -- RTL reorder never drags it into the Persian run.
    fs:SetText((prefix or "") .. T.ShapeLine(fa, T.Mode()))
end

local function unapply(fs)
    local o = original[fs]
    if not o then
        return
    end
    if o.font then
        pcall(fs.SetFont, fs, o.font, o.size, o.flags or "")
    end
    fs:SetText(o.text)
    original[fs] = nil
end

local function restore_all()
    for fs in pairs(original) do
        unapply(fs)
    end
    -- Brain review #136-3: let the client redraw its own English right away
    if QuestWatch_Update then
        pcall(QuestWatch_Update)
    end
    if WatchFrame_Update then
        pcall(WatchFrame_Update)
    end
    if ObjectiveTracker_Update then
        pcall(ObjectiveTracker_Update)
    end
end

local throttleT = {}
local function throttled(key)
    local now = GetTime and GetTime() or 0
    if throttleT[key] and now - throttleT[key] < 0.1 then
        return true
    end
    throttleT[key] = now
    return false
end

-- ------------------------------------------------------- quest title index
-- Brain review #136-7: titleIndex holds ONLY the quest-log entries and is
-- rebuilt on QUEST_LOG_UPDATE; the static EN-title map is built ONCE from the
-- data's EN field (first id wins) and is used only as a fallback - no
-- GetTitleForQuestID call per quest per update.
local titleIndex = {}
local staticTitle = nil

local function static_titles()
    if staticTitle then
        return staticTitle
    end
    staticTitle = {}
    for id, row in pairs(F.D.quests or {}) do
        if type(row) == "string" then
            -- wowfa2: field 1 is the title hash (F.TitleHash), not the EN title
            local p = F.Split(row, SEP)
            local k = (type(p[1]) == "string" and p[1]) or ""
            if k ~= "" and not staticTitle[k] then
                staticTitle[k] = id
            end
        end
    end
    return staticTitle
end

local function rebuild_titles()
    titleIndex = {}
    if GetNumQuestLogEntries and GetQuestLogTitle then
        for i = 1, GetNumQuestLogEntries() do
            local title, _, _, isHeader, _, _, _, qid = GetQuestLogTitle(i)
            if not isHeader and F.Usable(qid) and type(qid) == "number" and qid > 0
                and F.Usable(title) and type(title) == "string" and title ~= "" then
                titleIndex[simple(title)] = qid
            end
        end
    end
end

-- the quest title of one line, or nil ("Stranglethorn Tigerness (Complete)")
local function title_id_of(txt)
    local bare = string.match(txt, "^(.-)%s*%(%s*[Cc]omplete%s*%)$") or txt
    local k = simple(bare)
    if titleIndex[k] then
        return titleIndex[k], bare ~= txt
    end
    local st = static_titles()
    local hk = F.TitleHash(bare)
    if hk ~= "" and st[hk] then
        return st[hk], bare ~= txt
    end
    return nil, bare ~= txt
end

-- the modern tracker is taint-sensitive: never touch it in combat - queue and
-- apply on PLAYER_REGEN_ENABLED. The classic QuestWatch is plain: direct.
local pendingModern = false

local function in_combat_modern()
    if InCombatLockdown and InCombatLockdown() then
        pendingModern = true
        return true
    end
    return false
end

-- ------------------------------------------------------------- the walkers
-- one objective pass over a list of { fs = fontstring, qid = questID } entries
-- (Brain review extra: e.qid only - no ambient qid global)
local function render_objectives(list)
    local oidx = 0
    for _, e in ipairs(list) do
        local txt = e.fs and e.fs.GetText and e.fs:GetText()
        if F.Usable(txt) and txt ~= "" then
            -- classic watch lines carry a dash prefix (" - obj"); keep it
            local dash, body = string.match(txt, "^(%s*%-+)%s*(.+)$")
            body = body or txt
            local prefix = dash and (dash .. " ") or "" -- keep the classic " - "
            local status = status_fa(body)
            if status then
                apply(e.fs, status, prefix)
            else
                local fam, en, got, need = parse_obj_line(body)
                local line
                if fam then
                    oidx = oidx + 1
                    line = line_from_obj(fam, en, got, need) or line_from_qobj(e.qid, oidx)
                elseif e.qid then
                    oidx = oidx + 1
                    line = line_from_qobj(e.qid, oidx)
                end
                if line then
                    apply(e.fs, line, prefix)
                end
            end
        end
    end
end

-- classic / era-2: QuestWatchLine%d under QuestWatchFrame or WatchFrame
local function watch_frames(root)
    local out = {}
    for i = 1, 75 do
        local fs = _G["QuestWatchLine" .. i]
        if not fs then
            break
        end
        out[#out + 1] = fs
    end
    if #out == 0 and root and root.GetChildren then
        for _, child in pairs({ root:GetChildren() }) do
            if child.GetText and F.Usable(child:GetText()) then
                out[#out + 1] = child
            end
        end
    end
    return out
end

local function update_watch()
    rebuild_titles()
    local frames = watch_frames(QuestWatchFrame or WatchFrame)
    if #frames == 0 then
        return
    end
    -- titles first: the qid of each objective line is the last title above it
    local qid, oidx = nil, 0
    for i, fs in ipairs(frames) do
        local txt = fs.GetText and fs:GetText()
        if F.Usable(txt) and txt ~= "" then
            -- Brain review #136-8: classic QuestWatch prefixes objective lines
            -- with " - "; strip it for every match, put it back on the Persian
            local dash, body = string.match(txt, "^(%s*%-+)%s*(.+)$")
            body = body or txt
            local prefix = dash and (dash .. " ") or "" -- keep the classic " - "
            local id, wasComplete = title_id_of(body)
            if id then
                qid, oidx = id, 0
                -- inbox/29 D2: titles switched off - objectives still ride
                -- the same lines, so only the title render is skipped
                if F.Room.On("questText") then -- 51-B
                    local fa = title_fa(qid)
                    if wasComplete and fa then
                        fa = fa .. " (" .. (L.tracker_complete or "تکمیل‌شده") .. ")"
                    end
                    if fa then
                        apply(fs_of(fs), fa, prefix)
                    end
                end
            else
                local status = status_fa(body)
                if status then
                    if F.Room.On("questText") then -- 51-B -- a status line belongs to the title surface
                        apply(fs_of(fs), status, prefix)
                    end
                else
                    local fam, en, got, need = parse_obj_line(body)
                    local line
                    if F.Room.On("questText") then -- inbox/29 D2: the objective surface
                        if fam then
                            oidx = oidx + 1
                            line = line_from_obj(fam, en, got, need) or line_from_qobj(qid, oidx)
                        elseif qid then
                            oidx = oidx + 1
                            line = line_from_qobj(qid, oidx)
                        end
                    end
                    if line then
                        apply(fs_of(fs), line, prefix)
                    end
                end
            end
        end
    end
end

-- modern: ObjectiveTrackerFrame blocks (block.id = questID, .HeaderText, .lines)
local function update_modern()
    if in_combat_modern() then
        return
    end
    if throttled("otf") then
        return
    end
    local otf = ObjectiveTrackerFrame
    if not otf or not otf.blocks then
        return
    end
    for _, block in pairs(otf.blocks) do
        if block.HeaderText then
            local id = block.id
            if not id and block.HeaderText.GetText then
                id = title_id_of(block.HeaderText:GetText())
            end
            if id and F.Room.On("questText") then -- inbox/29 D2
                local fa = title_fa(id)
                if fa then
                    apply(fs_of(block.HeaderText), fa)
                end
            end
        end
        if block.lines and F.Room.On("questText") then -- inbox/29 D2
            for _, e in pairs(block.lines) do
                render_objectives({ { fs = fs_of(e), qid = block.id } })
            end
        end
    end
end

-- quest log list titles: QuestLogTitle%d buttons on QUEST_LOG_UPDATE / show
local function update_questlog()
    if throttled("qlog") then
        return
    end
    rebuild_titles()
    for i = 1, 40 do
        local b = _G["QuestLogTitle" .. i]
        if not b then
            break
        end
        local txt = b.GetText and b:GetText()
        if F.Usable(txt) and txt ~= "" and txt ~= "..." and F.Room.On("questText") then -- inbox/29 D2
            local id = title_id_of(txt)
            if id then
                local fa = title_fa(id)
                if fa then
                    apply(fs_of(b), fa) -- the BUTTON's own font string (#136-6)
                end
            else
                unapply(fs_of(b))
            end
        end
    end
end

-- gossip / quest greeting buttons: GossipTitleButton%d, QuestTitleButton%d
local function update_gossip()
    if throttled("gossip") then
        return
    end
    rebuild_titles()
    for _, prefix in ipairs({ "GossipTitleButton", "QuestTitleButton" }) do
        for i = 1, 32 do
            local b = _G[prefix .. i]
            if not b then
                break
            end
            local txt = b.GetText and b:GetText()
            if F.Usable(txt) and txt ~= "" and F.Room.On("npcSay") then -- inbox/29 D2
                local id = title_id_of(txt)
                if id then
                    local fa = title_fa(id)
                    if fa then
                        apply(fs_of(b), fa) -- the BUTTON's own font string (#136-6)
                    end
                else
                    unapply(fs_of(b))
                end
            end
        end
    end
end

-- ------------------------------------------------------------------- module
local function on_log_update()
    update_questlog()
end

local function on_gossip()
    update_gossip()
end

function M.install()
    -- classic: QuestWatch_Update global; era 2: WatchFrame_Update
    for _, fn in ipairs({ "QuestWatch_Update", "WatchFrame_Update" }) do
        if type(_G[fn]) == "function" then
            hooksecurefunc(fn, F:Wrap("tracker", update_watch))
        end
    end
    -- modern: the global ObjectiveTracker_Update and the quest module Update
    if type(_G["ObjectiveTracker_Update"]) == "function" then
        hooksecurefunc("ObjectiveTracker_Update", F:Wrap("tracker", update_modern))
    end
    local otf = ObjectiveTrackerFrame
    if otf and otf.Modules then
        for _, mod in pairs(otf.Modules) do
            if mod and type(mod.Update) == "function" then
                hooksecurefunc(mod, "Update", F:Wrap("tracker", update_modern))
            end
        end
    end
    F:On("QUEST_LOG_UPDATE", "tracker", on_log_update)
    F:On("GOSSIP_SHOW", "tracker", on_gossip)
    F:On("QUEST_GREETING", "tracker", on_gossip)
    F:On("QUEST_WATCH_UPDATE", "tracker", update_watch)
    F:On("PLAYER_REGEN_ENABLED", "tracker", function()
        if pendingModern then
            pendingModern = false
            F:Wrap("tracker", update_modern)()
        end
    end)
    F:On("PLAYER_ENTERING_WORLD", "tracker", function()
        F.After(1, F:Wrap("tracker", function()
            update_watch()
            update_questlog()
            update_modern()
        end))
    end)
    F:Listen("names", function()
        restore_all()
        F:Wrap("tracker", function()
            update_watch()
            update_questlog()
            update_modern()
        end)()
    end)
    -- inbox/29 D2: the surface switches of THIS module - off puts the English
    -- back right now, on re-renders everything still allowed
    F:Listen("surf", function(name)
        if name == nil or SURF_OWNED[name] then
            restore_all()
            F:Wrap("tracker", function()
                update_watch()
                update_questlog()
                update_modern()
            end)()
        end
    end)
end

function M.onState(_, active)
    if not active then
        restore_all()
        pendingModern = false
    end
end

F:RegisterModule(M)
