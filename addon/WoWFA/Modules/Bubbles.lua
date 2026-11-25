-- WoWFA Forever - the speech bubbles above heads. The game draws them with its own font:
-- a Persian line shows empty boxes. Behind the same switch as the Persian chat
-- (F.db.chatFa, default on): a bubble whose text has raw Persian letters gets our font
-- and the shaped text. Not a registered module: pcall everywhere, nothing in combat
-- needs it (bubbles are plain font strings).

local F = WoWFAF
local T = F.T

local function on()
    local db = F.db
    return db and db.enabled and db.chatFa ~= false and true or false
end

local function fix_fs(fs)
    local ok, txt = pcall(fs.GetText, fs)
    if not ok or not F.Usable(txt) or type(txt) ~= "string" or txt == "" then
        return
    end
    if not string.find(txt, "[\216-\219]") then
        -- 1.0.7: an NPC line the data has in Persian (Modules/Dialog.lua)
        local fa = F.Dialog and F.Dialog.BubbleFa and F.Dialog.BubbleFa(txt)
        if type(fa) ~= "string" or fa == "" then
            return -- no raw Persian (ours is already shaped: presentation forms)
        end
        txt = fa
    end
    local okS, shaped = pcall(function()
        return T.ShapeLine(T.Clean(txt), T.Mode())
    end)
    if not okS or type(shaped) ~= "string" or shaped == "" then
        return
    end
    -- rc36: the size of the first sight of this bubble string, never the size we set
    local base = fs.wfaBubbleBase
    if not base then
        local _, size, flags = fs:GetFont()
        base = { size = type(size) == "number" and size or 12, flags = flags or "" }
        fs.wfaBubbleBase = base
    end
    pcall(fs.SetFont, fs, F.FONT, math.floor(base.size * 0.9 * 10 + 0.5) / 10, base.flags)
    pcall(fs.SetText, fs, shaped)
end

local function scan_frame(f, depth)
    if depth > 3 then
        return
    end
    local okr, regs = pcall(function()
        return { f:GetRegions() }
    end)
    if okr then
        for _, r in ipairs(regs) do
            if type(r) == "table" and r.GetObjectType and r.GetObjectType(r) == "FontString" then
                fix_fs(r)
            end
        end
    end
    local okc, kids = pcall(function()
        return { f:GetChildren() }
    end)
    if okc then
        for _, k in ipairs(kids) do
            scan_frame(k, depth + 1)
        end
    end
end

local function scan()
    if not on() then
        return
    end
    if C_ChatBubbles and C_ChatBubbles.GetAllChatBubbles then
        local ok, list = pcall(C_ChatBubbles.GetAllChatBubbles)
        if ok and type(list) == "table" then
            for _, b in ipairs(list) do
                pcall(scan_frame, b, 0)
            end
        end
    end
end

local function soon()
    if not on() then
        return
    end
    for _, d in ipairs({ 0, 0.1, 0.4 }) do
        F.After(d, function()
            local ok, err = pcall(scan)
            if not ok then
                F:LogError("bubbles", err)
            end
        end)
    end
end

for _, ev in ipairs({ "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_EMOTE", "CHAT_MSG_MONSTER_SAY", "CHAT_MSG_MONSTER_YELL", "CHAT_MSG_MONSTER_PARTY" }) do
    F:On(ev, nil, soon)
end
