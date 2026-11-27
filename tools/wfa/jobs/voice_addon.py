"""Data for the in-game voice test addon, for any dubbed groups (generic NPC voices and named ones).

args: groups (studio group names that have recordings), cmangos (url of the CMaNGOS sql.gz)
Runs the studio's own loader to list the lines of those groups, then voice_map2 (client tables + CMaNGOS) to find
which voice sets, model files and creatures belong to them. Writes ci/work/voice/addon_data.txt:
  G|group|race|sex|guard|sets          one per group (sets = game voice sets that map to the group)
  L|group|line name|file id|category   every line of the group
  S|group|file ids                     every original game sound of the group's sets (muted in the addon)
  M|model file id|group,group          groups whose voice a model file may use
  C|group|entry ranges                 creatures that use only this group's voice (single model)
  X|entry|model:group/model:group      creatures with several models
"""
import importlib.util
import json
import pathlib
import shutil
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[3]
HERE = pathlib.Path(__file__).parent


def _ranges(nums):
    nums = sorted(set(nums))
    out, i = [], 0
    while i < len(nums):
        j = i
        while j + 1 < len(nums) and nums[j + 1] == nums[j] + 1:
            j += 1
        out.append(str(nums[i]) if i == j else "%d-%d" % (nums[i], nums[j]))
        i = j + 1
    return ",".join(out)


def _remap(g, ent, alias_of, vendors, fall_of):
    """a vendor creature of a target group speaks with the vendor group instead; a fallback group (no dub of its own) always does"""
    if g in fall_of:
        return fall_of[g]
    if g in alias_of and ent in vendors:
        return alias_of[g]
    return g


def run(args, rep):
    groups = list(args.get("groups") or [])
    node = shutil.which("node")
    if not node or not groups:
        rep.fail("need node and at least one group")
        return []
    r = subprocess.run([node, str(HERE / "studio_dump.js"), str(ROOT / "tools/dub-studio/voice_db.js"),
                        str(ROOT / "tools/dub-studio/loader.js"), json.dumps(groups)], capture_output=True, text=True)
    if r.returncode:
        rep.fail("node failed: %s" % (r.stderr or r.stdout)[-600:])
        return []
    d = json.loads(r.stdout)
    rep.h("Studio groups")
    found = [g[0] for g in d["groups"]]
    miss = [g for g in groups if g not in found]
    rep.ok("%d of %d groups found, %d lines" % (len(found), len(groups), len(d["lines"])))
    if miss:
        rep.add("not in the studio database: %s" % ", ".join(miss))
    if len(set(found)) != len(found):
        rep.add("WARNING: duplicate group names: %s" % sorted(x for x in set(found) if found.count(x) > 1))
    fids = sorted({x[0] for x in d["lines"]})
    spec = importlib.util.spec_from_file_location("voice_map2_x", HERE / "voice_map2.py")
    vm2 = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(vm2)
    paths = vm2.run({"files": fids, "cmangos": args.get("cmangos", ""), "build": args.get("build", "")}, rep)
    if not paths:
        return []
    m = json.load(open(ROOT / "ci/work/voice/addon_map.json", encoding="utf-8"))
    line_group = {x[0]: x[1] for x in d["lines"]}
    set_group = {}
    for s, fs in m["sets"].items():
        cnt = {}
        for f in fs:
            g = line_group.get(f)
            if g:
                cnt[g] = cnt.get(g, 0) + 1
        if cnt:
            set_group[s] = sorted(cnt.items(), key=lambda kv: (-kv[1], kv[0]))[0][0]
    rep.h("Voice sets per group")
    per = {}
    for s, g in set_group.items():
        per.setdefault(g, []).append(int(s))
    rep.table([[g, ",".join(str(x) for x in sorted(v))] for g, v in sorted(per.items())], ["group", "game voice sets"])
    alias = dict(args.get("vendor_alias") or {})
    vendors = set(int(x) for x in m.get("vendors", []))
    alias_of = {t: a for a, ts in alias.items() for t in ts}
    fall_of = {t: a for a, ts in (args.get("fallback_alias") or {}).items() for t in ts}
    if alias:
        cnt = {}
        for ent, (_nm, prs) in m["npc"].items():
            for p in prs:
                if set_group.get(str(p[0])) in alias_of or set_group.get(str(p[0])) in fall_of:
                    c = cnt.setdefault(p[0], [0, 0])
                    c[0 if int(ent) in vendors else 1] += 1
        rep.h("Vendor voices")
        rep.table([(s, set_group.get(str(s)), c[0], c[1]) for s, c in sorted(cnt.items())], ["voice set", "group", "vendors", "other creatures"])
        for s, c in cnt.items():
            g = set_group[str(s)]
            if g in fall_of:
                per.setdefault(fall_of[g], []).append(int(s))
            elif c[0] and not c[1]:
                per.setdefault(alias_of[g], []).append(int(s))
        rep.ok("%d vendor creatures in the CMaNGOS data" % len(vendors))
    out = []
    for g in d["groups"]:
        name = g[0]
        out.append("G|%s|%s|%s|%d|%s" % (name, (g[3] or "").lower(), g[2] or "", 1 if "guard" in name.lower() else 0,
                                          ",".join(str(x) for x in sorted(per.get(name, [])))))
    for fid, g, cat, nm in sorted(d["lines"], key=lambda x: (x[1], x[3])):
        out.append("L|%s|%s|%d|%s" % (g, nm.lower(), fid, cat))
    for name in sorted(per):
        mute = sorted({f for s in per[name] for f in m["sets"][str(s)]})
        out.append("S|%s|%s" % (name, _ranges(mute)))
    for mod, ss in sorted(m["models"].items(), key=lambda kv: int(kv[0])):
        gs = sorted({set_group[str(s)] for s in ss if str(s) in set_group})
        if gs:
            out.append("M|%s|%s" % (mod, ",".join(gs)))
    single, multi = {}, []
    for ent, (nm, prs) in m["npc"].items():
        pp = [(_remap(set_group.get(str(p[0])), int(ent), alias_of, vendors, fall_of), p[1]) for p in prs]
        if len(pp) == 1 and pp[0][0]:
            single.setdefault(pp[0][0], []).append(int(ent))
        elif any(g for g, _ in pp):
            multi.append((int(ent), pp))
    for g in sorted(single):
        out.append("C|%s|%s" % (g, _ranges(single[g])))
    for ent, pp in sorted(multi):
        out.append("X|%d|%s" % (ent, "/".join("%d:%s" % (mod or 0, g or "-") for g, mod in pp)))
    rep.ok("creatures: %d single-voice, %d with several models" % (sum(len(v) for v in single.values()), len(multi)))
    with open("ci/work/voice/addon_data.txt", "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(out) + "\n")
    return paths + ["ci/work/voice/addon_data.txt"]
