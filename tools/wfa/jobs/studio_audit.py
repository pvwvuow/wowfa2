"""Report only: what the dub studio misses for WoW Forever.
1. lines of the database that the studio page drops (loader.js catOf returns null), per kind and group
2. voice files of the Forever client that are not in the database at all (listfile path, per folder)
3. spoken text and Persian coverage, groups without race or sex, duplicate group names
args: build (default 1.60.1.71139), top (rows per table, default 40)"""
import csv
import importlib.util
import io
import json
import pathlib
import re

LISTFILE = "https://github.com/wowdev/wow-listfile/releases/latest/download/community-listfile.csv"
DB = "tools/dub-studio/voice_db.js"
GRUNT = re.compile(r"wound|attack|death|(^|_)dies?(_|\d|$)|dying|pain|hurt|injur|grunt|roar|breath|footstep|windup|(^|_)cast|jump|(^|_)land|effort|exert|battleshout|battlecry|warcry|emote|laugh|cheer|chuckle|sigh|yawn|cough|sneeze|whistle|snore|knock|choochoo|clap|kiss|giggle|flirt|fidget|loop|idle|stand|bored|footfall|swim|fall|parry|dodge|block|crit|spell|precast|channel|mount|growl|snarl|howl|bark|hiss|chirp|squawk|purr|whine|moo|oink|neigh|bleat|screech|shriek|scream|gasp|stun|knockdown|sleep|yell_?pain")
SPEECH = re.compile(r"slay|kill|intro|yell|(^|_)say|speech|speak|taunt|summon|berserk|engage|event|quest|(^|_)line|vo_qe|vo_quest|order|command|special|phase|talk|whisper|warn|alert|chat|greet|bye|farewell|(^|_)\d{2,3}_[mf]$|(^|_)[mf]$|response|reply|story|lore|intro|outro|victory|defeat|win|lose|thank|help|question|vendor|trainer|flight|innkeeper|guard")
NOISE_H = re.compile(r"footstep|footfall|swim|breath|loop|(^|_)jump|(^|_)land|(^|_)fall|drown|knock|choochoo|mount|giant|horse|snore|sleep|idle|fidget|whistle|bored")
CMD_H = re.compile(r"(^|_)err|attackmytarget|attacktarget|incomingdanger|openfire|help|healme|followme|waithere|flee|outofmana|congratulat|thank|welcome|hello|(^|_)(yes|no|nod|cry|laugh|cheer|kiss|flirt|silly|chicken|beg|raspberry|sigh|yawn|train|follow|rude|joke)")
COMBAT_H = re.compile(r"wound|attack|death|(^|_)dies?(_|\d|$)|dying|pain|hurt|crit|windup|casterrelease|battleshout|battlecry|warcry|(^|_)charge|(^|_)cast|exert|effort|grunt|roar|stun|parry|dodge|block")
CATS = ["greeting", "farewell", "pissed", "aggro", "speech", "player", "combat"]


def clean(name, gname):
    n, g = name.lower(), gname.lower().replace(" ", "")
    for v in (g, g.replace("the", ""), gname.lower().replace(" ", "_")):
        if len(v) >= 4:
            n = n.replace(v, "_")
    return n


def cat_of(name, gname, vo, kind):
    n = clean(name, gname)
    if re.search("greet", n):
        return 0, ""
    if re.search(r"farewell|goodbye|(^|_)bye", n):
        return 1, ""
    if re.search("pissed|annoy", n):
        return 2, ""
    if re.search("aggro", n):
        return 3, ""
    if kind == "h":
        hn = re.sub("(fe)?male", "_", n)
        m = NOISE_H.search(hn)
        if m:
            return None, "h-noise:" + m.group(0).strip("_")
        if CMD_H.search(hn):
            return 5, ""
        if COMBAT_H.search(hn):
            return 6, ""
    m = GRUNT.search(n)
    if m:
        return None, "grunt:" + m.group(0).strip("_")
    if SPEECH.search(n) or vo:
        return 4, ""
    return None, "nomatch"


def _cov():
    p = pathlib.Path(__file__).with_name("cmangos_cov.py")
    spec = importlib.util.spec_from_file_location("cmangos_cov_sa", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def run(args, rep):
    top = int(args.get("top", 40))
    build = str(args.get("build") or "1.60.1.71139")
    s = open(DB, encoding="ascii").read()
    db = json.loads(s[s.index("=") + 1:s.rindex(";")])
    L, G, T = db["L"], db["G"], db.get("T") or {}
    fv = set(db.get("FV") or [])
    rep.h("1. Lines the studio page drops (Forever lines only)")
    kept, dropped, why, per = {}, {}, {}, {}
    for x in L:
        if x[0] not in fv:
            continue
        g = G[x[1]]
        c, w = cat_of(x[3], g[0], x[4], g[1])
        k = g[1]
        if c is None:
            dropped[k] = dropped.get(k, 0) + 1
            why[(k, w)] = why.get((k, w), 0) + 1
            p = per.setdefault(x[1], [0, 0, []])
            p[1] += 1
            if len(p[2]) < 6:
                p[2].append(x[3])
        else:
            kept[k] = kept.get(k, 0) + 1
            p = per.setdefault(x[1], [0, 0, []])
            p[0] += 1
    for k in sorted(set(kept) | set(dropped)):
        rep.ok("kind %s: %d shown, %d dropped" % (k, kept.get(k, 0), dropped.get(k, 0)))
    rep.add("reasons (kind, first matching word: lines):")
    for (k, w), n in sorted(why.items(), key=lambda kv: -kv[1])[:top]:
        rep.add("- %s %s: %d" % (k, w, n))
    rep.add("groups with the most dropped Forever lines (shown/dropped: samples):")
    for gi, (a, b, sm) in sorted(per.items(), key=lambda kv: -kv[1][1])[:top]:
        if b:
            rep.add("- %s [%s] %d/%d: %s" % (G[gi][0], G[gi][1], a, b, ", ".join(sm)))
    rep.h("2. Voice files of the Forever client that are not in the database")
    cov = _cov()
    rows = list(csv.DictReader(io.StringIO(cov._get("https://wago.tools/db2/SoundKitEntry/csv?build=%s" % build).decode("utf-8-sig", "replace"))))
    ske = set()
    for r in rows:
        try:
            ske.add(int(r["FileDataID"]))
        except (KeyError, ValueError):
            pass
    rep.ok("client sound files: %d" % len(ske))
    have = {x[0] for x in L}
    lf = cov._get(LISTFILE).decode("utf-8", "replace")
    roots, fold, named = {}, {}, 0
    for line in lf.splitlines():
        fid, _, path = line.partition(";")
        try:
            fid = int(fid)
        except ValueError:
            continue
        if fid not in ske:
            continue
        named += 1
        p = path.strip().lower()
        parts = p.split("/")
        r0 = "/".join(parts[:2])
        a = roots.setdefault(r0, [0, 0])
        a[0] += 1
        if fid in have:
            a[1] += 1
            continue
        if len(parts) >= 4 and parts[1] in ("creature", "character", "dialog", "vo", "spells", "event", "doodad"):
            key = "/".join(parts[1:3]) if parts[1] in ("creature", "character", "dialog", "vo", "event") else parts[1]
            spoken = parts[1] in ("creature", "character", "dialog", "vo") or parts[-1].startswith("vo_")
            if spoken:
                f = fold.setdefault(key, [0, []])
                f[0] += 1
                if len(f[1]) < 5:
                    f[1].append("%d %s" % (fid, parts[-1]))
    rep.ok("client sound files with a listfile path: %d (no path: %d)" % (named, len(ske) - named))
    rep.add("client files per top folder (files, of them in the studio):")
    for r0, (n, h) in sorted(roots.items(), key=lambda kv: -kv[1][0])[:25]:
        rep.add("- %s: %d, %d" % (r0, n, h))
    tot = sum(f[0] for f in fold.values())
    rep.ok("voice-like client files NOT in the studio: %d in %d folders" % (tot, len(fold)))
    for k, (n, sm) in sorted(fold.items(), key=lambda kv: -kv[1][0])[:top * 2]:
        rep.add("- %s: %d: %s" % (k, n, ", ".join(sm)))
    rep.h("3. Texts, race, sex, names")
    fl = [x for x in L if x[0] in fv]
    wt = [x for x in fl if str(x[0]) in T]
    wf = [x for x in wt if (T[str(x[0])] + ["", ""])[1]]
    rep.ok("Forever lines %d, with spoken text %d, with Persian %d" % (len(fl), len(wt), len(wf)))
    cnt = {}
    for x in fl:
        cnt.setdefault(G[x[1]][0], set()).add(x[1])
    dup = [k for k, v in cnt.items() if len(v) > 1]
    rep.ok("group names used by more than one group: %d: %s" % (len(dup), ", ".join(sorted(dup)[:30])))
    return []
