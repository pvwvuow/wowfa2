"""Task runner: a JSON file in ci/tasks/ is an order the tasks workflow executes on GitHub's
runners (this replaces the old Z build host). Each task ends as a PR on branch task/<id> whose
body is the report, so the result is always readable and nothing lands on main unreviewed.

ci/tasks/<id>.json = {"id": "<id>", "kind": "<kind>", "args": {...}}
kinds: migrate, release (see the handlers below). Unknown kinds fail loudly."""
import base64
import json
import os
import shutil
import subprocess

from .core import OUT, ROOT, read_json

WORK = "/tmp/wfa-work"
OWNER = "pvwvuow"


def git(*args, cwd=ROOT, check=True, capture=False, secret=False):
    # secret=True: never echo the command (it carries an auth header)
    print("+ git " + ("<auth config hidden>" if secret else " ".join(args)), flush=True)
    return subprocess.run(["git"] + list(args), cwd=cwd, check=check, text=True,
                          capture_output=capture or secret)


def _auth_header():
    tok = os.environ.get("BOT_TOKEN", "")
    if not tok:
        raise SystemExit("BOT_TOKEN secret missing: see docs/OWNER_SETUP.md")
    b = base64.b64encode(("x-access-token:" + tok).encode()).decode()
    return "AUTHORIZATION: basic " + b


def sparse_fetch(repo, ref, patterns, dest):
    """Fetch only `patterns` of pvwvuow/<repo> at <ref> (branch or sha): partial + sparse +
    depth 1, so a 300 MB repo costs a few MB. The auth header lives only in the temp repo's
    config on the throw-away runner and is never printed."""
    if os.path.isdir(dest):
        shutil.rmtree(dest)
    os.makedirs(dest)
    git("init", "-q", cwd=dest)
    git("config", "http.https://github.com/.extraheader", _auth_header(), cwd=dest, secret=True)
    git("remote", "add", "origin", "https://github.com/%s/%s.git" % (OWNER, repo), cwd=dest)
    git("config", "remote.origin.promisor", "true", cwd=dest)
    git("config", "remote.origin.partialclonefilter", "blob:none", cwd=dest)
    git("sparse-checkout", "set", "--no-cone", *patterns, cwd=dest)
    git("fetch", "-q", "--depth", "1", "--filter=blob:none", "origin", ref, cwd=dest)
    git("checkout", "-q", "FETCH_HEAD", cwd=dest)
    return git("rev-parse", "HEAD", cwd=dest, capture=True).stdout.strip()


def lua_dump(data_dir, out, files):
    subprocess.run(["lua5.1", os.path.join(ROOT, "tools", "lua", "dump_old.lua"), data_dir, out] + files,
                   check=True)
    with open(out, encoding="utf-8") as f:
        return json.load(f)


# ------------------------------------------------------------------ handlers
def task_migrate(t, rep):
    from . import build as B
    from . import migrate as M
    from .lint import run as lint_run
    args = t["args"]
    data_pat = "/addon/WoWFA/Forever/Data/%s.lua"
    q_dir = os.path.join(WORK, "old_q")
    s_dir = os.path.join(WORK, "old_s")
    w_dir = os.path.join(WORK, "wow")
    q_sha = sparse_fetch("wowfa", args["wowfa_quests_ref"], [data_pat % n for n in ("Meta", "Names", "Quests")], q_dir)
    s_sha = sparse_fetch("wowfa", args["wowfa_tpl_ref"], [data_pat % n for n in ("Meta", "Spells")], s_dir)
    w_sha = sparse_fetch("wow", args.get("wow_ref", "main"), ["/data/forever/db/quest-*.json"], w_dir)
    rep.h("Sources")
    rep.table([("wowfa (quests, names)", q_sha), ("wowfa (templates)", s_sha), ("wow (EN titles)", w_sha)],
              ["input", "commit"])
    dq = os.path.join(q_dir, "addon/WoWFA/Forever/Data")
    ds = os.path.join(s_dir, "addon/WoWFA/Forever/Data")
    old_q = lua_dump(dq, os.path.join(WORK, "old_q.json"), ["Meta", "Names", "Quests"])
    old_t = lua_dump(ds, os.path.join(WORK, "old_t.json"), ["Meta", "Spells"])
    rep.add("- old meta (quests side): `%s`" % json.dumps(old_q.get("meta", {}).get("counts", {}), sort_keys=True)[:900])
    rep.add("- old meta (templates side): tpl rows in file = %d, tpl_site = %s"
            % (len(old_t.get("tpl", {})), old_t.get("meta", {}).get("counts", {}).get("tpl_site")))
    store, mr = M.migrate(old_q, old_t, w_dir)
    store.ui = {}
    store.terms = read_json(os.path.join(ROOT, "data", "terms.json"))
    store.save()
    rep.h("Migration")
    rep.add("- quests %d, templates %d, name rows %s" % (
        len(store.quests), len(store.tpl), ", ".join("%s %d" % (k, len(v)) for k, v in store.names.items())))
    rep.add("- quests without an English title (no tracker hash): %d" % mr["quests_without_en_title"])
    rep.add("- name rows filled from markers (one Persian everywhere): %d" % mr["fills"])
    rep.add("- kinds not migrated: %s" % (", ".join(mr["unknown_kinds"]) or "none"))
    swaps = sorted(mr["swaps"].items(), key=lambda kv: -kv[1])
    rep.add("- markers whose Persian now comes from the table (old marker text differed): %d distinct, %d uses"
            % (len(swaps), sum(n for _, n in swaps)))
    rep.add("<details><summary>marker swaps (kind, key, old marker Persian -> table Persian, uses)</summary>\n")
    for (k, key, old, new), n in swaps[:300]:
        rep.add("- %s `%s`: %s -> %s (%d)" % (k, key, old, new, n))
    rep.add("\n</details>")
    if mr["fill_conflicts"]:
        rep.add("<details><summary>fill conflicts kept as full markers (%d)</summary>\n" % len(mr["fill_conflicts"]))
        for x in mr["fill_conflicts"][:200]:
            rep.add("- " + x)
        rep.add("\n</details>")
    for n in mr["notes"][:50]:
        rep.add("- note: " + n)
    # build + round-trip proof with the real Lua parser
    pol = read_json(os.path.join(ROOT, "policy.json"))
    counts, zpath, notes = B.build(store, pol)
    new = lua_dump(os.path.join(OUT, "dist", "WoWFA", "Data"), os.path.join(WORK, "new.json"),
                   ["Meta", "Names", "Quests", "Tpl"])
    allnames = {k: v for k, v in store.names.items()}
    st, diffs = M.verify(old_q, old_t, new, allnames)
    rep.h("Round-trip proof (v0 Data vs new build, both read by real Lua)")
    rep.table(sorted(st.items()), ["check", "count"])
    if diffs:
        rep.fail("%d differences" % len(diffs))
        for d in diffs[:60]:
            rep.add("  - " + d)
    else:
        rep.ok("every quest, objective and template is byte-equal (after table names)")
    r = lint_run(store, pol)
    rep.h("Lint on the migrated data")
    rep.add("- errors: %d" % len(r.errors))
    for g, w, m in r.errors[:40]:
        rep.add("  - %s %s: %s" % (g, w, m))
    rep.add("- ratchet now (put these in policy.json): `%s`" %
            json.dumps({g: len(v) for g, v in sorted(r.ratchet.items())}))
    rep.add("- floors now (put these in policy.json): `%s`" % json.dumps(r.counts, sort_keys=True))
    return ["data"]


def task_release(t, rep):
    """Build from main and create a DRAFT pre-release in pvwvuow/wowfarsi-addon. Never publishes:
    the owner presses Publish."""
    from . import build as B
    from .store import Store
    pol = read_json(os.path.join(ROOT, "policy.json"))
    counts, zpath, notes = B.build(Store.load(), pol)
    tag = "forever-v" + pol["version"]
    env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
    notes_md = os.path.join(OUT, "release-notes.md")
    with open(notes_md, "w", encoding="utf-8") as f:
        f.write(t["args"].get("notes", "WoWFA %s" % pol["version"]) + "\n")
    subprocess.run(["gh", "release", "create", tag, zpath, "--repo", OWNER + "/wowfarsi-addon",
                    "--draft", "--prerelease", "--title", "WoWFA Forever " + pol["version"],
                    "--notes-file", notes_md], check=True, env=env)
    rep.ok("draft release %s created in wowfarsi-addon with %s" % (tag, os.path.basename(zpath)))
    rep.table(sorted(counts.items()), ["table", "rows"])
    return []


HANDLERS = {"migrate": task_migrate, "release": task_release}


# ------------------------------------------------------------------ runner
def changed_tasks(since):
    if not since or set(since) == {"0"}:
        return []
    p = git("diff", "--name-only", "--diff-filter=AM", since, "HEAD", "--", "ci/tasks", capture=True)
    return [x for x in p.stdout.split() if x.endswith(".json")]


def run(since, only):
    import sys
    sys.path.insert(0, os.path.join(ROOT, "tools"))
    from ci import Report
    files = ["ci/tasks/%s.json" % only] if only else changed_tasks(since)
    if not files:
        print("no new task files")
        return 0
    git("config", "user.name", "wowfa-bot")
    git("config", "user.email", "wowfa-bot@users.noreply.github.com")
    worst = 0
    for f in files:
        t = read_json(os.path.join(ROOT, f))
        tid = t["id"]
        if os.path.basename(f) != tid + ".json":
            raise SystemExit("%s: id %r must equal the file name" % (f, tid))
        if t["kind"] not in HANDLERS:
            raise SystemExit("%s: unknown kind %r" % (f, t["kind"]))
        rep = Report("task %s (%s)" % (tid, t["kind"]))
        branch = "task/" + tid
        git("checkout", "-q", "-B", branch, "origin/main")
        try:
            paths = HANDLERS[t["kind"]](t, rep)
        except subprocess.CalledProcessError as e:
            rep.fail("command failed: %s" % e)
            paths = []
        except Exception as e:  # report every crash in the PR, never swallow it
            import traceback
            rep.fail("crash: %s" % e)
            rep.add("```\n" + traceback.format_exc()[-3000:] + "\n```")
            paths = []
        os.makedirs(os.path.join(ROOT, "ci", "results"), exist_ok=True)
        res = os.path.join(ROOT, "ci", "results", tid + ".md")
        body = rep.text()
        with open(res, "w", encoding="utf-8") as fh:
            fh.write(body)
        git("add", "--", res, *[os.path.join(ROOT, p) for p in paths])
        git("commit", "-q", "-m", "task %s: %s" % (tid, "RED" if rep.failed else "green"))
        git("push", "-q", "-f", "origin", branch)
        env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
        short = body if len(body) < 60000 else body[:60000] + "\n\n(truncated: full text in ci/results/%s.md)\n" % tid
        with open("/tmp/pr-body.md", "w", encoding="utf-8") as fh:
            fh.write(short)
        p = subprocess.run(["gh", "pr", "create", "--base", "main", "--head", branch, "--title",
                            "task %s (%s)" % (tid, t["kind"]), "--body-file", "/tmp/pr-body.md"],
                           env=env, text=True, capture_output=True)
        if p.returncode:
            subprocess.run(["gh", "pr", "edit", branch, "--body-file", "/tmp/pr-body.md"], env=env, check=True)
        worst = max(worst, 1 if rep.failed else 0)
        git("reset", "-q", "--hard")
        git("clean", "-q", "-fd", "-e", "out")
        git("checkout", "-q", "main")
    return worst
