-- BBYA SOCIAL HUB — BASEMENT FULL UPGRADE v6
-- Root-cause Underground lighting cleanup.
-- One local lighting authority, four dedicated balanced low-output room fills, and no runtime watchdog.
-- Decorative neon remains visible but does not own SurfaceLight/PointLight emitters.
-- Audio routing / Basement Indo AutoDJ / global Lighting / every other BBYA area are untouched.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

local function finalCandidate()
 local candidate=root:FindFirstChild("Underground")
 if candidate and candidate:GetAttribute("Pass")=="BASEMENT_PREMIUM_V2"
  and candidate:FindFirstChild("CheckerFloor")
  and candidate:FindFirstChild("WhitePentagonCeilingLights")
  and candidate:FindFirstChild("PremiumLounge") then
  return candidate
 end
end

-- BasementPremiumUpgrade destroys/rebuilds Underground at startup. Wait for the
-- final builder instance once, then configure it once. No recurring re-assert loop.
local basement=nil
local deadline=os.clock()+45
repeat
 local candidate=finalCandidate()
 if candidate then
  task.wait(1.0)
  if candidate.Parent==root and root:FindFirstChild("Underground")==candidate and finalCandidate()==candidate then
   basement=candidate
   break
  end
 end
 task.wait(.15)
until os.clock()>=deadline
if not basement then
 warn("[BBYA] Basement Full Upgrade v6 skipped: stable premium Underground not ready")
 return
end

local checker=basement:FindFirstChild("CheckerFloor")
local pentagons=basement:FindFirstChild("WhitePentagonCeilingLights")
local oldLounge=basement:FindFirstChild("PremiumLounge")

local old=basement:FindFirstChild("BasementFullUpgradeV1")
if old then old:Destroy() end

local out=Instance.new("Model")
out.Name="BasementFullUpgradeV1"
out.Parent=basement
out:SetAttribute("DarkClubLighting",true)
out:SetAttribute("PremiumLoungeV4",true)
out:SetAttribute("UndergroundIdentity",true)
out:SetAttribute("AudioSystemUntouched",true)
out:SetAttribute("GlobalLightingUntouched",true)
out:SetAttribute("StartupRaceHardened",true)
out:SetAttribute("ContinuousDarkLock",false)
out:SetAttribute("LightingAuthority","V6_SINGLE_LOCAL_AUTHORITY")
out:SetAttribute("DecorativeNeonEmitters",false)
out:SetAttribute("BalancedAfterHeadroom",true)
out:SetAttribute("FillBrightness",.30)
out:SetAttribute("FillRange",40)

local C={
 dark=Color3.fromRGB(12,14,18),
 leather=Color3.fromRGB(26,28,33),
 leather2=Color3.fromRGB(36,39,45),
 fabric=Color3.fromRGB(46,49,56),
 metal=Color3.fromRGB(72,76,84),
 glass=Color3.fromRGB(71,82,93),
 white=Color3.fromRGB(208,210,207),
 blue=Color3.fromRGB(0,144,255),
 yellow=Color3.fromRGB(255,205,38),
 wash=Color3.fromRGB(150,160,174),
}

local function part(name,size,cf,color,mat,collide,parent,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.dark;p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false
 p.Transparency=transparency or 0;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out
 return p
end

local function hiddenAnchor(name,pos,parent)
 local p=part(name,Vector3.new(.35,.35,.35),CFrame.new(pos),C.white,Enum.Material.SmoothPlastic,false,parent,1)
 p.CastShadow=false
 return p
end

-- -----------------------------------------------------------------------------
-- 1) SINGLE UNDERGROUND LOCAL LIGHTING AUTHORITY
-- -----------------------------------------------------------------------------
-- Historical Underground builders attached a SurfaceLight to every decorative neon
-- strip, pentagon edge, deck pad and bar accent. Those emitters overlapped and clipped
-- mobile exposure. Remove that source once; do not create another system to fight it.
local removedLocalLights=0
for _,obj in ipairs(basement:GetDescendants()) do
 if obj:IsA("SurfaceLight") or obj:IsA("PointLight") or obj:IsA("SpotLight") then
  obj:Destroy()
  removedLocalLights+=1
 end
end

-- Decorative fixtures stay visible as emissive geometry only.
if pentagons then
 for _,obj in ipairs(pentagons:GetDescendants()) do
  if obj:IsA("BasePart") and obj.Material==Enum.Material.Neon then
   obj.Color=Color3.fromRGB(165,167,169)
   obj.Transparency=.08
   obj:SetAttribute("BBYAEmissiveOnly",true)
  end
 end
end
for _,obj in ipairs(basement:GetChildren()) do
 if obj:IsA("BasePart") and (
  obj.Name:match("^CeilingBlue") or obj.Name:match("^CeilingYellow")
  or obj.Name:match("^WallBlue") or obj.Name:match("^WallYellow")
 ) then
  obj.Transparency=.03
  obj:SetAttribute("BBYAEmissiveOnly",true)
 end
end

-- Four dedicated fills stay the only room-light source. After the 28-stud headroom pass
-- their output is raised one controlled step so avatars, floor, DJ booth and bar remain
-- readable without reactivating the old dozens-of-neon floodlights that caused whiteout.
local lighting=Instance.new("Model")
lighting.Name="UndergroundRoomLightingV6"
lighting:SetAttribute("Authority","V6_SINGLE_LOCAL_AUTHORITY")
lighting:SetAttribute("DedicatedLightCount",4)
lighting.Parent=out
for i,pos in ipairs({
 Vector3.new(-30,-1.55,-20),
 Vector3.new(30,-1.55,-20),
 Vector3.new(-30,-1.55,20),
 Vector3.new(30,-1.55,20),
}) do
 local a=hiddenAnchor("RoomFillAnchor"..i,pos,lighting)
 local s=Instance.new("SurfaceLight")
 s.Name="UndergroundRoomFill"
 s.Face=Enum.NormalId.Bottom
 s.Color=C.wash
 s.Brightness=.30
 s.Range=40
 s.Angle=135
 s.Shadows=false
 s.Parent=a
end

local function setChecker(targetChecker)
 if not targetChecker then return end
 for _,tile in ipairs(targetChecker:GetChildren()) do
  if tile:IsA("BasePart") then
   tile.Reflectance=0
   tile.Material=Enum.Material.SmoothPlastic
   local xi,zi=tile.Name:match("^Tile_([%-]?%d+)_([%-]?%d+)$")
   if xi and zi then
    if (tonumber(xi)+tonumber(zi))%2==0 then
     tile.Color=Color3.fromRGB(126,128,126)
    else
     tile.Color=Color3.fromRGB(10,11,14)
    end
   end
  end
 end
end
setChecker(checker)

local toneTargets={
 DJBoothBase=Color3.fromRGB(112,115,120),
 DJBoothTop=Color3.fromRGB(138,140,143),
 BarFrontWhite=Color3.fromRGB(104,107,112),
 BarTop=Color3.fromRGB(132,134,138),
}
for name,color in pairs(toneTargets) do
 local p=basement:FindFirstChild(name,true)
 if p and p:IsA("BasePart") then
  p.Color=color
  p.Reflectance=0
 end
end

-- -----------------------------------------------------------------------------
-- 2) PREMIUM LOUNGE REBUILD
-- -----------------------------------------------------------------------------
if oldLounge and oldLounge.Parent then oldLounge:Destroy() end
local lounge=Instance.new("Model");lounge.Name="PremiumLoungeV4";lounge.Parent=out

local function lowGlow(name,size,cf,color,parent)
 local p=part(name,size,cf,color,Enum.Material.Neon,false,parent)
 p.CastShadow=false
 p:SetAttribute("BBYAEmissiveOnly",true)
 return p
end

local function sectional(side,z,accent)
 local x=side*48.5
 local innerX=side*44.0
 local cluster=Instance.new("Model");cluster.Name=(side<0 and "West" or "East").."Sectional_"..tostring(z);cluster.Parent=lounge

 part("Plinth",Vector3.new(10.8,.72,15.5),CFrame.new(x,-14.15,z),Color3.fromRGB(18,20,24),Enum.Material.Metal,true,cluster)
 part("Seat",Vector3.new(10.5,1.45,15.1),CFrame.new(x,-13.15,z),C.leather2,Enum.Material.Fabric,true,cluster)

 part("BackShell",Vector3.new(1.55,4.25,15.3),CFrame.new(side*54.1,-11.35,z),C.leather,Enum.Material.Fabric,true,cluster)
 for n=-2,2 do
  local cz=z+n*2.7
  part("BackCushion"..n,Vector3.new(1.72,3.25,2.35),CFrame.new(side*53.15,-11.45,cz),C.fabric,Enum.Material.Fabric,false,cluster)
 end

 part("ArmFront",Vector3.new(9.6,2.15,1.15),CFrame.new(x,-12.35,z-7.0),C.leather,Enum.Material.Fabric,true,cluster)
 part("ArmRear",Vector3.new(9.6,2.15,1.15),CFrame.new(x,-12.35,z+7.0),C.leather,Enum.Material.Fabric,true,cluster)
 lowGlow("InnerUnderglow",Vector3.new(.12,.10,13.8),CFrame.new(innerX,-14.48,z),accent,cluster)
end

sectional(-1,-11,C.blue);sectional(-1,11,C.yellow)
sectional(1,-11,C.yellow);sectional(1,11,C.blue)

local function coffeeTable(name,x,z)
 local t=Instance.new("Model");t.Name=name;t.Parent=lounge
 part("Top",Vector3.new(7.2,.34,6.4),CFrame.new(x,-13.35,z),C.glass,Enum.Material.Glass,true,t,.18)
 for _,dx in ipairs({-2.8,2.8}) do
  for _,dz in ipairs({-2.35,2.35}) do
   part("Leg",Vector3.new(.22,1.35,.22),CFrame.new(x+dx,-14.05,z+dz),C.metal,Enum.Material.Metal,true,t)
  end
 end
end
coffeeTable("WestTable",-35.5,0);coffeeTable("EastTable",35.5,0)

-- -----------------------------------------------------------------------------
-- 3) UNDERGROUND ROOM IDENTITY / FINISHING
-- -----------------------------------------------------------------------------
local identity=Instance.new("Model");identity.Name="UndergroundIdentity";identity.Parent=out
local sign=part("IdentityPanel",Vector3.new(42,7,.26),CFrame.new(0,-7.0,42.38),Color3.fromRGB(17,20,25),Enum.Material.Metal,false,identity)
sign.CanQuery=true
local sg=Instance.new("SurfaceGui");sg.Name="IdentityGui";sg.Face=Enum.NormalId.Front;sg.PixelsPerStud=70;sg.LightInfluence=.15;sg.Parent=sign
local title=Instance.new("TextLabel");title.BackgroundTransparency=1;title.Position=UDim2.fromScale(.04,.10);title.Size=UDim2.fromScale(.92,.48);title.Text="BBYA UNDERGROUND";title.Font=Enum.Font.GothamBlack;title.TextScaled=true;title.TextColor3=C.white;title.Parent=sg
local sub=Instance.new("TextLabel");sub.BackgroundTransparency=1;sub.Position=UDim2.fromScale(.08,.62);sub.Size=UDim2.fromScale(.84,.20);sub.Text="INDO ROOM  •  BREAKBEAT  •  INDO BOUNCE";sub.Font=Enum.Font.GothamBold;sub.TextScaled=true;sub.TextColor3=C.blue;sub.Parent=sg

for _,x in ipairs({-48,-24,0,24,48}) do
 part("NorthTrim"..x,Vector3.new(.09,9.8,.18),CFrame.new(x,-7.8,42.55),C.metal,Enum.Material.Metal,false,identity)
 part("SouthTrim"..x,Vector3.new(.09,9.8,.18),CFrame.new(x,-7.8,-42.55),C.metal,Enum.Material.Metal,false,identity)
end

-- Final state is written once. There is intentionally no DescendantAdded hook,
-- delayed re-assert sequence, or five-second watchdog.
basement:SetAttribute("LightingProfile","DARK_UNDERGROUND_V9_READABLE")
basement:SetAttribute("LoungeProfile","LOW_SECTIONAL_V4")
basement:SetAttribute("RoomIdentity","BBYA_UNDERGROUND_INDO")
basement:SetAttribute("OverbrightRootCauseFix",true)
basement:SetAttribute("LegacyLocalLightsRemoved",removedLocalLights)
basement:SetAttribute("DedicatedRoomLightCount",4)
basement:SetAttribute("DecorativeNeonEmitters",false)
basement:SetAttribute("ContinuousDarkLock",false)
basement:SetAttribute("DarkLockVersion","REMOVED_V6_SINGLE_AUTHORITY")

print(string.format("[BBYA] Basement Full Upgrade v6 readable: removed %d stacked local lights / 4 controlled soft fills / no watchdog",removedLocalLights))
