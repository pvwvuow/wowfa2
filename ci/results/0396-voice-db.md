## task 0396-voice-db (script)

**RED**


### Base list

- ok: 58507 files in 2398 groups

### Client tables

wowf: 1.60.1.71139
wow_classic_era: 1.15.9.70576
- ok: CreatureDisplayInfo: 14228 rows (1.60.1.71139)
- ok: NPCSounds: 202 rows (1.60.1.71139)
- ok: SoundKitEntry: 91847 rows (1.60.1.71139)
BroadcastText 1.15.9.70576: HTTPError
- ok: BroadcastText: 10888 rows (latest retail)
- ok: BroadcastText: 10888 rows (latest retail)
broadcast columns: Text_lang Text1_lang ['SoundKitID_0', 'SoundKitID_1']
- FAIL: cannot read the CMaNGOS dump: HTTP Error 403: rate limit exceeded
- ok: texts: 7 from BroadcastText, 0 from CMaNGOS
- ok: 200 voice sets, 6016 displays with a voice, 7 files with a spoken text

### Missing files (listfile)

- ok: added 9671 files (255 new groups); 637 skipped because their folder name is shared by two groups

### Texts

- ok: 7 files have their spoken text, 0 with Persian

### Creatures

- ok: 0 creatures linked to 0 groups

### Thumbnails

https://wow.zamimg.com/modelviewer/classic/webthumbs/npc/{m}/{d}.webp: 0 of 0
https://wow.zamimg.com/modelviewer/classic/webthumbs/npc/{m}/{d}.png: 0 of 0
https://wow.zamimg.com/modelviewer/live/webthumbs/npc/{m}/{d}.webp: 0 of 0
https://wow.zamimg.com/modelviewer/live/webthumbs/npc/{m}/{d}.png: 0 of 0
- ok: thumbnail url: none worked

### Result

- ok: tools/dub-studio/voice_db.js: 3376247 bytes, 68178 files (+9671), 2653 groups (+255), 7 texts, 0 groups with creatures
