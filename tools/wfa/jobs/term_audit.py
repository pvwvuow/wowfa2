"""Report only: with which Persian words is each English game term translated (tpl, names, ui)?
For every concept (an English regex on the key) the Persian words that are CONCENTRATED in the matching rows
(a word is shown when at least `conc` of all rows that contain it are matching rows) are counted.
Two strong words for one concept = the same term translated two ways.
args: concepts [[id, regex], ...], top (10), min (3), conc (0.3), samples (2)"""
import re

from wfa.store import Store

MARK = re.compile(r"\{\{.*?\}\}|\{\d+\}|\|c[0-9a-fA-F]{8}|\|r|\$\w+")
TOKEN = re.compile(r"[\u0600-\u06FF\u200c]+")


def toks(s):
    s = MARK.sub(" ", s)
    out = set()
    for t in TOKEN.findall(s):
        t = t.strip("\u200c")
        if len(t) >= 2:
            out.add(t)
    return out


def run(args, rep):
    store = Store.load()
    docs = []
    for k, v in store.tpl.items():
        docs.append(("tpl", k.lower(), v))
    for kind, tab in store.names.items():
        for k, v in tab.items():
            docs.append(("n:" + kind, k.lower(), v))
    for k, v in store.ui.items():
        docs.append(("ui", str(k).lower(), v))
    base = {}
    dt = []
    for tbl, k, v in docs:
        t = toks(v)
        dt.append(t)
        for w in t:
            base[w] = base.get(w, 0) + 1
    top = int(args.get("top", 10))
    mn = int(args.get("min", 3))
    conc = float(args.get("conc", 0.3))
    ns = int(args.get("samples", 2))
    rep.add("rows scanned: %d" % len(docs))
    for cid, rx in args.get("concepts") or []:
        try:
            cr = re.compile(rx, re.I)
        except re.error as e:
            rep.add("- %s: bad regex %s" % (cid, e))
            continue
        hit = [i for i, d in enumerate(docs) if cr.search(d[1])]
        per = {}
        for i in hit:
            per[docs[i][0]] = per.get(docs[i][0], 0) + 1
        rep.h("%s /%s/ rows=%d %s" % (cid, rx, len(hit), ",".join("%s:%d" % kv for kv in sorted(per.items()))))
        cnt = {}
        for i in hit:
            for w in dt[i]:
                cnt[w] = cnt.get(w, 0) + 1
        rows = [(w, c, base[w]) for w, c in cnt.items() if c >= mn and c / base[w] >= conc]
        rows.sort(key=lambda r: -r[1])
        rep.add("  " + "  ".join("%s %d/%d" % r for r in rows[:top]))
        short = sorted(hit, key=lambda i: len(docs[i][1]))[:ns]
        for i in short:
            rep.add("  e.g. %s -> %s" % (docs[i][1][:70], docs[i][2][:90]))
    return []
