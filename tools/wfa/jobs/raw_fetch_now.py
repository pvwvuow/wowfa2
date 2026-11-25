"""Capture a Forever build into pvwvuow/wow-raw from this CI (owner, 25 Nov 2026: the game updated and the
wow-raw fetch workflow stopped after 71037). Same steps as wow-raw .github/workflows/fetch.yml:
clone wow-raw, tools/rawfetch.py fetch, tools/changes_text.py, then (push=true) publish the release and
commit the manifest to wow-raw main. The change report (.md) goes into this task report.
args: {"build": "auto" | "1.60.1.71091", "push": true}"""
import os
import subprocess
import tempfile

RAW = "pvwvuow/wow-raw"


def sh(cmd, cwd, env, rep, show=40):
    p = subprocess.run(cmd, cwd=cwd, env=env, text=True, capture_output=True)
    out = ((p.stdout or "") + (p.stderr or "")).replace(env.get("GH_TOKEN", "") or "\0", "<token>")
    tail = "\n".join(out.strip().splitlines()[-show:])
    rep.add("`%s` -> %d\n```\n%s\n```" % (" ".join(cmd[:4]), p.returncode, tail[:3500].replace("`", "'")))
    return p.returncode


def run(args, rep):
    tok = os.environ.get("BOT_TOKEN", "")
    build = str(args.get("build") or "auto")
    push = bool(args.get("push", True))
    tmp = tempfile.mkdtemp()
    out_file = os.path.join(tmp, "gh_output")
    open(out_file, "w").close()
    env = dict(os.environ, GH_TOKEN=tok, GITHUB_OUTPUT=out_file)
    repo = os.path.join(tmp, "wow-raw")
    rep.h("clone")
    if sh(["git", "clone", "-q", "--depth", "1", "https://x-access-token:%s@github.com/%s.git" % (tok, RAW), repo], tmp, env, rep):
        rep.fail("clone failed")
        return []
    rep.h("fetch " + build)
    if sh(["python3", "tools/rawfetch.py", "fetch", "--product", "forever", "--build", build, "--out", "dist"], repo, env, rep):
        rep.fail("fetch failed")
        return []
    outs = {}
    for line in open(out_file, encoding="utf-8"):
        if "=" in line:
            k, v = line.rstrip("\n").split("=", 1)
            outs[k] = v
    rep.ok("outputs: %s" % outs)
    if outs.get("changed") != "true":
        rep.ok("nothing new (build %s already captured)" % outs.get("build"))
        return []
    b, tag, zp = outs.get("build"), outs.get("tag"), outs.get("zip")
    rep.h("notes")
    sh(["python3", "tools/changes_text.py", "--product", "forever", "--build", b, "--zip", zp], repo, env, rep, show=10)
    md = os.path.join(repo, "manifests", "forever", "changes", "%s.md" % b)
    if os.path.exists(md):
        txt = open(md, encoding="utf-8").read()
        rep.h("change report %s (%d chars)" % (b, len(txt)))
        rep.add(txt[:9000])
    else:
        rep.ok("no change report file written")
    if not push:
        rep.ok("push=false: nothing published")
        return []
    rep.h("publish")
    dist = os.path.join(repo, "dist")
    files = [os.path.join("dist", f) for f in sorted(os.listdir(dist)) if f.endswith(".zip")] + ["dist/manifest.json"]
    notes = "dist/release-notes.md" if os.path.exists(os.path.join(dist, "release-notes.md")) else None
    cmd = ["gh", "release", "create", tag] + files + ["--repo", RAW, "--title", tag]
    cmd += ["--notes-file", notes] if notes else ["--notes", tag]
    sh(cmd, repo, env, rep, show=8)
    sh(["git", "-c", "user.name=wowfarsi-bot", "-c", "user.email=bot@wowfarsi.ir", "add", "manifests"], repo, env, rep, show=3)
    sh(["git", "-c", "user.name=wowfarsi-bot", "-c", "user.email=bot@wowfarsi.ir", "commit", "-q", "-m", "raw: " + tag], repo, env, rep, show=3)
    if sh(["git", "push", "-q", "origin", "HEAD:main"], repo, env, rep, show=5):
        rep.fail("push to wow-raw failed")
    else:
        rep.ok("captured %s into wow-raw" % tag)
    return []
