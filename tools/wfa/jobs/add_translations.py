"""Add reviewed Persian for spell names and description templates through the same fill-only,
gate-checked path as the site import (spells.import_classes).

args.names  {English name: Persian}; '~' = ZWNJ; {key} = the Persian of table spell <key> (composition)
args.descs  [{en: English text with its real numbers, fa: Persian with the same numbers}];
            [[key]] = the spell marker {{sp:key}} (key must be a spell in the table or in args.names)
"""
import re

from wfa import spells
from wfa.core import name_key
from wfa.store import Store

Z = "\u200c"


def run(args, rep):
    store = Store.load()
    names = args.get("names") or {}
    descs = args.get("descs") or []
    table = store.names["spell"]
    new_keys = {name_key(en) for en in names}
    problems = []
    entries = []
    for en, fa in names.items():
        if "\ufffd" in fa:
            problems.append("broken text for %s" % en)
            continue
        fa = fa.replace("~", Z)

        def sub(m):
            v = table.get(name_key(m.group(1)))
            if v is None:
                problems.append("%s: {%s} is not in the table" % (en, m.group(1)))
                return m.group(0)
            return v
        fa = re.sub(r"\{([^{}0-9][^{}]*)\}", sub, fa)
        if "{" in fa:
            continue
        entries.append({"n": en, "fa": fa})
    for d in descs:
        fa = d["fa"]
        if "\ufffd" in fa:
            problems.append("broken text in a description of %s" % d["en"][:40])
            continue
        fa = fa.replace("~", Z)
        ok = [True]

        def mark(m):
            k = name_key(m.group(1))
            if k not in table and k not in new_keys:
                problems.append("[[%s]] is not a spell (%s)" % (m.group(1), d["en"][:40]))
                ok[0] = False
                return m.group(0)
            return "{{sp:%s}}" % m.group(1)
        fa = re.sub(r"\[\[([^\[\]]+)\]\]", mark, fa)
        if ok[0]:
            entries.append({"n": None, "d": d["en"], "dFa": fa})
    rep.h("Input")
    rep.ok("%d names and %d descriptions given, %d entries ready, %d problems" % (len(names), len(descs), len(entries), len(problems)))
    for p in problems:
        rep.add("- PROBLEM %s" % p)
    out = spells.import_classes(store, {"warrior": {"build": "1.60.1.70959", "tabs": [], "trees": [], "spells": entries}})
    rep.h("Result")
    rep.ok("added: %s; already identical: %s" % (out["added"], out["same"]))
    for key in ("conflict", "gate_reject", "pair_reject"):
        rep.ok("%s: %d" % (key, len(out[key])))
        for x in out[key][:60]:
            rep.add("  - %s" % x)
    rep.ok("number mismatch: %d" % len(out["num_mismatch"]))
    for x in out["num_mismatch"][:30]:
        rep.add("  - %s" % (x["en"][:80],))
    if sum(out["added"].values()):
        store.save()
        return ["data"]
    return []
