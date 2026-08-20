-- BBYA SOCIAL HUB — TRAVEL / PAID TELEPORT v2
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local tp=remotes:FindFirstChild("Teleport") or Instance.new("RemoteEvent")
tp.Name="Teleport";tp.Parent=remotes
local state=remotes:FindFirstChild("State")
local internal=remotes:FindFirstChild("InternalTeleport") or Instance.new("BindableEvent")
internal.Name="InternalTeleport";internal.Parent=remotes

local productModule=script.Parent:FindFirstChild("MonetizationProducts")
local PRODUCTS={TRAVEL={}}
if productModule and productModule:IsA("ModuleScript") then
 local ok,data=pcall(require,productModule)
 if ok and type(data)=="table" then PRODUCTS=data end
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
 Skatepark=CFrame.new(0,3,-132),
}
local PAID={VIP=5,Skatepark=5,Rooftop=10,Basement=20}

local function isAdmin(player)
 if not player then return false end
 if player:GetAttribute("BBYAAdmin")==true then return true end
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

internal.Event:Connect(function(player,key)
 if doTeleport(player,key) then
  local price=PAID[key]
  if price then toast(player,string.format("%s access granted • %d R$",key,price)) end
 end
end)

tp.OnServerEvent:Connect(function(player,key)
 key=tostring(key or "")
 if not destinations[key] then return end
 local price=PAID[key]
 if not price or isAdmin(player) then
  doTeleport(player,key)
  return
 end
 local productId=PRODUCTS.TRAVEL and tonumber(PRODUCTS.TRAVEL[key]) or 0
 if productId<=0 then
  toast(player,"Travel purchase sedang sinkron. Coba lagi sebentar.")
  return
 end
 player:SetAttribute("BBYATravelPurchase",key)
 MarketplaceService:PromptProductPurchase(player,productId)
end)

print("[BBYA] Travel v2 online: VIP 5R / Skatepark 5R / Rooftop 10R / Basement 20R")