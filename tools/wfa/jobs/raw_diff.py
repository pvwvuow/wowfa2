"""Word diff old -> new of the Spell descriptions a build changed (wow-raw change report). Report only.

args: build, ids (list of spell ids as strings; empty = all)"""
import difflib
import json
import os
import re
import urllib.request


def _get(path):
    url = "https://api.github.com/repos/pvwvuow/wow-raw/contents/" + path + "?ref=main"
    req = urllib.request.Request(url, headers={"Accept": "application/vnd.github.raw", "Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""), "User-Agent": "wowfa2-ci"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read().decode("utf-8")


def run(args, rep):
    build = args.get("build", "1.60.1.71037")
    want = set(args.get("ids") or [])
    doc = json.loads(_get("manifests/forever/changes/%s.json" % build))
    changed = (doc.get("tables") or {}).get("Spell", {}).get("changed") or {}
    rep.h("word diff of the changed descriptions")
    for sid, ch in sorted(changed.items(), key=lambda kv: int(kv[0])):
        if want and sid not in want:
            continue
        for col in ("Description_lang", "AuraDescription_lang"):
            if col not in ch:
                continue
            old, new = ch[col]
            a, b = (old or "").split(), (new or "").split()
            sm = difflib.SequenceMatcher(None, a, b)
            parts = []
            for tag, i1, i2, j1, j2 in sm.get_opcodes():
                if tag == "equal":
                    continue
                parts.append("%s: [%s] -> [%s]" % (tag, " ".join(a[i1:i2])[:120], " ".join(b[j1:j2])[:120]))
            if parts:
                rep.ok("%s %s | %s" % (sid, col[:4], " ; ".join(parts)[:420]))
    return []
