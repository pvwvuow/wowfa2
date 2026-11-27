"""Where does the game use the sound files of some dub groups? (find the missing link for groups with no voice set)

args: match (list of words; every studio group whose name contains one of them), build (optional), cmangos (optional sql.gz url),
      tables (optional list of client tables to scan, default NPCSounds, CreatureSoundData, VocalUISounds)
Steps: group lines -> SoundKitEntry (kits) -> SoundKitChild (parent kits) -> every sound column of the tables above that
holds one of those kits -> displays / models / creatures that reach them.
Writes nothing, the report is the result.
"""
import gzip
import importlib.util
import io
import json
import pathlib
import re

_P = pathlib.Path(__file__).resolve().parents
ROOT = _P[3] if len(_P) > 3 else pathlib.Path.cwd()


def _mod(name):
    p = pathlib.Path(__file__).with_name(name + ".py")
    spec = importlib.util.spec_from_file_location(name + "_probe", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def _i(v):
    try:
        return int(v)
    except (TypeError, ValueError):
        return 0


def _find(cols, *pats):
    for p in pats:
        for c in cols:
            if re.fullmatch(p, c, re.I):
                return c
    return None


def run(args, rep):
    cov = _mod("cmangos_cov")
    vm = _mod("voice_map")
    words = [w.lower() for w in args.get("match", [])]
    s = (ROOT / "tools/dub-studio/voice_db.js").read_text(encoding="utf-8")
    d = json.loads(s[s.index("=") + 1:s.rindex(";")])
    G, L = d["G"], d["L"]
    gi = {i: g[0] for i, g in enumerate(G) if any(w in g[0].lower() for w in words)}
    rep.h("Studio groups")
    fids = {}
    for l in L:
        if l[1] in gi:
            fids.setdefault(gi[l[1]], []).append(l[0])
    rep.table([(n, len(fids.get(n, [])), min(fids.get(n, [0])), max(fids.get(n, [0]))) for n in sorted(gi.values())],
              ["group", "lines", "lowest file id", "highest file id"])
    sample = ["%s %s/%s" % (l[0], gi[l[1]], l[3]) for l in L if l[1] in gi][:30]
    rep.add("sample lines: " + "; ".join(sample) if gi else "no group matched")
    if not gi:
        return []
    build = str(args.get("build") or "1.15.9.70576")
    try:
        b = json.loads(cov._get("https://wago.tools/api/builds"))
        rep.h("Wago builds")
        rep.add("; ".join("%s %s" % (k, (v[0].get("version") if v else "-")) for k, v in sorted(b.items())))
    except Exception as e:  # noqa: BLE001
        rep.add("build list failed: %s" % type(e).__name__)
    ske = vm._csv(cov, "SoundKitEntry", build, rep)
    if not ske:
        rep.fail("SoundKitEntry missing")
        return []
    k_kit, k_file = _find(list(ske[0]), "SoundKitID"), _find(list(ske[0]), "FileDataID")
    kits_of = {}
    for r in ske:
        kits_of.setdefault(_i(r[k_file]), set()).add(_i(r[k_kit]))
    kit_groups = {}
    rep.h("Files to kits")
    rows = []
    for n in sorted(fids):
        have = [f for f in fids[n] if f in kits_of]
        for f in have:
            for k in kits_of[f]:
                kit_groups.setdefault(k, set()).add(n)
        rows.append((n, len(fids[n]), len(have), len({k for f in have for k in kits_of[f]})))
    rep.table(rows, ["group", "files", "files found in SoundKitEntry", "kits"])
    ch = vm._csv(cov, "SoundKitChild", build, rep)
    parents = {}
    if ch:
        c_kid = _find(list(ch[0]), r"SoundKitID", r"ChildSoundKitID", r".*child.*")
        c_par = _find(list(ch[0]), r"ParentSoundKitID", r".*parent.*")
        rep.add("SoundKitChild columns: %s / %s" % (c_kid, c_par))
        if c_kid and c_par:
            for r in ch:
                parents.setdefault(_i(r[c_kid]), set()).add(_i(r[c_par]))
    direct = {k: set(v) for k, v in kit_groups.items()}
    for k, gs in list(direct.items()):
        todo, seen = [k], {k}
        while todo:
            x = todo.pop()
            for p in parents.get(x, ()):
                if p not in seen:
                    seen.add(p)
                    kit_groups.setdefault(p, set()).update(gs)
                    todo.append(p)
    rep.ok("%d direct kits, %d with the parent kits" % (len(direct), len(kit_groups)))
    tables = args.get("tables") or ["NPCSounds", "CreatureSoundData", "VocalUISounds"]
    hit_ids = {}
    for t in tables:
        rows_t = vm._csv(cov, t, build, rep)
        if not rows_t:
            continue
        cols = [c for c in rows_t[0] if c.lower() != "id" and re.search(r"sound|kit", c, re.I)]
        hits = {}
        for r in rows_t:
            for c in cols:
                k = _i(r.get(c))
                if k and k in kit_groups:
                    for g in kit_groups[k]:
                        hits.setdefault((g, c), []).append((r.get("ID"), k, "direct" if k in direct else "parent"))
        rep.h("Hits in %s" % t)
        out = []
        for (g, c), v in sorted(hits.items()):
            out.append((g, c, len(v), sum(1 for x in v if x[2] == "direct"), ",".join(str(x[0]) for x in v[:8])))
            hit_ids.setdefault((t, g), set()).update(_i(x[0]) for x in v)
        rep.table(out[:80], ["group", "column", "rows", "direct", "row ids"])
        if not out:
            rep.add("nothing in %s refers to these kits (columns scanned: %d)" % (t, len(cols)))
    rep.h("Displays")
    cdi = vm._csv(cov, "CreatureDisplayInfo", build, rep)
    cmd = vm._csv(cov, "CreatureModelData", build, rep)
    if not (cdi and cmd):
        return []
    c_id, c_mod, c_snd = _find(list(cdi[0]), "ID"), _find(list(cdi[0]), "ModelID"), _find(list(cdi[0]), "NPCSoundID")
    m_id, m_fid = _find(list(cmd[0]), "ID"), _find(list(cmd[0]), "FileDataID")
    m_sd = _find(list(cmd[0]), r".*sounddata.*")
    rep.add("columns: display %s/%s/%s, model %s/%s/%s" % (c_id, c_mod, c_snd, m_id, m_fid, m_sd))
    fid_of = {_i(r[m_id]): _i(r[m_fid]) for r in cmd}
    summary, disp_of = [], {}
    for g in sorted(fids):
        nps = hit_ids.get(("NPCSounds", g), set())
        csd = hit_ids.get(("CreatureSoundData", g), set())
        mods = {_i(r[m_id]) for r in cmd if m_sd and _i(r[m_sd]) in csd}
        ds_n = {_i(r[c_id]) for r in cdi if c_snd and _i(r[c_snd]) in nps}
        ds_m = {_i(r[c_id]) for r in cdi if _i(r[c_mod]) in mods}
        disp_of[g] = ds_n | ds_m
        summary.append((g, len(nps), len(csd), len(mods), len(ds_n), len(ds_m), ",".join(str(fid_of.get(m, 0)) for m in sorted(mods)[:6])))
    rep.table(summary, ["group", "NPCSounds sets", "CreatureSoundData rows", "models", "displays via NPC set", "displays via model sound", "model file ids"])
    url = str(args.get("cmangos") or "")
    if url and any(disp_of.values()):
        sql = gzip.GzipFile(fileobj=io.BytesIO(cov._get(url))).read().decode("utf-8", "replace")
        cols, crow = cov.parse(sql, "creature_template")
        mcols = [c for c in cols if re.fullmatch(r"(model|display)_?id_?\d", c)]
        rep.h("Creatures")
        for g in sorted(fids):
            ds = disp_of.get(g, set())
            names = [cov.clean(r.get("name")) + " #" + str(r.get("entry")) for r in crow if any(_i(r.get(c)) in ds for c in mcols)]
            rep.add("%s: %d creatures, e.g. %s" % (g, len(names), "; ".join(names[:12])))
    return []
