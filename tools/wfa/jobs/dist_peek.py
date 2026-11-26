"""Report only: build out/dist and show the head of the big data files plus byte stats
(Persian bytes, ASCII letters, escapes), to see what the memory holds. args: files (dist paths),
head (chars, 2500)"""
import os
import re

from wfa import build as B
from wfa.core import OUT, ROOT, read_json
from wfa.store import Store


def run(args, rep):
    pol = read_json(os.path.join(ROOT, "policy.json"))
    B.build(Store.load(), pol)
    dist = os.path.join(OUT, "dist", "WoWFA")
    head = int(args.get("head", 2500))
    for rel in args.get("files") or ["Data/Quests.lua", "Data/Names.lua"]:
        p = os.path.join(dist, rel)
        b = open(p, "rb").read()
        hi = sum(1 for c in b if c >= 128)
        asc = len(re.findall(rb"[A-Za-z]", b))
        esc = len(re.findall(rb"\\\d{1,3}", b))
        rep.h(rel)
        rep.ok("%d bytes: %d non-ASCII bytes, %d ASCII letters, %d \\ddd escapes, %d lines" % (len(b), hi, asc, esc, b.count(b"\n")))
        txt = b[:head].decode("utf-8", errors="replace")
        rep.add("```\n" + txt.replace("```", "'''") + "\n```")
        mid = len(b) // 2
        txt = b[mid:mid + 1500].decode("utf-8", errors="replace")
        rep.add("middle:\n```\n" + txt.replace("```", "'''") + "\n```")
    return []
