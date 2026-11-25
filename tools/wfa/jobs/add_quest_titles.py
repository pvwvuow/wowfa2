"""Fill-only Persian TITLES for quests the data has no record for (owner 25 Nov, full review:
ForeverDB lists ~150 WoW Forever quests - mostly Riverglades - with no record; their texts
exist only in the game, so the title comes first and the harvest brings the rest).

args.titles  {"<quest id>": ["English title", "Persian title"]}   '~' = ZWNJ
A quest that already has a record is never touched (reported).
"""
from wfa import core
from wfa.store import Store

Z = "\u200c"


def _hash(en):
    fn = getattr(core, "title_hash", None)
    return fn(en) if fn else None


def run(args, rep):
    store = Store.load()
    quests = store.quests
    added, kept = 0, 0
    rep.h("Quest titles")
    for sid, pair in sorted((args.get("titles") or {}).items(), key=lambda kv: int(kv[0])):
        qid = int(sid)
        en, fa = pair[0], pair[1].replace("~", Z)
        if qid in quests:
            kept += 1
            rep.add("- %s %s: has a record, not changed" % (qid, en))
            continue
        rec = {"t": fa}
        h = _hash(en)
        if h:
            rec["h"] = h
        quests[qid] = rec
        added += 1
        rep.ok("%s %s -> %s" % (qid, en, fa))
    rep.ok("%d titles added, %d kept" % (added, kept))
    if added:
        store.save()
        return ["data"]
    return []
