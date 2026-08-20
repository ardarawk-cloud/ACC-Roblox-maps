local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local root = ReplicatedStorage:WaitForChild("BBYAVATAR")
local shared = root:WaitForChild("Shared")
local remotes = root:WaitForChild("Remotes")

local CatalogConfig = require(shared:WaitForChild("CatalogConfig"))
local AvatarDescriptionBuilder = require(shared:WaitForChild("AvatarDescriptionBuilder"))

local showroom = Workspace:WaitForChild("BBYAVATAR_SHOWROOM")
local displays = showroom:WaitForChild("DisplayPoints")

local mannequins = showroom:FindFirstChild("Mannequins")
if not mannequins then
    mannequins = Instance.new("Folder")
    mannequins.Name = "Mannequins"
    mannequins.Parent = showroom
end

local openCatalog = remotes:FindFirstChild("OpenCatalog")
if not openCatalog then
    openCatalog = Instance.new("RemoteEvent")
    openCatalog.Name = "OpenCatalog"
    openCatalog.Parent = remotes
end

local function getEnabledLooks()
    return CatalogConfig.GetEnabledLooks()
end

local function buildDescription(look)
    local description = Instance.new("HumanoidDescription")
    if look then
        AvatarDescriptionBuilder.ApplyLook(description, look)
    end
    return description
end

local function createMannequin(pedestal, index, look)
    local description = buildDescription(look)
    local ok, model = pcall(function()
        return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
    end)

    if not ok or not model then
        warn("[BBYAVATAR] Could not create mannequin", index)
        return nil
    end

    model.Name = look and ("Look_" .. look.id) or ("Preview_" .. index)
    model.Parent = mannequins

    local rootPart = model:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.Anchored = true
        model:PivotTo(pedestal.CFrame * CFrame.new(0, 4, 0) * CFrame.Angles(0, math.rad(180), 0))
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end

    return model
end

local function ensurePrompt(pedestal, index, look)
    local prompt = pedestal:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 12
        prompt.RequiresLineOfSight = false
        prompt.Parent = pedestal
    end

    prompt.ActionText = look and "Open Look" or "Browse Catalog"
    prompt.ObjectText = look and look.name or "BBYAVATAR"

    prompt.Triggered:Connect(function(player)
        openCatalog:FireClient(player, {
            displayIndex = index,
            lookId = look and look.id or nil,
        })
    end)
end

for _, child in ipairs(mannequins:GetChildren()) do
    child:Destroy()
end

local enabledLooks = getEnabledLooks()
local pedestals = displays:GetChildren()
table.sort(pedestals, function(a, b)
    return a.Name < b.Name
end)

for index, pedestal in ipairs(pedestals) do
    if pedestal:IsA("BasePart") then
        local look = enabledLooks[index]
        createMannequin(pedestal, index, look)
        ensurePrompt(pedestal, index, look)
    end
end

print(string.format("[BBYAVATAR] Mannequins ready: %d enabled looks across %d displays", #enabledLooks, #pedestals))
