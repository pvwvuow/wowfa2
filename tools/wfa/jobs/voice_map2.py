"""Which voice set AND which model file each creature really uses (for the in-game voice test addon).

creature_template (CMaNGOS) -> model ids -> CreatureDisplayInfo (NPCSoundID, ModelID) -> CreatureModelData (FileDataID).
The addon asks the game for the NPC's model file id, so a creature with several models (a dwarf and a human
version, say) gets the voice that matches the model it really shows, and an NPC missing from CMaNGOS still gets a
dwarf voice when its model is a dwarf model.

args: files (sound file ids that are dubbed; only voice sets holding one of them are kept), cmangos (url of the sql.gz), build (optional)
Writes ci/work/voice/addon_map.json:
  {"build", "sets": {set: [file ids]}, "models": {model file id: [set, ...]}, "npc": {entry: [name, [[set, model file id], ...]]}}
"""
import csv  # noqa: F401 - voice_map reads the tables
import gzip
import importlib.util
import io
import json
import os
import pathlib
import re


def _mod(name):
    p = pathlib.Path(__file__).with_name(name + ".py")
    spec = importlib.util.spec_from_file_location(name + "_v2", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def _geti(r, c):
    try:
        return int(r.get(c) or 0)
    except (TypeError, ValueError):
        return 0


def run(args, rep):
    cov = _mod("cmangos_cov")
    vm = _mod("voice_map")
    want = set(int(x) for x in args.get("files", []))
    rep.h("Client build")
    build = str(args.get("build") or "")
    if not build:
        try:
            b = json.loads(cov._get("https://wago.tools/api/builds"))
            for k in [k for k in sorted(b) if "forever" in k] + [k for k in sorted(b) if k == "wow_classic_era"]:
                lst = b.get(k) or []
                if lst:
                    build = str(lst[0].get("version") or "")
                    rep.ok("using %s %s" % (k, build))
                    break
        except Exception as e:  # noqa: BLE001
            rep.add("build list failed (%s); using latest tables" % type(e).__name__)
    cdi = vm._csv(cov, "CreatureDisplayInfo", build, rep)
    cmd = vm._csv(cov, "CreatureModelData", build, rep)
    nps = vm._csv(cov, "NPCSounds", build, rep)
    ske = vm._csv(cov, "SoundKitEntry", build, rep)
    if not (cdi and cmd and nps and ske):
        rep.fail("a client table is missing")
        return []
    c_id, c_snd, c_mod = vm._col(list(cdi[0]), "ID"), vm._col(list(cdi[0]), "NPCSoundID"), vm._col(list(cdi[0]), "ModelID")
    m_id, m_fid = vm._col(list(cmd[0]), "ID"), vm._col(list(cmd[0]), "FileDataID")
    n_id = vm._col(list(nps[0]), "ID")
    n_snd = [c for c in nps[0] if re.fullmatch(r"SoundID_?\[?\d\]?", c, re.I)]
    k_kit, k_file = vm._col(list(ske[0]), "SoundKitID"), vm._col(list(ske[0]), "FileDataID")
    rep.add("columns: display %s/%s/%s, model %s/%s" % (c_id, c_snd, c_mod, m_id, m_fid))
    if not (c_id and c_snd and c_mod and m_id and m_fid and n_id and n_snd and k_kit and k_file):
        rep.fail("a column was not found")
        return []
    kit_files = {}
    for r in ske:
        kit_files.setdefault(_geti(r, k_kit), []).append(_geti(r, k_file))
    set_files = {}
    for r in nps:
        fs = []
        for c in n_snd:
            fs += kit_files.get(_geti(r, c), [])
        if fs:
            set_files[_geti(r, n_id)] = sorted(set(fs))
    keep = {s for s, fs in set_files.items() if want & set(fs)}
    model_fid = {_geti(r, m_id): _geti(r, m_fid) for r in cmd}
    disp = {}
    for r in cdi:
        s, m = _geti(r, c_snd), model_fid.get(_geti(r, c_mod), 0)
        if s:
            disp[_geti(r, c_id)] = (s, m)
    rep.ok("%d voice sets (%d hold a dubbed file), %d displays with a voice, %d model files" % (len(set_files), len(keep), len(disp), len(model_fid)))
    models = {}
    for d, (s, m) in disp.items():
        if s in keep and m:
            models.setdefault(m, set()).add(s)
    rep.ok("model files that use a dubbed voice set: %d" % len(models))

    rep.h("Creatures")
    url = str(args.get("cmangos") or "")
    try:
        if not url:
            lst = json.loads(cov._get(cov.API))
            url = sorted([x for x in lst if x.get("name", "").endswith(".sql.gz")], key=lambda x: x["name"])[-1]["download_url"]
        sql = gzip.GzipFile(fileobj=io.BytesIO(cov._get(url))).read().decode("utf-8", "replace")
    except Exception as e:  # noqa: BLE001
        rep.fail("cannot read the CMaNGOS dump: %s" % e)
        return []
    cols, rows = cov.parse(sql, "creature_template")
    mcols = [c for c in cols if re.fullmatch(r"(model|display)_?id_?\d", c)]
    npc = {}
    for r in rows:
        pairs = []
        for c in mcols:
            d = disp.get(_geti(r, c))
            if d and list(d) not in pairs:
                pairs.append(list(d))
        if any(p[0] in keep for p in pairs):
            npc[r.get("entry")] = [cov.clean(r.get("name")), pairs]
    rep.ok("%d creatures use a dubbed voice set on at least one model" % len(npc))
    out = {"build": build or "latest", "sets": {str(s): set_files[s] for s in sorted(keep)},
           "models": {str(m): sorted(ss) for m, ss in sorted(models.items())}, "npc": npc}
    os.makedirs("ci/work/voice", exist_ok=True)
    with open("ci/work/voice/addon_map.json", "w", encoding="utf-8", newline="\n") as fh:
        json.dump(out, fh, ensure_ascii=False, separators=(",", ":"), sort_keys=True)
        fh.write("\n")
    rep.table([(m, "/".join(str(x) for x in sorted(ss))) for m, ss in sorted(models.items())][:40], ["model file id", "sets"])
    return ["ci/work/voice/addon_map.json"]
