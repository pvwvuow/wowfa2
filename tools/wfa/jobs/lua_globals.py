"""Report only: every GLOBAL variable the addon sources write (luac -l SETGLOBAL), per file.
A global written by an addon is tainted; if Blizzard code reads the same name, its secure
execution is tainted and protected calls (action bars ...) are blocked. args: allow (prefixes
that are ours, default WoWFA / SLASH_ / BINDING_)"""
import pathlib
import re
import shutil
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[3]


def run(args, rep):
    luac = None
    for name in ("luac5.1", "luac"):
        if shutil.which(name):
            luac = name
            break
    if not luac:
        rep.fail("no luac")
        return []
    allow = tuple(args.get("allow") or ["WoWFA", "SLASH_", "BINDING_"])
    rep.h("globals written")
    total = 0
    for f in sorted((ROOT / "addon").rglob("*.lua")):
        out = subprocess.run([luac, "-l", "-p", str(f)], capture_output=True, text=True).stdout
        names = {}
        for line in out.splitlines():
            m = re.search(r"\[(\d+)\]\s+SETGLOBAL\s.*;\s*(\S+)", line)
            if m:
                n = m.group(2)
                names.setdefault(n, []).append(m.group(1))
        bad = {n: l for n, l in names.items() if not n.startswith(allow)}
        if bad:
            total += len(bad)
            rep.add("%s: %s" % (f.relative_to(ROOT), ", ".join("%s (line %s)" % (n, ",".join(l[:5])) for n, l in sorted(bad.items()))))
    rep.ok("%d non-prefixed globals written" % total)
    return []
