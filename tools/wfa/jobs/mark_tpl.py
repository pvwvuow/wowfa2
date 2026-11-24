"""Mark spell / talent names inside the description templates (data/tpl).

A template key is the English description; when it names a spell (a multi-word name from
data/names/spell) and the Persian value writes that spell's Persian name as plain text, the plain
name becomes {{sp:<name>}} (resolved from the name table at build, coloured and switchable like any
other spell name). Where the value does NOT contain the table's Persian (a variant wording, or the
name written through another marker) nothing is changed and the case is listed.

args: apply (false = report), min_words (2), min_len (5), top (rows).
"""
import collections
import re

from wfa.core import MARKER_RE
from wfa.store import Store

PERS = "\u0600-\u06ff\u200c"
SKIP = re.compile(r"\{\{[^{}]*\}\}|\{\d+\}|<[^<>]*>|\|c[0-9a-fA-F]{8}|\|r")


def segs(text, fn):
    out, pos = [], 0
    for m in SKIP.finditer(text):
        out.append(fn(text[pos:m.start()]))
        out.append(m.group(0))
        pos = m.end()
    out.append(fn(text[pos:]))
    return "".join(out)


def run(args, rep):
    store = Store.load()
    apply = bool(args.get("apply"))
    min_words = int(args.get("min_words", 2))
    min_len = int(args.get("min_len", 5))
    top = int(args.get("top", 80))
    names = {k: v for k, v in store.names["spell"].items()
             if len(k.split()) >= min_words and len(v) >= min_len and not re.search(r"[A-Za-z0-9{}|]", v)}
    order = sorted(names, key=lambda s: (-len(s), s))
    rep.h("Spell names used")
    rep.ok("%d multi-word spell names, %d templates" % (len(names), len(store.tpl)))
    marked = collections.Counter()
    variants = []
    new_tpl = {}
    for tk, tv in store.tpl.items():
        low = tk.lower()
        taken = []
        value = tv
        for s in order:
            if s not in low:
                continue
            if not re.search(r"(?<![a-z'])%s(?![a-z])" % re.escape(s), low):
                continue
            if any(s in t for t in taken):
                continue
            taken.append(s)
            have = any(m.group(1) == "sp" and re.sub(r"\s+", " ", m.group(2).lower().strip()) == s
                       for m in MARKER_RE.finditer(value))
            if have:
                continue
            fa = names[s]
            rx = re.compile("(?<![%s0-9A-Za-z])%s(?![%s0-9A-Za-z])" % (PERS, re.escape(fa), PERS))
            hit = [0]

            def sub(seg):
                def r(mm):
                    hit[0] += 1
                    return "{{sp:%s}}" % s
                return rx.sub(r, seg)
            newv = segs(value, sub)
            if hit[0]:
                value = newv
                marked[s] += hit[0]
            else:
                variants.append((s, fa, tk[:90], tv[:150]))
        if value != tv:
            new_tpl[tk] = value
    rep.h("Marked")
    rep.ok("%d templates change, %d spell names marked (%d different)" % (len(new_tpl), sum(marked.values()), len(marked)))
    rep.table(marked.most_common(top), ["spell", "times"])
    rep.h("Variants: the key names the spell but the Persian value does not hold the table's name")
    rep.ok("%d cases" % len(variants))
    for s, fa, k, v in variants[:top]:
        rep.add("- %s (%s) | KEY %s | VAL %s" % (s, fa, k, v))
    if not apply:
        rep.ok("report only")
        return []
    for k, v in new_tpl.items():
        store.tpl[k] = v
    store.save()
    return ["data"]
