-- BBYA SOCIAL HUB — VIP FLOOR NEON FIX v1
-- Removes outer floor neon and rebuilds only precise double-line trim around the inner void.
local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper=root:WaitForChild("UpperLevels",30)
local vip=upper and upper:WaitForChild("L2_VIP_Level",30)
local active=vip and vip:WaitForChild("VIPMinimalStanding",30)
if not active then return end
task.wait(.4)

local old=active:FindFirstChild("FloorBoundaryNeon")
if old then old:Destroy() end
local previous=active:FindFirstChild("PreciseInnerFloorNeon")
if previous then previous:Destroy() end

local out=Instance.new("Model")
out.Name="PreciseInnerFloorNeon";out.Parent=active
out:SetAttribute("OuterNeonRemoved",true)
out:SetAttribute("DoubleInnerLine",true)
local PINK=Color3.fromRGB(255,42,157)
local BLUE=Color3.fromRGB(0,174,255)
local Y=25.03
local function strip(name,size,cf,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CastShadow=false;p.Parent=out
 local light=Instance.new("SurfaceLight");light.Face=Enum.NormalId.Top;light.Color=color;light.Brightness=.28;light.Range=5;light.Shadows=false;light.Parent=p
 return p
end

-- two narrow parallel lines per inner edge, aligned to the exact walkable opening.
for i,z in ipairs({22.76,22.98}) do strip("North_"..i,Vector3.new(69.8,.08,.08),CFrame.new(0,Y,z),BLUE) end
for i,z in ipairs({-26.76,-26.98}) do strip("South_"..i,Vector3.new(69.8,.08,.08),CFrame.new(0,Y,z),PINK) end
for i,x in ipairs({-34.76,-34.98}) do strip("West_"..i,Vector3.new(.08,.08,49.8),CFrame.new(x,Y,-2),PINK) end
for i,x in ipairs({34.76,34.98}) do strip("East_"..i,Vector3.new(.08,.08,49.8),CFrame.new(x,Y,-2),BLUE) end

print("[BBYA] VIP floor neon fixed: outer removed / 8 precise inner strips")
