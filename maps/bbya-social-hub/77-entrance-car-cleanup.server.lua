-- BBYA SOCIAL HUB — DDIAZ PREMIUM VALET ARRIVAL v7
-- Canonical entrance-car authority: two creator-permitted Ddiaz Design display cars.
-- Display only; scripts/audio/prompts/effects are stripped and every part is anchored.
-- Attribution:
-- 2021 Vorsteiner Lamborghini Huracan EVO 2WD — Ddiaz Design
-- https://skfb.ly/pFsG9 — CC BY-NC-SA 4.0 — used in BBYA Social Hub with creator permission.
-- 2004 VeilSide D1-GT Mazda RX-8 Tokyo Drift — Ddiaz Design
-- https://skfb.ly/pKzpM — CC BY-NC-SA 4.0 — used in BBYA Social Hub with creator permission.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local HURACAN_ASSET_ID = 97052038046118
local RX8_ASSET_ID = 91172120786409
local ROAD_SURFACE_Y = 0.52
local ROAD_Z = -75.5
local TARGET_CAR_LENGTH = 13.8

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local scene = root:WaitForChild("EntranceStreetScene", 30)
if not scene then return end

task.wait(0.5)

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

local function loadDisplay(assetId, name, x, yawDegrees, sourceUrl)
	local ok, loaded = pcall(InsertService.LoadAsset, InsertService, assetId)
	if not ok or not loaded then
		warn(string.format("[BBYA] Ddiaz car load failed asset=%s error=%s", tostring(assetId), tostring(loaded)))
		return nil
	end

	stripForDisplay(loaded)
	if countParts(loaded) < 1 then
		loaded:Destroy()
		warn(string.format("[BBYA] Ddiaz car asset=%s contains no BaseParts", tostring(assetId)))
		return nil
	end

	loaded.Name = name
	loaded:SetAttribute("RobloxAssetId", assetId)
	loaded:SetAttribute("DisplayOnly", true)
	loaded:SetAttribute("Creator", "Ddiaz Design")
	loaded:SetAttribute("SourceUrl", sourceUrl)
	loaded:SetAttribute("License", "CC BY-NC-SA 4.0")
	loaded:SetAttribute("CreatorPermission", true)

	local placed, err = pcall(normalizeAndPlace, loaded, x, yawDegrees)
	if not placed then
		loaded:Destroy()
		warn(string.format("[BBYA] Ddiaz car placement failed asset=%s error=%s", tostring(assetId), tostring(err)))
		return nil
	end

	addDisplayCollision(loaded)
	return loaded
end

local pending = Instance.new("Model")
pending.Name = "DdiazPremiumValetV7"
pending:SetAttribute("Pass", "DDIAZ_PREMIUM_VALET_V7")
pending:SetAttribute("EntranceCarAuthority", "DDIAZ_PREMIUM_VALET_V7")
pending:SetAttribute("TargetVehicleCount", 2)
pending:SetAttribute("CenterAccessKeptOpen", true)
pending:SetAttribute("DisplayOnly", true)
pending:SetAttribute("AttributionRequired", true)

local huracan = loadDisplay(HURACAN_ASSET_ID, "Ddiaz_Huracan_EVO", -15, 8, "https://skfb.ly/pFsG9")
local rx8 = loadDisplay(RX8_ASSET_ID, "Ddiaz_VeilSide_RX8", 15, 172, "https://skfb.ly/pKzpM")

if not huracan or not rx8 then
	if huracan then huracan:Destroy() end
	if rx8 then rx8:Destroy() end
	pending:Destroy()
	scene:SetAttribute("EntranceCarsQuarantined", true)
	scene:SetAttribute("EntranceCarAuthority", "FALLBACK_STREET_CARS_FAILSAFE_V1")
	return
end

huracan.Parent = pending
rx8.Parent = pending

-- Transactional swap: remove previous premium authority only after both new cars load and place.
for _, name in ipairs({
	"PremiumCarPairV1",
	"PremiumCarPairV2",
	"PremiumCar_Left_Wine",
	"PremiumCar_Right_Pearl",
	"PremiumValetGalleryV5",
	"PremiumValetGalleryV6",
	"PremiumArrivalPolishV6",
	"DdiazPremiumValetV7",
}) do
	local old = scene:FindFirstChild(name)
	if old then old:Destroy() end
end

pending.Parent = scene

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

floorLight("HuracanDisplayLight", -15)
floorLight("RX8DisplayLight", 15)

scene:SetAttribute("FallbackCarsRemoved", true)
scene:SetAttribute("FallbackCarsRetained", false)
scene:SetAttribute("EntranceCarsQuarantined", false)
scene:SetAttribute("EntranceCarAuthority", "DDIAZ_PREMIUM_VALET_V7")
scene:SetAttribute("EntranceCarSource", "DDIAZ_DESIGN_CREATOR_PERMISSION")
scene:SetAttribute("EntranceCarHuracanAssetId", HURACAN_ASSET_ID)
scene:SetAttribute("EntranceCarRX8AssetId", RX8_ASSET_ID)
scene:SetAttribute("EntranceCarCredit", "Ddiaz Design | CC BY-NC-SA 4.0 | creator permission")
