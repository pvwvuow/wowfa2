"""Report only: read the GlobalStrings table (the game's own English UI texts) from the newest wow-raw archive.
args: tag (optional wow-raw release tag, default = newest), mode: "prefix" (counts of key prefixes)
      or "list" (default), keys: [regex on the key], skip: [regex on the key to leave out],
      minlen / maxlen: value length window, limit: rows (default 300), covered: true = leave out the
      English texts that Locale_UI.lua already translates, table: another table name (default GlobalStrings)"""
import csv
import io
import os
import re
import subprocess
import tempfile
import zipfile

REPO = "pvwvuow/wow-raw"


def _gh(env, *a):
    return subprocess.run(["gh"] + list(a), env=env, text=True, capture_output=True)


def _covered():
    here = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(here, "..", "..", "..", "addon", "WoWFA", "Locale_UI.lua")
    got = set()
    try:
        with open(path, encoding="utf-8") as fh:
            for m in re.finditer(r'\{\s*"((?:[^"\\]|\\.)*)"\s*,\s*"', fh.read()):
                got.add(m.group(1))
    except OSError:
        pass
    return got


def run(args, rep):
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    table = args.get("table", "GlobalStrings")
    tag = args.get("tag")
    if not tag:
        r = _gh(env, "release", "list", "--repo", REPO, "-L", "1", "--json", "tagName", "--jq", ".[0].tagName")
        tag = (r.stdout or "").strip()
    rep.h("%s from %s" % (table, tag))
    tmp = tempfile.mkdtemp()
    d = _gh(env, "release", "download", tag, "--repo", REPO, "-p", "*.zip", "-D", tmp)
    if d.returncode:
        rep.fail("download: %s" % (d.stderr or "").strip()[:300])
        return []
    zs = [f for f in os.listdir(tmp) if f.endswith(".zip")]
    if not zs:
        rep.fail("no zip in %s" % tag)
        return []
    with zipfile.ZipFile(os.path.join(tmp, zs[0])) as z:
        name = table + ".csv"
        if name not in z.namelist():
            rep.fail("%s not in the archive" % name)
            return []
        body = z.read(name).decode("utf-8-sig", "replace")
    rd = csv.DictReader(io.StringIO(body))
    cols = rd.fieldnames or []
    rep.add("columns: %s" % ", ".join(cols))
    kc = next((c for c in cols if c.lower() in ("basetag", "key", "name")), cols[1] if len(cols) > 1 else cols[0])
    vc = next((c for c in cols if c.lower().startswith("tagtext") or c.endswith("_lang")), cols[-1])
    rows = [(r.get(kc, ""), r.get(vc, "")) for r in rd]
    rep.ok("%d rows, key column %s, text column %s" % (len(rows), kc, vc))
    if args.get("mode") == "prefix":
        cnt = {}
        for k, v in rows:
            p = "_".join(k.split("_")[:int(args.get("depth", 1))])
            cnt[p] = cnt.get(p, 0) + 1
        top = sorted(cnt.items(), key=lambda kv: -kv[1])[:int(args.get("limit", 150))]
        rep.table([(p, n) for p, n in top], ["prefix", "rows"])
        return []
    keys = [re.compile(x) for x in args.get("keys") or ["."]]
    skip = [re.compile(x) for x in args.get("skip") or []]
    lo, hi = int(args.get("minlen", 1)), int(args.get("maxlen", 200))
    cov = _covered() if args.get("covered") else set()
    out = []
    for k, v in rows:
        if not any(p.search(k) for p in keys) or any(p.search(k) for p in skip):
            continue
        if not (lo <= len(v) <= hi) or v in cov:
            continue
        out.append((k, v.replace("\n", "\\n")))
    lim = int(args.get("limit", 300))
    rep.ok("%d matching rows, showing %d" % (len(out), min(len(out), lim)))
    rep.add("```\n" + "\n".join("%s = %s" % (k, v) for k, v in out[:lim]) + "\n```")
    return []
