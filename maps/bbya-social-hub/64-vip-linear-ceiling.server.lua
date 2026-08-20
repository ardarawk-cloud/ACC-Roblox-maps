-- BBYA SOCIAL HUB — VIP GEOMETRIC WHITE CEILING v2.1
-- Reference lock: WHITE ONLY, connected triangular / polygon light frames.
-- Mounted flush under the rooftop slab. Owns VIP ceiling lighting only.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
if not upper then return end
local vip=upper:WaitForChild("L2_VIP_Level",30)
if not vip then return end
local premium=vip:WaitForChild("PremiumVIPPass",30)
if not premium then return end

local ceiling=premium:FindFirstChild("VIPCeiling")
if not ceiling then
 ceiling=Instance.new("Model")
 ceiling.Name="VIPCeiling"
 ceiling.Parent=premium
end

for _,obj in ipairs(ceiling:GetChildren()) do
 if obj.Name=="LinearCeilingPass" or obj.Name=="GeometricWhiteCeiling" or obj.Name:match("^Pendant") or obj.Name:match("^Beam") or obj.Name:match("^EastGlow") or obj.Name:match("^NorthCove") then
  obj:Destroy()
 end
end

local pass=Instance.new("Model")
pass.Name="GeometricWhiteCeiling"
pass:SetAttribute("Pass","VIP_GEOMETRIC_WHITE_CEILING_V2_1")
pass.Parent=ceiling

local WHITE=Color3.fromRGB(250,250,250)
local HOUSING=Color3.fromRGB(14,14,16)
-- Rooftop slabs are centered at Y=44.5 with 1 stud thickness, so underside = Y=44.0.
-- Housing top lands at 44.0; emitter sits just below it, visually ceiling-mounted.
local CEILING_Y=43.82

local function part(name,size,cf,color,material,transparency,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=true;p.CastShadow=false
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent
 return p
end

local segmentCount=0
local dynamicLights=0
local function segment(name,a,b,lit)
 segmentCount+=1
 local dx=b.X-a.X;local dz=b.Y-a.Y
 local len=math.sqrt(dx*dx+dz*dz)
 local midX=(a.X+b.X)/2;local midZ=(a.Y+b.Y)/2
 local yaw=-math.atan2(dz,dx)
 local cf=CFrame.new(midX,CEILING_Y,midZ)*CFrame.Angles(0,yaw,0)
 local unit=Instance.new("Model");unit.Name=name;unit.Parent=pass
 part("Housing",Vector3.new(len+.35,.18,.34),cf*CFrame.new(0,.09,0),HOUSING,Enum.Material.Metal,0,unit)
 local emitter=part("Emitter",Vector3.new(len,.09,.18),cf,WHITE,Enum.Material.Neon,0,unit)
 if lit then
  local light=Instance.new("SurfaceLight")
  light.Name="Downlight";light.Face=Enum.NormalId.Bottom;light.Color=WHITE
  light.Brightness=.95;light.Range=22;light.Angle=118;light.Shadows=false;light.Parent=emitter
  dynamicLights+=1
 end
 return emitter
end

local function polygon(name,pts,lightEvery)
 local group=Instance.new("Model");group.Name=name;group.Parent=pass
 for i=1,#pts do
  local a=pts[i];local b=pts[(i%#pts)+1]
  segment(string.format("%s_S%02d",name,i),a,b,(segmentCount%(lightEvery or 2)==0)).Parent=group
 end
end

-- Large WHITE connected frames: triangles / irregular polygons, matching the reference.
polygon("GeoLeftFront",{Vector2.new(-56,-20),Vector2.new(-31,-20),Vector2.new(-43,-5)},2)
polygon("GeoLeftRear",{Vector2.new(-55,-3),Vector2.new(-28,-3),Vector2.new(-37,14),Vector2.new(-56,11)},2)
polygon("GeoCenterFront",{Vector2.new(-25,-20),Vector2.new(3,-20),Vector2.new(-10,-5)},2)
polygon("GeoCenterRear",{Vector2.new(-22,0),Vector2.new(8,0),Vector2.new(-2,18),Vector2.new(-27,13)},2)
polygon("GeoRightFront",{Vector2.new(8,-20),Vector2.new(37,-20),Vector2.new(24,-4)},2)
polygon("GeoRightRear",{Vector2.new(13,1),Vector2.new(52,1),Vector2.new(39,19),Vector2.new(18,14)},2)
polygon("GeoFarRight",{Vector2.new(40,-17),Vector2.new(58,-9),Vector2.new(55,14),Vector2.new(43,5)},3)
segment("ConnectorL",Vector2.new(-31,-20),Vector2.new(-28,-3),true)
segment("ConnectorR",Vector2.new(37,-20),Vector2.new(40,-17),true)

pass:SetAttribute("SegmentCount",segmentCount)
pass:SetAttribute("DynamicLightCount",dynamicLights)
pass:SetAttribute("CeilingY",CEILING_Y)
pass:SetAttribute("RooftopUndersideY",44.0)
pass:SetAttribute("LightingStyle","White Geometric Triangle Frames")
pass:SetAttribute("WhiteOnly",true)
pass:SetAttribute("ReferenceShape","Connected triangles and polygons")
pass:SetAttribute("Floor1Untouched",true)

print(string.format("[BBYA] VIP Geometric White Ceiling v2.1 online: %d white segments / %d downlights / Y=%.2f",segmentCount,dynamicLights,CEILING_Y))
