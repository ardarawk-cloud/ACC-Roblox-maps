-- HANGAR EXCLUSIVE CLUB — LAB REFERENCE LOCK v10
-- LAB ONLY. DO NOT PUBLISH TO HANGAR LIVE.
-- Visual authority: supplied Hangar reference image. No improvisation.
-- OWNER LOCK: NO LASERS. No neon rods, no Beam lasers, no laser rig.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local HANGAR_LAB_MODEL_ASSET_ID = 0 -- HANGAR_LAB_V10_MODEL_ASSET_ID
local WIDTH = 360
local DEPTH = 280
local WALL_H = 88
local CROWN_H = 126
local BACK_Z = 92
local CENTER_Z = -48

Workspace:SetAttribute("HangarLabV10", true)
Workspace:SetAttribute("HangarLabReferenceLock", "SUPPLIED_IMAGE_NO_IMPROVISATION")
Workspace:SetAttribute("HangarLabRuntimeMode", "V10_WAITING_STATIC_MODEL")
Workspace:SetAttribute("HangarLabVisualQC", "PENDING")
Workspace:SetAttribute("HangarLabLasers", "DISABLED_BY_OWNER")

-- Hard environmental lock: no galaxy, no clouds.
for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("Sky") or child:IsA("Atmosphere") then
        child:Destroy()
    end
end
local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
    for _, child in ipairs(terrain:GetChildren()) do
        if child:IsA("Clouds") then child:Destroy() end
    end
end
Lighting.ClockTime = 20.5
Lighting.Brightness = 2.2
Lighting.ExposureCompensation = 0.22
Lighting.Ambient = Color3.fromRGB(58, 61, 72)
Lighting.OutdoorAmbient = Color3.fromRGB(22, 24, 30)
Lighting.EnvironmentDiffuseScale = 0.50
Lighting.EnvironmentSpecularScale = 0.82
Lighting.GlobalShadows = true

local map = Workspace:WaitForChild("Map")
task.wait(1.5)

-- Remove every legacy laser/neon proxy immediately.
local oldLightingSystem = Workspace:FindFirstChild("LightingSystem")
if oldLightingSystem then
    local oldLasers = oldLightingSystem:FindFirstChild("Lasers")
    if oldLasers then oldLasers:Destroy() end
end
local existingLaserRig = map:FindFirstChild("MovingLaserRigV10")
if existingLaserRig then existingLaserRig:Destroy() end
local furniture = map:FindFirstChild("Furniture")
if furniture then
    local rogueNeon = furniture:FindFirstChild("DJBoothNeon")
    if rogueNeon then rogueNeon:Destroy() end
end
local spawn = Workspace:FindFirstChild("HangarSpawn")
if spawn and spawn:IsA("SpawnLocation") then
    spawn.Transparency = 1
    spawn.Material = Enum.Material.SmoothPlastic
    spawn.CanCollide = false
end

if HANGAR_LAB_MODEL_ASSET_ID <= 0 then
    Workspace:SetAttribute("HangarLabRuntimeMode", "V10_ASSET_ID_NOT_INJECTED")
    warn("[HANGAR LAB V10] model asset ID was not injected")
    return
end

local okLoad, loaded = pcall(InsertService.LoadAsset, InsertService, HANGAR_LAB_MODEL_ASSET_ID)
if not okLoad or not loaded then
    Workspace:SetAttribute("HangarLabRuntimeMode", "V10_STATIC_MODEL_LOAD_FAILED")
    warn("[HANGAR LAB V10] static model load failed", HANGAR_LAB_MODEL_ASSET_ID, loaded)
    return
end
loaded.Name = "HangarReferenceLockedV10"
loaded:SetAttribute("VisualAuthority", "REFERENCE_LOCK_V10")
loaded:SetAttribute("NoImprovisation", true)

local meshCount = 0
local expected = {
    HangarShellMesh = false,
    HangarTrussMesh = false,
    ClubArchitectureMesh = false,
    PrivateJetLeftMesh = false,
    PrivateJetRightMesh = false,
    HelicopterMesh = false,
    IndustrialFixtureMesh = false,
    HangarSignMesh = false,
}
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
        Workspace:SetAttribute("HangarLabRuntimeMode", "V10_STATIC_MODEL_MISSING_" .. name)
        warn("[HANGAR LAB V10] required mesh missing", name)
        return
    end
end

loaded.Parent = map

-- Normalize to locked aircraft-hangar scale.
local boxCF, boxSize = loaded:GetBoundingBox()
if boxSize.X <= 1 then
    loaded:Destroy()
    Workspace:SetAttribute("HangarLabRuntimeMode", "V10_BAD_BOUNDS")
    return
end
local scale = WIDTH / boxSize.X
if math.abs(scale - 1) > 0.001 then loaded:ScaleTo(loaded:GetScale() * scale) end
boxCF, boxSize = loaded:GetBoundingBox()
local bottomY = boxCF.Position.Y - boxSize.Y * 0.5
loaded:PivotTo(loaded:GetPivot() + Vector3.new(-boxCF.Position.X, -bottomY, CENTER_Z - boxCF.Position.Z))
boxCF, boxSize = loaded:GetBoundingBox()
if boxSize.X < 340 or boxSize.X > 380 or boxSize.Y < 100 or boxSize.Z < 250 then
    loaded:Destroy()
    Workspace:SetAttribute("HangarLabRuntimeMode", "V10_SCALE_REJECTED")
    warn("[HANGAR LAB V10] bounds rejected", boxSize)
    return
end

-- STATIC MODEL IS AUTHORITATIVE. Remove every legacy/proxy visual from prior builds.
for _, name in ipairs({
    "HangarV7EnclosedInterior",
    "HangarFullMeshV8",
    "HangarFullMeshV8_BUILDING",
    "HangarFullMeshV9_STATIC",
    "HangarXLVisualRescue",
    "FullMeshV2"
}) do
    local old = map:FindFirstChild(name)
    if old then old:Destroy() end
end
for _, folderName in ipairs({"Architecture", "Vehicles", "Furniture"}) do
    local f = map:FindFirstChild(folderName)
    if f then
        for _, child in ipairs(f:GetChildren()) do child:Destroy() end
    end
end

-- Strip old stage-light housings/lenses. No laser replacement is created.
if oldLightingSystem then
    local stageLights = oldLightingSystem:FindFirstChild("StageLights")
    if stageLights then stageLights:Destroy() end
end

-- Hide old visible speakers but preserve the Sound object used by the music system.
local audioSystem = Workspace:FindFirstChild("AudioSystem")
local speakers = audioSystem and audioSystem:FindFirstChild("MainSpeakers")
if speakers then
    for _, d in ipairs(speakers:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Transparency = 1
            d.CanCollide = false
            d.CastShadow = false
        end
    end
end

-- Invisible collision envelope only.
local oldCollision = map:FindFirstChild("HangarLabCollisionV10")
if oldCollision then oldCollision:Destroy() end
local collision = Instance.new("Folder")
collision.Name = "HangarLabCollisionV10"
collision.Parent = map
local function collider(name, size, cf)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = true
    p.CanTouch = false
    p.CanQuery = true
    p.Transparency = 1
    p.Size = size
    p.CFrame = cf
    p.Parent = collision
end
collider("Floor", Vector3.new(WIDTH,3,DEPTH), CFrame.new(0,-1.5,CENTER_Z))
collider("LeftWall", Vector3.new(5,WALL_H,DEPTH), CFrame.new(-WIDTH/2,WALL_H/2,CENTER_Z))
collider("RightWall", Vector3.new(5,WALL_H,DEPTH), CFrame.new(WIDTH/2,WALL_H/2,CENTER_Z))
collider("BackWall", Vector3.new(WIDTH,WALL_H,5), CFrame.new(0,WALL_H/2,BACK_Z))

-- Reference lighting: industrial white ceiling pools only.
local oldLights = map:FindFirstChild("HangarLabLightsV10")
if oldLights then oldLights:Destroy() end
local lights = Instance.new("Folder")
lights.Name = "HangarLabLightsV10"
lights.Parent = map
for _, z in ipairs({-150,-100,-50,0,48}) do
    for _, x in ipairs({-135,-90,-45,0,45,90,135}) do
        local holder = Instance.new("Part")
        holder.Name = "CeilingLight"
        holder.Anchored = true
        holder.CanCollide = false
        holder.CanTouch = false
        holder.CanQuery = false
        holder.Transparency = 1
        holder.Size = Vector3.one
        holder.CFrame = CFrame.new(x,77,z)
        holder.Parent = lights
        local pl = Instance.new("PointLight")
        pl.Color = Color3.fromRGB(224,229,238)
        pl.Brightness = 1.45
        pl.Range = 64
        pl.Shadows = false
        pl.Parent = holder
    end
end

-- Mesh-backed club branding.
local signPart
for _, d in ipairs(loaded:GetDescendants()) do
    if d:IsA("MeshPart") and d.Name == "HangarSignMesh" then signPart = d break end
end
if signPart then
    local gui = Instance.new("SurfaceGui")
    gui.Name = "HangarBranding"
    gui.Face = Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 22
    gui.Parent = signPart
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Text = "HANGAR\nEXCLUSIVE CLUB"
    label.TextColor3 = Color3.fromRGB(14,17,22)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

Workspace:SetAttribute("HangarLabRuntimeMode", "V10_REFERENCE_LOCK_READY")
Workspace:SetAttribute("HangarLabStaticMeshCount", meshCount)
Workspace:SetAttribute("HangarLabRogueBlocksRemoved", true)
Workspace:SetAttribute("HangarLabRigidNeonRemoved", true)
Workspace:SetAttribute("HangarLabMovingLasers", false)
Workspace:SetAttribute("HangarLabLasers", "DISABLED_BY_OWNER")
Workspace:SetAttribute("HangarLabAircraftLayout", "REFERENCE_FLANKING_STAGE")
Workspace:SetAttribute("HangarLabVisualQC", "READY_FOR_SCREENSHOT")
print("[HANGAR LAB V10] REFERENCE LOCK READY / NO LASERS", HANGAR_LAB_MODEL_ASSET_ID, meshCount, boxSize)
