-- HANGAR — SKETCHFAB VEHICLE REPLACEMENT v1.2
-- Publishes approved owner-supplied Sketchfab art immediately.
-- Jet + Starlet are mandatory; hypercars stay procedural until their Roblox assets are approved.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local JET_ASSET_ID = 134086153147334 -- HANGAR_SKETCHFAB_JET_ASSET_ID
local STARLET_ASSET_ID = 138146762993175 -- HANGAR_SKETCHFAB_STARLET_ASSET_ID
local BUGATTI_ASSET_ID = 132221995654437 -- HANGAR_SKETCHFAB_BUGATTI_ASSET_ID
local LAMBO_ASSET_ID = 98880805686599 -- HANGAR_SKETCHFAB_LAMBO_ASSET_ID

local OUTDOOR_SURFACE_Y = 0.30
local INDOOR_SURFACE_Y = 0.40

local placements = {
    jet = {name="PrivateJetSketchfab", asset=JET_ASSET_ID, target=96, pos=Vector3.new(0, INDOOR_SURFACE_Y, -66), yaw=0, kind="jet"},
    starletA = {name="ToyotaStarletKP61_A", asset=STARLET_ASSET_ID, target=16, pos=Vector3.new(-132, OUTDOOR_SURFACE_Y, 270), yaw=0, kind="car"},
    starletB = {name="ToyotaStarletKP61_B", asset=STARLET_ASSET_ID, target=16, pos=Vector3.new(-100, OUTDOOR_SURFACE_Y, 270), yaw=0, kind="car"},
    bugatti = {name="BugattiChiron", asset=BUGATTI_ASSET_ID, target=18, pos=Vector3.new(100, OUTDOOR_SURFACE_Y, 270), yaw=90, kind="car"},
    lambo = {name="LamborghiniSestoElemento", asset=LAMBO_ASSET_ID, target=18, pos=Vector3.new(136, OUTDOOR_SURFACE_Y, 270), yaw=90, kind="car"},
}

Workspace:SetAttribute("HangarSketchfabVehicles", "BOOTING_V1_2_APPROVED_PARTIAL")
Workspace:SetAttribute("HangarSketchfabSource", "OWNER_SUPPLIED_CC_MODELS")
Workspace:SetAttribute("HangarVehicleScaleAuthority", "HUMAN_SCALE_V1_2")
Workspace:SetAttribute("HangarHypercarReplacement", "ROCKET_RACOON_ALL_ASSETS_READY")

local deadline = os.clock() + 35
while os.clock() < deadline and Workspace:GetAttribute("HangarEnvironmentReady") ~= true do task.wait(0.25) end

local environment = Workspace:FindFirstChild("Environment")
if not environment or Workspace:GetAttribute("HangarEnvironmentReady") ~= true then
    Workspace:SetAttribute("HangarSketchfabVehicles", "ENVIRONMENT_NOT_READY")
    return
end

local oldReplacement = environment:FindFirstChild("SketchfabVehicleDisplayV1")
if oldReplacement then oldReplacement:Destroy() end
local replacement = Instance.new("Model")
replacement.Name = "SketchfabVehicleDisplayV1"
replacement:SetAttribute("DisplayOnly", true)
replacement:SetAttribute("Source", "SKETCHFAB_OWNER_SUPPLIED")
replacement.Parent = environment

local collisionRoot = environment:FindFirstChild("Collision") or Instance.new("Folder")
collisionRoot.Name = "Collision"
collisionRoot.Parent = environment
for _, name in ipairs({"ClassicCarLeftAProxy","ClassicCarLeftBProxy","SketchfabJetBodyProxy","ToyotaStarletKP61_A_DisplayCollision","ToyotaStarletKP61_B_DisplayCollision","BugattiChiron_DisplayCollision","LamborghiniSestoElemento_DisplayCollision"}) do
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
    p.Parent = collisionRoot
end

local function normalizeAndPlace(model, spec)
    local _, size = model:GetBoundingBox()
    local horizontal = math.max(size.X, size.Z)
    if horizontal <= 0.01 then error("invalid model bounds") end
    local scale = spec.target / horizontal
    if scale < 0.001 or scale > 500 then error("unsafe model scale") end
    model:ScaleTo(model:GetScale() * scale)
    model:PivotTo(CFrame.new(spec.pos.X, 0, spec.pos.Z) * CFrame.Angles(0, math.rad(spec.yaw), 0))
    local boxCF, boxSize = model:GetBoundingBox()
    local bottomY = boxCF.Position.Y - boxSize.Y * 0.5
    model:PivotTo(model:GetPivot() + Vector3.new(0, spec.pos.Y - bottomY, 0))
    boxCF, boxSize = model:GetBoundingBox()
    local rotationOnly = boxCF - boxCF.Position
    if spec.kind == "car" then
        local bs = Vector3.new(math.max(4,boxSize.X*.84), math.max(2.3,boxSize.Y*.55), math.max(4,boxSize.Z*.84))
        makeBlocker(spec.name.."_DisplayCollision", CFrame.new(boxCF.Position.X, OUTDOOR_SURFACE_Y+bs.Y*.5, boxCF.Position.Z)*rotationOnly, bs)
    else
        local long = math.max(boxSize.X,boxSize.Z)
        local xLong = boxSize.X >= boxSize.Z
        local bodyLength = long*.72
        local bodyWidth = math.max(8, math.min(boxSize.X,boxSize.Z)*.18)
        local bs = xLong and Vector3.new(bodyLength,math.max(7,boxSize.Y*.52),bodyWidth) or Vector3.new(bodyWidth,math.max(7,boxSize.Y*.52),bodyLength)
        makeBlocker("SketchfabJetBodyProxy", CFrame.new(boxCF.Position.X,INDOOR_SURFACE_Y+bs.Y*.5,boxCF.Position.Z)*rotationOnly, bs)
    end
end

local function loadOne(spec)
    if spec.asset <= 0 then return nil end
    local ok, loaded = pcall(InsertService.LoadAsset, InsertService, spec.asset)
    if not ok or not loaded then error("LoadAsset failed for "..spec.name..": "..tostring(loaded)) end
    loaded.Name = spec.name
    loaded:SetAttribute("RobloxAssetId", spec.asset)
    loaded:SetAttribute("DisplayOnly", true)
    loaded:SetAttribute("Source", "SKETCHFAB_OWNER_SUPPLIED")
    if sanitize(loaded) < 1 then loaded:Destroy(); error("no renderable parts for "..spec.name) end
    loaded.Parent = replacement
    normalizeAndPlace(loaded, spec)
    return loaded
end

-- Mandatory approved swap. If either approved asset fails to load, keep all procedural art.
local mandatoryOk, mandatoryErr = pcall(function()
    loadOne(placements.jet)
    loadOne(placements.starletA)
    loadOne(placements.starletB)
end)
if not mandatoryOk then
    replacement:Destroy()
    for _, n in ipairs({"SketchfabJetBodyProxy","ToyotaStarletKP61_A_DisplayCollision","ToyotaStarletKP61_B_DisplayCollision"}) do local p=collisionRoot:FindFirstChild(n); if p then p:Destroy() end end
    Workspace:SetAttribute("HangarSketchfabVehicles", "APPROVED_ASSET_LOAD_FAILED")
    Workspace:SetAttribute("HangarProceduralVehicles", "RETAINED_FAILSAFE")
    warn("[HANGAR SKETCHFAB] approved swap failed", mandatoryErr)
    return
end

local replaced = {jet=true, classic=true, bugatti=false, lambo=false}
if BUGATTI_ASSET_ID > 0 then replaced.bugatti = pcall(function() loadOne(placements.bugatti) end) end
if LAMBO_ASSET_ID > 0 then replaced.lambo = pcall(function() loadOne(placements.lambo) end) end

local hideNames = {
    JetPlaneMesh=true, JetGlassAndTrimMesh=true, JetEngineMesh=true, JetLandingGearMesh=true, JetVIPLoungeMesh=true,
    ClassicCarLeftA=true, ClassicCarLeftB=true,
}
if replaced.bugatti then hideNames.HypercarRightA=true end
if replaced.lambo then hideNames.HypercarRightB=true end
for _, d in ipairs(environment:GetDescendants()) do
    if d:IsA("MeshPart") and hideNames[d.Name] and not d:IsDescendantOf(replacement) then
        d.Transparency=1; d.CastShadow=false; d.CanCollide=false; d.CanQuery=false
    end
end

Workspace:SetAttribute("HangarSketchfabVehicles", "READY_APPROVED_JET_STARLET_OWNER_QC")
Workspace:SetAttribute("HangarProceduralVehicles", "JET_CLASSIC_HIDDEN_HYPERCARS_RETAINED")
Workspace:SetAttribute("HangarVehicleArt", "SKETCHFAB_APPROVED_PARTIAL_V1_2")
Workspace:SetAttribute("HangarVehicleCountReal", 3 + (replaced.bugatti and 1 or 0) + (replaced.lambo and 1 or 0))
print("[HANGAR SKETCHFAB] APPROVED JET + STARLETS READY V1.2", JET_ASSET_ID, STARLET_ASSET_ID)
