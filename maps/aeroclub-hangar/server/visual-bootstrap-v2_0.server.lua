-- HANGAR — ENVIRONMENT REALISM REBUILD v2.1
-- Runtime QC correction: solid collision for real scene objects, remove non-GDD service clutter,
-- align walk surfaces to visible mesh tops, and keep floating QC billboards removed.
-- WITA remains separate. No gameplay/UI/monetization/lasers.

local InsertService = game:GetService("InsertService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local MODEL_ASSET_ID = 0 -- HANGAR_V20_REALISM_MODEL_ASSET_ID
local SPAWN_POS = Vector3.new(0, 6, 325)
local JET_TARGET = Vector3.new(0, 11, -66)

Workspace:SetAttribute("HangarRuntime", "V2_1_ENVIRONMENT_REALISM_SOLID_COLLISION")
Workspace:SetAttribute("HangarPhase", "PHASE_2_ENVIRONMENT_REALISM_REBUILD")
Workspace:SetAttribute("HangarEnvironmentReady", false)
Workspace:SetAttribute("HangarVisualQC", "BOOTING")
Workspace:SetAttribute("HangarModelAssetId", MODEL_ASSET_ID)
Workspace:SetAttribute("HangarVisibleFallback", "NONE")
Workspace:SetAttribute("HangarLaserQC", "DISABLED_REALISM_PASS")
Workspace:SetAttribute("HangarCollisionAuthority", "V2_1_SOLID_SCENE_OBJECTS")
Workspace:SetAttribute("HangarNonGDDClutter", "SERVICE_EQUIPMENT_HIDDEN")
Workspace:SetAttribute("HangarZoneSignage", "FLOATING_QC_BILLBOARDS_REMOVED")
Workspace:SetAttribute("HangarWalkSurfaceAlignment", "VISUAL_MESH_TOPS")

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

Lighting.Brightness = 1.8
Lighting.ExposureCompensation = 0.04
Lighting.Ambient = Color3.fromRGB(60, 66, 82)
Lighting.OutdoorAmbient = Color3.fromRGB(44, 50, 68)
Lighting.EnvironmentDiffuseScale = 0.54
Lighting.EnvironmentSpecularScale = 0.90
Lighting.GlobalShadows = true

for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("Atmosphere") or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") then
        child:Destroy()
    end
end

local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "HangarThinFog"
atmosphere.Density = 0.016
atmosphere.Offset = 0.02
atmosphere.Color = Color3.fromRGB(118, 132, 158)
atmosphere.Decay = Color3.fromRGB(14, 18, 30)
atmosphere.Glare = 0
atmosphere.Haze = 0.055
atmosphere.Parent = Lighting

local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "HangarPhase2Grade"
cc.Brightness = 0.02
cc.Contrast = 0.07
cc.Saturation = 0.05
cc.TintColor = Color3.fromRGB(226, 234, 255)
cc.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Name = "HangarPhase2Bloom"
bloom.Intensity = 0.08
bloom.Size = 18
bloom.Threshold = 1.95
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
-- Match the visible imported floor tops: indoor +0.40, outdoor +0.30.
safetyFloor("HangarBootFloorIndoor", Vector3.new(420, 2, 380), CFrame.new(0, -0.60, 0))
safetyFloor("HangarBootFloorOutdoor", Vector3.new(440, 2, 220), CFrame.new(0, -0.70, 285))

local ok, loaded = pcall(InsertService.LoadAsset, InsertService, MODEL_ASSET_ID)
if not ok or not loaded then
    Workspace:SetAttribute("HangarVisualQC", "REALISM_ASSET_LOAD_FAILED")
    warn("[HANGAR V2.1] LoadAsset failed", MODEL_ASSET_ID, loaded)
    return
end
loaded.Name = "HangarStaticMeshV2_1"

local expected = {
    HangarMesh=false, HangarTrussMesh=false, PolishedConcreteMesh=false, OutdoorApronMesh=false,
    ApronMarkingsMesh=false, DanceFloorMesh=false, JetPlaneMesh=false, JetGlassAndTrimMesh=false,
    JetEngineMesh=false, JetLandingGearMesh=false, JetVIPLoungeMesh=false, JetWingStagesMesh=false,
    ClassicCarLeftA=false, ClassicCarLeftB=false, HypercarRightA=false, HypercarRightB=false,
    BaggageClaimMesh=false, PhotoboothMesh=false, CornerShopMesh=false,
    DonorGateAndPedestalsMesh=false, ServiceEquipmentMesh=false,
}

local style = {
    HangarMesh={Enum.Material.Metal, Color3.fromRGB(42,48,60)},
    HangarTrussMesh={Enum.Material.Metal, Color3.fromRGB(78,88,108)},
    PolishedConcreteMesh={Enum.Material.Concrete, Color3.fromRGB(80,82,88)},
    OutdoorApronMesh={Enum.Material.Concrete, Color3.fromRGB(66,68,74)},
    ApronMarkingsMesh={Enum.Material.SmoothPlastic, Color3.fromRGB(184,146,40)},
    DanceFloorMesh={Enum.Material.SmoothPlastic, Color3.fromRGB(30,38,52)},
    JetPlaneMesh={Enum.Material.Metal, Color3.fromRGB(168,178,194)},
    JetEngineMesh={Enum.Material.Metal, Color3.fromRGB(60,66,76)},
    JetLandingGearMesh={Enum.Material.Metal, Color3.fromRGB(36,40,48)},
    JetVIPLoungeMesh={Enum.Material.SmoothPlastic, Color3.fromRGB(42,46,56)},
    JetWingStagesMesh={Enum.Material.Metal, Color3.fromRGB(36,40,50)},
    BaggageClaimMesh={Enum.Material.Metal, Color3.fromRGB(88,96,110)},
    PhotoboothMesh={Enum.Material.Metal, Color3.fromRGB(56,44,68)},
    CornerShopMesh={Enum.Material.Metal, Color3.fromRGB(58,48,42)},
    DonorGateAndPedestalsMesh={Enum.Material.Metal, Color3.fromRGB(54,60,74)},
    ServiceEquipmentMesh={Enum.Material.Metal, Color3.fromRGB(54,58,66)},
}

-- These are intentionally solid scene objects. Decorative lights/glass stay non-collidable.
local solidMeshNames = {
    JetPlaneMesh=true, JetEngineMesh=true, JetLandingGearMesh=true,
    JetVIPLoungeMesh=true, JetWingStagesMesh=true,
    ClassicCarLeftA=true, ClassicCarLeftB=true,
    HypercarRightA=true, HypercarRightB=true,
    BaggageClaimMesh=true, PhotoboothMesh=true, CornerShopMesh=true,
    DonorGateAndPedestalsMesh=true,
    GoldPedestalMesh=true, SilverPedestalMesh=true, BronzePedestalMesh=true,
    PerimeterTrackMesh=true,
}

local meshCount = 0
local solidMeshCount = 0
for _, d in ipairs(loaded:GetDescendants()) do
    if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Sound") then
        d:Destroy()
    elseif d:IsA("MeshPart") then
        meshCount += 1
        if expected[d.Name] ~= nil then expected[d.Name] = true end
        d.Anchored = true
        d.CanCollide = solidMeshNames[d.Name] == true
        if d.CanCollide then solidMeshCount += 1 end
        d.CanTouch = false
        d.CanQuery = true
        d.CastShadow = true
        d.DoubleSided = true
        local s = style[d.Name]
        if s then
            d.Material = s[1]
            d.Color = s[2]
        end
        if d.Name == "ServiceEquipmentMesh" then
            d.Transparency = 1
            d.CanCollide = false
            d.CanQuery = false
            d.CastShadow = false
        elseif string.find(d.Name, "Glass", 1, true) then
            d.Material = Enum.Material.Glass
            d.Transparency = math.max(d.Transparency, 0.12)
            d.CastShadow = false
            d.CanCollide = false
        elseif string.find(d.Name, "Tires", 1, true) then
            d.Material = Enum.Material.Rubber
            d.Color = Color3.fromRGB(18,18,20)
            d.CanCollide = false
        elseif string.find(d.Name, "Rims", 1, true) then
            d.Material = Enum.Material.Metal
            d.Color = Color3.fromRGB(112,122,138)
            d.CanCollide = false
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
        warn("[HANGAR V2.1] required realism mesh missing", name)
        return
    end
end

loaded.Parent = environment
local boxCF, size = loaded:GetBoundingBox()
if size.X < 410 or size.X > 470 or size.Z < 540 or size.Z > 640 or size.Y < 140 or size.Y > 190 then
    loaded:Destroy()
    Workspace:SetAttribute("HangarVisualQC", "REALISM_BOUNDS_REJECTED")
    warn("[HANGAR V2.1] bounds rejected", size)
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

-- Walk surfaces use the exact authored visible top heights after GLB import.
collider("HangarFloor", Vector3.new(410,3,370), CFrame.new(0,-1.10,0)) -- top +0.40
collider("OutdoorFloor", Vector3.new(438,3,215), CFrame.new(0,-1.20,285)) -- top +0.30
collider("DanceFloorWalkSurface", Vector3.new(156,1,100), CFrame.new(0,0.275,20)) -- top +0.775
collider("LeftWall", Vector3.new(6,105,380), CFrame.new(-210,52,0))
collider("RightWall", Vector3.new(6,105,380), CFrame.new(210,52,0))
collider("BackWall", Vector3.new(420,105,6), CFrame.new(0,52,-190))
collider("JetVIPFloor", Vector3.new(12,1,42), CFrame.new(0,9,-74))
collider("JetLeftWingStage", Vector3.new(38,2,20), CFrame.new(-39,11,-69))
collider("JetRightWingStage", Vector3.new(38,2,20), CFrame.new(39,11,-69))

-- Guaranteed physical proxies for scene objects that must not be walk-through.
-- Imported GLB mirrors authored Z, therefore authored -270/-70/-162 become +270/+70/+162 in runtime.
collider("ClassicCarLeftAProxy", Vector3.new(15,7,32), CFrame.new(-132,3.5,270))
collider("ClassicCarLeftBProxy", Vector3.new(15,7,32), CFrame.new(-92,3.5,270))
collider("HypercarRightAProxy", Vector3.new(17,7,36), CFrame.new(92,3.5,270))
collider("HypercarRightBProxy", Vector3.new(17,7,36), CFrame.new(136,3.5,270))
collider("BaggageClaimProxy", Vector3.new(90,8,38), CFrame.new(-132,4,70))
collider("GoldPedestalProxy", Vector3.new(16,12,16), CFrame.new(0,6,162))
collider("SilverPedestalProxy", Vector3.new(15,10,15), CFrame.new(-30,5,162))
collider("BronzePedestalProxy", Vector3.new(15,9,15), CFrame.new(30,4.5,162))
collider("DonorGateLeftPillarProxy", Vector3.new(10,56,10), CFrame.new(-92,28,186))
collider("DonorGateRightPillarProxy", Vector3.new(10,56,10), CFrame.new(92,28,186))

-- Floating QC labels remain removed. Final signage belongs to authored environment art.

local lights = Instance.new("Folder")
lights.Name = "HangarPhase2Lights"
lights.Parent = environment
local function point(name, pos, color, brightness, range)
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
    local l = Instance.new("PointLight")
    l.Color = color
    l.Brightness = brightness
    l.Range = range
    l.Shadows = false
    l.Parent = anchor
end

for _, z in ipairs({145,80,15,-55,-125}) do
    point("LeftRoofFill", Vector3.new(-140,78,z), Color3.fromRGB(148,174,215), 0.40, 78)
    point("RightRoofFill", Vector3.new(140,78,z), Color3.fromRGB(148,174,215), 0.40, 78)
end
point("ApronWarm", Vector3.new(-120,22,270), Color3.fromRGB(255,174,120), 0.48, 72)
point("ApronCool", Vector3.new(120,22,270), Color3.fromRGB(120,172,255), 0.48, 72)
point("DanceCool", Vector3.new(-48,22,24), Color3.fromRGB(86,154,222), 0.42, 62)
point("DancePink", Vector3.new(48,22,24), Color3.fromRGB(212,100,174), 0.36, 62)
point("BaggageRead", Vector3.new(-132,18,70), Color3.fromRGB(150,180,220), 0.42, 54)
point("JetKeyLeft", Vector3.new(-34,30,-64), Color3.fromRGB(128,178,238), 0.48, 66)
point("JetKeyRight", Vector3.new(34,30,-64), Color3.fromRGB(224,128,188), 0.38, 66)
point("JetTop", Vector3.new(0,44,-92), Color3.fromRGB(200,214,238), 0.30, 56)

Workspace:SetAttribute("HangarEnvironmentReady", true)
Workspace:SetAttribute("HangarVisualQC", "READY_V2_1_SOLID_COLLISION_OWNER_QC")
Workspace:SetAttribute("HangarStaticMeshCount", meshCount)
Workspace:SetAttribute("HangarSolidMeshCount", solidMeshCount)
Workspace:SetAttribute("HangarModelAssetId", MODEL_ASSET_ID)
Workspace:SetAttribute("HangarSpawnSequence", "OUTDOOR_APRON_TO_OPEN_GATE_TO_DANCE_TO_JET")
Workspace:SetAttribute("HangarEnvironmentDetail", "V2_1_SOLID_COLLISION_GDD_ZONES")
print("[HANGAR V2.1] REALISM + SOLID COLLISION + WALK SURFACE ALIGNMENT READY", MODEL_ASSET_ID, meshCount, solidMeshCount, size, boxCF.Position)