-- BBYA SOCIAL HUB — PASAR MALAM v1
-- Built behind BBYA Mall (rear edge ~Z443). Playable rides + carnival skill games.
-- IMPORTANT: no global soundtrack is created. Existing/local ride-game audio stays authoritative.

local Workspace=game:GetService("Workspace")
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local old=root:FindFirstChild("BBYANightMarket");if old then old:Destroy() end
local market=Instance.new("Model");market.Name="BBYANightMarket";market.Parent=root
market:SetAttribute("Location","BEHIND_MALL")
market:SetAttribute("TeleportKey","NightMarket")
market:SetAttribute("TravelPriceRobux",10)
market:SetAttribute("BackgroundMusicInjected",false)
market:SetAttribute("AudioPolicy","RIDE_NATIVE_ONLY")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local state=remotes and remotes:FindFirstChild("State")
local function toast(plr,msg) if state and state:IsA("RemoteEvent") then state:FireClient(plr,"toast",msg) end end
local function score(plr,n,label)
 local total=(plr:GetAttribute("BBYANightMarketScore") or 0)+n
 plr:SetAttribute("BBYANightMarketScore",total)
 toast(plr,string.format("%s +%d • SCORE %d",label,n,total))
end

local C={dark=Color3.fromRGB(28,27,26),metal=Color3.fromRGB(88,91,94),wood=Color3.fromRGB(117,79,47),ground=Color3.fromRGB(111,90,65),road=Color3.fromRGB(63,62,59),white=Color3.fromRGB(245,241,229),red=Color3.fromRGB(205,55,47),yellow=Color3.fromRGB(244,184,60),blue=Color3.fromRGB(48,115,180),cyan=Color3.fromRGB(50,195,214),green=Color3.fromRGB(61,141,84),pink=Color3.fromRGB(226,73,147),purple=Color3.fromRGB(129,75,171),orange=Color3.fromRGB(230,113,52)}
local function part(name,size,cf,color,mat,collide,parent,tr)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.white;p.Material=mat or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.Transparency=tr or 0;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or market;return p
end
local function neon(name,size,cf,color,parent)local p=part(name,size,cf,color,Enum.Material.Neon,false,parent);p.CastShadow=false;return p end
local function seat(name,cf,parent,color)local s=Instance.new("Seat");s.Name=name;s.Size=Vector3.new(2.4,.8,2.4);s.CFrame=cf;s.Color=color or C.red;s.Material=Enum.Material.SmoothPlastic;s.Anchored=true;s.Parent=parent;return s end
local function prompt(obj,action,title)local q=Instance.new("ProximityPrompt");q.ActionText=action;q.ObjectText=title;q.MaxActivationDistance=12;q.RequiresLineOfSight=false;q.Parent=obj;return q end
local function sign(parent,name,text,size,cf,bg)
 local p=part(name,size,cf,bg or C.dark,Enum.Material.SmoothPlastic,false,parent)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.PixelsPerStud=55;g.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=g;return p
end
local function bulb(cf,color,parent)
 local b=Instance.new("Part");b.Shape=Enum.PartType.Ball;b.Size=Vector3.new(.7,.7,.7);b.CFrame=cf;b.Color=color;b.Material=Enum.Material.Neon;b.Anchored=true;b.CanCollide=false;b.Parent=parent or market
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=.55;l.Range=7;l.Shadows=false;l.Parent=b;return b
end
local function tent(name,cf,w,d,color,title)
 local m=Instance.new("Model");m.Name=name;m.Parent=market
 part("Floor",Vector3.new(w,.45,d),cf*CFrame.new(0,.3,0),C.wood,Enum.Material.WoodPlanks,true,m)
 for _,x in ipairs({-w/2+.7,w/2-.7}) do for _,z in ipairs({-d/2+.7,d/2-.7}) do part("Pole",Vector3.new(.4,8,.4),cf*CFrame.new(x,4,z),C.metal,Enum.Material.Metal,true,m) end end
 part("Canopy",Vector3.new(w+1,.4,d+1),cf*CFrame.new(0,8,0),color,Enum.Material.Fabric,false,m)
 sign(m,"Banner",title,Vector3.new(w-2,2.2,.35),cf*CFrame.new(0,6.4,-d/2-.25),color);return m
end

-- ACCESS: walkable route around Mall east side, then into rear fairground.
part("MallEastWalkway",Vector3.new(18,.7,180),CFrame.new(107,.4,365),Color3.fromRGB(78,77,73),Enum.Material.Concrete,true)
part("MallRearWalkway",Vector3.new(116,.7,18),CFrame.new(58,.4,455),Color3.fromRGB(78,77,73),Enum.Material.Concrete,true)
part("MarketGround",Vector3.new(214,.8,170),CFrame.new(0,.4,550),C.ground,Enum.Material.Ground,true)
part("MainAisle",Vector3.new(30,.25,160),CFrame.new(0,.86,550),C.road,Enum.Material.Asphalt,true)
part("CrossAisle",Vector3.new(202,.25,24),CFrame.new(0,.87,550),C.road,Enum.Material.Asphalt,true)

-- Authentic entrance + ticket/info booth.
for _,x in ipairs({-16,16}) do part("GateLeg",Vector3.new(2,17,2),CFrame.new(x,8.5,466),C.red,Enum.Material.Metal,true) end
part("GateBeam",Vector3.new(35,3,2),CFrame.new(0,16,466),C.yellow,Enum.Material.Metal,true)
sign(market,"GateSign","BBYA PASAR MALAM",Vector3.new(31,4,.4),CFrame.new(0,19,464.9),C.red)
for i=0,10 do bulb(CFrame.new(-15+i*3,15.2,464.5),i%2==0 and C.yellow or C.cyan,market) end
local info=tent("TicketInfo",CFrame.new(-30,0,478),16,12,C.red,"TIKET • INFO")
local desk=part("Desk",Vector3.new(13,3,2),CFrame.new(-30,2,474.5),C.wood,Enum.Material.WoodPlanks,true,info)
prompt(desk,"INFO","PASAR MALAM").Triggered:Connect(function(plr)toast(plr,"Pasar Malam belakang Mall • Travel 10 R$ sekali unlock • semua wahana & game aktif.")end)

-- String lights and food/snack row.
for _,z in ipairs({490,520,550,580,610}) do
 part("LightPoleL",Vector3.new(.45,14,.45),CFrame.new(-100,7,z),C.metal,Enum.Material.Metal,true)
 part("LightPoleR",Vector3.new(.45,14,.45),CFrame.new(100,7,z),C.metal,Enum.Material.Metal,true)
 for x=-96,96,8 do local n=math.floor((x+96)/8)%3;bulb(CFrame.new(x,13.6,z),n==0 and C.red or (n==1 and C.yellow or C.cyan),market) end
end
local stalls={{-96,495,C.orange,"JAGUNG BAKAR"},{-96,518,C.red,"SATE & SOSIS"},{-96,541,C.pink,"GULALI"},{-96,564,C.cyan,"ES CAMPUR"},{-96,587,C.yellow,"MARTABAK"},{-96,610,C.green,"JAJANAN"},{96,495,C.purple,"POPCORN"},{96,518,C.blue,"MINUMAN"},{96,541,C.red,"BAKSO BAKAR"},{96,564,C.orange,"TAHU CRISPY"},{96,587,C.pink,"PERMEN KAPAS"},{96,610,C.green,"KOPI & TEH"}}
for i,s in ipairs(stalls) do local m=tent("Stall"..i,CFrame.new(s[1],0,s[2]),17,13,s[3],s[4]);part("Counter",Vector3.new(14,3,2.2),CFrame.new(s[1],2,s[2]-4.8),C.wood,Enum.Material.WoodPlanks,true,m) end

-- RIDE 1: KOMEDI PUTAR / CAROUSEL.
local carousel=Instance.new("Model");carousel.Name="PlayableCarousel";carousel.Parent=market
local carBase=CFrame.new(-55,1.5,512)
local carPivot=part("Pivot",Vector3.new(.2,.2,.2),carBase,C.dark,Enum.Material.SmoothPlastic,false,carousel,1);carousel.PrimaryPart=carPivot
local deck=Instance.new("Part");deck.Shape=Enum.PartType.Cylinder;deck.Size=Vector3.new(2.5,42,42);deck.CFrame=carBase*CFrame.Angles(0,0,math.rad(90));deck.Color=C.red;deck.Material=Enum.Material.WoodPlanks;deck.Anchored=true;deck.Parent=carousel
part("Mast",Vector3.new(2.4,17,2.4),carBase*CFrame.new(0,8.5,0),C.yellow,Enum.Material.Metal,true,carousel)
local roof=Instance.new("Part");roof.Shape=Enum.PartType.Cylinder;roof.Size=Vector3.new(2,45,45);roof.CFrame=carBase*CFrame.new(0,16,0)*CFrame.Angles(0,0,math.rad(90));roof.Color=C.red;roof.Material=Enum.Material.Fabric;roof.Anchored=true;roof.CanCollide=false;roof.Parent=carousel
for i=1,10 do local a=(i-1)*math.pi*2/10;local x,z=math.cos(a)*14,math.sin(a)*14;part("HorsePole"..i,Vector3.new(.35,12,.35),carBase*CFrame.new(x,7,z),C.yellow,Enum.Material.Metal,false,carousel);local horse=part("Horse"..i,Vector3.new(3,2.2,5),carBase*CFrame.new(x,5,z)*CFrame.Angles(0,-a+math.pi/2,0),i%2==0 and C.white or C.pink,Enum.Material.SmoothPlastic,false,carousel);seat("Seat"..i,horse.CFrame*CFrame.new(0,1.7,0),carousel,i%2==0 and C.blue or C.red) end
sign(market,"CarouselSign","KOMEDI PUTAR",Vector3.new(22,3,.4),CFrame.new(-55,11,489),C.red)
local carCtl=part("CarouselControl",Vector3.new(4,3,4),CFrame.new(-79,1.8,512),C.dark,Enum.Material.Metal,true)
local carPrompt=prompt(carCtl,"MULAI","KOMEDI PUTAR");local carRun=false;local carA=0
carPrompt.Triggered:Connect(function(plr)if carRun then return end;carRun=true;carPrompt.Enabled=false;toast(plr,"Komedi putar dimulai • duduk di kursi.");task.delay(45,function()carRun=false;carPrompt.Enabled=true end)end)

-- RIDE 2: BIANG LALA.
local ferris=Instance.new("Model");ferris.Name="PlayableFerrisWheel";ferris.Parent=market
local fBase=CFrame.new(56,24,515)
local hub=part("Hub",Vector3.new(2.5,3.5,3.5),fBase,C.yellow,Enum.Material.Metal,false,ferris);ferris.PrimaryPart=hub
for _,x in ipairs({49,63}) do part("FerrisSupport",Vector3.new(2,32,2),CFrame.new(x,14,515),C.metal,Enum.Material.Metal,true,market) end
for i=1,16 do local a=(i-1)*math.pi*2/16;local y,z=math.cos(a)*20,math.sin(a)*20;neon("Rim"..i,Vector3.new(.6,3,.6),fBase*CFrame.new(0,y,z),i%2==0 and C.red or C.yellow,ferris) end
for i=1,8 do local a=(i-1)*math.pi*2/8;local y,z=math.cos(a)*18,math.sin(a)*18;part("Spoke"..i,Vector3.new(.45,1,37),fBase*CFrame.Angles(a,0,0),C.metal,Enum.Material.Metal,false,ferris);local g=part("Gondola"..i,Vector3.new(6,3,4),fBase*CFrame.new(0,y,z),({C.red,C.blue,C.green,C.yellow})[(i-1)%4+1],Enum.Material.Metal,true,ferris);seat("Seat"..i,g.CFrame*CFrame.new(0,2,0),ferris,C.dark) end
sign(market,"FerrisSign","BIANG LALA",Vector3.new(22,3,.4),CFrame.new(56,9,488),C.blue)
local fCtl=part("FerrisControl",Vector3.new(4,3,4),CFrame.new(80,1.8,515),C.dark,Enum.Material.Metal,true)
local fPrompt=prompt(fCtl,"MULAI","BIANG LALA");local fRun=false;local fA=0
fPrompt.Triggered:Connect(function(plr)if fRun then return end;fRun=true;fPrompt.Enabled=false;toast(plr,"Biang lala dimulai.");task.delay(55,function()fRun=false;fPrompt.Enabled=true end)end)

-- RIDE 3: KORA-KORA.
for _,x in ipairs({-12,12}) do part("KoraTower",Vector3.new(2,28,2),CFrame.new(x,14,594),C.metal,Enum.Material.Metal,true) end
part("KoraTop",Vector3.new(30,2,2),CFrame.new(0,27,594),C.yellow,Enum.Material.Metal,true)
local kora=Instance.new("Model");kora.Name="PlayableKoraKora";kora.Parent=market
local kBase=CFrame.new(0,26,594);local kp=part("Pivot",Vector3.new(.2,.2,.2),kBase,C.dark,Enum.Material.SmoothPlastic,false,kora,1);kora.PrimaryPart=kp
part("Arm",Vector3.new(1.2,18,1.2),kBase*CFrame.new(0,-9,0),C.metal,Enum.Material.Metal,false,kora)
local boat=part("Boat",Vector3.new(28,4,8),kBase*CFrame.new(0,-18,0),C.red,Enum.Material.WoodPlanks,true,kora)
for i=-4,4 do seat("KoraSeat"..i,boat.CFrame*CFrame.new(i*2.7,2,0),kora,i%2==0 and C.yellow or C.blue) end
local kCtl=part("KoraControl",Vector3.new(4,3,4),CFrame.new(19,1.8,594),C.dark,Enum.Material.Metal,true)
local kPrompt=prompt(kCtl,"MULAI","KORA-KORA");local kRun=false;local kT=0
kPrompt.Triggered:Connect(function(plr)if kRun then return end;kRun=true;kPrompt.Enabled=false;toast(plr,"Kora-kora dimulai.");task.delay(50,function()kRun=false;kPrompt.Enabled=true end)end)

RunService.Heartbeat:Connect(function(dt)
 if carRun then carA=(carA+dt*.72)%(math.pi*2);carousel:PivotTo(carBase*CFrame.Angles(0,carA,0)) end
 if fRun then fA=(fA+dt*.2)%(math.pi*2);ferris:PivotTo(fBase*CFrame.Angles(fA,0,0)) end
 if kRun then kT+=dt;kora:PivotTo(kBase*CFrame.Angles(math.sin(kT*1.55)*math.rad(52),0,0)) end
end)

-- GAME 1: shooting gallery — actual clickable targets, 30-second session.
local shooting=tent("ShootingGallery",CFrame.new(-62,0,574),45,18,C.blue,"TEMBAK SASARAN • KLIK TARGET")
local shootSession={};local startShoot=part("Start",Vector3.new(8,3,3),CFrame.new(-62,2,567),C.dark,Enum.Material.Metal,true,shooting)
prompt(startShoot,"MULAI 30 DETIK","TEMBAK SASARAN").Triggered:Connect(function(plr)shootSession[plr.UserId]=os.clock()+30;toast(plr,"Klik target selama 30 detik.")end)
for i=1,8 do local target=neon("Target"..i,Vector3.new(3.2,4,.6),CFrame.new(-78+(i-1)*4.6,4.5,580),i%2==0 and C.red or C.yellow,shooting);local cd=Instance.new("ClickDetector");cd.MaxActivationDistance=38;cd.Parent=target;cd.MouseClick:Connect(function(plr)if (shootSession[plr.UserId] or 0)<os.clock() then toast(plr,"Tekan MULAI dulu.");return end;if target.Transparency>.5 then return end;score(plr,10,"TARGET");target.Transparency=.8;cd.MaxActivationDistance=0;task.delay(.75,function()if target.Parent then target.Transparency=0;cd.MaxActivationDistance=38 end end)end) end

-- GAME 2: whack-a-mole — active target changes continuously.
local whack=tent("WhackAMole",CFrame.new(62,0,574),45,18,C.green,"PUKUL TIKUS • KLIK YANG MUNCUL")
local whackSession={};local active=1;local moles={};local startWhack=part("Start",Vector3.new(8,3,3),CFrame.new(62,2,567),C.dark,Enum.Material.Metal,true,whack)
prompt(startWhack,"MULAI 25 DETIK","PUKUL TIKUS").Triggered:Connect(function(plr)whackSession[plr.UserId]=os.clock()+25;toast(plr,"Klik tikus yang menyala selama 25 detik.")end)
for i=1,6 do local x=50+((i-1)%3)*12;local z=575+math.floor((i-1)/3)*5;part("Hole"..i,Vector3.new(7,1,4),CFrame.new(x,1.5,z),C.dark,Enum.Material.Metal,true,whack);local mole=part("Mole"..i,Vector3.new(3,3,2),CFrame.new(x,3,z),C.yellow,Enum.Material.SmoothPlastic,false,whack,.75);moles[i]=mole;local cd=Instance.new("ClickDetector");cd.MaxActivationDistance=35;cd.Parent=mole;cd.MouseClick:Connect(function(plr)if (whackSession[plr.UserId] or 0)<os.clock() then return end;if i==active then score(plr,8,"TIKUS");active=(active%6)+1 end end) end
task.spawn(function()while whack.Parent do for i,m in ipairs(moles) do m.Transparency=i==active and 0 or .75 end;task.wait(.65);active=(active%6)+1 end end)

-- GAME 3: timing jackpot — stop moving light in the center.
local timing=tent("TimingGame",CFrame.new(0,0,626),62,15,C.purple,"LAMPU JACKPOT • STOP DI TENGAH")
local idx=1;local bulbs={};for i=1,11 do bulbs[i]=bulb(CFrame.new(-25+(i-1)*5,5.5,628),i==6 and C.yellow or C.white,timing) end
local stop=part("Stop",Vector3.new(12,3,3),CFrame.new(0,2,619.5),C.dark,Enum.Material.Metal,true,timing)
prompt(stop,"STOP","LAMPU JACKPOT").Triggered:Connect(function(plr)local d=math.abs(idx-6);if d==0 then score(plr,30,"JACKPOT") elseif d==1 then score(plr,15,"HAMPIR") else toast(plr,"Belum tepat • coba lagi.") end end)
task.spawn(function()while timing.Parent do idx=(idx%11)+1;for i,b in ipairs(bulbs) do b.Color=i==idx and C.cyan or (i==6 and C.yellow or C.white) end;task.wait(.11) end end)

local board=sign(market,"ScoreBoard","PASAR MALAM SCORE\nMainkan 3 game & kumpulkan poin",Vector3.new(34,7,.5),CFrame.new(0,8,551),C.dark)
prompt(board,"CEK SCORE","PASAR MALAM").Triggered:Connect(function(plr)toast(plr,"Pasar Malam Score: "..tostring(plr:GetAttribute("BBYANightMarketScore") or 0))end)
Players.PlayerRemoving:Connect(function(plr)shootSession[plr.UserId]=nil;whackSession[plr.UserId]=nil end)

print("[BBYA] Pasar Malam v1 online behind Mall: 3 playable rides + 3 skill games / Travel 10R / no injected soundtrack")