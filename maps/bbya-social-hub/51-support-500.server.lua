-- BBYA SOCIAL HUB — SUPPORT 500 TIER PATCH
-- Temporary compatibility layer until all Developer Product IDs are centralized.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local supportRemote=remotes:WaitForChild("Support")
local stateRemote=remotes:WaitForChild("State")

local PRODUCTS={
 {label="10",productId=0},
 {label="25",productId=0},
 {label="50",productId=0},
 {label="100",productId=0},
 {label="250",productId=0},
 {label="500",productId=0},
}

local function sendProducts(player)
 if not player or not player.Parent then return end
 stateRemote:FireClient(player,"supportProducts",PRODUCTS)
end

supportRemote.OnServerEvent:Connect(function(player,action,arg)
 if action=="list" then
  task.delay(.08,function()sendProducts(player)end)
 elseif action=="prompt" and tonumber(arg)==6 then
  stateRemote:FireClient(player,"toast","Support 500 R$ siap. Developer Product ID belum dipasang.")
 end
end)

Players.PlayerAdded:Connect(function(player)
 task.delay(2.15,function()sendProducts(player)end)
end)

print("[BBYA] Support 500 tier visible; waiting for Developer Product ID")