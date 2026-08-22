-- BBYA SOCIAL HUB — TRAVEL / ONE-TIME ACCESS v6
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local Players=game:GetService("Players")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local tp=remotes:FindFirstChild("Teleport") or Instance.new("RemoteEvent")
tp.Name="Teleport";tp.Parent=remotes
local state=remotes:FindFirstChild("State")
local internal=remotes:FindFirstChild("InternalTeleport") or Instance.new("BindableEvent")
internal.Name="InternalTeleport";internal.Parent=remotes

local passModule=script.Parent:FindFirstChild("TravelPasses")
local PASSES={VIP=0,Skatepark=0,Rooftop=0,Basement=0,Funkot=0,Mall=0,NightMarket=0}
if passModule and passModule:IsA("ModuleScript") then
 local ok,data=pcall(require,passModule)
 if ok and type(data)=="table" then PASSES=data end
end

local destinations={
 Arrival=CFrame.new(0,4,-58),
 Photo=CFrame.new(-39,3,-25),
 LookLab=CFrame.new(-38,3,-4),
 MainClub=CFrame.new(3,3,11),
 VIP=CFrame.new(46,27,2),
 Rooftop=CFrame.new(43,47,-28),
 Pool=CFrame.new(0,47,-12),
 Basement=CFrame.new(0,-12,0),
 Skatepark=CFrame.new(0,3,112),
 Funkot=CFrame.new(0,3,178),
 Mall=CFrame.new(0,4,302),
 NightMarket=CFrame.new(0,4,482),
}
local PRICES={VIP=5,Skatepark=5,Rooftop=10,Basement=20,Funkot=10,Mall=10,NightMarket=10}
local keyByPass={}
for key,id in pairs(PASSES) do
 id=tonumber(id) or 0
 if id>0 then keyByPass[id]=key end
end
local ownershipCache={}

local function isAdmin(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true or player:GetAttribute("BBYATravelBypass")==true then return true end
 return game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId
end
local function toast(player,msg)
 if state and state:IsA("RemoteEvent") then state:FireClient(player,"toast",msg) end
end
local function doTeleport(player,key)
 local cf=destinations[key]
 if not cf then return false end
 local char=player and player.Character
 local hrp=char and char:FindFirstChild("HumanoidRootPart")
 if not hrp then return false end
 hrp.CFrame=cf
 hrp.AssemblyLinearVelocity=Vector3.zero
 hrp.AssemblyAngularVelocity=Vector3.zero
 return true
end
local function owns(player,key)
 if isAdmin(player) then return true end
 local passId=tonumber(PASSES[key]) or 0
 if passId<=0 then return false end
 ownershipCache[player.UserId]=ownershipCache[player.UserId] or {}
 local cached=ownershipCache[player.UserId][key]
 if cached~=nil then return cached end
 local ok,value=pcall(MarketplaceService.UserOwnsGamePassAsync,MarketplaceService,player.UserId,passId)
 if ok then ownershipCache[player.UserId][key]=value==true;return value==true end
 return false
end

internal.Event:Connect(function(player,key)
 if doTeleport(player,key) then toast(player,tostring(key).." access ready.") end
end)

tp.OnServerEvent:Connect(function(player,key)
 key=tostring(key or "")
 if not destinations[key] then return end
 local price=PRICES[key]
 if not price then doTeleport(player,key);return end
 if owns(player,key) then doTeleport(player,key);return end
 local passId=tonumber(PASSES[key]) or 0
 if passId<=0 then
  toast(player,"One-time access sedang sinkron. Coba lagi sebentar.")
  return
 end
 player:SetAttribute("BBYAPendingTravelPass",key)
 MarketplaceService:PromptGamePassPurchase(player,passId)
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
 if not player or not purchased then return end
 local key=keyByPass[tonumber(passId) or 0]
 if not key then return end
 ownershipCache[player.UserId]=ownershipCache[player.UserId] or {}
 ownershipCache[player.UserId][key]=true
 player:SetAttribute("BBYAPendingTravelPass",nil)
 if doTeleport(player,key) then toast(player,string.format("%s unlocked permanently • %d R$",key,PRICES[key])) end
end)

Players.PlayerRemoving:Connect(function(player)ownershipCache[player.UserId]=nil end)
print("[BBYA] Travel v6 online: VIP 5R / Skatepark 5R / Rooftop 10R / Underground 20R / Funkot 10R / Mall 10R / Pasar Malam 10R")