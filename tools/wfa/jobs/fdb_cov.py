"""Coverage of the latest ForeverDB class data (pvwvuow/wow-raw fdb/latest/classes/<class>.json, the
game build in its manifest) against data/names/spell, data/names/tree and data/tpl.

ForeverDB gives every ability name and every talent (name, ranks with the English description).
What is missing here is written to ci/reports/fdb_missing.json (full lists) and counted in the report.
args: ref (default main), top (rows in the report).
"""
import json
import os
import re
import urllib.request

from wfa.core import name_key, num_key
from wfa.store import Store

CLASSES = ("warrior", "paladin", "hunter", "rogue", "priest", "shaman", "mage", "warlock", "druid")
ZW = re.compile("[\u2060-\u2064\u200b\u200d\u200e\u200f\ufeff\u200c]")


def fetch(repo, path, ref):
    url = "https://api.github.com/repos/pvwvuow/%s/contents/%s?ref=%s" % (repo, path, ref)
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""),
                                               "Accept": "application/vnd.github.raw", "User-Agent": "wowfa2-ci"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read().decode("utf-8")


def clean(s):
    return re.sub(r"\s+", " ", ZW.sub("", s or "")).strip()


def run(args, rep):
    store = Store.load()
    ref = args.get("ref", "main")
    top = int(args.get("top", 40))
    try:
        man = json.loads(fetch("wow-raw", "fdb/latest/manifest.json", ref))
    except Exception as e:
        rep.fail("cannot read wow-raw manifest: %s" % e)
        return []
    rep.h("ForeverDB archive")
    rep.ok("build %s, fetched %s" % (man.get("build"), man.get("fetched_at")))
    miss = {"build": man.get("build"), "names": {}, "talents": {}, "descriptions": {}}
    tot = {"abilities": 0, "talents": 0, "ranks": 0}
    for cls in CLASSES:
        try:
            d = json.loads(fetch("wow-raw", "fdb/latest/classes/%s.json" % cls, ref))["data"]
        except Exception as e:
            rep.fail("%s: %s" % (cls, e))
            continue
        nm, tl, ds = [], [], {}
        for ab in d.get("abilities", []):
            tot["abilities"] += 1
            en = clean(ab.get("name"))
            if en and name_key(en) not in store.names["spell"]:
                nm.append([en, ab.get("line"), bool(ab.get("newInForever"))])
        for tree in d.get("talentTrees", []):
            if name_key(tree.get("name", "")) not in store.names["tree"]:
                nm.append(["TREE " + tree.get("name", ""), "", False])
            for t in tree.get("talents", []):
                tot["talents"] += 1
                en = clean(t.get("name"))
                if en and name_key(en) not in store.names["spell"]:
                    tl.append([en, tree.get("name"), bool(t.get("newInForever"))])
                for r in t.get("ranks", []):
                    tot["ranks"] += 1
                    text = clean(r.get("description"))
                    if not text:
                        continue
                    key, nums = num_key(text)
                    if key not in store.tpl and key not in ds:
                        ds[key] = [en, text, r.get("rank")]
        miss["names"][cls] = nm
        miss["talents"][cls] = tl
        miss["descriptions"][cls] = ds
    rep.h("Counts")
    rep.ok("abilities %(abilities)d, talents %(talents)d, talent ranks %(ranks)d in the archive" % tot)
    rows = []
    for cls in CLASSES:
        if cls in miss["names"]:
            rows.append((cls, len(miss["names"][cls]), len(miss["talents"][cls]), len(miss["descriptions"][cls])))
    rep.table(rows, ["class", "ability names missing", "talent names missing", "talent descriptions missing (unique)"])
    for cls in CLASSES:
        if cls not in miss["names"]:
            continue
        rep.h(cls)
        rep.add("names: " + "; ".join("%s%s" % (a, " [new]" if n else "") for a, _l, n in miss["names"][cls][:top]))
        rep.add("talents: " + "; ".join("%s%s" % (a, " [new]" if n else "") for a, _l, n in miss["talents"][cls][:top]))
    os.makedirs("ci/reports", exist_ok=True)
    with open("ci/reports/fdb_missing.json", "w", encoding="utf-8", newline="\n") as fh:
        json.dump(miss, fh, ensure_ascii=False, indent=1, sort_keys=True)
        fh.write("\n")
    return ["ci/reports/fdb_missing.json"]
