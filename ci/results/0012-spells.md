## task 0012-spells (spells)

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
| names.spell | 1108 | 1108 | 0 |
| names.tree | 8 | 29 | 21 |
| tpl | 1638 | 1698 | 60 |
| class | names | trees | templates |
|---|---|---|---|
| druid | 0 | 1 | 7 |
| hunter | 0 | 3 | 2 |
| mage | 0 | 1 | 7 |
| paladin | 0 | 3 | 4 |
| priest | 0 | 2 | 5 |
| rogue | 0 | 5 | 10 |
| shaman | 0 | 3 | 10 |
| warlock | 0 | 1 | 4 |
| warrior | 0 | 2 | 11 |
- already identical: {"tree": 37, "spell": 938, "tpl": 366}

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
<details><summary>table already has another Persian (table kept) (625)</summary>

- tpl a strong attack that increases melee damage by # and causes a high amo: kept the table row (warrior/Heroic Strike)
- tpl charge an enemy, generate # rage, and stun it for # sec. cannot be use: kept the table row (warrior/Charge)
- tpl wounds the target causing them to bleed for # damage over # sec: kept the table row (warrior/Rend)
- tpl blasts nearby enemies with thunder, increasing the time between their : kept the table row (warrior/Thunder Clap)
- tpl maims the enemy, causing # damage and slowing the enemy's movement by : kept the table row (warrior/Hamstring)
- tpl a mocking attack that causes # damage, a moderate amount of threat and: kept the table row (warrior/Mocking Blow)
- tpl a vicious strike that deals weapon damage plus # and wounds the target: kept the table row (warrior/Mortal Strike)
- tpl your next # melee attacks strike an additional nearby opponent: kept the table row (warrior/Sweeping Strikes)
- tpl the warrior shouts, increasing the melee attack power of all party or : kept the table row (warrior/Battle Shout)
- tpl reduces the melee attack power of all enemies within # yards by # for : kept the table row (warrior/Demoralizing Shout)
- tpl a sweeping attack that does your weapon damage plus # to the target an: kept the table row (warrior/Cleave)
- tpl the warrior shouts, causing the targeted enemy to cower in fear. up to: kept the table row (warrior/Intimidating Shout)
- tpl forces all nearby enemies within # yards to focus attacks on you for #: kept the table row (warrior/Challenging Shout)
- tpl the warrior enters a berserker rage, becoming immune to fear and incap: kept the table row (warrior/Berserker Rage)
- tpl instantly attack the target causing damage equal to #% of your attack : kept the table row (warrior/Bloodthirst)
- tpl the warrior will gain #% increased critical strike chance and will be : kept the table row (warrior/Recklessness)
- tpl causes all enemies within # yds to be dazed, reducing movement speed b: kept the table row (warrior/Piercing Howl)
- tpl when activated, increases your physical damage done by #% and makes yo: kept the table row (warrior/Death Wish)
- tpl generates # rage at the cost of health, and then generates an addition: kept the table row (warrior/Bloodrage)
- tpl sunders the target's armor, reducing it by # per sunder armor and caus: kept the table row (warrior/Sunder Armor)
- tpl increases chance to block by #% for # sec, but will only block # attac: kept the table row (warrior/Shield Block)
- tpl reduces the damage taken from all attacks by #% for # sec: kept the table row (warrior/Shield Wall)
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
- tpl increases the damage done by your off-hand weapon by #% and the rage g: kept the table row (warrior/Dual Wield Specialization (talent))
- tpl reduces the rage cost of your execute ability by #: kept the table row (warrior/Improved Execute (talent))
- tpl your berserker rage ability will instantly generate # rage and has a #: kept the table row (warrior/Improved Berserker Rage (talent))
- tpl when activated, increases your physical damage done by #% and makes yo: kept the table row (warrior/Death Wish (talent))
- tpl reduces the cooldown of your intercept ability by # sec: kept the table row (warrior/Improved Intercept (talent))
- tpl reduces the rage cost of your cleave and whirlwind abilities by #: kept the table row (warrior/Improved Whirlwind (talent))
- tpl instantly attack the target causing damage equal to #% of your attack : kept the table row (warrior/Bloodthirst (talent))
- tpl increases all the rage generated by your bloodrage ability by #%: kept the table row (warrior/Improved Bloodrage (talent))
- tpl increases your chance to block attacks with your shield by #% and gran: kept the table row (warrior/Shield Specialization (talent))
- tpl increases your defense skill by #: kept the table row (warrior/Anticipation (talent))
- tpl increases damage dealt by your revenge ability by #%: kept the table row (warrior/Improved Revenge (talent))
- tpl reduces the rage cost of your thunder clap ability by #: kept the table row (warrior/Improved Thunder Clap (talent))
- tpl when activated, this ability temporarily grants you #% of your maximum: kept the table row (warrior/Last Stand (talent))
- tpl reduces the cooldown of your disarm ability by # secs: kept the table row (warrior/Improved Disarm (talent))
- tpl reduces the rage cost of your sunder armor ability by #: kept the table row (warrior/Improved Sunder Armor (talent))
- tpl gives your shield bash ability a #% chance to silence the target for #: kept the table row (warrior/Improved Shield Bash (talent))

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
- floors raised to the new counts: {"names.spell": 1108, "names.tree": 29, "tpl": 1698}

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
| names.spell | 1108 |
| names.tree | 29 |
| names.zone | 1178 |
| quests | 5189 |
| quests_with_title | 5189 |
| tpl | 1698 |
| ui | 0 |

### Gates

- ok: 0 errors

### Ratchet (known debt, may only shrink)

| gate | now | allowed |
|---|---|---|
| latin_in_fa | 492 | 492 |
| name_pairs_spell | 43 | 43 |
| name_pairs_zone | 9 | 9 |
| slot_unused | 17 | 17 |
| unit_word | 5 | 5 |
<details><summary>latin_in_fa (492)</summary>

- q:85:com: چی را گم کردی؟ من که گردنبندی ندزدیده‌ام، چون دزد نیستم!
شاید بدانم کار چه کسی ب
- q:721:com: بله؟ ببخش... <cough> خیلی بی‌حالم. می‌شود نزدیک‌تر بیایی،  ؟
رایدول تو را فرستاد
- q:722:det: دل و جرئتی، <cough>... که برای من به   آمده‌ای،  .
اگر واقعاً آمده‌ای به هامرتُو
- q:722:pro: قبیلهٔ سایه‌فورج... <cough> خطرناک است. مراقب باش. <cough> باید گردن‌آویز را پید
- q:722:com: ها! <cough cough>
می‌دانستم گردن‌آویزم را پیدا می‌کنی،  .
<weeze> واقعاً آفرین، 
- q:723:det: <هامرتو زخم‌هایش را می‌فشارد و پیش از آنکه دوباره حرف بزند، لحظه‌ای نفس تازه می‌
- q:812:com: ، جانم را نجات دادی. ممنونم.
این را بگیر؛ امیدوارم در سفرت به کارت بیاید، اگر هم
- q:842:desc: از پاسگاه دورنگاه کارگال، جادهٔ غربی را دنبال کنید.
در سه‌راه T شکل، به چپ بپیچی
- q:878:det: باید به دشمنانم ضربه بزنی. <snort> باید به   و ریزاردمن کمک کنی تا بریستل‌بک‌ها 
- q:878:pro: وقتی دانایانِ بریستل‌بک را کشتی، اطلاعاتِ بیشتری <snort> برای هورد داری،  . <sno
- q:878:com: بله، بله... باید از شادی لبریز باشم چون بالاخره <snort> بریستل‌بک‌ها دردِ قبیله‌
- q:879:det: سه تن از قبیله‌ام از کراول بیرون آمدند تا حمله‌ها به هورد را رهبری کنند،  . <sno
- q:879:pro: شکارت چطور پیش می‌رود،  ؟ <snort>    گمان می‌کند حقیقت را دربارهٔ کسی که حمله‌ها
- q:879:com: پس کار تمام است.   می‌گوید بهتر بود این‌طور تمام شود. <snort> وقتی به من پشت کرد
- q:906:det: سرِ لاک را برای   در چهارراه ببر،  . <snort> بی‌نیاز از حرف‌زدن باید بداند چه بر
- q:993:com: عالی است!   کسی را پیدا کرده که کمکم کند.
و این را ببین... شنل ماه‌پوی...<cough>
- q:1068:desc: خردکن‌های XT:۴ و XT:۹ را بکشید و سپس به سیرت استون‌بریک در مرز کوه‌های استون‌تال
- q:1658:t: نفوذ به جشن ویکرمن (PvP)
- q:2205:t: جست‌وجوی SI:۷
- q:2300:t: SI:7
- q:2381:desc: گنج ساوت‌سی را به ورنیکس پست در رتچت برگردانید. یادتان نرود که E.C.A.C. و ابزاره
- q:2458:desc: به برج شرکت ونچر، در شمال مرداب لجن سفر کنید و با مأمور مخفیِ دست شکسته، سرکارگر
- q:2608:desc: با دستور /Lay down دراز بکشید تا دکتر میکسیل‌پیکسیل معاینه‌تان کند. اگر علت را پ
- q:2939:com: آه، پس   تو را فرستاده؟
<mutters>... همیشه با خیال‌پردازی‌هایش که چیزی مهم پیدا 
- q:3542:com: بیا، چند سکه بگیر... برو برای خودت... <hic>... زره تازه‌ای بخر یا همچین چیزی....
- q:3564:det: بیا... این... <hic> را به   بده. موفق باشی!
- q:5042:pro: اگر نیروی آگاماگان را می‌خواهی، ۴ خرده‌سنگِ خونین لازم دارم،  .  اگر این برکت را
- q:5042:com: کاش   آزاد بود و می‌دید چطور به نابودکنندگانش یورش بردی! <snort>  با جمع‌آوری ای
- q:5043:pro: می‌گویند پیشاهنگان بزرگِ قبیله‌ام در تیراندازی همتا ندارند و هیچ یاغی‌ای، <snort
- q:5043:com: باشد که نشانه‌گیری‌ات خطا نرود و ضربهٔ سلاحت درست بر هدف بنشیند،  .  روحِ آگاماگ
- q:5044:pro: شمن‌ها و زمین‌خوان‌های قبیله‌های کویلبور <snort> در نبردها و آیین‌هایشان از نیرو
- q:5044:com: دشمنانت باید بیش از پیش از تو بترسند،  . <snort>  وقتی دوباره همدیگر را دیدیم، ا
- q:5045:pro: همهٔ جنگجویان <snort> به روحی نیرومند نیاز دارند. وقتی امیدی نمانده، روح وادارت 
- q:5045:com: بزرگ‌ترین جنگجویان و بزرگ‌ترین شمن‌های <snort> هم به اراده‌ات غبطه می‌خورند،  . 
- q:5046:pro: همهٔ کسانی که <snort> به نبرد می‌روند به محافظت نیاز دارند. استخوان‌هایشان باید 
- q:5052:det: خون علاوه بر خارها، <snort> جنبه‌های دیگری از زمین را هم تغییر داد: سنگ‌های سرخِ
- q:5052:pro: قبیله‌های ما در سراسرِ   <snort> به جاهای خاردار می‌روند، چون این مکان‌ها مقدس‌ا
- q:5052:com: آه، می‌فهمی. <snort> حرف‌هایم به گوشت نشست،  .   شاید در قفس باشد، اما هیچ قفسی 
- q:5321:det: در راه اردوگاه مایسترا بودم تا   را ببینم، اما اینجا ایستادم تا کمی چرت بزنم. از
- q:5672:det: روز بزرگی فرا رسیده،  . به سنی رسیده‌ای که در آن <priests or priestesses> ما آمو

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
