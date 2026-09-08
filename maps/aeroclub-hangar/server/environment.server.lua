-- AEROCLUB HANGAR — Environment Runtime v1.0
-- LAB ONLY. Loads approved static mesh asset; NO primitive visual fallback.

local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local AEROCLUB_MODEL_ASSET_ID = 0 -- AEROCLUB_HANGAR_V1_MODEL_ASSET_ID

Workspace:SetAttribute("AeroClubEnvironmentMode", "WAITING_STATIC_MESH")
Workspace:SetAttribute("AeroClubMeshAssetId", AEROCLUB_MODEL_ASSET_ID)

Lighting.Technology = Enum.Technology.Future
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
atmosphere.Density = 0.22
atmosphere.Offset = 0.08
atmosphere.Color = Color3.fromRGB(110, 120, 145)
atmosphere.Decay = Color3.fromRGB(22, 25, 36)
atmosphere.Glare = 0.08
atmosphere.Haze = 1.1
atmosphere.Parent = Lighting

local environment = Workspace:WaitForChild("Environment")
local interactive = Workspace:WaitForChild("InteractiveZones")
local lightingEquipment = Workspace:WaitForChild("LightingEquipment")
local statues = Workspace:WaitForChild("Statues")

if AEROCLUB_MODEL_ASSET_ID <= 0 then
    Workspace:SetAttribute("AeroClubEnvironmentMode", "ASSET_ID_NOT_INJECTED")
    warn("[AEROCLUB] static model asset ID not injected; visual fallback is intentionally disabled")
    return
end

local ok, loaded = pcall(InsertService.LoadAsset, InsertService, AEROCLUB_MODEL_ASSET_ID)
if not ok or not loaded then
    Workspace:SetAttribute("AeroClubEnvironmentMode", "STATIC_MESH_LOAD_FAILED")
    warn("[AEROCLUB] static mesh load failed", AEROCLUB_MODEL_ASSET_ID, loaded)
    return
end

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
        Workspace:SetAttribute("AeroClubEnvironmentMode", "MISSING_" .. name)
        warn("[AEROCLUB] required static mesh missing", name)
        return
    end
end

for _, child in ipairs(environment:GetChildren()) do child:Destroy() end
loaded.Name = "AeroClubStaticMeshV1"
loaded.Parent = environment

local _, size = loaded:GetBoundingBox()
if size.X < 370 or size.X > 430 or size.Z < 500 or size.Y < 120 then
    loaded:Destroy()
    Workspace:SetAttribute("AeroClubEnvironmentMode", "STATIC_MESH_BOUNDS_REJECTED")
    warn("[AEROCLUB] mesh bounds rejected", size)
    return
end

-- Invisible collision envelope only; never visible proxy art.
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
    return p
end
collider("HangarFloor", Vector3.new(382,3,332), CFrame.new(0,-1.5,0))
collider("LeftWall", Vector3.new(6,92,340), CFrame.new(-195,46,0))
collider("RightWall", Vector3.new(6,92,340), CFrame.new(195,46,0))
collider("BackWall", Vector3.new(390,92,6), CFrame.new(0,46,170))
collider("JetVIPFloor", Vector3.new(10,1,50), CFrame.new(0,7,96))
collider("JetLeftWingStage", Vector3.new(37,2,18), CFrame.new(-31,10,88))
collider("JetRightWingStage", Vector3.new(37,2,18), CFrame.new(31,10,88))

-- Spawn is invisible and placed on the dance-floor approach.
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
spawn.Size = Vector3.new(12,1,12)
spawn.CFrame = CFrame.new(0,1,-105)
spawn.Material = Enum.Material.SmoothPlastic

-- Main audio anchor. Asset IDs are intentionally not fabricated.
local audioAnchor = Instance.new("Part")
audioAnchor.Name = "MainAudioAnchor"
audioAnchor.Anchored = true
audioAnchor.Transparency = 1
audioAnchor.CanCollide = false
audioAnchor.Size = Vector3.one
audioAnchor.CFrame = CFrame.new(0,18,82)
audioAnchor.Parent = environment
local audio = Instance.new("Sound")
audio.Name = "MainClubAudio"
audio.Volume = 0.72
audio.RollOffMode = Enum.RollOffMode.InverseTapered
audio.RollOffMinDistance = 28
audio.RollOffMaxDistance = 320
audio.Parent = audioAnchor

-- Real lighting rig: invisible Beam laser sources + physical moving-head housings.
local movingHeads = lightingEquipment:WaitForChild("MovingHeads")
local lasers = lightingEquipment:WaitForChild("Lasers")
local fogMachines = lightingEquipment:WaitForChild("FogMachines")
local fireworks = lightingEquipment:WaitForChild("StageFireworks")
for _, f in ipairs({movingHeads,lasers,fogMachines,fireworks}) do
    for _, child in ipairs(f:GetChildren()) do child:Destroy() end
end

local clubColors = {
    Color3.fromRGB(0,220,255),
    Color3.fromRGB(196,42,255),
    Color3.fromRGB(255,40,175),
    Color3.fromRGB(80,255,90),
}
local laserTargets = {}
for i=1,6 do
    local x = -55 + (i-1)*22
    local housing = Instance.new("Part")
    housing.Name = string.format("MovingHead%02d",i)
    housing.Anchored = true
    housing.CanCollide = false
    housing.Size = Vector3.new(3.4,3.2,4.2)
    housing.Material = Enum.Material.Metal
    housing.Color = Color3.fromRGB(18,20,26)
    housing.CFrame = CFrame.new(x,58,116)
    housing.Parent = movingHeads

    local spot = Instance.new("SpotLight")
    spot.Name = "StageSpot"
    spot.Angle = 25
    spot.Brightness = 4.5
    spot.Range = 120
    spot.Face = Enum.NormalId.Front
    spot.Color = clubColors[((i-1)%#clubColors)+1]
    spot.Parent = housing

    local emitter = Instance.new("Part")
    emitter.Name = string.format("LaserEmitter%02d",i)
    emitter.Anchored = true
    emitter.Transparency = 1
    emitter.CanCollide = false
    emitter.CanQuery = false
    emitter.Size = Vector3.one
    emitter.CFrame = CFrame.new(x,57,113)
    emitter.Parent = lasers

    local target = Instance.new("Part")
    target.Name = string.format("LaserTarget%02d",i)
    target.Anchored = true
    target.Transparency = 1
    target.CanCollide = false
    target.CanQuery = false
    target.Size = Vector3.one
    target.CFrame = CFrame.new(x,8,10)
    target.Parent = lasers

    local a0 = Instance.new("Attachment")
    a0.Parent = emitter
    local a1 = Instance.new("Attachment")
    a1.Parent = target
    local beam = Instance.new("Beam")
    beam.Name = string.format("LaserBeam%02d",i)
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Width0 = 0.055
    beam.Width1 = 0.035
    beam.FaceCamera = true
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Color = ColorSequence.new(clubColors[((i-1)%#clubColors)+1])
    beam.Transparency = NumberSequence.new(0.18)
    beam.Parent = emitter
    laserTargets[i] = {target=target, phase=(i-1)*0.77}
end

for _, x in ipairs({-44,44}) do
    local fog = Instance.new("Part")
    fog.Name = "CO2Machine"
    fog.Anchored = true
    fog.Transparency = 1
    fog.CanCollide = false
    fog.Size = Vector3.one
    fog.CFrame = CFrame.new(x,11,105)
    fog.Parent = fogMachines
    local p = Instance.new("ParticleEmitter")
    p.Name = "ParticleEmitter"
    p.Enabled = false
    p.Rate = 90
    p.Lifetime = NumberRange.new(0.6,1.1)
    p.Speed = NumberRange.new(18,26)
    p.SpreadAngle = Vector2.new(10,10)
    p.Parent = fog
end

for _, x in ipairs({-58,-30,30,58}) do
    local fw = Instance.new("Part")
    fw.Name = "FireworkEmitter"
    fw.Anchored = true
    fw.Transparency = 1
    fw.CanCollide = false
    fw.Size = Vector3.one
    fw.CFrame = CFrame.new(x,12,108)
    fw.Parent = fireworks
    local p = Instance.new("ParticleEmitter")
    p.Name = "ParticleEmitter"
    p.Enabled = false
    p.Rate = 0
    p.Lifetime = NumberRange.new(0.6,1.0)
    p.Speed = NumberRange.new(30,42)
    p.SpreadAngle = Vector2.new(20,20)
    p.Parent = fw
end

local connection
connection = RunService.Heartbeat:Connect(function()
    if not loaded.Parent then
        if connection then connection:Disconnect() end
        return
    end
    local t = Workspace:GetServerTimeNow()
    for i, rig in ipairs(laserTargets) do
        local p = rig.phase
        rig.target.CFrame = CFrame.new(math.sin(t*0.42+p)*72, 8 + (math.sin(t*0.56+p)*0.5+0.5)*26, 10 + math.cos(t*0.31+p*1.4)*68)
    end
end)

-- Invisible interaction trigger for Corner Shop. Real item stands are asset/config driven later.
local cornerShop = interactive:WaitForChild("CornerShop")
for _, c in ipairs(cornerShop:GetChildren()) do c:Destroy() end
for i=1,4 do
    local stand = Instance.new("Model")
    stand.Name = "UGCStand"..i
    stand:SetAttribute("AssetId",0)
    stand:SetAttribute("ItemType","Asset")
    stand.Parent = cornerShop
    local touch = Instance.new("Part")
    touch.Name = "TouchPart"
    touch.Anchored = true
    touch.Transparency = 1
    touch.CanCollide = false
    touch.CanTouch = true
    touch.Size = Vector3.new(14,12,8)
    touch.CFrame = CFrame.new(-151+(i-1)*18,7,-266)
    touch.Parent = stand
end

-- Top-3 donor avatar dummies. Visual pedestals are in the static mesh.
for _, child in ipairs(statues:GetChildren()) do child:Destroy() end
local dummyPositions = {
    GoldPedestal = CFrame.new(0,11,-150),
    SilverPedestal = CFrame.new(-34,11,-150),
    BronzePedestal = CFrame.new(34,11,-150),
}
for name, cf in pairs(dummyPositions) do
    local okRig, rig = pcall(Players.CreateHumanoidModelFromDescription, Players, Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
    if okRig and rig then
        rig.Name = name
        rig:PivotTo(cf)
        for _, d in ipairs(rig:GetDescendants()) do
            if d:IsA("BasePart") then d.Anchored = true end
        end
        rig.Parent = statues
    end
end

Workspace:SetAttribute("AeroClubEnvironmentMode", "STATIC_FULL_MESH_V1_READY")
Workspace:SetAttribute("AeroClubEnvironmentReady", true)
Workspace:SetAttribute("AeroClubStaticMeshCount", meshCount)
Workspace:SetAttribute("AeroClubMeshAssetId", AEROCLUB_MODEL_ASSET_ID)
Workspace:SetAttribute("AeroClubLaserMode", "MOVING_BEAM_NO_NEON_RODS")
print("[AEROCLUB] static full-mesh v1 ready", AEROCLUB_MODEL_ASSET_ID, meshCount, size)
