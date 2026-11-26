"""Print every line of some groups of the dub studio database (what the studio lists for them).

args: groups (list of group names)
"""
import json
import pathlib

_P = pathlib.Path(__file__).resolve().parents
ROOT = _P[3] if len(_P) > 3 else pathlib.Path.cwd()


def run(args, rep):
    s = (ROOT / "tools/dub-studio/voice_db.js").read_text(encoding="utf-8")
    d = json.loads(s[s.index("=") + 1:s.rindex(";")])
    cats = ["greeting", "farewell", "pissed", "aggro", "speech"]
    G, L, T = d["G"], d["L"], d.get("T", {})
    rep.h("Groups")
    for name in args.get("groups", []):
        gi = [i for i, g in enumerate(G) if g[0] == name]
        rep.add("%s: group index %s" % (name, gi))
        rows = []
        for l in L:
            if l[1] in gi:
                t = T.get(str(l[0])) or ["", ""]
                rows.append((l[0], cats[l[2]], l[3], l[6], (t[0] or "")[:50]))
        rows.sort(key=lambda r: (r[1], r[2]))
        rep.table(rows, ["file id", "category", "name", "era", "text"])
    return []
