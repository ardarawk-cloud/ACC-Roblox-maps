-- BBYA SOCIAL HUB — ENTRANCE PREMIUM CAR AUTHORITY v2
-- Removes the old blocky fallback cars and, only after CI provisions two
-- BBYA-owned Model asset IDs, loads a static premium matched pair.
-- Source geometry: Spectral GT RS (CC0), recolored deterministically by CI.

local AssetService = game:GetService("AssetService")
local Workspace = game:GetService("Workspace")

local LEFT_ASSET_ID = 75165818784223 -- BBYA_CAR_LEFT_ASSET_ID
local RIGHT_ASSET_ID = 119133013192596 -- BBYA_CAR_RIGHT_ASSET_ID
local TARGET_LENGTH = 16.4
local ROAD_SURFACE_Y = 0.52

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local scene = root:WaitForChild("EntranceStreetScene", 30)
if not scene then return end

task.wait(0.35)
local removed = 0
for _, name in ipairs({"CloudCarSlot_Red", "CloudCarSlot_Blue"}) do
	local car = scene:FindFirstChild(name)
	if car then
		car:Destroy()
		removed += 1
	end
end
scene:SetAttribute("FallbackCarsRemoved", true)
scene:SetAttribute("PremiumCarRequiredBeforeReturn", true)
print("[BBYA] Entrance car cleanup removed " .. removed .. " non-premium fallback cars")

-- Asset ingest is fail-closed. Never bring the old fallback geometry back.
if LEFT_ASSET_ID <= 0 or RIGHT_ASSET_ID <= 0 then
	warn("[BBYA] Premium entrance cars staged but asset IDs are not provisioned yet")
	return
end

task.wait(0.65)
local oldPair = scene:FindFirstChild("PremiumCarPairV1")
if oldPair then oldPair:Destroy() end

local pair = Instance.new("Model")
pair.Name = "PremiumCarPairV1"
pair:SetAttribute("Pass", "PREMIUM_ENTRANCE_CARS_V1")
pair:SetAttribute("SourceLicense", "CC0-1.0")
pair:SetAttribute("SourceModel", "Spectral GT RS")
pair.Parent = scene

local function sanitizeAndWrap(loaded, name)
	local model
	if loaded:IsA("Model") then
		model = loaded
	else
		model = Instance.new("Model")
		for _, child in ipairs(loaded:GetChildren()) do
			child.Parent = model
		end
		loaded:Destroy()
	end
	model.Name = name

	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("LuaSourceContainer") then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.CanTouch = false
			d.CanQuery = true
			d.CastShadow = true
			d.Massless = true
		end
	end
	return model
end

local function normalizeLength(model)
	local _, size = model:GetBoundingBox()
	local horizontal = math.max(size.X, size.Z)
	if horizontal <= 0.01 then
		error("loaded car has invalid bounding box")
	end
	model:ScaleTo(model:GetScale() * (TARGET_LENGTH / horizontal))
end

local function groundModel(model, targetCF)
	model:PivotTo(targetCF)
	local boxCF, size = model:GetBoundingBox()
	local bottomY = boxCF.Position.Y - size.Y * 0.5
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
		math.max(2, size.X * 0.82),
		math.max(1.4, size.Y * 0.52),
		math.max(2, size.Z * 0.82)
	)
	local rotationOnly = model:GetPivot() - model:GetPivot().Position
	blocker.CFrame = CFrame.new(boxCF.Position.X, ROAD_SURFACE_Y + blocker.Size.Y * 0.5, boxCF.Position.Z) * rotationOnly
	blocker.Parent = model
end

local function loadCar(assetId, name, targetCF, side)
	local ok, loaded = pcall(function()
		return AssetService:LoadAssetAsync(assetId)
	end)
	if not ok or not loaded then
		warn(string.format("[BBYA] Premium car load failed side=%s asset=%d error=%s", side, assetId, tostring(loaded)))
		return false
	end

	local model = sanitizeAndWrap(loaded, name)
	model.Parent = pair
	local okScale, scaleErr = pcall(normalizeLength, model)
	if not okScale then
		model:Destroy()
		warn(string.format("[BBYA] Premium car normalization failed side=%s: %s", side, tostring(scaleErr)))
		return false
	end
	groundModel(model, targetCF)
	addDisplayCollision(model)
	model:SetAttribute("RobloxAssetId", assetId)
	model:SetAttribute("DisplayOnly", true)
	model:SetAttribute("PremiumEntranceCar", true)
	return true
end

-- Both cars sit parallel to the curb and face the central arrival/crosswalk.
local leftOK = loadCar(
	LEFT_ASSET_ID,
	"PremiumCar_Left_Wine",
	CFrame.new(-31, 2, -75.5) * CFrame.Angles(0, math.rad(0), 0),
	"LEFT"
)
local rightOK = loadCar(
	RIGHT_ASSET_ID,
	"PremiumCar_Right_Pearl",
	CFrame.new(31, 2, -75.5) * CFrame.Angles(0, math.rad(180), 0),
	"RIGHT"
)

scene:SetAttribute("PremiumCarsRequested", true)
scene:SetAttribute("PremiumCarsReady", leftOK and rightOK)
scene:SetAttribute("PremiumCarsLeftAsset", LEFT_ASSET_ID)
scene:SetAttribute("PremiumCarsRightAsset", RIGHT_ASSET_ID)

if leftOK and rightOK then
	print(string.format("[BBYA] Premium entrance pair online left=%d right=%d", LEFT_ASSET_ID, RIGHT_ASSET_ID))
else
	warn("[BBYA] Premium entrance pair incomplete; no fallback geometry restored")
end