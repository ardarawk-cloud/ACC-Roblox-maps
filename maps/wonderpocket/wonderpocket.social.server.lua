local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage
local Social = remotes:FindFirstChild("Social") or Instance.new("RemoteEvent")
Social.Name = "Social"
Social.Parent = remotes

local giftVisuals = {
    Balloon = {color=Color3.fromRGB(255,110,170), shape=Enum.PartType.Ball},
    IceCream = {color=Color3.fromRGB(255,220,180), shape=Enum.PartType.Ball},
    Flower = {color=Color3.fromRGB(255,120,160), shape=Enum.PartType.Ball},
    Fireworks = {color=Color3.fromRGB(255,215,70), shape=Enum.PartType.Ball},
}

local lastAction = {}
local function rate(player)
    local now = os.clock()
    local prev = lastAction[player.UserId] or 0
    if now - prev < 2 then return false end
    lastAction[player.UserId] = now
    return true
end

local function nearestOther(player)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, dist
    for _,other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local r = other.Character and other.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (r.Position-root.Position).Magnitude
                if d <= 30 and (not dist or d < dist) then best, dist = other, d end
            end
        end
    end
    return best
end

local function giftMoment(sender, target, giftId)
    local cfg = giftVisuals[giftId]
    if not cfg then return end
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local p = Instance.new("Part")
    p.Name = "WonderGift_"..giftId
    p.Size = Vector3.new(1.2,1.2,1.2)
    p.Shape = cfg.shape
    p.Material = Enum.Material.Neon
    p.Color = cfg.color
    p.Anchored = true
    p.CanCollide = false
    p.Position = targetRoot.Position + Vector3.new(0,4,0)
    p.Parent = workspace

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 0
    emitter.Lifetime = NumberRange.new(.6,1.2)
    emitter.Speed = NumberRange.new(3,6)
    emitter.Parent = p
    emitter:Emit(giftId == "Fireworks" and 35 or 14)

    Social:FireAllClients("GIFT_MOMENT",sender.DisplayName,target.DisplayName,giftId)
    task.delay(3,function() if p then p:Destroy() end end)
end

Social.OnServerEvent:Connect(function(player, action, value)
    if not rate(player) then return end
    action = tostring(action)
    if action == "GIFT_NEAREST" then
        local giftId = tostring(value)
        if not giftVisuals[giftId] then return end
        local target = nearestOther(player)
        if not target then
            Social:FireClient(player,"NOTICE","No friend/player nearby")
            return
        end
        giftMoment(player,target,giftId)
    elseif action == "VISIT_NEAREST" then
        local target = nearestOther(player)
        if not target then return end
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local troot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if root and troot then root.CFrame = troot.CFrame * CFrame.new(4,0,0) end
    end
end)

Players.PlayerRemoving:Connect(function(p) lastAction[p.UserId] = nil end)
print("[WONDERPOCKET] Social visit + gift moments loaded")
