"""List (and optionally translate) the Latin <tags> inside the quest texts: <cough>, <snort>,
<priests or priestesses> ... They are emotes / gender choices the game prints in angle brackets.

args: apply (false = report only), map ({"cough": "Persian", ...}; a key is the tag text without the
angle brackets, lower case), top (rows of the report).
"""
import collections
import re

from wfa.store import Store

FIELDS = ("obj", "det", "pro", "com", "desc")
TAG = re.compile(r"<([A-Za-z][^<>\n$|{}]{0,60})>")


def run(args, rep):
    store = Store.load()
    top = int(args.get("top", 150))
    mapping = {k.lower(): v for k, v in (args.get("map") or {}).items()}
    apply = bool(args.get("apply"))
    cnt = collections.Counter()
    for rec in store.quests.values():
        for f in FIELDS:
            for m in TAG.finditer(rec.get(f) or ""):
                cnt[m.group(1).strip().lower()] += 1
    rep.h("Latin <tags> in the quest texts")
    rep.ok("%d different tags, %d uses; %d mapped" % (len(cnt), sum(cnt.values()), sum(1 for t in cnt if t in mapping)))
    rep.table([(t, n, "mapped" if t in mapping else "") for t, n in cnt.most_common(top)], ["tag", "uses", "state"])
    if not apply or not mapping:
        rep.ok("report only: nothing written")
        return []
    changed = 0

    def sub(m):
        fa = mapping.get(m.group(1).strip().lower())
        return "<%s>" % fa if fa else m.group(0)

    for rec in store.quests.values():
        for f in FIELDS:
            t = rec.get(f)
            if t:
                new = TAG.sub(sub, t)
                if new != t:
                    rec[f] = new
                    changed += 1
    rep.ok("%d quest fields rewritten" % changed)
    store.save()
    return ["data"]
