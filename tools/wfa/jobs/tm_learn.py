"""Learn the game terms from the {{tm:EN|FA}} markers that are already in the data and mark the SAME
Persian wherever it stands as plain text in the templates (and, if asked, the quest texts), so every
such term follows the terms switch and gets the term colour (the owner: 'physical damage' and many
more were not marked).

A Persian string is learned when it stands in at least min_count tm markers and one English side
owns at least 80 percent of them. Never marked: a string that is also a class / zone / spell / tree /
npc name (two families), anything in stop, anything shorter than min_len letters.

args: apply (false = report only), min_count (3), min_len (3), stop ([]), sample (30), tpl (true),
      quests (true = also rewrite the quest texts; the story text says 'spirit' and 'power' in their
      everyday sense, so the owner's run uses false), allow (list: when given, a ONE-word term is
      marked only if it is in the list; multi-word terms always), fields (default every quest text
      field + o), top (rows of the table)
"""
import collections
import random
import re

from wfa.store import Store

SKIP = re.compile(r"\{\{[^{}]*\}\}|\{\d+\}|<[^<>]*>|\$[GgNnCcRrBb](?:[^;:\s]*:[^;]*;)?|\|c[0-9a-fA-F]{8}|\|r|\|T[^|]*\|t")
PERS = "\u0621-\u063a\u0641-\u064a\u0670\u0679-\u06d3\u06f0-\u06f9\u200c"
FIELDS = ("t", "obj", "det", "pro", "com", "desc")
TM = re.compile(r"\{\{tm:([^|{}]*)\|([^{}]+)\}\}")


def each_seg(text, fn):
    out, pos = [], 0
    for m in SKIP.finditer(text):
        out.append(fn(text[pos:m.start()]))
        out.append(m.group(0))
        pos = m.end()
    out.append(fn(text[pos:]))
    return "".join(out)


def letters(s):
    return len(s.replace("\u200c", "").replace(" ", ""))


def run(args, rep):
    store = Store.load()
    apply = bool(args.get("apply"))
    min_count = int(args.get("min_count", 3))
    min_len = int(args.get("min_len", 3))
    stop = set(args.get("stop") or [])
    allow = args.get("allow")
    fields = args.get("fields") or FIELDS
    use_tpl = args.get("tpl", True)
    use_quests = args.get("quests", True)

    def all_texts():
        for rec in store.quests.values():
            for f in fields:
                v = rec.get(f)
                if isinstance(v, str) and v:
                    yield v
            for v in rec.get("o") or []:
                if isinstance(v, str) and v:
                    yield v
        for v in store.tpl.values():
            if isinstance(v, str) and v:
                yield v

    seen = collections.defaultdict(collections.Counter)
    for text in all_texts():
        for m in TM.finditer(text):
            fa = m.group(2).strip()
            if fa:
                seen[fa][m.group(1).strip()] += 1

    names = set()
    for kind in ("class", "zone", "spell", "tree", "npc", "boss"):
        for fa in store.names.get(kind, {}).values():
            if isinstance(fa, str):
                names.add(fa.strip())
    learned, skipped = {}, []
    for fa, c in seen.items():
        total = sum(c.values())
        if total < min_count or letters(fa) < min_len or fa in stop or re.search(r"[A-Za-z0-9{}|]", fa):
            continue
        low = collections.Counter()
        for en, n in c.items():
            low[en.lower()] += n
        top, topn = low.most_common(1)[0]
        if topn < 0.8 * total:
            skipped.append(fa + " (two English)")
            continue
        if fa in names:
            skipped.append(fa + " (also a name)")
            continue
        if allow is not None and " " not in fa and fa not in allow:
            skipped.append(fa + " (one word, not allowed)")
            continue
        # the English spelling most used for that lower-case form
        best = max((en for en in c if en.lower() == top), key=lambda e: c[e])
        learned[fa] = best
    rep.h("Learned")
    rep.ok("%d Persian terms from %d different tm strings; %d skipped" % (len(learned), len(seen), len(skipped)))
    rep.add("skipped: " + " | ".join(skipped[:60]))
    if not learned:
        return []
    alt = "|".join(re.escape(x) for x in sorted(learned, key=lambda s: (-len(s), s)))
    rx = re.compile("(?<![%sA-Za-z0-9])(?:%s)(?![%sA-Za-z0-9])" % (PERS, alt, PERS))

    hits = collections.Counter()
    ctx = []

    def mark(s):
        def sub(m):
            fa = m.group(0)
            hits[fa] += 1
            if len(ctx) < 4000:
                ctx.append((fa, s[max(0, m.start() - 25):m.end() + 25]))
            return "{{tm:%s|%s}}" % (learned[fa], fa)
        return rx.sub(sub, s)

    def fix(text):
        return each_seg(text, mark)

    changed = 0
    if use_quests:
        for rec in store.quests.values():
            for f in fields:
                v = rec.get(f)
                if isinstance(v, str) and v:
                    new = fix(v)
                    if new != v and apply:
                        rec[f] = new
                    changed += new != v
            o = rec.get("o")
            if o:
                out = [fix(v) if isinstance(v, str) else v for v in o]
                if out != o:
                    changed += 1
                    if apply:
                        rec["o"] = out
    if use_tpl:
        for k, v in list(store.tpl.items()):
            if isinstance(v, str):
                new = fix(v)
                if new != v:
                    changed += 1
                    if apply:
                        store.tpl[k] = new
    rep.h("Plain terms that get marked")
    rep.ok("%d different, %d hits, %d texts %s" % (len(hits), sum(hits.values()), changed, "rewritten" if apply else "would change"))
    rep.table([(fa, learned[fa], n) for fa, n in hits.most_common(int(args.get("top", 70)))], ["persian", "english", "hits"])
    random.Random(5).shuffle(ctx)
    rep.h("sample contexts")
    for fa, c in ctx[:int(args.get("sample", 30))]:
        rep.add("- %s: ...%s..." % (fa, c))
    if not apply or not changed:
        return []
    store.save()
    return ["data"]
