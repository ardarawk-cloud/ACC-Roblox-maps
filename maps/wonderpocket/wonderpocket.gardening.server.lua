-- WONDERPOCKET Persistent Gardening Loop v1.2
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")

local ROOT = workspace:FindFirstChild("WONDERPOCKET") or workspace
local plotsFolder = ROOT:FindFirstChild("GardenPlots") or Instance.new("Folder")
plotsFolder.Name = "GardenPlots"
plotsFolder.Parent = ROOT

local Store = DataStoreService:GetDataStore("WONDERPOCKET_Garden_v1")
local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave", 20)
local GROW_SECONDS = 180
local REWARD_COINS = 12
local MAX_RETRIES = 4

local state = {}
local revision = {}
local savedRevision = {}
local saving = {}
local forcePending = {}
local actionLocks = {}

local function retry(label, fn)
    local lastErr
    for attempt=1,MAX_RETRIES do
        local ok, result = pcall(fn)
        if ok then return true, result end
        lastErr = result
        warn(string.format("[WONDERPOCKET] %s attempt %d failed: %s", label, attempt, tostring(result)))
        task.wait(math.min(2^(attempt-1), 6))
    end
    return false, lastErr
end

local function blankState()
    return {schemaVersion=1, plots={{readyAt=0},{readyAt=0},{readyAt=0}}}
end

local function normalize(data)
    if type(data) ~= "table" then data = blankState() end
    if type(data.plots) ~= "table" then data.plots = {} end
    for i=1,3 do
        local entry = type(data.plots[i]) == "table" and data.plots[i] or {}
        data.plots[i] = {readyAt=math.max(0, math.floor(tonumber(entry.readyAt) or 0))}
    end
    data.schemaVersion = 1
    return data
end

local function markDirty(player)
    revision[player] = (revision[player] or 0) + 1
end

local function save(player, force)
    local data = state[player]
    if not data then return false end
    if saving[player] then
        if force then forcePending[player] = true end
        return false
    end
    local currentRevision = revision[player] or 0
    if not force and currentRevision <= (savedRevision[player] or 0) then return true end

    saving[player] = true
    local targetRevision = currentRevision
    local payload = {
        schemaVersion = 1,
        plots = {
            {readyAt=data.plots[1].readyAt or 0},
            {readyAt=data.plots[2].readyAt or 0},
            {readyAt=data.plots[3].readyAt or 0},
        },
    }
    local ok = retry("garden save u_"..player.UserId, function()
        Store:UpdateAsync("u_"..player.UserId, function() return payload end)
    end)
    saving[player] = nil

    if ok then
        savedRevision[player] = math.max(savedRevision[player] or 0, targetRevision)
        player:SetAttribute("WP_GardenSaveHealthy", true)
    else
        player:SetAttribute("WP_GardenSaveHealthy", false)
    end

    local rerun = forcePending[player] == true or (revision[player] or 0) > (savedRevision[player] or 0)
    local nextForce = forcePending[player] == true
    forcePending[player] = nil
    if rerun and player.Parent and state[player] then task.defer(save, player, nextForce) end
    return ok
end

local function waitForPlot(player)
    local deadline = os.clock() + 15
    while player.Parent and os.clock() < deadline do
        local index = tonumber(player:GetAttribute("WP_PlotIndex")) or 0
        local cx = tonumber(player:GetAttribute("WP_PlotCenterX"))
        local cy = tonumber(player:GetAttribute("WP_PlotCenterY")) or 5
        local cz = tonumber(player:GetAttribute("WP_PlotCenterZ"))
        if index > 0 and cx and cz then return Vector3.new(cx, cy + .6, cz) end
        task.wait(.25)
    end
    return nil
end

local function addCoins(player, amount)
    player:SetAttribute("Coins", (tonumber(player:GetAttribute("Coins")) or 0) + math.max(0, math.floor(amount)))
end

local function setSprout(plot, ready)
    local sprout = plot:FindFirstChild("Sprout")
    if not sprout then
        sprout = Instance.new("Part")
        sprout.Name = "Sprout"
        sprout.Anchored = true
        sprout.CanCollide = false
        sprout.Parent = plot
    end
    sprout.Size = ready and Vector3.new(1.1,1.8,1.1) or Vector3.new(.5,.8,.5)
    sprout.Color = ready and Color3.fromRGB(255,140,48) or Color3.fromRGB(80,210,100)
    sprout.Position = plot.Position + Vector3.new(0, ready and 1.3 or .8, 0)
end

local function resetVisual(plot, prompt)
    prompt.ActionText = "Plant Carrot"
    local sprout = plot:FindFirstChild("Sprout")
    if sprout then sprout:Destroy() end
end

local function refreshVisual(plot, prompt, entry)
    local readyAt = tonumber(entry.readyAt) or 0
    if readyAt <= 0 then
        resetVisual(plot, prompt)
    elseif os.time() >= readyAt then
        prompt.ActionText = "Harvest Carrot"
        setSprout(plot, true)
    else
        prompt.ActionText = "Growing..."
        setSprout(plot, false)
    end
end

local function withActionLock(player, index, fn)
    local key = tostring(player.UserId)..":"..tostring(index)
    if actionLocks[key] then return end
    actionLocks[key] = true
    local ok, err = pcall(fn)
    actionLocks[key] = nil
    if not ok then warn("[WONDERPOCKET] Garden action failed", player.UserId, index, err) end
end

local function createPlot(player, index, position)
    local plot = Instance.new("Part")
    plot.Name = "Plot_" .. player.UserId .. "_" .. index
    plot.Size = Vector3.new(6,.8,6)
    plot.Position = position
    plot.Anchored = true
    plot.Material = Enum.Material.Ground
    plot.Color = Color3.fromRGB(96,62,40)
    plot:SetAttribute("OwnerUserId", player.UserId)
    plot.Parent = plotsFolder

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Plant Carrot"
    prompt.ObjectText = "Your Garden Plot"
    prompt.HoldDuration = .25
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = plot

    local entry = state[player].plots[index]
    refreshVisual(plot, prompt, entry)

    prompt.Triggered:Connect(function(triggeringPlayer)
        if triggeringPlayer ~= player or player:GetAttribute("WP_DataLoaded") ~= true then return end
        withActionLock(player, index, function()
            local now = os.time()
            local readyAt = tonumber(entry.readyAt) or 0

            if readyAt <= 0 then
                local seeds = math.max(0, math.floor(tonumber(player:GetAttribute("CarrotSeed")) or 0))
                if seeds <= 0 then
                    prompt.ActionText = "Need Carrot Seed"
                    task.delay(1.2, function()
                        if prompt.Parent and (tonumber(entry.readyAt) or 0) <= 0 then prompt.ActionText = "Plant Carrot" end
                    end)
                    return
                end

                player:SetAttribute("CarrotSeed", seeds - 1)
                entry.readyAt = now + GROW_SECONDS
                player:SetAttribute("WP_PlantedCount", (tonumber(player:GetAttribute("WP_PlantedCount")) or 0) + 1)
                player:SetAttribute("WP_LastEconomyAction", "PLANT_CARROT")
                refreshVisual(plot, prompt, entry)
                markDirty(player)
                if CriticalSave then CriticalSave:Fire(player) end
                task.spawn(save, player, true)
                return
            end

            if now < readyAt then
                prompt.ActionText = "Growing... " .. tostring(math.max(1, readyAt-now)) .. "s"
                return
            end

            entry.readyAt = 0
            addCoins(player, REWARD_COINS)
            player:SetAttribute("CarrotSeed", (tonumber(player:GetAttribute("CarrotSeed")) or 0) + 1)
            player:SetAttribute("WP_HarvestCount", (tonumber(player:GetAttribute("WP_HarvestCount")) or 0) + 1)
            player:SetAttribute("WP_LastEconomyAction", "HARVEST_CARROT")
            player:SetAttribute("WP_LastEconomyDeltaCoins", REWARD_COINS)
            resetVisual(plot, prompt)
            markDirty(player)
            if CriticalSave then CriticalSave:Fire(player) end
            task.spawn(save, player, true)
        end)
    end)
end

local function setup(player)
    local center = waitForPlot(player)
    if not center then
        player:SetAttribute("WP_GardenSaveHealthy", false)
        warn("[WONDERPOCKET] No player plot available for garden", player.UserId)
        return
    end

    local ok, data = retry("garden load u_"..player.UserId, function()
        return Store:GetAsync("u_"..player.UserId)
    end)
    state[player] = normalize(ok and data or nil)
    revision[player] = 0
    savedRevision[player] = 0
    player:SetAttribute("WP_GardenSaveHealthy", ok)

    local offsets = {Vector3.new(-7,0,9),Vector3.new(0,0,9),Vector3.new(7,0,9)}
    for i, offset in ipairs(offsets) do createPlot(player, i, center + offset) end
    player:SetAttribute("WP_GardenReady", true)
end

local function cleanupPlots(player)
    for _, obj in plotsFolder:GetChildren() do
        if obj:GetAttribute("OwnerUserId") == player.UserId then obj:Destroy() end
    end
end

CriticalSave.Event:Connect(function(player)
    if typeof(player)=="Instance" and player:IsA("Player") and state[player] then
        task.spawn(save, player, true)
    end
end)

Players.PlayerAdded:Connect(function(player) task.spawn(setup, player) end)
for _, player in Players:GetPlayers() do task.spawn(setup, player) end

Players.PlayerRemoving:Connect(function(player)
    local deadline = os.clock() + 8
    if saving[player] then forcePending[player] = true end
    while saving[player] and os.clock() < deadline do task.wait(.1) end
    if state[player] then save(player, true) end
    cleanupPlots(player)
    state[player] = nil
    revision[player] = nil
    savedRevision[player] = nil
    saving[player] = nil
    forcePending[player] = nil
    local prefix = tostring(player.UserId)..":"
    for key in pairs(actionLocks) do
        if string.sub(key,1,#prefix)==prefix then actionLocks[key]=nil end
    end
end)

game:BindToClose(function()
    for _, player in Players:GetPlayers() do task.spawn(save, player, true) end
    task.wait(4)
end)

print("[WONDERPOCKET] Seed-authoritative persistent offline-growth garden loaded")
