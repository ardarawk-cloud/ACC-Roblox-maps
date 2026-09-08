-- HANGAR — PHASE 2 VISUAL POLISH v1.4
-- Environment-only polish: exposure, material readability, entrance sightline, jet focal lighting.
-- No roles, UI, monetization, dance systems, lasers, or visible fallback.

local InsertService = game:GetService("InsertService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local MODEL_ASSET_ID = 99386261031802
local SPAWN_POS = Vector3.new(0, 6, 325)
local JET_TARGET = Vector3.new(0, 10, -58)

Workspace:SetAttribute("HangarRuntime", "V1_4_PHASE2_VISUAL_POLISH")
Workspace:SetAttribute("HangarEnvironmentReady", false)
Workspace:SetAttribute("HangarVisualQC", "BOOTING")
Workspace:SetAttribute("HangarModelAssetId", MODEL_ASSET_ID)
Workspace:SetAttribute("HangarPhase", "PHASE_2_ENVIRONMENT_VISUAL_POLISH")

local function ensureFolder(parent, name)
    local found = parent:FindFirstChild(name)
    if found and found:IsA("Folder") then return found end
    if found then found:Destroy() end
    local f = Instance.new("Folder")
    f.Name = name
    f.Parent = parent
    return f
end

local environment = ensureFolder(Workspace, "Environment")
ensureFolder(Workspace, "InteractiveZones")
ensureFolder(Workspace, "LightingEquipment")
ensureFolder(Workspace, "Statues")
for _, child in ipairs(environment:GetChildren()) do child:Destroy() end

-- Phase 2 lighting: deliberately reduce the white blowout seen in owner mobile QC.
Lighting.ClockTime = 0.35
Lighting.Brightness = 1.55
Lighting.ExposureCompensation = -0.18
Lighting.Ambient = Color3.fromRGB(36, 42, 56)
Lighting.OutdoorAmbient = Color3.fromRGB(18, 22, 32)
Lighting.EnvironmentDiffuseScale = 0.42
Lighting.EnvironmentSpecularScale = 0.72
Lighting.GlobalShadows = true

for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("Atmosphere") or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") then
        child:Destroy()
    end
end

local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "HangarThinFog"
atmosphere.Density = 0.022
atmosphere.Offset = 0.02
atmosphere.Color = Color3.fromRGB(108, 122, 150)
atmosphere.Decay = Color3.fromRGB(12, 16, 26)
atmosphere.Glare = 0
atmosphere.Haze = 0.10
atmosphere.Parent = Lighting

local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "HangarPhase2Grade"
cc.Brightness = -0.03
cc.Contrast = 0.18
cc.Saturation = 0.04
cc.TintColor = Color3.fromRGB(218, 228, 248)
cc.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Name = "HangarPhase2Bloom"
bloom.Intensity = 0.07
bloom.Size = 18
bloom.Threshold = 2.1
bloom.Parent = Lighting

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
safetyFloor("HangarBootFloorOutdoor", Vector3.new(390,2,210), CFrame.new(0,-1,270))

local ok, loaded = pcall(InsertService.LoadAsset, InsertService, MODEL_ASSET_ID)
if not ok or not loaded then
    Workspace:SetAttribute("HangarVisualQC", "FULL_MESH_ASSET_LOAD_FAILED")
    warn("[HANGAR V1.4] LoadAsset failed", MODEL_ASSET_ID, loaded)
    return
end
loaded.Name = "HangarStaticMeshV1_4"

local expected = {
    HangarMesh=false, HangarTrussMesh=false, PolishedConcreteMesh=false,
    OutdoorApronMesh=false, DanceFloorMesh=false, JetPlaneMesh=false,
    JetGlassAndTrimMesh=false, JetVIPLoungeMesh=false, JetWingStagesMesh=false,
    BaggageClaimMesh=false, PhotoboothMesh=false, CornerShopMesh=false,
    DonorGateAndPedestalsMesh=false,
}

local style = {
    HangarMesh={Enum.Material.Metal, Color3.fromRGB(46,52,64),0},
    HangarTrussMesh={Enum.Material.Metal, Color3.fromRGB(68,78,96),0},
    PolishedConcreteMesh={Enum.Material.Concrete, Color3.fromRGB(72,76,84),0},
    OutdoorApronMesh={Enum.Material.Concrete, Color3.fromRGB(55,59,67),0},
    DanceFloorMesh={Enum.Material.SmoothPlastic, Color3.fromRGB(24,30,40),0},
    JetPlaneMesh={Enum.Material.Metal, Color3.fromRGB(170,180,195),0},
    JetGlassAndTrimMesh={Enum.Material.Glass, Color3.fromRGB(12,28,44),0.12},
    JetVIPLoungeMesh={Enum.Material.SmoothPlastic, Color3.fromRGB(38,42,50),0},
    JetWingStagesMesh={Enum.Material.SmoothPlastic, Color3.fromRGB(30,34,42),0},
    BaggageClaimMesh={Enum.Material.Metal, Color3.fromRGB(42,46,54),0},
    PhotoboothMesh={Enum.Material.Metal, Color3.fromRGB(52,36,62),0},
    CornerShopMesh={Enum.Material.Metal, Color3.fromRGB(72,48,32),0},
    DonorGateAndPedestalsMesh={Enum.Material.Metal, Color3.fromRGB(38,42,52),0.18},
    GoldPedestalMesh={Enum.Material.Metal, Color3.fromRGB(190,142,48),0},
    SilverPedestalMesh={Enum.Material.Metal, Color3.fromRGB(142,154,174),0},
    BronzePedestalMesh={Enum.Material.Metal, Color3.fromRGB(142,82,44),0},
    ClassicCarLeftA={Enum.Material.Metal, Color3.fromRGB(150,48,44),0},
    ClassicCarLeftB={Enum.Material.Metal, Color3.fromRGB(52,78,148),0},
    HypercarRightA={Enum.Material.Metal, Color3.fromRGB(220,224,232),0},
    HypercarRightB={Enum.Material.Metal, Color3.fromRGB(148,44,56),0},
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
        d.DoubleSided = true
        local s = style[d.Name]
        if s then
            d.Material = s[1]
            d.Color = s[2]
            d.Transparency = s[3]
        end
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
        warn("[HANGAR V1.4] required mesh missing", name)
        return
    end
end

loaded.Parent = environment
local boxCF, size = loaded:GetBoundingBox()
if size.X < 370 or size.X > 430 or size.Z < 450 or size.Z > 540 or size.Y < 120 or size.Y > 180 then
    loaded:Destroy()
    Workspace:SetAttribute("HangarVisualQC", "BOUNDS_REJECTED")
    return
end

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
collider("OutdoorFloor", Vector3.new(382,3,200), CFrame.new(0,-1.5,270))
collider("LeftWall", Vector3.new(6,92,340), CFrame.new(-195,46,0))
collider("RightWall", Vector3.new(6,92,340), CFrame.new(195,46,0))
collider("BackWall", Vector3.new(390,92,6), CFrame.new(0,46,-170))
collider("JetVIPFloor", Vector3.new(10,1,46), CFrame.new(0,8,-68))
collider("JetLeftWingStage", Vector3.new(42,2,20), CFrame.new(-35,10,-56))
collider("JetRightWingStage", Vector3.new(42,2,20), CFrame.new(35,10,-56))

local lights = Instance.new("Folder")
lights.Name = "HangarPhase2Lights"
lights.Parent = environment
local function point(pos, color, brightness, range)
    local a = Instance.new("Part")
    a.Name = "LightAnchor"
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

-- Soft architectural fills. No lasers.
for _, z in ipairs({120,55,-20,-90}) do
    point(Vector3.new(-125,68,z), Color3.fromRGB(150,178,220), 0.55, 72)
    point(Vector3.new(125,68,z), Color3.fromRGB(150,178,220), 0.55, 72)
end
-- Entrance readable but not blown out.
point(Vector3.new(-115,20,225), Color3.fromRGB(255,172,118), 0.55, 60)
point(Vector3.new(115,20,225), Color3.fromRGB(120,170,255), 0.55, 60)
-- Jet focal lighting.
point(Vector3.new(-34,28,-58), Color3.fromRGB(130,190,255), 1.05, 70)
point(Vector3.new(34,28,-58), Color3.fromRGB(255,150,205), 0.85, 70)
point(Vector3.new(0,42,-82), Color3.fromRGB(210,225,255), 0.85, 62)
-- Dance floor separation.
point(Vector3.new(0,22,20), Color3.fromRGB(82,160,220), 0.45, 58)

Workspace:SetAttribute("HangarEnvironmentReady", true)
Workspace:SetAttribute("HangarVisualQC", "READY_PHASE2_OWNER_SCREENSHOT")
Workspace:SetAttribute("HangarStaticMeshCount", meshCount)
Workspace:SetAttribute("HangarSpawnSequence", "ACTUAL_FRONT_PLUS_Z_TO_CENTRAL_JET")
Workspace:SetAttribute("HangarVisibleFallback", "NONE")
Workspace:SetAttribute("HangarLaserQC", "DISABLED_PHASE2")
print("[HANGAR V1.4] PHASE 2 VISUAL POLISH READY", MODEL_ASSET_ID, meshCount, size, boxCF.Position)
