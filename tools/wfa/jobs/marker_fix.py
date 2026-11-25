"""Fix wrong markers by rule (owner 25 Nov: "no wrong colours, no generic words as terms").
args: rules [{fam, key, fa?("*" any, "" none), to: "plain" | "<fam>:<Key>", text?, newfa?, where?("tpl"|"q"|"all"), ctx?}],
      plain_tm [tm keys that are ordinary words -> plain Persian], strip_the (true: {{fam:the X}} -> {{fam:X}} when X is in
      its table and the marker has no Persian), apply.
ctx = substring of the tpl key / quest id the rule is limited to. Returns data when applied."""
import collections
import re

from wfa.store import Store

MK = re.compile(r"\{\{(\w+):([^{}|]*)(?:\|([^{}]*))?\}\}")
TABLE = {"sp": ["spell"], "cls": ["class", "tree"], "zn": ["zone"], "npc": ["npc", "boss"]}


def run(args, rep):
    store = Store.load()
    low = {kind: {k.lower() for k in t} for kind, t in store.names.items()}
    rules = collections.defaultdict(list)
    for r in args.get("rules") or []:
        rules[(r["fam"], r["key"].lower())].append(r)
    plain_tm = {k.lower() for k in args.get("plain_tm") or []}
    strip_the = bool(args.get("strip_the"))
    apply = bool(args.get("apply"))
    hits = collections.Counter()
    samples = collections.defaultdict(list)
    left = collections.Counter()

    def fix(src, key, text):
        def one(m):
            fam, en, fa = m.group(1), m.group(2), m.group(3)
            k = (fam, en.strip().lower())
            for r in rules.get(k, ()):
                want = r.get("fa", "*")
                if want != "*" and want != (fa or ""):
                    continue
                w = r.get("where", "all")
                if w != "all" and w != src:
                    continue
                if r.get("ctx") and r["ctx"].lower() not in key.lower():
                    continue
                to = r["to"]
                if to == "plain":
                    out = r.get("text") if r.get("text") is not None else (fa or en)
                else:
                    nf, nk = to.split(":", 1)
                    nfa = r.get("newfa") or fa
                    out = "{{%s:%s|%s}}" % (nf, nk, nfa) if nfa else "{{%s:%s}}" % (nf, nk)
                tag = "%s:%s|%s -> %s" % (fam, en, fa or "", to)
                hits[tag] += 1
                if len(samples[tag]) < 2:
                    samples[tag].append("%s %s" % (src, key[:50]))
                return out
            if fam == "tm" and k[1] in plain_tm and fa:
                hits["tm:%s -> plain" % k[1]] += 1
                return fa
            if strip_the and not fa and fam in TABLE and k[1].startswith("the "):
                rest = en.strip()[4:]
                if any(rest.lower() in low[t] for t in TABLE[fam]):
                    hits["%s:the X -> %s:X" % (fam, fam)] += 1
                    return "{{%s:%s}}" % (fam, rest)
            if fam in TABLE and not fa and not any(k[1] in low[t] for t in TABLE[fam]):
                left["%s:%s" % (fam, en)] += 1
            return m.group(0)
        return MK.sub(one, text)

    changed = 0
    for k in list(store.tpl):
        v = store.tpl[k]
        new = fix("tpl", k, v)
        if new != v:
            changed += 1
            if apply:
                store.tpl[k] = new
    for qid, rec in store.quests.items():
        for f, v in list(rec.items()):
            if isinstance(v, str):
                new = fix("q", str(qid), v)
                if new != v:
                    changed += 1
                    if apply:
                        rec[f] = new
            elif isinstance(v, list):
                nl = [fix("q", str(qid), x) if isinstance(x, str) else x for x in v]
                if nl != v:
                    changed += 1
                    if apply:
                        rec[f] = nl
    rep.h("fixes")
    rep.table([(t, n, " / ".join(samples[t])) for t, n in sorted(hits.items(), key=lambda x: -x[1])], ["rule", "n", "where"])
    rep.ok("%d strings changed, %d marker fixes" % (changed, sum(hits.values())))
    rep.h("still not in their table (no Persian)")
    rep.add(" ".join("%s(%d)" % x for x in left.most_common(200)) or "none")
    if not apply:
        rep.ok("report only")
        return []
    store.save()
    return ["data"]
