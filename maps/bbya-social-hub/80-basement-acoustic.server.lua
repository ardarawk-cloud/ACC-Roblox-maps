-- BBYA SOCIAL HUB — BASEMENT ACOUSTIC TREATMENT v3
-- Double-skin acoustic wall treatment + ceiling baffles for a sealed underground-club feel.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local basement=root:WaitForChild("Underground",30)
if not basement then return end
task.wait(.35)

local old=basement:FindFirstChild("AcousticTreatmentV3")
if old then old:Destroy() end
local out=Instance.new("Model");out.Name="AcousticTreatmentV3";out.Parent=basement
out:SetAttribute("DoubleSkinWalls",true)
out:SetAttribute("CeilingBaffles",true)
out:SetAttribute("ZoneAudioProfile","UNDERGROUND")

local C={panel=Color3.fromRGB(17,19,23),panel2=Color3.fromRGB(28,31,36),metal=Color3.fromRGB(58,62,69),white=Color3.fromRGB(224,225,220),blue=Color3.fromRGB(0,144,255),yellow=Color3.fromRGB(255,205,38)}
local function part(name,size,cf,color,mat,collide,parent)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.panel;p.Material=mat or Enum.Material.Fabric;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or out;return p
end

local panels=Instance.new("Model");panels.Name="AcousticWallPanels";panels.Parent=out
local function wallPanel(name,cf,size,index)
 local p=part(name,size,cf,(index%2==0) and C.panel or C.panel2,Enum.Material.Fabric,false,panels)
 p.Reflectance=0
 local trim=part(name.."Trim",Vector3.new(size.X+.15,size.Y+.15,.08),cf*CFrame.new(0,0,-size.Z/2-.05),C.metal,Enum.Material.Metal,false,panels)
 trim.Transparency=.1
end

-- North / south acoustic skins, mounted inside the concrete shell.
for i=-5,5 do
 local x=i*10
 wallPanel("NorthPanel"..i,CFrame.new(x,-7.6,42.86),Vector3.new(9.25,10.8,.42),i)
 wallPanel("SouthPanel"..i,CFrame.new(x,-7.6,-42.86)*CFrame.Angles(0,math.rad(180),0),Vector3.new(9.25,10.8,.42),i+1)
end
-- West / east skins.
for i=-3,3 do
 local z=i*11
 wallPanel("WestPanel"..i,CFrame.new(-57.86,-7.6,z)*CFrame.Angles(0,math.rad(90),0),Vector3.new(10.2,10.8,.42),i)
 wallPanel("EastPanel"..i,CFrame.new(57.86,-7.6,z)*CFrame.Angles(0,math.rad(-90),0),Vector3.new(10.2,10.8,.42),i+1)
end

-- Bass traps in all four room corners.
local traps=Instance.new("Model");traps.Name="CornerBassTraps";traps.Parent=out
for _,d in ipairs({{-56.8,41.7},{56.8,41.7},{-56.8,-41.7},{56.8,-41.7}}) do
 local p=part("BassTrap",Vector3.new(2.2,11.5,2.2),CFrame.new(d[1],-7.4,d[2])*CFrame.Angles(0,math.rad(45),0),C.panel2,Enum.Material.Fabric,false,traps)
 p.Shape=Enum.PartType.Block
end

-- Hanging absorptive baffles between the pentagon fixtures. No new neon here.
local baffles=Instance.new("Model");baffles.Name="CeilingBaffles";baffles.Parent=out
for row,z in ipairs({-27,-18,-3,10,23}) do
 for i=-4,4 do
  local x=i*11
  local b=part(string.format("Baffle_%d_%d",row,i),Vector3.new(7.2,.8,1.1),CFrame.new(x,-2.0,z)*CFrame.Angles(0,math.rad((i%2==0) and 8 or -8),0),C.panel,Enum.Material.Fabric,false,baffles)
 end
end

-- Heavy decorative isolation doors at the side service openings.
local doors=Instance.new("Model");doors.Name="IsolationDoors";doors.Parent=out
for _,x in ipairs({-50,50}) do
 part("Door"..x,Vector3.new(7.5,10,.65),CFrame.new(x,-8.2,-42.45),Color3.fromRGB(34,37,42),Enum.Material.Metal,false,doors)
 part("DoorPad"..x,Vector3.new(6.2,8.5,.22),CFrame.new(x,-8.2,-42.05),C.panel,Enum.Material.Fabric,false,doors)
end

print("[BBYA] Basement acoustic v3 online: double-skin panels / bass traps / ceiling baffles")
