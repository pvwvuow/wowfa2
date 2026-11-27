"""Report only: how many voice lines the dub studio really lists, by category, NPC voices and player-race voices
(runs the studio's own loader.js build over tools/dub-studio/voice_db.js with node).
"""
import json
import pathlib
import shutil
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[3]


def run(args, rep):
    node = shutil.which("node")
    if not node:
        rep.fail("no node on this runner")
        return []
    r = subprocess.run([node, str(pathlib.Path(__file__).with_name("studio_count.js")),
                        str(ROOT / "tools/dub-studio/voice_db.js"), str(ROOT / "tools/dub-studio/loader.js")],
                       capture_output=True, text=True)
    if r.returncode:
        rep.fail("node failed: %s" % (r.stderr or r.stdout)[-800:])
        return []
    d = json.loads(r.stdout)
    rep.h("Studio")
    rep.ok("%d groups (%d player-race), %d lines, %d of them old (file id < 600000)" % (d["groups"], d["h_groups"], d["lines"], d["old"]))
    rows = []
    tn = tp = 0
    for i, c in enumerate(d["cats"]):
        n, p = d["rows"].get("n%d" % i, 0), d["rows"].get("p%d" % i, 0)
        tn += n
        tp += p
        rows.append([c, n, p, n + p])
    rows.append(["total", tn, tp, tn + tp])
    rep.table(rows, ["category", "NPC voices", "player-race voices", "all"])
    return []
