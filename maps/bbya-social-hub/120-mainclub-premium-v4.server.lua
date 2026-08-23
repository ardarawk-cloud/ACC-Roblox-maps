-- BBYA SOCIAL HUB — MAIN CLUB PREMIUM v4
-- Late decorative/experience pass for the Main Club only.
-- Adds a proper entrance reveal, richer bar service details, moving-head-style
-- dance-floor lighting and premium standing cocktail pockets near the stage.
-- Preserves DJ booth, audio, lounge seating, restroom, mall, VIP and global Lighting.

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
out:SetAttribute("Scope","MAIN_CLUB_ONLY")
out:SetAttribute("EntranceReveal",true)
out:SetAttribute("BarServiceDetail",true)
out:SetAttribute("MovingHeadFixtures",8)
out:SetAttribute("RearCocktailPockets",4)
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
}

local function model(name,parent)
 local m=Instance.new("Model")
 m.Name=name;m.Parent=parent or out
 return m
end

local function block(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false
 p.CastShadow=material~=Enum.Material.Neon;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
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
 l.Name="ArchitecturalWarmth";l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=parent
 return l
end

-- -----------------------------------------------------------------------------
-- 1) MAIN CLUB ENTRANCE REVEAL
-- Open portal across the transition court. It frames the room without adding a door
-- or collision across the guest path.
-- -----------------------------------------------------------------------------
local entrance=model("MainClubEntranceReveal")
local PORTAL_Z=-7.45
for _,side in ipairs({-1,1}) do
 local x=3+side*15.2
 block("PortalPier_"..side,Vector3.new(.82,10.6,1.15),CFrame.new(x,6.25,PORTAL_Z),C.black,Enum.Material.Metal,0,false,entrance)
 block("PortalFace_"..side,Vector3.new(.16,8.8,.58),CFrame.new(x-side*.48,6.15,PORTAL_Z-.34),C.graphite,Enum.Material.Slate,0,false,entrance)
 block("ChampagneInlay_"..side,Vector3.new(.07,7.8,.09),CFrame.new(x-side*.58,6.15,PORTAL_Z-.69),C.champagne,Enum.Material.Metal,0,false,entrance)
 local emitter=block("PortalEmitter_"..side,Vector3.new(.10,.10,.10),CFrame.new(x-side*.75,5.3,PORTAL_Z-.72),C.warm,Enum.Material.Neon,.72,false,entrance)
 point(emitter,C.warm,.32,8.5)
end
block("PortalLintel",Vector3.new(31.2,.72,1.18),CFrame.new(3,11.58,PORTAL_Z),C.black,Enum.Material.Metal,0,false,entrance)
block("PortalLintelReveal",Vector3.new(28.8,.08,.10),CFrame.new(3,11.12,PORTAL_Z-.64),C.champagne,Enum.Material.Metal,0,false,entrance)
local plaque=block("MainClubPlaque",Vector3.new(10.8,1.38,.16),CFrame.new(3,10.12,PORTAL_Z-.66),C.ink,Enum.Material.Metal,0,false,entrance)
local sg=Instance.new("SurfaceGui")
sg.Name="MainClubPlaqueUI";sg.Face=Enum.NormalId.Front;sg.LightInfluence=.08;sg.PixelsPerStud=62;sg.Parent=plaque
local title=Instance.new("TextLabel")
title.Size=UDim2.fromScale(1,1);title.BackgroundTransparency=1;title.Text="BBYA  MAIN CLUB";title.TextColor3=C.champagne
title.TextStrokeTransparency=.88;title.Font=Enum.Font.GothamBold;title.TextScaled=true;title.Parent=sg

-- -----------------------------------------------------------------------------
-- 2) BAR SERVICE FINISH
-- Small, believable working-bar details on the existing premium counter.
-- -----------------------------------------------------------------------------
local bar=model("MainBarServiceFinish")
-- rubber cocktail mat and brass rail
block("CocktailMat",Vector3.new(2.2,.07,8.6),CFrame.new(34.00,4.47,10.2),Color3.fromRGB(20,20,23),Enum.Material.Rubber,0,false,bar)
block("ServiceRail",Vector3.new(.08,.08,9.2),CFrame.new(32.92,4.54,10.2),C.brass,Enum.Material.Metal,0,false,bar)
-- sink/ice wells read as recessed service stations without cutting the existing top
for i,z in ipairs({5.0,15.5}) do
 local rim=model("ServiceWell_"..i,bar)
 block("WellDark",Vector3.new(1.55,.06,2.5),CFrame.new(35.75,4.49,z),C.black,Enum.Material.Metal,0,false,rim)
 block("RimL",Vector3.new(.06,.08,2.55),CFrame.new(34.95,4.55,z),C.metal,Enum.Material.Metal,0,false,rim)
 block("RimR",Vector3.new(.06,.08,2.55),CFrame.new(36.55,4.55,z),C.metal,Enum.Material.Metal,0,false,rim)
 block("RimF",Vector3.new(1.65,.08,.06),CFrame.new(35.75,4.55,z-1.28),C.metal,Enum.Material.Metal,0,false,rim)
 block("RimB",Vector3.new(1.65,.08,.06),CFrame.new(35.75,4.55,z+1.28),C.metal,Enum.Material.Metal,0,false,rim)
end
-- shakers + garnish jars
for i,z in ipairs({8.1,9.1,10.1}) do
 verticalCylinder("Shaker"..i,.82,.36,CFrame.new(33.65,4.92,z),i==2 and C.champagne or C.metal,Enum.Material.Metal,0,bar)
end
for i,z in ipairs({12.2,13.0,13.8}) do
 local jar=verticalCylinder("GarnishJar"..i,.42,.50,CFrame.new(33.70,4.77,z),C.glass,Enum.Material.Glass,.48,bar)
 jar.Reflectance=.04
end
-- hanging glass rack above the bartender side
block("GlassRackRail",Vector3.new(.14,.14,9.6),CFrame.new(47.7,11.1,11),C.metal,Enum.Material.Metal,0,false,bar)
for i,z in ipairs({7.3,9.1,10.9,12.7,14.5}) do
 local stem=block("HangingStem"..i,Vector3.new(.05,.85,.05),CFrame.new(47.2,10.62,z),C.glass,Enum.Material.Glass,.50,false,bar)
 local bowl=verticalCylinder("HangingGlass"..i,.34,.56,CFrame.new(47.2,10.15,z),C.glass,Enum.Material.Glass,.62,bar)
 stem.Reflectance=.03;bowl.Reflectance=.04
end
-- low service glow remains local to the bar
local barGlow=block("ServiceGlow",Vector3.new(.08,.08,15.5),CFrame.new(36.95,4.10,11),C.warm,Enum.Material.Neon,.58,false,bar)
point(barGlow,C.warm,.18,5.8)

-- -----------------------------------------------------------------------------
-- 3) MOVING-HEAD-STYLE DANCE FLOOR LIGHTING
-- Eight compact fixtures hang from the existing ceiling/truss field. Slow movement
-- is deliberately restrained: no giant beam parts and no global Lighting changes.
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
 local baseCF=CFrame.new(d[1],d[2]-.35,d[3])*CFrame.Angles(math.rad(-12),math.rad(d[4]),0)
 local head=block("Head",Vector3.new(1.18,1.05,1.65),baseCF,C.black,Enum.Material.Metal,0,false,m)
 local lens=block("Lens",Vector3.new(.72,.55,.08),baseCF*CFrame.new(0,0,-.86),d[5],Enum.Material.Neon,.18,false,m)
 lens.CastShadow=false
 local light=Instance.new("SpotLight")
 light.Name="ClubBeam";light.Face=Enum.NormalId.Bottom;light.Color=d[5];light.Brightness=(d[5]==C.warm) and .48 or .60
 light.Range=44;light.Angle=28;light.Shadows=false;light.Parent=head
 local target=baseCF*CFrame.Angles(math.rad(8),math.rad((i%2==0) and 18 or -18),0)
 local tween=TweenService:Create(head,TweenInfo.new(5.6+(i%3)*.7,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{CFrame=target})
 tween:Play()
 -- lens follows visually through a weld-like local tween-free attachment is not used;
 -- keep it static as a small fixture face so only the functional light head moves.
end

-- -----------------------------------------------------------------------------
-- 4) PREMIUM STANDING COCKTAIL POCKETS
-- Four slim sculptural tables sit in the small band between dance floor and stage,
-- leaving the center approach to the DJ fully open.
-- -----------------------------------------------------------------------------
local cocktails=model("StageSideCocktailPockets")
local pocketPositions={Vector3.new(-20,1.0,34.2),Vector3.new(-12,1.0,34.2),Vector3.new(18,1.0,34.2),Vector3.new(26,1.0,34.2)}
for i,pos in ipairs(pocketPositions) do
 local m=model("CocktailPocket_"..i,cocktails)
 verticalCylinder("Foot",.14,2.25,CFrame.new(pos.X,1.08,pos.Z),C.black,Enum.Material.Metal,0,m)
 verticalCylinder("Stem",2.35,.32,CFrame.new(pos.X,2.30,pos.Z),C.metal,Enum.Material.Metal,0,m)
 local top=verticalCylinder("Top",.18,2.75,CFrame.new(pos.X,3.55,pos.Z),C.smoked,Enum.Material.Glass,.20,m)
 top.Reflectance=.10
 block("ChampagneRing",Vector3.new(.08,.08,2.35),CFrame.new(pos.X,3.47,pos.Z),C.champagne,Enum.Material.Metal,0,false,m)
 verticalCylinder("Bottle",.88,.32,CFrame.new(pos.X-.42,4.08,pos.Z+.18),C.bottle,Enum.Material.Glass,.12,m)
 verticalCylinder("GlassA",.48,.34,CFrame.new(pos.X+.30,3.95,pos.Z-.28),C.glass,Enum.Material.Glass,.58,m)
 verticalCylinder("GlassB",.48,.34,CFrame.new(pos.X+.65,3.95,pos.Z+.18),C.glass,Enum.Material.Glass,.58,m)
 local toe=block("ToeGlow",Vector3.new(.10,.05,1.45),CFrame.new(pos.X,1.15,pos.Z),i%2==0 and C.cyan or C.pink,Enum.Material.Neon,.52,false,m)
 point(toe,toe.Color,.10,3.8)
end

print("[BBYA] Main Club Premium v4 online: entrance reveal / working-bar finish / 8 moving heads / 4 cocktail pockets")
