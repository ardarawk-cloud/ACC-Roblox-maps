-- BBYA Social Hub v1.4.1 clean feature-station layout
local Players=game:GetService("Players")
local Debris=game:GetService("Debris")

local old=workspace:FindFirstChild("BBYA Feature Stations")
if old then old:Destroy() end
local root=Instance.new("Folder");root.Name="BBYA Feature Stations";root.Parent=workspace

local function part(name,size,cf,color,material,transparency)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0;p.Parent=root;return p
end
local function prompt(p,action,obj)
 local x=Instance.new("ProximityPrompt");x.ActionText=action;x.ObjectText=obj;x.HoldDuration=.15;x.MaxActivationDistance=10;x.RequiresLineOfSight=false;x.Parent=p;return x
end
local function label(p,msg,color)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=24;g.Parent=p
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Text=msg;t.TextColor3=color or Color3.new(1,1,1);t.Font=Enum.Font.GothamBlack;t.TextScaled=true;t.TextWrapped=true;t.Parent=g
 local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=10;limit.MaxTextSize=28;limit.Parent=t
 return t
end
local function weldAdornment(char,name,shape,size,offset,color)
 local head=char and char:FindFirstChild("Head");if not head then return end
 local prior=char:FindFirstChild(name);if prior then prior:Destroy() end
 local a=Instance.new("Part");a.Name=name;a.Shape=shape or Enum.PartType.Block;a.Size=size;a.Color=color;a.Material=Enum.Material.Neon;a.CanCollide=false;a.Massless=true;a.CFrame=head.CFrame*offset;a.Parent=char
 local w=Instance.new("WeldConstraint");w.Part0=head;w.Part1=a;w.Parent=a
end

-- SALON KIT: moved to dedicated right-side bay, away from stairs/VIP lounge.
local salon=part("BBYA Salon Counter",Vector3.new(15,3.5,5),CFrame.new(69,2.75,18),Color3.fromRGB(34,20,48),Enum.Material.Marble)
local salonSign=part("BBYA Salon Sign",Vector3.new(13,2,.35),CFrame.new(69,5.8,15.4),Color3.fromRGB(20,8,30),Enum.Material.SmoothPlastic)
label(salonSign,"BBYA SALON",Color3.fromRGB(255,100,220))
local looks={
 {"NEON HALO",function(c)weldAdornment(c,"BBYA Salon Look",Enum.PartType.Cylinder,Vector3.new(.35,4.2,4.2),CFrame.new(0,1.9,0)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(255,70,210))end},
 {"CYAN CROWN",function(c)weldAdornment(c,"BBYA Salon Look",Enum.PartType.Block,Vector3.new(2.8,.45,2.8),CFrame.new(0,1.55,0),Color3.fromRGB(55,210,255))end},
 {"GOLD ICON",function(c)weldAdornment(c,"BBYA Salon Look",Enum.PartType.Ball,Vector3.new(.65,.65,.65),CFrame.new(0,1.75,0),Color3.fromRGB(255,205,80))end},
}
local styleIndex={}
prompt(salon,"STYLE ME","Salon Kit").Triggered:Connect(function(plr)
 local c=plr.Character;if not c then return end
 local i=(styleIndex[plr.UserId]or 0)%#looks+1;styleIndex[plr.UserId]=i;looks[i][2](c);plr:SetAttribute("BBYASalonLook",looks[i][1])
end)
local resetPad=part("Salon Reset",Vector3.new(4,.3,4),CFrame.new(78,1,18),Color3.fromRGB(90,45,110),Enum.Material.Neon,.2)
prompt(resetPad,"RESET","Salon Look").Triggered:Connect(function(plr)local c=plr.Character;local a=c and c:FindFirstChild("BBYA Salon Look");if a then a:Destroy()end;plr:SetAttribute("BBYASalonLook","")end)

-- SUPPORT WALL: moved to left perimeter so stair circulation stays open.
local donateWall=part("Donate Text Wall",Vector3.new(18,8,.7),CFrame.new(-74,5,32)*CFrame.Angles(0,math.rad(-90),0),Color3.fromRGB(18,12,26),Enum.Material.SmoothPlastic)
local donateText=label(donateWall,"BBYA SUPPORT\nWaiting for supporters...",Color3.fromRGB(255,215,90))
local lastTotals={}
local function updateDonateWall(plr)
 local now=plr:GetAttribute("TotalDonated")or 0;local before=lastTotals[plr.UserId]or now
 if now>before then donateText.Text=string.format("THANK YOU %s!\n+R$%d • TOTAL R$%d",plr.DisplayName,now-before,now) end
 lastTotals[plr.UserId]=now
end
local function hookPlayer(plr)
 lastTotals[plr.UserId]=plr:GetAttribute("TotalDonated")or 0
 plr:GetAttributeChangedSignal("TotalDonated"):Connect(function()updateDonateWall(plr)end)
end
Players.PlayerAdded:Connect(hookPlayer);for _,p in ipairs(Players:GetPlayers())do hookPlayer(p)end

-- DUO PHOTO: separate right-rear photo bay.
local duoWall=part("Duo Photo Wall",Vector3.new(15,8,.7),CFrame.new(69,5,-31),Color3.fromRGB(45,14,55),Enum.Material.SmoothPlastic)
label(duoWall,"DUO PHOTO ♥",Color3.fromRGB(255,100,220))
for _,x in ipairs({-3,3})do
 local s=Instance.new("Seat");s.Name="Duo Photo Seat";s.Size=Vector3.new(2.6,1,2.6);s.CFrame=CFrame.new(69+x,1.7,-36)*CFrame.Angles(0,math.pi,0);s.Anchored=true;s.Color=Color3.fromRGB(80,45,95);s.Material=Enum.Material.Fabric;s.Parent=root
end

-- POOL SPLASH interaction remains on rooftop.
local pool=workspace:FindFirstChild("Rooftop Pool")
if pool then
 local splashPad=part("Pool Splash Pad",Vector3.new(6,.3,6),pool.CFrame*CFrame.new(0,pool.Size.Y/2+.4,0),Color3.fromRGB(50,190,255),Enum.Material.Glass,.55)
 local splashPrompt=prompt(splashPad,"SPLASH","Pool Party")
 splashPrompt.Triggered:Connect(function()
  splashPrompt.Enabled=false
  for i=1,20 do local d=Instance.new("Part");d.Shape=Enum.PartType.Ball;d.Size=Vector3.new(.35,.35,.35);d.Material=Enum.Material.Neon;d.Color=Color3.fromRGB(80,210,255);d.CanCollide=false;d.CFrame=splashPad.CFrame*CFrame.new(math.random(-3,3),2,math.random(-3,3));d.Parent=workspace;d.AssemblyLinearVelocity=Vector3.new(math.random(-9,9),math.random(10,20),math.random(-9,9));Debris:AddItem(d,2) end
  task.delay(2,function()if splashPrompt.Parent then splashPrompt.Enabled=true end end)
 end)
end

print("[BBYA] v1.4.1 clean layout loaded: salon/support/photo separated; stair and VIP paths clear")