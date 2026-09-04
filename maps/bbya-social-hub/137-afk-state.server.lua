-- BBYA SOCIAL HUB — AFK FRIENDLY FOUNDATION v1
-- Server-authoritative Player-level AFK state. This does not bypass Roblox idle enforcement.
-- No kick, teleport, respawn, movement forcing, rewards, persistence, economy, audio, or UI mutation.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AFK_TIMEOUT_SECONDS = 5 * 60
local CHECK_INTERVAL_SECONDS = 2
local MIN_REMOTE_INTERVAL_SECONDS = 1

local remotes = ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
if remotes and not remotes:IsA("Folder") then
    warn("[BBYA AFK] BBYAClubRemotes exists with unexpected class; AFK authority disabled")
    return
end
if not remotes then
    remotes = Instance.new("Folder")
    remotes.Name = "BBYAClubRemotes"
    remotes.Parent = ReplicatedStorage
end

local activityRemote = remotes:FindFirstChild("AFKActivity")
if activityRemote and not activityRemote:IsA("RemoteEvent") then
    warn("[BBYA AFK] AFKActivity exists with unexpected class; AFK authority disabled")
    return
end
if not activityRemote then
    activityRemote = Instance.new("RemoteEvent")
    activityRemote.Name = "AFKActivity"
    activityRemote.Parent = remotes
end

local lastActivityAt = {}
local lastRemoteAt = {}

local function setAFK(player, isAFK)
    if not player or player.Parent ~= Players then return end
    if isAFK then
        if player:GetAttribute("BBYAAFK") ~= true then
            player:SetAttribute("BBYAAFK", true)
            player:SetAttribute("BBYAAFKSince", os.time())
        end
    else
        if player:GetAttribute("BBYAAFK") ~= false then
            player:SetAttribute("BBYAAFK", false)
        end
        if player:GetAttribute("BBYAAFKSince") ~= 0 then
            player:SetAttribute("BBYAAFKSince", 0)
        end
    end
end

local function registerActivity(player, now)
    if not player or lastActivityAt[player] == nil then return end
    lastActivityAt[player] = now or os.clock()
    if player:GetAttribute("BBYAAFK") == true then
        setAFK(player, false)
    end
end

local function hasMovementIntent(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0.05
end

local function setupPlayer(player)
    lastActivityAt[player] = os.clock()
    lastRemoteAt[player] = 0
    -- Session-only state: every join starts ACTIVE and never loads AFK from persistence.
    player:SetAttribute("BBYAAFK", false)
    player:SetAttribute("BBYAAFKSince", 0)
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end
Players.PlayerAdded:Connect(setupPlayer)

activityRemote.OnServerEvent:Connect(function(player)
    if lastActivityAt[player] == nil then return end
    local now = os.clock()
    local previous = lastRemoteAt[player] or 0
    if now - previous < MIN_REMOTE_INTERVAL_SECONDS then return end
    lastRemoteAt[player] = now
    -- Client can only report activity for itself; server owns the final AFK attributes.
    registerActivity(player, now)
end)

Players.PlayerRemoving:Connect(function(player)
    lastActivityAt[player] = nil
    lastRemoteAt[player] = nil
end)

task.spawn(function()
    while task.wait(CHECK_INTERVAL_SECONDS) do
        local now = os.clock()
        for _, player in ipairs(Players:GetPlayers()) do
            if lastActivityAt[player] == nil then
                setupPlayer(player)
            elseif hasMovementIntent(player) then
                -- Server-observed movement intent is a valid activity signal and is respawn-safe.
                registerActivity(player, now)
            elseif now - lastActivityAt[player] >= AFK_TIMEOUT_SECONDS then
                setAFK(player, true)
            end
        end
    end
end)

print(string.format("[BBYA] AFK Friendly Foundation v1 online: timeout=%ds / session-only Player attributes", AFK_TIMEOUT_SECONDS))
