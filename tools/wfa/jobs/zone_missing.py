"""Every area name of the game build (wow-raw AreaTable) that has no Persian in names.zone yet
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
    for r in sorted(rows, key=lambda r: int(r.get("ID") or 0)):
        en = (r.get(col) or "").strip()
        if not en:
            continue
        k = name_key(en)
        if k in seen:
            continue
        seen.add(k)
        if k in have:
            known += 1
            continue
        if JUNK.search(en) or not re.search(r"[A-Za-z]", en):
            junk += 1
            continue
        par = byid.get(str(r.get("ParentAreaID") or ""), {}).get(col, "")
        miss.append({"id": int(r.get("ID") or 0), "en": en, "key": k, "parent": par,
                     "map": maps.get(str(r.get("ContinentID") or ""), "")})
    rep.table([("distinct names", len(seen)), ("already Persian", known), ("dev/test names skipped", junk),
               ("missing", len(miss))], ["", "count"])
    for m in miss[:60]:
        rep.add("- %s (%s / %s)" % (m["en"], m["parent"], m["map"]))
    out = os.path.join(ROOT, "ci", "results", "zone-missing.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump({"build": build, "tag": tag, "rows": miss}, f, ensure_ascii=False, indent=0)
        f.write("\n")
    rep.ok("worklist: ci/results/zone-missing.json")
    return [os.path.relpath(out, ROOT)]
