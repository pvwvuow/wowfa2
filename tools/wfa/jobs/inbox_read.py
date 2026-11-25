"""Read the wowfarsi.ir/report inbox NOW (owner, 25 Nov 2026: "I sent more reports from the site,
were they all received?"). The collector in pvwvuow/wowheadFA (tools/wowfa_reports.py) only runs
with its discord workflow; this job reads the same ntfy.sh topic directly (ntfy keeps 12 h), joins
the "WFR1 <id> <i>/<n>" parts and lists every report with its time. Read-only: nothing is written
anywhere, the wowheadFA collector still saves them on its next run.
Also lists the last runs of the wowheadFA workflows when the token may read them.
args: {"topic": "wowfarsi-rep-q7m3x9k2v8", "since": "12h", "max_chars": 2500}"""
import json
import os
import re
import subprocess
import urllib.request
from datetime import datetime, timezone

WFR = re.compile(r"^WFR1 ([a-z0-9]{6,16}) (\d{1,3})/(\d{1,3})$")


def _iso(t):
    return datetime.fromtimestamp(int(t or 0), timezone.utc).strftime("%Y-%m-%d %H:%M:%SZ")


def run(args, rep):
    topic = re.sub(r"[^A-Za-z0-9_-]", "", str(args.get("topic") or "wowfarsi-rep-q7m3x9k2v8"))
    since = re.sub(r"[^0-9a-z]", "", str(args.get("since") or "12h"))
    cap = int(args.get("max_chars") or 2500)
    rep.h("ntfy inbox")
    url = "https://ntfy.sh/%s/json?poll=1&since=%s" % (topic, since)
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "wowfa2-ci"})
        with urllib.request.urlopen(req, timeout=60) as r:
            text = r.read().decode("utf-8", "replace")
    except Exception as e:  # noqa: BLE001
        rep.fail("ntfy: %s" % e)
        return []
    parts = {}
    events = 0
    for line in text.splitlines():
        try:
            ev = json.loads(line)
        except Exception:  # noqa: BLE001
            continue
        if not isinstance(ev, dict) or ev.get("event") != "message":
            continue
        events += 1
        msg = str(ev.get("message") or "")
        head, _, body = msg.partition("\n")
        m = WFR.match(head.strip())
        if m:
            rid, i, n = m.group(1), int(m.group(2)), int(m.group(3))
        else:
            rid, i, n, body = "raw-" + str(ev.get("id")), 1, 1, msg
        p = parts.setdefault(rid, {"n": n, "t": int(ev.get("time") or 0), "got": {}})
        p["got"][i] = body
        p["t"] = min(p["t"], int(ev.get("time") or p["t"]))
    rep.ok("%d messages, %d reports in the last %s" % (events, len(parts), since))
    for rid, p in sorted(parts.items(), key=lambda kv: kv[1]["t"]):
        n = p["n"]
        miss = [i for i in range(1, n + 1) if i not in p["got"]]
        body = "".join(p["got"].get(i, "") for i in range(1, n + 1))
        rep.add("\n#### %s  (id %s, %d part(s)%s)\n" % (_iso(p["t"]), rid, n,
                                                     (", MISSING parts %s" % miss) if miss else ""))
        rep.add("```\n%s\n```" % body[:cap].replace("```", "'''"))
    rep.h("wowheadFA workflows (the collector)")
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    p = subprocess.run(["gh", "run", "list", "--repo", "pvwvuow/wowheadFA", "--limit", "12", "--json",
                        "workflowName,createdAt,status,conclusion,event"], env=env, text=True, capture_output=True)
    if p.returncode:
        rep.add("- cannot read: %s" % (p.stderr or "").strip()[:200])
    else:
        for r in json.loads(p.stdout or "[]"):
            rep.add("- %s %s %s/%s %s" % (r.get("createdAt"), r.get("workflowName"), r.get("status"),
                                         r.get("conclusion"), r.get("event")))
    return []
