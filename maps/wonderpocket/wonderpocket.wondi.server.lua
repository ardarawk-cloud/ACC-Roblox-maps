-- WONDERPOCKET Wondi Follow System v0.2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ROOT = workspace:FindFirstChild("WONDERPOCKET") or workspace
local folder = ROOT:FindFirstChild("ActiveWondies") or Instance.new("Folder")
folder.Name = "ActiveWondies"
folder.Parent = ROOT

local active = {}

local function makeWondi(player)
    local old = active[player]
    if old then old:Destroy() end

    local model = Instance.new("Model")
    model.Name = "Bubbi_" .. player.UserId

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Shape = Enum.PartType.Ball
    body.Size = Vector3.new(2.6, 2.4, 2.6)
    body.Material = Enum.Material.SmoothPlastic
    body.Color = Color3.fromRGB(118, 224, 145)
    body.Anchored = true
    body.CanCollide = false
    body.Parent = model

    local leaf = Instance.new("Part")
    leaf.Name = "Leaf"
    leaf.Size = Vector3.new(.35, 1.2, .75)
    leaf.Material = Enum.Material.SmoothPlastic
    leaf.Color = Color3.fromRGB(70, 180, 96)
    leaf.Anchored = true
    leaf.CanCollide = false
    leaf.Parent = model

    model.PrimaryPart = body
    model.Parent = folder
    model:SetAttribute("OwnerUserId", player.UserId)
    model:SetAttribute("WondiId", "Bubbi")
    active[player] = model
end

local function remove(player)
    if active[player] then
        active[player]:Destroy()
        active[player] = nil
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        makeWondi(player)
    end)
end)

for _, player in Players:GetPlayers() do
    if player.Character then makeWondi(player) end
    player.CharacterAdded:Connect(function()
        task.wait(1)
        makeWondi(player)
    end)
end

Players.PlayerRemoving:Connect(remove)

RunService.Heartbeat:Connect(function(dt)
    for player, model in pairs(active) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local body = model and model.PrimaryPart
        if root and body then
            local t = os.clock()
            local target = root.Position - root.CFrame.LookVector * 4 + root.CFrame.RightVector * 2 + Vector3.new(0, 1.4 + math.sin(t*3)*.25, 0)
            local alpha = 1 - math.exp(-6 * dt)
            local pos = body.Position:Lerp(target, alpha)
            body.CFrame = CFrame.new(pos, root.Position + Vector3.new(0,1,0))
            local leaf = model:FindFirstChild("Leaf")
            if leaf then
                leaf.CFrame = body.CFrame * CFrame.new(0, 1.55, 0) * CFrame.Angles(0, 0, math.rad(20))
            end
        end
    end
end)

print("[WONDERPOCKET] Wondi follow system loaded")
