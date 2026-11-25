"""Put files (screenshots) into the site repos straight on main via the contents API (BOT_TOKEN).
The files come as ONE zip (or tar) from a short-lived HTTPS relay URL; its sha256 must match. Only
plain file names with the allowed extensions are taken. Nothing in this repo changes.
args: url, sha256, dir ("assets/img/addon"), repos (["wowfarsiir", "wow"]),
      fallback ("wowfarsi-addon": used with dir "screenshots" when a site repo refuses the token)"""
import base64
import hashlib
import io
import json
import os
import re
import tarfile
import urllib.error
import urllib.request
import zipfile

OWNER = "pvwvuow"
OK_NAME = re.compile(r"^[a-z0-9][a-z0-9._-]{0,80}\.(webp|png|jpg|jpeg)$")


def api(method, path, body=None):
    req = urllib.request.Request("https://api.github.com" + path, method=method,
                                 data=json.dumps(body).encode() if body is not None else None,
                                 headers={"Authorization": "Bearer " + os.environ.get("BOT_TOKEN", ""),
                                          "Accept": "application/vnd.github+json", "User-Agent": "wowfa2-ci"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, json.loads(r.read().decode() or "{}")
    except urllib.error.HTTPError as e:
        return e.code, {}


def put(repo, path, data, msg):
    st, cur = api("GET", "/repos/%s/%s/contents/%s?ref=main" % (OWNER, repo, path))
    body = {"message": msg, "content": base64.b64encode(data).decode(), "branch": "main"}
    if st == 200 and isinstance(cur, dict) and cur.get("sha"):
        body["sha"] = cur["sha"]
    st, res = api("PUT", "/repos/%s/%s/contents/%s" % (OWNER, repo, path), body)
    return st, ((res.get("content") or {}).get("sha") if isinstance(res, dict) else None)


def members(blob):
    out = []
    if blob[:2] == b"PK":
        with zipfile.ZipFile(io.BytesIO(blob)) as zf:
            for n in zf.namelist():
                out.append((os.path.basename(n), zf.read(n)))
    else:
        with tarfile.open(fileobj=io.BytesIO(blob)) as tf:
            for m in tf.getmembers():
                if m.isfile():
                    out.append((os.path.basename(m.name), tf.extractfile(m).read()))
    return [(n, d) for n, d in out if OK_NAME.match(n)]


def run(args, rep):
    url = str(args.get("url") or "")
    want = str(args.get("sha256") or "").lower()
    rep.h("download")
    if not url.startswith("https://") or len(want) != 64:
        rep.fail("url must be https and sha256 given")
        return []
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "wowfa2-ci"}), timeout=90) as r:
            blob = r.read(20_000_001)
    except Exception as e:  # noqa: BLE001
        rep.fail("download failed: %s" % type(e).__name__)
        return []
    got = hashlib.sha256(blob).hexdigest()
    if got != want or len(blob) > 20_000_000:
        rep.fail("sha256 wrong (%s)" % got[:12])
        return []
    files = members(blob)
    rep.ok("%d files in the archive" % len(files))
    d = str(args.get("dir") or "assets/img/addon").strip("/")
    for repo in args.get("repos") or ["wowfarsiir", "wow"]:
        rep.h(repo)
        bad = 0
        for name, data in files:
            st, sha = put(repo, "%s/%s" % (d, name), data, "site: addon screenshot %s" % name)
            (rep.ok if st in (200, 201) else rep.fail)("%s/%s: HTTP %s %s (%d bytes)" % (d, name, st, sha or "", len(data)))
            bad += st not in (200, 201)
        if bad and args.get("fallback"):
            fb = args["fallback"]
            rep.h("fallback " + fb)
            for name, data in files:
                st, sha = put(fb, "screenshots/" + name, data, "screenshots: %s" % name)
                (rep.ok if st in (200, 201) else rep.fail)("screenshots/%s: HTTP %s %s" % (name, st, sha or ""))
            break
    return []
