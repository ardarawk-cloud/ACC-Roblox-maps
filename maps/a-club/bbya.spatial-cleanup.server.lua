-- BBYA Social Hub spatial cleanup v1.0
-- Clears overlapping platforms/signage around rooftop stairs, VIP and supporter paths.

task.wait(3)

local function find(name)
 return workspace:FindFirstChild(name,true)
end

local function setPart(name,cf,size)
 local p=find(name)
 if p and p:IsA("BasePart") then
  if cf then p.CFrame=cf end
  if size then p.Size=size end
  return p
 end
end

local function hide(name)
 local p=find(name)
 if p and p:IsA("BasePart") then
  p.Transparency=1;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 end
end

-- Rooftop stair run: make it narrower and keep it hard to the left wall so it no longer cuts through central signage/upper traffic.
for i=1,10 do
 local p=find("Rooftop Step "..i)
 if p and p:IsA("BasePart") then
  local z=52-(i-1)*4
  local y=2+(i-1)*1.8
  p.Size=Vector3.new(14,2,6)
  p.CFrame=CFrame.new(-78,y,z)
  p.Material=Enum.Material.Metal
 end
end

-- Remove the full-width rear balcony slab/rail that blocks the stair arrival; replace it with two clean wings.
local clubRoot=find("Main Club Upgrade") or workspace
hide("Upper Balcony Rear")
hide("Balcony Rail Rear")
local function makePart(name,size,cf,color,material,transparency,collide)
 local old=find(name);if old then old:Destroy() end
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide~=false
 p.Color=color;p.Material=material or Enum.Material.Slate;p.Transparency=transparency or 0;p.Parent=clubRoot
 return p
end
local stone=Color3.fromRGB(30,29,37)
local glass=Color3.fromRGB(55,80,110)
makePart("Upper Balcony Rear Left Wing",Vector3.new(42,2,18),CFrame.new(-37,16,28),stone,Enum.Material.Slate,0,true)
makePart("Upper Balcony Rear Right Wing",Vector3.new(42,2,18),CFrame.new(37,16,28),stone,Enum.Material.Slate,0,true)
makePart("Balcony Rail Rear Left Wing",Vector3.new(42,7,1),CFrame.new(-37,20,19),glass,Enum.Material.Glass,.55,true)
makePart("Balcony Rail Rear Right Wing",Vector3.new(42,7,1),CFrame.new(37,20,19),glass,Enum.Material.Glass,.55,true)

-- Keep the central stair landing visually open.
for _,name in ipairs({"Ceiling Beam 16","Ceiling Neon 16"}) do
 local p=find(name)
 if p and p:IsA("BasePart") then p.CanCollide=false end
end

-- Move rooftop/wayfinding signs away from stair heads and rails.
local poolSign=find("Pool Sign")
if poolSign and poolSign:IsA("BasePart") then
 poolSign.CFrame=CFrame.new(0,45,-42)
 poolSign.Size=Vector3.new(30,2.4,.35)
 poolSign.CanCollide=false
end
local way=find("Lobby Wayfinding")
if way and way:IsA("BasePart") then
 way.CFrame=CFrame.new(0,11.5,48)
 way.CanCollide=false
end

-- VIP signs sit above furniture instead of through it.
for _,name in ipairs({"Left VIP Platform Sign","Right VIP Platform Sign"}) do
 local p=find(name)
 if p and p:IsA("BasePart") then
  p.CFrame=p.CFrame*CFrame.new(0,3,0)
  p.CanCollide=false
 end
end

-- Supporter display must never intrude into stairs or walkways.
for _,name in ipairs({"Top Supporters Board","Donate Text Wall","Leaderboard Board"}) do
 local p=find(name)
 if p and p:IsA("BasePart") then p.CanCollide=false end
end

print("[BBYA] spatial cleanup applied: stair corridor, balcony opening, signage clearance")
