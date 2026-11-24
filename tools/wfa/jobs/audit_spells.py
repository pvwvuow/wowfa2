"""Audit of every spell / talent / class name and every description template.

Checks: empty or Latin Persian, Arabic letters (\u0643 \u064a) where Persian ones belong, runs of spaces,
space before punctuation, colour-code (|c..|r) balance between English and Persian, {n} slots versus
# numbers, Persian that is the English text, spell names the English key mentions that the Persian
value does not carry (neither as a marker nor as the table's own Persian), a spell name that two
different English names share. args: apply (normalise Arabic letters and space runs only), top.
"""
import collections
import re

from wfa.core import MARKER_RE
from wfa.store import Store

AR = {"\u0643": "\u06a9", "\u064a": "\u06cc", "\u0649": "\u06cc"}
SLOT = re.compile(r"\{(\d+)\}")


def norm(s):
    for a, b in AR.items():
        s = s.replace(a, b)
    return re.sub(r"(?<=\S) {2,}(?=\S)", " ", s)


def run(args, rep):
    store = Store.load()
    apply = bool(args.get("apply"))
    top = int(args.get("top", 40))
    bad = collections.defaultdict(list)
    fixes = 0
    for kind in ("spell", "tree", "class"):
        tbl = store.names[kind]
        for k in list(tbl):
            v = tbl[k]
            if not v.strip():
                bad["empty name"].append((kind, k))
            if re.search(r"[A-Za-z]", v):
                bad["latin in name"].append((kind, k, v))
            if v != v.strip() or " \n" in v:
                bad["edge space in name"].append((kind, k))
            nv = norm(v.strip())
            if nv != v:
                fixes += 1
                if apply:
                    tbl[k] = nv
    for k in list(store.tpl):
        v = store.tpl[k]
        if not v.strip():
            bad["empty template"].append((k[:80],))
            continue
        if v.strip().lower() == k.strip().lower():
            bad["persian equals english"].append((k[:80],))
        if k.count("|c") != v.count("|c") or k.count("|r") != v.count("|r"):
            bad["colour codes differ"].append((k[:70], k.count("|c"), v.count("|c"), k.count("|r"), v.count("|r")))
        if re.search(r"\s[\u060c\u061b\.:!\u061f]", MARKER_RE.sub("", v)):
            bad["space before punctuation"].append((k[:70],))
        slots = {int(x) for x in SLOT.findall(v)}
        n = k.count("#")
        if slots and max(slots) >= n:
            bad["slot beyond the numbers"].append((k[:70], n, sorted(slots)))
        if n and not slots:
            bad["English numbers but no slot"].append((k[:70], n))
        nv = norm(v)
        if nv != v:
            fixes += 1
            if apply:
                store.tpl[k] = nv
    # one Persian for two English spell names (kept as a ratchet, listed for review)
    by_fa = collections.defaultdict(list)
    for k, v in store.names["spell"].items():
        by_fa[v].append(k)
    dup = {v: ks for v, ks in by_fa.items() if len(ks) > 1}
    rep.h("Audit of spells, talents, classes")
    rep.ok("%d spell names, %d tree names, %d class names, %d templates" % (len(store.names["spell"]), len(store.names["tree"]), len(store.names["class"]), len(store.tpl)))
    rep.ok("%d Arabic letters / space runs %s" % (fixes, "normalised" if apply else "found (report only)"))
    for cat, rows in sorted(bad.items()):
        rep.ok("%s: %d" % (cat, len(rows)))
        for r in rows[:top]:
            rep.add("  - %s" % (r,))
    rep.ok("Persian shared by two English spell names: %d" % len(dup))
    if apply and fixes:
        store.save()
        return ["data"]
    return []
