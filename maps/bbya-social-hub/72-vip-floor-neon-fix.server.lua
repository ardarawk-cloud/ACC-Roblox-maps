-- BBYA SOCIAL HUB — VIP FLOOR NEON FIX v3
-- Restore the precise floor-edge neon the owner approved, while removing legacy
-- floating/asymmetric VIP rail neon that can survive the old UpperLevels builder.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
local vip=upper and upper:WaitForChild("L2_VIP_Level",30)
local active=vip and vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end

-- Let the legacy UpperLevels builder finish so late-created rail neon can be removed.
task.wait(1.8)

-- Remove the broad old floor-neon model and any previous precision pass.
for _,name in ipairs({"FloorBoundaryNeon","PreciseInnerFloorNeon"}) do
 local obj=active:FindFirstChild(name)
 if obj then obj:Destroy() end
end

-- Hard-clean legacy neon that belongs to 25-upper-levels.server.lua, not the
-- current VIP design. These are the floating/asymmetric lines visible in mobile screenshots.
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
out:SetAttribute("DoubleInnerLine",true)
out:SetAttribute("OwnerPinkPathsRemoved",2)
out:SetAttribute("LegacyFloatingRailNeonRemoved",true)

local BLUE=Color3.fromRGB(0,174,255)
local Y=25.03

local function strip(name,size,cf,color)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Neon
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=out
 local light=Instance.new("SurfaceLight")
 light.Name="FloorEdgeGlow";light.Face=Enum.NormalId.Top;light.Color=color
 light.Brightness=.24;light.Range=4.5;light.Angle=115;light.Shadows=false;light.Parent=p
 return p
end

-- Two very narrow parallel lines following only the true inner walking-floor edge.
-- This is the clean neon that was present before v2 removed it.
for i,z in ipairs({22.76,22.98}) do strip("North_"..i,Vector3.new(69.8,.07,.07),CFrame.new(0,Y,z),BLUE) end
for i,x in ipairs({34.76,34.98}) do strip("East_"..i,Vector3.new(.07,.07,49.8),CFrame.new(x,Y,-2),BLUE) end

active:SetAttribute("FloorBoundaryNeonSegments",4)
active:SetAttribute("InnerFloorNeonRemoved",false)
active:SetAttribute("FloorLightingProfile","PRECISE_INNER_EDGE_V3")

print("[BBYA] VIP floor neon v3: precise inner edge restored / legacy floating rail neon removed")
