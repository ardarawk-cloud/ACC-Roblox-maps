-- AEROCLUB HANGAR — VISUAL BOOTSTRAP v1.2
-- LAB ONLY. Layout-readability QC. LIVE target must remain untouched.

local InsertService = game:GetService("InsertService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local MODEL_ASSET_ID = 0 -- AEROCLUB_V12_MODEL_ASSET_ID

Workspace:SetAttribute("AeroClubVisualBootstrap", "V1_2_LAYOUT_READABILITY")
Workspace:SetAttribute("AeroClubEnvironmentReady", false)
Workspace:SetAttribute("AeroClubVisualQC", "BOOTING")
Workspace:SetAttribute("AeroClubLivePublishAllowed", false)

local function ensureFolder(parent, name)
    local f = parent:FindFirstChild(name)
    if f and f:IsA("Folder") then return f end
    if f then f:Destroy() end
    f = Instance.new("Folder")
    f.Name = name
    f.Parent = parent
    return f
end

local environment = ensureFolder(Workspace, "Environment")
ensureFolder(Workspace, "InteractiveZones")
ensureFolder(Workspace, "LightingEquipment")
ensureFolder(Workspace, "Statues")

-- Brighter night QC: preserve night mood while making forms readable on mobile.
Lighting.ClockTime = 0.45
Lighting.Brightness = 3.1
Lighting.ExposureCompensation = 0.42
Lighting.Ambient = Color3.fromRGB(72, 78, 96)
Lighting.OutdoorAmbient = Color3.fromRGB(34, 40, 58)
Lighting.EnvironmentDiffuseScale = 0.68
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true

for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("Atmosphere") or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") then
        child:Destroy()
    end
end

local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "AeroClubVolumetricFog"
atmosphere.Density = 0.055
atmosphere.Offset = 0.02
atmosphere.Color = Color3.fromRGB(120, 132, 158)
atmosphere.Decay = Color3.fromRGB(20, 24, 36)
atmosphere.Glare = 0.02
atmosphere.Haze = 0.28
atmosphere.Parent = Lighting

local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "AeroClubQCGrade"
cc.Brightness = 0.05
cc.Contrast = 0.08
cc.Saturation = 0.08
cc.TintColor = Color3.fromRGB(224, 232, 255)
cc.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Name = "AeroClubQCBloom"
bloom.Intensity = 0.18
bloom.Size = 24
bloom.Threshold = 1.6
bloom.Parent = Lighting

-- Spawn outside, facing the hangar entrance so the map reads in the intended sequence.
local spawn = Workspace:FindFirstChild("AeroClubSpawn")
if not spawn then
    spawn = Instance.new("SpawnLocation")
    spawn.Name = "AeroClubSpawn"
    spawn.Parent = Workspace
end
spawn.Anchored = true
spawn.Neutral = true
spawn.Transparency = 1
spawn.CanCollide = true
spawn.Size = Vector3.new(14, 1, 14)
spawn.CFrame = CFrame.lookAt(Vector3.new(0, 1, -305), Vector3.new(0, 1, -150))
spawn.Material = Enum.Material.SmoothPlastic

local function safetyFloor(name, size, cf)
    local p = Workspace:FindFirstChild(name)
    if not p then
        p = Instance.new("Part")
        p.Name = name
        p.Parent = Workspace
    end
    p.Anchored = true
    p.Transparency = 1
    p.CanCollide = true
    p.CanTouch = false
    p.CanQuery = true
    p.Size = size
    p.CFrame = cf
    return p
end

safetyFloor("AeroClubBootFloorIndoor", Vector3.new(390, 2, 340), CFrame.new(0, -1, 0))
safetyFloor("AeroClubBootFloorOutdoor", Vector3.new(390, 2, 170), CFrame.new(0, -1, -255))

for _, child in ipairs(environment:GetChildren()) do child:Destroy() end

if MODEL_ASSET_ID <= 0 then
    Workspace:SetAttribute("AeroClubVisualQC", "ASSET_ID_NOT_INJECTED")
    warn("[AEROCLUB V1.2] model asset id not injected")
    return
end

local ok, loaded = pcall(InsertService.LoadAsset, InsertService, MODEL_ASSET_ID)
if not ok or not loaded then
    Workspace:SetAttribute("AeroClubVisualQC", "ASSET_LOAD_FAILED")
    warn("[AEROCLUB V1.2] LoadAsset failed", MODEL_ASSET_ID, loaded)
    return
end

loaded.Name = "AeroClubStaticMeshV1_2"
local expected = {
    HangarMesh=false,
    HangarTrussMesh=false,
    PolishedConcreteMesh=false,
    OutdoorApronMesh=false,
    DanceFloorMesh=false,
    JetPlaneMesh=false,
    JetGlassAndTrimMesh=false,
    JetVIPLoungeMesh=false,
    JetWingStagesMesh=false,
    BaggageClaimMesh=false,
    PhotoboothMesh=false,
    CornerShopMesh=false,
    DonorGateAndPedestalsMesh=false,
}

local meshCount = 0
for _, d in ipairs(loaded:GetDescendants()) do
    if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Sound") then
        d:Destroy()
    elseif d:IsA("MeshPart") then
        meshCount += 1
        if expected[d.Name] ~= nil then expected[d.Name] = true end
        d.Anchored = true
        d.CanCollide = false
        d.CanTouch = false
        d.CanQuery = true
        d.CastShadow = true
    elseif d:IsA("BasePart") then
        d.Anchored = true
        d.CanCollide = false
        d.CanTouch = false
    end
end

for name, found in pairs(expected) do
    if not found then
        loaded:Destroy()
        Workspace:SetAttribute("AeroClubVisualQC", "MISSING_" .. name)
        warn("[AEROCLUB V1.2] required mesh missing", name)
        return
    end
end

loaded.Parent = environment
local boxCF, size = loaded:GetBoundingBox()
if size.X < 370 or size.X > 430 or size.Z < 450 or size.Z > 520 or size.Y < 120 or size.Y > 175 then
    loaded:Destroy()
    Workspace:SetAttribute("AeroClubVisualQC", "BOUNDS_REJECTED")
    warn("[AEROCLUB V1.2] bounds rejected", size)
    return
end

if math.abs(boxCF.Position.X) > 45 or math.abs(boxCF.Position.Z) > 100 then
    loaded:Destroy()
    Workspace:SetAttribute("AeroClubVisualQC", "PIVOT_REJECTED")
    warn("[AEROCLUB V1.2] model pivot unexpected", boxCF.Position)
    return
end

-- Invisible collision envelope aligned to the GDD layout.
local collisions = Instance.new("Folder")
collisions.Name = "Collision"
collisions.Parent = environment
local function collider(name, size3, cf)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Transparency = 1
    p.CanCollide = true
    p.CanTouch = false
    p.CanQuery = true
    p.Size = size3
    p.CFrame = cf
    p.Parent = collisions
end
collider("HangarFloor", Vector3.new(382,3,332), CFrame.new(0,-1.5,0))
collider("OutdoorFloor", Vector3.new(382,3,164), CFrame.new(0,-1.5,-252))
collider("LeftWall", Vector3.new(6,92,340), CFrame.new(-195,46,0))
collider("RightWall", Vector3.new(6,92,340), CFrame.new(195,46,0))
collider("BackWall", Vector3.new(390,92,6), CFrame.new(0,46,170))
collider("JetVIPFloor", Vector3.new(10,1,46), CFrame.new(0,8,68))
collider("JetLeftWingStage", Vector3.new(42,2,20), CFrame.new(-35,10,56))
collider("JetRightWingStage", Vector3.new(42,2,20), CFrame.new(35,10,56))

-- Neutral fill lights for visual QC only. No lasers/effects in this pass.
local lights = Instance.new("Folder")
lights.Name = "QCFillLights"
lights.Parent = environment
local function fillLight(name, pos, color, brightness, range)
    local anchor = Instance.new("Part")
    anchor.Name = name
    anchor.Anchored = true
    anchor.Transparency = 1
    anchor.CanCollide = false
    anchor.CanTouch = false
    anchor.CanQuery = false
    anchor.Size = Vector3.one
    anchor.CFrame = CFrame.new(pos)
    anchor.Parent = lights
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Shadows = false
    light.Parent = anchor
end

for _, z in ipairs({-125,-55,20,85,135}) do
    fillLight("HangarFill", Vector3.new(-115,72,z), Color3.fromRGB(190,210,255), 2.0, 95)
    fillLight("HangarFill", Vector3.new(115,72,z), Color3.fromRGB(190,210,255), 2.0, 95)
end
fillLight("JetKey", Vector3.new(0,48,36), Color3.fromRGB(210,225,255), 3.1, 115)
fillLight("DanceFill", Vector3.new(0,28,-25), Color3.fromRGB(120,220,255), 1.4, 80)
fillLight("OutdoorLeft", Vector3.new(-115,24,-235), Color3.fromRGB(255,190,145), 1.6, 78)
fillLight("OutdoorRight", Vector3.new(115,24,-235), Color3.fromRGB(145,190,255), 1.6, 78)
fillLight("EntranceFill", Vector3.new(0,42,-150), Color3.fromRGB(220,225,255), 2.0, 90)

Workspace:SetAttribute("AeroClubEnvironmentReady", true)
Workspace:SetAttribute("AeroClubVisualQC", "READY_FOR_LAYOUT_SCREENSHOT")
Workspace:SetAttribute("AeroClubStaticMeshCount", meshCount)
Workspace:SetAttribute("AeroClubMeshAssetId", MODEL_ASSET_ID)
Workspace:SetAttribute("AeroClubSpawnSequence", "OUTDOOR_TO_GATE_TO_DANCE_TO_JET")
Workspace:SetAttribute("AeroClubLaserQC", "DISABLED_FOR_LAYOUT_PASS")
print("[AEROCLUB V1.2] LAYOUT VISUAL READY", MODEL_ASSET_ID, meshCount, size, boxCF.Position)
