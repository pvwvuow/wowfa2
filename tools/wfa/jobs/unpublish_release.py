"""Turn a PUBLISHED release of pvwvuow/wowfarsi-addon back into a DRAFT (owner 27 Nov 2026: pull
1.1.8.470-beta back, a newer build replaces it). Only the GitHub release is touched: CurseForge has no
API to delete a file, the author removes it on the project page. Nothing is committed.
args: {"tag": "forever-v1.1.8.470-beta"}"""
import json
import os
import subprocess

REPO = "pvwvuow/wowfarsi-addon"


def run(args, rep):
    tag = str(args.get("tag", "")).strip()
    rep.h("Unpublish")
    if not tag.startswith("forever-v"):
        rep.fail("tag %r is not a WoWFA Forever tag" % tag)
        return []
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    v = subprocess.run(["gh", "release", "view", tag, "--repo", REPO, "--json", "isDraft,name"],
                       env=env, text=True, capture_output=True)
    if v.returncode:
        rep.fail("release %s not found: %s" % (tag, (v.stderr or "").strip()[:300]))
        return []
    info = json.loads(v.stdout)
    if info.get("isDraft"):
        rep.ok("%s is already a draft, nothing to do" % tag)
        return []
    p = subprocess.run(["gh", "release", "edit", tag, "--repo", REPO, "--draft=true"],
                       env=env, text=True, capture_output=True)
    if p.returncode:
        rep.fail("could not turn %s back into a draft: %s" % (tag, (p.stderr or "").strip()[:300]))
        return []
    rep.ok("%s is a draft again (CurseForge file stays until the author deletes it there)" % tag)
    return []
