"""Read a build change report of pvwvuow/wow-raw (manifests/forever/changes/<build>.json) and list the
spell rows it adds / changes, against our spell names. Report only.

args: build ("1.60.1.71037")"""
import json
import os
import urllib.request

from wfa.core import name_key
from wfa.store import Store


def _get(path):
    url = "https://api.github.com/repos/pvwvuow/wow-raw/contents/" + path + "?ref=main"
    req = urllib.request.Request(url, headers={"Accept": "application/vnd.github.raw", "Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""), "User-Agent": "wowfa2-ci"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read().decode("utf-8")


def _short(v, n=220):
    return json.dumps(v, ensure_ascii=False)[:n]


def run(args, rep):
    build = args.get("build", "1.60.1.71037")
    rep.h("build change report " + build)
    try:
        doc = json.loads(_get("manifests/forever/changes/%s.json" % build))
    except Exception as e:  # noqa: BLE001
        rep.fail("cannot read the report: %s" % e)
        return []
    tables = doc.get("tables") or {}
    store = Store.load()
    have = store.names["spell"]
    rep.ok("summary: %s" % _short(doc.get("summary"), 300))
    for tname in ("SpellName", "Spell"):
        t = tables.get(tname)
        if not isinstance(t, dict):
            rep.ok("%s: not in the report" % tname)
            continue
        added = t.get("added")
        changed = t.get("changed")
        rep.ok("%s: key=%s columns_added=%s columns_removed=%s" % (tname, t.get("key"), _short(t.get("columns_added"), 80), _short(t.get("columns_removed"), 80)))
        rep.ok("%s added (%s): %s" % (tname, type(added).__name__, _short(added, 1500)))
        rep.ok("%s changed (%s): %s" % (tname, type(changed).__name__, _short(changed, 1500)))
    names = []
    t = tables.get("SpellName") or {}
    added = t.get("added")
    rows = added.values() if isinstance(added, dict) else (added or [])
    for r in rows:
        if isinstance(r, dict):
            nm = r.get("Name_lang") or r.get("name") or ""
            names.append((r.get("ID") or r.get("id"), nm[:80], "known" if name_key(nm) in have else "NEW"))
    if names:
        rep.table(names, ["id", "name", "in our table"])
    return []
