"""Spells whose description the client changed in a build (wow-raw change report): find our template for the
OLD text (by its words, numbers and $variables ignored) and the one for the NEW text. Report only.

args: build"""
import json
import os
import re
import urllib.request

from wfa.store import Store

WORD = re.compile(r"[a-z][a-z']*")


def _get(path):
    url = "https://api.github.com/repos/pvwvuow/wow-raw/contents/" + path + "?ref=main"
    req = urllib.request.Request(url, headers={"Accept": "application/vnd.github.raw", "Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""), "User-Agent": "wowfa2-ci"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read().decode("utf-8")


def words(text):
    text = re.sub(r"\$[A-Za-z0-9]+(?::[^;]*;)?", " ", text or "")
    text = re.sub(r"\$l[^;]*;", " ", text)
    return tuple(WORD.findall(text.lower()))


def run(args, rep):
    build = args.get("build", "1.60.1.71037")
    rep.h("descriptions changed by " + build)
    doc = json.loads(_get("manifests/forever/changes/%s.json" % build))
    changed = (doc.get("tables") or {}).get("Spell", {}).get("changed") or {}
    store = Store.load()
    index = {}
    for k in store.tpl:
        index.setdefault(words(k), []).append(k)
    rows = []
    for sid, ch in sorted(changed.items(), key=lambda kv: int(kv[0])):
        for col in ("Description_lang", "AuraDescription_lang"):
            if col not in ch:
                continue
            old, new = ch[col]
            if words(old) == words(new):
                continue
            ho = index.get(words(old))
            hn = index.get(words(new))
            rows.append((sid, col[:4], "old in our data" if ho else "old not found", "new in our data" if hn else "new missing", (new or "")[:90]))
    rep.ok("%d changed spell descriptions with different wording" % len(rows))
    rep.table(rows, ["spell", "col", "old", "new", "new text"])
    ho = [r for r in rows if r[2] == "old in our data" and r[3] == "new missing"]
    rep.ok("%d of them need a new template (old known, new missing)" % len(ho))
    return []
