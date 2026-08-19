-- BBYA SOCIAL HUB — ENTRANCE VALIDATION BUILD v1.4
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

local C={black=Color3.fromRGB(9,8,12),charcoal=Color3.fromRGB(25,21,28),floor=Color3.fromRGB(71,58,63),pink=Color3.fromRGB(255,42,157),blue=Color3.fromRGB(0,174,255),warm=Color3.fromRGB(255,188,122),glass=Color3.fromRGB(50,34,55)}

local function part(name,size,cf,color,material,transparency)
 local p=Instance.new("Part");p.Name=name;p.Anchored=true;p.CanCollide=true;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0;p.Parent=model;return p
end
local function neon(name,size,cf,color)local p=part(name,size,cf,color or C.pink,Enum.Material.Neon,0);p.CanCollide=false;return p end
local function pointLight(parent,color,brightness,range)local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=true;l.Parent=parent end
local function fixedText(panel,text,font,canvasY,color)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.AlwaysOnTop=true;gui.LightInfluence=0;gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize;gui.CanvasSize=Vector2.new(2800,canvasY or 700);gui.Parent=panel
 local tc=color or C.pink
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=UDim2.fromScale(.01,.01);t.Size=UDim2.fromScale(.98,.98);t.Text=text;t.TextColor3=tc;t.TextScaled=true;t.Font=font;t.TextStrokeColor3=tc;t.TextStrokeTransparency=.16;t.Parent=gui
end
local function stroke(name,a,b,width)local mid=(a+b)/2;local p=neon(name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt(mid,b),C.pink);pointLight(p,C.pink,.5,10) end

part("ArrivalForecourt",Vector3.new(96,1,34),CFrame.new(0,0,-59),C.floor,Enum.Material.Slate)
part("EntryPad",Vector3.new(78,1,16),CFrame.new(0,0,-39),C.floor,Enum.Material.Slate)
part("FacadeLeft",Vector3.new(24,24,10),CFrame.new(-33,12,-39),C.black)
part("FacadeRight",Vector3.new(24,24,10),CFrame.new(33,12,-39),C.black)
part("FacadeHeader",Vector3.new(50,16,10),CFrame.new(0,26,-39),C.black)

part("PortalLeft",Vector3.new(3,15,3),CFrame.new(-22.5,7.5,-43.2),C.charcoal,Enum.Material.Metal)
part("PortalRight",Vector3.new(3,15,3),CFrame.new(22.5,7.5,-43.2),C.charcoal,Enum.Material.Metal)
part("PortalTop",Vector3.new(48,3,3),CFrame.new(0,15,-43.2),C.charcoal,Enum.Material.Metal)
neon("PortalPinkTop",Vector3.new(44,.25,.3),CFrame.new(0,13.6,-44.8),C.pink)

local gl=part("GlassLeft",Vector3.new(16,13,.45),CFrame.new(-33,7,-44.2),C.glass,Enum.Material.Glass,.22);gl.CanCollide=false
local gr=part("GlassRight",Vector3.new(16,13,.45),CFrame.new(33,7,-44.2),C.glass,Enum.Material.Glass,.22);gr.CanCollide=false

-- Branding remains on the validated SOUTH/front facade.
-- v1.4: larger lettering blocks with tighter vertical grouping.
local bbyaPanel=part("BBYASignPanel",Vector3.new(82,15,.35),CFrame.new(0,28.6,-44.35),C.black)
fixedText(bbyaPanel,"BBYA",Enum.Font.GothamBold,152,C.pink)
local socialPanel=part("SocialHubSignPanel",Vector3.new(60,7.2,.35),CFrame.new(0,21.8,-44.32),C.black)
fixedText(socialPanel,"SOCIAL HUB",Enum.Font.GothamMedium,149,C.pink)
local alwaysPanel=part("AlwaysOpenSignPanel",Vector3.new(60,7.2,.35),CFrame.new(0,16.5,-44.31),C.black)
fixedText(alwaysPanel,"24/7",Enum.Font.GothamMedium,149,C.blue)

local z=-44.7
local pts={Vector3.new(-7.5,36,z),Vector3.new(-6.2,41.3,z),Vector3.new(-2.5,38.2,z),Vector3.new(0,43.6,z),Vector3.new(2.5,38.2,z),Vector3.new(6.2,41.3,z),Vector3.new(7.5,36,z)}
for i=1,#pts-1 do stroke("CrownStroke"..i,pts[i],pts[i+1],.5) end
stroke("CrownBase",Vector3.new(-7.5,36,z),Vector3.new(7.5,36,z),.5)
stroke("CrownBase2",Vector3.new(-6.3,34.8,z),Vector3.new(6.3,34.8,z),.38)

for _,x in ipairs({-30,0,30}) do local w=neon("WarmFacade"..x,Vector3.new(7,.2,.35),CFrame.new(x,12,-44.5),C.warm);pointLight(w,C.warm,2.8,20) end
for _,x in ipairs({-16,16}) do local p=neon("PinkFacade"..x,Vector3.new(5,.18,.3),CFrame.new(x,17,-44.4),C.pink);pointLight(p,C.pink,1.8,14) end

local spawn=Instance.new("SpawnLocation");spawn.Name="EntranceSpawn";spawn.Anchored=true;spawn.Neutral=true;spawn.Size=Vector3.new(7,1,7);spawn.CFrame=CFrame.lookAt(Vector3.new(0,1,-66),Vector3.new(0,12,-44));spawn.Transparency=1;spawn.Parent=model

Lighting.ClockTime=20.2;Lighting.Brightness=3.2;Lighting.Ambient=Color3.fromRGB(72,52,72);Lighting.OutdoorAmbient=Color3.fromRGB(42,31,46);Lighting.EnvironmentDiffuseScale=.45;Lighting.EnvironmentSpecularScale=.5
for _,name in ipairs({"BBYAEntranceColor","BBYABloom"}) do local e=Lighting:FindFirstChild(name);if e then e:Destroy() end end
local cc=Instance.new("ColorCorrectionEffect");cc.Name="BBYAEntranceColor";cc.Brightness=.08;cc.Contrast=.03;cc.Saturation=.04;cc.TintColor=Color3.fromRGB(255,240,246);cc.Parent=Lighting
local bloom=Instance.new("BloomEffect");bloom.Name="BBYABloom";bloom.Intensity=.38;bloom.Size=24;bloom.Threshold=1.05;bloom.Parent=Lighting
print("[BBYA] Entrance validation v1.4: branding enlarged and vertical spacing tightened")