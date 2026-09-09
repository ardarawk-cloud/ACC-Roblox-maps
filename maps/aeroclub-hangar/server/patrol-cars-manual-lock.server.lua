-- HANGAR — TWO PATROL CARS MANUAL LOCK v1
-- Scope: ONLY the two owned patrol-car assets.
-- No jet edits. No furniture/architecture/lighting edits. No broad cleanup.
-- No auto nose detection. No generated collision/deck parts.

local InsertService = game:GetService("InsertService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local FLOOR_Y = 0.40

-- Per-asset settings. These are deliberately separate records, not one generic fleet rule.
-- targetLength preserves the latest measured display-size intent from V7; X/Z preserve V7 welcome positions.
-- Y floor placement is deterministic bounding-box grounding only; orientation is fixed, never inferred.
local CARS = {
    {
        name = "Patrol_McLarenF1LM",
        rawName = "RAW_Patrol_McLarenF1LM_128438812070025",
        assetId = 128438812070025,
        targetLength = 25,
        x = -60,
        z = 170,
        yaw = 0,
    },
    {
        name = "Patrol_PorscheCarreraGT",
        rawName = "RAW_Patrol_PorscheCarreraGT_108398505977253",
        assetId = 108398505977253,
        targetLength = 25,
        x = 60,
        z = 170,
        yaw = 0,
    },
}

Workspace:SetAttribute("HangarVehicleAuthority", "TWO_PATROL_MANUAL_LOCK_V1")
Workspace:SetAttribute("HangarVehicleScope", "PATROL_MCLAREN_AND_PORSCHE_ONLY")
Workspace:SetAttribute("HangarVehicleVisualQC", "NOT_VISUALLY_VERIFIED")
Workspace:SetAttribute("HangarVehicleAutoNose", false)
Workspace:SetAttribute("HangarVehicleBroadCleanup", false)
Workspace:SetAttribute("HangarVehicleGeneratedCollision", false)

local deadline = os.clock() + 35
while os.clock() < deadline and Workspace:GetAttribute("HangarEnvironmentReady") ~= true do
    task.wait(0.25)
end

local environment = Workspace:FindFirstChild("Environment")
if not environment or Workspace:GetAttribute("HangarEnvironmentReady") ~= true then
    Workspace:SetAttribute("HangarVehicleAuthority", "ENVIRONMENT_NOT_READY")
    return
end

-- RAW vault is isolated in ServerStorage and is never transformed.
local vault = ServerStorage:FindFirstChild("HangarVehicleAssetVault")
if not vault then
    vault = Instance.new("Folder")
    vault.Name = "HangarVehicleAssetVault"
    vault.Parent = ServerStorage
end

-- We only own this exact display container. Nothing outside it may be destroyed.
local oldDisplay = environment:FindFirstChild("HangarPatrolCarsManualV1")
if oldDisplay then
    oldDisplay:Destroy()
end

local display = Instance.new("Model")
display.Name = "HangarPatrolCarsManualV1"
display:SetAttribute("ScopeLock", "TWO_PATROL_CARS_ONLY")
display:SetAttribute("VisualQC", "NOT_VISUALLY_VERIFIED")
display.Parent = environment

local function getRaw(spec)
    local existing = vault:FindFirstChild(spec.rawName)
    if existing then
        return existing
    end

    local ok, loaded = pcall(InsertService.LoadAsset, InsertService, spec.assetId)
    if not ok or not loaded then
        return nil, "LOAD_FAIL"
    end

    loaded.Name = spec.rawName
    loaded:SetAttribute("RobloxAssetId", spec.assetId)
    loaded:SetAttribute("RawMaster", true)
    loaded:SetAttribute("TransformLocked", true)
    loaded.Parent = vault
    return loaded
end

local function sanitizeDisplay(model)
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

local function placeOne(spec)
    local raw, rawErr = getRaw(spec)
    if not raw then
        return false, rawErr
    end

    local model = raw:Clone()
    model.Name = spec.name
    model:SetAttribute("RobloxAssetId", spec.assetId)
    model:SetAttribute("ManualLock", true)
    model:SetAttribute("TargetLengthStuds", spec.targetLength)
    model:SetAttribute("ManualX", spec.x)
    model:SetAttribute("ManualZ", spec.z)
    model:SetAttribute("ManualYawDegrees", spec.yaw)
    model:SetAttribute("VisualQC", "NOT_VISUALLY_VERIFIED")

    local partCount = sanitizeDisplay(model)
    if partCount < 1 then
        model:Destroy()
        return false, "NO_PARTS"
    end

    -- Fixed per-asset size target only. No fleet-wide smart scale policy.
    local _, initialSize = model:GetBoundingBox()
    local horizontal = math.max(initialSize.X, initialSize.Z)
    if horizontal <= 0.01 then
        model:Destroy()
        return false, "INVALID_BOUNDS"
    end
    local scaleFactor = spec.targetLength / horizontal
    if scaleFactor < 0.001 or scaleFactor > 500 then
        model:Destroy()
        return false, "UNSAFE_SCALE"
    end
    model:ScaleTo(model:GetScale() * scaleFactor)
    model:SetAttribute("AppliedScaleFactor", scaleFactor)

    -- Fixed orientation. No nose-name scanning and no auto-rotate.
    model:PivotTo(CFrame.new(spec.x, 0, spec.z) * CFrame.Angles(0, math.rad(spec.yaw), 0))

    -- Deterministic floor-only grounding. It changes Y only; X/Z/yaw remain locked.
    local boxCF, boxSize = model:GetBoundingBox()
    local bottomY = boxCF.Position.Y - boxSize.Y * 0.5
    model:PivotTo(model:GetPivot() + Vector3.new(0, FLOOR_Y - bottomY, 0))

    model.Parent = display
    return true
end

local loaded = {}
local failed = {}
for _, spec in ipairs(CARS) do
    local ok, err = placeOne(spec)
    if ok then
        table.insert(loaded, spec.name)
    else
        table.insert(failed, spec.name .. ":" .. tostring(err))
    end
end

Workspace:SetAttribute("HangarPatrolCarsLoaded", table.concat(loaded, "|"))
Workspace:SetAttribute("HangarPatrolCarsFailures", table.concat(failed, "|"))
Workspace:SetAttribute("HangarVehicleAuthority", #failed == 0 and "READY_TWO_PATROL_MANUAL_LOCK_V1" or "PARTIAL_TWO_PATROL_MANUAL_LOCK_V1")
print("[HANGAR MANUAL LOCK] loaded", #loaded, "failed", #failed, "visualQC=NOT_VISUALLY_VERIFIED")
