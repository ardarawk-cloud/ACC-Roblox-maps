-- BBYA SOCIAL HUB — DDIAZ PREMIUM ENTRANCE CARS v1 TEST
-- Scope: entrance display only. Static / non-driveable. Test branch first.
-- Imported custom models are stripped of scripts, audio, prompts, particles, and physics.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local LAMBO_ASSET_ID = 0 -- BBYA_DDIAZ_LAMBO_ASSET_ID
local MAZDA_ASSET_ID = 0 -- BBYA_DDIAZ_MAZDA_ASSET_ID

local ROAD_SURFACE_Y = 0.52
local ROAD_Z = -75.5
local TARGET_CAR_LENGTH = 13.8
local LAMBO_X = -22
local MAZDA_X = 22

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local scene = root:WaitForChild("EntranceStreetScene", 30)
if not scene then return end

task.wait(0.35)

for _, name in ipairs({
    "PremiumCarPairV1",
    "PremiumCarPairV2",
    "PremiumValetGalleryV5",
    "PremiumValetGalleryV6",
    "PremiumArrivalPolishV6",
    "DdiazPremiumCarsV1",
    "DdiazVehicleCreditsV1",
}) do
    local old = scene:FindFirstChild(name)
    if old then old:Destroy() end
end

local gallery = Instance.new("Model")
gallery.Name = "DdiazPremiumCarsV1"
gallery:SetAttribute("Authority", "DDIAZ_PREMIUM_ENTRANCE_CARS_V1_TEST")
gallery:SetAttribute("DisplayOnly", true)
gallery:SetAttribute("VehicleCount", 2)
gallery:SetAttribute("CenterAccessKeptOpen", true)
gallery.Parent = scene

local function stripGameplay(instance)
    for _, d in ipairs(instance:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
            d:Destroy()
        elseif d:IsA("Sound") then
            d:Destroy()
        elseif d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then
            d:Destroy()
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
            d.Enabled = false
        elseif d:IsA("BasePart") then
            d.Anchored = true
            d.CanCollide = false
            d.CanTouch = false
            d.CanQuery = true
            d.Massless = true
        end
    end
end

local function countParts(model)
    local n = 0
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then n += 1 end
    end
    return n
end

local function normalizeAndPlace(model, x, baseYaw)
    local _, size = model:GetBoundingBox()
    local horizontal = math.max(size.X, size.Z)
    if horizontal <= 0.01 then error("invalid vehicle extents") end

    local correction = math.clamp(TARGET_CAR_LENGTH / horizontal, 0.05, 50)
    if math.abs(correction - 1) > 0.01 then
        model:ScaleTo(model:GetScale() * correction)
    end

    local _, scaledSize = model:GetBoundingBox()
    local axisFix = scaledSize.X > scaledSize.Z and 90 or 0
    model:PivotTo(CFrame.new(x, 0, ROAD_Z) * CFrame.Angles(0, math.rad(baseYaw + axisFix), 0))

    local boxCF, placedSize = model:GetBoundingBox()
    local bottomY = boxCF.Position.Y - placedSize.Y * 0.5
    model:PivotTo(model:GetPivot() + Vector3.new(0, ROAD_SURFACE_Y - bottomY, 0))
end

local function addDisplayCollision(model)
    local boxCF, size = model:GetBoundingBox()
    local blocker = Instance.new("Part")
    blocker.Name = "DisplayCollision"
    blocker.Anchored = true
    blocker.CanCollide = true
    blocker.CanTouch = false
    blocker.CanQuery = false
    blocker.Transparency = 1
    blocker.Size = Vector3.new(math.max(3, size.X * 0.9), math.max(1.5, size.Y * 0.52), math.max(3, size.Z * 0.9))
    blocker.CFrame = CFrame.new(boxCF.Position.X, ROAD_SURFACE_Y + blocker.Size.Y * 0.5, boxCF.Position.Z) * (boxCF - boxCF.Position)
    blocker.Parent = model
end

local function loadDisplay(assetId, modelName, x, yaw, credit, sourceUrl, licenseUrl)
    if assetId <= 0 then
        warn("[BBYA] Ddiaz car asset ID not locked yet: " .. modelName)
        return nil
    end

    local ok, loaded = pcall(InsertService.LoadAsset, InsertService, assetId)
    if not ok or not loaded then
        warn(string.format("[BBYA] Ddiaz car load failed asset=%d name=%s error=%s", assetId, modelName, tostring(loaded)))
        return nil
    end

    stripGameplay(loaded)
    if countParts(loaded) < 1 then
        loaded:Destroy()
        warn("[BBYA] Ddiaz car contains no BaseParts: " .. modelName)
        return nil
    end

    loaded.Name = modelName
    loaded:SetAttribute("RobloxAssetId", assetId)
    loaded:SetAttribute("DisplayOnly", true)
    loaded:SetAttribute("Artist", "Ddiaz Design")
    loaded:SetAttribute("Credit", credit)
    loaded:SetAttribute("SourceUrl", sourceUrl)
    loaded:SetAttribute("License", "CC Attribution-NonCommercial-ShareAlike 4.0")
    loaded:SetAttribute("LicenseUrl", licenseUrl)
    loaded:SetAttribute("AdditionalPermissionConfirmedByProjectOwner", true)
    loaded.Parent = gallery

    local placed, placeErr = pcall(normalizeAndPlace, loaded, x, yaw)
    if not placed then
        loaded:Destroy()
        warn("[BBYA] Ddiaz car placement failed: " .. tostring(placeErr))
        return nil
    end
    addDisplayCollision(loaded)
    return loaded
end

local lambo = loadDisplay(
    LAMBO_ASSET_ID,
    "2021_Vorsteiner_Lamborghini_Huracan_EVO_2WD",
    LAMBO_X,
    0,
    '"2021 Vorsteiner Lamborghini Huracan EVO 2WD" by Ddiaz Design',
    "https://skfb.ly/pFsG9",
    "https://creativecommons.org/licenses/by-nc-sa/4.0/"
)

local mazda = loadDisplay(
    MAZDA_ASSET_ID,
    "2004_VeilSide_D1_GT_Mazda_RX8_Tokyo_Drift",
    MAZDA_X,
    180,
    '"2004 VeilSide D1-GT Mazda RX-8 Tokyo Drift" by Ddiaz Design',
    "https://skfb.ly/pKzpM",
    "https://creativecommons.org/licenses/by-nc-sa/4.0/"
)

local ready = lambo ~= nil and mazda ~= nil
if ready then
    for _, fallbackName in ipairs({"CloudCarSlot_Red", "CloudCarSlot_Blue"}) do
        local fallback = scene:FindFirstChild(fallbackName)
        if fallback then fallback:Destroy() end
    end
else
    gallery:Destroy()
end

local credits = Instance.new("Folder")
credits.Name = "DdiazVehicleCreditsV1"
credits:SetAttribute("Lamborghini", '"2021 Vorsteiner Lamborghini Huracan EVO 2WD" (https://skfb.ly/pFsG9) by Ddiaz Design — CC BY-NC-SA 4.0')
credits:SetAttribute("Mazda", '"2004 VeilSide D1-GT Mazda RX-8 Tokyo Drift" (https://skfb.ly/pKzpM) by Ddiaz Design — CC BY-NC-SA 4.0')
credits:SetAttribute("LicenseUrl", "https://creativecommons.org/licenses/by-nc-sa/4.0/")
credits:SetAttribute("AdditionalPermissionConfirmedByProjectOwner", true)
credits.Parent = scene

scene:SetAttribute("DdiazPremiumCarsReady", ready)
scene:SetAttribute("EntranceCarAuthority", ready and "DDIAZ_PREMIUM_ENTRANCE_CARS_V1_TEST" or "FALLBACK_STREET_CARS_FAILSAFE")

if ready then
    print(string.format("[BBYA] DDIAZ_PREMIUM_CARS_READY lambo=%d mazda=%d", LAMBO_ASSET_ID, MAZDA_ASSET_ID))
else
    warn("[BBYA] Ddiaz premium cars unavailable; fallback entrance cars retained")
end
