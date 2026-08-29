-- BBYA SOCIAL HUB — ROBLOX-NATIVE ENTRANCE CARS v4
-- Uses Roblox-owned Creator Store vehicle models so geometry/materials are
-- native to Roblox. All bundled scripts/audio/gameplay are removed before
-- the models enter Workspace; the cars are static visual displays only.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local LEFT_ASSET_ID = 6433323089 -- Roblox official Sports Car
local RIGHT_ASSET_ID = 6433330180 -- Roblox official Supercar
local ROAD_SURFACE_Y = 0.52
local ROAD_Z = -75.5

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
}) do
	local old = scene:FindFirstChild(name)
	if old then old:Destroy() end
end

local pair = Instance.new("Model")
pair.Name = "PremiumCarPairV2"
pair:SetAttribute("Pass", "ROBLOX_NATIVE_ENTRANCE_CARS_V4")
pair:SetAttribute("Source", "ROBLOX_CREATOR_STORE_OFFICIAL")
pair.Parent = scene

local function stripGameplay(model)
	for _, d in ipairs(model:GetDescendants()) do
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

local function positionNative(model, targetX, yawDegrees)
	model:PivotTo(CFrame.Angles(0, math.rad(yawDegrees), 0))
	local boxCF, size = model:GetBoundingBox()
	local horizontal = math.max(size.X, size.Z)

	-- Keep official Roblox scale unless an unexpected wrapper/extents issue
	-- makes the model obviously too large or tiny.
	if horizontal > 22 or horizontal < 8 then
		local correction = math.clamp(14.5 / math.max(horizontal, 0.01), 0.65, 1.6)
		model:ScaleTo(model:GetScale() * correction)
		model:PivotTo(CFrame.Angles(0, math.rad(yawDegrees), 0))
		boxCF, size = model:GetBoundingBox()
	end

	local bottomY = boxCF.Position.Y - size.Y * 0.5
	local delta = Vector3.new(
		targetX - boxCF.Position.X,
		ROAD_SURFACE_Y - bottomY,
		ROAD_Z - boxCF.Position.Z
	)
	model:PivotTo(model:GetPivot() + delta)
	return size
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
		math.max(3, size.X * 0.82),
		math.max(1.5, size.Y * 0.52),
		math.max(3, size.Z * 0.82)
	)
	blocker.CFrame = CFrame.new(
		boxCF.Position.X,
		ROAD_SURFACE_Y + blocker.Size.Y * 0.5,
		boxCF.Position.Z
	)
	blocker.Parent = model
end

local function loadOfficialCar(assetId, name, targetX, yawDegrees)
	local ok, loaded = pcall(InsertService.LoadAsset, InsertService, assetId)
	if not ok or not loaded then
		warn(string.format("[BBYA] Roblox-native car load failed asset=%d error=%s", assetId, tostring(loaded)))
		return false
	end

	loaded.Name = name
	stripGameplay(loaded)
	loaded.Parent = pair

	local okPosition, positionErr = pcall(positionNative, loaded, targetX, yawDegrees)
	if not okPosition then
		loaded:Destroy()
		warn(string.format("[BBYA] Roblox-native car placement failed asset=%d error=%s", assetId, tostring(positionErr)))
		return false
	end

	addDisplayBlocker(loaded)
	loaded:SetAttribute("RobloxAssetId", assetId)
	loaded:SetAttribute("DisplayOnly", true)
	loaded:SetAttribute("OfficialRobloxAsset", true)
	return true
end

local leftOK = loadOfficialCar(LEFT_ASSET_ID, "PremiumCar_Left_Sports", -31, 0)
local rightOK = loadOfficialCar(RIGHT_ASSET_ID, "PremiumCar_Right_Super", 31, 180)
local ready = leftOK and rightOK

if not ready then
	pair:Destroy()
end

scene:SetAttribute("FallbackCarsRemoved", true)
scene:SetAttribute("EntranceCarsQuarantined", not ready)
scene:SetAttribute("EntranceCarAuthority", "ROBLOX_NATIVE_V4")
scene:SetAttribute("PremiumCarsRequested", true)
scene:SetAttribute("PremiumCarsReady", ready)
scene:SetAttribute("PremiumCarsLeftAsset", LEFT_ASSET_ID)
scene:SetAttribute("PremiumCarsRightAsset", RIGHT_ASSET_ID)

if ready then
	print(string.format("[BBYA] Roblox-native premium entrance pair online left=%d right=%d", LEFT_ASSET_ID, RIGHT_ASSET_ID))
else
	warn("[BBYA] Roblox-native entrance pair failed closed; road left clean")
end
