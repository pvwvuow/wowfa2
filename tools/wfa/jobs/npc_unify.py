"""One word, one Persian word, across the NPC names (the owner: cliff lurker = 'ambush of cliff').

args: rules [[en_regex, old, new], ...]  - in every NPC name whose ENGLISH key matches en_regex (use ".*" for all),
                                            the Persian substring old (every ZWNJ in it optional) becomes new
      sets  {key: persian}               - set one NPC name outright
      apply (false = report only)

Full markers {{npc:EN|old}} of a changed name follow it in the quest texts and templates.
"""
import collections
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
    npc = store.names["npc"]
    apply = bool(args.get("apply"))
    rules = [(re.compile(e, re.I), zre(o), n) for e, o, n in args.get("rules") or []]
    changes = {}
    per_rule = collections.Counter()
    for key, fa in npc.items():
        new = fa
        for i, (ex, rx, n) in enumerate(rules):
            if ex.search(key):
                nw, k = rx.subn(lambda m, n=n: n, new)
                if k:
                    per_rule[i] += k
                    new = nw
        if new != fa:
            changes[key] = (fa, new)
    for key, fa in (args.get("sets") or {}).items():
        if key in npc and npc[key] != fa:
            changes[key] = (npc[key], fa)
        elif key not in npc:
            rep.fail("no such NPC key: %s" % key)
    rep.h("Rules")
    rep.table([(i + 1, args["rules"][i][0], args["rules"][i][2], per_rule[i]) for i in range(len(rules))], ["#", "english", "becomes", "names"])
    rep.h("Changed names: %d" % len(changes))
    rep.add("\n".join("- %s: %s -> %s" % (k, o, n) for k, (o, n) in sorted(changes.items())[:int(args.get("show", 120))]))
    if not apply or not changes:
        return []
    for k, (o, n) in changes.items():
        npc[k] = n
    moved = 0

    def marker_sub(m):
        nonlocal moved
        fam, en, fa = m.group(1), m.group(2), m.group(3)
        if fam == "npc" and fa is not None:
            ch = changes.get(name_key(en))
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
    rep.ok("%d names set, %d markers followed" % (len(changes), moved))
    store.save()
    return ["data"]
