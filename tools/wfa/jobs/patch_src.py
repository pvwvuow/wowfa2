"""Patch addon sources, all-or-nothing. Two op kinds:
  {file, old, new, count}            exact text, must occur exactly `count` times
  {file, start, end, new}            replace what lies strictly BETWEEN two markers (each exactly once)
Report lists every op; nothing is written when one op fails. args: ops [...]"""
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[3]


def run(args, rep):
    texts = {}
    rep.h("ops")
    for i, op in enumerate(args.get("ops") or [], 1):
        f = op.get("file", "")
        p = ROOT / f
        if not p.is_file():
            rep.fail("#%d %s: no such file" % (i, f))
            return []
        s = texts.get(f)
        if s is None:
            s = p.read_text(encoding="utf-8")
        if "start" in op:
            a, b = op["start"], op["end"]
            if s.count(a) != 1 or s.count(b) != 1:
                rep.fail("#%d %s: markers found %d / %d times" % (i, f, s.count(a), s.count(b)))
                return []
            ia = s.index(a) + len(a)
            ib = s.index(b)
            if ib < ia:
                rep.fail("#%d %s: end marker before start marker" % (i, f))
                return []
            s = s[:ia] + op["new"] + s[ib:]
            rep.ok("#%d %s: block replaced" % (i, f))
        else:
            n = s.count(op["old"])
            want = int(op.get("count", 1))
            if n != want:
                rep.fail("#%d %s: found %d times, want %d: %s" % (i, f, n, want, op["old"][:80].replace("\n", " / ")))
                return []
            s = s.replace(op["old"], op["new"])
            rep.ok("#%d %s: %d replaced" % (i, f, n))
        texts[f] = s
    for f, s in texts.items():
        (ROOT / f).write_text(s, encoding="utf-8")
    rep.ok("%d files written" % len(texts))
    return ["data"]
