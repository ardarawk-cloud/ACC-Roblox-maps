-- WONDERPOCKET Gardening Loop v1.0
local Players = game:GetService("Players")

local ROOT = workspace:FindFirstChild("WONDERPOCKET") or workspace
local plots = ROOT:FindFirstChild("GardenPlots") or Instance.new("Folder")
plots.Name = "GardenPlots"
plots.Parent = ROOT

local GROW_SECONDS = 180
local REWARD_COINS = 12

local function addCoins(player, amount)
    player:SetAttribute("Coins", (tonumber(player:GetAttribute("Coins")) or 0) + math.max(0, math.floor(amount)))
end

local function waitForPlot(player)
    local deadline = os.clock() + 12
    while player.Parent and os.clock() < deadline do
        local index = tonumber(player:GetAttribute("WP_PlotIndex")) or 0
        local cx = tonumber(player:GetAttribute("WP_PlotCenterX"))
        local cz = tonumber(player:GetAttribute("WP_PlotCenterZ"))
        if index > 0 and cx and cz then return Vector3.new(cx, 5.6, cz) end
        task.wait(.25)
    end
    return nil
end

local function resetPlot(part, prompt)
    part:SetAttribute("State", "EMPTY")
    part:SetAttribute("ReadyAt", 0)
    prompt.ActionText = "Plant Carrot"
    local sprout = part:FindFirstChild("Sprout")
    if sprout then sprout:Destroy() end
end

local function createPlot(player, index, position)
    local part = Instance.new("Part")
    part.Name = "Plot_" .. player.UserId .. "_" .. index
    part.Size = Vector3.new(6, .8, 6)
    part.Position = position
    part.Anchored = true
    part.Material = Enum.Material.Ground
    part.Color = Color3.fromRGB(96, 62, 40)
    part:SetAttribute("OwnerUserId", player.UserId)
    part:SetAttribute("State", "EMPTY")
    part:SetAttribute("ReadyAt", 0)
    part.Parent = plots

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Plant Carrot"
    prompt.ObjectText = "Your Garden Plot"
    prompt.HoldDuration = .25
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = part

    prompt.Triggered:Connect(function(triggeringPlayer)
        if triggeringPlayer ~= player or player:GetAttribute("WP_DataLoaded") ~= true then return end
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

            player:SetAttribute("WP_PlantedCount", (tonumber(player:GetAttribute("WP_PlantedCount")) or 0) + 1)
        elseif state == "GROWING" then
            local readyAt = tonumber(part:GetAttribute("ReadyAt")) or 0
            if now < readyAt then
                prompt.ActionText = "Growing... " .. tostring(math.max(1, readyAt - now)) .. "s"
                return
            end

            addCoins(player, REWARD_COINS)
            player:SetAttribute("WP_HarvestCount", (tonumber(player:GetAttribute("WP_HarvestCount")) or 0) + 1)
            resetPlot(part, prompt)
        end
    end)

    return part
end

local function setup(player)
    local center = waitForPlot(player)
    if not center then
        warn("[WONDERPOCKET] No player plot available for garden", player.UserId)
        return
    end

    local offsets = {Vector3.new(-7,0,9), Vector3.new(0,0,9), Vector3.new(7,0,9)}
    for i, offset in ipairs(offsets) do
        createPlot(player, i, center + offset)
    end
    player:SetAttribute("WP_GardenReady", true)
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("WP_PlantedCount", 0)
    player:SetAttribute("WP_HarvestCount", tonumber(player:GetAttribute("WP_HarvestCount")) or 0)
    task.spawn(setup, player)
end)
for _, player in Players:GetPlayers() do task.spawn(setup, player) end

Players.PlayerRemoving:Connect(function(player)
    for _, obj in plots:GetChildren() do
        if obj:GetAttribute("OwnerUserId") == player.UserId then obj:Destroy() end
    end
end)

print("[WONDERPOCKET] Plot-owned canonical gardening loop loaded")
