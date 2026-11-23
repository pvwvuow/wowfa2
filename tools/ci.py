#!/usr/bin/env python3
"""WoWFA v1: the only entry point. Stdlib only (fonttools optional for the glyph gate).

  python3 tools/ci.py ci [--report out/report.md]   lint + build + lua tests (every PR, every push)
  python3 tools/ci.py check                         lint only
  python3 tools/ci.py build                         build out/dist + zip
  python3 tools/ci.py tasks --since <sha> | --only <id>   run ci/tasks/*.json (tasks workflow)

Workflows in .github/ only call this file, so all logic lives here and can change without
touching .github/ (which only the owner can edit)."""
import argparse
import json
import os
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from wfa import build as B          # noqa: E402
from wfa import lint as L           # noqa: E402
from wfa.core import OUT, ROOT, read_json   # noqa: E402
from wfa.store import Store         # noqa: E402

LUA = os.environ.get("WOWFA_LUA", "lua5.1")


def policy():
    return read_json(os.path.join(ROOT, "policy.json"))


def sh(cmd, **kw):
    print("+ " + (cmd if isinstance(cmd, str) else " ".join(cmd)), flush=True)
    return subprocess.run(cmd, shell=isinstance(cmd, str), check=True, **kw)


def have_lua():
    return shutil.which(LUA) is not None


# ------------------------------------------------------------------ report
class Report:
    def __init__(self, title):
        self.lines = ["## " + title, ""]
        self.failed = False

    def h(self, s):
        self.lines += ["", "### " + s, ""]

    def add(self, s=""):
        self.lines.append(s)

    def fail(self, s):
        self.failed = True
        self.lines.append("- FAIL: " + s)

    def ok(self, s):
        self.lines.append("- ok: " + s)

    def table(self, rows, head):
        self.lines.append("| " + " | ".join(head) + " |")
        self.lines.append("|" + "---|" * len(head))
        for r in rows:
            self.lines.append("| " + " | ".join(str(x).replace("|", "\\|") for x in r) + " |")

    def text(self):
        verdict = "**RED**" if self.failed else "**GREEN**"
        return "\n".join([self.lines[0], "", verdict] + self.lines[1:]) + "\n"


def lint_into(rep, store, pol):
    r = L.run(store, pol)
    rep.h("Counts")
    rep.table(sorted(r.counts.items()), ["table", "rows"])
    rep.h("Gates")
    if r.errors:
        by = {}
        for g, w, m in r.errors:
            by.setdefault(g, []).append("%s: %s" % (w, m))
        for g, items in sorted(by.items()):
            rep.fail("%s: %d" % (g, len(items)))
            for x in items[:15]:
                rep.add("  - " + x)
    else:
        rep.ok("0 errors")
    rep.h("Ratchet (known debt, may only shrink)")
    caps = pol.get("ratchet", {})
    rows = []
    for g in sorted(set(r.ratchet) | set(caps)):
        rows.append((g, len(r.ratchet.get(g, [])), caps.get(g, "not set")))
    rep.table(rows, ["gate", "now", "allowed"])
    for g, items in sorted(r.ratchet.items()):
        rep.add("<details><summary>%s (%d)</summary>\n\n%s\n\n</details>" %
                (g, len(items), "\n".join("- " + x for x in items[:40])))
    return r


def lua_tests(rep):
    rep.h("Lua")
    if not have_lua():
        rep.add("- %s not installed here: Lua gates skipped (CI installs it, so CI never skips)" % LUA)
        if os.environ.get("CI"):
            rep.fail("lua missing on CI")
        return
    dist = os.path.join(OUT, "dist", "WoWFA")
    nlua = 0
    for base, _, files in os.walk(dist):
        for fn in sorted(files):
            if not fn.endswith(".lua"):
                continue
            nlua += 1
            full = os.path.join(base, fn)
            p = subprocess.run(["luac5.1" if LUA == "lua5.1" else "luac", "-p", full], capture_output=True, text=True)
            if p.returncode:
                rep.fail("luac %s: %s" % (os.path.relpath(full, dist), p.stderr.strip()[:300]))
    rep.add("- luac -p: %d Lua files" % nlua)
    tdir = os.path.join(ROOT, "tests")
    runner = os.path.join(tdir, "run.lua")
    if os.path.exists(runner) and os.path.isdir(os.path.join(OUT, "dist", "WoWFA")):
        p = subprocess.run([LUA, runner, os.path.join(OUT, "dist", "WoWFA")], capture_output=True, text=True, cwd=ROOT)
        alllines = (p.stdout + p.stderr).strip().splitlines()
        tail = [ln for ln in alllines if ln.startswith("FAIL")][:30] + alllines[-14:]
        if p.returncode:
            rep.fail("tests/run.lua exit %d" % p.returncode)
        else:
            rep.ok("tests/run.lua passed")
        rep.add("```\n" + "\n".join(tail) + "\n```")
    else:
        rep.add("- tests/run.lua not present yet")


def cmd_ci(a):
    pol = policy()
    rep = Report("CI: WoWFA %s" % pol["version"])
    try:
        store = Store.load()
    except Exception as e:  # a broken data file must be loud, never skipped
        rep.fail("data/ does not load: %s" % e)
        return finish(rep, a)
    rep.h("Python tests")
    p = subprocess.run([sys.executable, os.path.join(ROOT, "tests", "py", "test_tools.py")],
                       capture_output=True, text=True)
    if p.returncode:
        rep.fail("tests/py/test_tools.py")
        rep.add("```\n" + (p.stdout + p.stderr)[-3000:] + "\n```")
    else:
        rep.ok(p.stdout.strip().splitlines()[-1])
    lint_into(rep, store, pol)
    counts, zpath, notes = B.build(store, pol)
    rep.h("Build")
    for n in notes:
        rep.add("- " + n)
    rep.ok("%s (%d bytes)" % (os.path.basename(zpath), os.path.getsize(zpath)))
    lua_tests(rep)
    return finish(rep, a)


def finish(rep, a):
    os.makedirs(OUT, exist_ok=True)
    path = getattr(a, "report", None) or os.path.join(OUT, "report.md")
    with open(path, "w", encoding="utf-8") as f:
        f.write(rep.text())
    print(rep.text())
    return 1 if rep.failed else 0


def cmd_check(a):
    pol = policy()
    rep = Report("check")
    lint_into(rep, Store.load(), pol)
    return finish(rep, a)


def cmd_build(a):
    pol = policy()
    counts, zpath, notes = B.build(Store.load(), pol)
    print(json.dumps(counts, indent=1), zpath, notes)
    return 0


def cmd_tasks(a):
    from wfa import tasks
    return tasks.run(a.since, a.only)


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("ci"); p.add_argument("--report")
    sub.add_parser("check")
    sub.add_parser("build")
    p = sub.add_parser("tasks"); p.add_argument("--since"); p.add_argument("--only")
    a = ap.parse_args()
    return {"ci": cmd_ci, "check": cmd_check, "build": cmd_build, "tasks": cmd_tasks}[a.cmd](a)


if __name__ == "__main__":
    sys.exit(main())
