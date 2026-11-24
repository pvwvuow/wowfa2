## task 0170-cfretry3 (script)

**GREEN**


### Re-publish

- forever-v1.0.0-beta.2 is a draft again
- old tag removed: ok
- target set to main: ok

### Publish

- WoWFA Forever 1.0.0-beta.2: draft=True, zip=WoWFA-1.0.0-beta.2.zip
- ok: published forever-v1.0.0-beta.2 (pre-release); the CurseForge workflow of wowfarsi-addon starts now

### Runs

- 45466569638 2026-11-24T19:05:51Z completed/success release
- 45465808950 2026-11-24T19:01:40Z completed/failure release
- 45462182348 2026-11-24T18:41:10Z completed/failure workflow_dispatch
- 45459278855 2026-11-24T18:24:56Z completed/failure release

### What run 45466569638 printed

```
[Check settings] ﻿2026-11-24T19:05:54.9835564Z ##[group]Run ok=1
[Check settings] ^[[36;1mok=1^[[0m
[Check settings] ^[[36;1mif [ -z "$CF_API_KEY" ]; then echo "::error::secret CF_API_KEY is missing (Settings > Secrets and variables > Actions > Secrets)"; ok=0; fi^[[0m
[Check settings] ^[[36;1mif [ -z "$P1$P2" ]; then echo "::error::variable CF_FOREVER_PROJECT_ID is missing (Settings > Secrets and variables > Actions > Variables)"; ok=0; fi^[[0m
[Check settings] ^[[36;1mecho "project id variable: ${P1:-<none>} / old CF_PROJECT_ID: ${P2:-<none>}"^[[0m
[Check settings] ^[[36;1m[ "$ok" = 1 ]^[[0m
[Check settings] shell: /usr/bin/bash -e {0}
[Check settings] env:
[Check settings]   CF_API_KEY: ***
[Check settings]   P1: 
[Check settings]   P2: 1764059
[Check settings] project id variable: <none> / old CF_PROJECT_ID: 1764059
[Download the release zip] ﻿2026-11-24T19:05:55.0483184Z ##[group]Run gh release download "$TAG" --repo "$GITHUB_REPOSITORY" --pattern 'WoWFA-*.zip' --dir .
[Download the release zip] ^[[36;1mgh release download "$TAG" --repo "$GITHUB_REPOSITORY" --pattern 'WoWFA-*.zip' --dir .^[[0m
[Download the release zip] ^[[36;1mgh release view "$TAG" --repo "$GITHUB_REPOSITORY" --json body --jq .body > notes.md^[[0m
[Download the release zip] ^[[36;1mls -l WoWFA-*.zip^[[0m
[Download the release zip] shell: /usr/bin/bash -e {0}
[Download the release zip] env:
[Download the release zip]   GH_TOKEN: ***
[Download the release zip]   TAG: forever-v1.0.0-beta.2
[Download the release zip] -rw-r--r-- 1 runner runner 2233661 Nov 24 19:05 WoWFA-1.0.0-beta.2.zip
[Upload to CurseForge] ﻿2026-11-24T19:05:56.3464273Z ##[group]Run set -uo pipefail
[Upload to CurseForge] ^[[36;1mset -uo pipefail^[[0m
[Upload to CurseForge] ^[[36;1mget() {^[[0m
[Upload to CurseForge] ^[[36;1m  code=$(curl -sS -o "$2" -w '%{http_code}' -H "X-Api-Token: $CF_API_KEY" "$1")^[[0m
[Upload to CurseForge] ^[[36;1m  echo "GET $1 -> HTTP $code"^[[0m
[Upload to CurseForge] ^[[36;1m  case "$code" in 2*) ;; *) head -c 600 "$2"; echo; echo "::error::CurseForge refused the API token (HTTP $code): make a new token at https://legacy.curseforge.com/account/api-tokens and put it in CF_API_KEY"; exit 1 ;; esac^[[0m
[Upload to CurseForge] ^[[36;1m}^[[0m
[Upload to CurseForge] ^[[36;1mget https://wow.curseforge.com/api/game/versions versions.json^[[0m
[Upload to CurseForge] ^[[36;1mget https://wow.curseforge.com/api/game/version-types types.json^[[0m
[Upload to CurseForge] ^[[36;1mGV=$(python3 - <<'PY'^[[0m
[Upload to CurseForge] ^[[36;1mimport json, os, sys^[[0m
[Upload to CurseForge] ^[[36;1mvs = json.load(open("versions.json"))^[[0m
[Upload to CurseForge] ^[[36;1mts = json.load(open("types.json"))^[[0m
[Upload to CurseForge] ^[[36;1mwant = os.environ.get("CF_GAME_VERSION", "").strip()^[[0m
[Upload to CurseForge] ^[[36;1mif want:^[[0m
[Upload to CurseForge] ^[[36;1m    ok = [v for v in vs if v.get("name") == want]^[[0m
[Upload to CurseForge] ^[[36;1m    if not ok:^[[0m
[Upload to CurseForge] ^[[36;1m        sys.stderr.write("::error::CF_GAME_VERSION %r is not a CurseForge version\n" % want)^[[0m
[Upload to CurseForge] ^[[36;1melse:^[[0m
[Upload to CurseForge] ^[[36;1m    slug = os.environ.get("CF_GAME_TYPE", "").strip() or "wow_classic"^[[0m
[Upload to CurseForge] ^[[36;1m    tids = [t["id"] for t in ts if t.get("slug") == slug]^[[0m
[Upload to CurseForge] ^[[36;1m    if not tids:^[[0m
[Upload to CurseForge] ^[[36;1m        sys.stderr.write("::error::flavour %r not found; set CF_GAME_TYPE to one of: %s\n"^[[0m
[Upload to CurseForge] ^[[36;1m                         % (slug, ", ".join(sorted(t.get("slug", "") for t in ts))))^[[0m
[Upload to CurseForge] ^[[36;1m    ok = sorted([v for v in vs if v.get("gameVersionTypeID") in tids], key=lambda v: v["id"])[-1:]^[[0m
[Upload to CurseForge] ^[[36;1mif ok:^[[0m
[Upload to CurseForge] ^[[36;1m    sys.stderr.write("game version: %s (id %s)\n" % (ok[0].get("name"), ok[0]["id"]))^[[0m
[Upload to CurseForge] ^[[36;1m    print(ok[0]["id"])^[[0m
[Upload to CurseForge] ^[[36;1mPY^[[0m
[Upload to CurseForge] ^[[36;1m)^[[0m
[Upload to CurseForge] ^[[36;1m[ -n "$GV" ] || { echo "::error::no CurseForge game version found"; exit 1; }^[[0m
[Upload to CurseForge] ^[[36;1mcase "$TAG" in *-*) REL=beta ;; *) REL=release ;; esac^[[0m
[Upload to CurseForge] ^[[36;1mZIP=$(ls WoWFA-*.zip | head -n1)^[[0m
[Upload to CurseForge] ^[[36;1mMETA=$(GV="$GV" REL="$REL" python3 -c 'import json,os; print(json.dumps({"changelog": open("notes.md").read(), "changelogType": "markdown", "displayName": os.environ["TAG"], "gameVersions": [int(os.environ["GV"])], "releaseType": os.environ["REL"]}))')^[[0m
[Upload to CurseForge] ^[[36;1mcode=$(curl -sS -o resp.json -w '%{http_code}' -X POST -H "X-Api-Token: $CF_API_KEY" \^[[0m
[Upload to CurseForge] ^[[36;1m  -F "metadata=$META" -F "file=@$ZIP" \^[[0m
[Upload to CurseForge] ^[[36;1m  "https://wow.curseforge.com/api/projects/$CF_PROJECT_ID/upload-file")^[[0m
[Upload to CurseForge] ^[[36;1mecho "upload to project $CF_PROJECT_ID -> HTTP $code"^[[0m
[Upload to CurseForge] ^[[36;1mcat resp.json; echo^[[0m
[Upload to CurseForge] ^[[36;1mcase "$code" in^[[0m
[Upload to CurseForge] ^[[36;1m  2*) echo "uploaded $ZIP as $REL" ;;^[[0m
[Upload to CurseForge] ^[[36;1m  403) echo "::error::HTTP 403: the token's account is not an author of project $CF_PROJECT_ID, or the project id is wrong"; exit 1 ;;^[[0m
[Upload to CurseForge] ^[[36;1m  404) echo "::error::HTTP 404: project $CF_PROJECT_ID not found (check CF_FOREVER_PROJECT_ID)"; exit 1 ;;^[[0m
[Upload to CurseForge] ^[[36;1m  *) echo "::error::CurseForge upload failed (HTTP $code), see the response above"; exit 1 ;;^[[0m
[Upload to CurseForge] ^[[36;1mesac^[[0m
[Upload to CurseForge] shell: /usr/bin/bash -e {0}
[Upload to CurseForge] env:
[Upload to CurseForge]   CF_API_KEY: ***
[Upload to CurseForge]   CF_PROJECT_ID: 1764059
[Upload to CurseForge]   CF_GAME_VERSION: 
[Upload to CurseForge]   CF_GAME_TYPE: wow-forever
[Upload to CurseForge]   TAG: forever-v1.0.0-beta.2
[Upload to CurseForge] GET https://wow.curseforge.com/api/game/versions -> HTTP 200
[Upload to CurseForge] GET https://wow.curseforge.com/api/game/version-types -> HTTP 200
[Upload to CurseForge] game version: 1.60.1 (id 17053)
[Upload to CurseForge] upload to project 1764059 -> HTTP 200
[Upload to CurseForge] {"id":9796990}
[Upload to CurseForge] uploaded WoWFA-1.0.0-beta.2.zip as beta
[Complete job] ﻿2026-11-24T19:05:57.2592136Z Cleaning up orphan processes
```
- ok: read 4 runs
