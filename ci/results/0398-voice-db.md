## task 0398-voice-db (script)

**GREEN**


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
script_texts: 259 sound files got a text (columns ['sound'] / content_default)
creature_ai_texts: 0 sound files got a text (columns ['sound'] / content_default)
dbscript_string: 0 sound files got a text (columns ['sound'] / content_default)
custom_texts: 0 sound files got a text (columns ['sound'] / content_default)
broadcast_text: 64 sound files got a text (columns ['soundentriesid1', 'soundentriesid2'] / text)
- ok: texts: 7 from BroadcastText, 323 from CMaNGOS
- ok: 200 voice sets, 6016 displays with a voice, 330 files with a spoken text

### Missing files (listfile)

- ok: added 9671 files (255 new groups); 637 skipped because their folder name is shared by two groups

### Texts

- ok: 327 files have their spoken text, 0 with Persian

### Creatures

- ok: 4256 creatures linked to 271 groups

### Thumbnails

https://wow.zamimg.com/modelviewer/classic/webthumbs/npc/{m}/{d}.webp: 6 of 6
https://wow.zamimg.com/modelviewer/classic/webthumbs/npc/{m}/{d}.png: 6 of 6
https://wow.zamimg.com/modelviewer/live/webthumbs/npc/{m}/{d}.webp: 6 of 6
https://wow.zamimg.com/modelviewer/live/webthumbs/npc/{m}/{d}.png: 6 of 6
- ok: thumbnail url: https://wow.zamimg.com/modelviewer/classic/webthumbs/npc/{m}/{d}.webp

### Result

- ok: tools/dub-studio/voice_db.js: 3633141 bytes, 68178 files (+9671), 2653 groups (+255), 327 texts, 271 groups with creatures
