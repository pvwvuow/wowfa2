"""Delete stale DRAFT releases of pvwvuow/wowfarsi-addon (never a published one).
args: {"tags": [exact tag names], "prefixes": [tag prefixes]}
Only releases with draft == true whose tag matches are deleted."""
import json
import os
import subprocess

REPO = "pvwvuow/wowfarsi-addon"


def run(args, rep):
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    tags = set(args.get("tags") or [])
    prefixes = tuple(args.get("prefixes") or [])
    p = subprocess.run(["gh", "api", "--paginate", "repos/%s/releases?per_page=100" % REPO],
                       env=env, text=True, capture_output=True)
    if p.returncode:
        rep.fail("list releases: %s" % (p.stderr or p.stdout).strip()[:300])
        return []
    txt = p.stdout.replace("][", ",")
    rels = json.loads(txt or "[]")
    rep.h("drafts")
    n = 0
    for r in rels:
        tag = r.get("tag_name") or ""
        if not r.get("draft"):
            continue
        if tag in tags or (prefixes and tag.startswith(prefixes)):
            d = subprocess.run(["gh", "api", "-X", "DELETE", "repos/%s/releases/%d" % (REPO, r["id"])],
                               env=env, text=True, capture_output=True)
            if d.returncode:
                rep.fail("delete %s (%d): %s" % (tag, r["id"], (d.stderr or d.stdout).strip()[:200]))
            else:
                n += 1
                rep.add("- deleted draft %s (%d)" % (tag, r["id"]))
    rep.ok("%d stale drafts deleted" % n)
    return []
