"""Questie's own Forever database (github.com/Questie/QuestieDB, data/Forever/foreverQuestDB.lua and
foreverNpcDB.lua) against data/: every quest id and NPC name Questie can show on the map or in a
tooltip, and whether we have its Persian title / name.

Writes ci/reports/questie_cov.json: quests_missing [id, name], quests_no_title [id, name],
quests_extra_ours (ids we have that Questie does not know), npc_missing [name, subname].
args: top (rows shown in the report), ref (default: default branch).
"""
import json
import os
import re
import urllib.request

from wfa.core import name_key
from wfa.store import Store

API = "https://api.github.com/repos/Questie/QuestieDB/contents/data/Forever/%s"
SKIP = re.compile(r"unused|placeholder|\btest|tester|\bfoo\b|gm can see|spawn point|waypoint|\bdnd\b|zzold|deprecated|copyright|aaa special", re.I)
LINE = re.compile(r'^\s*\[(\d+)\]\s*=\s*\{\s*"((?:[^"\\]|\\.)*)"(?:\s*,\s*(?:"((?:[^"\\]|\\.)*)"|nil))?', re.M)


def get(name, ref):
    url = API % name + (("?ref=" + ref) if ref else "")
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""),
                                               "Accept": "application/vnd.github.raw", "User-Agent": "wowfa2-ci"})
    with urllib.request.urlopen(req, timeout=300) as r:
        return r.read().decode("utf-8", "replace")


def unesc(s):
    return s.replace("\\'", "'").replace('\\"', '"').replace("\\\\", "\\").replace("\\n", " ")


def run(args, rep):
    store = Store.load()
    ref = args.get("ref", "")
    top = int(args.get("top", 60))
    try:
        qsrc = get("foreverQuestDB.lua", ref)
        nsrc = get("foreverNpcDB.lua", ref)
    except Exception as e:
        rep.fail("cannot read the QuestieDB files: %s" % e)
        return []
    rep.h("Source")
    rep.ok("foreverQuestDB.lua %d KB, foreverNpcDB.lua %d KB" % (len(qsrc) // 1024, len(nsrc) // 1024))
    rep.add("quest file starts: " + qsrc[:240].replace("\n", " | "))
    rep.add("npc file starts: " + nsrc[:240].replace("\n", " | "))
    for label, src in (("quest", qsrc), ("npc", nsrc)):
        ls = [x for x in src.split("\n") if re.match("\\s*\\[\\d+\\]", x)][:3]
        rep.add("%s data lines: %s" % (label, " || ".join(x[:160] for x in ls)))
    qs = {}
    for m in LINE.finditer(qsrc):
        qs[int(m.group(1))] = unesc(m.group(2))
    ns = {}
    for m in LINE.finditer(nsrc):
        ns[int(m.group(1))] = (unesc(m.group(2)), unesc(m.group(3) or ""))
    if not ns:
        alt = re.compile(r"^\s*\[(\d+)\]\s*=\s*\{\s*'((?:[^'\\]|\\.)*)'(?:\s*,\s*(?:'((?:[^'\\]|\\.)*)'|nil))?", re.M)
        for m in alt.finditer(nsrc):
            ns[int(m.group(1))] = (unesc(m.group(2)), unesc(m.group(3) or ""))
    rep.ok("parsed %d quests and %d NPCs" % (len(qs), len(ns)))
    if len(qs) < 100:
        rep.fail("the line pattern found too little; check the 'starts' lines above")
        return []
    ours = store.quests
    miss, notitle = [], []
    for qid, name in sorted(qs.items()):
        rec = ours.get(qid)
        if rec is None:
            miss.append([qid, name])
        elif not rec.get("t"):
            notitle.append([qid, name])
    extra = sorted(i for i in ours if i not in qs)
    npc = store.names.get("npc", {})
    boss = store.names.get("boss", {})
    seen, nmiss = set(), []
    for nid, (name, sub) in sorted(ns.items()):
        if not name or name.startswith("[") or "(" in name or SKIP.search(name):
            continue
        k = name_key(name)
        if k in npc or k in boss or k in seen:
            continue
        seen.add(k)
        nmiss.append([name, sub])
    rep.h("Quests")
    rep.table([("Questie knows", len(qs)), ("we have a record", len(qs) - len(miss)), ("no record at all", len(miss)),
               ("record without a title", len(notitle)), ("ours but unknown to Questie", len(extra))], ["", "count"])
    rep.add("missing: " + "; ".join("%d %s" % (i, n) for i, n in miss[:top]))
    rep.add("no title: " + "; ".join("%d %s" % (i, n) for i, n in notitle[:top]))
    rep.h("NPCs")
    rep.ok("%d NPC names in Questie have no Persian row (distinct names)" % len(nmiss))
    rep.add("; ".join("%s%s" % (n, (" <%s>" % s) if s else "") for n, s in nmiss[:top * 2]))
    os.makedirs("ci/reports", exist_ok=True)
    with open("ci/reports/questie_cov.json", "w", encoding="utf-8", newline="\n") as fh:
        json.dump({"quests_missing": miss, "quests_no_title": notitle, "quests_extra_ours": extra, "npc_missing": nmiss},
                  fh, ensure_ascii=False, indent=0)
        fh.write("\n")
    return ["ci/reports/questie_cov.json"]
