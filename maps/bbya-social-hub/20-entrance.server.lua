-- BBYA SOCIAL HUB — ENTRANCE VALIDATION BUILD v1.0
-- Scope lock: FACADE + OPENING + SIGNAGE/CROWN + LIGHTING ONLY.
local Workspace=game:GetService("Workspace")
local Lighting=game:GetService("Lighting")

local root=Workspace:FindFirstChild("BBYA_ZERO_BUILD") or Instance.new("Folder")
root.Name="BBYA_ZERO_BUILD"
root.Parent=Workspace

local old=root:FindFirstChild("Entrance")
if old then old:Destroy() end

local model=Instance.new("Model")
model.Name="Entrance"
model.Parent=root

local C={
 black=Color3.fromRGB(9,8,12),
 charcoal=Color3.fromRGB(25,21,28),
 floor=Color3.fromRGB(71,58,63),
 pink=Color3.fromRGB(255,42,157),
 warm=Color3.fromRGB(255,188,122),
 glass=Color3.fromRGB(50,34,55),
}

local function part(name,size,cf,color,material,transparency)
 local p=Instance.new("Part")
 p.Name=name
 p.Anchored=true
 p.CanCollide=true
 p.Size=size
 p.CFrame=cf
 p.Color=color
 p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0
 p.Parent=model
 return p
end

local function neon(name,size,cf,color)
 local p=part(name,size,cf,color or C.pink,Enum.Material.Neon,0)
 p.CanCollide=false
 return p
end

local function pointLight(parent,color,brightness,range)
 local l=Instance.new("PointLight")
 l.Color=color
 l.Brightness=brightness
 l.Range=range
 l.Shadows=true
 l.Parent=parent
end

local function fixedText(panel,text,font)
 for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
  local gui=Instance.new("SurfaceGui")
  gui.Face=face
  gui.AlwaysOnTop=true
  gui.LightInfluence=0
  gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
  gui.CanvasSize=Vector2.new(2200,500)
  gui.Parent=panel

  local t=Instance.new("TextLabel")
  t.BackgroundTransparency=1
  t.Size=UDim2.fromScale(1,1)
  t.Text=text
  t.TextColor3=C.pink
  t.TextScaled=true
  t.Font=font
  t.TextStrokeColor3=C.pink
  t.TextStrokeTransparency=.25
  t.Parent=gui
 end
end

local function stroke(name,a,b,width)
 local mid=(a+b)/2
 local p=neon(name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt(mid,b),C.pink)
 pointLight(p,C.pink,.5,10)
end

-- 1) FORECOURT / CAMERA REFERENCE
part("ArrivalForecourt",Vector3.new(96,1,34),CFrame.new(0,0,-59),C.floor,Enum.Material.Slate)
part("EntryPad",Vector3.new(78,1,16),CFrame.new(0,0,-39),C.floor,Enum.Material.Slate)

-- 2) SIMPLE FACADE MASSING: one clear premium frontage, no extra rooms yet
part("FacadeLeft",Vector3.new(24,24,10),CFrame.new(-33,12,-39),C.black)
part("FacadeRight",Vector3.new(24,24,10),CFrame.new(33,12,-39),C.black)
part("FacadeHeader",Vector3.new(42,12,10),CFrame.new(0,24,-39),C.black)

-- central portal opening 42w x 15h
part("PortalLeft",Vector3.new(3,15,3),CFrame.new(-22.5,7.5,-33.8),C.charcoal,Enum.Material.Metal)
part("PortalRight",Vector3.new(3,15,3),CFrame.new(22.5,7.5,-33.8),C.charcoal,Enum.Material.Metal)
part("PortalTop",Vector3.new(48,3,3),CFrame.new(0,15,-33.8),C.charcoal,Enum.Material.Metal)
neon("PortalPinkTop",Vector3.new(44,.25,.3),CFrame.new(0,13.6,-32.2),C.pink)

-- side glass keeps facade from reading as a black box
local gl=part("GlassLeft",Vector3.new(16,13,.45),CFrame.new(-33,7,-32.8),C.glass,Enum.Material.Glass,.22);gl.CanCollide=false
local gr=part("GlassRight",Vector3.new(16,13,.45),CFrame.new(33,7,-32.8),C.glass,Enum.Material.Glass,.22);gr.CanCollide=false

-- 3) BRANDING: fixed to wall, large, no camera-follow behavior
local bbyaPanel=part("BBYASignPanel",Vector3.new(64,10,.35),CFrame.new(0,28.5,-33.15),C.black)
fixedText(bbyaPanel,"BBYA",Enum.Font.GothamBold)
local socialPanel=part("SocialHubSignPanel",Vector3.new(44,4.5,.35),CFrame.new(0,21.5,-33.12),C.black)
fixedText(socialPanel,"SOCIAL HUB",Enum.Font.GothamMedium)

-- crown geometry only
local z=-32.7
local pts={
 Vector3.new(-7,35.5,z),Vector3.new(-5.8,40.5,z),Vector3.new(-2.4,37.8,z),
 Vector3.new(0,42.5,z),Vector3.new(2.4,37.8,z),Vector3.new(5.8,40.5,z),Vector3.new(7,35.5,z)
}
for i=1,#pts-1 do stroke("CrownStroke"..i,pts[i],pts[i+1],.48) end
stroke("CrownBase",Vector3.new(-7,35.5,z),Vector3.new(7,35.5,z),.48)
stroke("CrownBase2",Vector3.new(-6,34.5,z),Vector3.new(6,34.5,z),.35)

-- 4) LIGHTING ONLY: enough to read the architecture
for _,x in ipairs({-30,0,30}) do
 local w=neon("WarmFacade"..x,Vector3.new(7,.2,.35),CFrame.new(x,12,-32.5),C.warm)
 pointLight(w,C.warm,2.8,20)
end
for _,x in ipairs({-16,16}) do
 local p=neon("PinkFacade"..x,Vector3.new(5,.18,.3),CFrame.new(x,17,-32.4),C.pink)
 pointLight(p,C.pink,1.8,14)
end

-- spawn locked to direct frontal validation view
local spawn=Instance.new("SpawnLocation")
spawn.Name="EntranceSpawn"
spawn.Anchored=true
spawn.Neutral=true
spawn.Size=Vector3.new(7,1,7)
spawn.CFrame=CFrame.lookAt(Vector3.new(0,1,-66),Vector3.new(0,12,-34))
spawn.Transparency=1
spawn.Parent=model

Lighting.ClockTime=20.2
Lighting.Brightness=3.2
Lighting.Ambient=Color3.fromRGB(72,52,72)
Lighting.OutdoorAmbient=Color3.fromRGB(42,31,46)
Lighting.EnvironmentDiffuseScale=.45
Lighting.EnvironmentSpecularScale=.5

for _,name in ipairs({"BBYAEntranceColor","BBYABloom"}) do
 local e=Lighting:FindFirstChild(name)
 if e then e:Destroy() end
end

local cc=Instance.new("ColorCorrectionEffect")
cc.Name="BBYAEntranceColor"
cc.Brightness=.08
cc.Contrast=.03
cc.Saturation=.04
cc.TintColor=Color3.fromRGB(255,240,246)
cc.Parent=Lighting

local bloom=Instance.new("BloomEffect")
bloom.Name="BBYABloom"
bloom.Intensity=.38
bloom.Size=24
bloom.Threshold=1.05
bloom.Parent=Lighting

print("[BBYA] Entrance validation v1.0 loaded: facade/opening/signage/crown/lighting only")