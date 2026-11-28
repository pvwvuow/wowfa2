"""Report only: all player race voice files of the community listfile (sound/character/<race folder>/...),
compared with the dub studio database and with the Forever client sound tables.
args: build (default 1.60.1.71139), words (folder words), limit (sample names per folder)"""
import csv
import importlib.util
import io
import json
import pathlib
import re

LISTFILE = "https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv"
DB = "tools/dub-studio/voice_db.js"


def _cov():
    p = pathlib.Path(__file__).with_name("cmangos_cov.py")
    spec = importlib.util.spec_from_file_location("cmangos_cov_rl", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def run(args, rep):
    cov = _cov()
    build = str(args.get("build") or "1.60.1.71139")
    words = args.get("words") or ["human", "dwarf", "gnome", "nightelf", "orc", "scourge", "undead", "tauren", "troll"]
    n = int(args.get("limit", 4))
    s = open(DB, encoding="ascii").read()
    db = json.loads(s[s.index("=") + 1:s.rindex(";")])
    inL = {x[0]: x[1] for x in db["L"]}
    G = db["G"]
    fv = set(db.get("FV") or [])
    rows = list(csv.DictReader(io.StringIO(cov._get("https://wago.tools/db2/SoundKitEntry/csv?build=%s" % build).decode("utf-8-sig", "replace"))))
    ske = set()
    for r in rows:
        try:
            ske.add(int(r["FileDataID"]))
        except (KeyError, ValueError):
            pass
    rep.ok("client sound files: %d, studio lines: %d, marked Forever: %d" % (len(ske), len(inL), len(fv)))
    lf = cov._get(LISTFILE).decode("utf-8", "replace")
    by = {}
    for line in lf.splitlines():
        fid, _, path = line.partition(";")
        p = path.strip().lower()
        if not p.startswith("sound/character/") or not re.search(r"\.(ogg|mp3|wav)$", p):
            continue
        parts = p.split("/")
        if len(parts) < 4:
            continue
        key = "/".join(parts[2:-1]) or parts[2]
        try:
            fid = int(fid)
        except ValueError:
            continue
        by.setdefault(key, []).append((fid, parts[-1]))
    rep.ok("%d folders under sound/character" % len(by))
    for key in sorted(by):
        if not any(w in key for w in words):
            continue
        fl = by[key]
        ids = [f for f, _ in fl]
        have = [f for f in ids if f in inL]
        notin = [(f, nm) for f, nm in fl if f not in inL]
        inske = [f for f in ids if f in ske]
        notin_ske = [(f, nm) for f, nm in notin if f in ske]
        gs = sorted({G[inL[f]][0] for f in have})[:4]
        rep.add("%s: %d files, ids %d..%d, in studio %d (groups %s), in client %d, NOT in studio %d (of them in client %d): %s" % (
            key, len(fl), min(ids), max(ids), len(have), "/".join(gs), len(inske), len(notin), len(notin_ske),
            ", ".join("%d %s" % (f, nm) for f, nm in (notin_ske or notin)[:n])))
    return []
