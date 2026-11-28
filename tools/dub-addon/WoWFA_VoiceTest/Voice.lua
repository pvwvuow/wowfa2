-- WoWFA voice test 0.4: plays Persian voice lines (NPC voices, and the player's own error voice).
-- Which voice? 1) a named NPC (D.npcs), 2) the creature id (D.byEntry) checked against the model the game really shows,
-- 3) any NPC whose model is a dubbed model (D.models), e.g. every male dwarf: one fixed voice per creature, never a mix.
-- Triggers: opening a conversation (greeting, "pissed" after many clicks), closing it (farewell), first fight (aggro).
local D = WoWFAVoiceData
if not D then return end
D.npcs = D.npcs or {}
D.generic = D.generic or {}
D.byEntry = D.byEntry or {}
D.models = D.models or {}

local TRIGGER_CATS = { "greeting", "farewell", "pissed", "aggro", "vendor" }
local debug = false
local lastPlay = {}      -- category -> time
local seenGuid = {}      -- guid -> time of the aggro line
local clicks = {}        -- npc name -> { n = count, t = last time }
local active = nil       -- the conversation that is open now: { guid = , entry = }
local token = 0          -- bumped for every new NPC, so a late model answer for an old NPC is ignored
local resolving = nil    -- guid whose voice is being looked up right now

local function say(...) print("|cfff0c75eWoWFA voice|r", ...) end
local function dbg(...) if debug then say(...) end end
local function norm(s)
  if type(s) ~= "string" then return nil end
  local r = s:lower():gsub("[^%a%d]", "")
  return r
end

local byName = {}
for _, g in ipairs(D.generic) do byName[g.name] = g end

local function DB()
  WoWFAVoiceDB = WoWFAVoiceDB or {}
  WoWFAVoiceDB.bind = WoWFAVoiceDB.bind or {}
  return WoWFAVoiceDB
end

local function creatureId(unit)
  local g = UnitGUID(unit)
  if type(g) ~= "string" then return nil end
  local kind, _, _, _, _, id = strsplit("-", g)
  if kind ~= "Creature" and kind ~= "Vehicle" then return nil end
  return tonumber(id)
end

local function unitKey(unit)
  local id = creatureId(unit)
  if id then return "id" .. id end
  return "n" .. (norm(UnitName(unit)) or "")
end

local function lookupNamed(name)
  local k = norm(name)
  if not k then return nil end
  return D.npcs[k] or D.npcs[(k:gsub("^the", ""))]
end

-- ---------------------------------------------------------------- the model the game shows for a unit
local modelFrame, modelApi = nil, nil
local function modelAvailable()
  if modelApi ~= nil then return modelApi end
  modelApi = false
  local ok, f = pcall(CreateFrame, "PlayerModel", nil, UIParent)
  if ok and f and f.GetModelFileID and f.SetUnit then
    f:SetSize(8, 8)
    f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    f:SetAlpha(0)
    f:EnableMouse(false)
    modelFrame, modelApi = f, true
  end
  return modelApi
end

-- cb(modelFileId or nil); polls a few times because the model loads a moment after SetUnit
local function getModel(unit, cb)
  if not modelAvailable() then cb(nil, "no model api") return end
  local f = modelFrame
  pcall(f.ClearModel, f)
  local okSet = pcall(f.SetUnit, f, unit)
  if not okSet then cb(nil, "SetUnit failed") return end
  local tries = 0
  local function poll()
    tries = tries + 1
    local ok, id = pcall(f.GetModelFileID, f)
    if ok and type(id) == "number" and id > 0 then cb(id) return end
    if tries >= 12 then cb(nil, "model did not load") return end
    C_Timer.After(0.05, poll)
  end
  poll()
end

-- ---------------------------------------------------------------- choosing the voice
local function isGuard(name) return type(name) == "string" and name:lower():find("guard", 1, true) ~= nil end

-- groups = list of group names that share this model; one fixed pick per creature
local function pickGroup(groups, id, uname)
  local list = {}
  for _, gn in ipairs(groups) do if byName[gn] then list[#list + 1] = byName[gn] end end
  if #list == 0 then return nil end
  local guards, others = {}, {}
  for _, g in ipairs(list) do if g.guard then guards[#guards + 1] = g else others[#others + 1] = g end end
  local use = others
  if (isGuard(uname) and #guards > 0) or #others == 0 then use = guards end
  return use[((id or #(uname or "")) % #use) + 1]
end

-- returns entry, why   (model may be nil when the game would not tell us)
local function resolve(unit, model)
  local uname = UnitName(unit)
  local n = lookupNamed(uname)
  if n then return n, "named" end
  local id = creatureId(unit)
  if DB().bind[unitKey(unit)] and D.generic[1] then return pickGroup({ D.generic[1].name }, id, uname), "bound" end
  local pairsOf = id and D.byEntry[id]
  if pairsOf then
    -- one model only: no doubt about the voice, whatever the model check says
    if #pairsOf == 1 and pairsOf[1][2] then return pickGroup({ pairsOf[1][2] }, id, uname), "game data" end
    if model then
      local groups = {}
      for _, p in ipairs(pairsOf) do if p[1] == model and p[2] then groups[#groups + 1] = p[2] end end
      if #groups > 0 then return pickGroup(groups, id, uname), "game data + model" end
      if D.models[model] then return pickGroup(D.models[model], id, uname), "model" end
      return nil, "game data: this creature shows another model"
    end
    return nil, "game data: several models and the model is unknown"
  end
  if model and D.models[model] then return pickGroup(D.models[model], id, uname), "model" end
  if not model then return nil, "unknown creature and no model" end
  return nil, "model has no dub voice"
end

local function play(cat, entry)
  if not entry then return false end
  local list = entry[cat]
  if not list or #list == 0 then return false end
  local now = GetTime()
  if lastPlay[cat] and now - lastPlay[cat] < 1.0 then return false end
  lastPlay[cat] = now
  local e = list[math.random(#list)]
  local ok, err = pcall(PlaySoundFile, D.dir .. e.f, "Dialog")
  dbg(cat, entry.name, e.f, ok and "ok" or tostring(err))
  return ok
end

-- ---------------------------------------------------------------- conversation events
local function onInteract(ev)
  local name, guid = UnitName("npc"), UnitGUID("npc")
  if not name or not guid then return end
  -- the same NPC opening another window (gossip -> vendor): same conversation, no second greeting
  if active and active.guid == guid and GetTime() - active.t < 20 then
    active.t = GetTime()
    if ev == "MERCHANT_SHOW" and not active.vendor and play("vendor", active.entry) then active.vendor = true end
    return
  end
  if resolving == guid then return end
  active = nil
  resolving = guid
  token = token + 1
  local my = token
  getModel("npc", function(model, why)
    if resolving == guid then resolving = nil end
    if my ~= token or UnitGUID("npc") ~= guid then return end
    local entry, how = resolve("npc", model)
    dbg("npc", name, "id", tostring(creatureId("npc")), "model", tostring(model), why or "", "event", tostring(ev), "->", entry and entry.name or "none", how)
    if not entry then return end
    active = { guid = guid, entry = entry, t = GetTime() }
    local now = GetTime()
    local c = clicks[guid]
    if c and now - c.t < 10 then c.n = c.n + 1 else c = { n = 1 }; clicks[guid] = c end
    c.t = now
    if c.n >= 5 and play("pissed", entry) then return end
    if ev == "MERCHANT_SHOW" and play("vendor", entry) then active.vendor = true return end
    if c.n < 5 then play("greeting", entry) end
  end)
end

local WINDOWS = { "GossipFrame", "MerchantFrame", "QuestFrame", "ClassTrainerFrame", "TrainerFrame", "TaxiFrame", "BankFrame", "AuctionFrame", "GuildRegistrarFrame", "PetStableFrame", "TabardFrame" }
local function anyWindowOpen()
  for _, n in ipairs(WINDOWS) do
    local fr = _G[n]
    if fr and fr.IsShown and fr:IsShown() then return true end
  end
  return false
end

local function onClose()
  local a = active
  if not a then return end
  C_Timer.After(0.3, function()
    if active ~= a then return end
    if anyWindowOpen() then return end   -- only moved to another window of the same NPC
    active = nil
    play("farewell", a.entry)
  end)
end

-- no COMBAT_LOG_EVENT_UNFILTERED here: newer clients block addons from registering it
local function onCombatStart()
  for _, unit in ipairs({ "target", "mouseover", "focus" }) do
    if UnitExists(unit) and not UnitIsPlayer(unit) and UnitCanAttack("player", unit) then
      local entry = lookupNamed(UnitName(unit))
      if entry then
        local key = unitKey(unit)
        local now = GetTime()
        if not (seenGuid[key] and now - seenGuid[key] < 60) then
          seenGuid[key] = now
          play("aggro", entry)
          return
        end
      end
    end
  end
end

-- ---------------------------------------------------------------- the player's own voice: errors ("not enough mana")
-- D.player = { race, sex, errors = { kind = { dub = {ids}, orig = {ids} } } }. Only for a character of that race and sex.
-- A kind is only taken over when its error text is known below: its original sounds are muted and a dub line plays instead.
-- Anything not listed keeps its original sound. Entries starting with ERR_ or SPELL_FAILED_ are the game's own texts
-- (so it works in any language), the rest is plain English text.
local ERR_ORDER = { "loottoofar", "lootdidntkill", "nomana", "norage", "noenergy", "spellcooldown", "abilitycooldown", "itemcooldown",
  "inventoryfull", "bagfull", "itemmaxcount", "notenoughmoney", "invalidattacktarget", "genericnotarget", "cantequiplevel",
  "cantequipever", "proficiencyneeded", "mustequipitem", "notabag", "guildpermissions", "noammo", "alreadyingroup",
  "cantdropsoulbounditem", "outofrange" }
local ERR_TEXT = {
  nomana = { "ERR_OUT_OF_MANA", "not enough mana" },
  norage = { "ERR_OUT_OF_RAGE", "not enough rage" },
  noenergy = { "ERR_OUT_OF_ENERGY", "not enough energy" },
  spellcooldown = { "ERR_SPELL_COOLDOWN", "spell is not ready" },
  abilitycooldown = { "ERR_ABILITY_COOLDOWN", "ability is not ready" },
  itemcooldown = { "ERR_ITEM_COOLDOWN", "item is not ready" },
  inventoryfull = { "ERR_INV_FULL", "inventory is full" },
  bagfull = { "ERR_BAG_FULL", "that bag is full" },
  itemmaxcount = { "ERR_ITEM_MAX_COUNT", "any more of those" },
  notenoughmoney = { "ERR_NOT_ENOUGH_MONEY", "not enough money" },
  loottoofar = { "ERR_LOOT_TOO_FAR", "too far away to loot", "too far to loot" },
  lootdidntkill = { "ERR_LOOT_DIDNT_KILL", "permission to loot" },
  invalidattacktarget = { "ERR_INVALID_ATTACK_TARGET", "cannot attack that target" },
  genericnotarget = { "ERR_GENERIC_NO_TARGET", "you have no target" },
  cantequiplevel = { "you must reach level" },
  cantequipever = { "ERR_CANT_EQUIP_EVER", "can never use that" },
  proficiencyneeded = { "ERR_PROFICIENCY_NEEDED", "required proficiency" },
  mustequipitem = { "ERR_MUST_EQUIP_ITEM", "must equip that item" },
  notabag = { "ERR_NOT_A_BAG", "not a bag" },
  guildpermissions = { "ERR_GUILD_PERMISSIONS", "permission to do that" },
  noammo = { "ERR_NO_AMMO", "out of ammo", "no ammo" },
  alreadyingroup = { "already in a group" },
  cantdropsoulbounditem = { "drop soulbound" },
  outofrange = { "ERR_OUT_OF_RANGE", "out of range" },
}
local errPat = nil      -- kind -> list of lowercase texts (built at login)
local errOn = false     -- this character is the one the error voice is for
local lastErr = {}      -- kind -> time

local function playerMatches()
  local P = D.player
  if not P or not P.errors then return false end
  local okR, _, race = pcall(UnitRace, "player")
  local okS, sex = pcall(UnitSex, "player")
  if not okR or not okS or type(race) ~= "string" then return false end
  return race:lower() == P.race and ((sex == 2 and P.sex == "m") or (sex == 3 and P.sex == "f"))
end

local function buildErrors()
  errPat, errOn = {}, playerMatches()
  local n = 0
  for _, kind in ipairs(ERR_ORDER) do
    local e = D.player and D.player.errors and D.player.errors[kind]
    if e and e.dub and #e.dub > 0 and ERR_TEXT[kind] then
      local list = {}
      for _, t in ipairs(ERR_TEXT[kind]) do
        if t:find("^ERR_") or t:find("^SPELL_FAILED_") then
          local g = _G[t]
          if type(g) == "string" and not g:find("%%") and #g > 4 then list[#list + 1] = g:lower() end
        else
          list[#list + 1] = t
        end
      end
      if #list > 0 then errPat[kind] = list; n = n + 1 end
    end
  end
  return n
end

local function muteErrors()
  local muted = 0
  if not (errOn and MuteSoundFile and errPat) then return muted end
  for kind in pairs(errPat) do
    for _, id in ipairs(D.player.errors[kind].orig or {}) do
      if pcall(MuteSoundFile, id) then muted = muted + 1 end
    end
  end
  return muted
end

-- UI_ERROR_MESSAGE gives (type, text) or (text) depending on the game version: take the first text
local function onError(ev, a, b)
  if not errOn or not errPat then return end
  local msg = type(b) == "string" and b or (type(a) == "string" and a or nil)
  if not msg then return end
  local low = msg:lower()
  for _, kind in ipairs(ERR_ORDER) do
    local list = errPat[kind]
    if list then
      for _, t in ipairs(list) do
        if low:find(t, 1, true) then
          local now = GetTime()
          if lastErr[kind] and now - lastErr[kind] < 1.0 then return end
          lastErr[kind] = now
          local dub = D.player.errors[kind].dub
          local id = dub[math.random(#dub)]
          local ok, err = pcall(PlaySoundFile, D.dir .. id .. ".ogg", "Dialog")
          dbg("error voice", kind, id, ok and "ok" or tostring(err))
          return
        end
      end
    end
  end
  dbg("error text without a dub voice:", msg)
end

local f = CreateFrame("Frame")
local handlers = {
  GOSSIP_SHOW = onInteract, QUEST_GREETING = onInteract, MERCHANT_SHOW = onInteract, TRAINER_SHOW = onInteract, QUEST_DETAIL = onInteract,
  GOSSIP_CLOSED = onClose, MERCHANT_CLOSED = onClose, TRAINER_CLOSED = onClose, QUEST_FINISHED = onClose,
  PLAYER_REGEN_DISABLED = onCombatStart,
  UI_ERROR_MESSAGE = onError,
}
for ev in pairs(handlers) do
  local ok = pcall(f.RegisterEvent, f, ev)
  if not ok then dbg("event not available:", ev) end
end
f:RegisterEvent("PLAYER_LOGIN")

local function muteAll()
  local muted = 0
  if not MuteSoundFile then return muted, false end
  local function one(entry)
    for _, cat in ipairs(TRIGGER_CATS) do
      for _, e in ipairs(entry[cat] or {}) do
        if e.id and pcall(MuteSoundFile, e.id) then muted = muted + 1 end
      end
    end
    for _, id in ipairs(entry.mute or {}) do
      if pcall(MuteSoundFile, id) then muted = muted + 1 end
    end
  end
  for _, n in pairs(D.npcs) do one(n) end
  for _, g in ipairs(D.generic) do one(g) end
  return muted, true
end

f:SetScript("OnEvent", function(_, ev, ...)
  if ev == "PLAYER_LOGIN" then
    local muted, has = muteAll()
    local nErr = buildErrors()
    local mutedErr = muteErrors()
    local nEntry = 0
    for _ in pairs(D.byEntry) do nEntry = nEntry + 1 end
    say(string.format("v0.4.0 loaded: %d named NPC, %d voice groups, %d creatures, %d original sounds muted%s, model check %s (/wfv)",
      D.count or 0, #D.generic, nEntry, muted + mutedErr, has and "" or " (MuteSoundFile missing)", modelAvailable() and "on" or "OFF"))
    if D.player then
      say(string.format("own voice (%s %s): %s, %d error kinds", tostring(D.player.race), tostring(D.player.sex), errOn and "ON for this character" or "off (other race or sex)", nErr))
    end
    return
  end
  local h = handlers[ev]
  if h then
    local ok, err = pcall(h, ev, ...)
    if not ok then say("error", ev, tostring(err)) end
  end
end)

SLASH_WFV1 = "/wfv"
SlashCmdList["WFV"] = function(msg)
  msg = (msg or ""):lower()
  if msg == "debug" then debug = not debug; say("debug", debug and "on" or "off"); return end
  if msg == "info" or msg == "bind" or msg == "unbind" then
    local unit = UnitExists("target") and "target" or (UnitExists("mouseover") and "mouseover" or nil)
    if not unit then say("target an NPC first") return end
    local key = unitKey(unit)
    if msg == "bind" then DB().bind[key] = UnitName(unit) or true; say("bound:", UnitName(unit), key, "(this NPC always uses the first dub voice)") return end
    if msg == "unbind" then DB().bind[key] = nil; say("unbound:", UnitName(unit), key) return end
    getModel(unit, function(model, why)
      local entry, how = resolve(unit, model)
      say("info:", tostring(UnitName(unit)), key, "sex", tostring(UnitSex(unit)), "model", tostring(model), why or "")
      say("voice:", entry and entry.name or "none", "(" .. how .. ")")
    end)
    return
  end
  if msg == "errors" then
    say("own voice:", errOn and "ON" or "off", "- with /wfv debug on, every error text that has no dub is printed")
    for _, kind in ipairs(ERR_ORDER) do
      if errPat and errPat[kind] then say(kind, #D.player.errors[kind].dub, "dub files") end
    end
    return
  end
  if msg == "list" then
    for _, g in ipairs(D.generic) do
      say(g.name, "greeting", #(g.greeting or {}), "farewell", #(g.farewell or {}), "pissed", #(g.pissed or {}), "aggro", #(g.aggro or {}))
    end
    for _, n in pairs(D.npcs) do
      say(n.name, "greeting", #(n.greeting or {}), "farewell", #(n.farewell or {}), "pissed", #(n.pissed or {}), "aggro", #(n.aggro or {}))
    end
    return
  end
  if msg == "test" then
    local e = D.generic[1]
    if not e then for _, n in pairs(D.npcs) do e = n break end end
    for _, cat in ipairs({ "greeting", "farewell", "pissed", "aggro" }) do
      local x = e and e[cat] and e[cat][1]
      if x then say("test", e.name, cat, x.f); PlaySoundFile(D.dir .. x.f, "Dialog"); return end
    end
    say("no voice files")
    return
  end
  say("/wfv test | /wfv list | /wfv debug | /wfv info | /wfv bind | /wfv unbind (target an NPC) | /wfv errors")
end
