-- HANGAR — SHOWCASE FLEET v2.0
-- Owner-directed layout: full Drive GLB car fleet in front of donor statues and around/under the jet.
-- No generated image/art fallback. Existing HANGAR shell remains unchanged.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local JET_ASSET_ID = 135410789803386 -- HANGAR_SKETCHFAB_JET_ASSET_ID

local CAR01_ASSET_ID = 0 -- HANGAR_SHOWCASE_CAR01_ASSET_ID
local CAR02_ASSET_ID = 0 -- HANGAR_SHOWCASE_CAR02_ASSET_ID
local CAR03_ASSET_ID = 0 -- HANGAR_SHOWCASE_CAR03_ASSET_ID
local CAR04_ASSET_ID = 0 -- HANGAR_SHOWCASE_CAR04_ASSET_ID
local CAR05_ASSET_ID = 0 -- HANGAR_SHOWCASE_CAR05_ASSET_ID
local CAR06_ASSET_ID = 0 -- HANGAR_SHOWCASE_CAR06_ASSET_ID
local CAR07_ASSET_ID = 0 -- HANGAR_SHOWCASE_CAR07_ASSET_ID
local CAR08_ASSET_ID = 0 -- HANGAR_SHOWCASE_CAR08_ASSET_ID
local CAR09_ASSET_ID = 0 -- HANGAR_SHOWCASE_CAR09_ASSET_ID
local CAR10_ASSET_ID = 0 -- HANGAR_SHOWCASE_CAR10_ASSET_ID

local OUTDOOR_SURFACE_Y = 0.30
local INDOOR_SURFACE_Y = 0.40

local placements = {
    {name="PrivateJetSketchfab", asset=JET_ASSET_ID, target=96, pos=Vector3.new(0, INDOOR_SURFACE_Y, -66), yaw=0, kind="jet"},

    -- Donor-gate showcase. Center aisle remains open to the statues / hangar entrance.
    {name="Fleet_R34_Brian", asset=CAR01_ASSET_ID, target=18, pos=Vector3.new(-135, OUTDOOR_SURFACE_Y, 205), yaw=15, kind="car", zone="DONOR_FRONT"},
    {name="Fleet_DodgeCharger1970", asset=CAR02_ASSET_ID, target=19, pos=Vector3.new(-90, OUTDOOR_SURFACE_Y, 198), yaw=8, kind="car", zone="DONOR_FRONT"},
    {name="Fleet_SupraMKIV", asset=CAR03_ASSET_ID, target=18, pos=Vector3.new(-45, OUTDOOR_SURFACE_Y, 194), yaw=5, kind="car", zone="DONOR_FRONT"},
    {name="Fleet_Murcielago", asset=CAR04_ASSET_ID, target=18, pos=Vector3.new(45, OUTDOOR_SURFACE_Y, 194), yaw=-5, kind="car", zone="DONOR_FRONT"},
    {name="Fleet_Eclipse1995", asset=CAR05_ASSET_ID, target=18, pos=Vector3.new(90, OUTDOOR_SURFACE_Y, 198), yaw=-8, kind="car", zone="DONOR_FRONT"},
    {name="Fleet_S2000", asset=CAR06_ASSET_ID, target=18, pos=Vector3.new(135, OUTDOOR_SURFACE_Y, 205), yaw=-15, kind="car", zone="DONOR_FRONT"},

    -- Jet showcase. Cars use the empty wing-side floor without blocking the fuselage / VIP path.
    {name="Fleet_EclipseSpyder", asset=CAR07_ASSET_ID, target=18, pos=Vector3.new(-130, INDOOR_SURFACE_Y, -45), yaw=90, kind="car", zone="JET_FLOOR"},
    {name="Fleet_BRZRocketBunny", asset=CAR08_ASSET_ID, target=18, pos=Vector3.new(-85, INDOOR_SURFACE_Y, -105), yaw=90, kind="car", zone="JET_FLOOR"},
    {name="Fleet_SkylineR34CWest", asset=CAR09_ASSET_ID, target=18, pos=Vector3.new(85, INDOOR_SURFACE_Y, -105), yaw=-90, kind="car", zone="JET_FLOOR"},
    {name="Fleet_DodgeChargerFF8", asset=CAR10_ASSET_ID, target=19, pos=Vector3.new(130, INDOOR_SURFACE_Y, -45), yaw=-90, kind="car", zone="JET_FLOOR"},
}

Workspace:SetAttribute("HangarSketchfabVehicles", "BOOTING_SHOWCASE_FLEET_V2")
Workspace:SetAttribute("HangarSketchfabSource", "OWNER_DRIVE_GLB_FLEET")
Workspace:SetAttribute("HangarVehicleScaleAuthority", "HUMAN_SCALE_SHOWCASE_V2")
Workspace:SetAttribute("HangarFleetLayout", "DONOR_FRONT_6_PLUS_JET_FLOOR_4")
Workspace:SetAttribute("HangarFleetRequestedCarCount", 10)

local deadline = os.clock() + 35
while os.clock() < deadline and Workspace:GetAttribute("HangarEnvironmentReady") ~= true do
    task.wait(0.25)
end

local environment = Workspace:FindFirstChild("Environment")
if not environment or Workspace:GetAttribute("HangarEnvironmentReady") ~= true then
    Workspace:SetAttribute("HangarSketchfabVehicles", "ENVIRONMENT_NOT_READY")
    warn("[HANGAR FLEET] environment not ready")
    return
end

local oldReplacement = environment:FindFirstChild("SketchfabVehicleDisplayV1")
if oldReplacement then oldReplacement:Destroy() end
local oldFleet = environment:FindFirstChild("HangarShowcaseFleetV2")
if oldFleet then oldFleet:Destroy() end

local replacement = Instance.new("Model")
replacement.Name = "HangarShowcaseFleetV2"
replacement:SetAttribute("DisplayOnly", true)
replacement:SetAttribute("Source", "OWNER_DRIVE_GLB_FLEET")
replacement.Parent = environment

local collisionRoot = environment:FindFirstChild("Collision")
if not collisionRoot then
    collisionRoot = Instance.new("Folder")
    collisionRoot.Name = "Collision"
    collisionRoot.Parent = environment
end

for _, child in ipairs(collisionRoot:GetChildren()) do
    if child:GetAttribute("HangarFleetCollision") == true or string.find(child.Name, "_DisplayCollision", 1, true) then
        child:Destroy()
    end
end
for _, name in ipairs({"ClassicCarLeftAProxy","ClassicCarLeftBProxy","HypercarRightAProxy","HypercarRightBProxy","SketchfabJetBodyProxy"}) do
    local old = collisionRoot:FindFirstChild(name)
    if old then old:Destroy() end
end

local function sanitize(model)
    local parts = 0
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Sound") then
            d:Destroy()
        elseif d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then
            d:Destroy()
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
            d.Enabled = false
        elseif d:IsA("BasePart") then
            parts += 1
            d.Anchored = true
            d.CanCollide = false
            d.CanTouch = false
            d.CanQuery = true
            d.Massless = true
            d.CastShadow = true
        end
    end
    return parts
end

local function makeBlocker(name, cf, size)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Transparency = 1
    p.CanCollide = true
    p.CanTouch = false
    p.CanQuery = false
    p.Size = size
    p.CFrame = cf
    p:SetAttribute("HangarFleetCollision", true)
    p.Parent = collisionRoot
    return p
end

local function normalizeAndPlace(model, spec)
    local _, size = model:GetBoundingBox()
    local horizontal = math.max(size.X, size.Z)
    if horizontal <= 0.01 then error("invalid model bounds for " .. spec.name) end

    local scale = spec.target / horizontal
    if scale < 0.001 or scale > 500 then
        error(string.format("unsafe scale %.5f for %s", scale, spec.name))
    end
    model:ScaleTo(model:GetScale() * scale)
    model:PivotTo(CFrame.new(spec.pos.X, 0, spec.pos.Z) * CFrame.Angles(0, math.rad(spec.yaw), 0))

    local boxCF, boxSize = model:GetBoundingBox()
    local bottomY = boxCF.Position.Y - boxSize.Y * 0.5
    model:PivotTo(model:GetPivot() + Vector3.new(0, spec.pos.Y - bottomY, 0))

    boxCF, boxSize = model:GetBoundingBox()
    local rotationOnly = boxCF - boxCF.Position

    if spec.kind == "car" then
        local bs = Vector3.new(
            math.max(4, boxSize.X * 0.84),
            math.max(2.3, boxSize.Y * 0.58),
            math.max(4, boxSize.Z * 0.84)
        )
        local floorY = spec.zone == "DONOR_FRONT" and OUTDOOR_SURFACE_Y or INDOOR_SURFACE_Y
        makeBlocker(spec.name .. "_DisplayCollision", CFrame.new(boxCF.Position.X, floorY + bs.Y * 0.5, boxCF.Position.Z) * rotationOnly, bs)
    else
        local long = math.max(boxSize.X, boxSize.Z)
        local xLong = boxSize.X >= boxSize.Z
        local fuselageLength = long * 0.72
        local fuselageWidth = math.max(8, math.min(boxSize.X, boxSize.Z) * 0.18)
        local bs = xLong
            and Vector3.new(fuselageLength, math.max(7, boxSize.Y * 0.52), fuselageWidth)
            or Vector3.new(fuselageWidth, math.max(7, boxSize.Y * 0.52), fuselageLength)
        makeBlocker("SketchfabJetBodyProxy", CFrame.new(boxCF.Position.X, INDOOR_SURFACE_Y + bs.Y * 0.5, boxCF.Position.Z) * rotationOnly, bs)
    end

    model:SetAttribute("FinalSizeX", boxSize.X)
    model:SetAttribute("FinalSizeY", boxSize.Y)
    model:SetAttribute("FinalSizeZ", boxSize.Z)
end

local function loadOne(spec)
    if spec.asset <= 0 then error("asset id missing for " .. spec.name) end
    local ok, loaded = pcall(InsertService.LoadAsset, InsertService, spec.asset)
    if not ok or not loaded then
        error("LoadAsset failed for " .. spec.name .. ": " .. tostring(loaded))
    end
    loaded.Name = spec.name
    loaded:SetAttribute("RobloxAssetId", spec.asset)
    loaded:SetAttribute("DisplayOnly", true)
    loaded:SetAttribute("Source", "OWNER_DRIVE_GLB_FLEET")
    loaded:SetAttribute("ShowcaseZone", spec.zone or "JET")
    local partCount = sanitize(loaded)
    if partCount < 1 then
        loaded:Destroy()
        error("no renderable parts for " .. spec.name)
    end
    loaded:SetAttribute("PartCount", partCount)
    loaded.Parent = replacement
    normalizeAndPlace(loaded, spec)
end

local ok, err = pcall(function()
    for _, spec in ipairs(placements) do
        loadOne(spec)
    end
end)

if not ok then
    replacement:Destroy()
    for _, child in ipairs(collisionRoot:GetChildren()) do
        if child:GetAttribute("HangarFleetCollision") == true then child:Destroy() end
    end
    Workspace:SetAttribute("HangarSketchfabVehicles", "SHOWCASE_FLEET_LOAD_FAILED")
    Workspace:SetAttribute("HangarProceduralVehicles", "RETAINED_FAILSAFE")
    warn("[HANGAR FLEET] transactional fleet load failed", err)
    return
end

-- Replace all old procedural vehicle/aircraft art only after the full fleet is loaded.
local hideNames = {
    JetPlaneMesh=true,
    JetGlassAndTrimMesh=true,
    JetEngineMesh=true,
    JetLandingGearMesh=true,
    JetVIPLoungeMesh=true,
    ClassicCarLeftA=true,
    ClassicCarLeftB=true,
    HypercarRightA=true,
    HypercarRightB=true,
}
for _, d in ipairs(environment:GetDescendants()) do
    if d:IsA("MeshPart") and hideNames[d.Name] and not d:IsDescendantOf(replacement) then
        d.Transparency = 1
        d.CastShadow = false
        d.CanCollide = false
        d.CanQuery = false
    end
end

Workspace:SetAttribute("HangarSketchfabVehicles", "READY_SHOWCASE_FLEET_V2_OWNER_QC")
Workspace:SetAttribute("HangarProceduralVehicles", "HIDDEN_FULL_FLEET_SWAP")
Workspace:SetAttribute("HangarVehicleArt", "OWNER_DRIVE_REAL_MODELS_SHOWCASE_V2")
Workspace:SetAttribute("HangarVehicleCountReal", 11) -- 1 jet + 10 cars
print("[HANGAR FLEET] JET + 10 REAL CARS READY", JET_ASSET_ID)
