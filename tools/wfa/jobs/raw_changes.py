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


def run(args, rep):
    build = args.get("build", "1.60.1.71037")
    rep.h("build change report " + build)
    try:
        doc = json.loads(_get("manifests/forever/changes/%s.json" % build))
    except Exception as e:  # noqa: BLE001
        rep.fail("cannot read the report: %s" % e)
        return []
    rep.ok("top level: %s" % (sorted(doc.keys())[:12] if isinstance(doc, dict) else type(doc).__name__))
    tables = doc.get("tables", doc) if isinstance(doc, dict) else {}
    store = Store.load()
    have = store.names["spell"]
    for tname in ("SpellName", "Spell"):
        t = tables.get(tname) if isinstance(tables, dict) else None
        if not isinstance(t, dict):
            rep.ok("%s: not in the report" % tname)
            continue
        added = t.get("added") or []
        changed = t.get("changed") or []
        rep.ok("%s: %d added, %d changed (keys %s)" % (tname, len(added), len(changed), sorted(t.keys())))
        rows = []
        for r in added[:60]:
            nm = r.get("Name_lang") if isinstance(r, dict) else None
            if nm is None and isinstance(r, dict):
                nm = r.get("Description_lang") or ""
            rows.append((r.get("ID") if isinstance(r, dict) else r, str(nm)[:70], "known" if name_key(str(nm)) in have else "NEW"))
        rep.table(rows, ["id", "name", "in our table"])
        if changed:
            rep.table([(c.get("ID"), json.dumps(c, ensure_ascii=False)[:160]) for c in changed[:15] if isinstance(c, dict)], ["id", "change"])
    return []
