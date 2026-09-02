-- BBYA SOCIAL HUB — SHARED RESTROOM + MAIN CLUB SOFT LIGHTING v3
-- Premium tall shared restroom with full rear-footprint use and Zepeto-style avatar clearance.
-- Keeps one free Travel restroom for all venues; Main Club soft-light authority below is unchanged.

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
-- Same proven footprint/entrance as V2; premium V3 uses the full volume vertically and keeps the Travel landing clear.
local restroom=Instance.new("Model")
restroom.Name="SharedRestroomV1"
restroom:SetAttribute("BBYASharedAmenity","RESTROOM")
restroom:SetAttribute("LayoutVersion","V3_PREMIUM_TALL")
restroom:SetAttribute("RearSpaceUsed",true)
restroom:SetAttribute("RoomDepthStuds",21.6)
restroom:SetAttribute("PrivacyDivider",true)
restroom:SetAttribute("PremiumInterior",true)
restroom:SetAttribute("ZepetoClearance",true)
restroom:SetAttribute("ClearInteriorHeightStuds",12.1)
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

-- Tall shell: floor/footprint stay fixed while clear height grows from the V2 9.5-stud wall to 12.2 studs.
part(shell,"Floor",Vector3.new(16,.24,depth),CFrame.new(cx,1.02,cz),C.floor,Enum.Material.Slate,0,true)
part(shell,"Ceiling",Vector3.new(16,.35,depth),CFrame.new(cx,13.45,cz),C.dark,Enum.Material.Slate,0,false)
part(shell,"LeftWall",Vector3.new(.45,12.2,depth),CFrame.new(35.2,7.15,cz),C.wall,Enum.Material.Slate,0,true)
part(shell,"RightWall",Vector3.new(.45,12.2,depth),CFrame.new(50.8,7.15,cz),C.wall,Enum.Material.Slate,0,true)
part(shell,"BackWall",Vector3.new(16,12.2,.45),CFrame.new(cx,7.15,backZ),C.wall,Enum.Material.Slate,0,true)
-- Front wall retains the exact centered doorway and Travel approach, only increasing vertical clearance.
part(shell,"FrontWallL",Vector3.new(5.8,12.2,.45),CFrame.new(38.1,7.15,frontZ),C.wall,Enum.Material.Slate,0,true)
part(shell,"FrontWallR",Vector3.new(5.8,12.2,.45),CFrame.new(47.9,7.15,frontZ),C.wall,Enum.Material.Slate,0,true)
part(shell,"DoorHeader",Vector3.new(4.2,3.0,.45),CFrame.new(cx,11.75,frontZ),C.wall,Enum.Material.Slate,0,true)

-- Premium entrance: taller frame and layered sign without adding any world prompt.
part(detail,"EntryFrameL",Vector3.new(.22,9.2,.22),CFrame.new(40.92,5.65,-8.92),C.metal,Enum.Material.Metal,0,false)
part(detail,"EntryFrameR",Vector3.new(.22,9.2,.22),CFrame.new(45.08,5.65,-8.92),C.metal,Enum.Material.Metal,0,false)
local sign=part(detail,"RestroomSign",Vector3.new(4.7,1.25,.16),CFrame.new(cx,11.55,-8.94),C.dark,Enum.Material.Metal,0,false)
cornerSurfaceText(sign,Enum.NormalId.Back,"RESTROOM",C.white)
local subSign=part(detail,"RestroomSubSign",Vector3.new(3.4,.55,.12),CFrame.new(cx,10.55,-8.93),C.panel,Enum.Material.Metal,0,false)
cornerSurfaceText(subSign,Enum.NormalId.Back,"ALL GUESTS",C.cyan)
local signLine=part(detail,"RestroomSignAccent",Vector3.new(3.8,.07,.08),CFrame.new(cx,10.16,-8.84),C.cyan,Enum.Material.Neon,.18,false)
signLine.CastShadow=false

-- Dry-zone floor inlay visually separates the vanity/amenity area while preserving the clear landing at X=43/Z=-13.
part(detail,"DryZoneInlay",Vector3.new(5.7,.04,8.2),CFrame.new(38.35,1.16,-14.7),C.stone,Enum.Material.Marble,.28,false)

-- Two-basin premium vanity. Same efficient left-side footprint; mirror is now correctly aligned with the vanity.
part(fixtures,"VanityBase",Vector3.new(5.1,2.25,1.55),CFrame.new(38.2,2.18,-12.35),C.panel,Enum.Material.Metal,0,true)
part(fixtures,"VanityTop",Vector3.new(5.3,.24,1.72),CFrame.new(38.2,3.42,-12.35),C.stone,Enum.Material.Marble,0,false)
part(fixtures,"VanityBacksplash",Vector3.new(5.45,1.25,.12),CFrame.new(38.2,4.05,-13.17),C.stone,Enum.Material.Marble,0,false)
for i,x in ipairs({37.15,39.25}) do
 local basin=part(fixtures,"Basin_"..i,Vector3.new(1.45,.16,.88),CFrame.new(x,3.57,-12.35),C.white,Enum.Material.SmoothPlastic,0,false)
 basin.Shape=Enum.PartType.Cylinder;basin.CFrame=CFrame.new(x,3.57,-12.35)*CFrame.Angles(0,0,math.rad(90))
 part(fixtures,"Faucet_"..i,Vector3.new(.12,.55,.12),CFrame.new(x,3.86,-12.85),C.metal,Enum.Material.Metal,0,false)
end
part(detail,"MirrorFrame",Vector3.new(5.7,4.65,.08),CFrame.new(38.2,7.15,-13.32),C.metal,Enum.Material.Metal,0,false)
local mirror=part(fixtures,"Mirror",Vector3.new(5.35,4.25,.10),CFrame.new(38.2,7.15,-13.24),Color3.fromRGB(110,124,132),Enum.Material.Glass,.10,false)
mirror.Reflectance=.24
local mirrorTop=part(detail,"MirrorLightBar",Vector3.new(4.9,.12,.12),CFrame.new(38.2,9.45,-13.12),C.warm,Enum.Material.Neon,.12,false)
mirrorTop.CastShadow=false
part(detail,"MirrorAccentL",Vector3.new(.08,4.1,.08),CFrame.new(35.53,7.15,-13.10),C.cyan,Enum.Material.Neon,.32,false)
part(detail,"MirrorAccentR",Vector3.new(.08,4.1,.08),CFrame.new(40.87,7.15,-13.10),C.cyan,Enum.Material.Neon,.32,false)
part(detail,"VanityToeGlow",Vector3.new(4.5,.08,.08),CFrame.new(38.2,1.23,-11.54),C.cyan,Enum.Material.Neon,.40,false)

-- Right-side amenity wall uses the previously thin corridor edge without narrowing the main passage.
part(detail,"AmenityWallPanel",Vector3.new(.10,6.7,7.4),CFrame.new(50.50,5.15,-15.4),C.panel,Enum.Material.Metal,.05,false)
part(fixtures,"AmenityShelf",Vector3.new(.9,.18,3.6),CFrame.new(50.18,4.0,-14.6),C.metal,Enum.Material.Metal,0,false)
part(fixtures,"HandDryer",Vector3.new(.45,1.15,1.35),CFrame.new(50.32,5.35,-13.45),C.panel,Enum.Material.Metal,0,false)
part(fixtures,"TowelDispenser",Vector3.new(.42,1.25,1.45),CFrame.new(50.33,6.95,-15.55),C.panel,Enum.Material.Metal,0,false)
part(fixtures,"GroomingShelf",Vector3.new(.9,.16,2.6),CFrame.new(50.18,4.0,-18.25),C.metal,Enum.Material.Metal,0,false)
part(fixtures,"WasteBin",Vector3.new(1.15,1.75,1.15),CFrame.new(49.55,1.9,-16.9),C.dark,Enum.Material.Metal,0,true)
for i,z in ipairs({-17.5,-18.4,-19.3}) do
 part(fixtures,"WallHook_"..i,Vector3.new(.18,.36,.18),CFrame.new(50.38,6.2,z),C.metal,Enum.Material.Metal,0,false)
end

-- Tall privacy wall blocks the entrance-to-stall sightline while preserving the generous right-side passage.
part(shell,"PrivacyDivider",Vector3.new(10.4,9.2,.24),CFrame.new(40.4,5.6,-20.7),C.panel,Enum.Material.Slate,0,true)
part(detail,"PrivacyHeader",Vector3.new(10.4,.18,.30),CFrame.new(40.4,10.18,-20.7),C.metal,Enum.Material.Metal,0,false)
local privacyAccent=part(detail,"PrivacyAccent",Vector3.new(8.8,.08,.10),CFrame.new(40.4,10.05,-20.53),C.cyan,Enum.Material.Neon,.28,false)
privacyAccent.CastShadow=false

-- Three full-height premium stalls use the entire rear pocket; no floor area is added or stolen from another venue.
for _,x in ipairs({40.5,45.5}) do
 part(fixtures,"StallDivider_"..tostring(x),Vector3.new(.18,9.0,6.35),CFrame.new(x,5.6,-27.05),C.panel,Enum.Material.Metal,0,true)
end
for i,x in ipairs({38.0,43.0,48.0}) do
 part(fixtures,"StallDoor_"..i,Vector3.new(3.55,8.4,.14),CFrame.new(x,5.35,-23.85),C.panel,Enum.Material.Metal,.02,false)
 part(fixtures,"DoorGap_"..i,Vector3.new(.14,.14,.18),CFrame.new(x+1.35,8.75,-23.73),C.cyan,Enum.Material.Neon,.12,false)
 part(fixtures,"StallHandle_"..i,Vector3.new(.12,.48,.12),CFrame.new(x+1.25,4.55,-23.66),C.metal,Enum.Material.Metal,0,false)
 part(detail,"StallBackPanel_"..i,Vector3.new(4.6,5.2,.10),CFrame.new(x,5.15,-30.53),C.dark,Enum.Material.Slate,0,false)
 part(detail,"StallAccent_"..i,Vector3.new(3.4,.08,.08),CFrame.new(x,8.15,-30.42),C.cyan,Enum.Material.Neon,.38,false)
 part(fixtures,"ToiletBase_"..i,Vector3.new(1.55,.72,1.85),CFrame.new(x,1.55,-28.75),C.white,Enum.Material.SmoothPlastic,0,false)
 part(fixtures,"ToiletSeat_"..i,Vector3.new(1.72,.18,1.92),CFrame.new(x,2.00,-28.65),C.white,Enum.Material.SmoothPlastic,0,false)
 part(fixtures,"ToiletTank_"..i,Vector3.new(1.55,1.45,.58),CFrame.new(x,2.38,-29.62),C.white,Enum.Material.SmoothPlastic,0,false)
 part(fixtures,"PaperHolder_"..i,Vector3.new(.35,.35,.55),CFrame.new(x+1.62,3.05,-27.55),C.metal,Enum.Material.Metal,0,false)
end

-- Six diffusers move with the taller ceiling; soft output expands to cover the full premium volume evenly.
local restroomLights={
 {38.2,-14.2},{43.0,-14.2},{47.8,-14.2},
 {38.2,-25.7},{43.0,-25.7},{47.8,-25.7},
}
for i,v in ipairs(restroomLights) do
 local diffuser=part(detail,"RestroomCeilingLight_"..i,Vector3.new(2.45,.12,1.0),CFrame.new(v[1],13.18,v[2]),C.warm,Enum.Material.Glass,.25,false)
 surfaceLight(diffuser,.82,14,C.warm)
end
-- Thin cove accents make the taller walls read intentionally premium without becoming a nightclub light show.
part(detail,"CoveAccentL",Vector3.new(.08,.10,depth-2),CFrame.new(35.48,11.55,cz),C.cyan,Enum.Material.Neon,.48,false)
part(detail,"CoveAccentR",Vector3.new(.08,.10,depth-2),CFrame.new(50.52,11.55,cz),C.cyan,Enum.Material.Neon,.48,false)

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

print("[BBYA] Shared Restroom premium tall v3 + Main Club soft lighting v2 online")
