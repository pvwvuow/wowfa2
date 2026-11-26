"""Which NPC uses which voice set: creature -> display -> NPCSounds -> sound kit -> sound file.

Sources: CMaNGOS classic creature_template (entry, name, model ids) and the client tables
CreatureDisplayInfo (NPCSoundID), NPCSounds (SoundID_0..3) and SoundKitEntry (FileDataID) from wago.tools.
args: files (sound file ids we dubbed; only voice sets that contain one of them are written), build (optional)
Writes ci/work/voice/npc_voice.json: {"build", "sets": {set: [file ids]}, "npc": {entry: [name, [set, ...]]}}
"""
import csv
import importlib.util
import io
import json
import os
import pathlib
import re
import gzip


def _cov():
    p = pathlib.Path(__file__).with_name("cmangos_cov.py")
    spec = importlib.util.spec_from_file_location("cmangos_cov_v", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def _col(cols, *pats):
    for p in pats:
        for c in cols:
            if re.fullmatch(p, c, re.I):
                return c
    return None


def _csv(cov, table, build, rep):
    urls = []
    if build:
        urls.append("https://wago.tools/db2/%s/csv?build=%s" % (table, build))
    urls.append("https://wago.tools/db2/%s/csv" % table)
    for u in urls:
        try:
            body = cov._get(u).decode("utf-8-sig", "replace")
            rows = list(csv.DictReader(io.StringIO(body)))
            if rows:
                rep.ok("%s: %d rows (%s)" % (table, len(rows), "build " + build if "build=" in u else "latest retail"))
                return rows
        except Exception as e:  # noqa: BLE001 - the report must say why
            rep.add("%s: %s failed (%s)" % (table, u, type(e).__name__))
    return []


def run(args, rep):
    cov = _cov()
    want = set(int(x) for x in args.get("files", []))
    rep.h("Client build")
    build = str(args.get("build") or "")
    if not build:
        try:
            b = json.loads(cov._get("https://wago.tools/api/builds"))
            keys = sorted(b.keys())
            rep.add("products: " + ", ".join(keys))
            pick = [k for k in keys if "forever" in k] + [k for k in keys if k == "wow_classic_era"]
            for k in pick:
                lst = b.get(k) or []
                if lst:
                    build = str(lst[0].get("version") or "")
                    rep.ok("using %s %s" % (k, build))
                    break
        except Exception as e:  # noqa: BLE001
            rep.add("build list failed (%s); using latest retail tables" % type(e).__name__)
    cdi = _csv(cov, "CreatureDisplayInfo", build, rep)
    nps = _csv(cov, "NPCSounds", build, rep)
    ske = _csv(cov, "SoundKitEntry", build, rep)
    if not (cdi and nps and ske):
        rep.fail("a client table is missing")
        return []
    c_id, c_snd = _col(list(cdi[0]), "ID"), _col(list(cdi[0]), "NPCSoundID")
    n_id = _col(list(nps[0]), "ID")
    n_snd = [c for c in nps[0] if re.fullmatch(r"SoundID_?\[?\d\]?", c, re.I)]
    k_kit, k_file = _col(list(ske[0]), "SoundKitID"), _col(list(ske[0]), "FileDataID")
    rep.add("columns: display %s/%s, npcsounds %s %s, kit %s/%s" % (c_id, c_snd, n_id, n_snd, k_kit, k_file))
    if not (c_id and c_snd and n_id and n_snd and k_kit and k_file):
        rep.fail("a column was not found")
        return []
    kit_files = {}
    for r in ske:
        try:
            kit_files.setdefault(int(r[k_kit]), []).append(int(r[k_file]))
        except (TypeError, ValueError):
            pass
    set_files = {}
    for r in nps:
        files = []
        for c in n_snd:
            try:
                files += kit_files.get(int(r[c] or 0), [])
            except ValueError:
                pass
        if files:
            set_files[int(r[n_id])] = sorted(set(files))
    disp_set = {}
    for r in cdi:
        try:
            s = int(r[c_snd] or 0)
        except ValueError:
            continue
        if s:
            disp_set[int(r[c_id])] = s
    rep.ok("%d voice sets with files, %d displays with a voice set" % (len(set_files), len(disp_set)))
    keep = {s for s, fs in set_files.items() if want & set(fs)} if want else set(set_files)
    rep.ok("voice sets holding a dubbed file: %d" % len(keep))

    rep.h("Creatures")
    import urllib.request  # noqa: F401 - cov._get uses it
    try:
        lst = json.loads(cov._get(cov.API))
        gz = [x for x in lst if x.get("name", "").endswith(".sql.gz")]
        url = sorted(gz, key=lambda x: x["name"])[-1]["download_url"]
        sql = gzip.GzipFile(fileobj=io.BytesIO(cov._get(url))).read().decode("utf-8", "replace")
    except Exception as e:  # noqa: BLE001
        rep.fail("cannot read the CMaNGOS dump: %s" % e)
        return []
    cols, rows = cov.parse(sql, "creature_template")
    mcols = [c for c in cols if re.fullmatch(r"(model|display)_?id_?\d", c)]
    rep.ok("creature_template %d rows, model columns %s" % (len(rows), mcols))
    npc, multi, none = {}, 0, 0
    for r in rows:
        sets = []
        for c in mcols:
            try:
                s = disp_set.get(int(r.get(c) or 0))
            except ValueError:
                s = None
            if s and s not in sets:
                sets.append(s)
        if not sets:
            none += 1
            continue
        if len(sets) > 1:
            multi += 1
        if keep & set(sets):
            npc[r.get("entry")] = [cov.clean(r.get("name")), sets]
    rep.ok("%d creatures with a voice set (%d with more than one model voice, %d without any); %d use a dubbed set"
           % (len(rows) - none, multi, none, len(npc)))
    out = {"build": build or "retail", "sets": {str(s): set_files[s] for s in sorted(keep)}, "npc": npc}
    os.makedirs("ci/work/voice", exist_ok=True)
    with open("ci/work/voice/npc_voice.json", "w", encoding="utf-8", newline="\n") as fh:
        json.dump(out, fh, ensure_ascii=False, separators=(",", ":"), sort_keys=True)
        fh.write("\n")
    by = {}
    for e, (n, ss) in npc.items():
        for s in ss:
            if s in keep:
                by.setdefault(s, []).append(n)
    rep.table([(s, len(set_files[s]), len(by.get(s, [])), "; ".join(sorted(set(by.get(s, [])))[:12])) for s in sorted(keep)],
              ["set", "files", "creatures", "examples"])
    return ["ci/work/voice/npc_voice.json"]
