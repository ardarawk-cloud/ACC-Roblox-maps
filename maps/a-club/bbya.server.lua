-- BBYA Social Hub runtime v0.8
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")
local BBYA_QUEEN_USER_ID=4271188557
local COLORS={Color3.fromRGB(255,55,170),Color3.fromRGB(155,70,255),Color3.fromRGB(45,190,255),Color3.fromRGB(255,90,220)}
local function part(par,n,s,cf,c,m,tr,col)local p=Instance.new("Part");p.Name=n;p.Size=s;p.CFrame=cf;p.Anchored=true;p.CanCollide=col~=false;p.Color=c;p.Material=m or Enum.Material.SmoothPlastic;p.Transparency=tr or 0;p.Parent=par;return p end
local function text(p,s)local g=Instance.new("SurfaceGui");g.Face=Enum.NormalId.Front;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=35;g.LightInfluence=.05;g.Parent=p;local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Font=Enum.Font.GothamBlack;t.Text=s;t.TextColor3=Color3.fromRGB(255,90,210);t.TextStrokeTransparency=.25;t.TextScaled=true;t.Parent=g end
local function sofa(f,n,cf,c)part(f,n.." Seat",Vector3.new(14,2,5),cf,c,Enum.Material.Fabric);part(f,n.." Back",Vector3.new(14,4.5,1.2),cf*CFrame.new(0,2,2),c,Enum.Material.Fabric);part(f,n.." L",Vector3.new(1.2,3.2,5),cf*CFrame.new(-6.5,.8,0),c,Enum.Material.Fabric);part(f,n.." R",Vector3.new(1.2,3.2,5),cf*CFrame.new(6.5,.8,0),c,Enum.Material.Fabric)end
local function lamp(f,n,pos,c)local pole=part(f,n.." Pole",Vector3.new(.35,7,.35),CFrame.new(pos),Color3.fromRGB(40,40,48),Enum.Material.Metal,0,false);local l=part(f,n.." Lamp",Vector3.new(2,.3,2),pole.CFrame*CFrame.new(0,3.5,0),c,Enum.Material.Neon,0,false);local q=Instance.new("PointLight");q.Range=18;q.Brightness=1.5;q.Color=c;q.Parent=l end
local function build()
 for _,n in ipairs({"BBYA Visual v0.6","BBYA Visual v0.7","BBYA Visual v0.8"})do local o=workspace:FindFirstChild(n);if o then o:Destroy()end end
 local f=Instance.new("Folder");f.Name="BBYA Visual v0.8";f.Parent=workspace
 local floor=workspace:FindFirstChild("Main Floor");if floor then floor.Material=Enum.Material.Slate;floor.Color=Color3.fromRGB(26,25,33)end
 local dance=workspace:FindFirstChild("Dance Floor");if dance then dance.Material=Enum.Material.Glass;dance.Color=Color3.fromRGB(25,15,38);dance.Reflectance=.12 end
 -- architectural perimeter: breaks up empty blockout walls
 for _,x in ipairs({-58,-38,-18,18,38,58})do part(f,"Wall Column X"..x,Vector3.new(2,18,2),CFrame.new(x,10,-5),Color3.fromRGB(36,25,48),Enum.Material.Concrete)end
 for _,z in ipairs({42,20,-5,-30,-55})do part(f,"Side Column L"..z,Vector3.new(2,18,2),CFrame.new(-63,10,z),Color3.fromRGB(34,24,45),Enum.Material.Concrete);part(f,"Side Column R"..z,Vector3.new(2,18,2),CFrame.new(63,10,z),Color3.fromRGB(34,24,45),Enum.Material.Concrete)end
 -- ceiling beams and neon strips
 for z=-45,45,18 do part(f,"Ceiling Beam "..z,Vector3.new(118,1,2),CFrame.new(0,19,z),Color3.fromRGB(28,23,36),Enum.Material.Metal);part(f,"Ceiling Neon "..z,Vector3.new(92,.22,.35),CFrame.new(0,18.4,z),COLORS[(math.floor((z+45)/18)%#COLORS)+1],Enum.Material.Neon,0,false)end
 -- entrance portal, fixed readable sign
 local arch=workspace:FindFirstChild("Entrance Arch Top");if arch then local b=part(f,"Entrance Sign",Vector3.new(27,5,.8),arch.CFrame*CFrame.new(0,3.2,-2.2),Color3.fromRGB(20,8,30),Enum.Material.SmoothPlastic,0,false);text(b,"BBYA SOCIAL HUB");part(f,"Entrance Neon",Vector3.new(28,.3,.35),b.CFrame*CFrame.new(0,-2.8,-.5),COLORS[1],Enum.Material.Neon,0,false)end
 -- DJ stage frame
 local booth=workspace:FindFirstChild("DJ Booth");if booth then local b=part(f,"DJ Sign",Vector3.new(17,2.8,.5),booth.CFrame*CFrame.new(0,3,-3.2),Color3.fromRGB(22,9,32),Enum.Material.SmoothPlastic,0,false);text(b,"BBYA 24/7");for _,x in ipairs({-16,16})do part(f,"DJ Pillar"..x,Vector3.new(.5,10,.5),booth.CFrame*CFrame.new(x,4,-3.4),Color3.fromRGB(70,190,255),Enum.Material.Neon,0,false)end end
 -- VIP furnishing
 for _,cfg in ipairs({{"Left VIP Platform",Color3.fromRGB(78,30,92),-1},{"Right VIP Platform",Color3.fromRGB(42,43,100),1}})do local p=workspace:FindFirstChild(cfg[1]);if p then sofa(f,cfg[1].." Sofa",p.CFrame*CFrame.new(0,4,8),cfg[2]);part(f,cfg[1].." Table",Vector3.new(7,1.2,5),p.CFrame*CFrame.new(0,4,-2),Color3.fromRGB(30,25,38),Enum.Material.Glass);part(f,cfg[1].." Trim",Vector3.new(28,.25,.25),p.CFrame*CFrame.new(0,7,17),cfg[3]<0 and COLORS[1] or COLORS[3],Enum.Material.Neon,0,false)end end
 -- bar detail
 local bar=workspace:FindFirstChild("Main Bar");if bar then bar.Material=Enum.Material.Marble;bar.Color=Color3.fromRGB(35,22,42);for x=-24,24,8 do part(f,"Stool"..x,Vector3.new(2.2,3,2.2),bar.CFrame*CFrame.new(x,5,-9),Color3.fromRGB(65,42,75),Enum.Material.Metal)end end
 -- lounge dividers and ambient lamps
 for _,z in ipairs({30,5,-20,-45})do lamp(f,"Lamp L"..z,Vector3.new(-52,5,z),COLORS[1]);lamp(f,"Lamp R"..z,Vector3.new(52,5,z),COLORS[3])end
 -- staircase visual treatment
 for _,o in ipairs(workspace:GetDescendants())do if o:IsA("BasePart") and string.find(string.lower(o.Name),"stair") then o.Material=Enum.Material.Metal;o.Color=Color3.fromRGB(45,42,55)end end
 -- rooftop deck/pool
 local pool=workspace:FindFirstChild("Rooftop Pool");if pool then part(f,"Pool Deck",Vector3.new(pool.Size.X+12,.45,pool.Size.Z+12),pool.CFrame*CFrame.new(0,-.8,0),Color3.fromRGB(66,58,68),Enum.Material.WoodPlanks);part(f,"Pool Rim",Vector3.new(pool.Size.X+2,.22,pool.Size.Z+2),pool.CFrame*CFrame.new(0,.65,0),COLORS[3],Enum.Material.Neon,.35,false)end
 local lounge=workspace:FindFirstChild("Rooftop Lounge");if lounge then sofa(f,"Roof Sofa",lounge.CFrame*CFrame.new(0,3,3),Color3.fromRGB(85,35,90));part(f,"Roof Table",Vector3.new(7,1.2,5),lounge.CFrame*CFrame.new(0,3,-6),Color3.fromRGB(25,25,35),Enum.Material.Glass)end
 -- photo wall
 local ph=part(f,"Photo Wall",Vector3.new(25,13,1),CFrame.new(55,8,-54),Color3.fromRGB(34,12,44),Enum.Material.SmoothPlastic);text(ph,"BBYA ✦ SOCIAL HUB");for _,x in ipairs({-12,12})do part(f,"Photo Neon"..x,Vector3.new(.3,13,.3),ph.CFrame*CFrame.new(x,0,-.6),COLORS[1],Enum.Material.Neon,0,false)end
end
local function night()Lighting.ClockTime=21.5;Lighting.Brightness=2.7;Lighting.ExposureCompensation=.45;Lighting.Ambient=Color3.fromRGB(70,52,82);Lighting.OutdoorAmbient=Color3.fromRGB(38,42,66);Lighting.EnvironmentDiffuseScale=.45;Lighting.EnvironmentSpecularScale=.65 end
local function queenTag(c)local h=c:FindFirstChild("Head")or c:WaitForChild("Head",10);if not h or h:FindFirstChild("BBYAQueenTag")then return end;local g=Instance.new("BillboardGui");g.Name="BBYAQueenTag";g.Size=UDim2.fromOffset(150,34);g.StudsOffset=Vector3.new(0,3,0);g.MaxDistance=45;g.Parent=h;local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Text="👑 RATU BBYA";t.Font=Enum.Font.GothamBold;t.TextColor3=Color3.fromRGB(255,220,90);t.TextScaled=true;t.Parent=g end
local function setup(p)local q=p.UserId==BBYA_QUEEN_USER_ID;p:SetAttribute("BBYARole",q and "BBYA_QUEEN"or"PLAYER");p:SetAttribute("BBYAQueen",q);if q then p:SetAttribute("IsVIP",true);p:SetAttribute("BBYAAllAccess",true);p.CharacterAdded:Connect(function(c)task.wait(1);queenTag(c)end);if p.Character then queenTag(p.Character)end end end
local lights={};local function animate()for _,o in ipairs(workspace:GetDescendants())do if o:IsA("BasePart")and(string.find(o.Name,"Dance Light")or string.find(o.Name,"Ceiling Neon"))then table.insert(lights,o);o.Material=Enum.Material.Neon end end;if #lights>0 then task.spawn(function()local n=1;while true do n=n%#COLORS+1;for i,p in ipairs(lights)do TweenService:Create(p,TweenInfo.new(.8),{Color=COLORS[((n+i-2)%#COLORS)+1]}):Play()end;task.wait(1)end end)end end
build();night();animate();Players.PlayerAdded:Connect(setup);for _,p in ipairs(Players:GetPlayers())do setup(p)end
print("[BBYA] Social Hub runtime v0.8 visual construction loaded")