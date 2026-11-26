-- WoWFA Forever - 1.1.6: the live preview column of the settings window (the owner 26 Nov:
-- "a column on the left that shows, in the game's own look, exactly what the setting I switch
-- changes; an eye button next to each setting"). Every setting with something to see gets an
-- eye; a click draws its sample here. The samples are built from the SAME engine the game
-- windows use (the zone / NPC / quest / class tables, Walk, the NPC talk lookup, the system
-- lines, the red alerts, the game-window texts) and the spell sample is a REAL GameTooltip
-- the spell hooks translate, so what this column shows is what the game will show. Any switch
-- that changes redraws the open sample at once. Plain (insecure) frames only; every draw runs
-- in pcall and an error is logged once as "preview".

local F = WoWFAF
local T = F.T
local UI = F.UI
local C = F.C

local P = {}
F.Preview = P
F.PREVIEW_W = 310 -- the width the settings window grows by (Panel.lua reads it)

local function fa(s)
    return (string.gsub(s, "~", "\226\128\140"))
end

local TX = {
    title = fa("نمونهٔ زنده"),
    hint = fa("هر تنظیمی را عوض کنی، همین~جا می~بینی در بازی چه شکلی می~شود."),
    orig = fa("اصل بازی (انگلیسی):"),
    nofa = fa("برای این نمونه هنوز ترجمه~ای نیست؛ بازی همان انگلیسی را نشان می~دهد."),
    off = fa("این بخش خاموش است: بازی متن انگلیسی خودش را نشان می~دهد."),
    cap = {
        zone = fa("اسم منطقه وسط صفحه وقتی واردش می~شوی، و بالای نقشهٔ کوچک"),
        map = fa("اسم منطقه روی نقشهٔ دنیا، وقتی ماوس را رویش می~بری"),
        npc = fa("تولتیپ NPC، وقتی ماوس را رویش می~بری"),
        quest = fa("ردیاب کوئست، و پنجرهٔ کوئست با پنل فارسی کنارش"),
        spell = fa("تولتیپ واقعی یک اسپل؛ دقیقاً همانی که در بازی می~بینی"),
        talent = fa("تولتیپ واقعی یک تلنت، با تنظیم تلنت~ها"),
        text = fa("یک خط از متن کوئست: اسم~ها، اصطلاح~ها، عددها و رنگ~ها"),
        gossip = fa("پنجرهٔ گفتگوی NPC و پنل فارسی کنارش"),
        say = fa("حرف NPC در چت"),
        chat = fa("پیام بازیکن~ها در چت"),
        sys = fa("پیام~های سیستم در چت: غنیمت، تجربه، سطح"),
        alert = fa("پیام قرمز وسط صفحه"),
        gameui = fa("تب~ها و دکمه~های پنجره~های خود بازی"),
        font = fa("متنی که خود بازی با فونت خودش می~نویسد: اسم~ها، نامه، دوستان"),
    },
    chatmsg = fa("سلام، کسی برای سیاه~چال میاد؟"),
    fontmsg = fa("علی: سلام دوستان"),
    -- the sentence of the "text" sample: {1} NPC, {2} zone, {3} spell, {4} class (Persian from the data)
    text = fa("{1} در {2} منتظر توست. 10 {{it:Linen Cloth|پارچهٔ کتان}} بیاور، با {3} جلوی {{fac:Defias Brotherhood|برادری دفایاس}} بایست و با {{tm:Hearthstone|سنگ راهخانه}} برگرد. این کار مخصوص {4} است."),
    texten = "%s waits in %s. Bring 10 Linen Cloth, face the Defias Brotherhood with %s and come back with your Hearthstone. A task for a %s.",
}

local GAMEFONT = "Fonts\\FRIZQT__.TTF"
local GOLD = { 1, 0.82, 0 }
local WHITE = { 1, 1, 1 }
local GREY = { 0.75, 0.75, 0.75 }
local BROWN = { 0.20, 0.13, 0.06 }
local SW = 270 -- the sample width

local pane, stage, cur, curRow
local built = {}
local logged = false

-- ------------------------------------------------------------ widget helpers
local function en_fs(parent, size, color, flags, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(GAMEFONT, size, flags or "")
    fs:SetTextColor(color[1], color[2], color[3])
    fs:SetJustifyH(justify or "LEFT")
    return fs
end

-- one place, two strings: the game's English (game font) or our Persian (our font)
local function slot(parent, size, color, flags, justify, w)
    local s = { w = w or SW }
    s.en = en_fs(parent, size, color, flags, justify)
    s.fa = UI.Text(parent, size, color, justify or "RIGHT")
    s.en:SetWidth(s.w)
    s.fa:SetWidth(s.w)
    function s.Point(self, a, rel, b, x, y)
        self.en:SetPoint(a, rel, b, x, y)
        self.fa:SetPoint(a, rel, b, x, y)
    end
    -- isFa: Persian through the shaper; raw: an already shaped line (Walk, Sysmsg ...)
    function s.Set(self, text, isFa, raw)
        text = text or ""
        if isFa then
            self.en:Hide()
            self.fa:Show()
            if raw then
                self.fa:SetText(text)
            else
                self.fa:SetFa(text, self.w)
            end
        else
            self.fa:Hide()
            self.en:Show()
            self.en:SetText(text)
        end
    end
    function s.Hide(self)
        self.en:Hide()
        self.fa:Hide()
    end
    return s
end

local function solid(f, r, g, b, a)
    local t = f:CreateTexture(nil, "BACKGROUND")
    t:SetAllPoints()
    t:SetColorTexture(r, g, b, a or 1)
    return t
end

-- the game tooltip look: near-black glass, a thin light edge
local function tipbg(f)
    solid(f, 0.03, 0.03, 0.06, 0.92)
    for _, side in ipairs({ "TOP", "BOTTOM" }) do
        local l = f:CreateTexture(nil, "BORDER")
        l:SetColorTexture(0.62, 0.62, 0.62, 0.9)
        l:SetHeight(1)
        l:SetPoint(side .. "LEFT")
        l:SetPoint(side .. "RIGHT")
    end
    for _, side in ipairs({ "LEFT", "RIGHT" }) do
        local l = f:CreateTexture(nil, "BORDER")
        l:SetColorTexture(0.62, 0.62, 0.62, 0.9)
        l:SetWidth(1)
        l:SetPoint("TOP" .. side)
        l:SetPoint("BOTTOM" .. side)
    end
end

local function box(parent, w, h, x, y)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(w, h)
    f:SetPoint("TOPLEFT", parent, "TOPLEFT", x or 0, y or 0)
    return f
end

local function has_fa(s)
    return type(s) == "string" and string.find(s, "[\216-\219\239]") ~= nil
end

local function key(s)
    local ok, k = pcall(T.NameKey, s)
    return ok and k or string.lower(tostring(s or ""))
end

local function names(kind)
    return (F.D and F.D.names and F.D.names[kind]) or {}
end

-- the first English of a list the data has Persian for (else the first name of the table)
local function pick(kind, list)
    local tab = names(kind)
    for _, en in ipairs(list) do
        local v = tab[key(en)]
        if type(v) == "string" and v ~= "" then
            return en, v, key(en)
        end
    end
    local best
    for k in pairs(tab) do
        if not best or k < best then
            best = k
        end
    end
    if best then
        local en = string.gsub(best, "(%a)(%w*)", function(a, b) return string.upper(a) .. b end)
        return en, tab[best], best
    end
    return list[1], nil, key(list[1])
end

local function on(k)
    return F.Room and F.Room.On(k) and true or false
end

local function active(id)
    return F:Active(id) and true or false
end

local function gfmt(name, fallback, ...)
    local f = _G[name]
    if type(f) ~= "string" or f == "" then
        f = fallback
    end
    local ok, s = pcall(string.format, f, ...)
    return ok and s or fallback
end

-- ------------------------------------------------------------ the samples
local S = {}
P.SAMPLES = S

S.zone = {
    build = function(f)
        solid(f, 0.10, 0.13, 0.10, 1)
        local mm = box(f, 150, 22, SW - 150, -6)
        solid(mm, 0, 0, 0, 0.55)
        f.mm = slot(mm, 11, GOLD, "", "CENTER", 150)
        f.mm:Point("CENTER", mm, "CENTER", 0, 0)
        f.big = slot(f, 24, GOLD, "OUTLINE", "CENTER")
        f.big:Point("TOP", f, "TOP", 0, -70)
        f.sub = slot(f, 15, { 0.95, 0.95, 0.95 }, "OUTLINE", "CENTER")
        f.sub:Point("TOP", f, "TOP", 0, -110)
    end,
    update = function(f)
        local en, v = pick("zone", { "Elwynn Forest", "Durotar", "Mulgore", "Teldrassil", "Dun Morogh", "Tirisfal Glades" })
        local sen, sv = pick("zone", { "Goldshire", "Razor Hill", "Bloodhoof Village", "Dolanaar", "Kharanos", "Brill" })
        local ok = on("namesZone") and active("dungeons")
        f.big:Set(ok and v or en, ok and v ~= nil)
        f.sub:Set(ok and sv or sen, ok and sv ~= nil)
        f.mm:Set(ok and sv or sen, ok and sv ~= nil)
        return en .. "  /  " .. sen, ok and not v
    end,
}

S.map = {
    build = function(f)
        solid(f, 0.24, 0.21, 0.14, 1)
        f.a = slot(f, 20, { 1, 0.95, 0.8 }, "OUTLINE", "CENTER")
        f.a:Point("TOP", f, "TOP", 0, -80)
        f.b = slot(f, 13, { 0.9, 0.85, 0.7 }, "OUTLINE", "CENTER")
        f.b:Point("TOP", f, "TOP", 0, -112)
    end,
    update = function(f)
        local en, v = pick("zone", { "Elwynn Forest", "Durotar", "Westfall", "The Barrens" })
        local mode = (F.db and F.db.zoneMap) or 2
        local ok = on("namesZone") and active("dungeons") and mode ~= 3 and v ~= nil
        if ok then
            f.a:Set(v, true)
            if mode == 2 then
                f.b:Set(en, false)
            else
                f.b:Hide()
            end
        else
            f.a:Set(en, false)
            f.b:Hide()
        end
        return en
    end,
}

S.npc = {
    build = function(f)
        f.tip = box(f, 230, 78, 20, -24)
        tipbg(f.tip)
        f.name = slot(f.tip, 14, { 0.1, 0.9, 0.1 }, "", "LEFT", 214)
        f.name:Point("TOPLEFT", f.tip, "TOPLEFT", 8, -8)
        f.name2 = slot(f.tip, 12, GREY, "", "LEFT", 214)
        f.name2:Point("TOPLEFT", f.tip, "TOPLEFT", 8, -28)
        f.lvl = en_fs(f.tip, 12, WHITE)
        f.lvl:SetPoint("TOPLEFT", f.tip, "TOPLEFT", 8, -52)
        f.lvl:SetText("Level 30")
    end,
    update = function(f)
        local en, _, k = pick("npc", { "Marshal Dughan", "Hogger", "Innkeeper Farley", "Gornek", "Thrall" })
        local v = active("npc") and F.NpcLookup and F.NpcLookup(k) or nil
        local mode = F.NpcMode and F.NpcMode() or 1
        if v then
            f.name:Set(v, true)
            if mode == 2 then
                f.name2:Set(en, false)
            else
                f.name2:Hide()
            end
        else
            f.name:Set(en, false)
            f.name2:Hide()
        end
        return en
    end,
}

local function quest_row(title)
    local h = F.TitleHash(title)
    for id, row in pairs((F.D and F.D.quests) or {}) do
        if type(row) == "string" and string.sub(row, 1, #h) == h and h ~= "" then
            local p = F.Split(F.QRow(row), "\031")
            if (p[2] or "") ~= "" then
                return p
            end
        end
    end
end

local function cut(s, n)
    if #s <= n then
        return s
    end
    local at = string.find(s, " ", n, true)
    return at and (string.sub(s, 1, at - 1) .. " ...") or s
end

-- v4: ONE quest sample for every quest switch: the tracker (title + objectives, at the tracker
-- size), the game's quest window and the Persian pane beside it
S.quest = {
    build = function(f)
        local tr = box(f, SW, 76, 0, 0)
        f.tr = tr
        solid(tr, 0, 0, 0, 0.25)
        f.title = slot(tr, 13, GOLD, "", "LEFT")
        f.title:Point("TOPLEFT", tr, "TOPLEFT", 8, -8)
        f.o1 = slot(tr, 12, WHITE, "", "LEFT")
        f.o1:Point("TOPLEFT", tr, "TOPLEFT", 8, -32)
        f.o2 = slot(tr, 12, WHITE, "", "LEFT")
        f.o2:Point("TOPLEFT", tr, "TOPLEFT", 8, -52)
        f.qf = box(f, SW, 56, 0, -84)
        solid(f.qf, 0.85, 0.76, 0.56, 1)
        f.qt = en_fs(f.qf, 14, BROWN, "", "LEFT")
        f.qt:SetPoint("TOPLEFT", f.qf, "TOPLEFT", 10, -8)
        f.qt:SetWidth(SW - 20)
        f.qb = en_fs(f.qf, 11, BROWN, "", "LEFT")
        f.qb:SetPoint("TOPLEFT", f.qf, "TOPLEFT", 10, -30)
        f.qb:SetWidth(SW - 20)
        f.qb:SetText("Bring me the head of Edwin VanCleef ...")
        f.fp = box(f, SW, 150, 0, -146)
        UI.Glass(f.fp, 0.94)
        f.ft = UI.Text(f.fp, 14, C.gold)
        f.ft:SetPoint("TOPRIGHT", f.fp, "TOPRIGHT", -10, -10)
        f.ft:SetWidth(SW - 20)
        f.fb = UI.Text(f.fp, 12, C.text)
        f.fb:SetPoint("TOPRIGHT", f.fp, "TOPRIGHT", -10, -34)
        f.fb:SetWidth(SW - 20)
    end,
    update = function(f)
        local title = "The Defias Brotherhood"
        local mob = pick("npc", { "Kobold Vermin", "Defias Thug", "Mottled Boar", "Young Wolf" })
        local o1 = "3/10 " .. mob .. " slain"
        local o2 = "Ready for turn-in"
        -- the tracker size slider (F.SizeOf) and the font of our lines
        local ts, osz = F.SizeOf and F.SizeOf("title") or 13, F.SizeOf and F.SizeOf("obj") or 12
        for _, s in ipairs({ { f.title, ts }, { f.o1, osz }, { f.o2, osz } }) do
            pcall(s[1].fa.SetFont, s[1].fa, F.FONT, s[2], F.Flags and F.Flags(s[1] == f.title and "qs" or nil) or "")
        end
        local tr = active("tracker") and F.Walk
        local t = tr and F.Walk.Quest(title) or nil
        local a = tr and F.Walk.Objective(o1) or nil
        local b = tr and F.Walk.Objective(o2) or nil
        f.title:Set(t or title, t ~= nil, true)
        f.o1:Set(a or ("- " .. o1), a ~= nil, true)
        f.o2:Set(b or ("- " .. o2), b ~= nil, true)
        f.qt:SetText(title)
        local p = quest_row(title)
        if p and active("quests") and on("questText") then
            f.fp:Show()
            local tt = on("namesQuest") and T.Prepare(p[2]) or title
            if on("namesQuest") then
                f.ft:SetFa(tt, SW - 20)
            else
                f.ft:SetText(title)
            end
            f.fb:SetFa(cut(T.Prepare(p[4] or ""), 300), SW - 20)
        else
            f.fp:Hide()
        end
        -- the part the row changes (the red pulse): its title, objectives, pane or the tracker
        local h = curRow and curRow.wfaHi
        local function vis(s)
            return (s.fa and s.fa:IsShown()) and s.fa or s.en
        end
        if h == "qtitle" then
            f.hi = vis(f.title)
        elseif h == "qobj" then
            f.hi = vis(f.o1)
        elseif h == "qpane" then
            f.hi = f.fp:IsShown() and f.fp or f.qf
        elseif h == "qtrack" then
            f.hi = f.tr
        else
            f.hi = nil
        end
        return title .. "  /  " .. o1, p == nil
    end,
}

local CLASS_SPELL = { WARRIOR = 78, PALADIN = 635, HUNTER = 1978, ROGUE = 1752, PRIEST = 585, SHAMAN = 403,
    MAGE = 133, WARLOCK = 686, DRUID = 5176 }

-- a REAL tooltip the spell hooks translate; wfaSec tells Modules/Spells.lua which section's
-- display to use (the spellbook default, or the talents' own)
S.spell = {
    build = function(f)
        f.tip = CreateFrame("GameTooltip", "WoWFAF_PreviewTip", f, "GameTooltipTemplate")
    end,
    update = function(f)
        local _, cls = UnitClass("player")
        local id = CLASS_SPELL[cls or ""] or 133
        local tip = f.tip
        tip.wfaSec = (curRow and curRow.wfaSec) or "spellbook"
        tip:SetOwner(f, "ANCHOR_NONE")
        tip:ClearAllPoints()
        tip:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
        if tip.SetSpellByID then
            pcall(tip.SetSpellByID, tip, id)
        end
        tip:Show()
        if not f.again then
            f.again = true -- the client loads a spell's text on the first ask: draw once more
            F.After(0.4, function()
                if cur == "spell" and pane and pane:IsShown() then
                    P.Update()
                end
            end)
        end
        local name = (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(id)) or (GetSpellInfo and GetSpellInfo(id))
        return type(name) == "string" and name or ("spell " .. id)
    end,
}

local GOSSIP = { "How may I help you?", "I can instruct you in mining. Interested?", "Looking for a tabard?",
    "I will teach you what I can.", "Elune's grace upon you. How can I serve?" }

local function gossip_line()
    for _, en in ipairs(GOSSIP) do
        local ok, v = pcall(F.Dialog.Lookup, en)
        if ok and v then
            return en, v
        end
    end
    return GOSSIP[1], nil
end

S.gossip = {
    build = function(f)
        f.gp = box(f, SW, 80, 0, 0)
        solid(f.gp, 0.85, 0.76, 0.56, 1)
        f.gt = en_fs(f.gp, 13, BROWN, "", "LEFT")
        f.gt:SetPoint("TOPLEFT", f.gp, "TOPLEFT", 10, -10)
        f.gt:SetWidth(SW - 20)
        f.fp = box(f, SW, 90, 0, -88)
        UI.Glass(f.fp, 0.94)
        f.ft = UI.Text(f.fp, 13, C.text)
        f.ft:SetPoint("TOPRIGHT", f.fp, "TOPRIGHT", -10, -12)
        f.ft:SetWidth(SW - 20)
    end,
    update = function(f)
        local en, v = gossip_line()
        f.gt:SetText(en)
        if v and F.Dialog.On("dlgGossip") then
            f.fp:Show()
            f.ft:SetFa(T.Prepare(v), SW - 20)
        else
            f.fp:Hide()
        end
        return en, not v
    end,
}

local function chatbox(f)
    solid(f, 0, 0, 0, 0.4)
end

S.say = {
    build = function(f)
        chatbox(f)
        f.l = slot(f, 13, { 1, 1, 0.62 }, "", "LEFT")
        f.l:Point("TOPLEFT", f, "TOPLEFT", 8, -14)
    end,
    update = function(f)
        local en, v = gossip_line()
        local who = "Kobold Miner says: "
        local okon = v and F.Dialog.On("dlgSay") and F.db.chatFa ~= false
        if okon then
            local line = string.gsub(string.gsub(T.Prepare(v), "|c%x%x%x%x%x%x%x%x", ""), "|r", "")
            local ok, s = pcall(T.ShapeLine, T.Digits(line), T.Mode())
            f.l:Set(who .. (ok and s or line), true, true)
        else
            f.l:Set(who .. en, false)
        end
        return who .. en, not v
    end,
}

S.chat = {
    build = function(f)
        chatbox(f)
        f.l = slot(f, 13, { 0.25, 1, 0.25 }, "", "LEFT")
        f.l:Point("TOPLEFT", f, "TOPLEFT", 8, -14)
    end,
    update = function(f)
        local head = "[Guild] [Ali]: "
        if F.db.chatFa ~= false then
            local ok, s = pcall(T.ShapeLine, TX.chatmsg, T.Mode())
            f.l:Set(head .. (ok and s or TX.chatmsg), true, true)
        else
            f.l:Set(head .. TX.chatmsg, false) -- the game font: empty boxes, exactly like the game
        end
        return head .. "..."
    end,
}

S.sys = {
    build = function(f)
        chatbox(f)
        local cols = { { 0, 0.67, 0 }, { 0.44, 0.44, 1 }, { 0.5, 0.5, 1 }, { 1, 1, 0 } }
        f.l = {}
        for i = 1, 4 do
            f.l[i] = slot(f, 12, cols[i], "", "LEFT")
            f.l[i]:Point("TOPLEFT", f, "TOPLEFT", 8, -12 - (i - 1) * 24)
        end
    end,
    update = function(f)
        -- one line of each group switch: loot / experience / reputation / group
        local lines = {
            gfmt("LOOT_ITEM_SELF", "You receive loot: %s.", "[Linen Cloth]"),
            gfmt("COMBATLOG_XPGAIN_FIRSTPERSON", "%s dies, you gain %d experience.", "Kobold Vermin", 45),
            gfmt("FACTION_STANDING_INCREASED", "Your %s reputation has increased by %d.", "Stormwind", 25),
            gfmt("ERR_JOINED_GROUP_S", "%s joins the party.", "Ali"),
        }
        for i, en in ipairs(lines) do
            local out = F.SysmsgPreview and F.SysmsgPreview(en) or nil
            f.l[i]:Set(out or en, out ~= nil, true)
        end
        return lines[1]
    end,
}

S.alert = {
    build = function(f)
        solid(f, 0.08, 0.08, 0.10, 1)
        f.l1 = slot(f, 16, { 1, 0.13, 0.13 }, "OUTLINE", "CENTER")
        f.l1:Point("TOP", f, "TOP", 0, -50)
        f.l2 = slot(f, 16, { 1, 0.13, 0.13 }, "OUTLINE", "CENTER")
        f.l2:Point("TOP", f, "TOP", 0, -80)
    end,
    update = function(f)
        local a = gfmt("ERR_SPELL_OUT_OF_RANGE", "Out of range.")
        local b = gfmt("ERR_QUEST_LOG_FULL", "Your quest log is full.")
        local x = F.AlertPreview and F.AlertPreview(a) or nil
        local y = F.AlertPreview and F.AlertPreview(b) or nil
        f.l1:Set(x or a, x ~= nil, true)
        f.l2:Set(y or b, y ~= nil, true)
        return a .. "  /  " .. b
    end,
}

S.gameui = {
    build = function(f)
        solid(f, 0.10, 0.08, 0.06, 1)
        f.h = slot(f, 14, GOLD, "", "CENTER")
        f.h:Point("TOP", f, "TOP", 0, -14)
        f.tabs = {}
        for i = 1, 3 do
            local t = box(f, 84, 26, 4 + (i - 1) * 90, -110)
            solid(t, 0.25, 0.05, 0.03, 1)
            t.s = slot(t, 12, GOLD, "", "CENTER", 84)
            t.s:Point("CENTER", t, "CENTER", 0, 0)
            f.tabs[i] = t
        end
        f.b = box(f, 120, 24, 75, -60)
        solid(f.b, 0.5, 0.05, 0.03, 1)
        f.b.s = slot(f.b, 12, GOLD, "", "CENTER", 120)
        f.b.s:Point("CENTER", f.b, "CENTER", 0, 0)
    end,
    update = function(f)
        local G = F.GameUI
        local function put(s, en)
            local v = G and G.Preview and G.Preview(en) or nil
            s:Set(v or en, v ~= nil, true)
        end
        put(f.h, "Character Info")
        put(f.b.s, "Repair All")
        for i, en in ipairs({ "Character", "Reputation", "Skills" }) do
            put(f.tabs[i].s, en)
        end
        return "Character Info / Repair All / Character / Reputation / Skills"
    end,
}

S.font = {
    build = function(f)
        chatbox(f)
        f.l = f:CreateFontString(nil, "OVERLAY")
        if GameFontNormal then
            f.l:SetFontObject(GameFontNormal)
        else
            f.l:SetFont(GAMEFONT, 13, "")
        end
        f.l:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -16)
        f.l:SetWidth(SW - 16)
        f.l:SetJustifyH("LEFT")
    end,
    update = function(f)
        -- the game's own font object: with the switch off it has no Persian letters (boxes)
        f.l:SetText(TX.fontmsg)
        return "(a Persian name / message the game draws itself)"
    end,
}

-- v4: one line of quest text with every name family + a term + a number: the presets, the
-- class / term / digit switches, the colours and the text outline all show here
S.text = {
    build = function(f)
        -- the dark glass of the Persian quest pane (the owner: the tan parchment read badly)
        local bg = box(f, SW, 130, 0, 0)
        UI.Glass(bg, 0.94)
        f.t = UI.Text(bg, 13, C.text)
        f.t:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -14)
        f.t:SetWidth(SW - 20)
    end,
    update = function(f)
        local function mk(fam, kind, list)
            local en, v = pick(kind, list)
            if type(v) ~= "string" or v == "" then
                return en, en
            end
            return en, "{{" .. fam .. ":" .. en .. "|" .. v .. "}}"
        end
        local nen, nm = mk("npc", "npc", { "Marshal Dughan", "Gornek", "Innkeeper Farley" })
        local zen, zm = mk("zn", "zone", { "Elwynn Forest", "Durotar", "Westfall" })
        local sen, sm = mk("sp", "spell", { "Fireball", "Frostbolt", "Charge", "Smite" })
        local cen = (UnitClass and UnitClass("player")) or "Hunter"
        if not F.Usable(cen) or type(cen) ~= "string" then
            cen = "Hunter"
        end
        local cfa = names("class")[key(cen)]
        local cm = (type(cfa) == "string" and cfa ~= "") and ("{{cls:" .. cen .. "|" .. cfa .. "}}") or cen
        local s = string.gsub(TX.text, "{(%d)}", { ["1"] = nm, ["2"] = zm, ["3"] = sm, ["4"] = cm })
        local out = T.Digits(T.Markers(s))
        -- the word the row changes blinks red (row.wfaHi: a marker family, or "dig")
        local h = curRow and curRow.wfaHi
        local hi
        if h == "dig" then
            hi = T.Digits(T.Markers((string.gsub(s, "10", "|cffff2020%0|r", 1))))
        elseif h then
            local found = false
            local hs = string.gsub(s, "{{" .. h .. ":[^}]-}}", function(m)
                if found then
                    return m
                end
                found = true
                local w = T.Markers(m)
                w = string.gsub(w, "|c%x%x%x%x%x%x%x%x", "")
                w = string.gsub(w, "|r", "")
                return "|cffff2020" .. w .. "|r"
            end)
            if found then
                hi = T.Digits(T.Markers(hs))
            end
        end
        pcall(f.t.SetFont, f.t, F.FONT, 13, F.Flags and F.Flags() or "")
        f.t:SetFa(out, SW - 20)
        f.outs = hi and { out, hi } or nil
        f.k, f.el = 1, 0
        if hi and not f.blinking then
            f.blinking = true
            f:SetScript("OnUpdate", function(self, el)
                if not self.outs then
                    return
                end
                self.el = (self.el or 0) + (el or 0)
                if self.el >= 0.45 then
                    self.el = 0
                    self.k = 3 - (self.k or 1)
                    self.t:SetFa(self.outs[self.k], SW - 20)
                end
            end)
        end
        return string.format(TX.texten, nen, zen, sen, cen)
    end,
}

-- ------------------------------------------------------------ the column
local function frame_of(id)
    local f = built[id]
    if not f then
        f = CreateFrame("Frame", nil, stage)
        f:SetSize(SW, 300)
        f:SetPoint("TOPLEFT", stage, "TOPLEFT", 0, 0)
        S[id].build(f)
        built[id] = f
    end
    return f
end

function P.Current()
    return cur
end

function P.Frame(id)
    return built[id]
end

-- v4.1 (the owner 26 Nov: "the player can not tell what he is looking at; make the thing the
-- option changes blink red"): a red frame pulses around the part of the sample the row changes
-- (f.hi, set by the sample from curRow.wfaHi); the text sample makes the word itself blink
local halo
local function hi_place(region)
    if not halo then
        halo = CreateFrame("Frame", nil, stage)
        halo:SetFrameLevel((stage:GetFrameLevel() or 1) + 20)
        local edges = {
            { "TOPLEFT", "TOPRIGHT", false }, { "BOTTOMLEFT", "BOTTOMRIGHT", false },
            { "TOPLEFT", "BOTTOMLEFT", true }, { "TOPRIGHT", "BOTTOMRIGHT", true },
        }
        for _, e in ipairs(edges) do
            local t = halo:CreateTexture(nil, "OVERLAY")
            t:SetColorTexture(1, 0.13, 0.13, 1)
            t:SetPoint(e[1])
            t:SetPoint(e[2])
            if e[3] then
                t:SetWidth(2)
            else
                t:SetHeight(2)
            end
        end
        local tt = 0
        halo:SetScript("OnUpdate", function(self, el)
            tt = tt + (el or 0)
            self:SetAlpha(0.25 + 0.75 * math.abs(math.sin(tt * 4)))
        end)
    end
    if region then
        halo:ClearAllPoints()
        halo:SetPoint("TOPLEFT", region, "TOPLEFT", -3, 3)
        halo:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", 3, -3)
        halo:Show()
    else
        halo:Hide()
    end
end

function P.Update()
    if not pane or not cur or not S[cur] then
        return
    end
    local ok, err = pcall(function()
        for id, f in pairs(built) do
            if id ~= cur then
                f:Hide()
            end
        end
        local f = frame_of(cur)
        f:Show()
        f.hi = nil
        local en, missing = S[cur].update(f)
        hi_place(f.hi)
        pane.orig:SetText(tostring(en or ""))
        pane.note:SetFa(missing and TX.nofa or " ", SW)
    end)
    if not ok and not logged then
        logged = true
        F:LogError("preview", err)
    end
end

function P.Show(id, row)
    if not pane or not S[id] then
        return
    end
    cur = id
    if curRow and curRow.wfaSel then
        curRow.wfaSel:Hide()
    end
    curRow = row
    if row and row.wfaSel then
        row.wfaSel:Show()
    end
    pane.hint:Hide()
    local lbl = row and row.label and row.label.GetText and row.label:GetText()
    pane.name:SetText(type(lbl) == "string" and lbl or "")
    local cap = TX.cap[id]
    if id == "spell" and row and row.wfaSec == "talents" then
        cap = TX.cap.talent
    end
    pane.cap:SetFa(cap or " ", SW)
    P.Update()
end

-- v4.2 (the owner 26 Nov: "remove the eye; when the player switches something, the preview
-- shows what that switch changes"): no button on the row any more. A click on the row (the
-- switch itself, a choice, a colour pick) draws its sample. row.eye stays as a hidden handle
-- (the same Show, for the tests); the row being shown gets a soft gold background.
local function eye(row, id)
    if not row or row.eye then
        return
    end
    local function show()
        P.Show(id, row)
    end
    local b = CreateFrame("Button", nil, row)
    b:SetSize(1, 1)
    b:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    b:SetScript("OnClick", show)
    b:Hide()
    row.eye = b
    local sel = row:CreateTexture(nil, "BACKGROUND")
    sel:SetAllPoints()
    sel:SetColorTexture(C.gold[1], C.gold[2], C.gold[3], 0.10)
    sel:Hide()
    row.wfaSel = sel
    if row.HookScript then
        pcall(row.HookScript, row, "OnClick", show)
    end
    if row.pick and row.pick.HookScript then
        pcall(row.pick.HookScript, row.pick, "OnClick", show)
    end
end
P.Eye = eye

function F.PreviewAttach(panel)
    local H = tonumber(panel:GetHeight()) or 600
    pane = CreateFrame("Frame", nil, panel)
    pane:SetSize(F.PREVIEW_W - 16, H - 78)
    pane:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -64)
    UI.Glass(pane, 0.6)
    pane.title = UI.Text(pane, 15, C.gold)
    pane.title:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -10, -8)
    pane.title:SetFa(TX.title, SW)
    pane.name = UI.Text(pane, 13, C.goldLight)
    pane.name:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -10, -32)
    pane.name:SetWidth(SW)
    pane.cap = UI.Text(pane, 11, C.muted)
    pane.cap:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -10, -54)
    pane.cap:SetFa(" ", SW)
    pane.hint = UI.Text(pane, 12, C.muted)
    pane.hint:SetPoint("TOPRIGHT", pane, "TOPRIGHT", -10, -40)
    pane.hint:SetFa(TX.hint, SW)
    stage = CreateFrame("Frame", nil, pane)
    stage:SetSize(SW, 300)
    stage:SetPoint("TOPLEFT", pane, "TOPLEFT", 10, -86)
    local oh = UI.Text(pane, 11, C.muted)
    oh:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", -10, 70)
    oh:SetFa(TX.orig, SW)
    pane.orig = UI.Latin(pane, 11, C.text, "LEFT")
    pane.orig:SetPoint("BOTTOMLEFT", pane, "BOTTOMLEFT", 10, 48)
    pane.orig:SetWidth(SW)
    pane.note = UI.Text(pane, 11, C.orange)
    pane.note:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", -10, 10)
    pane.note:SetWidth(SW)
    pane.note:SetFa(" ", SW)
    local vl = UI.Line(panel, true, 0.35)
    vl:SetPoint("TOPLEFT", panel, "TOPLEFT", F.PREVIEW_W + 2, -64)
    vl:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", F.PREVIEW_W + 2, 14)
    P.pane = pane
    -- the eyes: exactly the rows the panel marked (row.wfaEye = the sample that changes with it)
    for _, row in ipairs(panel.allRows or {}) do
        if type(row) == "table" and row.wfaEye and S[row.wfaEye] then
            eye(row, row.wfaEye)
        end
    end
end

-- a switch changed: the open sample is drawn again (one frame later: the modules first)
for _, sig in ipairs({ "room", "options", "state", "npcname", "disp", "names" }) do
    F:Listen(sig, function()
        if pane and cur and pane:IsShown() then
            F.After(0.05, P.Update)
        end
    end)
end
