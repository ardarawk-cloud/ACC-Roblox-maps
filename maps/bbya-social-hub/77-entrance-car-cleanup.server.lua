-- BBYA SOCIAL HUB — ENTRANCE CAR PAIR v11
-- Isolated entrance-car authority only. No other BBYA system is modified here.
-- Primary display assets are the creator-permitted Ddiaz Design cars.
-- If a primary asset cannot be loaded by the running experience, use the already-approved
-- BBYA-owned premium Model asset for that same display slot rather than leaving the valet empty.
-- No procedural/fake-car geometry is fabricated.

local AssetService = game:GetService("AssetService")
local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local CAR_01_ASSET_ID = 97052038046118
local CAR_02_ASSET_ID = 91172120786409
local CAR_01_BBYA_FALLBACK_ID = 75165818784223
local CAR_02_BBYA_FALLBACK_ID = 119133013192596

local ROAD_SURFACE_Y = 0.52
local ROAD_Z = -75.5
local TARGET_CAR_LENGTH = 13.8
local PAIR_NAME = "BBYACarPairV11"

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local scene = root:WaitForChild("EntranceStreetScene", 30)
if not scene then return end

task.wait(1)

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

	if visibleParts < 1 then return false, "no visible BaseParts" end
	local spanX, spanY, spanZ = maxX - minX, maxY - minY, maxZ - minZ
	local horizontal = math.max(spanX, spanZ)
	if horizontal < 6 or horizontal > 24 or spanY < 0.8 or spanY > 12 then
		return false, string.format("suspicious visible extents %.2fx%.2fx%.2f", spanX, spanY, spanZ)
	end
	return true, string.format("visibleParts=%d extents=%.2fx%.2fx%.2f", visibleParts, spanX, spanY, spanZ)
end

local function addDisplayCollision(model)
	local old = model:FindFirstChild("DisplayCollision")
	if old then old:Destroy() end
	local boxCF, size = model:GetBoundingBox()
	local blocker = Instance.new("Part")
	blocker.Name = "DisplayCollision"
	blocker.Anchored = true
	blocker.CanCollide = true
	blocker.CanTouch = false
	blocker.CanQuery = false
	blocker.Transparency = 1
	blocker.Size = Vector3.new(math.max(4, size.X * 0.88), math.max(1.5, size.Y * 0.48), math.max(4, size.Z * 0.88))
	local rotationOnly = boxCF - boxCF.Position
	blocker.CFrame = CFrame.new(boxCF.Position.X, ROAD_SURFACE_Y + blocker.Size.Y * 0.5, boxCF.Position.Z) * rotationOnly
	blocker.Parent = model
end

local function fetchOne(assetId)
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

local function loadDisplay(primaryId, fallbackId, name, x, yawDegrees, sourceUrl)
	local loaded, loader = fetchOne(primaryId)
	local usedId = primaryId
	local source = "Ddiaz Design"

	if not loaded then
		warn(string.format("[BBYA] primary car asset %s unavailable; trying approved BBYA fallback %s", tostring(primaryId), tostring(fallbackId)))
		loaded, loader = fetchOne(fallbackId)
		usedId = fallbackId
		source = "BBYA approved premium fallback"
	end

	if not loaded then
		warn(string.format("[BBYA] entrance car %s could not load primary or fallback: %s", name, tostring(loader)))
		return nil
	end

	stripForDisplay(loaded)
	loaded.Name = name
	loaded:SetAttribute("RobloxAssetId", usedId)
	loaded:SetAttribute("PrimaryRobloxAssetId", primaryId)
	loaded:SetAttribute("DisplayOnly", true)
	loaded:SetAttribute("Creator", source)
	loaded:SetAttribute("SourceUrl", sourceUrl)
	loaded:SetAttribute("License", "CC BY-NC-SA 4.0")
	loaded:SetAttribute("CreatorPermission", true)
	loaded:SetAttribute("RuntimeLoader", loader)
	loaded:SetAttribute("UsedPrimaryAsset", usedId == primaryId)

	local placed, err = pcall(normalizeAndPlace, loaded, x, yawDegrees)
	if not placed then
		loaded:Destroy()
		warn(string.format("[BBYA] entrance car %s placement failed: %s", name, tostring(err)))
		return nil
	end

	local valid, geometry = visibleGeometryLooksLikeVehicle(loaded)
	if not valid then
		loaded:Destroy()
		warn(string.format("[BBYA] entrance car %s visual validation failed: %s", name, tostring(geometry)))
		return nil
	end
	loaded:SetAttribute("VisualValidation", geometry)
	addDisplayCollision(loaded)
	return loaded
end

local pending = Instance.new("Model")
pending.Name = PAIR_NAME
pending:SetAttribute("Pass", "BBYA_ENTRANCE_CARS_V11")
pending:SetAttribute("EntranceCarAuthority", "BBYA_ENTRANCE_CARS_V11")
pending:SetAttribute("TargetVehicleCount", 2)
pending:SetAttribute("CenterAccessKeptOpen", true)
pending:SetAttribute("DisplayOnly", true)
pending:SetAttribute("AttributionRequired", true)

local car01 = loadDisplay(CAR_01_ASSET_ID, CAR_01_BBYA_FALLBACK_ID, "BBYA Car 01", -15, 8, "https://skfb.ly/pFsG9")
local car02 = loadDisplay(CAR_02_ASSET_ID, CAR_02_BBYA_FALLBACK_ID, "BBYA Car 02", 15, 172, "https://skfb.ly/pKzpM")

if not car01 or not car02 then
	if car01 then car01:Destroy() end
	if car02 then car02:Destroy() end
	pending:Destroy()
	scene:SetAttribute("EntranceCarsQuarantined", true)
	scene:SetAttribute("EntranceCarAuthority", "BBYA_ENTRANCE_CARS_V11_LOAD_FAIL")
	warn("[BBYA] entrance pair aborted; both cars must validate before replacing any existing car authority")
	return
end

car01.Parent = pending
car02.Parent = pending
pending.Parent = scene

-- Transactional cleanup: only after BOTH replacement cars exist and validate.
for _, name in ipairs({
	"CloudCarSlot_Red", "CloudCarSlot_Blue", "PremiumCarPairV1", "PremiumCarPairV2",
	"PremiumCar_Left_Wine", "PremiumCar_Right_Pearl", "PremiumValetGalleryV5", "PremiumValetGalleryV6",
	"PremiumArrivalPolishV6", "DdiazPremiumValetV7", "DdiazPremiumValetV8", "BBYACarPairV9",
	"BBYACarPairBakedV10"
}) do
	local old = scene:FindFirstChild(name)
	if old and old ~= pending then old:Destroy() end
end

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
scene:SetAttribute("EntranceCarAuthority", "BBYA_ENTRANCE_CARS_V11")
scene:SetAttribute("EntranceCarSource", "DDIAZ_PRIMARY_BBYA_APPROVED_FALLBACK")
scene:SetAttribute("EntranceCar01AssetId", car01:GetAttribute("RobloxAssetId"))
scene:SetAttribute("EntranceCar02AssetId", car02:GetAttribute("RobloxAssetId"))
scene:SetAttribute("EntranceCarHuracanAssetId", CAR_01_ASSET_ID)
scene:SetAttribute("EntranceCarRX8AssetId", CAR_02_ASSET_ID)
scene:SetAttribute("EntranceCarCredit", "Ddiaz Design | CC BY-NC-SA 4.0 | creator permission")

print(string.format("[BBYA] Entrance Car Pair v11 online: car01=%s car02=%s", tostring(car01:GetAttribute("RobloxAssetId")), tostring(car02:GetAttribute("RobloxAssetId"))))
