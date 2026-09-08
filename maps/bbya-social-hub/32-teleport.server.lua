-- BBYA SOCIAL HUB — TRAVEL / ONE-TIME ACCESS v12
-- Reliable server-authoritative travel with explicit client result events.
-- v12 keeps any late-rebuilt GLOW LAB on final Mall L2, resolves travel from live Look/Photo anchors,
-- and rescues a player only if the destination floor disappears and they actually fall back to L1.

local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")

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
 Photo=CFrame.new(57.7,24.1,373),
 LookLab=CFrame.new(75.5,24.4,361.5),
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

local GLOW_TARGET_FLOOR_Y=21.70
local function currentGlow()
 local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD")
 local mall=root and root:FindFirstChild("BBYAMall")
 local glow=mall and mall:FindFirstChild("Tenant_glow")
 local floor=glow and glow:FindFirstChild("Floor")
 return mall,glow,floor
end

local function alignGlow(glow)
 if not glow or not glow:IsA("Model") then return nil end
 local floor=glow:FindFirstChild("Floor")
 if not floor or not floor:IsA("BasePart") then return nil end
 local dy=GLOW_TARGET_FLOOR_Y-floor.Position.Y
 if math.abs(dy)>.05 then
  glow:PivotTo(CFrame.new(0,dy,0)*glow:GetPivot())
  floor=glow:FindFirstChild("Floor") or floor
 end
 glow:SetAttribute("FinalVerticalAuthority","TRAVEL_V12_GLOW_REPLACEMENT_GUARD")
 return floor
end

local function startGlowReplacementGuard()
 task.spawn(function()
  local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",90)
  local mall=root and root:WaitForChild("BBYAMall",90)
  if not mall then return end

  local function correct(child)
   if child and child.Name=="Tenant_glow" and child:IsA("Model") then
    task.spawn(function()
     for _,delay in ipairs({0,.2,.7,1.5,3}) do
      if delay>0 then task.wait(delay) end
      if not child.Parent then return end
      if mall:GetAttribute("FloorSpacingStuds")==20 then alignGlow(child) end
     end
    end)
   end
  end
  mall.ChildAdded:Connect(correct)
  correct(mall:FindFirstChild("Tenant_glow"))

  while mall.Parent do
   if mall:GetAttribute("FloorSpacingStuds")==20 then
    local glow=mall:FindFirstChild("Tenant_glow")
    if glow then alignGlow(glow) end
    mall:SetAttribute("GlowLabTravelAlignedV12",true)
   end
   task.wait(.5)
  end
 end)
end
startGlowReplacementGuard()

local function anchorFor(glow,key)
 if not glow then return nil end
 if key=="LookLab" then
  return glow:FindFirstChild("LookLabInteract2",true) or glow:FindFirstChild("LookLabInteract1",true) or glow:FindFirstChild("LookLabInteract3",true)
 end
 return glow:FindFirstChild("MallPhotoInteract",true)
end

local function resolveGlowDestination(key)
 if key~="LookLab" and key~="Photo" then return destinations[key] end
 local deadline=os.clock()+8
 local lastGlow=nil
 local stableSince=nil
 while os.clock()<deadline do
  local mall,glow,floor=currentGlow()
  if mall and glow and floor and floor:IsA("BasePart") then
   if mall:GetAttribute("FloorSpacingStuds")==20 then
    floor=alignGlow(glow) or floor
    if glow~=lastGlow then lastGlow=glow;stableSince=os.clock() end
    local anchor=anchorFor(glow,key)
    if anchor and anchor:IsA("BasePart") and stableSince and os.clock()-stableSince>=1.0 then
     return CFrame.new(anchor.Position+Vector3.new(0,.65,0))
    end
   end
  end
  task.wait(.15)
 end
 return destinations[key]
end

local function rescueGlowArrival(player,key)
 if key~="LookLab" and key~="Photo" then return end
 task.spawn(function()
  local stop=os.clock()+5
  while os.clock()<stop do
   task.wait(.25)
   local char=player and player.Character
   local hrp=char and char:FindFirstChild("HumanoidRootPart")
   local hum=char and char:FindFirstChildOfClass("Humanoid")
   if not hrp or not hum or hum.Health<=0 then return end
   local _,glow=currentGlow()
   if glow then alignGlow(glow) end
   if hrp.Position.Y<20.3 then
    local cf=resolveGlowDestination(key)
    hum.Sit=false
    pcall(function()hum:ChangeState(Enum.HumanoidStateType.GettingUp)end)
    hrp.CFrame=cf
    hrp.AssemblyLinearVelocity=Vector3.zero
    hrp.AssemblyAngularVelocity=Vector3.zero
   end
  end
 end)
end

local function doTeleport(player,key)
 local cf=resolveGlowDestination(key)
 if not cf then return false,"Unknown destination" end
 local char=player and player.Character
 local hrp=char and char:FindFirstChild("HumanoidRootPart")
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not hrp or not hum or hum.Health<=0 then return false,"Character belum siap" end
 hum.Sit=false
 pcall(function()hum:ChangeState(Enum.HumanoidStateType.GettingUp)end)
 hrp.CFrame=cf
 hrp.AssemblyLinearVelocity=Vector3.zero
 hrp.AssemblyAngularVelocity=Vector3.zero
 rescueGlowArrival(player,key)
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
print("[BBYA] Travel v12 online: GLOW LAB replacement guard + live Look/Photo anchors + fall rescue")
