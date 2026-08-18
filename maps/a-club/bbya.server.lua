-- BBYA Social Hub runtime v0.7
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")

local BBYA_QUEEN_USER_ID=4271188557
local CLUB_COLORS={Color3.fromRGB(255,55,170),Color3.fromRGB(155,70,255),Color3.fromRGB(45,190,255),Color3.fromRGB(255,90,220)}

local function findPlayer(q)
 if not q or q=="" then return end
 q=string.lower(q)
 for _,p in ipairs(Players:GetPlayers()) do if string.sub(string.lower(p.Name),1,#q)==q or string.sub(string.lower(p.DisplayName),1,#q)==q then return p end end
end

local function markQueen(p)
 local q=p.UserId==BBYA_QUEEN_USER_ID
 p:SetAttribute("BBYARole",q and "BBYA_QUEEN" or "PLAYER")
 p:SetAttribute("BBYAQueen",q)
 if q then p:SetAttribute("IsVIP",true);p:SetAttribute("BBYAAllAccess",true) end
end

local function addQueenTag(c)
 local h=c:FindFirstChild("Head") or c:WaitForChild("Head",10)
 if not h or h:FindFirstChild("BBYAQueenTag") then return end
 local g=Instance.new("BillboardGui");g.Name="BBYAQueenTag";g.Size=UDim2.fromOffset(150,34);g.StudsOffset=Vector3.new(0,3,0);g.AlwaysOnTop=false;g.MaxDistance=45;g.Parent=h
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Font=Enum.Font.GothamBold;t.Text="👑 RATU BBYA";t.TextColor3=Color3.fromRGB(255,220,90);t.TextStrokeTransparency=.35;t.TextScaled=true;t.Parent=g
end

local function makePart(parent,name,size,cf,color,material,transparency,collide)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=collide~=false;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0;p.Parent=parent;return p
end

local function surfaceText(part,text,face,textColor)
 local gui=Instance.new("SurfaceGui");gui.Name="BBYASurfaceSign";gui.Face=face or Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=38;gui.LightInfluence=.08;gui.Parent=part
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Size=UDim2.fromScale(1,1);l.Font=Enum.Font.GothamBlack;l.Text=text;l.TextColor3=textColor or Color3.fromRGB(255,80,205);l.TextStrokeColor3=Color3.fromRGB(25,0,35);l.TextStrokeTransparency=.2;l.TextScaled=true;l.Parent=gui
end

local function buildSofa(parent,name,cf,color)
 local base=makePart(parent,name.." Base",Vector3.new(16,2.2,6),cf,color,Enum.Material.Fabric)
 makePart(parent,name.." Back",Vector3.new(16,5,1.5),cf*CFrame.new(0,2.2,2.4),color,Enum.Material.Fabric)
 makePart(parent,name.." Arm L",Vector3.new(1.5,3.6,6),cf*CFrame.new(-7.3,1,0),color,Enum.Material.Fabric)
 makePart(parent,name.." Arm R",Vector3.new(1.5,3.6,6),cf*CFrame.new(7.3,1,0),color,Enum.Material.Fabric)
 return base
end

local function buildVisualPass()
 for _,o in ipairs(workspace:GetDescendants()) do if o.Name=="BBYASign" or o.Name=="BBYA Visual v0.6" or o.Name=="BBYA Visual v0.7" then o:Destroy() end end
 local f=Instance.new("Folder");f.Name="BBYA Visual v0.7";f.Parent=workspace

 -- material upgrade existing architecture
 local floor=workspace:FindFirstChild("Main Floor");if floor then floor.Material=Enum.Material.Slate;floor.Color=Color3.fromRGB(28,27,35) end
 local dance=workspace:FindFirstChild("Dance Floor");if dance then dance.Material=Enum.Material.Glass;dance.Color=Color3.fromRGB(25,15,38);dance.Reflectance=.12 end
 local bar=workspace:FindFirstChild("Main Bar");if bar then bar.Material=Enum.Material.SmoothPlastic;bar.Color=Color3.fromRGB(34,18,42) end
 local rfloor=workspace:FindFirstChild("Rooftop Floor");if rfloor then rfloor.Material=Enum.Material.Concrete;rfloor.Color=Color3.fromRGB(42,42,50) end

 -- entrance facade
 local arch=workspace:FindFirstChild("Entrance Arch Top")
 if arch then
  local board=makePart(f,"BBYA Entrance Sign",Vector3.new(30,6,1),arch.CFrame*CFrame.new(0,4,-2.3),Color3.fromRGB(22,10,32),Enum.Material.SmoothPlastic,0,false)
  surfaceText(board,"BBYA SOCIAL HUB",Enum.NormalId.Front)
  makePart(f,"Entrance Neon",Vector3.new(31,.35,.45),board.CFrame*CFrame.new(0,-3.2,-.6),Color3.fromRGB(255,50,190),Enum.Material.Neon,0,false)
 end

 -- DJ branding and light frame
 local booth=workspace:FindFirstChild("DJ Booth")
 if booth then
  local b=makePart(f,"DJ Branding",Vector3.new(20,3,.5),booth.CFrame*CFrame.new(0,3,-3.3),Color3.fromRGB(25,10,35),Enum.Material.SmoothPlastic,0,false);surfaceText(b,"BBYA 24/7",Enum.NormalId.Front)
  makePart(f,"DJ Neon Frame Top",Vector3.new(34,.35,.35),booth.CFrame*CFrame.new(0,7,-3.4),Color3.fromRGB(70,200,255),Enum.Material.Neon,0,false)
 end

 -- VIP lounge actual furniture
 local left=workspace:FindFirstChild("Left VIP Platform")
 if left then
  makePart(f,"Left VIP Carpet",Vector3.new(30,.18,34),left.CFrame*CFrame.new(0,2.1,0),Color3.fromRGB(70,25,85),Enum.Material.Fabric,0,false)
  buildSofa(f,"Left VIP Sofa",left.CFrame*CFrame.new(0,4,8),Color3.fromRGB(75,28,90))
  makePart(f,"Left VIP Coffee Table",Vector3.new(8,1.3,6),left.CFrame*CFrame.new(0,4,-2),Color3.fromRGB(22,22,30),Enum.Material.Glass)
  makePart(f,"Left VIP Neon",Vector3.new(30,.25,.25),left.CFrame*CFrame.new(0,7,19),Color3.fromRGB(255,70,205),Enum.Material.Neon,0,false)
 end
 local right=workspace:FindFirstChild("Right VIP Platform")
 if right then
  makePart(f,"Right VIP Carpet",Vector3.new(30,.18,34),right.CFrame*CFrame.new(0,2.1,0),Color3.fromRGB(40,35,95),Enum.Material.Fabric,0,false)
  buildSofa(f,"Right VIP Sofa",right.CFrame*CFrame.new(0,4,8),Color3.fromRGB(45,45,105))
  makePart(f,"Right VIP Coffee Table",Vector3.new(8,1.3,6),right.CFrame*CFrame.new(0,4,-2),Color3.fromRGB(22,22,30),Enum.Material.Glass)
  makePart(f,"Right VIP Neon",Vector3.new(30,.25,.25),right.CFrame*CFrame.new(0,7,19),Color3.fromRGB(75,190,255),Enum.Material.Neon,0,false)
 end

 -- bar makeover
 if bar then
  local b=makePart(f,"Bar Sign",Vector3.new(24,3,.4),bar.CFrame*CFrame.new(0,1.5,-6.2),Color3.fromRGB(20,8,30),Enum.Material.SmoothPlastic,0,false);surfaceText(b,"MEET • CHILL • DANCE",Enum.NormalId.Front,Color3.fromRGB(120,210,255))
  for x=-24,24,8 do makePart(f,"Bar Stool "..x,Vector3.new(2.4,3,2.4),bar.CFrame*CFrame.new(x,5,-9),Color3.fromRGB(70,40,80),Enum.Material.Metal) end
 end

 -- rooftop pool deck + lounge
 local pool=workspace:FindFirstChild("Rooftop Pool")
 if pool then
  makePart(f,"Pool Neon Rim",Vector3.new(pool.Size.X+2,.25,pool.Size.Z+2),pool.CFrame*CFrame.new(0,.65,0),Color3.fromRGB(70,200,255),Enum.Material.Neon,.35,false)
  makePart(f,"Pool Deck",Vector3.new(pool.Size.X+10,.4,pool.Size.Z+10),pool.CFrame*CFrame.new(0,-.7,0),Color3.fromRGB(60,54,65),Enum.Material.WoodPlanks)
 end
 local lounge=workspace:FindFirstChild("Rooftop Lounge")
 if lounge then
  buildSofa(f,"Rooftop Sofa",lounge.CFrame*CFrame.new(0,3,3),Color3.fromRGB(85,35,90))
  makePart(f,"Rooftop Table",Vector3.new(7,1.2,5),lounge.CFrame*CFrame.new(0,3,-6),Color3.fromRGB(25,25,35),Enum.Material.Glass)
 end
 local rbar=workspace:FindFirstChild("Rooftop Bar")
 if rbar then local b=makePart(f,"Rooftop Sign",Vector3.new(20,3,.5),rbar.CFrame*CFrame.new(0,4,-6.2),Color3.fromRGB(20,8,30),Enum.Material.SmoothPlastic,0,false);surfaceText(b,"BBYA ROOFTOP",Enum.NormalId.Front) end

 -- photo spot / birthday reveal backdrop
 local photo=makePart(f,"BBYA Photo Wall",Vector3.new(28,15,1),CFrame.new(55,9,-54),Color3.fromRGB(35,12,45),Enum.Material.SmoothPlastic)
 surfaceText(photo,"BBYA ✦ SOCIAL HUB",Enum.NormalId.Front,Color3.fromRGB(255,95,215))
 for _,x in ipairs({-13.5,13.5}) do makePart(f,"Photo Neon "..x,Vector3.new(.35,15,.35),photo.CFrame*CFrame.new(x,0,-.6),Color3.fromRGB(255,70,200),Enum.Material.Neon,0,false) end

 -- architectural accent columns
 for _,x in ipairs({-22,22}) do makePart(f,"Entrance Glow "..x,Vector3.new(.55,16,.55),CFrame.new(x,9,63),Color3.fromRGB(255,70,200),Enum.Material.Neon,0,false) end
 for _,x in ipairs({-38,38}) do makePart(f,"Dance Accent "..x,Vector3.new(.4,8,.4),CFrame.new(x,5,-28),Color3.fromRGB(80,190,255),Enum.Material.Neon,0,false) end
end

local clubParts={}
local function setupClubLighting()
 for _,o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and (string.find(o.Name,"Dance Light") or string.find(o.Name,"Ceiling Light Strip")) then table.insert(clubParts,o);o.Material=Enum.Material.Neon end end
 if #clubParts==0 then return end
 task.spawn(function()local idx=1;while true do idx=idx%#CLUB_COLORS+1;for i,p in ipairs(clubParts) do TweenService:Create(p,TweenInfo.new(.7),{Color=CLUB_COLORS[((idx+i-2)%#CLUB_COLORS)+1]}):Play() end;task.wait(.8) end end)
end

local function night()
 Lighting.ClockTime=21.5;Lighting.Brightness=2.35;Lighting.ExposureCompensation=.35
 Lighting.Ambient=Color3.fromRGB(58,42,72);Lighting.OutdoorAmbient=Color3.fromRGB(30,34,58)
end

local function command(p,msg)
 if p.UserId~=BBYA_QUEEN_USER_ID or string.sub(msg,1,1)~="!" then return end
 local a=string.split(msg," ");local c=string.lower(a[1])
 if c=="!kick" then local t=findPlayer(a[2]);if t and t~=p then t:Kick("Removed by BBYA Queen") end
 elseif c=="!bring" then local t=findPlayer(a[2]);if t and t.Character and p.Character then t.Character:PivotTo(p.Character:GetPivot()*CFrame.new(3,0,0)) end
 elseif c=="!goto" then local t=findPlayer(a[2]);if t and t.Character and p.Character then p.Character:PivotTo(t.Character:GetPivot()*CFrame.new(3,0,0)) end
 elseif c=="!speed" then local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=math.clamp(tonumber(a[2]) or 32,16,80) end
 elseif c=="!normal" then local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=16 end
 elseif c=="!day" then Lighting.ClockTime=14;Lighting.Brightness=2
 elseif c=="!night" then night() end
end

local function setupPlayer(p)
 markQueen(p)
 if p.UserId==BBYA_QUEEN_USER_ID then
  p.CharacterAdded:Connect(function(c)task.wait(1);addQueenTag(c) end)
  p.Chatted:Connect(function(m)command(p,m) end)
  if p.Character then addQueenTag(p.Character) end
 end
end

local sp=workspace:FindFirstChild("A CLUB Entrance Spawn");if sp then sp.Name="BBYA Social Hub Entrance Spawn" end
buildVisualPass();night();setupClubLighting();Players.PlayerAdded:Connect(setupPlayer);for _,p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
print("[BBYA] Social Hub runtime v0.7 loaded")