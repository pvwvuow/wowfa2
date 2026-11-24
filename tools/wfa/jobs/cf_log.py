"""Read the CurseForge upload runs of pvwvuow/wowfarsi-addon (the bot can not open Actions logs).
args: {"rerun_tag": ""} - when a tag is given, the workflow is started again for it first.
Writes into the report: the secret NAMES and variable names/values of the repo (never secret values),
the last runs, and the tail of the failed steps' logs. Nothing is committed."""
import json
import os
import re
import subprocess
import time

REPO = "pvwvuow/wowfarsi-addon"
WF = "curseforge-forever.yml"


def gh(env, *a):
    p = subprocess.run(["gh"] + list(a), env=env, text=True, capture_output=True)
    return p.returncode, (p.stdout or ""), (p.stderr or "")


def clean(s):
    s = re.sub(r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}", "<uuid>", s)
    s = re.sub(r"(gh[pousr]_[A-Za-z0-9]{20,})", "<token>", s)
    return s.replace("`", "'")


def run(args, rep):
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    rep.h("Settings of " + REPO)
    c, o, e = gh(env, "secret", "list", "--repo", REPO)
    rep.add("- secrets (names only): " + (", ".join(l.split()[0] for l in o.splitlines() if l.strip()) or "none")
            + ("" if c == 0 else " (could not list: %s)" % clean(e.strip())[:200]))
    c, o, e = gh(env, "variable", "list", "--repo", REPO)
    rep.add("- variables: " + ("; ".join(" ".join(l.split()[:2]) for l in o.splitlines() if l.strip()) or "none")
            + ("" if c == 0 else " (could not list: %s)" % clean(e.strip())[:200]))
    tag = str(args.get("rerun_tag", "") or "").strip()
    if tag:
        c, o, e = gh(env, "workflow", "run", WF, "--repo", REPO, "-f", "tag=" + tag)
        rep.add("- started the workflow again for %s: %s" % (tag, "ok" if c == 0 else clean(e.strip())[:300]))
        if c == 0:
            time.sleep(75)
    rep.h("Runs")
    c, o, e = gh(env, "run", "list", "--repo", REPO, "--workflow", WF, "--limit", "4",
                 "--json", "databaseId,status,conclusion,event,createdAt,displayTitle")
    if c:
        rep.fail("run list failed: " + clean(e.strip())[:300])
        return []
    runs = json.loads(o or "[]")
    for r in runs:
        rep.add("- %s %s %s/%s %s" % (r.get("databaseId"), r.get("createdAt"), r.get("status"),
                                     r.get("conclusion"), r.get("event")))
    for r in runs[:2]:
        if r.get("conclusion") != "failure":
            continue
        rid = str(r.get("databaseId"))
        c, o, e = gh(env, "run", "view", rid, "--repo", REPO, "--log-failed")
        if c or not o.strip():
            c, o, e = gh(env, "run", "view", rid, "--repo", REPO, "--log")
        lines = [re.sub(r"^\S+\t\S+\t\S+Z ", "", l) for l in (o or e).splitlines()]
        rep.h("Log of run " + rid + " (last 60 lines)")
        rep.add("```\n" + clean("\n".join(lines[-60:]))[:6000] + "\n```")
    rep.ok("read %d runs" % len(runs))
    return []
