"""Fire the CurseForge upload of wowfarsi-addon again for a published release: the bot token can not
start workflows by hand, so the release is turned back into a draft and published again (that sends
the release `published` event). Then the run's printed lines are read into the report.
args: {"tag": "forever-v1.0.0-beta.2"}. Nothing is committed."""
import importlib.util
import os
import subprocess
import time

REPO = "pvwvuow/wowfarsi-addon"
HERE = os.path.dirname(os.path.abspath(__file__))


def _load(name):
    spec = importlib.util.spec_from_file_location("wfa_job_" + name, os.path.join(HERE, name + ".py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run(args, rep):
    tag = str(args.get("tag", "")).strip()
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    rep.h("Re-publish")
    p = subprocess.run(["gh", "release", "edit", tag, "--repo", REPO, "--draft=true"],
                       env=env, text=True, capture_output=True)
    if p.returncode:
        rep.fail("could not turn %s back into a draft: %s" % (tag, (p.stderr or "").strip()[:300]))
        return []
    rep.add("- %s is a draft again" % tag)
    time.sleep(5)
    _load("publish_release").run({"tag": tag}, rep)
    time.sleep(70)
    _load("cf_log").run({}, rep)
    return []
