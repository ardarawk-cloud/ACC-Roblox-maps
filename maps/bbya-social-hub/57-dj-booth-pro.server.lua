-- BBYA SOCIAL HUB — PROFESSIONAL DJ BOOTH v1
-- Rebuilds only the DJ booth presentation using deterministic Roblox-native geometry.
-- Keeps Floor1Features/DJ request interaction positions intact.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local club=root:WaitForChild("MainClubRealism",20)
if not club then warn("[BBYA] Pro DJ Booth: MainClubRealism missing");return end
local av=club:FindFirstChild("AudioVisual")
if not av then warn("[BBYA] Pro DJ Booth: AudioVisual missing");return end

local architecture=club:FindFirstChild("Architecture")
local old=av:FindFirstChild("DJBoothPremium")
if old then old:Destroy() end
for _,name in ipairs({"MonitorCab1","MonitorCab2","MonitorDriver1","MonitorDriver2"}) do
 local obj=av:FindFirstChild(name)
 if obj then obj:Destroy() end
end

local booth=Instance.new("Model")
booth.Name="DJBoothPremium"
booth:SetAttribute("Pass","PRO_DJ_BOOTH_V1")
booth.Parent=av

local C={
 black=Color3.fromRGB(6,6,8),
 ink=Color3.fromRGB(13,13,17),
 graphite=Color3.fromRGB(28,28,34),
 metal=Color3.fromRGB(58,59,66),
 silver=Color3.fromRGB(128,130,138),
 white=Color3.fromRGB(218,216,220),
 pink=Color3.fromRGB(255,39,154),
 cyan=Color3.fromRGB(0,216,234),
 gold=Color3.fromRGB(235,190,92),
 yellow=Color3.fromRGB(208,219,75),
 blue=Color3.fromRGB(76,151,238),
}

local function part(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true;p.CastShadow=true
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or booth
 return p
end
local function cyl(name,size,cf,color,material,parent)
 local p=part(name,size,cf,color,material or Enum.Material.SmoothPlastic,0,parent,false);p.Shape=Enum.PartType.Cylinder;return p
end
local function neon(name,size,cf,color,parent,transparency)
 local p=part(name,size,cf,color,Enum.Material.Neon,transparency or 0,parent,false);p.CastShadow=false;return p
end
local function model(name,parent)local m=Instance.new("Model");m.Name=name;m.Parent=parent or booth;return m end
local function roundGui(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=o end

-- BASE / CABINET ---------------------------------------------------------------
-- Main cabinet inspired by modular real-world DJ furniture, scaled for Roblox avatars.
part("DJPlatform",Vector3.new(25,.55,9.2),CFrame.new(3,3.42,34.0),C.black,Enum.Material.Metal,0,booth,true)
part("CabinetShell",Vector3.new(22.8,3.3,4.4),CFrame.new(3,5.05,31.9),C.ink,Enum.Material.Metal,0,booth,true)
part("CounterTop",Vector3.new(23.6,.28,5.15),CFrame.new(3,6.82,31.9),Color3.fromRGB(103,102,109),Enum.Material.Marble,0,booth,false)
part("FrontPlinth",Vector3.new(23.2,.34,.48),CFrame.new(3,3.52,29.56),C.black,Enum.Material.Metal,0,booth,false)

-- Open cubbies on the audience-facing side.
local cubbyY=4.85
local cubbyZ=29.60
for i=0,5 do
 local x=-7.0+i*4.0
 part("CubbieBack"..i,Vector3.new(3.45,2.38,.18),CFrame.new(x,cubbyY,30.28),Color3.fromRGB(24,24,29),Enum.Material.SmoothPlastic,0,booth,false)
 part("CubbieFloor"..i,Vector3.new(3.55,.16,1.50),CFrame.new(x,3.76,29.72),Color3.fromRGB(39,39,45),Enum.Material.SmoothPlastic,0,booth,false)
 if i<5 then part("Divider"..i,Vector3.new(.16,2.55,1.7),CFrame.new(x+2,cubbyY,29.68),C.metal,Enum.Material.Metal,0,booth,false) end
end
local frontAccent=neon("FrontAccent",Vector3.new(18.6,.08,.08),CFrame.new(3,6.22,29.46),C.pink,booth,.08)
local accentLight=Instance.new("PointLight");accentLight.Color=C.pink;accentLight.Brightness=.28;accentLight.Range=7;accentLight.Shadows=false;accentLight.Parent=frontAccent

-- PRIMARY DJ CONSOLE -----------------------------------------------------------
local gear=model("DJEquipment",booth)
part("ConsoleBase",Vector3.new(15.8,.34,3.2),CFrame.new(3,7.10,31.7),C.black,Enum.Material.Metal,0,gear,false)

-- Left/right media decks.
for side,x in ipairs({-1.9,7.9}) do
 local deck=part("Deck"..side,Vector3.new(4.7,.34,3.15),CFrame.new(x,7.31,31.68),Color3.fromRGB(20,20,24),Enum.Material.Metal,0,gear,false)
 local jog=cyl("JogWheel"..side,Vector3.new(.16,2.35,2.35),CFrame.new(x,7.55,31.68)*CFrame.Angles(0,0,math.rad(90)),C.silver,Enum.Material.Metal,gear)
 jog.Reflectance=.25
 cyl("JogInner"..side,Vector3.new(.17,1.72,1.72),CFrame.new(x,7.57,31.68)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(25,25,29),Enum.Material.SmoothPlastic,gear)
 neon("DeckScreen"..side,Vector3.new(1.22,.055,.62),CFrame.new(x+1.35,7.55,30.82),side==1 and C.cyan or C.pink,gear,.08)
 for b=1,4 do
  neon("DeckButton"..side.."_"..b,Vector3.new(.28,.07,.22),CFrame.new(x-1.62+(b-1)*.42,7.55,30.58),b%2==0 and C.gold or (side==1 and C.cyan or C.pink),gear,.04)
 end
end

-- Central 4-channel mixer.
part("Mixer",Vector3.new(5.0,.36,3.08),CFrame.new(3,7.33,31.68),Color3.fromRGB(15,15,19),Enum.Material.Metal,0,gear,false)
for channel=1,4 do
 local x=1.65+(channel-1)*.90
 for row=1,3 do
  cyl("Knob_"..channel.."_"..row,Vector3.new(.11,.18,.18),CFrame.new(x,7.59,30.85+(row-1)*.43)*CFrame.Angles(0,0,math.rad(90)),row==1 and C.cyan or (row==2 and C.pink or C.gold),Enum.Material.Neon,gear)
 end
 part("FaderSlot"..channel,Vector3.new(.09,.045,.78),CFrame.new(x,7.57,32.28),Color3.fromRGB(80,80,86),Enum.Material.Metal,0,gear,false)
 part("Fader"..channel,Vector3.new(.34,.12,.22),CFrame.new(x,7.64,32.15+((channel%2==0) and .18 or -.10)),C.silver,Enum.Material.Metal,0,gear,false)
end
neon("MixerMeterL",Vector3.new(.10,.07,1.2),CFrame.new(2.72,7.58,31.55),C.cyan,gear,.05)
neon("MixerMeterR",Vector3.new(.10,.07,1.2),CFrame.new(3.28,7.58,31.55),C.pink,gear,.05)

-- SECONDARY SHELF / LAPTOP -----------------------------------------------------
local shelf=model("TechShelf",booth)
part("ShelfTop",Vector3.new(17.8,.24,2.8),CFrame.new(3,8.55,34.35),Color3.fromRGB(88,87,94),Enum.Material.Metal,0,shelf,false)
for _,x in ipairs({-4.8,10.8}) do
 part("ShelfPost",Vector3.new(.38,1.65,.38),CFrame.new(x,7.75,34.35),C.metal,Enum.Material.Metal,0,shelf,false)
end

-- Laptop body and luminous BBYA screen.
part("LaptopBase",Vector3.new(4.5,.18,2.25),CFrame.new(3,8.76,34.15),C.silver,Enum.Material.Metal,0,shelf,false)
local laptopScreen=part("LaptopScreen",Vector3.new(4.45,2.75,.18),CFrame.new(3,10.05,35.05)*CFrame.Angles(math.rad(-9),0,0),Color3.fromRGB(12,12,18),Enum.Material.SmoothPlastic,0,shelf,false)
local lgui=Instance.new("SurfaceGui");lgui.Face=Enum.NormalId.Front;lgui.AlwaysOnTop=true;lgui.LightInfluence=0;lgui.PixelsPerStud=55;lgui.Parent=laptopScreen
local lf=Instance.new("Frame");lf.Size=UDim2.fromScale(1,1);lf.BackgroundColor3=Color3.fromRGB(12,9,20);lf.BorderSizePixel=0;lf.Parent=lgui
local grad=Instance.new("UIGradient");grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(90,19,73)),ColorSequenceKeypoint.new(.52,Color3.fromRGB(21,23,42)),ColorSequenceKeypoint.new(1,Color3.fromRGB(5,64,73))});grad.Rotation=25;grad.Parent=lf
local txt=Instance.new("TextLabel");txt.Size=UDim2.fromScale(1,1);txt.BackgroundTransparency=1;txt.Text="BBYA\nDJ SYSTEM";txt.TextColor3=C.white;txt.Font=Enum.Font.GothamBlack;txt.TextScaled=true;txt.Parent=lf

-- Performance pad controller and compact side tablet.
part("PadController",Vector3.new(3.3,.22,2.2),CFrame.new(-3.0,8.76,34.2),Color3.fromRGB(18,18,22),Enum.Material.Metal,0,shelf,false)
for r=0,3 do for c=0,3 do
 neon("Pad_"..r.."_"..c,Vector3.new(.47,.07,.38),CFrame.new(-4.05+c*.68,8.91,33.50+r*.43),((r+c)%3==0) and C.pink or (((r+c)%3==1) and C.cyan or C.gold),shelf,.10)
end end
local tablet=part("Tablet",Vector3.new(2.4,.15,1.65),CFrame.new(8.2,8.80,34.2)*CFrame.Angles(math.rad(-5),0,0),Color3.fromRGB(22,22,27),Enum.Material.SmoothPlastic,0,shelf,false)
local tgui=Instance.new("SurfaceGui");tgui.Face=Enum.NormalId.Top;tgui.AlwaysOnTop=true;tgui.LightInfluence=0;tgui.PixelsPerStud=40;tgui.Parent=tablet
local tl=Instance.new("TextLabel");tl.Size=UDim2.fromScale(1,1);tl.BackgroundColor3=Color3.fromRGB(10,30,37);tl.Text="CUE / FX";tl.TextColor3=C.cyan;tl.Font=Enum.Font.GothamBold;tl.TextScaled=true;tl.Parent=tgui;roundGui(tl,5)

-- DJ MONITOR SPEAKERS ----------------------------------------------------------
local function monitor(name,x,accent)
 local m=model(name,booth)
 local cab=part("Cabinet",Vector3.new(3.5,4.5,3.15),CFrame.new(x,10.40,34.70)*CFrame.Angles(math.rad(-4),0,0),C.black,Enum.Material.Metal,0,m,false)
 part("StandBase",Vector3.new(2.1,.26,2.0),CFrame.new(x,8.72,34.65),C.metal,Enum.Material.Metal,0,m,false)
 part("StandStem",Vector3.new(.34,2.35,.34),CFrame.new(x,9.20,34.65),C.metal,Enum.Material.Metal,0,m,false)
 cyl("Woofer",Vector3.new(.18,1.95,1.95),CFrame.new(x,10.05,33.09)*CFrame.Angles(0,0,math.rad(90)),accent,Enum.Material.SmoothPlastic,m)
 cyl("WooferInner",Vector3.new(.19,1.18,1.18),CFrame.new(x,10.05,32.98)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(18,18,21),Enum.Material.SmoothPlastic,m)
 cyl("Tweeter",Vector3.new(.17,.72,.72),CFrame.new(x,11.52,33.09)*CFrame.Angles(0,0,math.rad(90)),C.graphite,Enum.Material.SmoothPlastic,m)
 neon("PowerLED",Vector3.new(.18,.06,.18),CFrame.new(x-.95,8.65,33.12),C.cyan,m,.05)
end
monitor("MonitorLeft",-7.7,C.yellow)
monitor("MonitorRight",13.7,C.yellow)

-- Cable channel / rear tech details.
part("CableTray",Vector3.new(15.0,.22,.68),CFrame.new(3,7.05,34.15),C.black,Enum.Material.Metal,0,booth,false)
for i=1,6 do
 local color=(i%2==0) and C.cyan or C.pink
 neon("StatusLED"..i,Vector3.new(.16,.07,.16),CFrame.new(.9+i*.60,7.23,34.46),color,booth,.08)
end

print("[BBYA] Professional DJ Booth v1 online: dual decks + mixer + laptop shelf + monitor speakers")
