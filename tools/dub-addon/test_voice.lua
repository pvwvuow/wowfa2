-- mock of the game API: loads Data.lua and Voice.lua of the voice test addon and plays events through it
local base = arg and arg[1] or "tools/dub-addon/WoWFA_VoiceTest/"
local played, muted, printed, handlers = {}, {}, {}, {}
local now = 100
local events = {}
local race, sex = "Troll", 2
function GetTime() return now end
function print(...) local t = {} for i = 1, select("#", ...) do t[#t + 1] = tostring((select(i, ...))) end printed[#printed + 1] = table.concat(t, " ") end
function strsplit(sep, s) local out = {} for part in (s .. sep):gmatch("(.-)" .. sep:gsub("%p", "%%%0")) do out[#out + 1] = part end return unpack(out) end
function UnitRace() return race:gsub("^%l", string.upper), race end
function UnitSex() return sex end
function MuteSoundFile(id) muted[#muted + 1] = id end
function PlaySoundFile(path, ch) played[#played + 1] = path end
function UnitName(u) if u == "npc" then return "Test Dwarf" end end
local npcGuid = "Creature-0-0-0-0-16226-0"
function UnitGUID(u) if u == "npc" then return npcGuid end end
function UnitExists() return false end
C_Timer = { After = function(_, fn) fn() end }
UIParent = {}
local function frame()
  local f = {}
  setmetatable(f, { __index = function(t, k) return function() return true end end })
  f.GetModelFileID = function() return 118355 end
  f.IsShown = function() return false end
  f.RegisterEvent = function(self, ev) events[ev] = true end
  f.SetScript = function(self, what, fn) if what == "OnEvent" then handlers.onEvent = fn end end
  return f
end
function CreateFrame() return frame() end
SlashCmdList = {}
local function load(name)
  local fn, err = loadfile(base .. name)
  assert(fn, err)
  fn()
end
load("Data.lua"); load("Voice.lua")
local D = WoWFAVoiceData
local fails = 0
local function check(cond, what) if not cond then fails = fails + 1 print("FAIL: " .. what) io.write("FAIL: " .. what .. "\n") else io.write("ok: " .. what .. "\n") end end
check(#D.generic == 13, "13 dubbed groups (" .. #D.generic .. ")")
local nEntry = 0 for _ in pairs(D.byEntry) do nEntry = nEntry + 1 end
check(nEntry > 1000, "creatures mapped: " .. nEntry)
check(D.player and D.player.errors.nomana and #D.player.errors.nomana.dub > 0, "error voice data present")
local function ev(name, ...) handlers.onEvent(nil, name, ...) end
ev("PLAYER_LOGIN")
io.write("login: " .. table.concat(printed, " | ") .. "\n")
check(events.UI_ERROR_MESSAGE, "UI_ERROR_MESSAGE registered")
local ownOn = false for _, l in ipairs(printed) do if l:find("ON for this character", 1, true) then ownOn = true end end
check(ownOn, "own voice on for a male troll")
check(#muted > 100, "originals muted: " .. #muted)
local function err(msg, a) played = {} ev("UI_ERROR_MESSAGE", a or 0, msg) return played[1] end
local cases = { { "Not enough mana.", "nomana" }, { "Not enough rage.", "norage" }, { "Out of range.", "outofrange" }, { "You are too far away to loot that corpse.", "loottoofar" },
  { "Inventory is full.", "inventoryfull" }, { "Spell is not ready yet.", "spellcooldown" }, { "You have no target.", "genericnotarget" }, { "Not enough money.", "notenoughmoney" } }
for _, c in ipairs(cases) do
  now = now + 5
  local p = err(c[1])
  local ids = {} for _, id in ipairs(D.player.errors[c[2]] and D.player.errors[c[2]].dub or {}) do ids[D.dir .. id .. ".ogg"] = true end
  if D.player.errors[c[2]] then check(p and ids[p], c[1] .. " -> " .. c[2] .. " " .. tostring(p)) else io.write("skip (no dub for " .. c[2] .. ")\n") end
end
now = now + 5
check(err("Something unrelated happened.") == nil, "unrelated error plays nothing")
now = now + 5; local a1 = err("Not enough mana."); local a2 = err("Not enough mana.")
check(a1 and not a2, "same error twice in a second plays once")
now = now + 5; played = {} ev("UI_ERROR_MESSAGE", "Not enough mana.")
check(played[1] ~= nil, "text as the only argument")
now = now + 30; played = {}
ev("GOSSIP_SHOW")
check(played[1] and played[1]:find("voice\\", 1, true), "greeting plays for a dwarf NPC: " .. tostring(played[1]))
race = "Human"; ev("PLAYER_LOGIN")
local off = false for _, l in ipairs(printed) do if l:find("off (other race or sex)", 1, true) then off = true end end
check(off, "own voice off for a human")
now = now + 5; check(err("Not enough mana.") == nil, "no error voice for a human")
io.write(fails == 0 and "ALL OK\n" or ("FAILED " .. fails .. "\n"))
os.exit(fails == 0 and 0 or 1)
