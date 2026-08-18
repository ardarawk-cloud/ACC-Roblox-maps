-- BBYA Queen deck access hotfix v1.1
-- Compact side staircase. No long rails/beams crossing the room or camera sightline.

task.wait(3)

local old=workspace:FindFirstChild("BBYA Queen Access")
if old then old:Destroy() end

local throne=workspace:FindFirstChild("BBYA Queen Throne",true)
if not throne or not throne:IsA("BasePart") then
 warn("[BBYA] Queen access: throne not found")
 return
end

local model=Instance.new("Model")
model.Name="BBYA Queen Access"
model.Parent=workspace

-- Put the stairs tight to the OUTER LEFT side of the Queen platform.
-- Descend away from the lounge so nothing cuts across the center of the room.
local stepCount=6
local rise=0.95
local run=2.1
local width=6.2
local sideOffset=-8.5
local topOffsetZ=6.5
local topY=-1.15

for i=1,stepCount do
 local down=stepCount-i
 local p=Instance.new("Part")
 p.Name="Queen Stair "..i
 p.Anchored=true
 p.CanCollide=true
 p.Size=Vector3.new(width,.8,run+0.15)
 p.CFrame=throne.CFrame*CFrame.new(sideOffset,topY-down*rise,topOffsetZ+down*run)
 p.Material=Enum.Material.SmoothPlastic
 p.Color=Color3.fromRGB(31,26,42)
 p.Parent=model

 local edge=Instance.new("Part")
 edge.Name="Queen Stair Neon "..i
 edge.Anchored=true
 edge.CanCollide=false
 edge.Size=Vector3.new(width,.1,.14)
 edge.CFrame=p.CFrame*CFrame.new(0,.44,-p.Size.Z/2+.02)
 edge.Material=Enum.Material.Neon
 edge.Color=i%2==0 and Color3.fromRGB(48,210,255) or Color3.fromRGB(255,65,205)
 edge.Parent=model
end

-- Small landing only; no oversized platform.
local landing=Instance.new("Part")
landing.Name="Queen Access Landing"
landing.Anchored=true
landing.CanCollide=true
landing.Size=Vector3.new(7,0.8,5.5)
landing.CFrame=throne.CFrame*CFrame.new(sideOffset,topY,3.1)
landing.Material=Enum.Material.SmoothPlastic
landing.Color=Color3.fromRGB(29,24,40)
landing.Parent=model

-- Two short marker posts at the top only. No long rails.
for _,x in ipairs({-2.7,2.7}) do
 local post=Instance.new("Part")
 post.Name="Queen Access Marker"
 post.Anchored=true
 post.CanCollide=false
 post.Size=Vector3.new(.22,2.4,.22)
 post.CFrame=landing.CFrame*CFrame.new(x,1.55,-2.3)
 post.Material=Enum.Material.Neon
 post.Color=x<0 and Color3.fromRGB(48,210,255) or Color3.fromRGB(255,65,205)
 post.Parent=model
end

print("[BBYA] Queen deck staircase v1.1 compact layout created")