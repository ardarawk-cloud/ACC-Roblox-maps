-- BBYA SOCIAL HUB — VIP FLOOR NEON FIX v5
-- Preserve every existing BLUE/cyan VIP floor trim. Remove only PINK/magenta floor neon.
-- Do not delete the legacy FloorBoundaryNeon model wholesale.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
local vip=upper and upper:WaitForChild("L2_VIP_Level",30)
local active=vip and vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end

task.wait(1.8)

local function isPinkFloorNeon(obj)
 if not obj:IsA("BasePart") then return false end
 if obj.Material~=Enum.Material.Neon then return false end
 local y=obj.Position.Y
 if y<24.4 or y>25.6 then return false end
 local c=obj.Color
 return c.R>0.72 and c.G<0.48 and c.B>0.35
end

-- IMPORTANT: preserve FloorBoundaryNeon because it contains the blue trim the owner wants.
-- Remove only its pink/magenta segments.
local boundary=active:FindFirstChild("FloorBoundaryNeon")
if boundary then
 for _,obj in ipairs(boundary:GetDescendants()) do
  if isPinkFloorNeon(obj) then obj:Destroy() end
 end
end

-- Rebuild only our precision helper layer; never touch the blue legacy trim.
local oldPrecise=active:FindFirstChild("PreciseInnerFloorNeon")
if oldPrecise then oldPrecise:Destroy() end

local out=Instance.new("Model")
out.Name="PreciseInnerFloorNeon";out.Parent=active
out:SetAttribute("BlueLegacyTrimPreserved",true)
out:SetAttribute("PinkFloorNeonRemoved",true)

local BLUE=Color3.fromRGB(0,174,255)
local Y=25.03

local function strip(name,size,cf)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=BLUE;p.Material=Enum.Material.Neon
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=out
 local light=Instance.new("SurfaceLight")
 light.Name="FloorEdgeGlow";light.Face=Enum.NormalId.Top;light.Color=BLUE
 light.Brightness=.20;light.Range=4;light.Angle=110;light.Shadows=false;light.Parent=p
end

-- Keep the approved blue precision guides.
for i,z in ipairs({22.76,22.98}) do
 strip("NorthBlue_"..i,Vector3.new(69.8,.07,.07),CFrame.new(0,Y,z))
end
for i,x in ipairs({34.76,34.98}) do
 strip("EastBlue_"..i,Vector3.new(.07,.07,49.8),CFrame.new(x,Y,-2))
end

active:SetAttribute("PinkFloorNeonRemoved",true)
active:SetAttribute("BlueFloorTrimPreserved",true)
active:SetAttribute("FloorLightingProfile","PRESERVE_BLUE_REMOVE_PINK_V5")

print("[BBYA] VIP floor neon v5: BLUE trim preserved / PINK floor neon removed only")
