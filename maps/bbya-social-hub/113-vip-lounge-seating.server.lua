-- BBYA SOCIAL HUB — VIP LOUNGE SEATING v1
-- Two black upholstered L-sofa corners + low black square tables.
-- Late VIP-only pass: preserves rail, floor neon, audio and circulation.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
if not upper then return end
local vip=upper:WaitForChild("L2_VIP_Level",30)
if not vip then return end
local active=vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end

-- Wait for the late architectural VIP pass so furniture always wins last.
active:WaitForChild("VIPPrivateClubUpgradeV2",30)

local old=active:FindFirstChild("VIPLoungeSeatingV1")
if old then old:Destroy() end

local out=Instance.new("Model")
out.Name="VIPLoungeSeatingV1"
out:SetAttribute("Pass","VIP_LOUNGE_SEATING_V1")
out:SetAttribute("LoungeSetCount",2)
out:SetAttribute("Layout","TWO_REAR_L_CORNERS")
out:SetAttribute("RoundedCushions",true)
out:SetAttribute("MainCirculationPreserved",true)
out.Parent=active

local C={
 black=Color3.fromRGB(10,10,12),
 fabric=Color3.fromRGB(20,20,24),
 fabric2=Color3.fromRGB(27,27,32),
 graphite=Color3.fromRGB(34,35,40),
 metal=Color3.fromRGB(52,53,58),
 glass=Color3.fromRGB(16,17,20),
}

local function model(name,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent or out;return m
end

local function block(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.black;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=false
 p.CastShadow=transparency~=1;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out
 return p
end

-- Ellipsoid visuals avoid a boxy/Minecraft sofa silhouette.
local function softEllipsoid(name,scale,cf,color,parent)
 local p=block(name,Vector3.new(1,1,1),cf,color or C.fabric,Enum.Material.Fabric,0,false,parent)
 local mesh=Instance.new("SpecialMesh")
 mesh.MeshType=Enum.MeshType.Sphere
 mesh.Scale=scale
 mesh.Parent=p
 return p
end

local function seatBase(name,cf,parent)
 local s=Instance.new("Seat")
 s.Name=name;s.Size=Vector3.new(4.1,.55,3.4);s.CFrame=cf;s.Transparency=1;s.Anchored=true
 s.CanCollide=true;s.CanTouch=true;s.CanQuery=false;s.CastShadow=false;s.Parent=parent
 return s
end

local function makeTable(parent,x,z)
 local t=model("LowSquareTable",parent)
 block("Top",Vector3.new(5.4,.34,5.4),CFrame.new(x,26.22,z),C.glass,Enum.Material.Glass,.08,true,t).Reflectance=.09
 block("UnderTop",Vector3.new(4.8,.20,4.8),CFrame.new(x,26.00,z),C.black,Enum.Material.Metal,0,false,t)
 block("Pedestal",Vector3.new(1.15,1.05,1.15),CFrame.new(x,25.45,z),C.black,Enum.Material.Metal,0,true,t)
 block("Foot",Vector3.new(3.1,.18,3.1),CFrame.new(x,25.03,z),C.metal,Enum.Material.Metal,0,false,t)
 return t
end

local function backCushion(parent,name,pos,yaw)
 local cf=CFrame.new(pos)*CFrame.Angles(math.rad(-7),math.rad(yaw),0)
 return softEllipsoid(name,Vector3.new(4.25,2.45,1.05),cf,C.fabric2,parent)
end

local function seatCushion(parent,name,pos,yaw,index)
 local cf=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)
 softEllipsoid(name,Vector3.new(4.2,1.38,3.65),cf,(index%2==0) and C.fabric2 or C.fabric,parent)
 seatBase(name.."Seat",cf*CFrame.new(0,-.34,0),parent)
end

local function arm(parent,name,pos,yaw)
 softEllipsoid(name,Vector3.new(1.25,1.85,3.7),CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0),C.fabric2,parent)
end

local function buildLounge(name,side)
 -- side = -1 left / +1 right. Both sets hug the rear wall; return hugs the outer side wall.
 local lounge=model(name,out)
 local cx=side*41.0
 local outerX=side*52.2
 local rearZ=40.2

 -- recessed black plinth anchors the upholstery visually without reading as a block sofa.
 block("RearPlinth",Vector3.new(18.8,.62,4.4),CFrame.new(cx,25.24,rearZ),C.black,Enum.Material.Metal,0,true,lounge)
 block("ReturnPlinth",Vector3.new(4.4,.62,11.2),CFrame.new(outerX,25.24,34.8),C.black,Enum.Material.Metal,0,true,lounge)

 -- four soft rear seats, individually separated so the sofa reads upholstered.
 for i=1,4 do
  local x=cx-6.6+(i-1)*4.4
  seatCushion(lounge,"RearSeat"..i,Vector3.new(x,26.00,rearZ-.20),0,i)
  backCushion(lounge,"RearBack"..i,Vector3.new(x,27.65,rearZ+2.15),0)
 end

 -- two-seat return creates the L shape against the side wall.
 for i=1,2 do
  local z=31.8+(i-1)*4.3
  seatCushion(lounge,"ReturnSeat"..i,Vector3.new(outerX-side*.05,26.00,z),90,i)
  local backX=outerX+side*2.15
  backCushion(lounge,"ReturnBack"..i,Vector3.new(backX,27.65,z),90)
 end

 -- soft terminal arms, not square end caps.
 arm(lounge,"InnerArm",Vector3.new(cx-side*9.15,26.55,rearZ-.15),0)
 arm(lounge,"ReturnArm",Vector3.new(outerX,26.55,29.45),90)

 -- two small loose cushions add softness without visual clutter.
 softEllipsoid("LoosePillowA",Vector3.new(2.05,1.65,.72),CFrame.new(cx-side*2.8,27.25,rearZ+1.25)*CFrame.Angles(0,math.rad(side*12),math.rad(side*7)),C.fabric2,lounge)
 softEllipsoid("LoosePillowB",Vector3.new(1.85,1.55,.68),CFrame.new(outerX-side*.35,27.22,35.9)*CFrame.Angles(math.rad(-4),math.rad(90),math.rad(-side*8)),C.fabric,lounge)

 -- table sits in front but leaves a clear path between lounge and inner safety rail.
 makeTable(lounge,side*41.0,31.0)
 lounge:SetAttribute("SeatCount",6)
 lounge:SetAttribute("WallHugging",true)
 return lounge
end

buildLounge("LeftCornerLounge",-1)
buildLounge("RightCornerLounge",1)

active:SetAttribute("StandingOnly",false)
active:SetAttribute("VIPFurnitureMode","TWO_L_SOFA_LOUNGES")
active:SetAttribute("VIPLoungeSeatCount",12)
active:SetAttribute("VIPLoungeTableCount",2)
out:SetAttribute("SeatCount",12)
out:SetAttribute("TableCount",2)

print("[BBYA] VIP Lounge Seating v1 online: 2 rounded black L-sofas / 12 seats / 2 low square tables")
