-- BBYA SOCIAL HUB — FRONT LOBBY FINAL REBUILD v4.9
-- Live-playtest correction. This script intentionally runs AFTER the older premium layers settle,
-- then removes their arrival/lobby geometry and builds one clean entrance axis.

local ROOT_NAME = "BBYA Front Lobby v4.9"

-- Roblox server scripts start in parallel. Wait so legacy/premium builders finish first,
-- otherwise deleted pieces can reappear after this script runs.
task.wait(7)

for _,name in ipairs({ROOT_NAME,"BBYA Front Lobby v4.8"}) do
 local old=workspace:FindFirstChild(name)
 if old then old:Destroy() end
end

-- Remove old arrival/lobby geometry only. Main club/VIP/rooftop stay intact.
local rebuild=workspace:FindFirstChild("BBYA Premium Visual Rebuild v4")
if rebuild then
 local arrival=rebuild:FindFirstChild("01 Arrival Courtyard")
 if arrival then
  local removeExact={
   ["Facade Crown"]=true,["Facade Wing L"]=true,["Facade Wing R"]=true,
   ["Facade Crown Pink"]=true,["Facade Crown Cyan"]=true,
   ["BBYA Arrival Sign"]=true,["Arrival Subtitle"]=true,
   ["Lobby Floor Premium"]=true,["Lobby Ceiling"]=true,["Lobby Direction"]=true,
  }
  local list=arrival:GetDescendants()
  for i=#list,1,-1 do
   local o=list[i]
   if removeExact[o.Name] or string.find(o.Name,"Lobby Blade",1,true)==1 then o:Destroy() end
  end
 end
end

local phase3=workspace:FindFirstChild("BBYA Premium Phase 3 v4.3")
if phase3 then
 local oldLobby=phase3:FindFirstChild("01 Premium Lobby Experience")
 if oldLobby then oldLobby:Destroy() end
end

-- Remove old lobby/front signage that caused stacked text in screenshots.
local hideNames={
 ["WF Arrival Welcome"]=true,["WF Lobby Directory"]=true,["Lobby Direction"]=true,
 ["Concierge Sign"]=true,["Portal Title"]=true,["Stage Brand"]=true,
 ["WF Main Club"]=true,["WF West Services"]=true,["WF East Services"]=true,
 ["VIP Left Sign"]=true,["VIP Right Sign"]=true,["Roof Wayfinding L"]=true,["Roof Wayfinding R"]=true,
}
for _,o in ipairs(workspace:GetDescendants()) do
 if o:IsA("BasePart") and hideNames[o.Name] then
  o.Transparency=1;o.CanCollide=false;o.CanTouch=false
  for _,c in ipairs(o:GetChildren()) do if c:IsA("SurfaceGui") then c.Enabled=false end end
 end
end

local root=Instance.new("Folder")
root.Name=ROOT_NAME
root.Parent=workspace

local C={
 dark=Color3.fromRGB(39,34,42), dark2=Color3.fromRGB(54,47,56),
 floor=Color3.fromRGB(94,79,79), pink=Color3.fromRGB(255,68,202),
 pinkSoft=Color3.fromRGB(255,133,222), warm=Color3.fromRGB(255,185,124),
 warmWhite=Color3.fromRGB(255,230,207), cyan=Color3.fromRGB(66,210,235),
 green=Color3.fromRGB(62,108,72), glass=Color3.fromRGB(102,93,111),
}

local function part(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide~=false;p.CanTouch=false
 p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or C.dark;p.Transparency=transparency or 0
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or root
 return p
end

local function neon(name,size,cf,color,parent,brightness,range)
 local p=part(name,size,cf,color,Enum.Material.Neon,0,false,parent)
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness or .3;l.Range=range or 6;l.Shadows=false;l.Parent=p
 return p
end

local function light(name,pos,color,brightness,range,parent)
 local a=part(name,Vector3.new(.25,.25,.25),CFrame.new(pos),color,Enum.Material.Neon,1,false,parent)
 local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness;l.Range=range;l.Shadows=false;l.Parent=a
end

local function textSign(name,text,cf,size,color,font,parent)
 local p=part(name,size,cf,C.dark,Enum.Material.Metal,0,false,parent)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.LightInfluence=0;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=38;g.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=color or C.pinkSoft
 t.TextStrokeColor3=Color3.fromRGB(110,22,88);t.TextStrokeTransparency=.5;t.Font=font or Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=g
 return p
end

local function seat(name,cf,size,parent)
 local s=Instance.new("Seat");s.Name=name;s.Size=size;s.CFrame=cf;s.Anchored=true;s.Material=Enum.Material.Fabric
 s.Color=Color3.fromRGB(93,63,79);s.TopSurface=Enum.SurfaceType.Smooth;s.BottomSurface=Enum.SurfaceType.Smooth;s.Parent=parent;return s
end

local function planter(name,pos,parent)
 part(name.." Pot",Vector3.new(8,3,6),CFrame.new(pos),C.dark2,Enum.Material.Slate,0,true,parent)
 part(name.." Soil",Vector3.new(7.2,.3,5.2),CFrame.new(pos+Vector3.new(0,1.65,0)),Color3.fromRGB(64,44,35),Enum.Material.Ground,0,false,parent)
 for i=-1,1 do
  local stem=part(name.." Stem "..i,Vector3.new(.32,3.5,.32),CFrame.new(pos+Vector3.new(i*1.1,3.2,0)),C.green,Enum.Material.SmoothPlastic,0,false,parent)
  part(name.." Leaf "..i,Vector3.new(1.5,.2,4),stem.CFrame*CFrame.new(0,1.5,0)*CFrame.Angles(math.rad(15),0,math.rad(i*10)),C.green,Enum.Material.Grass,0,false,parent)
 end
end

-- 1. CLEAR ARRIVAL AXIS ----------------------------------------------------
local arrival=Instance.new("Folder");arrival.Name="01 Clean Arrival";arrival.Parent=root
part("Arrival Final Floor",Vector3.new(118,1.1,46),CFrame.new(0,2.1,101),C.floor,Enum.Material.Slate,0,true,arrival)
part("Arrival Center Runner",Vector3.new(22,.1,44),CFrame.new(0,2.7,101),Color3.fromRGB(115,89,91),Enum.Material.Marble,0,false,arrival)
neon("Arrival Edge Pink",Vector3.new(.1,.07,43),CFrame.new(-11.1,2.8,101),C.pink,arrival,.12,3)
neon("Arrival Edge Cyan",Vector3.new(.1,.07,43),CFrame.new(11.1,2.8,101),C.cyan,arrival,.1,3)
planter("Arrival Plant L",Vector3.new(-43,4,99),arrival);planter("Arrival Plant R",Vector3.new(43,4,99),arrival)

-- 2. ONE CLEAN BBYA FACADE -------------------------------------------------
local facade=Instance.new("Folder");facade.Name="02 BBYA Neon Facade";facade.Parent=root
-- 54-stud clear opening. No center columns/slabs.
part("Facade Left",Vector3.new(26,28,5),CFrame.new(-41,15.5,79),C.dark,Enum.Material.Slate,0,true,facade)
part("Facade Right",Vector3.new(26,28,5),CFrame.new(41,15.5,79),C.dark,Enum.Material.Slate,0,true,facade)
part("Facade Upper",Vector3.new(108,13,5),CFrame.new(0,29,79),C.dark,Enum.Material.Slate,0,true,facade)
part("Facade Header",Vector3.new(108,2,5),CFrame.new(0,15.2,79),C.dark2,Enum.Material.Metal,0,true,facade)
textSign("BBYA Hero","BBYA",CFrame.new(0,28,76.2),Vector3.new(70,12,.4),C.pinkSoft,Enum.Font.GothamBlack,facade)
textSign("BBYA Social Hub","SOCIAL HUB",CFrame.new(0,19.7,76.1),Vector3.new(40,3,.3),C.pinkSoft,Enum.Font.GothamMedium,facade)

-- Crown: simple readable tubes, centered above logo.
local cy,cz=38,75.8
neon("Crown Base",Vector3.new(15,.38,.38),CFrame.new(0,cy-2.7,cz),C.pink,facade,.45,7)
for i,cfg in ipairs({{-6.5,0,5,22},{-3.2,2.7,5,-25},{0,5.2,5,0},{3.2,2.7,5,25},{6.5,0,5,-22}}) do
 neon("Crown Stroke "..i,Vector3.new(.4,cfg[3],.4),CFrame.new(cfg[1],cy+cfg[2],cz)*CFrame.Angles(0,0,math.rad(cfg[4])),C.pink,facade,.45,7)
end
for _,x in ipairs({-27,27}) do neon("Entrance Edge "..x,Vector3.new(.22,10,.22),CFrame.new(x,9,76),C.pink,facade,.22,4) end

-- 3. WARM LOBBY ------------------------------------------------------------
local lobby=Instance.new("Folder");lobby.Name="03 Warm Lobby";lobby.Parent=root
part("Lobby Final Floor",Vector3.new(94,.8,34),CFrame.new(0,2.3,59),C.floor,Enum.Material.Slate,0,true,lobby)
-- Ceiling intentionally high (Y=26) to avoid mobile camera clipping.
part("Lobby High Ceiling",Vector3.new(96,.7,35),CFrame.new(0,26,59),C.dark,Enum.Material.Metal,0,true,lobby)
part("Lobby Runner",Vector3.new(20,.1,33),CFrame.new(0,2.75,59),Color3.fromRGB(119,89,92),Enum.Material.Marble,0,false,lobby)
neon("Lobby Runner L",Vector3.new(.1,.07,32),CFrame.new(-10.1,2.83,59),C.pink,lobby,.1,3)
neon("Lobby Runner R",Vector3.new(.1,.07,32),CFrame.new(10.1,2.83,59),C.pink,lobby,.1,3)

-- Left bar stays clear of the center 20-stud corridor.
part("Lobby Bar Back",Vector3.new(28,11,1),CFrame.new(-29,8.2,47),C.dark2,Enum.Material.Slate,0,true,lobby)
part("Lobby Bar Counter",Vector3.new(27,3,6),CFrame.new(-29,4.1,53),Color3.fromRGB(75,55,61),Enum.Material.Marble,0,true,lobby)
neon("Lobby Bar Glow",Vector3.new(24,.12,.12),CFrame.new(-29,2.58,50),C.pink,lobby,.15,3.5)
for row=0,2 do
 part("Bar Shelf "..row,Vector3.new(22,.2,1.2),CFrame.new(-29,6.5+row*2.3,47.7),Color3.fromRGB(84,61,64),Enum.Material.WoodPlanks,0,false,lobby)
 for i=-4,4,2 do neon("Bottle "..row.." "..i,Vector3.new(.38,1.1,.38),CFrame.new(-29+i*2.1,7.1+row*2.3,47),i%4==0 and C.pinkSoft or C.warm,lobby,.05,1.6) end
 end
end
textSign("Lobby Lounge Brand","BBYA LOUNGE",CFrame.new(-29,13.3,46.4),Vector3.new(20,2.2,.25),C.pinkSoft,Enum.Font.GothamBold,lobby)

-- Right lounge seating.
seat("Lobby Sofa A",CFrame.new(28,3.5,54),Vector3.new(8,1.4,4.5),lobby)
seat("Lobby Sofa B",CFrame.new(32,3.5,64)*CFrame.Angles(0,math.rad(180),0),Vector3.new(8,1.4,4.5),lobby)
seat("Lobby Sofa C",CFrame.new(20,3.5,65)*CFrame.Angles(0,math.rad(-24),0),Vector3.new(7,1.4,4.2),lobby)
part("Lobby Coffee Table",Vector3.new(6,.8,5),CFrame.new(27,3.2,60),C.glass,Enum.Material.Glass,.15,true,lobby)
planter("Lobby Plant L",Vector3.new(-43,4,66),lobby);planter("Lobby Plant R",Vector3.new(43,4,66),lobby)

-- Warm fill instead of giant neon bulbs.
for _,cfg in ipairs({
 {Vector3.new(-25,18,57),C.warmWhite,.55,23},{Vector3.new(25,18,57),C.warmWhite,.55,23},
 {Vector3.new(0,19,67),C.warm,.35,20},{Vector3.new(-28,13,50),C.pinkSoft,.28,15},
}) do light("Lobby Warm Fill",cfg[1],cfg[2],cfg[3],cfg[4],lobby) end

-- 4. SAFE CLUB THRESHOLD ---------------------------------------------------
-- A clean landing bridges lobby to existing main floor; no decorative beam crosses it.
part("Lobby To Club Landing",Vector3.new(34,.65,15),CFrame.new(0,2.25,39),Color3.fromRGB(80,68,72),Enum.Material.Slate,0,true,root)
textSign("Club Entry Small","MAIN CLUB",CFrame.new(0,11,32.1),Vector3.new(18,2.2,.25),C.warmWhite,Enum.Font.GothamBold,root)

workspace:SetAttribute("BBYAFrontLobby","4.9")
workspace:SetAttribute("BBYAFrontLobbyClean",true)
print("[BBYA] Front Lobby v4.9 loaded AFTER legacy builders — clean facade, high ceiling, clear entrance axis")