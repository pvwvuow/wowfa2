"""Report only: the shape of wow-raw fdb/latest/quests.json (English quest data of ForeverDB)
and a few full records, so the quest name marking can use the English side.
args: titles (English titles to print in full), ref (default main).
"""
import json
import os
import urllib.request


def fetch(repo, path, ref):
    url = "https://api.github.com/repos/pvwvuow/%s/contents/%s?ref=%s" % (repo, path, ref)
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""),
                                               "Accept": "application/vnd.github.raw", "User-Agent": "wowfa2-ci"})
    with urllib.request.urlopen(req, timeout=120) as r:
        return r.read().decode("utf-8")


def shape(v, depth=0):
    if isinstance(v, dict):
        return "{" + ", ".join("%s: %s" % (k, shape(x, depth + 1) if depth < 2 else type(x).__name__) for k, x in list(v.items())[:14]) + "}"
    if isinstance(v, list):
        return "[%d x %s]" % (len(v), shape(v[0], depth + 1) if v and depth < 2 else (type(v[0]).__name__ if v else "-"))
    return type(v).__name__


def run(args, rep):
    ref = args.get("ref", "main")
    try:
        raw = fetch("wow-raw", "fdb/latest/quests.json", ref)
        man = json.loads(fetch("wow-raw", "fdb/latest/manifest.json", ref))
    except Exception as e:
        rep.fail("cannot read wow-raw: %s" % e)
        return []
    data = json.loads(raw)
    rep.h("quests.json")
    rep.ok("manifest build %s; top level %s" % (man.get("build"), type(data).__name__))
    if isinstance(data, dict):
        rep.ok("keys: %s" % list(data.keys())[:20])
        items = data.get("quests") or data.get("data") or data
    else:
        items = data
    rows = list(items.values()) if isinstance(items, dict) else list(items)
    rep.ok("%d records; shape of the first: %s" % (len(rows), shape(rows[0]) if rows else "-"))
    want = [t.lower() for t in args.get("titles") or []]
    shown = 0
    for r in rows:
        title = str(r.get("title") or r.get("name") or "").lower() if isinstance(r, dict) else ""
        if title in want:
            rep.add("```")
            rep.add(json.dumps(r, ensure_ascii=False, indent=1)[:3000])
            rep.add("```")
            shown += 1
            if shown >= 4:
                break
    return []
