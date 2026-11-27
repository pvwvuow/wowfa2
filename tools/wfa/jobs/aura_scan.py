"""Report only: the aura (buff / debuff) spells of the newest wow-raw archive and how many of their names
we do not translate yet (the spell table of our data holds class spells only). Descriptions cannot be
templated from the raw table ($s1, $d are filled by the client), they come from the miss log of live
tooltips. args: tag (optional), limit (60 rows shown), offset, mode: "count" (default) or "names"
(list the missing names, most common first), minlen (default 3)"""
import csv
import io
import os
import subprocess
import tempfile
import zipfile

from wfa.core import name_key
from wfa.store import Store

REPO = "pvwvuow/wow-raw"


def _gh(env, *a):
    return subprocess.run(["gh"] + list(a), env=env, text=True, capture_output=True)


def _table(z, name):
    if name not in z.namelist():
        return None
    return csv.DictReader(io.StringIO(z.read(name).decode("utf-8-sig", "replace")))


def run(args, rep):
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    tag = args.get("tag")
    if not tag:
        r = _gh(env, "release", "list", "--repo", REPO, "-L", "1", "--json", "tagName", "--jq", ".[0].tagName")
        tag = (r.stdout or "").strip()
    rep.h("aura spells from %s" % tag)
    tmp = tempfile.mkdtemp()
    d = _gh(env, "release", "download", tag, "--repo", REPO, "-p", "*.zip", "-D", tmp)
    if d.returncode:
        rep.fail("download: %s" % (d.stderr or "").strip()[:300])
        return []
    zs = [f for f in os.listdir(tmp) if f.endswith(".zip")]
    if not zs:
        rep.fail("no zip in %s" % tag)
        return []
    with zipfile.ZipFile(os.path.join(tmp, zs[0])) as z:
        sn = _table(z, "SpellName.csv")
        sp = _table(z, "Spell.csv")
        if sn is None or sp is None:
            rep.fail("SpellName.csv / Spell.csv missing: %s" % ", ".join(sorted(n for n in z.namelist() if n.startswith("Spell"))[:30]))
            return []
        rep.add("SpellName columns: %s" % ", ".join(sn.fieldnames or []))
        rep.add("Spell columns: %s" % ", ".join(sp.fieldnames or []))
        ncol = next((c for c in (sn.fieldnames or []) if c.lower().startswith("name")), None)
        acol = next((c for c in (sp.fieldnames or []) if c.lower().startswith("auradescription")), None)
        dcol = next((c for c in (sp.fieldnames or []) if c.lower() == "description_lang"), None)
        names = {}
        for r in sn:
            names[r.get("ID", "")] = (r.get(ncol) or "").strip()
        rows = list(sp)
    if not ncol or not acol:
        rep.fail("no name / aura description column")
        return []
    store = Store.load()
    known = store.names["spell"]
    minlen = int(args.get("minlen", 3))
    aura = {}
    for r in rows:
        nm = names.get(r.get("ID", ""), "")
        if len(nm) < minlen or not (r.get(acol) or "").strip():
            continue
        e = aura.setdefault(nm, [0, (r.get(acol) or "").strip()[:90]])
        e[0] += 1
    miss = {nm: e for nm, e in aura.items() if name_key(nm) not in known}
    rep.ok("%d spell rows, %d unique names carry an aura text, %d of those names are missing in our data"
           % (len(rows), len(aura), len(miss)))
    rep.ok("our spell names: %d, our description templates: %d" % (len(known), len(store.tpl)))
    if args.get("mode") == "names":
        lim, off = int(args.get("limit", 60)), int(args.get("offset", 0))
        order = sorted(miss.items(), key=lambda kv: (-kv[1][0], kv[0]))
        rep.table([(nm, e[0], e[1]) for nm, e in order[off:off + lim]], ["name", "rows", "aura text"])
    return []
