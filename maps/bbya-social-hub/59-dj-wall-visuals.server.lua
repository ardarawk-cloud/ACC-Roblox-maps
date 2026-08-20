-- BBYA SOCIAL HUB — DJ WALL RANDOM VISUALS v1
-- Presentation-only overlay for IdleVisuals. Message mode remains owned by 50-dj-wall-message.server.lua.

local Workspace=game:GetService("Workspace")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local system=root:WaitForChild("DJWallMessageSystem",20)
if not system then return end
local screen=system:FindFirstChild("PrestigeLED",true)
if not screen then return end
local gui=screen:FindFirstChild("DJWallUI")
if not gui then return end
local bg=gui:FindFirstChildWhichIsA("Frame")
if not bg then return end
local idle=bg:FindFirstChild("IdleVisuals")
if not idle then return end

local old=idle:FindFirstChild("BBYARandomVisuals")
if old then old:Destroy() end

local C={
 black=Color3.fromRGB(4,4,8),ink=Color3.fromRGB(10,8,15),pink=Color3.fromRGB(255,38,155),
 cyan=Color3.fromRGB(0,210,238),gold=Color3.fromRGB(238,190,94),white=Color3.fromRGB(245,243,248),
 muted=Color3.fromRGB(115,108,128),purple=Color3.fromRGB(115,62,219),green=Color3.fromRGB(62,205,124),
}

local rootFrame=Instance.new("Frame")
rootFrame.Name="BBYARandomVisuals"
rootFrame.Size=UDim2.fromScale(1,1)
rootFrame.BackgroundColor3=C.black
rootFrame.BorderSizePixel=0
rootFrame.ZIndex=20
rootFrame.Parent=idle
local rootGrad=Instance.new("UIGradient")
rootGrad.Color=ColorSequence.new({
 ColorSequenceKeypoint.new(0,Color3.fromRGB(37,5,31)),
 ColorSequenceKeypoint.new(.52,Color3.fromRGB(5,5,10)),
 ColorSequenceKeypoint.new(1,Color3.fromRGB(3,31,37)),
})
rootGrad.Rotation=8
rootGrad.Parent=rootFrame

local function text(parent,value,pos,size,font,color,z)
 local l=Instance.new("TextLabel")
 l.BackgroundTransparency=1;l.Text=value;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.GothamBold
 l.TextColor3=color or C.white;l.TextScaled=true;l.TextWrapped=true;l.ZIndex=z or 23;l.Parent=parent
 return l
end
local function frame(parent,pos,size,color,trans,z)
 local f=Instance.new("Frame")
 f.Position=pos;f.Size=size;f.BackgroundColor3=color or C.pink;f.BackgroundTransparency=trans or 0;f.BorderSizePixel=0;f.ZIndex=z or 22;f.Parent=parent
 return f
end
local function round(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 10);c.Parent=o end

local modes={}
local function mode(name)
 local f=Instance.new("Frame");f.Name=name;f.Size=UDim2.fromScale(1,1);f.BackgroundTransparency=1;f.Visible=false;f.ZIndex=21;f.Parent=rootFrame
 table.insert(modes,f);return f
end

-- MODE 1: iconic BBYA wordmark -------------------------------------------------
local logoMode=mode("LogoPulse")
local logoGlow=frame(logoMode,UDim2.fromScale(.18,.20),UDim2.fromScale(.64,.53),Color3.fromRGB(26,8,27),.08,21);round(logoGlow,28)
local logo=text(logoMode,"BBYA",UDim2.fromScale(.18,.20),UDim2.fromScale(.64,.39),Enum.Font.GothamBlack,C.white,24)
local logoSub=text(logoMode,"SOCIAL HUB  //  LIVE",UDim2.fromScale(.28,.59),UDim2.fromScale(.44,.07),Enum.Font.GothamBold,C.pink,24)
text(logoMode,"MUSIC • PEOPLE • NIGHT",UDim2.fromScale(.32,.70),UDim2.fromScale(.36,.05),Enum.Font.GothamMedium,C.muted,24)

-- MODE 2: wide equalizer -------------------------------------------------------
local eqMode=mode("LiveSpectrum")
text(eqMode,"BBYA LIVE WAVE",UDim2.fromScale(.05,.07),UDim2.fromScale(.42,.08),Enum.Font.GothamBlack,C.white,24)
text(eqMode,"AUTO DJ // SOCIAL FLOOR",UDim2.fromScale(.58,.08),UDim2.fromScale(.37,.05),Enum.Font.GothamBold,C.cyan,24)
local bars={}
local BAR_COUNT=34
for i=1,BAR_COUNT do
 local b=frame(eqMode,UDim2.new((i-.5)/BAR_COUNT,0,.86,0),UDim2.new(.017,0,0,-40),i%5==0 and C.cyan or (i%3==0 and C.gold or C.pink),.02,23)
 b.AnchorPoint=Vector2.new(.5,1);round(b,7);table.insert(bars,b)
end

-- MODE 3: orbital BBYA ---------------------------------------------------------
local orbitMode=mode("Orbit")
local center=text(orbitMode,"BBYA",UDim2.fromScale(.34,.32),UDim2.fromScale(.32,.23),Enum.Font.GothamBlack,C.white,25)
text(orbitMode,"NIGHT NETWORK",UDim2.fromScale(.38,.57),UDim2.fromScale(.24,.05),Enum.Font.GothamBold,C.gold,25)
local orbitBlocks={}
for i=1,18 do
 local b=frame(orbitMode,UDim2.fromScale(.5,.5),UDim2.fromScale(.025,.08),i%2==0 and C.pink or C.cyan,.08,23);round(b,5);table.insert(orbitBlocks,b)
end

-- MODE 4: neon matrix ----------------------------------------------------------
local gridMode=mode("NeonMatrix")
local gridLines={}
for i=0,12 do
 local v=frame(gridMode,UDim2.new(i/12,0,0,0),UDim2.new(0,2,1,0),i%3==0 and C.pink or C.cyan,.75,22);table.insert(gridLines,v)
end
for i=0,6 do
 local h=frame(gridMode,UDim2.new(0,0,i/6,0),UDim2.new(1,0,0,2),i%2==0 and C.cyan or C.purple,.80,22);table.insert(gridLines,h)
end
text(gridMode,"BBYA",UDim2.fromScale(.30,.28),UDim2.fromScale(.40,.24),Enum.Font.GothamBlack,C.white,25)
text(gridMode,"CONNECTED AFTER DARK",UDim2.fromScale(.31,.55),UDim2.fromScale(.38,.06),Enum.Font.GothamBold,C.pink,25)

local active=1
local modeStarted=os.clock()
local nextChange=9
local function selectMode(index)
 for i,m in ipairs(modes) do m.Visible=i==index end
 active=index;modeStarted=os.clock();nextChange=math.random(8,13)
end
selectMode(1)

local t=0
math.randomseed(math.floor(os.clock()*100000)%2147483647)
task.spawn(function()
 while rootFrame.Parent do
  local dt=.08;task.wait(dt);t+=dt
  if os.clock()-modeStarted>=nextChange then
   local n=math.random(1,#modes)
   if n==active then n=(n%#modes)+1 end
   selectMode(n)
  end

  if logoMode.Visible then
   local pulse=.92+math.sin(t*2.0)*.05
   logo.Size=UDim2.fromScale(.64*pulse,.39*pulse)
   logo.Position=UDim2.fromScale(.5-.32*pulse,.395-.195*pulse)
   logo.TextColor3=(math.sin(t*.7)>0) and C.white or Color3.fromRGB(240,224,239)
  elseif eqMode.Visible then
   for i,b in ipairs(bars) do
    local h=.12+math.abs(math.sin(t*3.3+i*.47))*.49+math.abs(math.sin(t*1.25+i*.17))*.12
    b.Size=UDim2.new(.017,0,h,0)
   end
  elseif orbitMode.Visible then
   for i,b in ipairs(orbitBlocks) do
    local a=t*.65+(i/#orbitBlocks)*math.pi*2
    local rx=.37;local ry=.30
    local x=.5+math.cos(a)*rx;local y=.5+math.sin(a)*ry
    b.Position=UDim2.fromScale(x,y)
    b.Rotation=math.deg(a)+90
   end
   center.Rotation=math.sin(t*.7)*1.2
  elseif gridMode.Visible then
   rootGrad.Rotation=(rootGrad.Rotation+.22)%360
  end
 end
end)

print("[BBYA] DJ Wall random visuals v1 online: logo + spectrum + orbit + neon matrix")
