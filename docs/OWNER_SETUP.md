# راه‌اندازی یک‌باره (فقط صاحب پروژه، حدود ۵ دقیقه)

توکن من اجازهٔ نوشتن فایل‌های `.github/` و ساخت Secret رو نداره. این سه کار فقط یک بار لازمه.

## ۱. ساخت توکن ربات
GitHub > Settings > Developer settings > Fine-grained tokens > Generate new token
- Name: `wowfa-bot`، Expiration: 1 year
- Repository access: Only select repositories: `wowfa2`, `wowfa`, `wow`, `wowfarsi-addon`
- Permissions > Repository: **Contents: Read and write**، **Pull requests: Read and write** (Metadata خودکار Read می‌شه)
- Generate و توکن رو کپی کن (فقط یک بار نشون می‌ده). این توکن رو هیچ‌جا نفرست، نه برای من، نه تو چت.

## ۲. گذاشتن توکن به‌عنوان Secret
ریپوی `pvwvuow/wowfa2` > Settings > Secrets and variables > Actions > New repository secret
- Name: `WOWFA_BOT_TOKEN`
- Secret: همون توکن

## ۳. دو فایل CI
ریپوی `wowfa2` > Add file > Create new file
- اسم: `.github/workflows/ci.yml`، متن: کل محتوای `ci/workflows/ci.yml` (دکمهٔ Copy raw file)، Commit
- دوباره: `.github/workflows/tasks.yml`، متن: کل `ci/workflows/tasks.yml`، Commit

بعدش فقط بگو «انجام شد». بقیه‌اش با منه.
