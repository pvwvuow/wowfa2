"""Replace text inside the Persian value of templates: args.edits = [{"key": substring of the English
key (lower case), "old": text, "new": text, "count": expected hits (default 1)}]. All or nothing."""
from wfa.store import Store


def run(args, rep):
    store = Store.load()
    ok = True
    plan = {}
    for i, e in enumerate(args["edits"], 1):
        hits = [k for k in store.tpl if e["key"] in k.lower()]
        if len(hits) != 1:
            ok = False
            rep.fail("#%d key %r matches %d templates" % (i, e["key"], len(hits)))
            continue
        v = plan.get(hits[0], store.tpl[hits[0]])
        n = v.count(e["old"])
        if n != e.get("count", 1):
            ok = False
            rep.fail("#%d %r found %d times, expected %d in: %s" % (i, e["old"], n, e.get("count", 1), v[:200]))
            continue
        plan[hits[0]] = v.replace(e["old"], e["new"])
        rep.ok("#%d replaced in %s" % (i, hits[0][:70]))
    if not ok:
        return []
    store.tpl.update(plan)
    store.save()
    return ["data"]
