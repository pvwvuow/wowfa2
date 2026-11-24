"""Report only: how the quest texts carry name markers, quest by quest.

args: titles (English quest titles to print in full with every name found in them), top, ids.
Shows (1) the asked quests, (2) the marker census per field, (3) plain Persian names of every
family that no marker covers (counts, quests, plural use), (4) short markers whose table has no
Persian (they stay English), (5) the objective list field 'o' versus 'obj'.
"""
import collections
import json
import re

from wfa.core import MARKER_RE, name_key, title_hash
from wfa.store import Store

FIELDS = ("t", "obj", "det", "pro", "com", "desc")
SKIP = re.compile(r"\{\{[^{}]*\}\}|\{\d+\}|<[^<>]*>|\$[GgNnCcRrBb](?:[^;:\s]*:[^;]*;)?|\|c[0-9a-fA-F]{8}|\|r")
PERS = "\u0600-\u06ff\u200c"
FAMKIND = (("npc", "npc"), ("boss", "npc"), ("zone", "zn"), ("spell", "sp"), ("class", "cls"), ("obj", "ob"))


def each_seg(text, fn):
    out, pos = [], 0
    for m in SKIP.finditer(text):
        out.append(fn(text[pos:m.start()]))
        out.append(m.group(0))
        pos = m.end()
    out.append(fn(text[pos:]))
    return "".join(out)


def run(args, rep):
    store = Store.load()
    top = int(args.get("top", 40))
    cand = {}
    for kind, fam in FAMKIND:
        for key, fa in store.names[kind].items():
            fa = (fa or "").strip()
            if len(fa) < 3 or re.search(r"[A-Za-z0-9{}|]", fa):
                continue
            cand.setdefault(fa, set()).add((fam, kind, key))
    amb = {fa for fa, s in cand.items() if len({x[0] for x in s}) > 1}
    names = {fa: sorted(s)[0] for fa, s in cand.items() if fa not in amb}
    alt = "|".join(re.escape(x) for x in sorted(names, key=lambda s: (-len(s), s)))
    rx = re.compile("(?<![%sA-Za-z0-9])(?:%s)(?![%sA-Za-z0-9])" % (PERS, alt, PERS))
    rx_pl = re.compile("(?<![%sA-Za-z0-9])(%s)(?=\u200c?(?:\u0647\u0627|\u0647\u0627\u06cc)(?![%s]))" % (PERS, alt, PERS))

    # 1. the asked quests
    wanted = {title_hash(t): t for t in args.get("titles") or []}
    ids = set(int(i) for i in args.get("ids") or [])
    rep.h("Asked quests")
    for qid, rec in sorted(store.quests.items()):
        if rec.get("h") in wanted or qid in ids:
            rep.add("### quest %d" % qid)
            rep.add("```")
            rep.add(json.dumps(rec, ensure_ascii=False, indent=1)[:3500])
            rep.add("```")
            for f in FIELDS + ("o",):
                v = rec.get(f)
                for seg in (v if isinstance(v, list) else [v]):
                    if not seg:
                        continue
                    found = []
                    each_seg(seg, lambda s: (found.extend(m.group(0) for m in rx.finditer(s)), s)[1])
                    for fa in found:
                        rep.add("- plain in %s: %s -> %s" % (f, fa, names[fa]))

    # 2. marker census
    census = collections.Counter()
    short = collections.Counter()
    for qid, rec in store.quests.items():
        for f in FIELDS + ("o",):
            v = rec.get(f)
            for seg in (v if isinstance(v, list) else [v]):
                if not seg:
                    continue
                for m in MARKER_RE.finditer(seg):
                    census[(f if f != "o" else "o", m.group(1), "full" if m.group(3) is not None else "short")] += 1
                    if m.group(3) is None:
                        short[(m.group(1), m.group(2))] += 1
    rep.h("Marker census")
    byfam = collections.Counter()
    for (f, fam, form), n in census.items():
        byfam[(fam, form)] += n
    rep.table(sorted((k[0], k[1], n) for k, n in byfam.items()), ["family", "form", "markers"])
    rep.ok("quests: %d; with a title: %d; with an 'o' list: %d" % (
        len(store.quests), sum(1 for r in store.quests.values() if r.get("t")),
        sum(1 for r in store.quests.values() if r.get("o"))))

    # 4. short markers with no Persian
    kind_of = {"sp": "spell", "zn": "zone", "cls": "class", "npc": "npc", "it": "it", "ob": "obj", "set": "set"}
    nofa = collections.Counter()
    for (fam, en), n in short.items():
        k = kind_of.get(fam)
        if k and not store.names[k].get(name_key(en)):
            nofa[(fam, en)] += n
    rep.h("Short markers without a Persian name (they render English)")
    rep.ok("%d different, %d uses" % (len(nofa), sum(nofa.values())))
    rep.table([(a, b, n) for (a, b), n in nofa.most_common(top)], ["family", "english", "uses"])

    # 3. plain names
    hits = collections.Counter()
    where = collections.defaultdict(set)
    infield = collections.Counter()
    plural = collections.Counter()
    for qid, rec in store.quests.items():
        for f in FIELDS + ("o",):
            v = rec.get(f)
            for seg in (v if isinstance(v, list) else [v]):
                if not seg:
                    continue

                def cnt(s):
                    for m in rx.finditer(s):
                        hits[m.group(0)] += 1
                        where[m.group(0)].add(qid)
                        infield[(names[m.group(0)][0], f)] += 1
                    for m in rx_pl.finditer(s):
                        plural[m.group(1)] += 1
                    return s
                each_seg(seg, cnt)
    rep.h("Plain Persian names that no marker covers")
    rep.ok("%d different names, %d hits, %d quests touched; %d Persian strings are shared by two families (skipped)" % (
        len(hits), sum(hits.values()), len(set().union(*where.values())) if where else 0, len(amb)))
    rep.table(sorted((k[0], k[1], n) for k, n in infield.items()), ["family", "field", "hits"])
    for fam in ("npc", "zn", "sp", "cls", "ob"):
        rows = [(fa, names[fa][2], n, len(where[fa]), plural.get(fa, 0)) for fa, n in hits.most_common() if names[fa][0] == fam][:top]
        rep.h("top plain names: %s" % fam)
        rep.table(rows, ["persian", "key", "hits", "quests", "plural"])
    rep.h("ambiguous Persian (two families)")
    rep.add(" ".join(sorted(amb)[:120]))

    # 5. o vs obj
    mism = 0
    for qid, rec in store.quests.items():
        o = rec.get("o")
        if o and rec.get("obj"):
            a = len(MARKER_RE.findall(rec["obj"]))
            b = sum(len(MARKER_RE.findall(x)) for x in o)
            if a != b:
                mism += 1
    rep.ok("quests whose 'o' list carries a different number of markers than 'obj': %d" % mism)
    return []
