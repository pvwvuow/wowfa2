## task 0001-migrate (migrate)

**GREEN**


### Sources

| input | commit |
|---|---|
| wowfa (quests, names) | bb1f7a9ba8b43cefb5d8df87d870231f3197cd11 |
| wowfa (templates) | 63d4fa8b875780ecb2f5dbb17ec300390015444b |
| wow (EN titles) | 62f85ce3a78a855eb836536f19dd0ec2468963ef |
- old meta (quests side): `{"a16_already": 0, "a16_applied": 4257, "a16_notfound": 4, "a16_variants": 4261, "item_lines": 109296, "item_lines_keyed": 109296, "items": 23247, "names_boss": 31, "names_class": 19, "names_it": 20562, "names_itn": 0, "names_itn_from_quests": 1744, "names_npc": 10251, "names_obj": 141, "names_set": 67, "names_spell": 1107, "names_spell_site": 592, "names_tree": 8, "names_zone": 1178, "qobj": 4015, "questEN": 4244, "quests": 5189, "setb_client_variants": 20, "site_conflict": 0, "site_disagreement": 1, "tpl": 791, "tpl_pack": 517, "tpl_pack_bad": 0, "tpl_pack_over_shared": 21, "truth_absent": 3, "truth_changed": 4437, "truth_hidden": 950, "znDropped": 2, "znOverrides": 42}`
- old meta (templates side): tpl rows in file = 1639, tpl_site = 585

### Migration

- quests 5189, templates 1639, name rows zone 1178, spell 1108, class 19, tree 8, npc 10251, boss 31, obj 141, itn 0, it 20562, set 67
- quests without an English title (no tracker hash): 3
- name rows filled from markers (one Persian everywhere): 1
- kinds not migrated: none
- markers whose Persian now comes from the table (old marker text differed): 53 distinct, 1372 uses
<details><summary>marker swaps (kind, key, old marker Persian -> table Persian, uses)</summary>

- zone `eastern plaguelands`: طاعون‌زار شرقی -> اراضی طاعون‌زدهٔ شرقی (490)
- zone `ahn'qiraj`: آن‌کیراج -> آن‌قیراج (218)
- zone `moonglade`: بیشهٔ مهتابی -> مون‌گلید (117)
- zone `stratholme`: استراتهولم -> استرات‌هولم (81)
- zone `badlands`: بیابان -> بدلندز (80)
- zone `naxxramas`: ناکس‌راماس -> نکس‌راماس (79)
- zone `gnomeregan`: گنومریگان -> گنومرگان (75)
- zone `dire maul`: دایر مول -> ماول مخوف (67)
- zone `maraudon`: ماراودون -> مارادون (23)
- zone `blackfathom deeps`: ژرفای سیاه‌ژرف -> اعماق سیاه‌ژرف (18)
- zone `ragefire chasm`: شکاف آتش‌خشم -> شکاف ریج‌فایر (13)
- spell `judgement`: داوری مقدس -> داوری (13)
- zone `razorfen kraul`: کرال ریزرفن -> ریزورفن کرال (11)
- zone `razorfen downs`: تپه‌های ریزرفن -> تپه‌های ریزورفن (11)
- zone `arathi basin`: حوضهٔ آراتی -> حوضهٔ آراثی (11)
- zone `shadowfang keep`: دژ نیش‌سایه -> دژ شادوفنگ (8)
- spell `bane of agony`: بلای رنج -> نفرین رنج (6)
- zone `ironforge`: آیرون‌فورج -> ایرون‌فورج (4)
- spell `stealth`: پنهان‌کاری -> مخفی‌کاری (3)
- spell `arcane blast`: ضربهٔ اسرار -> انفجار اسرار (3)
- spell `eviscerate`: شکم‌دران -> احشاء‌بری (3)
- spell `smite`: ضربهٔ مقدس -> کوبش الهی (3)
- spell `lava burst`: فوران گدازهٔ -> فوران گدازه (2)
- spell `scorch`: سوزاندن -> برشته‌کردن (2)
- spell `berserker rage`: خشم بربرانه -> خشم برسرکر (2)
- spell `mongoose bite`: گاز مانگوس -> گاز راسو (2)
- zone `ruins of ahn'qiraj`: ویرانه‌های آن‌کیراج -> ویرانه‌های آن‌قیراج (1)
- zone `east plaguelands`: طاعون‌زار شرقی -> طاعون زار شرقی (1)
- spell `thunderclap`: کوبش آذرخش -> تندرکوب (1)
- spell `blink`: برق‌پا -> جهش آنی (1)
- spell `nature's grasp`: چنگ طبیعت -> چنگال طبیعت (1)
- spell `hurricane`: گردباد -> طوفان (1)
- spell `bane of havoc`: بلای آشوب -> نفرین آشوب (1)
- spell `shield block`: بلوک سپر -> سد سپر (1)
- spell `flamestrike`: ضربهٔ شعلهٔ -> ضربهٔ شعله (1)
- spell `cower`: زاری گربه -> کزکردن (1)
- spell `flash heal`: شفای سریع -> شفای فوری (1)
- spell `gift of the wild`: موهبت وحش -> موهبت طبیعت (1)
- spell `mongoose bite`: گاز خدنگ -> گاز راسو (1)
- spell `tainted blood`: خون آلودهٔ -> خون آلوده (1)
- spell `bane of doom`: بلای نابودی -> نفرین نابودی (1)
- spell `fire nova`: موج آتش -> فوران آتش (1)
- spell `pyroblast`: انفجار آتشین -> گلولهٔ آتشین (1)
- spell `reincarnation`: بازگشت به زندگی -> تناسخ (1)
- spell `thunder clap`: کوبش آذرخش -> کوبش تندر (1)
- spell `sentry totem`: توتم دیده‌بانِ -> توتم دیده‌بان (1)
- spell `ghost wolf`: گرگ شبح -> گرگ سایه (1)
- spell `enrage`: خشم‌افروزی -> خشم‌گرفتن (1)
- spell `ferocious bite`: گاز درنده -> گازگرفتن درنده (1)
- spell `penance`: توبه -> کفاره (1)
- spell `mind flay`: شلاق ذهنِ -> شلاق ذهن (1)
- spell `penance`: توبهٔ -> کفاره (1)
- spell `starfire`: آتش ستارهٔ -> آتش ستاره (1)

</details>

### Round-trip proof (v0 Data vs new build, both read by real Lua)

| check | count |
|---|---|
| missing | 0 |
| qobj_diff | 0 |
| qobj_same | 4015 |
| quests_diff | 0 |
| quests_same | 5189 |
| tpl_diff | 0 |
| tpl_same | 1639 |
- ok: every quest, objective and template is byte-equal (after table names)

### Lint on the migrated data

- errors: 8
  - banned q:742:obj: banned string 'اسپیل'
  - banned q:742:det: banned string 'اسپیل'
  - banned q:742:o1: banned string 'اسپیل'
  - banned tpl:counters the enemy's spellcast, preventing any spell from th: banned string 'اسپیل'
  - banned tpl:creates a violent storm in the target area causing # nature : banned string 'اسپیل'
  - marker tpl:increases the damage done or health drained by your drain li: broken marker syntax
  - banned tpl:subjugates the target demon, up to level #, forcing it to do: banned string 'اسپیل'
  - banned tpl:use: immerse a weapon with poison for # min. each attack has: banned string 'اسپیل'
- ratchet now (put these in policy.json): `{"latin_in_fa": 518, "name_pairs_spell": 43, "name_pairs_zone": 9, "slot_unused": 17, "unit_word": 5}`
- floors now (put these in policy.json): `{"names.boss": 31, "names.class": 19, "names.it": 20562, "names.itn": 0, "names.npc": 10251, "names.obj": 141, "names.set": 67, "names.spell": 1108, "names.tree": 8, "names.zone": 1178, "quests": 5189, "quests_with_title": 5189, "tpl": 1639, "ui": 0}`
