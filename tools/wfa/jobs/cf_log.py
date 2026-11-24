"""Read the CurseForge upload runs of pvwvuow/wowfarsi-addon (the bot can not open Actions logs).
args: {"rerun_tag": ""} - when a tag is given, the workflow is started again for it first.
Writes into the report the last runs and, for failed runs, only what the steps PRINTED (the echoed
script itself is skipped). Secret values are masked by GitHub. Nothing is committed."""
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
    s = re.sub(r"\x1b\[[0-9;]*m", "", s)
    s = re.sub(r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}", "<uuid>", s)
    s = re.sub(r"(gh[pousr]_[A-Za-z0-9]{20,})", "<token>", s)
    return s.replace("`", "'")


def printed(raw):
    out, inside = [], False
    for l in raw.splitlines():
        parts = l.split("\t")
        step = parts[1] if len(parts) > 2 else ""
        text = parts[-1]
        text = re.sub(r"^\d{4}-\d\d-\d\dT[0-9:.]+Z ?", "", text)
        if text.startswith("##[group]"):
            inside = True
            continue
        if text.startswith("##[endgroup]"):
            inside = False
            continue
        if inside:
            continue
        out.append("[%s] %s" % (step, text))
    return out


def run(args, rep):
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    tag = str(args.get("rerun_tag", "") or "").strip()
    if tag:
        c, o, e = gh(env, "workflow", "run", WF, "--repo", REPO, "-f", "tag=" + tag)
        rep.add("- started the workflow again for %s: %s" % (tag, "ok" if c == 0 else clean(e.strip())[:300]))
        if c == 0:
            time.sleep(75)
    rep.h("Runs")
    c, o, e = gh(env, "run", "list", "--repo", REPO, "--workflow", WF, "--limit", "4",
                 "--json", "databaseId,status,conclusion,event,createdAt")
    if c:
        rep.fail("run list failed: " + clean(e.strip())[:300])
        return []
    runs = json.loads(o or "[]")
    for r in runs:
        rep.add("- %s %s %s/%s %s" % (r.get("databaseId"), r.get("createdAt"), r.get("status"),
                                     r.get("conclusion"), r.get("event")))
    for r in runs[:1]:
        rid = str(r.get("databaseId"))
        c, o, e = gh(env, "run", "view", rid, "--repo", REPO, "--log")
        lines = printed(o or e)
        rep.h("What run " + rid + " printed")
        rep.add("```\n" + clean("\n".join(lines[-80:]))[:7000] + "\n```")
    rep.ok("read %d runs" % len(runs))
    return []
