"""Mark a published wowfarsi-addon release as a full release (not pre-release) and Latest
(owner, 25 Nov 2026: "why is 1.0.6 Pre-release on GitHub if it is released?"). CurseForge already
gets every upload as type release; this only changes the GitHub label.
args: {"tag": "forever-v1.0.6-beta", "prerelease": false}"""
import json
import os
import subprocess

REPO = "pvwvuow/wowfarsi-addon"


def run(args, rep):
    tag = str(args["tag"])
    pre = bool(args.get("prerelease", False))
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    cmd = ["gh", "release", "edit", tag, "--repo", REPO, "--prerelease=%s" % ("true" if pre else "false")]
    if not pre:
        cmd.append("--latest")
    p = subprocess.run(cmd, env=env, text=True, capture_output=True)
    if p.returncode:
        rep.fail("gh release edit: %s" % (p.stderr or p.stdout).strip()[:400])
        return []
    v = subprocess.run(["gh", "release", "view", tag, "--repo", REPO, "--json", "tagName,isDraft,isPrerelease,url"],
                       env=env, text=True, capture_output=True)
    rep.ok("%s: %s" % (tag, (v.stdout or v.stderr).strip()[:300]))
    r = subprocess.run(["gh", "api", "repos/%s/releases/latest" % REPO, "--jq", ".tag_name"],
                       env=env, text=True, capture_output=True)
    rep.add("- GitHub latest release now: %s" % (r.stdout or r.stderr).strip()[:100])
    return []
