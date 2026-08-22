-- BBYA SOCIAL HUB — VIP FLOOR NEON FIX v4
-- Owner lock: no legacy pink floor neon in VIP. Restore the full inner-edge list
-- as one consistent BLUE double-line on all four sides of the central opening.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
local vip=upper and upper:WaitForChild("L2_VIP_Level",30)
local active=vip and vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end

-- Let all earlier VIP builders finish before taking final floor-neon authority.
task.wait(2.4)

local BLUE=Color3.fromRGB(0,174,255)
local Y=25.03

local function isLegacyPinkFloorPart(obj)
 if not obj:IsA("BasePart") then return false end
 local n=obj.Name
 if n:match("^BalconyRailZ") or n:match("^BalconyRailX") or n=="QueenCrownLine" then return true end
 if obj.Material~=Enum.Material.Neon then return false end
 if obj.Position.Y<24.0 or obj.Position.Y>27.2 then return false end
 local c=obj.Color
 return c.R>.72 and c.G<.42 and c.B>.30
end

local function removeLegacyFloorNeon()
 for _,name in ipairs({"FloorBoundaryNeon","PreciseInnerFloorNeon"}) do
  local obj=active:FindFirstChild(name)
  if obj then obj:Destroy() end
 end
 for _,obj in ipairs(vip:GetDescendants()) do
  if isLegacyPinkFloorPart(obj) then obj:Destroy() end
 end
end

removeLegacyFloorNeon()

local out=Instance.new("Model")
out.Name="PreciseInnerFloorNeon";out.Parent=active
out:SetAttribute("Pass","VIP_FLOOR_NEON_V4")
out:SetAttribute("OuterNeonRemoved",true)
out:SetAttribute("PreciseFloorEdge",true)
out:SetAttribute("DoubleInnerLine",true)
out:SetAttribute("AllFourSidesRestored",true)
out:SetAttribute("AllInnerEdgesBlue",true)
out:SetAttribute("LegacyPinkFloorNeonRemoved",true)
out:SetAttribute("LegacyFloatingRailNeonRemoved",true)

local function strip(name,size,cf)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=BLUE;p.Material=Enum.Material.Neon
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=out
 local light=Instance.new("SurfaceLight")
 light.Name="FloorEdgeGlow";light.Face=Enum.NormalId.Top;light.Color=BLUE
 light.Brightness=.24;light.Range=4.5;light.Angle=115;light.Shadows=false;light.Parent=p
 return p
end

-- Full four-side double list under the safety rails.
for i,z in ipairs({22.76,22.98}) do strip("North_"..i,Vector3.new(69.8,.07,.07),CFrame.new(0,Y,z)) end
for i,z in ipairs({-26.76,-26.98}) do strip("South_"..i,Vector3.new(69.8,.07,.07),CFrame.new(0,Y,z)) end
for i,x in ipairs({-34.76,-34.98}) do strip("West_"..i,Vector3.new(.07,.07,49.8),CFrame.new(x,Y,-2)) end
for i,x in ipairs({34.76,34.98}) do strip("East_"..i,Vector3.new(.07,.07,49.8),CFrame.new(x,Y,-2)) end

-- Guard against a slower legacy script re-adding the old pink floor trim after this pass.
vip.DescendantAdded:Connect(function(obj)
 task.defer(function()
  if not obj or not obj.Parent then return end
  if obj:IsA("Model") and obj.Name=="FloorBoundaryNeon" then
   obj:Destroy();return
  end
  if isLegacyPinkFloorPart(obj) then obj:Destroy() end
 end)
end)

active:SetAttribute("FloorBoundaryNeonSegments",8)
active:SetAttribute("InnerFloorNeonRemoved",false)
active:SetAttribute("FloorLightingProfile","PRECISE_ALL_BLUE_INNER_EDGE_V4")
active:SetAttribute("PinkFloorNeonAllowed",false)

print("[BBYA] VIP floor neon v4: all legacy pink floor neon removed / full 4-side blue inner list restored")
