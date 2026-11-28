"""Report only: the player voice pack of every playable race and sex (error lines, emotes, body sounds),
compared with the dwarf male pack, in the community listfile, the Forever client and the dub studio.
args: build (default 1.60.1.71139), ref (default dwarf|m), limit (names shown per list)"""
import csv
import importlib.util
import io
import json
import pathlib
import re

LISTFILE = "https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv"
DB = "tools/dub-studio/voice_db.js"
RACES = ["human", "dwarf", "gnome", "nightelf", "orc", "troll", "tauren", "scourge"]
ALIAS = {"undead": "scourge"}
PRE = re.compile(r"^(vo_)?(pc_?)?(human|dwarf|gnome|nightelf|night_elf|orc|troll|tauren|undead|scourge)_?(female|male)_?")
DROP = re.compile(r"footstep|mount|swim|loop|choochoo_?loop")


def _cov():
    p = pathlib.Path(__file__).with_name("cmangos_cov.py")
    spec = importlib.util.spec_from_file_location("cmangos_cov_rg", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def norm(nm):
    n = re.sub(r"\.(ogg|mp3|wav)$", "", nm.lower())
    m = PRE.match(n)
    if not m:
        return None, None, None
    race = m.group(3).replace("night_elf", "nightelf")
    race = ALIAS.get(race, race)
    sex = "f" if m.group(4) == "female" else "m"
    rest = n[m.end():]
    rest = re.sub(r"(_?\d+)+[a-z]?$", "", rest).strip("_ ")
    return race, sex, rest or "?"


def kind(rest):
    if rest.startswith("err") or "_err" in rest:
        return "err"
    if re.search(r"wound|attack|death|dies|jump|land|crit|battle|warcry|exert|breath|drown|fall|cast|grunt|stun|parry|dodge|block|charge", rest):
        return "body"
    return "talk"


def run(args, rep):
    cov = _cov()
    build = str(args.get("build") or "1.60.1.71139")
    ref = tuple(str(args.get("ref") or "dwarf|m").split("|"))
    lim = int(args.get("limit", 40))
    s = open(DB, encoding="ascii").read()
    db = json.loads(s[s.index("=") + 1:s.rindex(";")])
    inL = {x[0]: x for x in db["L"]}
    fv = set(db.get("FV") or [])
    T = db.get("T") or {}
    rows = list(csv.DictReader(io.StringIO(cov._get("https://wago.tools/db2/SoundKitEntry/csv?build=%s" % build).decode("utf-8-sig", "replace"))))
    ske = set()
    for r in rows:
        try:
            ske.add(int(r["FileDataID"]))
        except (KeyError, ValueError):
            pass
    lf = cov._get(LISTFILE).decode("utf-8", "replace")
    packs = {}
    for line in lf.splitlines():
        fid, _, path = line.partition(";")
        p = path.strip().lower()
        if not p.startswith("sound/") or not re.search(r"\.(ogg|mp3|wav)$", p) or DROP.search(p):
            continue
        race, sex, rest = norm(p.rsplit("/", 1)[-1])
        if not race:
            continue
        try:
            fid = int(fid)
        except ValueError:
            continue
        packs.setdefault((race, sex), {}).setdefault(rest, []).append((fid, p))
    # what a "full pack" holds: the reference pack's line kinds that the Forever client has
    def usable(files):
        return [f for f, _ in files if f in ske]
    refp = {k: v for k, v in packs.get(ref, {}).items() if usable(v)}
    rep.ok("reference %s|%s: %d different lines in the client (err %d, talk %d, body %d)" % (
        ref[0], ref[1], len(refp), len([k for k in refp if kind(k) == "err"]),
        len([k for k in refp if kind(k) == "talk"]), len([k for k in refp if kind(k) == "body"])))
    rep.add("ref lines: " + ", ".join(sorted(refp))[:3000])
    for race in RACES:
        for sex in ("m", "f"):
            pk = packs.get((race, sex), {})
            cl = {k: v for k, v in pk.items() if usable(v)}
            files = [f for v in cl.values() for f in usable(v)]
            st = [f for f in files if f in inL]
            stfv = [f for f in st if f in fv]
            txt = [f for f in st if str(f) in T]
            fa = [f for f in st if str(f) in T and T[str(f)][1]]
            notst = sorted({(k, f) for k, v in cl.items() for f in usable(v) if f not in inL})
            miss_ref = sorted(set(refp) - set(cl))
            miss_lf = [k for k in miss_ref if k in pk]
            rep.h("%s %s" % (race, sex))
            rep.add("- client: %d lines (%d files): err %d, talk %d, body %d" % (
                len(cl), len(files), len([k for k in cl if kind(k) == "err"]),
                len([k for k in cl if kind(k) == "talk"]), len([k for k in cl if kind(k) == "body"])))
            rep.add("- studio: %d of those files (Forever mark %d), with text %d, with Persian %d" % (len(st), len(stfv), len(txt), len(fa)))
            if notst:
                rep.add("- in the client but NOT in the studio: %d: %s" % (len(notst), ", ".join("%s %d" % (k, f) for k, f in notst[:lim])))
            if miss_ref:
                rep.add("- %d lines of the %s|%s pack missing in the client (listfile has %d of them only outside the client): %s" % (
                    len(miss_ref), ref[0], ref[1], len(miss_lf), ", ".join(miss_ref[:lim])))
            folders = sorted({p.rsplit("/", 1)[0] for v in pk.values() for _, p in v})
            rep.add("- folders: " + ", ".join(folders[:8]))
    return []
