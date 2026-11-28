"""Report only: runs a Lua file with the CI's Lua (luajit, lua5.1 or lua) and shows its output.
args: file (repo path), args (list of arguments for the script)"""
import pathlib
import shutil
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[3]


def run(args, rep):
    lua = next((n for n in ("lua5.1", "luajit", "lua") if shutil.which(n)), None)
    if not lua:
        rep.fail("no lua interpreter")
        return []
    rep.h("%s %s" % (lua, args.get("file")))
    r = subprocess.run([lua, str(ROOT / args["file"])] + [str(a) for a in args.get("args", [])], capture_output=True, text=True, cwd=str(ROOT), timeout=120)
    for ln in (r.stdout or "").splitlines():
        (rep.fail if ln.startswith("FAIL") else rep.ok if ln.startswith("ok") else rep.add)(ln if ln.startswith(("FAIL", "ok")) else "- " + ln)
    if r.stderr.strip():
        rep.fail("stderr: " + r.stderr.strip()[:600])
    if r.returncode:
        rep.fail("exit code %d" % r.returncode)
    return []
