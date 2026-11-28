"""Report only: every dub studio group that has lines in the Forever client, with its size and sample file names.
args: limit (samples per group, default 2)"""
import json

DB = "tools/dub-studio/voice_db.js"


def run(args, rep):
    s = open(DB, encoding="ascii").read()
    db = json.loads(s[s.index("=") + 1:s.rindex(";")])
    L, G = db["L"], db["G"]
    fv = set(db.get("FV") or [])
    n = int(args.get("limit", 2))
    by = {}
    for x in L:
        if x[0] in fv:
            by.setdefault(x[1], []).append(x[3])
    rep.ok("%d lines in %d groups, build %s" % (len(fv), len(by), db.get("FB")))
    for gi, names in sorted(by.items(), key=lambda kv: (G[kv[0]][1], -len(kv[1]), G[kv[0]][0])):
        names.sort(key=len)
        rep.add("%s [%s] %d: %s" % (G[gi][0], G[gi][1], len(names), ", ".join(names[:n])))
    return []
