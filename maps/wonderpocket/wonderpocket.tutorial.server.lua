local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(script.Parent:WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:FindFirstChild("WONDERPOCKET_Remotes") or Instance.new("Folder")
remotes.Name = "WONDERPOCKET_Remotes"
remotes.Parent = ReplicatedStorage

local Tutorial = remotes:FindFirstChild("Tutorial") or Instance.new("RemoteEvent")
Tutorial.Name = "Tutorial"
Tutorial.Parent = remotes

local CriticalSave = ServerStorage:WaitForChild("WONDERPOCKET_CriticalSave", 20)
local FIRST_SESSION_TARGET_SECONDS = math.max(60, math.floor(((Config.Onboarding and Config.Onboarding.FirstSessionTargetMinutes) or 10) * 60))

local STEPS = {
    {id="MeetWondi", text="Meet Bubbi, your Wondi companion — walk over and tap SAY HI", done=function(p) return p:GetAttribute("WP_Tutorial_MetWondi") == true end},
    {id="PlantCarrot", text="Grow your Pocket — go to your garden and plant the starter carrot", done=function(p) return (tonumber(p:GetAttribute("WP_PlantedCount")) or 0) >= 1 end},
    {id="BuyFurniture", text="Decorate your Pocket — open SHOP below and buy one furniture item", done=function(p) return (tonumber(p:GetAttribute("WP_PurchasedFurnitureCount")) or 0) >= 1 end},
    {id="PlaceFurniture", text="Make it yours — close Shop → BUILD → choose furniture → PLACE it inside your Pocket plot", done=function(p) return (tonumber(p:GetAttribute("WP_PlacedCount")) or 0) >= 1 end},
    {id="HarvestCarrot", text="Care for your garden — return when the carrot is ready, then HARVEST it", done=function(p) return (tonumber(p:GetAttribute("WP_HarvestCount")) or 0) >= 1 end},
    {id="Treasure", text="Discover beyond home — use Adventure Gate → Treasure Island → collect one treasure", done=function(p) return (tonumber(p:GetAttribute("WP_TreasureProgress")) or 0) >= 1 or p:GetAttribute("WP_TreasureIslandComplete") == true end},
}

local watchedAttributes = {
    "WP_Tutorial_MetWondi",
    "WP_PlantedCount",
    "WP_PurchasedFurnitureCount",
    "WP_PlacedCount",
    "WP_HarvestCount",
    "WP_TreasureProgress",
    "WP_TreasureIslandComplete",
}

local connections = {}

local function hasPersistedTutorialProgress(player)
    return player:GetAttribute("WP_Tutorial_MetWondi") == true
        or (tonumber(player:GetAttribute("WP_PlantedCount")) or 0) >= 1
        or (tonumber(player:GetAttribute("WP_PurchasedFurnitureCount")) or 0) >= 1
        or (tonumber(player:GetAttribute("WP_PlacedCount")) or 0) >= 1
        or (tonumber(player:GetAttribute("WP_HarvestCount")) or 0) >= 1
end

local function finalizeJourneyTiming(player)
    if tonumber(player:GetAttribute("WP_FirstJourneySeconds")) then return end
    local startedAt = tonumber(player:GetAttribute("WP_TutorialStartedAt")) or 0
    if startedAt <= 0 then return end
    local seconds = math.max(0, os.time() - startedAt)
    player:SetAttribute("WP_FirstJourneySeconds", seconds)
    player:SetAttribute("WP_FirstJourneyTargetSeconds", FIRST_SESSION_TARGET_SECONDS)
    player:SetAttribute("WP_FirstJourneyWithinTarget", seconds <= FIRST_SESSION_TARGET_SECONDS)
end

local function evaluate(player)
    if player:GetAttribute("WP_OnboardingComplete") == true then
        player:SetAttribute("WP_TutorialComplete", true)
        player:SetAttribute("WP_TutorialStep", 0)
        player:SetAttribute("WP_TutorialStepId", "COMPLETE")
        player:SetAttribute("WP_TutorialObjective", "Pocket ready!")
        return
    end
    if player:GetAttribute("WP_TutorialStarted") ~= true then return end

    for index, step in ipairs(STEPS) do
        if not step.done(player) then
            player:SetAttribute("WP_TutorialStep", index)
            player:SetAttribute("WP_TutorialStepId", step.id)
            player:SetAttribute("WP_TutorialObjective", step.text)
            Tutorial:FireClient(player, "STEP", index, #STEPS, step.id, step.text)
            return
        end
    end

    player:SetAttribute("WP_TutorialComplete", true)
    player:SetAttribute("WP_TutorialStep", 0)
    player:SetAttribute("WP_TutorialStepId", "COMPLETE")
    player:SetAttribute("WP_TutorialObjective", "Pocket ready!")
    finalizeJourneyTiming(player)
    player:SetAttribute("WP_OnboardingComplete", true)
    if CriticalSave then CriticalSave:Fire(player) end
    Tutorial:FireClient(player, "COMPLETE", #STEPS, #STEPS, "COMPLETE", "Your Pocket journey has begun!")
end

local function setup(player)
    -- Resolve authoritative main data first. Slow successful loads must never be
    -- mistaken for a fresh tutorial session.
    while player.Parent and player:GetAttribute("WP_DataLoaded") ~= true do
        if player:GetAttribute("WP_DataLoadFailed") == true then return end
        task.wait(.25)
    end
    if not player.Parent or player:GetAttribute("WP_DataLoaded") ~= true then return end

    -- Furniture purchases live in their own fail-closed store. Wait for that
    -- store before migrating v31-and-earlier purchase-only tutorial progress.
    while player.Parent
        and player:GetAttribute("WP_InventoryLoaded") ~= true
        and player:GetAttribute("WP_InventoryLoadFailed") ~= true do
        task.wait(.25)
    end
    if not player.Parent then return end

    player:SetAttribute("WP_TutorialComplete", player:GetAttribute("WP_OnboardingComplete") == true)
    player:SetAttribute("WP_FirstJourneyTargetSeconds", FIRST_SESSION_TARGET_SECONDS)

    -- v32+ persists WP_TutorialStarted in canonical player data. This fallback
    -- migrates older sessions that already completed any persisted milestone.
    if player:GetAttribute("WP_OnboardingComplete") ~= true
        and player:GetAttribute("WP_TutorialStarted") ~= true
        and hasPersistedTutorialProgress(player) then
        player:SetAttribute("WP_TutorialStarted", true)
        if CriticalSave then CriticalSave:Fire(player) end
    end

    -- For a resumed tutorial this timer measures only the current QA session.
    -- The clean first-session 10-minute run is intentionally tested separately from rejoin QC.
    if player:GetAttribute("WP_TutorialStarted") == true
        and player:GetAttribute("WP_OnboardingComplete") ~= true
        and tonumber(player:GetAttribute("WP_TutorialStartedAt")) == nil then
        player:SetAttribute("WP_TutorialStartedAt", os.time())
    end

    connections[player] = {}
    for _, attr in ipairs(watchedAttributes) do
        table.insert(connections[player], player:GetAttributeChangedSignal(attr):Connect(function()
            evaluate(player)
        end))
    end

    if player:GetAttribute("WP_TutorialStarted") == true then evaluate(player) end
end

Tutorial.OnServerEvent:Connect(function(player, action)
    if action ~= "START" or player:GetAttribute("WP_DataLoaded") ~= true then return end
    if player:GetAttribute("WP_OnboardingComplete") == true then return end
    if player:GetAttribute("WP_DataReadOnly") == true then return end

    local firstStart = player:GetAttribute("WP_TutorialStarted") ~= true
    player:SetAttribute("WP_TutorialStarted", true)
    player:SetAttribute("WP_FirstJourneyTargetSeconds", FIRST_SESSION_TARGET_SECONDS)
    if tonumber(player:GetAttribute("WP_TutorialStartedAt")) == nil then
        player:SetAttribute("WP_TutorialStartedAt", os.time())
    end
    if firstStart and CriticalSave then CriticalSave:Fire(player) end
    evaluate(player)
end)

Players.PlayerAdded:Connect(function(player) task.spawn(setup, player) end)
for _, player in Players:GetPlayers() do task.spawn(setup, player) end
Players.PlayerRemoving:Connect(function(player)
    for _, connection in ipairs(connections[player] or {}) do connection:Disconnect() end
    connections[player] = nil
end)

print("[WONDERPOCKET] Persistent guided tutorial + master-config first-session QA timing loaded")
