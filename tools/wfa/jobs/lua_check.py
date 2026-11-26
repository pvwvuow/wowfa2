"""Report only: syntax check (luac -p) of Lua files anywhere in the repo.

args: files (list of repo paths)
"""
import pathlib
import shutil
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[3]


def run(args, rep):
    luac = next((n for n in ("luac5.1", "luac") if shutil.which(n)), None)
    if not luac:
        rep.fail("no luac")
        return []
    rep.h("luac -p")
    for rel in args.get("files", []):
        p = ROOT / rel
        if not p.exists():
            rep.fail("%s: missing" % rel)
            continue
        r = subprocess.run([luac, "-p", str(p)], capture_output=True, text=True)
        if r.returncode:
            rep.fail("%s: %s" % (rel, (r.stderr or r.stdout).strip()))
        else:
            rep.ok("%s: syntax ok" % rel)
    return []
