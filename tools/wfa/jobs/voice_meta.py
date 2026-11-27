"""Where and for whom a voice group is used (dub studio filters: dungeon / open world, Alliance / Horde).

For every group of tools/dub-studio/voice_db.js that has creatures (field C) this reads the CMaNGOS dump:
creature_template (faction template) + creature (map of every spawn) + the client tables Map and
FactionTemplate (wago.tools), and writes ci/data/vo_meta.json and the field M of voice_db.js:
  M = {raw group: {"f": "A" Alliance | "H" Horde | "B" both | "N" neutral/hostile, "p": "d" dungeon or raid |
                   "w" open world | "b" both, "m": [map names, most spawns first], "n": spawns counted}}
Groups without creatures (generic player-race voices) get Alliance / Horde from the race in the name.
args: cmangos (url of the .sql.gz), build (optional)
"""
import csv
import gzip
import importlib.util
import io
import json
import os
import pathlib
import re

from wfa.core import name_key
from wfa.store import Store

DB = "tools/dub-studio/voice_db.js"
OUT = "ci/data/vo_meta.json"
ALLIANCE_RACE = ("human", "dwarf", "nightelf", "gnome", "draenei", "worgen", "kultiran", "lightforged", "voidelf", "mechagnome", "darkirondwarf")
HORDE_RACE = ("orc", "undead", "scourge", "forsaken", "tauren", "troll", "bloodelf", "goblin", "nightborne", "magharorc", "zandalari", "vulpera")
# reputation factions (FactionTemplate.Faction) that are one side whatever the group bits say
A_REP = {72, 47, 69, 54, 930, 469, 730, 890, 509, 1037, 1050, 1068}
H_REP = {76, 81, 68, 530, 911, 67, 729, 889, 510, 1052, 1067}


def _cov():
    p = pathlib.Path(__file__).with_name("cmangos_cov.py")
    spec = importlib.util.spec_from_file_location("cmangos_cov_meta", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def _int(v):
    try:
        return int(v or 0)
    except (TypeError, ValueError):
        return 0


def _col(cols, *pats):
    for p in pats:
        for c in cols:
            if re.fullmatch(p, c, re.I):
                return c
    return None


def _csv(cov, table, builds, rep):
    for b in builds + [""]:
        u = "https://wago.tools/db2/%s/csv" % table + ("?build=%s" % b if b else "")
        try:
            rows = list(csv.DictReader(io.StringIO(cov._get(u).decode("utf-8-sig", "replace"))))
            if rows:
                rep.ok("%s: %d rows (%s)" % (table, len(rows), b or "latest retail"))
                return rows
        except Exception as e:  # noqa: BLE001
            rep.add("%s %s: %s" % (table, b or "retail", type(e).__name__))
    return []


def side_of_race(name):
    n = re.sub(r"[^a-z]", "", name.lower())
    for r in ALLIANCE_RACE:
        if n.startswith(r):
            return "A"
    for r in HORDE_RACE:
        if n.startswith(r):
            return "H"
    return ""


def side_of_group(a, h, n):
    if a and not h:
        return "A"
    if h and not a:
        return "H"
    if a and h:
        if a >= 4 * h:
            return "A"
        if h >= 4 * a:
            return "H"
        return "B"
    return "N" if n else ""


def run(args, rep):
    cov = _cov()
    store = Store.load()
    s = open(DB, encoding="ascii").read()
    db = json.loads(s[s.index("=") + 1:s.rindex(";")])
    G, C = db["G"], db.get("C", {})
    rep.h("Database")
    rep.ok("%d groups, %d with creatures" % (len(G), len(C)))

    rep.h("Client tables")
    builds = []
    if args.get("build"):
        builds.append(str(args["build"]))
    try:
        b = json.loads(cov._get("https://wago.tools/api/builds"))
        for k in ("wow_classic_era", "wowf"):
            if b.get(k):
                builds.append(str(b[k][0].get("version") or ""))
    except Exception as e:  # noqa: BLE001
        rep.add("build list failed (%s)" % type(e).__name__)
    builds = [x for x in builds if x]
    maps = _csv(cov, "Map", builds, rep)
    fts = _csv(cov, "FactionTemplate", builds, rep)
    if not maps or not fts:
        rep.fail("a client table is missing")
        return []
    mid, mname, mtype = _col(list(maps[0]), "ID"), _col(list(maps[0]), r"MapName_lang", r"MapName"), _col(list(maps[0]), "InstanceType")
    map_name = {_int(r[mid]): (r.get(mname) or r.get("Directory") or "").strip() for r in maps}
    map_inst = {_int(r[mid]): _int(r.get(mtype)) for r in maps}
    fid, ffac, fgrp, ffr = (_col(list(fts[0]), "ID"), _col(list(fts[0]), "Faction"),
                            _col(list(fts[0]), "FactionGroup"), _col(list(fts[0]), "FriendGroup"))
    tpl_side = {}
    for r in fts:
        g = _int(r.get(fgrp)) & 6
        rep_f = _int(r.get(ffac))
        side = ""
        if g == 2 or (g == 0 and rep_f in A_REP):
            side = "A"
        elif g == 4 or (g == 0 and rep_f in H_REP):
            side = "H"
        elif g == 6:
            side = "B"
        elif _int(r.get(fgrp)) & 8 or g == 0:
            side = "N"
        tpl_side[_int(r[fid])] = side
    rep.ok("%d maps, %d faction templates" % (len(map_name), len(tpl_side)))

    rep.h("CMaNGOS")
    try:
        url = str(args.get("cmangos") or "")
        sql = gzip.GzipFile(fileobj=io.BytesIO(cov._get(url))).read().decode("utf-8", "replace")
    except Exception as e:  # noqa: BLE001
        rep.fail("cannot read the CMaNGOS dump: %s" % e)
        return []
    tcols, trows = cov.parse(sql, "creature_template")
    fa_col, fh_col = _col(tcols, r"faction_?a(lliance)?"), _col(tcols, r"faction_?h(orde)?")
    one = _col(tcols, r"faction")
    rep.add("faction columns: %s %s %s" % (fa_col, fh_col, one))
    tpl_of = {}
    for r in trows:
        e = _int(r.get("entry"))
        a = _int(r.get(fa_col)) if fa_col else _int(r.get(one)) if one else 0
        h = _int(r.get(fh_col)) if fh_col else a
        tpl_of[e] = (a, h)
    ccols, crows = cov.parse(sql, "creature")
    idc, mapc = _col(ccols, "id", "entry"), _col(ccols, "map")
    rep.ok("creature_template %d rows, creature (spawns) %d rows, columns %s %s" % (len(trows), len(crows), idc, mapc))
    spawns = {}
    for r in crows:
        e, m = _int(r.get(idc)), _int(r.get(mapc))
        d = spawns.setdefault(e, {})
        d[m] = d.get(m, 0) + 1
    del crows

    rep.h("Groups")
    M = {}
    fa_zone = store.names.get("zone", {})
    for gk, creatures in C.items():
        a = h = n = 0
        w = i = 0
        by_map = {}
        for c in creatures:
            e = c[0]
            sa, sh = tpl_of.get(e, (0, 0))
            sides = {tpl_side.get(sa, ""), tpl_side.get(sh, "")} - {""}
            if "A" in sides and "H" not in sides:
                a += 1
            elif "H" in sides and "A" not in sides:
                h += 1
            elif sides:
                n += 1
            for m, k in spawns.get(e, {}).items():
                by_map[m] = by_map.get(m, 0) + k
                if map_inst.get(m, 0) == 0:
                    w += k
                else:
                    i += k
        tot = w + i
        side = side_of_group(a, h, n)
        gname = G[int(gk)][0] if int(gk) < len(G) else ""
        if not side or side == "N":
            rs = side_of_race(gname)
            if rs:
                side = rs
        if not tot:
            p = ""
        elif i and w:
            p = "b" if min(i, w) * 10 >= tot else ("d" if i > w else "w")
        else:
            p = "d" if i else "w"
        top = sorted(by_map.items(), key=lambda kv: -kv[1])[:3]
        names = []
        for m, k in top:
            en = map_name.get(m, "")
            if en:
                v = fa_zone.get(name_key(en))
                v = v if isinstance(v, str) else (v.get("fa") if isinstance(v, dict) else None)
                names.append(v or en)
        M[gk] = {"f": side, "p": p, "m": names, "n": tot}
    for gi, g in enumerate(G):
        if str(gi) not in M:
            rs = side_of_race(g[0])
            if rs:
                M[str(gi)] = {"f": rs, "p": "", "m": [], "n": 0}
    cnt = {}
    for v in M.values():
        cnt[(v["f"], v["p"])] = cnt.get((v["f"], v["p"]), 0) + 1
    rep.table(sorted(([k[0] or "?", k[1] or "?", v] for k, v in cnt.items())), ["side", "place", "groups"])
    rep.ok("%d groups classified of %d" % (len(M), len(G)))
    os.makedirs("ci/data", exist_ok=True)
    open(OUT, "w", encoding="ascii", newline="\n").write(json.dumps(M, ensure_ascii=True, separators=(",", ":"), sort_keys=True) + "\n")
    db["M"] = M
    db["v"] = 0
    body = json.dumps(db, ensure_ascii=True, separators=(",", ":"))
    import hashlib
    db["v"] = int(hashlib.sha1(body.encode()).hexdigest()[:8], 16)
    open(DB, "w", encoding="ascii", newline="\n").write("window.VO_RAW=" + json.dumps(db, ensure_ascii=True, separators=(",", ":")) + ";\n")
    rep.ok("%s: field M written" % DB)
    return [OUT, DB]
