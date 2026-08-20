-- BBYA SOCIAL HUB — FLOOR 1 FEATURE PASS v1
-- Functional interactions for Main Club, Editorial Photo Room and Look Lab.

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
runtime:SetAttribute("Pass","FEATURE_V1")
runtime.Parent=root

local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes") or Instance.new("Folder")
remotes.Name="BBYAClubRemotes";remotes.Parent=ReplicatedStorage
local feature=remotes:FindFirstChild("Feature") or Instance.new("RemoteEvent")
feature.Name="Feature";feature.Parent=remotes
local state=remotes:FindFirstChild("State")
local internalMusic=remotes:FindFirstChild("InternalMusic")

local PLAYLIST={"Pumpin' And Bumpin' D","DJ Party Time","Electronic Music","Electronic Avenue","DJ","Welcome","Store"}
local cooldown={}
local activeBottle={}
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

-- PHOTO MODE ------------------------------------------------------------------
local photoAnchor=anchor("PhotoModeInteract",Vector3.new(-36,2.7,-25))
local photoPrompt=prompt(photoAnchor,"Start Photo Mode","BBYA Editorial",10,.25)
photoPrompt.Triggered:Connect(function(plr)
 if not allow(plr,"photo",8) or not closeEnough(plr,photoAnchor.Position,15) then return end
 local _,hum,hrp=character(plr);if not hrp then return end
 hrp.CFrame=CFrame.lookAt(Vector3.new(-44.2,2.7,-25),Vector3.new(-33.0,3.2,-25))
 if hum then hum.WalkSpeed=0;hum.JumpPower=0;task.delay(6,function()if hum.Parent then hum.WalkSpeed=16;hum.JumpPower=50 end end) end
 feature:FireClient(plr,"photoMode",{
  camera=CFrame.lookAt(Vector3.new(-32.6,4.6,-25),Vector3.new(-44.1,3.0,-25)),
  duration=6,
  label="BBYA EDITORIAL"
 })
end)

-- LOOK LAB --------------------------------------------------------------------
local lookChairs={Vector3.new(-42.0,2.0,-10),Vector3.new(-42.0,2.0,-3),Vector3.new(-42.0,2.0,4)}
for i,pos in ipairs(lookChairs) do
 local a=anchor("LookChairInteract"..i,pos+Vector3.new(2.0,1.2,0))
 local p=prompt(a,"Start Styling","Look Lab Chair "..i,8,.2)
 p.Triggered:Connect(function(plr)
  if not allow(plr,"look",4) or not closeEnough(plr,a.Position,12) then return end
  local _,hum,hrp=character(plr);if not hrp then return end
  hrp.CFrame=CFrame.lookAt(pos+Vector3.new(0,.8,0),Vector3.new(-49,3,pos.Z))
  if hum then hum.WalkSpeed=0;task.delay(8,function()if hum.Parent then hum.WalkSpeed=16 end end) end
  feature:FireClient(plr,"lookSession",{chair=i})
 end)
end

-- DANCE FLOOR -----------------------------------------------------------------
local danceAnchor=anchor("DanceInteract",Vector3.new(3,2.3,6))
local dancePrompt=prompt(danceAnchor,"Hit The Floor","Main Dance Floor",11,.1)
dancePrompt.Triggered:Connect(function(plr)
 if not allow(plr,"dance",3) or not closeEnough(plr,danceAnchor.Position,16) then return end
 feature:FireClient(plr,"dance",{emotes={"dance","dance2","dance3"}})
end)

-- DJ REQUEST ------------------------------------------------------------------
local djAnchor=anchor("DJRequestInteract",Vector3.new(3,5.5,28.6))
local djPrompt=prompt(djAnchor,"Request Track","DJ Booth",10,.2)
djPrompt.Triggered:Connect(function(plr)
 if not allow(plr,"djmenu",2) or not closeEnough(plr,djAnchor.Position,15) then return end
 feature:FireClient(plr,"djMenu",{playlist=PLAYLIST})
end)

-- VIP SEATING + BOTTLE SERVICE ------------------------------------------------
local vipZ={0,14,28}
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
 local servicePrompt=prompt(serviceAnchor,"Bottle Service","VIP Bay "..bay,8,.35)
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
  toast(plr,"Bottle service aktif untuk 45 detik.")
  Debris:AddItem(m,45);task.delay(46,function()if activeBottle[bay]==m then activeBottle[bay]=nil end end)
 end)
end

-- BAR SIGNATURE DRINK ----------------------------------------------------------
local barAnchor=anchor("BarOrderInteract",Vector3.new(29.5,3.2,11))
local barPrompt=prompt(barAnchor,"Order Signature","Main Bar",9,.25)
barPrompt.Triggered:Connect(function(plr)
 if not allow(plr,"drink",18) or not closeEnough(plr,barAnchor.Position,12) then return end
 local backpack=plr:FindFirstChildOfClass("Backpack");if not backpack then return end
 if backpack:FindFirstChild("BBYA Signature") or (plr.Character and plr.Character:FindFirstChild("BBYA Signature")) then toast(plr,"Kamu masih pegang BBYA Signature.");return end
 local tool=Instance.new("Tool");tool.Name="BBYA Signature";tool.RequiresHandle=true;tool.CanBeDropped=false
 local h=Instance.new("Part");h.Name="Handle";h.Size=Vector3.new(.55,1.05,.55);h.Shape=Enum.PartType.Cylinder;h.Material=Enum.Material.Glass;h.Color=C.cyan;h.Transparency=.18;h.CanCollide=false;h.Parent=tool
 local glow=Instance.new("PointLight");glow.Color=C.cyan;glow.Brightness=.25;glow.Range=5;glow.Parent=h
 tool.Parent=backpack;toast(plr,"BBYA Signature siap. Roleplay prop sudah masuk inventory.")
 Debris:AddItem(tool,120)
end)

feature.OnServerEvent:Connect(function(plr,action,arg)
 if action=="djRequest" then
  local idx=tonumber(arg);if not idx or not PLAYLIST[idx] then return end
  if internalMusic then internalMusic:Fire("request",plr,idx) else toast(plr,"DJ request system sedang reconnect.") end
 elseif action=="lookMood" then
  local mood=tostring(arg or "");local colors={Night=C.pink,Editorial=C.warm,Clean=C.cyan};local col=colors[mood];if not col then return end
  if not allow(plr,"lookmood",2) then return end
  local ch=plr.Character;if not ch then return end
  local oldH=ch:FindFirstChild("BBYALookHighlight");if oldH then oldH:Destroy() end
  local h=Instance.new("Highlight");h.Name="BBYALookHighlight";h.FillColor=col;h.FillTransparency=.78;h.OutlineColor=col;h.OutlineTransparency=.15;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=ch
  plr:SetAttribute("BBYALookMood",mood);toast(plr,"Look mood aktif: "..mood)
  Debris:AddItem(h,18)
 elseif action=="photoPose" then
  local pose=tostring(arg or "wave");feature:FireClient(plr,"playEmote",pose)
 end
end)

Players.PlayerRemoving:Connect(function(plr)
 local prefix=tostring(plr.UserId)..":";for k in pairs(cooldown) do if string.sub(k,1,#prefix)==prefix then cooldown[k]=nil end end
end)

print("[BBYA] Floor 1 feature pass online: photo, look lab, dance, DJ requests, VIP service and bar")