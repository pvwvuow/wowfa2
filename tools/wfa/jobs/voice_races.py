"""Report only: what the lines of the player-race voice groups (kind h) look like, kept and dropped.

Reads tools/dub-studio/voice_db.js. For every kind h group (Human, Gnome, Bloodelf ... with the
Male / Female / pc variants) the line names are reduced to a stem (digits -> #, group name removed);
the report lists every stem with its count, and the studio's current category for it (or "dropped").
args: top (how many stems to list, default 400)
"""
import collections
import json
import re

DB = "tools/dub-studio/voice_db.js"
GRUNT = re.compile(r"wound|attack|death|(^|_)dies?(_|\d|$)|dying|pain|hurt|injur|grunt|roar|breath|footstep|windup|(^|_)cast|jump|(^|_)land|effort|exert|battleshout|battlecry|warcry|emote|laugh|cheer|chuckle|sigh|yawn|cough|sneeze|whistle|snore|knock|choochoo|clap|kiss|giggle|flirt|fidget|loop|idle|stand|bored|footfall|swim|fall|parry|dodge|block|crit|spell|precast|channel|mount|growl|snarl|howl|bark|hiss|chirp|squawk|purr|whine|moo|oink|neigh|bleat|screech|shriek|scream|gasp|stun|knockdown|sleep|yell_?pain")
SPEECH = re.compile(r"slay|kill|intro|yell|(^|_)say|speech|speak|taunt|summon|berserk|engage|event|quest|(^|_)line|vo_qe|vo_quest|order|command|special|phase|talk|whisper|warn|alert|chat|greet|bye|farewell|(^|_)\d{2,3}_[mf]$|(^|_)[mf]$|response|reply|story|lore|intro|outro|victory|defeat|win|lose|thank|help|question|vendor|trainer|flight|innkeeper|guard")


def cat_of(n):
    if "greet" in n:
        return "greeting"
    if re.search(r"farewell|goodbye|(^|_)bye", n):
        return "farewell"
    if re.search(r"pissed|annoy", n):
        return "pissed"
    if "aggro" in n:
        return "aggro"
    if GRUNT.search(n):
        return "dropped (grunt/emote word)"
    if SPEECH.search(n):
        return "speech"
    return "dropped (no speech word)"


def run(args, rep):
    s = open(DB, encoding="ascii").read()
    db = json.loads(s[s.index("=") + 1:s.rindex(";")])
    G, L = db["G"], db["L"]
    rep.h("Player-race groups")
    hg = {i: g[0] for i, g in enumerate(G) if g[1] == "h"}
    rep.ok("%d kind-h groups of %d: %s" % (len(hg), len(G), ", ".join(sorted(hg.values())[:60])))
    stems = collections.Counter()
    status = {}
    total = 0
    for x in L:
        if x[1] not in hg:
            continue
        total += 1
        n = x[3].lower()
        g = re.sub(r"[^a-z0-9]", "", hg[x[1]].lower())
        m = n.replace(g, "").strip("_")
        st = re.sub(r"\d+", "#", m)
        stems[st] += 1
        status[st] = cat_of(n)
    rep.ok("%d lines in those groups, %d distinct stems" % (total, len(stems)))
    per = collections.Counter()
    for st, k in stems.items():
        per[status[st]] += k
    rep.table(sorted(per.items(), key=lambda kv: -kv[1]), ["studio category now", "lines"])
    rep.h("Stems")
    rows = [(st, k, status[st]) for st, k in stems.most_common(int(args.get("top", 400)))]
    rep.table(rows, ["stem", "lines", "now"])
    return []
