"""NPC names: one English word, one Persian word. Per first (or last) English word, find the Persian word most
names share and list the names that lack it (spelling variants, other synonyms).

args: pos first|last, min (group size), share (min share of the modal word), per (names shown per group)
"""
import collections
import re

from wfa.store import Store


def words(s):
    return [w for w in re.split(r"\s+", s.strip()) if w]


def run(args, rep):
    npc = Store.load().names["npc"]
    pos = args.get("pos", "first")
    groups = collections.defaultdict(list)
    for k, fa in npc.items():
        e = words(re.sub(r"^the\s+", "", k))
        if len(e) >= 2:
            groups[e[0] if pos == "first" else e[-1]].append((k, fa))
    out = []
    for fw, lst in sorted(groups.items(), key=lambda kv: -len(kv[1])):
        if len(lst) < int(args.get("min", 5)):
            continue
        cnt = collections.Counter()
        for k, fa in lst:
            for t in set(words(fa)):
                cnt[t] += 1
        m, c = cnt.most_common(1)[0]
        share = c / len(lst)
        if share < float(args.get("share", 0.55)) or share >= 1.0:
            continue
        bad = [(k, fa) for k, fa in lst if m not in words(fa)]
        out.append("### %s -> %s (%d names, %d%%)" % (fw, m, len(lst), int(100 * share)))
        out.extend("- %s: %s" % x for x in bad[: int(args.get("per", 12))])
    rep.add("\n".join(out))
    return []
