"""Spellbook + talent import from the site's class files (wow repo, data/forever/db/<class>.json).

Re-runnable after every game / site update: FILL-ONLY (an existing row is never overwritten, the
reviewed table wins; every disagreement is reported), and every new row must pass the same gates as
the rest of data/ BEFORE it is added, so an import can never add lint debt or break the ratchet.

What becomes what:
  tabs[].n/fa, trees[].n/fa            -> names/tree   (talent tree names)
  spells[].n/fa, trees..tiers[][].n/fa -> names/spell  (spell + talent names)
  spells[].d/dFa, tier nodes d/dFa     -> tpl          (description line: numbers -> #, Persian {i})
  spells[].reqs[i]/reqsFa[i]           -> tpl          ("Requires Battle Stance" lines)
A description row is taken only when the Persian carries EXACTLY the English numbers (each EN
number used, no extra number): a translation made for other numbers (an old rank, a changed patch
value) is reported, never guessed. dC/dCFa (the Classic text) is ignored: the live client is Forever.
"""
import re

from .core import MARKER_RE, name_key, num_key
from .lint import Result, SLOT, UNIT_EN, check_text
from .resolve import shorten

CLASSES = ("warrior", "paladin", "hunter", "rogue", "priest", "shaman", "mage", "warlock", "druid")
_FA_DIGITS = {ord(c): str(i) for i, c in enumerate("\u06f0\u06f1\u06f2\u06f3\u06f4\u06f5\u06f6\u06f7\u06f8\u06f9")}
_FA_DIGITS.update({ord(c): str(i) for i, c in enumerate("\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669")})
_FA_DIGITS[0x066B] = "."   # Arabic decimal separator
_NUM = re.compile(r"[0-9]+(?:\.[0-9]+)?")


def _fa_slots(fa, en_nums):
    """Persian text -> the same text with every number replaced by its EN slot {i}.
    None when a Persian number is not one of the EN numbers or an EN number is never used."""
    hold = []

    def keep(m):
        hold.append(m.group(0))
        return chr(0xE000 + len(hold) - 1)   # a private-use char: no digit inside the placeholder
    body = MARKER_RE.sub(keep, fa).translate(_FA_DIGITS)
    while re.search(r"[0-9],[0-9]{3}", body):
        body = re.sub(r"([0-9]),([0-9]{3})", r"\1\2", body)
    free = list(range(len(en_nums)))
    used = set()
    bad = []

    def slot(m):
        v = m.group(0)
        for i in free:
            if en_nums[i] == v:
                free.remove(i)
                used.add(i)
                return "{%d}" % i
        for i in used:          # the same number shown twice in Persian
            if en_nums[i] == v:
                return "{%d}" % i
        bad.append(v)
        return v
    out = _NUM.sub(slot, body)
    if bad or len(used) != len(en_nums):
        return None
    # equal EN values (75% ... 75%) are interchangeable at THIS rank only. If the Persian also
    # reorders the numbers, which slot is which can not be known: other ranks could swap values
    order = [int(x) for x in re.findall(r"\{([0-9]+)\}", out)]
    if len(set(en_nums)) < len(en_nums) and order != sorted(order):
        return None
    return re.sub("[\ue000-\uf8ff]", lambda m: hold[ord(m.group(0)) - 0xE000], out)


def _row_ok(key, fa, banned):
    """The per-row twin of lint.run's template gates: no error, no new debt."""
    r = Result()
    check_text(r, "tpl", fa, banned)
    n = key.count("#")
    used = [int(x) for x in SLOT.findall(fa)]
    if any(i >= n for i in used) or any(i not in used for i in range(n)):
        return False
    for i, m in enumerate(re.finditer(r"#", key)):
        after = key[m.end():m.end() + 5].strip()
        for en_u, fa_u in UNIT_EN.items():
            if after.startswith(en_u) and ("{%d}" % i) in fa:
                if not fa.split("{%d}" % i, 1)[1].lstrip().startswith(fa_u):
                    return False
    return not r.errors and not r.ratchet


def _name_ok(fa, banned):
    r = Result()
    check_text(r, "name", fa, banned)
    return bool(fa.strip()) and not r.errors and not r.ratchet


def import_classes(store, classes, banned=None):
    """classes: {class: parsed json}. Mutates store (fill-only). Returns a report dict."""
    banned = banned if banned is not None else store.terms.get("banned", [])
    rep = {"builds": {}, "added": {"tree": 0, "spell": 0, "tpl": 0}, "same": {"tree": 0, "spell": 0, "tpl": 0},
           "conflict": [], "num_mismatch": [], "gate_reject": [], "pair_reject": [], "no_text": 0,
           "per_class": {}}
    used_fa = {k: {} for k in ("tree", "spell")}
    for kind in used_fa:
        for k, v in store.names[kind].items():
            used_fa[kind].setdefault(v, set()).add(k)

    def put_name(kind, en, fa, where):
        if not en or not fa:
            return
        k = name_key(en)
        fa = fa.strip()
        have = store.names[kind].get(k)
        if have is not None:
            if have == fa:
                rep["same"][kind] += 1
            else:
                rep["conflict"].append("%s %s: table %s / site %s (%s)" % (kind, en, have, fa, where))
            return
        if not _name_ok(fa, banned):
            rep["gate_reject"].append("%s %s: %s (%s)" % (kind, en, fa, where))
            return
        others = used_fa[kind].get(fa, set()) - {k}
        if others:   # the name_pairs ratchet: a second English for one Persian needs a human look
            rep["pair_reject"].append("%s %s = %s, already %s (%s)" % (kind, en, fa, ", ".join(sorted(others)), where))
            return
        store.names[kind][k] = fa
        used_fa[kind].setdefault(fa, set()).add(k)
        rep["added"][kind] += 1
        pc[kind] += 1

    def put_tpl(en, fa, where):
        if not en or not fa:
            rep["no_text"] += 1
            return
        key, nums = num_key(en)
        if len(key) < 6:
            return
        fa2 = _fa_slots(fa.strip(), nums)
        if fa2 is None:
            rep["num_mismatch"].append({"w": where, "en": en, "fa": fa})
            return
        swaps = {}
        fa2 = shorten(fa2, store.names, swaps, {})
        have = store.tpl.get(key)
        if have is not None:
            if have == fa2:
                rep["same"]["tpl"] += 1
            else:
                rep["conflict"].append("tpl %s: kept the table row (%s)" % (key[:70], where))
            return
        if not _row_ok(key, fa2, banned):
            rep["gate_reject"].append("tpl %s (%s)" % (key[:70], where))
            return
        store.tpl[key] = fa2
        rep["added"]["tpl"] += 1
        pc["tpl"] += 1

    for cls in CLASSES:
        d = classes.get(cls)
        if d is None:
            continue
        pc = {"tree": 0, "spell": 0, "tpl": 0}
        rep["builds"][cls] = d.get("build", "?")
        for tab in d.get("tabs", []):
            put_name("tree", tab.get("n"), tab.get("fa"), cls)
        for sp in d.get("spells", []):
            w = "%s/%s" % (cls, sp.get("n"))
            put_name("spell", sp.get("n"), sp.get("fa"), w)
            put_tpl(sp.get("d"), sp.get("dFa"), w)
            for en, fa in zip(sp.get("reqs") or [], sp.get("reqsFa") or []):
                put_tpl(en, fa, w + " (req)")
        for tree in d.get("trees", []):
            put_name("tree", tree.get("n"), tree.get("fa"), cls)
            for tier in tree.get("tiers", []):
                for node in tier:
                    w = "%s/%s (talent)" % (cls, node.get("n"))
                    put_name("spell", node.get("n"), node.get("fa"), w)
                    put_tpl(node.get("d"), node.get("dFa"), w)
        rep["per_class"][cls] = pc
    return rep
