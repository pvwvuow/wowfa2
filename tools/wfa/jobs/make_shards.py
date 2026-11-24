"""Cut a name / template table into small work files for translators and reviewers.

Each file is ci/work/<table>/cNNN.json = {key: current Persian}, keys sorted (so names that share
words sit together), `size` rows per file. Small files matter: a reviewer that gets 100 rows reads
every one, one that gets 2000 skims.

args.jobs = [{"table": "npc"|"zone"|"boss"|"spell"|"tpl", "size": 100, "risky": true}]
  risky (npc only): keep a row only if one of its words also appears in another name, or a word looks like a
  compound with an agent suffix (wyrmhunter, shadowstalker ...). A name whose words all occur nowhere else
  is a plain proper name (transliteration only) and needs no meaning review.
"""
import collections
import json
import pathlib
import re
import shutil

from wfa.store import Store

_P = pathlib.Path(__file__).resolve().parents
ROOT = _P[3] if len(_P) > 3 else pathlib.Path.cwd()

SUFFIX = ("hunter", "slayer", "stalker", "walker", "watcher", "guard", "guardian", "sentinel", "rider", "caller",
          "summoner", "seer", "smith", "weaver", "singer", "binder", "breaker", "render", "ripper", "bane", "born",
          "kin", "lord", "master", "keeper", "warden", "shaper", "speaker", "thief", "reaver", "crawler", "creeper",
          "lurker", "dweller", "eater", "drinker", "spitter", "howler", "screecher", "whisperer", "piercer",
          "tracker", "cutter", "splitter", "crusher", "smasher", "mauler", "pounder", "thumper", "herder",
          "tender", "mender", "healer", "charmer", "tamer", "gazer", "fiend", "borer", "digger", "seeker",
          "runner", "striker", "wrecker", "burner", "bringer", "taker", "maker", "hound", "wing", "fang", "claw",
          "tooth", "scale", "hide", "horn", "tail", "back", "eye", "mane", "blade", "fist")


def _words(key):
    return re.findall(r"[a-z]+", key.lower())


def run(args, rep):
    store = Store.load()
    rep.h("Shards")
    out_paths = []
    for job in args.get("jobs") or []:
        table = job["table"]
        size = int(job.get("size", 100))
        data = store.tpl if table == "tpl" else store.names[table]
        keys = sorted(data, key=str)
        total = len(keys)
        if job.get("risky"):
            freq = collections.Counter()
            for k in keys:
                for w in set(_words(k)):
                    freq[w] += 1
            keep = []
            for k in keys:
                ws = _words(k)
                if any(freq[w] >= 2 for w in ws) or any(len(w) >= 7 and w.endswith(SUFFIX) for w in ws):
                    keep.append(k)
            keys = keep
        folder = ROOT / "ci" / "work" / table
        if folder.exists():
            shutil.rmtree(folder)
        folder.mkdir(parents=True)
        n = 0
        for i in range(0, len(keys), size):
            n += 1
            part = {k: data[k] for k in keys[i:i + size]}
            (folder / ("c%03d.json" % n)).write_text(json.dumps(part, ensure_ascii=False, indent=0) + "\n",
                                                      encoding="utf-8")
        rep.ok("%s: %d of %d rows kept, %d files of up to %d rows" % (table, len(keys), total, n, size))
        out_paths.append("ci/work/" + table)
    return out_paths
