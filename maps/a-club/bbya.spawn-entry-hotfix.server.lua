-- BBYA Spawn / Entrance hotfix v1.2
-- Keep board placement/size unchanged; maximize text readability on the wide screen.

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
 baseCF=spawn.CFrame*CFrame.new(0,4.8,-9)
else
 baseCF=CFrame.new(0,5,48)
end

-- KEEP board dimensions/placement exactly as v1.1.
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

-- Small crown accent only; do not waste the wide screen.
local crown=Instance.new("TextLabel")
crown.BackgroundTransparency=1
crown.Position=UDim2.fromScale(.015,.08)
crown.Size=UDim2.fromScale(.09,.25)
crown.Text="♛"
crown.TextColor3=gold
crown.TextStrokeTransparency=.15
crown.Font=Enum.Font.GothamBlack
crown.TextScaled=true
crown.Parent=gui

-- Main title now dominates almost the full width of the screen.
local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromScale(.09,.015)
title.Size=UDim2.fromScale(.89,.52)
title.Text="BBYA SOCIAL HUB"
title.TextColor3=pink
title.TextStrokeTransparency=.04
title.Font=Enum.Font.GothamBlack
title.TextScaled=true
title.TextXAlignment=Enum.TextXAlignment.Center
title.Parent=gui

local subtitle=Instance.new("TextLabel")
subtitle.BackgroundTransparency=1
subtitle.Position=UDim2.fromScale(.035,.54)
subtitle.Size=UDim2.fromScale(.93,.24)
subtitle.Text="MUSIC  •  DANCE  •  FRIENDS  •  VIBES"
subtitle.TextColor3=cyan
subtitle.TextStrokeTransparency=.15
subtitle.Font=Enum.Font.GothamBlack
subtitle.TextScaled=true
subtitle.TextXAlignment=Enum.TextXAlignment.Center
subtitle.Parent=gui

local line=Instance.new("Frame")
line.BorderSizePixel=0
line.Position=UDim2.fromScale(.08,.79)
line.Size=UDim2.fromScale(.84,.014)
line.BackgroundColor3=pink
line.Parent=gui
local grad=Instance.new("UIGradient")
grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,cyan),ColorSequenceKeypoint.new(.5,pink),ColorSequenceKeypoint.new(1,cyan)})
grad.Parent=line

local welcome=Instance.new("TextLabel")
welcome.BackgroundTransparency=1
welcome.Position=UDim2.fromScale(.11,.815)
welcome.Size=UDim2.fromScale(.78,.15)
welcome.Text="WELCOME TO THE NIGHT"
welcome.TextColor3=Color3.fromRGB(245,238,250)
welcome.TextStrokeTransparency=.22
welcome.Font=Enum.Font.GothamBlack
welcome.TextScaled=true
welcome.TextXAlignment=Enum.TextXAlignment.Center
welcome.Parent=gui

print("[BBYA] Arrival sign v1.2 loaded: same location, much larger text")