"""Zone names and quest titles: the same spelling fixes the NPC names got (the owner 25 Nov: 'zones and quests too').
Persian-only substitutions (the zone table is English-keyed, quest titles hold Persian only).

args: pairs [[old, new], ...] (every ZWNJ in old optional), apply, show
Zone markers {{zone:EN|old}} of a changed zone follow it in the quest texts and templates.
"""
import re

from wfa.core import MARKER_RE
from wfa.store import Store

FIELDS = ("t", "obj", "det", "pro", "com", "desc")


def zre(s):
    return re.compile("".join("\u200c?" if ch == "\u200c" else re.escape(ch) for ch in s))


def name_key(s):
    s = s.replace("\u2018", "'").replace("\u2019", "'").replace("\u201c", "'").replace("\u201d", "'").lower()
    s = re.sub(r"^\s*the\s+", "", s)
    return re.sub(r"\s+", " ", s).strip()


def run(args, rep):
    store = Store.load()
    pairs = [(zre(o), n) for o, n in args.get("pairs") or []]
    apply = bool(args.get("apply"))

    def fix(s):
        for rx, n in pairs:
            s = rx.sub(lambda m, n=n: n, s)
        return s

    zone = store.names["zone"]
    zc = {k: (v, fix(v)) for k, v in zone.items() if isinstance(v, str) and fix(v) != v}
    qc = {}
    for qid, rec in store.quests.items():
        t = rec.get("t")
        if isinstance(t, str) and t and fix(t) != t:
            qc[qid] = (t, fix(t))
    rep.h("Zone names changed: %d" % len(zc))
    rep.add("\n".join("- %s: %s -> %s" % (k, o, n) for k, (o, n) in sorted(zc.items())[: int(args.get("show", 60))]))
    rep.h("Quest titles changed: %d" % len(qc))
    rep.add("\n".join("- %s: %s -> %s" % (k, o, n) for k, (o, n) in sorted(qc.items())[: int(args.get("show", 60))]))
    if not apply or not (zc or qc):
        return []
    for k, (o, n) in zc.items():
        zone[k] = n
    for qid, (o, n) in qc.items():
        store.quests[qid]["t"] = n
    moved = 0

    def marker_sub(m):
        nonlocal moved
        fam, en, fa = m.group(1), m.group(2), m.group(3)
        if fam == "zone" and fa is not None:
            ch = zc.get(name_key(en))
            if ch and ch[0] == fa:
                moved += 1
                return "{{%s:%s|%s}}" % (fam, en, ch[1])
        return m.group(0)

    for rec in store.quests.values():
        for f in FIELDS:
            v = rec.get(f)
            if isinstance(v, str) and v:
                rec[f] = MARKER_RE.sub(marker_sub, v)
        o = rec.get("o")
        if o:
            rec["o"] = [MARKER_RE.sub(marker_sub, v) if isinstance(v, str) else v for v in o]
    for k, v in list(store.tpl.items()):
        if isinstance(v, str):
            store.tpl[k] = MARKER_RE.sub(marker_sub, v)
    rep.ok("%d zone names and %d quest titles set, %d markers followed" % (len(zc), len(qc), moved))
    store.save()
    return ["data"]
