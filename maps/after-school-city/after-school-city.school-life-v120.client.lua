-- AFTER SCHOOL CITY — V1.2 School Life client presentation
-- Localizes only school-life proximity prompts. No reward or progression authority lives here.

local LocalizationService = game:GetService("LocalizationService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local CLIENT_VERSION = "1.2.0-school-life-foundation-1"
local localeId = string.lower(LocalizationService.RobloxLocaleId or "en-us")
local lang = string.sub(localeId, 1, 2) == "id" and "id" or "en"

local TEXT = {
    en = {
        interact = "INTERACT",
        teacher = "MS. MAYA",
        canteen = "MR. BUDI • CANTEEN",
        club = "NAYA • CLUB ROOM",
    },
    id = {
        interact = "INTERAKSI",
        teacher = "MS. MAYA",
        canteen = "MR. BUDI • KANTIN",
        club = "NAYA • RUANG KLUB",
    },
}
local L = TEXT[lang]

local OBJECT_TEXT = {
    TEACHER = L.teacher,
    CANTEEN = L.canteen,
    CLUB = L.club,
}

ProximityPromptService.PromptShown:Connect(function(prompt)
    local promptId = prompt:GetAttribute("ASCSchoolPromptId")
    if not promptId then
        return
    end
    prompt.ActionText = L.interact
    prompt.ObjectText = OBJECT_TEXT[promptId] or prompt.ObjectText
end)

print("[AFTER SCHOOL CITY] V1.2 School Life client ready locale=" .. localeId .. " version=" .. CLIENT_VERSION)
