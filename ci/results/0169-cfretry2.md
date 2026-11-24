## task 0169-cfretry2 (script)

**GREEN**


### Re-publish

- forever-v1.0.0-beta.2 is a draft again

### Publish

- WoWFA Forever 1.0.0-beta.2: draft=True, zip=WoWFA-1.0.0-beta.2.zip
- ok: published forever-v1.0.0-beta.2 (pre-release); the CurseForge workflow of wowfarsi-addon starts now

### Runs

- 45465808950 2026-11-24T19:01:40Z completed/failure release
- 45462182348 2026-11-24T18:41:10Z completed/failure workflow_dispatch
- 45459278855 2026-11-24T18:24:56Z completed/failure release

### What run 45465808950 printed

```
[Set up job] ﻿2026-11-24T19:01:42.8784644Z Current runner version: '2.338.2'
[Set up job] Secret source: Actions
[Set up job] Cache mode: write
[Set up job] Prepare workflow directory
[Set up job] Prepare all required actions
[Set up job] Complete job name: upload
[Download the release zip] ﻿2026-11-24T19:01:42.9766459Z ##[group]Run gh release download "$TAG" --repo "$GITHUB_REPOSITORY" --pattern 'WoWFA-*.zip' --dir .
[Download the release zip] ^[[36;1mgh release download "$TAG" --repo "$GITHUB_REPOSITORY" --pattern 'WoWFA-*.zip' --dir .^[[0m
[Download the release zip] ^[[36;1mgh release view "$TAG" --repo "$GITHUB_REPOSITORY" --json body --jq .body > notes.md^[[0m
[Download the release zip] ^[[36;1mls -l WoWFA-*.zip^[[0m
[Download the release zip] shell: /usr/bin/bash -e {0}
[Download the release zip] env:
[Download the release zip]   GH_TOKEN: ***
[Download the release zip]   TAG: forever-v1.0.0-beta.2
[Download the release zip] -rw-r--r-- 1 runner runner 2233661 Nov 24 19:01 WoWFA-1.0.0-beta.2.zip
[Upload to CurseForge] ﻿2026-11-24T19:01:44.4350840Z ##[group]Run set -euo pipefail
[Upload to CurseForge] ^[[36;1mset -euo pipefail^[[0m
[Upload to CurseForge] ^[[36;1mtest -n "$CF_API_KEY" && test -n "$CF_PROJECT_ID" || { echo "CF_API_KEY / CF_FOREVER_PROJECT_ID missing"; exit 1; }^[[0m
[Upload to CurseForge] ^[[36;1mcurl -fsS -H "X-Api-Token: $CF_API_KEY" https://wow.curseforge.com/api/game/versions > versions.json^[[0m
[Upload to CurseForge] ^[[36;1mcurl -fsS -H "X-Api-Token: $CF_API_KEY" https://wow.curseforge.com/api/game/version-types > types.json^[[0m
[Upload to CurseForge] ^[[36;1mGV=$(python3 - <<'PY'^[[0m
[Upload to CurseForge] ^[[36;1mimport json, os, sys^[[0m
[Upload to CurseForge] ^[[36;1mvs = json.load(open("versions.json"))^[[0m
[Upload to CurseForge] ^[[36;1mts = json.load(open("types.json"))^[[0m
[Upload to CurseForge] ^[[36;1mwant = os.environ.get("CF_GAME_VERSION", "").strip()^[[0m
[Upload to CurseForge] ^[[36;1mif want:^[[0m
[Upload to CurseForge] ^[[36;1m    ok = [v for v in vs if v.get("name") == want]^[[0m
[Upload to CurseForge] ^[[36;1melse:^[[0m
[Upload to CurseForge] ^[[36;1m    slug = os.environ.get("CF_GAME_TYPE", "").strip() or "wow_classic"^[[0m
[Upload to CurseForge] ^[[36;1m    tids = [t["id"] for t in ts if t.get("slug") == slug]^[[0m
[Upload to CurseForge] ^[[36;1m    if not tids:^[[0m
[Upload to CurseForge] ^[[36;1m        sys.stderr.write("flavour '%s' not found; known: %s\n" % (slug, ", ".join(sorted(t.get("slug", "") for t in ts))))^[[0m
[Upload to CurseForge] ^[[36;1m    ok = sorted([v for v in vs if v.get("gameVersionTypeID") in tids], key=lambda v: v["id"])[-1:]^[[0m
[Upload to CurseForge] ^[[36;1mif ok:^[[0m
[Upload to CurseForge] ^[[36;1m    sys.stderr.write("game version: %s (id %s)\n" % (ok[0].get("name"), ok[0]["id"]))^[[0m
[Upload to CurseForge] ^[[36;1m    print(ok[0]["id"])^[[0m
[Upload to CurseForge] ^[[36;1mPY^[[0m
[Upload to CurseForge] ^[[36;1m)^[[0m
[Upload to CurseForge] ^[[36;1mtest -n "$GV" || { echo "no CurseForge game version found"; exit 1; }^[[0m
[Upload to CurseForge] ^[[36;1mcase "$TAG" in *-*) REL=beta ;; *) REL=release ;; esac^[[0m
[Upload to CurseForge] ^[[36;1mZIP=$(ls WoWFA-*.zip | head -n1)^[[0m
[Upload to CurseForge] ^[[36;1mMETA=$(GV="$GV" REL="$REL" python3 -c 'import json,os; print(json.dumps({"changelog": open("notes.md").read(), "changelogType": "markdown", "displayName": os.environ["TAG"], "gameVersions": [int(os.environ["GV"])], "releaseType": os.environ["REL"]}))')^[[0m
[Upload to CurseForge] ^[[36;1mcurl -fsS -H "X-Api-Token: $CF_API_KEY" \^[[0m
[Upload to CurseForge] ^[[36;1m  -F "metadata=$META" -F "file=@$ZIP" \^[[0m
[Upload to CurseForge] ^[[36;1m  "https://wow.curseforge.com/api/projects/$CF_PROJECT_ID/upload-file"^[[0m
[Upload to CurseForge] shell: /usr/bin/bash -e {0}
[Upload to CurseForge] env:
[Upload to CurseForge]   CF_API_KEY: ***
[Upload to CurseForge]   CF_PROJECT_ID: 
[Upload to CurseForge]   CF_GAME_VERSION: 
[Upload to CurseForge]   CF_GAME_TYPE: wow-forever
[Upload to CurseForge]   TAG: forever-v1.0.0-beta.2
[Upload to CurseForge] CF_API_KEY / CF_FOREVER_PROJECT_ID missing
[Upload to CurseForge] ##[error]Process completed with exit code 1.
[Complete job] ﻿2026-11-24T19:01:44.4503757Z Cleaning up orphan processes
```
- ok: read 3 runs
