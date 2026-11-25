"""Every Persian name of one kind as plain work shards for reading: ci/reports/dump/<kind>_NN.txt,
'english = persian' per line, sorted by the English words read from the LAST word backwards, so every
'... Guard', '... Shaman', '... Raider' stands together and its Persian can be compared at a glance.
args: kind (npc | boss | zone | quest), per (lines per shard, default 800).
"""
import json
import os
import re
import urllib.request

from wfa.store import Store


def fetch(repo, path, ref="main"):
    url = "https://api.github.com/repos/pvwvuow/%s/contents/%s?ref=%s" % (repo, path, ref)
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""),
                                               "Accept": "application/vnd.github.raw", "User-Agent": "wowfa2-ci"})
    with urllib.request.urlopen(req, timeout=180) as r:
        return r.read().decode("utf-8")


def rows_of(store, kind):
    if kind != "quest":
        return list(store.names.get(kind, {}).items())
    data = json.loads(fetch("wow-raw", "fdb/latest/quests.json"))
    rows = data.get("quests") if isinstance(data, dict) else data
    if isinstance(rows, dict):
        rows = list(rows.values())
    out = []
    for q in rows or []:
        rec = store.quests.get(int(q.get("id") or 0))
        if rec and rec.get("t") and q.get("name"):
            fa = re.sub("\\{\\{[a-z]+:([^|}]*)\\|?([^}]*)\\}\\}", lambda m: m.group(2) or m.group(1), rec["t"])
            out.append((q["name"].strip(), fa))
    return out


def run(args, rep):
    store = Store.load()
    kind = args.get("kind", "npc")
    per = int(args.get("per", 800))
    rows = [(en, fa) for en, fa in rows_of(store, kind) if isinstance(fa, str) and fa]
    rows.sort(key=lambda r: (list(reversed(re.findall("[a-z0-9']+", r[0].lower()))), r[0].lower()))
    d = "ci/reports/dump"
    os.makedirs(d, exist_ok=True)
    for f in os.listdir(d):
        if f.startswith(kind + "_"):
            os.remove(os.path.join(d, f))
    paths = []
    for k in range(0, len(rows), per):
        p = "%s/%s_%02d.txt" % (d, kind, k // per)
        with open(p, "w", encoding="utf-8", newline="\n") as fh:
            fh.write("\n".join("%s = %s" % r for r in rows[k:k + per]) + "\n")
        paths.append(p)
    rep.ok("%s: %d names in %d shards" % (kind, len(rows), len(paths)))
    return paths
