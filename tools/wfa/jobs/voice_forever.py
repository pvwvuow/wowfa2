"""Marks which voice lines the WoW Forever client really has (dub studio: only dub what Forever needs).

The Forever build's own client table SoundKitEntry (wago.tools, product wowf) lists every sound file the
client uses. A file of tools/dub-studio/voice_db.js that is in it is needed, one that is not is retail only.
Writes the field FV (sorted file ids of the database that Forever has) and FB (the build) of voice_db.js.
The studio also drops player-race voices of races that cannot be played in Forever (Blood Elf, Draenei ...).
args: build (optional, default the newest wowf build)
"""
import csv
import hashlib
import importlib.util
import io
import json
import pathlib
import re

DB = "tools/dub-studio/voice_db.js"


def _cov():
    p = pathlib.Path(__file__).with_name("cmangos_cov.py")
    spec = importlib.util.spec_from_file_location("cmangos_cov_forever", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def run(args, rep):
    cov = _cov()
    build = str(args.get("build") or "")
    if not build:
        try:
            b = json.loads(cov._get("https://wago.tools/api/builds"))
            build = str(b["wowf"][0]["version"])
        except Exception as e:  # noqa: BLE001
            rep.fail("cannot read the build list: %s" % type(e).__name__)
            return []
    rep.h("Forever build %s" % build)
    url = "https://wago.tools/db2/SoundKitEntry/csv?build=%s" % build
    try:
        rows = list(csv.DictReader(io.StringIO(cov._get(url).decode("utf-8-sig", "replace"))))
    except Exception as e:  # noqa: BLE001
        rep.fail("SoundKitEntry of %s not readable: %s" % (build, type(e).__name__))
        return []
    col = next((c for c in (rows[0] if rows else {}) if re.fullmatch(r"FileDataID", c, re.I)), None)
    if not col:
        rep.fail("no FileDataID column")
        return []
    fs = {int(r[col]) for r in rows if (r.get(col) or "0").isdigit() and int(r[col])}
    if len(fs) < 10000:
        rep.fail("only %d files in the table: not the full client list" % len(fs))
        return []
    rep.ok("%d sound files in the client of %s" % (len(fs), build))
    s = open(DB, encoding="ascii").read()
    db = json.loads(s[s.index("=") + 1:s.rindex(";")])
    L, G = db["L"], db["G"]
    fv = sorted({x[0] for x in L if x[0] in fs})
    rep.ok("%d of %d lines of the studio database are in the Forever client (%d of them with a file id below 600000)" %
           (len(fv), len(L), sum(1 for f in fv if f < 600000)))
    kind = {}
    for x in L:
        k = G[x[1]][1]
        a = kind.setdefault(k, [0, 0])
        a[0] += 1
        a[1] += 1 if x[0] in fs else 0
    for k, (n, m) in sorted(kind.items()):
        rep.add("kind %s: %d lines, %d in Forever" % (k, n, m))
    groups = {}
    for x in L:
        if x[0] in fs:
            groups[x[1]] = groups.get(x[1], 0) + 1
    rep.add("%d of %d groups keep at least one line" % (len(groups), len(G)))
    top = sorted(groups.items(), key=lambda kv: -kv[1])[:12]
    rep.add("biggest: " + "; ".join("%s %d" % (G[g][0], n) for g, n in top))
    db["FV"] = fv
    db["FB"] = build
    db["v"] = 0
    body = json.dumps(db, ensure_ascii=True, separators=(",", ":"))
    db["v"] = int(hashlib.sha1(body.encode()).hexdigest()[:8], 16)
    open(DB, "w", encoding="ascii", newline="\n").write("window.VO_RAW=" + json.dumps(db, ensure_ascii=True, separators=(",", ":")) + ";\n")
    rep.ok("%s: fields FV and FB written" % DB)
    return [DB]
