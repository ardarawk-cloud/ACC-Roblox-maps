-- BBYA SOCIAL HUB — SIX-CAR VALET GALLERY v5
-- Turns the two Roblox-owned Creator Store vehicle packs into an intentional
-- six-car arrival gallery. Each vehicle is extracted, normalized and parked
-- independently so the entrance reads as premium valet, not an inserted pack.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local LEFT_ASSET_ID = 6433323089 -- Roblox official Sports Car pack
local RIGHT_ASSET_ID = 6433330180 -- Roblox official Supercar pack
local ROAD_SURFACE_Y = 0.52
local ROAD_Z = -75.5
local TARGET_CAR_LENGTH = 13.4

-- Leave a generous center opening for the entrance/crosswalk.
local LEFT_SLOTS = {-43, -28, -13}
local RIGHT_SLOTS = {13, 28, 43}

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local scene = root:WaitForChild("EntranceStreetScene", 30)
if not scene then return end

task.wait(0.35)

for _, name in ipairs({
	"CloudCarSlot_Red",
	"CloudCarSlot_Blue",
	"PremiumCarPairV1",
	"PremiumCarPairV2",
	"PremiumCar_Left_Wine",
	"PremiumCar_Right_Pearl",
	"PremiumValetGalleryV5",
}) do
	local old = scene:FindFirstChild(name)
	if old then old:Destroy() end
end

local gallery = Instance.new("Model")
gallery.Name = "PremiumValetGalleryV5"
gallery:SetAttribute("Pass", "SIX_CAR_VALET_GALLERY_V5")
gallery:SetAttribute("Source", "ROBLOX_CREATOR_STORE_OFFICIAL")
gallery:SetAttribute("TargetVehicleCount", 6)
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

local function collectVehicleModels(container)
	local candidates = {}
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Model") then
			local parts = countParts(child)
			local okBox, boxCF, size = pcall(function()
				local cf, s = child:GetBoundingBox()
				return cf, s
			end)
			if okBox and boxCF and size then
				local horizontal = math.max(size.X, size.Z)
				if parts >= 6 and horizontal >= 5 and horizontal <= 30 and size.Y <= 14 then
					table.insert(candidates, child)
				end
			end
		end
	end

	-- Keep the pack's original left-to-right ordering so liveries remain varied.
	table.sort(candidates, function(a, b)
		local aCF = a:GetBoundingBox()
		local bCF = b:GetBoundingBox()
		return aCF.Position.X < bCF.Position.X
	end)
	return candidates
end

local function normalizeVehicle(model)
	local _, size = model:GetBoundingBox()
	local horizontal = math.max(size.X, size.Z)
	if horizontal <= 0.01 then
		error("vehicle has invalid extents")
	end
	local correction = math.clamp(TARGET_CAR_LENGTH / horizontal, 0.72, 1.45)
	if math.abs(correction - 1) > 0.015 then
		model:ScaleTo(model:GetScale() * correction)
	end
end

local function placeVehicle(model, x, yawDegrees)
	normalizeVehicle(model)

	-- Preserve the model's native orientation, then mirror the opposite valet row.
	local originalPivot = model:GetPivot()
	local nativeRotation = originalPivot - originalPivot.Position
	model:PivotTo(CFrame.new(x, 0, ROAD_Z) * CFrame.Angles(0, math.rad(yawDegrees), 0) * nativeRotation)

	local boxCF, size = model:GetBoundingBox()
	local bottomY = boxCF.Position.Y - size.Y * 0.5
	model:PivotTo(model:GetPivot() + Vector3.new(0, ROAD_SURFACE_Y - bottomY, 0))
end

local function addDisplayBlocker(model)
	local boxCF, size = model:GetBoundingBox()
	local blocker = Instance.new("Part")
	blocker.Name = "DisplayCollision"
	blocker.Anchored = true
	blocker.CanCollide = true
	blocker.CanTouch = false
	blocker.CanQuery = false
	blocker.Transparency = 1
	blocker.Size = Vector3.new(
		math.max(3, size.X * 0.86),
		math.max(1.4, size.Y * 0.46),
		math.max(3, size.Z * 0.86)
	)
	local rotationOnly = boxCF - boxCF.Position
	blocker.CFrame = CFrame.new(
		boxCF.Position.X,
		ROAD_SURFACE_Y + blocker.Size.Y * 0.5,
		boxCF.Position.Z
	) * rotationOnly
	blocker.Parent = model
end

local function loadThree(assetId, prefix, slots, yawDegrees)
	local ok, loaded = pcall(InsertService.LoadAsset, InsertService, assetId)
	if not ok or not loaded then
		warn(string.format("[BBYA] Valet pack load failed asset=%d error=%s", assetId, tostring(loaded)))
		return nil
	end

	stripGameplay(loaded)
	local vehicles = collectVehicleModels(loaded)
	if #vehicles < 3 then
		warn(string.format("[BBYA] Valet pack asset=%d exposed only %d vehicle models", assetId, #vehicles))
		loaded:Destroy()
		return nil
	end

	local selected = {}
	for i = 1, 3 do
		local vehicle = vehicles[i]
		vehicle.Parent = gallery
		vehicle.Name = string.format("%s_%02d", prefix, i)
		vehicle:SetAttribute("RobloxAssetId", assetId)
		vehicle:SetAttribute("DisplayOnly", true)
		vehicle:SetAttribute("OfficialRobloxAsset", true)
		vehicle:SetAttribute("ValetSlot", i)

		local okPlace, placeErr = pcall(placeVehicle, vehicle, slots[i], yawDegrees)
		if not okPlace then
			warn(string.format("[BBYA] Valet vehicle placement failed asset=%d index=%d error=%s", assetId, i, tostring(placeErr)))
			loaded:Destroy()
			return nil
		end
		addDisplayBlocker(vehicle)
		table.insert(selected, vehicle)
	end

	-- Any unused pack wrappers/extra contents are intentionally discarded.
	loaded:Destroy()
	return selected
end

local leftCars = loadThree(LEFT_ASSET_ID, "Valet_Left_Sports", LEFT_SLOTS, 0)
local rightCars = loadThree(RIGHT_ASSET_ID, "Valet_Right_Super", RIGHT_SLOTS, 180)
local ready = leftCars ~= nil and rightCars ~= nil and #leftCars == 3 and #rightCars == 3

if not ready then
	gallery:Destroy()
end

scene:SetAttribute("FallbackCarsRemoved", true)
scene:SetAttribute("EntranceCarsQuarantined", not ready)
scene:SetAttribute("EntranceCarAuthority", "SIX_CAR_VALET_GALLERY_V5")
scene:SetAttribute("PremiumCarsRequested", true)
scene:SetAttribute("PremiumCarsReady", ready)
scene:SetAttribute("PremiumCarsLeftAsset", LEFT_ASSET_ID)
scene:SetAttribute("PremiumCarsRightAsset", RIGHT_ASSET_ID)
scene:SetAttribute("PremiumEntranceCarCount", ready and 6 or 0)
scene:SetAttribute("PremiumEntranceCenterClearance", 26)

if ready then
	print(string.format("[BBYA] Six-car valet gallery online count=6 left=%d right=%d", LEFT_ASSET_ID, RIGHT_ASSET_ID))
else
	warn("[BBYA] Six-car valet gallery failed closed; road left clean")
end
