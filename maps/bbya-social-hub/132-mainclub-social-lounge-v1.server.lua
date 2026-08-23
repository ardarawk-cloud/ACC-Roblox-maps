-- BBYA SOCIAL HUB — MAIN CLUB SOCIAL LOUNGE v1
-- Converts the former Floor 1 Photo Studio + Salon footprints into one connected premium social lounge.
-- Open access / Main Club hospitality only. Does not recreate the old studio functions.
-- No global Lighting, audio, DJ, monetization, VIP, Mall, restroom, fishing or stage changes.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local floor1=root:WaitForChild("Floor1Core",30)
local front=root:WaitForChild("Floor1FrontPremium",30)
local realism=root:WaitForChild("MainClubRealism",30)
if not floor1 or not front or not realism then
 warn("[BBYA] Main Club Social Lounge v1 prerequisites unavailable")
 return
end

local old=root:FindFirstChild("MainClubSocialLoungeV1")
if old then old:Destroy() end

for _,name in ipairs({"PhotoAreaPremium","SalonLookStudioPremium"}) do
 local stale=front:FindFirstChild(name,true)
 if stale then stale:Destroy() end
end

local out=Instance.new("Model")
out.Name="MainClubSocialLoungeV1"
out:SetAttribute("Pass","MAIN_CLUB_SOCIAL_LOUNGE_V1")
out:SetAttribute("Scope","FORMER_PHOTO_AND_SALON_FOOTPRINTS")
out:SetAttribute("FormerPhotoStudioConverted",true)
out:SetAttribute("FormerSalonConverted",true)
out:SetAttribute("OpenAccess",true)
out:SetAttribute("VIPGateAdded",false)
out:SetAttribute("MainClubSightlinePreserved",true)
out:SetAttribute("GlobalLightingUntouched",true)
out:SetAttribute("AudioUntouched",true)
out:SetAttribute("DJUntouched",true)
out:SetAttribute("MonetizationUntouched",true)
out.Parent=root

local C={
 black=Color3.fromRGB(8,8,10),ink=Color3.fromRGB(14,13,17),charcoal=Color3.fromRGB(24,23,28),
 graphite=Color3.fromRGB(42,40,46),fabric=Color3.fromRGB(48,39,49),plum=Color3.fromRGB(76,48,67),
 taupe=Color3.fromRGB(93,76,78),brass=Color3.fromRGB(181,137,81),champagne=Color3.fromRGB(214,177,119),
 marble=Color3.fromRGB(126,120,129),smoked=Color3.fromRGB(73,83,94),warm=Color3.fromRGB(255,216,178),
 pink=Color3.fromRGB(243,53,151),cyan=Color3.fromRGB(35,191,216),green=Color3.fromRGB(65,91,70),white=Color3.fromRGB(239,236,241),
}

local function model(name,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m
end

local function block(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true
 p.CastShadow=material~=Enum.Material.Neon;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out;return p
end

local function cylinder(name,height,diameter,cf,color,material,transparency,parent,collide)
 local p=block(name,Vector3.new(height,diameter,diameter),cf*CFrame.Angles(0,0,math.rad(90)),color,material,transparency,parent,collide)
 p.Shape=Enum.PartType.Cylinder;return p
end

local function point(parent,color,brightness,range)
 local l=Instance.new("PointLight");l.Name="LoungeLocalWarmth";l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=parent;return l
end

local function surface(parent,color,brightness,range,angle)
 local l=Instance.new("SurfaceLight");l.Name="LoungeLocalWash";l.Face=Enum.NormalId.Bottom;l.Color=color;l.Brightness=brightness;l.Range=range;l.Angle=angle or 110;l.Shadows=false;l.Parent=parent;return l
end

local function textPlate(parent,name,size,cf,textValue,color)
 local plate=block(name,size,cf,C.black,Enum.Material.Glass,.08,parent,false)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.LightInfluence=.2;gui.PixelsPerStud=70;gui.Parent=plate
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text=textValue;text.TextColor3=color or C.white
 text.Font=Enum.Font.GothamBold;text.TextScaled=true;text.Parent=gui
 return plate
end

local function lowTable(parent,name,x,z,accent)
 local m=model(name,parent)
 cylinder("Foot",.16,2.45,CFrame.new(x,1.12,z),C.black,Enum.Material.Metal,0,m,false)
 cylinder("Stem",.95,.20,CFrame.new(x,1.63,z),C.brass,Enum.Material.Metal,0,m,false)
 local top=cylinder("Top",.16,3.05,CFrame.new(x,2.18,z),C.marble,Enum.Material.Marble,0,m,false);top.Reflectance=.08
 local lamp=cylinder("Lamp",.50,.66,CFrame.new(x,2.58,z),Color3.fromRGB(58,43,47),Enum.Material.Fabric,0,m,false);point(lamp,accent or C.warm,.27,6.5)
 cylinder("GlassA",.36,.28,CFrame.new(x-.62,2.40,z-.26),C.smoked,Enum.Material.Glass,.45,m,false)
 cylinder("GlassB",.36,.28,CFrame.new(x+.58,2.40,z+.18),C.smoked,Enum.Material.Glass,.45,m,false)
end

local function loungeChair(parent,name,cf,accent)
 local m=model(name,parent)
 block("Base",Vector3.new(3.7,.46,3.6),cf*CFrame.new(0,.32,0),C.black,Enum.Material.Metal,0,m,false)
 block("Seat",Vector3.new(3.35,.70,3.25),cf*CFrame.new(0,.82,0),accent or C.fabric,Enum.Material.Fabric,0,m,true)
 block("Back",Vector3.new(3.35,2.65,.66),cf*CFrame.new(0,1.82,1.30)*CFrame.Angles(math.rad(-6),0,0),accent or C.fabric,Enum.Material.Fabric,0,m,false)
 block("ArmL",Vector3.new(.52,1.40,3.05),cf*CFrame.new(-1.68,1.22,0),C.taupe,Enum.Material.Fabric,0,m,false)
 block("ArmR",Vector3.new(.52,1.40,3.05),cf*CFrame.new(1.68,1.22,0),C.taupe,Enum.Material.Fabric,0,m,false)
end

local function planter(parent,name,x,z)
 local m=model(name,parent)
 cylinder("Pot",1.45,2.0,CFrame.new(x,1.35,z),C.charcoal,Enum.Material.Slate,0,m,false)
 block("Stem",Vector3.new(.20,3.2,.20),CFrame.new(x,3.15,z),C.green,Enum.Material.SmoothPlastic,0,m,false)
 for i=1,5 do
  local a=math.rad((i-1)*72)
  block("Leaf"..i,Vector3.new(.14,1.75,.56),CFrame.new(x+math.cos(a)*.60,4.15,z+math.sin(a)*.60)*CFrame.Angles(math.rad(18),-a,0),C.green,Enum.Material.SmoothPlastic,0,m,false)
 end
end

-- ZONE A — former Photo Studio: intimate arrival lounge.
local photoLounge=model("FormerPhotoLounge",out)
local photoFloor=block("LoungeRug",Vector3.new(20,.08,15.5),CFrame.new(-39.0,1.04,-25.0),Color3.fromRGB(32,29,35),Enum.Material.Fabric,0,photoLounge,false);photoFloor.Reflectance=0
block("Backdrop",Vector3.new(.42,8.8,15.8),CFrame.new(-50.0,5.55,-25.0),C.ink,Enum.Material.Slate,0,photoLounge,false)
for i,z in ipairs({-31.0,-28.0,-25.0,-22.0,-19.0}) do
 block("WallSlat"..i,Vector3.new(.10,6.2,.22),CFrame.new(-49.72,5.4,z),i==3 and C.champagne or C.brass,Enum.Material.Metal,0,photoLounge,false)
end
textPlate(photoLounge,"LoungeMark",Vector3.new(.10,1.45,6.0),CFrame.new(-49.62,7.2,-25)*CFrame.Angles(0,math.rad(90),0),"BBYA  LOUNGE",C.white)

local sofaA=model("SofaWest",photoLounge)
block("Plinth",Vector3.new(3.9,.40,10.3),CFrame.new(-45.2,1.20,-25),C.black,Enum.Material.Metal,0,sofaA,false)
for i,z in ipairs({-28.2,-25.0,-21.8}) do
 block("Seat"..i,Vector3.new(3.35,.72,2.75),CFrame.new(-44.7,1.72,z),i==2 and C.plum or C.fabric,Enum.Material.Fabric,0,sofaA,true)
 block("Back"..i,Vector3.new(.66,2.55,2.70),CFrame.new(-46.35,2.82,z)*CFrame.Angles(0,0,math.rad(-5)),i==2 and Color3.fromRGB(86,56,75) or C.fabric,Enum.Material.Fabric,0,sofaA,false)
end
loungeChair(photoLounge,"ChairNorth",CFrame.new(-34.7,1.08,-29.4)*CFrame.Angles(0,math.rad(-58),0),C.taupe)
loungeChair(photoLounge,"ChairSouth",CFrame.new(-34.7,1.08,-20.6)*CFrame.Angles(0,math.rad(-122),0),C.taupe)
lowTable(photoLounge,"ConversationTable",-38.3,-25,C.warm)
planter(photoLounge,"PlanterNorth",-47.0,-32.1);planter(photoLounge,"PlanterSouth",-47.0,-17.9)
block("CeilingRaft",Vector3.new(17.5,.26,11.5),CFrame.new(-39.0,11.6,-25),C.charcoal,Enum.Material.Fabric,0,photoLounge,false)
for i,z in ipairs({-29,-25,-21}) do
 local strip=block("CeilingGlow"..i,Vector3.new(12.0,.035,.38),CFrame.new(-39.0,11.43,z),C.warm,Enum.Material.Neon,.72,photoLounge,false);strip.CastShadow=false;surface(strip,C.warm,.25,10,110)
end
block("GlassDivider",Vector3.new(.10,3.0,12.0),CFrame.new(-28.6,2.55,-25.0),C.smoked,Enum.Material.Glass,.64,photoLounge,false)
block("GlassCap",Vector3.new(.14,.10,12.0),CFrame.new(-28.6,4.10,-25.0),C.champagne,Enum.Material.Metal,0,photoLounge,false)

-- ZONE B — former Salon: long social lounge facing the Main Club.
local salonLounge=model("FormerSalonLounge",out)
block("LoungeFloorInset",Vector3.new(22,.08,19),CFrame.new(-38.5,1.04,-3.5),Color3.fromRGB(31,29,34),Enum.Material.SmoothPlastic,0,salonLounge,false)
block("WallPanel",Vector3.new(.46,8.0,19.0),CFrame.new(-49.2,5.2,-3.5),C.ink,Enum.Material.Slate,0,salonLounge,false)
block("BrassDatum",Vector3.new(.08,.08,17.0),CFrame.new(-48.92,8.75,-3.5),C.brass,Enum.Material.Metal,0,salonLounge,false)
local banquette=model("LongBanquette",salonLounge)
block("SeatBase",Vector3.new(4.3,.48,16.5),CFrame.new(-45.4,1.25,-3.5),C.black,Enum.Material.Metal,0,banquette,false)
for i,z in ipairs({-9.0,-5.35,-1.70,1.95}) do
 block("Seat"..i,Vector3.new(3.65,.72,3.25),CFrame.new(-44.9,1.73,z),(i%2==0) and C.plum or C.fabric,Enum.Material.Fabric,0,banquette,true)
 block("Back"..i,Vector3.new(.68,2.60,3.18),CFrame.new(-46.65,2.85,z)*CFrame.Angles(0,0,math.rad(-5)),(i%2==0) and Color3.fromRGB(83,54,73) or C.fabric,Enum.Material.Fabric,0,banquette,false)
end
lowTable(salonLounge,"SocialTableA",-37.0,-7.2,C.pink);lowTable(salonLounge,"SocialTableB",-37.0,1.0,C.cyan)
loungeChair(salonLounge,"ClubChairA",CFrame.new(-31.8,1.08,-9.5)*CFrame.Angles(0,math.rad(-72),0),C.taupe)
loungeChair(salonLounge,"ClubChairB",CFrame.new(-31.8,1.08,3.2)*CFrame.Angles(0,math.rad(-108),0),C.taupe)
for i,z in ipairs({-8.4,-3.3,1.8}) do
 local glass=block("DanceEdgeGlass"..i,Vector3.new(.10,2.45,4.2),CFrame.new(-27.8,2.30,z),C.smoked,Enum.Material.Glass,.70,salonLounge,false);glass.Reflectance=.08
 block("DanceEdgeCap"..i,Vector3.new(.14,.08,4.2),CFrame.new(-27.8,3.58,z),C.champagne,Enum.Material.Metal,0,salonLounge,false)
end
for i,z in ipairs({-8.0,-2.5,3.0}) do
 block("PendantStem"..i,Vector3.new(.06,1.55,.06),CFrame.new(-39.0,11.7,z),C.brass,Enum.Material.Metal,0,salonLounge,false)
 cylinder("Pendant"..i,.40,.74,CFrame.new(-39.0,10.82,z),C.black,Enum.Material.Metal,0,salonLounge,false)
 local bulb=block("PendantBulb"..i,Vector3.new(.24,.18,.24),CFrame.new(-39.0,10.55,z),C.warm,Enum.Material.Neon,.26,salonLounge,false);bulb.CastShadow=false;point(bulb,C.warm,.30,7.5)
end
local marker=textPlate(out,"SocialLoungeMarker",Vector3.new(7.0,1.15,.10),CFrame.new(-38.5,7.7,-14.2),"SOCIAL  LOUNGE",C.champagne);marker:SetAttribute("FormerStudioConnector",true)

print("[BBYA] Main Club Social Lounge v1 online: former Photo Studio + Salon converted into connected premium open-access lounge")
