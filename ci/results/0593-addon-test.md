## task 0593-addon-test (script)

**GREEN**


### step 1: dub_addon_data

- ok: tools/dub-addon/WoWFA_VoiceTest/Data.lua: 79145 bytes, sha256 ce06bd2289dbe5c5e09068a52e8711aa155b28bc513743053f72ab66fe99e523
- ok: 13 groups, 1322 creatures, 34 error kinds with a dub

### step 2: lua_check


### luac -p

- ok: tools/dub-addon/WoWFA_VoiceTest/Data.lua: syntax ok
- ok: tools/dub-addon/WoWFA_VoiceTest/Voice.lua: syntax ok
- ok: tools/dub-addon/test_voice.lua: syntax ok

### step 3: lua_run


### lua5.1 tools/dub-addon/test_voice.lua

- ok: ok: 13 dubbed groups (13)
- ok: ok: creatures mapped: 1322
- ok: ok: error voice data present
- login: |cfff0c75eWoWFA voice|r v0.4.0 loaded: 0 named NPC, 13 voice groups, 1322 creatures, 370 original sounds muted, model check on (/wfv) | |cfff0c75eWoWFA voice|r own voice (troll m): ON for this character, 24 error kinds
- ok: ok: UI_ERROR_MESSAGE registered
- ok: ok: own voice on for a male troll
- ok: ok: originals muted: 370
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
