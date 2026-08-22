-- BBYA SOCIAL HUB — PASAR MALAM v1
-- Authentic Indonesian night fair behind BBYA Mall.
-- Playable rides + skill games. This script intentionally injects NO global music.
-- AudioPolicy=RIDE_NATIVE_ONLY preserves venue audio and leaves ride/game-local audio untouched.

local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local previous=root:FindFirstChild("BBYANightMarket")
if previous then previous:Destroy() end

local market=Instance.new("Model")
market.Name="BBYANightMarket"
market.Parent=root
market:SetAttribute("Pass","NIGHT_MARKET_V1")
market:SetAttribute("Location","BEHIND_MALL")
market:SetAttribute("TeleportKey","NightMarket")
market:SetAttribute("TravelPriceRobux",10)
market:SetAttribute("AudioPolicy","RIDE_NATIVE_ONLY")
market:SetAttribute("BackgroundMusicInjected",false)
market:SetAttribute("PlayableRides",3)
market:SetAttribute("PlayableGames",3)

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local state=remotes and remotes:FindFirstChild("State")
local function toast(player,msg)
 if state and state:IsA("RemoteEvent") then state:FireClient(player,"toast",msg) end
end
local function addScore(player,amount,label)
 local total=(player:GetAttribute("BBYANightMarketScore") or 0)+amount
 player:SetAttribute("BBYANightMarketScore",total)
 toast(player,string.format("%s +%d • SCORE %d",label or "MENANG",amount,total))
end

local C={
 asphalt=Color3.fromRGB(64,62,59),dirt=Color3.fromRGB(110,89,64),cream=Color3.fromRGB(239,222,186),
 red=Color3.fromRGB(201,55,47),yellow=Color3.fromRGB(242,184,61),green=Color3.fromRGB(59,139,82),
 blue=Color3.fromRGB(48,113,177),cyan=Color3.fromRGB(50,194,211),pink=Color3.fromRGB(222,70,144),
 purple=Color3.fromRGB(126,72,167),white=Color3.fromRGB(244,240,227),black=Color3.fromRGB(24,23,23),
 metal=Color3.fromRGB(87,90,93),wood=Color3.fromRGB(117,79,47),orange=Color3.fromRGB(229,112,51),
}
local function part(name,size,cf,color,mat,collide,parent,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.white;p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Transparency=transparency or 0;p.Parent=parent or market
 return p
end
local function neon(name,size,cf,color,parent)
 local p=part(name,size,cf,color,Enum.Material.Neon,false,parent);p.CastShadow=false;return p
end
local function seat(name,cf,parent,color)
 local s=Instance.new("Seat")
 s.Name=name;s.Size=Vector3.new(2.4,.8,2.4);s.CFrame=cf;s.Color=color or C.red;s.Material=Enum.Material.SmoothPlastic
 s.Anchored=true;s.CanCollide=true;s.Parent=parent
 return s
end
local function prompt(parent,action,obj,hold)
 local q=Instance.new("ProximityPrompt")
 q.ActionText=action;q.ObjectText=obj;q.HoldDuration=hold or 0;q.MaxActivationDistance=12;q.RequiresLineOfSight=false;q.Parent=parent
 return q
end
local function sign(parent,name,textValue,size,cf,textColor,bg)
 local p=part(name,size,cf,bg or C.black,Enum.Material.SmoothPlastic,false,parent)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.PixelsPerStud=52;g.Parent=p
 local t=Instance.new("TextLabel");t.Name="Text";t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=textValue
 t.TextColor3=textColor or C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=g
 return p,t
end
local function bulb(name,cf,color,parent,range)
 local b=Instance.new("Part")
 b.Name=name;b.Shape=Enum.PartType.Ball;b.Size=Vector3.new(.7,.7,.7);b.CFrame=cf;b.Color=color;b.Material=Enum.Material.Neon
 b.Anchored=true;b.CanCollide=false;b.CanTouch=false;b.CastShadow=false;b.Parent=parent or market
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=.65;l.Range=range or 8;l.Shadows=false;l.Parent=b
 return b
end
local function pole(name,cf,height,parent)
 return part(name,Vector3.new(.45,height,.45),cf*CFrame.new(0,height/2,0),C.metal,Enum.Material.Metal,true,parent)
end
local function tent(name,center,w,d,color,title)
 local m=Instance.new("Model");m.Name=name;m.Parent=market
 part("Floor",Vector3.new(w,.5,d),center*CFrame.new(0,.3,0),Color3.fromRGB(82,72,60),Enum.Material.WoodPlanks,true,m)
 for _,x in ipairs({-w/2+.7,w/2-.7}) do for _,z in ipairs({-d/2+.7,d/2-.7}) do pole("Pole",center*CFrame.new(x,0,z),8,m) end end
 part("Canopy",Vector3.new(w+1,.45,d+1),center*CFrame.new(0,8,0),color,Enum.Material.Fabric,false,m)
 sign(m,"Banner",title,Vector3.new(w-2,2.4,.35),center*CFrame.new(0,6.5,-d/2-.25),C.white,color)
 return m
end
local function click(partObj,dist)
 local c=Instance.new("ClickDetector");c.MaxActivationDistance=dist or 30;c.Parent=partObj;return c
end

-- Mall rear wall is around Z=443. The fair starts behind a short service gap.
local ENTRY_Z=466
local CENTER_Z=550
local W,D=214,170

-- Physical walk-in route around the east side of Mall, plus rear service lane.
part("MallEastWalkway",Vector3.new(18,.7,180),CFrame.new(107,.4,365),Color3.fromRGB(78,77,73),Enum.Material.Concrete,true)
part("MallRearWalkway",Vector3.new(116,.7,18),CFrame.new(58,.4,455),Color3.fromRGB(78,77,73),Enum.Material.Concrete,true)
part("RearServiceLane",Vector3.new(48,.7,26),CFrame.new(0,.4,456),Color3.fromRGB(73,72,69),Enum.Material.Concrete,true)

part("MarketGround",Vector3.new(W,.8,D),CFrame.new(0,.4,CENTER_Z),C.dirt,Enum.Material.Ground,true)
part("MainAisle",Vector3.new(30,.25,D-8),CFrame.new(0,.86,CENTER_Z),C.asphalt,Enum.Material.Asphalt,true)
part("CrossAisle",Vector3.new(W-12,.25,24),CFrame.new(0,.87,550),C.asphalt,Enum.Material.Asphalt,true)

-- Entrance gate.
local gate=Instance.new("Model");gate.Name="PasarMalamGate";gate.Parent=market
for _,x in ipairs({-16,16}) do part("GateLeg",Vector3.new(2.2,17,2.2),CFrame.new(x,8.5,ENTRY_Z),C.red,Enum.Material.Metal,true,gate) end
part("GateBeam",Vector3.new(35,3,2.2),CFrame.new(0,16,ENTRY_Z),C.yellow,Enum.Material.Metal,true,gate)
sign(gate,"GateSign","BBYA PASAR MALAM",Vector3.new(31,4,.45),CFrame.new(0,19,ENTRY_Z-1.3),C.white,C.red)
for i=0,10 do bulb("GateBulb"..i,CFrame.new(-15+i*3,15.2,ENTRY_Z-1.4),i%2==0 and C.yellow or C.cyan,gate,8) end
local infoTent=tent("TicketInfo",CFrame.new(-30,0,478),16,12,C.red,"TIKET • INFO")
local infoCounter=part("Counter",Vector3.new(13,3,2.5),CFrame.new(-30,2,474.6),C.wood,Enum.Material.WoodPlanks,true,infoTent)
prompt(infoCounter,"INFO","PASAR MALAM",0).Triggered:Connect(function(player)
 toast(player,"Pasar malam ada di belakang Mall • wahana dan game bisa dimainkan • Travel 10 R$ sekali unlock.")
end)

-- Fences and warm string-light canopy.
for _,x in ipairs({-W/2,W/2}) do
 for z=480,626,12 do part("Fence",Vector3.new(.35,3.2,10),CFrame.new(x,1.8,z),C.metal,Enum.Material.Metal,true,market) end
end
for x=-96,96,12 do part("RearFence",Vector3.new(10,3.2,.35),CFrame.new(x,1.8,635),C.metal,Enum.Material.Metal,true,market) end
local lights=Instance.new("Model");lights.Name="StringLights";lights.Parent=market
for _,z in ipairs({488,520,552,584,616}) do
 pole("PoleL",CFrame.new(-99,0,z),14,lights);pole("PoleR",CFrame.new(99,0,z),14,lights)
 for x=-96,96,8 do
  local n=math.floor((x+96)/8)%3
  bulb("StringBulb",CFrame.new(x,13.6,z),n==0 and C.red or (n==1 and C.yellow or C.cyan),lights,7)
 end
end

-- Food/snack stalls around the edges.
local stalls={
 {-96,493,C.orange,"JAGUNG BAKAR"},{-96,516,C.red,"SATE & SOSIS"},{-96,539,C.pink,"GULALI"},
 {-96,562,C.cyan,"ES CAMPUR"},{-96,585,C.yellow,"MARTABAK MINI"},{-96,608,C.green,"JAJANAN"},
 {96,493,C.purple,"POPCORN"},{96,516,C.blue,"MINUMAN"},{96,539,C.red,"BAKSO BAKAR"},
 {96,562,C.orange,"TAHU CRISPY"},{96,585,C.pink,"PERMEN KAPAS"},{96,608,C.green,"KOPI & TEH"},
}
for i,s in ipairs(stalls) do
 local m=tent("Stall"..i,CFrame.new(s[1],0,s[2]),17,13,s[3],s[4])
 part("Counter",Vector3.new(14,3,2.4),CFrame.new(s[1],2,s[2]-4.8),C.wood,Enum.Material.WoodPlanks,true,m)
 for j=-1,1 do bulb("StallBulb",CFrame.new(s[1]+j*4.5,7.1,s[2]-6),C.yellow,m,6) end
end

-- Family seating corner.
local rest=Instance.new("Model");rest.Name="FamilyRestArea";rest.Parent=market
part("RestFloor",Vector3.new(48,.3,22),CFrame.new(69,.9,622),Color3.fromRGB(91,76,59),Enum.Material.WoodPlanks,true,rest)
for _,x in ipairs({52,64,76,88}) do
 part("Bench",Vector3.new(7,1,2.2),CFrame.new(x,1.8,619),C.wood,Enum.Material.WoodPlanks,true,rest)
 part("Table",Vector3.new(4,2.4,4),CFrame.new(x,1.7,627),C.wood,Enum.Material.WoodPlanks,true,rest)
end

-- =========================================================
-- PLAYABLE RIDE 1: KOMEDI PUTAR / CAROUSEL
-- =========================================================
local carousel=Instance.new("Model");carousel.Name="PlayableCarousel";carousel.Parent=market
local carBase=CFrame.new(-55,1.5,512)
local carPivot=part("Pivot",Vector3.new(.2,.2,.2),carBase,C.black,Enum.Material.SmoothPlastic,false,carousel,1)
carousel.PrimaryPart=carPivot
local deck=Instance.new("Part");deck.Name="Deck";deck.Shape=Enum.PartType.Cylinder;deck.Size=Vector3.new(2.5,42,42);deck.CFrame=carBase*CFrame.Angles(0,0,math.rad(90));deck.Color=C.red;deck.Material=Enum.Material.WoodPlanks;deck.Anchored=true;deck.Parent=carousel
part("Mast",Vector3.new(2.4,17,2.4),carBase*CFrame.new(0,8.5,0),C.yellow,Enum.Material.Metal,true,carousel)
local canopy=Instance.new("Part");canopy.Name="Canopy";canopy.Shape=Enum.PartType.Cylinder;canopy.Size=Vector3.new(2,45,45);canopy.CFrame=carBase*CFrame.new(0,16,0)*CFrame.Angles(0,0,math.rad(90));canopy.Color=C.red;canopy.Material=Enum.Material.Fabric;canopy.Anchored=true;canopy.CanCollide=false;canopy.Parent=carousel
for i=1,10 do
 local a=(i-1)*math.pi*2/10
 local x,z=math.cos(a)*14,math.sin(a)*14
 part("HorsePole"..i,Vector3.new(.35,12,.35),carBase*CFrame.new(x,7,z),C.yellow,Enum.Material.Metal,false,carousel)
 local horse=part("Horse"..i,Vector3.new(3,2.2,5),carBase*CFrame.new(x,5,z)*CFrame.Angles(0,-a+math.pi/2,0),i%2==0 and C.white or C.pink,Enum.Material.SmoothPlastic,false,carousel)
 seat("Seat"..i,horse.CFrame*CFrame.new(0,1.7,.2),carousel,i%2==0 and C.blue or C.red)
end
for i=1,16 do local a=(i-1)*math.pi*2/16;bulb("CarouselBulb",carBase*CFrame.new(math.cos(a)*20,16.8,math.sin(a)*20),i%2==0 and C.yellow or C.cyan,carousel,8) end
local carControl=part("CarouselControl",Vector3.new(4,3,4),CFrame.new(-78,1.8,512),C.black,Enum.Material.Metal,true,market)
sign(market,"CarouselSign","KOMEDI PUTAR",Vector3.new(22,3,.4),CFrame.new(-55,11,489),C.white,C.red)
local carPrompt=prompt(carControl,"MULAI","KOMEDI PUTAR",.5)
local carRunning=false
local carAngle=0
carPrompt.Triggered:Connect(function(player)
 if carRunning then toast(player,"Komedi putar sedang berjalan.");return end
 carRunning=true;carPrompt.Enabled=false;toast(player,"Komedi putar dimulai • duduk di kursi untuk ikut.")
 task.delay(45,function()carRunning=false;carPrompt.Enabled=true end)
end)

-- =========================================================
-- PLAYABLE RIDE 2: BIANG LALA / FERRIS WHEEL
-- =========================================================
local ferrisStatic=Instance.new("Model");ferrisStatic.Name="FerrisSupport";ferrisStatic.Parent=market
local ferris=Instance.new("Model");ferris.Name="PlayableFerrisWheel";ferris.Parent=market
local FBASE=CFrame.new(56,24,515)
for _,x in ipairs({-9,9}) do
 part("SupportA",Vector3.new(2,31,2),CFrame.new(56+x/2,13,515)*CFrame.Angles(0,0,math.rad(x<0 and -18 or 18)),C.metal,Enum.Material.Metal,true,ferrisStatic)
end
local hub=part("Hub",Vector3.new(2.5,3.5,3.5),FBASE*CFrame.Angles(0,math.rad(90),0),C.yellow,Enum.Material.Metal,false,ferris)
ferris.PrimaryPart=hub
for i=1,16 do
 local a=(i-1)*math.pi*2/16
 local y,z=math.cos(a)*20,math.sin(a)*20
 part("Rim"..i,Vector3.new(.6,3.8,.6),FBASE*CFrame.new(0,y,z),i%2==0 and C.red or C.yellow,Enum.Material.Neon,false,ferris)
end
for i=1,8 do
 local a=(i-1)*math.pi*2/8
 local y,z=math.cos(a)*19,math.sin(a)*19
 part("Spoke"..i,Vector3.new(.35,39,.35),FBASE*CFrame.Angles(math.rad(90),0,a),C.metal,Enum.Material.Metal,false,ferris)
 local gondola=part("Gondola"..i,Vector3.new(6,3.2,4),FBASE*CFrame.new(0,y,z),({C.red,C.blue,C.green,C.yellow})[(i-1)%4+1],Enum.Material.Metal,true,ferris)
 seat("FerrisSeat"..i,gondola.CFrame*CFrame.new(0,2,0),ferris,C.black)
end
sign(market,"FerrisSign","BIANG LALA",Vector3.new(22,3,.4),CFrame.new(56,10,487),C.white,C.blue)
local ferrisControl=part("FerrisControl",Vector3.new(4,3,4),CFrame.new(80,1.8,515),C.black,Enum.Material.Metal,true,market)
local ferrisPrompt=prompt(ferrisControl,"MULAI","BIANG LALA",.5)
local ferrisRunning=false
local ferrisAngle=0
ferrisPrompt.Triggered:Connect(function(player)
 if ferrisRunning then toast(player,"Biang lala sedang berjalan.");return end
 ferrisRunning=true;ferrisPrompt.Enabled=false;toast(player,"Biang lala dimulai • naik ke gondola sebelum putaran berikutnya.")
 task.delay(55,function()ferrisRunning=false;ferrisPrompt.Enabled=true end)
end)

-- =========================================================
-- PLAYABLE RIDE 3: KORA-KORA
-- =========================================================
local koraStatic=Instance.new("Model");koraStatic.Name="KoraKoraSupport";koraStatic.Parent=market
for _,x in ipairs({-12,12}) do
 part("Tower",Vector3.new(2,28,2),CFrame.new(x,14,594)*CFrame.Angles(0,0,math.rad(x<0 and -15 or 15)),C.metal,Enum.Material.Metal,true,koraStatic)
end
part("TopBeam",Vector3.new(30,2,2),CFrame.new(0,27,594),C.yellow,Enum.Material.Metal,true,koraStatic)
local kora=Instance.new("Model");kora.Name="PlayableKoraKora";kora.Parent=market
local KPIV=CFrame.new(0,26,594)
local kp=part("Pivot",Vector3.new(.2,.2,.2),KPIV,C.black,Enum.Material.SmoothPlastic,false,kora,1);kora.PrimaryPart=kp
part("Arm",Vector3.new(1.3,18,1.3),KPIV*CFrame.new(0,-9,0),C.metal,Enum.Material.Metal,false,kora)
local boat=part("Boat",Vector3.new(28,4,8),KPIV*CFrame.new(0,-18,0),C.red,Enum.Material.WoodPlanks,true,kora)
for i=-4,4 do seat("KoraSeat"..i,boat.CFrame*CFrame.new(i*2.7,2,0),kora,i%2==0 and C.yellow or C.blue) end
sign(market,"KoraSign","KORA-KORA",Vector3.new(22,3,.4),CFrame.new(0,8,621)*CFrame.Angles(0,math.rad(180),0),C.white,C.red)
local koraControl=part("KoraControl",Vector3.new(4,3,4),CFrame.new(19,1.8,594),C.black,Enum.Material.Metal,true,market)
local koraPrompt=prompt(koraControl,"MULAI","KORA-KORA",.5)
local koraRunning=false
local koraT=0
koraPrompt.Triggered:Connect(function(player)
 if koraRunning then toast(player,"Kora-kora sedang berjalan.");return end
 koraRunning=true;koraPrompt.Enabled=false;toast(player,"Kora-kora dimulai • duduk sebelum ayunan penuh.")
 task.delay(50,function()koraRunning=false;koraPrompt.Enabled=true end)
end)

-- Ride animation loop. No Sound objects are created here.
RunService.Heartbeat:Connect(function(dt)
 if carRunning and carousel.Parent then
  carAngle=(carAngle+dt*.72)%(math.pi*2)
  carousel:PivotTo(carBase*CFrame.Angles(0,carAngle,0))
 end
 if ferrisRunning and ferris.Parent then
  ferrisAngle=(ferrisAngle+dt*.20)%(math.pi*2)
  ferris:PivotTo(FBASE*CFrame.Angles(ferrisAngle,0,0))
 end
 if koraRunning and kora.Parent then
  koraT+=dt
  local swing=math.sin(koraT*1.55)*math.rad(52)
  kora:PivotTo(KPIV*CFrame.Angles(swing,0,0))
 end
end)

-- =========================================================
-- PLAYABLE SKILL GAME 1: TEMBAK SASARAN
-- =========================================================
local shooting=tent("ShootingGallery",CFrame.new(-63,0,574),45,18,C.blue,"TEMBAK SASARAN • KLIK TARGET")
local shootSessions={}
local shootStart=part("Start",Vector3.new(8,3,3),CFrame.new(-63,2,567),C.black,Enum.Material.Metal,true,shooting)
prompt(shootStart,"MULAI 30 DETIK","TEMBAK SASARAN",0).Triggered:Connect(function(player)
 shootSessions[player.UserId]=os.clock()+30
 toast(player,"TEMBAK SASARAN dimulai • klik target menyala selama 30 detik.")
end)
for i=1,8 do
 local x=-79+(i-1)*4.6
 local target=part("Target"..i,Vector3.new(3.2,4,.6),CFrame.new(x,4.5,580),i%2==0 and C.red or C.yellow,Enum.Material.Neon,false,shooting)
 local cd=click(target,38)
 cd.MouseClick:Connect(function(player)
  if (shootSessions[player.UserId] or 0)<os.clock() then toast(player,"Tekan MULAI untuk bermain.");return end
  if target.Transparency>.5 then return end
  addScore(player,10,"TARGET")
  target.Transparency=.8;cd.MaxActivationDistance=0
  task.delay(.8,function()if target.Parent then target.Transparency=0;cd.MaxActivationDistance=38 end end)
 end)
end

-- =========================================================
-- PLAYABLE SKILL GAME 2: PUKUL TIKUS / WHACK-A-MOLE
-- =========================================================
local whack=tent("WhackAMole",CFrame.new(62,0,574),45,18,C.green,"PUKUL TIKUS • KLIK YANG MUNCUL")
local whackSessions={}
local moleParts={}
local activeMole=1
local whackStart=part("Start",Vector3.new(8,3,3),CFrame.new(62,2,567),C.black,Enum.Material.Metal,true,whack)
prompt(whackStart,"MULAI 25 DETIK","PUKUL TIKUS",0).Triggered:Connect(function(player)
 whackSessions[player.UserId]=os.clock()+25
 toast(player,"PUKUL TIKUS dimulai • klik tikus yang menyala.")
end)
for i=1,6 do
 local x=50+((i-1)%3)*12
 local z=575+math.floor((i-1)/3)*5
 local base=part("Hole"..i,Vector3.new(7,1.2,4),CFrame.new(x,1.5,z),C.black,Enum.Material.Metal,true,whack)
 local mole=part("Mole"..i,Vector3.new(3,3,2),CFrame.new(x,3,z),C.black,Enum.Material.SmoothPlastic,false,whack,.65)
 moleParts[i]=mole
 click(mole,35).MouseClick:Connect(function(player)
  if (whackSessions[player.UserId] or 0)<os.clock() then toast(player,"Tekan MULAI untuk bermain.");return end
  if i~=activeMole then return end
  addScore(player,8,"TIKUS")
  activeMole=((activeMole+math.random(1,5)-1)%6)+1
 end)
end
task.spawn(function()
 while whack.Parent do
  for i,mole in ipairs(moleParts) do
   if mole.Parent then
    mole.Transparency=(i==activeMole) and 0 or .75
    mole.Color=(i==activeMole) and C.yellow or C.black
   end
  end
  task.wait(.65)
  activeMole=(activeMole%6)+1
 end
end)

-- =========================================================
-- PLAYABLE SKILL GAME 3: LAMPU JACKPOT / STOP TIMING
-- =========================================================
local timing=tent("TimingGame",CFrame.new(0,0,626),62,15,C.purple,"LAMPU JACKPOT • STOP DI TENGAH")
local timingIndex=1
local timingLights={}
for i=1,11 do
 local x=-25+(i-1)*5
 timingLights[i]=bulb("Timing"..i,CFrame.new(x,5.5,628),i==6 and C.yellow or C.white,timing,6)
end
local stopPad=part("StopPad",Vector3.new(12,3,3),CFrame.new(0,2,619.5),C.black,Enum.Material.Metal,true,timing)
prompt(stopPad,"STOP","LAMPU JACKPOT",0).Triggered:Connect(function(player)
 local dist=math.abs(timingIndex-6)
 if dist==0 then addScore(player,30,"JACKPOT")
 elseif dist==1 then addScore(player,15,"HAMPIR")
 else toast(player,"Belum tepat • coba lagi saat lampu di tengah.") end
end)
task.spawn(function()
 while timing.Parent do
  timingIndex=(timingIndex%11)+1
  for i,b in ipairs(timingLights) do
   if b.Parent then b.Color=(i==timingIndex) and C.cyan or (i==6 and C.yellow or C.white) end
  end
  task.wait(.11)
 end
end)

-- Score board at central cross aisle.
local board,boardText=sign(market,"ScoreBoard","PASAR MALAM SCORE\nMainkan 3 game untuk kumpulkan poin",Vector3.new(34,7,.5),CFrame.new(0,8,551),C.white,C.black)
local boardPrompt=prompt(board,"CEK SCORE","PASAR MALAM",0)
boardPrompt.Triggered:Connect(function(player)
 toast(player,"Pasar Malam Score kamu: "..tostring(player:GetAttribute("BBYANightMarketScore") or 0))
end)

-- Cleanup per-player session state.
Players.PlayerRemoving:Connect(function(player)
 shootSessions[player.UserId]=nil
 whackSessions[player.UserId]=nil
end)

print("[BBYA] Pasar Malam v1 online behind Mall: Carousel + Ferris Wheel + Kora-Kora / Shooting + Whack + Timing / no injected global music")