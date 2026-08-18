-- BBYA Social Hub runtime v1.0.1 collision hotfix
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")
local BBYA_QUEEN_USER_ID=4271188557
local COLORS={Color3.fromRGB(255,55,170),Color3.fromRGB(155,70,255),Color3.fromRGB(45,190,255),Color3.fromRGB(255,90,220)}
local function part(par,n,s,cf,c,m,tr,col)local p=Instance.new("Part");p.Name=n;p.Size=s;p.CFrame=cf;p.Anchored=true;p.CanCollide=col~=false;p.Color=c;p.Material=m or Enum.Material.SmoothPlastic;p.Transparency=tr or 0;p.Parent=par;return p end
local function text(p,s,color)local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=35;g.LightInfluence=.05;g.Parent=p;local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Font=Enum.Font.GothamBlack;t.Text=s;t.TextColor3=color or Color3.fromRGB(255,90,210);t.TextStrokeTransparency=.25;t.TextScaled=true;t.Parent=g end
local function sofa(f,n,cf,c)part(f,n.." Seat",Vector3.new(14,2,5),cf,c,Enum.Material.Fabric);part(f,n.." Back",Vector3.new(14,4.5,1.2),cf*CFrame.new(0,2,2),c,Enum.Material.Fabric);part(f,n.." L",Vector3.new(1.2,3.2,5),cf*CFrame.new(-6.5,.8,0),c,Enum.Material.Fabric);part(f,n.." R",Vector3.new(1.2,3.2,5),cf*CFrame.new(6.5,.8,0),c,Enum.Material.Fabric)end
local function findPlayer(q)if not q or q==""then return nil end;q=string.lower(q);for _,p in ipairs(Players:GetPlayers())do if string.sub(string.lower(p.Name),1,#q)==q or string.sub(string.lower(p.DisplayName),1,#q)==q then return p end end end
local function build()
 for _,n in ipairs({"BBYA Visual v0.6","BBYA Visual v0.7","BBYA Visual v0.8","BBYA Visual v0.9","BBYA Visual v0.9.1","BBYA Visual v1.0","BBYA Visual v1.0.1"})do local o=workspace:FindFirstChild(n);if o then o:Destroy()end end
 local f=Instance.new("Folder");f.Name="BBYA Visual v1.0.1";f.Parent=workspace
 -- HOTFIX: the post shown inside the sofa is a legacy/base-map support, not our decorative rail.
 -- Hide only narrow vertical supports immediately around the VIP/stair lounge footprint.
 for _,o in ipairs(workspace:GetDescendants())do
  if o:IsA("BasePart") then
   local ln=string.lower(o.Name)
   if string.find(ln,"stair") then o.Material=Enum.Material.Metal;o.Color=Color3.fromRGB(38,35,47) end
   if (string.find(ln,"pillar") or string.find(ln,"column") or string.find(ln,"support") or string.find(ln,"post")) and o.Size.Y>=6 and o.Size.X<=4 and o.Size.Z<=4 then
    for _,pn in ipairs({"Left VIP Platform","Right VIP Platform"})do local vp=workspace:FindFirstChild(pn);if vp then local lp=vp.CFrame:PointToObjectSpace(o.Position);if math.abs(lp.X)<12 and lp.Z>3 and lp.Z<13 then o.Transparency=1;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false end end end
   end
  end
 end
 local floor=workspace:FindFirstChild("Main Floor");if floor then floor.Material=Enum.Material.Slate;floor.Color=Color3.fromRGB(26,25,33)end
 local dance=workspace:FindFirstChild("Dance Floor");if dance then dance.Material=Enum.Material.Glass;dance.Color=Color3.fromRGB(25,15,38);dance.Reflectance=.12 end
 for _,z in ipairs({-40,-12,16,44})do part(f,"Ceiling Beam "..z,Vector3.new(112,.5,1),CFrame.new(0,18.8,z),Color3.fromRGB(25,22,33),Enum.Material.Metal);part(f,"Ceiling Neon "..z,Vector3.new(72,.14,.2),CFrame.new(0,18.42,z),COLORS[(math.floor((z+40)/28)%#COLORS)+1],Enum.Material.Neon,0,false)end
 local arch=workspace:FindFirstChild("Entrance Arch Top");if arch then local b=part(f,"Entrance Sign",Vector3.new(24,4,.55),arch.CFrame*CFrame.new(0,2.7,-2.2),Color3.fromRGB(20,8,30),Enum.Material.SmoothPlastic,0,false);text(b,"BBYA SOCIAL HUB")end
 local booth=workspace:FindFirstChild("DJ Booth");if booth then local b=part(f,"DJ Sign",Vector3.new(15,2.3,.4),booth.CFrame*CFrame.new(0,3,-3.2),Color3.fromRGB(22,9,32),Enum.Material.SmoothPlastic,0,false);text(b,"BBYA 24/7")end
 for _,cfg in ipairs({{"Left VIP Platform",Color3.fromRGB(78,30,92)},{"Right VIP Platform",Color3.fromRGB(42,43,100)}})do local p=workspace:FindFirstChild(cfg[1]);if p then sofa(f,cfg[1].." Sofa",p.CFrame*CFrame.new(0,4,8),cfg[2]);part(f,cfg[1].." Table",Vector3.new(7,1.2,5),p.CFrame*CFrame.new(0,4,-2),Color3.fromRGB(30,25,38),Enum.Material.Glass)end end
 -- no new vertical rails/posts anywhere near sofas; upper guard is horizontal only
 for _,x in ipairs({-44,44})do part(f,"Upper Guard Neon "..x,Vector3.new(.12,.14,64),CFrame.new(x,16.55,-5),x<0 and COLORS[1] or COLORS[3],Enum.Material.Neon,0,false)end
 local pool=workspace:FindFirstChild("Rooftop Pool");if pool then part(f,"Pool Deck",Vector3.new(pool.Size.X+12,.45,pool.Size.Z+12),pool.CFrame*CFrame.new(0,-.8,0),Color3.fromRGB(66,58,68),Enum.Material.WoodPlanks)end
 local lounge=workspace:FindFirstChild("Rooftop Lounge");if lounge then sofa(f,"Roof Sofa",lounge.CFrame*CFrame.new(-10,3,3),Color3.fromRGB(85,35,90));local throne=Instance.new("Seat");throne.Name="BBYA Queen Throne";throne.Size=Vector3.new(5,2.4,5);throne.CFrame=lounge.CFrame*CFrame.new(11,3,3);throne.Anchored=true;throne.Color=Color3.fromRGB(255,190,70);throne.Material=Enum.Material.Metal;throne.Parent=f;part(f,"Queen Throne Back",Vector3.new(5,7,1),throne.CFrame*CFrame.new(0,3,2),Color3.fromRGB(105,30,105),Enum.Material.Fabric);local crown=part(f,"Queen Crown Sign",Vector3.new(10,2.8,.4),throne.CFrame*CFrame.new(0,7,2.7),Color3.fromRGB(28,8,38),Enum.Material.SmoothPlastic,0,false);text(crown,"QUEEN BBYA",Color3.fromRGB(255,215,90))end
end
local function night()Lighting.ClockTime=21.5;Lighting.Brightness=2.85;Lighting.ExposureCompensation=.5;Lighting.Ambient=Color3.fromRGB(72,55,84);Lighting.OutdoorAmbient=Color3.fromRGB(40,44,68)end
local function queenTag(c)local h=c:FindFirstChild("Head")or c:WaitForChild("Head",10);if not h or h:FindFirstChild("BBYAQueenTag")then return end;local g=Instance.new("BillboardGui");g.Name="BBYAQueenTag";g.Size=UDim2.fromOffset(150,34);g.StudsOffset=Vector3.new(0,3,0);g.MaxDistance=45;g.Parent=h;local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Text="👑 RATU BBYA";t.Font=Enum.Font.GothamBold;t.TextColor3=Color3.fromRGB(255,220,90);t.TextScaled=true;t.Parent=g end
local function queenCommand(p,msg)if p.UserId~=BBYA_QUEEN_USER_ID or string.sub(msg,1,1)~="!"then return end;local a=string.split(msg," ");local c=string.lower(a[1]);if c=="!kick"then local t=findPlayer(a[2]);if t and t~=p then t:Kick("Removed by BBYA Queen")end elseif c=="!bring"then local t=findPlayer(a[2]);if t and t.Character and p.Character then t.Character:PivotTo(p.Character:GetPivot()*CFrame.new(3,0,0))end elseif c=="!goto"then local t=findPlayer(a[2]);if t and t.Character and p.Character then p.Character:PivotTo(t.Character:GetPivot()*CFrame.new(3,0,0))end elseif c=="!speed"then local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=math.clamp(tonumber(a[2])or 32,16,80)end elseif c=="!normal"then local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=16 end elseif c=="!day"then Lighting.ClockTime=14 elseif c=="!night"then night()end end
local function setup(p)local q=p.UserId==BBYA_QUEEN_USER_ID;p:SetAttribute("BBYARole",q and "BBYA_QUEEN"or"PLAYER");p:SetAttribute("BBYAQueen",q);if q then p:SetAttribute("IsVIP",true);p:SetAttribute("BBYAAllAccess",true);p.CharacterAdded:Connect(function(c)task.wait(1);queenTag(c)end);p.Chatted:Connect(function(m)queenCommand(p,m)end);if p.Character then queenTag(p.Character)end end end
build();night();Players.PlayerAdded:Connect(setup);for _,p in ipairs(Players:GetPlayers())do setup(p)end
print("[BBYA] v1.0.1 lounge pillar collision hotfix loaded")