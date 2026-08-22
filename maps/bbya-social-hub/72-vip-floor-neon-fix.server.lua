-- BBYA SOCIAL HUB — VIP FLOOR NEON OWNER LOCK v6
-- FINAL AUTHORITY: no pink neon/light/strip may remain anywhere inside VIP.
-- The central opening must always keep one symmetric BLUE double-line on ALL FOUR sides.
-- This pass also repairs missing lines if another late script removes or changes them.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30);if not root then return end
local upper=root:WaitForChild("UpperLevels",30);if not upper then return end
local vip=upper:WaitForChild("L2_VIP_Level",30);if not vip then return end
local active=vip:WaitForChild("VIPMinimalStanding",30);if not active then return end

-- Give the base VIP builder enough time to finish its synchronous dressing first.
task.wait(1.2)

local BLUE=Color3.fromRGB(0,174,255)
local Y=25.03
local LOCK_NAME="PreciseInnerFloorNeon"

local specs={
 {"North_1",Vector3.new(69.8,.07,.07),CFrame.new(0,Y,22.76)},
 {"North_2",Vector3.new(69.8,.07,.07),CFrame.new(0,Y,22.98)},
 {"South_1",Vector3.new(69.8,.07,.07),CFrame.new(0,Y,-26.76)},
 {"South_2",Vector3.new(69.8,.07,.07),CFrame.new(0,Y,-26.98)},
 {"West_1",Vector3.new(.07,.07,49.8),CFrame.new(-34.76,Y,-2)},
 {"West_2",Vector3.new(.07,.07,49.8),CFrame.new(-34.98,Y,-2)},
 {"East_1",Vector3.new(.07,.07,49.8),CFrame.new(34.76,Y,-2)},
 {"East_2",Vector3.new(.07,.07,49.8),CFrame.new(34.98,Y,-2)},
}

local function pinkColor(c)
 return c and c.R>.70 and c.G<.48 and c.B>.28
end

local function beamIsPink(b)
 local ok,res=pcall(function()
  for _,k in ipairs(b.Color.Keypoints) do if pinkColor(k.Value) then return true end end
  return false
 end)
 return ok and res
end

local function trailIsPink(t)
 local ok,res=pcall(function()
  for _,k in ipairs(t.Color.Keypoints) do if pinkColor(k.Value) then return true end end
  return false
 end)
 return ok and res
end

local function thinStrip(p)
 local s=p.Size
 local mn=math.min(s.X,s.Y,s.Z)
 local mx=math.max(s.X,s.Y,s.Z)
 return mn<=.45 and mx>=4
end

local function isApprovedBlueStrip(obj)
 local lock=active:FindFirstChild(LOCK_NAME)
 return lock and obj:IsDescendantOf(lock) and obj:IsA("BasePart") and obj.Name:match("^(North|South|West|East)_") and obj.Color==BLUE
end

local function shouldRemove(obj)
 if obj.Name=="FloorBoundaryNeon" and obj.Parent==active then return true end
 if obj:IsA("BasePart") then
  if isApprovedBlueStrip(obj) then return false end
  if pinkColor(obj.Color) and (obj.Material==Enum.Material.Neon or thinStrip(obj)) then return true end
  local n=obj.Name
  if n:match("^BalconyRailZ") or n:match("^BalconyRailX") or n=="QueenCrownLine" then return true end
 elseif obj:IsA("Light") then
  return pinkColor(obj.Color)
 elseif obj:IsA("Beam") then
  return beamIsPink(obj)
 elseif obj:IsA("Trail") then
  return trailIsPink(obj)
 end
 return false
end

local function scrubPink()
 local removed=0
 local broad=active:FindFirstChild("FloorBoundaryNeon")
 if broad then broad:Destroy();removed+=1 end
 for _,obj in ipairs(vip:GetDescendants()) do
  if obj.Parent and shouldRemove(obj) then obj:Destroy();removed+=1 end
 end
 return removed
end

local old=active:FindFirstChild(LOCK_NAME)
if old then old:Destroy() end
scrubPink()

local out=Instance.new("Model")
out.Name=LOCK_NAME
out.Parent=active
out:SetAttribute("Pass","VIP_FLOOR_NEON_V6_FINAL")
out:SetAttribute("AllFourSidesRestored",true)
out:SetAttribute("AllInnerEdgesBlue",true)
out:SetAttribute("SymmetricDoubleLine",true)
out:SetAttribute("PinkVIPLightingAllowed",false)
out:SetAttribute("FinalAuthority",true)

local repairing=false
local function ensureStrip(spec)
 if not out.Parent then return end
 local name,size,cf=spec[1],spec[2],spec[3]
 local p=out:FindFirstChild(name)
 if not p or not p:IsA("BasePart") then
  if p then p:Destroy() end
  p=Instance.new("Part")
  p.Name=name
  p.Parent=out
 end
 p.Size=size
 p.CFrame=cf
 p.Color=BLUE
 p.Material=Enum.Material.Neon
 p.Transparency=0
 p.Anchored=true
 p.CanCollide=false
 p.CanTouch=false
 p.CanQuery=false
 p.CastShadow=false
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 local light=p:FindFirstChild("FloorEdgeGlow")
 if not light or not light:IsA("SurfaceLight") then
  if light then light:Destroy() end
  light=Instance.new("SurfaceLight")
  light.Name="FloorEdgeGlow"
  light.Parent=p
 end
 light.Face=Enum.NormalId.Top
 light.Color=BLUE
 light.Brightness=.24
 light.Range=4.5
 light.Angle=115
 light.Shadows=false
end

local function ensureAll()
 if repairing or not out.Parent then return end
 repairing=true
 for _,spec in ipairs(specs) do ensureStrip(spec) end
 out:SetAttribute("VerifiedSegmentCount",8)
 repairing=false
end

ensureAll()

-- Remove any late-created legacy pink object immediately, on BOTH left and right sides.
vip.DescendantAdded:Connect(function(obj)
 task.defer(function()
  if not obj or not obj.Parent then return end
  if shouldRemove(obj) then
   obj:Destroy()
  elseif obj:IsDescendantOf(out) then
   ensureAll()
  end
 end)
end)

-- If any of the approved eight segments gets deleted by another late script, recreate it.
out.ChildRemoved:Connect(function()
 task.defer(ensureAll)
end)

-- Short startup-race sweep only; no permanent expensive descendant polling.
task.spawn(function()
 local total=0
 for _=1,40 do
  total+=scrubPink()
  ensureAll()
  task.wait(.25)
 end
 active:SetAttribute("PinkObjectsScrubbedV6",total)
 active:SetAttribute("VIPNeonFinalLockVerified",true)
end)

active:SetAttribute("FloorBoundaryNeonSegments",8)
active:SetAttribute("FloorLightingProfile","PRECISE_ALL_BLUE_V6_FINAL")
active:SetAttribute("PinkFloorNeonAllowed",false)
active:SetAttribute("PinkVIPLightingAllowed",false)
active:SetAttribute("VIPNeonSymmetry","NORTH_SOUTH_WEST_EAST_DOUBLE")
print("[BBYA] VIP neon v6 FINAL: pink scrubbed both sides / symmetric 8-segment blue perimeter locked")
