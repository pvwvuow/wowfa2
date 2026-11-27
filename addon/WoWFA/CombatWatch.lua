-- WoWFA Forever 1.2.0 - combat watch (the owner 27 Nov: "when I enter combat many settings get
-- messed up"). It is PASSIVE: it only reads, never writes anything of the game and never touches a
-- frame. When a fight starts it takes a small snapshot (our saved options, the font and size of the
-- chat windows, the module states, a few game settings). When the fight ends it compares and records
-- what CHANGED in db.combatDiff (the 12 newest, with a count): the report line on the status page
-- shows them, so the exact setting is named instead of guessed. Everything is pcall'd, so it can
-- never break a fight.

local F = WoWFAF

-- saved keys that change by themselves (counters, logs): not a setting
local SKIP = { miss = true, missN = true, missV = true, errors = true, profiles = true, combatDiff = true,
    newSeen = true, harvest = true, lastBuild = true, lastVersion = true, combatSkip = true, beacon = true, trace = true }
local CVARS = { "uiScale", "useUiScale", "chatStyle", "UnitNameOwn", "nameplateShowEnemies", "Sound_EnableAllSound" }

local snap -- the snapshot taken when the fight started

-- 1.2.2 (the owner 27 Nov: "many things turn English in combat"): every place that holds a write back
-- during a fight calls F.CombatSkip(kind). The kinds seen in a fight are counted once per fight in
-- db.combatSkip and ride in the report ("combatskip :: tracker :: x3"): the next report names the guard.
local skipped = {}
function F.CombatSkip(kind)
    skipped[tostring(kind)] = true
end

local function flat(prefix, t, out, depth, budget)
    for k, v in pairs(t) do
        if budget.n > 600 then
            return
        end
        if not (depth == 0 and SKIP[k]) then
            local key = prefix .. tostring(k)
            local ty = type(v)
            if ty == "table" then
                if depth < 2 then
                    flat(key .. ".", v, out, depth + 1, budget)
                end
            elseif ty == "number" or ty == "boolean" then
                budget.n = budget.n + 1
                out[key] = tostring(v)
            elseif ty == "string" then
                budget.n = budget.n + 1
                out[key] = string.sub(v, 1, 80)
            end
        end
    end
end

local function take()
    local out, budget = {}, { n = 0 }
    if type(F.db) == "table" then
        flat("db.", F.db, out, 0, budget)
    end
    for i = 1, 10 do
        local cf = _G["ChatFrame" .. i]
        if type(cf) == "table" and type(cf.GetFont) == "function" then
            local ok, font, size = pcall(cf.GetFont, cf)
            if ok then
                out["chat" .. i .. ".font"] = tostring(font)
                out["chat" .. i .. ".size"] = tostring(size)
            end
        end
    end
    for _, m in ipairs(F.order or {}) do
        if type(m) == "table" then
            out["module." .. tostring(m.id) .. ".state"] = tostring(m.state)
        end
    end
    if type(GetCVar) == "function" then
        for _, name in ipairs(CVARS) do
            local ok, v = pcall(GetCVar, name)
            if ok and v ~= nil then
                out["game." .. name] = tostring(v)
            end
        end
    end
    out["font"] = tostring(F.FONT)
    return out
end

local function done()
    local before = snap
    snap = nil
    local db = F.db
    if not before or type(db) ~= "table" then
        return
    end
    local now = take()
    local list = type(db.combatDiff) == "table" and db.combatDiff or {}
    db.combatDiff = list
    local names, seen = {}, {}
    for k, v in pairs(before) do
        if now[k] ~= v then
            names[#names + 1] = k
            seen[k] = true
        end
    end
    for k, v in pairs(now) do
        if not seen[k] and before[k] ~= v then
            names[#names + 1] = k
        end
    end
    table.sort(names)
    for i = 1, math.min(#names, 12) do
        local k = names[i]
        local v = tostring(before[k]) .. " > " .. tostring(now[k])
        local hit
        for _, c in ipairs(list) do
            if c.k == k and c.v == v then
                hit = c
                break
            end
        end
        if hit then
            hit.n = (hit.n or 1) + 1
        else
            table.insert(list, 1, { k = k, v = v, n = 1 })
        end
    end
    while #list > 12 do
        table.remove(list)
    end
end

F:On("PLAYER_REGEN_DISABLED", nil, function()
    local ok, res = pcall(take)
    snap = ok and res or nil
end)
F:On("PLAYER_REGEN_ENABLED", nil, function()
    if next(skipped) ~= nil and type(F.db) == "table" then
        local cs = type(F.db.combatSkip) == "table" and F.db.combatSkip or {}
        F.db.combatSkip = cs
        for k in pairs(skipped) do
            cs[k] = (tonumber(cs[k]) or 0) + 1
        end
        skipped = {}
    end
    local ok, err = pcall(done)
    if not ok then
        F:LogError("combatwatch", err)
    end
end)

F.CombatWatch = { Snapshot = take, Done = done }
