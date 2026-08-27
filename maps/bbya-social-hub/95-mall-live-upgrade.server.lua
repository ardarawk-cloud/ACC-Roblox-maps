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

local function addSurfaceText(partObj,text,color)
 local oldGui=partObj:FindFirstChildOfClass("SurfaceGui")
 if oldGui then oldGui:Destroy() end
 local gui=Instance.new("SurfaceGui")
 gui.Face=Enum.NormalId.Front
 gui.PixelsPerStud=60
 gui.LightInfluence=.05
 gui.Parent=partObj
 local label=Instance.new("TextLabel")
 label.Size=UDim2.fromScale(1,1)
 label.BackgroundTransparency=1
 label.Text=text
 label.TextColor3=color or C.white
 label.Font=Enum.Font.GothamBold
 label.TextScaled=true
 label.TextWrapped=true
 label.Parent=gui
 return label
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
escal:SetAttribute("VisualRefinement","V11_SCREENSHOT_QC")
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
 part("MidLanding",Vector3.new(14.5,.48,3.6),CFrame.new(xBase,baseY+7.0,midZ),C.warmStone,Enum.Material.Slate,true,stair,0)
 for i=0,6 do
  local z=midZ-dir*(1.18+i*run)
  local y=baseY+7.75+i
  part("FlightB_Step"..i,Vector3.new(5.9,stepH,depth),CFrame.new(xB,y,z),C.graphite,Enum.Material.Metal,true,stair,0)
 end
 part("LowerLanding",Vector3.new(8.6,.42,3.1),CFrame.new(xA,baseY+.22,edgeZ+dir*.72),C.warmStone,Enum.Material.Slate,true,stair,0)
 part("UpperLanding",Vector3.new(8.6,.42,3.1),CFrame.new(xB,baseY+14.22,edgeZ+dir*.72),C.warmStone,Enum.Material.Slate,true,stair,0)

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

-- Screenshot QC v11: rebuild each affected glass edge with a wider 12.5-stud opening.
local stairGlassOpenings={
 {level=2,z=338,x=-14.45}, -- L1 -> L2 arrival
 {level=2,z=392,x=14.45},  -- L2 -> L3 departure
 {level=3,z=392,x=21.55},  -- L2 -> L3 arrival
 {level=3,z=338,x=-21.55}, -- L3 -> L4 departure
 {level=4,z=338,x=-14.45}, -- L3 -> L4 arrival
}

local function rebuildAtriumRailZ(level,edgeZ,gapCenterX,gapWidth)
 local floorModel=mall:FindFirstChild("Level"..level)
 if not floorModel then return false end
 local rails={}
 for _,d in ipairs(floorModel:GetChildren()) do
  if d:IsA("BasePart") and d.Name:match("^AtriumRailZ"..level) and math.abs(d.Position.Z-edgeZ)<1 then
   table.insert(rails,d)
  end
 end
 if #rails==0 then return false end

 local style=rails[1]
 local leftEdge=math.huge
 local rightEdge=-math.huge
 for _,rail in ipairs(rails) do
  leftEdge=math.min(leftEdge,rail.Position.X-rail.Size.X/2)
  rightEdge=math.max(rightEdge,rail.Position.X+rail.Size.X/2)
 end
 local railY=style.Position.Y
 local railZ=style.Position.Z
 local railHeight=style.Size.Y
 local railDepth=style.Size.Z
 local railColor=style.Color
 local railMaterial=style.Material
 local railTransparency=style.Transparency
 for _,rail in ipairs(rails) do rail:Destroy() end

 local gapHalf=gapWidth/2
 local gapLeft=math.max(leftEdge,gapCenterX-gapHalf)
 local gapRight=math.min(rightEdge,gapCenterX+gapHalf)
 local leftWidth=gapLeft-leftEdge
 if leftWidth>.25 then
  local seg=part("AtriumRailZ"..level.."_V11L_"..math.floor(edgeZ),Vector3.new(leftWidth,railHeight,railDepth),CFrame.new(leftEdge+leftWidth/2,railY,railZ),railColor,railMaterial,true,floorModel,railTransparency)
  seg.CastShadow=false
 end
 local rightWidth=rightEdge-gapRight
 if rightWidth>.25 then
  local seg=part("AtriumRailZ"..level.."_V11R_"..math.floor(edgeZ),Vector3.new(rightWidth,railHeight,railDepth),CFrame.new(gapRight+rightWidth/2,railY,railZ),railColor,railMaterial,true,floorModel,railTransparency)
  seg.CastShadow=false
 end
 return true
end

local openingCount=0
for _,spec in ipairs(stairGlassOpenings) do
 if rebuildAtriumRailZ(spec.level,spec.z,spec.x,12.5) then openingCount+=1 end
end
escal:SetAttribute("GlassLandingClearance","V11_WIDE")
escal:SetAttribute("GlassOpenings",openingCount)
mall:SetAttribute("MallStairGlassClearance","V11_WIDE")
mall:SetAttribute("MallStairGlassOpenings",openingCount)

-- V9 added decorative brass caps after the glass rail. Split those caps at the same openings.
task.spawn(function()
 local v9=mall:WaitForChild("MallPremiumAtmosphereV9",180)
 if not v9 then return end
 local caps=v9:FindFirstChild("AtriumRailCapsV9",true)
 if not caps then return end
 local capOpenings=0
 for _,spec in ipairs(stairGlassOpenings) do
  local targets={}
  for _,d in ipairs(caps:GetChildren()) do
   if d:IsA("BasePart") and d.Name=="RailCapZ_L"..spec.level and math.abs(d.Position.Z-spec.z)<1 then
    table.insert(targets,d)
   end
  end
  for _,cap in ipairs(targets) do
   local leftEdge=cap.Position.X-cap.Size.X/2
   local rightEdge=cap.Position.X+cap.Size.X/2
   local gapLeft=spec.x-6.25
   local gapRight=spec.x+6.25
   local capY,capZ=cap.Position.Y,cap.Position.Z
   local h,d=cap.Size.Y,cap.Size.Z
   local color,mat,tr=cap.Color,cap.Material,cap.Transparency
   cap:Destroy()
   local lw=gapLeft-leftEdge
   if lw>.20 then part("RailCapZ_L"..spec.level.."_V11L_"..math.floor(spec.z),Vector3.new(lw,h,d),CFrame.new(leftEdge+lw/2,capY,capZ),color,mat,false,caps,tr) end
   local rw=rightEdge-gapRight
   if rw>.20 then part("RailCapZ_L"..spec.level.."_V11R_"..math.floor(spec.z),Vector3.new(rw,h,d),CFrame.new(gapRight+rw/2,capY,capZ),color,mat,false,caps,tr) end
   capOpenings+=1
  end
 end
 caps:SetAttribute("StairOpenings","V11")
 caps:SetAttribute("OpeningCount",capOpenings)
 mall:SetAttribute("MallGoldRailClearance","V11")
end)

-- Central lift v11: replace the hidden rear-corner lift with a visible north-atrium lift hub.
task.spawn(function()
 local baseLift=mall:WaitForChild("ElevatorCore",90)
 if not baseLift then return end
 baseLift:Destroy()

 local elevator=Instance.new("Model")
 elevator.Name="ElevatorCore"
 elevator:SetAttribute("Pass","CENTRAL_LIFT_V11")
 elevator:SetAttribute("FormerRearCornerRemoved",true)
 elevator:SetAttribute("VisibleFromAtrium",true)
 elevator.Parent=mall

 local levels={1,15,29,43}
 part("LiftRearGlass",Vector3.new(17,57,.55),CFrame.new(0,29,414),Color3.fromRGB(112,137,148),Enum.Material.Glass,true,elevator,.42)
 for _,x in ipairs({-8.4,8.4}) do
  part("LiftPier"..x,Vector3.new(1.15,57,11),CFrame.new(x,29,409),C.graphite,Enum.Material.Metal,true,elevator,0)
 end

 local function liftPrompt(parent,action,targetFloor,targetY)
  local q=Instance.new("ProximityPrompt")
  q.ActionText=action
  q.ObjectText="LIFT • L"..targetFloor
  q.HoldDuration=.05
  q.MaxActivationDistance=9
  q.RequiresLineOfSight=false
  q.Parent=parent
  q.Triggered:Connect(function(player)
   local char=player.Character
   if char then
    char:PivotTo(CFrame.new(0,targetY+3,399))
    toast(player,"Lift • Level "..targetFloor)
   end
  end)
 end

 for i,y in ipairs(levels) do
  part("LiftLobby"..i,Vector3.new(23,.42,14),CFrame.new(0,y+.72,398.5),C.warmStone,Enum.Material.Slate,true,elevator,0)
  part("LiftDoorL"..i,Vector3.new(6.2,8.5,.35),CFrame.new(-3.15,y+5.1,403.65),C.dark,Enum.Material.Metal,true,elevator,0)
  part("LiftDoorR"..i,Vector3.new(6.2,8.5,.35),CFrame.new(3.15,y+5.1,403.65),C.dark,Enum.Material.Metal,true,elevator,0)
  local header=part("LiftHeader"..i,Vector3.new(15,2.2,.28),CFrame.new(0,y+10.15,403.55),C.graphite,Enum.Material.Metal,false,elevator,0)
  if i==4 then addSurfaceText(header,"L4 • CINEMA\nPASSPORT FINAL",C.gold) else addSurfaceText(header,"CENTRAL LIFT • L"..i,C.white) end
  if i<4 then
   local upPad=part("LiftUpPad"..i,Vector3.new(3.2,.22,3.2),CFrame.new(-4,y+1.03,394.5),C.gold,Enum.Material.Neon,false,elevator,.22)
   upPad.CanQuery=true
   liftPrompt(upPad,"UP",i+1,levels[i+1])
  end
  if i>1 then
   local downPad=part("LiftDownPad"..i,Vector3.new(3.2,.22,3.2),CFrame.new(4,y+1.03,394.5),C.white,Enum.Material.Neon,false,elevator,.35)
   downPad.CanQuery=true
   liftPrompt(downPad,"DOWN",i-1,levels[i-1])
  end
 end
 mall:SetAttribute("MallCentralLift","V11")
end)

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

 -- Repurpose the old LEVEL slabs into real wayfinding instead of decorative black panels.
 local levelCopy={
  [1]="L1 • RETAIL\nLIFT → NORTH",
  [2]="L2 • RETAIL\nLIFT → NORTH",
  [3]="L3 • FOOD + PLAY\nLIFT → NORTH",
  [4]="L4 • CINEMA + LOUNGE\nPASSPORT FINAL",
 }
 for _,d in ipairs(mall:GetChildren()) do
  if d:IsA("BasePart") and (d.Name:match("^LevelSignW") or d.Name:match("^LevelSignE")) then
   d.Color=Color3.fromRGB(62,60,57)
   d.Material=Enum.Material.Metal
   d.Reflectance=.01
   d.Size=Vector3.new(12,3,.35)
   local level=tonumber(d.Name:match("(%d+)$"))
   local gui=d:FindFirstChildOfClass("SurfaceGui")
   local label=gui and gui:FindFirstChildOfClass("TextLabel")
   if label and levelCopy[level] then
    label.Text=levelCopy[level]
    label.TextColor3=(level==4) and C.gold or C.white
    label.Font=Enum.Font.GothamBold
   end
  end
 end

 authority:SetAttribute("PostVisualRefinement","V11")
 authority:SetAttribute("BlackPlaceholderSurfacesSoftened",true)
 authority:SetAttribute("CorridorHotspotsReduced",true)
 authority:SetAttribute("LevelPanelsRepurposed",true)
 mall:SetAttribute("MallPremiumVisualRefinement","V11")
end)

-- -----------------------------------------------------------------------------
-- 3) MALL PASSPORT / PRESENCE
-- v11 aligns FOOD/CINEMA checkpoints with the actual destination footprints.
-- -----------------------------------------------------------------------------
local passport=Instance.new("Folder")
passport.Name="MallPassportZones"
passport.Parent=up

local zoneDefs={
 {key="ARRIVAL",label="Mall Arrival",pos=Vector3.new(0,3,300),size=Vector3.new(36,8,22)},
 {key="ATRIUM",label="Central Atrium",pos=Vector3.new(0,5,365),size=Vector3.new(50,10,44)},
 {key="LEVEL2",label="Level 2 Retail",pos=Vector3.new(62,18,365),size=Vector3.new(32,8,40)},
 {key="FOOD",label="Food Hall",pos=Vector3.new(-56,33,370),size=Vector3.new(72,10,48)},
 {key="CINEMA",label="Cinema Level",pos=Vector3.new(0,47,408),size=Vector3.new(100,10,48)},
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
  player:SetAttribute("BBYAMallPassport_"..z.key,true)
  syncPassport(player,z.label)
  toast(player,"Mall Passport • "..z.label.." checked in")
  if player:GetAttribute("BBYAMallPassportComplete")==true then
   toast(player,"Mall Passport COMPLETE • BBYA Mall Explorer")
   v2:FireClient(player,"promo",{title="MALL PASSPORT COMPLETE",body="All 5 Mall zones discovered."})
  elseif count==4 then
   v2:FireClient(player,"promo",{title="FINAL CHECKPOINT",body="Go to L4 • BBYA CINEMA via Central Lift."})
  end
 end)
end

local function initPlayer(player)
 visited[player.UserId]=visited[player.UserId] or {}
 player:SetAttribute("BBYAMallPassport",0)
 player:SetAttribute("BBYAMallPassportComplete",false)
 player:SetAttribute("BBYAInsideMall",false)
 for _,z in ipairs(zoneDefs) do player:SetAttribute("BBYAMallPassport_"..z.key,false) end
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

mall:SetAttribute("MallScreenshotQC","V11")
mall:SetAttribute("MallPassportDestinationAlignment","V11")
print(string.format("[BBYA] Mall v11 screenshot QC online: %d wide stair openings, gold caps cleared, central lift active, level panels repurposed, passport zones aligned",openingCount))
