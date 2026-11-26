"""Report: the NPC gossip lines (CMaNGOS classic npc_text) used by the MOST creatures that have no
Persian yet, keyed exactly like Modules/Dialog.lua keys the live text (markup out, $B = a space,
the player's name = $n, then num_key). Lines with another token ($C class, $R race, $G he:she;)
are skipped: the live text has the real word there and a fixed key can not match it.

Writes ci/work/voice/gossip_top.json: [{key, en, n, npcs}]
args: top (150), url (the .sql.gz; default the newest in Full_DB)
"""
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
    spec = importlib.util.spec_from_file_location("cmangos_cov_g", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def norm(t):
    s = re.sub(r"\$[Bb]", " ", t)
    s = re.sub(r"<[^<>]*>", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    s = re.sub(r"\$[Nn]\b", "$n", s)
    if re.search(r"\$(?!n\b)", s):
        return None
    return s


def run(args, rep):
    cov = _cov()
    store = Store.load()
    top = int(args.get("top", 150))
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
    _c, nt = cov.parse(sql, "npc_text")
    _c, gm = cov.parse(sql, "gossip_menu")
    cc, ct = cov.parse(sql, "creature_template")
    gcol = next((c for c in cc if c.startswith("gossip")), None)
    menus = {}
    for r in gm:
        menus.setdefault(r.get("text_id"), set()).add(r.get("entry"))
    npcs = {}
    if gcol:
        for r in ct:
            g = r.get(gcol)
            if g and g != "0":
                npcs.setdefault(g, []).append(cov.clean(r.get("name")))
    lines = {}
    skipped = 0
    for r in nt:
        names = []
        for m in menus.get(r.get("id"), ()):
            names += npcs.get(m, [])
        for i in range(8):
            for j in (0, 1):
                t = cov.clean(r.get("text%d_%d" % (i, j)))
                if not t or len(t) < 3:
                    continue
                s = norm(t)
                if not s:
                    skipped += 1
                    continue
                k = num_key(s)[0]
                e = lines.setdefault(k, {"key": k, "en": s, "npcs": set()})
                e["npcs"].update(n for n in names if n)
    have = sum(1 for k in lines if store.tpl.get(k))
    todo = [e for k, e in lines.items() if not store.tpl.get(k)]
    todo.sort(key=lambda e: (-len(e["npcs"]), e["en"]))
    out = [{"key": e["key"], "en": e["en"], "n": len(e["npcs"]), "npcs": sorted(e["npcs"])[:3]} for e in todo[:top]]
    os.makedirs("ci/work/voice", exist_ok=True)
    with open("ci/work/voice/gossip_top.json", "w", encoding="utf-8") as fh:
        json.dump(out, fh, ensure_ascii=False, indent=0)
        fh.write("\n")
    rep.h("Result")
    rep.ok("%d keyable gossip lines, %d already Persian, %d skipped (class/race/gender tokens)" % (len(lines), have, skipped))
    rep.h("Top %d without Persian (creatures using it)" % len(out))
    for e in out:
        rep.add("- [%d] %s\n  KEY %s" % (e["n"], e["en"][:400], e["key"][:400]))
    return ["ci/work/voice"]
