"""Reword text in the templates (data/tpl) and the quest texts: regex find / replace where every ZWNJ of
the pattern is optional (the display strips it, so the exact spelling is not known).

args: subs [[old, new], ...] (old is a plain string, ZWNJ optional), count_only (false)
"""
import re

from wfa.store import Store

FIELDS = ("t", "obj", "det", "pro", "com", "desc")


def run(args, rep):
    store = Store.load()
    subs = []
    for old, new in args.get("subs") or []:
        pat = "".join("\u200c?" if ch == "\u200c" else re.escape(ch) for ch in old)
        subs.append((old, new, re.compile(pat)))
    counts = {old: 0 for old, _, _ in subs}

    def fix(text):
        for old, new, rx in subs:
            text, k = rx.subn(lambda m, n=new: n, text)
            counts[old] += k
        return text

    for k, v in list(store.tpl.items()):
        if isinstance(v, str):
            new = fix(v)
            if new != v and not args.get("count_only"):
                store.tpl[k] = new
    for rec in store.quests.values():
        for f in FIELDS:
            v = rec.get(f)
            if isinstance(v, str) and v:
                new = fix(v)
                if new != v and not args.get("count_only"):
                    rec[f] = new
    rep.h("Reworded")
    rep.table([(old[:40], n) for old, n in counts.items()], ["old", "replaced"])
    if args.get("count_only") or not any(counts.values()):
        return []
    store.save()
    return ["data"]
