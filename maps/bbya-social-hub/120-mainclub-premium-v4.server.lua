-- BBYA SOCIAL HUB — MAIN CLUB PREMIUM v4
-- Final refinement pass for the Main Club only.
-- Premium entrance reveal, realistic bar-service dressing, restrained moving heads,
-- and proper stage-side cocktail pockets replacing the legacy round tables.
-- Preserves stage, DJ booth, lounge seating, restroom, mall, VIP and global ambience.

local Workspace=game:GetService("Workspace")
local TweenService=game:GetService("TweenService")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local realism=root:WaitForChild("MainClubRealism",30)
if not realism then return end

local old=root:FindFirstChild("MainClubPremiumV4")
if old then old:Destroy() end

local out=Instance.new("Model")
out.Name="MainClubPremiumV4"
out:SetAttribute("Pass","MAIN_CLUB_PREMIUM_V4")
out:SetAttribute("Revision","V4_REFINED_FINAL")
out:SetAttribute("Scope","MAIN_CLUB_ONLY")
out:SetAttribute("EntranceReveal",true)
out:SetAttribute("BarServiceDetail",true)
out:SetAttribute("MovingHeadFixtures",8)
out:SetAttribute("RearCocktailPockets",4)
out:SetAttribute("LegacyRearCocktailsRemoved",true)
out:SetAttribute("MovingHeadOpticsAligned",true)
out:SetAttribute("NoGlobalLightingChanges",true)
out:SetAttribute("AudioUntouched",true)
out:SetAttribute("DJBoothUntouched",true)
out:SetAttribute("VIPUntouched",true)
out:SetAttribute("MallUntouched",true)
out.Parent=root

local C={
 black=Color3.fromRGB(7,7,9),
 ink=Color3.fromRGB(13,12,16),
 graphite=Color3.fromRGB(36,35,40),
 metal=Color3.fromRGB(61,60,66),
 smoked=Color3.fromRGB(42,48,53),
 brass=Color3.fromRGB(154,116,67),
 champagne=Color3.fromRGB(210,171,108),
 marble=Color3.fromRGB(121,116,123),
 warm=Color3.fromRGB(255,219,184),
 pink=Color3.fromRGB(247,55,158),
 cyan=Color3.fromRGB(32,190,215),
 white=Color3.fromRGB(245,244,247),
 bottle=Color3.fromRGB(52,39,29),
 glass=Color3.fromRGB(196,211,220),
 ice=Color3.fromRGB(216,231,238),
 citrus=Color3.fromRGB(224,164,72),
}

local function model(name,parent)
 local m=Instance.new("Model")
 m.Name=name
 m.Parent=parent or out
 return m
end

local function block(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Color=color or C.graphite
 p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0
 p.Anchored=true
 p.CanCollide=collide==true
 p.CanTouch=false
 p.CanQuery=false
 p.CastShadow=material~=Enum.Material.Neon
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out
 return p
end

local function verticalCylinder(name,height,diameter,cf,color,material,transparency,parent)
 local p=block(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,transparency,false,parent)
 p.Shape=Enum.PartType.Cylinder
 return p
end

local function point(parent,color,brightness,range)
 local l=Instance.new("PointLight")
 l.Name="ArchitecturalWarmth"
 l.Color=color
 l.Brightness=brightness
 l.Range=range
 l.Shadows=false
 l.Parent=parent
 return l
end

-- -----------------------------------------------------------------------------
-- 1) MAIN CLUB ENTRANCE REVEAL
-- Layered portal + shallow canopy create a deliberate arrival sequence while keeping
-- the guest path fully open and collision-free.
-- -----------------------------------------------------------------------------
local entrance=model("MainClubEntranceReveal")
local PORTAL_Z=-7.45

block("RevealCanopy",Vector3.new(30.2,.24,3.4),CFrame.new(3,11.18,PORTAL_Z+1.28),C.ink,Enum.Material.Metal,0,false,entrance)
block("RevealCanopyLip",Vector3.new(28.8,.08,.10),CFrame.new(3,10.98,PORTAL_Z-.44),C.champagne,Enum.Material.Metal,0,false,entrance)

for _,side in ipairs({-1,1}) do
 local x=3+side*15.2
 block("PortalPier_"..side,Vector3.new(.82,10.6,1.15),CFrame.new(x,6.25,PORTAL_Z),C.black,Enum.Material.Metal,0,false,entrance)
 block("PortalFace_"..side,Vector3.new(.16,8.8,.58),CFrame.new(x-side*.48,6.15,PORTAL_Z-.34),C.graphite,Enum.Material.Slate,0,false,entrance)
 block("ChampagneInlay_"..side,Vector3.new(.07,7.8,.09),CFrame.new(x-side*.58,6.15,PORTAL_Z-.69),C.champagne,Enum.Material.Metal,0,false,entrance)
 for rib=1,3 do
  block("RevealFin_"..side.."_"..rib,Vector3.new(.14,5.6,.72),CFrame.new(x-side*(1.10+rib*.34),5.6,PORTAL_Z+.54),C.ink,Enum.Material.Metal,0,false,entrance)
 end
 local emitter=block("PortalEmitter_"..side,Vector3.new(.10,.10,.10),CFrame.new(x-side*.75,5.3,PORTAL_Z-.72),C.warm,Enum.Material.Neon,.72,false,entrance)
 point(emitter,C.warm,.30,8.0)
end

block("PortalLintel",Vector3.new(31.2,.72,1.18),CFrame.new(3,11.58,PORTAL_Z),C.black,Enum.Material.Metal,0,false,entrance)
block("PortalLintelReveal",Vector3.new(28.8,.08,.10),CFrame.new(3,11.12,PORTAL_Z-.64),C.champagne,Enum.Material.Metal,0,false,entrance)
local plaque=block("MainClubPlaque",Vector3.new(10.8,1.38,.16),CFrame.new(3,10.12,PORTAL_Z-.66),C.ink,Enum.Material.Metal,0,false,entrance)
local sg=Instance.new("SurfaceGui")
sg.Name="MainClubPlaqueUI"
sg.Face=Enum.NormalId.Front
sg.LightInfluence=.08
sg.PixelsPerStud=62
sg.Parent=plaque
local title=Instance.new("TextLabel")
title.Size=UDim2.fromScale(1,1)
title.BackgroundTransparency=1
title.Text="BBYA  MAIN CLUB"
title.TextColor3=C.champagne
title.TextStrokeTransparency=.88
title.Font=Enum.Font.GothamBold
title.TextScaled=true
title.Parent=sg

-- -----------------------------------------------------------------------------
-- 2) BAR SERVICE FINISH
-- Working-bar cues: wells, ice, shakers, garnish jars, tap tower, POS, hanging stems,
-- service rail and low local task glow. All pieces sit on the existing bar geometry.
-- -----------------------------------------------------------------------------
local bar=model("MainBarServiceFinish")
block("CocktailMat",Vector3.new(2.2,.07,8.6),CFrame.new(34.00,4.47,10.2),Color3.fromRGB(20,20,23),Enum.Material.Rubber,0,false,bar)
block("ServiceRail",Vector3.new(.08,.08,9.2),CFrame.new(32.92,4.54,10.2),C.brass,Enum.Material.Metal,0,false,bar)

for i,z in ipairs({5.0,15.5}) do
 local rim=model("ServiceWell_"..i,bar)
 block("WellDark",Vector3.new(1.55,.06,2.5),CFrame.new(35.75,4.49,z),C.black,Enum.Material.Metal,0,false,rim)
 block("RimL",Vector3.new(.06,.08,2.55),CFrame.new(34.95,4.55,z),C.metal,Enum.Material.Metal,0,false,rim)
 block("RimR",Vector3.new(.06,.08,2.55),CFrame.new(36.55,4.55,z),C.metal,Enum.Material.Metal,0,false,rim)
 block("RimF",Vector3.new(1.65,.08,.06),CFrame.new(35.75,4.55,z-1.28),C.metal,Enum.Material.Metal,0,false,rim)
 block("RimB",Vector3.new(1.65,.08,.06),CFrame.new(35.75,4.55,z+1.28),C.metal,Enum.Material.Metal,0,false,rim)
 for cube=1,5 do
  local ox=((cube-1)%2)*.48-.24
  local oz=(math.floor((cube-1)/2)-1)*.52
  block("Ice_"..cube,Vector3.new(.34,.22,.34),CFrame.new(35.72+ox,4.59,z+oz)*CFrame.Angles(0,math.rad(cube*13),0),C.ice,Enum.Material.Glass,.38,false,rim)
 end
end

for i,z in ipairs({8.1,9.1,10.1}) do
 verticalCylinder("Shaker"..i,.82,.36,CFrame.new(33.65,4.92,z),i==2 and C.champagne or C.metal,Enum.Material.Metal,0,bar)
end
for i,z in ipairs({12.2,13.0,13.8}) do
 local jar=verticalCylinder("GarnishJar"..i,.42,.50,CFrame.new(33.70,4.77,z),C.glass,Enum.Material.Glass,.48,bar)
 jar.Reflectance=.04
 block("Garnish"..i,Vector3.new(.22,.12,.22),CFrame.new(33.70,4.83,z),i==2 and C.citrus or C.warm,Enum.Material.SmoothPlastic,0,false,bar)
end

local tap=model("TapTower",bar)
verticalCylinder("Tower",1.42,.42,CFrame.new(33.72,5.20,17.75),C.metal,Enum.Material.Metal,0,tap)
block("TapBridge",Vector3.new(1.60,.20,.20),CFrame.new(33.72,5.88,17.75),C.metal,Enum.Material.Metal,0,false,tap)
for i,x in ipairs({33.20,33.72,34.24}) do
 block("TapHandle"..i,Vector3.new(.16,.62,.16),CFrame.new(x,6.24,17.75),i==2 and C.champagne or C.black,Enum.Material.Metal,0,false,tap)
end

local pos=model("BarPOS",bar)
block("POSBase",Vector3.new(1.15,.12,.85),CFrame.new(33.78,4.56,2.75),C.black,Enum.Material.Metal,0,false,pos)
block("POSScreen",Vector3.new(1.28,.78,.12),CFrame.new(33.78,5.03,2.93)*CFrame.Angles(math.rad(-12),0,0),C.smoked,Enum.Material.Glass,.08,false,pos)
block("POSGlow",Vector3.new(.92,.50,.03),CFrame.new(33.78,5.04,2.86)*CFrame.Angles(math.rad(-12),0,0),C.cyan,Enum.Material.Neon,.72,false,pos)

block("GlassRackRail",Vector3.new(.14,.14,9.6),CFrame.new(47.7,11.1,11),C.metal,Enum.Material.Metal,0,false,bar)
for i,z in ipairs({7.3,9.1,10.9,12.7,14.5}) do
 local stem=block("HangingStem"..i,Vector3.new(.05,.85,.05),CFrame.new(47.2,10.62,z),C.glass,Enum.Material.Glass,.50,false,bar)
 local bowl=verticalCylinder("HangingGlass"..i,.34,.56,CFrame.new(47.2,10.15,z),C.glass,Enum.Material.Glass,.62,bar)
 stem.Reflectance=.03
 bowl.Reflectance=.04
end

local barGlow=block("ServiceGlow",Vector3.new(.08,.08,15.5),CFrame.new(36.95,4.10,11),C.warm,Enum.Material.Neon,.60,false,bar)
point(barGlow,C.warm,.16,5.2)

-- -----------------------------------------------------------------------------
-- 3) MOVING-HEAD-STYLE DANCE FLOOR LIGHTING
-- Eight compact fixtures align to the existing truss field. Head + lens move together,
-- with the optical face aimed from the front of each fixture. Slow sweep only.
-- -----------------------------------------------------------------------------
local rig=model("DanceFloorMovingHeads")
local fixtures={
 {-18,17.15,4,-10,C.pink},{-8,17.15,4,10,C.cyan},{4,17.15,4,-8,C.warm},{16,17.15,4,8,C.pink},
 {-18,17.15,25,9,C.cyan},{-8,17.15,25,-9,C.pink},{4,17.15,25,7,C.cyan},{16,17.15,25,-7,C.warm},
}

for i,d in ipairs(fixtures) do
 local m=model("MovingHead_"..i,rig)
 block("Clamp",Vector3.new(1.25,.28,.50),CFrame.new(d[1],d[2]+.70,d[3]),C.metal,Enum.Material.Metal,0,false,m)
 block("Yoke",Vector3.new(.20,1.25,1.35),CFrame.new(d[1],d[2],d[3]),C.black,Enum.Material.Metal,0,false,m)
 local baseCF=CFrame.new(d[1],d[2]-.35,d[3])*CFrame.Angles(math.rad(-24),math.rad(d[4]),0)
 local head=block("Head",Vector3.new(1.18,1.05,1.65),baseCF,C.black,Enum.Material.Metal,0,false,m)
 local lens=block("Lens",Vector3.new(.72,.55,.08),baseCF*CFrame.new(0,0,-.86),d[5],Enum.Material.Neon,.18,false,m)
 lens.CastShadow=false
 local light=Instance.new("SpotLight")
 light.Name="ClubBeam"
 light.Face=Enum.NormalId.Front
 light.Color=d[5]
 light.Brightness=(d[5]==C.warm) and .42 or .52
 light.Range=38
 light.Angle=24
 light.Shadows=false
 light.Parent=head
 local target=baseCF*CFrame.Angles(math.rad(7),math.rad((i%2==0) and 14 or -14),0)
 local duration=6.4+(i%3)*.8
 TweenService:Create(head,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{CFrame=target}):Play()
 TweenService:Create(lens,TweenInfo.new(duration,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{CFrame=target*CFrame.new(0,0,-.86)}):Play()
end

-- -----------------------------------------------------------------------------
-- 4) PREMIUM STAGE-SIDE COCKTAIL POCKETS
-- Remove the legacy round-table models generated by the base realism pass, then
-- replace them with four slim hospitality consoles + stools. Center DJ approach stays open.
-- -----------------------------------------------------------------------------
for _,obj in ipairs(realism:GetDescendants()) do
 if obj:IsA("Model") and obj.Name:match("^RearCocktail_") then
  obj:Destroy()
 end
end

local cocktails=model("StageSideCocktailPockets")
local pocketPositions={Vector3.new(-20,1.0,34.0),Vector3.new(-12,1.0,34.0),Vector3.new(18,1.0,34.0),Vector3.new(26,1.0,34.0)}

for i,pos in ipairs(pocketPositions) do
 local m=model("CocktailPocket_"..i,cocktails)
 block("BackPanel",Vector3.new(4.9,2.45,.32),CFrame.new(pos.X,2.22,pos.Z+.72),C.ink,Enum.Material.Metal,0,false,m)
 block("BackInset",Vector3.new(4.20,1.72,.08),CFrame.new(pos.X,2.36,pos.Z+.53),C.graphite,Enum.Material.Slate,0,false,m)
 block("ChampagneReveal",Vector3.new(3.8,.06,.06),CFrame.new(pos.X,3.31,pos.Z+.47),C.champagne,Enum.Material.Metal,0,false,m)
 local console=block("CocktailConsole",Vector3.new(4.75,.22,1.45),CFrame.new(pos.X,3.64,pos.Z),C.smoked,Enum.Material.Glass,.16,false,m)
 console.Reflectance=.10
 block("ConsoleEdge",Vector3.new(4.55,.07,.07),CFrame.new(pos.X,3.72,pos.Z-.70),C.champagne,Enum.Material.Metal,0,false,m)
 block("FootRail",Vector3.new(3.65,.12,.12),CFrame.new(pos.X,1.62,pos.Z-.66),C.metal,Enum.Material.Metal,0,false,m)

 verticalCylinder("BottleBucket",.58,.72,CFrame.new(pos.X-.95,4.02,pos.Z+.05),C.metal,Enum.Material.Metal,0,m)
 verticalCylinder("Bottle",.92,.30,CFrame.new(pos.X-.95,4.47,pos.Z+.05),C.bottle,Enum.Material.Glass,.10,m)
 verticalCylinder("GlassA",.50,.34,CFrame.new(pos.X+.28,4.00,pos.Z-.18),C.glass,Enum.Material.Glass,.58,m)
 verticalCylinder("GlassB",.50,.34,CFrame.new(pos.X+.67,4.00,pos.Z+.16),C.glass,Enum.Material.Glass,.58,m)

 for stool=1,2 do
  local sx=pos.X+((stool==1) and -1.35 or 1.35)
  verticalCylinder("StoolSeat"..stool,.22,1.55,CFrame.new(sx,2.34,pos.Z-1.78),C.smoked,Enum.Material.Glass,.18,m)
  verticalCylinder("StoolStem"..stool,1.82,.22,CFrame.new(sx,1.38,pos.Z-1.78),C.metal,Enum.Material.Metal,0,m)
  verticalCylinder("StoolFoot"..stool,.12,1.24,CFrame.new(sx,.47,pos.Z-1.78),C.black,Enum.Material.Metal,0,m)
 end

 local toe=block("PocketGlow",Vector3.new(3.20,.05,.06),CFrame.new(pos.X,1.10,pos.Z+.49),i%2==0 and C.cyan or C.pink,Enum.Material.Neon,.64,false,m)
 point(toe,toe.Color,.08,3.2)
end

print("[BBYA] Main Club Premium v4 refined final: premium reveal / realistic bar service / aligned moving heads / legacy rear tables replaced")
