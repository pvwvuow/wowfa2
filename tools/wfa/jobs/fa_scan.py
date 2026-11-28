"""Report only: where a Persian word (or any substring) is used - tpl, names (all kinds), ui, quests and the
addon's own Lua texts - with the English key beside it.
args: words (list of Persian strings), samples (4 per place), lua (true: also scan addon/WoWFA/**/*.lua)"""
import os
import pathlib

from wfa.store import Store, QUEST_FIELDS

ROOT = pathlib.Path(__file__).resolve().parents[3]


def around(s, w, n=28):
    i = s.find(w)
    if i < 0:
        return s[:60]
    return s[max(0, i - n): i + len(w) + n].replace("\n", " ")


def run(args, rep):
    store = Store.load()
    ns = int(args.get("samples", 4))
    for w in args.get("words") or []:
        places = {}

        def add(place, en, fa):
            d = places.setdefault(place, [0, []])
            d[0] += 1
            if len(d[1]) < ns:
                d[1].append("%s -> %s" % (en[:50], around(fa, w)))

        for k, v in store.tpl.items():
            if w in v:
                add("tpl", k, v)
        for kind, tab in store.names.items():
            for k, v in tab.items():
                if w in v:
                    add("n:" + kind, k, v)
        for k, v in store.ui.items():
            if w in v:
                add("ui", str(k), v)
        for qid, rec in store.quests.items():
            for f in QUEST_FIELDS[1:]:
                if rec.get(f) and w in rec[f]:
                    add("quest:" + f, "q%d" % qid, rec[f])
            for line in rec.get("o") or []:
                if w in line:
                    add("quest:o", "q%d" % qid, line)
        if args.get("lua", True):
            base = ROOT / "addon" / "WoWFA"
            for p in sorted(base.rglob("*.lua")):
                try:
                    lines = p.read_text(encoding="utf-8").splitlines()
                except Exception:
                    continue
                rel = str(p.relative_to(base))
                if rel.startswith("Data"):
                    continue
                for n, line in enumerate(lines, 1):
                    if w in line:
                        add("lua", "%s:%d" % (rel, n), line.strip())
        rep.h("%s: %s" % (w, ", ".join("%s %d" % (p, d[0]) for p, d in sorted(places.items())) or "nowhere"))
        for p, d in sorted(places.items()):
            for s in d[1]:
                rep.add("  [%s] %s" % (p, s))
    return []
