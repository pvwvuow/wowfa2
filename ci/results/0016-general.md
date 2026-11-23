## task 0016-general (fix)

**RED**


### Ops

- ok: #1 set names.spell['attack']: None -> 'حمله'
- ok: #2 set names.spell['dodge']: None -> 'جاخالی'
- ok: #3 set names.spell['parry']: None -> 'پری'
- ok: #4 set names.spell['dual wield']: None -> 'دو سلاحه'
- ok: #5 set names.spell['languages']: None -> 'زبان\u200cها'
- ok: #6 set names.spell['armor proficiency']: None -> 'مهارت زره'
- ok: #7 set names.spell['shadowmeld']: None -> 'ذوب در سایه'
- ok: #8 set names.spell["elune's light"]: None -> 'نور الون'
- ok: #9 set names.spell['wisp spirit']: None -> 'روح ویسپ'
- ok: #10 set names.spell['quickness']: None -> 'تیزپایی'
- ok: #11 set names.spell['first aid']: 'کمک\u200cهای اولیه' -> 'کمک\u200cهای اولیه'
- ok: #12 set names.spell['fishing']: 'ماهیگیری' -> 'ماهیگیری'
- ok: #13 set names.spell['cooking']: 'آشپزی' -> 'آشپزی'
- ok: #14 set tpl['increases your critical strike chance with all spells and attacks by #% for # sec']: None -> 'شانس ضربهٔ بحرانی تو را با همهٔ اسپل\u200cها و حمله\u200cها به مدت {1} ثانیه {0}% افزایش می\u200cدهد.'
- ok: #15 set tpl['activate to slip into the shadows, reducing the chance for enemies to detect your presence. lasts until cancelled or upon moving. using this ability in combat discourages enemies from attacking you, but increases the cooldown to # min']: None -> 'با فعال کردن، در سایه\u200cها فرو می\u200cروی و احتمال اینکه دشمنان حضورت را تشخیص دهند کم می\u200cشود. تا وقتی لغوش کنی یا حرکت کنی ادامه دارد. استفاده از این توانایی در نبرد دشمنان را از حمله به تو منصرف می\u200cکند، اما زمان آماده\u200cسازی آن را به {0} دقیقه افزایش می\u200cدهد.'
- ok: #16 set tpl['allows one-hand and off-hand weapons to be equipped in the off-hand']: None -> 'اجازه می\u200cدهد سلاح\u200cهای یک\u200cدستی و دست\u200cچپ را در دست دوم به\u200cکار ببری.'
- ok: #17 set tpl['gives a chance to dodge enemy melee attacks']: None -> 'به تو شانس جاخالی دادن از حمله\u200cهای نزدیک دشمن را می\u200cدهد.'
- ok: #18 set tpl['gives a chance to parry enemy melee attacks']: None -> 'به تو شانس پری کردن (دفع) حمله\u200cهای نزدیک دشمن را می\u200cدهد.'
- ok: #19 set tpl['allows the creation and use bandages up to a potential skill of #. the cloth used to make those bandages are found on humanoids in the world']: None -> 'ساختن و استفاده از باندها را تا سطح مهارت {0} ممکن می\u200cکند. پارچهٔ لازم برای ساختن این باندها از انسان\u200cنماهای سراسر جهان به دست می\u200cآید.'
- ok: #20 set tpl['equip a fishing pole and find a body of water to fish. right-click on the bob in the water when it splashes to catch your fish. higher skill increases your chance of fishing successfully in higher level areas']: None -> 'یک چوب ماهیگیری به دست بگیر و کنار آب برو. وقتی چوب\u200cپنبهٔ روی آب تکان خورد، روی آن راست\u200cکلیک کن تا ماهی را بگیری. مهارت بالاتر شانس موفقیت ماهیگیری در مناطق سطح\u200cبالاتر را بیشتر می\u200cکند.'
- ok: #21 set tpl['requires fishing pole']: None -> 'نیازمند چوب ماهیگیری'
- #22 find 'aspects of a cheetah': 0 hits

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
| names.spell | 1118 |
| names.tree | 29 |
| names.zone | 1178 |
| quests | 5189 |
| quests_with_title | 5189 |
| tpl | 1706 |
| ui | 0 |

### Gates

- FAIL: ratchet: 1
  - name_pairs_spell: 44 now, allowed 43: new debt added

### Ratchet (known debt, may only shrink)

| gate | now | allowed |
|---|---|---|
| latin_in_fa | 492 | 492 |
| name_pairs_spell | 44 | 43 |
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
<details><summary>name_pairs_spell (44)</summary>

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
- spell: جاخالی <- dodge, evasion
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
