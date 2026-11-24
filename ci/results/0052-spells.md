## task 0052-spells (spells)

**GREEN**


### Source

- wow@62f85ce3a78a855eb836536f19dd0ec2468963ef
- note: druid.json is from build 1.60.1.70790, the game is 1.60.1.70959: a reworded tooltip simply will not match (the addon's miss watch reports it), nothing wrong is shown
- note: hunter.json is from build 1.60.1.70790, the game is 1.60.1.70959: a reworded tooltip simply will not match (the addon's miss watch reports it), nothing wrong is shown
- note: mage.json is from build 1.60.1.70790, the game is 1.60.1.70959: a reworded tooltip simply will not match (the addon's miss watch reports it), nothing wrong is shown
- note: paladin.json is from build 1.60.1.70790, the game is 1.60.1.70959: a reworded tooltip simply will not match (the addon's miss watch reports it), nothing wrong is shown
- note: priest.json is from build 1.60.1.70790, the game is 1.60.1.70959: a reworded tooltip simply will not match (the addon's miss watch reports it), nothing wrong is shown
- note: rogue.json is from build 1.60.1.70790, the game is 1.60.1.70959: a reworded tooltip simply will not match (the addon's miss watch reports it), nothing wrong is shown
- note: shaman.json is from build 1.60.1.70790, the game is 1.60.1.70959: a reworded tooltip simply will not match (the addon's miss watch reports it), nothing wrong is shown
- note: warlock.json is from build 1.60.1.70790, the game is 1.60.1.70959: a reworded tooltip simply will not match (the addon's miss watch reports it), nothing wrong is shown
- note: warrior.json is from build 1.60.1.70790, the game is 1.60.1.70959: a reworded tooltip simply will not match (the addon's miss watch reports it), nothing wrong is shown

### Added (fill-only)

| table | before | after | added |
|---|---|---|---|
| names.spell | 1119 | 1119 | 0 |
| names.tree | 30 | 30 | 0 |
| tpl | 1708 | 1708 | 0 |
| class | names | trees | templates |
|---|---|---|---|
| druid | 0 | 0 | 0 |
| hunter | 0 | 0 | 0 |
| mage | 0 | 0 | 0 |
| paladin | 0 | 0 | 0 |
| priest | 0 | 0 | 0 |
| rogue | 0 | 0 | 0 |
| shaman | 0 | 0 | 0 |
| warlock | 0 | 0 | 0 |
| warrior | 0 | 0 | 0 |
- already identical: {"tree": 58, "spell": 938, "tpl": 404}

### Not taken (worklist)

- numbers differ between EN and Persian (needs a translator): 27
<details><summary>number mismatch (27)</summary>

- warrior/Spearing Strike (talent): A brutal attack that deals 75% weapon damage. Deals an additional 75% weapon damage against Giants, 
- paladin/Seal of Righteousness: Fills the Paladin with holy spirit for 30 sec, granting each melee attack an additional 23 to 76 Hol
- paladin/Consecration: Consecrates the land beneath the Paladin, doing 96 Holy damage over 8 sec to enemies who enter the a
- paladin/Light's Vigil (talent): Applies Light's Vigil to a friendly target for 30 sec. The caster's next Holy Shock on the target in
- paladin/Holy Shield (talent): Increases chance to block by 30% for 10 sec, and deals 75 Holy damage for each attack blocked while 
- paladin/Unsealed Wrath (talent): Your melee attacks store a copy of your active Seal for 15 sec, stacking up to 3 times. Landing an a
- hunter/Deadly Aspects (talent): While Aspect of the Hawk is active, Auto Shot has a 2% chance of increasing ranged attack speed by 3
- rogue/Ghostly Strike: A strike that deals 125% (180% if a Dagger is equipped in your Main Hand) weapon damage, increases y
- rogue/Venom (talent): Finishing move that increases the damage of your Poisons by 30% and your chance to apply Poisons by 
- rogue/Flawless Execution (talent): Reduces the Energy cost of your Eviscerate ability by 15.
- rogue/Hack and Slash (talent): Gives your melee weapon attacks a benefit depending on the weapon.

 Axe/Sword: Your successful
 mel
- priest/Penance (talent): Launches a volley of holy light at the target, causing 45 Holy damage to an enemy, or 134 healing to
- shaman/Frost Resistance Totem: Summons a Frost Resistance Totem with 5 health at the feet of the caster for 5 min. The totem increa
- shaman/Healing Stream Totem: Summons a Healing Stream Totem with 5 health at the feet of the caster for 5 min that heals group me
- shaman/Poison Cleansing Totem: Summons a Poison Cleansing Totem with 5 health at the feet of the caster that attempts to remove 1 p
- shaman/Mana Spring Totem: Summons a Mana Spring Totem with 5 health at the feet of the caster for 5 min that restores 10 mana 
- shaman/Disease Cleansing Totem: Summons a Disease Cleansing Totem with 5 health at the feet of the caster that attempts to remove 1 
- shaman/Improved Stormstrike (talent): When you Stormstrike, you have a 50% chance to gain 50% mana regeneration while casting spells for 1
- shaman/Riptide (talent): Heals a friendly target for 445 over 15 sec, and increases the effectiveness of your Chain Heal cast
- warlock/Demonic Sacrifice: When activated, sacrifices your summoned Demon to enhance the opposing aspect of your power, grantin
- warlock/Hellfire: Ignites the area surrounding the caster, causing 210 Fire damage to himself and 210 Fire damage to a
- warlock/Soul Harvest (talent): Killing a non-trivial target afflicted by your Drain Soul increases your Mana regeneration by 50% fo
- warlock/Wrack (talent): Tears the target apart from within, inflicting 86 Shadow damage every 1 sec and increasing the damag
- warlock/Demonic Sacrifice (talent): When activated, sacrifices your summoned Demon to enhance the opposing aspect of your power, grantin
- warlock/Shadow and Flame (talent): Hitting an enemy with Conflagrate increases all Shadow damage you deal by 2% for 20 sec, and hitting
- druid/Abolish Poison: Attempts to cure 1 poison effect on the target, and 1 more poison effect every 2 seconds for 8 sec.
- druid/Bloom (talent): When your Rejuvenation or Regrowth spell expires due to its duration, the target is instantly healed

</details>
<details><summary>table already has another Persian (table kept) (647)</summary>

- tpl a strong attack that increases melee damage by # and causes a high amo: kept the table row (warrior/Heroic Strike)
- tpl charge an enemy, generate # rage, and stun it for # sec. cannot be use: kept the table row (warrior/Charge)
- tpl requires battle stance: kept the table row (warrior/Charge (req))
- tpl wounds the target causing them to bleed for # damage over # sec: kept the table row (warrior/Rend)
- tpl requires battle stance, defensive stance: kept the table row (warrior/Rend (req))
- tpl blasts nearby enemies with thunder, increasing the time between their : kept the table row (warrior/Thunder Clap)
- tpl requires battle stance, defensive stance: kept the table row (warrior/Thunder Clap (req))
- tpl maims the enemy, causing # damage and slowing the enemy's movement by : kept the table row (warrior/Hamstring)
- tpl requires battle stance, berserker stance: kept the table row (warrior/Hamstring (req))
- tpl requires battle stance: kept the table row (warrior/Overpower (req))
- tpl a mocking attack that causes # damage, a moderate amount of threat and: kept the table row (warrior/Mocking Blow)
- tpl requires battle stance: kept the table row (warrior/Mocking Blow (req))
- tpl requires battle stance: kept the table row (warrior/Retaliation (req))
- tpl a vicious strike that deals weapon damage plus # and wounds the target: kept the table row (warrior/Mortal Strike)
- tpl requires battle stance: kept the table row (warrior/Spearing Strike (req))
- tpl your next # melee attacks strike an additional nearby opponent: kept the table row (warrior/Sweeping Strikes)
- tpl requires battle stance: kept the table row (warrior/Sweeping Strikes (req))
- tpl the warrior shouts, increasing the melee attack power of all party or : kept the table row (warrior/Battle Shout)
- tpl reduces the melee attack power of all enemies within # yards by # for : kept the table row (warrior/Demoralizing Shout)
- tpl a sweeping attack that does your weapon damage plus # to the target an: kept the table row (warrior/Cleave)
- tpl the warrior shouts, causing the targeted enemy to cower in fear. up to: kept the table row (warrior/Intimidating Shout)
- tpl requires battle stance, berserker stance: kept the table row (warrior/Execute (req))
- tpl forces all nearby enemies within # yards to focus attacks on you for #: kept the table row (warrior/Challenging Shout)
- tpl the warrior enters a berserker rage, becoming immune to fear and incap: kept the table row (warrior/Berserker Rage)
- tpl instantly attack the target causing damage equal to #% of your attack : kept the table row (warrior/Bloodthirst)
- tpl the warrior will gain #% increased critical strike chance and will be : kept the table row (warrior/Recklessness)
- tpl causes all enemies within # yds to be dazed, reducing movement speed b: kept the table row (warrior/Piercing Howl)
- tpl when activated, increases your physical damage done by #% and makes yo: kept the table row (warrior/Death Wish)
- tpl generates # rage at the cost of health, and then generates an addition: kept the table row (warrior/Bloodrage)
- tpl sunders the target's armor, reducing it by # per sunder armor and caus: kept the table row (warrior/Sunder Armor)
- tpl requires defensive stance: kept the table row (warrior/Taunt (req))
- tpl requires battle stance, defensive stance: kept the table row (warrior/Shield Bash (req))
- tpl requires defensive stance: kept the table row (warrior/Revenge (req))
- tpl increases chance to block by #% for # sec, but will only block # attac: kept the table row (warrior/Shield Block)
- tpl requires defensive stance: kept the table row (warrior/Shield Block (req))
- tpl requires defensive stance: kept the table row (warrior/Disarm (req))
- tpl reduces the damage taken from all attacks by #% for # sec: kept the table row (warrior/Shield Wall)
- tpl requires defensive stance: kept the table row (warrior/Shield Wall (req))
- tpl slam the target with your shield, causing # to # damage, increased by : kept the table row (warrior/Shield Slam)
- tpl when activated, this ability temporarily grants you #% of your maximum: kept the table row (warrior/Last Stand)
- tpl stuns the target for # sec: kept the table row (warrior/Concussion Blow)
- tpl reduces the cost of your heroic strike ability by # rage: kept the table row (warrior/Improved Heroic Strike (talent))
- tpl increases your parry chance by #%: kept the table row (warrior/Deflection (talent))
- tpl increases the bleed damage done by your rend ability by #%: kept the table row (warrior/Improved Rend (talent))
- tpl increases the rage generated by your charge ability by #: kept the table row (warrior/Improved Charge (talent))
- tpl tactical mastery lets you retain up to an additional # rage when you c: kept the table row (warrior/Improved Tactical Mastery (talent))
- tpl increases the critical strike chance of your overpower ability by #%: kept the table row (warrior/Improved Overpower (talent))
- tpl generates # rage every # sec while in combat, and reduces rage loss wh: kept the table row (warrior/Anger Management (talent))
- tpl your critical strikes cause your opponent to bleed, dealing #% of your: kept the table row (warrior/Deep Wounds (talent))
- tpl increases the damage you deal with two-handed melee weapons by #%: kept the table row (warrior/Two-Handed Weapon Specialization (talent))
- tpl increases the critical strike damage bonus of your abilities by #%: kept the table row (warrior/Impale (talent))
- tpl your next # melee attacks strike an additional nearby opponent: kept the table row (warrior/Sweeping Strikes (talent))
- tpl gives your hamstring ability a #% chance to immobilize the target for : kept the table row (warrior/Improved Hamstring (talent))
- tpl a vicious strike that deals weapon damage plus # and wounds the target: kept the table row (warrior/Mortal Strike (talent))
- tpl improves your chance to get a critical strike with melee attacks by #%: kept the table row (warrior/Cruelty (talent))
- tpl gives you a #% chance to generate # additional rage when you deal mele: kept the table row (warrior/Unbridled Wrath (talent))
- tpl causes all enemies within # yds to be dazed, reducing movement speed b: kept the table row (warrior/Piercing Howl (talent))
- tpl regenerates #% of your total health over # sec after being the victim : kept the table row (warrior/Blood Craze (talent))
- spell Enrage: table خشم‌گرفتن / site خشم‌افروزی (warrior/Enrage (talent))
- tpl gives you a #% chance to deal #% increased physical damage for # sec a: kept the table row (warrior/Enrage (talent))

</details>
<details><summary>would add a second English for one Persian (name_pairs ratchet) (2)</summary>

- tree Shadow = جادوی سایه, already shadow magic (priest)
- tree Elemental = نبرد بنیادی, already elemental combat (shaman)

</details>
<details><summary>failed a data gate (3)</summary>

- tpl inflicts # nature damage to an enemy every # sec. for # min (rogue/Deadly Poison)
- tpl places a spell on the target that heals them for # the next time they  (priest/Prayer of Mending)
- tpl charge an enemy, immobilizing them and interrupting any spell they are (druid/Feral Charge)

</details>
- floors raised to the new counts: {"names.spell": 1119, "names.tree": 30, "tpl": 1708}

### Counts

| table | rows |
|---|---|
| names.boss | 31 |
| names.class | 19 |
| names.it | 20562 |
| names.itn | 0 |
| names.npc | 10251 |
| names.obj | 141 |
| names.set | 67 |
| names.spell | 1119 |
| names.tree | 30 |
| names.zone | 1178 |
| quests | 5189 |
| quests_with_title | 5189 |
| tpl | 1708 |
| ui | 25 |

### Gates

- ok: 0 errors

### Ratchet (known debt, may only shrink)

| gate | now | allowed |
|---|---|---|
| latin_in_fa | 459 | 492 |
| name_pairs_boss | 1 | not set |
| name_pairs_npc | 67 | not set |
| name_pairs_spell | 43 | 43 |
| name_pairs_zone | 9 | 9 |
| slot_unused | 17 | 17 |
| unit_word | 5 | 5 |
<details><summary>latin_in_fa (459)</summary>

- q:842:desc: از پاسگاه دورنگاه کارگال، جادهٔ غربی را دنبال کنید.
در سه‌راه T شکل، به چپ بپیچی
- q:1068:desc: خردکن‌های XT:۴ و XT:۹ را بکشید و سپس به سیرت استون‌بریک در مرز   و   برگردید.
- q:1658:t: نفوذ به جشن ویکرمن (PvP)
- q:2205:t: جست‌وجوی SI:۷
- q:2300:t: SI:7
- q:2381:desc: گنج ساوت‌سی را به ورنیکس پست در رتچت برگردانید. یادتان نرود که E.C.A.C. و ابزاره
- q:2458:desc: به برج شرکت ونچر، در شمال   سفر کنید و با مأمور مخفیِ دست شکسته، سرکارگر فیزول، 
- q:2608:desc: با دستور /Lay down دراز بکشید تا   معاینه‌تان کند. اگر علت را پیدا نکند، چطور در
- q:5672:det: روز بزرگی فرا رسیده،  . به سنی رسیده‌ای که در آن <priests or priestesses> ما آمو
- q:6185:desc: را برای سرنخ‌هایی دربارهٔ «بلایت‌کالر» و مأموران گمشدهٔ SI:۷ بگرد. اگر نشان SI:۷
- q:96658:obj: با <quest ender> در <town> صحبت کن تا آشپزی را بیاموزی.
*آشپزی را از <quest ende
- q:96658:o1: با <quest ender> در <town> صحبت کن تا آشپزی را بیاموزی.
- q:96658:o2: *آشپزی را از <quest ender> در <town> بیاموز
- n:it:barely legible journal entry, page i: یادداشتِ دفترچهٔ ناخوانا، برگ I
- n:it:barely legible journal entry, page ii: یادداشتِ دفترچهٔ ناخوانا، برگ II
- n:it:barely legible journal entry, page iii: یادداشتِ دفترچهٔ ناخوانا، برگ III
- n:it:barely legible journal entry, page iv: یادداشتِ دفترچهٔ ناخوانا، برگ IV
- n:it:barely legible journal entry, page ix: یادداشتِ دفترچهٔ ناخوانا، برگ IX
- n:it:barely legible journal entry, page v: یادداشتِ دفترچهٔ ناخوانا، برگ V
- n:it:barely legible journal entry, page vi: یادداشتِ دفترچهٔ ناخوانا، برگ VI
- n:it:barely legible journal entry, page vii: یادداشتِ دفترچهٔ ناخوانا، برگ VII
- n:it:barely legible journal entry, page viii: یادداشتِ دفترچهٔ ناخوانا، برگ VIII
- n:it:barely legible journal entry, page x: یادداشتِ دفترچهٔ ناخوانا، برگ X
- n:it:book of deathstones: rune of teleportation i: کتابِ سنگ‌های مرگ: رونِ تله‌پورت I
- n:it:book of deathstones: rune of teleportation ii: کتابِ سنگ‌های مرگ: رونِ تله‌پورت II
- n:it:book of entangling roots ii: کتابِ ریشه‌های گیرنده II
- n:it:book of entangling roots iii: کتابِ ریشه‌های گیرنده III
- n:it:book of entangling roots iv: کتابِ ریشه‌های گیرنده IV
- n:it:book of entangling roots v: کتابِ ریشه‌های گیرنده V
- n:it:book of entangling roots vi: کتابِ ریشه‌های گیرنده VI
- n:it:book of faerie fire ii: کتاب آتشِ پری II
- n:it:book of faerie fire iii: کتاب آتشِ پری III
- n:it:book of faerie fire iv: کتاب آتشِ پری IV
- n:it:book of ferocious bite v: کتاب گازِ خشم‌آلود V
- n:it:book of healing touch ii: کتابِ لمسِ شفا II
- n:it:book of healing touch iii: کتابِ لمسِ شفا III
- n:it:book of healing touch iv: کتابِ لمسِ شفا IV
- n:it:book of healing touch ix: کتابِ لمسِ شفا IX
- n:it:book of healing touch v: کتابِ لمسِ شفا V
- n:it:book of healing touch vi: کتابِ لمسِ شفا VI

</details>
<details><summary>name_pairs_boss (1)</summary>

- boss: ماروویثِ بی‌مرگ، عنصرِ نخستین <- deathless marrow with primeval elemental, deathless marrowwith primeval elemental

</details>
<details><summary>name_pairs_npc (67)</summary>

- npc: «اسکویلر» ثورن‌منتل <- "squealer" thornmantle, \"squealer\" thornmantle
- npc: نگهبانِ نقره‌ای <- argent guard, argent sentry
- npc: لجنِ بیل <- bile slime, bile sludge
- npc: لجن سیاه <- black ooze, black slime
- npc: استخوان‌جو <- bone chewer, gnawbone
- npc: براک <- brack, brakk
- npc: نگهبانِ قهرمان <- champion guardian, champion guardsman
- npc: احضارگر سرخ <- crimson conjuror, scarlet evoker, scarlet invoker
- npc: مدافع سرخ <- crimson defender, scarlet defender
- npc: محافظ سرخ <- crimson guardsman, scarlet protector
- npc: بازپرس سرخ <- crimson inquisitor, scarlet inquisitor
- npc: راهب سرخ <- crimson monk, scarlet monk
- npc: کاهن سرخ <- crimson priest, scarlet priest
- npc: جادوگر سرخ <- crimson sorcerer, scarlet magus, scarlet sorcerer
- npc: جشن‌گیرندهٔ دارناسوس <- darnassus celebrant, darnassus reveler
- npc: جادوگر دیفیاس <- defias magician, defias wizard
- npc: افعی منحرف <- deviate adder, deviate viper
- npc: ریک <- eric, reak
- npc: رین <- erin, rayne
- npc: خرس خاکستری درنده <- ferocious grizzled bear, vicious gray bear
- npc: نگهبان آتش <- fireguard, flameguard
- npc: غول پتک‌یخ <- frostmallet giant, frostmaul giant
- npc: پدربزرگ زمستان <- grandpa winter, greatfather winter
- npc: هارروک <- harroc, harruk
- npc: هماتوس <- hematos, hematus
- npc: کارگرِ هورد <- horde laborer, horde peon
- npc: جشن‌گیرندهٔ آیرون‌فورج <- ironforge celebrant, ironforge reveler
- npc: کینا <- keena, keina
- npc: کورموک <- kormok, kurmokk
- npc: کورو <- koru, korv
- npc: جنون دریاچه <- lake frenzy, loch frenzy
- npc: ماوس <- maws, mouse
- npc: کوه‌نورد طوفان‌نیزه <- mountaineer stormpike, stormpike mountaineer
- npc: ناگ <- nag, nogg
- npc: وحشت سمی <- noxious horror, toxic horror
- npc: اوموک <- omok, omokk
- npc: جشن‌گیرندهٔ اورگریمار <- orgrimmar celebrant, orgrimmar reveler
- npc: خفاش طاعونی <- plaguebat, plagued bat
- npc: پولی <- poley, polly
- npc: رارک <- rarc, rarck, rawrk

</details>
<details><summary>name_pairs_spell (43)</summary>

- spell: شلیک هدفمند <- aim shot, targeted shot
- spell: انفجار اسرار <- arcane blast, arcane explosion
- spell: درخشش اسرار <- arcane brilliance, arcane light
- spell: نفرین رنج <- bane of agony, curse of agony
- spell: نفرین نابودی <- bane of doom, curse of doom
- spell: فریاد نبرد <- battle roar, battle shout
- spell: شفای پیوندی <- binding heal, holy binding
- spell: خونریزی <- bleed, bleeding, hemorrhage
- spell: فهم اسکرول <- comprehend scroll, comprehension
- spell: بلعیدن سایه <- consume shadows, devour shadow
- spell: بی‌رحمی <- cruelty, ruthlessness
- spell: داوری صلیبی <- crusader judgement, crusader judgment
- spell: سپر الهی <- divine aegis, divine shield
- spell: انفجار آتش <- fire blast, flame blast
- spell: فوران آتش <- fire nova, pyroclasm
- spell: شوک آتش <- fire shock, flame shock
- spell: گلولهٔ آتشین <- firebolt, pyroblast
- spell: رگبار <- flurry, volley
- spell: تلهٔ انجماد <- freeze trap, freezing trap
- spell: موهبت طبیعت <- gift of nature, gift of the wild
- spell: شفای بزرگ <- greater heal, greater healing
- spell: دعای شفا <- healing prayer, prayer of healing
- spell: خواب زمستانی <- hibernate, hibernation
- spell: خاکسترکردن <- incinerate, incineration
- spell: داوری <- judgement, judgment
- spell: تازیانهٔ درد <- lash of pain, whip of pain
- spell: موج شفای کوچک <- lesser healing wave, minor healing wave
- spell: تیر آذرخش <- lightning arrow, lightning bolt
- spell: سلاح گرداب <- maelstrom weapon, vortex weapon
- spell: توتم چشمهٔ مانا <- mana fountain totem, mana spring totem
- spell: شلیک چندگانه <- multi-shot, multiple shot, multiple shots
- spell: دعای پایداری <- prayer of fortitude, prayer of tenacity
- spell: شفای سریع <- quick heal, swift heal
- spell: احیا <- resurrect, resurrection
- spell: درد سوزان <- scorching pain, searing pain
- spell: مهر صلیبی <- seal of crusaders, seal of the crusader
- spell: مهر خشم <- seal of fury, seal of wrath
- spell: تیر سایه <- shadow arrow, shadow bolt
- spell: قفل اسپل <- spell block, spell blockade, spell lock
- spell: ضربهٔ توفان <- storm strike, stormstrike

</details>
<details><summary>name_pairs_zone (9)</summary>

- zone: ارتفاعات آراتی <- arathi heights, arathi highlands
- zone: جزایر نیزهٔ تاریک <- dark spear islands, darkspear islands
- zone: شهر غرق‌شده <- drowned city, sunken city
- zone: لانهٔ اونیکسیا <- onyxia s lair, onyxia's lair
- zone: مرداب ریزر <- razor marsh, razor swamp
- zone: قلعهٔ تیراگارد <- tiragard castle, tiragarde keep
- zone: درهٔ وارسانگ <- warsong canyon, warsong gulch
- zone: زول‌فراک <- zul farrak, zul'farrak
- zone: زول‌گوروب <- zul gurub, zul'gurub

</details>
<details><summary>slot_unused (17)</summary>

- tpl:(#) set: each time you gain a discipline effect, decrease it: number #3 never shown
- tpl:(#) set: healing chain spells cast time reduced by #.# sec: number #3 never shown
- tpl:(#) set: increases your critical strike chance by #.#%: number #3 never shown
- tpl:(#) set: reduces the cast time of your flaming storm spell b: number #3 never shown
- tpl:(#) set: reduces the cast time of your healing spells by #.#: number #3 never shown
- tpl:(#) set: reduces the cast time of your holy light spell by #: number #3 never shown
- tpl:(#) set: reduces the cast time of your mind control spell by: number #3 never shown
- tpl:(#) set: reduces the cast time of your quick heal spells by : number #3 never shown
- tpl:(#) set: reduces the cooldown of storm strike by #.# sec: number #3 never shown
- tpl:(#) set: reduces the cooldown of your swift heal spells by #: number #3 never shown
- tpl:(#) set: shortens the cast time of your banish spell by #.# : number #3 never shown
- tpl:(#) set: shortens the cooldown of your berserk ability by #.: number #3 never shown
- tpl:(#) set: shortens the cooldown of your judgment spell by #.#: number #3 never shown
- tpl:(#) set: shortens the cooldown of your power of transformati: number #3 never shown
- tpl:(#) set: your hibernation spell can now be cast in cheetah f: number #4 never shown
- tpl:(#) set: your resurrect spell can now be cast in bear form a: number #3 never shown
- tpl:damage per second increased by #.#: number #2 never shown

</details>
<details><summary>unit_word (5)</summary>

- tpl:"taught you to permanently enchant a pair of gloves, giving : {0} not followed by دقیقه
- tpl:(#) set: damage spells have a chance to cause you to maintai: {2} not followed by ثانیه
- tpl:rank #: # yards instead of # yards, # instead of #, # min in: {6} not followed by دقیقه
- tpl:summons a mana tide totem with # health at the feet of the c: {3} not followed by ثانیه
- tpl:transfers # mana every # sec from the target to the caster. : {1} not followed by ثانیه

</details>
