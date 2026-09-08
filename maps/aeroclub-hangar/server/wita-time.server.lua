-- HANGAR — REALTIME WITA DAY/NIGHT v1.0
-- Syncs Roblox celestial time to WITA (UTC+8) and keeps the club readable at night.
-- Environment-only. No gameplay, UI, lasers, or monetization changes.

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local WITA_OFFSET_SECONDS = 8 * 60 * 60
local BALI_LATITUDE = -8.65

local function witaClockTime()
    local secondsToday = (os.time() + WITA_OFFSET_SECONDS) % 86400
    return secondsToday / 3600
end

local function periodFor(clock)
    if clock >= 5.25 and clock < 7 then
        return "DAWN"
    elseif clock >= 7 and clock < 17.25 then
        return "DAY"
    elseif clock >= 17.25 and clock < 18.75 then
        return "DUSK"
    end
    return "NIGHT"
end

local sky = Lighting:FindFirstChildOfClass("Sky")
if not sky then
    sky = Instance.new("Sky")
    sky.Name = "HangarWITASky"
    sky.Parent = Lighting
end
sky.CelestialBodiesShown = true
sky.SunAngularSize = 21
sky.MoonAngularSize = 11
sky.StarCount = 3000
if sky.SunTextureId == "" then
    sky.SunTextureId = "rbxasset://sky/sun.jpg"
end
if sky.MoonTextureId == "" then
    sky.MoonTextureId = "rbxasset://sky/moon.jpg"
end

Lighting.GeographicLatitude = BALI_LATITUDE

local function tunePhase2Lights(multiplier)
    local environment = Workspace:FindFirstChild("Environment")
    if not environment then return end
    local group = environment:FindFirstChild("HangarPhase2Lights")
    if not group then return end

    for _, d in ipairs(group:GetDescendants()) do
        if d:IsA("PointLight") then
            local base = d:GetAttribute("HangarWITABaseBrightness")
            if typeof(base) ~= "number" then
                base = d.Brightness
                d:SetAttribute("HangarWITABaseBrightness", base)
            end
            d.Brightness = base * multiplier
        end
    end
end

local function applyWITA()
    local clock = witaClockTime()
    local period = periodFor(clock)

    Lighting.ClockTime = clock

    local lightMultiplier = 1
    if period == "DAY" then
        Lighting.Brightness = 2.35
        Lighting.ExposureCompensation = -0.03
        Lighting.Ambient = Color3.fromRGB(92, 96, 106)
        Lighting.OutdoorAmbient = Color3.fromRGB(108, 112, 122)
        Lighting.EnvironmentDiffuseScale = 0.62
        Lighting.EnvironmentSpecularScale = 0.82
        lightMultiplier = 0.72
    elseif period == "DAWN" then
        Lighting.Brightness = 2.00
        Lighting.ExposureCompensation = 0.02
        Lighting.Ambient = Color3.fromRGB(78, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(92, 76, 68)
        Lighting.EnvironmentDiffuseScale = 0.56
        Lighting.EnvironmentSpecularScale = 0.80
        lightMultiplier = 1.05
    elseif period == "DUSK" then
        Lighting.Brightness = 1.95
        Lighting.ExposureCompensation = 0.04
        Lighting.Ambient = Color3.fromRGB(72, 64, 74)
        Lighting.OutdoorAmbient = Color3.fromRGB(82, 66, 78)
        Lighting.EnvironmentDiffuseScale = 0.54
        Lighting.EnvironmentSpecularScale = 0.80
        lightMultiplier = 1.12
    else
        -- Night must stay club-dark but readable on mobile.
        Lighting.Brightness = 1.85
        Lighting.ExposureCompensation = 0.12
        Lighting.Ambient = Color3.fromRGB(58, 64, 82)
        Lighting.OutdoorAmbient = Color3.fromRGB(38, 44, 62)
        Lighting.EnvironmentDiffuseScale = 0.50
        Lighting.EnvironmentSpecularScale = 0.82
        lightMultiplier = 1.45
    end

    local atmosphere = Lighting:FindFirstChild("HangarThinFog")
    if atmosphere and atmosphere:IsA("Atmosphere") then
        atmosphere.Density = period == "DAY" and 0.026 or 0.018
        atmosphere.Haze = period == "DAY" and 0.08 or 0.07
    end

    local cc = Lighting:FindFirstChild("HangarPhase2Grade")
    if cc and cc:IsA("ColorCorrectionEffect") then
        if period == "DAY" then
            cc.Brightness = 0
            cc.Contrast = 0.08
            cc.Saturation = 0.03
            cc.TintColor = Color3.fromRGB(255, 250, 244)
        elseif period == "DAWN" or period == "DUSK" then
            cc.Brightness = 0.01
            cc.Contrast = 0.10
            cc.Saturation = 0.05
            cc.TintColor = Color3.fromRGB(255, 228, 214)
        else
            cc.Brightness = 0.025
            cc.Contrast = 0.10
            cc.Saturation = 0.05
            cc.TintColor = Color3.fromRGB(224, 232, 255)
        end
    end

    local bloom = Lighting:FindFirstChild("HangarPhase2Bloom")
    if bloom and bloom:IsA("BloomEffect") then
        bloom.Intensity = period == "NIGHT" and 0.11 or 0.06
        bloom.Threshold = period == "NIGHT" and 1.8 or 2.1
    end

    tunePhase2Lights(lightMultiplier)

    Workspace:SetAttribute("HangarTimeAuthority", "REALTIME_WITA_UTC_PLUS_8")
    Workspace:SetAttribute("HangarWITAClockTime", clock)
    Workspace:SetAttribute("HangarWITAPeriod", period)
    Workspace:SetAttribute("HangarCelestialBodies", "SUN_AND_MOON_ENABLED")
end

applyWITA()

-- Re-apply quickly during boot because the Phase 2 environment script creates its grade/lights asynchronously.
task.spawn(function()
    for _ = 1, 10 do
        task.wait(0.75)
        applyWITA()
    end
    while true do
        task.wait(20)
        applyWITA()
    end
end)

print("[HANGAR] realtime WITA day/night active; sun + moon enabled")
