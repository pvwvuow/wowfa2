## task 0599-grep-alerts (script)

**GREEN**


### closer to interact

addon/WoWFA/Locale_Opt.lua:84
```
   82 L.ALERTS[#L.ALERTS + 1] = { "Must have ammo equipped in the ammo slot.", fa("باید مهمات را در جایگاه مهمات بگذارید.") }
   83 -- 1.0.7 (user reports 25 Nov)
   84 L.ALERTS[#L.ALERTS + 1] = { "You need to be closer to interact with that target.", fa("برای تعامل با این هدف باید نزدیک~تر بروید.") }
   85 L.ALERTS[#L.ALERTS + 1] = { "You don't have a pet!", fa("حیوان خانگی ندارید!") }
   86 L.ALERTS[#L.ALERTS + 1] = { "Thank you for your report!", fa("از گزارش شما سپاسگزاریم!") }
```
- ok: closer to interact: 1 hits

### mail database

addon/WoWFA/Locale_Opt.lua:73
```
   71 
   72 L.ALERTS = L.ALERTS or {}
   73 L.ALERTS[#L.ALERTS + 1] = { "Internal mail database error.", fa("خطای داخلی پایگاه دادهٔ نامه~ها.") }
   74 L.ALERTS[#L.ALERTS + 1] = { "The item was not found.", fa("آیتم پیدا نشد.") }
   75 L.ALERTS[#L.ALERTS + 1] = { "You are mounted.", fa("شما سوار مرکب هستید.") }
```
- ok: mail database: 1 hits

### ERR_OUT_OF_MANA

addon/WoWFA/Locale_Alerts.lua:42
```
   40     { "SPELL_FAILED_LINE_OF_SIGHT", "هدف در خط دید نیست" },
   41     { "SPELL_FAILED_TOO_CLOSE", "هدف خیلی نزدیک است" },
   42     { "ERR_OUT_OF_MANA", "مانا کافی نیست" },
   43     { "ERR_OUT_OF_RAGE", "خشم کافی نیست" },
   44     { "ERR_OUT_OF_ENERGY", "انرژی کافی نیست" },
```
- ok: ERR_OUT_OF_MANA: 1 hits

### Tracking Beasts

- ok: Tracking Beasts: 0 hits
