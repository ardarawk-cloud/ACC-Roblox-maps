-- BBYA SOCIAL HUB — BAKED DDIAZ CAR PAIR v10
-- Canonical entrance-car authority: two creator-permitted Ddiaz Design display cars.
-- The actual Roblox Model assets are baked into ServerStorage by the dedicated packaging workflow.
-- Runtime only CLONES that baked source into the generated EntranceStreetScene.
-- No cloud asset loading. No procedural/fake-car fallback.
-- Runtime display names are intentionally generic: BBYA Car 01 / BBYA Car 02.
-- Attribution:
-- 2021 Vorsteiner Lamborghini Huracan EVO 2WD — Ddiaz Design
-- https://skfb.ly/pFsG9 — CC BY-NC-SA 4.0 — used in BBYA Social Hub with creator permission.
-- 2004 VeilSide D1-GT Mazda RX-8 Tokyo Drift — Ddiaz Design
-- https://skfb.ly/pKzpM — CC BY-NC-SA 4.0 — used in BBYA Social Hub with creator permission.

local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local CAR_01_ASSET_ID = 97052038046118
local CAR_02_ASSET_ID = 91172120786409
local BAKED_SOURCE_NAME = "BBYABakedCarsSourceV10"
local PAIR_NAME = "BBYACarPairBakedV10"
local ROAD_SURFACE_Y = 0.52
local ROAD_Z = -75.5
local TARGET_CAR_LENGTH = 13.8

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local scene = root:WaitForChild("EntranceStreetScene", 30)
if not scene then return end

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

local function countVisibleParts(model)
	local n = 0
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") and d.Transparency < 0.97 then n += 1 end
	end
	return n
end

local function normalizeAndPlace(model, x, yawDegrees)
	local _, size = model:GetBoundingBox()
	local horizontal = math.max(size.X, size.Z)
	if horizontal <= 0.05 then error("invalid vehicle extents") end
	local correction = math.clamp(TARGET_CAR_LENGTH / horizontal, 0.18, 3.5)
	if math.abs(correction - 1) > 0.01 then model:ScaleTo(model:GetScale() * correction) end

	local nativePivot = model:GetPivot()
	local nativeRotation = nativePivot - nativePivot.Position
	model:PivotTo(CFrame.new(x, 0, ROAD_Z) * CFrame.Angles(0, math.rad(yawDegrees), 0) * nativeRotation)

	local boxCF, placedSize = model:GetBoundingBox()
	local bottomY = boxCF.Position.Y - placedSize.Y * 0.5
	model:PivotTo(model:GetPivot() + Vector3.new(0, ROAD_SURFACE_Y - bottomY, 0))
end

local function validateVehicle(model)
	local visibleParts = 0
	local minX, minY, minZ = math.huge, math.huge, math.huge
	local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") and d.Transparency < 0.97 then
			visibleParts += 1
			local p, half = d.Position, d.Size * 0.5
			minX = math.min(minX, p.X-half.X); minY = math.min(minY, p.Y-half.Y); minZ = math.min(minZ, p.Z-half.Z)
			maxX = math.max(maxX, p.X+half.X); maxY = math.max(maxY, p.Y+half.Y); maxZ = math.max(maxZ, p.Z+half.Z)
		end
	end
	if visibleParts < 1 then return false, "no visible BaseParts" end
	local spanX, spanY, spanZ = maxX-minX, maxY-minY, maxZ-minZ
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
	blocker.Anchored = true; blocker.CanCollide = true; blocker.CanTouch = false; blocker.CanQuery = false; blocker.Transparency = 1
	blocker.Size = Vector3.new(math.max(4,size.X*.88), math.max(1.5,size.Y*.48), math.max(4,size.Z*.88))
	local rotationOnly = boxCF - boxCF.Position
	blocker.CFrame = CFrame.new(boxCF.Position.X, ROAD_SURFACE_Y + blocker.Size.Y*.5, boxCF.Position.Z) * rotationOnly
	blocker.Parent = model
end

local baked = ServerStorage:WaitForChild(BAKED_SOURCE_NAME, 15)
if not baked or not baked:IsA("Model") then
	scene:SetAttribute("EntranceCarsQuarantined", true)
	scene:SetAttribute("EntranceCarAuthority", "BAKED_DDIAZ_CARS_V10_SOURCE_MISSING")
	scene:SetAttribute("FallbackCarsRetained", false)
	warn("[BBYA] baked Ddiaz source missing from ServerStorage; refusing fake/runtime fallback")
	return
end

local oldPair = scene:FindFirstChild(PAIR_NAME)
if oldPair then oldPair:Destroy() end
local pair = baked:Clone()
pair.Name = PAIR_NAME
pair.Parent = scene

local car01 = pair:FindFirstChild("BBYA Car 01")
local car02 = pair:FindFirstChild("BBYA Car 02")
if not car01 or not car02 or not car01:IsA("Model") or not car02:IsA("Model") then
	pair:Destroy()
	scene:SetAttribute("EntranceCarsQuarantined", true)
	scene:SetAttribute("EntranceCarAuthority", "BAKED_DDIAZ_CARS_V10_INVALID_PACKAGE")
	warn("[BBYA] baked Ddiaz package is missing BBYA Car 01/02")
	return
end

stripForDisplay(car01); stripForDisplay(car02)
if countVisibleParts(car01) < 1 or countVisibleParts(car02) < 1 then
	pair:Destroy()
	scene:SetAttribute("EntranceCarsQuarantined", true)
	scene:SetAttribute("EntranceCarAuthority", "BAKED_DDIAZ_CARS_V10_NO_GEOMETRY")
	warn("[BBYA] baked Ddiaz package contains no visible geometry")
	return
end

local ok1, err1 = pcall(normalizeAndPlace, car01, -15, 8)
local ok2, err2 = pcall(normalizeAndPlace, car02, 15, 172)
if not ok1 or not ok2 then
	pair:Destroy()
	scene:SetAttribute("EntranceCarsQuarantined", true)
	scene:SetAttribute("EntranceCarAuthority", "BAKED_DDIAZ_CARS_V10_PLACEMENT_FAIL")
	warn(string.format("[BBYA] baked car placement failed car01=%s car02=%s", tostring(err1), tostring(err2)))
	return
end

local valid1, geo1 = validateVehicle(car01)
local valid2, geo2 = validateVehicle(car02)
if not valid1 or not valid2 then
	pair:Destroy()
	scene:SetAttribute("EntranceCarsQuarantined", true)
	scene:SetAttribute("EntranceCarAuthority", "BAKED_DDIAZ_CARS_V10_VISUAL_FAIL")
	warn(string.format("[BBYA] baked car validation failed car01=%s car02=%s", tostring(geo1), tostring(geo2)))
	return
end

car01:SetAttribute("RobloxAssetId", CAR_01_ASSET_ID); car01:SetAttribute("DisplayOnly", true); car01:SetAttribute("Creator", "Ddiaz Design")
car01:SetAttribute("SourceUrl", "https://skfb.ly/pFsG9"); car01:SetAttribute("License", "CC BY-NC-SA 4.0"); car01:SetAttribute("CreatorPermission", true); car01:SetAttribute("VisualValidation", geo1)
car02:SetAttribute("RobloxAssetId", CAR_02_ASSET_ID); car02:SetAttribute("DisplayOnly", true); car02:SetAttribute("Creator", "Ddiaz Design")
car02:SetAttribute("SourceUrl", "https://skfb.ly/pKzpM"); car02:SetAttribute("License", "CC BY-NC-SA 4.0"); car02:SetAttribute("CreatorPermission", true); car02:SetAttribute("VisualValidation", geo2)
addDisplayCollision(car01); addDisplayCollision(car02)

-- Retire every known old car authority after the baked pair validates.
for _, name in ipairs({
	"CloudCarSlot_Red","CloudCarSlot_Blue","PremiumCarPairV1","PremiumCarPairV2","PremiumCar_Left_Wine","PremiumCar_Right_Pearl",
	"PremiumValetGalleryV5","PremiumValetGalleryV6","PremiumArrivalPolishV6","DdiazPremiumValetV7","DdiazPremiumValetV8","BBYACarPairV9"
}) do
	local old = scene:FindFirstChild(name)
	if old and old ~= pair then old:Destroy() end
end

scene:SetAttribute("FallbackCarsRemoved", true); scene:SetAttribute("FallbackCarsRetained", false); scene:SetAttribute("EntranceCarsQuarantined", false)
scene:SetAttribute("EntranceCarAuthority", "BAKED_DDIAZ_CARS_V10"); scene:SetAttribute("EntranceCarSource", "DDIAZ_DESIGN_CREATOR_PERMISSION")
scene:SetAttribute("EntranceCar01AssetId", CAR_01_ASSET_ID); scene:SetAttribute("EntranceCar02AssetId", CAR_02_ASSET_ID)
scene:SetAttribute("EntranceCarHuracanAssetId", CAR_01_ASSET_ID); scene:SetAttribute("EntranceCarRX8AssetId", CAR_02_ASSET_ID)
scene:SetAttribute("EntranceCarCredit", "Ddiaz Design | CC BY-NC-SA 4.0 | creator permission")
pair:SetAttribute("Pass", "BAKED_DDIAZ_CARS_V10"); pair:SetAttribute("TargetVehicleCount", 2); pair:SetAttribute("CenterAccessKeptOpen", true)
pair:SetAttribute("DisplayOnly", true); pair:SetAttribute("AttributionRequired", true)

print("[BBYA] Baked Ddiaz Car Pair v10 online: BBYA Car 01 + BBYA Car 02 active")
