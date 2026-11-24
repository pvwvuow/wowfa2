"""Coverage of the ForeverDB quest list (pvwvuow/wow-raw fdb/latest/quests.json: id, level, name,
zone, quest giver and turn-in NPC) against data/quests and data/names/npc|boss.

ForeverDB has no quest TEXT, so a quest counts as covered when data/quests has its record, and as
partial when the record lacks a field (t title, obj objectives text, det description, o objective
lines). Quest giver / turn-in NPCs are checked by name. Everything missing is written to
ci/reports/quest_cov.json; the report shows counts per level band and the top rows.
args: ref (default main), top (rows per list in the report).
"""
import json
import os
import urllib.request

from wfa.core import name_key
from wfa.store import Store

FIELDS = ("t", "obj", "det")


def fetch(repo, path, ref):
    url = "https://api.github.com/repos/pvwvuow/%s/contents/%s?ref=%s" % (repo, path, ref)
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""),
                                               "Accept": "application/vnd.github.raw", "User-Agent": "wowfa2-ci"})
    with urllib.request.urlopen(req, timeout=180) as r:
        return r.read().decode("utf-8")


def band(lv):
    try:
        lv = int(lv)
    except Exception:
        return "?"
    if lv <= 0:
        return "?"
    lo = ((lv - 1) // 10) * 10 + 1
    return "%02d-%02d" % (lo, lo + 9)


def run(args, rep):
    store = Store.load()
    ref = args.get("ref", "main")
    top = int(args.get("top", 40))
    quests = getattr(store, "quests", None)
    if not isinstance(quests, dict):
        rep.fail("Store has no quests dict")
        return []
    try:
        data = json.loads(fetch("wow-raw", "fdb/latest/quests.json", ref))
    except Exception as e:
        rep.fail("cannot read wow-raw quests.json: %s" % e)
        return []
    rows = data.get("quests") if isinstance(data, dict) else data
    if isinstance(rows, dict):
        rows = list(rows.values())
    npc = store.names.get("npc", {})
    boss = store.names.get("boss", {})
    missing, partial, npc_miss = [], [], {}
    bands = {}
    for q in rows:
        if not isinstance(q, dict):
            continue
        qid = str(q.get("id"))
        lv = q.get("level")
        b = band(lv)
        st = bands.setdefault(b, {"fdb": 0, "missing": 0, "partial": 0})
        st["fdb"] += 1
        zone = (q.get("zone") or {}).get("n") if isinstance(q.get("zone"), dict) else q.get("category")
        rec = quests.get(int(q.get("id") or 0))
        if rec is None:
            st["missing"] += 1
            missing.append([int(q.get("id") or 0), lv, q.get("name"), zone, bool(q.get("knownInForever"))])
        else:
            lack = [f for f in FIELDS if not rec.get(f)]
            if lack:
                st["partial"] += 1
                partial.append([int(q.get("id") or 0), lv, q.get("name"), ",".join(lack)])
        for role in ("starts", "ends"):
            who = q.get(role) or {}
            if not isinstance(who, dict) or who.get("type") != "npc":
                continue
            en = (who.get("name") or "").strip()
            if not en:
                continue
            k = name_key(en)
            if k in npc or k in boss:
                continue
            e = npc_miss.setdefault(en, {"name": en, "id": who.get("id"), "level": 0, "zone": "", "quests": 0})
            e["quests"] += 1
            try:
                if int(lv or 0) > e["level"]:
                    e["level"] = int(lv or 0)
                    e["zone"] = ((who.get("location") or {}).get("zone") if isinstance(who.get("location"), dict) else "") or zone or ""
            except Exception:
                pass
    rep.h("ForeverDB quests vs data")
    rep.ok("%d ForeverDB quests, %d quest records in data" % (len(rows), len(quests)))
    tab = [(b, s["fdb"], s["missing"], s["partial"]) for b, s in sorted(bands.items())]
    rep.table(tab, ["level", "ForeverDB quests", "no Persian record", "record lacks a field"])
    missing.sort(key=lambda r: (-(r[1] or 0), r[0]))
    partial.sort(key=lambda r: (-(r[1] or 0), r[0]))
    nm = sorted(npc_miss.values(), key=lambda e: (-e["level"], e["name"]))
    rep.h("Missing quests (highest level first)")
    rep.add("; ".join("%s L%s %s (%s)" % (r[0], r[1], r[2], r[3]) for r in missing[:top]) or "none")
    rep.h("Partial quests")
    rep.add("; ".join("%s L%s %s [%s]" % (r[0], r[1], r[2], r[3]) for r in partial[:top]) or "none")
    rep.h("Quest NPCs without a Persian name: %d" % len(nm))
    rep.add("; ".join("%s (L%s %s)" % (e["name"], e["level"], e["zone"]) for e in nm[:top * 2]) or "none")
    os.makedirs("ci/reports", exist_ok=True)
    with open("ci/reports/quest_cov.json", "w", encoding="utf-8", newline="\n") as fh:
        json.dump({"missing": missing, "partial": partial, "npc": nm}, fh, ensure_ascii=False, indent=1)
        fh.write("\n")
    return ["ci/reports/quest_cov.json"]
