-- BBYA SOCIAL HUB — PREMIUM PHASE 5 v4.5.1
-- Final venue-density + crowd-atmosphere pass. No fake NPC crowds; reacts to real players.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ROOT_NAME = "BBYA Premium Phase 5 v4.5"
local old = workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end

local rebuild = workspace:WaitForChild("BBYA Premium Visual Rebuild v4",15)
if not rebuild then
 warn("[BBYA PHASE5] Premium Visual Rebuild v4 missing")
 return
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = workspace

local C = {
 black=Color3.fromRGB(8,8,14),
 dark=Color3.fromRGB(22,19,29),
 stone=Color3.fromRGB(44,39,50),
 stone2=Color3.fromRGB(61,52,65),
 pink=Color3.fromRGB(255,45,170),
 purple=Color3.fromRGB(130,65,228),
 cyan=Color3.fromRGB(48,228,255),
 blue=Color3.fromRGB(50,125,255),
 gold=Color3.fromRGB(255,193,79),
 warm=Color3.fromRGB(255,125,70),
 glass=Color3.fromRGB(72,102,132),
 wood=Color3.fromRGB(86,61,44),
 green=Color3.fromRGB(38,105,69),
}

local function part(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide~=false
 p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or C.stone;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or root
 return p
end

local function neon(name,size,cf,color,parent,withLight)
 local p=part(name,size,cf,color or C.pink,Enum.Material.Neon,0,false,parent)
 p:SetAttribute("BBYADecorativeNeon",true)
 if withLight then
  p:SetAttribute("BBYADecorativeLight",true)
  local l=Instance.new("PointLight")
  l.Color=p.Color;l.Brightness=.45;l.Range=8;l.Shadows=false;l.Parent=p
 end
 return p
end

local function sign(name,text,cf,size,color,parent)
 local p=part(name,size,cf,C.black,Enum.Material.Metal,0,false,parent)
 local g=Instance.new("SurfaceGui")
 g.Face=Enum.NormalId.Front;g.LightInfluence=0;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=30;g.Parent=p
 local t=Instance.new("TextLabel")
 t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=color or C.pink;t.TextStrokeTransparency=.28
 t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=g
 return p
end

local function seat(name,cf,size,color,parent)
 local s=Instance.new("Seat")
 s.Name=name;s.Size=size or Vector3.new(6,1.3,4);s.CFrame=cf;s.Anchored=true;s.Material=Enum.Material.Fabric;s.Color=color or Color3.fromRGB(77,47,84);s.Parent=parent
 return s
end

local function loungePod(parent,name,center,yaw,accent)
 local f=Instance.new("Folder");f.Name=name;f.Parent=parent
 local cf=CFrame.new(center)*CFrame.Angles(0,math.rad(yaw or 0),0)
 seat(name.." Sofa A",cf*CFrame.new(-5,0,0),Vector3.new(7,1.3,4),Color3.fromRGB(76,47,82),f)
 seat(name.." Sofa B",cf*CFrame.new(5,0,0),Vector3.new(7,1.3,4),Color3.fromRGB(68,44,78),f)
 part(name.." Table",Vector3.new(5,.9,4),cf*CFrame.new(0,.1,-4.4),C.black,Enum.Material.Glass,.12,true,f)
 neon(name.." Accent",Vector3.new(12,.14,.16),cf*CFrame.new(0,1.15,2.3),accent or C.pink,f,false)
 return f
end

-- ============================================================
-- 01 ARRIVAL DENSITY / PREMIUM QUEUE LANGUAGE
-- ============================================================
local arrival=Instance.new("Folder");arrival.Name="01 Arrival Density";arrival.Parent=root

-- Valet/queue bollards keep the entry from feeling like an empty plaza.
for _,x in ipairs({-34,-22,-10,10,22,34}) do
 for _,z in ipairs({88,97}) do
  local postCF=CFrame.new(x,3,z)*CFrame.Angles(0,0,math.rad(90))
  local post=part("Arrival Bollard "..x.." "..z,Vector3.new(3,.8,.8),postCF,C.black,Enum.Material.Metal,0,true,arrival)
  post.Shape=Enum.PartType.Cylinder
  local cap=neon("Bollard Cap "..x.." "..z,Vector3.new(.12,1,1),CFrame.new(x,4.5,z)*CFrame.Angles(0,0,math.rad(90)),x<0 and C.cyan or C.pink,arrival,false)
  cap.Shape=Enum.PartType.Cylinder
 end
end
for _,z in ipairs({88,97}) do
 for _,x in ipairs({-28,-16,16,28}) do
  neon("Queue Rope "..x.." "..z,Vector3.new(11,.12,.12),CFrame.new(x,3.7,z),x<0 and C.cyan or C.pink,arrival,false)
 end
end

-- Arrival feature plaques + photo moment.
sign("Arrival Dress Code","BBYA NIGHT STANDARD",CFrame.new(-52,7,82.5),Vector3.new(22,3,.3),C.gold,arrival)
sign("Arrival Experience","MUSIC • DANCE • ROOFTOP",CFrame.new(52,7,82.5),Vector3.new(24,3,.3),C.cyan,arrival)
part("Arrival Photo Plinth",Vector3.new(24,.8,10),CFrame.new(0,2,91),C.dark,Enum.Material.Marble,0,true,arrival)
neon("Arrival Plinth Edge",Vector3.new(23,.14,.18),CFrame.new(0,2.45,86.1),C.pink,arrival,true)

-- ============================================================
-- 02 MAIN CLUB INTERIOR DENSITY
-- ============================================================
local club=Instance.new("Folder");club.Name="02 Main Club Density";club.Parent=root

-- Speaker towers give the stage actual scale.
for _,x in ipairs({-43,43}) do
 local f=Instance.new("Folder");f.Name="Speaker Tower "..x;f.Parent=club
 part("Speaker Column",Vector3.new(8,18,6),CFrame.new(x,11,-52),C.black,Enum.Material.Metal,0,true,f)
 for y=5,17,4 do
  local coneCF=CFrame.new(x,y,-48.8)*CFrame.Angles(0,math.rad(90),0)
  local cone=part("Speaker Cone "..y,Vector3.new(.7,4,4),coneCF,Color3.fromRGB(29,27,34),Enum.Material.Metal,0,false,f)
  cone.Shape=Enum.PartType.Cylinder
  local ring=neon("Speaker Ring "..y,Vector3.new(.12,4.25,4.25),cone.CFrame*CFrame.new(.42,0,0),x<0 and C.cyan or C.pink,f,false)
  ring.Shape=Enum.PartType.Cylinder
 end
end

-- Social islands outside dance-floor footprint.
loungePod(club,"West Social Island",Vector3.new(-51,2,8),15,C.cyan)
loungePod(club,"East Social Island",Vector3.new(51,2,8),-15,C.pink)
loungePod(club,"West Rear Lounge",Vector3.new(-51,2,-31),-10,C.purple)
loungePod(club,"East Rear Lounge",Vector3.new(51,2,-31),10,C.gold)

-- Bottle-service rails / standing counters.
for _,x in ipairs({-62,62}) do
 part("Standing Rail "..x,Vector3.new(18,1.1,3),CFrame.new(x,4,30),C.black,Enum.Material.Marble,0,true,club)
 neon("Standing Rail Glow "..x,Vector3.new(17,.12,.16),CFrame.new(x,4.6,28.55),x<0 and C.cyan or C.pink,club,false)
 for _,ox in ipairs({-6,0,6}) do seat("Rail Stool "..x.." "..ox,CFrame.new(x+ox,2.4,25.5),Vector3.new(3,1.1,3),Color3.fromRGB(76,47,82),club) end
end

-- Crowd-reactive floor halo. No fake NPCs; intensity is based on real players.
local crowdZone=part("Real Crowd Zone",Vector3.new(88,12,66),CFrame.new(0,7,-6),Color3.new(1,1,1),Enum.Material.SmoothPlastic,1,false,club)
local halo={}
for i=0,15 do
 local a=(math.pi*2)*(i/16)
 local x=math.cos(a)*40
 local z=-6+math.sin(a)*29
 local h=neon("Crowd Halo "..i,Vector3.new(4,.16,.3),CFrame.new(x,1.9,z)*CFrame.Angles(0,-a,0),i%2==0 and C.pink or C.cyan,club,false)
 h.Transparency=.45
 table.insert(halo,h)
end

local function playersInside(zone)
 local count=0
 local half=zone.Size/2
 for _,p in ipairs(Players:GetPlayers()) do
  local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
  if hrp then
   local q=zone.CFrame:PointToObjectSpace(hrp.Position)
   if math.abs(q.X)<=half.X and math.abs(q.Y)<=half.Y and math.abs(q.Z)<=half.Z then count+=1 end
  end
 end
 return count
end

local crowdLevel=-1
local function applyCrowdLevel(level,count)
 if level==crowdLevel then workspace:SetAttribute("BBYARealCrowdCount",count);return end
 crowdLevel=level
 workspace:SetAttribute("BBYACrowdIntensity",level)
 workspace:SetAttribute("BBYARealCrowdCount",count)
 local transparency=level==0 and .72 or (level==1 and .48 or (level==2 and .25 or .08))
 for i,h in ipairs(halo) do
  local col
  if level>=3 then col=i%3==0 and C.gold or (i%2==0 and C.pink or C.cyan)
  elseif level==2 then col=i%2==0 and C.pink or C.cyan
  elseif level==1 then col=i%2==0 and C.purple or C.blue
  else col=i%2==0 and C.purple or C.cyan end
  TweenService:Create(h,TweenInfo.new(.5),{Color=col,Transparency=transparency}):Play()
 end
end

task.spawn(function()
 while root.Parent do
  local n=playersInside(crowdZone)
  local level=n>=10 and 3 or (n>=5 and 2 or (n>=2 and 1 or 0))
  applyCrowdLevel(level,n)
  task.wait(1.5)
 end
end)

-- ============================================================
-- 03 ROOFTOP SERVICE DENSITY
-- ============================================================
local roof=Instance.new("Folder");roof.Name="03 Rooftop Service Density";roof.Parent=root

for _,cfg in ipairs({{-58,38,-18,0,C.cyan},{58,38,-18,180,C.pink},{-58,38,35,0,C.gold},{58,38,35,180,C.purple}}) do
 local x,y,z,yaw,accent=cfg[1],cfg[2],cfg[3],cfg[4],cfg[5]
 local f=loungePod(roof,"Bottle Service Pod "..x.." "..z,Vector3.new(x,y,z),yaw,accent)
 part("Bottle Ice Bucket",Vector3.new(2.2,1.6,2.2),CFrame.new(x,y+1.2,z-4.3),C.glass,Enum.Material.Glass,.25,false,f)
 neon("Bottle Sparkle",Vector3.new(.6,1.8,.6),CFrame.new(x,y+2.2,z-4.3),accent,f,true)
end

-- Rooftop perimeter standing ledges.
for _,x in ipairs({-84,84}) do
 part("Rooftop View Ledge "..x,Vector3.new(2.5,1,48),CFrame.new(x,40,8),C.black,Enum.Material.Marble,0,true,roof)
 neon("Rooftop Ledge Glow "..x,Vector3.new(.16,.16,46),CFrame.new(x + (x<0 and 1.3 or -1.3),40.6,8),x<0 and C.cyan or C.pink,roof,false)
end

workspace:SetAttribute("BBYAPremiumPhase5","4.5.1")
print("[BBYA] Premium Phase 5 v4.5.1 loaded — real crowd atmosphere + venue density")
