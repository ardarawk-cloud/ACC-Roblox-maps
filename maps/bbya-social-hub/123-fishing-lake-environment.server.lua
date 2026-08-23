-- BBYA SOCIAL HUB — PREMIUM FISHING LAKE ENVIRONMENT v2
-- Premium rear-of-Night-Market district. Environment only; gameplay lives in 124-fishing-core.server.lua.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 35)
if not root then return end
local market = root:WaitForChild("BBYANightMarket", 35)
if not market then return end

task.wait(1.8)
local old = root:FindFirstChild("PremiumFishingDistrictV2")
if old then old:Destroy() end

local district = Instance.new("Model")
district.Name = "PremiumFishingDistrictV2"
district.Parent = root
district:SetAttribute("Pass", "PREMIUM_FISHING_DISTRICT_V2")
district:SetAttribute("MarketRearBoundaryZ", 685)
district:SetAttribute("LakeCenterX", 0)
district:SetAttribute("LakeCenterZ", 790)
district:SetAttribute("LakeRadiusX", 112)
district:SetAttribute("LakeRadiusZ", 70)
district:SetAttribute("DesignLanguage", "warm luxury lakeside + night market")
district:SetAttribute("NoFlat2DHeroAssets", true)

local LAKE_X, LAKE_Z = 0, 790
local RX, RZ = 112, 70
local WATER_Y = 0.25

local C = {
 dark=Color3.fromRGB(15,18,23), charcoal=Color3.fromRGB(27,31,37), graphite=Color3.fromRGB(43,48,55),
 metal=Color3.fromRGB(87,92,98), stone=Color3.fromRGB(112,108,101), stone2=Color3.fromRGB(74,75,73),
 wood=Color3.fromRGB(111,77,51), wood2=Color3.fromRGB(73,49,35), brass=Color3.fromRGB(206,164,90),
 warm=Color3.fromRGB(255,221,171), white=Color3.fromRGB(242,242,239), leaf=Color3.fromRGB(51,88,59),
 leaf2=Color3.fromRGB(73,108,72), water=Color3.fromRGB(27,83,101), water2=Color3.fromRGB(10,39,57),
 gold=Color3.fromRGB(239,188,77), cyan=Color3.fromRGB(70,205,220), pink=Color3.fromRGB(238,104,169),
}

local function model(name,parent)
 local m=Instance.new("Model");m.Name=name;m.Parent=parent or district;return m
end
local function part(name,size,cf,color,material,collide,parent,transparency)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=collide==true;p.CanQuery=true;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CastShadow=p.Transparency<.92;p.Parent=parent or district;return p
end
local function ball(name,size,cf,color,material,collide,parent,transparency)
 local p=part(name,size,cf,color,material,collide,parent,transparency);p.Shape=Enum.PartType.Ball;return p
end
local function cylinder(name,size,cf,color,material,collide,parent,transparency)
 local p=part(name,size,cf,color,material,collide,parent,transparency);p.Shape=Enum.PartType.Cylinder;return p
end
local function wedge(name,size,cf,color,material,collide,parent,transparency)
 local p=Instance.new("WedgePart");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.graphite;p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CastShadow=p.Transparency<.92;p.Parent=parent or district;return p
end
local function light(parent,brightness,range,color)
 local l=Instance.new("PointLight");l.Color=color or C.warm;l.Brightness=brightness or .7;l.Range=range or 14;l.Shadows=true;l.Parent=parent;return l
end
local function signFaces(board,title,sub)
 for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
  local g=Instance.new("SurfaceGui");g.Face=face;g.PixelsPerStud=56;g.LightInfluence=.12;g.Parent=board
  local bg=Instance.new("Frame");bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=C.dark;bg.BorderSizePixel=0;bg.Parent=g
  local a=Instance.new("Frame");a.Size=UDim2.new(0,6,1,0);a.BackgroundColor3=C.brass;a.BorderSizePixel=0;a.Parent=bg
  local h=Instance.new("TextLabel");h.BackgroundTransparency=1;h.Position=UDim2.fromScale(.08,.12);h.Size=UDim2.fromScale(.84,.43);h.Text=title;h.TextColor3=C.white;h.Font=Enum.Font.GothamBlack;h.TextScaled=true;h.TextXAlignment=Enum.TextXAlignment.Left;h.Parent=bg
  local s=Instance.new("TextLabel");s.BackgroundTransparency=1;s.Position=UDim2.fromScale(.08,.63);s.Size=UDim2.fromScale(.84,.18);s.Text=sub;s.TextColor3=Color3.fromRGB(183,180,173);s.Font=Enum.Font.GothamBold;s.TextScaled=true;s.TextXAlignment=Enum.TextXAlignment.Left;s.Parent=bg
 end
end
local function lamp(name,x,z,parent,height)
 height=height or 6.2;local m=model(name,parent)
 cylinder("Post",Vector3.new(height,.30,.30),CFrame.new(x,1.05+height/2,z)*CFrame.Angles(0,0,math.rad(90)),C.graphite,Enum.Material.Metal,true,m)
 local orb=ball("Glow",Vector3.new(.74,.74,.74),CFrame.new(x,1.1+height,z),C.warm,Enum.Material.Glass,false,m,.10);light(orb,.65,14,C.warm);return m
end
local function bench(name,cf,parent)
 local m=model(name,parent);part("Seat",Vector3.new(6.3,.42,1.5),cf*CFrame.new(0,1.42,0),C.wood,Enum.Material.WoodPlanks,true,m)
 part("Back",Vector3.new(6.3,2.2,.34),cf*CFrame.new(0,2.38,.66)*CFrame.Angles(math.rad(-7),0,0),C.wood2,Enum.Material.WoodPlanks,true,m)
 for _,x in ipairs({-2.45,2.45}) do part("Leg"..x,Vector3.new(.32,1.25,1.1),cf*CFrame.new(x,.72,0),C.graphite,Enum.Material.Metal,true,m) end;return m
end
local function planter(name,pos,parent)
 local m=model(name,parent);cylinder("Pot",Vector3.new(1.8,2.9,2.9),CFrame.new(pos.X,1.25,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.stone2,Enum.Material.Concrete,true,m)
 cylinder("Trunk",Vector3.new(3.1,.38,.38),CFrame.new(pos.X,3.1,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.wood2,Enum.Material.Wood,false,m)
 for i=1,6 do local a=math.rad((i-1)*60);ball("Leaf"..i,Vector3.new(1.75,2.25,1.5),CFrame.new(pos.X+math.cos(a),5.0+(i%2)*.2,pos.Z+math.sin(a)),i%2==0 and C.leaf2 or C.leaf,Enum.Material.SmoothPlastic,false,m) end;return m
end

-- Make a deliberate 26-stud passage through the rear market safety rail once the guard is available.
task.spawn(function()
 local guard=root:WaitForChild("NightMarketBoundaryLayoutGuardV1",12)
 if not guard then return end
 for _,d in ipairs(guard:GetDescendants()) do
  if d:IsA("BasePart") and d.Position.Z>679 and d.Position.Z<685 and math.abs(d.Position.X)<14 then
   local n=string.lower(d.Name)
   if string.find(n,"rail") or string.find(n,"barrier") or string.find(n,"fence") then d:Destroy() end
  end
 end
end)

local env=model("Environment")
-- Low landscape base, leaving the boardwalk above the shoreline and avoiding a flat floating platform look.
part("LakesideGround",Vector3.new(286,1.2,205),CFrame.new(0,-1.05,786),Color3.fromRGB(54,67,53),Enum.Material.Ground,true,env)

-- Two translucent elliptical layers create depth/reflection without a square pond footprint.
local deep=ball("DeepWater",Vector3.new(RX*2.04,1.25,RZ*2.04),CFrame.new(LAKE_X,WATER_Y-.34,LAKE_Z),C.water2,Enum.Material.Glass,false,env,.18);deep.Reflectance=.04
local water=ball("LakeWater",Vector3.new(RX*2,.54,RZ*2),CFrame.new(LAKE_X,WATER_Y,LAKE_Z),C.water,Enum.Material.Glass,false,env,.27);water.Reflectance=.12;water:SetAttribute("BBYAFishingWater",true)

-- Organic stone shoreline: 40 tangent segments around an ellipse, never a rectangular rim.
local shore=model("NaturalStoneShore",env)
for i=0,39 do
 local a=(i/40)*math.pi*2;local x=LAKE_X+math.cos(a)*(RX+3.5);local z=LAKE_Z+math.sin(a)*(RZ+3.5)
 local tangent=Vector3.new(-RX*math.sin(a),0,RZ*math.cos(a)).Unit;local yaw=math.atan2(tangent.X,tangent.Z)
 part("ShoreStone"..i,Vector3.new(13.2+(i%3)*1.1,1.55,6.0),CFrame.new(x,.18,z)*CFrame.Angles(0,yaw,0),i%2==0 and C.stone or C.stone2,Enum.Material.Slate,true,shore)
end

-- Premium reveal from the Night Market.
local approach=model("MarketLakeApproach",env)
part("ApproachDeck",Vector3.new(25,1.05,54),CFrame.new(0,.88,707),C.wood,Enum.Material.WoodPlanks,true,approach)
for _,x in ipairs({-12.8,12.8}) do
 part("GatePost"..x,Vector3.new(1.2,10.5,1.2),CFrame.new(x,5.6,686.5),C.graphite,Enum.Material.Metal,true,approach)
 part("GateCap"..x,Vector3.new(1.45,.35,1.45),CFrame.new(x,10.75,686.5),C.brass,Enum.Material.Metal,false,approach)
end
part("GateHeader",Vector3.new(27,1,1.3),CFrame.new(0,10.2,686.5),C.graphite,Enum.Material.Metal,true,approach)
local entry=part("EntrySign",Vector3.new(18,3.3,.36),CFrame.new(0,8.35,685.78),C.dark,Enum.Material.Metal,false,approach);signFaces(entry,"BBYA LAKESIDE","FISH • RELAX • COLLECT")
for _,z in ipairs({692,708,724}) do lamp("ApproachL"..z,-10.4,z,approach,6.2);lamp("ApproachR"..z,10.4,z,approach,6.2) end

-- Main public pier, sized for a social group rather than a tiny fishing plank.
local pier=model("MainFishingPier",env)
part("PierDeck",Vector3.new(18,1.12,64),CFrame.new(0,1.0,751),C.wood,Enum.Material.WoodPlanks,true,pier)
for _,x in ipairs({-9.4,9.4}) do for z=726,777,10 do cylinder("Post"..x.."_"..z,Vector3.new(4.4,.5,.5),CFrame.new(x,-.05,z)*CFrame.Angles(0,0,math.rad(90)),C.wood2,Enum.Material.Wood,true,pier) end end
for _,z in ipairs({732,746,760,774}) do lamp("PierL"..z,-8,z,pier,5.35);lamp("PierR"..z,8,z,pier,5.35) end

-- Social boardwalks: the lake remains useful even for players who are not fishing.
local promenade=model("LakesidePromenade",env)
part("WestDeck",Vector3.new(70,.95,12),CFrame.new(-53,.9,724),C.wood2,Enum.Material.WoodPlanks,true,promenade)
part("EastDeck",Vector3.new(70,.95,12),CFrame.new(53,.9,724),C.wood2,Enum.Material.WoodPlanks,true,promenade)
for _,spec in ipairs({{-67,720},{-38,720},{38,720},{67,720}}) do bench("Bench"..spec[1],CFrame.new(spec[1],.2,spec[2])*CFrame.Angles(0,math.rad(180),0),promenade) end
for _,x in ipairs({-78,-50,-24,24,50,78}) do lamp("Promenade"..x,x,730,promenade,6.0) end

-- Boutique fishing atelier with dimensional rod showcase.
local shop=model("FishingAtelier",env)
part("Floor",Vector3.new(35,.9,25),CFrame.new(-92,.7,700),C.stone2,Enum.Material.Slate,true,shop)
part("RearWall",Vector3.new(35,10,1),CFrame.new(-92,5.6,711.7),C.dark,Enum.Material.Concrete,true,shop)
part("LeftWall",Vector3.new(1,10,25),CFrame.new(-109,5.6,700),C.dark,Enum.Material.Concrete,true,shop)
part("RightPier",Vector3.new(1.2,10,4),CFrame.new(-75,5.6,709),C.graphite,Enum.Material.Metal,true,shop)
part("Canopy",Vector3.new(36,.75,26),CFrame.new(-92,10.65,700),C.graphite,Enum.Material.Metal,true,shop)
local shopSign=part("ShopSign",Vector3.new(22,3,.38),CFrame.new(-92,8.6,687.3),C.dark,Enum.Material.Metal,false,shop);signFaces(shopSign,"BBYA ANGLER","RODS • SKINS • LAKE TOKENS")
for _,x in ipairs({-104,-96,-88,-80}) do local d=part("CanopyLight"..x,Vector3.new(.6,.22,.6),CFrame.new(x,10.15,697),C.warm,Enum.Material.Neon,false,shop);light(d,.45,9,C.warm) end

local rack=model("RodDisplayRack",shop)
part("RackBack",Vector3.new(22,6.3,.45),CFrame.new(-92,4.2,710.9),C.graphite,Enum.Material.Metal,false,rack)
local accents={C.white,C.pink,C.cyan,Color3.fromRGB(230,72,72),C.gold}
for i=1,5 do
 local x=-102+(i-1)*5;local accent=accents[i]
 cylinder("RodBase"..i,Vector3.new(5.8,.18,.18),CFrame.new(x,5.1,710.3)*CFrame.Angles(0,0,math.rad(78)),accent,Enum.Material.Metal,false,rack)
 cylinder("RodTip"..i,Vector3.new(3.7,.11,.11),CFrame.new(x+.8,7.3,710.3)*CFrame.Angles(0,0,math.rad(78)),accent,Enum.Material.Metal,false,rack)
 cylinder("Reel"..i,Vector3.new(.55,.75,.75),CFrame.new(x-.5,3.2,710.0)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,false,rack)
end
local counter=part("RodCounter",Vector3.new(12,2.3,2.6),CFrame.new(-92,1.9,689.8),C.wood2,Enum.Material.WoodPlanks,true,shop)
local prompt=Instance.new("ProximityPrompt");prompt.Name="GetFishingRod";prompt.ActionText="Ambil Pancing";prompt.ObjectText="BBYA ANGLER";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.HoldDuration=.15;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Parent=counter

-- Rare cove: darker, greener, and visually distinct for high-rarity hunting.
local rare=model("RareFishingCove",env)
local rareDeck=part("RareCoveDeck",Vector3.new(14,1,42),CFrame.new(86,1,812)*CFrame.Angles(0,math.rad(-32),0),C.wood2,Enum.Material.WoodPlanks,true,rare);rareDeck:SetAttribute("FishingSpot","RARE_COVE")
for _,p in ipairs({Vector3.new(103,0,834),Vector3.new(111,0,815),Vector3.new(105,0,792),Vector3.new(92,0,847)}) do planter("Cove"..math.floor(p.X+p.Z),p,rare) end
local rareSign=part("RareSign",Vector3.new(9,2.6,.3),CFrame.new(93,5,786)*CFrame.Angles(0,math.rad(28),0),C.dark,Enum.Material.Metal,false,rare);signFaces(rareSign,"MOON COVE","RARE WATER")

-- Scenic pier balances the opposite side and provides a premium photo / social point.
local scenic=model("ScenicPier",env)
local scenicDeck=part("ScenicDeck",Vector3.new(15,1,44),CFrame.new(-88,1,816)*CFrame.Angles(0,math.rad(30),0),C.wood,Enum.Material.WoodPlanks,true,scenic);scenicDeck:SetAttribute("FishingSpot","SCENIC_PIER")
bench("ScenicBench",CFrame.new(-100,.2,837)*CFrame.Angles(0,math.rad(145),0),scenic);lamp("ScenicA",-94,829,scenic,5.8);lamp("ScenicB",-81,803,scenic,5.8)

-- Three-dimensional hero fish display at the atelier entrance.
local display=model("FishShowcase",shop)
local displaySpecs={
 {body=Color3.fromRGB(195,49,62),accent=Color3.fromRGB(250,145,78),cf=CFrame.new(-103,3,687.2)},
 {body=Color3.fromRGB(63,91,135),accent=Color3.fromRGB(77,226,207),cf=CFrame.new(-92,3,687.2)},
 {body=Color3.fromRGB(237,236,222),accent=Color3.fromRGB(242,191,72),cf=CFrame.new(-81,3,687.2)},
}
for i,s in ipairs(displaySpecs) do
 ball("Body"..i,Vector3.new(6.1,2.35,2.05),s.cf,s.body,Enum.Material.SmoothPlastic,false,display)
 wedge("TailTop"..i,Vector3.new(2.2,2.65,.4),s.cf*CFrame.new(-3.6,.5,0)*CFrame.Angles(0,math.rad(90),0),s.accent,Enum.Material.SmoothPlastic,false,display)
 wedge("TailBottom"..i,Vector3.new(2.2,2.65,.4),s.cf*CFrame.new(-3.6,-.5,0)*CFrame.Angles(math.rad(180),math.rad(90),0),s.accent,Enum.Material.SmoothPlastic,false,display)
 wedge("Dorsal"..i,Vector3.new(1.8,1.2,.28),s.cf*CFrame.new(-.35,1.2,0)*CFrame.Angles(0,math.rad(90),0),s.accent,Enum.Material.SmoothPlastic,false,display)
 ball("EyeL"..i,Vector3.new(.34,.34,.34),s.cf*CFrame.new(2.25,.42,-.92),Color3.fromRGB(7,8,9),Enum.Material.SmoothPlastic,false,display)
 ball("EyeR"..i,Vector3.new(.34,.34,.34),s.cf*CFrame.new(2.25,.42,.92),Color3.fromRGB(7,8,9),Enum.Material.SmoothPlastic,false,display)
end

district:SetAttribute("InstalledDescendants",#district:GetDescendants())
print("[BBYA] Premium Fishing Lake environment v2 online: premium lake + boardwalk + atelier + rare cove")
