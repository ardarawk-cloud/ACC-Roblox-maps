-- BBYA SOCIAL HUB — PASAR MALAM PREMIUM OVERLAY v3
-- Visual/interaction rebuild layered over 98-night-market.server.lua.
-- Keeps Travel 10R and existing local ride/game audio policy. Creates NO Sound.

local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local market=root:WaitForChild("BBYANightMarket",30)
if not market then return end
task.wait(1.3)

local previous=market:FindFirstChild("PremiumNightMarketV3")
if previous then previous:Destroy() end
local premium=Instance.new("Model")
premium.Name="PremiumNightMarketV3"
premium.Parent=market
market:SetAttribute("Pass","NIGHT_MARKET_PREMIUM_V3")
market:SetAttribute("VisualTier","AUTHENTIC_INDONESIAN_FAIR")
market:SetAttribute("PlayableRides",4)
market:SetAttribute("PlayableGames",4)
market:SetAttribute("TravelPriceRobux",10)
market:SetAttribute("BackgroundMusicInjected",false)
market:SetAttribute("AudioPolicy","RIDE_NATIVE_ONLY")

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
local state=remotes and remotes:FindFirstChild("State")
local function toast(plr,msg)
 if state and state:IsA("RemoteEvent") then state:FireClient(plr,"toast",msg) end
end
local function score(plr,n,label)
 local total=(plr:GetAttribute("BBYANightMarketScore") or 0)+n
 plr:SetAttribute("BBYANightMarketScore",total)
 toast(plr,string.format("%s +%d • POIN %d",label,n,total))
end

local C={
 black=Color3.fromRGB(25,24,22),dark=Color3.fromRGB(39,37,34),metal=Color3.fromRGB(94,96,94),galv=Color3.fromRGB(137,140,136),
 wood=Color3.fromRGB(116,77,44),wood2=Color3.fromRGB(149,105,61),cream=Color3.fromRGB(239,222,188),white=Color3.fromRGB(245,240,227),
 red=Color3.fromRGB(190,48,40),red2=Color3.fromRGB(145,42,37),yellow=Color3.fromRGB(237,177,50),blue=Color3.fromRGB(53,105,160),
 green=Color3.fromRGB(61,123,73),pink=Color3.fromRGB(205,72,124),cyan=Color3.fromRGB(65,153,164),purple=Color3.fromRGB(112,71,139),
 orange=Color3.fromRGB(214,107,48),warm=Color3.fromRGB(255,226,174),cable=Color3.fromRGB(32,31,29),asphalt=Color3.fromRGB(55,55,52),
}
local function part(name,size,cf,color,mat,collide,parent,tr)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.white;p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Transparency=tr or 0;p.Parent=parent or premium;return p
end
local function wedge(name,size,cf,color,mat,collide,parent)
 local p=Instance.new("WedgePart");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.white;p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.Parent=parent or premium;return p
end
local function ball(name,size,cf,color,mat,collide,parent)
 local p=part(name,size,cf,color,mat,collide,parent);p.Shape=Enum.PartType.Ball;return p
end
local function cylinder(name,length,diameter,cf,color,mat,collide,parent)
 local p=part(name,Vector3.new(length,diameter,diameter),cf,color,mat,collide,parent);p.Shape=Enum.PartType.Cylinder;return p
end
local function beam(name,a,b,t,color,mat,parent)
 local mid=(a+b)/2
 return part(name,Vector3.new(t,t,(b-a).Magnitude),CFrame.lookAt(mid,b),color,mat,false,parent)
end
local function bulb(name,cf,color,parent,brightness,range)
 local b=ball(name,Vector3.new(.6,.6,.6),cf,color,Enum.Material.Neon,false,parent);b.CastShadow=false
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness or .42;l.Range=range or 7;l.Shadows=false;l.Parent=b
 return b
end
local function sign(parent,name,textValue,size,cf,bg,fg)
 local p=part(name,size,cf,bg or C.black,Enum.Material.Metal,false,parent)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.PixelsPerStud=58;g.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=textValue;t.TextColor3=fg or C.white;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=g
 return p
end
local function prompt(obj,action,title,hold)
 local q=Instance.new("ProximityPrompt");q.ActionText=action;q.ObjectText=title;q.HoldDuration=hold or 0;q.MaxActivationDistance=12;q.RequiresLineOfSight=false;q.Parent=obj;return q
end
local function rail(name,a,b,parent)
 part(name.."PostA",Vector3.new(.3,3,.3),CFrame.new(a.X,2.2,a.Z),C.galv,Enum.Material.Metal,true,parent)
 part(name.."PostB",Vector3.new(.3,3,.3),CFrame.new(b.X,2.2,b.Z),C.galv,Enum.Material.Metal,true,parent)
 beam(name.."Top",Vector3.new(a.X,3.5,a.Z),Vector3.new(b.X,3.5,b.Z),.18,C.galv,Enum.Material.Metal,parent)
 beam(name.."Mid",Vector3.new(a.X,2.3,a.Z),Vector3.new(b.X,2.3,b.Z),.14,C.galv,Enum.Material.Metal,parent)
end
local function queue(name,cx,cz,w,d,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent or premium
 local x1,x2=cx-w/2,cx+w/2;local z1,z2=cz-d/2,cz+d/2
 local gap=4
 rail("SouthL",Vector3.new(x1,0,z1),Vector3.new(cx-gap/2,0,z1),m);rail("SouthR",Vector3.new(cx+gap/2,0,z1),Vector3.new(x2,0,z1),m);rail("North",Vector3.new(x1,0,z2),Vector3.new(x2,0,z2),m)
 rail("West",Vector3.new(x1,0,z1),Vector3.new(x1,0,z2),m);rail("East",Vector3.new(x2,0,z1),Vector3.new(x2,0,z2),m)
 return m
end
local function canopy(parent,cf,w,d,c1,c2)
 for i=1,8 do
  local sw=w/8
  part("Stripe"..i,Vector3.new(sw+.05,.3,d),cf*CFrame.new(-w/2+sw*(i-.5),7.6,0),i%2==0 and c1 or c2,Enum.Material.Fabric,false,parent)
 end
end
local function booth(name,cf,title,color,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent or premium
 part("Floor",Vector3.new(9,.4,7),cf*CFrame.new(0,.3,0),C.wood,Enum.Material.WoodPlanks,true,m)
 part("Back",Vector3.new(9,6,.35),cf*CFrame.new(0,3.2,3.2),color,Enum.Material.Metal,true,m)
 local counter=part("Counter",Vector3.new(9,2.8,1.6),cf*CFrame.new(0,1.8,-2.7),C.dark,Enum.Material.Metal,true,m)
 canopy(m,cf,10,8,color,C.cream)
 sign(m,"Name",title,Vector3.new(7.5,1.8,.25),cf*CFrame.new(0,5.2,-4.1),color,C.white)
 local lamp=part("Lamp",Vector3.new(1,.25,1),cf*CFrame.new(0,5.5,0),C.white,Enum.Material.Neon,false,m)
 local light=Instance.new("PointLight");light.Color=C.warm;light.Brightness=1;light.Range=11;light.Parent=lamp
 return m,counter
end

for _,o in ipairs(market:GetChildren()) do
 if o:IsA("Part") and o.Shape==Enum.PartType.Ball and o.Material==Enum.Material.Neon and o.Position.Y>12 and o.Position.Z>485 and o.Position.Z<625 then o:Destroy() end
 if o:IsA("BasePart") and (o.Name:match("^LightPole") or o.Name=="GateBeam" or o.Name=="GateSign") then o.Transparency=1;o.CanCollide=false end
end

for i,p in ipairs({{-8,502,16,8},{10,538,12,6},{-7,581,15,7},{8,620,19,6}}) do
 part("Patch"..i,Vector3.new(p[3],.06,p[4]),CFrame.new(p[1],1.12,p[2])*CFrame.Angles(0,math.rad(i%2==0 and 5 or -6),0),C.asphalt,Enum.Material.Asphalt,false)
end
for _,x in ipairs({-19,19}) do part("Drain"..x,Vector3.new(.7,.08,170),CFrame.new(x,1.14,550),Color3.fromRGB(43,43,41),Enum.Material.Metal,false) end

local gate=Instance.new("Model");gate.Name="PremiumGate";gate.Parent=premium
for _,x in ipairs({-19,19}) do
 part("Tower",Vector3.new(2.2,21,2.2),CFrame.new(x,10.8,470),C.red2,Enum.Material.Metal,true,gate)
 for y=4,18,4 do beam("Brace",Vector3.new(x-1.7,y,469.4),Vector3.new(x+1.7,y+2,470.6),.2,C.yellow,Enum.Material.Metal,gate) end
end
part("TopTruss",Vector3.new(41,2.5,2.2),CFrame.new(0,20.6,470),C.yellow,Enum.Material.Metal,true,gate)
sign(gate,"Marquee","BBYA PASAR MALAM",Vector3.new(35,5,.45),CFrame.new(0,17.5,468.6),C.red,C.white)
sign(gate,"Sub","WAHANA • PERMAINAN • JAJANAN",Vector3.new(27,1.5,.35),CFrame.new(0,14.4,468.55),C.black,C.yellow)
for i=0,12 do bulb("GateBulb"..i,CFrame.new(-18+i*3,21.1,468.8),i%2==0 and C.warm or C.yellow,gate,.6,8) end
for _,x in ipairs({-10,0,10}) do
 local post=part("Turnstile",Vector3.new(.65,4,.65),CFrame.new(x,2.7,476),C.galv,Enum.Material.Metal,true,gate)
 for a=0,2 do part("Arm",Vector3.new(5.8,.16,.16),post.CFrame*CFrame.new(0,.7,0)*CFrame.Angles(0,math.rad(a*60),0),C.galv,Enum.Material.Metal,false,gate) end
end

local strings=Instance.new("Model");strings.Name="WarmStringLights";strings.Parent=premium
for row,z in ipairs({493,523,553,583,613}) do
 local pts={}
 for n=0,12 do
  local x=-100+n*(200/12);local u=math.abs(x)/100;local y=13.2+2.2*u*u
  pts[#pts+1]=Vector3.new(x,y,z)
 end
 for n=1,#pts-1 do beam("Cable",pts[n],pts[n+1],.055,C.cable,Enum.Material.SmoothPlastic,strings) end
 for n,p in ipairs(pts) do
  if n>1 and n<#pts then
   bulb("Warm",CFrame.new(p),C.warm,strings,.38,7)
   if row%2==0 and n%2==0 then part("Flag",Vector3.new(1.2,1.5,.08),CFrame.new(p+Vector3.new(0,-1,0)),({C.red,C.yellow,C.blue,C.green})[((n+row)%4)+1],Enum.Material.Fabric,false,strings) end
  end
 end
 part("Pole",Vector3.new(.45,15,.45),CFrame.new(-104,7.5,z),C.wood,Enum.Material.Wood,true,strings)
 part("Pole",Vector3.new(.45,15,.45),CFrame.new(104,7.5,z),C.wood,Enum.Material.Wood,true,strings)
end

local stallNames={"TELUR GULUNG","SOSIS & BAKSO BAKAR","JAGUNG BAKAR","CILOK • CIMOL","GULALI","ES TEH • ES JERUK","POPCORN","JASUKE","MARTABAK MINI","TAHU CRISPY","ANEKA MINUMAN","BONEKA & HADIAH"}
local stallColors={C.orange,C.red,C.yellow,C.green,C.pink,C.cyan,C.purple,C.blue,C.red,C.orange,C.green,C.pink}
for i=1,12 do
 local old=market:FindFirstChild("Stall"..i)
 if old and old:IsA("Model") then
  local pivot=old:GetPivot();local yaw=i<=6 and -math.pi/2 or math.pi/2
  old:PivotTo(CFrame.new(pivot.Position)*CFrame.Angles(0,yaw,0))
 end
 local left=i<=6;local row=left and i or i-6
 local x=left and -96 or 96;local z=493+(row-1)*23
 local yaw=left and -math.pi/2 or math.pi/2
 local cf=CFrame.new(x,0,z)*CFrame.Angles(0,yaw,0)
 local front=Instance.new("Model");front.Name="StallFront"..i;front.Parent=premium
 sign(front,"Fascia",stallNames[i],Vector3.new(15,2.1,.3),cf*CFrame.new(0,6.3,-7),stallColors[i],C.white)
 part("CounterTop",Vector3.new(14,.3,3),cf*CFrame.new(0,3.4,-5),C.metal,Enum.Material.Metal,true,front)
 for j=-1,1 do bulb("CounterBulb",cf*CFrame.new(j*4.3,7.1,-7.1),C.warm,front,.35,6) end
 if i<=4 or (i>=8 and i<=10) then
  local grill=part("Grill",Vector3.new(4.5,.25,2.2),cf*CFrame.new(-2,3.7,-5),C.black,Enum.Material.Metal,false,front)
  local smoke=Instance.new("Smoke");smoke.Color=Color3.fromRGB(200,196,188);smoke.Opacity=.07;smoke.Size=2.3;smoke.RiseVelocity=1.1;smoke.Parent=grill
 end
 if i==12 then for r=1,2 do for c=1,5 do ball("Prize",Vector3.new(1.5,1.5,1.5),cf*CFrame.new(-5+(c-1)*2.5,4.2+(r-1)*1.8,-6.5),({C.pink,C.yellow,C.blue,C.green,C.purple})[((r+c)%5)+1],Enum.Material.Fabric,false,front) end end end
end

queue("CarouselQueue",-83,520,14,31,premium);local _,carCounter=booth("CarouselOperator",CFrame.new(-83,0,498),"KOMIDI PUTAR",C.red,premium)
queue("FerrisQueue",85,520,14,31,premium);local _,fCounter=booth("FerrisOperator",CFrame.new(85,0,498),"BIANG LALA",C.blue,premium)
queue("KoraQueue",25,594,14,31,premium);local _,kCounter=booth("KoraOperator",CFrame.new(25,0,618),"KORA-KORA",C.red,premium)

local carousel=market:FindFirstChild("PlayableCarousel")
if carousel then
 for _,o in ipairs(carousel:GetChildren()) do
  if o:IsA("Part") and o.Shape==Enum.PartType.Cylinder and math.max(o.Size.Y,o.Size.Z)>44 and o.Position.Y>12 then o.Transparency=1;o.CanCollide=false end
 end
 local center=Vector3.new(-55,1.5,512)
 for i=1,12 do
  local a=(i-1)*math.pi*2/12
  local panel=CFrame.new(center)*CFrame.Angles(0,-a,0)*CFrame.new(0,15.2,-7.5)*CFrame.Angles(math.rad(-17),0,0)
  part("RoofPanel"..i,Vector3.new(7.2,.32,15.8),panel,i%2==0 and C.red or C.cream,Enum.Material.Fabric,false,carousel)
 end
 ball("CarouselFinial",Vector3.new(2.2,2.2,2.2),CFrame.new(-55,20.2,512),C.yellow,Enum.Material.Neon,false,carousel)
 for i=1,10 do
  local body=carousel:FindFirstChild("Horse"..i)
  if body and body:IsA("BasePart") then
   part("Neck"..i,Vector3.new(1.3,2.7,1.5),body.CFrame*CFrame.new(0,1.6,-1.8)*CFrame.Angles(math.rad(-24),0,0),C.white,Enum.Material.SmoothPlastic,false,carousel)
   ball("Head"..i,Vector3.new(1.9,1.7,2.3),body.CFrame*CFrame.new(0,2.8,-2.4),C.white,Enum.Material.SmoothPlastic,false,carousel)
   for _,x in ipairs({-1,1}) do for _,z in ipairs({-1.4,1.4}) do part("Leg"..i,Vector3.new(.48,2.7,.48),body.CFrame*CFrame.new(x,-1.9,z),C.white,Enum.Material.SmoothPlastic,false,carousel) end end
  end
 end
 for i=1,20 do local a=(i-1)*math.pi*2/20;bulb("CarouselTrim"..i,CFrame.new(-55+math.cos(a)*20,16.1,512+math.sin(a)*20),i%2==0 and C.warm or C.yellow,carousel,.3,5) end
end

local kora=market:FindFirstChild("PlayableKoraKora")
if kora then
 local boat=kora:FindFirstChild("Boat")
 if boat and boat:IsA("BasePart") then
  boat.Transparency=1;boat.CanCollide=false
  part("BoatDeck",Vector3.new(28,3.8,8.5),boat.CFrame,C.red2,Enum.Material.WoodPlanks,true,kora)
  wedge("Bow",Vector3.new(7,5,8.5),boat.CFrame*CFrame.new(-17,.5,0)*CFrame.Angles(0,math.rad(90),0),C.red,Enum.Material.WoodPlanks,true,kora)
  wedge("Stern",Vector3.new(7,5,8.5),boat.CFrame*CFrame.new(17,.5,0)*CFrame.Angles(0,math.rad(-90),0),C.red,Enum.Material.WoodPlanks,true,kora)
  part("RailL",Vector3.new(34,1,.3),boat.CFrame*CFrame.new(0,2.8,-4),C.yellow,Enum.Material.Metal,false,kora)
  part("RailR",Vector3.new(34,1,.3),boat.CFrame*CFrame.new(0,2.8,4),C.yellow,Enum.Material.Metal,false,kora)
  for i=-7,7 do bulb("BoatBulb"..i,boat.CFrame*CFrame.new(i*2.1,4.1,-4.3),i%2==0 and C.warm or C.red,kora,.28,5) end
 end
end

local oldFerris=market:FindFirstChild("PlayableFerrisWheel")
if oldFerris then
 for _,o in ipairs(oldFerris:GetDescendants()) do if o:IsA("BasePart") then o.Transparency=1;o.CanCollide=false;o.CanTouch=false end end
end
for _,o in ipairs(market:GetChildren()) do if o:IsA("BasePart") and (o.Name=="FerrisSupport" or o.Name=="FerrisControl" or o.Name=="FerrisSign") then o.Transparency=1;o.CanCollide=false end end
local ferris=Instance.new("Model");ferris.Name="PremiumFerrisWheel";ferris.Parent=premium
local rotor=Instance.new("Model");rotor.Name="Rotor";rotor.Parent=ferris
local center=Vector3.new(56,29,515)
local hub=part("Hub",Vector3.new(2.2,3.6,3.6),CFrame.new(center),C.yellow,Enum.Material.Metal,false,rotor);rotor.PrimaryPart=hub
for _,sx in ipairs({-1,1}) do
 beam("SupportA",Vector3.new(56+sx*7,1.4,503),Vector3.new(56+sx*1.8,29,515),1.25,C.galv,Enum.Material.Metal,ferris)
 beam("SupportB",Vector3.new(56+sx*7,1.4,527),Vector3.new(56+sx*1.8,29,515),1.25,C.galv,Enum.Material.Metal,ferris)
end
beam("Axle",Vector3.new(50,29,515),Vector3.new(62,29,515),1.7,C.dark,Enum.Material.Metal,ferris)
local rim={}
for i=1,24 do local a=(i-1)*math.pi*2/24;rim[i]=Vector3.new(center.X,center.Y+math.cos(a)*22,center.Z+math.sin(a)*22) end
for i=1,24 do local j=i%24+1;beam("Rim"..i,rim[i],rim[j],.65,i%2==0 and C.red or C.yellow,Enum.Material.Metal,rotor);bulb("RimBulb"..i,CFrame.new(rim[i]),i%2==0 and C.warm or C.red,rotor,.28,5) end
for i=1,12 do local a=(i-1)*math.pi*2/12;beam("Spoke"..i,center,Vector3.new(center.X,center.Y+math.cos(a)*21.5,center.Z+math.sin(a)*21.5),.32,C.galv,Enum.Material.Metal,rotor) end
local gondolas={}
for i=1,10 do
 local g=Instance.new("Model");g.Name="Gondola"..i;g.Parent=ferris
 local r=part("Root",Vector3.new(.2,.2,.2),CFrame.new(center),C.black,Enum.Material.SmoothPlastic,false,g,1);g.PrimaryPart=r
 local col=({C.red,C.blue,C.green,C.yellow,C.purple})[((i-1)%5)+1]
 part("Cabin",Vector3.new(6.8,3.2,4.2),CFrame.new(center),col,Enum.Material.Metal,true,g)
 part("Roof",Vector3.new(7.3,.35,4.7),CFrame.new(center+Vector3.new(0,2.7,0)),C.cream,Enum.Material.Fabric,false,g)
 for _,x in ipairs({-2.8,2.8}) do for _,z in ipairs({-1.6,1.6}) do part("Post",Vector3.new(.22,3,.22),CFrame.new(center+Vector3.new(x,2,z)),C.galv,Enum.Material.Metal,false,g) end end
 local s=Instance.new("Seat");s.Name="RideSeat";s.Size=Vector3.new(3.5,.7,2.1);s.CFrame=CFrame.new(center+Vector3.new(0,1.2,0));s.Anchored=true;s.Color=C.dark;s.Material=Enum.Material.SmoothPlastic;s.Parent=g
 gondolas[i]={model=g,offset=(i-1)*math.pi*2/10}
end
local ferrisRunning=false;local ferrisA=0;local ferrisStart=0
local fPrompt=prompt(fCounter,"MULAI WAHANA","BIANG LALA",.4)
fPrompt.Triggered:Connect(function(plr)
 if ferrisRunning then toast(plr,"Biang lala sedang berjalan.");return end
 ferrisRunning=true;ferrisStart=os.clock();fPrompt.Enabled=false;toast(plr,"Biang lala dimulai • gondola tetap tegak.")
 task.delay(58,function()ferrisRunning=false;fPrompt.Enabled=true end)
end)

local train=Instance.new("Model");train.Name="PlayableMiniTrain";train.Parent=premium
local tc=Vector3.new(-55,1.3,617);local rx,rz=28,17
local outer,inner={},{}
for i=1,32 do local a=(i-1)*math.pi*2/32;outer[i]=Vector3.new(tc.X+math.cos(a)*30,1.25,tc.Z+math.sin(a)*19);inner[i]=Vector3.new(tc.X+math.cos(a)*26,1.25,tc.Z+math.sin(a)*15) end
for i=1,32 do local j=i%32+1;beam("Outer",outer[i],outer[j],.2,C.galv,Enum.Material.Metal,train);beam("Inner",inner[i],inner[j],.2,C.galv,Enum.Material.Metal,train);if i%2==0 then beam("Sleeper",inner[i],outer[i],.3,C.wood,Enum.Material.Wood,train) end end
local cars={}
for i=1,3 do
 local car=Instance.new("Model");car.Name="Car"..i;car.Parent=train
 local r=part("Root",Vector3.new(.2,.2,.2),CFrame.new(tc),C.black,Enum.Material.SmoothPlastic,false,car,1);car.PrimaryPart=r
 local col=({C.red,C.blue,C.yellow})[i]
 part("Body",Vector3.new(4.5,2.2,7.2),CFrame.new(tc),col,Enum.Material.Metal,true,car)
 part("Canopy",Vector3.new(4.8,.35,7.5),CFrame.new(tc+Vector3.new(0,3.6,0)),C.cream,Enum.Material.Fabric,false,car)
 local s=Instance.new("Seat");s.Name="RideSeat";s.Size=Vector3.new(2.8,.7,2);s.CFrame=CFrame.new(tc+Vector3.new(0,1.7,0));s.Anchored=true;s.Color=C.dark;s.Parent=car
 cars[i]={model=car,offset=(i-1)*.78}
end
queue("TrainQueue",-88,617,13,25,premium);local _,trainCounter=booth("TrainOperator",CFrame.new(-88,0,638),"KERETA MINI",C.yellow,premium)
local trainRunning=false;local trainT=0
prompt(trainCounter,"MULAI WAHANA","KERETA MINI",.4).Triggered:Connect(function(plr)
 if trainRunning then toast(plr,"Kereta mini sedang berjalan.");return end
 trainRunning=true;trainT=0;toast(plr,"Kereta mini berangkat.");task.delay(45,function()trainRunning=false end)
end)

local svc=Instance.new("Model");svc.Name="ServiceDetails";svc.Parent=premium
part("ServicePad",Vector3.new(34,.25,20),CFrame.new(-95,1.05,647),C.asphalt,Enum.Material.Asphalt,true,svc)
local gen=part("Generator",Vector3.new(13,5.5,6),CFrame.new(-99,4,649),C.blue,Enum.Material.Metal,true,svc)
part("Vent",Vector3.new(.25,3.2,4.3),gen.CFrame*CFrame.new(6.6,0,0),C.black,Enum.Material.Metal,false,svc)
cylinder("CableReel",4,5,CFrame.new(-85,3.1,650)*CFrame.Angles(0,0,math.rad(90)),C.wood,Enum.Material.Wood,true,svc)
beam("PowerCable",Vector3.new(-84,1.3,644),Vector3.new(-22,1.3,625),.14,C.cable,Enum.Material.SmoothPlastic,svc)
for i,x in ipairs({50,63,76,89}) do
 part("Bench"..i,Vector3.new(7,.6,2),CFrame.new(x,1.7,645),C.wood2,Enum.Material.WoodPlanks,true,svc)
 part("Table"..i,Vector3.new(4,2.4,4),CFrame.new(x,1.8,654),({C.red,C.blue,C.green,C.yellow})[i],Enum.Material.SmoothPlastic,true,svc)
end
for _,x in ipairs({47,94}) do part("Bin",Vector3.new(2.4,3.4,2.4),CFrame.new(x,2.1,637),C.green,Enum.Material.Metal,true,svc) end

local ring=Instance.new("Model");ring.Name="RingToss";ring.Parent=premium
part("Platform",Vector3.new(40,.4,17),CFrame.new(0,1.1,646),C.wood,Enum.Material.WoodPlanks,true,ring)
canopy(ring,CFrame.new(0,0,646),41,18,C.purple,C.cream)
sign(ring,"Name","LEMPAR GELANG • STOP DI BOTOL",Vector3.new(34,2.2,.3),CFrame.new(0,6.2,637.2),C.purple,C.white)
local counter=part("Counter",Vector3.new(35,2.8,2.3),CFrame.new(0,2.1,639),C.wood2,Enum.Material.WoodPlanks,true,ring)
local xs={-14,-10,-6,-2,2,6,10,14}
for row=1,3 do for i,x in ipairs(xs) do local b=cylinder("Bottle",2.5,.8,CFrame.new(x,2.2,646+(row-1)*3)*CFrame.Angles(0,0,math.rad(90)),({C.red,C.yellow,C.blue,C.green})[((row+i)%4)+1],Enum.Material.Glass,false,ring);b.Transparency=.15 end end
local aim=part("Aim",Vector3.new(3,.25,1),CFrame.new(-14,5.1,643),C.yellow,Enum.Material.Neon,false,ring)
local aimIndex=1;local aimDir=1
prompt(counter,"LEMPAR","LEMPAR GELANG").Triggered:Connect(function(plr)
 local d=math.abs(aimIndex-4.5)
 if d<.6 then score(plr,30,"MASUK!") elseif d<1.6 then score(plr,15,"HAMPIR") else toast(plr,"Gelang meleset • coba lagi.") end
end)
task.spawn(function()
 while ring.Parent do
  aimIndex=aimIndex+aimDir*.25
  if aimIndex>=8 then aimIndex=8;aimDir=-1 elseif aimIndex<=1 then aimIndex=1;aimDir=1 end
  local ix=math.clamp(math.floor(aimIndex+.5),1,#xs);aim.CFrame=CFrame.new(xs[ix],5.1,643);task.wait(.08)
 end
end)

RunService.Heartbeat:Connect(function(dt)
 if ferrisRunning then
  local elapsed=os.clock()-ferrisStart;local ramp=math.clamp(math.min(elapsed/7,(58-elapsed)/7),0,1)
  ferrisA=(ferrisA+dt*.19*ramp)%(math.pi*2);rotor:PivotTo(CFrame.new(center)*CFrame.Angles(ferrisA,0,0))
  for _,g in ipairs(gondolas) do local a=ferrisA+g.offset;g.model:PivotTo(CFrame.new(center.X,center.Y+math.cos(a)*22,center.Z+math.sin(a)*22)) end
 end
 if trainRunning then
  trainT=trainT+dt*.44
  for _,car in ipairs(cars) do
   local a=trainT-car.offset;local x=tc.X+math.cos(a)*rx;local z=tc.Z+math.sin(a)*rz;local dx=-math.sin(a)*rx;local dz=math.cos(a)*rz
   local pos=Vector3.new(x,2.5,z);car.model:PivotTo(CFrame.lookAt(pos,pos+Vector3.new(dx,0,dz)))
  end
 end
end)

print("[BBYA] Pasar Malam Premium v3 overlay: realistic frontage + warm fair lighting + refined rides + mini train + ring toss / no injected soundtrack")
