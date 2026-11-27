"""Report only: the names a word is already translated in (npc / zone / spell tables).
args: words (list), kinds (default npc), limit (8 per word)"""
from wfa.store import Store


def run(args, rep):
    store = Store.load()
    lim = int(args.get("limit", 8))
    for kind in args.get("kinds") or ["npc"]:
        tab = store.names.get(kind) or {}
        for w in args.get("words") or []:
            wl = w.lower()
            hits = [(k, v) for k, v in tab.items() if wl in k]
            hits.sort(key=lambda kv: len(kv[0]))
            rep.h("%s: %s (%d)" % (kind, w, len(hits)))
            for k, v in hits[:lim]:
                rep.add("- %s -> %s" % (k, v))
    return []
