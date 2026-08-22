-- BBYA SOCIAL HUB — VIP FLOOR NEON OWNER LOCK v5
-- Final owner rule: NO pink neon/strip/light is allowed inside the VIP model.
-- The central opening keeps one consistent BLUE double-line on all four sides.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30);if not root then return end
local upper=root:WaitForChild("UpperLevels",30);if not upper then return end
local vip=upper:WaitForChild("L2_VIP_Level",30);if not vip then return end
local active=vip:WaitForChild("VIPMinimalStanding",30);if not active then return end

task.wait(2.4)
local BLUE=Color3.fromRGB(0,174,255)
local Y=25.03

local function pinkColor(c)
 return c and c.R>.70 and c.G<.48 and c.B>.28
end
local function thinStrip(p)
 local s=p.Size;local mn=math.min(s.X,s.Y,s.Z);local mx=math.max(s.X,s.Y,s.Z)
 return mn<=.45 and mx>=4
end
local function beamIsPink(b)
 local ok,res=pcall(function()
  for _,k in ipairs(b.Color.Keypoints) do if pinkColor(k.Value) then return true end end
  return false
 end)
 return ok and res
end
local function shouldRemove(obj)
 if obj:IsA("BasePart") then
  if obj:IsDescendantOf(active:FindFirstChild("PreciseInnerFloorNeon") or active) and obj.Name:match("^(North|South|West|East)_") and obj.Color==BLUE then return false end
  if pinkColor(obj.Color) and (obj.Material==Enum.Material.Neon or thinStrip(obj)) then return true end
  local n=obj.Name
  if n:match("^BalconyRailZ") or n:match("^BalconyRailX") or n=="QueenCrownLine" then return true end
 elseif obj:IsA("Light") then
  return pinkColor(obj.Color)
 elseif obj:IsA("Beam") then
  return beamIsPink(obj)
 elseif obj:IsA("Trail") then
  local ok,res=pcall(function()for _,k in ipairs(obj.Color.Keypoints) do if pinkColor(k.Value) then return true end end;return false end)
  return ok and res
 end
 return false
end

local function scrubPink()
 local removed=0
 local broad=active:FindFirstChild("FloorBoundaryNeon");if broad then broad:Destroy();removed+=1 end
 for _,obj in ipairs(vip:GetDescendants()) do
  if obj.Parent and shouldRemove(obj) then obj:Destroy();removed+=1 end
 end
 return removed
end

local old=active:FindFirstChild("PreciseInnerFloorNeon");if old then old:Destroy() end
scrubPink()

local out=Instance.new("Model");out.Name="PreciseInnerFloorNeon";out.Parent=active
out:SetAttribute("Pass","VIP_FLOOR_NEON_V5")
out:SetAttribute("AllFourSidesRestored",true);out:SetAttribute("AllInnerEdgesBlue",true);out:SetAttribute("PinkVIPLightingAllowed",false)
local function strip(name,size,cf)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=BLUE;p.Material=Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=out
 local light=Instance.new("SurfaceLight");light.Name="FloorEdgeGlow";light.Face=Enum.NormalId.Top;light.Color=BLUE;light.Brightness=.24;light.Range=4.5;light.Angle=115;light.Shadows=false;light.Parent=p
end
for i,z in ipairs({22.76,22.98}) do strip("North_"..i,Vector3.new(69.8,.07,.07),CFrame.new(0,Y,z)) end
for i,z in ipairs({-26.76,-26.98}) do strip("South_"..i,Vector3.new(69.8,.07,.07),CFrame.new(0,Y,z)) end
for i,x in ipairs({-34.76,-34.98}) do strip("West_"..i,Vector3.new(.07,.07,49.8),CFrame.new(x,Y,-2)) end
for i,x in ipairs({34.76,34.98}) do strip("East_"..i,Vector3.new(.07,.07,49.8),CFrame.new(x,Y,-2)) end

-- Catch late-created legacy strips immediately.
vip.DescendantAdded:Connect(function(obj)
 task.defer(function()if obj and obj.Parent and shouldRemove(obj) then obj:Destroy() end end)
end)
-- Also sweep for startup races for several seconds after construction.
task.spawn(function()
 local total=0
 for _=1,48 do total+=scrubPink();task.wait(.25) end
 active:SetAttribute("PinkObjectsScrubbedV5",total)
end)

active:SetAttribute("FloorBoundaryNeonSegments",8);active:SetAttribute("FloorLightingProfile","PRECISE_ALL_BLUE_V5");active:SetAttribute("PinkFloorNeonAllowed",false);active:SetAttribute("PinkVIPLightingAllowed",false)
print("[BBYA] VIP neon v5: hard pink scrub active / 4-side blue double list locked")
