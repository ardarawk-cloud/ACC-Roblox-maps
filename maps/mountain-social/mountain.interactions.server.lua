-- Mountain Social Adventure interaction systems
-- Campfire, secret-route reward, photo hooks. Server-authoritative where state matters.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")

local root = workspace:WaitForChild("ACC_MountainSocial")
local remotes = ReplicatedStorage:FindFirstChild("ACC_MountainRemotes") or Instance.new("Folder")
remotes.Name = "ACC_MountainRemotes"
remotes.Parent = ReplicatedStorage

local photoRemote = remotes:FindFirstChild("PhotoMode") or Instance.new("RemoteEvent")
photoRemote.Name = "PhotoMode"
photoRemote.Parent = remotes

local function prompt(part, action, objectText, hold)
    local p = part:FindFirstChildOfClass("ProximityPrompt") or Instance.new("ProximityPrompt")
    p.ActionText = action
    p.ObjectText = objectText
    p.HoldDuration = hold or 0
    p.MaxActivationDistance = 10
    p.RequiresLineOfSight = false
    p.Parent = part
    return p
end

local function setupCampfires()
    local camps = root:FindFirstChild("Camps")
    if not camps then return end
    for _,camp in ipairs(camps:GetChildren()) do
        local firePart = camp:FindFirstChild("Campfire", true)
        if firePart and firePart:IsA("BasePart") then
            local pr = prompt(firePart, "Warm Up", camp.Name, 0.4)
            pr.Triggered:Connect(function(player)
                player:SetAttribute("ACC_LastCamp", camp.Name)
                player:SetAttribute("ACC_WarmedUntil", os.time()+180)
            end)
        end
    end
end

local function setupSecrets()
    local secrets = root:FindFirstChild("Secrets")
    if not secrets then return end
    for _,node in ipairs(secrets:GetDescendants()) do
        if node:IsA("BasePart") and (node.Name == "SecretReward" or node:GetAttribute("SecretReward")) then
            local pr = prompt(node, "Discover", "Hidden Route", 0.8)
            pr.Triggered:Connect(function(player)
                if player:GetAttribute("ACC_SecretFound") then return end
                player:SetAttribute("ACC_SecretFound", true)
                local stats = player:FindFirstChild("leaderstats")
                local discoveries = stats and stats:FindFirstChild("Discoveries")
                if discoveries then discoveries.Value += 1 end
            end)
        end
    end
end

photoRemote.OnServerEvent:Connect(function(player, enabled)
    player:SetAttribute("ACC_PhotoMode", enabled == true)
end)

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("ACC_SecretFound", false)
    player:SetAttribute("ACC_PhotoMode", false)
end)

setupCampfires()
setupSecrets()
