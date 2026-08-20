local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local STORE = DataStoreService:GetDataStore("ACC_MountainSummits_v1")
local ROOT = workspace:WaitForChild("ACC_MountainSocial", 15)

local function ensureStats(player)
    local leaderstats = player:FindFirstChild("leaderstats") or Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local summits = leaderstats:FindFirstChild("Summits") or Instance.new("IntValue")
    summits.Name = "Summits"
    summits.Parent = leaderstats

    local discoveries = leaderstats:FindFirstChild("Discoveries") or Instance.new("IntValue")
    discoveries.Name = "Discoveries"
    discoveries.Parent = leaderstats
    return summits
end

local function titleFor(count)
    if count >= 100 then return "Legend of the Peak" end
    if count >= 50 then return "Cloud Walker" end
    if count >= 20 then return "Ridge Master" end
    if count >= 10 then return "Summit Seeker" end
    if count >= 3 then return "Trail Regular" end
    if count >= 1 then return "First Summit" end
    return "New Hiker"
end

Players.PlayerAdded:Connect(function(player)
    local summits = ensureStats(player)
    local ok, data = pcall(function()
        return STORE:GetAsync("u_" .. player.UserId)
    end)
    if ok and type(data) == "table" then summits.Value = tonumber(data.summits) or 0 end
    player:SetAttribute("MountainTitle", titleFor(summits.Value))
    summits.Changed:Connect(function(v)
        player:SetAttribute("MountainTitle", titleFor(v))
    end)
end)

if not ROOT then return end
local summit = ROOT:FindFirstChild("ACC_SummitMonument", true)
if summit and summit:IsA("BasePart") then
    local debounce = {}
    summit.Touched:Connect(function(hit)
        local player = hit.Parent and Players:GetPlayerFromCharacter(hit.Parent)
        if not player or debounce[player] then return end
        local cp = player:GetAttribute("MountainCheckpoint") or 0
        if cp < 12 then return end
        debounce[player] = true
        local summits = ensureStats(player)
        summits.Value += 1
        player:SetAttribute("LastSummitAt", os.time())
        task.spawn(function()
            pcall(function()
                STORE:SetAsync("u_" .. player.UserId, { summits = summits.Value })
            end)
        end)
        task.delay(8, function() debounce[player] = nil end)
    end)
end
