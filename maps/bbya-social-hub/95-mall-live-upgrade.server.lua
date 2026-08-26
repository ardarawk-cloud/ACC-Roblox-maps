-- BBYA SOCIAL HUB — MALL LIVE UPGRADE v3 / VISUAL CLEANUP v7
-- Screenshot-driven cleanup for the live Mall.
-- Keeps passport/presence gameplay, removes oversized atrium clutter, and calms
-- primitive escalator/lighting treatment without touching global Lighting or other venues.

local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local mall=root:WaitForChild("BBYAMall",60)
if not mall then return end

local old=mall:FindFirstChild("MallLiveUpgradeV2")
if old then old:Destroy() end

local up=Instance.new("Model")
up.Name="MallLiveUpgradeV2"
up:SetAttribute("Pass","MALL_LIVE_CLEAN_V3")
up:SetAttribute("VisualCleanup","SCREENSHOT_DRIVEN_V7")
up:SetAttribute("DigitalBillboardsRemoved",true)
up:SetAttribute("AtriumClutterRemoved",true)
up:SetAttribute("EscalatorMassReduced",true)
up:SetAttribute("LocalLightingOnly",true)
up:SetAttribute("GlobalLightingUntouched",true)
up.Parent=mall

mall:SetAttribute("Pass","ACTIVE_MALL_V3")
mall:SetAttribute("Operational",true)
mall:SetAttribute("PassportZones",5)
mall:SetAttribute("MobileAtriumCleanup","V7")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes"
remotes.Parent=ReplicatedStorage
local v2=remotes:FindFirstChild("MallV2Event") or Instance.new("RemoteEvent")
v2.Name="MallV2Event"
v2.Parent=remotes
local state=remotes:FindFirstChild("State")

local C={
 white=Color3.fromRGB(240,239,235),
 stone=Color3.fromRGB(164,162,157),
 dark=Color3.fromRGB(45,47,51),
 metal=Color3.fromRGB(65,68,73),
 gold=Color3.fromRGB(214,170,91),
 cyan=Color3.fromRGB(38,192,214),
}

local function part(name,size,cf,color,mat,collide,parent,tr)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or C.dark
 p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true
 p.CanCollide=collide==true
 p.CanTouch=false
 p.CanQuery=false
 p.Transparency=tr or 0
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or up
 return p
end

local function toast(player,msg)
 if state and state:IsA("RemoteEvent") then state:FireClient(player,"toast",msg) end
end

-- -----------------------------------------------------------------------------
-- 1) ATRIUM CLEANUP
-- The previous Live v2 added five large digital slabs, four kiosks and a stage.
-- Premium Gallery v6 later removed some of them, but the digital network remained.
-- v3 intentionally creates none of those objects.
-- -----------------------------------------------------------------------------
for _,legacyName in ipairs({"DigitalSignageNetwork","AtriumKiosks","AtriumLiveStageV2"}) do
 local legacy=mall:FindFirstChild(legacyName,true)
 if legacy then legacy:Destroy() end
end

-- Small low-profile arrival marker only; no giant black SurfaceGui billboard.
local arrival=Instance.new("Model")
arrival.Name="PremiumArrivalCleanV3"
arrival.Parent=up
part("ArrivalThreshold",Vector3.new(42,.08,1.4),CFrame.new(0,1.08,291),C.gold,Enum.Material.Metal,false,arrival,.16)
for _,x in ipairs({-18,18}) do
 local fixture=part("ArrivalLight"..x,Vector3.new(5.5,.08,.6),CFrame.new(x,10.9,292),C.white,Enum.Material.Neon,false,arrival,.58)
 fixture.CastShadow=false
 local light=Instance.new("SurfaceLight")
 light.Face=Enum.NormalId.Bottom
 light.Color=Color3.fromRGB(255,228,196)
 light.Brightness=.55
 light.Range=13
 light.Angle=120
 light.Shadows=false
 light.Parent=fixture
end

-- -----------------------------------------------------------------------------
-- 2) CALM THE BASE FLOOR PLATES AND ESCALATORS
-- Screenshot evidence showed blown-out slab undersides and thick floating stair blocks.
-- Keep all circulation positions/walkability, but reduce visual mass.
-- -----------------------------------------------------------------------------
for level=1,4 do
 local floorModel=mall:FindFirstChild("Level"..level)
 if floorModel then
  for _,name in ipairs({"WestSlab","EastSlab","SouthSlab","NorthSlab"}) do
   local slab=floorModel:FindFirstChild(name)
   if slab and slab:IsA("BasePart") then
    slab.Color=C.stone
    slab.Material=Enum.Material.Concrete
    slab.Reflectance=.015
   end
  end
 end
end

local escal=mall:FindFirstChild("Escalators")
if escal then
 for _,d in ipairs(escal:GetDescendants()) do
  if d:IsA("BasePart") then
   if d.Name:match("Step%d+$") then
    local oldTop=d.Position.Y+d.Size.Y*.5
    d.Size=Vector3.new(6.4,.56,2.45)
    d.CFrame=CFrame.new(d.Position.X,oldTop-d.Size.Y*.5,d.Position.Z)
    d.Color=Color3.fromRGB(55,57,61)
    d.Material=Enum.Material.Metal
    d.Reflectance=.025
   elseif d.Name:match("Guide%d+$") then
    d.Size=Vector3.new(.07,.055,1.9)
    d.Color=C.cyan
    d.Transparency=.52
    d.CastShadow=false
   end
  end
 end
 escal:SetAttribute("VisualRefinement","V7_THIN_STEPS")
end

-- Reduce only Mall-owned legacy lights. Global Lighting and other venues stay untouched.
for _,d in ipairs(mall:GetDescendants()) do
 if d:IsA("PointLight") and d.Parent and d.Parent.Name:match("^Light") then
  d.Brightness=math.min(d.Brightness,.72)
  d.Range=math.min(d.Range,16)
  d.Shadows=false
 elseif d:IsA("SpotLight") and d.Parent and d.Parent.Name:match("^AtriumLight") then
  d.Brightness=math.min(d.Brightness,1.35)
  d.Range=math.min(d.Range,40)
  d.Shadows=false
 end
end

-- -----------------------------------------------------------------------------
-- 3) MALL PASSPORT / PRESENCE — preserved from Live v2
-- -----------------------------------------------------------------------------
local passport=Instance.new("Folder")
passport.Name="MallPassportZones"
passport.Parent=up

local zoneDefs={
 {key="ARRIVAL",label="Mall Arrival",pos=Vector3.new(0,3,300),size=Vector3.new(36,8,22)},
 {key="ATRIUM",label="Central Atrium",pos=Vector3.new(0,5,365),size=Vector3.new(50,10,44)},
 {key="LEVEL2",label="Level 2 Retail",pos=Vector3.new(62,18,365),size=Vector3.new(32,8,40)},
 {key="FOOD",label="Food Hall",pos=Vector3.new(0,33,414),size=Vector3.new(54,8,28)},
 {key="CINEMA",label="Cinema Level",pos=Vector3.new(0,47,414),size=Vector3.new(54,8,28)},
}
local visited={}
local touchCooldown={}

local function syncPassport(player,lastLabel)
 local set=visited[player.UserId] or {}
 local count=0
 for _ in pairs(set) do count+=1 end
 player:SetAttribute("BBYAMallPassport",count)
 local complete=count>=#zoneDefs
 player:SetAttribute("BBYAMallPassportComplete",complete)
 v2:FireClient(player,"passport",{count=count,total=#zoneDefs,last=lastLabel,complete=complete})
end

for _,z in ipairs(zoneDefs) do
 local sensor=part("Passport_"..z.key,z.size,CFrame.new(z.pos),C.white,Enum.Material.SmoothPlastic,false,passport,1)
 sensor.CanTouch=true
 sensor.Touched:Connect(function(hit)
  local char=hit and hit.Parent
  local player=char and Players:GetPlayerFromCharacter(char)
  if not player then return end
  local token=tostring(player.UserId)..":"..z.key
  if touchCooldown[token] then return end
  touchCooldown[token]=true
  task.delay(1.5,function()touchCooldown[token]=nil end)
  visited[player.UserId]=visited[player.UserId] or {}
  if visited[player.UserId][z.key] then return end
  visited[player.UserId][z.key]=true
  syncPassport(player,z.label)
  toast(player,"Mall Passport • "..z.label.." checked in")
  if player:GetAttribute("BBYAMallPassportComplete")==true then
   toast(player,"Mall Passport COMPLETE • BBYA Mall Explorer")
   v2:FireClient(player,"promo",{title="MALL PASSPORT COMPLETE",body="All 5 Mall zones discovered."})
  end
 end)
end

local function initPlayer(player)
 visited[player.UserId]=visited[player.UserId] or {}
 player:SetAttribute("BBYAMallPassport",0)
 player:SetAttribute("BBYAMallPassportComplete",false)
 player:SetAttribute("BBYAInsideMall",false)
end
Players.PlayerAdded:Connect(initPlayer)
for _,player in ipairs(Players:GetPlayers()) do initPlayer(player) end
Players.PlayerRemoving:Connect(function(player)visited[player.UserId]=nil end)

local presence=part("MallPresenceVolume",Vector3.new(196,66,166),CFrame.new(0,31,365),C.white,Enum.Material.SmoothPlastic,false,up,1)
presence.CanTouch=true
local inside={}
presence.Touched:Connect(function(hit)
 local player=hit and hit.Parent and Players:GetPlayerFromCharacter(hit.Parent)
 if not player or inside[player] then return end
 inside[player]=true
 player:SetAttribute("BBYAInsideMall",true)
 syncPassport(player,nil)
 v2:FireClient(player,"presence",{inside=true})
end)

task.spawn(function()
 while up.Parent do
  for _,player in ipairs(Players:GetPlayers()) do
   local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
   if hrp then
    local p=hrp.Position
    local inMall=math.abs(p.X)<=100 and p.Z>=282 and p.Z<=448 and p.Y>=-2 and p.Y<=66
    if inMall~=inside[player] then
     inside[player]=inMall
     player:SetAttribute("BBYAInsideMall",inMall)
     v2:FireClient(player,"presence",{inside=inMall})
    end
   end
  end
  task.wait(.8)
 end
end)

print("[BBYA] Mall Live v3 / Visual Cleanup v7 online: clean atrium, thin escalators, calm local lighting, passport preserved")
