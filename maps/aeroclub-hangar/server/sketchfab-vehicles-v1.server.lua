-- HANGAR — SKETCHFAB VEHICLE REPLACEMENT v1.0
-- Replaces procedural jet/cars with vetted GLB assets supplied by the owner.
-- Environment shell, WITA, wing stages and other Phase 2 zones remain untouched.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local JET_ASSET_ID = 0 -- HANGAR_SKETCHFAB_JET_ASSET_ID
local STARLET_ASSET_ID = 0 -- HANGAR_SKETCHFAB_STARLET_ASSET_ID
local BUGATTI_ASSET_ID = 0 -- HANGAR_SKETCHFAB_BUGATTI_ASSET_ID
local LAMBO_ASSET_ID = 0 -- HANGAR_SKETCHFAB_LAMBO_ASSET_ID

local OUTDOOR_SURFACE_Y = 0.30
local INDOOR_SURFACE_Y = 0.40

local placements = {
    jet = {name="PrivateJetSketchfab", asset=JET_ASSET_ID, target=145, pos=Vector3.new(0, INDOOR_SURFACE_Y, -66), yaw=0},
    starletA = {name="ToyotaStarletKP61_A", asset=STARLET_ASSET_ID, target=31, pos=Vector3.new(-132, OUTDOOR_SURFACE_Y, 270), yaw=0},
    starletB = {name="ToyotaStarletKP61_B", asset=STARLET_ASSET_ID, target=31, pos=Vector3.new(-92, OUTDOOR_SURFACE_Y, 270), yaw=0},
    bugatti = {name="BugattiChiron", asset=BUGATTI_ASSET_ID, target=35, pos=Vector3.new(92, OUTDOOR_SURFACE_Y, 270), yaw=90},
    lambo = {name="LamborghiniSestoElemento", asset=LAMBO_ASSET_ID, target=35, pos=Vector3.new(136, OUTDOOR_SURFACE_Y, 270), yaw=90},
}

Workspace:SetAttribute("HangarSketchfabVehicles", "BOOTING")
Workspace:SetAttribute("HangarSketchfabSource", "OWNER_SUPPLIED_CC_MODELS")
Workspace:SetAttribute("HangarProceduralVehicles", "ACTIVE_UNTIL_TRANSACTIONAL_SWAP")

local deadline = os.clock() + 35
while os.clock() < deadline and Workspace:GetAttribute("HangarEnvironmentReady") ~= true do
    task.wait(0.25)
end

local environment = Workspace:FindFirstChild("Environment")
if not environment or Workspace:GetAttribute("HangarEnvironmentReady") ~= true then
    Workspace:SetAttribute("HangarSketchfabVehicles", "ENVIRONMENT_NOT_READY")
    warn("[HANGAR SKETCHFAB] environment not ready")
    return
end

local oldReplacement = environment:FindFirstChild("SketchfabVehicleDisplayV1")
if oldReplacement then oldReplacement:Destroy() end

local replacement = Instance.new("Model")
replacement.Name = "SketchfabVehicleDisplayV1"
replacement:SetAttribute("DisplayOnly", true)
replacement:SetAttribute("Source", "SKETCHFAB_OWNER_SUPPLIED")
replacement.Parent = environment

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

local function normalizeAndPlace(model, targetHorizontal, pos, yaw)
    local _, size = model:GetBoundingBox()
    local horizontal = math.max(size.X, size.Z)
    if horizontal <= 0.01 then error("invalid model bounds") end

    local scale = targetHorizontal / horizontal
    if scale < 0.01 or scale > 500 then
        error(string.format("unsafe scale %.4f from size %s", scale, tostring(size)))
    end
    model:ScaleTo(scale)
    model:PivotTo(CFrame.new(pos.X, 0, pos.Z) * CFrame.Angles(0, math.rad(yaw), 0))

    local boxCF, boxSize = model:GetBoundingBox()
    local bottomY = boxCF.Position.Y - boxSize.Y * 0.5
    model:PivotTo(model:GetPivot() + Vector3.new(0, pos.Y - bottomY, 0))

    local _, finalSize = model:GetBoundingBox()
    return finalSize
end

local function loadOne(spec)
    if spec.asset <= 0 then error("asset id not injected for " .. spec.name) end
    local ok, loaded = pcall(InsertService.LoadAsset, InsertService, spec.asset)
    if not ok or not loaded then error("LoadAsset failed for " .. spec.name .. ": " .. tostring(loaded)) end
    loaded.Name = spec.name
    loaded:SetAttribute("RobloxAssetId", spec.asset)
    loaded:SetAttribute("DisplayOnly", true)
    loaded:SetAttribute("Source", "SKETCHFAB_OWNER_SUPPLIED")
    local partCount = sanitize(loaded)
    if partCount < 1 then
        loaded:Destroy()
        error("no renderable parts for " .. spec.name)
    end
    loaded.Parent = replacement
    local size = normalizeAndPlace(loaded, spec.target, spec.pos, spec.yaw)
    loaded:SetAttribute("PartCount", partCount)
    loaded:SetAttribute("FinalSizeX", size.X)
    loaded:SetAttribute("FinalSizeY", size.Y)
    loaded:SetAttribute("FinalSizeZ", size.Z)
    return loaded
end

local loadedModels = {}
local ok, err = pcall(function()
    loadedModels.jet = loadOne(placements.jet)
    loadedModels.starletA = loadOne(placements.starletA)
    loadedModels.starletB = loadOne(placements.starletB)
    loadedModels.bugatti = loadOne(placements.bugatti)
    loadedModels.lambo = loadOne(placements.lambo)
end)

if not ok then
    replacement:Destroy()
    Workspace:SetAttribute("HangarSketchfabVehicles", "LOAD_FAILED_PROCEDURAL_RETAINED")
    Workspace:SetAttribute("HangarProceduralVehicles", "RETAINED_FAILSAFE")
    warn("[HANGAR SKETCHFAB] transactional load failed; procedural vehicles retained", err)
    return
end

-- Hide only the procedural vehicle/aircraft art after every replacement is ready.
-- Wing stages stay visible because they are part of the locked club layout, not aircraft body art.
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
        -- Keep old jet physical shell as a temporary collision guide; car proxy Parts already handle cars.
        if string.find(d.Name, "Jet", 1, true) then
            d.CanQuery = true
        else
            d.CanCollide = false
            d.CanQuery = false
        end
    end
end

Workspace:SetAttribute("HangarSketchfabVehicles", "READY_OWNER_VISUAL_QC")
Workspace:SetAttribute("HangarProceduralVehicles", "HIDDEN_TRANSACTIONAL_SWAP")
Workspace:SetAttribute("HangarVehicleArt", "SKETCHFAB_REAL_MODELS_V1")
Workspace:SetAttribute("HangarVehicleCount", 5)
print("[HANGAR SKETCHFAB] REAL JET + CARS READY", JET_ASSET_ID, STARLET_ASSET_ID, BUGATTI_ASSET_ID, LAMBO_ASSET_ID)
