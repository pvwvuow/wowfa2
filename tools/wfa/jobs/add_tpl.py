"""Add new spell-description templates (fill-only: a key that already exists is listed, never changed).
Used for the descriptions a game build rewrote (owner, 25 Nov 2026: 1.60.1.71091).
args: rows {english key (lower-case, numbers as #, no final period): persian with {0}.. slots}"""
from wfa.store import Store


def run(args, rep):
    rows = args.get("rows") or {}
    store = Store.load()
    added, kept = [], []
    for k, v in rows.items():
        k = str(k).strip()
        if not k or not str(v).strip():
            continue
        if k in store.tpl:
            kept.append(k)
            continue
        store.tpl[k] = str(v).strip()
        added.append(k)
    store.save()
    rep.h("templates")
    rep.ok("%d added, %d already there (not touched)" % (len(added), len(kept)))
    for k in added:
        rep.add("- + %s\n  FA %s" % (k, store.tpl[k]))
    for k in kept:
        rep.add("- = %s" % k)
    return ["data"] if added else []
