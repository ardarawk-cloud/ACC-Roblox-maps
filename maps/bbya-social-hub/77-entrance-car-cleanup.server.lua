-- BBYA SOCIAL HUB — PREMIUM VALET ARRIVAL v6.1
-- Keeps the six official Roblox vehicles and adds lightweight arrival dressing:
-- warm local floor lights, champagne-gold guide accents, and velvet valet ropes.
-- No global Lighting writes; all gameplay/audio bundled with vehicle packs is stripped.
-- v6.1 fail-safe: fallback red/blue entrance cars remain until all six premium cars are ready.

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
local ALL_SLOTS = {-43, -28, -13, 13, 28, 43}

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local scene = root:WaitForChild("EntranceStreetScene", 30)
if not scene then return end

task.wait(0.35)

-- IMPORTANT: do not remove CloudCarSlot_Red / CloudCarSlot_Blue here.
-- They are the fail-safe arrival cars and are removed only after all premium cars load.
for _, name in ipairs({
	"PremiumCarPairV1",
	"PremiumCarPairV2",
	"PremiumCar_Left_Wine",
	"PremiumCar_Right_Pearl",
	"PremiumValetGalleryV5",
	"PremiumValetGalleryV6",
	"PremiumArrivalPolishV6",
}) do
	local old = scene:FindFirstChild(name)
	if old then old:Destroy() end
end

local gallery = Instance.new("Model")
gallery.Name = "PremiumValetGalleryV6"
gallery:SetAttribute("Pass", "PREMIUM_VALET_ARRIVAL_V6_1")
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

	loaded:Destroy()
	return selected
end

local function makePart(parent, name, size, cf, material, color, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Size = size
	p.CFrame = cf
	p.Material = material
	p.Color = color
	p.Transparency = transparency or 0
	p.CastShadow = false
	p.Parent = parent
	return p
end

local function addArrivalPolish()
	local polish = Instance.new("Model")
	polish.Name = "PremiumArrivalPolishV6"
	polish:SetAttribute("Pass", "PREMIUM_ARRIVAL_POLISH_V6")
	polish:SetAttribute("GlobalLightingWrites", false)
	polish:SetAttribute("MobileLightweight", true)
	polish.Parent = scene

	local champagne = Color3.fromRGB(212, 170, 92)
	local warm = Color3.fromRGB(255, 222, 182)
	local velvet = Color3.fromRGB(105, 12, 34)
	local nearBlack = Color3.fromRGB(15, 15, 18)

	-- Thin champagne guide lines visually tie the three-car groups together.
	makePart(
		polish,
		"LeftValetGuide",
		Vector3.new(38, 0.05, 0.16),
		CFrame.new(-30.5, ROAD_SURFACE_Y + 0.04, -69.1),
		Enum.Material.Neon,
		champagne,
		0.25
	)
	makePart(
		polish,
		"RightValetGuide",
		Vector3.new(38, 0.05, 0.16),
		CFrame.new(30.5, ROAD_SURFACE_Y + 0.04, -69.1),
		Enum.Material.Neon,
		champagne,
		0.25
	)

	-- One non-shadowing warm pool per display car. Small radius keeps mobile cost low.
	for i, x in ipairs(ALL_SLOTS) do
		local lamp = makePart(
			polish,
			"ValetFloorLight_" .. i,
			Vector3.new(1.1, 0.08, 1.1),
			CFrame.new(x, ROAD_SURFACE_Y + 0.045, -70.0),
			Enum.Material.Metal,
			nearBlack,
			0
		)
		local lens = makePart(
			polish,
			"ValetFloorLens_" .. i,
			Vector3.new(0.72, 0.025, 0.72),
			CFrame.new(x, ROAD_SURFACE_Y + 0.095, -70.0),
			Enum.Material.Neon,
			warm,
			0.18
		)
		lens.Parent = polish
		local point = Instance.new("PointLight")
		point.Name = "WarmDisplayPool"
		point.Color = warm
		point.Brightness = 0.72
		point.Range = 10
		point.Shadows = false
		point.Parent = lamp
	end

	local function makeBollard(name, x, z)
		local model = Instance.new("Model")
		model.Name = name
		model.Parent = polish

		makePart(
			model,
			"Base",
			Vector3.new(0.28, 1.15, 1.15),
			CFrame.new(x, ROAD_SURFACE_Y + 0.14, z) * CFrame.Angles(0, 0, math.rad(90)),
			Enum.Material.Metal,
			nearBlack,
			0
		).Shape = Enum.PartType.Cylinder

		local stem = makePart(
			model,
			"Stem",
			Vector3.new(2.2, 0.28, 0.28),
			CFrame.new(x, ROAD_SURFACE_Y + 1.25, z) * CFrame.Angles(0, 0, math.rad(90)),
			Enum.Material.Metal,
			champagne,
			0
		)
		stem.Shape = Enum.PartType.Cylinder

		local cap = makePart(
			model,
			"Cap",
			Vector3.new(0.28, 0.58, 0.58),
			CFrame.new(x, ROAD_SURFACE_Y + 2.35, z) * CFrame.Angles(0, 0, math.rad(90)),
			Enum.Material.Metal,
			champagne,
			0
		)
		cap.Shape = Enum.PartType.Cylinder

		local attachment = Instance.new("Attachment")
		attachment.Name = "RopeAttachment"
		attachment.Position = Vector3.new(0, 0.04, 0)
		attachment.Parent = cap

		local glow = Instance.new("PointLight")
		glow.Name = "BollardGlow"
		glow.Color = champagne
		glow.Brightness = 0.34
		glow.Range = 5
		glow.Shadows = false
		glow.Parent = cap
		return attachment
	end

	-- Two short velvet ropes frame the arrival path while leaving the center fully open.
	local leftA = makeBollard("ValetBollard_L1", -11, -67.2)
	local leftB = makeBollard("ValetBollard_L2", -6.8, -67.2)
	local rightA = makeBollard("ValetBollard_R1", 6.8, -67.2)
	local rightB = makeBollard("ValetBollard_R2", 11, -67.2)

	local function rope(name, a0, a1)
		local beam = Instance.new("Beam")
		beam.Name = name
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.Color = ColorSequence.new(velvet)
		beam.Width0 = 0.13
		beam.Width1 = 0.13
		beam.FaceCamera = true
		beam.Segments = 8
		beam.CurveSize0 = -0.28
		beam.CurveSize1 = 0.28
		beam.LightEmission = 0.12
		beam.Parent = polish
	end

	rope("VelvetRope_Left", leftA, leftB)
	rope("VelvetRope_Right", rightA, rightB)

	return polish
end

local leftCars = loadThree(LEFT_ASSET_ID, "Valet_Left_Sports", LEFT_SLOTS, 0)
local rightCars = loadThree(RIGHT_ASSET_ID, "Valet_Right_Super", RIGHT_SLOTS, 180)
local ready = leftCars ~= nil and rightCars ~= nil and #leftCars == 3 and #rightCars == 3

local fallbackRed = scene:FindFirstChild("CloudCarSlot_Red")
local fallbackBlue = scene:FindFirstChild("CloudCarSlot_Blue")
local fallbackReady = fallbackRed ~= nil and fallbackBlue ~= nil

local polishReady = false
if ready then
	-- Premium swap is transactional: only now may the dependable fallback cars disappear.
	if fallbackRed then fallbackRed:Destroy() end
	if fallbackBlue then fallbackBlue:Destroy() end
	fallbackReady = false

	local okPolish, polishErr = pcall(addArrivalPolish)
	polishReady = okPolish
	if not okPolish then
		local partial = scene:FindFirstChild("PremiumArrivalPolishV6")
		if partial then partial:Destroy() end
		warn("[BBYA] Arrival polish failed safely: " .. tostring(polishErr))
	end
else
	gallery:Destroy()
end

scene:SetAttribute("FallbackCarsRemoved", ready)
scene:SetAttribute("FallbackCarsRetained", not ready and fallbackReady)
scene:SetAttribute("EntranceCarsQuarantined", not ready and not fallbackReady)
scene:SetAttribute("EntranceCarAuthority", ready and "PREMIUM_VALET_ARRIVAL_V6_1" or "FALLBACK_STREET_CARS_FAILSAFE_V1")
scene:SetAttribute("PremiumCarsRequested", true)
scene:SetAttribute("PremiumCarsReady", ready)
scene:SetAttribute("PremiumCarsLeftAsset", LEFT_ASSET_ID)
scene:SetAttribute("PremiumCarsRightAsset", RIGHT_ASSET_ID)
scene:SetAttribute("PremiumEntranceCarCount", ready and 6 or (fallbackReady and 2 or 0))
scene:SetAttribute("PremiumEntranceCenterClearance", 26)
scene:SetAttribute("PremiumArrivalPolishReady", polishReady)
scene:SetAttribute("PremiumArrivalLocalLightCount", polishReady and 10 or 0)

if ready then
	print(string.format("[BBYA] Premium valet arrival v6.1 online cars=6 polish=%s left=%d right=%d", tostring(polishReady), LEFT_ASSET_ID, RIGHT_ASSET_ID))
elseif fallbackReady then
	warn("[BBYA] Premium valet unavailable; fallback red/blue entrance cars retained")
else
	warn("[BBYA] Premium valet unavailable and fallback entrance cars missing")
end