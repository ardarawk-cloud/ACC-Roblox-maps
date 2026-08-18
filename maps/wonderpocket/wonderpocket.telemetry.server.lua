local Players = game:GetService("Players")

local startedAt = os.time()
workspace:SetAttribute("WP_ServerStartedAt", startedAt)
workspace:SetAttribute("WP_RuntimeHealthy", true)
workspace:SetAttribute("WP_CurrentPlayers", 0)
workspace:SetAttribute("WP_PeakPlayers", 0)
workspace:SetAttribute("WP_TotalJoins", 0)

local joins = 0
local peak = 0

local function refresh()
    local current = #Players:GetPlayers()
    joins += 1
    peak = math.max(peak, current)
    workspace:SetAttribute("WP_CurrentPlayers", current)
    workspace:SetAttribute("WP_PeakPlayers", peak)
    workspace:SetAttribute("WP_TotalJoins", joins)
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("WP_SessionStartedAt", os.time())
    task.defer(refresh)
end)

Players.PlayerRemoving:Connect(function(player)
    local started = tonumber(player:GetAttribute("WP_SessionStartedAt")) or os.time()
    player:SetAttribute("WP_LastSessionSeconds", math.max(0, os.time()-started))
    task.defer(function()
        workspace:SetAttribute("WP_CurrentPlayers", #Players:GetPlayers())
    end)
end)

for _,player in Players:GetPlayers() do
    player:SetAttribute("WP_SessionStartedAt", os.time())
end
workspace:SetAttribute("WP_CurrentPlayers", #Players:GetPlayers())
workspace:SetAttribute("WP_PeakPlayers", #Players:GetPlayers())

print("[WONDERPOCKET] Closed-test telemetry ready")
