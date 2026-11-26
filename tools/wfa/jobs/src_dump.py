"""Report only: print addon source files with the Lua byte escapes (\\ddd) decoded to UTF-8,
so the Persian strings can be read. args: files [paths under addon/WoWFA], grep (optional: only
lines that contain one of these substrings), limit (max lines per file, 1500)"""
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[3]
ESC = re.compile(rb"\\(\d{1,3})")


def decode(raw):
    out = ESC.sub(lambda m: bytes([int(m.group(1)) & 255]), raw)
    return out.decode("utf-8", errors="replace")


def run(args, rep):
    limit = int(args.get("limit", 1500))
    needles = args.get("grep") or []
    for rel in args.get("files") or []:
        p = ROOT / "addon" / "WoWFA" / rel
        rep.h(rel)
        if not p.exists():
            rep.fail("%s: missing" % rel)
            continue
        lines = decode(p.read_bytes()).split("\n")
        keep = []
        for i, l in enumerate(lines):
            if needles and not any(n in l for n in needles):
                continue
            keep.append("%5d %s" % (i + 1, l.replace("\u200c", "~")))
            if len(keep) >= limit:
                break
        rep.add("```\n%s\n```" % "\n".join(keep).replace("```", "'''"))
        rep.ok("%s: %d lines" % (rel, len(keep)))
    return []
