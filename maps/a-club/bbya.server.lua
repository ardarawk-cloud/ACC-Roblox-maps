-- BBYA Social Hub runtime v0.4
-- ACC technical master layer / BBYA Queen gameplay layer

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local BBYA_QUEEN_USER_ID = 4271188557
local CLUB_COLORS = {Color3.fromRGB(255,55,170),Color3.fromRGB(155,70,255),Color3.fromRGB(45,190,255),Color3.fromRGB(255,90,220)}

local function findPlayer(query)
 if not query or query=="" then return nil end; query=string.lower(query)
 for _,p in ipairs(Players:GetPlayers()) do if string.sub(string.lower(p.Name),1,#query)==query or string.sub(string.lower(p.DisplayName),1,#query)==query then return p end end
end
local function markQueen(p)
 local q=p.UserId==BBYA_QUEEN_USER_ID; p:SetAttribute("BBYARole",q and "BBYA_QUEEN" or "PLAYER"); p:SetAttribute("BBYAQueen",q)
 if q then p:SetAttribute("IsVIP",true); p:SetAttribute("BBYAAllAccess",true) end
end
local function addQueenTag(c)
 local h=c:FindFirstChild("Head") or c:WaitForChild("Head",10); if not h or h:FindFirstChild("BBYAQueenTag") then return end
 local g=Instance.new("BillboardGui"); g.Name="BBYAQueenTag"; g.Size=UDim2.fromOffset(220,58); g.StudsOffset=Vector3.new(0,3.4,0); g.AlwaysOnTop=true; g.MaxDistance=120; g.Parent=h
 local t=Instance.new("TextLabel"); t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,.58);t.Font=Enum.Font.GothamBold;t.Text="👑 RATU BBYA 👑";t.TextColor3=Color3.fromRGB(255,220,90);t.TextStrokeTransparency=.25;t.TextScaled=true;t.Parent=g
 local s=Instance.new("TextLabel");s.BackgroundTransparency=1;s.Position=UDim2.fromScale(0,.58);s.Size=UDim2.fromScale(1,.42);s.Font=Enum.Font.GothamMedium;s.Text="OWNER • ALL ACCESS";s.TextColor3=Color3.new(1,1,1);s.TextStrokeTransparency=.45;s.TextScaled=true;s.Parent=g
end
local function sign(part,text,offset)
 if not part or part:FindFirstChild("BBYASign") then return end
 local g=Instance.new("BillboardGui");g.Name="BBYASign";g.Size=UDim2.fromOffset(500,110);g.StudsOffset=offset or Vector3.new(0,8,0);g.AlwaysOnTop=true;g.MaxDistance=220;g.Parent=part
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Size=UDim2.fromScale(1,1);l.Font=Enum.Font.GothamBlack;l.Text=text;l.TextColor3=Color3.fromRGB(255,90,210);l.TextStrokeColor3=Color3.fromRGB(45,5,65);l.TextStrokeTransparency=.15;l.TextScaled=true;l.Parent=g
end
local function setupIdentity()
 local sp=workspace:FindFirstChild("A CLUB Entrance Spawn");if sp then sp.Name="BBYA Social Hub Entrance Spawn" end
 sign(workspace:FindFirstChild("Entrance Arch Top"),"BBYA SOCIAL HUB",Vector3.new(0,5,0));sign(workspace:FindFirstChild("DJ Booth"),"BBYA • 24/7",Vector3.new(0,6,0));sign(workspace:FindFirstChild("Rooftop Bar"),"BBYA ROOFTOP",Vector3.new(0,6,0))
end
local function setupSocialZones()
 local targets={{"Rooftop Pool","POOL PARTY • HANGOUT"},{"VIP Platform Left","VIP SOCIAL LOUNGE"},{"VIP Platform Right","VIP SOCIAL LOUNGE"},{"Main Bar","BBYA BAR • MEET & CHILL"}}
 for _,x in ipairs(targets) do sign(workspace:FindFirstChild(x[1]),x[2],Vector3.new(0,4.5,0)) end
 local folder=workspace:FindFirstChild("BBYA Social Zones") or Instance.new("Folder");folder.Name="BBYA Social Zones";folder.Parent=workspace
 for _,x in ipairs(targets) do local p=workspace:FindFirstChild(x[1]);if p and not folder:FindFirstChild(x[1].." Zone") then local z=Instance.new("Part");z.Name=x[1].." Zone";z.Size=Vector3.new(math.max(p.Size.X,8),.2,math.max(p.Size.Z,8));z.CFrame=p.CFrame*CFrame.new(0,p.Size.Y/2+.12,0);z.Anchored=true;z.CanCollide=false;z.CanTouch=false;z.Transparency=.82;z.Material=Enum.Material.Neon;z.Color=Color3.fromRGB(255,70,190);z.Parent=folder end end
end
local clubParts={}
local function setupClubLighting()
 for _,o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and (string.find(o.Name,"Dance Light") or string.find(o.Name,"Ceiling Light Strip")) then table.insert(clubParts,o);o.Material=Enum.Material.Neon end end
 if #clubParts==0 then return end
 task.spawn(function() local idx=1;while true do idx=idx%#CLUB_COLORS+1;for i,p in ipairs(clubParts) do TweenService:Create(p,TweenInfo.new(.7),{Color=CLUB_COLORS[((idx+i-2)%#CLUB_COLORS)+1]}):Play() end;task.wait(.8) end end)
end
local function night() Lighting.ClockTime=21.5;Lighting.Brightness=1.8;Lighting.Ambient=Color3.fromRGB(35,22,55);Lighting.OutdoorAmbient=Color3.fromRGB(15,18,40) end
local function command(p,msg)
 if p.UserId~=BBYA_QUEEN_USER_ID or string.sub(msg,1,1)~="!" then return end;local a=string.split(msg," ");local c=string.lower(a[1])
 if c=="!kick" then local t=findPlayer(a[2]);if t and t~=p then t:Kick("Removed by BBYA Queen") end
 elseif c=="!bring" then local t=findPlayer(a[2]);if t and t.Character and p.Character then t.Character:PivotTo(p.Character:GetPivot()*CFrame.new(3,0,0)) end
 elseif c=="!goto" then local t=findPlayer(a[2]);if t and t.Character and p.Character then p.Character:PivotTo(t.Character:GetPivot()*CFrame.new(3,0,0)) end
 elseif c=="!speed" then local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=math.clamp(tonumber(a[2]) or 32,16,80) end
 elseif c=="!normal" then local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=16 end
 elseif c=="!day" then Lighting.ClockTime=14;Lighting.Brightness=2 elseif c=="!night" then night() end
end
local function player(p) markQueen(p);if p.UserId==BBYA_QUEEN_USER_ID then p.CharacterAdded:Connect(function(c) task.wait(1);addQueenTag(c) end);p.Chatted:Connect(function(m) command(p,m) end);if p.Character then addQueenTag(p.Character) end end end
setupIdentity();setupSocialZones();night();setupClubLighting();Players.PlayerAdded:Connect(player);for _,p in ipairs(Players:GetPlayers()) do player(p) end
print("[BBYA] Social Hub runtime v0.4 loaded")