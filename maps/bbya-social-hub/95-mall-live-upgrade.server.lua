-- BBYA SOCIAL HUB — MALL LIVE UPGRADE v2
-- Adds a premium arrival, animated escalator detail, rotating digital signage,
-- atrium kiosks, photo booth, active mall-passport exploration and operational detail.
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local mall=root:WaitForChild("BBYAMall",30)
if not mall then return end
local old=mall:FindFirstChild("MallLiveUpgradeV2")
if old then old:Destroy() end
local up=Instance.new("Model");up.Name="MallLiveUpgradeV2";up.Parent=mall
mall:SetAttribute("Pass","ACTIVE_MALL_V2")
mall:SetAttribute("Operational",true)
mall:SetAttribute("PassportZones",5)

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local v2=remotes:FindFirstChild("MallV2Event") or Instance.new("RemoteEvent")
v2.Name="MallV2Event";v2.Parent=remotes
local state=remotes:FindFirstChild("State")

local C={
 dark=Color3.fromRGB(19,21,25),black=Color3.fromRGB(8,9,11),white=Color3.fromRGB(244,242,236),
 stone=Color3.fromRGB(151,148,140),concrete=Color3.fromRGB(74,76,79),metal=Color3.fromRGB(86,91,99),
 glass=Color3.fromRGB(150,194,207),gold=Color3.fromRGB(214,170,91),pink=Color3.fromRGB(235,56,147),
 cyan=Color3.fromRGB(38,192,214),green=Color3.fromRGB(64,181,119),orange=Color3.fromRGB(226,130,67),
 purple=Color3.fromRGB(141,84,221),red=Color3.fromRGB(203,74,78),wood=Color3.fromRGB(119,84,60),
}
local function part(name,size,cf,color,mat,collide,parent,tr)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.dark;p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Transparency=tr or 0;p.Parent=parent or up
 return p
end
local function glass(name,size,cf,parent,tr)
 local p=part(name,size,cf,C.glass,Enum.Material.Glass,true,parent,tr or .35);p.CastShadow=false;return p
end
local function neon(name,size,cf,color,parent)
 local p=part(name,size,cf,color,Enum.Material.Neon,false,parent);p.CastShadow=false;return p
end
local function roundedCylinder(name,size,cf,color,parent,collide)
 local p=part(name,size,cf,color,Enum.Material.SmoothPlastic,collide,parent);p.Shape=Enum.PartType.Cylinder;return p
end
local function prompt(parent,action,obj,hold)
 local q=Instance.new("ProximityPrompt");q.ActionText=action;q.ObjectText=obj;q.HoldDuration=hold or 0;q.MaxActivationDistance=11;q.RequiresLineOfSight=false;q.Parent=parent;return q
end
local function toast(player,msg)
 if state and state:IsA("RemoteEvent") then state:FireClient(player,"toast",msg) end
end
local function screen(parent,name,size,cf,title,body,accent)
 local p=part(name,size,cf,C.black,Enum.Material.Metal,false,parent)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.PixelsPerStud=62;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.Parent=p
 local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=C.black;bg.BorderSizePixel=0;bg.Parent=g
 local bar=Instance.new("Frame");bar.Size=UDim2.new(0,8,1,0);bar.BackgroundColor3=accent or C.gold;bar.BorderSizePixel=0;bar.Parent=bg
 local h=Instance.new("TextLabel");h.Name="Title";h.BackgroundTransparency=1;h.Position=UDim2.fromOffset(26,18);h.Size=UDim2.new(1,-44,0,46);h.Text=title;h.TextColor3=C.white;h.Font=Enum.Font.GothamBlack;h.TextSize=28;h.TextXAlignment=Enum.TextXAlignment.Left;h.Parent=bg
 local b=Instance.new("TextLabel");b.Name="Body";b.BackgroundTransparency=1;b.Position=UDim2.fromOffset(26,66);b.Size=UDim2.new(1,-44,1,-82);b.Text=body;b.TextColor3=Color3.fromRGB(179,181,187);b.Font=Enum.Font.GothamMedium;b.TextSize=17;b.TextWrapped=true;b.TextXAlignment=Enum.TextXAlignment.Left;b.TextYAlignment=Enum.TextYAlignment.Top;b.Parent=bg
 return p,h,b,bar
end
local function lamp(cf,parent)
 local mast=part("ArrivalLampMast",Vector3.new(.35,8,.35),cf,C.metal,Enum.Material.Metal,true,parent)
 local head=part("ArrivalLampHead",Vector3.new(1.6,.4,.8),cf*CFrame.new(0,4.1,0),C.dark,Enum.Material.Metal,false,parent)
 local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,231,192);light.Brightness=1.4;light.Range=18;light.Shadows=false;light.Parent=head
 return mast
end

-- 1) PREMIUM ARRIVAL / DROP-OFF
local arrival=Instance.new("Model");arrival.Name="PremiumArrival";arrival.Parent=up
part("ArrivalForecourt",Vector3.new(176,.45,24),CFrame.new(0,.8,277),Color3.fromRGB(73,74,76),Enum.Material.Concrete,true,arrival)
-- twin side drop-off lanes keep the existing Funkot connector clear down the center.
for _,x in ipairs({-54,54}) do
 part("DropoffLane"..x,Vector3.new(52,.08,14),CFrame.new(x,1.05,274),Color3.fromRGB(32,34,37),Enum.Material.Asphalt,true,arrival)
 neon("LaneEdgeA"..x,Vector3.new(52,.035,.14),CFrame.new(x,1.11,268),C.white,arrival)
 neon("LaneEdgeB"..x,Vector3.new(52,.035,.14),CFrame.new(x,1.11,280),C.gold,arrival)
end
-- glass-and-metal entrance canopy.
part("CanopySpine",Vector3.new(68,.8,14),CFrame.new(0,11.7,291),C.dark,Enum.Material.Metal,true,arrival)
glass("CanopyGlass",Vector3.new(64,.42,12),CFrame.new(0,11.25,291),arrival,.42)
for _,x in ipairs({-30,-15,0,15,30}) do neon("CanopyRib"..x,Vector3.new(.35,.18,12),CFrame.new(x,11.02,291),C.gold,arrival) end
for _,x in ipairs({-32,32}) do
 part("CanopyColumn"..x,Vector3.new(1.2,10,1.2),CFrame.new(x,6.1,291),C.metal,Enum.Material.Metal,true,arrival)
end
for _,x in ipairs({-78,-62,-46,46,62,78}) do lamp(CFrame.new(x,5,276),arrival) end
for _,x in ipairs({-38,-28,-18,18,28,38}) do
 roundedCylinder("Bollard"..x,Vector3.new(3,.85,.85),CFrame.new(x,2.2,286)*CFrame.Angles(0,0,math.rad(90)),C.metal,arrival,true)
end
-- Valet / concierge podium.
local valet=part("ValetPodium",Vector3.new(7,3,4),CFrame.new(43,2.6,285),C.dark,Enum.Material.Metal,true,arrival)
local vp=prompt(valet,"ASK","MALL CONCIERGE")
vp.Triggered:Connect(function(player)
 toast(player,"Welcome to BBYA Mall • Directory inside the main atrium.")
 v2:FireClient(player,"promo",{title="WELCOME TO BBYA MALL",body="Shop • Eat • Play • Cinema • Complete 5 Mall Passport check-ins."})
end)
local _,_,arrivalBody=screen(arrival,"ArrivalTotem",Vector3.new(13,8,.55),CFrame.new(-43,5.2,285)*CFrame.Angles(0,math.rad(180),0),"BBYA MALL","OPEN • ACTIVE\nDROP-OFF • VALET • DIRECTORY",C.gold)

-- 2) ATRIUM KIOSKS / RETAIL ISLANDS
local kiosks=Instance.new("Model");kiosks.Name="AtriumKiosks";kiosks.Parent=up
local kioskDefs={
 {"BEAN BAR",-20,345,C.orange,"ORDER","Coffee kiosk"},
 {"POP LAB",20,345,C.pink,"BROWSE","Limited drops"},
 {"GADGET GO",-20,385,C.cyan,"TRY","Tech accessories"},
 {"BALI BITES",20,385,C.green,"ORDER","Quick bites"},
}
for i,k in ipairs(kioskDefs) do
 local model=Instance.new("Model");model.Name="Kiosk_"..k[1];model.Parent=kiosks
 roundedCylinder("KioskBase",Vector3.new(1.2,9,9),CFrame.new(k[2],1.7,k[3])*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(48,49,53),model,true)
 roundedCylinder("CounterRing",Vector3.new(.7,10.2,10.2),CFrame.new(k[2],2.5,k[3])*CFrame.Angles(0,0,math.rad(90)),k[4],model,true)
 local pole=part("Pole",Vector3.new(.4,6,.4),CFrame.new(k[2],5,k[3]),C.metal,Enum.Material.Metal,false,model)
 local board,_,body=screen(model,"KioskSign",Vector3.new(8,3,.35),CFrame.new(k[2],8,k[3]-4.7),k[1],k[6],k[4])
 local q=prompt(board,k[5],k[1])
 q.Triggered:Connect(function(player)
  player:SetAttribute("BBYAMallInteractions",(player:GetAttribute("BBYAMallInteractions") or 0)+1)
  toast(player,k[1].." • interaction complete")
 end)
 local spot=Instance.new("PointLight");spot.Color=k[4];spot.Brightness=.8;spot.Range=12;spot.Parent=pole
end

-- 3) DIGITAL MALL NETWORK
local digital=Instance.new("Model");digital.Name="DigitalSignageNetwork";digital.Parent=up
local boards={}
 {screen(digital,"AtriumDigitalSouth",Vector3.new(18,8,.5),CFrame.new(0,10,337),"NOW AT BBYA","SHOP • EAT • PLAY • CINEMA",C.gold)},
 {screen(digital,"AtriumDigitalNorth",Vector3.new(18,8,.5),CFrame.new(0,10,393)*CFrame.Angles(0,math.rad(180),0),"LIVE DIRECTORY","4 LEVELS • 18 TENANTS",C.cyan)},
 {screen(digital,"Level2Digital",Vector3.new(15,6,.45),CFrame.new(-38,20,365)*CFrame.Angles(0,math.rad(90),0),"LEVEL 2","FASHION • AUDIO • SPORT",C.pink)},
 {screen(digital,"Level3Digital",Vector3.new(15,6,.45),CFrame.new(38,34,365)*CFrame.Angles(0,math.rad(-90),0),"LEVEL 3","FOOD HALL • ARCADE • FAMILY",C.green)},
 {screen(digital,"Level4Digital",Vector3.new(15,6,.45),CFrame.new(-38,48,365)*CFrame.Angles(0,math.rad(90),0),"LEVEL 4","CINEMA • SKY LOUNGE",C.purple)},
}
local campaigns={
 {"MALL PASSPORT","CHECK IN AT 5 ZONES • COMPLETE THE BBYA MALL LOOP"},
 {"ATRIUM LIVE","DIGITAL EVENT STAGE • DAILY SOCIAL MOMENTS"},
 {"LEVEL 3","FOOD HALL • PIXEL ARCADE • FAMILY ZONE"},
 {"LEVEL 4","BBYA CINEMA • SCREENINGS • SKY LOUNGE"},
 {"SHOP THE HUB","18 ACTIVE DESTINATIONS ACROSS 4 LEVELS"},
}
task.spawn(function()
 local n=0
 while up.Parent do
  n=(n%#campaigns)+1
  local c=campaigns[n]
  for _,tuple in ipairs(boards) do
   local title=tuple[2];local body=tuple[3];local bar=tuple[4]
   if title and body then
    title.Text=c[1];body.Text=c[2]
    if bar then bar.BackgroundColor3=({C.gold,C.pink,C.green,C.purple,C.cyan})[n] end
   end
  end
  task.wait(12)
 end
end)

-- 4) ATRIUM EVENT STAGE DETAIL
local stage=Instance.new("Model");stage.Name="AtriumLiveStageV2";stage.Parent=up
part("StageDeckV2",Vector3.new(30,.65,18),CFrame.new(0,2.05,365),Color3.fromRGB(30,31,35),Enum.Material.Metal,true,stage)
for _,x in ipairs({-13,13}) do part("StageTrussV"..x,Vector3.new(.6,10,.6),CFrame.new(x,7,372),C.metal,Enum.Material.Metal,false,stage) end
part("StageTrussTop",Vector3.new(27,.6,.6),CFrame.new(0,12,372),C.metal,Enum.Material.Metal,false,stage)
local stageScreen,stageTitle,stageBody=screen(stage,"StageScreen",Vector3.new(23,7,.5),CFrame.new(0,8,373),"ATRIUM LIVE","NEXT: BBYA SOCIAL HOUR",C.pink)
local sq=prompt(stageScreen,"VIEW","ATRIUM LIVE")
sq.Triggered:Connect(function(player)
 v2:FireClient(player,"promo",{title=stageTitle.Text,body=stageBody.Text})
end)
local events={"BBYA SOCIAL HOUR","STREET STYLE SPOTLIGHT","ARCADE CHALLENGE NIGHT","MALL CREATOR MEETUP"}
task.spawn(function()
 local i=0
 while stage.Parent do
  i=(i%#events)+1;stageTitle.Text="ATRIUM LIVE";stageBody.Text="NOW / NEXT • "..events[i]
  task.wait(20)
 end
end)

-- 5) PHOTO BOOTH EXPERIENCE
local booth=Instance.new("Model");booth.Name="BBYAPhotoBooth";booth.Parent=up
part("PhotoBoothFloor",Vector3.new(14,.5,10),CFrame.new(-47,1.6,365),Color3.fromRGB(39,40,45),Enum.Material.Metal,true,booth)
for _,x in ipairs({-53.5,-40.5}) do part("PhotoWall"..x,Vector3.new(.5,10,10),CFrame.new(x,6.3,365),C.dark,Enum.Material.Metal,true,booth) end
part("PhotoBack",Vector3.new(14,10,.5),CFrame.new(-47,6.3,369.8),C.black,Enum.Material.Metal,true,booth)
neon("PhotoStripL",Vector3.new(.2,8,.2),CFrame.new(-52.8,6.2,360.3),C.pink,booth)
neon("PhotoStripR",Vector3.new(.2,8,.2),CFrame.new(-41.2,6.2,360.3),C.cyan,booth)
local cameraPod=part("PhotoCamera",Vector3.new(1.5,2,1.5),CFrame.new(-47,5.5,359.8),C.dark,Enum.Material.Metal,false,booth)
local flash=part("PhotoFlash",Vector3.new(5,4,.25),CFrame.new(-47,7.5,360.1),C.white,Enum.Material.Neon,false,booth,1)
local photoPrompt=prompt(cameraPod,"TAKE PHOTO","BBYA PHOTO BOOTH",.4)
photoPrompt.Triggered:Connect(function(player)
 player:SetAttribute("BBYAMallPhotoBooth",true)
 flash.Transparency=0;v2:FireClient(player,"photo_flash",{})
 task.delay(.12,function()if flash.Parent then flash.Transparency=1 end end)
 toast(player,"BBYA Photo Booth • captured moment")
end)

-- 6) ESCALATOR MOTION DETAIL (visual tread motion; existing mall circulation remains authoritative).
local escalators=Instance.new("Model");escalators.Name="EscalatorMotionDetail";escalators.Parent=up
local movingTreads={}
local function buildEscalator(name,startPos,endPos,color)
 local m=Instance.new("Model");m.Name=name;m.Parent=escalators
 local delta=endPos-startPos
 local yaw=math.atan2(-delta.X,-delta.Z)
 local horiz=Vector3.new(delta.X,0,delta.Z).Magnitude
 local pitch=math.atan2(delta.Y,horiz)
 part("EscalatorBed",Vector3.new(7,.7,delta.Magnitude),CFrame.lookAt((startPos+endPos)/2,endPos)*CFrame.Angles(-pitch,0,0),Color3.fromRGB(52,54,59),Enum.Material.Metal,false,m)
 for _,sx in ipairs({-3.7,3.7}) do
  local mid=(startPos+endPos)/2
  part("Handrail"..sx,Vector3.new(.28,2.4,delta.Magnitude),CFrame.lookAt(mid+Vector3.new(sx,2.1,0),endPos+Vector3.new(sx,2.1,0))*CFrame.Angles(-pitch,0,0),C.dark,Enum.Material.Metal,false,m)
 end
 for i=1,14 do
  local tread=part("MovingTread"..i,Vector3.new(6,.26,1.5),CFrame.new(startPos),color,Enum.Material.Metal,false,m)
  table.insert(movingTreads,{part=tread,a=startPos,b=endPos,phase=(i-1)/14})
 end
end
buildEscalator("EscalatorVisualA",Vector3.new(24,2.2,333),Vector3.new(24,15.5,350),C.metal)
buildEscalator("EscalatorVisualB",Vector3.new(-24,15.5,350),Vector3.new(-24,2.2,333),Color3.fromRGB(112,115,121))
local t0=os.clock()
RunService.Heartbeat:Connect(function()
 local t=(os.clock()-t0)*.085
 for _,row in ipairs(movingTreads) do
  local u=(t+row.phase)%1
  local pos=row.a:Lerp(row.b,u)
  local d=row.b-row.a
  local angle=math.atan2(d.Y,Vector3.new(d.X,0,d.Z).Magnitude)
  row.part.CFrame=CFrame.new(pos)*CFrame.Angles(-angle,0,0)
 end
end)

-- 7) FOOD HALL FURNITURE DETAIL / COMMON AREA
local food=Instance.new("Model");food.Name="FoodHallDetailV2";food.Parent=up
for _,x in ipairs({-20,0,20}) do
 for _,z in ipairs({407,422}) do
  roundedCylinder("FoodTable",Vector3.new(.65,5.4,5.4),CFrame.new(x,31.3,z)*CFrame.Angles(0,0,math.rad(90)),C.wood,food,true)
  for _,off in ipairs({Vector3.new(0,1.3,-4),Vector3.new(0,1.3,4),Vector3.new(-4,1.3,0),Vector3.new(4,1.3,0)}) do
   local s=Instance.new("Seat");s.Name="FoodSeat";s.Size=Vector3.new(2.1,.65,2.1);s.CFrame=CFrame.new(Vector3.new(x,30,z)+off);s.Anchored=true;s.Color=Color3.fromRGB(72,73,77);s.Material=Enum.Material.Fabric;s.Parent=food
  end
 end
end

-- 8) MALL PASSPORT — session exploration loop.
local passport=Instance.new("Folder");passport.Name="MallPassportZones";passport.Parent=up
local zoneDefs={
 {key="ARRIVAL",label="Mall Arrival",pos=Vector3.new(0,3,300),size=Vector3.new(36,8,22)},
 {key="ATRIUM",label="Central Atrium",pos=Vector3.new(0,5,365),size=Vector3.new(50,10,44)},
 {key="LEVEL2",label="Level 2 Retail",pos=Vector3.new(62,18,365),size=Vector3.new(32,8,40)},
 {key="FOOD",label="Food Hall",pos=Vector3.new(0,33,414),size=Vector3.new(54,8,28)},
 {key="CINEMA",label="Cinema Level",pos=Vector3.new(0,47,414),size=Vector3.new(54,8,28)},
}
local visited={}
local touchCooldown={}
local function syncPassport(player,lastLabel)
 local set=visited[player.UserId] or {};local count=0
 for _ in pairs(set) do count+=1 end
 player:SetAttribute("BBYAMallPassport",count)
 if count>=#zoneDefs then player:SetAttribute("BBYAMallPassportComplete",true) end
 v2:FireClient(player,"passport",{count=count,total=#zoneDefs,last=lastLabel,complete=count>=#zoneDefs})
end
for _,z in ipairs(zoneDefs) do
 local sensor=part("Passport_"..z.key,z.size,CFrame.new(z.pos),C.white,Enum.Material.SmoothPlastic,false,passport,1);sensor.CanTouch=true
 sensor.Touched:Connect(function(hit)
  local char=hit and hit.Parent;local player=char and Players:GetPlayerFromCharacter(char)
  if not player then return end
  local token=tostring(player.UserId)..":"..z.key
  if touchCooldown[token] then return end;touchCooldown[token]=true;task.delay(1.5,function()touchCooldown[token]=nil end)
  visited[player.UserId]=visited[player.UserId] or {}
  if visited[player.UserId][z.key] then return end
  visited[player.UserId][z.key]=true
  syncPassport(player,z.label)
  toast(player,"Mall Passport • "..z.label.." checked in")
  local set=visited[player.UserId];local count=0;for _ in pairs(set) do count+=1 end
  if count>=#zoneDefs then
   toast(player,"Mall Passport COMPLETE • BBYA Mall Explorer")
   v2:FireClient(player,"promo",{title="MALL PASSPORT COMPLETE",body="BBYA Mall Explorer • all 5 zones discovered."})
  end
 end)
end
Players.PlayerAdded:Connect(function(player)
 visited[player.UserId]={};player:SetAttribute("BBYAMallPassport",0);player:SetAttribute("BBYAMallPassportComplete",false)
end)
for _,player in ipairs(Players:GetPlayers()) do visited[player.UserId]=visited[player.UserId] or {};player:SetAttribute("BBYAMallPassport",0) end
Players.PlayerRemoving:Connect(function(player)visited[player.UserId]=nil end)

-- Mall presence flag for client HUD and future systems.
local presence=part("MallPresenceVolume",Vector3.new(196,66,166),CFrame.new(0,31,365),C.white,Enum.Material.SmoothPlastic,false,up,1);presence.CanTouch=true
local inside={}
presence.Touched:Connect(function(hit)
 local player=hit and hit.Parent and Players:GetPlayerFromCharacter(hit.Parent)
 if not player or inside[player] then return end
 inside[player]=true;player:SetAttribute("BBYAInsideMall",true);syncPassport(player,nil)
 v2:FireClient(player,"presence",{inside=true})
end)
-- position sweep handles clean exit because TouchEnded is unreliable on streamed geometry.
task.spawn(function()
 while up.Parent do
  for _,player in ipairs(Players:GetPlayers()) do
   local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
   if hrp then
    local p=hrp.Position;local inMall=math.abs(p.X)<=100 and p.Z>=282 and p.Z<=448 and p.Y>=-2 and p.Y<=66
    if inMall~=inside[player] then
     inside[player]=inMall;player:SetAttribute("BBYAInsideMall",inMall);v2:FireClient(player,"presence",{inside=inMall})
    end
   end
  end
  task.wait(1)
 end
end)

print("[BBYA] Mall Live Upgrade v2 online: premium arrival / kiosks / digital network / live stage / photo booth / escalator motion / passport")