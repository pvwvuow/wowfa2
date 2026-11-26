"""Rebuild the zip from main and REPLACE it in the existing DRAFT of pvwvuow/wowfarsi-addon (same
tag, same asset name, --clobber); the notes are replaced too. A PUBLISHED release is never touched
(bump the version instead). No release with that tag yet = the normal draft is created.
args: {"notes": text}"""
import json
import os
import subprocess

from wfa import tasks as T
from wfa.core import OUT, ROOT, read_json


def run(args, rep):
    from wfa import build as B
    from wfa.store import Store
    rep.h("Release redraft")
    pol = read_json(os.path.join(ROOT, "policy.json"))
    tag = "forever-v" + pol["version"]
    repo = T.OWNER + "/wowfarsi-addon"
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    p = subprocess.run(["gh", "release", "view", tag, "--repo", repo, "--json", "isDraft,assets"],
                       env=env, text=True, capture_output=True)
    if p.returncode:
        rep.add("- no release %s yet (%s): creating the draft" % (tag, (p.stderr or "").strip()[:200]))
        T.task_release({"args": {"notes": args.get("notes", "")}}, rep)
        return []
    info = json.loads(p.stdout or "{}")
    if not info.get("isDraft"):
        rep.fail("%s is already PUBLISHED: not touched (bump the version)" % tag)
        return []
    counts, zpath, _ = B.build(Store.load(), pol)
    subprocess.run(["gh", "release", "upload", tag, zpath, "--repo", repo, "--clobber"], env=env, check=True)
    notes_md = os.path.join(OUT, "release-notes.md")
    with open(notes_md, "w", encoding="utf-8") as f:
        f.write(args.get("notes", "WoWFA %s" % pol["version"]) + "\n")
    subprocess.run(["gh", "release", "edit", tag, "--repo", repo, "--notes-file", notes_md], env=env, check=True)
    rep.ok("draft %s: %s replaced (%d bytes), notes updated" % (tag, os.path.basename(zpath), os.path.getsize(zpath)))
    rep.table(sorted(counts.items()), ["table", "rows"])
    return []
