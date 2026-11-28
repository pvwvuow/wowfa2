"""Report only: entries of the name tables, templates and ui strings that contain a word.
args: words (list of lower-case substrings), limit (per word, default 8)"""
import glob
import json
import os


def run(args, rep):
    limit = int(args.get("limit", 8))
    rep.h("Name kinds")
    rep.add(", ".join(sorted(os.listdir("data/names"))))
    for w in args.get("words", []):
        rep.h(w)
        n = 0
        for p in sorted(glob.glob("data/names/*/*.json")) + sorted(glob.glob("data/tpl/*.json")) + ["data/ui/strings.json"]:
            if not os.path.exists(p):
                continue
            for k, v in json.load(open(p, encoding="utf-8")).items():
                if w in k.lower():
                    if n < limit:
                        rep.add("- %s | %s | %s" % (p.replace("data/", ""), k[:90], str(v)[:110]))
                    n += 1
        rep.add("(%d in all)" % n)
    return []
