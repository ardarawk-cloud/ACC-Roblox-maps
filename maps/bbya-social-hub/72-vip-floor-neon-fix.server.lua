-- BBYA SOCIAL HUB — VIP FLOOR NEON FIX v4
-- Owner correction: remove the distracting PINK floor-edge neon visible below the rail/walkway.
-- Keep only the restrained BLUE inner-edge guides. Also hard-clean legacy floating rail neon.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
local vip=upper and upper:WaitForChild("L2_VIP_Level",30)
local active=vip and vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end

-- Let late VIP builders finish first, then apply final cleanup.
task.wait(1.8)

-- Rebuild this layer deterministically so old pink segments cannot survive.
for _,name in ipairs({"FloorBoundaryNeon","PreciseInnerFloorNeon"}) do
 local obj=active:FindFirstChild(name)
 if obj then obj:Destroy() end
end

-- Remove old floating/asymmetric rail neon from legacy UpperLevels passes.
for _,obj in ipairs(vip:GetDescendants()) do
 if obj:IsA("BasePart") then
  local n=obj.Name
  if n:match("^BalconyRailZ") or n:match("^BalconyRailX") or n=="QueenCrownLine" then
   obj:Destroy()
  end
 end
end

local out=Instance.new("Model")
out.Name="PreciseInnerFloorNeon";out.Parent=active
out:SetAttribute("OuterNeonRemoved",true)
out:SetAttribute("PreciseFloorEdge",true)
out:SetAttribute("PinkFloorNeonRemoved",true)
out:SetAttribute("LegacyFloatingRailNeonRemoved",true)

local BLUE=Color3.fromRGB(0,174,255)
local Y=25.03

local function strip(name,size,cf,color)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Neon
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=out
 local light=Instance.new("SurfaceLight")
 light.Name="FloorEdgeGlow";light.Face=Enum.NormalId.Top;light.Color=color
 light.Brightness=.20;light.Range=4;light.Angle=110;light.Shadows=false;light.Parent=p
 return p
end

-- Keep only the BLUE inner guides. Pink south/west floor strips are intentionally removed.
for i,z in ipairs({22.76,22.98}) do
 strip("NorthBlue_"..i,Vector3.new(69.8,.07,.07),CFrame.new(0,Y,z),BLUE)
end
for i,x in ipairs({34.76,34.98}) do
 strip("EastBlue_"..i,Vector3.new(.07,.07,49.8),CFrame.new(x,Y,-2),BLUE)
end

active:SetAttribute("FloorBoundaryNeonSegments",4)
active:SetAttribute("PinkFloorNeonRemoved",true)
active:SetAttribute("FloorLightingProfile","BLUE_ONLY_INNER_EDGE_V4")

print("[BBYA] VIP floor neon v4: distracting pink floor strips removed / blue inner guides retained")
