## task 0074-marktpl (script)

**GREEN**


### terms.json

- ok: type dict, keys ['banned', 'locks']
- banned: ['اسپیل']
- locks: {'spell': 'اسپل', 'stun': 'فلج', 'silence': 'سکوت', 'slow': 'کندی', 'poison': 'زهر', 'rage': 'خشم', 'daze': 'گیجی', 'charges': 'شارژ', 'polymorph': 'تغییر شکل اجباری', 'fire nova': 'فوران آتش', 'lava burst': 'فوران گدازه', 'fire blast': 'انفجار آتش'}
- ok: 12 term pairs usable

### candidates

- ok: 48 names, 12 skipped as ambiguous (two families)
ambiguous: انضباط انفجار آتش بازسازی تعادل تغییر شکل اجباری تهاجم دروئید زهرها فهم اسکرول فوران آتش فوران گدازه نابودی
- ok: markers already in the templates: {'npc': 88, 'tm': 2781, 'sp': 866, 'cls': 104, 'zn': 34, 'it': 20}

### plain names in the templates

- ok: 48 different, 123 hits
| name | fam | en | hits |
|---|---|---|---|
| فلج | tm | stun | 24 |
| مخفی‌کاری | sp | Stealth | 7 |
| پالادین | cls | Paladin | 6 |
| داوری | sp | Judgement | 6 |
| شمن | cls | Shaman | 6 |
| تبعید | sp | Banish | 4 |
| کاهن | cls | Priest | 4 |
| شارژ | tm | charges | 4 |
| معدن‌کاری | sp | Mining | 3 |
| جوان‌سازی | sp | Rejuvenation | 3 |
| خلع سلاح | sp | Disarm | 3 |
| گیجی | tm | daze | 3 |
| ماهیگیری | sp | Fishing | 3 |
| تحریک | sp | Taunt | 3 |
| ضدحمله | sp | Counterattack | 3 |
| رگبار | sp | Flurry | 2 |
| زهر | tm | poison | 2 |
| چشمهٔ نور | sp | Lightwell | 2 |
| نور الهی | sp | Divine Light | 2 |
| کندی | tm | slow | 2 |
| حالت بربر | sp | Berserk Stance | 2 |
| اورگریمار | zn | Orgrimmar | 2 |
| استورم‌ویند | zn | Stormwind | 2 |
| افسون‌گری | sp | Enchanting | 1 |
| رهگیری | sp | Intercept | 1 |
| آهنگری | sp | Blacksmithing | 1 |
| عقب‌نشینی | sp | Disengage | 1 |
| رام‌کردن جانور | sp | Tame Beast | 1 |
| نور مقدس | sp | Holy Light | 1 |
| تنفس زیر آب | sp | Underwater Breathing | 1 |
| اجرای متمرکز | sp | Focused Casting | 1 |
| سوختن سایه | sp | Shadowburn | 1 |
| سوزاندن | sp | Immolate | 1 |
| ضربهٔ شعله | sp | Flamestrike | 1 |
| آتش ماه | sp | Moonfire | 1 |
| تلهٔ انجماد | sp | Freeze Trap | 1 |
| داوری صلیبی | sp | Crusader Judgement | 1 |
| بوران | sp | Blizzard | 1 |
| ضربهٔ فلج‌کننده | sp | Bash | 1 |
| رویش دوباره | sp | Regrowth | 1 |
| شوک یخ | sp | Frost Shock | 1 |
| گوی یخی | sp | Frozen Orb | 1 |
| مراقبه | sp | Meditation | 1 |
| خرده‌ستارگان | sp | Starshards | 1 |
| آتش ستاره | sp | Starfire | 1 |
| پنجهٔ وحشی | sp | Claw | 1 |
| نیروی مقدس | sp | Holy Power | 1 |
| جنبهٔ میمون | sp | Aspect of the Monkey | 1 |
- ok: hits per family: {'sp': 68, 'tm': 35, 'cls': 16, 'zn': 4}

### sample contexts

- فلج: ... به او می‌زند؛ اگر هدف فلج یا از کار افتاده باشد، ...
- فلج: ... تو فلج شده‌اند، ...
- نور الهی: ... ثانیه از نور الهی سرشار می‌کند و به هر حمل...
- تبعید: ... تبعید را ...
- مخفی‌کاری: ...نیازمند مخفی‌کاری...
- رام‌کردن جانور: ... ثانیه‌ای که روی رام‌کردن جانور تمرکز می‌کنی، ...
- آتش ستاره: ... برای آتش ستاره را ...
- اورگریمار: ...ارت‌ها در یک بستهٔ هدیهٔ اورگریمار کلیک راست کنید....
- داوری: ... و داوری خرد را ...
- شمن: ...سلاح شمن را با باد آغشته می‌کند. ...
- ok: 105 templates rewritten
