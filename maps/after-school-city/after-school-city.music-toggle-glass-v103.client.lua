-- AFTER SCHOOL CITY — V1.0.3 music toggle glass harmonization.
-- Visual-only. Does not alter audio, playlist, volume, playback, or music authority.

local Players = game:GetService("Players")

local player = Players.LocalPlayer
if not player then
    return
end

local playerGui = player:WaitForChild("PlayerGui")
local musicGui = playerGui:WaitForChild("ASC_PersonalMusic", 20)
if not musicGui then
    warn("[ASC V1.0.3] ASC_PersonalMusic GUI not found")
    return
end

local toggle = musicGui:WaitForChild("MusicToggle", 10)
if not toggle or not toggle:IsA("TextButton") then
    warn("[ASC V1.0.3] MusicToggle not found")
    return
end

toggle.BackgroundTransparency = 0.48

for _, child in ipairs(toggle:GetChildren()) do
    if child:IsA("UIStroke") then
        child.Transparency = 0.58
        child.Thickness = 1
    end
end

toggle:SetAttribute("ASC_UIVisualPass", "1.0.3-music-toggle-glass")

print("[AFTER SCHOOL CITY] V1.0.3 music toggle glass applied")
