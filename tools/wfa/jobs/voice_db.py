"""Full NPC voice database for the dub studio (tools/dub-studio/voice_db.js).

Base: the owner's voice list (ci/data/vo_raw.json: L = [file id, group, cat, name, vo], G = [group name, kind]).
Adds, without renaming any existing group or line (old recordings keep their folders):
  - sound files the list missed: community listfile (sound/creature, sound/character), old files (id < 600000)
    and every file the client tables use for NPC voices or broadcast texts
  - T: spoken English text of a file (BroadcastText -> SoundKit -> file) and its Persian row from data/tpl
  - C: creatures that use a group (creature -> display -> NPCSounds -> files, or the same name), Persian name, display
  - thumb: a working Wowhead model thumbnail url template ({m} = display & 255, {d} = display)
args: url + sha256 (optional: zip holding vo_raw.json, written to ci/data/vo_raw.json), build (optional)
"""
import csv
import gzip
import hashlib
import importlib.util
import io
import json
import os
import pathlib
import re
import zipfile

from wfa.core import name_key, num_key
from wfa.store import Store

LISTFILE = "https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv"
THUMBS = [
    "https://wow.zamimg.com/modelviewer/classic/webthumbs/npc/{m}/{d}.webp",
    "https://wow.zamimg.com/modelviewer/classic/webthumbs/npc/{m}/{d}.png",
    "https://wow.zamimg.com/modelviewer/live/webthumbs/npc/{m}/{d}.webp",
    "https://wow.zamimg.com/modelviewer/live/webthumbs/npc/{m}/{d}.png",
]


def _cov():
    p = pathlib.Path(__file__).with_name("cmangos_cov.py")
    spec = importlib.util.spec_from_file_location("cmangos_cov_db", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def norm(s):
    return re.sub(r"[^a-z0-9]", "", str(s or "").lower())


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
        except Exception as e:  # noqa: BLE001 - the report must say why
            rep.add("%s %s: %s" % (table, b or "retail", type(e).__name__))
    return []


def _int(v):
    try:
        return int(v or 0)
    except (TypeError, ValueError):
        return 0


def _fa_name(v):
    if isinstance(v, str):
        return v
    if isinstance(v, dict):
        for k in ("fa", "t", "name"):
            if isinstance(v.get(k), str):
                return v[k]
    if isinstance(v, (list, tuple)) and v and isinstance(v[0], str):
        return v[0]
    return ""


def run(args, rep):
    cov = _cov()
    store = Store.load()
    rep.h("Base list")
    raw_path = "ci/data/vo_raw.json"
    changed = []
    if args.get("url"):
        try:
            body = cov._get(str(args["url"]))
        except Exception as e:  # noqa: BLE001
            rep.fail("download failed: %s" % type(e).__name__)
            return []
        if hashlib.sha256(body).hexdigest() != str(args.get("sha256", "")).lower():
            rep.fail("sha256 differs")
            return []
        data = zipfile.ZipFile(io.BytesIO(body)).read("vo_raw.json")
        json.loads(data)
        os.makedirs("ci/data", exist_ok=True)
        open(raw_path, "wb").write(data)
        changed.append(raw_path)
    raw = json.load(open(raw_path, encoding="utf-8"))
    L, G = raw["L"], raw["G"]
    n0, g0 = len(L), len(G)
    rep.ok("%d files in %d groups" % (n0, g0))

    rep.h("Client tables")
    builds = []
    if args.get("build"):
        builds.append(str(args["build"]))
    try:
        b = json.loads(cov._get("https://wago.tools/api/builds"))
        for k in ("wowf", "wow_classic_era"):
            if b.get(k):
                builds.append(str(b[k][0].get("version") or ""))
                rep.add("%s: %s" % (k, b[k][0].get("version")))
    except Exception as e:  # noqa: BLE001
        rep.add("build list failed (%s)" % type(e).__name__)
    builds = [x for x in builds if x]
    cdi = _csv(cov, "CreatureDisplayInfo", builds, rep)
    nps = _csv(cov, "NPCSounds", builds, rep)
    ske = _csv(cov, "SoundKitEntry", builds, rep)
    bct = []
    for bb in [x for x in builds if not x.startswith("1.60")] + [""]:
        part = _csv(cov, "BroadcastText", [bb] if bb else [], rep) if bb else _csv(cov, "BroadcastText", [], rep)
        bct += part
    if not (cdi and nps and ske):
        rep.fail("a client table is missing")
        return changed
    kit_files = {}
    kc, fc = _col(list(ske[0]), "SoundKitID"), _col(list(ske[0]), "FileDataID")
    for r in ske:
        if _int(r[kc]) and _int(r[fc]):
            kit_files.setdefault(_int(r[kc]), []).append(_int(r[fc]))
    ncols = [c for c in nps[0] if re.fullmatch(r"SoundID_?\[?\d\]?", c, re.I)]
    nid = _col(list(nps[0]), "ID")
    set_files = {}
    for r in nps:
        fs = []
        for c in ncols:
            fs += kit_files.get(_int(r[c]), [])
        if fs:
            set_files[_int(r[nid])] = sorted(set(fs))
    did, dsnd = _col(list(cdi[0]), "ID"), _col(list(cdi[0]), "NPCSoundID")
    disp_set = {_int(r[did]): _int(r[dsnd]) for r in cdi if _int(r[dsnd])}
    text_of = {}
    if bct:
        bc = list(bct[0])
        t0, t1 = _col(bc, r"Text_lang", r"Text"), _col(bc, r"Text1_lang", r"Text1")
        kcols = [c for c in bc if re.fullmatch(r"SoundKitID_?\[?\d\]?", c, re.I)]
        rep.add("broadcast columns: %s %s %s" % (t0, t1, kcols))
        for r in bct:
            en = (r.get(t0) or "").strip() if t0 else ""
            en1 = (r.get(t1) or "").strip() if t1 else ""
            for c in kcols:
                for f in kit_files.get(_int(r[c]), []):
                    text_of.setdefault(f, (en, en1))
    sql = ""
    try:
        url = str(args.get("cmangos") or "")
        if not url:
            lst = json.loads(cov._get(cov.API))
            gz = [x for x in lst if x.get("name", "").endswith(".sql.gz")]
            url = sorted(gz, key=lambda x: x["name"])[-1]["download_url"]
        sql = gzip.GzipFile(fileobj=io.BytesIO(cov._get(url))).read().decode("utf-8", "replace")
    except Exception as e:  # noqa: BLE001
        rep.fail("cannot read the CMaNGOS dump: %s" % e)
    nb = len(text_of)
    for table in ("script_texts", "creature_ai_texts", "dbscript_string", "custom_texts", "broadcast_text"):
        cols, rs = cov.parse(sql, table) if sql else ([], [])
        scol = [c for c in cols if re.fullmatch(r"sound(id|entriesid)?_?\d?", c)]
        tcol = _col(cols, r"content_default", r"maletext", r"text")
        fcol = _col(cols, r"femaletext", r"text1")
        if not (scol and tcol):
            if cols:
                rep.add("%s: no sound/text column (%s)" % (table, ", ".join(cols[:12])))
            continue
        k = 0
        for r in rs:
            en, en1 = cov.clean(r.get(tcol)), cov.clean(r.get(fcol)) if fcol else ""
            for c in scol:
                for f in kit_files.get(_int(r.get(c)), []):
                    if f not in text_of and (en or en1):
                        text_of[f] = (en, en1)
                        k += 1
        rep.add("%s: %d sound files got a text (columns %s / %s)" % (table, k, scol, tcol))
    rep.ok("texts: %d from BroadcastText, %d from CMaNGOS" % (nb, len(text_of) - nb))
    table_files = set(f for fs in set_files.values() for f in fs) | set(text_of)
    rep.ok("%d voice sets, %d displays with a voice, %d files with a spoken text" % (len(set_files), len(disp_set), len(text_of)))

    rep.h("Missing files (listfile)")
    have = {x[0] for x in L}
    gmap = {}
    for i, g in enumerate(G):
        gmap.setdefault(norm(g[0]), []).append(i)
    added, skipped_dup, new_groups = 0, 0, 0
    try:
        lf = cov._get(LISTFILE).decode("utf-8", "replace")
    except Exception as e:  # noqa: BLE001
        rep.fail("listfile download failed: %s" % type(e).__name__)
        lf = ""
    for line in lf.splitlines():
        fid, _, path = line.partition(";")
        p = path.strip().lower()
        if not (p.startswith("sound/creature/") or p.startswith("sound/character/")):
            continue
        if not re.search(r"\.(ogg|mp3|wav)$", p):
            continue
        fid = _int(fid)
        if not fid or fid in have or not (fid < 600000 or fid in table_files):
            continue
        parts = p.split("/")
        if len(parts) < 4:
            continue
        folder = parts[2]
        idx = gmap.get(norm(folder))
        if idx and len(idx) > 1:
            skipped_dup += 1
            continue
        if idx:
            gi = idx[0]
        else:
            G.append([folder[:1].upper() + folder[1:], "h" if parts[1] == "character" else "c"])
            gi = len(G) - 1
            gmap[norm(folder)] = [gi]
            new_groups += 1
        name = re.sub(r"\.(ogg|mp3|wav)$", "", parts[-1])
        L.append([fid, gi, 0, name, 1 if name.startswith("vo_") else 0])
        have.add(fid)
        added += 1
    rep.ok("added %d files (%d new groups); %d skipped because their folder name is shared by two groups" % (added, new_groups, skipped_dup))

    rep.h("Texts")
    T = {}
    with_fa = 0
    for x in L:
        t = text_of.get(x[0])
        if not t:
            continue
        en = t[1] if t[1] and "female" in x[3] else (t[0] or t[1])
        en = re.sub(r"\s+", " ", en).strip()
        if not en:
            continue
        fa = store.tpl.get(num_key(en)[0], "") or ""
        with_fa += 1 if fa else 0
        T[str(x[0])] = [en, fa]
    rep.ok("%d files have their spoken text, %d with Persian" % (len(T), with_fa))

    rep.h("Creatures")
    group_of = {x[0]: x[1] for x in L}
    C = {}
    cols, rows = cov.parse(sql, "creature_template") if sql else ([], [])
    mcols = [c for c in cols if re.fullmatch(r"(model|display)_?id_?\d", c)]
    npc_fa = store.names.get("npc", {})
    boss_fa = store.names.get("boss", {})
    by_name = {}
    for i, g in enumerate(G):
        by_name.setdefault(norm(re.sub(r"\s*\(.*\)\s*$", "", g[0])), []).append(i)
    linked = 0
    for r in rows:
        en = cov.clean(r.get("name"))
        if not en:
            continue
        k = name_key(en)
        fa = _fa_name(npc_fa.get(k)) or _fa_name(boss_fa.get(k))
        disp = [_int(r.get(c)) for c in mcols if _int(r.get(c))]
        gs = []
        for d in disp:
            for f in set_files.get(disp_set.get(d, 0), []):
                gi = group_of.get(f)
                if gi is not None and gi not in gs:
                    gs.append(gi)
        for gi in by_name.get(norm(en), []):
            if gi not in gs:
                gs.append(gi)
        for gi in gs:
            lst2 = C.setdefault(str(gi), [])
            if len(lst2) < 40:
                lst2.append([_int(r.get("entry")), en, fa, disp[0] if disp else 0])
        linked += 1 if gs else 0
    rep.ok("%d creatures linked to %d groups" % (linked, len(C)))

    rep.h("Thumbnails")
    thumb = ""
    probe = [c[3] for v in C.values() for c in v if c[3]][:6]
    for tpl in THUMBS:
        okn = 0
        for d in probe:
            try:
                b = cov._get(tpl.format(m=d & 255, d=d))
                if len(b) > 200:
                    okn += 1
            except Exception:  # noqa: BLE001
                pass
        rep.add("%s: %d of %d" % (tpl, okn, len(probe)))
        if okn and not thumb:
            thumb = tpl
    rep.ok("thumbnail url: %s" % (thumb or "none worked"))

    out = {"v": 0, "build": builds[0] if builds else "retail", "L": L, "G": G, "T": T, "C": C, "thumb": thumb}
    body = json.dumps(out, ensure_ascii=True, separators=(",", ":"))
    out["v"] = int(hashlib.sha1(body.encode()).hexdigest()[:8], 16)
    js = "window.VO_RAW=" + json.dumps(out, ensure_ascii=True, separators=(",", ":")) + ";\n"
    p = "tools/dub-studio/voice_db.js"
    open(p, "w", encoding="ascii", newline="\n").write(js)
    rep.h("Result")
    rep.ok("%s: %d bytes, %d files (+%d), %d groups (+%d), %d texts, %d groups with creatures" %
           (p, len(js), len(L), len(L) - n0, len(G), len(G) - g0, len(T), len(C)))
    return changed + [p]
