-- BBYA SOCIAL HUB — SKATEPARK EXPOSURE + LAMP GROUNDING FIX v3
-- Keeps the park bright/readable and physically grounds all skatepark lamp masts.
-- Local skatepark objects only. No global Lighting writes.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local park=root:WaitForChild("RearSkatepark",30)
if not park then return end

-- Wait for both lighting passes to finish building before tuning geometry/illumination.
local upgrade=park:WaitForChild("SkateparkUpgradeV2",30)
local stadium=park:WaitForChild("SkateparkStadiumLightingV1",30)
if not upgrade or not stadium then return end

task.wait(.65)

local SOFT_WHITE=Color3.fromRGB(238,241,238)
local WARM_WHITE=Color3.fromRGB(248,238,218)
local MAST_COLOR=Color3.fromRGB(70,73,78)

local function groundVerticalMast(mast,bottomY,topY)
 if not mast or not mast:IsA("BasePart") then return false end
 local height=math.max(.5,topY-bottomY)
 mast.Size=Vector3.new(mast.Size.X,height,mast.Size.Z)
 mast.CFrame=CFrame.new(mast.Position.X,bottomY+height/2,mast.Position.Z)
 mast.Color=MAST_COLOR
 mast.Anchored=true
 mast.CanCollide=false
 mast.CanTouch=false
 return true
end

local function ensureBase(parent,name,pos)
 local base=parent:FindFirstChild(name)
 if not base then
  base=Instance.new("Part")
  base.Name=name
  base.Size=Vector3.new(.9,.18,.9)
  base.Anchored=true
  base.CanCollide=false
  base.CanTouch=false
  base.Material=Enum.Material.Metal
  base.Color=Color3.fromRGB(52,54,58)
  base.TopSurface=Enum.SurfaceType.Smooth
  base.BottomSurface=Enum.SurfaceType.Smooth
  base.Parent=parent
 end
 base.CFrame=CFrame.new(pos.X,1.09,pos.Z)
 return base
end

local fence=upgrade:FindFirstChild("FenceRoadLights")
local streetMasts=0
local streetArms=0
if fence then
 -- Road lamps were originally only 5.7 studs tall at Y=12.7, leaving a large air gap.
 -- Ground them from the skate slab (Y=1) to the existing arm/head height.
 for _,obj in ipairs(fence:GetChildren()) do
  if obj:IsA("BasePart") and obj.Name:match("Mast$") then
   if groundVerticalMast(obj,1.0,15.32) then
    streetMasts+=1
    local prefix=obj.Name:gsub("Mast$","")
    ensureBase(fence,prefix.."Base",obj.Position)
   end
  end
 end

 -- Reconnect each horizontal arm between the mast top and lamp head.
 -- The old arm transform rotated the long axis sideways, which made some heads look detached.
 for _,obj in ipairs(fence:GetChildren()) do
  if obj:IsA("BasePart") and obj.Name:match("Arm$") then
   local prefix=obj.Name:gsub("Arm$","")
   local mast=fence:FindFirstChild(prefix.."Mast")
   local head=fence:FindFirstChild(prefix.."Head")
   if mast and mast:IsA("BasePart") and head and head:IsA("BasePart") then
    local from=Vector3.new(mast.Position.X,15.25,mast.Position.Z)
    local to=head.Position
    local delta=to-from
    local dist=delta.Magnitude
    if dist>.2 then
     obj.Size=Vector3.new(obj.Size.X,obj.Size.Y,dist)
     obj.CFrame=CFrame.lookAt((from+to)/2,to)
     streetArms+=1
    end
   end
  end
 end

 for _,obj in ipairs(fence:GetDescendants()) do
  if obj:IsA("SpotLight") and obj.Name=="RoadWash" then
   obj.Color=SOFT_WHITE
   obj.Brightness=3.0
   obj.Range=48
   obj.Angle=84
   obj.Shadows=false
  elseif obj:IsA("PointLight") and obj.Name=="FloodFill" then
   obj.Color=WARM_WHITE
   obj.Brightness=.55
   obj.Range=25
   obj.Shadows=false
  elseif obj:IsA("BasePart") and obj.Name:match("Lens$") then
   obj.Color=WARM_WHITE
   obj.Transparency=.18
  end
 end
end

local stadiumMasts=0
-- Stadium towers were originally 11 studs tall centered at Y=16.5, so their bottoms began at Y=11.
-- Extend each tower continuously from the slab to its existing flood head at Y=22.
for _,obj in ipairs(stadium:GetChildren()) do
 if obj:IsA("BasePart") and obj.Name:match("Mast$") then
  if groundVerticalMast(obj,1.0,22.0) then
   stadiumMasts+=1
   local prefix=obj.Name:gsub("Mast$","")
   ensureBase(stadium,prefix.."Base",obj.Position)
  end
 end
end

for _,obj in ipairs(stadium:GetDescendants()) do
 if obj:IsA("SpotLight") and obj.Name=="StadiumFlood" then
  obj.Color=SOFT_WHITE
  obj.Brightness=4.0
  obj.Range=62
  obj.Angle=92
  obj.Shadows=false
 elseif obj:IsA("PointLight") and obj.Name=="TowerFill" then
  obj.Color=WARM_WHITE
  obj.Brightness=.45
  obj.Range=28
  obj.Shadows=false
 elseif obj:IsA("PointLight") and obj.Name=="AmbientWash" then
  obj.Color=SOFT_WHITE
  obj.Brightness=.32
  obj.Range=22
  obj.Shadows=false
 elseif obj:IsA("BasePart") and obj.Name:match("Lens%d+$") then
  obj.Color=WARM_WHITE
  obj.Transparency=.20
 end
end

stadium:SetAttribute("Profile","BALANCED_BRIGHT_V3_GROUNDED")
park:SetAttribute("LightingBrightnessProfile","BALANCED_BRIGHT_V3")
park:SetAttribute("ExposureFix","NO_WHITEOUT_V3")
park:SetAttribute("LampGeometryAuthority","LAMP_GROUNDING_V3")
park:SetAttribute("StreetMastsGrounded",streetMasts>0)
park:SetAttribute("StreetArmsReconnected",streetArms>0)
park:SetAttribute("StadiumMastsGrounded",stadiumMasts>0)
park:SetAttribute("GlobalLightingWrites",false)

print(string.format("[BBYA] Skatepark lamp grounding v3 online: street=%d arms=%d stadium=%d",streetMasts,streetArms,stadiumMasts))
