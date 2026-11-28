"""Report only: what the WoW Forever client really has (builds, playable races, maps, voice tables).
Answers: which voice lines can Forever use at all (dub studio filter).
args: build (optional, e.g. 1.60.1.71139)"""
import csv
import importlib.util
import io
import json
import pathlib
import re
from collections import Counter


def _cov():
    p = pathlib.Path(__file__).with_name("cmangos_cov.py")
    spec = importlib.util.spec_from_file_location("cmangos_cov_probe", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def _rows(cov, table, build, rep):
    u = "https://wago.tools/db2/%s/csv" % table + ("?build=%s" % build if build else "")
    try:
        rows = list(csv.DictReader(io.StringIO(cov._get(u).decode("utf-8-sig", "replace"))))
        rep.ok("%s (%s): %d rows" % (table, build or "latest", len(rows)))
        return rows
    except Exception as e:  # noqa: BLE001
        rep.add("%s (%s): %s" % (table, build or "latest", type(e).__name__))
        return []


def run(args, rep):
    cov = _cov()
    rep.h("Builds")
    cand = []
    try:
        b = json.loads(cov._get("https://wago.tools/api/builds"))
        for k, v in b.items():
            if isinstance(v, list) and v:
                vs = [str(x.get("version")) for x in v[:3]]
                rep.add("%s: %s" % (k, ", ".join(vs)))
                for x in v:
                    s = str(x.get("version"))
                    if s.startswith("1.60") and s not in cand:
                        cand.append(s)
    except Exception as e:  # noqa: BLE001
        rep.add("builds: %s" % type(e).__name__)
    rep.add("builds that start with 1.60: %s" % cand[:8])
    build = str(args.get("build") or (cand[0] if cand else ""))
    rep.h("Races and maps of %s" % (build or "latest"))
    races = _rows(cov, "ChrRaces", build, rep)
    if races:
        cols = list(races[0])
        rep.add("ChrRaces columns: %s" % ", ".join(cols[:30]))
        nm = [c for c in cols if re.fullmatch(r"(Name_lang|Name|ClientFileString|ClientPrefix)", c)]
        fl = [c for c in cols if re.fullmatch(r"(Flags|ID|Alliance|Faction.*|BaseLanguage)", c)]
        for r in races[:60]:
            rep.add("race " + " | ".join("%s=%s" % (c, r.get(c)) for c in fl + nm))
    maps = _rows(cov, "Map", build, rep)
    if maps:
        cols = list(maps[0])
        ex = [c for c in cols if re.fullmatch(r"ExpansionID", c)]
        ty = [c for c in cols if re.fullmatch(r"InstanceType", c)]
        rep.add("Map columns: %s" % ", ".join(cols[:30]))
        if ex:
            rep.add("maps per expansion: %s" % dict(Counter(r.get(ex[0]) for r in maps)))
        if ty:
            rep.add("maps per instance type: %s" % dict(Counter(r.get(ty[0]) for r in maps)))
        names = [c for c in cols if re.fullmatch(r"MapName_lang|MapName", c)]
        if names:
            for r in maps:
                if (r.get("ID") or "") in {"0", "1", "530", "571", "870", "2222", "36", "33", "34", "43", "47", "70", "109", "129", "189", "209", "229", "230", "249", "289", "309", "329", "349", "369", "389", "409", "429", "469", "509", "531", "533", "532", "540", "542", "544", "545", "550", "555", "560", "564", "565", "574", "575", "576", "585", "595", "598"}:
                    rep.add("map %s %s exp=%s type=%s" % (r.get("ID"), r.get(names[0]), r.get(ex[0]) if ex else "?", r.get(ty[0]) if ty else "?"))
    rep.h("Voice tables of %s" % (build or "latest"))
    cdi = _rows(cov, "CreatureDisplayInfo", build, rep)
    nps = _rows(cov, "NPCSounds", build, rep)
    ske = _rows(cov, "SoundKitEntry", build, rep)
    if cdi:
        c = [x for x in cdi[0] if re.fullmatch(r"NPCSoundID", x, re.I)]
        rep.add("displays with a voice set: %d" % sum(1 for r in cdi if c and (r.get(c[0]) or "0") != "0"))
    if ske:
        f = [x for x in ske[0] if re.fullmatch(r"FileDataID", x, re.I)]
        rep.add("distinct sound files in SoundKitEntry: %d" % len({r[f[0]] for r in ske if f and r.get(f[0])}))
    ske_latest = _rows(cov, "SoundKitEntry", "", rep)
    if ske_latest and ske:
        f = [x for x in ske[0] if re.fullmatch(r"FileDataID", x, re.I)][0]
        a = {r[f] for r in ske if r.get(f)}
        b2 = {r[f] for r in ske_latest if r.get(f)}
        rep.add("files in the Forever build: %d; in latest retail: %d; only retail: %d" % (len(a), len(b2), len(b2 - a)))
    return []
