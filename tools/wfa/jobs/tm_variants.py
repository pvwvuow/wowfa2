"""Report only: the SAME English term with TWO OR MORE Persian renderings inside the {{kind:EN|FA}} markers
(tpl, quests, ui, names), and the same word stem (stun / stunned / stuns) with different renderings.
args: kinds (default ["tm"]), top (120), min (2: rows a variant must have to count), words (extra: EN terms to show in full)"""
import re

from wfa.store import Store, QUEST_FIELDS

MK = re.compile(r"\{\{(\w+):([^|}]+)(?:\|([^}]*))?\}\}")
ZW = "\u200c"


def stem(en):
    w = en.lower().strip()
    if " " in w or "-" in w:
        return None
    return re.sub(r"(ing|ed|es|s)$", "", w) if len(w) > 5 else w


def run(args, rep):
    store = Store.load()
    kinds = set(args.get("kinds") or ["tm"])
    texts = []
    for v in store.tpl.values():
        texts.append(("tpl", v))
    for qid, rec in store.quests.items():
        for f in QUEST_FIELDS[1:]:
            if rec.get(f):
                texts.append(("q", rec[f]))
        for line in rec.get("o") or []:
            texts.append(("q", line))
    for v in store.ui.values():
        texts.append(("ui", v))
    for kind, tab in store.names.items():
        for v in tab.values():
            texts.append(("n", v))
    by = {}
    seen_rows = 0
    for tbl, s in texts:
        for m in MK.finditer(s):
            k, en, fa = m.group(1), m.group(2).strip(), m.group(3)
            if k not in kinds or fa is None:
                continue
            seen_rows += 1
            d = by.setdefault(en.lower(), {})
            d[fa] = d.get(fa, 0) + 1
    rep.add("markers read: %d, distinct terms: %d" % (seen_rows, len(by)))
    mn = int(args.get("min", 2))
    multi = []
    for en, d in by.items():
        solid = {fa: n for fa, n in d.items() if n >= 1}
        # differences that are only the half-space or the spacing are one rendering
        norm = {}
        for fa, n in solid.items():
            norm.setdefault(fa.replace(ZW, "").replace(" ", ""), []).append((fa, n))
        if len(norm) >= 2:
            tot = sum(n for fa, n in solid.items())
            multi.append((tot, en, solid))
    multi.sort(key=lambda r: -r[0])
    rep.h("one term, two or more renderings: %d" % len(multi))
    for tot, en, solid in multi[: int(args.get("top", 120))]:
        parts = sorted(solid.items(), key=lambda kv: -kv[1])
        rep.add("- %s (%d): %s" % (en, tot, " | ".join("%s x%d" % kv for kv in parts[:5])))
    # same stem, different main rendering
    groups = {}
    for en, d in by.items():
        st = stem(en)
        if st:
            main = max(d.items(), key=lambda kv: kv[1])
            groups.setdefault(st, []).append((en, main[0], sum(d.values())))
    rep.h("same stem, different main rendering")
    shown = 0
    for st, items in sorted(groups.items()):
        mains = {x[1].replace(ZW, "").replace(" ", "") for x in items}
        if len(items) >= 2 and len(mains) >= 2:
            rep.add("- %s: %s" % (st, " | ".join("%s=%s x%d" % x for x in sorted(items, key=lambda x: -x[2])[:6])))
            shown += 1
            if shown >= int(args.get("top", 120)):
                break
    for w in args.get("words") or []:
        d = by.get(w.lower())
        rep.add("word %s: %s" % (w, d))
    return []
