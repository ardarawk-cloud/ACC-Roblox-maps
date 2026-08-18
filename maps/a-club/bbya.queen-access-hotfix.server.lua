-- BBYA Queen deck access hotfix v1.0
-- Builds a compact staircase relative to the Queen throne so the elevated seating is reachable.

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

-- Build stairs on the outer/left side of the throne so they do not cut through the lounge.
local stepCount=7
local rise=1.15
local run=3.0
local width=8
local base=throne.CFrame*CFrame.new(-10,-(stepCount*rise)+1,-8)

for i=1,stepCount do
 local p=Instance.new("Part")
 p.Name="Queen Stair "..i
 p.Anchored=true
 p.CanCollide=true
 p.Size=Vector3.new(width,1,run+0.5)
 p.CFrame=base*CFrame.new(0,i*rise,(i-1)*run)
 p.Material=Enum.Material.SmoothPlastic
 p.Color=Color3.fromRGB(34,28,46)
 p.Parent=model

 local edge=Instance.new("Part")
 edge.Name="Queen Stair Neon "..i
 edge.Anchored=true
 edge.CanCollide=false
 edge.Size=Vector3.new(width,.12,.18)
 edge.CFrame=p.CFrame*CFrame.new(0,.56,-p.Size.Z/2-.02)
 edge.Material=Enum.Material.Neon
 edge.Color=i%2==0 and Color3.fromRGB(45,205,255) or Color3.fromRGB(255,65,200)
 edge.Parent=model
end

-- Landing connects the last stair to the Queen seating level.
local landing=Instance.new("Part")
landing.Name="Queen Access Landing"
landing.Anchored=true
landing.CanCollide=true
landing.Size=Vector3.new(12,1,10)
landing.CFrame=throne.CFrame*CFrame.new(-10,-1.2,10)
landing.Material=Enum.Material.SmoothPlastic
landing.Color=Color3.fromRGB(30,24,42)
landing.Parent=model

local railColor=Color3.fromRGB(255,70,205)
for _,x in ipairs({-width/2-0.35,width/2+0.35}) do
 local rail=Instance.new("Part")
 rail.Name="Queen Access Rail"
 rail.Anchored=true
 rail.CanCollide=false
 rail.Size=Vector3.new(.25,3,stepCount*run+4)
 rail.CFrame=base*CFrame.new(x,stepCount*rise/2+1.5,(stepCount-1)*run/2)
 rail.Material=Enum.Material.Metal
 rail.Color=Color3.fromRGB(45,40,55)
 rail.Parent=model

 local neon=Instance.new("Part")
 neon.Name="Queen Access Rail Neon"
 neon.Anchored=true
 neon.CanCollide=false
 neon.Size=Vector3.new(.12,.12,stepCount*run+4)
 neon.CFrame=rail.CFrame*CFrame.new(0,1.55,0)
 neon.Material=Enum.Material.Neon
 neon.Color=railColor
 neon.Parent=model
end

print("[BBYA] Queen deck staircase created")