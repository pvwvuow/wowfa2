## task 0250-rawstatus (script)

**GREEN**


### wow-raw workflow runs

- fetch.yml: error HTTP 403: Resource not accessible by personal access token (https://api.github.com/repos/pvwvuow/wow-raw/actions/workflows/fetch.yml)
- hotfix-feed.yml: error HTTP 403: Resource not accessible by personal access token (https://api.github.com/repos/pvwvuow/wow-raw/actions/workflows/hotfix-feed.yml)
- fdb-fetch.yml: error HTTP 403: Resource not accessible by personal access token (https://api.github.com/repos/pvwvuow/wow-raw/actions/workflows/fdb-fetch.yml)

### runner

- repos/pvwvuow/wow-raw/actions/variables: gh: Resource not accessible by personal access token (HTTP 403)
- repos/pvwvuow/wow-raw/actions/runners: gh: Resource not accessible by personal access token (HTTP 403)
- repos/pvwvuow/wowfa2/actions/runners: gh: Resource not accessible by personal access token (HTTP 403)

### captured builds

manifests/index.json:
```
{
 "forever": {
  "1.60.1.70634": [
   {
    "digest": "f1fb032af56800f860dbc66b056d308d69575085f4f62be928b93d9463aeace3",
    "fetched_at": "2026-11-02T16:01:21Z",
    "rows": 308802,
    "tables": 69,
    "tag": "forever-1.60.1.70634"
   }
  ],
  "1.60.1.70707": [
   {
    "digest": "793e5783def2e119c6590241ab0acace73c3ccdd4584e277b7eb2e4d35e3624b",
    "fetched_at": "2026-11-02T16:04:45Z",
    "rows": 309335,
    "tables": 69,
    "tag": "forever-1.60.1.70707"
   }
  ],
  "1.60.1.70753": [
   {
    "digest": "4bf0819ff8c8c7fd0fad41f57304a0a71961e38244f9f39ae54321a01cfa6061",
    "fetched_at": "2026-11-03T01:02:15Z",
    "rows": 315114,
    "tables": 85,
    "tag": "forever-1.60.1.70753"
   }
  ],
  "1.60.1.70755": [
   {
    "digest": "4bf0819ff8c8c7fd0fad41f57304a0a71961e38244f9f39ae54321a01cfa6061",
    "fetched_at": "2026-11-03T23:27:15Z",
    "rows": 315114,
    "tables": 85,
    "tag": "forever-1.60.1.70755"
   }
  ],
  "1.60.1.70790": [
   {
    "digest": "cab402ad2f2d7d73af38587581816e26cb069cedf583e1e72fcb15ea7021e874",
    "fetched_at": "2026-11-04T18:42:45Z",
    "rows": 315253,
    "tables": 84,
    "tag": "forever-1.60.1.70790"
   },
   {
    "digest": "0d8737000c94c5088587cff1a57455d478b061a881afe2e8cfc7685d2fa2c339",
    "fetched_at": "2026-11-05T07:26:13Z",
    "rows": 396378,
    "tables": 108,
    "tag": "forever-1.60.1.70790-h20261105T072613Z"
   },
   {
    "digest": "a5f8a6b5eff713dc9c3f8acb65d1d5d1a67b05fb7fc2ccefe3e7e6b13996c9ef",
    "fetched_at": "2026-11-05T10:40:04Z",
    "rows": 396520,
    "tables": 109,
    "tag": "forever-1.60.1.70790-h20261105T104004Z"
   }
  ],
  "1.60.1.70840": [
   {
    "digest": "0937d48b215e833b322445f2cf19ad53a57e7736d9e3206121b1e47c1ec6e71c",
    "fetched_at": "2026-11-07T05:35:12Z",
    "rows": 398966,
    "tables": 109,
    "tag": "forever-1.60.1.70840"
   }
  ],
  "1.60.1.70862": [
   {
    "digest": "afbb1fb85b5acb751342fd810a752aa55dd0214bbd526eb6cf0ce89a9ed8735b",
    "fetched_at": "2026-11-07T09:32:42Z",
    "rows": 399024,
    "tables": 109,
    "tag": "forever-1.60.1.70862"
   }
  ],
  "1.60.1.70888": [
   {
    "digest": "41ebf5047d42896f7df721c9d4078b4e1c8f15dedb355ae16863ee585c2ea2bc",
    "fetched_at": "2026-11-11T14:19:35Z",
    "rows": 399150,
    "tables": 109,
    "tag": "forever-1.60.1.70888"
   }
  ],
  "1.60.1.70938": [
   {
    "digest": "6ffc92ea546bd964953bcadeedf36c482a09260ea01653fdd77766c3c8ed7457",
    "fetched_at": "2026-11-13T07:00:40Z",
    "rows": 399210,
    "tables"
```
tables/products.json:
```
{
 "v": 1,
 "_note": "What rawfetch.py archives per product (docs/DATA_PIPELINE.md D2 in pvwvuow/wow). wago = product id on wago.tools, ribbit = Blizzard version-server code. required = tables that must exist (missing = run fails, nothing published); optional = fetched when the product has them (a missing optional table is only recorded as absent). shrink_guard = max share of rows a table may lose against the previous build before the run fails. Forever talent trees are Trait* tables (TraitDefinition.SpellID -> TraitNodeEntry -> TraitNodeXTraitNodeEntry -> TraitNode PosX/PosY in TraitTree); Talent/TalentTab only hold the old Classic layout. Forever ItemEffect has no ParentItemID: the item -> effect link is ItemXItemEffect (ItemID, ItemEffectID). Stat numbers are computed by the client from RandPropPoints / ItemArmor* / ItemDamage* / Curve (wow-ops docs/DATA_TRUTH_PLAN.md W1d).",
 "products": {
  "forever": {
   "wago": "wowf",
   "ribbit": "wowf",
   "locale": "enUS",
   "shrink_guard": 0.2,
   "required": [
    "Achievement",
    "AreaTable",
    "ChrClasses",
    "ChrRaces",
    "Creature",
    "CurrencyTypes",
    "Emotes",
    "Faction",
    "Item",
    "ItemClass",
    "ItemEffect",
    "ItemSearchName",
    "ItemSet",
    "ItemSparse",
    "LfgDungeons",
    "Map",
    "QuestFactionReward",
    "QuestLine",
    "QuestLineXQuest",
    "QuestMoneyReward",
    "QuestSort",
    "QuestV2",
    "QuestXp",
    "SkillLine",
    "SkillLineAbility",
    "Spell",
    "SpellName",
    "Talent",
    "TalentTab"
   ],
   "optional": [
    "SpellEffect",
    "SpellMisc",
    "SpellDuration",
    "SpellRadius",
    "SpellRange",
    "SpellCastTimes",
    "SpellCooldowns",
    "SpellPower",
    "SpellAuraOptions",
    "SpellLevels",
    "SpellCategories",
    "SpellClassOptions",
    "SpellDescriptionVariables",
    "SpellXDescriptionVariables",
    "SpellTargetRestrictions",
    "SpellEquippedItems",
    "SpellInterrupts",
    "SpellAuraRestrictions",
    "SpellShapeshift",
    "SpellProcsPerMinute",
    "SpellReagents",
    "SpellTotems",
    "SpellItemEnchantment",
    "ItemSubClass",
    "ItemRandomProperties",
    "ItemRandomSuffix",
    "ItemExtendedCost",
    "CreatureFamily",
    "CreatureType",
    "FactionTemplate",
    "TaxiNodes",
    "TaxiPath",
    "WorldMapArea",
    "UiMap",
    "UiMapAssignment",
    "AreaPOI",
    "DungeonEncounter",
    "JournalInstance",
    "JournalEncounter",
    "JournalEncounterSection",
    "QuestInfo",
    "Languages",
    "
```

### wago.tools builds

| product | newest builds | first seen |
|---|---|---|
| wowf | 1.60.1.71091, 1.60.1.71037, 1.60.1.70959 | 2026-11-24 15:21:07 |
| wow_cn_beta | 1.60.1.70450, 1.60.1.70374, 1.60.1.70338 | 2026-10-19 22:53:11 |
| wow_classic_era | 1.15.9.70576, 1.15.9.70003, 1.15.9.69722 | 2026-10-26 23:15:05 |
- ok: wago products listed: 15 (classic-like shown: 3)
