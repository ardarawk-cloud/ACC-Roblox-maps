-- BBYA SOCIAL HUB — SHARED RESTROOM + MAIN CLUB SOFT LIGHTING v1
-- One shared restroom beside Main Bar; reusable free Travel destination for every venue.
-- Adds restrained warm-neutral ceiling wash to Main Club without changing global Lighting.

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
-- Main Bar occupies the right club projection around X 32..53 / Z -4..26.
-- This room uses the empty front pocket immediately beside the bar, leaving a clear approach corridor.
local restroom=Instance.new("Model");restroom.Name="SharedRestroomV1";restroom:SetAttribute("BBYASharedAmenity","RESTROOM");restroom.Parent=root
local shell=Instance.new("Folder");shell.Name="Architecture";shell.Parent=restroom
local fixtures=Instance.new("Folder");fixtures.Name="Fixtures";fixtures.Parent=restroom
local detail=Instance.new("Folder");detail.Name="Detail";detail.Parent=restroom

local cx,cz=43,-15.5
part(shell,"Floor",Vector3.new(16,.24,13),CFrame.new(cx,1.02,cz),C.floor,Enum.Material.Slate,0,true)
part(shell,"Ceiling",Vector3.new(16,.35,13),CFrame.new(cx,10.65,cz),C.dark,Enum.Material.Slate,0,false)
part(shell,"LeftWall",Vector3.new(.45,9.5,13),CFrame.new(35.2,5.8,cz),C.wall,Enum.Material.Slate,0,true)
part(shell,"RightWall",Vector3.new(.45,9.5,13),CFrame.new(50.8,5.8,cz),C.wall,Enum.Material.Slate,0,true)
part(shell,"BackWall",Vector3.new(16,9.5,.45),CFrame.new(cx,5.8,-21.8),C.wall,Enum.Material.Slate,0,true)
-- Front wall leaves a 4-stud doorway centered toward Main Bar.
part(shell,"FrontWallL",Vector3.new(5.8,9.5,.45),CFrame.new(38.1,5.8,-9.2),C.wall,Enum.Material.Slate,0,true)
part(shell,"FrontWallR",Vector3.new(5.8,9.5,.45),CFrame.new(47.9,5.8,-9.2),C.wall,Enum.Material.Slate,0,true)
part(shell,"DoorHeader",Vector3.new(4.2,2.1,.45),CFrame.new(cx,9.5,-9.2),C.wall,Enum.Material.Slate,0,true)

-- Entry frame + calm amenity signage; no world teleport prompt.
part(detail,"EntryFrameL",Vector3.new(.22,7.0,.22),CFrame.new(40.92,4.65,-8.92),C.metal,Enum.Material.Metal,0,false)
part(detail,"EntryFrameR",Vector3.new(.22,7.0,.22),CFrame.new(45.08,4.65,-8.92),C.metal,Enum.Material.Metal,0,false)
local sign=part(detail,"RestroomSign",Vector3.new(4.4,1.15,.16),CFrame.new(cx,8.65,-8.94),C.dark,Enum.Material.Metal,0,false)
cornerSurfaceText(sign,Enum.NormalId.Back,"RESTROOM",C.white)
local signLine=part(detail,"RestroomSignAccent",Vector3.new(3.4,.07,.08),CFrame.new(cx,8.08,-8.84),C.cyan,Enum.Material.Neon,.18,false)
signLine.CastShadow=false

-- Three shared stalls along the back wall.
for _,x in ipairs({40.5,45.5}) do
 part(fixtures,"StallDivider_"..tostring(x),Vector3.new(.18,6.5,4.9),CFrame.new(x,4.35,-19.35),C.panel,Enum.Material.Metal,0,true)
end
for i,x in ipairs({38.0,43.0,48.0}) do
 part(fixtures,"StallDoor_"..i,Vector3.new(3.55,5.8,.14),CFrame.new(x,4.05,-16.92),C.panel,Enum.Material.Metal,.03,false)
 part(fixtures,"DoorGap_"..i,Vector3.new(.09,.09,.18),CFrame.new(x+1.35,4.0,-16.80),C.cyan,Enum.Material.Neon,.20,false)
 part(fixtures,"ToiletBase_"..i,Vector3.new(1.55,.72,1.85),CFrame.new(x,1.55,-20.15),C.white,Enum.Material.SmoothPlastic,0,false)
 part(fixtures,"ToiletSeat_"..i,Vector3.new(1.72,.18,1.92),CFrame.new(x,2.00,-20.05),C.white,Enum.Material.SmoothPlastic,0,false)
 part(fixtures,"ToiletTank_"..i,Vector3.new(1.55,1.45,.58),CFrame.new(x,2.38,-21.00),C.white,Enum.Material.SmoothPlastic,0,false)
end

-- Compact vanity beside the entrance, clear of the travel landing zone.
part(fixtures,"VanityBase",Vector3.new(5.1,2.25,1.55),CFrame.new(38.2,2.18,-11.35),C.panel,Enum.Material.Metal,0,true)
part(fixtures,"VanityTop",Vector3.new(5.3,.24,1.72),CFrame.new(38.2,3.42,-11.35),C.stone,Enum.Material.Marble,0,false)
for i,x in ipairs({37.15,39.25}) do
 local basin=part(fixtures,"Basin_"..i,Vector3.new(1.45,.16,.88),CFrame.new(x,3.57,-11.35),C.white,Enum.Material.SmoothPlastic,0,false)
 basin.Shape=Enum.PartType.Cylinder;basin.CFrame=CFrame.new(x,3.57,-11.35)*CFrame.Angles(0,0,math.rad(90))
 part(fixtures,"Faucet_"..i,Vector3.new(.12,.55,.12),CFrame.new(x,3.86,-11.85),C.metal,Enum.Material.Metal,0,false)
end
local mirror=part(fixtures,"Mirror",Vector3.new(5.1,2.6,.10),CFrame.new(38.2,5.25,-9.48),Color3.fromRGB(110,124,132),Enum.Material.Glass,.12,false)
mirror.Reflectance=.22

-- Soft restroom ceiling panels.
for i,x in ipairs({38.0,43.0,48.0}) do
 local diffuser=part(detail,"RestroomCeilingLight_"..i,Vector3.new(2.7,.12,1.05),CFrame.new(x,10.38,-14.1),C.warm,Enum.Material.Glass,.28,false)
 surfaceLight(diffuser,.72,11,C.warm)
end

-- MAIN CLUB SOFT CEILING WASH -------------------------------------------------
local clubLights=Instance.new("Model");clubLights.Name="MainClubSoftLightingV1";clubLights.Parent=root
clubLights:SetAttribute("LightingIntent","SOFT_WARM_NEUTRAL")

-- Low-output architectural fixtures: enough facial/environment fill without flattening nightlife contrast.
local clubFixturePositions={
 {-18,3},{-5,3},{8,3},{21,3},{34,3},
 {-18,21},{-5,21},{8,21},{21,21},{34,21},
 {42,2},{42,18}, -- bar-side fill
}
for i,v in ipairs(clubFixturePositions) do
 local isBar=v[1]>=40
 local fixture=part(clubLights,"SoftCeilingFixture_"..i,Vector3.new(isBar and 2.8 or 3.2,.13,1.0),CFrame.new(v[1],17.35,v[2]),C.warm,Enum.Material.Glass,.32,false)
 fixture.CastShadow=false
 surfaceLight(fixture,isBar and .62 or .48,isBar and 16 or 14,C.warm)
end

print("[BBYA] Shared Restroom v1 + Main Club soft ceiling lighting online")