"""names.itn = the item names of quest OBJECTIVES (owner, 25 Nov 2026: user reports "0/4 Miners'
Union Card", "0/1 Thistlenettle's Badge", "0/1 Tablet of Ryun'eh" stayed English). The item
tooltips stay locked in v1.0; only the names an objective line needs are shipped:
  * every item a quest text names with a marker {{it:EN}} / {{it:EN|FA}} (names.it Persian first,
    the marker's own Persian as the fallback),
  * args.extra: more English item names (taken from names.it).
Fill-only (an existing itn row is kept). policy.json: "itn" joins ship.names, floor raised.
args: {"extra": ["miners' union card", ...]}"""
import json
import os

from wfa.core import MARKER_RE, ROOT, name_key, read_json
from wfa.store import Store


def _strings(v):
    if isinstance(v, str):
        yield v
    elif isinstance(v, dict):
        for x in v.values():
            yield from _strings(x)
    elif isinstance(v, list):
        for x in v:
            yield from _strings(x)


def run(args, rep):
    import sys
    sys.path.insert(0, os.path.join(ROOT, "tools"))
    from ci import lint_into
    store = Store.load()
    it = store.names.get("it", {})
    itn = store.names.setdefault("itn", {})
    before = len(itn)
    seen, from_it, from_marker, nofa = set(), 0, 0, []
    for rec in store.quests.values():
        for s in _strings(rec):
            for m in MARKER_RE.finditer(s):
                if m.group(1) != "it":
                    continue
                k = name_key(m.group(2))
                if not k or k in seen:
                    continue
                seen.add(k)
                if k in itn:
                    continue
                if it.get(k):
                    itn[k] = it[k]
                    from_it += 1
                elif m.group(3):
                    itn[k] = m.group(3).strip()
                    from_marker += 1
                else:
                    nofa.append(m.group(2))
    extra_ok, extra_miss = [], []
    for e in args.get("extra") or []:
        k = name_key(str(e))
        if k in itn:
            extra_ok.append("%s (already)" % k)
        elif it.get(k):
            itn[k] = it[k]
            extra_ok.append("%s -> %s" % (k, it[k]))
        else:
            extra_miss.append(k)
    store.save()
    pol_path = os.path.join(ROOT, "policy.json")
    pol = read_json(pol_path)
    ship = pol["ship"]["names"]
    if "itn" not in ship:
        ship.append("itn")
    pol.setdefault("floors", {})["names.itn"] = len(itn)
    with open(pol_path, "w", encoding="utf-8") as fh:
        json.dump(pol, fh, ensure_ascii=False, indent=1)
        fh.write("\n")
    rep.h("objective item names (names.itn)")
    rep.ok("itn %d -> %d (from names.it %d, from the markers %d), %d item markers in the quests"
           % (before, len(itn), from_it, from_marker, len(seen)))
    rep.add("- markers with no Persian anywhere: %d %s" % (len(nofa), ", ".join(nofa[:30])))
    rep.add("- extra: %s" % ("; ".join(extra_ok) or "none"))
    if extra_miss:
        rep.add("- extra NOT in names.it (need a translation): %s" % ", ".join(extra_miss))
    lint_into(rep, store, pol)
    return ["data", "policy.json"]
