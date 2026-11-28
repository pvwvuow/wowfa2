"""Report only. Two views.
args.finds   [[id, table prefix ("tpl", "n:it", "n", "ui"), EN regex, limit], ...]: the rows, EN -> FA
args.lasts   [last EN word, ...]: item-like names (n:it, n:itn, n:set) whose English ends in that word, with the
             Persian first and last words counted (one English noun should have ONE Persian noun)"""
import re

from wfa.store import Store

TOK = re.compile(r"[\u0600-\u06FF\u200c]+")


def run(args, rep):
    store = Store.load()
    docs = []
    for k, v in store.tpl.items():
        docs.append(("tpl", k, v))
    for kind, tab in store.names.items():
        for k, v in tab.items():
            docs.append(("n:" + kind, k, v))
    for k, v in store.ui.items():
        docs.append(("ui", str(k), v))
    for cid, tbl, rx, lim in args.get("finds") or []:
        cr = re.compile(rx, re.I)
        rows = [d for d in docs if d[0].startswith(tbl) and cr.search(d[1])]
        rep.h("%s: %s /%s/ %d rows" % (cid, tbl, rx, len(rows)))
        for t, k, v in sorted(rows, key=lambda d: len(d[1]))[: int(lim)]:
            rep.add("- [%s] %s -> %s" % (t, k[:90], v[:110]))
    for w in args.get("lasts") or []:
        first, last, n = {}, {}, 0
        for t, k, v in docs:
            if t not in ("n:it", "n:itn", "n:set") or not k.endswith(" " + w) and k != w:
                continue
            toks = [x.strip("\u200c") for x in TOK.findall(re.sub(r"\{\{.*?\}\}", " ", v))]
            toks = [x for x in toks if len(x) >= 2]
            if not toks:
                continue
            n += 1
            first[toks[0]] = first.get(toks[0], 0) + 1
            last[toks[-1]] = last.get(toks[-1], 0) + 1
        top = lambda d: "  ".join("%s %d" % kv for kv in sorted(d.items(), key=lambda kv: -kv[1])[:6])
        rep.h("last word '%s': %d rows" % (w, n))
        rep.add("  first: " + top(first))
        rep.add("  last:  " + top(last))
    return []
