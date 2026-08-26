-- BBYA SOCIAL HUB — MALL LIVE UPGRADE v4 / VISUAL CLEANUP v8
-- Screenshot-driven premium refinement for the live Mall.
-- Keeps passport/presence gameplay, replaces the stacked atrium stair mass with compact
-- switchback circulation, removes harsh black retail surfaces, and balances Mall-local lights.
-- Global Lighting / audio / fishing / VIP / Night Market are not changed here.

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
up:SetAttribute("Pass","MALL_LIVE_CLEAN_V4")
up:SetAttribute("VisualCleanup","SCREENSHOT_DRIVEN_V8")
up:SetAttribute("DigitalBillboardsRemoved",true)
up:SetAttribute("AtriumClutterRemoved",true)
up:SetAttribute("EscalatorMassReduced",true)
up:SetAttribute("CompactSwitchbackCirculation",true)
up:SetAttribute("RetailBlackPanelsSoftened",true)
up:SetAttribute("LocalLightingOnly",true)
up:SetAttribute("GlobalLightingUntouched",true)
up.Parent=mall

mall:SetAttribute("Pass","ACTIVE_MALL_V4")
mall:SetAttribute("Operational",true)
mall:SetAttribute("PassportZones",5)
mall:SetAttribute("MobileAtriumCleanup","V8")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes"
remotes.Parent=ReplicatedStorage
local v2=remotes:FindFirstChild("MallV2Event") or Instance.new("RemoteEvent")
v2.Name="MallV2Event"
v2.Parent=remotes
local state=remotes:FindFirstChild("State")

local C={
 white=Color3.fromRGB(240,239,235),
 stone=Color3.fromRGB(151,148,143),
 warmStone=Color3.fromRGB(112,107,101),
 dark=Color3.fromRGB(45,47,51),
 graphite=Color3.fromRGB(61,61,61),
 metal=Color3.fromRGB(77,79,82),
 gold=Color3.fromRGB(204,163,96),
 warm=Color3.fromRGB(255,226,197),
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

local function beamBetween(name,a,b,color,parent,thickness)
 local mid=(a+b)/2
 local len=(b-a).Magnitude
 local p=part(name,Vector3.new(thickness or .15,thickness or .15,len),CFrame.lookAt(mid,b),color,Enum.Material.Metal,false,parent,0)
 p.CastShadow=false
 return p
end

local function toast(player,msg)
 if state and state:IsA("RemoteEvent") then state:FireClient(player,"toast",msg) end
end

-- -----------------------------------------------------------------------------
-- 1) ATRIUM CLEANUP
-- Keep one clean focal point. No old digital slabs, kiosks or stage.
-- -----------------------------------------------------------------------------
for _,legacyName in ipairs({"DigitalSignageNetwork","AtriumKiosks","AtriumLiveStageV2"}) do
 local legacy=mall:FindFirstChild(legacyName,true)
 if legacy then legacy:Destroy() end
end

local arrival=Instance.new("Model")
arrival.Name="PremiumArrivalCleanV4"
arrival.Parent=up
part("ArrivalThreshold",Vector3.new(42,.08,1.4),CFrame.new(0,1.08,291),C.gold,Enum.Material.Metal,false,arrival,.20)
for _,x in ipairs({-18,18}) do
 local fixture=part("ArrivalLight"..x,Vector3.new(5.0,.07,.55),CFrame.new(x,10.9,292),C.white,Enum.Material.Neon,false,arrival,.72)
 fixture.CastShadow=false
 local light=Instance.new("SurfaceLight")
 light.Face=Enum.NormalId.Bottom
 light.Color=C.warm
 light.Brightness=.42
 light.Range=11
 light.Angle=110
 light.Shadows=false
 light.Parent=fixture
end

-- -----------------------------------------------------------------------------
-- 2) FLOOR PLATES + PREMIUM COMPACT CIRCULATION
-- Base Mall used six long stair runs stacked through the atrium. On phone this becomes a
-- dense industrial silhouette. Replace them with three compact switchback stairs, one per
-- floor connection, alternating atrium corners. Each staircase is bidirectional and keeps
-- the floor-to-floor route physically walkable while clearing the central sightline.
-- -----------------------------------------------------------------------------
for level=1,4 do
 local floorModel=mall:FindFirstChild("Level"..level)
 if floorModel then
  for _,name in ipairs({"WestSlab","EastSlab","SouthSlab","NorthSlab"}) do
   local slab=floorModel:FindFirstChild(name)
   if slab and slab:IsA("BasePart") then
    slab.Color=C.stone
    slab.Material=Enum.Material.Concrete
    slab.Reflectance=.01
   end
  end
 end
end

local oldEscal=mall:FindFirstChild("Escalators")
if oldEscal then oldEscal:Destroy() end
local escal=Instance.new("Model")
escal.Name="Escalators"
escal:SetAttribute("VisualRefinement","V8_COMPACT_SWITCHBACK")
escal:SetAttribute("LongStackedRunsRemoved",true)
escal.Parent=mall

local function buildSwitchback(name,baseY,edgeZ,dir,xBase)
 local stair=Instance.new("Model")
 stair.Name=name
 stair.Parent=escal
 local xA=xBase-3.55
 local xB=xBase+3.55
 local depth=1.62
 local run=1.34
 local stepH=.50
 local firstStart=edgeZ+dir*1.18
 local midZ=edgeZ+dir*10.45

 for i=0,6 do
  local z=firstStart+dir*(i*run)
  local y=baseY+.75+i
  part("FlightA_Step"..i,Vector3.new(5.9,stepH,depth),CFrame.new(xA,y,z),C.graphite,Enum.Material.Metal,true,stair,0)
 end
 part("MidLanding",Vector3.new(13.0,.48,3.2),CFrame.new(xBase,baseY+7.0,midZ),C.warmStone,Enum.Material.Slate,true,stair,0)
 for i=0,6 do
  local z=midZ-dir*(1.18+i*run)
  local y=baseY+7.75+i
  part("FlightB_Step"..i,Vector3.new(5.9,stepH,depth),CFrame.new(xB,y,z),C.graphite,Enum.Material.Metal,true,stair,0)
 end
 part("LowerLanding",Vector3.new(6.2,.42,2.8),CFrame.new(xA,baseY+.22,edgeZ+dir*.72),C.warmStone,Enum.Material.Slate,true,stair,0)
 part("UpperLanding",Vector3.new(6.2,.42,2.8),CFrame.new(xB,baseY+14.22,edgeZ+dir*.72),C.warmStone,Enum.Material.Slate,true,stair,0)

 local railColor=C.gold
 local firstA=Vector3.new(xA-3.0,baseY+2.1,firstStart)
 local firstB=Vector3.new(xA-3.0,baseY+8.0,midZ-dir*.3)
 local secondA=Vector3.new(xB+3.0,baseY+9.1,midZ-dir*.3)
 local secondB=Vector3.new(xB+3.0,baseY+15.0,edgeZ+dir*1.0)
 beamBetween("OuterRailA",firstA,firstB,railColor,stair,.14)
 beamBetween("OuterRailB",secondA,secondB,railColor,stair,.14)
 beamBetween("InnerRailA",Vector3.new(xA+3.0,firstA.Y,firstA.Z),Vector3.new(xA+3.0,firstB.Y,firstB.Z),railColor,stair,.11)
 beamBetween("InnerRailB",Vector3.new(xB-3.0,secondA.Y,secondA.Z),Vector3.new(xB-3.0,secondB.Y,secondB.Z),railColor,stair,.11)
end

buildSwitchback("L1_L2_SouthWest",1,338,1,-18)
buildSwitchback("L2_L3_NorthEast",15,392,-1,18)
buildSwitchback("L3_L4_SouthWest",29,338,1,-18)

-- Reduce only Mall-owned legacy lights. Global Lighting and other venues stay untouched.
for _,d in ipairs(mall:GetDescendants()) do
 if d:IsA("PointLight") and d.Parent and d.Parent.Name:match("^Light") then
  d.Brightness=math.min(d.Brightness,.58)
  d.Range=math.min(d.Range,14)
  d.Shadows=false
 elseif d:IsA("SpotLight") and d.Parent and d.Parent.Name:match("^AtriumLight") then
  d.Brightness=math.min(d.Brightness,.92)
  d.Range=math.min(d.Range,34)
  d.Shadows=false
 end
end

-- Premium Gallery v6 is created by the later Mall authority. Refine its screenshot-proven
-- problem surfaces after it exists instead of stacking a second storefront system.
task.spawn(function()
 local authority=mall:WaitForChild("MallPremiumGalleryV6",120)
 if not authority then return end

 for _,unit in ipairs(mall:GetChildren()) do
  if unit:IsA("Model") and unit.Name:match("^Tenant_") then
   local gallery=unit:FindFirstChild("PremiumRetailGalleryV6")
   if gallery then
    for _,d in ipairs(gallery:GetDescendants()) do
     if d:IsA("BasePart") then
      if d.Name=="FeaturePanel" then
       d.Color=Color3.fromRGB(78,74,69)
       d.Material=Enum.Material.Slate
       d.Reflectance=0
      elseif d.Name=="ExteriorBack" then
       d.Color=Color3.fromRGB(68,65,61)
       d.Material=Enum.Material.Slate
      elseif d.Name=="ShortSideReturn" then
       d.Color=Color3.fromRGB(58,57,55)
       d.Material=Enum.Material.Slate
      elseif d.Name=="RearCeiling" then
       d.Color=Color3.fromRGB(48,47,46)
       d.Material=Enum.Material.Metal
      elseif d.Name=="TenantIdentity" then
       d.Color=Color3.fromRGB(45,43,42)
      end
     elseif d:IsA("PointLight") and d.Name=="MallLocalLight" then
      d.Brightness=math.min(d.Brightness,.30)
      d.Range=math.min(d.Range,10)
      d.Shadows=false
     end
    end
   end
  end
 end

 for _,d in ipairs(authority:GetDescendants()) do
  if d:IsA("BasePart") and d.Name:match("^CeilingPanel_") then
   d.Transparency=math.max(d.Transparency,.80)
   d.CastShadow=false
  elseif d:IsA("SurfaceLight") and d.Parent and d.Parent.Name:match("^CeilingPanel_") then
   d.Brightness=math.min(d.Brightness,.70)
   d.Range=math.min(d.Range,13)
   d.Angle=110
   d.Shadows=false
  end
 end

 -- The old level markers are useful, but their near-black slabs read as placeholders
 -- from oblique mobile angles. Retain text and interaction context with a warmer backing.
 for _,d in ipairs(mall:GetChildren()) do
  if d:IsA("BasePart") and (d.Name:match("^LevelSignW") or d.Name:match("^LevelSignE")) then
   d.Color=Color3.fromRGB(62,60,57)
   d.Material=Enum.Material.Metal
   d.Reflectance=.01
  end
 end

 authority:SetAttribute("PostVisualRefinement","V8")
 authority:SetAttribute("BlackPlaceholderSurfacesSoftened",true)
 authority:SetAttribute("CorridorHotspotsReduced",true)
 mall:SetAttribute("MallPremiumVisualRefinement","V8")
end)

-- -----------------------------------------------------------------------------
-- 3) MALL PASSPORT / PRESENCE — preserved
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

print("[BBYA] Mall Live v4 / Visual Cleanup v8 online: compact switchback circulation, retail panels softened, local lighting balanced, passport preserved")
