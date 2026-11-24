## task 0165-cflog (script)

**GREEN**


### Settings of pvwvuow/wowfarsi-addon

- secrets (names only): none (could not list: failed to get secrets: HTTP 403: Resource not accessible by personal access token (https://api.github.com/repos/pvwvuow/wowfarsi-addon/actions/secrets?per_page=100))
- variables: none (could not list: failed to get variables: HTTP 403: Resource not accessible by personal access token (https://api.github.com/repos/pvwvuow/wowfarsi-addon/actions/variables?per_page=100))

### Runs

- 45462182348 2026-11-24T18:41:10Z completed/failure workflow_dispatch
- 45459278855 2026-11-24T18:24:56Z completed/failure release

### Log of run 45462182348 (last 60 lines)

```
upload	Upload to CurseForge	﻿2026-11-24T18:41:15.3881481Z ##[group]Run set -uo pipefail
upload	Upload to CurseForge	2026-11-24T18:41:15.3882374Z ^[[36;1mset -uo pipefail^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3883089Z ^[[36;1mget() {^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3883821Z ^[[36;1m  code=$(curl -sS -o "$2" -w '%{http_code}' -H "X-Api-Token: $CF_API_KEY" "$1")^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3884959Z ^[[36;1m  echo "GET $1 -> HTTP $code"^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3886667Z ^[[36;1m  case "$code" in 2*) ;; *) head -c 600 "$2"; echo; echo "::error::CurseForge refused the API token (HTTP $code): make a new token at https://legacy.curseforge.com/account/api-tokens and put it in CF_API_KEY"; exit 1 ;; esac^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3888325Z ^[[36;1m}^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3889262Z ^[[36;1mget https://wow.curseforge.com/api/game/versions versions.json^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3890298Z ^[[36;1mget https://wow.curseforge.com/api/game/version-types types.json^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3891136Z ^[[36;1mGV=$(python3 - <<'PY'^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3891729Z ^[[36;1mimport json, os, sys^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3892362Z ^[[36;1mvs = json.load(open("versions.json"))^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3893104Z ^[[36;1mts = json.load(open("types.json"))^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3893867Z ^[[36;1mwant = os.environ.get("CF_GAME_VERSION", "").strip()^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3894867Z ^[[36;1mif want:^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3895491Z ^[[36;1m    ok = [v for v in vs if v.get("name") == want]^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3896181Z ^[[36;1m    if not ok:^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3897034Z ^[[36;1m        sys.stderr.write("::error::CF_GAME_VERSION %r is not a CurseForge version\n" % want)^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3897960Z ^[[36;1melse:^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3898658Z ^[[36;1m    slug = os.environ.get("CF_GAME_TYPE", "").strip() or "wow_classic"^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3899589Z ^[[36;1m    tids = [t["id"] for t in ts if t.get("slug") == slug]^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3900325Z ^[[36;1m    if not tids:^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3901180Z ^[[36;1m        sys.stderr.write("::error::flavour %r not found; set CF_GAME_TYPE to one of: %s\n"^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3902278Z ^[[36;1m                         % (slug, ", ".join(sorted(t.get("slug", "") for t in ts))))^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3903424Z ^[[36;1m    ok = sorted([v for v in vs if v.get("gameVersionTypeID") in tids], key=lambda v: v["id"])[-1:]^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3904376Z ^[[36;1mif ok:^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3905367Z ^[[36;1m    sys.stderr.write("game version: %s (id %s)\n" % (ok[0].get("name"), ok[0]["id"]))^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3906260Z ^[[36;1m    print(ok[0]["id"])^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3906848Z ^[[36;1mPY^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3907339Z ^[[36;1m)^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3908020Z ^[[36;1m[ -n "$GV" ] || { echo "::error::no CurseForge game version found"; exit 1; }^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3909011Z ^[[36;1mcase "$TAG" in *-*) REL=beta ;; *) REL=release ;; esac^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3909771Z ^[[36;1mZIP=$(ls WoWFA-*.zip | head -n1)^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3911606Z ^[[36;1mMETA=$(GV="$GV" REL="$REL" python3 -c 'import json,os; print(json.dumps({"changelog": open("notes.md").read(), "changelogType": "markdown", "displayName": os.environ["TAG"], "gameVersions": [int(os.environ["GV"])], "releaseType": os.environ["REL"]}))')^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3913688Z ^[[36;1mcode=$(curl -sS -o resp.json -w '%{http_code}' -X POST -H "X-Api-Token: $CF_API_KEY" \^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3914860Z ^[[36;1m  -F "metadata=$META" -F "file=@$ZIP" \^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3915808Z ^[[36;1m  "https://wow.curseforge.com/api/projects/$CF_PROJECT_ID/upload-file")^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3916804Z ^[[36;1mecho "upload to project $CF_PROJECT_ID -> HTTP $code"^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3917554Z ^[[36;1mcat resp.json; echo^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3918121Z ^[[36;1mcase "$code" in^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3918701Z ^[[36;1m  2*) echo "uploaded $ZIP as $REL" ;;^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3919912Z ^[[36;1m  403) echo "::error::HTTP 403: the token's account is not an author of project $CF_PROJECT_ID, or the project id is wrong"; exit 1 ;;^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3921464Z ^[[36;1m  404) echo "::error::HTTP 404: project $CF_PROJECT_ID not found (check CF_FOREVER_PROJECT_ID)"; exit 1 ;;^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3923018Z ^[[36;1m  *) echo "::error::CurseForge upload failed (HTTP $code), see the response above"; exit 1 ;;^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3923962Z ^[[36;1mesac^[[0m
upload	Upload to CurseForge	2026-11-24T18:41:15.3957567Z shell: /usr/bin/bash -e {0}
upload	Upload to CurseForge	2026-11-24T18:41:15.3958160Z env:
upload	Upload to CurseForge	2026-11-24T18:41:15.3958773Z   CF_API_KEY: ***
upload	Upload to CurseForge	2026-11-24T18:41:15.3959271Z   CF_PROJECT_ID: 1764059
upload	Upload to CurseForge	2026-11-24T18:41:15.3959791Z   CF_GAME_
```

### Log of run 45459278855 (last 60 lines)

```
upload	Upload to CurseForge	﻿2026-11-24T18:25:00.4065391Z ##[group]Run set -euo pipefail
upload	Upload to CurseForge	2026-11-24T18:25:00.4066992Z ^[[36;1mset -euo pipefail^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4069373Z ^[[36;1mtest -n "$CF_API_KEY" && test -n "$CF_PROJECT_ID" || { echo "CF_API_KEY / CF_FOREVER_PROJECT_ID missing"; exit 1; }^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4072942Z ^[[36;1mcurl -fsS -H "X-Api-Token: $CF_API_KEY" https://wow.curseforge.com/api/game/versions > versions.json^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4076849Z ^[[36;1mcurl -fsS -H "X-Api-Token: $CF_API_KEY" https://wow.curseforge.com/api/game/version-types > types.json^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4079381Z ^[[36;1mGV=$(python3 - <<'PY'^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4080721Z ^[[36;1mimport json, os, sys^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4082094Z ^[[36;1mvs = json.load(open("versions.json"))^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4083856Z ^[[36;1mts = json.load(open("types.json"))^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4085615Z ^[[36;1mwant = os.environ.get("CF_GAME_VERSION", "").strip()^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4087263Z ^[[36;1mif want:^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4088496Z ^[[36;1m    ok = [v for v in vs if v.get("name") == want]^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4090060Z ^[[36;1melse:^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4091579Z ^[[36;1m    slug = os.environ.get("CF_GAME_TYPE", "").strip() or "wow_classic"^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4093870Z ^[[36;1m    tids = [t["id"] for t in ts if t.get("slug") == slug]^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4095522Z ^[[36;1m    if not tids:^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4097752Z ^[[36;1m        sys.stderr.write("flavour '%s' not found; known: %s\n" % (slug, ", ".join(sorted(t.get("slug", "") for t in ts))))^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4101000Z ^[[36;1m    ok = sorted([v for v in vs if v.get("gameVersionTypeID") in tids], key=lambda v: v["id"])[-1:]^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4103668Z ^[[36;1mif ok:^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4105443Z ^[[36;1m    sys.stderr.write("game version: %s (id %s)\n" % (ok[0].get("name"), ok[0]["id"]))^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4107522Z ^[[36;1m    print(ok[0]["id"])^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4108761Z ^[[36;1mPY^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4109748Z ^[[36;1m)^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4111161Z ^[[36;1mtest -n "$GV" || { echo "no CurseForge game version found"; exit 1; }^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4113266Z ^[[36;1mcase "$TAG" in *-*) REL=beta ;; *) REL=release ;; esac^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4115289Z ^[[36;1mZIP=$(ls WoWFA-*.zip | head -n1)^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4120269Z ^[[36;1mMETA=$(GV="$GV" REL="$REL" python3 -c 'import json,os; print(json.dumps({"changelog": open("notes.md").read(), "changelogType": "markdown", "displayName": os.environ["TAG"], "gameVersions": [int(os.environ["GV"])], "releaseType": os.environ["REL"]}))')^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4127398Z ^[[36;1mcurl -fsS -H "X-Api-Token: $CF_API_KEY" \^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4130044Z ^[[36;1m  -F "metadata=$META" -F "file=@$ZIP" \^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4133097Z ^[[36;1m  "https://wow.curseforge.com/api/projects/$CF_PROJECT_ID/upload-file"^[[0m
upload	Upload to CurseForge	2026-11-24T18:25:00.4176230Z shell: /usr/bin/bash -e {0}
upload	Upload to CurseForge	2026-11-24T18:25:00.4177735Z env:
upload	Upload to CurseForge	2026-11-24T18:25:00.4179463Z   CF_API_KEY: ***
upload	Upload to CurseForge	2026-11-24T18:25:00.4180820Z   CF_PROJECT_ID: 
upload	Upload to CurseForge	2026-11-24T18:25:00.4182076Z   CF_GAME_VERSION: 
upload	Upload to CurseForge	2026-11-24T18:25:00.4183552Z   CF_GAME_TYPE: 
upload	Upload to CurseForge	2026-11-24T18:25:00.4184833Z   TAG: forever-v1.0.0-beta.2
upload	Upload to CurseForge	2026-11-24T18:25:00.4186172Z ##[endgroup]
upload	Upload to CurseForge	2026-11-24T18:25:00.4264732Z CF_API_KEY / CF_FOREVER_PROJECT_ID missing
upload	Upload to CurseForge	2026-11-24T18:25:00.4278886Z ##[error]Process completed with exit code 1.
```
- ok: read 2 runs
