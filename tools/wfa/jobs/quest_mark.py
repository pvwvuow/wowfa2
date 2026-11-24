"""Mark the plain Persian names in the quest texts (every field the player reads: obj, det, pro,
com, desc and the tracker objective lists 'o') so the runtime can colour them.

Sources of a (Persian -> family, English) pair, strongest first:
  learned   every full marker {{fam:EN|FA}} already in the data (a deliberate translator choice)
  table     data/names npc + boss (npc), zone (zn), obj (ob)
  professions   the profession skills of data/names/spell (sp)
Safety: a single-word NPC / zone / object name is marked only when it was learned or is a long
proper name (>= 5 letters) that is not in the stop list, not used as a plural and not seen more than
max_single times; two families sharing one Persian string are skipped; classes and common spell
words are never marked. Titles ('t') are left alone (the list wraps them in its own colour).
args: apply, stop_keys, stop (Persian strings), max_single (60), min_single (5), sample (20), top (40)
"""
import collections
import random
import re

from wfa.core import MARKER_RE, name_key
from wfa.store import Store

FIELDS = ("obj", "det", "pro", "com", "desc")
KIND_OF = {"npc": "npc", "zn": "zone", "ob": "obj", "sp": "spell"}
SKIP = re.compile(r"\{\{[^{}]*\}\}|\{\d+\}|<[^<>]*>|\$[GgNnCcRrBb](?:[^;:\s]*:[^;]*;)?|\|c[0-9a-fA-F]{8}|\|r")
# letters only: the Arabic punctuation (\u060c \u061b \u061f) and the diacritics end a word
PERS = "\u0621-\u063a\u0641-\u064a\u0670\u0679-\u06d3\u06f0-\u06f9\u200c"
SMALL = {"of", "the", "and", "in", "on", "at", "to", "de", "la", "du", "von"}
PROFESSIONS = ("alchemy", "blacksmithing", "enchanting", "engineering", "herbalism", "leatherworking",
               "mining", "skinning", "tailoring", "cooking", "fishing", "first aid", "gnome engineering",
               "goblin engineering", "gnomish engineering", "dragonscale leatherworking",
               "elemental leatherworking", "tribal leatherworking", "armorsmith", "weaponsmith",
               "swordsmith", "hammersmith", "axesmith", "mooncloth tailoring", "shadoweave tailoring",
               "spellfire tailoring", "transmutation", "lockpicking")
STOP_KEYS = ("cleft", "den", "legendary", "sepulcher", "talar", "aman", "scald", "beast", "phantasm",
             "slave", "lady", "torn", "broken one", "rotted one", "aeolynn", "priest", "buzzard", "boar",
             "spider", "raptor", "murloc", "bear", "wolf", "guard", "hunter", "spirit", "shadow", "ghost",
             "jang", "shade", "raze", "ferra", "bayne", "ogre", "horse", "roon", "chicken", "boy", "slime",
             "dar", "baron", "steven", "peon", "grub", "crawler", "duke", "poley", "prowler", "panther",
             "rat", "priestess", "deer", "nightmare", "cat", "skeleton", "shore", "wanted", "maul",
             "drunk", "mound of dirt", "loose dirt")


def title_of(key):
    out = []
    for i, w in enumerate(key.split(" ")):
        if i and w in SMALL:
            out.append(w)
        else:
            out.append("-".join(p[:1].upper() + p[1:] for p in w.split("-")))
    return " ".join(out)


def each_seg(text, fn):
    out, pos = [], 0
    for m in SKIP.finditer(text):
        out.append(fn(text[pos:m.start()]))
        out.append(m.group(0))
        pos = m.end()
    out.append(fn(text[pos:]))
    return "".join(out)


def letters(fa):
    return len(fa.replace("\u200c", "").replace(" ", ""))


def run(args, rep):
    store = Store.load()
    apply = bool(args.get("apply"))
    stop_keys = set(STOP_KEYS) | set(args.get("stop_keys") or [])
    stop = set(args.get("stop") or [])
    max_single = int(args.get("max_single", 60))
    min_single = int(args.get("min_single", 5))
    top = int(args.get("top", 40))

    def segs(rec):
        for f in FIELDS:
            v = rec.get(f)
            if v:
                yield f, None, v
        for i, v in enumerate(rec.get("o") or []):
            if v:
                yield "o", i, v

    # ---- learned pairs + original-case English
    learned = collections.defaultdict(set)   # fa -> {(fam, key)}
    en_case = {}                             # (fam, key) -> English as written
    for rec in store.quests.values():
        for f in FIELDS + ("t", "o"):
            v = rec.get(f)
            for seg in (v if isinstance(v, list) else [v]):
                for m in MARKER_RE.finditer(seg or ""):
                    fam, en, fa = m.group(1), m.group(2), m.group(3)
                    if fam not in KIND_OF or not en:
                        continue
                    en_case.setdefault((fam, name_key(en)), en)
                    if fa and not re.search(r"[A-Za-z0-9{}|]", fa) and letters(fa) >= 4:
                        learned[fa].add((fam, name_key(en)))
    cand = {}
    amb = set()

    def put(fa, val, src):
        cur = cand.get(fa)
        if fa in amb:
            return
        if cur is None:
            cand[fa] = (val, src)
        elif cur[0] != val:
            if cur[1] == "learned" and src == "table":
                return
            if cur[1] == "table" and src == "learned":
                cand[fa] = (val, src)
                return
            amb.add(fa)
            cand.pop(fa, None)

    for fa, s in learned.items():
        if len(s) == 1:
            put(fa, next(iter(s)), "learned")
        else:
            amb.add(fa)
    for kind, fam in (("npc", "npc"), ("boss", "npc"), ("zone", "zn"), ("obj", "ob")):
        for key, fa in store.names[kind].items():
            fa = (fa or "").strip()
            if not fa or fa in stop or key in stop_keys or re.search(r"[A-Za-z0-9{}|]", fa):
                continue
            if " " in fa:
                if letters(fa) < 6:
                    continue
            elif letters(fa) < min_single:
                continue
            put(fa, (fam, key), "table")
    for key in PROFESSIONS:
        fa = (store.names["spell"].get(key) or "").strip()
        if fa and fa not in stop and not re.search(r"[A-Za-z0-9{}|]", fa) and letters(fa) >= 4:
            put(fa, ("sp", key), "table")
    cand = {fa: v for fa, v in cand.items() if fa not in amb and fa not in stop and v[0][1] not in stop_keys}
    rep.h("Candidates")
    rep.ok("%d names usable (%d learned from existing markers), %d skipped as ambiguous" % (
        len(cand), sum(1 for v in cand.values() if v[1] == "learned"), len(amb)))
    alt = "|".join(re.escape(x) for x in sorted(cand, key=lambda s: (-len(s), s)))
    rx = re.compile("(?<![%sA-Za-z0-9])(?:%s)(?![%sA-Za-z0-9])" % (PERS, alt, PERS))
    rx_pl = re.compile("(?<![%sA-Za-z0-9])(%s)(?=\u200c?(?:\u0647\u0627|\u0647\u0627\u06cc)(?![%s]))" % (PERS, alt, PERS))

    hits = collections.Counter()
    plural = collections.Counter()
    where = collections.defaultdict(set)
    for qid, rec in store.quests.items():
        for f, i, v in segs(rec):
            def cnt(s):
                for m in rx.finditer(s):
                    hits[m.group(0)] += 1
                    where[m.group(0)].add(qid)
                for m in rx_pl.finditer(s):
                    plural[m.group(1)] += 1
                return s
            each_seg(v, cnt)
    common = set()
    for fa, n in hits.items():
        if " " not in fa and (plural.get(fa) or n > max_single):
            common.add(fa)
    use = {fa: v for fa, v in cand.items() if hits.get(fa) and fa not in common}
    rep.h("Plain names found")
    rep.ok("%d different names, %d hits in %d quests; %d single-word names skipped as common nouns" % (
        len(hits), sum(hits.values()), len(set().union(*where.values())) if where else 0, len(common)))
    byfam = collections.Counter()
    for fa, n in hits.items():
        if fa in use:
            byfam[use[fa][0][0]] += n
    rep.ok("to mark per family: %s" % dict(byfam))
    rep.table([(fa, use[fa][0][0], use[fa][0][1], use[fa][1], hits[fa]) for fa, _n in
               sorted(((fa, hits[fa]) for fa in use), key=lambda x: -x[1])[:top]],
              ["persian", "family", "english key", "source", "hits"])
    rep.h("Skipped as common nouns")
    rep.add(" ".join(sorted(common)))
    rnd = random.Random(5)
    sample = []
    for qid, rec in store.quests.items():
        for f, i, v in segs(rec):
            each_seg(v, lambda s, q=qid, ff=f: ([sample.append((q, ff, m.group(0), s[max(0, m.start() - 25):m.end() + 25].replace("\n", " ")))
                                                 for m in rx.finditer(s) if m.group(0) in use], s)[1])
    rnd.shuffle(sample)
    rep.h("Sample contexts")
    for q, f, fa, c in sample[:int(args.get("sample", 20))]:
        rep.add("- q%d %s %s: ...%s..." % (q, f, fa, c))
    if not apply:
        rep.ok("report only: nothing written")
        return []

    def table_fa(fam, key):
        return store.names[KIND_OF[fam]].get(key) if fam != "npc" else (store.names["npc"].get(key) or store.names["boss"].get(key))

    def mark(m):
        fa = m.group(0)
        v = use.get(fa)
        if not v:
            return fa
        (fam, key), _src = v
        en = en_case.get((fam, key)) or title_of(key)
        if table_fa(fam, key) == fa:
            return "{{%s:%s}}" % (fam, en)
        return "{{%s:%s|%s}}" % (fam, en, fa)

    changed = marks = 0
    for qid, rec in store.quests.items():
        for f in FIELDS:
            v = rec.get(f)
            if v:
                new = each_seg(v, lambda s: rx.sub(mark, s))
                if new != v:
                    marks += len(MARKER_RE.findall(new)) - len(MARKER_RE.findall(v))
                    rec[f] = new
                    changed += 1
        o = rec.get("o")
        if o:
            out = []
            for v in o:
                new = each_seg(v, lambda s: rx.sub(mark, s)) if v else v
                if new != v:
                    marks += len(MARKER_RE.findall(new)) - len(MARKER_RE.findall(v))
                    changed += 1
                out.append(new)
            rec["o"] = out
    rep.ok("%d fields rewritten, %d markers added" % (changed, marks))
    store.save()
    return ["data"]
