"""Apply reviewed NPC name corrections ({english key: new Persian} in ci/data/*.json) and carry the change into
the texts: the OLD Persian of every changed name is replaced inside full markers {{fam:EN|OLD}} (only when EN is
the corrected name itself) and, for names of >= min_letters, as plain text in the quest texts and the templates.

args: files [repo paths], check {file: [sha1[:6] per 20 sorted items]}, min_letters (6), tpl (true), table (npc)
"""
import collections
import hashlib
import json
import pathlib
import re

from wfa.core import MARKER_RE
from wfa.store import Store

SKIP = re.compile(r"\{\{[^{}]*\}\}|\{\d+\}|<[^<>]*>|\$[GgNnCcRrBb](?:[^;:\s]*:[^;]*;)?|\|c[0-9a-fA-F]{8}|\|r")
PERS = "\u0621-\u063a\u0641-\u064a\u0670\u0679-\u06d3\u06f0-\u06f9\u200c"
FIELDS = ("t", "obj", "det", "pro", "com", "desc")
_P = pathlib.Path(__file__).resolve().parents
ROOT = _P[3] if len(_P) > 3 else pathlib.Path.cwd()


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
    table = store.names[args.get("table", "npc")]
    fixes = {}
    check = args.get("check") or {}
    bad = []
    for f in args.get("files") or []:
        part = json.loads((ROOT / f).read_text(encoding="utf-8"))
        want = check.get(f)
        if want is not None:
            items = sorted(part.items())
            got = [hashlib.sha1(json.dumps(items[i:i + 20]).encode()).hexdigest()[:6]
                   for i in range(0, len(items), 20)]
            if len(got) != len(want):
                bad.append("%s: %d groups, expected %d" % (f, len(got), len(want)))
            for i, (g, w) in enumerate(zip(got, want)):
                if g != w:
                    bad.append("%s group %d (%s ... ) differs" % (f, i, items[i * 20][0]))
        fixes.update(part)
    rep.h("Corrections")
    if bad:
        rep.fail("data check failed")
        rep.add("\n".join(bad))
        return []
    rep.ok("%d corrections read" % len(fixes))
    missing, same, pairs = [], 0, {}
    keys_of = collections.defaultdict(set)
    for key, new in fixes.items():
        old = table.get(key)
        if old is None:
            missing.append(key)
        elif old == new:
            same += 1
        else:
            table[key] = new
            pairs.setdefault(old, new)
            keys_of[old].add(key)
    rep.ok("%d set, %d already like that, %d keys not in the table" % (len(pairs), same, len(missing)))
    if missing:
        rep.add("missing: " + "; ".join(missing[:40]))

    # ---- carry the change into the texts
    min_letters = int(args.get("min_letters", 6))
    plain = []
    for o, n in pairs.items():
        # a plain mention is only rewritten when this old Persian belonged to ONE english name
        if len(keys_of[o]) == 1 and len(o.replace("\u200c", "").replace(" ", "")) >= min_letters and "{" not in o:
            plain.append((o, n, re.compile("(?<![%sA-Za-z0-9])%s(?![%sA-Za-z0-9])" % (PERS, re.escape(o), PERS))))
    count_marker = collections.Counter()
    count_plain = collections.Counter()

    def marker_sub(m):
        fa = m.group(3)
        if fa is not None and fa in pairs:
            en = m.group(2).lower().replace("\u2019", "'").strip()
            if en in keys_of[fa]:
                count_marker[fa] += 1
                return "{{%s:%s|%s}}" % (m.group(1), m.group(2), table.get(en, pairs[fa]))
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
        for f in FIELDS:
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
    if args.get("tpl", True):
        for k, v in list(store.tpl.items()):
            if isinstance(v, str):
                new = fix(v)
                if new != v:
                    store.tpl[k] = new
                    changed += 1
    rep.h("Texts")
    rep.ok("%d text fields rewritten; %d full markers and %d plain mentions followed the new name" % (
        changed, sum(count_marker.values()), sum(count_plain.values())))
    rows = sorted(((o, pairs[o], count_marker.get(o, 0), count_plain.get(o, 0)) for o in pairs
                   if count_marker.get(o, 0) or count_plain.get(o, 0)), key=lambda r: -(r[2] + r[3]))
    rep.table(rows[:40], ["old", "new", "in markers", "as plain text"])
    store.save()
    return ["data"]
