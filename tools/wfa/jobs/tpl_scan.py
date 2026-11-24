"""Report only: how the spell / talent description templates (data/tpl) use name markers.

args: grep (list of lower-case strings; every template whose key or value holds one is printed in full),
top (rows per table), sample (entries per sample list).
"""
import collections
import re

from wfa.core import MARKER_RE
from wfa.store import Store

LATIN = re.compile(r"[A-Za-z][A-Za-z'\u2019\-]*(?: [A-Za-z][A-Za-z'\u2019\-]*)*")
PERS = re.compile(r"[\u0600-\u06ff]")


def run(args, rep):
    store = Store.load()
    top = int(args.get("top", 60))
    sample = int(args.get("sample", 15))
    greps = [g.lower() for g in args.get("grep") or []]
    fam = collections.Counter()
    runs = collections.Counter()
    mixed = []
    spell_fa = {}
    for key, fa in store.names["spell"].items():
        spell_fa.setdefault(fa, key)
    plain_spell = collections.Counter()
    for k, v in store.tpl.items():
        for m in MARKER_RE.finditer(v):
            fam[m.group(1)] += 1
        bare = MARKER_RE.sub("", v)
        bare = re.sub(r"\{\d+\}", "", bare)
        lat = [x for x in LATIN.findall(bare) if len(x) > 2]
        if lat and PERS.search(bare):
            mixed.append((k, v))
            for x in lat:
                runs[x.lower()] += 1
        for fa, en in spell_fa.items():
            if len(fa) >= 5 and fa in bare:
                plain_spell[fa] += 1
    rep.h("Templates")
    rep.ok("%d templates; markers used: %s" % (len(store.tpl), dict(fam)))
    rep.ok("%d templates hold Latin words next to Persian text (outside markers)" % len(mixed))
    rep.h("Latin runs inside Persian templates")
    rep.table([(x, n, "spell name" if x in store.names["spell"] else "") for x, n in runs.most_common(top)], ["run", "templates", "is a spell key"])
    rep.h("Spell names written in plain Persian (no marker) inside templates")
    rep.table([(fa, spell_fa[fa], n) for fa, n in plain_spell.most_common(top)], ["persian", "key", "templates"])
    rep.h("Samples of mixed templates")
    for k, v in mixed[:sample]:
        rep.add("- KEY: %s" % k[:160])
        rep.add("  VAL: %s" % v[:260])
    for g in greps:
        rep.h("grep: %s" % g)
        n = 0
        for k, v in store.tpl.items():
            if g in k.lower() or g in v.lower():
                rep.add("- KEY: %s" % k)
                rep.add("  VAL: %s" % v)
                n += 1
                if n >= 12:
                    break
        for k, v in store.names["spell"].items():
            if g in k or g in v.lower():
                rep.add("- spell name: %s -> %s" % (k, v))
    return []
