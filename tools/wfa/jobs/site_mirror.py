"""Copy named files from main of one site repo to main of the public site repo (BOT_TOKEN), the
same thing the publish workflow does, for when that workflow is not running.
args: src ("pvwvuow/wow"), dst ("pvwvuow/wowfarsiir"), paths [files], message.
Only plain file paths (no .github/, no ..). Never deletes."""
import os
import shutil
import subprocess
import tempfile


def _git(cmd, cwd=None):
    p = subprocess.run(cmd, cwd=cwd, text=True, capture_output=True)
    return p.returncode, ((p.stdout or "") + (p.stderr or "")).strip()


def run(args, rep):
    src, dst = str(args.get("src", "")), str(args.get("dst", ""))
    paths = list(args.get("paths") or [])
    rep.h("Mirror %s -> %s" % (src, dst))
    if not (src.startswith("pvwvuow/") and dst.startswith("pvwvuow/")) or not paths:
        rep.fail("src/dst must be pvwvuow/* and paths given")
        return []
    for p in paths:
        if p.startswith(".github/") or ".." in p or p.startswith("/"):
            rep.fail("refused path %s" % p)
            return []
    tok = os.environ.get("BOT_TOKEN", "")
    a, b = tempfile.mkdtemp(), tempfile.mkdtemp()
    try:
        for repo, d in ((src, a), (dst, b)):
            c, o = _git(["git", "clone", "-q", "--depth", "1", "https://x-access-token:%s@github.com/%s.git" % (tok, repo), d])
            if c:
                rep.fail("clone %s failed: %s" % (repo, o.replace(tok, "***")[:300]))
                return []
        for p in paths:
            f = os.path.join(a, p)
            if not os.path.isfile(f):
                rep.fail("missing in %s: %s" % (src, p))
                return []
            t = os.path.join(b, p)
            os.makedirs(os.path.dirname(t), exist_ok=True)
            shutil.copyfile(f, t)
            rep.add("- copied %s (%d bytes)" % (p, os.path.getsize(t)))
        _git(["git", "add", "-A"], cwd=b)
        if _git(["git", "diff", "--cached", "--quiet"], cwd=b)[0] == 0:
            rep.ok("%s already has these files" % dst)
            return []
        _git(["git", "config", "user.name", "wowfarsi-bot"], cwd=b)
        _git(["git", "config", "user.email", "bot@wowfarsi.ir"], cwd=b)
        c, o = _git(["git", "commit", "-q", "-m", args.get("message") or "site sync"], cwd=b)
        if c:
            rep.fail("commit failed: %s" % o[:300])
            return []
        c, o = _git(["git", "push", "-q", "origin", "HEAD:main"], cwd=b)
        if c:
            rep.fail("push refused: %s" % o.replace(tok, "***")[:400])
            return []
        rep.ok("pushed to %s main" % dst)
    finally:
        shutil.rmtree(a, ignore_errors=True)
        shutil.rmtree(b, ignore_errors=True)
    return []
