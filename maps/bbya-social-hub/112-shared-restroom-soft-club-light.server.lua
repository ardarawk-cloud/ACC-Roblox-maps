-- BBYA SOCIAL HUB — SHARED RESTROOM + MAIN CLUB SOFT LIGHTING v2
-- Extends the shared restroom into the unused rear-right footprint and slightly lifts Main Club soft fill.
-- Keeps one free Travel restroom for all venues and does not change global Lighting.

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
-- Right-front footprint continues to roughly Z=-33. V1 stopped at Z=-21.8, leaving a large unused rear pocket.
-- V2 keeps the same entrance at Z=-9.2 but extends the room back to Z=-30.8.
local restroom=Instance.new("Model")
restroom.Name="SharedRestroomV1"
restroom:SetAttribute("BBYASharedAmenity","RESTROOM")
restroom:SetAttribute("LayoutVersion","V2_EXTENDED_REAR")
restroom:SetAttribute("RearSpaceUsed",true)
restroom:SetAttribute("RoomDepthStuds",21.6)
restroom:SetAttribute("PrivacyDivider",true)
restroom.Parent=root

local shell=Instance.new("Folder");shell.Name="Architecture";shell.Parent=restroom
local fixtures=Instance.new("Folder");fixtures.Name="Fixtures";fixtures.Parent=restroom
local detail=Instance.new("Folder");detail.Name="Detail";detail.Parent=restroom

local cx=43
local frontZ=-9.2
local backZ=-30.8
local cz=(frontZ+backZ)/2
local depth=math.abs(backZ-frontZ)

part(shell,"Floor",Vector3.new(16,.24,depth),CFrame.new(cx,1.02,cz),C.floor,Enum.Material.Slate,0,true)
part(shell,"Ceiling",Vector3.new(16,.35,depth),CFrame.new(cx,10.65,cz),C.dark,Enum.Material.Slate,0,false)
part(shell,"LeftWall",Vector3.new(.45,9.5,depth),CFrame.new(35.2,5.8,cz),C.wall,Enum.Material.Slate,0,true)
part(shell,"RightWall",Vector3.new(.45,9.5,depth),CFrame.new(50.8,5.8,cz),C.wall,Enum.Material.Slate,0,true)
part(shell,"BackWall",Vector3.new(16,9.5,.45),CFrame.new(cx,5.8,backZ),C.wall,Enum.Material.Slate,0,true)
-- Front wall keeps the original centered 4-stud doorway toward Main Bar.
part(shell,"FrontWallL",Vector3.new(5.8,9.5,.45),CFrame.new(38.1,5.8,frontZ),C.wall,Enum.Material.Slate,0,true)
part(shell,"FrontWallR",Vector3.new(5.8,9.5,.45),CFrame.new(47.9,5.8,frontZ),C.wall,Enum.Material.Slate,0,true)
part(shell,"DoorHeader",Vector3.new(4.2,2.1,.45),CFrame.new(cx,9.5,frontZ),C.wall,Enum.Material.Slate,0,true)

-- Entry frame + amenity signage; still no duplicate world prompt.
part(detail,"EntryFrameL",Vector3.new(.22,7.0,.22),CFrame.new(40.92,4.65,-8.92),C.metal,Enum.Material.Metal,0,false)
part(detail,"EntryFrameR",Vector3.new(.22,7.0,.22),CFrame.new(45.08,4.65,-8.92),C.metal,Enum.Material.Metal,0,false)
local sign=part(detail,"RestroomSign",Vector3.new(4.4,1.15,.16),CFrame.new(cx,8.65,-8.94),C.dark,Enum.Material.Metal,0,false)
cornerSurfaceText(sign,Enum.NormalId.Back,"RESTROOM",C.white)
local signLine=part(detail,"RestroomSignAccent",Vector3.new(3.4,.07,.08),CFrame.new(cx,8.08,-8.84),C.cyan,Enum.Material.Neon,.18,false)
signLine.CastShadow=false

-- Front foyer: vanity stays near the entrance while the Travel landing remains clear around X=43/Z=-13.
part(fixtures,"VanityBase",Vector3.new(5.1,2.25,1.55),CFrame.new(38.2,2.18,-12.35),C.panel,Enum.Material.Metal,0,true)
part(fixtures,"VanityTop",Vector3.new(5.3,.24,1.72),CFrame.new(38.2,3.42,-12.35),C.stone,Enum.Material.Marble,0,false)
for i,x in ipairs({37.15,39.25}) do
 local basin=part(fixtures,"Basin_"..i,Vector3.new(1.45,.16,.88),CFrame.new(x,3.57,-12.35),C.white,Enum.Material.SmoothPlastic,0,false)
 basin.Shape=Enum.PartType.Cylinder;basin.CFrame=CFrame.new(x,3.57,-12.35)*CFrame.Angles(0,0,math.rad(90))
 part(fixtures,"Faucet_"..i,Vector3.new(.12,.55,.12),CFrame.new(x,3.86,-12.85),C.metal,Enum.Material.Metal,0,false)
end
local mirror=part(fixtures,"Mirror",Vector3.new(5.1,2.6,.10),CFrame.new(38.2,5.25,-9.48),Color3.fromRGB(110,124,132),Enum.Material.Glass,.12,false)
mirror.Reflectance=.22

-- Small right-wall amenity details make the longer foyer intentional rather than empty.
part(fixtures,"AmenityShelf",Vector3.new(.9,.18,3.6),CFrame.new(50.25,4.0,-14.6),C.metal,Enum.Material.Metal,0,false)
part(fixtures,"HandDryer",Vector3.new(.45,1.15,1.35),CFrame.new(50.42,5.2,-13.5),C.panel,Enum.Material.Metal,0,false)
part(fixtures,"WasteBin",Vector3.new(1.15,1.75,1.15),CFrame.new(49.55,1.9,-16.7),C.dark,Enum.Material.Metal,0,true)

-- Privacy divider blocks the direct entrance-to-stall sightline while leaving a generous passage on the right.
part(shell,"PrivacyDivider",Vector3.new(10.4,6.8,.24),CFrame.new(40.4,4.4,-20.7),C.panel,Enum.Material.Slate,0,true)
local privacyAccent=part(detail,"PrivacyAccent",Vector3.new(8.8,.08,.10),CFrame.new(40.4,7.55,-20.53),C.cyan,Enum.Material.Neon,.28,false)
privacyAccent.CastShadow=false

-- Three shared stalls now sit deep in the rear pocket instead of wasting the available footprint.
for _,x in ipairs({40.5,45.5}) do
 part(fixtures,"StallDivider_"..tostring(x),Vector3.new(.18,6.5,6.35),CFrame.new(x,4.35,-27.05),C.panel,Enum.Material.Metal,0,true)
end
for i,x in ipairs({38.0,43.0,48.0}) do
 part(fixtures,"StallDoor_"..i,Vector3.new(3.55,5.8,.14),CFrame.new(x,4.05,-23.85),C.panel,Enum.Material.Metal,.03,false)
 part(fixtures,"DoorGap_"..i,Vector3.new(.09,.09,.18),CFrame.new(x+1.35,4.0,-23.73),C.cyan,Enum.Material.Neon,.20,false)
 part(fixtures,"ToiletBase_"..i,Vector3.new(1.55,.72,1.85),CFrame.new(x,1.55,-28.75),C.white,Enum.Material.SmoothPlastic,0,false)
 part(fixtures,"ToiletSeat_"..i,Vector3.new(1.72,.18,1.92),CFrame.new(x,2.00,-28.65),C.white,Enum.Material.SmoothPlastic,0,false)
 part(fixtures,"ToiletTank_"..i,Vector3.new(1.55,1.45,.58),CFrame.new(x,2.38,-29.62),C.white,Enum.Material.SmoothPlastic,0,false)
end

-- Six soft ceiling diffusers cover both the foyer and the new rear stall zone evenly.
local restroomLights={
 {38.2,-14.2},{43.0,-14.2},{47.8,-14.2},
 {38.2,-25.7},{43.0,-25.7},{47.8,-25.7},
}
for i,v in ipairs(restroomLights) do
 local diffuser=part(detail,"RestroomCeilingLight_"..i,Vector3.new(2.45,.12,1.0),CFrame.new(v[1],10.38,v[2]),C.warm,Enum.Material.Glass,.28,false)
 surfaceLight(diffuser,.72,11,C.warm)
end

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

print("[BBYA] Shared Restroom v2 extended rear mapping + Main Club soft lighting v2 online")
