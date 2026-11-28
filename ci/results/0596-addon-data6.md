## task 0596-addon-data6 (script)

**GREEN**


### step 1: voice_addon


### Studio groups

- ok: 16 of 16 groups found, 353 lines

### Client build

- ok: CreatureDisplayInfo: 14228 rows (build 1.60.1.71139)
- ok: CreatureModelData: 1198 rows (build 1.60.1.71139)
- ok: NPCSounds: 202 rows (build 1.60.1.71139)
- ok: SoundKitEntry: 91847 rows (build 1.60.1.71139)
columns: display ID/NPCSoundID/ModelID, model ID/FileDataID
- ok: 200 voice sets (30 hold a dubbed file), 6016 displays with a voice, 1198 model files
- ok: model files that use a dubbed voice set: 20
- ok: voice sets on dubbed models that nobody dubbed: 43

### Creatures

vendor flag column: npcflags
- ok: 1322 creatures use a dubbed voice set on at least one model
| model file id | sets |
|---|---|
| 119369 | 110 |
| 119376 | 64/65/66/106/108/109/110 |
| 120791 | 44 |
| 123345 | 66 |
| 124224 | 66 |
| 124225 | 66 |
| 124516 | 50 |
| 124521 | 50 |
| 124533 | 50 |
| 124738 | 64 |
| 197330 | 37 |
| 878772 | 36/37/38/50/98/99/100/155/156 |
| 900914 | 42/43/44/104/105/106/159 |
| 917116 | 110 |
| 959310 | 50 |
| 968705 | 110 |
| 1000764 | 49/50 |
| 1011653 | 38/44/49/50/115/116/155 |
| 1022938 | 77/78/110/139/140 |
| 1890761 | 49 |

### Voice sets per group

| group | game voice sets |
|---|---|
| Dwarfmalegrimnpc | 36,98,155,156 |
| Dwarfmaleguardnpc | 37,99 |
| Dwarfmalestandardnpc | 38,100 |
| Gnomemalestandardnpc | 42,104 |
| Gnomemaleyoungnpc | 43,105 |
| Gnomemalezanynpc | 44,106,159,160 |
| Goblinmalegruffnpc | 64,108 |
| Goblinmaleguardnpc | 65,109 |
| Goblinmalezanynpc | 66,110 |
| Humanmalestandardnpc | 49,115 |
| Humanmalewarriornpc | 50,116 |
| Trollmaleshamannpc | 77,139 |
| Trollmalestandardnpc | 78,140 |

### Vendor voices

| voice set | group | vendors | other creatures |
|---|---|---|---|
| 64 | Goblinmalegruffnpc | 0 | 45 |
| 65 | Goblinmaleguardnpc | 0 | 22 |
| 66 | Goblinmalezanynpc | 1 | 60 |
| 108 | Goblinmalegruffnpc | 0 | 17 |
| 109 | Goblinmaleguardnpc | 1 | 12 |
| 110 | Goblinmalezanynpc | 1 | 36 |
- ok: 54 vendor creatures in the CMaNGOS data
- ok: 372 more original sounds of voice sets on dubbed models (muted too)

### Model voices

model 119376: Goblinmalegruffnpc,Goblinmaleguardnpc,Goblinmalezanynpc only (not Gnomemalezanynpc)
model 878772: Dwarfmalegrimnpc,Dwarfmaleguardnpc,Dwarfmalestandardnpc only (not Humanmalewarriornpc)
model 1011653: Humanmalestandardnpc,Humanmalewarriornpc only (not Dwarfmalegrimnpc,Dwarfmalestandardnpc,Gnomemalezanynpc)
model 1022938: Trollmaleshamannpc,Trollmalestandardnpc only (not Goblinmalezanynpc)
- ok: creatures: 1166 single-voice, 156 with several models

### step 2: dub_addon_data

- ok: tools/dub-addon/WoWFA_VoiceTest/Data.lua: 82017 bytes, sha256 b1eb7d83af01b81aef0b5877a9d6dd4c5975cafbe1d521930522aec85eca3923
- ok: 13 groups, 1322 creatures, 34 error kinds with a dub

### step 3: lua_check


### luac -p

- ok: tools/dub-addon/WoWFA_VoiceTest/Data.lua: syntax ok
- ok: tools/dub-addon/WoWFA_VoiceTest/Voice.lua: syntax ok
- ok: tools/dub-addon/test_voice.lua: syntax ok

### step 4: lua_run


### lua5.1 tools/dub-addon/test_voice.lua

- ok: ok: 13 dubbed groups (13)
- ok: ok: creatures mapped: 1322
- ok: ok: error voice data present
- login: |cfff0c75eWoWFA voice|r v0.4.1 loaded: 0 named NPC, 13 voice groups, 1322 creatures, 742 original sounds muted, model check on (/wfv) | |cfff0c75eWoWFA voice|r own voice (troll m): ON for this character, 24 error kinds
- ok: ok: UI_ERROR_MESSAGE registered
- ok: ok: own voice on for a male troll
- ok: ok: originals muted: 742
- ok: ok: Not enough mana. -> nomana Interface\AddOns\WoWFA_VoiceTest\voice\543208.ogg
- ok: ok: Not enough rage. -> norage Interface\AddOns\WoWFA_VoiceTest\voice\543195.ogg
- ok: ok: Out of range. -> outofrange Interface\AddOns\WoWFA_VoiceTest\voice\543222.ogg
- ok: ok: You are too far away to loot that corpse. -> loottoofar Interface\AddOns\WoWFA_VoiceTest\voice\543193.ogg
- ok: ok: Inventory is full. -> inventoryfull Interface\AddOns\WoWFA_VoiceTest\voice\543215.ogg
- ok: ok: Spell is not ready yet. -> spellcooldown Interface\AddOns\WoWFA_VoiceTest\voice\543166.ogg
- ok: ok: You have no target. -> genericnotarget Interface\AddOns\WoWFA_VoiceTest\voice\543190.ogg
- ok: ok: Not enough money. -> notenoughmoney Interface\AddOns\WoWFA_VoiceTest\voice\543212.ogg
- ok: ok: unrelated error plays nothing
- ok: ok: same error twice in a second plays once
- ok: ok: text as the only argument
- ok: ok: greeting plays for a dwarf NPC: Interface\AddOns\WoWFA_VoiceTest\voice\547870.ogg
- ok: ok: own voice off for a human
- ok: ok: no error voice for a human
- ALL OK
