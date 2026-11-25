"""Report only: are these marker names in their family tables, and with which Persian?
args.items [[fam, English], ...]; fam zn=zone, npc=npc+boss, fac=?(listed as a term), tm=term"""
from wfa.store import Store

TABLE = {"zn": ["zone"], "npc": ["npc", "boss"], "sp": ["spell"], "cls": ["class", "tree"]}


def run(args, rep):
    store = Store.load()
    rep.h("markers")
    for fam, en in args.get("items") or []:
        k = en.lower()
        hit = None
        for t in TABLE.get(fam, []):
            if k in store.names.get(t, {}):
                hit = (t, store.names[t][k])
                break
        rep.add("- %s:%s -> %s" % (fam, en, ("%s = %s" % hit) if hit else "NOT IN TABLE"))
    rep.h("tables")
    rep.add("names tables: %s" % ", ".join(sorted(store.names)))
    return []
