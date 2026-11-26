"""Report only: where the addon's Lua memory goes. Builds out/dist, then on the WoW mock (lua5.1)
loads the TOC file by file (KB after a full GC per file), fires the login events, and measures
every data table under WoWFAF.D (and the big runtime tables) by dropping it and collecting.
args: none"""
import json
import os
import subprocess
import tempfile

from wfa import build as B
from wfa.core import OUT, ROOT, read_json
from wfa.store import Store

LUA = r'''
local ROOT = arg[1]
WOWFA_TEST_UNLOCK = false
dofile("tests/lua/wow_mock.lua")
local function kb()
    collectgarbage("collect")
    collectgarbage("collect")
    return collectgarbage("count")
end
local base = kb()
print(string.format("BASE mock %.0f", base))
local prev = base
for line in io.lines(ROOT .. "/WoWFA_Forever.toc") do
    line = line:gsub("\r$", "")
    if line ~= "" and not line:find("^##") then
        local f = loadfile(ROOT .. "/" .. line:gsub("\\", "/"))
        if f then
            pcall(f, "WoWFA", {})
        end
        local now = kb()
        print(string.format("FILE %s %.0f", line, now - prev))
        prev = now
    end
end
local F = WoWFAF
for _, ev in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD" }) do
    pcall(FireEvent, ev, "WoWFA")
    local now = kb()
    print(string.format("EVENT %s %.0f", ev, now - prev))
    prev = now
end
if C_Timer and C_Timer._run then pcall(C_Timer._run) end
print(string.format("TOTAL %.0f", kb() - base))
-- every table under F.D and F: drop it, collect, the drop = what it held alone
local function measure(owner, name, prefix)
    local keys = {}
    for k, v in pairs(owner) do
        if type(v) == "table" then keys[#keys + 1] = k end
    end
    for _, k in ipairs(keys) do
        local v = owner[k]
        local n = 0
        for _ in pairs(v) do n = n + 1 end
        local before = kb()
        owner[k] = nil
        local after = kb()
        owner[k] = v
        print(string.format("TABLE %s%s %.0f %d", prefix, tostring(k), before - after, n))
    end
end
if type(F) == "table" then
    if type(F.D) == "table" then
        if type(F.D.names) == "table" then measure(F.D.names, "names", "D.names.") end
        measure(F.D, "D", "D.")
    end
    measure(F, "F", "F.")
end
'''


def run(args, rep):
    pol = read_json(os.path.join(ROOT, "policy.json"))
    B.build(Store.load(), pol)
    dist = os.path.join(OUT, "dist", "WoWFA")
    with tempfile.NamedTemporaryFile("w", suffix=".lua", delete=False) as fh:
        fh.write(LUA)
        script = fh.name
    p = subprocess.run(["lua5.1", script, dist], capture_output=True, text=True, cwd=ROOT)
    out = (p.stdout or "").splitlines()
    rep.h("files (KB after load, full GC)")
    rows = []
    for l in out:
        if l.startswith(("BASE", "FILE", "EVENT", "TOTAL")):
            rows.append(l.split(" ", 1))
    rep.table(rows, ["what", "KB"])
    rep.h("tables (KB held alone, entries)")
    t = []
    for l in out:
        if l.startswith("TABLE"):
            _, name, k, n = l.split(" ")
            t.append((int(float(k)), name, n))
    t.sort(reverse=True)
    rep.table([(n, k, c) for k, n, c in t[:60]], ["table", "KB", "entries"])
    rep.h("dist files on disk")
    sizes = []
    for base, _, files in os.walk(dist):
        for fn in files:
            if fn.endswith(".lua"):
                full = os.path.join(base, fn)
                sizes.append((os.path.getsize(full) // 1024, os.path.relpath(full, dist)))
    sizes.sort(reverse=True)
    rep.table([(n, k) for k, n in sizes[:20]], ["file", "KB"])
    if p.returncode:
        rep.add("```\n" + (p.stderr or "")[-2000:] + "\n```")
    rep.ok("done")
    return []
