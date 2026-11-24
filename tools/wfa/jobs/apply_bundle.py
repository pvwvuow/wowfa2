"""Download a reviewed bundle (a short-lived HTTPS relay URL), check its sha256 and apply it.

bundle = {"npc": {key: new}, "zone": {key: new}, "tpl": {key: [old, new]}, "spell": {key: new}}
  npc / zone / spell: same as apply_npc_fixes (the new Persian also follows into full markers {{fam:EN|OLD}}
  whose EN is that very key; no plain-text rewriting).
  tpl: a row is changed only when the current value still equals `old` (anything else is listed, not touched).

args: url (https), sha256, max_bytes (4000000),
      skip_contains {table: [text, ...]}: rows whose key contains one of the texts are dropped before applying
"""
import hashlib
import importlib.util
import json
import pathlib
import tempfile
import urllib.request

from wfa.store import Store

_HERE = pathlib.Path(__file__).resolve().parent


def _load(name):
    spec = importlib.util.spec_from_file_location("wfa_job_" + name, _HERE / (name + ".py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run(args, rep):
    url = str(args.get("url") or "")
    want = str(args.get("sha256") or "").lower()
    limit = int(args.get("max_bytes", 4000000))
    rep.h("Bundle")
    if not url.startswith("https://") or len(want) != 64:
        rep.fail("url must be https and sha256 must be given")
        return []
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "wowfa2-ci"})
        with urllib.request.urlopen(req, timeout=90) as r:
            body = r.read(limit + 1)
    except Exception as e:  # noqa: BLE001 - the report must say why
        rep.fail("download failed: %s" % type(e).__name__)
        return []
    got = hashlib.sha256(body).hexdigest()
    if len(body) > limit or got != want:
        rep.fail("size or sha256 wrong (got %s, %d bytes)" % (got[:12], len(body)))
        return []
    try:
        bundle = json.loads(body.decode("utf-8"))
    except ValueError:
        rep.fail("the bundle is not valid JSON")
        return []
    rep.ok("bundle read: %d bytes, sha256 %s, tables %s" % (
        len(body), got[:12], ", ".join("%s %d" % (k, len(v)) for k, v in sorted(bundle.items()))))
    for table, texts in sorted((args.get("skip_contains") or {}).items()):
        rows = bundle.get(table) or {}
        drop = [k for k in rows if any(t in k for t in texts)]
        for k in drop:
            del rows[k]
        rep.ok("%s: %d rows dropped by skip_contains %s" % (table, len(drop), texts))
        if drop:
            rep.add("dropped: " + "; ".join(sorted(drop)[:60]))
    mod = _load("apply_npc_fixes")
    tmp = pathlib.Path(tempfile.mkdtemp())
    for table in ("npc", "zone", "spell"):
        rows = bundle.get(table) or {}
        if not rows:
            continue
        f = tmp / (table + ".json")
        f.write_text(json.dumps(rows, ensure_ascii=False), encoding="utf-8")
        rep.h("names." + table)
        mod.run({"files": [str(f)], "table": table, "min_letters": 99, "tpl": True}, rep)
    tpl = bundle.get("tpl") or {}
    if tpl:
        store = Store.load()
        done, skipped = 0, []
        for k, pair in tpl.items():
            old, new = pair[0], pair[1]
            if store.tpl.get(k) != old:
                skipped.append(k)
                continue
            store.tpl[k] = new
            done += 1
        store.save()
        rep.h("tpl")
        rep.ok("%d templates set, %d skipped (current value is not the one reviewed)" % (done, len(skipped)))
        if skipped:
            rep.add("skipped: " + "; ".join(x[:60] for x in skipped[:30]))
    return ["data"]
