-- WoWFA Forever 1.2.1 - texts of the buffs and debuffs part (Modules/Auras.lua)
-- natural Persian: the dispel types are the words players say, the time left reads like a sentence

local L = WoWFAF_L
local function fa(s)
    return (string.gsub(s, "~", "\226\128\140"))
end

L.en = L.en or {}
L.en.m_auras = "Buffs and debuffs"
L.m_auras = fa("باف~ها و دیباف~ها")
L.m_auras_d = fa("نام و توضیح باف~ها و دیباف~ها وقتی موس را روی آیکن آن~ها می~بری")

-- the dispel type line of an aura tooltip
L.AURA_DISPEL = {
    magic = fa("جادو"),
    curse = fa("نفرین"),
    poison = fa("زهر"),
    disease = fa("بیماری"),
    enrage = fa("خشم"),
    bleed = fa("خون~ریزی"),
}

-- "5 min remaining" -> "5 دقیقه مانده"
L.AURA_UNIT = {
    sec = fa("ثانیه"), secs = fa("ثانیه"), second = fa("ثانیه"), seconds = fa("ثانیه"),
    min = fa("دقیقه"), mins = fa("دقیقه"), minute = fa("دقیقه"), minutes = fa("دقیقه"),
    hr = fa("ساعت"), hrs = fa("ساعت"), hour = fa("ساعت"), hours = fa("ساعت"),
    day = fa("روز"), days = fa("روز"),
}
L.AURA_LEFT = fa("%s %s مانده")

-- the settings page
if type(L.PN) == "table" then
    L.PN.h_auras = fa("باف~ها و دیباف~ها")
    L.PN.auras = fa("باف~ها و دیباف~ها به فارسی")
    L.PN.auras_d = fa("نام، توضیح، نوع دیسپل و زمان مانده افکت~های روی شخصیت و هدف. نمایش نام و توضیح همان اسپل~هاست.")
end
