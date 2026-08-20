local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local root = ReplicatedStorage:WaitForChild("BBYAVATAR")
local remotes = root:WaitForChild("Remotes")
local showroom = Workspace:WaitForChild("BBYAVATAR_SHOWROOM")
local displays = showroom:WaitForChild("DisplayPoints")

local function ensurePrompt(pedestal, index)
    local prompt = pedestal:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Browse Look"
        prompt.ObjectText = "BBYAVATAR Look " .. index
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 12
        prompt.RequiresLineOfSight = false
        prompt.Parent = pedestal
    end

    prompt.Triggered:Connect(function(player)
        local event = remotes:FindFirstChild("OpenCatalog")
        if event then
            event:FireClient(player, {displayIndex = index})
        end
    end)
end

local openCatalog = remotes:FindFirstChild("OpenCatalog")
if not openCatalog then
    openCatalog = Instance.new("RemoteEvent")
    openCatalog.Name = "OpenCatalog"
    openCatalog.Parent = remotes
end

for i, pedestal in ipairs(displays:GetChildren()) do
    if pedestal:IsA("BasePart") then
        ensurePrompt(pedestal, i)
    end
end

print("[BBYAVATAR] Mannequin/display interaction ready")
