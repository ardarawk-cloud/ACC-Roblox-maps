-- BBYA SOCIAL HUB — PREMIUM VENUE POLISH v4.1
-- Detail pass on top of Premium Visual Rebuild v4.
-- Uses existing anchors, so future layout movement does not require hard-coded world positions.

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local ROOT = "BBYA Premium Venue Polish v4.1"
local old = workspace:FindFirstChild(ROOT)
if old then old:Destroy() end

local root = Instance.new("Folder")
root.Name = ROOT
root.Parent = workspace

local C = {
 black = Color3.fromRGB(8, 8, 14),
 stone = Color3.fromRGB(34, 31, 39),
 stone2 = Color3.fromRGB(52, 46, 55),
 pink = Color3.fromRGB(255, 50, 180),
 purple = Color3.fromRGB(150, 72, 255),
 cyan = Color3.fromRGB(45, 220, 255),
 blue = Color3.fromRGB(50, 118, 255),
 gold = Color3.fromRGB(255, 196, 72),
 glass = Color3.fromRGB(78, 105, 135),
 wood = Color3.fromRGB(87, 60, 43),
 cream = Color3.fromRGB(220, 204, 190),
 green = Color3.fromRGB(35, 105, 68),
}

local function find(name)
 return workspace:FindFirstChild(name, true)
end

local function part(name, size, cf, color, material, transparency, collide, parent)
 local p = Instance.new("Part")
 p.Name = name
 p.Size = size
 p.CFrame = cf
 p.Anchored = true
 p.CanCollide = collide ~= false
 p.Material = material or Enum.Material.SmoothPlastic
 p.Color = color or C.stone
 p.Transparency = transparency or 0
 p.TopSurface = Enum.SurfaceType.Smooth
 p.BottomSurface = Enum.SurfaceType.Smooth
 p.Parent = parent or root
 return p
end

local function neon(name, size, cf, color, parent, brightness, range)
 local p = part(name, size, cf, color or C.pink, Enum.Material.Neon, 0, false, parent)
 local l = Instance.new("PointLight")
 l.Brightness = brightness or .7
 l.Range = range or 12
 l.Color = p.Color
 l.Shadows = false
 l.Parent = p
 return p
end

local function label(base, text, color, face)
 local g = Instance.new("SurfaceGui")
 g.Face = face or Enum.NormalId.Front
 g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
 g.PixelsPerStud = 26
 g.LightInfluence = 0
 g.Parent = base
 local t = Instance.new("TextLabel")
 t.Size = UDim2.fromScale(1,1)
 t.BackgroundTransparency = 1
 t.Text = text
 t.TextColor3 = color or C.pink
 t.TextStrokeTransparency = .25
 t.Font = Enum.Font.GothamBlack
 t.TextScaled = true
 t.Parent = g
 return t
end

local function sofa(parent, name, cf, color)
 local seat = Instance.new("Seat")
 seat.Name = name .. " Seat"
 seat.Size = Vector3.new(8, 1.4, 4)
 seat.CFrame = cf
 seat.Anchored = true
 seat.Material = Enum.Material.Fabric
 seat.Color = color or Color3.fromRGB(80, 46, 90)
 seat.Parent = parent
 part(name .. " Back", Vector3.new(8, 3.4, .8), cf * CFrame.new(0, 1.8, 1.65), seat.Color, Enum.Material.Fabric, 0, true, parent)
 part(name .. " Base", Vector3.new(8.8, .65, 4.6), cf * CFrame.new(0, -.65, 0), C.black, Enum.Material.Metal, 0, true, parent)
 return seat
end

local function palm(parent, name, cf, scale)
 scale = scale or 1
 local trunk = part(name .. " Trunk", Vector3.new(1.2, 8.5, 1.2) * scale, cf * CFrame.new(0, 4.25*scale, 0) * CFrame.Angles(0,0,math.rad(-4)), Color3.fromRGB(80,55,38), Enum.Material.Wood, 0, true, parent)
 for i=0,5 do
  part(name .. " Leaf " .. i, Vector3.new(.8,.25,6.5)*scale, cf * CFrame.new(0,8.6*scale,0) * CFrame.Angles(0,i*math.pi/3,math.rad(-18)), C.green, Enum.Material.SmoothPlastic, 0, false, parent)
 end
 return trunk
end

local function tableRound(parent, name, cf)
 local top = part(name .. " Top", Vector3.new(5.5,.55,5.5), cf, C.black, Enum.Material.Glass, .12, true, parent)
 top.Shape = Enum.PartType.Cylinder
 part(name .. " Stem", Vector3.new(.7,2.8,.7), cf*CFrame.new(0,-1.55,0), C.gold, Enum.Material.Metal, 0, true, parent)
 return top
end

-- Wait for main rebuild anchors.
task.wait(1)

-- ============================================================
-- MAIN CLUB DEPTH
-- ============================================================
local dance = find("Dance Floor")
local booth = find("DJ Booth")
if dance and dance:IsA("BasePart") then
 local f = Instance.new("Folder"); f.Name="Main Club Detail"; f.Parent=root
 local cf = dance.CFrame
 local sx, sz = dance.Size.X, dance.Size.Z

 -- Neon perimeter runway around the floor.
 neon("Dance Edge Front", Vector3.new(sx+.8,.18,.3), cf*CFrame.new(0,dance.Size.Y/2+.16,-sz/2-.2), C.pink, f, .6, 10)
 neon("Dance Edge Back", Vector3.new(sx+.8,.18,.3), cf*CFrame.new(0,dance.Size.Y/2+.16,sz/2+.2), C.cyan, f, .6, 10)
 neon("Dance Edge Left", Vector3.new(.3,.18,sz+.8), cf*CFrame.new(-sx/2-.2,dance.Size.Y/2+.16,0), C.purple, f, .6, 10)
 neon("Dance Edge Right", Vector3.new(.3,.18,sz+.8), cf*CFrame.new(sx/2+.2,dance.Size.Y/2+.16,0), C.blue, f, .6, 10)

 -- Ceiling truss grid + moving-color accent nodes.
 local rigY = dance.Size.Y/2 + 14
 for _, z in ipairs({-sz*.30, 0, sz*.30}) do
  part("Ceiling Truss Z "..z, Vector3.new(sx*.82,.35,.6), cf*CFrame.new(0,rigY,z), C.black, Enum.Material.Metal, 0, false, f)
 end
 for _, x in ipairs({-sx*.32,0,sx*.32}) do
  part("Ceiling Truss X "..x, Vector3.new(.6,.35,sz*.78), cf*CFrame.new(x,rigY,0), C.black, Enum.Material.Metal, 0, false, f)
 end
 local nodes={}
 for _,x in ipairs({-sx*.3,0,sx*.3}) do
  for _,z in ipairs({-sz*.27,0,sz*.27}) do
   local n=neon("Rig Node",Vector3.new(1.2,.35,1.2),cf*CFrame.new(x,rigY-.4,z),C.pink,f,.9,18)
   table.insert(nodes,n)
  end
 end
 task.spawn(function()
  local palette={C.pink,C.purple,C.cyan,C.blue,C.gold}
  local i=1
  while f.Parent do
   for k,n in ipairs(nodes) do
    local color=palette[((i+k-2)%#palette)+1]
    TweenService:Create(n,TweenInfo.new(.45),{Color=color}):Play()
    local l=n:FindFirstChildOfClass("PointLight"); if l then l.Color=color end
   end
   i=i%#palette+1
   task.wait(.7)
  end
 end)
end

if booth and booth:IsA("BasePart") then
 local f = Instance.new("Folder"); f.Name="DJ Detail"; f.Parent=root
 local cf=booth.CFrame
 -- layered console
 part("DJ Console Deck",Vector3.new(math.max(booth.Size.X*.75,14),1.1,3.2),cf*CFrame.new(0,2.0,-.6),C.black,Enum.Material.Metal,0,true,f)
 for x=-3,3 do
  if x~=0 then
   local platter=part("DJ Platter "..x,Vector3.new(3,.22,3),cf*CFrame.new(x*1.5,2.7,-.7),Color3.fromRGB(25,22,32),Enum.Material.Metal,0,false,f)
   platter.Shape=Enum.PartType.Cylinder
   neon("DJ Ring "..x,Vector3.new(3.2,.10,3.2),platter.CFrame*CFrame.new(0,.18,0),x<0 and C.cyan or C.pink,f,.6,6).Shape=Enum.PartType.Cylinder
  end
 end
 local sign=part("DJ Back Logo",Vector3.new(18,4,.45),cf*CFrame.new(0,7,4),C.black,Enum.Material.Metal,0,false,f)
 label(sign,"BBYA • 24/7",C.pink)
end

-- ============================================================
-- VIP LOUNGE DETAIL
-- ============================================================
for _, spec in ipairs({{"Left VIP Platform",-1,C.blue},{"Right VIP Platform",1,C.pink}}) do
 local anchor=find(spec[1])
 if anchor and anchor:IsA("BasePart") then
  local f=Instance.new("Folder");f.Name=spec[1].." Premium Booths";f.Parent=root
  local cf=anchor.CFrame
  for i=-1,1 do
   local boothCF=cf*CFrame.new(i*11,anchor.Size.Y/2+1.2,3)
   sofa(f,"VIP Booth "..i,boothCF,spec[2]<0 and Color3.fromRGB(38,55,95) or Color3.fromRGB(88,38,82))
   tableRound(f,"VIP Table "..i,boothCF*CFrame.new(0,1.6,-5.2))
   neon("VIP Booth Accent "..i,Vector3.new(8,.16,.16),boothCF*CFrame.new(0,3,2.1),spec[3],f,.45,8)
  end
  local rail=part("VIP Glass Rail",Vector3.new(math.max(anchor.Size.X-3,20),5,.3),cf*CFrame.new(0,anchor.Size.Y/2+3,-anchor.Size.Z/2+.5),C.glass,Enum.Material.Glass,.55,false,f)
  rail.CanQuery=false
 end
end

-- ============================================================
-- BAR WALL / SOCIAL DEPTH
-- ============================================================
local bar=find("BBYA Bar")
if bar and bar:IsA("BasePart") then
 local f=Instance.new("Folder");f.Name="Premium Bar Detail";f.Parent=root
 local cf=bar.CFrame
 part("Bar Back Wall",Vector3.new(bar.Size.X*.92,8,.7),cf*CFrame.new(0,5,5.2),C.black,Enum.Material.Slate,0,true,f)
 for y=2,6,2 do
  part("Bar Shelf "..y,Vector3.new(bar.Size.X*.82,.25,1.4),cf*CFrame.new(0,y+1.3,4.55),C.wood,Enum.Material.WoodPlanks,0,true,f)
 end
 local colors={C.pink,C.cyan,C.purple,C.gold,C.blue}
 local count=math.max(7,math.floor(bar.Size.X/2.6))
 for i=1,count do
  local x=((i-1)/(math.max(count-1,1))-.5)*(bar.Size.X*.72)
  local bottle=part("Neon Bottle "..i,Vector3.new(.55,1.7,.55),cf*CFrame.new(x,4.0+(i%3)*1.9,4.1),colors[(i-1)%#colors+1],Enum.Material.Glass,.15,false,f)
  local light=Instance.new("PointLight");light.Color=bottle.Color;light.Brightness=.25;light.Range=4;light.Parent=bottle
 end
 local barSign=part("Bar Logo",Vector3.new(14,2.8,.35),cf*CFrame.new(0,8.2,4.75),C.black,Enum.Material.Metal,0,false,f)
 label(barSign,"BBYA SKY BAR",C.gold)
end

-- ============================================================
-- ROOFTOP RESORT / POOL PARTY
-- ============================================================
local pool=find("Rooftop Pool")
if pool and pool:IsA("BasePart") then
 local f=Instance.new("Folder");f.Name="Rooftop Resort Detail";f.Parent=root
 local cf=pool.CFrame
 local sx,sz=pool.Size.X,pool.Size.Z

 -- infinity glow edge
 neon("Infinity Edge",Vector3.new(sx*.92,.18,.25),cf*CFrame.new(0,pool.Size.Y/2+.25,-sz/2-.15),C.cyan,f,.7,14)

 -- pairs of premium daybeds
 for _, side in ipairs({-1,1}) do
  for i=-2,2 do
   local bedCF=cf*CFrame.new(side*(sx/2+8),pool.Size.Y/2+1.0,i*8)*CFrame.Angles(0,side<0 and math.rad(90) or math.rad(-90),0)
   sofa(f,"Pool Daybed "..side.." "..i,bedCF,Color3.fromRGB(200,185,180))
   neon("Daybed Accent "..side.." "..i,Vector3.new(5.5,.12,.12),bedCF*CFrame.new(0,1.4,2.2),side<0 and C.pink or C.cyan,f,.25,5)
  end
 end

 -- two pergola cabanas on far side
 for _,x in ipairs({-sx*.3,sx*.3}) do
  local base=cf*CFrame.new(x,pool.Size.Y/2+1,sz/2+12)
  for _,dx in ipairs({-5,5}) do for _,dz in ipairs({-4,4}) do part("Cabana Post",Vector3.new(.6,8,.6),base*CFrame.new(dx,4,dz),C.wood,Enum.Material.Wood,0,true,f) end end
  part("Cabana Roof",Vector3.new(11,.55,9),base*CFrame.new(0,8,0),C.black,Enum.Material.Fabric,0,true,f)
  sofa(f,"Cabana Sofa",base*CFrame.new(0,1.0,2.2),Color3.fromRGB(70,48,76))
  neon("Cabana Strip",Vector3.new(10,.14,.14),base*CFrame.new(0,7.65,-4.2),x<0 and C.pink or C.purple,f,.45,7)
 end

 -- tropical framing palms
 for _,x in ipairs({-sx*.6,sx*.6}) do
  palm(f,"Rooftop Palm "..x,cf*CFrame.new(x,pool.Size.Y/2,sz/2+20),.9)
 end

 -- poolside logo backdrop
 local logo=part("Pool Party Logo",Vector3.new(28,5,.5),cf*CFrame.new(0,pool.Size.Y/2+7,sz/2+21),C.black,Enum.Material.Metal,0,false,f)
 label(logo,"BBYA POOL PARTY",C.pink)
end

-- ============================================================
-- CITY VIEW / SKYLINE GLOW
-- ============================================================
local rooftop=find("Rooftop Floor")
if rooftop and rooftop:IsA("BasePart") then
 local f=Instance.new("Folder");f.Name="Skyline Glow";f.Parent=root
 local cf=rooftop.CFrame
 local backZ=rooftop.Size.Z/2+35
 local rng=Random.new(417)
 for i=1,22 do
  local x=(-.5+(i-1)/21)*rooftop.Size.X*1.45
  local h=rng:NextNumber(18,52)
  local w=rng:NextNumber(5,10)
  local tower=part("Sky Tower "..i,Vector3.new(w,h,7),cf*CFrame.new(x,h/2-1,backZ+rng:NextNumber(-8,8)),Color3.fromRGB(13,18,30),Enum.Material.SmoothPlastic,0,true,f)
  for y=4,h-3,6 do
   neon("Sky Window",Vector3.new(w*.6,.16,.12),tower.CFrame*CFrame.new(0,-h/2+y,-3.56),i%3==0 and C.pink or C.cyan,f,.08,2)
  end
 end
end

-- ============================================================
-- LIGHTING FINISH
-- ============================================================
local bloom=Lighting:FindFirstChild("BBYA_PremiumBloom") or Instance.new("BloomEffect")
bloom.Name="BBYA_PremiumBloom";bloom.Intensity=.75;bloom.Size=28;bloom.Threshold=1.05;bloom.Parent=Lighting
local cc=Lighting:FindFirstChild("BBYA_PremiumColor") or Instance.new("ColorCorrectionEffect")
cc.Name="BBYA_PremiumColor";cc.Brightness=.03;cc.Contrast=.12;cc.Saturation=.08;cc.TintColor=Color3.fromRGB(245,235,255);cc.Parent=Lighting

workspace:SetAttribute("BBYAPremiumPolish","4.1")
print("[BBYA] Premium Venue Polish v4.1 loaded")
