-- WoWFA Forever - spellbook and talents: Persian name + description in the
-- tooltip. Descriptions are matched as templates (numbers -> #) against the
-- live English text and refilled with the live numbers, so a rank change or a
-- number tweak in a patch still shows the right values. A text the game has
-- reworded simply does not match (and is counted for the update warning).

local F = WoWFAF
local T = F.T
local C = F.C
local DESC = { 1.0, 0.82, 0.0 }

local function tdp(kind)
    return TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType
        and Enum.TooltipDataType[kind] ~= nil
end

-- 1.1.8 (the owner's taint log: the blocked actions name "last WoWFA hook: spellbook"): a
-- TooltipDataProcessor post-call runs INSIDE the game's own tooltip build. On an action bar
-- mouseover that build is part of a secure path (ActionButton OnEnter -> UpdateAction) and
-- our function running there leaves the path tainted, so the bar layout is blocked in combat.
-- A hooksecurefunc / HookScript hook runs after the game's function and its taint is dropped,
-- and a timer starts a clean execution of its own. So on a client that can tell a tooltip's data
-- type we only note that a tooltip was set or shown, and one frame later (own execution) run the
-- same function for a tooltip of that kind. The old post-call stays as the fallback (older
-- clients and the test mock). Returns true when the function is hooked, either way.
local tipPost, tipPend, tipHooked = {}, {}, false
local TIP_SETTERS = { "SetAction", "SetSpellBookItem", "SetSpellByID", "SetSpell", "SetUnit" }

local function tip_kind(tt)
    local get = tt and (tt.GetPrimaryTooltipData or tt.GetTooltipData)
    if not get then
        return nil
    end
    local ok, d = pcall(get, tt)
    if ok and type(d) == "table" and F.Usable(d.type) then
        return d.type, d
    end
    return nil
end

local function tip_fire(tt)
    local etype, d = tip_kind(tt)
    if etype == nil then
        return
    end
    for kind, list in pairs(tipPost) do
        if Enum.TooltipDataType[kind] == etype then
            for i = 1, #list do
                pcall(list[i], tt, d)
            end
        end
    end
end

-- the hook runs right after the game's own function (a secure hook: its taint is dropped), so the
-- Persian is in place before the tooltip is drawn. A timer made the tooltip show one English frame
-- every time the game rebuilt it (an action bar tooltip is rebuilt every few ticks). tipPend only
-- stops a hook that fires inside our own work (tt:Show -> OnShow) from running it again.
local function tip_note(tt)
    if tipPend[tt] then
        return
    end
    tipPend[tt] = true
    tip_fire(tt)
    tipPend[tt] = nil
end

-- the test mock's RunTip (tests/lua/wow_mock.lua) runs the hooked functions of a kind at once
function F.TipPostRun(kind, tt, data)
    for _, fn in ipairs(tipPost[kind] or {}) do
        fn(tt, data)
    end
end

function F.TipPost(kind, fn)
    local gt = GameTooltip
    local can = gt and (gt.GetPrimaryTooltipData or gt.GetTooltipData) and gt.HookScript and F.After
        and Enum and Enum.TooltipDataType and Enum.TooltipDataType[kind] ~= nil
    if can then
        tipPost[kind] = tipPost[kind] or {}
        tipPost[kind][#tipPost[kind] + 1] = fn
        if not tipHooked then
            tipHooked = true
            for _, tt in ipairs({ GameTooltip, _G.ItemRefTooltip }) do
                if type(tt) == "table" and tt.HookScript then
                    pcall(tt.HookScript, tt, "OnShow", tip_note)
                    for _, m in ipairs(TIP_SETTERS) do
                        if type(tt[m]) == "function" then
                            pcall(hooksecurefunc, tt, m, tip_note)
                        end
                    end
                end
            end
        end
        return true
    end
    if tdp(kind) then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType[kind], fn)
        return true
    end
    return false
end

local function left_lines(tt, data)
    local out = {}
    if data and type(data.lines) == "table" then
        for _, ln in ipairs(data.lines) do
            out[#out + 1] = F.Usable(ln.leftText) and ln.leftText or ""
        end
        if #out > 0 then
            return out
        end
    end
    local name = tt:GetName()
    if not name then
        return out
    end
    for i = 1, tt:NumLines() do
        local fs = _G[name .. "TextLeft" .. i]
        local t = fs and fs:GetText()
        out[#out + 1] = (F.Usable(t) and t) or ""
    end
    return out
end

-- 0.5.7 (Brain audit B8): the live spell name can carry |c..|r or an icon /
-- hyperlink escape - strip before the Once key and the name lookup
local function plain(s)
    s = string.gsub(s or "", "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    s = string.gsub(s, "|T.-|t", "")
    s = string.gsub(s, "|H.-|h", "")
    s = string.gsub(s, "|h", "")
    return s
end

-- 1.1.6 (the owner's b71139 list: 60 of 65 misses were Leatherworking recipes): a profession
-- recipe tooltip ("Leatherworking: Fine Leather Belt", "Reagents: ...", "Equip: ...", the made
-- item's lines) is ITEM content. Items stay English for now, so it is never logged as a miss.
local PROF = {
    alchemy = true, blacksmithing = true, cooking = true, enchanting = true, engineering = true,
    ["first aid"] = true, leatherworking = true, tailoring = true, smelting = true, mining = true,
    jewelcrafting = true, inscription = true, fishing = true, skinning = true, herbalism = true,
    poisons = true,
}
local function recipe(name)
    local p = string.match(string.lower(plain(name or "")), "^%s*([%a ]-)%s*:%s")
    return p ~= nil and PROF[p] == true
end
local ITEM_LINE = { "^reagents:", "^equip:", "^use:", "^chance on hit:", "^you haven't collected", "^set:" }
local function item_line(text)
    local t = string.gsub(string.lower(plain(text or "")), "^%s+", "")
    for _, p in ipairs(ITEM_LINE) do
        if string.find(t, p) then
            return true
        end
    end
    return false
end
F.IsRecipeTip, F.IsItemLine = recipe, item_line

-- rc6 (rc4 miss list: 27 of 34 "misses" were our OWN Persian read back as a new
-- line): any line that already holds Arabic-script text is never matched and
-- never logged. UTF-8: U+0600-06FF = D8-DB xx, presentation forms = EF AD-BB xx.
local function has_fa(s)
    return type(s) == "string"
        and (string.find(s, "[\216-\219]") ~= nil or string.find(s, "\239[\173-\187]") ~= nil)
end

-- rc4 (the owner's miss list: "If the hunter takes damage, she will be dazed"):
-- the client fills the $g he/she choice with the PLAYER's gender while the data
-- was keyed from the male text. On a miss, retry the key with the male words.
local function gender_alts(key)
    if not string.find(key, "%f[%a]she%f[%A]") and not string.find(key, "%f[%a]her") then
        return nil
    end
    local k = string.gsub(key, "%f[%a]she%f[%A]", "he")
    k = string.gsub(k, "%f[%a]herself%f[%A]", "himself")
    local his = string.gsub(k, "%f[%a]her%f[%A]", "his")
    local him = string.gsub(k, "%f[%a]her%f[%A]", "him")
    return { his, him }
end

-- rc7 (rc6 miss list): a tooltip line that is a LIST ("You are proficient in the
-- use of the following armor types:" + one word per line, the languages a race
-- speaks) differs per class and race, so no single template can hold it. The
-- header and every word are rows of the ui table ("l:" + lowercase English);
-- the list is shown only when ALL of its parts are known, else it stays English
-- and the normal miss log shows it.
local function list_fa(text)
    if not string.find(text, "[\r\n]") then
        return nil
    end
    local ui = F.D.ui
    if type(ui) ~= "table" then
        return nil
    end
    local parts = {}
    for ln in string.gmatch(text, "[^\r\n]+") do
        ln = string.gsub(ln, "^%s+", "")
        ln = string.gsub(ln, "%s+$", "")
        if ln ~= "" then
            parts[#parts + 1] = ln
        end
    end
    if #parts < 2 then
        return nil
    end
    local out = {}
    for i = 1, #parts do
        local fa = ui["l:" .. string.lower(parts[i])]
        if type(fa) ~= "string" then
            return nil
        end
        out[#out + 1] = fa
    end
    return out
end

-- rc8 (settings v2): the font string of tooltip line i (matched by its text, so a
-- tooltip whose rows are not 1:1 with the data lines still finds the right one)
local function line_fs(tt, i, expect)
    local name = tt.GetName and tt:GetName()
    if not name or type(expect) ~= "string" then
        return nil
    end
    local want = plain(expect)
    local function try(k)
        local fs = _G[name .. "TextLeft" .. k]
        if fs and fs.GetText then
            local ok, t = pcall(fs.GetText, fs)
            if ok and F.Usable(t) and type(t) == "string" and plain(t) == want then
                return fs
            end
        end
        return nil
    end
    local fs = try(i)
    if fs then
        return fs
    end
    local n = (tt.NumLines and tt:NumLines()) or 0
    for k = 1, n do
        fs = try(k)
        if fs then
            return fs
        end
    end
    return nil
end

-- rc8: which settings section this tooltip belongs to: the frame that is open
-- (the Forever PlayerSpellsFrame holds the spellbook AND the talents), else the module
local function section_of(modId)
    local ok, r = pcall(function()
        local f = _G.PlayerSpellsFrame
        if f then
            local tf, sf = f.TalentsFrame, f.SpellBookFrame
            if tf and tf.IsShown and tf:IsShown() then
                return "talents"
            end
            if sf and sf.IsShown and sf:IsShown() then
                return "spellbook"
            end
        end
        return nil
    end)
    if ok and r then
        return r
    end
    return modId == "talents" and "talents" or "spellbook"
end

-- rc22 (the owner: Persian only, the first words of a description fell under the rest;
-- and the same after a font size change): the tooltip is as wide as its English lines,
-- so the Persian is wrapped at THAT width. A line wider than the tooltip is re-wrapped
-- by the client, which cuts our already ordered line and puts its logical start last.
local function tip_w(tt)
    local ok, w = pcall(function()
        return tt:GetWidth()
    end)
    if ok and F.Usable(w) and type(w) == "number" and w >= 140 then
        return w - 18
    end
    return nil
end

local function spell_tip(modId, tt, data)
    if tt and tt.wfaScan then
        return -- the /wowfa dump scanner tooltip: we export English, never translate it
    end
    if F.ShiftEn and F.ShiftEn() then
        return -- 1.0.7: Shift held = the game's English original (Modules/Dialog.lua re-shows on release)
    end
    if not tt or (tt.IsForbidden and tt:IsForbidden()) then
        return
    end
    local lines = left_lines(tt, data)
    local name = lines[1]
    if type(name) ~= "string" or name == "" then
        return
    end
    name = plain(name)
    -- rc8: line 1 already holds Persian = our own in-place rewrite (or a Persian game text)
    if has_fa(name) then
        return
    end
    if not T.Once(tt, "s" .. name) then
        return
    end
    local names = F.D.names and F.D.names.spell or {}
    local tpl = F.D.tpl or {}
    local faName = names[T.NameKey(name)] -- lane-28 §A3: NameKey on both sides
    -- 1.1.8 (the owner's list: "Call silentecho" x33): a hunter's Call Pet spell carries the PET's
    -- own name ("Call <pet name>"), so no table can hold it: a one-word "Call X" of a hunter is
    -- "Call" in Persian + the pet's name, and it is never a miss
    if faName == nil and F.L and F.L.call_pet and not has_fa(name) then
        local pet = string.match(name, "^Call (%S+)$")
        if pet then
            local okc, _, cls = pcall(UnitClass, "player")
            if okc and cls == "HUNTER" then
                faName = F.L.call_pet .. " " .. pet
            end
        end
    end
    -- rc4: a line 1 that starts with a digit is a cost row ("107 Mana"), never a name
    if faName == nil and not string.find(name, "^%d") and not has_fa(name) and not recipe(name) then
        F:Miss("spell", T.NameKey(name), name) -- rc3 update watch (Core F:Miss)
    end
    local found, srcOf = {}, {}
    for i = 2, #lines do
        local text = lines[i]
        if text ~= "" and #text > (tt.wfaMin or 8) and not has_fa(text) then
            local lst = list_fa(text)
            local key, nums = T.NumKey(text)
            local fa = (not lst) and tpl[key] or nil
            if not fa and not lst then
                local alts = gender_alts(key)
                if alts then
                    fa = tpl[alts[1]] or tpl[alts[2]]
                end
            end
            if lst then
                for _, s in ipairs(lst) do
                    found[#found + 1] = s
                    srcOf[#found] = i
                end
            elseif fa then
                found[#found + 1] = T.Fill(fa, nums)
                srcOf[#found] = i
            elseif #text > (tt.wfaMiss or 30) and not recipe(name) and not item_line(text) then
                -- rc4: description-sized lines only (cost / range / cast header
                -- rows are short; they belong to the in-place settings v2 work)
                F:Miss("tpl", key, plain(text), name)
            end
        end
    end
    F:Track(modId, faName ~= nil or #found > 0)
    -- lane-b16: the sp family switch off = the English name stays on the
    -- spell/talent tooltip. A hit still counts (the data matches the game).
    -- rc8: the section's own (or General's) display of the name and the description
    local sec = (tt and tt.wfaSec) or section_of(modId) -- 1.1.6: the settings preview names its section
    local tmod = F.mods and F.mods.talents -- rc36: the Talents switch also holds the fallback path
    if sec == "talents" and tmod and not tmod.active then
        return
    end
    local tmode = F.Disp and F.Disp(sec, "title") or 2
    local dmode = F.Disp and F.Disp(sec, "desc") or 2
    local showName = faName ~= nil and F.Room.On("namesSpell") and tmode ~= 3 -- 51-B
    -- Brain review: the descriptions are the room's «توضیحات و افکت‌ها» (they
    -- used to ride no switch at all, so «کاملاً انگلیسی» still showed Persian)
    local showDesc = #found > 0 and F.Room.On("textDesc") and dmode ~= 3
    if showName then
        local done = false
        if tmode == 1 or tmode == 2 then
            -- in place: line 1 becomes the Persian name (+ the English under it)
            local fs = line_fs(tt, 1, lines[1])
            if fs then
                local shown = faName
                if tmode == 2 then
                    shown = faName .. "\n" .. name
                end
                done = pcall(T.TipSet, tt, fs, shown, nil, "Left")
            end
        end
        if not done then
            T.TipLine(tt, faName, C.gold)
        end
    end
    if showDesc then
        if dmode == 1 then
            -- in place: the Persian text replaces the English line it translates
            local order, byLine = {}, {}
            for k, fa in ipairs(found) do
                local i = srcOf[k] or 0
                if not byLine[i] then
                    byLine[i] = {}
                    order[#order + 1] = i
                end
                byLine[i][#byLine[i] + 1] = T.Prepare(fa)
            end
            for _, i in ipairs(order) do
                local txt = table.concat(byLine[i], "\n")
                local fs = i > 0 and line_fs(tt, i, lines[i]) or nil
                local ok = false
                if fs then
                    ok = pcall(T.TipSet, tt, fs, txt, nil, "Left")
                end
                if not ok then
                    T.TipLine(tt, txt, DESC)
                end
            end
        else
            for _, fa in ipairs(found) do
                T.TipLine(tt, T.Prepare(fa), DESC)
            end
        end
    end
    T.Done(tt)
    if showName or showDesc then
        tt:Show()
        -- one frame after the layout: a string the client re-wrapped after all is wrapped
        -- again, narrower (T.TipRecheck), then the tooltip lays itself out once more
        if T.Mode() == 3 and F.After then
            F.After(0, function()
                local ok, changed = pcall(T.TipRecheck, tt)
                if ok and changed then
                    pcall(tt.Show, tt)
                end
            end)
        end
    end
end

-- 1.2.1: the buffs and debuffs (Modules/Auras.lua) put an aura tooltip through the same function
F.SpellTip = spell_tip

local function data_ok()
    local t = F.D.tpl
    local n = F.D.names and F.D.names.spell
    if type(t) == "table" and next(t) then
        return t
    end
    return n
end

-- --------------------------------------------------------------- spellbook
local S = { id = "spellbook", order = 5, risk = "high", nameKey = "m_spellbook", descKey = "m_spellbook_d", watchMiss = true }
S.data = data_ok

function S.api()
    return tdp("Spell") or (GameTooltip and (GameTooltip.SetSpellBookItem or GameTooltip.SetSpell or GameTooltip.SetSpellByID) ~= nil)
end

function S.install()
    local fn = F:Wrap("spellbook", function(tt, data)
        spell_tip("spellbook", tt, data)
    end)
    if F.TipPost("Spell", fn) then
        return
    end
    for _, method in ipairs({ "SetSpellBookItem", "SetSpell", "SetSpellByID" }) do
        if GameTooltip[method] then
            hooksecurefunc(GameTooltip, method, function(tt)
                fn(tt)
            end)
        end
    end
end
F:RegisterModule(S)

-- ----------------------------------------------------------------- talents
local TL = { id = "talents", order = 6, risk = "high", nameKey = "m_talents", descKey = "m_talents_d", watchMiss = true }
TL.data = data_ok

function TL.api()
    if GetTalentInfo ~= nil and GameTooltip ~= nil and GameTooltip.SetTalent ~= nil then
        TL.okWhy = nil
        return true
    end
    -- lane-b12 (owner test of 0.5.4: Talents=noapi): this client has no
    -- GameTooltip.SetTalent - talent tooltips arrive as Spell tooltip data,
    -- which the spellbook module already hooks. Report ok with the
    -- "via spellbook" why and DO NOT add a second hook (never add the
    -- Persian text twice). Final wording after the owner's talent-hover test.
    if tdp("Spell") then
        TL.okWhy = "via_spellbook"
        return true
    end
    TL.okWhy = nil
    return false
end

function TL.install()
    if GameTooltip and GameTooltip.SetTalent then
        hooksecurefunc(GameTooltip, "SetTalent", F:Wrap("talents", function(tt)
            spell_tip("talents", tt)
        end))
        return
    end
    -- 0.5.7 (Brain audit B9): on this client talent tooltips arrive as Spell
    -- data. The spellbook hook covers them while spellbook is active; when the
    -- player turns Spellbook OFF and Talents ON, talents must still translate -
    -- so install a Spell post-call that only acts while spellbook is NOT active
    -- (never a double line).
    F.TipPost("Spell", F:Wrap("talents", function(tt, data)
        if F:Active("spellbook") then
            return
        end
        spell_tip("talents", tt, data)
    end))
end
F:RegisterModule(TL)

-- --------------------------------------------- rc4: tooltips with no spell data
-- The owner's rc3 test: the Forever talent frame (Primary / Secondary, Apply
-- Changes) shows plain GameTooltip text with no Spell tooltip data, so no
-- post-call fires (Ferocity stayed English and never reached the miss list).
-- Fallback: on GameTooltip show, when line 1 is a KNOWN spell/talent name and
-- the tooltip is not an item or a unit, run the same spell_tip. T.Once (same
-- "s"..name key) keeps a tooltip the post-call already did from getting the
-- Persian twice. Unknown names under a talent/spell frame are logged (kind
-- "tip", with the owner frame path) so the next build can hook that frame.
local function owner_path(tt)
    local ok, path = pcall(function()
        local parts = {}
        local f = tt.GetOwner and tt:GetOwner()
        local n = 0
        while f and n < 6 do
            local nm = f.GetName and f:GetName()
            if type(nm) == "string" and F.Usable(nm) then
                parts[#parts + 1] = nm
            end
            f = f.GetParent and f:GetParent()
            n = n + 1
        end
        return table.concat(parts, "<")
    end)
    return (ok and type(path) == "string") and path or ""
end

local function is_item_or_unit(tt)
    local ok, r = pcall(function()
        if tt.GetItem then
            local _, link = tt:GetItem()
            if link then
                return true
            end
        end
        if tt.GetUnit then
            local _, unit = tt:GetUnit()
            if unit then
                return true
            end
        end
        return false
    end)
    return (not ok) or r
end

local function plain_tip(tt)
    if not tt or (tt.IsForbidden and tt:IsForbidden()) then
        return
    end
    local mod = (F:Active("spellbook") and "spellbook") or (F:Active("talents") and "talents") or nil
    if not mod then
        return
    end
    local tname = tt.GetName and tt:GetName()
    local fs = tname and _G[tname .. "TextLeft1"]
    local first = fs and fs:GetText()
    if not F.Usable(first) or type(first) ~= "string" or first == "" then
        return
    end
    first = plain(first)
    if has_fa(first) then
        return
    end
    local names = F.D.names and F.D.names.spell or {}
    if names[T.NameKey(first)] == nil then
        local path = owner_path(tt)
        local low = string.lower(path)
        -- rc19: the micro menu buttons (SpellbookMicroButton, TalentMicroButton) are no spell
        -- frames - their "Spellbook (P)" tooltip was logged as a miss
        local inFrame = (string.find(low, "talent") or string.find(low, "spell")) and not string.find(low, "microbutton")
        -- rc6: a spec tab tooltip is just the tree name ("Survival", "Beast Mastery")
        local trees = F.D.names and F.D.names.tree or {}
        local faTree = inFrame and trees[T.NameKey(first)] or nil
        if faTree and not is_item_or_unit(tt) then
            if T.Once(tt, "t" .. T.NameKey(first)) and F.Room.On("namesSpell") then
                T.TipLine(tt, faTree, C.gold)
                T.Done(tt)
                tt:Show()
            end
            return
        end
        if inFrame then
            F:Miss("tip", path .. "|" .. T.NameKey(first), first, path)
        end
        return
    end
    if is_item_or_unit(tt) then
        return
    end
    spell_tip(mod, tt, nil)
end

if GameTooltip and GameTooltip.HookScript then
    GameTooltip:HookScript("OnShow", function(tt)
        local ok, err = pcall(plain_tip, tt)
        if not ok then
            F:LogError("spellbook", err)
        end
    end)
end
