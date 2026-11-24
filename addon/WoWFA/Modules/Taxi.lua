-- WoWFA Forever - the flight master map: the destination tooltip ("Orgrimmar, Durotar")
-- gets the Persian zone names. Behind the zone name switch (namesZone). Not a registered
-- module: one tooltip hook, pcall everywhere, a name the data does not know stays English.

local F = WoWFAF
local T = F.T

local function on()
    local db = F.db
    return db and db.enabled and F.Room and F.Room.On("namesZone") and true or false
end

local function in_taxi(f)
    local n = 0
    while type(f) == "table" and n < 10 do
        if (TaxiFrame and f == TaxiFrame) or (FlightMapFrame and f == FlightMapFrame) then
            return true
        end
        local ok, p = pcall(f.GetParent, f)
        if not ok then
            return false
        end
        f = p
        n = n + 1
    end
    return false
end

local function zone_fa(name)
    local z = F.D and F.D.names and F.D.names.zone
    return z and z[T.NameKey(name)] or nil
end

-- "Orgrimmar, Durotar" -> the Persian name of each part (Persian comma between)
local function translate(line)
    if string.find(line, "|", 1, true) or string.find(line, "[\216-\219\239]") then
        return nil
    end
    local whole = zone_fa(line)
    if whole then
        return whole
    end
    local a, b = string.match(line, "^(.-),%s*(.+)$")
    if a then
        local fa_a, fa_b = zone_fa(a), zone_fa(b)
        if fa_a or fa_b then
            return (fa_a or a) .. "\216\140 " .. (fa_b or b)
        end
    end
    return nil
end

local function on_show(tt)
    if not on() then
        return
    end
    local ok, owner = pcall(tt.GetOwner, tt)
    if not ok or not in_taxi(owner) then
        return
    end
    local name = tt.GetName and tt:GetName()
    local fs = name and _G[name .. "TextLeft1"]
    if not fs then
        return
    end
    local okT, txt = pcall(fs.GetText, fs)
    if not okT or not F.Usable(txt) or type(txt) ~= "string" or txt == "" then
        return
    end
    local fa = translate(txt)
    if not fa then
        return
    end
    if not T.Once(tt, "taxi|" .. txt) then
        return
    end
    pcall(T.TipSet, tt, fs, fa, nil, "Left")
    T.Done(tt)
    pcall(tt.Show, tt)
end

if GameTooltip and GameTooltip.HookScript then
    GameTooltip:HookScript("OnShow", function(tt)
        local ok, err = pcall(on_show, tt)
        if not ok then
            F:LogError("taxi", err)
        end
    end)
end
