"""Every data gate in one place. ERROR fails the build. RATCHET counts may never grow past
policy.json "ratchet" (so known debt is visible and can only shrink). Nothing is skipped silently:
every gate reports a number, even when it is 0."""
import re

from .core import FREE_MARKERS, MARKER_KIND, MARKER_RE
from .store import QUEST_FIELDS

LATIN = re.compile(r"[A-Za-z]")
DOLLAR = re.compile(r"\$[A-Za-z]+(?:[^;]*;)?|\$\w")      # $N $C $R $B $Gmale:female;
COLOR_UPPER = re.compile(r"\|C[0-9A-Fa-f]{8}|\|R")
SLOT = re.compile(r"\{(\d+)\}")
UNIT_EN = {"sec": "\u062b\u0627\u0646\u06cc\u0647", "min": "\u062f\u0642\u06cc\u0642\u0647", "hr": "\u0633\u0627\u0639\u062a"}
BAD_CHARS = {"\ufffd": "U+FFFD replacement char", "\ufeff": "U+FEFF BOM",
             "\u200e": "U+200E LRM", "\u200f": "U+200F RLM",
             "\u2010": "U+2010 hyphen (no glyph in Vazirmatn)",
             "\u2011": "U+2011 non-breaking hyphen (no glyph in Vazirmatn)"}


class Result:
    def __init__(self):
        self.errors = []      # (gate, where, msg)
        self.ratchet = {}     # gate -> [examples]
        self.counts = {}      # name -> int
        self.notes = []

    def err(self, gate, where, msg):
        self.errors.append((gate, where, msg))

    def debt(self, gate, where, msg):
        self.ratchet.setdefault(gate, []).append("%s: %s" % (where, msg))


def strip_markers(s):
    return MARKER_RE.sub(" ", s)


def check_text(r, where, s, banned):
    for ch, label in BAD_CHARS.items():
        if ch in s:
            r.err("chars", where, label)
    if COLOR_UPPER.search(s):
        r.err("colour", where, "uppercase colour escape (|C / |R): the game prints it as text")
    for b in banned:
        if b in s:
            r.err("banned", where, "banned string %r" % b)
    # marker grammar: every {{ must be a whole, known marker
    rest = MARKER_RE.sub("", s)
    if "{{" in rest or "}}" in rest:
        r.err("marker", where, "broken marker syntax")
    for m in MARKER_RE.finditer(s):
        kind = m.group(1)
        if kind not in MARKER_KIND and kind not in FREE_MARKERS:
            r.err("marker", where, "unknown marker kind %r" % kind)
    plain = DOLLAR.sub(" ", strip_markers(s))
    plain = re.sub(r"\|c[0-9a-f]{8}|\|r|\|T[^|]*\|t|\|H[^|]*\|h", " ", plain)
    if LATIN.search(plain):
        r.debt("latin_in_fa", where, plain.strip()[:80])


def run(store, policy):
    r = Result()
    banned = store.terms.get("banned", [])
    # ---- quests
    no_title = 0
    for qid, rec in store.quests.items():
        if not rec.get("t"):
            no_title += 1
        for f in QUEST_FIELDS[1:]:
            if rec.get(f):
                check_text(r, "q:%d:%s" % (qid, f), rec[f], banned)
        for i, line in enumerate(rec.get("o") or []):
            check_text(r, "q:%d:o%d" % (qid, i + 1), line, banned)
        h = rec.get("h", "")
        if h and not re.fullmatch(r"[0-9a-f]{8}", h):
            r.err("quest", "q:%d" % qid, "bad title hash %r" % h)
    if no_title:
        r.debt("quest_no_title", "quests", "%d quests without a Persian title" % no_title)
    # ---- names
    for kind, table in store.names.items():
        seen = {}
        for k, v in table.items():
            w = "n:%s:%s" % (kind, k)
            if not v.strip():
                r.err("empty", w, "empty Persian")
                continue
            if k != k.lower() or k != k.strip() or "  " in k:
                r.err("key", w, "key is not name_key() form")
            check_text(r, w, v, banned)
            seen.setdefault(v, []).append(k)
        if kind in policy["ship"]["names"]:
            for fa, keys in seen.items():
                if len(keys) > 1:
                    r.debt("name_pairs_" + kind, kind, "%s <- %s" % (fa, ", ".join(sorted(keys))))
    # ---- short markers must point at a row (else the game shows English there)
    def short_refs(where, s):
        for m in MARKER_RE.finditer(s):
            kind, en, fa = m.group(1), m.group(2), m.group(3)
            if fa is None and kind in MARKER_KIND:
                from .core import name_key
                if name_key(en) not in store.names[MARKER_KIND[kind]]:
                    r.debt("marker_unresolved", where, "{{%s:%s}}" % (kind, en))
    for qid, rec in store.quests.items():
        for f in QUEST_FIELDS[1:]:
            if rec.get(f):
                short_refs("q:%d:%s" % (qid, f), rec[f])
    # ---- templates
    for k, v in store.tpl.items():
        w = "tpl:" + k[:60]
        if not v.strip():
            r.err("empty", w, "empty Persian")
            continue
        check_text(r, w, v, banned)
        short_refs(w, v)
        n = k.count("#")
        used = [int(x) for x in SLOT.findall(v)]
        for i in used:
            if i >= n:
                r.err("slot", w, "slot {%d} but the English has only %d numbers" % (i, n))
        for i in range(n):
            if i not in used:
                r.debt("slot_unused", w, "number #%d never shown" % (i + 1))
        # duration slot must be followed by its unit word
        for i, m in enumerate(re.finditer(r"#", k)):
            after = k[m.end():m.end() + 5].strip()
            for en_u, fa_u in UNIT_EN.items():
                if after.startswith(en_u) and ("{%d}" % i) in v:
                    tail = v.split("{%d}" % i, 1)[1].lstrip()
                    if not tail.startswith(fa_u):
                        r.debt("unit_word", w, "{%d} not followed by %s" % (i, fa_u))
    # ---- ui
    for k, v in store.ui.items():
        check_text(r, "ui:" + k, v, banned)
    # ---- counts + floors (the anti-'#245' gate: data can never vanish silently)
    r.counts["quests"] = len(store.quests)
    r.counts["quests_with_title"] = len(store.quests) - no_title
    r.counts["tpl"] = len(store.tpl)
    r.counts["ui"] = len(store.ui)
    for kind, table in store.names.items():
        r.counts["names." + kind] = len(table)
    for name, floor in policy.get("floors", {}).items():
        have = r.counts.get(name)
        if have is None:
            r.err("floor", name, "unknown count name in policy.json floors")
        elif have < floor:
            r.err("floor", name, "%d rows, floor is %d (data lost? if on purpose, lower the floor in the same PR)" % (have, floor))
    for gate, items in r.ratchet.items():
        cap = policy.get("ratchet", {}).get(gate)
        if cap is not None and len(items) > cap:
            r.err("ratchet", gate, "%d now, allowed %d: new debt added" % (len(items), cap))
    return r
