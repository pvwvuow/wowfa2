# WoWFA v1 architecture (Brain, 22 Nov 2026)

Why a new repo: the v0 system (wowfa + wow + wowfa-packs + wow-ops + a self-hosted Z runner) stored
the same Persian string in up to 12 places, needed a human-like agent (Z) to run builds, and lost data
silently (wowfa #245 dropped ~585 spell tooltips and still merged). Z is gone. v1 has two actors:
**Brain** (edits small files through the GitHub API, cannot run CI locally) and **GitHub Actions**
(runs everything heavy). The owner only tests in game and presses Publish.

## The five rules
1. **One source of truth: `data/`.** Every Persian string lives in exactly one file. Generated Lua is
   never committed; it exists only in CI output and the release zip.
2. **Names are referenced, not copied.** Text says `{{sp:Frostbolt}}`; the build takes the Persian from
   `data/names/spell/`. Renaming a spell is one line, and every quest/tooltip follows. A full marker
   `{{sp:EN|FA}}` is an explicit exception and is counted.
3. **Nothing disappears silently.** `policy.json` has a floor per table; the build fails if a table
   shrinks below it. Known debt is a *ratchet*: it is counted on every run and may only go down.
4. **Workflows are dumb.** `.github/workflows/*.yml` only call `python3 tools/ci.py ...`. All logic is
   in the repo, so a change never needs the owner (Brain cannot write `.github/`).
5. **Every result is a readable report.** CI comments its report on the PR; a task opens a PR whose
   body is its report. Merge only on a finished GREEN report.

## Layout
```
policy.json              version, interface, game build, shipped surfaces/name kinds, floors, ratchet
data/                    THE source of truth (UTF-8 JSON, one entry per line)
  quests/qNNNN.json      {"<id>": {"h": title hash, "t","obj","det","pro","com","desc": Persian, "o": [objective lines]}}
  names/<kind>/<a-z|_>.json   {"<name_key(EN)>": "Persian"}   kinds: zone spell class tree npc boss obj itn it set
  tpl/<a-z|_>.json       {"<normalised EN tooltip line, numbers as #>": "Persian with {0} {1}"}
  ui/strings.json        panel / welcome / toast Persian
  terms.json             term locks + banned strings (lint input)
addon/WoWFA/             hand-written runtime Lua only (+ WoWFA.toc.in, Fonts, Media)
tools/ci.py              the only entry point: ci | check | build | tasks
tools/wfa/               store (load/save), lint (all gates), resolve (markers), build, migrate, tasks
tools/lua/dump_old.lua   reads Lua data with the real Lua parser (migration + round-trip proof)
tests/py/                tool tests          tests/run.lua + tests/lua/   addon tests on a WoW mock
ci/workflows/            the exact copies of .github/workflows (owner pastes them once)
ci/tasks/<id>.json       orders for the tasks workflow (migrate, release, ...)
ci/results/<id>.md       a task's report (also its PR body)
docs/                    this file, OWNER_SETUP.md, RULES.md
```

## Flows
- **Edit Persian**: Brain changes the one row in `data/` on a branch, opens a PR, CI comments
  GREEN/RED, Brain merges on GREEN.
- **Heavy job** (migration, new game build import, release): Brain adds `ci/tasks/<id>.json` on main;
  the tasks workflow runs it with the bot token and opens PR `task/<id>` with the report.
- **Release**: task kind `release` builds from main and creates a DRAFT pre-release in the public
  `pvwvuow/wowfarsi-addon` (the existing download page and CurseForge source). The owner publishes.

## Runtime (v1.0 scope: quests, quest tracker, zone names, spellbook + tooltips, talents)
Ported from v0 where it was proven (Shape.lua byte-identical; Text/Quests/Tracker/Spells trimmed),
dropped where it was dev-only (Capture, Watch, Debug, Room profiles, 95 KB Panel). Items, NPC names,
dungeons stay off (their data is kept in `data/names` for v1.1 but not shipped). Zone names get their
own module (v0 hid them behind the `dungeons` lock, so they never showed).
Generated Data: `Meta.lua`, `Names.lua` (shipped kinds only), `Quests.lua` (`D.quests` 7-field
records, `\031` separated, field 1 = title hash for the tracker index; `D.qobj`), `Tpl.lua` (`D.tpl`),
`Strings.lua` (`D.ui`).

## Failure classes and the gate that stops each
| Class (seen in v0) | Gate |
|---|---|
| Data silently dropped by a rebuild (#245, tpl_site) | floors in policy.json; Meta counts written from what was really emitted |
| Same name spelled 4 ways (Warsong) | names referenced by marker, one row; `name_pairs_<kind>` ratchet |
| U+FFFD / BOM / RLM / U+2011 hyphen in text | `chars` gate (error) |
| Uppercase colour escape printed as text | `colour` gate (error) |
| Banned spelling (اسپیل) | `banned` gate from data/terms.json |
| Broken or unknown marker | `marker` gate (error); unresolved short marker = ratchet |
| Tooltip number slot out of range / number never shown | `slot` (error) / `slot_unused` (ratchet) |
| Duration number without its unit word | `unit_word` ratchet |
| English leaking into Persian | `latin_in_fa` ratchet |
| Generated Lua does not load | luac on every generated file; addon tests on the mock land with the port |
| Glyph missing from Vazirmatn (boxes in game) | glyph gate on the shipped strings (fontTools), lands with the addon port |
| Migration changed text unnoticed | round-trip proof: v0 Data and new build both read by real Lua, compared byte by byte |
| Runner vanished / CI never ran | GitHub-hosted runners only; Brain merges only with a finished report |
| Token leaked into logs/repo | token only in the `WOWFA_BOT_TOKEN` secret; auth header never printed |
| Python `"\031"` is octal 25, not 31 | separators written as `\x1f`; a test pins the Lua escape |
