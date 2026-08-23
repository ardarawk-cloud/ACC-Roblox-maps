-- BBYA SOCIAL HUB — FISHING FEEDBACK HOTFIX v394
-- Fixes screenshot feedback only: rod does not travel outside lakeside, water reads deeper,
-- and ambient fish schools sit well below the surface. Does not replace Fishing Core v2/v3.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 35)
if not root then return end
local district = root:WaitForChild("PremiumFishingDistrictV2", 35)
if not district then return end

task.wait(2)

district:SetAttribute("FeedbackHotfix", "V394")
district:SetAttribute("RodAutoStoredOutsideLake", true)
district:SetAttribute("DeepWaterVisual", true)
district:SetAttribute("AmbientFishHiddenBelowSurface", true)

local LAKE_CENTER = Vector3.new(
    district:GetAttribute("LakeCenterX") or 0,
    0,
    district:GetAttribute("LakeCenterZ") or 790
)
local ACTIVE_RADIUS = 205
local ACTIVE_RADIUS_SQ = ACTIVE_RADIUS * ACTIVE_RADIUS

local function nearFishingDistrict(player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local dx = hrp.Position.X - LAKE_CENTER.X
    local dz = hrp.Position.Z - LAKE_CENTER.Z
    return (dx * dx + dz * dz) <= ACTIVE_RADIUS_SQ
end

local function clearFishingRodsFrom(container)
    if not container then return end
    for _, item in ipairs(container:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("BBYAFishingRod") == true then
            item:Destroy()
        end
    end
end

local function storeRodOutsideLake(player)
    if nearFishingDistrict(player) then
        player:SetAttribute("BBYAFishingRodStored", false)
        return
    end
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:UnequipTools() end
        clearFishingRodsFrom(char)
    end
    clearFishingRodsFrom(player:FindFirstChildOfClass("Backpack"))
    player:SetAttribute("BBYAFishingRodStored", true)
end

-- Make the original surface less transparent and substantially darken the body below it.
local lakeWater = district:FindFirstChild("LakeWater", true)
if lakeWater and lakeWater:IsA("BasePart") then
    lakeWater.Color = Color3.fromRGB(18, 58, 76)
    lakeWater.Transparency = 0.18
    lakeWater.Reflectance = 0.08
    lakeWater.Material = Enum.Material.Glass
    lakeWater:SetAttribute("DeepWaterSurfaceV394", true)
end

local deepWater = district:FindFirstChild("DeepWater", true)
if deepWater and deepWater:IsA("BasePart") then
    deepWater.Color = Color3.fromRGB(5, 22, 35)
    deepWater.Transparency = 0.08
    deepWater.Size = Vector3.new(deepWater.Size.X, 8.5, deepWater.Size.Z)
    deepWater.CFrame = CFrame.new(deepWater.Position.X, -3.65, deepWater.Position.Z)
    deepWater.Reflectance = 0.02
    deepWater.Material = Enum.Material.Glass
    deepWater:SetAttribute("DepthMetersVisual", 8.5)
end

-- Extra dark lower volume gives the lake actual visual depth instead of a thin glass plate.
local oldVolume = district:FindFirstChild("DeepLakeVolumeV394")
if oldVolume then oldVolume:Destroy() end
local volume = Instance.new("Part")
volume.Name = "DeepLakeVolumeV394"
volume.Shape = Enum.PartType.Ball
volume.Size = Vector3.new(214, 10.5, 132)
volume.CFrame = CFrame.new(LAKE_CENTER.X, -5.0, LAKE_CENTER.Z)
volume.Color = Color3.fromRGB(4, 18, 29)
volume.Material = Enum.Material.Glass
volume.Transparency = 0.15
volume.Reflectance = 0
volume.Anchored = true
volume.CanCollide = false
volume.CanTouch = false
volume.CanQuery = false
volume.CastShadow = false
volume.Parent = district

-- V3 schools were intentionally close to the surface for visibility. Feedback wants depth,
-- so push their animation centers down and soften geometry visibility.
local upgrade = district:FindFirstChild("PremiumFishingUpgradeV3")
local schools = upgrade and upgrade:FindFirstChild("AmbientFishSchools", true)
if schools then
    local depthByName = {
        AzureSchool = -4.2,
        JadeSchool = -4.8,
        MoonSchool = -5.3,
        RareSchool = -4.5,
    }
    for _, school in ipairs(schools:GetChildren()) do
        if school:IsA("Model") and school:GetAttribute("BBYAFishSchool") == true then
            local targetY = depthByName[school.Name] or -4.6
            school:SetAttribute("CenterY", targetY)
            school:SetAttribute("SurfaceHiddenV394", true)
            for _, d in ipairs(school:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Transparency = math.max(d.Transparency, 0.30)
                end
            end
        end
    end
end

local function setupPlayer(player)
    task.spawn(function()
        task.wait(1)
        storeRodOutsideLake(player)
    end)
    player.CharacterAdded:Connect(function()
        task.wait(1.2)
        storeRodOutsideLake(player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)

-- Low-frequency authority guard: cheap, and guarantees rods cannot be carried back to club/mall.
task.spawn(function()
    while task.wait(0.65) do
        for _, player in ipairs(Players:GetPlayers()) do
            if not nearFishingDistrict(player) then
                storeRodOutsideLake(player)
            end
        end
    end
end)

print("[BBYA] Fishing feedback hotfix v394 online: rod auto-store + deep lake + submerged schools")
