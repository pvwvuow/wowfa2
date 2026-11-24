"""Report only: the vocabulary behind the NPC names. For every English word that stands in at least
min_count NPC names, the Persian words that stand most often in the same names (a name is a pair; the
word it was translated to is the Persian word with the highest share). A wrong word shows up as a
Persian word that does not fit the English one (cliff lurker = 'ambush', not 'one who ambushes').

args: min_count (6), top (400), per (3), agents (true = also list every English '-er / -or' agent word
      with its Persian), grep (list of English substrings: print those names in full), limit (40)
"""
import collections
import re

from wfa.store import Store

WORD = re.compile(r"[a-z][a-z'\-]*")


def run(args, rep):
    store = Store.load()
    npc = store.names["npc"]
    min_count = int(args.get("min_count", 6))
    per = int(args.get("per", 3))
    en_n = collections.Counter()
    co = collections.defaultdict(collections.Counter)
    fa_n = collections.Counter()
    for en, fa in npc.items():
        ews = set(WORD.findall(en.lower()))
        fws = set(w for w in re.split(r"[\s\u060c,:;()]+", fa) if w)
        for w in fws:
            fa_n[w] += 1
        for e in ews:
            en_n[e] += 1
            for w in fws:
                co[e][w] += 1
    rows = []
    for e, n in en_n.most_common():
        if n < min_count:
            break
        cand = []
        for w, c in co[e].most_common(40):
            # share of the English word's names that hold w, damped by how common w is overall
            score = c / n - 0.6 * (fa_n[w] - c) / max(len(npc), 1) * 8
            cand.append((score, w, c))
        cand.sort(reverse=True)
        rows.append((e, n, "  |  ".join("%s %d" % (w, c) for _, w, c in cand[:per])))
    rep.h("English words and their Persian words (%d words)" % len(rows))
    rep.table(rows[:int(args.get("top", 400))], ["english", "names", "persian (count)"])
    if args.get("agents"):
        ag = [(e, n) for e, n in en_n.items() if re.search(r"(er|or)$", e) and n >= 2 and e not in ("water", "outer", "inner", "elder", "master", "hunter")]
        ag.sort(key=lambda x: -x[1])
        rows2 = []
        for e, n in ag[:150]:
            cand = sorted(((c, w) for w, c in co[e].items() if c * 2 >= n), reverse=True)[:2]
            rows2.append((e, n, "  |  ".join(w for _, w in cand)))
        rep.h("agent words (-er / -or)")
        rep.table(rows2, ["english", "names", "persian"])
    for g in args.get("grep") or []:
        hits = [(k, v) for k, v in sorted(npc.items()) if g.lower() in k]
        rep.h("%s: %d names" % (g, len(hits)))
        for k, v in hits[:int(args.get("limit", 40))]:
            rep.add("- %s = %s" % (k, v))
    return []
