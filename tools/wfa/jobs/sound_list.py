"""List the original NPC greeting / farewell / annoyed sound files from the community listfile
(github.com/wowdev/wow-listfile), with their fileDataIDs: the IDs are what MuteSoundFile() needs.

Writes ci/work/voice/npc_sounds.csv: fileDataID, kind, group, path   (report only otherwise)
args: url (default: the latest community-listfile.csv), pat (regex for the file name)
"""
import csv
import os
import re
import urllib.request

URL = "https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv"
KINDS = (("greeting", re.compile(r"greet|hello|npcgreeting", re.I)),
         ("farewell", re.compile(r"farewell|goodbye|bye\b|npcfarewell", re.I)),
         ("annoyed", re.compile(r"pissed|annoy|npcpissed", re.I)))


def run(args, rep):
    url = args.get("url") or URL
    rep.h("Source")
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "wowfa2-ci"})
        data = urllib.request.urlopen(req, timeout=300).read().decode("utf-8", "replace")
    except Exception as e:
        rep.fail("cannot read the listfile: %s" % e)
        return []
    lines = data.splitlines()
    rep.ok("%d listfile lines" % len(lines))
    rows = []
    base = re.compile(r"^sound/(creature|character|spells?|dialog)/", re.I)
    for ln in lines:
        fid, _s, path = ln.partition(";")
        if not path or not base.match(path):
            continue
        name = path.rsplit("/", 1)[-1]
        for kind, rx in KINDS:
            if rx.search(name):
                parts = path.split("/")
                rows.append([fid, kind, "/".join(parts[1:-1]), path])
                break
    rows.sort(key=lambda r: (r[1], r[2].lower(), r[3].lower()))
    os.makedirs("ci/work/voice", exist_ok=True)
    with open("ci/work/voice/npc_sounds.csv", "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["fileDataID", "kind", "group", "path"])
        w.writerows(rows)
    rep.h("Result")
    rep.ok("%d files" % len(rows))
    by, groups = {}, {}
    for r in rows:
        by[r[1]] = by.get(r[1], 0) + 1
        groups[r[2]] = groups.get(r[2], 0) + 1
    rep.table(sorted(by.items()), ["kind", "files"])
    rep.table(sorted(groups.items(), key=lambda kv: -kv[1])[:40], ["group (top 40)", "files"])
    return ["ci/work/voice"]
