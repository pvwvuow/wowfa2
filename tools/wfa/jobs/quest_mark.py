"""Mark the plain Persian names in the quest texts (every field the player reads: obj, det, pro,
com, desc and the tracker objective lists 'o') so the runtime can colour them.

Sources of a (Persian -> family, English) pair, strongest first:
  learned   every full marker {{fam:EN|FA}} already in the data (a deliberate translator choice)
  table     data/names npc + boss (npc), zone (zn), obj (ob), it (items, with items = true)
  professions   the profession skills of data/names/spell (sp)
Safety: a single-word name is marked only when it was learned or has >= min_single letters, is not
in the stop list, not used as a plural and not seen more than max_single times; two families
sharing one Persian string are skipped; classes and common spell words are never marked. Titles
('t') are left alone (the list wraps them in its own colour).
args: apply, stop_keys, stop (Persian strings), max_single (60), min_single (5), sample (20), top (40),
      items (true = also item names: learned, or table names of >= 8 letters),
      max_item (40: an item name seen more often than this is a generic phrase, skipped),
      aliases (true = a kill target that the quest text names differently from the marker in its own
      desc ("10 <alias> ra bokosh...") gets that marker with the text as written),
      check (rows of the final list of the most used single-word markers)
"""
import collections
import random
import re

from wfa.core import MARKER_RE, name_key
from wfa.store import Store

FIELDS = ("obj", "det", "pro", "com", "desc")
KIND_OF = {"npc": "npc", "zn": "zone", "ob": "obj", "sp": "spell", "it": "it"}
SKIP = re.compile(r"\{\{[^{}]*\}\}|\{\d+\}|<[^<>]*>|\$[GgNnCcRrBb](?:[^;:\s]*:[^;]*;)?|\|c[0-9a-fA-F]{8}|\|r")
# letters only: the Arabic punctuation (\u060c \u061b \u061f) and the diacritics end a word
PERS = "\u0621-\u063a\u0641-\u064a\u0670\u0679-\u06d3\u06f0-\u06f9\u200c"
WORDCH = "[^\\s{}\u060c\u061b.!\u061f:0-9\u06f0-\u06f9]"
KILL = re.compile("([0-9\u06f0-\u06f9]+)\\s+(%s+(?:\\s+%s+){0,3}?)\\s+\u0631\u0627\\s+(?:\u0628\u06a9\u0634|\u0634\u06a9\u0627\u0631)" % (WORDCH, WORDCH))
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
             "drunk", "mound of dirt", "loose dirt", "girl", "abandoned")


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


_WORD = re.compile("[%s]+" % PERS)
_PERS1 = re.compile("[%s]" % PERS)
_PLURAL = re.compile("\u200c?(?:\u0647\u0627|\u0647\u0627\u06cc)(?![%s])" % PERS)


class Finder:
    """Longest-first whole-name matcher, indexed by the first word (a 30k-name regex alternation
    is far too slow in Python). A name must start and end on a word edge; plural=True yields the
    names that are followed by the plural suffix instead (a common noun test)."""

    def __init__(self, names):
        self.index = collections.defaultdict(list)
        for n in names:
            m = _WORD.match(n)
            if m:
                self.index[m.group(0)].append(n)
        for k in self.index:
            self.index[k].sort(key=lambda x: (-len(x), x))

    @staticmethod
    def _edge(ch):
        return ch == "" or not (_PERS1.match(ch) or ("A" <= ch <= "Z") or ("a" <= ch <= "z") or ("0" <= ch <= "9"))

    def find(self, text, plural=False):
        pos = 0
        for m in _WORD.finditer(text):
            s = m.start()
            if s < pos:
                continue
            if s and not self._edge(text[s - 1]) and not _PERS1.match(text[s - 1]):
                continue
            for name in self.index.get(m.group(0)) or ():
                if not text.startswith(name, s):
                    continue
                e = s + len(name)
                if plural:
                    ok = _PLURAL.match(text, e) is not None
                else:
                    ok = self._edge(text[e:e + 1])
                if ok:
                    yield s, e, name
                    pos = e
                    break

    def sub(self, text, fn):
        out, last = [], 0
        for s, e, name in self.find(text):
            out.append(text[last:s])
            out.append(fn(name))
            last = e
        out.append(text[last:])
        return "".join(out)


def run(args, rep):
    store = Store.load()
    apply = bool(args.get("apply"))
    stop_keys = set(STOP_KEYS) | set(args.get("stop_keys") or [])
    stop = set(args.get("stop") or [])
    max_single = int(args.get("max_single", 60))
    min_single = int(args.get("min_single", 5))
    max_item = int(args.get("max_item", 40))
    top = int(args.get("top", 40))
    want_items = bool(args.get("items"))
    want_alias = bool(args.get("aliases"))

    def segs(rec):
        for f in FIELDS:
            v = rec.get(f)
            if v:
                yield f, None, v
        for i, v in enumerate(rec.get("o") or []):
            if v:
                yield "o", i, v

    def table_fa(fam, key):
        if fam == "npc":
            return store.names["npc"].get(key) or store.names["boss"].get(key)
        return store.names[KIND_OF[fam]].get(key)

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
                    if fam == "it" and not want_items:
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
    if want_items:
        for key, fa in store.names["it"].items():
            fa = (fa or "").strip()
            if not fa or fa in stop or key in stop_keys or re.search(r"[A-Za-z0-9{}|]", fa):
                continue
            if " " not in fa or letters(fa) < 8:
                continue
            put(fa, ("it", key), "table")
    for key in PROFESSIONS:
        fa = (store.names["spell"].get(key) or "").strip()
        if fa and fa not in stop and not re.search(r"[A-Za-z0-9{}|]", fa) and letters(fa) >= 4:
            put(fa, ("sp", key), "table")
    cand = {fa: v for fa, v in cand.items() if fa not in amb and fa not in stop and v[0][1] not in stop_keys}
    rep.h("Candidates")
    rep.ok("%d names usable (%d learned from existing markers), %d skipped as ambiguous" % (
        len(cand), sum(1 for v in cand.values() if v[1] == "learned"), len(amb)))
    finder = Finder(list(cand))

    hits = collections.Counter()
    plural = collections.Counter()
    where = collections.defaultdict(set)
    for qid, rec in store.quests.items():
        for f, i, v in segs(rec):
            def cnt(s, qid=qid):
                for _a, _b, name in finder.find(s):
                    hits[name] += 1
                    where[name].add(qid)
                for _a, _b, name in finder.find(s, plural=True):
                    plural[name] += 1
                return s
            each_seg(v, cnt)
    common = set()
    generic_items = set()
    for fa, n in hits.items():
        if " " not in fa and (plural.get(fa) or n > max_single):
            common.add(fa)
        if cand[fa][0][0] == "it" and cand[fa][1] == "table" and n > max_item:
            generic_items.add(fa)
    use = {fa: v for fa, v in cand.items() if hits.get(fa) and fa not in common and fa not in generic_items}
    rep.h("Plain names found")
    rep.ok("%d different names, %d hits in %d quests; %d single-word names skipped as common nouns, %d item names skipped as generic" % (
        len(hits), sum(hits.values()), len(set().union(*where.values())) if where else 0, len(common), len(generic_items)))
    byfam = collections.Counter()
    for fa, n in hits.items():
        if fa in use:
            byfam[use[fa][0][0]] += n
    rep.ok("to mark per family: %s" % dict(byfam))
    rep.table([(fa, use[fa][0][0], use[fa][0][1], use[fa][1], hits[fa]) for fa, _n in
               sorted(((fa, hits[fa]) for fa in use), key=lambda x: -x[1])[:top]],
              ["persian", "family", "english key", "source", "hits"])
    rep.h("Skipped as common nouns / generic items")
    rep.add(" ".join(sorted(common)))
    rep.add("ITEMS: " + " ".join(sorted(generic_items)))
    rnd = random.Random(5)
    sample = []
    for qid, rec in store.quests.items():
        for f, i, v in segs(rec):
            each_seg(v, lambda s, q=qid, ff=f: ([sample.append((q, ff, name, s[max(0, a - 25):b + 25].replace("\n", " ")))
                                                 for a, b, name in finder.find(s) if name in use], s)[1])
    rnd.shuffle(sample)
    rep.h("Sample contexts")
    for q, f, fa, c in sample[:int(args.get("sample", 20))]:
        rep.add("- q%d %s %s: ...%s..." % (q, f, fa, c))

    # ---- aliases of kill targets
    alias = {}   # qid -> {P: (fam, key, en)}
    if want_alias:
        rep.h("Kill targets named differently from their marker")
        shown = 0
        for qid, rec in store.quests.items():
            ms = set()
            for m in MARKER_RE.finditer(rec.get("desc") or ""):
                if m.group(1) == "npc" and m.group(2):
                    ms.add((name_key(m.group(2)), m.group(2), m.group(3)))
            if len({x[0] for x in ms}) != 1:
                continue
            key, en, fam_fa = next(iter(ms))
            fa_m = fam_fa or table_fa("npc", key)
            if not fa_m:
                continue
            words = set(re.split("[ \u200c]", fa_m))
            found = {}
            for f, i, v in segs(rec):
                if f == "desc":
                    continue
                each_seg(v, lambda s: ([found.setdefault(m.group(2).strip(), 0) for m in KILL.finditer(s)], s)[1])
            for p in found:
                if p == fa_m or p in cand or p in use:
                    continue
                if not (words & set(re.split("[ \u200c]", p))):
                    if shown < 25:
                        rep.add("- q%d NOT shared: %s vs marker %s" % (qid, p, fa_m))
                        shown += 1
                    continue
                alias.setdefault(qid, {})[p] = ("npc", key, en_case.get(("npc", key)) or en)
                if shown < 25:
                    rep.add("- q%d alias %s -> %s (%s)" % (qid, p, fa_m, en))
                    shown += 1
        rep.ok("%d quests get an alias marker" % len(alias))

    if not apply:
        rep.ok("report only: nothing written")
        return []

    def mark(fa):
        v = use.get(fa)
        if not v:
            return fa
        (fam, key), _src = v
        en = en_case.get((fam, key)) or title_of(key)
        if table_fa(fam, key) == fa:
            return "{{%s:%s}}" % (fam, en)
        return "{{%s:%s|%s}}" % (fam, en, fa)

    def apply_text(qid, text):
        new = each_seg(text, lambda s: finder.sub(s, mark))
        al = alias.get(qid)
        if al:
            for p, (fam, key, en) in sorted(al.items(), key=lambda x: -len(x[0])):
                rxa = re.compile("(?<![%sA-Za-z0-9])%s(?![%sA-Za-z0-9])" % (PERS, re.escape(p), PERS))
                new = each_seg(new, lambda s, rxa=rxa, fam=fam, en=en, p=p: rxa.sub("{{%s:%s|%s}}" % (fam, en, p), s))
        return new

    changed = marks = 0
    for qid, rec in store.quests.items():
        for f in FIELDS:
            v = rec.get(f)
            if v:
                new = apply_text(qid, v)
                if new != v:
                    marks += len(MARKER_RE.findall(new)) - len(MARKER_RE.findall(v))
                    rec[f] = new
                    changed += 1
        o = rec.get("o")
        if o:
            out = []
            for v in o:
                new = apply_text(qid, v) if v else v
                if new != v:
                    marks += len(MARKER_RE.findall(new)) - len(MARKER_RE.findall(v))
                    changed += 1
                out.append(new)
            rec["o"] = out
    rep.ok("%d fields rewritten, %d markers added" % (changed, marks))

    # ---- check list: the most used single-word markers after the pass
    used = collections.Counter()
    for rec in store.quests.values():
        for f in FIELDS + ("o",):
            v = rec.get(f)
            for seg in (v if isinstance(v, list) else [v]):
                for m in MARKER_RE.finditer(seg or ""):
                    fam, en, fa = m.group(1), m.group(2), m.group(3)
                    if fam in KIND_OF and en:
                        shown_fa = fa or table_fa(fam, name_key(en)) or "?"
                        if " " not in shown_fa:
                            used[(fam, shown_fa, en)] += 1
    rep.h("Check: the most used single-word markers (a common word here is a wrong marker)")
    rep.table([(a, b, c, n) for (a, b, c), n in used.most_common(int(args.get("check", 60)))],
              ["family", "persian", "english", "uses"])
    store.save()
    return ["data"]
