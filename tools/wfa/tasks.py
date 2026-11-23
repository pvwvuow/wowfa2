"""Task runner: a JSON file in ci/tasks/ is an order the tasks workflow executes on GitHub's
runners (this replaces the old Z build host). Each task ends as a PR on branch task/<id> whose
body is the report, so the result is always readable and nothing lands on main unreviewed.

ci/tasks/<id>.json = {"id": "<id>", "kind": "<kind>", "args": {...}}
kinds: migrate, fix, import, edit, spells, release (see the handlers below). Unknown kinds fail loudly.
Optional "onto": "<branch>" runs on that branch and pushes back to it (its PR gets a comment)."""
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

# ------------------------------------------------------------------ fix: precise data edits
def _tables(store, name):
    """name: quests | tpl | ui | names.<kind> | * -> list of (table_name, dict)"""
    if name == "*":
        out = [("quests", store.quests), ("tpl", store.tpl), ("ui", store.ui)]
        return out + [("names." + k, v) for k, v in sorted(store.names.items())]
    if name == "quests":
        return [("quests", store.quests)]
    if name in ("tpl", "ui"):
        return [(name, getattr(store, name))]
    if name.startswith("names.") and name[6:] in store.names:
        return [(name, store.names[name[6:]])]
    raise ValueError("unknown table %r" % name)


def _keys(tab, op):
    if "key" in op:
        k = int(op["key"]) if isinstance(next(iter(tab), ""), int) else str(op["key"])
        return [k] if k in tab else []
    pre = op.get("key_prefix")
    return [k for k in tab if pre is None or str(k).startswith(pre)]


def _strings(val):
    """yield (path, text) for every string inside a value (quest records are dicts + lists)"""
    if isinstance(val, str):
        yield (), val
    elif isinstance(val, dict):
        for f in sorted(val):
            for p, x in _strings(val[f]):
                yield (f,) + p, x
    elif isinstance(val, list):
        for i, v in enumerate(val):
            for p, x in _strings(v):
                yield (i,) + p, x


def _put(val, path, new):
    if not path:
        return new
    val[path[0]] = _put(val[path[0]], path[1:], new)
    return val


def task_fix(t, rep):
    """ops (all literal, no regex):
      {"op":"replace","table":T,"key"|"key_prefix":..,"old":..,"new":..,"count":N}  N = expected hits
      {"op":"set","table":T,"key":K,"value":V,"expect_old":X?,"create":false}
      {"op":"delete","table":T,"key":K}           remove one row (lower the floor in policy.json too)
      {"op":"find","table":T,"text":S}            report every hit (max 80)
      {"op":"show","table":T,"key"|"key_prefix":..}  report full values (max 20)
    A wrong count / missing key / unexpected old value fails the task and nothing is committed."""
    import sys
    sys.path.insert(0, os.path.join(ROOT, "tools"))
    from ci import lint_into, policy
    from .store import Store
    store = Store.load()
    ok = True
    rep.h("Ops")
    for i, op in enumerate(t["args"]["ops"], 1):
        kind = op["op"]
        tabs = _tables(store, op.get("table", "*"))
        if kind == "replace":
            hits = 0
            for tn, tab in tabs:
                for k in _keys(tab, op):
                    for path, x in list(_strings(tab[k])):
                        if op["old"] in x:
                            hits += x.count(op["old"])
                            tab[k] = _put(tab[k], path, x.replace(op["old"], op["new"]))
            good = hits == op.get("count", hits)
            ok &= good
            (rep.ok if good else rep.fail)("#%d replace %r -> %r in %s: %d hits (expected %s)"
                                          % (i, op["old"], op["new"], op.get("table", "*"), hits, op.get("count", "any")))
        elif kind == "set":
            tn, tab = tabs[0]
            k = op["key"]
            if tn == "quests":
                raise ValueError("set works on name/tpl/ui tables only")
            if k not in tab and not op.get("create"):
                ok = False
                rep.fail("#%d set %s[%r]: key missing (use create)" % (i, tn, k))
                continue
            if "expect_old" in op and tab.get(k) != op["expect_old"]:
                ok = False
                rep.fail("#%d set %s[%r]: old value is %r, expected %r" % (i, tn, k, tab.get(k), op["expect_old"]))
                continue
            rep.ok("#%d set %s[%r]: %r -> %r" % (i, tn, k, tab.get(k), op["value"]))
            tab[k] = op["value"]
        elif kind == "delete":
            tn, tab = tabs[0]
            k = op["key"]
            if tn == "quests":
                k = int(k)
            if k not in tab:
                ok = False
                rep.fail("#%d delete %s[%r]: key missing" % (i, tn, k))
                continue
            rep.ok("#%d delete %s[%r] (was %r)" % (i, tn, k, tab[k]))
            del tab[k]
        elif kind == "find":
            n = 0
            for tn, tab in tabs:
                for k in sorted(tab, key=str):
                    for path, x in _strings(tab[k]):
                        if op["text"] in x:
                            n += 1
                            if n <= 80:
                                j = x.find(op["text"])
                                rep.add("  - %s:%s%s: ...%s..." % (tn, k, "".join(":%s" % p for p in path),
                                                                 x[max(0, j - 60):j + 80].replace("\n", " ")))
            rep.add("- #%d find %r: %d hits" % (i, op["text"], n))
        elif kind == "show":
            n = 0
            for tn, tab in tabs:
                for k in sorted(_keys(tab, op), key=str):
                    n += 1
                    if n <= 20:
                        rep.add("- #%d %s[%r] =\n```\n%s\n```" % (i, tn, k, json.dumps(tab[k], ensure_ascii=False, indent=1)))
            rep.add("- #%d show: %d rows" % (i, n))
        else:
            raise ValueError("unknown op %r" % kind)
    if not ok:
        rep.fail("an op did not match: nothing committed")
        return []
    store.save()
    lint_into(rep, store, policy())
    return ["data"]


# ------------------------------------------------------------------ import: copy files repo -> repo
def task_import(t, rep):
    """args: {"repo": "wowfa", "ref": "<sha|branch>", "map": [{"from": path, "to": path, "dir": false}]}
    Byte-exact copy (fonts, textures, Lua). dir=true copies every file directly inside the folder.
    A missing source fails the task; the report lists every copied file with its blob sha."""
    a = t["args"]
    src = os.path.join(WORK, "import_src")
    pats = sorted(set("/" + m["from"].strip("/") + ("/" if m.get("dir") else "") for m in a["map"]))
    sha = sparse_fetch(a["repo"], a["ref"], pats, src)
    rep.h("Import")
    rep.add("- source: %s@%s" % (a["repo"], sha))
    rows, paths = [], []
    for m in a["map"]:
        s = os.path.join(src, m["from"].strip("/"))
        d = os.path.join(ROOT, m["to"].strip("/"))
        pairs = []
        if m.get("dir"):
            if not os.path.isdir(s):
                raise ValueError("missing folder %s" % m["from"])
            for fn in sorted(os.listdir(s)):
                if os.path.isfile(os.path.join(s, fn)):
                    pairs.append((os.path.join(s, fn), os.path.join(d, fn)))
        else:
            if not os.path.isfile(s):
                raise ValueError("missing file %s" % m["from"])
            pairs.append((s, d))
        for fs, fd in pairs:
            os.makedirs(os.path.dirname(fd), exist_ok=True)
            shutil.copyfile(fs, fd)
            rel = os.path.relpath(fd, ROOT)
            blob = git("hash-object", fd, capture=True).stdout.strip()
            rows.append((rel, os.path.getsize(fd), blob))
            paths.append(rel)
    rep.table(rows, ["file", "bytes", "blob sha"])
    rep.ok("%d files copied byte-exact" % len(rows))
    return paths


# ------------------------------------------------------------------ edit: literal file edits
def task_edit(t, rep):
    """args.ops (applied in order, all-or-nothing, literal text only):
      {"file": path, "old": s, "new": s, "count": 1}   count = exact expected occurrences
      {"file": path, "write": content}                 create / overwrite the whole file
      {"file": path, "delete": true}
    Files are read and written as UTF-8 bytes unchanged otherwise (no newline translation)."""
    ok, changed, deleted = True, {}, []
    rep.h("Edits")
    for i, op in enumerate(t["args"]["ops"], 1):
        rel = op["file"].strip("/")
        path = os.path.join(ROOT, rel)
        if op.get("delete"):
            if not os.path.isfile(path):
                ok = False
                rep.fail("#%d delete %s: no such file" % (i, rel))
                continue
            deleted.append(rel)
            changed.pop(rel, None)
            rep.ok("#%d delete %s" % (i, rel))
            continue
        if "write" in op:
            changed[rel] = op["write"]
            rep.ok("#%d write %s (%d chars)" % (i, rel, len(op["write"])))
            continue
        text = changed.get(rel)
        if text is None:
            if not os.path.isfile(path):
                ok = False
                rep.fail("#%d %s: no such file" % (i, rel))
                continue
            with open(path, encoding="utf-8", newline="") as f:
                text = f.read()
        n = text.count(op["old"])
        want = op.get("count", 1)
        if n != want:
            ok = False
            rep.fail("#%d %s: %d matches, expected %d: %r" % (i, rel, n, want, op["old"][:120]))
            continue
        changed[rel] = text.replace(op["old"], op["new"])
        rep.ok("#%d %s: %d replaced" % (i, rel, n))
    if not ok:
        rep.fail("an edit did not match: nothing written")
        return []
    for rel, text in changed.items():
        path = os.path.join(ROOT, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8", newline="") as f:
            f.write(text)
    for rel in deleted:
        git("rm", "-q", "--", rel)
    return sorted(changed)


# ------------------------------------------------------------------ spells: site class files -> data
def task_spells(t, rep):
    """args: {"wow_ref": "main"}. Spell + talent names, tree names and description templates from
    wow/data/forever/db/<class>.json (see tools/wfa/spells.py). Re-run it after every site/game update:
    fill-only, every new row pre-checked against the gates, floors raised to the new counts, and the
    rows it could not take are written to ci/results/<id>-todo.json (the translation worklist)."""
    from ci import lint_into
    from .spells import CLASSES, import_classes
    from .store import Store
    a = t.get("args", {})
    src = os.path.join(WORK, "spells_src")
    sha = sparse_fetch("wow", a.get("wow_ref", "main"), ["/data/forever/db/%s.json" % c for c in CLASSES], src)
    classes = {}
    for c in CLASSES:
        p = os.path.join(src, "data", "forever", "db", c + ".json")
        if not os.path.isfile(p):
            raise ValueError("missing class file %s.json in wow@%s" % (c, sha))
        classes[c] = read_json(p)
    pol_path = os.path.join(ROOT, "policy.json")
    pol = read_json(pol_path)
    store = Store.load()
    before = {"names.spell": len(store.names["spell"]), "names.tree": len(store.names["tree"]), "tpl": len(store.tpl)}
    r = import_classes(store, classes)
    rep.h("Source")
    rep.add("- wow@%s" % sha)
    game = pol.get("game_build", "?")
    for c, b in sorted(r["builds"].items()):
        if b != game:
            rep.add("- note: %s.json is from build %s, the game is %s: a reworded tooltip simply will not "
                    "match (the addon's miss watch reports it), nothing wrong is shown" % (c, b, game))
    rep.h("Added (fill-only)")
    after = {"names.spell": len(store.names["spell"]), "names.tree": len(store.names["tree"]), "tpl": len(store.tpl)}
    rep.table([(k, before[k], after[k], after[k] - before[k]) for k in sorted(before)], ["table", "before", "after", "added"])
    rep.table([(c, v["spell"], v["tree"], v["tpl"]) for c, v in sorted(r["per_class"].items())],
              ["class", "names", "trees", "templates"])
    rep.add("- already identical: %s" % json.dumps(r["same"]))
    def det(title, items):
        rep.add("<details><summary>%s (%d)</summary>\n\n%s\n\n</details>" %
                (title, len(items), "\n".join("- " + x for x in items[:60])))
    rep.h("Not taken (worklist)")
    rep.add("- numbers differ between EN and Persian (needs a translator): %d" % len(r["num_mismatch"]))
    det("number mismatch", ["%s: %s" % (x["w"], x["en"][:100]) for x in r["num_mismatch"]])
    det("table already has another Persian (table kept)", r["conflict"])
    det("would add a second English for one Persian (name_pairs ratchet)", r["pair_reject"])
    det("failed a data gate", r["gate_reject"])
    todo = os.path.join(ROOT, "ci", "results", t["id"] + "-todo.json")
    os.makedirs(os.path.dirname(todo), exist_ok=True)
    with open(todo, "w", encoding="utf-8") as fh:
        json.dump({"source": "wow@" + sha, "num_mismatch": r["num_mismatch"], "conflict": r["conflict"],
                   "pair_reject": r["pair_reject"], "gate_reject": r["gate_reject"]},
                  fh, ensure_ascii=False, indent=1)
        fh.write("\n")
    store.save()
    floors = pol.setdefault("floors", {})
    for k, v in after.items():
        if floors.get(k, 0) < v:
            floors[k] = v
    with open(pol_path, "w", encoding="utf-8") as fh:
        json.dump(pol, fh, ensure_ascii=False, indent=1)
        fh.write("\n")
    rep.add("- floors raised to the new counts: %s" % json.dumps({k: floors[k] for k in after}))
    lint_into(rep, store, pol)
    return ["data", "policy.json", os.path.relpath(todo, ROOT)]


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


HANDLERS = {"migrate": task_migrate, "fix": task_fix, "import": task_import, "edit": task_edit, "spells": task_spells, "release": task_release}


# ------------------------------------------------------------------ runner
def changed_tasks(since):
    if not since or set(since) == {"0"}:
        return []
    p = git("diff", "--name-only", "--diff-filter=AM", since, "HEAD", "--", "ci/tasks", capture=True)
    return [x for x in p.stdout.split() if x.endswith(".json")]


def run(since, only):
    import sys
    sys.path.insert(0, os.path.join(ROOT, "tools"))
    from ci import Report, lint_into, policy  # noqa: F401  (preload before a branch checkout)
    from . import store as _store  # noqa: F401
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
        onto = t.get("onto")
        branch = onto or "task/" + tid
        git("fetch", "-q", "origin")
        git("checkout", "-q", "-B", branch, "origin/" + (onto or "main"))
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
        git("push", "-q", *([] if onto else ["-f"]), "origin", branch)
        env = dict(os.environ, GH_TOKEN=os.environ.get("BOT_TOKEN", ""))
        short = body if len(body) < 60000 else body[:60000] + "\n\n(truncated: full text in ci/results/%s.md)\n" % tid
        with open("/tmp/pr-body.md", "w", encoding="utf-8") as fh:
            fh.write(short)
        if onto:
            subprocess.run(["gh", "pr", "comment", branch, "--body-file", "/tmp/pr-body.md"], env=env, check=True)
            p = None
        else:
            p = subprocess.run(["gh", "pr", "create", "--base", "main", "--head", branch, "--title",
                            "task %s (%s)" % (tid, t["kind"]), "--body-file", "/tmp/pr-body.md"],
                               env=env, text=True, capture_output=True)
        if p is not None and p.returncode:
            subprocess.run(["gh", "pr", "edit", branch, "--body-file", "/tmp/pr-body.md"], env=env, check=True)
        worst = max(worst, 1 if rep.failed else 0)
        git("reset", "-q", "--hard")
        git("clean", "-q", "-fd", "-e", "out")
        git("checkout", "-q", "main")
    return worst
