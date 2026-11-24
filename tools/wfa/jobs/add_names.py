"""Fill-only additions to the name tables and the description templates.

args.names  {"npc": {"English name": "Persian"}, "zone": {...}, ...}   (key = name_key(English))
args.tpl    {"English line with its real numbers": "Persian with {0} {1} slots"}  (key = num_key)
An existing entry with another value is reported and never overwritten.
"""
from wfa.core import name_key, num_key
from wfa.store import Store

Z = "\u200c"


def run(args, rep):
    store = Store.load()
    added = 0
    rep.h("Names")
    for kind, rows in (args.get("names") or {}).items():
        if kind not in store.names:
            rep.fail("unknown name kind %s" % kind)
            continue
        for en, fa in rows.items():
            k = name_key(en)
            fa = fa.replace("~", Z)
            old = store.names[kind].get(k)
            if old is None:
                store.names[kind][k] = fa
                added += 1
                rep.ok("%s: %s -> %s" % (kind, k, fa))
            elif old == fa:
                rep.add("- %s: %s already there" % (kind, k))
            else:
                rep.add("- CONFLICT %s: %s has %s (given %s), not changed" % (kind, k, old, fa))
    rep.h("Templates")
    for en, fa in (args.get("tpl") or {}).items():
        k, nums = num_key(en)
        fa = fa.replace("~", Z)
        old = store.tpl.get(k)
        if old is None:
            store.tpl[k] = fa
            added += 1
            rep.ok("tpl: %s -> %s" % (k, fa))
        elif old == fa:
            rep.add("- tpl %s already there" % k)
        else:
            rep.add("- CONFLICT tpl %s has %s (given %s), not changed" % (k, old, fa))
    rep.ok("%d entries added" % added)
    if added:
        store.save()
        return ["data"]
    return []
