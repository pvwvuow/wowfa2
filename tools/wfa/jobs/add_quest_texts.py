"""Fill-only Persian quest TEXT parts from the owner's harvest (25 Nov 2026).

args.quests  {"<quest id>": {"en": English title (for the hash, only when the record is new),
              "t": ..., "obj": ..., "det": ..., "pro": ..., "com": ..., "desc": ...}}   '~' = ZWNJ
A part that already has text is never changed (listed). A new record gets the title hash.
"""
from wfa import core
from wfa.store import Store

Z = "\u200c"
PARTS = ("t", "obj", "det", "pro", "com", "desc")


def run(args, rep):
    store = Store.load()
    quests = store.quests
    rep.h("Quest texts")
    changed = 0
    for sid, row in sorted((args.get("quests") or {}).items(), key=lambda kv: int(kv[0])):
        qid = int(sid)
        rec = quests.get(qid)
        new = rec is None
        if new:
            rec = {}
        put = []
        for p in PARTS:
            v = row.get(p)
            if not v:
                continue
            v = v.replace("~", Z)
            if rec.get(p):
                rep.add("- %s %s already has text, not changed" % (qid, p))
                continue
            rec[p] = v
            put.append(p)
        if new and row.get("en"):
            fn = getattr(core, "title_hash", None)
            if fn:
                rec["h"] = fn(row["en"])
        if put:
            quests[qid] = rec
            changed += 1
            rep.ok("%s %s: %s %s" % (qid, "NEW" if new else "filled", row.get("en") or "", ",".join(put)))
    rep.ok("%d quest records changed" % changed)
    if changed:
        store.save()
        return ["data"]
    return []
