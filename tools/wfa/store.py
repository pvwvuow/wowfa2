"""The ONE source of truth: data/. Load it all, save it canonically.

data/quests/qNNNN.json   {"<questID>": {"h","t","obj","det","pro","com","desc","o"}}  (NNNN = id // 100)
data/names/<kind>/<a-z|_>.json   {"<name_key(EN)>": "Persian"}
data/tpl/<a-z|_>.json    {"<normalised EN template, numbers = #>": "Persian with {0} {1} slots"}
data/ui/strings.json     {"<ui key>": "Persian"}
data/terms.json          term locks + banned strings (lint input)
"""
import glob
import os

from .core import DATA, NAME_KINDS, read_json, shard_letter, write_json_map

QUEST_FIELDS = ("h", "t", "obj", "det", "pro", "com", "desc")


class Store:
    def __init__(self):
        self.quests = {}            # int id -> dict
        self.names = {k: {} for k in NAME_KINDS}
        self.tpl = {}
        self.ui = {}
        self.terms = {}
        self.where = {}             # (table, key) -> file, for error messages

    # ---------- load ----------
    @classmethod
    def load(cls, root=DATA):
        s = cls()
        for p in sorted(glob.glob(os.path.join(root, "quests", "q*.json"))):
            for k, v in read_json(p).items():
                qid = int(k)
                if qid in s.quests:
                    raise ValueError("quest %d twice (%s, %s)" % (qid, s.where[("q", qid)], p))
                if qid // 100 != int(os.path.basename(p)[1:-5]):
                    raise ValueError("quest %d is in the wrong shard %s" % (qid, p))
                s.quests[qid] = v
                s.where[("q", qid)] = p
        for kind in NAME_KINDS:
            for p in sorted(glob.glob(os.path.join(root, "names", kind, "*.json"))):
                for k, v in read_json(p).items():
                    if k in s.names[kind]:
                        raise ValueError("names/%s key %r twice" % (kind, k))
                    s.names[kind][k] = v
                    s.where[("n:" + kind, k)] = p
        for p in sorted(glob.glob(os.path.join(root, "tpl", "*.json"))):
            for k, v in read_json(p).items():
                if k in s.tpl:
                    raise ValueError("tpl key %r twice" % k)
                s.tpl[k] = v
                s.where[("tpl", k)] = p
        ui = os.path.join(root, "ui", "strings.json")
        if os.path.exists(ui):
            s.ui = read_json(ui)
        terms = os.path.join(root, "terms.json")
        if os.path.exists(terms):
            s.terms = read_json(terms)
        return s

    # ---------- save (canonical) ----------
    def save(self, root=DATA):
        shards = {}
        for qid, rec in self.quests.items():
            clean = {f: rec[f] for f in QUEST_FIELDS if rec.get(f)}
            if rec.get("o"):
                clean["o"] = list(rec["o"])
            shards.setdefault(qid // 100, {})[str(qid)] = clean
        _replace_dir(os.path.join(root, "quests"),
                     {"q%04d.json" % n: (m, True) for n, m in shards.items()})
        for kind, table in self.names.items():
            by = {}
            for k, v in table.items():
                by.setdefault(shard_letter(k) + ".json", {})[k] = v
            _replace_dir(os.path.join(root, "names", kind), {f: (m, False) for f, m in by.items()})
        by = {}
        for k, v in self.tpl.items():
            by.setdefault(shard_letter(k) + ".json", {})[k] = v
        _replace_dir(os.path.join(root, "tpl"), {f: (m, False) for f, m in by.items()})
        if self.ui:
            write_json_map(os.path.join(root, "ui", "strings.json"), self.ui)


def _replace_dir(d, files):
    os.makedirs(d, exist_ok=True)
    for old in glob.glob(os.path.join(d, "*.json")):
        if os.path.basename(old) not in files:
            os.remove(old)
    for name, (m, sort_int) in files.items():
        write_json_map(os.path.join(d, name), m, sort_int=sort_int)
