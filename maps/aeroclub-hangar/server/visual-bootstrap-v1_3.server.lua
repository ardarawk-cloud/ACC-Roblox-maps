-- HANGAR — FULL MESH RUNTIME v1.3
-- Active environment authority. No visible Part fallback.
-- Fixed approved asset is committed in source so publish no longer rewrites this script.

local InsertService = game:GetService("InsertService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local MODEL_ASSET_ID = 99386261031802 -- HANGAR_V13_MODEL_ASSET_ID
local SPAWN_POS = Vector3.new(0, 6, -325)
local JET_TARGET = Vector3.new(0, 10, 58)

Workspace:SetAttribute("HangarRuntime", "V1_3_FIXED_ASSET_NO_BOM")
Workspace:SetAttribute("HangarEnvironmentReady", false)
Workspace:SetAttribute("HangarVisualQC", "BOOTING")
Workspace:SetAttribute("HangarModelAssetId", MODEL_ASSET_ID)

local function ensureFolder(parent, name)
    local found = parent:FindFirstChild(name)
    if found and found:IsA("Folder") then return found end
    if found then found:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent
    return folder
end

local environment = ensureFolder(Workspace, "Environment")
ensureFolder(Workspace, "InteractiveZones")
ensureFolder(Workspace, "LightingEquipment")
ensureFolder(Workspace, "Statues")

for _, child in ipairs(environment:GetChildren()) do child:Destroy() end

-- Readable night-club lighting for mobile QC. This executes before any asset call.
Lighting.ClockTime = 0.35
Lighting.Brightness = 3.25
Lighting.ExposureCompensation = 0.48
Lighting.Ambient = Color3.fromRGB(78, 84, 104)
Lighting.OutdoorAmbient = Color3.fromRGB(38, 44, 62)
Lighting.EnvironmentDiffuseScale = 0.70
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true

for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("Atmosphere") or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") then
        child:Destroy()
    end
end

local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "HangarVolumetricFog"
atmosphere.Density = 0.045
atmosphere.Offset = 0.01
atmosphere.Color = Color3.fromRGB(120, 132, 158)
atmosphere.Decay = Color3.fromRGB(18, 22, 34)
atmosphere.Glare = 0.01
atmosphere.Haze = 0.20
atmosphere.Parent = Lighting

local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "HangarGrade"
cc.Brightness = 0.05
cc.Contrast = 0.09
cc.Saturation = 0.08
cc.TintColor = Color3.fromRGB(226, 233, 255)
cc.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Name = "HangarBloom"
bloom.Intensity = 0.16
bloom.Size = 22
bloom.Threshold = 1.75
bloom.Parent = Lighting

-- Real spawn marker; spawn-safety uses the exact same point.
local spawn = Workspace:FindFirstChild("HangarSpawn")
if not spawn then
    spawn = Instance.new("SpawnLocation")
    spawn.Name = "HangarSpawn"
    spawn.Parent = Workspace
end
spawn.Anchored = true
spawn.Neutral = true
spawn.Transparency = 1
spawn.CanCollide = true
spawn.Size = Vector3.new(14, 1, 14)
spawn.CFrame = CFrame.lookAt(Vector3.new(SPAWN_POS.X, 1, SPAWN_POS.Z), Vector3.new(JET_TARGET.X, 1, JET_TARGET.Z))

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
end
safetyFloor("HangarBootFloorIndoor", Vector3.new(390,2,340), CFrame.new(0,-1,0))
safetyFloor("HangarBootFloorOutdoor", Vector3.new(390,2,210), CFrame.new(0,-1,-270))

local ok, loaded = pcall(InsertService.LoadAsset, InsertService, MODEL_ASSET_ID)
if not ok or not loaded then
    Workspace:SetAttribute("HangarVisualQC", "FULL_MESH_ASSET_LOAD_FAILED")
    warn("[HANGAR V1.3] LoadAsset failed", MODEL_ASSET_ID, loaded)
    return
end

loaded.Name = "HangarStaticMeshV1_3"
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
        Workspace:SetAttribute("HangarVisualQC", "MISSING_" .. name)
        warn("[HANGAR V1.3] required mesh missing", name)
        return
    end
end

loaded.Parent = environment
local boxCF, size = loaded:GetBoundingBox()
if size.X < 370 or size.X > 430 or size.Z < 450 or size.Z > 540 or size.Y < 120 or size.Y > 180 then
    loaded:Destroy()
    Workspace:SetAttribute("HangarVisualQC", "BOUNDS_REJECTED")
    warn("[HANGAR V1.3] bounds rejected", size)
    return
end
if math.abs(boxCF.Position.X) > 50 or math.abs(boxCF.Position.Z) > 110 then
    loaded:Destroy()
    Workspace:SetAttribute("HangarVisualQC", "PIVOT_REJECTED")
    warn("[HANGAR V1.3] pivot rejected", boxCF.Position)
    return
end

-- Invisible collisions aligned to the GDD. They are physics only, not visual fallback art.
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
collider("OutdoorFloor", Vector3.new(382,3,200), CFrame.new(0,-1.5,-270))
collider("LeftWall", Vector3.new(6,92,340), CFrame.new(-195,46,0))
collider("RightWall", Vector3.new(6,92,340), CFrame.new(195,46,0))
collider("BackWall", Vector3.new(390,92,6), CFrame.new(0,46,170))
collider("JetVIPFloor", Vector3.new(10,1,46), CFrame.new(0,8,68))
collider("JetLeftWingStage", Vector3.new(42,2,20), CFrame.new(-35,10,56))
collider("JetRightWingStage", Vector3.new(42,2,20), CFrame.new(35,10,56))

-- Practical fill only. No fake laser bars.
local lights = Instance.new("Folder")
lights.Name = "HangarFillLights"
lights.Parent = environment
local function fill(pos, color, brightness, range)
    local a = Instance.new("Part")
    a.Name = "Fill"
    a.Anchored = true
    a.Transparency = 1
    a.CanCollide = false
    a.CanTouch = false
    a.CanQuery = false
    a.Size = Vector3.one
    a.CFrame = CFrame.new(pos)
    a.Parent = lights
    local l = Instance.new("PointLight")
    l.Color = color
    l.Brightness = brightness
    l.Range = range
    l.Shadows = false
    l.Parent = a
end
for _, z in ipairs({-125,-55,20,85,135}) do
    fill(Vector3.new(-115,72,z), Color3.fromRGB(190,210,255), 2.0, 95)
    fill(Vector3.new(115,72,z), Color3.fromRGB(190,210,255), 2.0, 95)
end
fill(Vector3.new(0,48,36), Color3.fromRGB(215,228,255), 3.2, 120)
fill(Vector3.new(0,30,-30), Color3.fromRGB(120,220,255), 1.3, 80)
fill(Vector3.new(-115,24,-235), Color3.fromRGB(255,190,145), 1.5, 78)
fill(Vector3.new(115,24,-235), Color3.fromRGB(145,190,255), 1.5, 78)
fill(Vector3.new(0,42,-150), Color3.fromRGB(225,230,255), 2.1, 90)

Workspace:SetAttribute("HangarEnvironmentReady", true)
Workspace:SetAttribute("HangarVisualQC", "READY_OWNER_RUNTIME_QC")
Workspace:SetAttribute("HangarStaticMeshCount", meshCount)
Workspace:SetAttribute("HangarModelAssetId", MODEL_ASSET_ID)
Workspace:SetAttribute("HangarSpawnSequence", "FAR_OUTDOOR_FACE_CENTRAL_JET")
Workspace:SetAttribute("HangarVisibleFallback", "NONE")
print("[HANGAR V1.3] FULL MESH READY", MODEL_ASSET_ID, meshCount, size, boxCF.Position)
