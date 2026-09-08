-- AEROCLUB HANGAR — VISUAL BOOTSTRAP v1.1
-- LAB ONLY. Purpose: prove the rebuilt environment renders before systems/UI are re-enabled.
-- LIVE target must remain untouched.

local InsertService = game:GetService("InsertService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local MODEL_ASSET_ID = 138364957741127

Workspace:SetAttribute("AeroClubVisualBootstrap", "V1_1")
Workspace:SetAttribute("AeroClubEnvironmentReady", false)
Workspace:SetAttribute("AeroClubVisualQC", "BOOTING")

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

-- Never let a deprecated/non-scriptable lighting property kill the runtime.
Lighting.ClockTime = 0.3
Lighting.Brightness = 2.15
Lighting.ExposureCompensation = 0.08
Lighting.Ambient = Color3.fromRGB(34, 37, 48)
Lighting.OutdoorAmbient = Color3.fromRGB(8, 10, 17)
Lighting.EnvironmentDiffuseScale = 0.5
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true

for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("Atmosphere") then child:Destroy() end
end
local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "AeroClubVolumetricFog"
atmosphere.Density = 0.12
atmosphere.Offset = 0.03
atmosphere.Color = Color3.fromRGB(95, 105, 128)
atmosphere.Decay = Color3.fromRGB(18, 22, 32)
atmosphere.Glare = 0.03
atmosphere.Haze = 0.55
atmosphere.Parent = Lighting

-- Spawn exists BEFORE any asset call, so a load failure can never drop the player into empty sky.
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
spawn.CFrame = CFrame.new(0, 1, -105)
spawn.Material = Enum.Material.SmoothPlastic

-- Invisible boot floor. This is collision safety only, never visual art.
local bootFloor = Workspace:FindFirstChild("AeroClubBootFloor")
if not bootFloor then
    bootFloor = Instance.new("Part")
    bootFloor.Name = "AeroClubBootFloor"
    bootFloor.Parent = Workspace
end
bootFloor.Anchored = true
bootFloor.Transparency = 1
bootFloor.CanCollide = true
bootFloor.CanTouch = false
bootFloor.Size = Vector3.new(390, 2, 340)
bootFloor.CFrame = CFrame.new(0, -1, 0)

for _, child in ipairs(environment:GetChildren()) do child:Destroy() end

local ok, loaded = pcall(InsertService.LoadAsset, InsertService, MODEL_ASSET_ID)
if not ok or not loaded then
    Workspace:SetAttribute("AeroClubVisualQC", "ASSET_LOAD_FAILED")
    warn("[AEROCLUB V1.1] LoadAsset failed", MODEL_ASSET_ID, loaded)
    return
end

loaded.Name = "AeroClubStaticMeshV1_1"
local expected = {
    HangarMesh=false,
    HangarTrussMesh=false,
    PolishedConcreteMesh=false,
    JetPlaneMesh=false,
    JetGlassAndTrimMesh=false,
    JetVIPLoungeMesh=false,
    JetWingStagesMesh=false,
    InteractiveZoneMesh=false,
    PerimeterTrackMesh=false,
    DonorGateAndPedestalsMesh=false,
    LightingFixtureMesh=false,
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
        warn("[AEROCLUB V1.1] required mesh missing", name)
        return
    end
end

loaded.Parent = environment
local boxCF, size = loaded:GetBoundingBox()
-- Actual generated map is ~390 wide and ~460 deep because outdoor zones extend beyond the 340-stud hangar shell.
if size.X < 370 or size.X > 430 or size.Z < 430 or size.Z > 500 or size.Y < 120 or size.Y > 170 then
    loaded:Destroy()
    Workspace:SetAttribute("AeroClubVisualQC", "BOUNDS_REJECTED")
    warn("[AEROCLUB V1.1] bounds rejected", size)
    return
end

-- Keep generator coordinates authoritative. Only reject absurd displacement.
if math.abs(boxCF.Position.X) > 40 or math.abs(boxCF.Position.Z) > 100 then
    loaded:Destroy()
    Workspace:SetAttribute("AeroClubVisualQC", "PIVOT_REJECTED")
    warn("[AEROCLUB V1.1] model pivot unexpected", boxCF.Position)
    return
end

-- Collision envelope aligned to the GDD map.
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
collider("OutdoorFloor", Vector3.new(382,3,150), CFrame.new(0,-1.5,-245))
collider("LeftWall", Vector3.new(6,92,340), CFrame.new(-195,46,0))
collider("RightWall", Vector3.new(6,92,340), CFrame.new(195,46,0))
collider("BackWall", Vector3.new(390,92,6), CFrame.new(0,46,170))
collider("JetVIPFloor", Vector3.new(10,1,50), CFrame.new(0,7,96))
collider("JetLeftWingStage", Vector3.new(37,2,18), CFrame.new(-31,10,88))
collider("JetRightWingStage", Vector3.new(37,2,18), CFrame.new(31,10,88))

Workspace:SetAttribute("AeroClubEnvironmentReady", true)
Workspace:SetAttribute("AeroClubVisualQC", "READY_FOR_SCREENSHOT")
Workspace:SetAttribute("AeroClubStaticMeshCount", meshCount)
Workspace:SetAttribute("AeroClubMeshAssetId", MODEL_ASSET_ID)
print("[AEROCLUB V1.1] VISUAL READY", MODEL_ASSET_ID, meshCount, size, boxCF.Position)
