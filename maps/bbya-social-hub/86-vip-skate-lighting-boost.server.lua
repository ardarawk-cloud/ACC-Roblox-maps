-- BBYA SOCIAL HUB — VIP + SKATEPARK LIGHTING BOOST v1
-- VIP: brighter premium white ambience without adding visible square downlights.
-- Skatepark: very bright night coverage using fence/tower flood lighting.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end

local WHITE=Color3.fromRGB(250,252,255)
local WARM=Color3.fromRGB(255,244,220)

local function transparentEmitter(parent,name,pos,brightness,range)
 local p=Instance.new("Part")
 p.Name=name;p.Size=Vector3.new(.2,.2,.2);p.CFrame=CFrame.new(pos);p.Transparency=1
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent
 local l=Instance.new("PointLight");l.Name="AmbientWash";l.Color=WHITE;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=p
 return p
end

-- VIP -------------------------------------------------------------------------
local upper=root:FindFirstChild("UpperLevels")
local vip=upper and upper:FindFirstChild("L2_VIP_Level")
local active=vip and vip:FindFirstChild("VIPMinimalStanding")
if active then
 local old=active:FindFirstChild("VIPBrightnessBoostV1")
 if old then old:Destroy() end
 local boost=Instance.new("Model");boost.Name="VIPBrightnessBoostV1";boost.Parent=active
 boost:SetAttribute("VisibleDownlightsAdded",false)
 boost:SetAttribute("TriangleWashBoosted",true)
 boost:SetAttribute("BrightnessProfile","PREMIUM_BRIGHT")

 local network=active:FindFirstChild("TriangleCeilingNetwork")
 if network then
  for _,obj in ipairs(network:GetDescendants()) do
   if obj:IsA("SurfaceLight") and obj.Name=="WhiteTubeWash" then
    obj.Color=WHITE;obj.Brightness=.95;obj.Range=18;obj.Angle=135;obj.Shadows=false
   end
  end
 end

 -- Invisible broad ambient emitters: no new visible squares/strips.
 for i,pos in ipairs({
  Vector3.new(-34,38,-24),Vector3.new(0,38,-24),Vector3.new(34,38,-24),
  Vector3.new(-34,38,20),Vector3.new(0,38,20),Vector3.new(34,38,20),
 }) do transparentEmitter(boost,"VIPAmbient"..i,pos,1.35,29) end

 active:SetAttribute("LightingBrightnessProfile","PREMIUM_BRIGHT_V1")
end

-- SKATEPARK -------------------------------------------------------------------
local park=root:FindFirstChild("RearSkatepark")
if park then
 local upgrade=park:FindFirstChild("SkateparkUpgradeV2")
 if upgrade then
  local fenceLights=upgrade:FindFirstChild("FenceRoadLights")
  if fenceLights then
   for _,obj in ipairs(fenceLights:GetDescendants()) do
    if obj:IsA("SpotLight") and obj.Name=="RoadWash" then
     obj.Color=WHITE;obj.Brightness=7.5;obj.Range=72;obj.Angle=105;obj.Shadows=false
    elseif obj:IsA("BasePart") and obj.Name:match("Head$") then
     local fill=obj:FindFirstChild("FloodFill") or Instance.new("PointLight")
     fill.Name="FloodFill";fill.Color=WHITE;fill.Brightness=2.8;fill.Range=48;fill.Shadows=false;fill.Parent=obj
    elseif obj:IsA("BasePart") and obj.Name:match("Lens$") then
     obj.Color=WHITE
    end
   end
  end
 end

 local old=park:FindFirstChild("SkateparkStadiumLightingV1")
 if old then old:Destroy() end
 local stadium=Instance.new("Model");stadium.Name="SkateparkStadiumLightingV1";stadium.Parent=park
 stadium:SetAttribute("Profile","VERY_BRIGHT")
 stadium:SetAttribute("TowerCount",4)
 stadium:SetAttribute("NoNeon",true)

 local function p(name,size,cf,color,material,parent)
  local x=Instance.new("Part");x.Name=name;x.Size=size;x.CFrame=cf;x.Color=color;x.Material=material;x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth;x.Parent=parent or stadium;return x
 end
 local function tower(name,pos,target)
  local mast=p(name.."Mast",Vector3.new(.42,11,.42),CFrame.new(pos.X,16.5,pos.Z),Color3.fromRGB(72,75,80),Enum.Material.Metal)
  local headPos=Vector3.new(pos.X,22,pos.Z)
  local head=p(name.."TwinFlood",Vector3.new(5,.55,1.3),CFrame.lookAt(headPos,target),Color3.fromRGB(42,44,48),Enum.Material.Metal)
  for i,xoff in ipairs({-1.45,1.45}) do
   local lens=p(name.."Lens"..i,Vector3.new(1.85,.1,.92),head.CFrame*CFrame.new(xoff,-.32,-.12),WHITE,Enum.Material.Glass)
   lens.Transparency=.08
  end
  local s=Instance.new("SpotLight");s.Name="StadiumFlood";s.Face=Enum.NormalId.Front;s.Color=WHITE;s.Brightness=10;s.Range=92;s.Angle=118;s.Shadows=false;s.Parent=head
  local fill=Instance.new("PointLight");fill.Name="TowerFill";fill.Color=WARM;fill.Brightness=2.4;fill.Range=52;fill.Shadows=false;fill.Parent=head
 end
 local target=Vector3.new(0,2,112)
 tower("NW",Vector3.new(-55,0,146),target)
 tower("NE",Vector3.new(55,0,146),target)
 tower("SW",Vector3.new(-55,0,78),target)
 tower("SE",Vector3.new(55,0,78),target)

 -- Low invisible fill prevents dark pockets under ramps/rails.
 for i,pos in ipairs({Vector3.new(-30,7,100),Vector3.new(0,7,112),Vector3.new(30,7,124),Vector3.new(0,7,138)}) do
  transparentEmitter(stadium,"ParkFill"..i,pos,1.8,34)
 end
 park:SetAttribute("LightingBrightnessProfile","VERY_BRIGHT_V1")
end

print("[BBYA] Lighting boost v1 online: VIP premium bright / Skatepark very bright")
