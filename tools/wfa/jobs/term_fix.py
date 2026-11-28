"""One Persian word per English game term (the owner 28 Nov: stun was 'فلج' here and 'مبهوت' there).
Dry run by default: the report lists, per rule, how many rows change and a few before -> after.
args: rules, apply (false), samples (3)
rule: {id, tables: ["tpl", "n:it", "n:itn", "n:set", "n:spell", "n" (every names kind), "ui", "quests"],
       en: regex on the English key, en_not: regex, last: [last English words], finds: [[find, repl], ...],
       lit: finds are plain strings, ci: ignore case}
rule with "lua": {id, lua: [file names under addon/WoWFA, "*" = every Lua outside Data], finds, lit}
The finds of one rule run in order on the same text."""
import pathlib
import re

from wfa.store import Store, QUEST_FIELDS

ROOT = pathlib.Path(__file__).resolve().parents[3]


def compile_finds(r):
    out = []
    for f, t in r["finds"]:
        flags = re.I if r.get("ci") else 0
        out.append((re.compile(re.escape(f) if r.get("lit") else f, flags), t))
    return out


def run(args, rep):
    store = Store.load()
    apply = bool(args.get("apply"))
    ns = int(args.get("samples", 3))
    grand = 0
    lua_changed = []
    for r in args.get("rules") or []:
        finds = compile_finds(r)

        def fix(v):
            for rx, t in finds:
                v = rx.sub(t, v)
            return v

        changed, samples = 0, []
        if r.get("lua"):
            base = ROOT / "addon" / "WoWFA"
            files = sorted(p for p in base.rglob("*.lua") if not str(p.relative_to(base)).startswith("Data"))
            want = r["lua"]
            for p in files:
                rel = str(p.relative_to(base))
                if "*" not in want and rel not in want:
                    continue
                txt = p.read_text(encoding="utf-8")
                new = fix(txt)
                if new != txt:
                    n = sum(1 for a, b in zip(txt.splitlines(), new.splitlines()) if a != b)
                    changed += n
                    for a, b in zip(txt.splitlines(), new.splitlines()):
                        if a != b and len(samples) < ns:
                            samples.append("%s: %s  =>  %s" % (rel, a.strip()[:90], b.strip()[:90]))
                    if apply:
                        p.write_text(new, encoding="utf-8")
                        lua_changed.append("addon/WoWFA/" + rel)
        else:
            en = re.compile(r["en"], re.I) if r.get("en") else None
            en_not = re.compile(r["en_not"], re.I) if r.get("en_not") else None
            last = r.get("last")

            def ok(key):
                k = key.lower()
                if en and not en.search(k):
                    return False
                if en_not and en_not.search(k):
                    return False
                if last and not any(k == w or k.endswith(" " + w) for w in last):
                    return False
                return True

            for tname in r.get("tables") or []:
                if tname == "quests":
                    for qid, rec in store.quests.items():
                        for f in QUEST_FIELDS[1:]:
                            v = rec.get(f)
                            if v:
                                nv = fix(v)
                                if nv != v:
                                    changed += 1
                                    if len(samples) < ns:
                                        samples.append("q%d.%s: %s  =>  %s" % (qid, f, v[:60], nv[:60]))
                                    if apply:
                                        rec[f] = nv
                        os_ = rec.get("o") or []
                        for i, line in enumerate(os_):
                            nl = fix(line)
                            if nl != line:
                                changed += 1
                                if apply:
                                    os_[i] = nl
                    continue
                if tname == "tpl":
                    tabs = [("tpl", store.tpl)]
                elif tname == "ui":
                    tabs = [("ui", store.ui)]
                elif tname == "n":
                    tabs = [("n:" + k, t) for k, t in store.names.items()]
                else:
                    tabs = [(tname, store.names.get(tname[2:]) or {})]
                for label, tab in tabs:
                    for k in list(tab):
                        if not ok(str(k)):
                            continue
                        v = tab[k]
                        nv = fix(v)
                        if nv != v:
                            changed += 1
                            if len(samples) < ns:
                                samples.append("[%s] %s: %s  =>  %s" % (label, str(k)[:40], v[:55], nv[:55]))
                            if apply:
                                tab[k] = nv
        grand += changed
        rep.h("%s: %d changed" % (r.get("id"), changed))
        for s in samples:
            rep.add("  " + s)
    rep.add("TOTAL %d %s" % (grand, "applied" if apply else "(dry run, nothing written)"))
    if apply:
        store.save()
        return ["data"] + sorted(set(lua_changed))
    return []
