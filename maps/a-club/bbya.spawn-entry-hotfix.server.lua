-- BBYA Spawn / Entrance hotfix v1.1
-- Readable mobile-first arrival: compact neon box, large title, no giant empty black wall.

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

local spawn=nil
for _,o in ipairs(workspace:GetDescendants()) do
 if o:IsA("SpawnLocation") then spawn=o break end
end

if spawn then
 -- Keep a little more breathing room from the entrance.
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

-- Place the board close enough to read on mobile, but not in the player's face.
local baseCF
if spawn then
 baseCF=spawn.CFrame*CFrame.new(0,4.8,-9)
else
 baseCF=CFrame.new(0,5,48)
end

local back=makePart(model,"Neon Box Back",Vector3.new(22,6,.45),baseCF,Color3.fromRGB(8,8,14),Enum.Material.SmoothPlastic,0,false)
local cyan=Color3.fromRGB(45,220,255)
local pink=Color3.fromRGB(255,62,210)
local gold=Color3.fromRGB(255,204,88)

makePart(model,"Top Neon",Vector3.new(22.5,.18,.18),baseCF*CFrame.new(0,3.08,-.28),pink,Enum.Material.Neon,0,false)
makePart(model,"Bottom Neon",Vector3.new(22.5,.18,.18),baseCF*CFrame.new(0,-3.08,-.28),cyan,Enum.Material.Neon,0,false)
makePart(model,"Left Neon",Vector3.new(.18,6.2,.18),baseCF*CFrame.new(-11.12,0,-.28),cyan,Enum.Material.Neon,0,false)
makePart(model,"Right Neon",Vector3.new(.18,6.2,.18),baseCF*CFrame.new(11.12,0,-.28),pink,Enum.Material.Neon,0,false)

local gui=Instance.new("SurfaceGui")
gui.Name="BBYA Arrival Sign"
gui.Face=Enum.NormalId.Front
gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
gui.CanvasSize=Vector2.new(1200,330)
gui.LightInfluence=0
gui.AlwaysOnTop=true
gui.Parent=back

local crown=Instance.new("TextLabel")
crown.BackgroundTransparency=1
crown.Position=UDim2.fromScale(.03,.05)
crown.Size=UDim2.fromScale(.14,.28)
crown.Text="♛"
crown.TextColor3=gold
crown.TextStrokeTransparency=.2
crown.Font=Enum.Font.GothamBlack
crown.TextScaled=true
crown.Parent=gui

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromScale(.16,.05)
title.Size=UDim2.fromScale(.81,.46)
title.Text="BBYA SOCIAL HUB"
title.TextColor3=pink
title.TextStrokeTransparency=.08
title.Font=Enum.Font.GothamBlack
title.TextScaled=true
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=gui

local subtitle=Instance.new("TextLabel")
subtitle.BackgroundTransparency=1
subtitle.Position=UDim2.fromScale(.08,.53)
subtitle.Size=UDim2.fromScale(.84,.21)
subtitle.Text="MUSIC  •  DANCE  •  FRIENDS  •  VIBES"
subtitle.TextColor3=cyan
subtitle.TextStrokeTransparency=.22
subtitle.Font=Enum.Font.GothamBold
subtitle.TextScaled=true
subtitle.Parent=gui

local welcome=Instance.new("TextLabel")
welcome.BackgroundTransparency=1
welcome.Position=UDim2.fromScale(.22,.79)
welcome.Size=UDim2.fromScale(.56,.12)
welcome.Text="WELCOME TO THE NIGHT"
welcome.TextColor3=Color3.fromRGB(235,225,245)
welcome.TextStrokeTransparency=.35
welcome.Font=Enum.Font.GothamBold
welcome.TextScaled=true
welcome.Parent=gui

local line=Instance.new("Frame")
line.BorderSizePixel=0
line.Position=UDim2.fromScale(.18,.75)
line.Size=UDim2.fromScale(.64,.012)
line.BackgroundColor3=pink
line.Parent=gui
local grad=Instance.new("UIGradient")
grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,cyan),ColorSequenceKeypoint.new(.5,pink),ColorSequenceKeypoint.new(1,cyan)})
grad.Parent=line

print("[BBYA] Arrival sign v1.1 loaded: larger text, compact readable box")