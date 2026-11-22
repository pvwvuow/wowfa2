"""Marker resolution. In data/ a name marker may be short {{sp:Frostbolt}}: its Persian comes from
data/names/spell at build time, so renaming a spell is ONE edit. A full marker {{sp:EN|FA}} is an
explicit exception (kept as written)."""
from .core import MARKER_KIND, MARKER_RE, name_key

# kinds whose table is authoritative (a marker's own Persian never wins over the table)
AUTHORITATIVE = ("spell", "zone", "class")


def resolve(text, names):
    def sub(m):
        kind, en, fa = m.group(1), m.group(2), m.group(3)
        if fa is not None or kind not in MARKER_KIND:
            return m.group(0)
        v = names.get(MARKER_KIND[kind], {}).get(name_key(en))
        return "{{%s:%s|%s}}" % (kind, en, v) if v else m.group(0)
    return MARKER_RE.sub(sub, text)


def canon(text, names):
    """For comparisons: every authoritative-kind marker shows the table's Persian."""
    def sub(m):
        kind, en = m.group(1), m.group(2)
        t = MARKER_KIND.get(kind)
        if t in AUTHORITATIVE:
            v = names.get(t, {}).get(name_key(en))
            if v:
                return "{{%s:%s|%s}}" % (kind, en, v)
        return m.group(0)
    return MARKER_RE.sub(sub, text)


def shorten(text, names, swaps, fills):
    """Migration: full marker -> short marker when the table will give the same (or, for
    authoritative kinds, the table's) Persian. Records every Persian change in `swaps`."""
    def sub(m):
        kind, en, fa = m.group(1), m.group(2), m.group(3)
        t = MARKER_KIND.get(kind)
        if fa is None or t is None:
            return m.group(0)
        key = name_key(en)
        v = names.get(t, {}).get(key)
        if v is None and t in AUTHORITATIVE and fills.get((t, key)) == fa:
            v = fa
        if v is None:
            return m.group(0)
        if v == fa:
            return "{{%s:%s}}" % (kind, en)
        if t in AUTHORITATIVE:
            swaps[(t, key, fa, v)] = swaps.get((t, key, fa, v), 0) + 1
            return "{{%s:%s}}" % (kind, en)
        return m.group(0)
    return MARKER_RE.sub(sub, text)
