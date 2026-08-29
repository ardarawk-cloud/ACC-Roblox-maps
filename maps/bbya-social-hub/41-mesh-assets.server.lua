-- BBYA SOCIAL HUB — PRO DJ RIG REAL-MESH TEST v2
-- TEST PLACE ONLY. Loads two Roblox-owned test Model assets created from the CC BY source mesh.
-- No audio writes. No SoundGroup writes. No global Lighting writes.

local Workspace = game:GetService("Workspace")
local InsertService = game:GetService("InsertService")

local CDJ_ASSET_ID = tonumber("__CDJ_ASSET_ID__")
local MIXER_ASSET_ID = tonumber("__MIXER_ASSET_ID__")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD")
local oldPass = root:FindFirstChild("MeshAssetPass")
if oldPass then oldPass:Destroy() end

local out = Instance.new("Folder")
out.Name = "MeshAssetPass"
out:SetAttribute("Mode", "BBYA_PRO_DJ_RIG_V2_REAL_MESH_TEST")
out:SetAttribute("LegacyMarker", "BBYA_PRO_DJ_RIG_V1_NATIVE_PROTOTYPE")
out:SetAttribute("ExternalRuntimeAssets", true)
out:SetAttribute("VisualOnly", true)
out:SetAttribute("AudioWrites", false)
out:SetAttribute("GlobalLightingWrites", false)
out:SetAttribute("PrototypeOnly", true)
out:SetAttribute("Layout", "2_MEDIA_PLAYERS_PLUS_4CH_MIXER")
out:SetAttribute("Attribution", "Pioneer CDJ 3000 / DJM A9 model by MaxTht — Creative Commons Attribution")
out.Parent = root

if not CDJ_ASSET_ID or not MIXER_ASSET_ID then
    warn("[BBYA Pro DJ Rig v2] asset IDs were not injected by the isolated test publisher")
    return
end

local realism = root:WaitForChild("MainClubRealism", 30)
if not realism then
    warn("[BBYA Pro DJ Rig v2] MainClubRealism unavailable")
    return
end
local dressing = realism:WaitForChild("Dressing", 15)
if dressing then dressing:WaitForChild("Planter_RRear", 30) end

local av = realism:FindFirstChild("AudioVisual")
local booth = av and av:FindFirstChild("DJBoothPremium")
local boothTop = booth and booth:FindFirstChild("BoothTop")
if not booth or not boothTop or not boothTop:IsA("BasePart") then
    warn("[BBYA Pro DJ Rig v2] DJ booth anchor unavailable")
    return
end

local function loadModel(assetId, name)
    local ok, package = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)
    if not ok or not package then
        warn("[BBYA Pro DJ Rig v2] failed to load " .. name .. " asset=" .. tostring(assetId) .. " err=" .. tostring(package))
        return nil
    end
    package.Name = name
    for _, inst in ipairs(package:GetDescendants()) do
        if inst:IsA("BasePart") then
            inst.Anchored = true
            inst.CanCollide = false
            inst.CanTouch = false
            inst.CanQuery = false
            inst.CastShadow = true
        end
    end
    return package
end

local function placeOnBooth(model, targetWidth, xOffset, zOffset)
    model.Parent = booth
    local size = model:GetExtentsSize()
    local horizontal = math.max(size.X, 0.001)
    local scale = targetWidth / horizontal
    if model.ScaleTo then model:ScaleTo(scale) end
    size = model:GetExtentsSize()
    local y = boothTop.Size.Y * 0.5 + size.Y * 0.5 + 0.04
    model:PivotTo(boothTop.CFrame * CFrame.new(xOffset, y, zOffset))
end

-- Load first; only replace the old placeholder if BOTH real mesh assets are available.
local cdjLeft = loadModel(CDJ_ASSET_ID, "BBYA_REAL_CDJ_L")
local mixer = loadModel(MIXER_ASSET_ID, "BBYA_REAL_DJM_A9")
if not cdjLeft or not mixer then
    if cdjLeft then cdjLeft:Destroy() end
    if mixer then mixer:Destroy() end
    warn("[BBYA Pro DJ Rig v2] keeping old DJ equipment because real-mesh load was incomplete")
    return
end
local cdjRight = cdjLeft:Clone()
cdjRight.Name = "BBYA_REAL_CDJ_R"

local oldGear = booth:FindFirstChild("DJEquipment")
if oldGear then oldGear:Destroy() end
local oldV1 = booth:FindFirstChild("BBYAProDJRigV1")
if oldV1 then oldV1:Destroy() end
local oldV2 = booth:FindFirstChild("BBYAProDJRigV2RealMesh")
if oldV2 then oldV2:Destroy() end

local rig = Instance.new("Model")
rig.Name = "BBYAProDJRigV2RealMesh"
rig:SetAttribute("Authority", "BBYA_PRO_DJ_RIG_V2_REAL_MESH_TEST")
rig:SetAttribute("VisualTarget", "REAL_PROFESSIONAL_DJ_HARDWARE")
rig:SetAttribute("NoAudioWrites", true)
rig:SetAttribute("NoGlobalLightingWrites", true)
rig:SetAttribute("CDJAssetId", CDJ_ASSET_ID)
rig:SetAttribute("MixerAssetId", MIXER_ASSET_ID)
rig:SetAttribute("License", "CC BY")
rig:SetAttribute("CreatorCredit", "MaxTht")
rig.Parent = booth

cdjLeft.Parent = rig
mixer.Parent = rig
cdjRight.Parent = rig

-- Real-world layout: media player — 4-channel mixer — media player.
placeOnBooth(cdjLeft, 4.35, -4.55, 0.05)
placeOnBooth(mixer, 4.55, 0, 0.05)
placeOnBooth(cdjRight, 4.35, 4.55, 0.05)

out:SetAttribute("RigReady", true)
out:SetAttribute("CDJAssetId", CDJ_ASSET_ID)
out:SetAttribute("MixerAssetId", MIXER_ASSET_ID)
print("[BBYA] PRO DJ RIG v2 REAL MESH ready — two real-mesh media players + DJM mixer; audio/global lighting untouched")
