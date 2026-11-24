## task 0077-marktpl2 (script)

**GREEN**


### terms.json

- ok: type dict, keys ['banned', 'locks']
- banned: ['اسپیل']
- locks: {'spell': 'اسپل', 'stun': 'فلج', 'silence': 'سکوت', 'slow': 'کندی', 'poison': 'زهر', 'rage': 'خشم', 'daze': 'گیجی', 'charges': 'شارژ', 'polymorph': 'تغییر شکل اجباری', 'fire nova': 'فوران آتش', 'lava burst': 'فوران گدازه', 'fire blast': 'انفجار آتش'}
- ok: 12 term pairs usable

### candidates

- ok: 10 names, 16 skipped as ambiguous (two families)
ambiguous: انضباط انفجار آتش بازسازی تعادل تغییر شکل اجباری تهاجم حفاظت خشم دروئید زهرها زیرکی فهم اسکرول فوران آتش فوران گدازه نابودی کلیدزنی
- ok: markers already in the templates: {'sp': 934, 'npc': 88, 'tm': 2816, 'cls': 120, 'zn': 38, 'it': 20}

### plain names in the templates

- ok: 10 different, 10 hits
| name | fam | en | hits |
|---|---|---|---|
| خفه‌کردن | sp | Garrote | 1 |
| آرامش | sp | Tranquility | 1 |
| عنصر آب | sp | Water Elemental | 1 |
| جنبهٔ شاهین | sp | Aspect of the Hawk | 1 |
| جنگاور | cls | Warrior | 1 |
| دارناسوس | zn | Darnassus | 1 |
| کیفر | cls | Retribution | 1 |
| تاناریس | zn | Tanaris | 1 |
| مثله‌کردن | sp | Mutilate | 1 |
| سکوت | tm | silence | 1 |
- ok: hits per family: {'sp': 5, 'cls': 2, 'zn': 2, 'tm': 1}

### sample contexts

- آرامش: ... و آرامش ...
- دارناسوس: ...جعبهٔ دست‌سازه‌ها، پیمان دارناسوس و دسته‌ای کارت و ساخت بس...
- کیفر: ...استفاده: روش اجرای مهر کیفر خداوند (رنک ...
- خفه‌کردن: ... و خفه‌کردن را ...
- سکوت: ... ثانیه دچار سکوت هم می‌کند....
- جنگاور: ...جنگاور ...
- تاناریس: ... در تاناریس ...
- عنصر آب: ...نیازمند شهرت ارجمند نزد عنصر آب هیداشیان....
- مثله‌کردن: ... یا مثله‌کردن بعدی تو را ...
- جنبهٔ شاهین: ... جنبهٔ شاهین را می‌پذیرد و ...
- ok: 10 templates rewritten
