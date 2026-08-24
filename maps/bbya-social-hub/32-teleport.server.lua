-- BBYA SOCIAL HUB — TRAVEL / ONE-TIME ACCESS v9
-- Reliable server-authoritative travel with explicit client result events.
-- Photo Studio + Look Lab now point to their current Mall Level 2 locations.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local Players=game:GetService("Players")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local tp=remotes:FindFirstChild("Teleport") or Instance.new("RemoteEvent")
tp.Name="Teleport";tp.Parent=remotes
local result=remotes:FindFirstChild("TravelResult") or Instance.new("RemoteEvent")
result.Name="TravelResult";result.Parent=remotes
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
 Photo=CFrame.new(78,18,369), -- GLOW LAB photo side, Mall L2
 LookLab=CFrame.new(61,18,361), -- GLOW LAB styling side, Mall L2
 MainClub=CFrame.new(3,3,11),
 Toilet=CFrame.new(43,3,-13),
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
for key,id in pairs(PASSES) do id=tonumber(id) or 0;if id>0 then keyByPass[id]=key end end
local ownershipCache={}
local debounce={}

local function isAdmin(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true or player:GetAttribute("BBYATravelBypass")==true then return true end
 return game.CreatorType==Enum.CreatorType.User and player.UserId==game.CreatorId
end
local function hasRoleBypass(player,key)
 if isAdmin(player) then return true end
 if key=="VIP" and player:GetAttribute("BBYAVIPBypass")==true then return true end
 if key=="Rooftop" and player:GetAttribute("BBYARooftopBypass")==true then return true end
 if key=="Basement" and player:GetAttribute("BBYASecretRoomBypass")==true then return true end
 return false
end
local function toast(player,msg)if state and state:IsA("RemoteEvent") then state:FireClient(player,"toast",msg) end end
local function send(player,ok,key,msg)
 if player and result then result:FireClient(player,ok==true,tostring(key or ""),tostring(msg or "")) end
end
local function doTeleport(player,key)
 local cf=destinations[key]
 if not cf then return false,"Unknown destination" end
 local char=player and player.Character
 local hrp=char and char:FindFirstChild("HumanoidRootPart")
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not hrp or not hum or hum.Health<=0 then return false,"Character belum siap" end
 hum.Sit=false
 hrp.CFrame=cf
 hrp.AssemblyLinearVelocity=Vector3.zero
 hrp.AssemblyAngularVelocity=Vector3.zero
 return true,key.." ready"
end
local function owns(player,key)
 if hasRoleBypass(player,key) then return true end
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
 local ok,msg=doTeleport(player,key)
 if ok then toast(player,tostring(key).." access ready.") end
 send(player,ok,key,msg)
end)

tp.OnServerEvent:Connect(function(player,key)
 key=tostring(key or "")
 if not destinations[key] then send(player,false,key,"Destination tidak tersedia");return end
 local now=os.clock();local last=debounce[player.UserId] or 0
 if now-last<.35 then return end;debounce[player.UserId]=now

 local price=PRICES[key]
 if not price then
  local ok,msg=doTeleport(player,key);send(player,ok,key,msg);return
 end
 if owns(player,key) then
  local ok,msg=doTeleport(player,key);send(player,ok,key,msg);return
 end
 local passId=tonumber(PASSES[key]) or 0
 if passId<=0 then
  toast(player,"One-time access sedang sinkron. Coba lagi sebentar.")
  send(player,false,key,"Access pass belum sinkron")
  return
 end
 player:SetAttribute("BBYAPendingTravelPass",key)
 local ok=pcall(function()MarketplaceService:PromptGamePassPurchase(player,passId)end)
 if not ok then
  player:SetAttribute("BBYAPendingTravelPass",nil)
  send(player,false,key,"Roblox purchase prompt gagal dibuka")
 end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
 if not player then return end
 local key=keyByPass[tonumber(passId) or 0] or player:GetAttribute("BBYAPendingTravelPass")
 if not key then return end
 player:SetAttribute("BBYAPendingTravelPass",nil)
 if not purchased then send(player,false,key,"Purchase dibatalkan");return end
 ownershipCache[player.UserId]=ownershipCache[player.UserId] or {}
 ownershipCache[player.UserId][key]=true
 local ok,msg=doTeleport(player,key)
 if ok then toast(player,string.format("%s unlocked permanently • %d R$",key,PRICES[key] or 0)) end
 send(player,ok,key,msg)
end)

Players.PlayerRemoving:Connect(function(player)
 ownershipCache[player.UserId]=nil;debounce[player.UserId]=nil
end)
print("[BBYA] Travel v9 online: reliable touch result + Mall L2 Photo/Look destinations + server acknowledgement")
