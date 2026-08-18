-- BBYA Social Hub runtime v0.6
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")

local BBYA_QUEEN_USER_ID=4271188557
local CLUB_COLORS={Color3.fromRGB(255,55,170),Color3.fromRGB(155,70,255),Color3.fromRGB(45,190,255),Color3.fromRGB(255,90,220)}

local function findPlayer(q)
 if not q or q=="" then return end
 q=string.lower(q)
 for _,p in ipairs(Players:GetPlayers()) do
  if string.sub(string.lower(p.Name),1,#q)==q or string.sub(string.lower(p.DisplayName),1,#q)==q then return p end
 end
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

local function removeOldSigns()
 for _,o in ipairs(workspace:GetDescendants()) do if o.Name=="BBYASign" then o:Destroy() end end
end

local function makePart(parent,name,size,cf,color,material,transparency)
 local p=Instance.new("Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanCollide=true;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Transparency=transparency or 0;p.Parent=parent
 return p
end

local function surfaceText(part,text,face,textColor)
 local gui=Instance.new("SurfaceGui");gui.Name="BBYASurfaceSign";gui.Face=face or Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=35;gui.LightInfluence=.15;gui.Parent=part
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Size=UDim2.fromScale(1,1);l.Font=Enum.Font.GothamBlack;l.Text=text;l.TextColor3=textColor or Color3.fromRGB(255,80,205);l.TextStrokeColor3=Color3.fromRGB(25,0,35);l.TextStrokeTransparency=.2;l.TextScaled=true;l.Parent=gui
end

local function buildVisualPass()
 removeOldSigns()
 local old=workspace:FindFirstChild("BBYA Visual v0.6");if old then old:Destroy() end
 local f=Instance.new("Folder");f.Name="BBYA Visual v0.6";f.Parent=workspace

 -- Entrance facade / fixed signage
 local arch=workspace:FindFirstChild("Entrance Arch Top")
 if arch then
  local board=makePart(f,"BBYA Entrance Sign",Vector3.new(30,6,1),arch.CFrame*CFrame.new(0,4,-2.3),Color3.fromRGB(22,10,32),Enum.Material.SmoothPlastic)
  board.CanCollide=false;surfaceText(board,"BBYA SOCIAL HUB",Enum.NormalId.Front)
  local glow=makePart(f,"Entrance Neon",Vector3.new(31,.35,.45),board.CFrame*CFrame.new(0,-3.2,-.6),Color3.fromRGB(255,50,190),Enum.Material.Neon);glow.CanCollide=false
 end

 -- DJ fixed sign
 local booth=workspace:FindFirstChild("DJ Booth")
 if booth then
  local b=makePart(f,"DJ Branding",Vector3.new(20,3,.5),booth.CFrame*CFrame.new(0,3,-3.3),Color3.fromRGB(25,10,35),Enum.Material.SmoothPlastic);b.CanCollide=false;surfaceText(b,"BBYA 24/7",Enum.NormalId.Front)
 end

 -- VIP lounge framing
 for _,name in ipairs({"Left VIP Platform","Right VIP Platform"}) do
  local p=workspace:FindFirstChild(name)
  if p then
   local trim=makePart(f,name.." Neon Trim",Vector3.new(p.Size.X,.3,p.Size.Z),p.CFrame*CFrame.new(0,p.Size.Y/2+.18,0),Color3.fromRGB(170,55,255),Enum.Material.Neon,.35);trim.CanCollide=false
  end
 end

 -- Main bar front fixed sign
 local bar=workspace:FindFirstChild("Main Bar")
 if bar then
  local b=makePart(f,"Bar Sign",Vector3.new(24,3,.4),bar.CFrame*CFrame.new(0,1.5,-6.2),Color3.fromRGB(20,8,30),Enum.Material.SmoothPlastic);b.CanCollide=false;surfaceText(b,"MEET • CHILL • DANCE",Enum.NormalId.Front,Color3.fromRGB(120,210,255))
 end

 -- Rooftop pool accent and fixed rooftop branding
 local pool=workspace:FindFirstChild("Rooftop Pool")
 if pool then
  local rim=makePart(f,"Pool Neon Rim",Vector3.new(pool.Size.X+2,.25,pool.Size.Z+2),pool.CFrame*CFrame.new(0,.65,0),Color3.fromRGB(70,200,255),Enum.Material.Neon,.45);rim.CanCollide=false
 end
 local rbar=workspace:FindFirstChild("Rooftop Bar")
 if rbar then
  local b=makePart(f,"Rooftop Sign",Vector3.new(20,3,.5),rbar.CFrame*CFrame.new(0,4,-6.2),Color3.fromRGB(20,8,30),Enum.Material.SmoothPlastic);b.CanCollide=false;surfaceText(b,"BBYA ROOFTOP",Enum.NormalId.Front)
 end

 -- Decorative neon columns at entrance + dance floor
 for _,x in ipairs({-22,22}) do makePart(f,"Entrance Glow "..x,Vector3.new(.55,16,.55),CFrame.new(x,9,63),Color3.fromRGB(255,70,200),Enum.Material.Neon).CanCollide=false end
 for _,x in ipairs({-38,38}) do makePart(f,"Dance Accent "..x,Vector3.new(.4,8,.4),CFrame.new(x,5,-28),Color3.fromRGB(80,190,255),Enum.Material.Neon).CanCollide=false end
end

local clubParts={}
local function setupClubLighting()
 for _,o in ipairs(workspace:GetDescendants()) do
  if o:IsA("BasePart") and (string.find(o.Name,"Dance Light") or string.find(o.Name,"Ceiling Light Strip")) then table.insert(clubParts,o);o.Material=Enum.Material.Neon end
 end
 if #clubParts==0 then return end
 task.spawn(function()
  local idx=1
  while true do
   idx=idx%#CLUB_COLORS+1
   for i,p in ipairs(clubParts) do TweenService:Create(p,TweenInfo.new(.7),{Color=CLUB_COLORS[((idx+i-2)%#CLUB_COLORS)+1]}):Play() end
   task.wait(.8)
  end
 end)
end

local function night()
 Lighting.ClockTime=21.5;Lighting.Brightness=2.15;Lighting.ExposureCompensation=.25
 Lighting.Ambient=Color3.fromRGB(48,35,64);Lighting.OutdoorAmbient=Color3.fromRGB(24,28,52)
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
print("[BBYA] Social Hub runtime v0.6 loaded")