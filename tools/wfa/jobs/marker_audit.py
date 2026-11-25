"""Audit every marker {{fam:EN|FA}} / {{fam:EN}} in tpl + quests + ui: is EN a real entry of its
family table? Lists per family the keys that are NOT in their table (sp -> names.spell, cls ->
names.class + names.tree, zn -> names.zone, npc -> names.npc + names.boss, it -> names.itn) and the
term (tm) keys sorted by use, so wrong colours can be fixed by hand. Report only.
args: sample (contexts per key, 2), top (rows per table, 400)"""
import collections
import re

from wfa.store import Store

MK = re.compile(r"\{\{(\w+):([^{}|]*)(?:\|([^{}]*))?\}\}")


def strings(store):
    for k, v in store.tpl.items():
        yield "tpl", k, v
    for qid, rec in store.quests.items():
        for f, v in rec.items():
            if isinstance(v, str):
                yield "q", "%s.%s" % (qid, f), v
            elif isinstance(v, list):
                for i, x in enumerate(v):
                    if isinstance(x, str):
                        yield "q", "%s.%s%d" % (qid, f, i), x
    for k, v in store.ui.items():
        if isinstance(v, str):
            yield "ui", k, v


def run(args, rep):
    store = Store.load()
    n = store.names
    low = {kind: {k.lower() for k in t} for kind, t in n.items()}
    table = {"sp": ["spell"], "cls": ["class", "tree"], "zn": ["zone"], "npc": ["npc", "boss"], "it": ["itn"]}
    samp = int(args.get("sample", 2))
    top = int(args.get("top", 400))
    use = collections.Counter()
    bad = collections.defaultdict(collections.Counter)
    ctx = collections.defaultdict(list)
    fams = collections.Counter()
    for src, key, v in strings(store):
        for m in MK.finditer(v):
            fam, en, fa = m.group(1), m.group(2).strip(), m.group(3)
            fams[(src, fam)] += 1
            k = (fam, en.lower(), fa or "")
            use[k] += 1
            if fam in table and not any(en.lower() in low.get(t, ()) for t in table[fam]):
                bad[fam][(en.lower(), fa or "")] += 1
            if len(ctx[k]) < samp:
                ctx[k].append("%s %s: ...%s..." % (src, key[:60], v[max(0, m.start() - 30):m.end() + 30].replace("\n", " ")))
    rep.h("markers per source/family")
    rep.table(sorted(((s, f, c) for (s, f), c in fams.items()), key=lambda r: -r[2]), ["src", "fam", "n"])
    for fam in ("sp", "cls", "zn", "npc", "it"):
        rows = bad[fam].most_common(top)
        rep.h("%s markers whose name is not in %s (%d keys, %d uses)" % (fam, "+".join(table[fam]), len(bad[fam]), sum(bad[fam].values())))
        rep.table([(en, fa, c, " || ".join(ctx[(fam, en, fa)])[:220]) for (en, fa), c in rows], ["en", "fa", "uses", "context"])
    # sp keys that ARE in names.spell but are plain english words (one word, lower case in the text)
    rep.h("one-word sp markers (check: real spell or a plain word?)")
    one = collections.Counter()
    for (fam, en, fa), c in use.items():
        if fam == "sp" and " " not in en:
            one[(en, fa)] += c
    rep.table([(en, fa, c, " || ".join(ctx[("sp", en, fa)])[:220]) for (en, fa), c in one.most_common(top)], ["en", "fa", "uses", "context"])
    rep.h("tm keys by use")
    tm = collections.Counter()
    for (fam, en, fa), c in use.items():
        if fam == "tm":
            tm[en] += c
    rep.add(" ".join("%s(%d)" % (k, c) for k, c in tm.most_common(top)))
    rep.ok("report only: nothing written")
    return []
