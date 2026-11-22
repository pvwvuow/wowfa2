-- lua5.1 tools/lua/dump_old.lua <old Data dir> <out.json> <File> [<File> ...]
-- Loads the v0 generated Data/*.lua with the REAL Lua parser and writes them as JSON
-- (bytes >= 0x80 copied raw, control chars as \u00XX). Used by the migrate task and by the
-- round-trip proof (our own build output is dumped the same way and compared).
local dir, out = arg[1], arg[2]
WoWFA_FData = {}
for i = 3, #arg do
  local f = assert(loadfile(dir .. "/" .. arg[i] .. ".lua"))
  f("WoWFA", {})
end
local buf = {}
local function w(s) buf[#buf + 1] = s end
local function str(s)
  w('"')
  w((string.gsub(s, '[%c"\\]', function(c)
    if c == '"' then return '\\"' end
    if c == '\\' then return '\\\\' end
    return string.format('\\u%04x', string.byte(c))
  end)))
  w('"')
end
local enc
enc = function(v)
  local t = type(v)
  if t == "string" then str(v)
  elseif t == "number" then
    if v == math.floor(v) then w(string.format("%d", v)) else w(string.format("%.17g", v)) end
  elseif t == "boolean" then w(tostring(v))
  elseif t == "table" then
    local n = #v
    local arr = n > 0
    if arr then
      for k in pairs(v) do
        if type(k) ~= "number" or k < 1 or k > n or k ~= math.floor(k) then arr = false break end
      end
    end
    if arr then
      w("[")
      for i = 1, n do if i > 1 then w(",") end enc(v[i]) end
      w("]")
    else
      local keys = {}
      for k in pairs(v) do keys[#keys + 1] = k end
      table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
      w("{")
      for i, k in ipairs(keys) do
        if i > 1 then w(",") end
        str(tostring(k)) w(":") enc(v[k])
      end
      w("}")
    end
  else w("null") end
end
enc(WoWFA_FData)
local fh = assert(io.open(out, "wb"))
fh:write(table.concat(buf))
fh:close()
