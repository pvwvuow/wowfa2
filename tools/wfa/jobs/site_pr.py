"""Open a DRAFT pull request in a site repo with files that come as ONE zip from a short-lived
HTTPS relay URL (sha256 checked), plus optional exact-text replacements. Text files only.
args: url, sha256, repo ("pvwvuow/wow"), branch, title, body, replace [{path, old, new, count}]
Everything else is remote_pr (draft only, never .github/, never merges)."""
import hashlib
import importlib.util
import io
import os
import re
import urllib.request
import zipfile

OK_PATH = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._/-]{0,120}\.(html|css|js|json|py|yml|md|txt)$")


def run(args, rep):
    url = str(args.get("url") or "")
    want = str(args.get("sha256") or "").lower()
    rep.h("download")
    if not url.startswith("https://") or len(want) != 64:
        rep.fail("url must be https and sha256 given")
        return []
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "wowfa2-ci"}), timeout=90) as r:
            blob = r.read(5_000_001)
    except Exception as e:  # noqa: BLE001
        rep.fail("download failed: %s" % type(e).__name__)
        return []
    if hashlib.sha256(blob).hexdigest() != want or len(blob) > 5_000_000:
        rep.fail("sha256 wrong")
        return []
    files = {}
    with zipfile.ZipFile(io.BytesIO(blob)) as zf:
        for n in zf.namelist():
            if n.endswith("/"):
                continue
            if not OK_PATH.match(n) or ".." in n or n.startswith(".github/"):
                rep.fail("refused file name %s" % n)
                return []
            files[n] = zf.read(n).decode("utf-8")
    rep.ok("%d files in the zip" % len(files))
    here = os.path.dirname(os.path.abspath(__file__))
    spec = importlib.util.spec_from_file_location("wfa_job_remote_pr", os.path.join(here, "remote_pr.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    sub = dict(args)
    sub["files"] = files
    return mod.run(sub, rep)
