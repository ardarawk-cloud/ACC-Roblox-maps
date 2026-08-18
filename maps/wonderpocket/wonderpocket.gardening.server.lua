-- WONDERPOCKET Gardening Loop v0.2
local Players = game:GetService("Players")
local ROOT = workspace:FindFirstChild("WONDERPOCKET") or workspace
local plots = ROOT:FindFirstChild("GardenPlots") or Instance.new("Folder")
plots.Name = "GardenPlots"
plots.Parent = ROOT

local GROW_SECONDS = 180
local REWARD_COINS = 12

local function getStats(player)
    local stats = player:FindFirstChild("leaderstats")
    if not stats then
        stats = Instance.new("Folder")
        stats.Name = "leaderstats"
        stats.Parent = player
    end
    local coins = stats:FindFirstChild("Coins") or Instance.new("IntValue")
    coins.Name = "Coins"
    if coins.Parent == nil then coins.Value = 250 end
    coins.Parent = stats
    return coins
end

local function createPlot(player, index)
    local part = Instance.new("Part")
    part.Name = "Plot_" .. player.UserId .. "_" .. index
    part.Size = Vector3.new(6, .8, 6)
    part.Anchored = true
    part.Material = Enum.Material.Ground
    part.Color = Color3.fromRGB(96, 62, 40)
    part:SetAttribute("OwnerUserId", player.UserId)
    part:SetAttribute("State", "EMPTY")
    part:SetAttribute("ReadyAt", 0)
    part.Parent = plots

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Plant Carrot"
    prompt.ObjectText = "Garden Plot"
    prompt.HoldDuration = .35
    prompt.MaxActivationDistance = 10
    prompt.Parent = part

    prompt.Triggered:Connect(function(triggeringPlayer)
        if triggeringPlayer ~= player then return end
        local state = part:GetAttribute("State")
        local now = os.time()
        if state == "EMPTY" then
            part:SetAttribute("State", "GROWING")
            part:SetAttribute("ReadyAt", now + GROW_SECONDS)
            prompt.ActionText = "Growing..."
            local sprout = Instance.new("Part")
            sprout.Name = "Sprout"
            sprout.Size = Vector3.new(.5, .8, .5)
            sprout.Anchored = true
            sprout.CanCollide = false
            sprout.Color = Color3.fromRGB(80, 210, 100)
            sprout.Position = part.Position + Vector3.new(0, .8, 0)
            sprout.Parent = part
        elseif state == "GROWING" and now >= (part:GetAttribute("ReadyAt") or 0) then
            part:SetAttribute("State", "READY")
            prompt.ActionText = "Harvest Carrot"
            local sprout = part:FindFirstChild("Sprout")
            if sprout then
                sprout.Size = Vector3.new(1.1, 1.8, 1.1)
                sprout.Color = Color3.fromRGB(255, 140, 48)
            end
        elseif state == "READY" then
            getStats(player).Value += REWARD_COINS
            part:SetAttribute("State", "EMPTY")
            part:SetAttribute("ReadyAt", 0)
            prompt.ActionText = "Plant Carrot"
            local sprout = part:FindFirstChild("Sprout")
            if sprout then sprout:Destroy() end
            player:SetAttribute("WP_HarvestCount", (player:GetAttribute("WP_HarvestCount") or 0) + 1)
        end
    end)
    return part
end

local function setup(player)
    task.wait(2)
    local base = Vector3.new((player.UserId % 5) * 26, 2, -35 - math.floor((player.UserId % 25)/5)*26)
    for i=1,3 do
        local plot = createPlot(player, i)
        plot.Position = base + Vector3.new((i-2)*7, 0, 0)
    end
end

Players.PlayerAdded:Connect(setup)
for _,p in Players:GetPlayers() do task.spawn(setup,p) end
Players.PlayerRemoving:Connect(function(player)
    for _,obj in plots:GetChildren() do
        if obj:GetAttribute("OwnerUserId") == player.UserId then obj:Destroy() end
    end
end)

print("[WONDERPOCKET] Gardening loop loaded")
