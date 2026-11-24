"""Fire the CurseForge upload of wowfarsi-addon again for a published release: the bot token can not
start workflows by hand, so the release is turned back into a draft and published again (that sends
the release `published` event). A release run uses the workflow file AT THE TAG, so with
retag=true the tag is deleted while the release is a draft and published again on the current main
(the newest workflow). notes_replace=[[old, new], ...] edits the release notes first (curl -F in
the CurseForge workflow cuts a value at ';', so notes must not hold one). Then the run's printed
lines are read into the report.
args: {"tag": "forever-v1.0.1-beta", "retag": false, "notes_replace": [[";", ","]]}. Nothing is committed."""
import importlib.util
import json
import os
import subprocess
import tempfile
import time

REPO = "pvwvuow/wowfarsi-addon"
HERE = os.path.dirname(os.path.abspath(__file__))


def _load(name):
    spec = importlib.util.spec_from_file_location("wfa_job_" + name, os.path.join(HERE, name + ".py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _gh(env, *a):
    p = subprocess.run(["gh"] + list(a), env=env, text=True, capture_output=True)
    return p.returncode, (p.stdout or "").strip(), (p.stderr or "").strip()


def run(args, rep):
    tag = str(args.get("tag", "")).strip()
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    rep.h("Re-publish")
    reps = args.get("notes_replace") or []
    if reps:
        c, o, e = _gh(env, "release", "view", tag, "--repo", REPO, "--json", "body")
        if c:
            rep.fail("could not read the notes of %s: %s" % (tag, e[:300]))
            return []
        body = json.loads(o).get("body") or ""
        new = body
        for a, b in reps:
            new = new.replace(a, b)
        if new != body:
            with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as fh:
                fh.write(new)
                path = fh.name
            c, o, e = _gh(env, "release", "edit", tag, "--repo", REPO, "--notes-file", path)
            rep.add("- notes cleaned: %s" % ("ok" if c == 0 else e[:200]))
        else:
            rep.add("- notes had nothing to clean")
    c, o, e = _gh(env, "release", "edit", tag, "--repo", REPO, "--draft=true")
    if c:
        rep.fail("could not turn %s back into a draft: %s" % (tag, e[:300]))
        return []
    rep.add("- %s is a draft again" % tag)
    if args.get("retag"):
        c, o, e = _gh(env, "api", "-X", "DELETE", "repos/%s/git/refs/tags/%s" % (REPO, tag))
        rep.add("- old tag removed: %s" % ("ok" if c == 0 else e[:200]))
        c, o, e = _gh(env, "release", "edit", tag, "--repo", REPO, "--target", "main")
        rep.add("- target set to main: %s" % ("ok" if c == 0 else e[:200]))
    time.sleep(5)
    _load("publish_release").run({"tag": tag}, rep)
    time.sleep(70)
    _load("cf_log").run({}, rep)
    return []
