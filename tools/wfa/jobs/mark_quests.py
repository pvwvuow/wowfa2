"""Mark plain Persian NPC / zone names in the quest texts with {{npc:EN|FA}} / {{zn:EN|FA}}.

args: kinds (default ["npc", "zone"]), min_len (4), apply (false = report only), stop (list of
Persian strings never to mark), max_single (single-word names with more hits than this are
treated as common words and skipped), sample (contexts to show).
The runtime resolves a marker to Persian (or the English when that name family is off) and
colours it (F.ColorOf), so every unmarked name is a name that can not be coloured or hovered.
"""
import collections
import random
import re

from wfa.core import MARKER_RE
from wfa.store import Store

FIELDS = ("obj", "det", "pro", "com", "desc")
FAM = {"npc": "npc", "zone": "zn", "spell": "sp", "class": "cls", "obj": "ob"}
SKIP = re.compile(r"\{\{[^{}]*\}\}|<[^<>]*>|\$[GgNnCcRrBb](?:[^;:\s]*:[^;]*;)?|\|c[0-9a-fA-F]{8}|\|r")
PERS = "\u0600-\u06ff\u200c"
SMALL = {"of", "the", "and", "in", "on", "at", "to", "de", "la", "du", "von"}


def title_of(key):
    out = []
    for i, w in enumerate(key.split(" ")):
        if i and w in SMALL:
            out.append(w)
        else:
            out.append("-".join(p[:1].upper() + p[1:] for p in w.split("-")))
    return " ".join(out)


def run(args, rep):
    store = Store.load()
    kinds = args.get("kinds") or ["npc", "zone"]
    min_len = int(args.get("min_len", 4))
    apply = bool(args.get("apply"))
    stop = set(args.get("stop") or [])
    max_single = int(args.get("max_single", 80))
    sample_n = int(args.get("sample", 12))

    # the original-case English of a name, from markers the data already has
    en_of = {}
    for rec in store.quests.values():
        for f in FIELDS + ("t",):
            for m in MARKER_RE.finditer(rec.get(f) or ""):
                fam, en, fa = m.group(1), m.group(2), m.group(3)
                if fam in ("npc", "zn") and fa and en:
                    en_of.setdefault(fa, en)

    cand = {}
    for kind in kinds:
        for key, fa in store.names[kind].items():
            fa = (fa or "").strip()
            if len(fa) < min_len or re.search(r"[A-Za-z0-9{}|]", fa):
                continue
            cand.setdefault(fa, set()).add((FAM[kind], key))
    ambiguous = sorted(fa for fa, s in cand.items() if len(s) > 1)
    names = {fa: next(iter(s)) for fa, s in cand.items() if len(s) == 1 and fa not in stop}
    rep.h("Candidates")
    rep.ok("%d usable names, %d ambiguous (same Persian for two names: skipped), %d in the stop list"
           % (len(names), len(ambiguous), len(stop)))
    if not names:
        return []
    alt = "|".join(re.escape(x) for x in sorted(names, key=lambda s: (-len(s), s)))
    rx = re.compile("(?<![%sA-Za-z0-9])(?:%s)(?![%sA-Za-z0-9])" % (PERS, alt, PERS))

    hits = collections.Counter()
    where = collections.defaultdict(set)
    ctx = []

    def count_seg(seg, qid):
        for m in rx.finditer(seg):
            hits[m.group(0)] += 1
            where[m.group(0)].add(qid)
            if len(ctx) < 4000:
                ctx.append((m.group(0), seg[max(0, m.start() - 30):m.end() + 30].replace("\n", " ")))

    def each_seg(text, fn):
        out, pos = [], 0
        for m in SKIP.finditer(text):
            out.append(fn(text[pos:m.start()]))
            out.append(m.group(0))
            pos = m.end()
        out.append(fn(text[pos:]))
        return "".join(out)

    for qid, rec in store.quests.items():
        for f in FIELDS:
            t = rec.get(f)
            if t:
                each_seg(t, lambda s, q=qid: (count_seg(s, q), s)[1])

    suspicious = {fa for fa, n in hits.items() if " " not in fa and n > max_single}
    rep.h("Plain names found in quest text")
    rep.ok("%d different names, %d hits in %d quests; %d single-word names above %d hits are treated as common words"
           % (len(hits), sum(hits.values()), len(set().union(*where.values())) if where else 0,
              len(suspicious), max_single))
    rows = []
    for fa, n in hits.most_common(60):
        fam, key = names[fa]
        rows.append((fa, fam, key, n, "SKIP" if fa in suspicious else ""))
    rep.table(rows, ["name", "fam", "key", "hits", "skip"])
    rep.h("Skipped as common words (all)")
    rep.add(" ".join(sorted(suspicious)) or "-")
    rep.h("Sample contexts")
    random.Random(7).shuffle(ctx)
    for fa, c in ctx[:sample_n]:
        rep.add("- %s: ...%s..." % (fa, c))
    if not apply:
        rep.ok("report only (apply = false): nothing written")
        return []

    use = {fa: v for fa, v in names.items() if fa not in suspicious and hits.get(fa)}
    changed = 0

    def mark(mm):
        fa = mm.group(0)
        if fa not in use:
            return fa
        fam, key = use[fa]
        return "{{%s:%s|%s}}" % (fam, en_of.get(fa) or title_of(key), fa)

    for qid, rec in store.quests.items():
        for f in FIELDS:
            t = rec.get(f)
            if not t:
                continue
            new = each_seg(t, lambda s: rx.sub(mark, s))
            if new != t:
                rec[f] = new
                changed += 1
    rep.ok("%d quest fields rewritten, %d names marked" % (changed, len(use)))
    store.save()
    return ["data"]
