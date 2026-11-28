## task 0553-term-fix-dry (script)

**GREEN**


### two-handed: 7 changed

  [tpl] " teaches you how to permanently enchant: «افسون دائمی سلاح {{tm:two-handed|دو دستی}} را به تو می  =>  «افسون دائمی سلاح {{tm:two-handed|دودستی}} را به تو می‌
  [tpl] allows you to use two-handed axes and tw: اجازه می‌دهد از تبر {{tm:two-handed|دو دستی}} و گرز {{t  =>  اجازه می‌دهد از تبر {{tm:two-handed|دودستی}} و گرز {{tm
  [tpl] increases the damage you deal with two-h: {{tm:Damage|آسیب}} واردشدهٔ تو با {{tm:melee weapons|سل  =>  {{tm:Damage|آسیب}} واردشدهٔ تو با {{tm:melee weapons|سل

### threat: 5 changed

  [tpl] (#) set: your damage spells have a chanc: ({0}) ست: اسپل‌های آسیب‌زنندهٔ شما شانس دارند شما را جا  =>  ({0}) ست: اسپل‌های آسیب‌زنندهٔ شما شانس دارند شما را جا
  [tpl] a defensive combat stance. decreases dam: حالتی دفاعی برای {{tm:combat|نبرد}} است. آسیبی را که در  =>  حالتی دفاعی برای {{tm:combat|نبرد}} است. آسیبی را که در
  [tpl] cower, causing no damage but lowering yo: با {{sp:Cower}} آسیبی وارد نمی‌کنی، اما تیتت را به‌شدت   =>  با {{sp:Cower}} آسیبی وارد نمی‌کنی، اما تهدیدت را به‌شد

### pet-tm: 4 changed

  [tpl] begins taming a beast to be your compani: رام‌کردن جانوری را آغاز می‌کنی تا همراهت شود. در {1} ثا  =>  رام‌کردن جانوری را آغاز می‌کنی تا همراهت شود. در {1} ثا
  [tpl] gives your pet a #% chance to gain a #% : {{tm:pet|پت}} تو پس از هر {{tm:Critical Strike|ضربهٔ بح  =>  {{tm:pet|حیوان خانگی}} تو پس از هر {{tm:Critical Strike
  [tpl] your searing pain generates #% less thre: {{sp:searing pain}} تو {0}% تهدید کمتری ایجاد می‌کند و   =>  {{sp:searing pain}} تو {0}% تهدید کمتری ایجاد می‌کند و 

### pet-companion: 31 changed

  [tpl] (#) set: increases the cast range of you: ({0}) ست: برد اجرای توانایی {{tm:healing|شفا}} حیوان هم  =>  ({0}) ست: برد اجرای توانایی {{tm:healing|شفا}} حیوان خا
  [tpl] orders your pet to attack your current t: به حیوان همراهتان فرمان می‌دهد به هدف فعلی‌تان حمله کند  =>  به حیوان خانگی‌تان فرمان می‌دهد به هدف فعلی‌تان حمله کن
  q3092.com: کار من این است که با آموزش اصول حرفه‌مان آماده‌ات کنم: از را  =>  کار من این است که با آموزش اصول حرفه‌مان آماده‌ات کنم: از را

### pet-lua: 17 changed

  Locale_Alerts.lua: { "Your pet is dead.", "پت شما مرده است." },  =>  { "Your pet is dead.", "حیوان خانگی شما مرده است." },
  Locale_Alerts.lua: { "You already have a pet.", "از قبل یک پت دارید." },  =>  { "You already have a pet.", "از قبل یک حیوان خانگی دارید." },
  Locale_Opt.lua: L.rp_d = fa("خط پایین هر چیزی است که افزونه در بازی دید و فارسی~اش را نداشت (هشدار، اسم NP  =>  L.rp_d = fa("خط پایین هر چیزی است که افزونه در بازی دید و فارسی~اش را نداشت (هشدار، اسم NP

### stun-sys: 3 changed

  Locale_Sys.lua: { "SPELL_FAILED_STUNNED", "وقتی مبهوت هستید نمی~توانید این کار را بکنید" },  =>  { "SPELL_FAILED_STUNNED", "وقتی فلج شده~اید نمی~توانید این کار را بکنید" },
  Locale_Sys.lua: { "SPELL_FAILED_SILENCED", "وقتی ساکت شده~اید نمی~توانید این کار را بکنید" },  =>  { "SPELL_FAILED_SILENCED", "وقتی دچار سکوت شده~اید نمی~توانید این کار را بکنید" },
  Locale_Sys.lua: { "ERR_ATTACK_STUNNED", "وقتی مبهوت هستید نمی~توانید حمله کنید" },  =>  { "ERR_ATTACK_STUNNED", "وقتی فلج شده~اید نمی~توانید حمله کنید" },

### stun-alerts: 1 changed

  Locale_Alerts.lua: { "Can't do that while stunned", "وقتی گیج هستید نمی" .. Z .. "توانید این کار را انجام دهی  =>  { "Can't do that while stunned", "وقتی فلج شده" .. Z .. "اید نمی" .. Z .. "توانید این کار 

### wand: 31 changed

  [n:it] alchemist's wand: وندِ کیمیاگر  =>  واند کیمیاگر
  [n:it] brilliant wand: وندِ درخشان  =>  واند درخشان
  [n:it] broken wand: وندِ شکسته  =>  واند شکسته

### crossbow: 7 changed

  [n:it] concealed hand crossbow: کمان‌پرتابِ دست‌پوشِ پنهان  =>  کمانک دست‌پوشِ پنهان
  [n:it] fine light crossbow: کمان پولکیِ مرغوبِ سبک  =>  کمانک مرغوبِ سبک
  [n:it] heavy crossbow: کمان پولکیِ سنگین  =>  کمانک سنگین

### tabard: 11 changed

  [n:it] azeroth commerce authority tabard: جلیقه‌زارِ اقتدارِ تجارتِ ازروت  =>  شنل‌نشانهٔ اقتدارِ تجارتِ ازروت
  [n:it] darkspear battle tabard: جامه‌زراهٔ نبردِ دارک‌اسپیر  =>  شنل‌نشانهٔ نبردِ دارک‌اسپیر
  [n:it] frostwolf battle tabard: جلیقه‌زارِ نبرد فراست‌ولف  =>  شنل‌نشانهٔ نبرد فراست‌ولف

### tabard2: 2 changed

  [n:it] tabard of frost: شنل‌نشان یخ  =>  شنل‌نشانهٔ یخ
  [n:it] tabard of the scarlet crusade: شنل‌نشان صلیبی سرخ  =>  شنل‌نشانهٔ صلیبی سرخ

### polearm: 2 changed

  [tpl] gives your melee weapon attacks a benefi: به حمله‌های سلاح نزدیک تو بسته به نوع سلاح مزیتی می‌دهد  =>  به حمله‌های سلاح نزدیک تو بسته به نوع سلاح مزیتی می‌دهد
  [tpl] increases your chance to get a critical : شانس تو برای {{tm:Critical Strike|ضربهٔ بحرانی}} با تبر  =>  شانس تو برای {{tm:Critical Strike|ضربهٔ بحرانی}} با تبر

### fist: 1 changed

  [n:it] rune of fist weapon specialization: رونِ تخصص سلاح مشت‌زن  =>  رونِ تخصص سلاح مشت‌زنی

### offhand: 11 changed

  [tpl] allows one-hand and off-hand weapons to : اجازه می‌دهد سلاح‌های یک‌دستی و دست‌چپ را در دست دوم به  =>  اجازه می‌دهد سلاح‌های یک‌دستی و دست چپ را در دست چپ به‌
  [tpl] increases the damage done by your off-ha: {{tm:Damage|آسیب}} واردشده توسط سلاح دست غیر مسلط را {0  =>  {{tm:Damage|آسیب}} واردشده توسط سلاح دست چپ را {0}% افز
  [tpl] increases the damage done by your off-ha: {{tm:Damage|آسیب}} واردشده توسط سلاح دست دوم تو را {0}%  =>  {{tm:Damage|آسیب}} واردشده توسط سلاح دست چپ تو را {0}% 

### melee-ap: 14 changed

  [tpl] charges an enemy, immobilizes it for # s: به سمت دشمن هجوم می‌برد، او را {0} ثانیه بی‌حرکت می‌کند  =>  به سمت دشمن هجوم می‌برد، او را {0} ثانیه بی‌حرکت می‌کند
  [tpl] gives all members of the raid or group t: {{sp:Greater Blessing of Might}} را به همهٔ اعضای رید ی  =>  {{sp:Greater Blessing of Might}} را به همهٔ اعضای رید ی
  [tpl] imbue the shaman's weapon with wind. eac: سلاح {{cls:Shaman}} را با باد آغشته می‌کند. هر ضربه {0}  =>  سلاح {{cls:Shaman}} را با باد آغشته می‌کند. هر ضربه {0}

### mana-regen: 4 changed

  [tpl] afflicting a target with serpent sting a: آلوده‌کردن هدف با {{sp:Serpent Sting}} اجازه می‌دهد {0}  =>  آلوده‌کردن هدف با {{sp:Serpent Sting}} اجازه می‌دهد {0}
  [tpl] allows #% of your mana regeneration to c: اجازه می‌دهد {0}% از {{tm:mana regeneration|بازسازی مان  =>  اجازه می‌دهد {0}% از {{tm:mana regeneration|بازیابی مان
  [tpl] increases the focus regeneration of your: بازسازی تمرکز حیوان‌های خانگی تو را {0}% افزایش می‌دهد   =>  بازسازی تمرکز حیوان‌های خانگی تو را {0}% افزایش می‌دهد 

### in-combat: 2 changed

  [tpl] brings a dead player back to life with #: بازیکن مرده را با {0} {{tm:health|سلامتی}} و {1} {{tm:m  =>  بازیکن مرده را با {0} {{tm:health|سلامتی}} و {1} {{tm:m
  [tpl] incapacitates the target for up to # sec: هدف را تا {0} ثانیه از کار می‌اندازد. فقط روی انسان‌نما  =>  هدف را تا {0} ثانیه از کار می‌اندازد. فقط روی انسان‌نما

### stealth: 5 changed

  [tpl] dodge chance increased by #% and movemen: شانس جاخالی‌دادنت {0}% و سرعت حرکتت {1}% افزایش می‌یابد  =>  شانس جاخالی‌دادنت {0}% و سرعت حرکتت {1}% افزایش می‌یابد
  [tpl] garrote the enemy, causing # damage over: دشمن را با طناب خفه می‌کند و طی {1} ثانیه {0} {{tm:dama  =>  دشمن را با طناب خفه می‌کند و طی {1} ثانیه {0} {{tm:dama
  [n:it] enchant cloak - stealth: افسونِ شنل: پنهان‌کاری  =>  افسونِ شنل: مخفی‌کاری

### dodge: 2 changed

  [n:it] enchant cloak - dodge: افسونِ شنل: گریز  =>  افسونِ شنل: جاخالی
  [n:it] formula: enchant cloak - dodge: فرمول: افسونِ شنل - گریز  =>  فرمول: افسونِ شنل - جاخالی

### evasion: 1 changed

  [n:spell] evasion: جاخالی  =>  گریز

### mail-label: 1 changed

  [ui] l:mail: زنجیری  =>  حلقه‌ای

### mail: 74 changed

  [n:it] blood guard's mail greaves: ساق‌پوش زره‌حلقه‌ای نگهبان خون  =>  ساق‌پوش زره حلقه‌ای نگهبان خون
  [n:it] blood guard's mail grips: دستکش‌های زنجیریِ نگهبان خون  =>  دستکش‌های زره حلقه‌ای نگهبان خون
  [n:it] blood guard's mail vices: دست‌بند زره‌حلقه‌ای نگهبان خون  =>  دست‌بند زره حلقه‌ای نگهبان خون

### shoulders: 172 changed

  [n:it] ancient pauldrons: سرشانه‌پوش کهن  =>  سرشانه‌های کهن
  [n:it] azure gustwoven spaulders: شانه‌بندِ بادبافِ لاجوردی  =>  سرشانه‌های بادبافِ لاجوردی
  [n:it] azure shoulders: شانه‌پوشِ لاجوردی  =>  سرشانه‌های لاجوردی

### bracers: 256 changed

  [n:it] aetherwisp bracers: بازوبندهای شبح اثیری  =>  مچ‌بندهای شبح اثیری
  [n:it] al'aketh bracers: مچ‌بندِ ال‌آکث  =>  مچ‌بندهای ال‌آکث
  [n:it] al'aketh wristguards: مچ‌بندِ ال‌آکث  =>  مچ‌بندهای ال‌آکث

### leggings: 88 changed

  [n:it] archer's leggings: پاافزارِ کمان‌دار  =>  شلوار کمان‌دار
  [n:it] azure stormsewn leggings: پاافزارِ توفان‌دوزِ لاجوردی  =>  شلوار توفان‌دوزِ لاجوردی
  [n:it] barbaric leggings: پاافزارِ وحشیانه  =>  شلوار وحشیانه

### legguards: 33 changed

  [n:it] brutal legguards: پاافزارِ محافظِ بی‌رحم  =>  محافظ محافظِ بی‌رحم
  [n:it] cobalt legguards: پاافزارِ محافظِ کبالت  =>  محافظ محافظِ کبالت
  [n:it] conqueror's legguards: پاافزارِ محافظِ فاتح  =>  محافظ محافظِ فاتح

### tunic: 52 changed

  [n:it] barkshell tunic: پیراهنِ پوستهٔ چوب  =>  تونیک پوستهٔ چوب
  [n:it] beastmaster's tunic: پیراهنِ استاد جانوران  =>  تونیک استاد جانوران
  [n:it] beaststalker's tunic: تن‌پوش غول‌شکار  =>  تونیک غول‌شکار

### breastplate: 12 changed

  [n:it] black dragonscale breastplate: سینه‌بند فلس اژدهای سیاه  =>  سینه‌پوش فلس اژدهای سیاه
  [n:it] bloodlust breastplate: سینه‌بند تشنهٔ خون  =>  سینه‌پوش تشنهٔ خون
  [n:it] bloodsoul breastplate: سینه‌بند روح خونین  =>  سینه‌پوش روح خونین

### mantle: 81 changed

  [n:it] abjurer's mantle: شنلک باطل‌گر  =>  شنل‌شانهٔ باطل‌گر
  [n:it] aurora mantle: شنل سپیده‌دم  =>  شنل‌شانهٔ سپیده‌دم
  [n:it] batwing mantle: ردای رویی بال‌خفاش  =>  شنل‌شانهٔ رویی بال‌خفاش

### necklace: 11 changed

  [n:it] ephemeral choker: گردن‌بندِ زودگذر  =>  گردنبندِ زودگذر
  [n:it] essene's necklace: گردن‌بندِ اسنه  =>  گردنبندِ اسنه
  [n:it] forlorn necklace: گردن‌بند اندوه‌بار  =>  گردنبند اندوه‌بار

### hammer: 34 changed

  [n:it] arcanite blacksmith hammer: پتکِ آهنگریِ آکانیت  =>  چکشِ آهنگریِ آکانیت
  [n:it] battering hammer: پتک کوبنده  =>  چکش کوبنده
  [n:it] battleworn hammer: پتکِ جنگ‌فرسوده  =>  چکشِ جنگ‌فرسوده

### knife: 8 changed

  [n:it] big bronze knife: کاردِ برنزیِ بزرگ  =>  چاقوی برنزیِ بزرگ
  [n:it] bloodstained knife: کاردِ خون‌لکه  =>  چاقوی خون‌لکه
  [n:it] broad bladed knife: کاردِ تیغ‌پهن  =>  چاقوی تیغ‌پهن

### claw: 6 changed

  [n:it] crawler claw: چنگ خزنده  =>  چنگال خزنده
  [n:it] curved basilisk claw: چنگ خمیدهٔ بازیلیسک  =>  چنگال خمیدهٔ بازیلیسک
  [n:it] familiar claw: چنگِ همدم  =>  چنگالِ همدم

### bag: 20 changed

  [n:it] 20-slot bag: کیسهٔ ۲۰ خانه‌ای  =>  کیفِ ۲۰ خانه‌ای
  [n:it] a reasonably large bag: کیسهٔ نسبتاً بزرگ  =>  کیفِ نسبتاً بزرگ
  [n:it] a very large bag: کیسهٔ بسیار بزرگ  =>  کیفِ بسیار بزرگ

### idol: 3 changed

  [n:it] ferocious idol: تندیس درنده  =>  بتِ درنده
  [n:it] lunar idol: تندیس قمری  =>  بتِ قمری
  [n:it] unbalanced idol: تندیسِ نامتعادل  =>  بتِ نامتعادل

### totem: 22 changed

  [n:it] tablet of agitating totem: لوح توتم برانگیزاننده  =>  توتمِ توتم برانگیزاننده
  [n:it] tablet of disease cleansing totem: لوح توتم پاکسازی بیماری  =>  توتمِ توتم پاکسازی بیماری
  [n:it] tablet of earthbind totem: سنگ‌نوشتهٔ توتم زمین‌گیرکننده  =>  توتمِ توتم زمین‌گیرکننده

### ring: 8 changed

  [n:it] blush ember ring: حلقهٔ اخگر سرخ  =>  انگشتر اخگر سرخ
  [n:it] dalson family wedding ring: حلقهٔ عروسی خانوادهٔ دالسون  =>  انگشتر عروسی خانوادهٔ دالسون
  [n:it] frigid ring: حلقهٔ یخ‌زده  =>  انگشتر یخ‌زده
TOTAL 1042 (dry run, nothing written)
