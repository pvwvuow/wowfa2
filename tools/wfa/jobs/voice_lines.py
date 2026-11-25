"""List every English NPC line from the open CMaNGOS classic database, for the owner's own dubbing.

Writes ci/work/voice/lines.csv (utf-8 with BOM, opens in Excel): source, id, npc, en, has_fa, fa
  npc_text (gossip greetings, with the NPCs that use them), script_texts / creature_ai_texts (say/yell), dbscript_string and
  broadcast_text (every NPC line). has_fa = 1 when data/tpl already holds a Persian row.
args: url (the .sql.gz; default: the newest in Full_DB)
"""
import csv
import gzip
import importlib.util
import io
import json
import os
import pathlib
import re

from wfa.core import num_key
from wfa.store import Store


def _cov():
    p = pathlib.Path(__file__).with_name("cmangos_cov.py")
    spec = importlib.util.spec_from_file_location("cmangos_cov_x", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def run(args, rep):
    cov = _cov()
    store = Store.load()
    url = args.get("url")
    rep.h("Source")
    try:
        if not url:
            lst = json.loads(cov._get(cov.API))
            gz = [x for x in lst if x.get("name", "").endswith(".sql.gz")]
            url = sorted(gz, key=lambda x: x["name"])[-1]["download_url"]
        sql = gzip.GzipFile(fileobj=io.BytesIO(cov._get(url))).read().decode("utf-8", "replace")
    except Exception as e:
        rep.fail("cannot read the CMaNGOS dump: %s" % e)
        return []
    rep.ok(url.rsplit("/", 1)[-1])
    tabs = re.findall(r"CREATE TABLE `([^`]+)`", sql)
    rep.add("text-like tables: " + ", ".join(t for t in tabs if re.search(r"text|gossip|broadcast|script_string|say|yell", t)))

    rows = []

    def add(src, ident, npc, en):
        en = cov.clean(en)
        if len(en) < 2:
            return
        k = num_key(en)[0]
        fa = store.tpl.get(k, "")
        rows.append([src, ident, npc, en, 1 if fa else 0, fa])

    # gossip greetings
    _c, nt = cov.parse(sql, "npc_text")
    _c, gm = cov.parse(sql, "gossip_menu")
    cc, ct = cov.parse(sql, "creature_template")
    gcol = next((c for c in cc if c.startswith("gossip")), None)
    menu_of_text = {}
    for r in gm:
        menu_of_text.setdefault(r.get("text_id"), set()).add(r.get("entry"))
    npcs_of_menu = {}
    if gcol:
        for r in ct:
            g = r.get(gcol)
            if g and g != "0":
                npcs_of_menu.setdefault(g, []).append(cov.clean(r.get("name")))
    rep.ok("npc_text %d rows, gossip_menu %d, creature_template %d (gossip column: %s)" % (len(nt), len(gm), len(ct), gcol))
    for r in nt:
        names = []
        for m in menu_of_text.get(r.get("id"), ()):
            names += npcs_of_menu.get(m, [])
        npc = "; ".join(sorted(set(n for n in names if n))[:4])
        seen = set()
        for i in range(8):
            for j in (0, 1):
                t = cov.clean(r.get("text%d_%d" % (i, j)))
                if t and t not in seen:
                    seen.add(t)
                    add("gossip", r.get("id"), npc, t)

    # npc speech (say / yell), scripted lines and every broadcast text
    done = set(r[3] for r in rows)
    for table in ("script_texts", "dbscript_string", "custom_texts", "creature_ai_texts", "broadcast_text"):
        cols, rs = cov.parse(sql, table)
        cands = [c for c in cols if c.startswith("content_default") or ("male" in c and "text" in c)]
        rep.ok("%s: %d rows, text columns %s" % (table, len(rs), cands))
        for r in rs:
            for col in cands:
                t = cov.clean(r.get(col))
                if t and t not in done:
                    done.add(t)
                    add(table, r.get("entry") or r.get("id"), "", t)

    rows.sort(key=lambda r: (r[2] == "", r[2].lower(), r[0], r[3]))
    os.makedirs("ci/work/voice", exist_ok=True)
    with open("ci/work/voice/lines.csv", "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["source", "id", "npc", "en", "has_fa", "fa"])
        w.writerows(rows)
    have = sum(1 for r in rows if r[4])
    rep.h("Result")
    rep.ok("%d lines, %d already have Persian" % (len(rows), have))
    by = {}
    for r in rows:
        by[r[0]] = by.get(r[0], 0) + 1
    rep.table(sorted(by.items()), ["source", "lines"])
    return ["ci/work/voice"]
