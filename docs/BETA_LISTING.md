# WoWFA beta 1: the listing (CurseForge + the site)

Everything the owner pastes when the first beta goes out. Nothing here is published by CI: he presses Publish.

## CurseForge

- Project name: **WoWFA (Persian) for WoW Forever**
- Slug: wowfa-persian
- Category: Localization (Translation)
- Main file: the zip of the release `forever-v1.0.0-<version>` from wowfarsi-addon (folder `WoWFA`)
- Release type: **Beta**
- Game version: WoW Forever (the client build in policy.json: game_build). If the list has no Forever entry, pick the closest and say it in the description.
- License: all rights reserved for the data; the addon code is free to use. Credit line: "Data from ForeverDB.net" (required).
- Links: site https://wowfarsi.ir , issues = the site feedback page.

### Summary (one line)

Persian for WoW Forever: quests, quest tracker, zone and NPC names, spells, talents, game alerts and chat.

### Description (English)

WoWFA brings WoW Forever to Persian.

- Quests: full text, titles, objectives, and the quest tracker, with names coloured like on the site.
- Names: zones, NPCs, spells, talents and classes. Each family has its own switch, so you decide what stays English.
- Spellbook and talents: Persian only, or Persian under the English.
- Game alerts: the red messages in the middle of the screen (Out of range, Invalid target, ...).
- Persian chat: your chat shows Persian letters and typed Persian is joined and reads right to left.
- Share your setup: copy a settings code and give it to a friend. A code made by a newer version still loads as far as your version understands it, and tells you to update.
- Updates from the game: when the game is patched, sensitive parts pause themselves instead of showing wrong text.

This is a beta. Text the data does not know stays English and is listed in the Status page (misses), so you can send it to us.

Data from ForeverDB.net.

### Description (Persian, for the site and the second tab)

WoWFA بازی WoW Forever را فارسی می‌کند.

- کوئست‌ها: متن کامل، عنوان، هدف‌ها و ردیاب کوئست، با نام‌های رنگی مثل سایت.
- نام‌ها: مناطق، NPCها، اسپل‌ها، استعدادها و کلاس‌ها. هر دسته کلید جدا دارد و خودت تعیین می‌کنی چه چیزی انگلیسی بماند.
- کتاب جادو و استعدادها: فقط فارسی، یا فارسی زیر انگلیسی.
- هشدارهای بازی: پیام‌های قرمز وسط صفحه (خارج از برد، هدف نامعتبر و ...) فارسی.
- چت فارسی: حروف فارسی در چت دیده می‌شوند و متن تایپ‌شده به هم وصل و راست‌به‌چپ نمایش داده می‌شود.
- اشتراک‌گذاری تنظیمات: کد تنظیمات را به دوستت بده. اگر کد را نسخهٔ جدیدتر ساخته باشد، هر چه نسخهٔ تو می‌شناسد اعمال می‌شود و پیام آپدیت می‌بینی.
- بعد از آپدیت بازی، بخش‌های حساس خودشان متوقف می‌شوند تا متن اشتباه نشان داده نشود.

این نسخه بتاست. متنی که در دیتا نیست انگلیسی می‌ماند و در صفحهٔ «وضعیت» فهرست می‌شود؛ همان را برای ما بفرست.

### Changelog (beta 1)

- First public beta.
- 1197 NPC names rewritten in natural Persian; 44 zone names unified.
- Persian game alerts, Persian chat (font, joined letters, typing), chat font size slider.
- Tooltips set to Persian only no longer drop the first words under the rest.
- Settings codes work between versions.

### Screenshots to upload (he takes them in game)

1. Quest window with coloured names
2. Quest list beside the map with Persian zone headers
3. A talent tooltip (Persian only) and the settings window, General page
4. The world map hover label with the black outline
5. Persian chat (typing and a received line)

### Before pressing Publish

- [ ] policy.json version is the beta name (the release task builds it)
- [ ] the zip opens as `WoWFA/WoWFA.toc` with Interface set
- [ ] one clean install test: delete WTF saved variables, install, open /wowfa
- [ ] "Data from ForeverDB.net" is in the description (it is)
- [ ] screenshots uploaded

## The site (wowfarsi.ir)

Download page copy (Persian):

> نسخهٔ بتای اول WoWFA
> اددان فارسی WoW Forever. نصب: فایل را از CurseForge یا همین صفحه بگیر، پوشهٔ WoWFA را در Interface/AddOns بریز، بازی را باز کن و /wowfa را بزن.
> این نسخه بتاست. هر متنی که انگلیسی ماند را در صفحهٔ «وضعیت» اددان کپی کن و بفرست.
> Data from ForeverDB.net

Open questions for the owner: the site repo is private (pvwvuow/wow), where should the beta page and the feedback form live (a page in the site, or a GitHub Issue form)?
