-- WoWFA Forever - NPC names (rc11): the name line of an NPC tooltip, the name
-- above an NPC (nameplates, the V key) and the target frame name.
-- F.db.npcName: 1 = Persian only, 2 = Persian with the English under it
-- (tooltip + nameplates), 3 = English (untouched). Players are never touched.
-- Lookup = names.npc, then names.boss, by T.NameKey of the English name (the
-- export keys the same way). A name the data does not know stays English and
-- is remembered in the miss list.

local F = WoWFAF
local L = F.L
local T = F.T

local M = { id = "npc", order = 4, risk = "low", nameKey = "m_npc", descKey = "m_npc_d" }

function M.data()
    return F.D.names and F.D.names.npc
end

function M.api()
    return UnitName ~= nil and GameTooltip ~= nil
end

local function mode()
    local v = F.db and F.db.npcName
    if v ~= 2 and v ~= 3 then
        return 1
    end
    return v
end
F.NpcMode = mode

local function lookup(name, quiet)
    if not F.Usable(name) or type(name) ~= "string" or name == "" then
        return nil
    end
    if not F.Room.On("namesNpc") or mode() == 3 then
        return nil
    end
    local names = F.D.names or {}
    local key = T.NameKey(name)
    local v = (names.npc and names.npc[key]) or (names.boss and names.boss[key])
    if v == nil and not quiet and not string.find(name, "[\216-\219\239]") then
        F:Miss("npc", key, name)
    end
    return v
end
F.NpcLookup = lookup

local memo = {}
local function shaped(fa)
    local key = fa .. "\1" .. tostring(T.Mode()) .. tostring(F.Room.On("faDigits"))
    local s = memo[key]
    if not s then
        s = T.ShapeLine(T.Digits(fa), T.Mode())
        memo[key] = s
    end
    return s
end

-- font strings we rewrote: fs -> the font to give back
local orig = setmetatable({}, { __mode = "k" })

local function put(fs, fa, en, two)
    if not orig[fs] then
        local font, size, flags = fs:GetFont()
        orig[fs] = { font = font, size = size, flags = flags }
    end
    local o = orig[fs]
    fs:SetFont(F.FONT, o.size or 12, F.Flags("npc", o.flags or "")) -- 1.1.0: the NPC outline switch
    local s = shaped(fa)
    if two and type(en) == "string" then
        s = s .. "\n" .. en
    end
    fs:SetText(s)
end

local function unput(fs)
    local o = orig[fs]
    if o and o.font then
        pcall(fs.SetFont, fs, o.font, o.size, o.flags or "")
    end
    orig[fs] = nil
end

-- the name above a unit: the client calls CompactUnitFrame_UpdateName every
-- time it writes the name; we write ours right after it
local function plate(frame)
    if type(frame) ~= "table" then
        return
    end
    local fs = frame.name
    if type(fs) ~= "table" or not fs.SetText then
        return
    end
    if not M.active then
        if orig[fs] then
            unput(fs)
        end
        return
    end
    local unit = frame.unit
    if not F.Usable(unit) or type(unit) ~= "string" or string.sub(unit, 1, 9) ~= "nameplate" then
        return
    end
    local isp = UnitIsPlayer(unit)
    local en = UnitName(unit)
    if (F.Usable(isp) and isp) or not F.Usable(en) then
        unput(fs)
        return
    end
    local fa = lookup(en, true)
    if fa then
        put(fs, fa, en, mode() == 2)
    else
        unput(fs)
    end
end
M.plate = plate

-- the unit tooltip: line 1 is the name
local function tip(tt)
    if tt ~= GameTooltip or not M.active then
        return
    end
    local name, unit = tt:GetUnit()
    if not F.Usable(name) or not F.Usable(unit) then
        return
    end
    local isp = UnitIsPlayer(unit)
    -- 1.1.8: a unit we cannot tell for sure is a player (a value the game hides) is never
    -- looked up and never logged: a player's name must not reach the NPC miss list
    if not F.Usable(isp) or isp then
        return
    end
    -- 1.0.3: a player's pet (the owner saw "Huntard" in the miss list) is named by its
    -- player: never translated, never a miss
    local okc, ctl = pcall(UnitPlayerControlled, unit)
    if not okc or not F.Usable(ctl) or ctl then
        return
    end
    local fa = lookup(name)
    if not fa then
        return
    end
    if not T.Once(tt, "n|" .. tostring(name)) then
        return
    end
    local fs = _G[(tt:GetName() or "GameTooltip") .. "TextLeft1"]
    if type(fs) ~= "table" or not fs.GetText then
        return
    end
    local cur = fs:GetText()
    if not F.Usable(cur) or cur ~= name then
        return
    end
    local shown = fa
    if mode() == 2 then
        shown = fa .. "\n" .. name
    end
    pcall(T.TipSet, tt, fs, shown, nil, "Left", "npc")
    T.Done(tt)
    tt:Show()
end

-- the target frame name (a single line: Persian only)
local function target_fonts()
    local out = {}
    local function add(fs)
        if type(fs) == "table" and fs.SetText and fs.GetFont then
            out[#out + 1] = fs
        end
    end
    add(_G.TargetFrameTextureFrameName)
    local tf = _G.TargetFrame
    if type(tf) == "table" then
        add(tf.name)
        local c = tf.TargetFrameContent
        if type(c) == "table" and type(c.TargetFrameContentMain) == "table" then
            add(c.TargetFrameContentMain.Name)
        end
    end
    return out
end

local function target()
    local fonts = target_fonts()
    local fa, en
    if M.active and UnitExists and UnitExists("target") then
        local isp = UnitIsPlayer("target")
        en = UnitName("target")
        if not (F.Usable(isp) and isp) and F.Usable(en) then
            fa = lookup(en, true)
        end
    end
    for _, fs in ipairs(fonts) do
        if fa then
            put(fs, fa, en, false)
        else
            -- 1.1.6: switched off = the English name back right away (not on the next target)
            if orig[fs] and UnitExists and UnitExists("target") then
                local okn, n = pcall(UnitName, "target")
                if okn and F.Usable(n) and type(n) == "string" then
                    pcall(fs.SetText, fs, n)
                end
            end
            unput(fs)
        end
    end
end
M.target = target

-- the name family or the display changed: the plates and the target frame again
local function redo()
    if C_NamePlate and C_NamePlate.GetNamePlates and CompactUnitFrame_UpdateName then
        local okp, plates = pcall(C_NamePlate.GetNamePlates)
        if okp and type(plates) == "table" then
            for _, np in ipairs(plates) do
                if type(np) == "table" and type(np.UnitFrame) == "table" then
                    -- 1.1.6: never call CompactUnitFrame_UpdateName from addon code (taint);
                    -- put the English back ourselves, then our own plate pass
                    local uf = np.UnitFrame
                    local fs = uf.name
                    if type(fs) == "table" and orig[fs] and F.Usable(uf.unit) then
                        local okn, en = pcall(UnitName, uf.unit)
                        if okn and F.Usable(en) and type(en) == "string" then
                            pcall(fs.SetText, fs, en)
                        end
                    end
                    pcall(plate, uf)
                end
            end
        end
    end
    target()
end

function M.install()
    -- 1.1.8: no post-call inside the game's tooltip build (see F.TipPost in Spells.lua)
    if not (F.TipPost and F.TipPost("Unit", F:Wrap("npc", tip))) and GameTooltip.HookScript then
        GameTooltip:HookScript("OnTooltipSetUnit", F:Wrap("npc", tip))
    end
    if type(CompactUnitFrame_UpdateName) == "function" then
        hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
            local ok, err = pcall(plate, frame)
            if not ok then
                F:LogError("npc", err)
            end
        end)
    end
    F:On("PLAYER_TARGET_CHANGED", "npc", function()
        F.After(0, F:Wrap("npc", target))
    end)
    if type(TargetFrame_Update) == "function" then
        hooksecurefunc("TargetFrame_Update", F:Wrap("npc", target))
    end
    if type(TargetFrame) == "table" and type(TargetFrame.Update) == "function" then
        hooksecurefunc(TargetFrame, "Update", F:Wrap("npc", target))
    end
    F:Listen("options", function(key)
        if key == "fontOutline" then
            pcall(redo)
        end
    end)
    for _, sig in ipairs({ "names", "room", "npcname" }) do
        F:Listen(sig, F:Wrap("npc", redo))
    end
end

function M.onState()
    pcall(redo)
end

F:RegisterModule(M)
