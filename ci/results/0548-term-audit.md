## task 0548-term-audit (script)

**GREEN**

rows scanned: 38761

### stun /\bstun/ rows=33 n:spell:1,tpl:32

  
  e.g. stun -> فلج
  e.g. stunned -> {{tm:stun|فلج}} شده‌اید.

### silence /\bsilenc/ rows=14 n:it:1,n:spell:1,tpl:12

  اعمال‌شده 3/3
  e.g. silence -> سکوت
  e.g. silencer -> خاموش‌کننده

### slow /\bslow(s|ed|ing)?\b/ rows=26 n:it:2,n:spell:2,tpl:22

  فاصلهٔ 6/14  حرکتش 4/5  نزدیک‌شدن 3/4  حمله‌هایش 3/7  بزند، 3/8  یابد 3/7
  e.g. slow -> کندی
  e.g. slow fall -> سقوط آهسته

### root /\broot(s|ed)?\b/ rows=35 n:it:25,n:itn:2,n:obj:1,n:spell:2,tpl:5

  ریشهٔ 15/28  ریشه‌های 8/8  گیرنده 6/7  ریشه 4/4
  e.g. root tea -> چای ریشه
  e.g. lily root -> ریشهٔ زنبق

### snare /\bsnare/ rows=2 n:it:1,tpl:1

  
  e.g. deprecate snare kit -> کیت دام‌گذاری منسوخ‌شده
  e.g. (#) set: when hit in combat, has a #% chance to remove a snare effect. -> ({0}) ست: هنگام ضربه‌خوردن در {{tm:combat|نبرد}}، {1}% شانس دارد اثر {{tm:Movement Impairi

### daze /\bdaze/ rows=7 n:spell:1,tpl:6

  
  e.g. long daze -> گیجی طولانی
  e.g. dazes the target, slowing movement speed by #% for # sec -> هدف را دچار {{tm:daze|گیجی}} می‌کند و سرعت حرکتش را برای {1} ثانیه {0}% کاهش می‌دهد.

### fear /\bfear/ rows=36 n:it:8,n:itn:1,n:npc:1,n:spell:4,tpl:22

  ترس 15/15  مصون 5/9  فرار 4/10  اثرات 4/6  فیردرد 3/3
  e.g. fear -> ترس
  e.g. fear ward -> حفاظ ترس

### sleep /\bsleep/ rows=28 n:it:17,n:itn:1,n:npc:5,n:spell:1,n:zone:1,tpl:3

  خواب 12/15  خفته 6/13  بی‌رؤیا 3/3
  e.g. sleep -> خواب
  e.g. stone sleeper -> خفتهٔ سنگی

### disorient /\bdisorient/ rows=4 n:it:1,tpl:3

  
  e.g. disorienting smog potion -> معجون مه گیج‌کننده
  e.g. reduces the duration of fear and disorient effects on you by #% -> مدت اثرهای ترس و {{tm:Disorient|سرگشتگی}} بر تو را {0}% کاهش می‌دهد.

### incapacitate /\bincapacit/ rows=8 tpl:8

  می‌اندازد 5/6
  e.g. puts the enemy target in a state of meditation, incapacitating them fo -> هدف دشمن را در حالت مراقبه قرار می‌دهد و تا {0} ثانیه از کار می‌اندازد.
  e.g. unleashing this seal's energy will judge an enemy, instantly causing # -> رهاکردن {{tm:energy|انرژی}} این مهر، دشمن را {{sp:Judgement|داوری}} می‌کند و بی‌درنگ {0} ت

### charm /\bcharm/ rows=45 n:it:33,n:itn:6,tpl:6

  تعویذِ 12/24  خوش‌شانسی 6/8  هازارا 3/4
  e.g. charmed -> افسون شده‌اید.
  e.g. troll charm -> طلسم ترول

### taunt /\btaunt/ rows=10 n:it:1,n:spell:1,tpl:8

  
  e.g. taunt -> تحریک
  e.g. manual of taunt -> کتابچهٔ تحریک

### polymorph /\bpolymorph/ rows=24 n:it:5,n:npc:9,n:spell:2,tpl:8

  دگرشکل‌شده 7/7  برطرف 6/15  درمی‌آیی؛ 5/5  اجباری 5/7  گاو 4/8  گوناگون 3/6  سهم 3/3  آیتم‌ها 3/4
  e.g. polymorph -> تغییر شکل اجباری
  e.g. polymorph: cow -> تغییر شکل اجباری: گاو

### blind /\bblind/ rows=20 n:it:6,n:npc:7,n:spell:2,tpl:5

  نابینا 6/7  کورکننده 4/4  نورکور 3/3
  e.g. blind -> نابینایی
  e.g. blindweed -> علفِ کورکننده

### banish /\bbanish/ rows=9 n:it:3,n:itn:1,n:npc:1,n:spell:1,tpl:3

  
  e.g. banish -> تبعید
  e.g. libram of banishment -> لیبرام تبعید

### interrupt /\binterrupt/ rows=27 tpl:27

  قطع 14/16  ممکن 7/18  مانع 6/10  مکتب 5/7  فرار 5/10  بی‌حرکت 4/13  نمی‌کند 3/10
  e.g. grants you immunity to silence and interrupt effects for # sec -> برای {0} ثانیه در برابر اثرهای {{tm:Silence|سکوت}} و قطع {{tm:spellcasting|اجرای اسپل}} مص
  e.g. (#) set: increases your chance to resist silence and interrupt effects -> ({0}) ست: شانس مقاومت شما در برابر {{tm:silence|سکوت}} و {{tm:interrupt effects|اثرهای قطع

### bleed /\bbleed/ rows=19 n:it:2,n:npc:2,n:spell:3,tpl:12

  خونریزی 8/9
  e.g. bleed -> خونریزی
  e.g. bleeding -> خونریزی

### disease /\bdisease/ rows=31 n:it:11,n:itn:1,n:npc:7,n:spell:3,tpl:9

  بیماری 15/15  بیمار 7/11
  e.g. cure disease -> درمان بیماری
  e.g. diseased wolf -> گرگ بیمار

### poison /\bpoison/ rows=109 n:class:1,n:it:39,n:npc:7,n:spell:32,n:tree:1,n:zone:1,tpl:28

  زهر 49/102  زهرِ 14/21  زهری 8/8  مسموم 8/9  زخم 8/25  آنی 6/18  فوری 6/18  زهرها 5/6  کشنده 5/5  پاک 3/8
  e.g. poison -> زهر
  e.g. poisons -> زهرها

### curse /\bcurse/ rows=79 n:it:32,n:itn:1,n:npc:14,n:spell:14,n:zone:1,tpl:17

  نفرین 40/50  نفرین‌شده 20/26  رفع 7/22  ضعف 6/10  بی‌پروایی 5/6  نفرین‌شدهٔ 4/4  نگه 3/7  سارگراس 3/4
  e.g. cursed mage -> جادوگر نفرین‌شده
  e.g. cursed ooze -> لجن نفرین‌شده

### magic /\bmagic\b/ rows=77 n:class:1,n:it:38,n:itn:2,n:spell:7,n:tree:1,n:zone:1,tpl:27

  جادو 32/47  رفع 8/22  تضعیف 7/9  جادوییِ 5/6  بلعِ 3/3
  e.g. magic dust -> گردِ جادویی
  e.g. magic beans -> لوبیای جادویی

### stealth /\bstealth/ rows=28 n:it:5,n:spell:1,tpl:22

  تشخیص 6/19  پنهان‌کاری 5/7  بالاتر 5/10  گویی 4/4  باشید 3/9  نمی‌شکند 3/3
  e.g. stealth -> مخفی‌کاری
  e.g. stealthman 52 -> پنهان‌ساز ۵۲

### invisib /\binvisib/ rows=40 n:it:15,n:itn:3,n:npc:7,n:spell:6,tpl:9

  نامرئی 15/15  نامرئی‌شدن 12/12  تشخیص 8/19  نامرئی‌سازی 4/4  ضعیف 4/8
  e.g. invisibility -> نامرئی‌شدن
  e.g. invisible man -> مرد نامرئی

### knock /\bknock(ed|s)? ?(back|down|away)/ rows=1 n:spell:1

  
  e.g. knockdown -> زمین‌گیری

### two-hand /two.hand/ rows=12 n:it:4,n:spell:4,tpl:4

  
  e.g. two-handed sword -> شمشیر دودستی
  e.g. two-handed sword -> شمشیر دودستی

### one-hand /one.hand/ rows=3 tpl:3

  یک‌دستی 3/3
  e.g. requires one-handed axes, one-handed maces, one-handed swords -> نیازمند تبر یک‌دستی، گرز یک‌دستی یا شمشیر یک‌دستی.
  e.g. increases the damage you deal with one-handed melee weapons by #% -> {{tm:Damage|آسیب}} وارده با {{tm:melee weapons|سلاح جنگی}} یک‌دستی را {0}% افزایش می‌دهد.

### main hand /main.?hand/ rows=14 tpl:14

  اصلی 12/17  غیرفعال 4/6  مزیتی 4/7  کندتر 3/8  شخصاً 3/3  سلاح، 3/8  می‌زنند 3/8
  e.g. grants your main hand melee attacks against enemies afflicted by your  -> به {{tm:melee attacks|حمله‌های نزدیک‌زن}} دست اصلی تو علیه دشمنانی که دچار {{sp:Rend}} تو 
  e.g. backstab the target, causing #% weapon damage plus # to the target. mu -> از پشت به هدف ضربه می‌زنی و {0}% {{tm:weapon damage|آسیب سلاح}} به‌علاوهٔ {1} به او وارد م

### off hand /off.?hand/ rows=12 n:it:6,tpl:6

  غیرمسلط 4/4
  e.g. enchant off-hand - wisdom -> افسون دستِ غیرمسلط — خرد
  e.g. formula: enchant off hand - wisdom -> فرمول: افسون دست غیرمسلط — خرد

### ranged /\branged\b/ rows=37 n:it:1,n:npc:1,n:spell:1,tpl:34

  دوربرد 21/21
  e.g. ranged skills trainer -> مربی مهارت‌های دوربرد
  e.g. requires ranged weapon -> نیازمند سلاح دوربرد

### thrown /\bthrown\b/ rows=1 tpl:1

  
  e.g. equip: explodes when a thrown attack hits, dealing # to # fire damage  -> مجهز به: هنگام اصابت حملهٔ پرتابی منفجر می‌شود و به دشمنان نزدیک {0} تا {1} {{tm:fire dama

### shield /\bshield\b/ rows=283 n:it:206,n:itn:5,n:npc:1,n:obj:1,n:spell:22,tpl:47,ui:1

  سپر 217/313  سپرِ 33/49  جذب 9/29  واژهٔ 8/24  سپری 7/7  سپرت 6/6  بلوک 4/9  می‌کنی؛ 4/5  جذب‌شده 3/5
  e.g. l:shield -> سپر
  e.g. box shield -> سپرِ جعبه‌ای

### wand /\bwand\b/ rows=87 n:it:83,n:itn:3,n:spell:1

  واند 43/43  وندِ 29/29
  e.g. dire wand -> واند هولناک
  e.g. dusk wand -> وندِ غروب

### bow /\bbow\b/ rows=69 n:it:64,n:itn:2,n:npc:1,n:spell:1,tpl:1

  کمان 45/66  کمانِ 24/31  کمانه‌دارِ 4/6  بازگشتی 4/5
  e.g. bow -> کمان
  e.g. bow guy -> مسئول کمان

### crossbow /crossbow/ rows=14 n:it:12,n:spell:1,tpl:1

  کمانک 6/6  پولکیِ 4/6  کمان‌پرتابِ 3/3
  e.g. crossbow -> کمانک
  e.g. heavy crossbow -> کمان پولکیِ سنگین

### gun /\bgun\b/ rows=12 n:it:9,n:itn:2,n:zone:1

  هشدار 4/10  پرتوِ 4/6
  e.g. dae'gun -> دائه‌گان
  e.g. hum gun -> تفنگ همهمه

### polearm /polearm/ rows=4 n:it:1,tpl:3

  
  e.g. summit guardian polearm -> نیزهٔ بلند نگهبان قله
  e.g. increases your chance to get a critical strike with axes and polearms  -> شانس تو برای {{tm:Critical Strike|ضربهٔ بحرانی}} با تبرها و سلاح‌های دسته‌بلند را {0}% افز

### staff /\bstaff\b/ rows=144 n:it:136,n:itn:4,n:npc:1,tpl:3

  عصای 139/269  گره‌دار 7/9  عصا 3/8
  e.g. ley staff -> عصای لی
  e.g. war staff -> عصای جنگ

### mace /\bmace\b/ rows=43 n:it:37,n:itn:4,tpl:2

  گرز 28/58  گرزِ 15/19
  e.g. mace -> گرز
  e.g. rock mace -> گرزِ صخره

### axe /\baxe\b/ rows=160 n:it:134,n:itn:9,n:npc:11,n:spell:2,n:zone:1,tpl:3

  تبر 89/122  تبرِ 60/68  تبرانداز 10/10  پرتابی 6/13  برق‌افشان 3/5  هلالی 3/6
  e.g. hand axe -> تبرِ دستی
  e.g. keen axe -> تبرِ تیزبین

### sword /\bsword\b/ rows=87 n:it:74,n:itn:5,n:spell:3,tpl:5

  شمشیر 62/170  شمشیرِ 24/32  یک‌ونیم‌دستی 5/5  لینکن 4/6  می‌گیرند 3/9  یک‌ونیم‌دستهٔ 3/3
  e.g. sword -> شمشیر
  e.g. merc sword -> شمشیر مزدور

### dagger /\bdagger/ rows=105 n:it:73,n:itn:5,n:npc:10,n:spell:2,n:zone:3,tpl:12

  خنجر 59/102  خنجرِ 26/33  خارخنجر 8/8  اصلی 6/17  ضربه‌ای 3/7
  e.g. dagger -> خنجر
  e.g. hook dagger -> خنجرِ قلاب‌دار

### fist /fist weapon/ rows=3 n:it:1,tpl:2

  
  e.g. rune of fist weapon specialization -> رونِ تخصص سلاح مشت‌زن
  e.g. increases your chance to get a critical strike with fist weapons by #% -> شانس {{tm:Critical Strike|ضربهٔ بحرانی}} تو با سلاح مشت‌زنی را {0}% افزایش می‌دهد.

### cloth /\bcloth\b/ rows=80 n:it:71,n:itn:5,tpl:3,ui:1

  پارچه‌ای 36/39  پارچه‌ایِ 24/24  نازک 6/10  پارچه 4/4  بازیکنِ 4/12
  e.g. l:cloth -> پارچه‌ای
  e.g. silk cloth -> پارچهٔ ابریشمی

### leather /\bleather\b/ rows=673 n:it:637,n:itn:31,n:obj:1,n:set:1,tpl:2,ui:1

  چرمی 375/377  چرمِ 170/173  چرم 85/116  چرمیِ 38/38  شرور 18/26  تیره 18/50  مدافع 18/59  توتمی 18/25  خرد 18/38  درمانگر 16/47
  e.g. l:leather -> چرمی
  e.g. fel leather -> چرم پلیدی

### mail /\bmail\b/ rows=188 n:it:185,n:npc:1,n:spell:1,ui:1

  حلقه‌ای 72/140  زره‌حلقه‌ای 25/27  زره‌زنجیری 24/25  زنجیریِ 22/61  جنگاور 12/30  آسمان‌خوان 12/29  ردگیر 12/17  زره‌پوستِ 10/12  گریفون 9/27  حلقه‌ایِ 9/17
  e.g. mail -> زره زنجیری
  e.g. l:mail -> زنجیری

### plate /\bplate\b/ rows=213 n:it:205,n:itn:5,n:set:1,tpl:1,ui:1

  صفحه‌ایِ 88/88  صفحه‌ای 86/103  امپراتوری 20/49  مبارک 10/19  برجسته 9/16  بازیکنِ 8/12  مرمرین 7/9  پولادیِ 7/7  گوتیک 7/9  فولادِ 4/6
  e.g. l:plate -> صفحه‌ای
  e.g. dwarven plate -> زره صفحه‌ای دورفی

### trinket /trinket/ rows=1 n:it:1

  
  e.g. carved stone trinket -> آویزِ سنگیِ کنده‌کاری‌شده

### finger /\bfinger/ rows=20 n:it:11,n:itn:1,n:npc:1,n:spell:2,tpl:5

  انگشت 8/11
  e.g. ice finger -> انگشت یخ
  e.g. dragon finger -> انگشت اژدها

### neck /\bneck\b/ rows=0 

  

### wrist /\bwrist/ rows=96 n:it:85,n:itn:6,tpl:5

  مچ 27/31  مچ‌بندِ 24/80  افزودن 3/5
  e.g. glacial wrists -> مچ‌بندهای یخچالی
  e.g. glacial wrists -> مچ‌بندهای یخچالی

### waist /\bwaist/ rows=75 n:it:71,n:itn:3,tpl:1

  کمر 49/87  میان‌بندِ 4/10
  e.g. black waistcord -> کمربندِ سیاه
  e.g. fiery waistcord -> بند کمر آتشین

### shoulder /\bshoulder/ rows=330 n:it:318,n:itn:12

  شانه‌پوشِ 128/168  سرشانه‌های 110/240  سرشانهٔ 31/72  شانهٔ 19/28  چکمه، 17/18  شانه‌پوش 14/17  ستِ 12/36  ماورایی 6/12  فرماندهِ 5/16  نِدِر 5/12
  e.g. azure shoulders -> شانه‌پوشِ لاجوردی
  e.g. elite shoulders -> سرشانه‌های زبده

### chest /\bchest\b/ rows=68 n:it:55,n:itn:5,n:obj:8

  سینه 23/27  صندوقِ 6/14  استقامتِ 5/15  ویژگی‌های 3/5
  e.g. malem chest -> صندوق مالم
  e.g. small chest -> صندوقِ کوچک

### legs /\blegs\b/ rows=23 n:it:23

  چکمه، 17/18  ستِ 12/36  شانه‌پوش 10/17
  e.g. chimaera hide legs -> شلوار پوست کیمرا
  e.g. restored plate legs -> ساق‌پوش صفحه‌ای بازسازی‌شده

### feet /\bfeet\b/ rows=25 n:it:3,tpl:22

  یاردی 17/49
  e.g. feet of the lynx -> چکمه‌های سیاه‌گوش
  e.g. transmog ui feet item -> آیتم کفش رابط تغییر ظاهر

### hands /\bhands\b/ rows=12 n:it:9,n:npc:1,n:spell:1,tpl:1

  دست‌های 4/4  دست‌گذاری 4/4
  e.g. panic hands -> دست‌های هراس
  e.g. lay on hands -> دست‌گذاری

### head /\bhead\b/ rows=244 n:it:162,n:itn:66,n:npc:10,n:zone:3,tpl:3

  سر 176/207  سرِ 55/61  بریدهٔ 17/22  هترا 6/7  کوچک‌شده 4/5  قزل‌آلای 4/4  سرمرگ 3/3
  e.g. a head rag -> دستمال سر
  e.g. zac's head -> سر زَک

### back /\bback\b/ rows=14 n:it:1,tpl:13

  فکر 3/7
  e.g. kresh's back -> پشت کرش
  e.g. betsy! give me betsy back! -> بتسی! بتسی‌ام رو پس بده!

### tabard /tabard/ rows=35 n:it:32,n:itn:2,tpl:1

  شنل‌نشانهٔ 16/16  جلیقه‌زارِ 9/10
  e.g. guild tabard -> جلیقه‌زارِ گیلد
  e.g. hidden tabard -> شنل‌نشانهٔ پنهان

### quiver /quiver/ rows=17 n:it:14,n:itn:2,tpl:1

  ترکش 9/12  ترکشِ 8/9
  e.g. heavy quiver -> ترکشِ سنگین
  e.g. light quiver -> ترکشِ سبک

### ammo /\bammo|arrow|bullet/ rows=78 n:boss:2,n:it:36,n:itn:5,n:npc:10,n:spell:7,n:zone:9,tpl:9

  تیر 18/38  مهمات 9/9  تیرِ 8/10  گورتپهٔ 4/4  دارو 4/5  دارراو 4/4  داروشیر 4/4  مهماتِ 4/4  دارراوشیر 3/3  منسوخ‌شده 3/6
  e.g. barrow key -> کلید گورپشته
  e.g. holy arrow -> تیرِ مقدس

### bag /\bbag\b/ rows=117 n:it:103,n:itn:8,tpl:6

  کیف 40/65  کیفِ 33/41  مواد 13/32  خانه‌ای 5/10  ماگوویو 3/7  موادِ 3/3  بی‌انتها 3/3
  e.g. book bag -> کیسهٔ کتاب
  e.g. dusty bag -> کیفِ غبارآلود

### reagent /reagent/ rows=25 n:it:19,n:itn:3,n:npc:2,tpl:1

  مواد 17/32
  e.g. reagent bot -> ربات مواد
  e.g. reagent bot -> ربات مواد

### consumable /consumable/ rows=1 n:it:1

  
  e.g. raid consumables -> مواد مصرفی ریید

### trade goods /trade goods/ rows=0 

  

### quest item /quest item/ rows=2 n:it:2

  
  e.g. chu's quest item -> آیتمِ مأموریتِ چو
  e.g. quest item placeholder -> جای‌نگهدارِ آیتم مأموریت

### junk /\bjunk\b|\bpoor\b/ rows=5 n:it:3,tpl:2

  
  e.g. shiny junk -> زبالهٔ براق
  e.g. kum'isha's junk -> عوارجِ کومی‌یشا

### soulbound /soulbound|binds when/ rows=2 n:it:1,n:itn:1

  
  e.g. soulbound keepsake -> یادگار روح‌بسته
  e.g. soulbound keepsake -> یادگار روح‌بسته

### unique /\bunique\b/ rows=8 tpl:8

  تجهیز 8/8  یکتا 8/8
  e.g. unique equipment: expert (#) -> تجهیز یکتا: کارشناس ({0})
  e.g. unique equipment: battle rune (#) -> تجهیز یکتا: رون {{tm:Battle|نبرد}} ({0})

### requires /^requires\b/ rows=25 tpl:25

  نیازمند 24/66  شهرت 6/13
  e.g. requires daggers -> نیازمند خنجر
  e.g. requires shields -> نیازمند سپر

### durability /durability/ rows=13 n:it:13

  
  e.g. durability bow -> کمان بادوام
  e.g. durability hat -> کلاه بادوام

### cooldown /cooldown/ rows=142 tpl:142

  توانایی 24/73  کول‌داون 5/5  مشترک 4/5  دایرهٔ 4/7  کوتاه‌تر 3/3  ندارد 3/9  حذف 3/4
  e.g. use: eat me.(# sec cooldown) -> استفاده: مرا بخور. ({{tm:cooldown|کول‌داون}} {0} ثانیه)
  e.g. use: heals # to # hp.(# min cooldown) -> استفاده: {0} تا {1} {{tm:HP|سلامتی}} بازیابی می‌کند. ({{tm:cooldown|کول‌داون}} {2} دقیقه)

### cast time /cast time|sec cast/ rows=36 tpl:36

  زمان 30/81  اجرای 29/84
  e.g. (#) set: shortens the cast time of your spell spell -> ({0}) ست: زمان اجرای {{tm:spell|اسپل}} را کوتاه می‌کند.
  e.g. (#) set: healing chain spells cast time reduced by # sec -> ({0}) ست: زمان اجرای اسپل‌های زنجیرهٔ {{tm:Healing|شفا}} {1} ثانیه کاهش می‌یابد.

### instant /\binstant\b/ rows=26 n:it:8,n:spell:6,tpl:12

  آنی 17/18  فوری 8/18  ضربه‌ای 4/7  فعال‌سازی، 3/10
  e.g. instant toxin -> زهر فوری
  e.g. instant poison -> زهر آنی

### channel /\bchannel/ rows=27 n:it:10,n:itn:2,n:spell:3,n:zone:1,tpl:11

  کانال‌سازی 5/5  حفظ 3/7  سریع‌تر 3/6  کانال‌گر 3/3  هدایت 3/5
  e.g. mana channels -> کانال‌های مانا
  e.g. frost channeling -> کانال‌سازی یخ

### yard /\byd\b|\byards?\b/ rows=74 tpl:74

  شعاع 59/70  یاردی 43/49  یارد 27/30  اعضای 25/49  برد 9/30  پیرامون 3/3  نزدیک‌شدن 3/4  یاردی، 3/3
  e.g. # yards instead of # yards, # min instead of # min -> شعاع {0} یارد به‌جای {1} یارد و مدت {2} دقیقه به‌جای {3} دقیقه.
  e.g. increases the range of your fire spells by # yards -> برد {{tm:Fire spells|اسپل‌های آتش}} را {0} یارد افزایش می‌دهد.

### attack power /attack power/ rows=66 tpl:66

  ببخشد 3/3  گوناگون 3/6  درمی‌آیی؛ 3/5
  e.g. attack power increased by # -> {{tm:Attack power|قدرت حمله}} {0} واحد افزایش یافته است.
  e.g. increases your attack power by #% -> {{tm:Attack Power|قدرت حمله}} تو را {0}% افزایش می‌دهد.

### critical /\bcritical/ rows=121 n:it:2,n:npc:2,n:spell:1,tpl:116

  پاداش 12/39  حمله‌هایت 6/11  بحرانی 5/5  تو، 5/6  موفق 4/6  غیردوره‌ای 4/5  نادیده 4/12  می‌گیرند 4/9  حمله‌ها 4/13  فعال‌شدن، 4/6
  e.g. critical mass -> جرم بحرانی
  e.g. critically injured soldier -> سرباز به‌شدت مجروح

### haste /\bhaste\b/ rows=6 n:it:1,tpl:5

  سلاحت 3/6
  e.g. enchant gloves - minor haste -> افسون دستکش — شتاب ناچیز
  e.g. increases hitpoints by #. #% haste to all spells and attacks. # mana r -> {{tm:hitpoints|سلامتی}} را {0} واحد افزایش می‌دهد. {1}% {{tm:haste|شتاب}} به همهٔ اسپل‌ها 

### dodge /\bdodge/ rows=25 n:it:2,n:spell:1,tpl:22

  جاخالی 6/9
  e.g. dodge -> جاخالی دادن
  e.g. enchant cloak - dodge -> افسونِ شنل: گریز

### parry /\bparry|\bparries/ rows=12 n:spell:1,tpl:11

  
  e.g. parry -> پری
  e.g. increases your parry chance by #% -> شانس {{tm:Parry|پری}} تو را {0}% افزایش می‌دهد.

### block /\bblock(s|ed|ing)?\b/ rows=30 n:it:5,n:spell:3,n:zone:1,tpl:21

  بلوک 9/9  سپرت 5/6
  e.g. ice block -> قالب یخ
  e.g. spell block -> قفل اسپل

### armor /\barmor\b/ rows=281 n:it:189,n:itn:6,n:npc:1,n:set:10,n:spell:15,tpl:59,ui:1

  زره 160/437  زرهٔ 35/67  زرهِ 25/26  کیت 10/23  نادیده 8/12  می‌گیرند 7/9  حمله‌هایت 5/11  کیتِ 5/14  شخصیت‌های 4/4  مجموعه‌ای 4/4
  e.g. armor -> زره
  e.g. fel armor -> زره ناپاک

### resist /\bresist/ rows=100 n:it:38,n:itn:1,n:npc:9,n:spell:11,tpl:41

  مقاومت 54/56  برابر 44/97  مقاومتِ 14/14
  e.g. fire resistance -> مقاومت آتش
  e.g. frost resistance -> مقاومت یخ

### stamina /\bstamina/ rows=46 n:it:33,n:spell:1,tpl:12

  استقامت 18/33  استقامتِ 12/15  طاقت 4/4
  e.g. great stamina -> استقامت عظیم
  e.g. scroll of stamina -> طومارِ طاقت

### strength /\bstrength/ rows=77 n:it:47,n:itn:4,n:npc:5,n:spell:5,n:zone:1,tpl:15

  قدرت 42/110
  e.g. strength -> قدرت بدنی
  e.g. divine strength -> نیروی الهی

### agility /\bagility/ rows=69 n:it:48,n:itn:3,n:spell:2,tpl:16

  چابکی 45/51  چابکیِ 8/9
  e.g. agility -> چابکی
  e.g. mental agility -> چابکی ذهنی

### intellect /\bintellect/ rows=58 n:it:40,n:spell:4,tpl:14

  هوش 35/35  هوشِ 7/7  هوشت 4/6
  e.g. intellect -> هوش
  e.g. arcane intellect -> هوش اسرار

### spirit /\bspirit\b/ rows=206 n:it:69,n:itn:3,n:npc:87,n:set:3,n:spell:15,n:zone:3,tpl:26

  روح 158/238  روحِ 13/22  سرشار 5/13  زندانی 4/11
  e.g. spirit -> روح
  e.g. spirit den -> لانهٔ ارواح

### mana /\bmana\b/ rows=242 n:boss:1,n:it:72,n:itn:5,n:npc:16,n:spell:12,n:zone:1,tpl:135

  مانا 77/90  بازیابی 40/103  مانای 37/37  هزینهٔ 27/56  نشسته 10/28  مصرف 9/26  ادامه 9/30  بازمی‌گرداند 8/25  اجازه 7/22  مانایت 6/6
  e.g. mana burn -> سوزاندن مانا
  e.g. mana jade -> یشمِ مانا

### rage /\brage\b/ rows=80 n:it:20,n:itn:2,n:npc:9,n:spell:5,n:zone:1,tpl:43

  خشم 37/119  خشمِ 11/17  تولید 8/9  چنگال‌خشم 6/8  تولیدشده 3/4  زخم‌خشم 3/4
  e.g. rage paw -> پنجهٔ خشم
  e.g. rage potion -> معجونِ خشم

### energy /\benergy\b/ rows=66 n:it:6,n:itn:1,tpl:59

  مهر، 13/13  رهاکردن 11/11  ضربه‌های 6/16  انرژی 6/12  سرشار 5/13  دهند 4/11  بازگردانند 3/4  رها 3/3
  e.g. energy cloak -> شنل انرژی
  e.g. fizzy energy drink -> نوشیدنی انرژی‌زای گازدار

### health /\bhealth\b/ rows=147 n:it:5,n:npc:1,n:spell:2,tpl:139

  بازیابی 55/103  هنگام 37/120  طی 27/84  باید 24/71  نشسته 24/28  شعاع 21/70  خوردن 21/30  یاردی 18/49  حداکثر 18/51  دست‌کم 16/18
  e.g. health funnel -> مجرای سلامتی
  e.g. idol of health -> بتِ سلامتی

### threat /\bthreat\b/ rows=68 n:it:3,n:itn:1,tpl:64

  ایجاد 27/55  تهدید 18/19  ایجادشده 17/17  بسیار 10/22  بالا 9/12  نمی‌کند، 5/6  زیادی 3/6  بدون 3/8  نمی‌کند 3/10
  e.g. enchant gloves - threat -> افسونِ دستکش: تهدید
  e.g. beginnings of the undead threat -> آغاز تهدید مردگان

### healing /\bhealing\b/ rows=203 n:it:86,n:itn:4,n:npc:12,n:spell:19,tpl:82

  شفا 73/99  شفای 32/66  شفابخش 18/19  موج 12/31  لمسِ 10/12  جویبار 9/11  اثرها 6/6  دعای 6/15  دهند 4/11  درمانی 4/6
  e.g. healing way -> مسیر شفا
  e.g. healing rain -> باران شفا

### heal /\bheals?\b/ rows=83 n:it:21,n:spell:8,tpl:54

  شفای 29/66  بازمی‌گرداند 13/25  سریع 11/26  گروهش 4/4  هدفی 4/7  زنجیره‌ای 4/6  اثر، 3/5  نمی‌کند 3/10  دوره‌ای 3/9  غیردوره‌ای 3/5
  e.g. heal -> شفا
  e.g. chain heal -> شفای زنجیره‌ای

### bandage /bandage/ rows=44 n:it:38,n:itn:5,tpl:1

  باندِ 24/24  بانداژ 7/7  باند 6/7  رونیِ 4/8  باندهای 4/7  ماگوویو 3/7  حوضهٔ 3/10
  e.g. silk bandage -> باندِ ابریشم
  e.g. wool bandage -> باندِ پشم

### aggro /aggro/ rows=2 n:npc:2

  
  e.g. warmaster laggrond -> استاد جنگ لگ‌راند
  e.g. commander aggro'gosh -> فرمانده اگروگوش

### melee /\bmelee/ rows=121 n:spell:1,tpl:120

  حملهٔ 38/76  نزدیک 20/58  می‌کنند 15/34  دارند 15/41  کنند 14/41  حمله‌های 11/31  سرشار 9/13  مهر، 8/13  اضافی 8/24  نزدیک‌زن 8/8
  e.g. melee specialization -> تخصص نزدیک‌زن
  e.g. requires melee weapon -> نیازمند سلاح نزدیک‌زن است.

### buff /\bbuff/ rows=6 n:npc:4,n:spell:1,tpl:1

  
  e.g. flame buffet -> سیلی شعله
  e.g. flame buffet totem -> توتم رگبار شعله

### aura /\baura\b/ rows=27 n:it:3,n:itn:1,n:spell:10,tpl:13

  هالهٔ 13/14
  e.g. owl aura -> هالهٔ جغد
  e.g. aura of fear -> هالهٔ ترس

### pet /\bpet\b/ rows=44 n:it:7,n:npc:2,n:spell:7,tpl:28

  خانگی 13/28  حیوان 12/17
  e.g. call pet -> فراخوان حیوان خانگی
  e.g. feed pet -> غذا دادن به حیوان خانگی

### totem /\btotem/ rows=337 n:it:146,n:itn:9,n:npc:99,n:spell:35,tpl:48

  توتم 216/224  توتمِ 38/38  سنگ‌نوشتهٔ 28/52  توتمی 25/25  شعاع 24/70  مقاومت 21/56  یاردی 17/49  پوست‌سنگی 13/15  هوا 10/23  جویبار 9/11
  e.g. ice totem -> توتم یخ
  e.g. air totem -> توتمِ هوا

### trap /\btrap/ rows=60 n:it:33,n:itn:1,n:npc:5,n:obj:1,n:spell:8,tpl:12

  تله‌گذار 18/18  تلهٔ 11/11  تله 9/9  دام‌گذار 3/3
  e.g. frost trap -> تلهٔ یخ
  e.g. disarm trap -> خنثی‌سازی تله

### stance /\bstance/ rows=16 n:spell:4,tpl:12

  حالتی 3/3
  e.g. battle stance -> حالت نبرد
  e.g. berserk stance -> حالت بربر

### form /\bform\b/ rows=68 n:it:2,n:npc:19,n:spell:9,tpl:38

  شکل 43/49  نوع 8/25  مکان 7/9  برطرف 6/15  درمی‌آیی؛ 5/5  اژدهایی 4/13  یوزپلنگ 3/7  گوناگون 3/6  سهم 3/3  آیتم‌ها 3/4
  e.g. cat form -> شکل گربه
  e.g. owl form -> شکل جغد

### shadow /\bshadow\b/ rows=244 n:class:1,n:it:93,n:itn:14,n:npc:32,n:spell:23,n:tree:1,n:zone:7,tpl:73

  سایه 146/236  سایهٔ 28/46  درد 11/35  واژهٔ 10/24  کلام 7/15  شود، 6/17  طاقه 6/15  درون 5/13  مبتلا 4/4  شورای 4/9
  e.g. shadow -> سایه
  e.g. sky shadow -> سایه آسمان

### holy /\bholy\b/ rows=178 n:it:69,n:itn:2,n:spell:20,n:tree:1,tpl:86

  مقدس 93/137  واژهٔ 12/24  مقدسِ 9/9  مهر، 8/13  رهاکردن 6/11  کودکس 6/18  می‌گیرد 5/15  باشد، 4/12  سرشار 4/13  بلوک 4/9
  e.g. holy -> مقدس
  e.g. holy fire -> آتش مقدس

### fire /\bfire\b/ rows=267 n:it:101,n:itn:8,n:npc:21,n:spell:28,n:tree:1,n:zone:4,tpl:104

  آتش 158/236  آتشِ 21/48  درونی 8/12  بسته 7/15  شود، 6/17  می‌سوزاند 5/8  کندتر 5/8  سلاح‌های 5/11  سلاح، 5/8  می‌زنند 5/8
  e.g. fire -> آتش
  e.g. fire -> آتش

### frost /\bfrost\b/ rows=121 n:it:55,n:itn:3,n:npc:6,n:spell:18,n:tree:1,n:zone:1,tpl:37

  یخ 69/128  یخِ 6/12  سرما 4/8  منجمد 3/10
  e.g. frost -> یخ
  e.g. frost ram -> قوچ یخ

### nature /\bnature\b/ rows=84 n:it:27,n:itn:1,n:npc:6,n:spell:11,tpl:39

  طبیعت 50/61  زهری 3/8
  e.g. nature sword -> شمشیر طبیعت
  e.g. nature's cull -> گزینش طبیعت

### arcane /\barcane\b/ rows=160 n:boss:1,n:it:82,n:itn:7,n:npc:7,n:spell:26,n:tree:1,n:zone:1,tpl:35

  اسرار 73/76  آرکان 18/20  اسرارآمیز 14/43  موشک‌های 11/11  رازآمیز 9/22  آرکانِ 6/6
  e.g. arcane -> اسرار
  e.g. arcane orb -> گویِ آرکان
