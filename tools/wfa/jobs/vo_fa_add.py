"""Adds hand translations of spoken lines to ci/data/vo_fa.json ({english: persian}, the dub studio's source of Persian).
args: map {english: persian} ("~" = ZWNJ) or url (a JSON file of that map), sha (sha256 of the map as sent, to prove nothing was lost on the way),
force (replace a Persian that is already there; default false). voice_text merges them into voice_db.js."""
import hashlib
import json
import re

FA = "ci/data/vo_fa.json"


def key(s):
    return re.sub(r"[^a-z0-9'$]+", " ", str(s or "").lower()).strip()


def run(args, rep):
    m = args.get("map") or {}
    got = hashlib.sha256(json.dumps(m, sort_keys=True, ensure_ascii=True).encode()).hexdigest()
    if args.get("url"):
        # a big map comes as a file (sha256 of its bytes), so nothing is retyped on the way
        import importlib.util
        import pathlib
        p = pathlib.Path(__file__).with_name("cmangos_cov.py")
        spec = importlib.util.spec_from_file_location("cmangos_cov_fa", p)
        cov = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cov)
        try:
            body = cov._get(str(args["url"]))
        except Exception as e:  # noqa: BLE001
            rep.fail("download failed: %s" % type(e).__name__)
            return []
        got = hashlib.sha256(body).hexdigest()
        m = json.loads(body.decode("utf-8"))
    if args.get("sha") and got != args["sha"]:
        rep.fail("the map changed on the way (sha %s, expected %s)" % (got[:12], args["sha"][:12]))
        return []
    rep.ok("%d entries, sha %s" % (len(m), got[:12]))
    try:
        cur = json.load(open(FA, encoding="utf-8"))
    except (OSError, ValueError):
        cur = {}
    have = {key(k): k for k in cur}
    add = rep_ = same = 0
    for en, fa in m.items():
        fa = re.sub(r"\s+", " ", str(fa).replace("~", "\u200c")).strip()
        if not fa or re.search(r"[A-Za-z]{3}", fa.replace("NPC", "")):
            rep.add("skipped (no Persian): %s" % en)
            continue
        k = have.get(key(en))
        if k is None:
            cur[en] = fa
            have[key(en)] = en
            add += 1
        elif cur[k] == fa:
            same += 1
        elif args.get("force"):
            cur[k] = fa
            rep_ += 1
        else:
            same += 1
    json.dump(cur, open(FA, "w", encoding="utf-8", newline="\n"), ensure_ascii=True, indent=0, sort_keys=True)
    open(FA, "a").write("\n")
    rep.ok("%s: %d added, %d replaced, %d already there; %d entries in all" % (FA, add, rep_, same, len(cur)))
    return [FA]
