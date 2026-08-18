-- BBYA Social Hub runtime v1.2 FUNCTIONAL SYSTEMS PACK
-- Music stays owned by the existing BBYA audio system; this file does not replace it.
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")
local DataStoreService=game:GetService("DataStoreService")
local Debris=game:GetService("Debris")

local BBYA_QUEEN_USER_ID=4271188557
local COLORS={Color3.fromRGB(255,55,170),Color3.fromRGB(155,70,255),Color3.fromRGB(45,190,255),Color3.fromRGB(255,90,220)}
local profileStore=DataStoreService:GetDataStore("BBYA_Profile_v1")
local serverLikesStore=DataStoreService:GetDataStore("BBYA_Likes_v1")
local profiles={}

local function part(par,n,s,cf,c,m,tr,col)
 local p=Instance.new("Part");p.Name=n;p.Size=s;p.CFrame=cf;p.Anchored=true;p.CanCollide=col~=false;p.Color=c;p.Material=m or Enum.Material.SmoothPlastic;p.Transparency=tr or 0;p.Parent=par;return p
end
local function text(p,s,color)
 local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=30;g.LightInfluence=.05;g.Parent=p
 local t=Instance.new("TextLabel");t.Name="Text";t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Font=Enum.Font.GothamBlack;t.Text=s;t.TextColor3=color or Color3.fromRGB(255,90,210);t.TextStrokeTransparency=.3;t.TextScaled=true;t.Parent=g
 return t
end
local function sign(f,n,cf,label,w,color)local b=part(f,n,Vector3.new(w or 14,2.4,.35),cf,Color3.fromRGB(20,8,30),Enum.Material.SmoothPlastic,0,false);text(b,label,color);return b end
local function prompt(p,action,obj,hold)local pr=Instance.new("ProximityPrompt");pr.ActionText=action;pr.ObjectText=obj;pr.HoldDuration=hold or 0;pr.MaxActivationDistance=10;pr.RequiresLineOfSight=false;pr.Parent=p;return pr end
local function sofa(f,n,cf,c)local seat=Instance.new("Seat");seat.Name=n.." Seat";seat.Size=Vector3.new(14,2,5);seat.CFrame=cf;seat.Anchored=true;seat.Color=c;seat.Material=Enum.Material.Fabric;seat.Parent=f;part(f,n.." Back",Vector3.new(14,4.5,1.2),cf*CFrame.new(0,2,2),c,Enum.Material.Fabric);part(f,n.." L",Vector3.new(1.2,3.2,5),cf*CFrame.new(-6.5,.8,0),c,Enum.Material.Fabric);part(f,n.." R",Vector3.new(1.2,3.2,5),cf*CFrame.new(6.5,.8,0),c,Enum.Material.Fabric)end
local function findPlayer(q)if not q or q==""then return nil end;q=string.lower(q);for _,p in ipairs(Players:GetPlayers())do if string.sub(string.lower(p.Name),1,#q)==q or string.sub(string.lower(p.DisplayName),1,#q)==q then return p end end end

local function titleFor(profile,isQueen)
 if isQueen then return "👑 RATU BBYA" end
 if profile.CustomTitle and profile.CustomTitle~="" then return profile.CustomTitle end
 local level=profile.Level or 1
 if level>=25 then return "BBYA LEGEND" elseif level>=15 then return "NIGHT ICON" elseif level>=8 then return "BBYA REGULAR" elseif level>=3 then return "SOCIALITE" end
 return ""
end
local function applyOverhead(player,character)
 local head=character:FindFirstChild("Head")or character:WaitForChild("Head",10);if not head then return end
 local old=head:FindFirstChild("BBYATitleTag");if old then old:Destroy()end
 local profile=profiles[player.UserId]or{Level=1};local title=titleFor(profile,player.UserId==BBYA_QUEEN_USER_ID);if title==""then return end
 local g=Instance.new("BillboardGui");g.Name="BBYATitleTag";g.Size=UDim2.fromOffset(170,34);g.StudsOffset=Vector3.new(0,3,0);g.MaxDistance=48;g.AlwaysOnTop=false;g.Parent=head
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Text=title;t.Font=Enum.Font.GothamBold;t.TextColor3=player.UserId==BBYA_QUEEN_USER_ID and Color3.fromRGB(255,220,90)or Color3.fromRGB(255,130,225);t.TextStrokeTransparency=.4;t.TextScaled=true;t.Parent=g
end
local function saveProfile(player)
 local p=profiles[player.UserId];if not p then return end
 p.Donated=player:GetAttribute("TotalDonated")or p.Donated or 0
 pcall(function()profileStore:SetAsync("u"..player.UserId,p)end)
end

local boardText=nil
local function refreshBoard()
 if not boardText then return end
 local rows={}
 for _,p in ipairs(Players:GetPlayers())do
  local pr=profiles[p.UserId]or{Level=1,Likes=0,Donated=0}
  table.insert(rows,{name=p.DisplayName,level=pr.Level or 1,likes=pr.Likes or 0,donated=p:GetAttribute("TotalDonated")or pr.Donated or 0})
 end
 table.sort(rows,function(a,b)if a.level==b.level then return a.donated>b.donated end return a.level>b.level end)
 local out="BBYA SOCIAL LEADERBOARD\n"
 for i=1,math.min(8,#rows)do local r=rows[i];out..=string.format("%d. %s  LV.%d  ♥%d  R$%d\n",i,r.name,r.level,r.likes,r.donated)end
 boardText.Text=out
end
local function celebration(player,delta)
 if delta<=0 then return end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not root then return end
 local anchor=Instance.new("Part");anchor.Name="BBYA Donate Effect";anchor.Size=Vector3.new(1,1,1);anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CFrame=root.CFrame*CFrame.new(0,5,0);anchor.Parent=workspace
 local bill=Instance.new("BillboardGui");bill.Size=UDim2.fromOffset(260,70);bill.AlwaysOnTop=true;bill.Parent=anchor
 local lab=Instance.new("TextLabel");lab.BackgroundTransparency=1;lab.Size=UDim2.fromScale(1,1);lab.Font=Enum.Font.GothamBlack;lab.Text=string.format("%s SUPPORT +%d",player.DisplayName,delta);lab.TextColor3=Color3.fromRGB(255,215,90);lab.TextStrokeTransparency=.25;lab.TextScaled=true;lab.Parent=bill
 for i=1,18 do local c=Instance.new("Part");c.Size=Vector3.new(.35,.35,.35);c.Material=Enum.Material.Neon;c.Color=COLORS[math.random(1,#COLORS)];c.CanCollide=false;c.CFrame=root.CFrame*CFrame.new(math.random(-4,4),math.random(2,8),math.random(-4,4));c.Parent=workspace;c.AssemblyLinearVelocity=Vector3.new(math.random(-8,8),math.random(8,18),math.random(-8,8));Debris:AddItem(c,2.5)end
 Debris:AddItem(anchor,4)
end

local function build()
 for _,o in ipairs(workspace:GetChildren())do if string.sub(o.Name,1,11)=="BBYA Visual"or o.Name=="BBYA Social Systems"then o:Destroy()end end
 local f=Instance.new("Folder");f.Name="BBYA Visual v1.2";f.Parent=workspace
 local systems=Instance.new("Folder");systems.Name="BBYA Social Systems";systems.Parent=workspace
 -- remove legacy lounge post collisions
 for _,o in ipairs(workspace:GetDescendants())do if o:IsA("BasePart")then local ln=string.lower(o.Name);if string.find(ln,"stair")then o.Material=Enum.Material.Metal;o.Color=Color3.fromRGB(38,35,47)end;if(string.find(ln,"pillar")or string.find(ln,"column")or string.find(ln,"support")or string.find(ln,"post"))and o.Size.Y>=6 and o.Size.X<=4 and o.Size.Z<=4 then for _,pn in ipairs({"Left VIP Platform","Right VIP Platform"})do local vp=workspace:FindFirstChild(pn);if vp then local lp=vp.CFrame:PointToObjectSpace(o.Position);if math.abs(lp.X)<12 and lp.Z>3 and lp.Z<13 then o.Transparency=1;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false end end end end end end
 local floor=workspace:FindFirstChild("Main Floor");if floor then floor.Material=Enum.Material.Slate;floor.Color=Color3.fromRGB(26,25,33)end
 local dance=workspace:FindFirstChild("Dance Floor");if dance then dance.Material=Enum.Material.Glass;dance.Color=Color3.fromRGB(25,15,38);for i=-2,2 do for j=-2,2 do local tile=part(f,"Dance Tile",Vector3.new(6,.18,6),dance.CFrame*CFrame.new(i*6,dance.Size.Y/2+.12,j*6),COLORS[((i+j+20)%#COLORS)+1],Enum.Material.Neon,.15,false);task.spawn(function()while tile.Parent do TweenService:Create(tile,TweenInfo.new(.8),{Transparency=.55}):Play();task.wait(.8);TweenService:Create(tile,TweenInfo.new(.8),{Transparency=.12}):Play();task.wait(.8)end end)end end end
 for _,z in ipairs({-40,-12,16,44})do part(f,"Ceiling Beam "..z,Vector3.new(112,.5,1),CFrame.new(0,18.8,z),Color3.fromRGB(25,22,33),Enum.Material.Metal);part(f,"Ceiling Neon "..z,Vector3.new(72,.14,.2),CFrame.new(0,18.42,z),COLORS[(math.floor((z+40)/28)%#COLORS)+1],Enum.Material.Neon,0,false)end
 local arch=workspace:FindFirstChild("Entrance Arch Top");if arch then sign(f,"Entrance Sign",arch.CFrame*CFrame.new(0,2.7,-2.2),"BBYA SOCIAL HUB",24)end
 local booth=workspace:FindFirstChild("DJ Booth");if booth then sign(f,"DJ Sign",booth.CFrame*CFrame.new(0,3,-3.2),"DJ • BBYA 24/7",17);local dj=part(systems,"DJ Console",Vector3.new(8,1,3),booth.CFrame*CFrame.new(0,2,-1),Color3.fromRGB(35,25,48),Enum.Material.Metal);prompt(dj,"Hype Crowd","DJ Console",.3).Triggered:Connect(function()for _,p in ipairs(f:GetDescendants())do if p:IsA("BasePart")and string.find(p.Name,"Neon")then p.Color=COLORS[math.random(1,#COLORS)]end end end)end
 for _,cfg in ipairs({{"Left VIP Platform",Color3.fromRGB(78,30,92)},{"Right VIP Platform",Color3.fromRGB(42,43,100)}})do local p=workspace:FindFirstChild(cfg[1]);if p then sofa(f,cfg[1].." Sofa",p.CFrame*CFrame.new(0,4,8),cfg[2]);part(f,cfg[1].." Table",Vector3.new(7,1.2,5),p.CFrame*CFrame.new(0,4,-2),Color3.fromRGB(30,25,38),Enum.Material.Glass);sign(f,cfg[1].." Sign",p.CFrame*CFrame.new(0,8,13),"VIP LOUNGE",12)end end
 -- functional bar
 local bar=part(f,"BBYA Bar",Vector3.new(24,4,6),CFrame.new(-31,3,30),Color3.fromRGB(32,22,38),Enum.Material.Marble);sign(f,"Bar Sign",CFrame.new(-31,7,27),"BBYA BAR • MOCKTAILS",20);prompt(bar,"Order","Neon Mocktail",.2).Triggered:Connect(function(plr)if plr.Backpack:FindFirstChild("BBYA Neon Drink")then return end;local tool=Instance.new("Tool");tool.Name="BBYA Neon Drink";tool.RequiresHandle=true;local h=Instance.new("Part");h.Name="Handle";h.Size=Vector3.new(1.2,1.8,1.2);h.Color=COLORS[math.random(1,#COLORS)];h.Material=Enum.Material.Neon;h.CanCollide=false;h.Parent=tool;tool.Parent=plr.Backpack end)
 -- photo/selfie zone with pose seats
 local photo=part(f,"Photo Wall",Vector3.new(20,12,1),CFrame.new(31,7,31),Color3.fromRGB(45,15,55),Enum.Material.SmoothPlastic);text(photo,"BBYA ♥ NIGHT");for _,x in ipairs({-6,0,6})do local s=Instance.new("Seat");s.Name="Photo Pose Seat";s.Size=Vector3.new(3,1,3);s.CFrame=CFrame.new(31+x,2,25)*CFrame.Angles(0,math.pi,0);s.Anchored=true;s.Transparency=.55;s.Color=COLORS[(math.floor((x+6)/6)%#COLORS)+1];s.Material=Enum.Material.Neon;s.Parent=f end
 -- chill area
 local chill=part(f,"Chill Table",Vector3.new(7,1,7),CFrame.new(31,2,-30),Color3.fromRGB(35,30,45),Enum.Material.Glass);sign(f,"Chill Sign",CFrame.new(31,6,-34),"CHILL & TALK",14);for i=0,5 do local a=i*math.pi/3;local s=Instance.new("Seat");s.Name="Chill Seat";s.Size=Vector3.new(4,1.2,4);s.CFrame=CFrame.new(31+math.cos(a)*8,2,-30+math.sin(a)*8)*CFrame.Angles(0,-a+math.pi/2,0);s.Anchored=true;s.Color=Color3.fromRGB(70,35,80);s.Material=Enum.Material.Fabric;s.Parent=f end
 -- Like BBYA station, one persistent like per account
 local likePad=part(systems,"Like BBYA",Vector3.new(8,.4,8),CFrame.new(49,1,-31),Color3.fromRGB(255,65,175),Enum.Material.Neon,.1);local likePrompt=prompt(likePad,"LIKE","Support BBYA",.3);likePrompt.Triggered:Connect(function(plr)local pr=profiles[plr.UserId];if not pr or pr.HasLiked then return end;pr.HasLiked=true;pr.Likes=(pr.Likes or 0)+1;local ls=plr:FindFirstChild("leaderstats");if ls and ls:FindFirstChild("Likes")then ls.Likes.Value=pr.Likes end;pcall(function()serverLikesStore:UpdateAsync("total",function(v)return(v or 0)+1 end)end);saveProfile(plr);refreshBoard()end)
 -- functional social leaderboard
 local board=part(f,"Leaderboard Board",Vector3.new(24,14,1),CFrame.new(-49,8,-31),Color3.fromRGB(15,12,22),Enum.Material.SmoothPlastic);local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=22;gui.Parent=board;boardText=Instance.new("TextLabel");boardText.BackgroundTransparency=1;boardText.Size=UDim2.fromScale(1,1);boardText.TextColor3=Color3.fromRGB(235,225,255);boardText.TextXAlignment=Enum.TextXAlignment.Left;boardText.TextYAlignment=Enum.TextYAlignment.Top;boardText.Font=Enum.Font.GothamBold;boardText.TextScaled=false;boardText.TextSize=22;boardText.Parent=gui
 -- rooftop + queen throne
 local pool=workspace:FindFirstChild("Rooftop Pool");if pool then part(f,"Pool Deck",Vector3.new(pool.Size.X+12,.45,pool.Size.Z+12),pool.CFrame*CFrame.new(0,-.8,0),Color3.fromRGB(66,58,68),Enum.Material.WoodPlanks);sign(f,"Pool Sign",pool.CFrame*CFrame.new(0,5,-pool.Size.Z/2-4),"ROOFTOP POOL PARTY",20);for _,x in ipairs({-14,14})do sofa(f,"Pool Sofa "..x,pool.CFrame*CFrame.new(x,2,pool.Size.Z/2+6),Color3.fromRGB(60,35,75))end end
 local lounge=workspace:FindFirstChild("Rooftop Lounge");if lounge then sofa(f,"Roof Sofa",lounge.CFrame*CFrame.new(-10,3,3),Color3.fromRGB(85,35,90));local throne=Instance.new("Seat");throne.Name="BBYA Queen Throne";throne.Size=Vector3.new(5,2.4,5);throne.CFrame=lounge.CFrame*CFrame.new(11,3,3);throne.Anchored=true;throne.Color=Color3.fromRGB(255,190,70);throne.Material=Enum.Material.Metal;throne.Parent=f;part(f,"Queen Throne Back",Vector3.new(5,7,1),throne.CFrame*CFrame.new(0,3,2),Color3.fromRGB(105,30,105),Enum.Material.Fabric);sign(f,"Queen Crown Sign",throne.CFrame*CFrame.new(0,7,2.7),"QUEEN BBYA",10,Color3.fromRGB(255,215,90))end
 -- teleport hub
 local spots={{"DANCE",CFrame.new(0,1,0)},{"VIP",CFrame.new(-30,5,8)},{"BAR",CFrame.new(-31,5,24)},{"PHOTO",CFrame.new(31,5,25)},{"CHILL",CFrame.new(31,4,-30)}};for i,v in ipairs(spots)do local pad=part(systems,"Teleport "..v[1],Vector3.new(7,.35,7),CFrame.new(-20+(i-1)*10,1,-44),COLORS[((i-1)%#COLORS)+1],Enum.Material.Neon,.1);prompt(pad,"Go",v[1]).Triggered:Connect(function(plr)if plr.Character then plr.Character:PivotTo(v[2]*CFrame.new(0,3,0))end end)end
end

local function night()Lighting.ClockTime=21.5;Lighting.Brightness=2.85;Lighting.ExposureCompensation=.5;Lighting.Ambient=Color3.fromRGB(72,55,84);Lighting.OutdoorAmbient=Color3.fromRGB(40,44,68)end
local function partyBurst()
 for _,o in ipairs(workspace:GetDescendants())do if o:IsA("BasePart")and(string.find(o.Name,"Neon")or string.find(o.Name,"Dance Tile"))then o.Color=COLORS[math.random(1,#COLORS)]end end
end
local function queenCommand(p,msg)
 if p.UserId~=BBYA_QUEEN_USER_ID or string.sub(msg,1,1)~="!"then return end
 local a=string.split(msg," ");local c=string.lower(a[1])
 if c=="!kick"then local t=findPlayer(a[2]);if t and t~=p then t:Kick("Removed by BBYA Queen")end
 elseif c=="!bring"then local t=findPlayer(a[2]);if t and t.Character and p.Character then t.Character:PivotTo(p.Character:GetPivot()*CFrame.new(3,0,0))end
 elseif c=="!goto"then local t=findPlayer(a[2]);if t and t.Character and p.Character then p.Character:PivotTo(t.Character:GetPivot()*CFrame.new(3,0,0))end
 elseif c=="!speed"then local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=math.clamp(tonumber(a[2])or 32,16,80)end
 elseif c=="!normal"then local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=16 end
 elseif c=="!day"then Lighting.ClockTime=14
 elseif c=="!night"then night()
 elseif c=="!party"or c=="!event"then partyBurst()
 elseif c=="!title"then local target=findPlayer(a[2]);if target then local title=table.concat(a," ",3);profiles[target.UserId].CustomTitle=string.sub(title,1,24);if target.Character then applyOverhead(target,target.Character)end;saveProfile(target)end
 elseif c=="!untitle"then local target=findPlayer(a[2]);if target then profiles[target.UserId].CustomTitle="";if target.Character then applyOverhead(target,target.Character)end;saveProfile(target)end
 end
end
local function setup(player)
 local data={Level=1,XP=0,Likes=0,Donated=0,HasLiked=false,CustomTitle=""};pcall(function()local saved=profileStore:GetAsync("u"..player.UserId);if type(saved)=="table"then for k,v in pairs(saved)do data[k]=v end end end);profiles[player.UserId]=data
 local q=player.UserId==BBYA_QUEEN_USER_ID;player:SetAttribute("BBYARole",q and"BBYA_QUEEN"or"GUEST");player:SetAttribute("BBYAQueen",q);if q then player:SetAttribute("IsVIP",true);player:SetAttribute("BBYAAllAccess",true)end
 local ls=Instance.new("Folder");ls.Name="leaderstats";ls.Parent=player;local lv=Instance.new("IntValue");lv.Name="Level";lv.Value=data.Level;lv.Parent=ls;local likes=Instance.new("IntValue");likes.Name="Likes";likes.Value=data.Likes;likes.Parent=ls;local don=Instance.new("IntValue");don.Name="Donated";don.Value=player:GetAttribute("TotalDonated")or data.Donated or 0;don.Parent=ls
 local lastDon=don.Value
 player:GetAttributeChangedSignal("TotalDonated"):Connect(function()local now=player:GetAttribute("TotalDonated")or 0;don.Value=now;data.Donated=now;if now>lastDon then celebration(player,now-lastDon)end;lastDon=now;refreshBoard()end)
 player.CharacterAdded:Connect(function(c)task.wait(1);applyOverhead(player,c)end);if player.Character then applyOverhead(player,player.Character)end
 if q then player.Chatted:Connect(function(m)queenCommand(player,m)end)end
 task.spawn(function()while player.Parent do task.wait(60);data.XP=(data.XP or 0)+1;local newLevel=math.floor(data.XP/5)+1;if newLevel~=data.Level then data.Level=newLevel;lv.Value=newLevel;if player.Character then applyOverhead(player,player.Character)end end;refreshBoard()end end)
 refreshBoard()
end

build();night();Players.PlayerAdded:Connect(setup);Players.PlayerRemoving:Connect(function(p)saveProfile(p);profiles[p.UserId]=nil;task.defer(refreshBoard)end);for _,p in ipairs(Players:GetPlayers())do setup(p)end
game:BindToClose(function()for _,p in ipairs(Players:GetPlayers())do saveProfile(p)end end)
print("[BBYA] v1.2 functional pack loaded: persistence, level, likes, leaderboard, donate effects, titles, DJ, bar, photo poses, chill, pool, teleport, Queen events")