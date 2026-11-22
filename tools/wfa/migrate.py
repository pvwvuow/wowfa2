"""One-time import of the v0 data (pvwvuow/wowfa Data/*.lua + wow quest titles) into data/.
Input `dump` = JSON written by tools/lua/dump_old.lua (real Lua parser)."""
import glob
import json
import os

from .core import NAME_KINDS, name_key, title_hash
from .resolve import AUTHORITATIVE, MARKER_RE, shorten
from .store import Store

FIELDS = ("t", "obj", "det", "pro", "com", "desc")


def load_en_titles(wow):
    titles = {}
    for p in sorted(glob.glob(os.path.join(wow, "data", "forever", "db", "quest-*.json"))):
        with open(p, encoding="utf-8") as f:
            d = json.load(f)
        qs = d.get("quests", d) if isinstance(d, dict) else d
        items = qs.items() if isinstance(qs, dict) else ((str(q.get("id")), q) for q in qs)
        for k, q in items:
            if isinstance(q, dict) and q.get("name"):
                try:
                    titles[int(k)] = q["name"].strip()
                except (TypeError, ValueError):
                    pass
    return titles


def migrate(quest_dump, tpl_dump, wow):
    rep = {"notes": [], "swaps": {}, "fills": 0, "unknown_kinds": []}
    s = Store()
    names = quest_dump.get("names", {})
    for kind, table in names.items():
        if kind not in NAME_KINDS:
            rep["unknown_kinds"].append("%s (%d rows)" % (kind, len(table)))
            continue
        for k, v in table.items():
            if isinstance(v, str) and v.strip():
                nk = name_key(k)
                if nk in s.names[kind] and s.names[kind][nk] != v:
                    rep["notes"].append("names/%s: %r and another key both normalise to %r (kept the first)" % (kind, k, nk))
                    continue
                s.names[kind][nk] = v
    # fills: an authoritative-kind marker whose key has no table row and ONE Persian everywhere
    seen = {}
    def collect(text):
        for m in MARKER_RE.finditer(text):
            from .core import MARKER_KIND
            t = MARKER_KIND.get(m.group(1))
            if t in AUTHORITATIVE and m.group(3):
                key = name_key(m.group(2))
                if key not in s.names[t]:
                    seen.setdefault((t, key), set()).add(m.group(3))
    old_q = quest_dump.get("quests", {})
    old_o = quest_dump.get("qobj", {})
    old_t = tpl_dump.get("tpl", {})
    for raw in old_q.values():
        for part in raw.split("\x1f")[1:]:
            collect(part)
    for lines in old_o.values():
        for x in lines:
            collect(x)
    for v in old_t.values():
        collect(v)
    fills = {k: next(iter(v)) for k, v in seen.items() if len(v) == 1}
    for (t, key), fa in fills.items():
        s.names[t][key] = fa
    rep["fills"] = len(fills)
    rep["fill_conflicts"] = sorted("%s:%s -> %s" % (t, k, " | ".join(sorted(v)))
                                   for (t, k), v in seen.items() if len(v) > 1)
    en_titles = load_en_titles(wow) if wow else {}
    no_hash = 0
    for k, raw in old_q.items():
        qid = int(k)
        p = raw.split("\x1f")
        p += [""] * (7 - len(p))
        if len(p) > 7:
            rep["notes"].append("q:%d has %d fields (expected 7), extra kept in desc" % (qid, len(p)))
            p = p[:6] + ["\x1f".join(p[6:])]
        en = p[0] or en_titles.get(qid, "")
        rec = {"h": title_hash(en) if en else ""}
        if not en:
            no_hash += 1
        for f, val in zip(FIELDS, p[1:]):
            if val:
                rec[f] = shorten(val, s.names, rep["swaps"], {})
        o = old_o.get(k)
        if o:
            rec["o"] = [shorten(x, s.names, rep["swaps"], {}) for x in o]
        s.quests[qid] = rec
    rep["quests_without_en_title"] = no_hash
    for k, v in old_t.items():
        s.tpl[k] = shorten(v, s.names, rep["swaps"], {})
    return s, rep


def verify(old_q, old_t, new, names):
    """Round-trip proof: v0 Data (real Lua) vs our built Data (real Lua). Every field must be
    byte-equal after authoritative markers show the table's Persian. Returns (stats, diffs)."""
    from .resolve import canon
    st = {"quests_same": 0, "quests_diff": 0, "qobj_same": 0, "qobj_diff": 0,
          "tpl_same": 0, "tpl_diff": 0, "missing": 0}
    diffs = []
    nq, no, nt = new.get("quests", {}), new.get("qobj", {}), new.get("tpl", {})
    for k, raw in old_q.get("quests", {}).items():
        if k not in nq:
            st["missing"] += 1
            diffs.append("q:%s missing in new build" % k)
            continue
        a = [canon(x, names) for x in (raw.split("\x1f") + [""] * 7)[1:7]]
        b = [canon(x, names) for x in (nq[k].split("\x1f") + [""] * 7)[1:7]]
        if a == b:
            st["quests_same"] += 1
        else:
            st["quests_diff"] += 1
            for i, (x, y) in enumerate(zip(a, b)):
                if x != y:
                    diffs.append("q:%s field %d: old=%r new=%r" % (k, i + 2, x[:120], y[:120]))
                    break
    for k, lines in old_q.get("qobj", {}).items():
        a = [canon(x, names) for x in lines]
        b = [canon(x, names) for x in no.get(k, [])]
        if a == b:
            st["qobj_same"] += 1
        else:
            st["qobj_diff"] += 1
            diffs.append("qobj:%s differs" % k)
    for k, v in old_t.get("tpl", {}).items():
        if k not in nt:
            st["missing"] += 1
            diffs.append("tpl missing: %r" % k[:80])
        elif canon(v, names) == canon(nt[k], names):
            st["tpl_same"] += 1
        else:
            st["tpl_diff"] += 1
            diffs.append("tpl %r: old=%r new=%r" % (k[:60], v[:100], nt[k][:100]))
    return st, diffs
