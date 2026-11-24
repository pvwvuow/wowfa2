"""Build 71037 removed the sentence "When applied to main hand, disables any benefit you personally receive
from Flametongue / Windfury Totem." from the weapon imbue descriptions. For every template that still has
it, add the template WITHOUT it (key and Persian), keeping the old one for players on the old text.
The Persian sentence to drop is the one that names a totem; if that is not exactly one sentence the
template is reported and left alone."""
import re

from wfa.store import Store

GONE = re.compile(r"\s*when applied to main hand, disables any benefit you personally receive from (?:flametongue|windfury) totem\.", re.I)
SPLIT = re.compile(r"(?<=[.!\u061f])\s+")


def run(args, rep):
    store = Store.load()
    todo = [k for k in store.tpl if GONE.search(k)]
    rep.h("weapon imbue templates with the removed sentence")
    rep.ok("%d templates carry it" % len(todo))
    added = 0
    rows = []
    for k in todo:
        newkey = re.sub(r"\s+", " ", GONE.sub("", k)).strip()
        if newkey in store.tpl:
            rows.append((k[:50], "new key already there", ""))
            continue
        val = store.tpl[k]
        parts = SPLIT.split(val)
        hit = [i for i, p in enumerate(parts) if re.search(r"totem|\u062a\u0648\u062a\u0645", p, re.I)]
        if len(hit) != 1:
            rows.append((k[:50], "%d Persian sentences name a totem" % len(hit), ""))
            continue
        gone = parts.pop(hit[0])
        store.tpl[newkey] = " ".join(parts).strip()
        added += 1
        rows.append((k[:50], "added", gone[:60]))
    rep.table(rows, ["template", "result", "Persian sentence dropped"])
    rep.ok("%d new templates" % added)
    if not added or not args.get("apply"):
        return []
    store.save()
    return ["data"]
