-- BBYA Spawn / Entrance hotfix v1.0
-- Moves the active respawn slightly backward and adds a premium neon BBYA SOCIAL HUB box at arrival.

task.wait(2)

local function makePart(parent,name,size,cf,color,material,transparency,collide)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=cf
 p.Anchored=true
 p.CanCollide=collide==true
 p.Material=material or Enum.Material.SmoothPlastic
 p.Color=color
 p.Transparency=transparency or 0
 p.Parent=parent
 return p
end

-- Find the current respawn/spawn and move it backward relative to its facing direction.
local spawn=nil
for _,o in ipairs(workspace:GetDescendants()) do
 if o:IsA("SpawnLocation") then
  spawn=o
  break
 end
end

if spawn then
 spawn.CFrame=spawn.CFrame*CFrame.new(0,0,10)
 spawn.Size=Vector3.new(math.max(spawn.Size.X,8),spawn.Size.Y,math.max(spawn.Size.Z,8))
 spawn.Transparency=1
 spawn.CanCollide=false
 spawn.Neutral=true
end

local old=workspace:FindFirstChild("BBYA Arrival Neon Box")
if old then old:Destroy() end

local model=Instance.new("Model")
model.Name="BBYA Arrival Neon Box"
model.Parent=workspace

local baseCF
if spawn then
 -- Put the sign in front of the player after the spawn has been moved backward.
 baseCF=spawn.CFrame*CFrame.new(0,5,-13)
else
 baseCF=CFrame.new(0,6,48)
end

local back=makePart(model,"Neon Box Back",Vector3.new(28,9,.6),baseCF,Color3.fromRGB(8,8,15),Enum.Material.SmoothPlastic,0,false)
local trimColorA=Color3.fromRGB(45,210,255)
local trimColorB=Color3.fromRGB(255,60,205)

-- Neon frame
makePart(model,"Top Neon",Vector3.new(28.6,.22,.25),baseCF*CFrame.new(0,4.55,-.36),trimColorB,Enum.Material.Neon,0,false)
makePart(model,"Bottom Neon",Vector3.new(28.6,.22,.25),baseCF*CFrame.new(0,-4.55,-.36),trimColorA,Enum.Material.Neon,0,false)
makePart(model,"Left Neon",Vector3.new(.22,9.2,.25),baseCF*CFrame.new(-14.15,0,-.36),trimColorA,Enum.Material.Neon,0,false)
makePart(model,"Right Neon",Vector3.new(.22,9.2,.25),baseCF*CFrame.new(14.15,0,-.36),trimColorB,Enum.Material.Neon,0,false)

local gui=Instance.new("SurfaceGui")
gui.Name="BBYA Arrival Sign"
gui.Face=Enum.NormalId.Front
gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
gui.PixelsPerStud=32
gui.LightInfluence=0
gui.Parent=back

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromScale(.05,.15)
title.Size=UDim2.fromScale(.9,.36)
title.Text="BBYA SOCIAL HUB"
title.TextColor3=Color3.fromRGB(255,92,218)
title.TextStrokeTransparency=.25
title.Font=Enum.Font.GothamBlack
title.TextScaled=true
title.Parent=gui

local sub=Instance.new("TextLabel")
sub.BackgroundTransparency=1
sub.Position=UDim2.fromScale(.08,.56)
sub.Size=UDim2.fromScale(.84,.18)
sub.Text="MUSIC  •  DANCE  •  FRIENDS  •  VIBES"
sub.TextColor3=Color3.fromRGB(70,220,255)
sub.TextStrokeTransparency=.45
sub.Font=Enum.Font.GothamBold
sub.TextScaled=true
sub.Parent=gui

local line=Instance.new("Frame")
line.BorderSizePixel=0
line.Position=UDim2.fromScale(.19,.81)
line.Size=UDim2.fromScale(.62,.018)
line.BackgroundColor3=Color3.fromRGB(255,65,205)
line.Parent=gui
local grad=Instance.new("UIGradient")
grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,trimColorA),ColorSequenceKeypoint.new(.5,trimColorB),ColorSequenceKeypoint.new(1,trimColorA)})
grad.Parent=line

print("[BBYA] Respawn moved backward and arrival neon box added")