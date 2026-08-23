-- BBYAVATAR native R15 mannequin upgrade v1.
-- Replaces the low-part fallback silhouettes created by runtime.server.lua with
-- Roblox-native R15 rigs. If rig creation fails, the original silhouettes stay.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYAVATAR_SHOWROOM", 15)
if not root then
    warn("[BBYAVATAR] native mannequins skipped: showroom missing")
    return
end

local remoteFolder = ReplicatedStorage:WaitForChild("BBYAVATAR", 10)
local openEvent = remoteFolder and remoteFolder:FindFirstChild("OpenCatalog")
if not openEvent or not openEvent:IsA("RemoteEvent") then
    warn("[BBYAVATAR] native mannequins skipped: catalog remote missing")
    return
end

local description = Instance.new("HumanoidDescription")
description.HeightScale = 1.03
description.WidthScale = 0.92
description.DepthScale = 0.94
description.HeadScale = 0.95
description.BodyTypeScale = 0.72
description.ProportionScale = 0.78

local ok, template = pcall(function()
    return Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
end)
if not ok or not template then
    warn("[BBYAVATAR] native mannequin template unavailable; keeping fallback silhouettes")
    return
end

template.Name = "BBYAVATAR_R15_TEMPLATE"
local humanoid = template:FindFirstChildOfClass("Humanoid")
if humanoid then
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    humanoid.BreakJointsOnDeath = false
end
for _, descendant in ipairs(template:GetDescendants()) do
    if descendant:IsA("BasePart") then
        descendant.Anchored = true
        descendant.CanCollide = false
        descendant.CanTouch = false
        descendant.CanQuery = true
        descendant.CastShadow = true
    elseif descendant:IsA("Script") or descendant:IsA("LocalScript") then
        descendant:Destroy()
    end
end

local palette = {
    TRENDING = Color3.fromRGB(93,78,116),
    ["NEW DROPS"] = Color3.fromRGB(73,99,119),
    STREETWEAR = Color3.fromRGB(105,82,72),
    CYBER = Color3.fromRGB(65,104,108),
    LUXURY = Color3.fromRGB(125,105,68),
    CUTE = Color3.fromRGB(125,88,111),
    BALI = Color3.fromRGB(112,91,70),
    CREATORS = Color3.fromRGB(72,105,83),
    FEATURED = Color3.fromRGB(171,145,91),
}
local neutral = Color3.fromRGB(191,188,181)
local dark = Color3.fromRGB(38,39,44)

local function categoryFromModel(model)
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and prompt.ObjectText ~= "" then
        return prompt.ObjectText
    end
    local name = model.Name
    if string.sub(name, 1, 5) == "Look_" then
        return string.sub(name, 6)
    end
    return "FEATURED"
end

local function displayPosition(model)
    local torso = model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart", true)
    if torso then return torso.Position end
    return nil
end

local candidates = {}
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("Model") and string.sub(descendant.Name, 1, 5) == "Look_" then
        table.insert(candidates, descendant)
    end
end

local upgraded = 0
for index, oldModel in ipairs(candidates) do
    local pos = displayPosition(oldModel)
    if pos then
        local category = categoryFromModel(oldModel)
        local accent = palette[category] or Color3.fromRGB(92,92,102)
        local rig = template:Clone()
        rig.Name = string.format("R15Look_%02d_%s", index, string.gsub(category, "%s+", "_"))

        for _, descendant in ipairs(rig:GetDescendants()) do
            if descendant:IsA("BasePart") then
                local n = descendant.Name
                if string.find(n, "Head") then
                    descendant.Color = neutral
                elseif string.find(n, "Leg") or string.find(n, "Foot") then
                    descendant.Color = dark
                elseif n ~= "HumanoidRootPart" then
                    descendant.Color = accent
                end
            end
        end

        local upperTorso = rig:FindFirstChild("UpperTorso") or rig:FindFirstChild("Torso") or rig:FindFirstChild("HumanoidRootPart")
        if upperTorso and upperTorso:IsA("BasePart") then
            local q = Instance.new("ProximityPrompt")
            q.ActionText = "EXPLORE"
            q.ObjectText = category
            q.HoldDuration = 0
            q.MaxActivationDistance = 9
            q.RequiresLineOfSight = true
            q.Parent = upperTorso
            q.Triggered:Connect(function(player)
                openEvent:FireClient(player, category)
            end)
        end

        rig.Parent = oldModel.Parent
        rig:PivotTo(CFrame.new(pos.X, 3.15, pos.Z) * CFrame.Angles(0, math.rad(180), 0))
        oldModel:Destroy()
        upgraded += 1
    end
end

template:Destroy()
root:SetAttribute("MannequinSystem", "NATIVE_R15_V1")
root:SetAttribute("NativeR15Mannequins", upgraded)
root:SetAttribute("FallbackBlockMannequins", #candidates - upgraded)
print(string.format("[BBYAVATAR] native R15 mannequins ready • %d/%d upgraded", upgraded, #candidates))
