-- BBYA SOCIAL HUB — MAIN CLUB SOCIAL LOUNGE UPGRADE v1
-- Upgrades the two Arrival Lounge bays already created by ClubPurityMallStudiosV1
-- in the former Floor 1 Photo Studio + Salon footprint.
-- Reuses the existing MainClubFrontExtension architecture; does not stack a second floor/ceiling shell.
-- Open access. No VIP gate, global Lighting, audio, DJ, monetization, Mall, restroom, fishing or stage changes.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60)
if not root then return end

local purity=root:WaitForChild("ClubPurityMallStudiosV1",150)
if not purity then
 warn("[BBYA] Main Club Social Lounge upgrade: ClubPurityMallStudiosV1 unavailable")
 return
end
local extension=purity:WaitForChild("MainClubFrontExtension",30)
if not extension then
 warn("[BBYA] Main Club Social Lounge upgrade: MainClubFrontExtension unavailable")
 return
end

-- MainClubFrontExtension is parented before ClubPurity creates its two simple lounge bays.
-- Wait for both bays explicitly so the premium replacement cannot race and leave duplicates behind.
local arrival1=extension:WaitForChild("ArrivalLounge1",30)
local arrival2=extension:WaitForChild("ArrivalLounge2",30)
if not arrival1 or not arrival2 then
 warn("[BBYA] Main Club Social Lounge upgrade: legacy ArrivalLounge1/2 unavailable")
 return
end

local old=root:FindFirstChild("MainClubSocialLoungeV1")
if old then old:Destroy() end
arrival1:Destroy()
arrival2:Destroy()

local out=Instance.new("Model")
out.Name="MainClubSocialLoungeV1"
out:SetAttribute("Pass","MAIN_CLUB_SOCIAL_LOUNGE_UPGRADE_V1")
out:SetAttribute("Authority","CLUB_PURITY_MAIN_CLUB_FRONT_EXTENSION")
out:SetAttribute("FormerPhotoStudioLoungeUpgraded",true)
out:SetAttribute("FormerSalonLoungeUpgraded",true)
out:SetAttribute("ReplacedArrivalLounge1",true)
out:SetAttribute("ReplacedArrivalLounge2",true)
out:SetAttribute("WaitedForLegacyLounges",true)
out:SetAttribute("ReusedExistingArchitecture",true)
out:SetAttribute("OpenAccess",true)
out:SetAttribute("VIPGateAdded",false)
out:SetAttribute("MainClubSightlinePreserved",true)
out:SetAttribute("GlobalLightingUntouched",true)
out:SetAttribute("AudioUntouched",true)
out:SetAttribute("DJUntouched",true)
out:SetAttribute("MonetizationUntouched",true)
out.Parent=root

local C={
 black=Color3.fromRGB(8,8,10),ink=Color3.fromRGB(14,13,17),charcoal=Color3.fromRGB(25,23,28),
 graphite=Color3.fromRGB(43,40,46),fabric=Color3.fromRGB(48,39,49),fabric2=Color3.fromRGB(61,48,58),
 plum=Color3.fromRGB(79,49,69),taupe=Color3.fromRGB(92,75,79),brass=Color3.fromRGB(181,137,81),
 champagne=Color3.fromRGB(214,177,119),marble=Color3.fromRGB(124,118,128),smoked=Color3.fromRGB(78,88,99),
 warm=Color3.fromRGB(255,216,178),pink=Color3.fromRGB(243,53,151),cyan=Color3.fromRGB(35,191,216),
 green=Color3.fromRGB(64,88,70),white=Color3.fromRGB(240,237,242),
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
 local l=Instance.new("PointLight")
 l.Name="LoungeLocalWarmth";l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=parent;return l
end

local function surface(parent,color,brightness,range,angle)
 local l=Instance.new("SurfaceLight")
 l.Name="LoungeLocalWash";l.Face=Enum.NormalId.Bottom;l.Color=color;l.Brightness=brightness;l.Range=range;l.Angle=angle or 110;l.Shadows=false;l.Parent=parent;return l
end

local function textPlate(parent,name,size,cf,textValue,color)
 local plate=block(name,size,cf,C.black,Enum.Material.Glass,.08,parent,false)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.LightInfluence=.18;gui.PixelsPerStud=72;gui.Parent=plate
 local text=Instance.new("TextLabel")
 text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Text=textValue;text.TextColor3=color or C.white
 text.Font=Enum.Font.GothamBold;text.TextScaled=true;text.Parent=gui
 return plate
end

local function cocktailTable(parent,name,x,z,accent)
 local m=model(name,parent)
 cylinder("Foot",.14,2.25,CFrame.new(x,1.18,z),C.black,Enum.Material.Metal,0,m,false)
 cylinder("Stem",.98,.18,CFrame.new(x,1.70,z),C.brass,Enum.Material.Metal,0,m,false)
 local top=cylinder("StoneTop",.16,2.95,CFrame.new(x,2.25,z),C.marble,Enum.Material.Marble,0,m,false);top.Reflectance=.08
 local lamp=cylinder("TableLamp",.48,.68,CFrame.new(x,2.62,z),Color3.fromRGB(58,43,47),Enum.Material.Fabric,0,m,false)
 point(lamp,accent or C.warm,.28,6.2)
 cylinder("GlassA",.34,.27,CFrame.new(x-.58,2.47,z-.28),C.smoked,Enum.Material.Glass,.44,m,false)
 cylinder("GlassB",.34,.27,CFrame.new(x+.55,2.47,z+.20),C.smoked,Enum.Material.Glass,.44,m,false)
 cylinder("Bottle",.95,.28,CFrame.new(x+.10,2.80,z-.48)*CFrame.Angles(0,0,math.rad(8)),Color3.fromRGB(66,86,70),Enum.Material.Glass,.10,m,false)
end

local function loungeChair(parent,name,cf,accent)
 local m=model(name,parent)
 block("Base",Vector3.new(3.55,.46,3.45),cf*CFrame.new(0,.28,0),C.black,Enum.Material.Metal,0,m,false)
 block("Seat",Vector3.new(3.20,.70,3.08),cf*CFrame.new(0,.76,0),accent or C.taupe,Enum.Material.Fabric,0,m,true)
 block("Back",Vector3.new(3.18,2.45,.64),cf*CFrame.new(0,1.73,1.22)*CFrame.Angles(math.rad(-6),0,0),accent or C.taupe,Enum.Material.Fabric,0,m,false)
 block("ArmL",Vector3.new(.48,1.28,2.88),cf*CFrame.new(-1.61,1.13,0),C.fabric2,Enum.Material.Fabric,0,m,false)
 block("ArmR",Vector3.new(.48,1.28,2.88),cf*CFrame.new(1.61,1.13,0),C.fabric2,Enum.Material.Fabric,0,m,false)
 block("Cushion",Vector3.new(1.18,.30,1.12),cf*CFrame.new(.48,1.22,.42)*CFrame.Angles(math.rad(-18),math.rad(10),math.rad(8)),C.plum,Enum.Material.Fabric,0,m,false)
end

local function planter(parent,name,x,z)
 local m=model(name,parent)
 cylinder("Pot",1.35,1.90,CFrame.new(x,1.78,z),C.charcoal,Enum.Material.Slate,0,m,false)
 block("Stem",Vector3.new(.18,2.8,.18),CFrame.new(x,3.35,z),C.green,Enum.Material.SmoothPlastic,0,m,false)
 for i=1,5 do
  local a=math.rad((i-1)*72)
  block("Leaf"..i,Vector3.new(.13,1.55,.50),CFrame.new(x+math.cos(a)*.55,4.18,z+math.sin(a)*.55)*CFrame.Angles(math.rad(18),-a,0),C.green,Enum.Material.SmoothPlastic,0,m,false)
 end
end

local function premiumBay(index,z,accent,seatColor)
 local bay=model("PremiumLoungeBay"..index,out)
 bay:SetAttribute("FormerStudioBay",index==1 and "PHOTO" or "SALON")
 bay:SetAttribute("OpenToMainClub",true)

 local rug=block("Rug",Vector3.new(12.8,.055,9.2),CFrame.new(-39.1,1.13,z),Color3.fromRGB(31,28,34),Enum.Material.Fabric,0,bay,false)
 rug.Reflectance=0

 block("BanquettePlinth",Vector3.new(3.95,.38,8.65),CFrame.new(-44.25,1.31,z),C.black,Enum.Material.Metal,0,bay,false)
 for n=1,3 do
  local zz=z-2.55+(n-1)*2.55
  block("Seat"..n,Vector3.new(3.45,.72,2.28),CFrame.new(-43.82,1.78,zz),n==2 and seatColor or C.fabric,Enum.Material.Fabric,0,bay,true)
  block("Back"..n,Vector3.new(.66,2.55,2.20),CFrame.new(-45.52,2.82,zz)*CFrame.Angles(0,0,math.rad(-5)),n==2 and seatColor or C.fabric2,Enum.Material.Fabric,0,bay,false)
  if n~=2 then
   block("Throw"..n,Vector3.new(.34,1.00,.92),CFrame.new(-43.55,2.20,zz+.35)*CFrame.Angles(math.rad(3),0,math.rad(n==1 and -12 or 12)),accent,Enum.Material.Fabric,0,bay,false)
  end
 end

 cocktailTable(bay,"CocktailTable",-37.3,z,accent)

 local chairZ=z+(index==1 and -3.65 or 3.65)
 local yaw=index==1 and -62 or -118
 loungeChair(bay,"ClubChair",CFrame.new(-32.25,1.10,chairZ)*CFrame.Angles(0,math.rad(yaw),0),C.taupe)

 local divider=block("SmokedDivider",Vector3.new(.10,2.15,6.55),CFrame.new(-29.45,2.25,z),C.smoked,Enum.Material.Glass,.72,bay,false)
 divider.Reflectance=.08
 block("DividerCap",Vector3.new(.14,.08,6.55),CFrame.new(-29.45,3.36,z),C.champagne,Enum.Material.Metal,0,bay,false)

 planter(bay,"Planter",-47.35,z+3.70)

 block("PendantStem",Vector3.new(.06,1.75,.06),CFrame.new(-38.8,11.55,z),C.brass,Enum.Material.Metal,0,bay,false)
 cylinder("PendantShade",.42,.78,CFrame.new(-38.8,10.55,z),C.black,Enum.Material.Metal,0,bay,false)
 local bulb=block("PendantBulb",Vector3.new(.25,.18,.25),CFrame.new(-38.8,10.26,z),C.warm,Enum.Material.Neon,.28,bay,false)
 bulb.CastShadow=false;point(bulb,C.warm,.31,7.8)

 local wash=block("LocalWash",Vector3.new(5.8,.035,.42),CFrame.new(-41.2,11.92,z),C.warm,Enum.Material.Neon,.82,bay,false)
 wash.CastShadow=false;surface(wash,C.warm,.18,8.5,105)
end

premiumBay(1,-27.0,C.warm,C.taupe)
premiumBay(2,-13.0,C.pink,C.plum)

local floor=extension:FindFirstChild("FrontClubFloor")
if floor and floor:IsA("BasePart") then
 floor.Color=Color3.fromRGB(24,23,28)
 floor.Material=Enum.Material.SmoothPlastic
 floor.Reflectance=.07
end

textPlate(out,"SocialLoungeMark",Vector3.new(.10,1.35,7.2),CFrame.new(-49.42,8.05,-14.5)*CFrame.Angles(0,math.rad(90),0),"BBYA  SOCIAL  LOUNGE",C.champagne)
block("LoungeConnectorInlay",Vector3.new(8.8,.035,.055),CFrame.new(-39.0,1.135,-20.0),C.champagne,Enum.Material.Metal,0,out,false)

print("[BBYA] Main Club Social Lounge Upgrade v1 online: waited for ClubPurity ArrivalLounge1/2, then replaced both with premium former-studio lounge bays")
