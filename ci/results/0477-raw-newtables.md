## task 0477-raw-newtables (script)

**GREEN**


### clone

`git clone -q --depth` -> 0
```

```

### fetch auto

`python3 tools/rawfetch.py fetch --product` -> 0
```
forever 1.60.1.71139 official=1.60.1.71139 changed=True tag=forever-1.60.1.71139-h20261127T120721Z
tables 116, absent 14, rows 427995, zip dist/forever-1.60.1.71139-h20261127T120721Z.zip
```
- ok: outputs: {'ready': 'true', 'build': '1.60.1.71139', 'official': '1.60.1.71139', 'tag': 'forever-1.60.1.71139-h20261127T120721Z', 'changed': 'true', 'zip': 'dist/forever-1.60.1.71139-h20261127T120721Z.zip'}

### notes

`python3 tools/changes_text.py --product forever` -> 0
```
notes: /tmp/tmpv8j8i9ux/wow-raw/manifests/forever/notes/1.60.1.71139.md (197 lines)
```

### change report 1.60.1.71139 (3484 chars)

# forever 1.60.1.71139 vs 1.60.1.71091

Row-level diff of the raw client tables (generated 2026-11-26T04:43:15Z).

| table | added | removed | changed rows |
|---|---|---|---|
| Achievement | 0 | 0 | 2 |
| CurvePoint | 0 | 0 | 5 |
| Item | 1 | 0 | 4 |
| ItemEffect | 0 | 0 | 6 |
| ItemLimitCategory | 1 | 0 | 0 |
| ItemSparse | 2 | 0 | 82 |
| SkillLineAbility | 1 | 0 | 6 |
| Spell | 0 | 0 | 4 |
| SpellAuraOptions | 0 | 7 | 0 |
| SpellClassOptions | 0 | 7 | 0 |
| SpellDuration | 1 | 0 | 0 |
| SpellEffect | 3 | 0 | 23 |
| SpellInterrupts | 0 | 15 | 3 |
| SpellMisc | 0 | 0 | 67 |
| SpellName | 0 | 0 | 3 |

## Achievement: first changed rows

- ID 62054: Criteria_tree 221563 -> 238156
- ID 64014: Criteria_tree 234126 -> 238175

## CurvePoint: first changed rows

- ID 295686: Pos_1 -8 -> 8
- ID 295687: Pos_1 -16 -> 16
- ID 295688: Pos_1 -24 -> 24
- ID 295689: Pos_1 -32 -> 32
- ID 295690: Pos_1 -40 -> 40

## Item: first changed rows

- ID 278487: IconFileDataID 666950 -> 1045105; ItemGroupSoundsID 13 -> 24
- ID 278917: IconFileDataID 134884 -> 7699043
- ID 278956: IconFileDataID 132744 -> 132743
- ID 278973: IconFileDataID 0 -> 132639

## ItemEffect: first changed rows

- ID 97630: SpellID 1248377 -> 1248381
- ID 97789: SpellID 5006 -> 1248386
- ID 97827: SpellID 434 -> 1248381
- ID 97850: SpellID 433 -> 1248377
- ID 100343: SpellID 1129 -> 1248394

## ItemSparse: first changed rows

- ID 2892: Bonding 0 -> 1; SellPrice 30 -> 0
- ID 2893: Bonding 0 -> 1; SellPrice 55 -> 0
- ID 3775: Bonding 0 -> 1; SellPrice 13 -> 0
- ID 3776: Bonding 0 -> 1; SellPrice 175 -> 0
- ID 4632: Flags_2 0 -> 131072

## SkillLineAbility: first changed rows

- ID 3962: TradeSkillCategoryID 2632 -> 2640
- ID 3963: TradeSkillCategoryID 2632 -> 2640
- ID 3964: TradeSkillCategoryID 2632 -> 2640
- ID 4204: TradeSkillCategoryID 2632 -> 2640
- ID 11740: TradeSkillCategoryID 2632 -> 2640

## Spell: first changed rows

- ID 16914: Description_lang Creates a violent storm in the target area causing $1278965s -> Creates a violent storm in the target area causing $1278965s
- ID 17401: Description_lang Creates a violent storm in the target area causing $1278968s -> Creates a violent storm in the target area causing $1278968s
- ID 17402: Description_lang Creates a violent storm in the target area causing $1278759s -> Creates a violent storm in the target area causing $1278759s
- ID 1300180: Description_lang Stealth to sneak around, but reduce your movement speed by $ -> Stealth to sneak around, but reduce your movement speed by $

## SpellEffect: first changed rows

- ID 684163: ImplicitTarget_0 6 -> 25
- ID 692746: EffectAura 80 -> 4; EffectMiscValue_0 3 -> 0
- ID 693406: ImplicitTarget_0 1 -> 27
- ID 696517: EffectAura 101 -> 4; EffectMiscValue_0 1 -> 0
- ID 696766: EffectAura 79 -> 4; EffectMiscValue_0 127 -> 0

## SpellInterrupts: first changed rows

- ID 129136: AuraInterruptFlags_0 4194304 -> 0
- ID 129156: AuraInterruptFlags_0 4194304 -> 0
- ID 246865: AuraInterruptFlags_0 268435456 -> 268435460

## SpellMisc: first changed rows

- ID 315567: Attributes_5 0 -> 2
- ID 315867: Attributes_5 0 -> 2
- ID 316115: Attributes_5 0 -> 2
- ID 316273: Attributes_5 0 -> 2
- ID 316807: Attributes_5 0 -> 2

## SpellName: first changed rows

- ID 1308764: Name_lang Might of Bedrock -> Pauldrons of Shattered Summits
- ID 1309241: Name_lang Legwraps of Suspended Time -> Legwraps of Gathering Flame
- ID 1309243: Name_lang Legwraps of Suspended Time -> Legwraps of Gathering Flame


### publish

`gh release create forever-1.60.1.71139-h20261127T120721Z` -> 0
```
https://github.com/pvwvuow/wow-raw/releases/tag/forever-1.60.1.71139-h20261127T120721Z
```
`git -c user.name=wowfarsi-bot -c` -> 0
```

```
`git -c user.name=wowfarsi-bot -c` -> 0
```

```
`git push -q origin` -> 0
```

```
- ok: captured forever-1.60.1.71139-h20261127T120721Z into wow-raw
