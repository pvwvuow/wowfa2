"""Is our raw game data current? (owner, 25 Nov 2026: "the game updated, are we up to date?")
Report only: the last runs of the pvwvuow/wow-raw workflows (fetch, hotfix-feed, fdb-fetch), the runner
variable / runners when the token may read them, tables/products.json, the newest captured build in
manifests/index.json and the newest builds wago.tools lists. Nothing is written.
args: {}"""
import json
import os
import subprocess
import urllib.request

RAW = "pvwvuow/wow-raw"


def gh(env, *a):
    p = subprocess.run(["gh"] + list(a), env=env, text=True, capture_output=True)
    return p.returncode, (p.stdout or ""), (p.stderr or "")


def run(args, rep):
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    rep.h("wow-raw workflow runs")
    for wf in ("fetch.yml", "hotfix-feed.yml", "fdb-fetch.yml"):
        c, o, e = gh(env, "run", "list", "--repo", RAW, "--workflow", wf, "--limit", "5",
                     "--json", "databaseId,status,conclusion,event,createdAt")
        if c:
            rep.add("- %s: error %s" % (wf, e.strip()[:200]))
            continue
        for r in json.loads(o or "[]"):
            rep.add("- %s %s %s/%s %s" % (wf, r.get("createdAt"), r.get("status"), r.get("conclusion"), r.get("event")))
    rep.h("runner")
    for path in ("repos/%s/actions/variables" % RAW, "repos/%s/actions/runners" % RAW,
                 "repos/pvwvuow/wowfa2/actions/runners"):
        c, o, e = gh(env, "api", path)
        rep.add("- %s: %s" % (path, (o if c == 0 else e).strip()[:600]))
    rep.h("captured builds")
    for path in ("manifests/index.json", "tables/products.json"):
        c, o, e = gh(env, "api", "repos/%s/contents/%s" % (RAW, path), "-H", "Accept: application/vnd.github.raw")
        rep.add("%s:\n```\n%s\n```" % (path, (o if c == 0 else e).strip()[:2500]))
    rep.h("wago.tools builds")
    try:
        req = urllib.request.Request("https://wago.tools/api/builds", headers={"User-Agent": "wowfa2-ci", "Accept": "application/json"})
        with urllib.request.urlopen(req, timeout=60) as r:
            builds = json.loads(r.read().decode("utf-8"))
    except Exception as e:  # noqa: BLE001
        rep.fail("wago.tools: %s" % e)
        return []
    rows = []
    items = builds.items() if isinstance(builds, dict) else []
    for prod, lst in items:
        if not isinstance(lst, list) or not lst:
            continue
        vers = [str((b or {}).get("version") or "") for b in lst[:3] if isinstance(b, dict)]
        when = str((lst[0] or {}).get("created_at") or "") if isinstance(lst[0], dict) else ""
        if any(v.startswith("1.") for v in vers) or "forever" in prod.lower():
            rows.append((prod, ", ".join(vers), when))
    rep.table(rows, ["product", "newest builds", "first seen"])
    rep.ok("wago products listed: %d (classic-like shown: %d)" % (len(builds) if isinstance(builds, dict) else 0, len(rows)))
    return []
