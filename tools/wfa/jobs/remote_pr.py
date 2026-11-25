"""Open a DRAFT pull request in another repo of the owner (the owner, 25 Nov: drafts only).
args: {"repo": "pvwvuow/wowheadFA", "branch": "feat/x", "title": "...", "body": "...",
       "files": {"path": "full new content"},
       "replace": [{"path": "...", "old": "exact text", "new": "...", "count": 1}]}
Uses BOT_TOKEN. Never touches .github/workflows. Never merges. Nothing is committed here."""
import os
import subprocess
import tempfile


def _run(cmd, cwd=None, env=None):
    p = subprocess.run(cmd, cwd=cwd, env=env, text=True, capture_output=True)
    return p.returncode, (p.stdout or "").strip(), (p.stderr or "").strip()


def run(args, rep):
    repo = str(args.get("repo", "")).strip()
    branch = str(args.get("branch", "")).strip()
    rep.h("Draft PR in %s" % repo)
    if not repo.startswith("pvwvuow/") or not branch:
        rep.fail("repo must be pvwvuow/* and branch given")
        return []
    files = args.get("files") or {}
    reps = args.get("replace") or []
    for p in list(files) + [r.get("path", "") for r in reps]:
        if p.startswith(".github/") or ".." in p:
            rep.fail("refused path %s" % p)
            return []
    tok = os.environ.get("BOT_TOKEN", "")
    env = dict(os.environ, GH_TOKEN=tok)
    work = tempfile.mkdtemp()
    url = "https://x-access-token:%s@github.com/%s.git" % (tok, repo)
    c, o, e = _run(["git", "clone", "--depth", "1", url, work])
    if c:
        rep.fail("clone failed: %s" % e.replace(tok, "***")[:300])
        return []
    _run(["git", "checkout", "-b", branch], cwd=work)
    for p, body in files.items():
        full = os.path.join(work, p)
        os.makedirs(os.path.dirname(full) or work, exist_ok=True)
        with open(full, "w", encoding="utf-8", newline="") as f:
            f.write(body)
        rep.add("- wrote %s (%d bytes)" % (p, len(body.encode("utf-8"))))
    for r in reps:
        full = os.path.join(work, r["path"])
        with open(full, encoding="utf-8", newline="") as f:
            s = f.read()
        n = s.count(r["old"])
        want = int(r.get("count", 1))
        if n != want:
            rep.fail("%s: %d matches, wanted %d - nothing pushed" % (r["path"], n, want))
            return []
        s = s.replace(r["old"], r["new"])
        with open(full, "w", encoding="utf-8", newline="") as f:
            f.write(s)
        rep.add("- replaced in %s" % r["path"])
    _run(["git", "config", "user.name", "wowfarsi-bot"], cwd=work)
    _run(["git", "config", "user.email", "bot@wowfarsi.ir"], cwd=work)
    _run(["git", "add", "-A"], cwd=work)
    c, o, e = _run(["git", "commit", "-m", args.get("title") or "draft"], cwd=work)
    if c:
        rep.fail("commit failed: %s" % (o + e)[:300])
        return []
    c, o, e = _run(["git", "push", "-f", "origin", branch], cwd=work)
    if c:
        rep.fail("push failed: %s" % e.replace(tok, "***")[:300])
        return []
    c, o, e = _run(["gh", "pr", "create", "--repo", repo, "--head", branch, "--draft",
                    "--title", args.get("title") or branch, "--body", args.get("body") or ""],
                   cwd=work, env=env)
    if c and "already exists" not in e:
        rep.fail("pr failed: %s" % e[:300])
        return []
    rep.ok("draft PR: %s" % (o or e)[:200])
    return []
