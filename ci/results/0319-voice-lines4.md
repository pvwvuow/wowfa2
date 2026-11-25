## task 0319-voice-lines4 (script)

**GREEN**


### Source

- ok: ClassicDB_1_12_1_z2815.sql.gz
text-like tables: broadcast_text, broadcast_text_locale, creature_ai_texts, custom_texts, dbscript_string, dbscripts_on_gossip, gossip_menu, gossip_menu_option, gossip_texts, locales_gossip_menu_option, locales_npc_text, locales_page_text, npc_gossip, npc_text, npc_text_broadcast_text, page_text, script_texts
- ok: npc_text 2446 rows, gossip_menu 3856, creature_template 10384 (gossip column: gossipmenuid)
- ok: script_texts: 1523 rows, text columns ['content_default']
- ok: dbscript_string: 0 rows, text columns ['content_default']
- ok: custom_texts: 0 rows, text columns ['content_default']
- ok: creature_ai_texts: 0 rows, text columns ['content_default']
- ok: broadcast_text: 11104 rows, text columns ['text', 'text1']

### Result

- ok: 13184 lines, 26 already have Persian
| source | lines |
|---|---|
| broadcast_text | 9043 |
| gossip | 2688 |
| script_texts | 1453 |
