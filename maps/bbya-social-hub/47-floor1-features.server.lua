-- BBYA SOCIAL HUB — FLOOR 1 FEATURE PASS v2
-- Functional social interactions for Main Club, Editorial Photo Room and Look Lab.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local Debris=game:GetService("Debris")

local root=Workspace:WaitForChild("BBYA_ZERO_BUILD",20)
if not root then return end
local club=root:WaitForChild("MainClubRealism",20)
local front=root:WaitForChild("Floor1FrontPremium",20)
if not club or not front then warn("[BBYA Features] Floor 1 build unavailable");return end

local old=root:FindFirstChild("Floor1Features")
if old then old:Destroy() end
local runtime=Instance.new("Model")
runtime.Name="Floor1Features"
runtime:SetAttribute("Pass","FEATURE_V2")
runtime.Parent=root

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local feature=remotes:FindFirstChild("Feature") or Instance.new("RemoteEvent")
feature.Name="Feature";feature.Parent=remotes
local state=remotes:FindFirstChild("State")
local internalMusic=remotes:FindFirstChild("InternalMusic")

local PLAYLIST={"Pumpin' And Bumpin' D","DJ Party Time","Electronic Music","Electronic Avenue","DJ","Welcome","Store"}
local PHOTO_ANGLES={
 Classic=CFrame.lookAt(Vector3.new(-32.6,4.6,-25),Vector3.new(-44.1,3.0,-25)),
 Low=CFrame.lookAt(Vector3.new(-34.0,2.9,-20.7),Vector3.new(-44.0,3.1,-25)),
 Editorial=CFrame.lookAt(Vector3.new(-38.2,5.7,-16.7),Vector3.new(-44.0,3.2,-25)),
}
local LOOK_COLORS={
 Night=Color3.fromRGB(244,48,149),Editorial=Color3.fromRGB(255,205,158),Clean=Color3.fromRGB(31,184,207),
 Gold=Color3.fromRGB(211,165,97),Mono=Color3.fromRGB(218,216,221),
}
local DRINKS={
 ["Pink Tonic"]={color=Color3.fromRGB(244,68,153),light=Color3.fromRGB(255,91,177)},
 ["Blue Fizz"]={color=Color3.fromRGB(44,173,209),light=Color3.fromRGB(63,202,235)},
 ["Gold Zero"]={color=Color3.fromRGB(196,154,83),light=Color3.fromRGB(255,205,138)},
}
local cooldown={}
local activeBottle={}
local vipMoodIndex={}
local C={black=Color3.fromRGB(10,10,13),metal=Color3.fromRGB(52,50,57),brass=Color3.fromRGB(183,137,83),glass=Color3.fromRGB(90,102,112),pink=Color3.fromRGB(244,48,149),cyan=Color3.fromRGB(31,184,207),warm=Color3.fromRGB(255,205,158),plum=Color3.fromRGB(75,48,68),white=Color3.fromRGB(238,235,239)}

local function toast(plr,msg)
 if state then state:FireClient(plr,"toast",msg) else feature:FireClient(plr,"toast",msg) end
end
local function anchor(name,pos,parent)
 local p=Instance.new("Part");p.Name=name;p.Size=Vector3.new(1,1,1);p.CFrame=CFrame.new(pos);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Transparency=1;p.Parent=parent or runtime;return p
end
local function prompt(parent,action,obj,dist,hold)
 local p=Instance.new("ProximityPrompt");p.ActionText=action;p.ObjectText=obj;p.KeyboardKeyCode=Enum.KeyCode.E;p.GamepadKeyCode=Enum.KeyCode.ButtonX;p.MaxActivationDistance=dist or 9;p.HoldDuration=hold or .15;p.RequiresLineOfSight=false;p.Style=Enum.ProximityPromptStyle.Default;p.Parent=parent;return p
end
local function part(name,size,cf,color,material,transparency,parent,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or C.metal;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or runtime;return p
end
local function cylinder(name,size,cf,color,material,transparency,parent,collide)
 local p=part(name,size,cf,color,material,transparency,parent,collide);p.Shape=Enum.PartType.Cylinder;return p
end
local function character(plr)
 local ch=plr.Character;if not ch then return end
 return ch,ch:FindFirstChildOfClass("Humanoid"),ch:FindFirstChild("HumanoidRootPart")
end
local function closeEnough(plr,pos,maxDist)
 local _,_,hrp=character(plr);return hrp and (hrp.Position-pos).Magnitude<=(maxDist or 18)
end
local function allow(plr,key,seconds)
 local id=tostring(plr.UserId)..":"..key;local now=os.clock();local last=cooldown[id] or 0
 if now-last<(seconds or 2) then return false end
 cooldown[id]=now;return true
end
local function freezeFor(plr,seconds)
 local _,hum=character(plr);if not hum then return end
 local walk=hum.WalkSpeed;local jump=hum.JumpPower
 hum.WalkSpeed=0;hum.JumpPower=0
 task.delay(seconds,function()if hum.Parent then hum.WalkSpeed=walk;hum.JumpPower=jump end end)
end

-- PHOTO MODE ------------------------------------------------------------------
local photoAnchor=anchor("PhotoModeInteract",Vector3.new(-36,2.7,-25))
local photoPrompt=prompt(photoAnchor,"Open Photo Studio","BBYA Editorial",10,.22)
photoPrompt.Triggered:Connect(function(plr)
 if not closeEnough(plr,photoAnchor.Position,15) then return end
 feature:FireClient(plr,"photoMenu",{angles={"Classic","Low","Editorial"}})
end)
local prepAnchor=anchor("PhotoPrepInteract",Vector3.new(-39.0,3.1,-16.8))
local prepPrompt=prompt(prepAnchor,"Prep The Look","Photo Prep Console",8,.18)
prepPrompt.Triggered:Connect(function(plr)
 if closeEnough(plr,prepAnchor.Position,11) then feature:FireClient(plr,"lookSession",{source="photo"}) end
end)

-- LOOK LAB --------------------------------------------------------------------
local lookChairs={Vector3.new(-42.0,2.0,-10),Vector3.new(-42.0,2.0,-3),Vector3.new(-42.0,2.0,4)}
for i,pos in ipairs(lookChairs) do
 local a=anchor("LookChairInteract"..i,pos+Vector3.new(2.0,1.2,0))
 local p=prompt(a,"Start Styling","Look Lab Chair "..i,8,.2)
 p.Triggered:Connect(function(plr)
  if not allow(plr,"look",2) or not closeEnough(plr,a.Position,12) then return end
  local _,_,hrp=character(plr);if not hrp then return end
  hrp.CFrame=CFrame.lookAt(pos+Vector3.new(0,.8,0),Vector3.new(-49,3,pos.Z))
  freezeFor(plr,10)
  feature:FireClient(plr,"lookSession",{chair=i,source="chair"})
 end)
end
local washAnchor=anchor("LookWashInteract",Vector3.new(-31.5,3.1,4.0))
local washPrompt=prompt(washAnchor,"Refresh Style","Look Lab Wash Station",8,.25)
washPrompt.Triggered:Connect(function(plr)
 if not allow(plr,"wash",12) or not closeEnough(plr,washAnchor.Position,11) then return end
 local ch=plr.Character;if not ch then return end
 local h=Instance.new("Highlight");h.Name="BBYARefreshGlow";h.FillColor=C.cyan;h.FillTransparency=.82;h.OutlineColor=C.warm;h.OutlineTransparency=.25;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=ch
 Debris:AddItem(h,4);feature:FireClient(plr,"washFx",{});toast(plr,"Look refreshed — siap balik ke floor.")
end)

-- DANCE FLOOR -----------------------------------------------------------------
for i,pos in ipairs({Vector3.new(-9,2.3,6),Vector3.new(3,2.3,6),Vector3.new(15,2.3,6)}) do
 local a=anchor("DanceInteract"..i,pos)
 local p=prompt(a,"Dance","Main Floor Spot "..i,9,.08)
 p.Triggered:Connect(function(plr)
  if not allow(plr,"dance"..i,2.5) or not closeEnough(plr,a.Position,13) then return end
  feature:FireClient(plr,"dance",{emotes=i==1 and {"dance","dance2"} or (i==2 and {"dance2","dance3"} or {"dance","dance3"})})
 end)
end

-- DJ REQUEST ------------------------------------------------------------------
local djAnchor=anchor("DJRequestInteract",Vector3.new(3,5.5,28.6))
local djPrompt=prompt(djAnchor,"Request Track","DJ Booth",10,.2)
djPrompt.Triggered:Connect(function(plr)
 if not allow(plr,"djmenu",1.5) or not closeEnough(plr,djAnchor.Position,15) then return end
 feature:FireClient(plr,"djMenu",{playlist=PLAYLIST})
 if internalMusic then internalMusic:Fire("queue",plr) end
end)

-- VIP SEATING + BOTTLE SERVICE + AMBIENCE ------------------------------------
local vipZ={0,14,28}
local moodColors={C.warm,C.pink,C.cyan}
local moodNames={"Warm","Rose","Ice"}
for bay,z in ipairs(vipZ) do
 local seatModel=Instance.new("Model");seatModel.Name="VIPSeatRuntime"..bay;seatModel.Parent=runtime
 for s=1,3 do
  local zz=z-2.25+(s-1)*2.25
  local seat=Instance.new("Seat");seat.Name="VIPSeat"..bay.."_"..s;seat.Size=Vector3.new(2.2,.45,1.8);seat.CFrame=CFrame.new(-44.1,2.05,zz)*CFrame.Angles(0,math.rad(-90),0);seat.Transparency=1;seat.Anchored=true;seat.CanCollide=false;seat.Parent=seatModel
  local a=anchor("VIPSit"..bay.."_"..s,Vector3.new(-41.8,2.8,zz),seatModel)
  local p=prompt(a,"Sit","VIP Banquette",7,.12)
  p.Triggered:Connect(function(plr)
   if not closeEnough(plr,a.Position,10) then return end
   local _,hum=character(plr);if hum then seat:Sit(hum) end
  end)
 end
 local serviceAnchor=anchor("BottleService"..bay,Vector3.new(-37.4,2.5,z),seatModel)
 local servicePrompt=prompt(serviceAnchor,"Bottle Service","VIP Bay "..bay,8,.30)
 servicePrompt.Triggered:Connect(function(plr)
  if not allow(plr,"bottle"..bay,20) or not closeEnough(plr,serviceAnchor.Position,11) then return end
  if activeBottle[bay] and activeBottle[bay].Parent then toast(plr,"Bottle service sudah aktif di bay ini.");return end
  local m=Instance.new("Model");m.Name="BottleServiceSet"..bay;m.Parent=runtime;activeBottle[bay]=m
  cylinder("IceBucket",Vector3.new(1.4,2.2,2.2),CFrame.new(-37.4,2.35,z)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,0,m,false)
  cylinder("Bottle",Vector3.new(1.8,.5,.5),CFrame.new(-37.4,3.25,z)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(173,137,67),Enum.Material.Glass,.05,m,false)
  for g=1,4 do
   local ang=(g-1)*math.pi/2
   cylinder("Glass"..g,Vector3.new(.45,.42,.42),CFrame.new(-37.4+math.cos(ang)*1.25,3.0,z+math.sin(ang)*1.25)*CFrame.Angles(0,0,math.rad(90)),C.glass,Enum.Material.Glass,.25,m,false)
  end
  local glow=part("ServiceGlow",Vector3.new(.08,.08,2.4),CFrame.new(-37.4,2.08,z),C.warm,Enum.Material.Neon,.15,m,false)
  local light=Instance.new("PointLight");light.Color=C.warm;light.Brightness=.45;light.Range=8;light.Parent=glow
  toast(plr,"Bottle service aktif untuk 60 detik.")
  Debris:AddItem(m,60);task.delay(61,function()if activeBottle[bay]==m then activeBottle[bay]=nil end end)
 end)
 local moodAnchor=anchor("VIPMood"..bay,Vector3.new(-46.2,3.8,z),seatModel)
 local moodPrompt=prompt(moodAnchor,"Change Ambience","VIP Bay "..bay,7,.12)
 local moodLight=Instance.new("PointLight");moodLight.Name="VIPMoodLight";moodLight.Color=C.warm;moodLight.Brightness=.38;moodLight.Range=14;moodLight.Shadows=false;moodLight.Parent=moodAnchor
 moodPrompt.Triggered:Connect(function(plr)
  if not allow(plr,"vipmood"..bay,2) or not closeEnough(plr,moodAnchor.Position,10) then return end
  vipMoodIndex[bay]=((vipMoodIndex[bay] or 1)%#moodColors)+1
  moodLight.Color=moodColors[vipMoodIndex[bay]]
  toast(plr,"VIP ambience: "..moodNames[vipMoodIndex[bay]])
 end)
end

-- BAR MENU ---------------------------------------------------------------------
local barAnchor=anchor("BarOrderInteract",Vector3.new(29.5,3.2,11))
local barPrompt=prompt(barAnchor,"Open Drink Menu","Main Bar",9,.20)
barPrompt.Triggered:Connect(function(plr)
 if closeEnough(plr,barAnchor.Position,12) then feature:FireClient(plr,"barMenu",{items={"Pink Tonic","Blue Fizz","Gold Zero"}}) end
end)
local function giveDrink(plr,name)
 local spec=DRINKS[name];if not spec then return end
 if not allow(plr,"drink",10) then toast(plr,"Bar sedang menyiapkan pesananmu.");return end
 local backpack=plr:FindFirstChildOfClass("Backpack");if not backpack then return end
 for _,container in ipairs({backpack,plr.Character}) do if container and container:FindFirstChild(name) then toast(plr,"Kamu masih pegang "..name..".");return end end
 local tool=Instance.new("Tool");tool.Name=name;tool.RequiresHandle=true;tool.CanBeDropped=false
 local h=Instance.new("Part");h.Name="Handle";h.Size=Vector3.new(.55,1.05,.55);h.Shape=Enum.PartType.Cylinder;h.Material=Enum.Material.Glass;h.Color=spec.color;h.Transparency=.16;h.CanCollide=false;h.Parent=tool
 local glow=Instance.new("PointLight");glow.Color=spec.light;glow.Brightness=.20;glow.Range=4;glow.Parent=h
 tool.Parent=backpack;toast(plr,name.." siap di inventory.");Debris:AddItem(tool,120)
end

feature.OnServerEvent:Connect(function(plr,action,arg)
 if action=="photoStart" then
  local angle=tostring(arg or "Classic");local camera=PHOTO_ANGLES[angle]
  if not camera or not allow(plr,"photo",7) or not closeEnough(plr,photoAnchor.Position,18) then return end
  local _,_,hrp=character(plr);if not hrp then return end
  hrp.CFrame=CFrame.lookAt(Vector3.new(-44.2,2.7,-25),Vector3.new(-33.0,3.2,-25));freezeFor(plr,7)
  feature:FireClient(plr,"photoMode",{camera=camera,duration=7,label="BBYA EDITORIAL · "..string.upper(angle)})
 elseif action=="djRequest" then
  local idx=tonumber(arg);if not idx or not PLAYLIST[idx] then return end
  if internalMusic then internalMusic:Fire("request",plr,idx) else toast(plr,"DJ request system sedang reconnect.") end
 elseif action=="lookMood" then
  local mood=tostring(arg or "");local col=LOOK_COLORS[mood];if not col then return end
  if not allow(plr,"lookmood",1.5) then return end
  local ch=plr.Character;if not ch then return end
  local oldH=ch:FindFirstChild("BBYALookHighlight");if oldH then oldH:Destroy() end
  local h=Instance.new("Highlight");h.Name="BBYALookHighlight";h.FillColor=col;h.FillTransparency=.80;h.OutlineColor=col;h.OutlineTransparency=.12;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=ch
  plr:SetAttribute("BBYALookMood",mood);toast(plr,"Look mood aktif: "..mood);Debris:AddItem(h,22)
 elseif action=="photoPose" then
  local pose=tostring(arg or "wave");feature:FireClient(plr,"playEmote",pose)
 elseif action=="barOrder" then
  giveDrink(plr,tostring(arg or ""))
 end
end)

Players.PlayerRemoving:Connect(function(plr)
 local prefix=tostring(plr.UserId)..":";for k in pairs(cooldown) do if string.sub(k,1,#prefix)==prefix then cooldown[k]=nil end end
end)

print("[BBYA] Floor 1 feature v2 online: multi-angle photo, full Look Lab, dance zones, DJ queue, VIP ambience and bar menu")