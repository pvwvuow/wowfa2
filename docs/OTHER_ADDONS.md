# What other translation addons have (25 Nov 2026)

Checked: ForeverAR (Arabic, Forever, v0.5.21), UALL Forever (Ukrainian, v1.0.18), Forever WoWPoPolsku 2.0 (Polish, v0.6.1),
WoWTR (Turkish, Forever v26.1106), WOW-UKRAINE (Classic/Retail), Viet Craft (Vietnamese, alpha), WoWForeverIT (Italian, v0.9.15).
Second check (25 Nov, evening): Czech Forever 0.8.0, WoWFCzech (+4 voice packs), Azeroth cesky, ForeverPL 0.9.58, Forever Magyar Kronikak, WoW Forever Japanese 0.14.0.
Sources: their CurseForge pages/changelogs; PolishForever and WoWLang on GitHub. Hooks are mostly not published (inferred).

| # | Feature | Who has it | Effort | Value | WoWFA |
|---|---|---|---|---|---|
| 1 | NPC gossip / greeting dialogue + NPC speech bubbles and yells | ForeverAR, UALL, Polish, WoWTR, Ukraine, Viet | L (code + data) | very high | 1.0.7: code done (Modules/Dialog.lua), data fills from the harvest |
| 2 | Native quest log + objective tracker in Persian (not only our pane) | UALL, Polish, Ukraine, Italian | M | very high | tracker + log titles/objectives already; log detail text next |
| 3 | Item tooltips (names, stats, use/equip, flavour) | ForeverAR, UALL, Polish, WoWTR, Ukraine, Italian | M-L | very high | code exists (locked in v1.0), waits for the item bank |
| 4 | Books, letters, plaques (ItemText frame) | ForeverAR, UALL, WoWTR, Ukraine | M | high | 1.0.7: code done (Modules/Dialog.lua), data fills from the harvest |
| 5 | Untranslated capture/export with id + context | ForeverAR, Polish, Ukraine, Italian | M | very high | done: F:Miss (status page) + WoWFA_Harvest (q, n, x) + job harvest_read |
| 6 | Show English original on Shift | UALL (Shift), Polish, WoWTR (toggle), Japanese (Alt) | S-M | high | 1.0.7: done (General > Shift switch) |
| 7 | Questie / Immersion / DialogueUI integration | Polish, ForeverAR (Questie) | M each | high | next |
| 8 | Cinematic / intro subtitles | WoWTR, Polish, Ukraine, Magyar | M | high (story) | later |
| 9 | Tutorials / help tips | WoWTR, Ukraine | S-M | medium | later |
| 10 | Broad UI frames (character, bags, mail, AH, group finder, guild) | UALL, ForeverAR, Polish, Ukraine, Italian, Czech Forever (13,000 UI texts), Japanese (16,115 UI) | L | high | later |
| 11 | Factions, achievements, PvP ranks | UALL, ForeverAR | M-L | medium | later |
| 12 | Presets, minimap menu, auto-pause in combat or raids | ForeverAR, Ukraine | S-M | medium | presets + minimap exist |
| 13 | Translated guide steps (RestedXP) | ForeverAR | M-L | high for guide users | later |
| 14 | Voice-over / TTS | UALL voice pack, Polish + Spoken, Czech Forever (30,000 lines), WoWFCzech, Japanese | L | high but costly | no |
| 15 | Quest title mode: native / English / both | Czech Forever, Azeroth cesky | S | medium | open: check the title setting |
| 16 | Objective counters translated (x/y lines) | ForeverPL, Czech Forever | S-M | high | open: tracker count lines come with the next harvest |
| 17 | Per-group name switches (places, mobs, items, factions) | ForeverPL, Czech Forever | S | medium | check against the owner spec of 23 Nov |
| 18 | Per-part on/off switches (quests, dialogue, books, UI ...) | UALL, Azeroth cesky, ForeverPL | S | medium | check |
| 19 | Gender forms and name declension | ForeverPL, WoWFCzech | M | n/a | not needed: Persian has no grammatical gender |
| 20 | Creature model previews | ForeverPL | M | low | no |

## Volumes (what they claim)

| Addon | Quests | NPC lines | Books | Items | Spells | UI |
|---|---|---|---|---|---|---|
| WoW Forever Japanese | 4,805 | 11,214 | 923 + 209 letters | 9,282 | 20,340 | 16,115 |
| UALL Forever | 640,000 words | yes | yes | yes | yes | yes (108,000 texts all together) |
| Czech Forever | yes | yes | 1,000+ pages | 11,000 spell/talent/aura/item | | 13,000 (23,000 texts) |

WoWFA now (build 71091): quests 5,343, talk/speech/description templates 1,788, NPC names 10,398, zones 1,584, spells 1,277.
The biggest gaps are the NPC talk lines (only what the harvest brought) and item tooltips.

## The update loop (never miss a game change)

1. The addon keeps every English text it could not translate: the status page report line (F:Miss) and
   WTF/Account/<acc>/SavedVariables/WoWFA.lua (WoWFA_Harvest: q quests, n NPC names, x talk/speech/books).
2. The owner sends that file; it is pushed to ci/inbox/WoWFA.lua and job `harvest_read` turns it into
   ci/results/harvest-<build>.json (only English game text; the file is deleted from the inbox).
3. The rows are translated (meaning-first Persian, markers) and added: talk/books as tpl rows
   (key = the harvested key, lower case, a last dot dropped, so "..." ends with ".."), quests with job add_quest_texts, names with add_names.
4. A new game build: `raw_fetch_now` + `raw_changes` show what changed; reworded texts stop matching and
   show up in step 1 by themselves.
