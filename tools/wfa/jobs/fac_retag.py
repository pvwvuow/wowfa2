"""Factions / groups get their own marker family "fac" (owner 25 Nov: "yes, a separate colour").
{{npc:Forsaken|fa}} -> {{fac:Forsaken|fa}} for every name in FACTIONS (or args names), in tpl and quests.
Only markers WITH Persian move (fac has no name table). args: names [extra], apply. Returns data when applied."""
import collections
import re

from wfa.store import Store

MK = re.compile(r"\{\{(npc|tm):([^{}|]*)\|([^{}]+)\}\}")
FACTIONS = {
    "forsaken", "the forsaken", "scarlet", "scarlet crusade", "the scarlet crusade", "syndicate", "the syndicate",
    "twilight hammer", "twilight's hammer", "the twilight's hammer", "deadwood", "earthen ring", "the earthen ring",
    "darkspear", "darkspear trolls", "burning legion", "the burning legion", "shadow council", "the shadow council",
    "barov family", "arathor allied forces", "hammer of twilight", "arathor coalition", "zandalar tribe",
    "zandala tribe", "knights of the silver hand", "silver hand", "the silver hand", "argent dawn", "the argent dawn",
    "cenarion circle", "the cenarion circle", "defias brotherhood", "the defias brotherhood", "defias", "kirin tor",
    "the kirin tor", "explorers' league", "timbermaw hold", "thorium brotherhood", "bloodsail buccaneers",
    "steamwheedle cartel", "hydraxian waterlords", "brood of nozdormu", "silverwing sentinels", "warsong outriders",
    "frostwolf clan", "stormpike guard", "league of arathor", "the defilers", "defilers", "shen'dralar",
    "wintersaber trainers", "ravenholdt", "gnomeregan exiles", "venture company", "venture co.", "the venture co.",
    "scourge", "the scourge", "cult of the damned", "the cult of the damned", "burning blade", "the burning blade",
    "bloodsail", "dark iron dwarves", "dark iron", "blackrock clan", "blackrock orcs", "dragonmaw clan", "smolderthorn",
    "theramore", "stormwind guard", "ironforge guard", "kor'kron", "nozdom's heir",
}


def run(args, rep):
    store = Store.load()
    names = FACTIONS | {n.lower() for n in args.get("names") or []}
    apply = bool(args.get("apply"))
    hits = collections.Counter()

    def fix(text):
        def one(m):
            fam, en, fa = m.group(1), m.group(2), m.group(3)
            if fam == "npc" and en.strip().lower() in names:
                hits[en.strip()] += 1
                return "{{fac:%s|%s}}" % (en, fa)
            return m.group(0)
        return MK.sub(one, text)

    changed = 0
    for k in list(store.tpl):
        v = store.tpl[k]
        if isinstance(v, str):
            new = fix(v)
            if new != v:
                changed += 1
                if apply:
                    store.tpl[k] = new
    for rec in store.quests.values():
        for f, v in list(rec.items()):
            if isinstance(v, str):
                new = fix(v)
            elif isinstance(v, list):
                new = [fix(x) if isinstance(x, str) else x for x in v]
            else:
                continue
            if new != v:
                changed += 1
                if apply:
                    rec[f] = new
    rep.h("factions retagged npc -> fac")
    rep.table(sorted(hits.items(), key=lambda x: -x[1]), ["name", "n"])
    rep.ok("%d strings, %d markers" % (changed, sum(hits.values())))
    if not apply:
        rep.ok("report only")
        return []
    store.save()
    return ["data"]
