-- WoWFA Sound Browser: listen to the original NPC greeting / farewell / annoyed sounds. Type /wsb
local data = WSB_DATA or {}
local KIND = { "greeting", "farewell", "annoyed" }
local st = { g = 1, k = 0, i = 0, list = {}, handle = nil }
local frame, label, info, btnKind

local function rebuild()
  st.list = {}
  local g = data[st.g]
  if g then
    for _, f in ipairs(g[2]) do
      if st.k == 0 or f[2] == st.k then st.list[#st.list + 1] = f end
    end
  end
  st.i = 0
end

local function refresh()
  if not frame then return end
  local g = data[st.g]
  local kn = (st.k == 0) and "all" or KIND[st.k]
  label:SetText(string.format("%d/%d  %s", st.g, #data, g and g[1] or "-"))
  btnKind:SetText("Kind: " .. kn)
  local f = st.list[st.i]
  if f then
    info:SetText(string.format("[%d/%d] %s (%s)  id %d", st.i, #st.list, f[3], KIND[f[2]], f[1]))
  else
    info:SetText(string.format("%d files in this set. Press Next.", #st.list))
  end
end

local function stopCur()
  if st.handle and StopSound then pcall(StopSound, st.handle) end
  st.handle = nil
end

local function play()
  local f = st.list[st.i]
  if not f then return end
  stopCur()
  local ok, willPlay, handle = pcall(PlaySoundFile, f[1], "Master")
  if ok then st.handle = handle end
  if (not ok) or willPlay == false then print("WSB: this sound is not in your client: " .. f[3]) end
  refresh()
end

local function step(d)
  if #st.list == 0 then return end
  st.i = st.i + d
  if st.i > #st.list then st.i = 1 elseif st.i < 1 then st.i = #st.list end
  play()
end

local function group(d)
  if #data == 0 then return end
  st.g = st.g + d
  if st.g > #data then st.g = 1 elseif st.g < 1 then st.g = #data end
  rebuild()
  refresh()
end

local function cycleKind()
  st.k = (st.k + 1) % 4
  rebuild()
  refresh()
end

local function mkbtn(parent, text, w, x, y, fn)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(w, 22)
  b:SetPoint("TOPLEFT", x, y)
  b:SetText(text)
  b:SetScript("OnClick", fn)
  return b
end

local function build()
  frame = CreateFrame("Frame", "WSBFrame", UIParent)
  frame:SetSize(540, 150)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
  frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  local bg = frame:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  if bg.SetColorTexture then bg:SetColorTexture(0, 0, 0, 0.85) else bg:SetTexture(0, 0, 0, 0.85) end
  local t = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  t:SetPoint("TOPLEFT", 10, -8)
  t:SetText("WoWFA Sound Browser")
  label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  label:SetPoint("TOPLEFT", 10, -30)
  info = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  info:SetPoint("TOPLEFT", 10, -52)
  mkbtn(frame, "< Set", 80, 10, -80, function() group(-1) end)
  mkbtn(frame, "Set >", 80, 95, -80, function() group(1) end)
  btnKind = mkbtn(frame, "Kind: all", 120, 180, -80, cycleKind)
  mkbtn(frame, "< Prev", 80, 10, -112, function() step(-1) end)
  mkbtn(frame, "Replay", 80, 95, -112, play)
  mkbtn(frame, "Next >", 80, 180, -112, function() step(1) end)
  mkbtn(frame, "Stop", 70, 265, -112, stopCur)
  local x = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  x:SetPoint("TOPRIGHT", 2, 2)
  frame:Hide()
  rebuild()
end

local function showFrame()
  if not frame then build() end
  refresh()
  frame:Show()
end

SLASH_WSB1 = "/wsb"
SlashCmdList["WSB"] = function(msg)
  msg = string.lower(msg or "")
  local cmd, arg = msg:match("^(%S*)%s*(.-)$")
  if #data == 0 then
    print("WSB: no data")
    return
  end
  if cmd == "list" then
    local c = 0
    for i, g in ipairs(data) do
      if arg == "" or string.find(string.lower(g[1]), arg, 1, true) then
        print(i, g[1], #g[2])
        c = c + 1
        if c >= 40 then break end
      end
    end
  elseif cmd == "set" and arg ~= "" then
    local n = tonumber(arg)
    if n and data[n] then
      st.g = n
    else
      for i, g in ipairs(data) do
        if string.find(string.lower(g[1]), arg, 1, true) then
          st.g = i
          break
        end
      end
    end
    rebuild()
    showFrame()
  elseif cmd == "kind" then
    local m = { all = 0, greeting = 1, g = 1, farewell = 2, f = 2, annoyed = 3, a = 3 }
    if m[arg] then
      st.k = m[arg]
      rebuild()
    end
    showFrame()
  else
    if frame and frame:IsShown() then frame:Hide() else showFrame() end
  end
end
