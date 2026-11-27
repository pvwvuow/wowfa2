-- WoWFA Forever 1.2.2 - diagnostics (the owner 27 Nov: "a temporary buff comes on my head and then every buff
-- and many texts turn English", and "the addon feels heavy"). Two things, both printed in the report:
--   * a ring of the last 40 events (db.trace, kept over a /reload): a fight starts / ends, a new buff on the
--     player (its name when the game lets us read it), a change of the game's addon restrictions, a module that
--     faults or changes state, a module that comes back after a fight. Every line has the time (t=) and a "c"
--     when it happened in combat
--   * a timer per module hook and per event (F.perfW / F.perfE, filled in Core.lua), and the addon's memory
-- Nothing of the game is written. Every call is wrapped in pcall.

local F = WoWFAF

-- the game's addon restrictions that are ON right now ("Combat=2,Encounter=2"); nil when the client has none
local function restr()
    if not (C_RestrictedActions and Enum and type(Enum.AddOnRestrictionType) == "table") then
        return nil
    end
    local get = C_RestrictedActions.GetAddOnRestrictionState
    if type(get) ~= "function" then
        return nil
    end
    local parts = {}
    for name, v in pairs(Enum.AddOnRestrictionType) do
        local ok, st = pcall(get, v)
        if ok and F.Usable(st) and st ~= 0 and st ~= false then
            parts[#parts + 1] = tostring(name) .. "=" .. tostring(st)
        end
    end
    table.sort(parts)
    return table.concat(parts, ",")
end

-- the modules that are not plainly ok ("spellbook:fault,auras:update")
local function modline()
    local bad = {}
    for _, m in ipairs(F.order or {}) do
        local s = m.state
        if s ~= "ok" and s ~= "off" and s ~= "locked" then
            bad[#bad + 1] = tostring(m.id) .. ":" .. tostring(s)
        end
    end
    if #bad == 0 then
        return "all-ok"
    end
    return table.concat(bad, ",")
end

local function snapshot(tag)
    local ok, err = pcall(function()
        F.Trace(tag, "restr=" .. tostring(restr() or "-") .. " mods=" .. modline())
    end)
    if not ok then
        F:LogError("core", err)
    end
end

F:On("PLAYER_REGEN_DISABLED", nil, function()
    snapshot("fight-start")
end)
F:On("PLAYER_REGEN_ENABLED", nil, function()
    snapshot("fight-end")
end)
F:On("ADDON_RESTRICTION_STATE_CHANGED", nil, function()
    snapshot("restrict")
end)

-- a NEW buff on the player: its own frame with a unit filter (UNIT_AURA of every unit would cost)
local af = CreateFrame("Frame")
local lastAura = 0
pcall(af.RegisterUnitEvent, af, "UNIT_AURA", "player")
af:SetScript("OnEvent", function(_, _, _, info)
    local now = GetTime and GetTime() or 0
    if now - lastAura < 0.5 then
        return
    end
    local ok, err = pcall(function()
        if not F.Usable(info) or type(info) ~= "table" then
            return
        end
        local add = info.addedAuras
        if type(add) ~= "table" or #add == 0 then
            return
        end
        lastAura = now
        local nm = add[1] and add[1].name
        F.Trace("aura+", tostring(#add) .. " " .. (F.Usable(nm) and tostring(nm) or "(secret)"))
    end)
    if not ok then
        F:LogError("core", err)
    end
end)

-- the memory of the addon in KB, looked up at most every 30 s (the call scans every addon)
local memAt, memKB = -100, nil
local function mem()
    local upd = UpdateAddOnMemoryUsage or (C_AddOns and C_AddOns.UpdateAddOnMemoryUsage)
    local get = GetAddOnMemoryUsage or (C_AddOns and C_AddOns.GetAddOnMemoryUsage)
    if not (upd and get) then
        return nil
    end
    local now = GetTime and GetTime() or 0
    if now - memAt > 30 then
        memAt = now
        pcall(upd)
        local ok, kb = pcall(get, F.ADDON)
        if ok and tonumber(kb) then
            memKB = tonumber(kb)
        end
    end
    return memKB
end

local function top(tab, n)
    local arr = {}
    for k, v in pairs(tab or {}) do
        arr[#arr + 1] = { k = k, n = v.n or 0, ms = v.ms or 0 }
    end
    table.sort(arr, function(a, b)
        return a.ms > b.ms
    end)
    local out = {}
    for i = 1, math.min(n, #arr) do
        out[i] = arr[i]
    end
    return out
end

-- the lines the report carries after its own (status page and the small page of the icon)
function F.DiagLines()
    local out = {}
    local db = F.db or {}
    for _, e in ipairs(type(db.trace) == "table" and db.trace or {}) do
        local v = string.gsub(tostring(e.v or ""), "|", "!")
        v = string.gsub(v, "%c+", " ")
        out[#out + 1] = string.format("trace :: t=%d%s :: %s :: %s", tonumber(e.t) or 0, e.c == 1 and "c" or "", tostring(e.k), v)
    end
    out[#out + 1] = string.format("perf :: up=%ds", GetTime and math.floor(GetTime()) or 0)
    for _, e in ipairs(top(F.perfW, 5)) do
        out[#out + 1] = string.format("perf :: wrap :: %s :: n=%d ms=%.0f", tostring(e.k), e.n, e.ms)
    end
    for _, e in ipairs(top(F.perfE, 5)) do
        out[#out + 1] = string.format("perf :: event :: %s :: n=%d ms=%.0f", tostring(e.k), e.n, e.ms)
    end
    local kb = mem()
    if kb then
        out[#out + 1] = string.format("perf :: mem :: %d KB", kb)
    end
    return out
end
