"""Completes the player race voice packs of the dub studio (tools/dub-studio/voice_db.js).

voice_db skipped every file whose top folder name belongs to two groups (gnome, troll), so those two races had
only 5 of 64 error lines and about a quarter of their vocal packs. This adds every file of the community listfile
under sound/character/<playable race>/ that is missing, into the existing group of its own sub folder
(for example Gnomevocalfemale) or into a new group named like the folder. A file counts when its id is below
600000 or it is in the sound table of the Forever client. Then the Forever marks (FV) are rebuilt.
args: build (default 1.60.1.71139)"""
import csv
import importlib.util
import io
import json
import pathlib
import re

LISTFILE = "https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv"
DB = "tools/dub-studio/voice_db.js"
RACES = ("human", "dwarf", "gnome", "nightelf", "orc", "scourge", "tauren", "troll")


def _load(name):
    p = pathlib.Path(__file__).with_name(name)
    spec = importlib.util.spec_from_file_location(name[:-3] + "_vr", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def norm(s):
    return re.sub(r"[^a-z0-9]", "", str(s or "").lower())


def run(args, rep):
    cov = _load("cmangos_cov.py")
    build = str(args.get("build") or "1.60.1.71139")
    s = open(DB, encoding="ascii").read()
    db = json.loads(s[s.index("=") + 1:s.rindex(";")])
    L, G = db["L"], db["G"]
    n0, g0 = len(L), len(G)
    have = {x[0] for x in L}
    rows = list(csv.DictReader(io.StringIO(cov._get("https://wago.tools/db2/SoundKitEntry/csv?build=%s" % build).decode("utf-8-sig", "replace"))))
    ske = set()
    for r in rows:
        try:
            ske.add(int(r["FileDataID"]))
        except (KeyError, ValueError):
            pass
    if len(ske) < 10000:
        rep.fail("the client sound table is not complete (%d files)" % len(ske))
        return []
    rep.ok("client sound files: %d" % len(ske))
    gmap = {}
    for i, g in enumerate(G):
        if g[1] == "h":
            gmap.setdefault(norm(g[0]), []).append(i)
    lf = cov._get(LISTFILE).decode("utf-8", "replace")
    added, newg, per = 0, 0, {}
    for line in lf.splitlines():
        fid, _, path = line.partition(";")
        p = path.strip().lower()
        if not p.startswith("sound/character/") or not re.search(r"\.(ogg|mp3|wav)$", p):
            continue
        parts = p.split("/")
        if len(parts) < 4 or parts[2] not in RACES:
            continue
        try:
            fid = int(fid)
        except ValueError:
            continue
        if fid in have or not (fid < 600000 or fid in ske):
            continue
        folder = parts[-2] if len(parts) >= 5 else parts[2]
        idx = gmap.get(norm(folder))
        if idx:
            gi = idx[0]
        else:
            G.append([folder[:1].upper() + folder[1:], "h"])
            gi = len(G) - 1
            gmap[norm(folder)] = [gi]
            newg += 1
        name = re.sub(r"\.(ogg|mp3|wav)$", "", parts[-1])
        L.append([fid, gi, 0, name, 1 if name.startswith("vo_") else 0])
        have.add(fid)
        added += 1
        per[G[gi][0]] = per.get(G[gi][0], 0) + 1
    rep.ok("added %d files, %d new groups" % (added, newg))
    for k, v in sorted(per.items(), key=lambda kv: -kv[1]):
        rep.add("%s: +%d" % (k, v))
    if not added:
        return []
    db["v"] = 0
    open(DB, "w", encoding="ascii", newline="\n").write("window.VO_RAW=" + json.dumps(db, ensure_ascii=True, separators=(",", ":")) + ";\n")
    vf = _load("voice_forever.py")
    out = vf.run({"build": build}, rep)
    rep.ok("database: %d lines (+%d), %d groups (+%d)" % (len(L), len(L) - n0, len(G), len(G) - g0))
    return out or [DB]
