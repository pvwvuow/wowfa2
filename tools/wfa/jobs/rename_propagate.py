"""After a name was corrected in data/names, the OLD Persian can still stand in other places: inside a full
marker {{fam:EN|OLD}} and as plain text in the quest texts / templates. This job rewrites those, so the
texts do not show two spellings of one name.

args: pairs [[old, new], ...], fields (default every quest text field + o + t), tpl (true = also the templates),
      min_letters (default 5: a shorter old string is never replaced as plain text), apply
"""
import collections
import re

from wfa.core import MARKER_RE
from wfa.store import Store

SKIP = re.compile(r"\{\{[^{}]*\}\}|\{\d+\}|<[^<>]*>|\$[GgNnCcRrBb](?:[^;:\s]*:[^;]*;)?|\|c[0-9a-fA-F]{8}|\|r")
PERS = "\u0621-\u063a\u0641-\u064a\u0670\u0679-\u06d3\u06f0-\u06f9\u200c"
FIELDS = ("t", "obj", "det", "pro", "com", "desc")


def each_seg(text, fn):
    out, pos = [], 0
    for m in SKIP.finditer(text):
        out.append(fn(text[pos:m.start()]))
        out.append(m.group(0))
        pos = m.end()
    out.append(fn(text[pos:]))
    return "".join(out)


def run(args, rep):
    store = Store.load()
    pairs = [(o, n) for o, n in args.get("pairs") or [] if o and n and o != n]
    min_letters = int(args.get("min_letters", 5))
    plain = []
    for o, n in pairs:
        letters = len(o.replace("\u200c", "").replace(" ", ""))
        if letters >= min_letters:
            plain.append((o, n, re.compile("(?<![%sA-Za-z0-9])%s(?![%sA-Za-z0-9])" % (PERS, re.escape(o), PERS))))
    old_to_new = dict(pairs)
    count_marker = collections.Counter()
    count_plain = collections.Counter()

    def marker_sub(m):
        fa = m.group(3)
        if fa is not None and fa in old_to_new:
            count_marker[fa] += 1
            return "{{%s:%s|%s}}" % (m.group(1), m.group(2), old_to_new[fa])
        return m.group(0)

    def fix(text):
        if not text:
            return text
        text = MARKER_RE.sub(marker_sub, text)

        def seg(s):
            for o, n, rx in plain:
                s, k = rx.subn(n, s)
                if k:
                    count_plain[o] += k
            return s
        return each_seg(text, seg)

    changed = 0
    for rec in store.quests.values():
        for f in args.get("fields") or FIELDS:
            v = rec.get(f)
            if isinstance(v, str) and v:
                new = fix(v)
                if new != v:
                    rec[f] = new
                    changed += 1
        o = rec.get("o")
        if o:
            out = [fix(v) for v in o]
            if out != o:
                changed += 1
                rec["o"] = out
    if args.get("tpl"):
        for k, v in list(store.tpl.items()):
            if isinstance(v, str):
                new = fix(v)
                if new != v:
                    store.tpl[k] = new
                    changed += 1
    rep.h("Rewritten")
    rep.ok("%d fields changed" % changed)
    rows = [(o, n, count_marker.get(o, 0), count_plain.get(o, 0)) for o, n in pairs]
    rep.table(rows, ["old", "new", "in markers", "as plain text"])
    if not changed:
        return []
    store.save()
    return ["data"]
