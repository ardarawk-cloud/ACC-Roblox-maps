-- BBYA SOCIAL HUB — CLUB LOUNGE MATCH v1
-- Replaces the former Salon/Photo footprint with a direct continuation
-- of the existing Main Club left-side banquette language.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",60)
if not root then return end

local authority=root:WaitForChild("MainClubFinalAuthorityV2",60)
local luxury=root:WaitForChild("Floor1LuxuryFinish",60)
if not authority or not luxury then
 warn("[BBYA Club Lounge Match] prerequisites unavailable")
 return
end

-- Remove the custom v380 extension so there is only one visual language here.
local legacy=authority:FindFirstChild("PureClubFrontExtension")
if legacy then legacy:Destroy() end
local old=root:FindFirstChild("ClubLoungeMatchV1")
if old then old:Destroy() end

local out=Instance.new("Model")
out.Name="ClubLoungeMatchV1"
out:SetAttribute("Pass","CLUB_LOUNGE_MATCH_V1")
out:SetAttribute("MatchesExistingLeftVIP",true)
out:SetAttribute("FormerStudioArea",true)
out.Parent=root

authority:SetAttribute("FrontExtensionMatched",true)

local C={
 black=Color3.fromRGB(8,8,10),ink=Color3.fromRGB(14,13,17),charcoal=Color3.fromRGB(25,23,28),
 graphite=Color3.fromRGB(42,39,45),bronze=Color3.fromRGB(142,103,68),brass=Color3.fromRGB(184,139,84),
 stone=Color3.fromRGB(91,86,93),marble=Color3.fromRGB(132,126,134),fabric=Color3.fromRGB(39,34,41),
 plum=Color3.fromRGB(67,47,63),glass=Color3.fromRGB(80,87,96),warm=Color3.fromRGB(255,204,157),
}

local function part(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true
 p.CastShadow=material~=Enum.Material.Neon;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent or out
 return p
end
local function cylinder(name,size,cf,color,material,transparency,parent,collide)
 local p=part(name,size,cf,color,material,transparency,parent,collide);p.Shape=Enum.PartType.Cylinder;return p
end
local function model(name,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m end
local function point(parent,color,brightness,range)
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=parent;return l
end

-- Same polished floor / ceiling tone as Main Club, continuing into the retired studio footprint.
local shell=model("MatchedClubShell",out)
local floor=part("ClubFloorContinuation",Vector3.new(25,.16,42),CFrame.new(-39,1.02,-14.5),Color3.fromRGB(22,22,27),Enum.Material.SmoothPlastic,0,shell,true)
floor.Reflectance=.08
part("CeilingContinuation",Vector3.new(24,.42,40),CFrame.new(-39,13.0,-14.5),C.ink,Enum.Material.Slate,0,shell,false)
part("FloorBrassDatum",Vector3.new(.07,.035,39.5),CFrame.new(-26.65,1.115,-14.5),C.brass,Enum.Material.Metal,0,shell,false)
-- Continue the same bronze datum from the existing left wall.
part("LeftBronzeDatumContinuation",Vector3.new(.07,.10,28),CFrame.new(-48.92,11.05,-20),C.brass,Enum.Material.Metal,0,shell,false)

-- Continue the same recessed warm wall coves used in Main Club refinement.
for i,z in ipairs({-31,-18}) do
 part("LeftCoveRecess"..i,Vector3.new(.42,5.6,8.2),CFrame.new(-49.25,8.0,z),C.ink,Enum.Material.Slate,0,shell,false)
 local glow=part("LeftCoveLight"..i,Vector3.new(.08,4.8,6.9),CFrame.new(-49.00,8.0,z),C.warm,Enum.Material.Neon,.35,shell,false)
 point(glow,C.warm,.14,7)
end

local function cocktailTable(parent,name,x,z,diameter)
 local m=model(name,parent)
 cylinder("Foot",Vector3.new(.14,diameter*.58,diameter*.58),CFrame.new(x,.22,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,m,false)
 cylinder("Stem",Vector3.new(1.15,.20,.20),CFrame.new(x,.92,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,m,false)
 local top=cylinder("StoneTop",Vector3.new(.18,diameter,diameter),CFrame.new(x,1.58,z)*CFrame.Angles(0,0,math.rad(90)),C.marble,Enum.Material.Marble,0,m,false)
 top.Reflectance=.08
 local lamp=cylinder("TableLamp",Vector3.new(.48,.70,.70),CFrame.new(x,2.02,z)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(56,43,43),Enum.Material.Fabric,0,m,false)
 point(lamp,C.warm,.30,6)
end

-- Exact continuation of the existing BuiltInVIP banquette proportions/materials.
local function matchingBanquette(index,z)
 local m=model("BuiltInVIPContinuation"..index,out)
 part("Plinth",Vector3.new(13.8,.28,10.6),CFrame.new(-39.0,1.03,z),Color3.fromRGB(28,26,31),Enum.Material.Slate,0,m,true)
 part("WallPanel",Vector3.new(.48,7.2,9.0),CFrame.new(-48.0,5.0,z),C.ink,Enum.Material.Slate,0,m,false)
 part("BronzeReveal",Vector3.new(.08,5.5,7.7),CFrame.new(-47.72,5.0,z),C.bronze,Enum.Material.Metal,0,m,false)
 part("SeatBase",Vector3.new(4.2,.54,7.3),CFrame.new(-44.55,1.22,z),C.black,Enum.Material.Metal,0,m,false)
 for n=1,3 do
  local zz=z-2.35+(n-1)*2.35
  part("SeatCushion"..n,Vector3.new(3.65,.72,2.12),CFrame.new(-44.15,1.72,zz),index==2 and C.plum or C.fabric,Enum.Material.Fabric,0,m,true)
  part("BackCushion"..n,Vector3.new(.72,2.65,2.05),CFrame.new(-46.15,2.90,zz)*CFrame.Angles(0,0,math.rad(-5)),index==2 and Color3.fromRGB(76,54,70) or Color3.fromRGB(50,43,51),Enum.Material.Fabric,0,m,false)
 end
 part("Divider",Vector3.new(.12,2.15,8.0),CFrame.new(-32.8,2.12,z),C.glass,Enum.Material.Glass,.52,m,false)
 part("DividerCap",Vector3.new(.18,.12,8.0),CFrame.new(-32.8,3.23,z),C.brass,Enum.Material.Metal,0,m,false)
 cocktailTable(m,"LowTable",-37.4,z,3.2)
end

-- Existing Main Club bays are 0 / 14 / 28. Continue the rhythm backwards at -14 / -28.
matchingBanquette(1,-28)
matchingBanquette(2,-14)

print("[BBYA] Club Lounge Match v1 online: former Salon/Photo area now matches existing Main Club banquettes")
