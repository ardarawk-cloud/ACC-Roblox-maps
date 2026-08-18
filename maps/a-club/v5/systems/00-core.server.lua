-- [SYS-CORE] BBYA V5 PLAYER / PROFILE CORE
local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local QUEEN_ID=4271188557
local profileStore=DataStoreService:GetDataStore("BBYA_Profile_v1")

local remotes=ReplicatedStorage:FindFirstChild("BBYA_V5_Remotes") or Instance.new("Folder")
remotes.Name="BBYA_V5_Remotes";remotes.Parent=ReplicatedStorage
local function sysRemote(name)
 local r=remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
 r.Name=name;r.Parent=remotes;return r
end
local DanceRemote=sysRemote("Dance")
local SyncRemote=sysRemote("SyncDance")
local MusicRemote=sysRemote("MusicControl")
local MusicState=sysRemote("MusicState")
local NoticeRemote=sysRemote("Notice")
local LiftRemote=sysRemote("LiftTravel")
local VIPRemote=sysRemote("VIPAction")
local SupportRemote=sysRemote("SupportAction")

local profiles={}
local function defaultProfile() return {Level=1,XP=0,Likes=0,Donated=0} end
local function rankName(level,donated,isQueen)
 if isQueen then return "BBYA QUEEN" end
 if donated>=1000 then return "ROYAL ELITE" end
 if donated>=500 then return "NIGHT ARISTOCRAT" end
 if level>=40 then return "NIGHT ICON" end
 if level>=20 then return "SOCIALITE" end
 if level>=10 then return "REGULAR" end
 return "NEWBIE"
end

local function refreshTag(p)
 local char=p.Character;local head=char and char:FindFirstChild("Head");if not head then return end
 local old=head:FindFirstChild("BBYA_V5_Title");if old then old:Destroy() end
 local g=Instance.new("BillboardGui");g.Name="BBYA_V5_Title";g.Size=UDim2.fromOffset(190,38);g.StudsOffset=Vector3.new(0,3.1,0);g.MaxDistance=52;g.AlwaysOnTop=false;g.Parent=head
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Size=UDim2.fromScale(1,1);t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.TextColor3=Color3.fromRGB(255,130,220);t.TextStrokeTransparency=.55;t.Parent=g
 t.Text=rankName(p:GetAttribute("BBYALevel") or 1,p:GetAttribute("TotalDonated") or 0,p.UserId==QUEEN_ID)
end

local function applyProfile(p,data)
 data=type(data)=="table" and data or defaultProfile();profiles[p.UserId]=data
 if p.UserId==QUEEN_ID then p:SetAttribute("BBYAQueen",true);p:SetAttribute("BBYAAllAccess",true);p:SetAttribute("IsVIP",true);p:SetAttribute("BBYARole","BBYA_QUEEN")
 else p:SetAttribute("BBYAQueen",false);if p:GetAttribute("BBYARole")==nil then p:SetAttribute("BBYARole","GUEST") end end
 p:SetAttribute("BBYALevel",tonumber(data.Level) or 1);p:SetAttribute("BBYAXP",tonumber(data.XP) or 0);p:SetAttribute("BBYALikes",tonumber(data.Likes) or 0)
 if p:GetAttribute("TotalDonated")==nil then p:SetAttribute("TotalDonated",tonumber(data.Donated) or 0) end
 local ls=p:FindFirstChild("leaderstats") or Instance.new("Folder");ls.Name="leaderstats";ls.Parent=p
 local function iv(name,val)local x=ls:FindFirstChild(name) or Instance.new("IntValue");x.Name=name;x.Value=val;x.Parent=ls;return x end
 iv("Level",p:GetAttribute("BBYALevel"));iv("Likes",p:GetAttribute("BBYALikes"));iv("Donated",p:GetAttribute("TotalDonated") or 0)
 p.CharacterAdded:Connect(function() task.wait(1);refreshTag(p) end)
 if p.Character then task.defer(refreshTag,p) end
end

local function load(p)
 local data;pcall(function() data=profileStore:GetAsync("u"..p.UserId) end);applyProfile(p,data)
end
local function save(p)
 local data=profiles[p.UserId] or defaultProfile();data.Level=p:GetAttribute("BBYALevel") or data.Level;data.XP=p:GetAttribute("BBYAXP") or data.XP;data.Likes=p:GetAttribute("BBYALikes") or data.Likes;data.Donated=p:GetAttribute("TotalDonated") or data.Donated
 pcall(function() profileStore:SetAsync("u"..p.UserId,data) end)
end

Players.PlayerAdded:Connect(load)
Players.PlayerRemoving:Connect(function(p) save(p);profiles[p.UserId]=nil end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(load,p) end

task.spawn(function()
 while task.wait(60) do
  for _,p in ipairs(Players:GetPlayers()) do
   local xp=(p:GetAttribute("BBYAXP") or 0)+1;local level=math.floor(xp/5)+1
   p:SetAttribute("BBYAXP",xp);p:SetAttribute("BBYALevel",level)
   local ls=p:FindFirstChild("leaderstats");if ls and ls:FindFirstChild("Level") then ls.Level.Value=level end
   refreshTag(p)
  end
 end
end)

game:BindToClose(function() for _,p in ipairs(Players:GetPlayers()) do save(p) end end)
workspace:SetAttribute("BBYASystemCore","5.0")
