"""Writes the Data.lua of the voice test addon from ci/work/voice/addon_data.txt (job voice_addon).
args: stems = ["Group/line name", ...] the lines that have a recording (the addon holds voice/<file id>.ogg for each),
      out = path of the Data.lua (default tools/dub-addon/WoWFA_VoiceTest/Data.lua)"""
import collections
import hashlib
import re

AD = "ci/work/voice/addon_data.txt"
ERRG = "Trollmaleerrormessages"
CATS = ("greeting", "farewell", "pissed", "aggro", "vendor")


def rng(s):
    out = []
    for part in filter(None, s.split(",")):
        a, _, b = part.partition("-")
        out += list(range(int(a), int(b or a) + 1))
    return out


def cat_of(stem):
    s = stem.lower()
    for key, cat in (("farewell", "farewell"), ("pissed", "pissed"), ("vendor", "vendor"), ("greet", "greeting")):
        if key in s:
            return cat
    return None


def ids(v):
    return "{ " + ", ".join(str(x) for x in v) + " }"


def run(args, rep):
    G, L, S, C, M, X = {}, collections.defaultdict(dict), {}, collections.defaultdict(list), {}, []
    for ln in open(AD, encoding="utf-8"):
        p = ln.rstrip("\n").split("|")
        if p[0] == "G":
            G[p[1]] = dict(race=p[2], sex=p[3], guard=p[4] == "1")
        elif p[0] == "L":
            L[p[1]][p[2]] = int(p[3])
        elif p[0] == "S":
            S[p[1]] = rng(p[2])
        elif p[0] == "C":
            C[p[1]] = rng(p[2])
        elif p[0] == "M":
            M[int(p[1])] = p[2].split(",")
        elif p[0] == "X":
            X.append(p)
    stems = args.get("stems")
    if not stems and args.get("stems_from"):
        import json
        stems = json.load(open(args["stems_from"], encoding="utf-8"))["args"]["args"]["steps"][0]["args"]["stems"]
    have = collections.defaultdict(dict)
    for st in stems:
        g, _, stem = st.partition("/")
        if stem not in L[g]:
            rep.fail("no game sound for %s" % st)
            return []
        have[g][stem] = L[g][stem]
    dubbed = {}
    for g, d in have.items():
        if g == ERRG:
            continue
        cats = collections.defaultdict(list)
        for stem, fid in sorted(d.items(), key=lambda kv: kv[1]):
            c = cat_of(stem)
            if c:
                cats[c].append(fid)
            else:
                rep.fail("no category: %s %s" % (g, stem))
        dubbed[g] = cats
    kinds = collections.OrderedDict()
    for stem, fid in sorted(L[ERRG].items()):
        m = re.match(r"^[a-z]+male_err_(.+?)\d+$", stem)
        if not m:
            rep.fail("odd error name %s" % stem)
            continue
        k = kinds.setdefault(m.group(1), {"orig": [], "dub": []})
        k["orig"].append(fid)
        if stem in have[ERRG]:
            k["dub"].append(fid)
    o = ["WoWFAVoiceData = {", '  dir = "Interface\\\\AddOns\\\\WoWFA_VoiceTest\\\\voice\\\\",', "  count = 0,", "  npcs = {},", "  extraMute = { %s }," % ", ".join(str(x) for x in S.get("_extra", [])), "  generic = {"]
    for g in sorted(dubbed):
        info, c = G[g], dubbed[g]
        o.append("    {")
        o.append('      name = "%s", race = "%s", sex = "%s", guard = %s,' % (g, info["race"], info["sex"], "true" if info["guard"] else "false"))
        for cat in CATS:
            if c.get(cat):
                o.append("      %s = { %s }," % (cat, ", ".join('{ f = "%d.ogg", id = %d }' % (f, f) for f in c[cat])))
        o.append("      mute = { %s }," % ", ".join(str(x) for x in S.get(g, [])))
        o.append("    },")
    o.append("  },")
    names = set(dubbed)
    by = collections.OrderedDict()
    for g in sorted(C):
        if g in names:
            for e in C[g]:
                by.setdefault(e, []).append((0, g))
    for p in X:
        e, pairs = int(p[1]), []
        for part in p[2].split("/"):
            mod, _, g = part.partition(":")
            pairs.append((int(mod), g if g != "-" and g in names else None))
        if any(g for _, g in pairs):
            by[e] = pairs
    o.append("  byEntry = {")
    for e in sorted(by):
        o.append("    [%d] = { %s }," % (e, ", ".join("{ %d, %s }" % (m, '"%s"' % g if g else "false") for m, g in by[e])))
    o.append("  },")
    o.append("  models = {")
    for m in sorted(M):
        gs = [g for g in M[m] if g in names]
        if gs:
            o.append("    [%d] = { %s }," % (m, ", ".join('"%s"' % g for g in gs)))
    o.append("  },")
    o.append('  player = { race = "%s", sex = "%s", errors = {' % (G[ERRG]["race"], G[ERRG]["sex"]))
    for k, v in kinds.items():
        if v["dub"]:
            o.append('    ["%s"] = { dub = %s, orig = %s },' % (k, ids(v["dub"]), ids(v["orig"])))
    o.append("  } },")
    o.append("}")
    text = "\n".join(o) + "\n"
    out = args.get("out") or "tools/dub-addon/WoWFA_VoiceTest/Data.lua"
    open(out, "w", encoding="utf-8", newline="\n").write(text)
    rep.ok("%s: %d bytes, sha256 %s" % (out, len(text.encode()), hashlib.sha256(text.encode()).hexdigest()))
    rep.ok("%d groups, %d creatures, %d error kinds with a dub" % (len(dubbed), len(by), len([k for k in kinds.values() if k["dub"]])))
    return [out]
