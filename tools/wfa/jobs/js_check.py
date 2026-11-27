"""Report only: syntax check (node --check) of JavaScript files in the repo.

args: files (list of repo paths)
"""
import pathlib
import shutil
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[3]


def run(args, rep):
    node = shutil.which("node")
    if not node:
        rep.fail("no node on this runner")
        return []
    rep.h("node --check")
    for rel in args.get("files", []):
        p = ROOT / rel
        if not p.exists():
            rep.fail("%s: missing" % rel)
            continue
        r = subprocess.run([node, "--check", str(p)], capture_output=True, text=True)
        if r.returncode:
            rep.fail("%s: %s" % (rel, (r.stderr or r.stdout).strip()[:600]))
        else:
            rep.ok("%s: syntax ok" % rel)
    return []
