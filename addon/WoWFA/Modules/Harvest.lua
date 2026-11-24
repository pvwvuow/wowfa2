-- WoWFA Forever - harvest (1.0.2). The owner: "high level quests and NPC names are not
-- translated". Checked against the open classic database (cmangos/classic-db): the classic
-- content is complete; what is left is WoW Forever's OWN content (Riverglades, Zephras Isle,
-- Krol'dok, the new quests and their NPCs), whose English text exists only in the game.
-- So while the player plays, every quest shown in the quest window or the quest log that has
-- no Persian (or lacks a part), and every NPC name with no Persian, is saved IN ENGLISH to
-- WoWFA_Harvest. Send WTF\Account\<account>\SavedVariables\WoWFA.lua and the next build
-- has them in Persian.
-- English game text only: nothing about the player, realm or account is stored.
--   /wowfa harvest        counts       /wowfa harvest clear   empty it
--   /wowfa harvest off    stop         /wowfa harvest on      start again (default on)

local F = WoWFAF
local T = F.T
local SEP = "\031"
local H = {}
F.Harvest = H
H.MAXQ, H.MAXN = 4000, 8000

local function chat(msg)
    if F.Chat then
        F.Chat("WoWFA harvest: " .. msg)
    elseif print then
        print("WoWFA harvest: " .. msg)
    end
end

local function store()
    if type(WoWFA_Harvest) ~= "table" then
        WoWFA_Harvest = {}
    end
    local h = WoWFA_Harvest
    if type(h.q) ~= "table" then h.q = {} end
    if type(h.n) ~= "table" then h.n = {} end
    h.nq = tonumber(h.nq) or 0
    h.nn = tonumber(h.nn) or 0
    h.v = F.VERSION
    h.b = F.clientBuildText
    return h
end

local function str(v)
    if type(v) == "string" and v ~= "" and (not F.Usable or F.Usable(v)) then
        return v
    end
    return nil
end

local function on()
    return F.db ~= nil and F.db.enabled ~= false and F.db.harvest ~= false
end

local function zone()
    local ok, z = pcall(GetRealZoneText)
    return (ok and str(z)) or nil
end

-- the Persian parts the data already has for a quest id (nil = no record at all)
local function have(id)
    local raw = id and F.D and F.D.quests and F.D.quests[id]
    if type(raw) ~= "string" then
        return nil
    end
    local p = F.Split(raw, SEP)
    return { t = p[2] or "", obj = p[3] or "", det = p[4] or "", pro = p[5] or "", com = p[6] or "" }
end

-- keep the English parts the data lacks. parts = { t, obj, det, pro, com, o = { lines } }
function H.Quest(id, parts, level)
    id = tonumber(id)
    if not on() or not id or id <= 0 or type(parts) ~= "table" then
        return
    end
    local fa = have(id)
    local need, any = {}, false
    for _, k in ipairs({ "t", "obj", "det", "pro", "com" }) do
        local v = str(parts[k])
        if v and (fa == nil or fa[k] == "") then
            need[k] = v
            any = true
        end
    end
    if fa == nil and type(parts.o) == "table" and #parts.o > 0 then
        need.o = parts.o
        any = true
    end
    if not any then
        return
    end
    local h = store()
    local e = h.q[id]
    if not e then
        if h.nq >= H.MAXQ then
            return
        end
        e = {}
        h.q[id] = e
        h.nq = h.nq + 1
    end
    for k, v in pairs(need) do
        e[k] = v
    end
    level = tonumber(level)
    if level and level > 0 then
        e.lv = level
    end
    e.z = e.z or zone()
end

-- keep an NPC name the data has no Persian for (players and pets never)
function H.Unit(unit)
    if not on() or not (UnitExists and UnitExists(unit)) then
        return
    end
    local okp, isp = pcall(UnitIsPlayer, unit)
    if okp and isp then
        return
    end
    local okc, ctl = pcall(UnitPlayerControlled, unit)
    if okc and ctl then
        return
    end
    local okn, en = pcall(UnitName, unit)
    en = okn and str(en)
    if not en then
        return
    end
    local key = T.NameKey(en)
    local names = (F.D and F.D.names) or {}
    if (names.npc and names.npc[key]) or (names.boss and names.boss[key]) then
        return
    end
    local h = store()
    local e = h.n[en]
    if not e then
        if h.nn >= H.MAXN then
            return
        end
        e = {}
        h.n[en] = e
        h.nn = h.nn + 1
    end
    local okl, lv = pcall(UnitLevel, unit)
    if okl and type(lv) == "number" and lv ~= 0 then
        e.lv = lv
    end
    e.z = e.z or zone()
end

local function quest_frame(which)
    local id = GetQuestID and select(2, pcall(GetQuestID))
    local function g(f)
        if not f then return nil end
        local ok, v = pcall(f)
        return ok and v or nil
    end
    local parts = { t = g(GetTitleText) }
    if which == "detail" then
        parts.det = g(GetQuestText)
        parts.obj = g(GetObjectiveText)
    elseif which == "progress" then
        parts.pro = g(GetProgressText)
    elseif which == "complete" then
        parts.com = g(GetRewardText)
    end
    H.Quest(id, parts)
end

-- the quest log: titles + objective lines of every quest, the texts of the SELECTED one
local function log_scan()
    if not on() then
        return
    end
    local n = 0
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        local ok, a = pcall(C_QuestLog.GetNumQuestLogEntries)
        n = ok and tonumber(a) or 0
    elseif GetNumQuestLogEntries then
        local ok, a = pcall(GetNumQuestLogEntries)
        n = ok and tonumber(a) or 0
    end
    for i = 1, math.min(n or 0, 60) do
        local title, level, header, qid
        if C_QuestLog and C_QuestLog.GetInfo then
            local ok, info = pcall(C_QuestLog.GetInfo, i)
            if ok and type(info) == "table" then
                title, level, header, qid = info.title, info.level, info.isHeader, info.questID
            end
        elseif GetQuestLogTitle then
            local ok, a, b, _, d, _, _, _, hId = pcall(GetQuestLogTitle, i)
            if ok then
                title, level, header, qid = a, b, d, hId
            end
        end
        if qid and not header then
            local lines = {}
            if C_QuestLog and C_QuestLog.GetQuestObjectives then
                local ok, objs = pcall(C_QuestLog.GetQuestObjectives, qid)
                if ok and type(objs) == "table" then
                    for _, o in ipairs(objs) do
                        if type(o) == "table" and str(o.text) then
                            lines[#lines + 1] = o.text
                        end
                    end
                end
            end
            H.Quest(qid, { t = title, o = lines }, level)
        end
    end
    -- the selected quest's own texts (reading the selection never changes it)
    local sel, sid
    if C_QuestLog and C_QuestLog.GetSelectedQuest then
        local ok, a = pcall(C_QuestLog.GetSelectedQuest)
        sid = ok and tonumber(a) or nil
        if sid and C_QuestLog.GetLogIndexForQuestID then
            local ok2, b = pcall(C_QuestLog.GetLogIndexForQuestID, sid)
            sel = ok2 and tonumber(b) or nil
        end
    elseif GetQuestLogSelection then
        local ok, a = pcall(GetQuestLogSelection)
        sel = ok and tonumber(a) or nil
        if sel and sel > 0 and GetQuestLogTitle then
            local ok2, _, _, _, _, _, _, _, hId = pcall(GetQuestLogTitle, sel)
            sid = ok2 and tonumber(hId) or nil
        end
    end
    if sid and sel and sel > 0 and GetQuestLogQuestText then
        local ok, desc, obj = pcall(GetQuestLogQuestText, sel)
        if ok then
            H.Quest(sid, { det = desc, obj = obj })
        end
    end
end

local pending = false
local function log_later()
    if pending then
        return
    end
    pending = true
    local function go()
        pending = false
        local ok, err = pcall(log_scan)
        if not ok and F.LogError then
            F:LogError("harvest", err)
        end
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(1, go)
    else
        go()
    end
end

local ev = CreateFrame and CreateFrame("Frame")
if ev then
    for _, e in ipairs({ "QUEST_DETAIL", "QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_LOG_UPDATE",
        "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT", "NAME_PLATE_UNIT_ADDED" }) do
        pcall(ev.RegisterEvent, ev, e)
    end
    ev:SetScript("OnEvent", function(_, e, a1)
        local ok, err = pcall(function()
            if e == "QUEST_DETAIL" then
                quest_frame("detail")
            elseif e == "QUEST_PROGRESS" then
                quest_frame("progress")
            elseif e == "QUEST_COMPLETE" then
                quest_frame("complete")
            elseif e == "QUEST_LOG_UPDATE" then
                log_later()
            elseif e == "PLAYER_TARGET_CHANGED" then
                H.Unit("target")
            elseif e == "UPDATE_MOUSEOVER_UNIT" then
                H.Unit("mouseover")
            elseif e == "NAME_PLATE_UNIT_ADDED" and type(a1) == "string" then
                H.Unit(a1)
            end
        end)
        if not ok and F.LogError then
            F:LogError("harvest", err)
        end
    end)
end

function H.Command(arg)
    arg = arg or ""
    if arg == "clear" then
        WoWFA_Harvest = nil
        chat("emptied (gone from the file after /reload)")
    elseif arg == "off" then
        if F.db then F.db.harvest = false end
        chat("off")
    elseif arg == "on" then
        if F.db then F.db.harvest = true end
        chat("on")
    else
        local h = store()
        chat(string.format("%d quests and %d NPC names saved in English (%s). Send WTF\\Account\\<account>\\SavedVariables\\WoWFA.lua after /reload.",
            h.nq, h.nn, on() and "on" or "off"))
    end
end

-- /wowfa harvest ...: wrap the slash handler (Core.lua and Dump.lua load first)
local orig = SlashCmdList and SlashCmdList["WOWFAF"]
if orig then
    SlashCmdList["WOWFAF"] = function(msg)
        local m = string.lower(tostring(msg or ""))
        local cmd, rest = string.match(m, "^%s*(%S*)%s*(.-)%s*$")
        if cmd == "harvest" then
            local ok, err = pcall(H.Command, rest)
            if not ok and F.LogError then
                F:LogError("harvest", err)
            end
            return
        end
        return orig(msg)
    end
end
