"""Every area name of the game build (wow-raw AreaTable + AreaPOI, and WMOAreaTable = the indoor names
like "Darkshire Town Hall", straight from wago.tools when the archive lacks it) that has no Persian in names.zone yet
(owner, 25 Nov 2026: "Darkshire Town Hall", "Scarlet Raven Tavern" showed up English; translate
everything that is missing). Report + worklist only, nothing in data/ changes.
args: {"build": "1.60.1.71091"}  -> ci/results/zone-missing.json  [{id, en, key, parent, map}]"""
import csv
import io
import json
import os
import re
import subprocess
import tempfile
import urllib.request
import zipfile

from wfa.core import name_key
from wfa.store import Store

RAW = "pvwvuow/wow-raw"
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
JUNK = re.compile(r"(test|unused|deprecated|\bqa\b|programmer|zzold|\bdev\b|\[|\]|copy of|placeholder|\btmp\b|do not use|reuse)", re.I)


def gh(env, *a):
    p = subprocess.run(["gh"] + list(a), env=env, text=True, capture_output=True)
    return p.returncode, (p.stdout or ""), (p.stderr or "")


def table(zf, name):
    for m in zf.namelist():
        if m.lower().endswith("/" + name.lower() + ".csv") or m.lower() == name.lower() + ".csv":
            return list(csv.DictReader(io.TextIOWrapper(zf.open(m), encoding="utf-8-sig")))
    return None


def wago(name, build):
    url = "https://wago.tools/db2/%s/csv?build=%s&locale=enUS" % (name, build)
    req = urllib.request.Request(url, headers={"User-Agent": "wowfarsi-raw/1 (+https://wowfarsi.ir)"})
    with urllib.request.urlopen(req, timeout=120) as r:
        body = r.read()
    return list(csv.DictReader(io.StringIO(body.decode("utf-8-sig", "replace"))))


def run(args, rep):
    build = str(args.get("build") or "1.60.1.71091")
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    c, o, e = gh(env, "release", "list", "--repo", RAW, "--limit", "60", "--json", "tagName,createdAt")
    if c:
        rep.fail("release list: %s" % e.strip()[:300])
        return []
    tags = [r["tagName"] for r in sorted(json.loads(o or "[]"), key=lambda r: r.get("createdAt") or "", reverse=True)
            if build in r.get("tagName", "") and "forever" in r.get("tagName", "")]
    if not tags:
        rep.fail("no wow-raw release for %s" % build)
        return []
    tag = tags[0]
    tmp = tempfile.mkdtemp()
    c, o, e = gh(env, "release", "download", tag, "--repo", RAW, "--pattern", "*.zip", "--dir", tmp)
    zips = [os.path.join(tmp, f) for f in os.listdir(tmp) if f.endswith(".zip")]
    if c or not zips:
        rep.fail("download %s: %s" % (tag, e.strip()[:300]))
        return []
    zf = zipfile.ZipFile(zips[0])
    rows = table(zf, "AreaTable")
    if not rows:
        rep.fail("AreaTable.csv not in %s (%s)" % (tag, ", ".join(zf.namelist()[:20])))
        return []
    maps = {}
    for r in table(zf, "Map") or []:
        maps[str(r.get("ID"))] = r.get("MapName_lang") or r.get("Directory") or ""
    rep.h("AreaTable of %s: %d rows, columns %s" % (tag, len(rows), ", ".join(list(rows[0].keys())[:12])))
    col = "AreaName_lang" if "AreaName_lang" in rows[0] else next((k for k in rows[0] if "AreaName" in k), None)
    if not col:
        rep.fail("no AreaName column")
        return []
    byid = {str(r.get("ID")): r for r in rows}
    have = Store.load().names.get("zone", {})
    seen, miss, junk, known = set(), [], 0, 0
    srcs = {"AreaTable": 0}

    def take(en, src, parent, mp, rid):
        nonlocal junk, known
        en = (en or "").strip()
        if not en:
            return
        k = name_key(en)
        if k in seen:
            return
        seen.add(k)
        if k in have:
            known += 1
            return
        if JUNK.search(en) or not re.search(r"[A-Za-z]", en):
            junk += 1
            return
        srcs[src] = srcs.get(src, 0) + 1
        miss.append({"id": rid, "src": src, "en": en, "key": k, "parent": parent, "map": mp})

    for r in sorted(rows, key=lambda r: int(r.get("ID") or 0)):
        par = byid.get(str(r.get("ParentAreaID") or ""), {}).get(col, "")
        take(r.get(col), "AreaTable", par, maps.get(str(r.get("ContinentID") or ""), ""), int(r.get("ID") or 0))
    wmo = table(zf, "WMOAreaTable")
    if wmo is None:
        try:
            wmo = wago("WMOAreaTable", build)
        except Exception as e:  # noqa: BLE001
            rep.fail("WMOAreaTable from wago.tools: %s" % e)
            wmo = []
    rep.ok("WMOAreaTable rows: %d" % len(wmo))
    for r in wmo:
        par = byid.get(str(r.get("AreaTableID") or ""), {}).get(col, "")
        take(r.get("AreaName_lang"), "WMOAreaTable", par, "", int(r.get("ID") or 0))
    poi = table(zf, "AreaPOI") or []
    rep.ok("AreaPOI rows: %d" % len(poi))
    for r in poi:
        par = byid.get(str(r.get("AreaID") or ""), {}).get(col, "")
        take(r.get("Name_lang"), "AreaPOI", par, maps.get(str(r.get("ContinentID") or ""), ""), int(r.get("ID") or 0))
    rep.ok("missing per source: %s" % json.dumps(srcs))
    rep.table([("distinct names", len(seen)), ("already Persian", known), ("dev/test names skipped", junk),
               ("missing", len(miss))], ["", "count"])
    for m in miss[:400]:
        rep.add("- %s [%s] (%s / %s)" % (m["en"], m["src"], m["parent"], m["map"]))
    out = os.path.join(ROOT, "ci", "results", "zone-missing.json")
    with open(out, "w", encoding="utf-8") as f:
        f.write('{"build": %s, "tag": %s, "rows": [\n' % (json.dumps(build), json.dumps(tag)))
        f.write(",\n".join(json.dumps(m, ensure_ascii=False) for m in miss))
        f.write("\n]}\n")
    rep.ok("worklist: ci/results/zone-missing.json")
    return [os.path.relpath(out, ROOT)]
