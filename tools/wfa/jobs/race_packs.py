"""Report only: the player race voice packs of the dub studio. Every group of kind h whose name holds a race word:
lines in the database, lines in the Forever client, sample file names.
args: words (race words, lowercase), limit (samples)"""
import json

DB = "tools/dub-studio/voice_db.js"


def run(args, rep):
    s = open(DB, encoding="ascii").read()
    db = json.loads(s[s.index("=") + 1:s.rindex(";")])
    L, G = db["L"], db["G"]
    fv = set(db.get("FV") or [])
    words = args.get("words") or ["human", "dwarf", "gnome", "nightelf", "orc", "scourge", "undead", "tauren", "troll"]
    n = int(args.get("limit", 3))
    tot, inf, names = {}, {}, {}
    for x in L:
        gi = x[1]
        tot[gi] = tot.get(gi, 0) + 1
        if x[0] in fv:
            inf[gi] = inf.get(gi, 0) + 1
        names.setdefault(gi, [])
        if len(names[gi]) < 40:
            names[gi].append(x[3])
    rep.ok("%d groups, %d lines" % (len(G), len(L)))
    for gi, g in enumerate(G):
        low = g[0].lower()
        if not any(w in low for w in words):
            continue
        if g[1] != "h" and tot.get(gi, 0) < 20:
            continue
        nm = sorted(names.get(gi, []), key=len)
        rep.add("%s [%s race=%s] total %d, forever %d: %s" % (g[0], g[1], g[3] if len(g) > 3 else "", tot.get(gi, 0), inf.get(gi, 0), ", ".join(nm[:n])))
    return []
