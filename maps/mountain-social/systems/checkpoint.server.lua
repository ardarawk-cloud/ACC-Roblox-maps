local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local ROOT_NAME = "ACC_MountainSocial"
local DATASTORE = DataStoreService:GetDataStore("ACC_MountainSocial_v1")

local function root()
    return workspace:FindFirstChild(ROOT_NAME)
end

local function checkpointsFolder()
    local r = root()
    return r and r:FindFirstChild("Checkpoints")
end

local function checkpointNumber(part)
    local n = tonumber(part:GetAttribute("CheckpointNumber"))
    if n then return n end
    return tonumber(string.match(part.Name, "%d+"))
end

local function save(player, checkpoint)
    player:SetAttribute("MountainCheckpoint", checkpoint)
    task.spawn(function()
        pcall(function()
            DATASTORE:SetAsync("u_" .. player.UserId, { checkpoint = checkpoint })
        end)
    end)
end

local function teleportToCheckpoint(player)
    local cp = player:GetAttribute("MountainCheckpoint") or 0
    if cp <= 0 then return end
    local folder = checkpointsFolder()
    if not folder then return end
    for _, part in ipairs(folder:GetChildren()) do
        if checkpointNumber(part) == cp then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0) end
            return
        end
    end
end

local function wireCheckpoint(part)
    if not part:IsA("BasePart") or part:GetAttribute("ACC_Wired") then return end
    part:SetAttribute("ACC_Wired", true)
    part.Touched:Connect(function(hit)
        local char = hit.Parent
        local player = char and Players:GetPlayerFromCharacter(char)
        if not player then return end
        local n = checkpointNumber(part)
        if not n then return end
        local current = player:GetAttribute("MountainCheckpoint") or 0
        if n > current then save(player, n) end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("MountainCheckpoint", 0)
    local ok, data = pcall(function()
        return DATASTORE:GetAsync("u_" .. player.UserId)
    end)
    if ok and type(data) == "table" and tonumber(data.checkpoint) then
        player:SetAttribute("MountainCheckpoint", tonumber(data.checkpoint))
    end
    player.CharacterAdded:Connect(function()
        task.wait(1)
        teleportToCheckpoint(player)
    end)
end)

local folder = checkpointsFolder()
if folder then
    for _, p in ipairs(folder:GetChildren()) do wireCheckpoint(p) end
    folder.ChildAdded:Connect(wireCheckpoint)
end
