-- Hangar Exclusive Club — STATIC CLOUD FULL MESH v9
-- Fix for v8 runtime EditableMesh replication failure on clients.
-- Visible hangar geometry must come from a Roblox cloud Model asset containing MeshParts.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local HANGAR_MODEL_ASSET_ID = 0 -- HANGAR_STATIC_MODEL_ASSET_ID
local WIDTH = 360
local DEPTH = 280
local WALL_H = 88
local CROWN_H = 126
local BACK_Z = 92
local FRONT_Z = BACK_Z - DEPTH
local CENTER_Z = (BACK_Z + FRONT_Z) / 2

Workspace:SetAttribute("HangarStaticMeshV9Target", true)
Workspace:SetAttribute("HangarStaticMeshV9Ready", false)
Workspace:SetAttribute("HangarRuntimeVisualMode", "V9_STATIC_MESH_WAITING")

-- Remove the outdoor/galaxy look. The opaque hangar shell is still the primary enclosure.
for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("Sky") then child:Destroy() end
    if child:IsA("Atmosphere") then child:Destroy() end
end
local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
    for _, child in ipairs(terrain:GetChildren()) do
        if child:IsA("Clouds") then child:Destroy() end
    end
end

Lighting.ClockTime = 20
Lighting.Brightness = 2.5
Lighting.ExposureCompensation = 0.34
Lighting.Ambient = Color3.fromRGB(62, 66, 78)
Lighting.OutdoorAmbient = Color3.fromRGB(24, 27, 35)
Lighting.EnvironmentDiffuseScale = 0.52
Lighting.EnvironmentSpecularScale = 0.88
Lighting.GlobalShadows = true

local map = Workspace:WaitForChild("Map")
task.wait(2)

if HANGAR_MODEL_ASSET_ID <= 0 then
    Workspace:SetAttribute("HangarRuntimeVisualMode", "V9_ASSET_ID_NOT_LOCKED_KEEP_V7")
    warn("[HANGAR V9] static model asset id is not locked; keeping v7 fallback")
    return
end

local ok, loaded = pcall(InsertService.LoadAsset, InsertService, HANGAR_MODEL_ASSET_ID)
if not ok or not loaded then
    Workspace:SetAttribute("HangarRuntimeVisualMode", "V9_STATIC_LOAD_FAILED_KEEP_V7")
    warn("[HANGAR V9] LoadAsset failed", HANGAR_MODEL_ASSET_ID, loaded)
    return
end

loaded.Name = "HangarFullMeshV9_STATIC"
loaded:SetAttribute("RobloxModelAssetId", HANGAR_MODEL_ASSET_ID)
loaded:SetAttribute("VisualAuthority", "STATIC_CLOUD_MESHPART_MODEL")

local meshCount = 0
for _, d in ipairs(loaded:GetDescendants()) do
    if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
        d:Destroy()
    elseif d:IsA("Sound") then
        d:Destroy()
    elseif d:IsA("MeshPart") then
        meshCount += 1
        d.Anchored = true
        d.CanCollide = false
        d.CanTouch = false
        d.CanQuery = true
        d.CastShadow = true
    elseif d:IsA("BasePart") then
        d.Anchored = true
        d.CanCollide = false
        d.CanTouch = false
        d.CanQuery = true
    end
end

if meshCount < 7 then
    loaded:Destroy()
    Workspace:SetAttribute("HangarRuntimeVisualMode", "V9_STATIC_MODEL_INVALID_KEEP_V7")
    warn("[HANGAR V9] static model did not expose enough MeshParts", meshCount)
    return
end

loaded.Parent = map

-- Normalize cloud importer scale to the locked aircraft-hangar width.
local boxCF, boxSize = loaded:GetBoundingBox()
if boxSize.X <= 1 then
    loaded:Destroy()
    Workspace:SetAttribute("HangarRuntimeVisualMode", "V9_STATIC_MODEL_BAD_BOUNDS_KEEP_V7")
    warn("[HANGAR V9] invalid static model bounds", boxSize)
    return
end
local correction = WIDTH / boxSize.X
if math.abs(correction - 1) > 0.001 then
    loaded:ScaleTo(loaded:GetScale() * correction)
end

boxCF, boxSize = loaded:GetBoundingBox()
local bottomY = boxCF.Position.Y - boxSize.Y * 0.5
local delta = Vector3.new(-boxCF.Position.X, -bottomY, CENTER_Z - boxCF.Position.Z)
loaded:PivotTo(loaded:GetPivot() + delta)

-- Confirm imported dimensions before retiring fallback.
boxCF, boxSize = loaded:GetBoundingBox()
if boxSize.X < 330 or boxSize.X > 390 or boxSize.Y < 90 or boxSize.Z < 240 then
    loaded:Destroy()
    Workspace:SetAttribute("HangarRuntimeVisualMode", "V9_STATIC_MODEL_SCALE_REJECTED_KEEP_V7")
    warn("[HANGAR V9] normalized model bounds rejected", boxSize)
    return
end

-- Static cloud mesh is now authoritative. Remove runtime-generated mesh experiments and v7 fallback.
for _, name in ipairs({"HangarV7EnclosedInterior", "HangarFullMeshV8", "HangarFullMeshV8_BUILDING", "HangarXLVisualRescue", "FullMeshV2"}) do
    local old = map:FindFirstChild(name)
    if old then old:Destroy() end
end

-- Retire visible v1 proxy geometry so no black floating blocks remain.
local architecture = map:FindFirstChild("Architecture")
if architecture then
    for _, child in ipairs(architecture:GetChildren()) do
        if child.Name:match("^Mesh_Hangar") or child.Name:match("^RoofTruss_") or child.Name == "Apron" then child:Destroy() end
    end
end
local vehicles = map:FindFirstChild("Vehicles")
if vehicles then
    for _, child in ipairs(vehicles:GetChildren()) do
        if child.Name:match("^Mesh_PrivateJet") or child.Name:match("^Mesh_Helicopter") then child:Destroy() end
    end
end
local furniture = map:FindFirstChild("Furniture")
if furniture then
    for _, child in ipairs(furniture:GetChildren()) do
        if child.Name == "Stage" or child.Name:match("^DJBooth") or child.Name:match("^Mesh_BarCounter") or child.Name:match("^Mesh_LeatherSofa_") or child.Name:match("^Mesh_MetalFencing_") or child.Name:match("^BarStool_") then
            child:Destroy()
        end
    end
end

-- Keep audio object, hide only the old visible speaker proxy boxes.
local audioSystem = Workspace:FindFirstChild("AudioSystem")
local speakers = audioSystem and audioSystem:FindFirstChild("MainSpeakers")
if speakers then
    for _, child in ipairs(speakers:GetChildren()) do
        if child:IsA("BasePart") then child.Transparency = 1; child.CanCollide = false end
    end
end

-- Replace the old floating laser rods with beams anchored to the stage zone.
local lightingSystem = Workspace:FindFirstChild("LightingSystem")
local legacyLasers = lightingSystem and lightingSystem:FindFirstChild("Lasers")
if legacyLasers then
    for _, child in ipairs(legacyLasers:GetChildren()) do
        if child:IsA("BasePart") then child.Transparency = 1; child.CanCollide = false end
    end
end

-- Invisible gameplay collision helpers. Visible geometry remains MeshPart-only.
local oldCollision = map:FindFirstChild("HangarCollisionV9")
if oldCollision then oldCollision:Destroy() end
local collision = Instance.new("Folder")
collision.Name = "HangarCollisionV9"
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

-- Mesh-backed club branding.
local signPart
for _, d in ipairs(loaded:GetDescendants()) do
    if d:IsA("MeshPart") and string.find(d.Name, "HangarSignMesh", 1, true) then signPart = d; break end
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
    label.TextColor3 = Color3.fromRGB(15,18,23)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

-- Room fill lights under the roof. Their holders are invisible and do not count as visible geometry.
local oldLights = map:FindFirstChild("HangarStaticLightsV9")
if oldLights then oldLights:Destroy() end
local lights = Instance.new("Folder")
lights.Name = "HangarStaticLightsV9"
lights.Parent = map
for _, z in ipairs({-150,-100,-50,0,50}) do
    for _, x in ipairs({-135,-90,-45,0,45,90,135}) do
        local holder = Instance.new("Part")
        holder.Name = "CeilingLightHolder"
        holder.Anchored = true
        holder.CanCollide = false
        holder.CanTouch = false
        holder.CanQuery = false
        holder.Transparency = 1
        holder.Size = Vector3.one
        holder.CFrame = CFrame.new(x,78,z)
        holder.Parent = lights
        local pl = Instance.new("PointLight")
        pl.Color = Color3.fromRGB(222,229,241)
        pl.Brightness = 1.85
        pl.Range = 68
        pl.Shadows = false
        pl.Parent = holder
    end
end
for i, x in ipairs({-72,-36,0,36,72}) do
    local holder = Instance.new("Part")
    holder.Name = "StageWash"..i
    holder.Anchored = true
    holder.CanCollide = false
    holder.CanTouch = false
    holder.CanQuery = false
    holder.Transparency = 1
    holder.Size = Vector3.one
    holder.CFrame = CFrame.new(x,56,66)
    holder.Parent = lights
    local sp = Instance.new("SpotLight")
    sp.Face = Enum.NormalId.Front
    sp.Angle = 78
    sp.Range = 110
    sp.Brightness = 3.2
    sp.Color = Color3.fromRGB(235,222,214)
    sp.Shadows = false
    sp.Parent = holder
end

local spawn = Workspace:FindFirstChild("HangarSpawn")
if spawn and spawn:IsA("SpawnLocation") then
    spawn.Transparency = 1
    spawn.Material = Enum.Material.SmoothPlastic
    spawn.CanCollide = false
end

Workspace:SetAttribute("HangarStaticMeshV9Ready", true)
Workspace:SetAttribute("HangarRuntimeVisualMode", "V9_STATIC_CLOUD_FULL_MESH")
Workspace:SetAttribute("HangarScaleClass", "AIRCRAFT_HANGAR_XL")
Workspace:SetAttribute("HangarVisibleGeometry", "STATIC_CLOUD_MESHPART_ONLY")
Workspace:SetAttribute("HangarStaticMeshCount", meshCount)
Workspace:SetAttribute("HangarGalaxyRemoved", true)
print("[HANGAR V9] STATIC CLOUD FULL MESH READY", HANGAR_MODEL_ASSET_ID, meshCount, boxSize)
