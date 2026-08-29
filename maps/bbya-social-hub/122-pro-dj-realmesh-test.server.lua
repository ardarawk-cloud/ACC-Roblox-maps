-- BBYA SOCIAL HUB — PRO DJ REAL-MESH V2 TEST LOADER
-- TEST PLACE ONLY. Visual-only. No audio writes. No global Lighting writes.
-- Source model attribution: MaxTht / Sketchfab / CC Attribution.

local AssetService = game:GetService("AssetService")
local Workspace = game:GetService("Workspace")

local TEST_PLACE_ID = 124607344716828
if game.PlaceId ~= TEST_PLACE_ID then
	return
end

local CDJ_PAIR_ASSET_ID = 0 -- BBYA_PRO_DJ_V2_CDJ_ASSET_ID
local DJM_A9_ASSET_ID = 0 -- BBYA_PRO_DJ_V2_DJM_ASSET_ID

if CDJ_PAIR_ASSET_ID <= 0 or DJM_A9_ASSET_ID <= 0 then
	warn("[BBYA Pro DJ V2] Model asset IDs are not provisioned")
	return
end

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end

local realism = root:WaitForChild("MainClubRealism", 30)
if not realism then
	warn("[BBYA Pro DJ V2] MainClubRealism unavailable")
	return
end

local dressing = realism:WaitForChild("Dressing", 15)
if dressing then
	dressing:WaitForChild("Planter_RRear", 30)
end

local av = realism:FindFirstChild("AudioVisual")
local booth = av and av:FindFirstChild("DJBoothPremium")
local boothTop = booth and booth:FindFirstChild("BoothTop")
if not booth or not boothTop or not boothTop:IsA("BasePart") then
	warn("[BBYA Pro DJ V2] DJ booth anchor unavailable")
	return
end

for _, name in ipairs({"DJEquipment", "BBYAProDJRigV1", "BBYAProDJRigV2"}) do
	local old = booth:FindFirstChild(name)
	if old then old:Destroy() end
end

local rig = Instance.new("Model")
rig.Name = "BBYAProDJRigV2"
rig:SetAttribute("Authority", "BBYA_PRO_DJ_REALMESH_V2_TEST")
rig:SetAttribute("VisualOnly", true)
rig:SetAttribute("AudioWrites", false)
rig:SetAttribute("GlobalLightingWrites", false)
rig:SetAttribute("TestPlaceOnly", true)
rig:SetAttribute("SourceLicense", "CC Attribution")
rig:SetAttribute("SourceCreator", "MaxTht")
rig.Parent = booth

local function sanitizeLoaded(loaded, name)
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

local function loadModel(assetId, name)
	local ok, loaded = pcall(function()
		return AssetService:LoadAssetAsync(assetId)
	end)
	if not ok or not loaded then
		warn(string.format("[BBYA Pro DJ V2] Load failed %s asset=%d error=%s", name, assetId, tostring(loaded)))
		return nil
	end
	local model = sanitizeLoaded(loaded, name)
	model.Parent = rig
	model:SetAttribute("RobloxAssetId", assetId)
	model:SetAttribute("DisplayOnly", true)
	return model
end

local function normalizeHorizontal(model, targetHorizontal)
	local _, size = model:GetBoundingBox()
	local horizontal = math.max(size.X, size.Z)
	if horizontal <= 0.01 then
		error("invalid model bounding box")
	end
	model:ScaleTo(model:GetScale() * (targetHorizontal / horizontal))
end

local function placeOnBooth(model, targetCF)
	model:PivotTo(targetCF)
	local boxCF, size = model:GetBoundingBox()
	local bottomY = boxCF.Position.Y - size.Y * 0.5
	local topY = boothTop.Position.Y + boothTop.Size.Y * 0.5 + 0.035
	model:PivotTo(model:GetPivot() + Vector3.new(0, topY - bottomY, 0))
end

local cdjPair = loadModel(CDJ_PAIR_ASSET_ID, "ProfessionalCDJPair")
local mixer = loadModel(DJM_A9_ASSET_ID, "ProfessionalFourChannelMixer")

if not cdjPair or not mixer then
	rig:SetAttribute("Ready", false)
	return
end

local okPair, pairErr = pcall(normalizeHorizontal, cdjPair, 10.8)
local okMixer, mixerErr = pcall(normalizeHorizontal, mixer, 4.45)
if not okPair or not okMixer then
	warn("[BBYA Pro DJ V2] Normalize failed: " .. tostring(pairErr or mixerErr))
	rig:Destroy()
	return
end

-- Both source assets preserve the same original coordinate frame. Overlaying
-- their pivots reconstructs the intended two-deck + center-mixer layout.
local centerCF = boothTop.CFrame * CFrame.new(0, boothTop.Size.Y * 0.5, 0)
placeOnBooth(cdjPair, centerCF)
placeOnBooth(mixer, centerCF)

rig:SetAttribute("CDJPairAssetId", CDJ_PAIR_ASSET_ID)
rig:SetAttribute("MixerAssetId", DJM_A9_ASSET_ID)
rig:SetAttribute("Ready", true)
print(string.format("[BBYA Pro DJ V2] REALMESH_READY cdj=%d mixer=%d place=%d", CDJ_PAIR_ASSET_ID, DJM_A9_ASSET_ID, game.PlaceId))
