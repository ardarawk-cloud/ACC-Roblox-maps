-- HANGAR — REALTIME WITA DAY/NIGHT v1.1
-- Syncs Roblox celestial time to WITA (UTC+8).
-- Night readability pass: reduce black crush, open entrance sightline, preserve club mood.
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
if sky.SunTextureId == "" then sky.SunTextureId = "rbxasset://sky/sun.jpg" end
if sky.MoonTextureId == "" then sky.MoonTextureId = "rbxasset://sky/moon.jpg" end
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

local function setMeshStyle(name, color, transparency, castShadow)
    local environment = Workspace:FindFirstChild("Environment")
    if not environment then return end
    local mesh = environment:FindFirstChild(name, true)
    if mesh and mesh:IsA("MeshPart") then
        if color then mesh.Color = color end
        if transparency ~= nil then mesh.Transparency = transparency end
        if castShadow ~= nil then mesh.CastShadow = castShadow end
    end
end

local function applyMeshReadability(period)
    if period == "NIGHT" then
        setMeshStyle("HangarMesh", Color3.fromRGB(58, 66, 82), 0, true)
        setMeshStyle("HangarTrussMesh", Color3.fromRGB(86, 98, 122), 0, true)
        setMeshStyle("PolishedConcreteMesh", Color3.fromRGB(88, 92, 102), 0, false)
        setMeshStyle("OutdoorApronMesh", Color3.fromRGB(72, 76, 88), 0, false)
        setMeshStyle("DanceFloorMesh", Color3.fromRGB(38, 46, 60), 0, false)
        setMeshStyle("JetPlaneMesh", Color3.fromRGB(188, 198, 214), 0, true)
        -- Current donor-gate mesh is a temporary monolithic block. Fade it at night so it cannot hide the jet sightline.
        setMeshStyle("DonorGateAndPedestalsMesh", Color3.fromRGB(54, 58, 72), 0.60, false)
    elseif period == "DUSK" or period == "DAWN" then
        setMeshStyle("HangarMesh", Color3.fromRGB(54, 60, 74), 0, true)
        setMeshStyle("HangarTrussMesh", Color3.fromRGB(78, 88, 108), 0, true)
        setMeshStyle("PolishedConcreteMesh", Color3.fromRGB(82, 84, 92), 0, false)
        setMeshStyle("OutdoorApronMesh", Color3.fromRGB(68, 70, 78), 0, false)
        setMeshStyle("DanceFloorMesh", Color3.fromRGB(34, 40, 52), 0, false)
        setMeshStyle("DonorGateAndPedestalsMesh", Color3.fromRGB(48, 52, 64), 0.42, false)
    else
        setMeshStyle("HangarMesh", Color3.fromRGB(46, 52, 64), 0, true)
        setMeshStyle("HangarTrussMesh", Color3.fromRGB(68, 78, 96), 0, true)
        setMeshStyle("PolishedConcreteMesh", Color3.fromRGB(72, 76, 84), 0, false)
        setMeshStyle("OutdoorApronMesh", Color3.fromRGB(55, 59, 67), 0, false)
        setMeshStyle("DanceFloorMesh", Color3.fromRGB(24, 30, 40), 0, false)
        setMeshStyle("DonorGateAndPedestalsMesh", Color3.fromRGB(38, 42, 52), 0.24, false)
    end
end

local function ensureReadabilityLights(period)
    local environment = Workspace:FindFirstChild("Environment")
    if not environment then return end

    local old = environment:FindFirstChild("HangarWITAReadabilityLights")
    if period == "DAY" then
        if old then old:Destroy() end
        return
    end

    if old then old:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = "HangarWITAReadabilityLights"
    folder.Parent = environment

    local phaseMultiplier = period == "NIGHT" and 1 or 0.55
    local function add(pos, color, brightness, range)
        local anchor = Instance.new("Part")
        anchor.Name = "ReadabilityAnchor"
        anchor.Anchored = true
        anchor.Transparency = 1
        anchor.CanCollide = false
        anchor.CanTouch = false
        anchor.CanQuery = false
        anchor.Size = Vector3.one
        anchor.CFrame = CFrame.new(pos)
        anchor.Parent = folder

        local light = Instance.new("PointLight")
        light.Color = color
        light.Brightness = brightness * phaseMultiplier
        light.Range = range
        light.Shadows = false
        light.Parent = anchor
    end

    -- Front apron/entrance path: enough fill to read avatar and floor without flattening the scene.
    add(Vector3.new(0, 12, 245), Color3.fromRGB(138, 162, 210), 0.70, 95)
    add(Vector3.new(0, 16, 145), Color3.fromRGB(150, 178, 224), 0.82, 100)
    -- Dance-floor route separation.
    add(Vector3.new(-58, 14, 34), Color3.fromRGB(92, 150, 220), 0.46, 76)
    add(Vector3.new(58, 14, 34), Color3.fromRGB(210, 102, 174), 0.38, 76)
    -- Soft neutral lift before the jet, keeping the aircraft as focal point.
    add(Vector3.new(0, 18, -18), Color3.fromRGB(170, 190, 224), 0.52, 88)
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
        Lighting.Brightness = 2.05
        Lighting.ExposureCompensation = 0.06
        Lighting.Ambient = Color3.fromRGB(86, 78, 78)
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 84, 76)
        Lighting.EnvironmentDiffuseScale = 0.58
        Lighting.EnvironmentSpecularScale = 0.82
        lightMultiplier = 1.10
    elseif period == "DUSK" then
        Lighting.Brightness = 2.00
        Lighting.ExposureCompensation = 0.08
        Lighting.Ambient = Color3.fromRGB(82, 72, 84)
        Lighting.OutdoorAmbient = Color3.fromRGB(92, 74, 88)
        Lighting.EnvironmentDiffuseScale = 0.58
        Lighting.EnvironmentSpecularScale = 0.84
        lightMultiplier = 1.18
    else
        -- Keep the night cinematic, but prevent black crush on mobile.
        Lighting.Brightness = 2.10
        Lighting.ExposureCompensation = 0.20
        Lighting.Ambient = Color3.fromRGB(72, 80, 104)
        Lighting.OutdoorAmbient = Color3.fromRGB(52, 60, 84)
        Lighting.EnvironmentDiffuseScale = 0.58
        Lighting.EnvironmentSpecularScale = 0.88
        lightMultiplier = 1.80
    end

    local atmosphere = Lighting:FindFirstChild("HangarThinFog")
    if atmosphere and atmosphere:IsA("Atmosphere") then
        atmosphere.Density = period == "DAY" and 0.026 or 0.016
        atmosphere.Haze = period == "DAY" and 0.08 or 0.055
    end

    local cc = Lighting:FindFirstChild("HangarPhase2Grade")
    if cc and cc:IsA("ColorCorrectionEffect") then
        if period == "DAY" then
            cc.Brightness = 0
            cc.Contrast = 0.08
            cc.Saturation = 0.03
            cc.TintColor = Color3.fromRGB(255, 250, 244)
        elseif period == "DAWN" or period == "DUSK" then
            cc.Brightness = 0.02
            cc.Contrast = 0.08
            cc.Saturation = 0.05
            cc.TintColor = Color3.fromRGB(255, 228, 214)
        else
            cc.Brightness = 0.045
            cc.Contrast = 0.055
            cc.Saturation = 0.06
            cc.TintColor = Color3.fromRGB(226, 234, 255)
        end
    end

    local bloom = Lighting:FindFirstChild("HangarPhase2Bloom")
    if bloom and bloom:IsA("BloomEffect") then
        bloom.Intensity = period == "NIGHT" and 0.10 or 0.06
        bloom.Threshold = period == "NIGHT" and 1.85 or 2.1
    end

    tunePhase2Lights(lightMultiplier)
    applyMeshReadability(period)
    ensureReadabilityLights(period)

    Workspace:SetAttribute("HangarTimeAuthority", "REALTIME_WITA_UTC_PLUS_8")
    Workspace:SetAttribute("HangarWITAClockTime", clock)
    Workspace:SetAttribute("HangarWITAPeriod", period)
    Workspace:SetAttribute("HangarCelestialBodies", "SUN_AND_MOON_ENABLED")
    Workspace:SetAttribute("HangarNightReadability", "V1_1_BLACK_CRUSH_REDUCED")
    Workspace:SetAttribute("HangarEntranceSightline", "DONOR_GATE_FADED_FOR_JET_VIEW")
end

applyWITA()

task.spawn(function()
    -- Environment/mesh arrives asynchronously; re-apply tightly during boot, then maintain WITA time.
    for _ = 1, 12 do
        task.wait(0.75)
        applyWITA()
    end
    while true do
        task.wait(20)
        applyWITA()
    end
end)

print("[HANGAR] realtime WITA v1.1 active; night readability + sun/moon enabled")
