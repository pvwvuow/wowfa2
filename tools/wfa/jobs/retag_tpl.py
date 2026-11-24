"""Fix the family of spell names inside the description templates and list English leaks.

1. A marker whose English text is a (multi-word) spell name that the template key really names, but
   which is written as {{tm:..}} / {{npc:..}} / {{cls:..}} ..., becomes the short {{sp:name}} (the
   Persian then comes from data/names/spell: one spelling for one spell).
2. A full {{sp:EN|FA}} whose FA differs from the table becomes the short {{sp:EN}}.
3. Report: every short marker {{fam:EN}} whose name is not in its table (it would show English
   inside a Persian sentence), grouped by family.

args: apply (false = report), top (rows).
"""
import collections
import re

from wfa.core import MARKER_KIND, MARKER_RE, name_key
from wfa.store import Store


def run(args, rep):
    store = Store.load()
    apply = bool(args.get("apply"))
    top = int(args.get("top", 60))
    spells = store.names["spell"]
    multi = {k for k in spells if len(k.split()) >= 2}
    moved = collections.Counter()
    unified = collections.Counter()
    leaks = collections.defaultdict(collections.Counter)
    new_tpl = {}
    for tk, tv in store.tpl.items():
        low = tk.lower()

        def sub(m):
            fam, en, fa = m.group(1), m.group(2), m.group(3)
            key = name_key(en)
            if fam != "sp" and fam not in ("qs", "set") and key in multi and re.search(r"(?<![a-z'])%s(?![a-z])" % re.escape(key), low):
                moved[(fam, key)] += 1
                return "{{sp:%s}}" % key
            if fam == "sp" and fa is not None and spells.get(key) not in (None, fa):
                unified[key] += 1
                return "{{sp:%s}}" % en
            return m.group(0)
        nv = MARKER_RE.sub(sub, tv)
        if nv != tv:
            new_tpl[tk] = nv
        for m in MARKER_RE.finditer(nv):
            fam, en, fa = m.group(1), m.group(2), m.group(3)
            t = MARKER_KIND.get(fam)
            if fa is None and t and name_key(en) not in store.names.get(t, {}):
                leaks[fam][name_key(en)] += 1
    rep.h("Moved to the spell family")
    rep.ok("%d templates change; %d markers moved to sp; %d full sp markers unified with the table"
           % (len(new_tpl), sum(moved.values()), sum(unified.values())))
    rep.table([(f, k, n) for (f, k), n in moved.most_common(top)], ["was", "spell", "times"])
    rep.h("Unresolved short markers (English would show inside Persian text)")
    for fam, c in sorted(leaks.items()):
        rep.ok("%s: %d different, %d uses" % (fam, len(c), sum(c.values())))
        rep.add(", ".join("%s x%d" % (k, n) for k, n in c.most_common(top)))
    if not apply:
        rep.ok("report only")
        return []
    for k, v in new_tpl.items():
        store.tpl[k] = v
    store.save()
    return ["data"]
