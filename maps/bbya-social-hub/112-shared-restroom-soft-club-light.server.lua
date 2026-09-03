-- BBYA SOCIAL HUB — SHARED RESTROOM + MAIN CLUB SOFT LIGHTING v5
-- Premium tall shared restroom with full rear-footprint use and true 15-stud avatar clearance.
-- v5: basin cylinders use a horizontal shallow orientation; Main Club soft-light authority below is unchanged.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

for _,name in ipairs({"SharedRestroomV1","MainClubSoftLightingV1"}) do
 local old=root:FindFirstChild(name)
 if old then old:Destroy() end
end

local C={
 dark=Color3.fromRGB(12,12,15),
 wall=Color3.fromRGB(28,27,32),
 panel=Color3.fromRGB(40,39,45),
 metal=Color3.fromRGB(62,61,68),
 floor=Color3.fromRGB(48,46,51),
 stone=Color3.fromRGB(113,108,112),
 white=Color3.fromRGB(232,230,225),
 warm=Color3.fromRGB(255,226,199),
 cyan=Color3.fromRGB(65,198,218),
 pink=Color3.fromRGB(235,53,157),
}

local function part(parent,name,size,cf,color,material,transparency,collide)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.panel;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
 return p
end
local function cornerSurfaceText(host,face,text,color)
 local sg=Instance.new("SurfaceGui");sg.Face=face;sg.AlwaysOnTop=false;sg.LightInfluence=.35;sg.PixelsPerStud=60;sg.Parent=host
 local l=Instance.new("TextLabel");l.Size=UDim2.fromScale(1,1);l.BackgroundTransparency=1;l.Text=text;l.TextColor3=color or C.white;l.Font=Enum.Font.GothamBold;l.TextScaled=true;l.Parent=sg
 return l
end
local function surfaceLight(host,brightness,range,color)
 local l=Instance.new("SurfaceLight")
 l.Face=Enum.NormalId.Bottom;l.Brightness=brightness;l.Range=range;l.Angle=115;l.Color=color or C.warm;l.Shadows=false;l.Parent=host
 return l
end

-- SHARED RESTROOM -------------------------------------------------------------
local restroom=Instance.new("Model")
restroom.Name="SharedRestroomV1"
restroom:SetAttribute("BBYASharedAmenity","RESTROOM")
restroom:SetAttribute("LayoutVersion","V5_TRUE_15_CLEAR_BASIN_HORIZONTAL")
restroom:SetAttribute("RearSpaceUsed",true)
restroom:SetAttribute("RoomDepthStuds",21.6)
restroom:SetAttribute("PrivacyDivider",true)
restroom:SetAttribute("PremiumInterior",true)
restroom:SetAttribute("ZepetoClearance",true)
restroom:SetAttribute("ClearInteriorHeightStuds",15)
restroom:SetAttribute("BasinOrientation","HORIZONTAL_SHALLOW")
restroom:SetAttribute("StallCount",3)
restroom.Parent=root

local shell=Instance.new("Folder");shell.Name="Architecture";shell.Parent=restroom
local fixtures=Instance.new("Folder");fixtures.Name="Fixtures";fixtures.Parent=restroom
local detail=Instance.new("Folder");detail.Name="Detail";detail.Parent=restroom

local cx=43
local frontZ=-9.2
local backZ=-30.8
local cz=(frontZ+backZ)/2
local depth=math.abs(backZ-frontZ)

-- Floor top is ~1.14 and ceiling bottom is ~16.145: true ~15 studs clear.
part(shell,"Floor",Vector3.new(16,.24,depth),CFrame.new(cx,1.02,cz),C.floor,Enum.Material.Slate,0,true)
part(shell,"Ceiling",Vector3.new(16,.35,depth),CFrame.new(cx,16.32,cz),C.dark,Enum.Material.Slate,0,false)
part(shell,"LeftWall",Vector3.new(.45,15.0,depth),CFrame.new(35.2,8.64,cz),C.wall,Enum.Material.Slate,0,true)
part(shell,"RightWall",Vector3.new(.45,15.0,depth),CFrame.new(50.8,8.64,cz),C.wall,Enum.Material.Slate,0,true)
part(shell,"BackWall",Vector3.new(16,15.0,.45),CFrame.new(cx,8.64,backZ),C.wall,Enum.Material.Slate,0,true)
part(shell,"FrontWallL",Vector3.new(5.8,15.0,.45),CFrame.new(38.1,8.64,frontZ),C.wall,Enum.Material.Slate,0,true)
part(shell,"FrontWallR",Vector3.new(5.8,15.0,.45),CFrame.new(47.9,8.64,frontZ),C.wall,Enum.Material.Slate,0,true)
part(shell,"DoorHeader",Vector3.new(4.2,3.0,.45),CFrame.new(cx,14.65,frontZ),C.wall,Enum.Material.Slate,0,true)

-- Premium entrance follows the taller shell; Travel landing stays untouched.
part(detail,"EntryFrameL",Vector3.new(.22,11.5,.22),CFrame.new(40.92,6.9,-8.92),C.metal,Enum.Material.Metal,0,false)
part(detail,"EntryFrameR",Vector3.new(.22,11.5,.22),CFrame.new(45.08,6.9,-8.92),C.metal,Enum.Material.Metal,0,false)
local sign=part(detail,"RestroomSign",Vector3.new(4.7,1.25,.16),CFrame.new(cx,14.45,-8.94),C.dark,Enum.Material.Metal,0,false)
cornerSurfaceText(sign,Enum.NormalId.Back,"RESTROOM",C.white)
local subSign=part(detail,"RestroomSubSign",Vector3.new(3.4,.55,.12),CFrame.new(cx,13.45,-8.93),C.panel,Enum.Material.Metal,0,false)
cornerSurfaceText(subSign,Enum.NormalId.Back,"ALL GUESTS",C.cyan)
local signLine=part(detail,"RestroomSignAccent",Vector3.new(3.8,.07,.08),CFrame.new(cx,13.06,-8.84),C.cyan,Enum.Material.Neon,.18,false)
signLine.CastShadow=false

part(detail,"DryZoneInlay",Vector3.new(5.7,.04,8.2),CFrame.new(38.35,1.16,-14.7),C.stone,Enum.Material.Marble,.28,false)

-- Vanity/mirror remain on the interior side of the basin; no exterior-facing glass panel.
part(fixtures,"VanityBase",Vector3.new(5.1,2.25,1.55),CFrame.new(38.2,2.18,-12.35),C.panel,Enum.Material.Metal,0,true)
part(fixtures,"VanityTop",Vector3.new(5.3,.24,1.72),CFrame.new(38.2,3.42,-12.35),C.stone,Enum.Material.Marble,0,false)
part(fixtures,"VanityBacksplash",Vector3.new(5.45,1.25,.12),CFrame.new(38.2,4.05,-13.15),C.stone,Enum.Material.Marble,0,false)
for i,x in ipairs({37.15,39.25}) do
 -- Roblox Cylinder length follows local X. Put the thin .16 dimension on local X,
 -- then rotate Z 90 degrees so the basin stays shallow vertically and wide across X.
 local basin=part(fixtures,"Basin_"..i,Vector3.new(.16,1.45,.88),CFrame.new(x,3.57,-12.35),C.white,Enum.Material.SmoothPlastic,0,false)
 basin.Shape=Enum.PartType.Cylinder;basin.CFrame=CFrame.new(x,3.57,-12.35)*CFrame.Angles(0,0,math.rad(90))
 basin:SetAttribute("OrientationFix","HORIZONTAL_SHALLOW_V1")
 part(fixtures,"Faucet_"..i,Vector3.new(.12,.55,.12),CFrame.new(x,3.86,-12.85),C.metal,Enum.Material.Metal,0,false)
end
part(detail,"MirrorFrame",Vector3.new(5.7,5.6,.08),CFrame.new(38.2,7.7,-13.23),C.metal,Enum.Material.Metal,0,false)
local mirror=part(fixtures,"Mirror",Vector3.new(5.35,5.25,.10),CFrame.new(38.2,7.7,-13.14),Color3.fromRGB(110,124,132),Enum.Material.Glass,.10,false)
mirror.Reflectance=.24
local mirrorTop=part(detail,"MirrorLightBar",Vector3.new(4.9,.12,.12),CFrame.new(38.2,10.55,-13.02),C.warm,Enum.Material.Neon,.12,false)
mirrorTop.CastShadow=false
part(detail,"MirrorAccentL",Vector3.new(.08,5.1,.08),CFrame.new(35.53,7.7,-13.00),C.cyan,Enum.Material.Neon,.32,false)
part(detail,"MirrorAccentR",Vector3.new(.08,5.1,.08),CFrame.new(40.87,7.7,-13.00),C.cyan,Enum.Material.Neon,.32,false)
part(detail,"VanityToeGlow",Vector3.new(4.5,.08,.08),CFrame.new(38.2,1.23,-11.54),C.cyan,Enum.Material.Neon,.40,false)

part(detail,"AmenityWallPanel",Vector3.new(.10,8.8,7.4),CFrame.new(50.50,6.2,-15.4),C.panel,Enum.Material.Metal,.05,false)
part(fixtures,"AmenityShelf",Vector3.new(.9,.18,3.6),CFrame.new(50.18,4.0,-14.6),C.metal,Enum.Material.Metal,0,false)
part(fixtures,"HandDryer",Vector3.new(.45,1.15,1.35),CFrame.new(50.32,5.35,-13.45),C.panel,Enum.Material.Metal,0,false)
part(fixtures,"TowelDispenser",Vector3.new(.42,1.25,1.45),CFrame.new(50.33,6.95,-15.55),C.panel,Enum.Material.Metal,0,false)
part(fixtures,"GroomingShelf",Vector3.new(.9,.16,2.6),CFrame.new(50.18,4.0,-18.25),C.metal,Enum.Material.Metal,0,false)
part(fixtures,"WasteBin",Vector3.new(1.15,1.75,1.15),CFrame.new(49.55,1.9,-16.9),C.dark,Enum.Material.Metal,0,true)
for i,z in ipairs({-17.5,-18.4,-19.3}) do
 part(fixtures,"WallHook_"..i,Vector3.new(.18,.36,.18),CFrame.new(50.38,6.2,z),C.metal,Enum.Material.Metal,0,false)
end

part(shell,"PrivacyDivider",Vector3.new(10.4,11.6,.24),CFrame.new(40.4,6.8,-20.7),C.panel,Enum.Material.Slate,0,true)
part(detail,"PrivacyHeader",Vector3.new(10.4,.18,.30),CFrame.new(40.4,12.58,-20.7),C.metal,Enum.Material.Metal,0,false)
local privacyAccent=part(detail,"PrivacyAccent",Vector3.new(8.8,.08,.10),CFrame.new(40.4,12.45,-20.53),C.cyan,Enum.Material.Neon,.28,false)
privacyAccent.CastShadow=false

for _,x in ipairs({40.5,45.5}) do
 part(fixtures,"StallDivider_"..tostring(x),Vector3.new(.18,11.5,6.35),CFrame.new(x,6.85,-27.05),C.panel,Enum.Material.Metal,0,true)
end
for i,x in ipairs({38.0,43.0,48.0}) do
 part(fixtures,"StallDoor_"..i,Vector3.new(3.55,10.8,.14),CFrame.new(x,6.55,-23.85),C.panel,Enum.Material.Metal,.02,false)
 part(fixtures,"DoorGap_"..i,Vector3.new(.14,.14,.18),CFrame.new(x+1.35,11.0,-23.73),C.cyan,Enum.Material.Neon,.12,false)
 part(fixtures,"StallHandle_"..i,Vector3.new(.12,.48,.12),CFrame.new(x+1.25,4.55,-23.66),C.metal,Enum.Material.Metal,0,false)
 part(detail,"StallBackPanel_"..i,Vector3.new(4.6,7.2,.10),CFrame.new(x,6.15,-30.53),C.dark,Enum.Material.Slate,0,false)
 part(detail,"StallAccent_"..i,Vector3.new(3.4,.08,.08),CFrame.new(x,10.15,-30.42),C.cyan,Enum.Material.Neon,.38,false)
 part(fixtures,"ToiletBase_"..i,Vector3.new(1.55,.72,1.85),CFrame.new(x,1.55,-28.75),C.white,Enum.Material.SmoothPlastic,0,false)
 part(fixtures,"ToiletSeat_"..i,Vector3.new(1.72,.18,1.92),CFrame.new(x,2.00,-28.65),C.white,Enum.Material.SmoothPlastic,0,false)
 part(fixtures,"ToiletTank_"..i,Vector3.new(1.55,1.45,.58),CFrame.new(x,2.38,-29.62),C.white,Enum.Material.SmoothPlastic,0,false)
 part(fixtures,"PaperHolder_"..i,Vector3.new(.35,.35,.55),CFrame.new(x+1.62,3.05,-27.55),C.metal,Enum.Material.Metal,0,false)
end

local restroomLights={
 {38.2,-14.2},{43.0,-14.2},{47.8,-14.2},
 {38.2,-25.7},{43.0,-25.7},{47.8,-25.7},
}
for i,v in ipairs(restroomLights) do
 local diffuser=part(detail,"RestroomCeilingLight_"..i,Vector3.new(2.45,.12,1.0),CFrame.new(v[1],16.02,v[2]),C.warm,Enum.Material.Glass,.25,false)
 surfaceLight(diffuser,.82,17,C.warm)
end
part(detail,"CoveAccentL",Vector3.new(.08,.10,depth-2),CFrame.new(35.48,14.35,cz),C.cyan,Enum.Material.Neon,.48,false)
part(detail,"CoveAccentR",Vector3.new(.08,.10,depth-2),CFrame.new(50.52,14.35,cz),C.cyan,Enum.Material.Neon,.48,false)

-- MAIN CLUB SOFT CEILING WASH -------------------------------------------------
local clubLights=Instance.new("Model")
clubLights.Name="MainClubSoftLightingV1"
clubLights:SetAttribute("LightingIntent","SOFT_WARM_NEUTRAL")
clubLights:SetAttribute("LightingVersion","V2_SLIGHTLY_BRIGHTER")
clubLights:SetAttribute("NormalBrightness",.56)
clubLights:SetAttribute("BarBrightness",.70)
clubLights.Parent=root

-- Same fixture positions as V1; only a modest fill lift so the nightclub contrast remains intact.
local clubFixturePositions={
 {-18,3},{-5,3},{8,3},{21,3},{34,3},
 {-18,21},{-5,21},{8,21},{21,21},{34,21},
 {42,2},{42,18}, -- bar-side fill
}
for i,v in ipairs(clubFixturePositions) do
 local isBar=v[1]>=40
 local fixture=part(clubLights,"SoftCeilingFixture_"..i,Vector3.new(isBar and 2.8 or 3.2,.13,1.0),CFrame.new(v[1],17.35,v[2]),C.warm,Enum.Material.Glass,.32,false)
 fixture.CastShadow=false
 surfaceLight(fixture,isBar and .70 or .56,isBar and 16 or 14,C.warm)
end

print("[BBYA] Shared Restroom true 15-clear v5 + horizontal basins + Main Club soft lighting v2 online")
