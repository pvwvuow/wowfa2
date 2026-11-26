"""Report only: grep the Python tools and tests (tools/**/*.py, tests/py/*.py) for plain
substrings. args: grep [substrings], ctx (2), limit (40)"""
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[3]


def run(args, rep):
    ctx = int(args.get("ctx", 2))
    limit = int(args.get("limit", 40))
    files = sorted((ROOT / "tools").rglob("*.py")) + sorted((ROOT / "tests").rglob("*.py"))
    for g in args.get("grep") or []:
        hits = 0
        rep.h(g)
        for f in files:
            lines = f.read_text(encoding="utf-8", errors="replace").split("\n")
            for i, l in enumerate(lines):
                if g in l:
                    hits += 1
                    if hits > limit:
                        continue
                    a, b = max(0, i - ctx), min(len(lines), i + ctx + 1)
                    body = "\n".join("%5d %s" % (j + 1, lines[j][:160]) for j in range(a, b))
                    rep.add("%s:%d\n```\n%s\n```" % (f.relative_to(ROOT), i + 1, body.replace("```", "'''")))
        rep.ok("%s: %d hits" % (g, hits))
    return []
