## task 0078-marktpl3 (script)

**GREEN**


### terms.json

- ok: type dict, keys ['banned', 'locks']
- banned: ['اسپیل']
- locks: {'spell': 'اسپل', 'stun': 'فلج', 'silence': 'سکوت', 'slow': 'کندی', 'poison': 'زهر', 'rage': 'خشم', 'daze': 'گیجی', 'charges': 'شارژ', 'polymorph': 'تغییر شکل اجباری', 'fire nova': 'فوران آتش', 'lava burst': 'فوران گدازه', 'fire blast': 'انفجار آتش'}
- ok: 12 term pairs usable

### candidates

- ok: 8 names, 12 skipped as ambiguous (two families)
ambiguous: انضباط انفجار آتش بازسازی تعادل تغییر شکل اجباری تهاجم دروئید زهرها فهم اسکرول فوران آتش فوران گدازه نابودی
- ok: markers already in the templates: {'sp': 934, 'npc': 88, 'tm': 2816, 'cls': 120, 'zn': 38, 'it': 20}

### plain names in the templates

- ok: 8 different, 8 hits
| name | fam | en | hits |
|---|---|---|---|
| خفه‌کردن | sp | Garrote | 1 |
| آرامش | sp | Tranquility | 1 |
| جنبهٔ شاهین | sp | Aspect of the Hawk | 1 |
| جنگاور | cls | Warrior | 1 |
| دارناسوس | zn | Darnassus | 1 |
| تاناریس | zn | Tanaris | 1 |
| مثله‌کردن | sp | Mutilate | 1 |
| سکوت | tm | silence | 1 |
- ok: hits per family: {'sp': 4, 'cls': 1, 'zn': 2, 'tm': 1}

### sample contexts

- خفه‌کردن: ... و خفه‌کردن را ...
- تاناریس: ... در تاناریس ...
- سکوت: ... ثانیه دچار سکوت هم می‌کند....
- جنبهٔ شاهین: ... جنبهٔ شاهین را می‌پذیرد و ...
- آرامش: ... و آرامش ...
- مثله‌کردن: ... یا مثله‌کردن بعدی تو را ...
- دارناسوس: ...جعبهٔ دست‌سازه‌ها، پیمان دارناسوس و دسته‌ای کارت و ساخت بس...
- جنگاور: ...جنگاور ...
- ok: 8 templates rewritten
