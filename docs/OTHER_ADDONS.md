# What other translation addons have (25 Nov 2026)

Checked: ForeverAR (Arabic, Forever, v0.5.21), UALL Forever (Ukrainian, v1.0.18), Forever WoWPoPolsku 2.0 (Polish, v0.6.1),
WoWTR (Turkish, Forever v26.1106), WOW-UKRAINE (Classic/Retail), Viet Craft (Vietnamese, alpha), WoWForeverIT (Italian, v0.9.15).
Sources: their CurseForge pages/changelogs; PolishForever and WoWLang on GitHub. Hooks are mostly not published (inferred).

| # | Feature | Who has it | Effort | Value | WoWFA |
|---|---|---|---|---|---|
| 1 | NPC gossip / greeting dialogue + NPC speech bubbles and yells | ForeverAR, UALL, Polish, WoWTR, Ukraine, Viet | L (code + data) | very high | 1.0.7: code done (Modules/Dialog.lua), data fills from the harvest |
| 2 | Native quest log + objective tracker in Persian (not only our pane) | UALL, Polish, Ukraine, Italian | M | very high | tracker + log titles/objectives already; log detail text next |
| 3 | Item tooltips (names, stats, use/equip, flavour) | ForeverAR, UALL, Polish, WoWTR, Ukraine, Italian | M-L | very high | code exists (locked in v1.0), waits for the item bank |
| 4 | Books, letters, plaques (ItemText frame) | ForeverAR, UALL, WoWTR, Ukraine | M | high | 1.0.7: code done (Modules/Dialog.lua), data fills from the harvest |
| 5 | Untranslated capture/export with id + context | ForeverAR, Polish, Ukraine, Italian | M | very high | done: F:Miss (status page) + WoWFA_Harvest (q, n, x) + job harvest_read |
| 6 | Show English original on Shift | UALL (Shift), Polish, WoWTR (toggle) | S-M | high | 1.0.7: done (General > Shift switch) |
| 7 | Questie / Immersion / DialogueUI integration | Polish, ForeverAR (Questie) | M each | high | next |
| 8 | Cinematic / intro subtitles | WoWTR, Polish, Ukraine | M | high (story) | later |
| 9 | Tutorials / help tips | WoWTR, Ukraine | S-M | medium | later |
| 10 | Broad UI frames (character, bags, mail, AH, group finder, guild) | UALL, ForeverAR, Polish, Ukraine, Italian | L | high | later |
| 11 | Factions, achievements, PvP ranks | UALL, ForeverAR | M-L | medium | later |
| 12 | Presets, minimap menu, auto-pause in combat or raids | ForeverAR, Ukraine | S-M | medium | presets + minimap exist |
| 13 | Translated guide steps (RestedXP) | ForeverAR | M-L | high for guide users | later |
| 14 | Voice-over / TTS | UALL voice pack, Polish + Spoken | L | high but costly | no |

## The update loop (never miss a game change)

1. The addon keeps every English text it could not translate: the status page report line (F:Miss) and
   WTF/Account/<acc>/SavedVariables/WoWFA.lua (WoWFA_Harvest: q quests, n NPC names, x talk/speech/books).
2. The owner sends that file; it is pushed to ci/inbox/WoWFA.lua and job `harvest_read` turns it into
   ci/results/harvest-<build>.json (only English game text; the file is deleted from the inbox).
3. The rows are translated (meaning-first Persian, markers) and added: talk/books as tpl rows
   (key = the harvested key), quests with the quest jobs, names with add_names.
4. A new game build: `raw_fetch_now` + `raw_changes` show what changed; reworded texts stop matching and
   show up in step 1 by themselves.
