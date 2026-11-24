"""Publish a DRAFT release of pvwvuow/wowfarsi-addon (the owner asked the bot to press Publish).
args: {"tag": "forever-v1.0.0-beta.2"}. Checks that the draft exists and carries the WoWFA zip, then
turns it into a published pre-release. Publishing with BOT_TOKEN fires the release `published` event,
so the CurseForge workflow of wowfarsi-addon runs. Nothing is committed."""
import json
import os
import subprocess

REPO = "pvwvuow/wowfarsi-addon"


def run(args, rep):
    tag = str(args.get("tag", "")).strip()
    rep.h("Publish")
    if not tag.startswith("forever-v"):
        rep.fail("tag %r is not a WoWFA Forever tag" % tag)
        return []
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    v = subprocess.run(["gh", "release", "view", tag, "--repo", REPO, "--json", "isDraft,tagName,assets,name"],
                       env=env, text=True, capture_output=True)
    if v.returncode:
        rep.fail("release %s not found: %s" % (tag, (v.stderr or "").strip()[:300]))
        return []
    info = json.loads(v.stdout)
    zips = [a.get("name", "") for a in info.get("assets", []) if a.get("name", "").endswith(".zip")]
    rep.add("- %s: draft=%s, zip=%s" % (info.get("name"), info.get("isDraft"), ", ".join(zips) or "none"))
    if not zips:
        rep.fail("the release has no zip: not published")
        return []
    if not info.get("isDraft"):
        rep.ok("already published, nothing to do")
        return []
    p = subprocess.run(["gh", "release", "edit", tag, "--repo", REPO, "--draft=false", "--prerelease",
                        "--tag", tag], env=env, text=True, capture_output=True)
    if p.returncode:
        rep.fail("publish failed: %s" % (p.stderr or "").strip()[:300])
        return []
    rep.ok("published %s (pre-release); the CurseForge workflow of wowfarsi-addon starts now" % tag)
    return []
