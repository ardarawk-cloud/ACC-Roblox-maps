-- BBYA SOCIAL HUB — BBYA CAR PAIR v9
-- Canonical entrance-car authority: two creator-permitted Ddiaz Design display cars.
-- Runtime display names are intentionally generic: BBYA Car 01 / BBYA Car 02.
-- IMPORTANT: procedural street cars remain visible unless BOTH premium models load, place,
-- and pass visible-geometry validation. This prevents an empty entrance in production.
-- Display only; scripts/audio/prompts/effects are stripped and every part is anchored.
-- Attribution:
-- 2021 Vorsteiner Lamborghini Huracan EVO 2WD — Ddiaz Design
-- https://skfb.ly/pFsG9 — CC BY-NC-SA 4.0 — used in BBYA Social Hub with creator permission.
-- 2004 VeilSide D1-GT Mazda RX-8 Tokyo Drift — Ddiaz Design
-- https://skfb.ly/pKzpM — CC BY-NC-SA 4.0 — used in BBYA Social Hub with creator permission.

local AssetService = game:GetService("AssetService")
local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local CAR_01_ASSET_ID = 97052038046118
local CAR_02_ASSET_ID = 91172120786409
local ROAD_SURFACE_Y = 0.52
local ROAD_Z = -75.5
local TARGET_CAR_LENGTH = 13.8

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local scene = root:WaitForChild("EntranceStreetScene", 30)
if not scene then return end

task.wait(1.0)

local function stripForDisplay(instance)
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

local function normalizeAndPlace(model, x, yawDegrees)
	local _, size = model:GetBoundingBox()
	local horizontal = math.max(size.X, size.Z)
	if horizontal <= 0.05 then error("invalid vehicle extents") end

	local correction = math.clamp(TARGET_CAR_LENGTH / horizontal, 0.18, 3.5)
	if math.abs(correction - 1) > 0.01 then
		model:ScaleTo(model:GetScale() * correction)
	end

	local nativePivot = model:GetPivot()
	local nativeRotation = nativePivot - nativePivot.Position
	model:PivotTo(CFrame.new(x, 0, ROAD_Z) * CFrame.Angles(0, math.rad(yawDegrees), 0) * nativeRotation)

	local boxCF, placedSize = model:GetBoundingBox()
	local bottomY = boxCF.Position.Y - placedSize.Y * 0.5
	model:PivotTo(model:GetPivot() + Vector3.new(0, ROAD_SURFACE_Y - bottomY, 0))
end

local function visibleGeometryLooksLikeVehicle(model)
	local visibleParts = 0
	local minX, minY, minZ = math.huge, math.huge, math.huge
	local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") and d.Transparency < 0.97 then
			visibleParts += 1
			local p = d.Position
			local half = d.Size * 0.5
			minX = math.min(minX, p.X - half.X)
			minY = math.min(minY, p.Y - half.Y)
			minZ = math.min(minZ, p.Z - half.Z)
			maxX = math.max(maxX, p.X + half.X)
			maxY = math.max(maxY, p.Y + half.Y)
			maxZ = math.max(maxZ, p.Z + half.Z)
		end
	end

	if visibleParts < 1 then
		return false, "no visible BaseParts"
	end

	local spanX = maxX - minX
	local spanY = maxY - minY
	local spanZ = maxZ - minZ
	local horizontal = math.max(spanX, spanZ)
	if horizontal < 6 or horizontal > 24 or spanY < 0.8 or spanY > 12 then
		return false, string.format("suspicious visible extents %.2fx%.2fx%.2f", spanX, spanY, spanZ)
	end

	return true, string.format("visibleParts=%d extents=%.2fx%.2fx%.2f", visibleParts, spanX, spanY, spanZ)
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
	blocker.Size = Vector3.new(
		math.max(4, size.X * 0.88),
		math.max(1.5, size.Y * 0.48),
		math.max(4, size.Z * 0.88)
	)
	local rotationOnly = boxCF - boxCF.Position
	blocker.CFrame = CFrame.new(
		boxCF.Position.X,
		ROAD_SURFACE_Y + blocker.Size.Y * 0.5,
		boxCF.Position.Z
	) * rotationOnly
	blocker.Parent = model
end

local function fetchAsset(assetId)
	local okModern, modern = pcall(AssetService.LoadAssetAsync, AssetService, assetId)
	if okModern and modern then
		return modern, "AssetService.LoadAssetAsync"
	end

	local okLegacy, legacy = pcall(InsertService.LoadAsset, InsertService, assetId)
	if okLegacy and legacy then
		return legacy, "InsertService.LoadAsset"
	end

	return nil, string.format("AssetService=%s | InsertService=%s", tostring(modern), tostring(legacy))
end

local function loadDisplay(assetId, name, x, yawDegrees, sourceUrl)
	local loaded, loader = fetchAsset(assetId)
	if not loaded then
		warn(string.format("[BBYA] car load failed asset=%s error=%s", tostring(assetId), tostring(loader)))
		return nil
	end

	stripForDisplay(loaded)
	if countParts(loaded) < 1 then
		loaded:Destroy()
		warn(string.format("[BBYA] car asset=%s contains no BaseParts", tostring(assetId)))
		return nil
	end

	loaded.Name = name
	loaded:SetAttribute("RobloxAssetId", assetId)
	loaded:SetAttribute("DisplayOnly", true)
	loaded:SetAttribute("Creator", "Ddiaz Design")
	loaded:SetAttribute("SourceUrl", sourceUrl)
	loaded:SetAttribute("License", "CC BY-NC-SA 4.0")
	loaded:SetAttribute("CreatorPermission", true)
	loaded:SetAttribute("RuntimeLoader", loader)

	local placed, err = pcall(normalizeAndPlace, loaded, x, yawDegrees)
	if not placed then
		loaded:Destroy()
		warn(string.format("[BBYA] car placement failed asset=%s error=%s", tostring(assetId), tostring(err)))
		return nil
	end

	local valid, geometry = visibleGeometryLooksLikeVehicle(loaded)
	if not valid then
		loaded:Destroy()
		warn(string.format("[BBYA] car visual validation failed asset=%s detail=%s", tostring(assetId), tostring(geometry)))
		return nil
	end
	loaded:SetAttribute("VisualValidation", geometry)

	addDisplayCollision(loaded)
	return loaded
end

local pending = Instance.new("Model")
pending.Name = "BBYACarPairV9"
pending:SetAttribute("Pass", "BBYA_CAR_PAIR_V9")
pending:SetAttribute("EntranceCarAuthority", "BBYA_CAR_PAIR_V9")
pending:SetAttribute("TargetVehicleCount", 2)
pending:SetAttribute("CenterAccessKeptOpen", true)
pending:SetAttribute("DisplayOnly", true)
pending:SetAttribute("AttributionRequired", true)
pending:SetAttribute("FallbackRemovalRequiresValidatedPair", true)

local car01 = loadDisplay(CAR_01_ASSET_ID, "BBYA Car 01", -15, 8, "https://skfb.ly/pFsG9")
local car02 = loadDisplay(CAR_02_ASSET_ID, "BBYA Car 02", 15, 172, "https://skfb.ly/pKzpM")

if not car01 or not car02 then
	if car01 then car01:Destroy() end
	if car02 then car02:Destroy() end
	pending:Destroy()
	scene:SetAttribute("EntranceCarsQuarantined", true)
	scene:SetAttribute("EntranceCarAuthority", "FALLBACK_STREET_CARS_FAILSAFE_V2")
	scene:SetAttribute("FallbackCarsRetained", true)
	warn("[BBYA] BBYA Car pair unavailable; retaining guaranteed procedural street cars")
	return
end

car01.Parent = pending
car02.Parent = pending
pending.Parent = scene

for _, name in ipairs({
	"PremiumCarPairV1",
	"PremiumCarPairV2",
	"PremiumCar_Left_Wine",
	"PremiumCar_Right_Pearl",
	"PremiumValetGalleryV5",
	"PremiumValetGalleryV6",
	"PremiumArrivalPolishV6",
	"DdiazPremiumValetV7",
	"DdiazPremiumValetV8",
}) do
	local old = scene:FindFirstChild(name)
	if old then old:Destroy() end
end

local fallbackRed = scene:FindFirstChild("CloudCarSlot_Red")
local fallbackBlue = scene:FindFirstChild("CloudCarSlot_Blue")
if fallbackRed then fallbackRed:Destroy() end
if fallbackBlue then fallbackBlue:Destroy() end

local function floorLight(name, x)
	local base = Instance.new("Part")
	base.Name = name
	base.Anchored = true
	base.CanCollide = false
	base.CanTouch = false
	base.CanQuery = false
	base.CastShadow = false
	base.Size = Vector3.new(1.2, 0.08, 1.2)
	base.CFrame = CFrame.new(x, ROAD_SURFACE_Y + 0.045, ROAD_Z + 5.2)
	base.Material = Enum.Material.Metal
	base.Color = Color3.fromRGB(18, 18, 20)
	base.Parent = pending

	local light = Instance.new("PointLight")
	light.Name = "WarmDisplayPool"
	light.Color = Color3.fromRGB(255, 218, 174)
	light.Brightness = 0.58
	light.Range = 9
	light.Shadows = false
	light.Parent = base
end

floorLight("BBYACar01DisplayLight", -15)
floorLight("BBYACar02DisplayLight", 15)

scene:SetAttribute("FallbackCarsRemoved", true)
scene:SetAttribute("FallbackCarsRetained", false)
scene:SetAttribute("EntranceCarsQuarantined", false)
scene:SetAttribute("EntranceCarAuthority", "BBYA_CAR_PAIR_V9")
scene:SetAttribute("EntranceCarSource", "DDIAZ_DESIGN_CREATOR_PERMISSION")
scene:SetAttribute("EntranceCar01AssetId", CAR_01_ASSET_ID)
scene:SetAttribute("EntranceCar02AssetId", CAR_02_ASSET_ID)
-- Legacy compatibility attributes retained for any older diagnostics.
scene:SetAttribute("EntranceCarHuracanAssetId", CAR_01_ASSET_ID)
scene:SetAttribute("EntranceCarRX8AssetId", CAR_02_ASSET_ID)
scene:SetAttribute("EntranceCarCredit", "Ddiaz Design | CC BY-NC-SA 4.0 | creator permission")

print("[BBYA] BBYA Car Pair v9 online: BBYA Car 01 + BBYA Car 02 active")
