"""Mark plain Persian class / zone / spell / term names inside the spell and talent templates
(data/tpl) with full markers {{fam:EN|FA}}, so the runtime colours them and the family switches
work on them. Report first (apply = false), then apply.

args: kinds (["class", "zone", "spell", "tree"]), terms (true = also the glossary words of
terms.json "fa" locks), min_len (3), stop (Persian strings never marked), apply, sample.
A spell name of ONE word is marked only when it is at least 5 letters and not a common word (the
stop list); a name that is part of a longer marked name is never marked on its own (longest first).
"""
import collections
import random
import re

from wfa.store import Store

FAM = {"class": "cls", "zone": "zn", "spell": "sp", "tree": "cls"}
SKIP = re.compile(r"\{\{[^{}]*\}\}|\{\d+\}|<[^<>]*>|\$[A-Za-z0-9]+|\|c[0-9a-fA-F]{8}|\|r|\|T[^|]*\|t")
PERS = "\u0600-\u06ff\u200c"
SMALL = {"of", "the", "and", "in", "on", "at", "to"}


def title_of(key):
    return " ".join(w if (i and w in SMALL) else w[:1].upper() + w[1:] for i, w in enumerate(key.split(" ")))


def each_seg(text, fn):
    out, pos = [], 0
    for m in SKIP.finditer(text):
        out.append(fn(text[pos:m.start()]))
        out.append(m.group(0))
        pos = m.end()
    out.append(fn(text[pos:]))
    return "".join(out)


def term_pairs(terms):
    """terms.json shapes we accept: {"locks": {en: fa}} / {"terms": {en: fa}} / [{"en","fa"}]"""
    out = {}
    if isinstance(terms, dict):
        for k in ("locks", "terms", "glossary", "lock"):
            v = terms.get(k)
            if isinstance(v, dict):
                for en, fa in v.items():
                    if isinstance(fa, str):
                        out[en] = fa
                    elif isinstance(fa, dict) and isinstance(fa.get("fa"), str):
                        out[en] = fa["fa"]
            elif isinstance(v, list):
                for r in v:
                    if isinstance(r, dict) and isinstance(r.get("en"), str) and isinstance(r.get("fa"), str):
                        out[r["en"]] = r["fa"]
    return out


def run(args, rep):
    store = Store.load()
    kinds = args.get("kinds") or ["class", "zone", "spell", "tree"]
    min_len = int(args.get("min_len", 3))
    stop = set(args.get("stop") or [])
    apply = bool(args.get("apply"))
    rep.h("terms.json")
    t = store.terms
    rep.ok("type %s, keys %s" % (type(t).__name__, sorted(t.keys())[:20] if isinstance(t, dict) else len(t)))
    for k in (sorted(t.keys())[:6] if isinstance(t, dict) else []):
        rep.add("- %s: %s" % (k, str(t[k])[:300]))
    pairs = term_pairs(t) if args.get("terms") else {}
    rep.ok("%d term pairs usable" % len(pairs))

    cand = {}
    for kind in kinds:
        for key, fa in store.names[kind].items():
            fa = (fa or "").strip()
            if len(fa) < min_len or re.search(r"[A-Za-z0-9{}|]", fa):
                continue
            if kind == "spell" and " " not in fa and len(fa) < 5:
                continue
            cand.setdefault(fa, set()).add((FAM[kind], title_of(key)))
    for en, fa in pairs.items():
        fa = fa.strip()
        if len(fa) >= min_len and not re.search(r"[A-Za-z0-9{}|]", fa):
            cand.setdefault(fa, set()).add(("tm", en))
    amb = sorted(fa for fa, s in cand.items() if len({x[0] for x in s}) > 1)
    names = {}
    for fa, s in cand.items():
        if fa in stop or fa in amb:
            continue
        names[fa] = sorted(s)[0]
    only = set(args.get("only") or [])
    if only:
        names = {fa: v for fa, v in names.items() if "%s:%s" % v in only}
    rep.h("candidates")
    rep.ok("%d names, %d skipped as ambiguous (two families)" % (len(names), len(amb)))
    rep.add("ambiguous: " + " ".join(amb[:80]))
    alt = "|".join(re.escape(x) for x in sorted(names, key=lambda s: (-len(s), s)))
    rx = re.compile("(?<![%sA-Za-z0-9])(?:%s)(?![%sA-Za-z0-9])" % (PERS, alt, PERS))

    have = collections.Counter()
    for v in store.tpl.values():
        for m in re.finditer(r"\{\{(\w+):", v):
            have[m.group(1)] += 1
    rep.ok("markers already in the templates: %s" % dict(have))

    hits = collections.Counter()
    ctx = []
    for k, v in store.tpl.items():
        def cnt(s):
            for m in rx.finditer(s):
                hits[m.group(0)] += 1
                if len(ctx) < 3000:
                    ctx.append((m.group(0), s[max(0, m.start() - 25):m.end() + 25]))
            return s
        each_seg(v, cnt)
    rep.h("plain names in the templates")
    rep.ok("%d different, %d hits" % (len(hits), sum(hits.values())))
    rep.table([(fa, names[fa][0], names[fa][1], n) for fa, n in hits.most_common(80)], ["name", "fam", "en", "hits"])
    by = collections.Counter()
    for fa, n in hits.items():
        by[names[fa][0]] += n
    rep.ok("hits per family: %s" % dict(by))
    random.Random(3).shuffle(ctx)
    rep.h("sample contexts")
    for fa, c in ctx[:int(args.get("sample", 30))]:
        rep.add("- %s: ...%s..." % (fa, c))
    if not apply:
        rep.ok("report only: nothing written")
        return []
    changed = 0
    for k in list(store.tpl):
        v = store.tpl[k]
        new = each_seg(v, lambda s: rx.sub(lambda m: "{{%s:%s|%s}}" % (names[m.group(0)][0], names[m.group(0)][1], m.group(0)), s))
        if new != v:
            store.tpl[k] = new
            changed += 1
    rep.ok("%d templates rewritten" % changed)
    store.save()
    return ["data"]
