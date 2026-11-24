## task 0045-tplscan (script)

**GREEN**


### Templates

- ok: 1708 templates; markers used: {'npc': 88, 'tm': 2793, 'sp': 785, 'cls': 104, 'zn': 34, 'it': 20}
- ok: 2 templates hold Latin words next to Persian text (outside markers)

### Latin runs inside Persian templates

| run | templates | is a spell key |
|---|---|---|
| cffffffff | 6 |  |

### Spell names written in plain Persian (no marker) inside templates

| persian | key | templates |
|---|---|---|
| ارجمند | reverence | 12 |
| قربانی | sacrifice | 9 |
| داوری | judgement | 9 |
| جاخالی | evasion | 7 |
| مخفی‌کاری | stealth | 6 |
| تهاجم | aggression | 6 |
| خونریزی | bleed | 5 |
| نور مقدس | holy light | 5 |
| استقامت | endurance | 5 |
| شکل گربه | cat form | 4 |
| معدن‌کاری | mining | 3 |
| رگبار | flurry | 3 |
| جوان‌سازی | rejuvenation | 3 |
| سوزاندن | immolate | 3 |
| تبعید | banish | 3 |
| خلع سلاح | disarm | 3 |
| دیده‌بانی نور | light's vigil | 3 |
| دروئید | druid | 3 |
| جاخالی دادن | dodge | 3 |
| تحریک | taunt | 3 |
| برخورد | impact | 3 |
| شمشیر | sword | 3 |
| حالت نبرد | battle stance | 3 |
| کوبیدن | pummel | 2 |
| موشک‌های اسرار | arcane missiles | 2 |
| تعادل | balance | 2 |
| نابودی | destruction | 2 |
| ماهیگیری | fishing | 2 |
| خشم الهی | divine fury | 2 |
| فوران گدازه | lava burst | 2 |
| گوی آتش | fireball | 2 |
| درد سوزان | scorching pain | 2 |
| مثله‌کردن | mutilate | 2 |
| خفه‌کردن | garrote | 2 |
| ضربهٔ شوم | sinister strike | 2 |
| جنبهٔ میمون | aspect of the monkey | 2 |
| جنبهٔ گله | aspect of the pack | 2 |
| ضدحمله | counterattack | 2 |
| تلهٔ یخ | frost trap | 2 |
| حالت بربر | berserk stance | 2 |
| حالت دفاعی | defensive stance | 2 |
| تغییر شکل اجباری | polymorph | 2 |
| افسون‌گری | enchanting | 1 |
| رهگیری | intercept | 1 |
| آهنگری | blacksmithing | 1 |
| دستکش | gloves | 1 |
| آفرینش خوراک | food creation | 1 |
| مصیبت درد | disaster of pain | 1 |
| آفرینش آب | water creation | 1 |
| انضباط | discipline | 1 |
| توانایی‌های شکافنده | piercing abilities | 1 |
| شکافتن | lacerate | 1 |
| کیفار | vengeance | 1 |
| نیش افعی | viper sting | 1 |
| فریاد دلاورانه | braveheart roar | 1 |
| حلقهٔ مرگ | death coil | 1 |
| سد ترس | fear barrier | 1 |
| ویرانی | ruin | 1 |
| بی‌ملاحظه | reckless | 1 |
| فریاد دلیرانه | brave roar | 1 |
| قدرت دگرگونی | power of transformation | 1 |
| تیر یخ | frostbolt | 1 |
| انفجار پرتابه | missile burst | 1 |
| تاریکی | darkness | 1 |
| آماده‌سازی | preparation | 1 |
| چشم در برابر چشم | eye for an eye | 1 |
| عقب‌نشینی | disengage | 1 |
| نفرین آشوب | bane of havoc | 1 |
| رام‌کردن جانور | tame beast | 1 |
| باران آتش | rain of fire | 1 |

### Samples of mixed templates

- KEY: gives your melee weapon attacks a benefit depending on the weapon. |cffffffffaxe/polearm:|r increases your critical strike chance by #%. |cffffffffmace/staff:|r
  VAL: به حمله‌های سلاح نزدیک تو بسته به نوع سلاح مزیتی می‌دهد.

 |cffffffffتبر/سلاح دسته‌بلند:|r شانس ضربهٔ
 بحرانی تو را {0}% بیشتر می‌کند.

 |cffffffffگرز/عصا:|r حمله‌هایت {1}%
 از {{tm:armor|زره}} هدف را نادیده می‌گیرند.

 |cffffffffشمشیر:|r هر حملهٔ نزدیک موفق
 
- KEY: gives your melee weapon attacks a benefit depending on the weapon. |cffffffffaxe/sword:|r your successful melee attacks have a #% chance to trigger an extra att
  VAL: به حمله‌های سلاح نزدیک تو بسته به نوع سلاح مزیتی می‌دهد.

 |cffffffffتبر/شمشیر:|r هر حملهٔ نزدیک موفق
 {0}% شانس دارد در
 همان لحظه یک حملهٔ اضافه
 روی هدف فعال کند.

 |cffffffffخنجر/سلاح مشتی:|r شانس ضربهٔ
 بحرانی تو را {1}% بیشتر می‌کند.

 |cffffffffگرز:|r ح

### grep: hunter's mark

- KEY: grants your melee and ranged attacks against enemies afflicted by hunter's mark a #% chance to allow an activation of mongoose bite. lasts # sec
  VAL: حمله‌های {{tm:melee|نزدیک‌زن}} و دوربردت به دشمنانی که {{sp:Hunter's Mark}} روی آن‌هاست، {0}% شانس دارند امکان فعال‌کردن {{sp:Mongoose Bite}} را به تو بدهند. {1} ثانیه دوام دارد.
- KEY: increases the ranged attack power bonus of your hunter's mark spell by #%
  VAL: پاداش {{tm:Ranged Attack Power|قدرت حملهٔ دوربرد}} اسپل {{sp:hunter's mark}} را {0}% {{tm:increases|افزایش می‌دهد}}.
- KEY: places the hunter's mark on the target, increasing the ranged attack power of all attackers against that target by #. in addition, the target of this ability can always be seen by the hunter whether it stealths or turns invisible. the target also appears on the mini-map. lasts for # min
  VAL: نشان {{cls:the hunter}} را روی هدف می‌گذارد و {{tm:the Ranged Attack Power|قدرت حملهٔ دوربرد}} همهٔ مهاجمان علیه آن هدف را {0} افزایش می‌دهد. افزون بر این، {{cls:the hunter}} همیشه می‌تواند هدف این توانایی را ببیند، حتی اگر مخفی شود یا نامرئی شود. هدف روی نقشهٔ کوچک هم دیده می‌شود. {1} دقیقه دوام دارد.
- spell name: hunter's mark -> نشان شکارچی

### grep: hunters mark

