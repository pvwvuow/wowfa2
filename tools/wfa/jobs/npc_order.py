"""NPC names: where does the adjective sit? (the owner 25 Nov: 'Ancient X Gorilla' came out as 'gorilla X ancient').

args: mode "stats"  - last Persian word and first English word frequency, with examples
      mode "cand"   - args adj: [[en_first_word_regex, fa_adjective], ...]: names whose ENGLISH starts with the
                      word and whose PERSIAN ends with the adjective -> proposed order (adjective right after the head word)
"""
import collections
import re

from wfa.store import Store

ZW = "\u200c"


def words(s):
    return [w for w in re.split(r"\s+", s.strip()) if w]


def run(args, rep):
    store = Store.load()
    npc = store.names["npc"]
    mode = args.get("mode", "stats")
    if mode == "stats":
        last = collections.defaultdict(list)
        first = collections.defaultdict(list)
        for k, fa in npc.items():
            w = words(fa)
            if len(w) >= 2:
                last[w[-1]].append((k, fa))
            e = words(k)
            if len(e) >= 2:
                first[e[0]].append((k, fa))
        rep.h("Last Persian word (names with 2+ words), top %d" % int(args.get("top", 150)))
        rows = sorted(last.items(), key=lambda kv: -len(kv[1]))[: int(args.get("top", 150))]
        rep.add("\n".join("- %s (%d): %s" % (w, len(v), " | ".join("%s = %s" % x for x in v[:2])) for w, v in rows))
        rep.h("First English word, top %d" % int(args.get("top", 150)))
        rows = sorted(first.items(), key=lambda kv: -len(kv[1]))[: int(args.get("top", 150))]
        rep.add("\n".join("- %s (%d): %s" % (w, len(v), " | ".join("%s = %s" % x for x in v[:2])) for w, v in rows))
        return []
    if mode == "auto":
        groups = collections.defaultdict(list)
        for k, fa in npc.items():
            e = words(re.sub(r"^the\s+", "", k))
            if len(e) >= 2:
                groups[e[0]].append((k, fa))
        out = []
        for fw, lst in sorted(groups.items(), key=lambda kv: -len(kv[1])):
            if len(lst) < int(args.get("min", 4)):
                continue
            cnt = collections.Counter()
            for k, fa in lst:
                for t in set(words(fa)):
                    cnt[t] += 1
            m, c = cnt.most_common(1)[0]
            if c / len(lst) < float(args.get("share", 0.6)):
                continue
            cand = []
            for k, fa in lst:
                w = words(fa)
                e = words(re.sub(r"^the\s+", "", k))
                if len(w) >= 3 and len(e) >= 3 and w[-1] == m:
                    cand.append((k, fa, " ".join([w[0], m] + w[1:-1])))
            if cand:
                out.append("### %s -> %s (%d names, %d%% have it, %d at the end)" % (fw, m, len(lst), 100 * c // len(lst), len(cand)))
                out.extend("- %s: %s -> %s" % x for x in cand[: int(args.get("per", 40))])
        rep.add("\n".join(out))
        return []
    out = []
    for en_rx, fa_adj in args.get("adj") or []:
        rx = re.compile(r"^(?:the\s+)?(?:%s)\s" % en_rx, re.I)
        n = 0
        for k, fa in sorted(npc.items()):
            if not rx.search(k):
                continue
            w = words(fa)
            if len(w) >= 3 and w[-1] == fa_adj:
                new = " ".join([w[0], fa_adj] + w[1:-1])
                out.append("- %s: %s -> %s" % (k, fa, new))
                n += 1
        rep.h("%s = %s: %d" % (en_rx, fa_adj, n))
    rep.add("\n".join(out[: int(args.get("show", 400))]))
    return []
