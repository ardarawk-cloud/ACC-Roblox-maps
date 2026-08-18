-- BBYA SOCIAL HUB — PREMIUM PHASE 4 v4.4.1
-- Real venue interaction pass: VIP gates, sky lift, photo portal and rooftop party-state visuals.

local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local ROOT_NAME="BBYA Premium Phase 4 v4.4"
local old=workspace:FindFirstChild(ROOT_NAME)
if old then old:Destroy() end
local root=Instance.new("Folder");root.Name=ROOT_NAME;root.Parent=workspace

local remotes=ReplicatedStorage:WaitForChild("BBYA_Remotes",15)
local Feedback=remotes and remotes:FindFirstChild("Feedback")
local C={black=Color3.fromRGB(8,8,14),stone=Color3.fromRGB(40,36,47),pink=Color3.fromRGB(255,45,170),purple=Color3.fromRGB(124,64,226),cyan=Color3.fromRGB(48,228,255),gold=Color3.fromRGB(255,193,79),glass=Color3.fromRGB(70,100,128)}

local function part(name,size,cf,color,material,transparency,collide,parent)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide~=false;p.Material=material or Enum.Material.SmoothPlastic;p.Color=color or C.stone;p.Transparency=transparency or 0;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent or root;return p
end
local function neon(name,size,cf,color,parent,brightness,range)
 local p=part(name,size,cf,color,Enum.Material.Neon,0,false,parent);local l=Instance.new("PointLight");l.Color=color;l.Brightness=brightness or .65;l.Range=range or 9;l.Shadows=false;l.Parent=p;return p
end
local function sign(name,text,cf,size,color,parent)
 local p=part(name,size,cf,C.black,Enum.Material.Metal,0,false,parent);local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.LightInfluence=0;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=30;g.Parent=p;local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=color or C.pink;t.TextStrokeTransparency=.25;t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=g;return p,t
end
local function prompt(parent,action,objectText,hold)
 local p=Instance.new("ProximityPrompt");p.ActionText=action;p.ObjectText=objectText;p.HoldDuration=hold or .25;p.MaxActivationDistance=10;p.RequiresLineOfSight=false;p.Parent=parent;return p
end
local function feedback(player,text)if Feedback then Feedback:FireClient(player,text)end end
local function isVIP(player)return player:GetAttribute("IsVIP")==true or player:GetAttribute("BBYAAllAccess")==true or player:GetAttribute("BBYAQueen")==true end

-- VIP GATES ---------------------------------------------------------------
local vipFolder=Instance.new("Folder");vipFolder.Name="01 VIP Gates";vipFolder.Parent=root
local function makeVIPGate(name,x,accent)
 local f=Instance.new("Folder");f.Name=name;f.Parent=vipFolder;local z=23
 part(name.." Arch L",Vector3.new(2.4,11,3),CFrame.new(x-6,6.5,z),C.stone,Enum.Material.Marble,0,true,f)
 part(name.." Arch R",Vector3.new(2.4,11,3),CFrame.new(x+6,6.5,z),C.stone,Enum.Material.Marble,0,true,f)
 part(name.." Crown",Vector3.new(14,1.8,3),CFrame.new(x,12,z),C.black,Enum.Material.Metal,0,true,f)
 sign(name.." Sign","VIP ACCESS",CFrame.new(x,10.7,z-1.62),Vector3.new(11,2.5,.3),C.gold,f)
 neon(name.." Accent L",Vector3.new(.22,8,.22),CFrame.new(x-4.8,6.5,z-1.55),accent,f,.5,7)
 neon(name.." Accent R",Vector3.new(.22,8,.22),CFrame.new(x+4.8,6.5,z-1.55),accent,f,.5,7)
 local left=part(name.." Door L",Vector3.new(5.5,8,.5),CFrame.new(x-2.75,6,z),C.glass,Enum.Material.Glass,.28,true,f)
 local right=part(name.." Door R",Vector3.new(5.5,8,.5),CFrame.new(x+2.75,6,z),C.glass,Enum.Material.Glass,.28,true,f)
 local lc,lo=left.CFrame,left.CFrame*CFrame.new(-5.4,0,0);local rc,ro=right.CFrame,right.CFrame*CFrame.new(5.4,0,0)
 local pad=part(name.." Access Pad",Vector3.new(2,3,.8),CFrame.new(x+8,4,z-1.2),C.black,Enum.Material.Metal,0,false,f);local pp=prompt(pad,"ENTER","VIP • 10 ROBUX",.2);local busy=false
 local function configured()return workspace:GetAttribute("BBYAMonetizationConfigured")==true end
 local function setOpen(open,instant)
  left.CanCollide=not open and configured();right.CanCollide=not open and configured();local gl=open and lo or lc;local gr=open and ro or rc
  if instant then left.CFrame=gl;right.CFrame=gr else TweenService:Create(left,TweenInfo.new(.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{CFrame=gl}):Play();TweenService:Create(right,TweenInfo.new(.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{CFrame=gr}):Play() end
 end
 local function refresh()if configured()then pp.ObjectText="VIP • 10 ROBUX";setOpen(false,true)else pp.ObjectText="VIP PREVIEW • PASS PENDING";setOpen(true,true)end end
 refresh();workspace:GetAttributeChangedSignal("BBYAMonetizationConfigured"):Connect(refresh)
 pp.Triggered:Connect(function(player)
  if busy then return end;if not configured()then feedback(player,"VIP preview open • Game Pass setup pending");return end;if not isVIP(player)then feedback(player,"VIP access required • use VIP / SAWER panel");return end
  busy=true;setOpen(true,false);feedback(player,"VIP access granted");task.delay(4,function()if f.Parent then setOpen(false,false)end;busy=false end)
 end)
end
makeVIPGate("West VIP Gate",-52,C.cyan);makeVIPGate("East VIP Gate",52,C.pink)

-- SKY LIFT ----------------------------------------------------------------
local lift=Instance.new("Folder");lift.Name="02 Sky Lift";lift.Parent=root
local liftX,liftZ=82,34
part("Sky Lift Shaft Back",Vector3.new(10,40,.8),CFrame.new(liftX,20,liftZ+5),C.black,Enum.Material.Metal,0,true,lift)
part("Sky Lift Shaft L",Vector3.new(.8,40,10),CFrame.new(liftX-5,20,liftZ),C.glass,Enum.Material.Glass,.58,false,lift)
part("Sky Lift Shaft R",Vector3.new(.8,40,10),CFrame.new(liftX+5,20,liftZ),C.glass,Enum.Material.Glass,.58,false,lift)
neon("Sky Lift Line L",Vector3.new(.18,38,.18),CFrame.new(liftX-4.5,20,liftZ-4.5),C.cyan,lift,.35,8)
neon("Sky Lift Line R",Vector3.new(.18,38,.18),CFrame.new(liftX+4.5,20,liftZ-4.5),C.pink,lift,.35,8)
sign("Sky Lift Vertical Sign","SKY\nLIFT",CFrame.new(liftX,22,liftZ+4.5),Vector3.new(7,10,.3),C.gold,lift)

local function liftStation(name,y,targetY,labelText)
 local f=Instance.new("Folder");f.Name=name;f.Parent=lift
 part(name.." Platform",Vector3.new(9,1,9),CFrame.new(liftX,y,liftZ),C.stone,Enum.Material.Marble,0,true,f)
 local doorL=part(name.." Door L",Vector3.new(4.4,8,.5),CFrame.new(liftX-2.25,y+4,liftZ-4.6),C.glass,Enum.Material.Glass,.25,false,f)
 local doorR=part(name.." Door R",Vector3.new(4.4,8,.5),CFrame.new(liftX+2.25,y+4,liftZ-4.6),C.glass,Enum.Material.Glass,.25,false,f)
 local dlClosed,drClosed=doorL.CFrame,doorR.CFrame;local dlOpen=dlClosed*CFrame.new(-4.1,0,0);local drOpen=drClosed*CFrame.new(4.1,0,0)
 local panel=part(name.." Call Panel",Vector3.new(1.5,3,.7),CFrame.new(liftX+6,y+2,liftZ-4.3),C.black,Enum.Material.Metal,0,false,f);neon(name.." Call Glow",Vector3.new(1,.18,.18),panel.CFrame*CFrame.new(0,1.1,-.38),C.gold,f,.25,4)
 local pp=prompt(panel,labelText,"BBYA SKY LIFT",.35);local busy=false
 local function doors(open)
  TweenService:Create(doorL,TweenInfo.new(.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{CFrame=open and dlOpen or dlClosed}):Play();TweenService:Create(doorR,TweenInfo.new(.28,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{CFrame=open and drOpen or drClosed}):Play()
 end
 pp.Triggered:Connect(function(player)
  if busy or not player.Character then return end;busy=true;doors(true);feedback(player,"Sky Lift boarding...");task.wait(.45);doors(false);task.wait(.42)
  if player.Character then player.Character:PivotTo(CFrame.new(liftX,targetY+3,liftZ)) end
  feedback(player,labelText=="ROOFTOP" and "Welcome to BBYA Rooftop" or "Welcome back to Main Club");task.wait(.2);busy=false
 end)
end
liftStation("Main Club Lift",2.2,38.2,"ROOFTOP");liftStation("Rooftop Lift",38.2,2.2,"MAIN CLUB")

-- PHOTO PORTAL ------------------------------------------------------------
local photo=Instance.new("Folder");photo.Name="03 Photo Portal";photo.Parent=root
local px,pz=58,18
part("Photo Portal Floor",Vector3.new(32,.5,18),CFrame.new(px,1.7,pz),C.black,Enum.Material.Marble,0,true,photo)
for _,x in ipairs({px-15,px+15})do part("Photo Portal Column "..x,Vector3.new(2,12,2),CFrame.new(x,7,pz),C.stone,Enum.Material.Marble,0,true,photo);neon("Photo Portal Line "..x,Vector3.new(.22,10,.22),CFrame.new(x,7,pz-1.1),x<px and C.cyan or C.pink,photo,.6,8)end
part("Photo Portal Crown",Vector3.new(32,1.5,2),CFrame.new(px,13,pz),C.black,Enum.Material.Metal,0,true,photo);sign("Photo Portal Sign","BBYA PHOTO PORTAL",CFrame.new(px,11.4,pz-1.15),Vector3.new(25,3,.3),C.pink,photo)
local poses={{-9,"wave","WAVE"},{0,"dance","VIBE"},{9,"cheer","HYPE"}}
for _,cfg in ipairs(poses)do
 local pad=part("Pose Pad "..cfg[3],Vector3.new(6,.35,6),CFrame.new(px+cfg[1],2.1,pz-4),Color3.fromRGB(28,20,38),Enum.Material.Glass,.08,true,photo);neon("Pose Ring "..cfg[3],Vector3.new(5,.12,.18),pad.CFrame*CFrame.new(0,.25,-2.8),cfg[1]<0 and C.cyan or(cfg[1]>0 and C.gold or C.pink),photo,.3,5)
 local pp=prompt(pad,"POSE",cfg[3],.1);pp.Triggered:Connect(function(player)local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if h then pcall(function()h:PlayEmote(cfg[2])end);feedback(player,"Photo pose • "..cfg[3])end end)
end

-- ROOFTOP EVENT STATE -----------------------------------------------------
local event=Instance.new("Folder");event.Name="04 Rooftop Event State";event.Parent=root
local strips={};for i=-4,4 do local s=neon("Rooftop Event Strip "..i,Vector3.new(8,.18,.22),CFrame.new(i*9,49.2,17),i%2==0 and C.pink or C.cyan,event,.35,7);table.insert(strips,s)end
local _,eventText=sign("Rooftop Live State","BBYA • NIGHT MODE",CFrame.new(0,45,16.8),Vector3.new(28,3,.3),C.gold,event)
local function refreshParty()
 local party=workspace:GetAttribute("BBYAPartyMode")==true;eventText.Text=party and "BBYA • PARTY MODE" or "BBYA • NIGHT MODE";eventText.TextColor3=party and C.pink or C.gold
 for i,s in ipairs(strips)do local color=party and(i%3==0 and C.gold or(i%2==0 and C.pink or C.cyan))or(i%2==0 and C.purple or C.cyan);TweenService:Create(s,TweenInfo.new(.45),{Color=color}):Play();local l=s:FindFirstChildOfClass("PointLight");if l then l.Color=color;l.Brightness=party and .8 or .35 end end
 workspace:SetAttribute("BBYARooftopEventState",party and "PARTY" or "NIGHT")
end
refreshParty();workspace:GetAttributeChangedSignal("BBYAPartyMode"):Connect(refreshParty)
workspace:SetAttribute("BBYAPremiumPhase4","4.4.1")
print("[BBYA] Premium Phase 4 v4.4.1 loaded")
