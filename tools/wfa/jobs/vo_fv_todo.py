"""Report: every distinct spoken English text of a Forever line (voice_db FV) that has no Persian yet.
Writes ci/data/vo_todo_fv.json: [[english, lines, kind, group], ...], player races first. Report only otherwise."""
import json
import re

DB = "tools/dub-studio/voice_db.js"
OUT = "ci/data/vo_todo_fv.json"


def key(s):
    return re.sub(r"[^a-z0-9'$]+", " ", str(s or "").lower()).strip()


def run(args, rep):
    s = open(DB, encoding="ascii").read()
    db = json.loads(s[s.index("=") + 1:s.rindex(";")])
    L, G, T = db["L"], db["G"], db.get("T") or {}
    fv = set(db.get("FV") or [])
    seen, nfa, nt = {}, 0, 0
    for x in L:
        if x[0] not in fv:
            continue
        v = T.get(str(x[0]))
        if not v:
            continue
        nt += 1
        if v[1]:
            nfa += 1
            continue
        k = key(v[0])
        if not k:
            continue
        g = G[x[1]]
        r = seen.setdefault(k, [v[0], 0, g[1], g[0]])
        r[1] += 1
        if g[1] == "h":
            r[2] = "h"
    rows = sorted(seen.values(), key=lambda r: (r[2] != "h", -r[1], r[0].lower()))
    open(OUT, "w", encoding="utf-8", newline="\n").write(json.dumps(rows, ensure_ascii=True, indent=0) + "\n")
    rep.ok("Forever lines with a text: %d, with Persian: %d" % (nt, nfa))
    rep.ok("%d distinct texts without Persian (%d of player races) -> %s" % (len(rows), len([r for r in rows if r[2] == "h"]), OUT))
    for r in rows[:15]:
        rep.add("- %s x%d [%s %s]" % (r[0], r[1], r[2], r[3]))
    return [OUT]
