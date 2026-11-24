"""Report only: the templates (data/tpl) whose English key or Persian text holds a substring.

args: grep (list of substrings, matched lower-case on the key and as is on the Persian), limit (30)
"""
from wfa.store import Store


def run(args, rep):
    store = Store.load()
    grep = args.get("grep") or []
    limit = int(args.get("limit", 30))
    for g in grep:
        hits = [(k, v) for k, v in store.tpl.items() if g.lower() in k.lower() or g in v]
        rep.h("%s: %d templates" % (g, len(hits)))
        for k, v in hits[:limit]:
            rep.add("- KEY %s\n  FA %s" % (k, v))
    return []
