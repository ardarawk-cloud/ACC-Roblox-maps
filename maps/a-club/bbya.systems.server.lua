-- BBYA Social Hub v1.6 functional interaction + Queen control backend
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Debris=game:GetService("Debris")
local Lighting=game:GetService("Lighting")

local QUEEN_ID=4271188557
local remotes=ReplicatedStorage:FindFirstChild("BBYA_Remotes") or Instance.new("Folder")
remotes.Name="BBYA_Remotes";remotes.Parent=ReplicatedStorage
local function remote(name)local r=remotes:FindFirstChild(name)or Instance.new("RemoteEvent");r.Name=name;r.Parent=remotes;return r end
local DanceRemote=remote("Dance")
local SyncRemote=remote("SyncDance")
local TitleRemote=remote("SetTitle")
local FXRemote=remote("FX")
local TeleportRemote=remote("Teleport")
local AdminRemote=remote("QueenAdmin")
local NoticeRemote=remote("Notice")

local lastEmote={}
local cooldown={}
local function ready(player,key,seconds)local id=tostring(player.UserId)..":"..key;local now=os.clock();if cooldown[id]and now-cooldown[id]<seconds then return false end;cooldown[id]=now;return true end
local allowedEmotes={dance=true,dance2=true,dance3=true,wave=true,cheer=true,laugh=true,point=true}
local teleportSpots={DANCE=CFrame.new(0,5,0),VIP=CFrame.new(-30,8,8),BAR=CFrame.new(-31,6,24),PHOTO=CFrame.new(31,6,25),CHILL=CFrame.new(31,6,-30),DJ=CFrame.new(0,7,-39),POOL=CFrame.new(0,24,35)}
local function isQueen(p)return p and p.UserId==QUEEN_ID end
local function playEmote(player,name)if not allowedEmotes[name]then return end;local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if not hum then return end;lastEmote[player.UserId]=name;pcall(function()hum:PlayEmote(name)end)end

DanceRemote.OnServerEvent:Connect(function(player,name)if typeof(name)~="string"or not ready(player,"dance",.2)then return end;playEmote(player,string.lower(name))end)
SyncRemote.OnServerEvent:Connect(function(player,targetUserId)if typeof(targetUserId)~="number"or not ready(player,"sync",1)then return end;local target=Players:GetPlayerByUserId(targetUserId);if not target then return end;local a=player.Character and player.Character:FindFirstChild("HumanoidRootPart");local b=target.Character and target.Character:FindFirstChild("HumanoidRootPart");if not a or not b or(a.Position-b.Position).Magnitude>35 then return end;local name=lastEmote[target.UserId];if name then playEmote(player,name)end end)

TitleRemote.OnServerEvent:Connect(function(player,targetUserId,title)
 if not isQueen(player)or typeof(targetUserId)~="number"or typeof(title)~="string"then return end
 title=string.sub(title:gsub("[%c]",""),1,24);local target=Players:GetPlayerByUserId(targetUserId);if not target then return end
 target:SetAttribute("BBYACustomTitle",title);local head=target.Character and target.Character:FindFirstChild("Head");if not head then return end
 local old=head:FindFirstChild("BBYACustomTitleTag");if old then old:Destroy()end;if title==""then return end
 local gui=Instance.new("BillboardGui");gui.Name="BBYACustomTitleTag";gui.Size=UDim2.fromOffset(180,34);gui.StudsOffset=Vector3.new(0,3.5,0);gui.MaxDistance=45;gui.Parent=head
 local lab=Instance.new("TextLabel");lab.BackgroundTransparency=1;lab.Size=UDim2.fromScale(1,1);lab.Font=Enum.Font.GothamBold;lab.Text=title;lab.TextColor3=Color3.fromRGB(255,180,235);lab.TextStrokeTransparency=.35;lab.TextScaled=true;lab.Parent=gui
end)

TeleportRemote.OnServerEvent:Connect(function(player,spot)if typeof(spot)~="string"or not ready(player,"tp",.5)then return end;local cf=teleportSpots[string.upper(spot)];if cf and player.Character then player.Character:PivotTo(cf)end end)
FXRemote.OnServerEvent:Connect(function(player,kind)
 if(kind~="glowstick"and kind~="confetti")or not ready(player,"fx",kind=="confetti"and 4 or 1)then return end
 local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");if not root then return end
 if kind=="glowstick"then if player.Backpack:FindFirstChild("BBYA Glowstick")or char:FindFirstChild("BBYA Glowstick")then return end;local tool=Instance.new("Tool");tool.Name="BBYA Glowstick";tool.RequiresHandle=true;local h=Instance.new("Part");h.Name="Handle";h.Size=Vector3.new(.35,3,.35);h.Material=Enum.Material.Neon;h.Color=Color3.fromRGB(255,70,200);h.CanCollide=false;h.Parent=tool;local light=Instance.new("PointLight");light.Range=10;light.Brightness=1;light.Color=h.Color;light.Parent=h;tool.Parent=player.Backpack
 else for i=1,20 do local p=Instance.new("Part");p.Size=Vector3.new(.25,.25,.25);p.Material=Enum.Material.Neon;p.Color=Color3.fromHSV(math.random(),.8,1);p.CanCollide=false;p.CFrame=root.CFrame*CFrame.new(math.random(-4,4),math.random(2,7),math.random(-4,4));p.Parent=workspace;p.AssemblyLinearVelocity=Vector3.new(math.random(-10,10),math.random(10,22),math.random(-10,10));Debris:AddItem(p,2.5)end end
end)

local function announce(text)text=string.sub(tostring(text or""):gsub("[%c]"," "),1,120);if text~=""then NoticeRemote:FireAllClients(text)end end
AdminRemote.OnServerEvent:Connect(function(player,action,arg1,arg2)
 if not isQueen(player)or not ready(player,"admin",.25)then return end;action=string.lower(tostring(action or""))
 if action=="announce"then announce(arg1)
 elseif action=="party"then workspace:SetAttribute("BBYAPartyMode",true);Lighting.ClockTime=22;announce("BBYA PARTY MODE ON")
 elseif action=="normal"then workspace:SetAttribute("BBYAPartyMode",false);Lighting.ClockTime=21.5;announce("BBYA normal mode")
 elseif action=="bring"or action=="goto"or action=="kick"then local uid=tonumber(arg1);local t=uid and Players:GetPlayerByUserId(uid);if not t then return end;if action=="kick"and t~=player then t:Kick("Removed by BBYA Queen")elseif action=="bring"and t.Character and player.Character then t.Character:PivotTo(player.Character:GetPivot()*CFrame.new(3,0,0))elseif action=="goto"and t.Character and player.Character then player.Character:PivotTo(t.Character:GetPivot()*CFrame.new(3,0,0))end
 elseif action=="speed"then local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if hum then hum.WalkSpeed=math.clamp(tonumber(arg1)or 32,16,80)end
 elseif action=="speednormal"then local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if hum then hum.WalkSpeed=16 end
 end
end)

local function tagQueen(p)p:SetAttribute("BBYAQueen",isQueen(p));if isQueen(p)then p:SetAttribute("BBYARole","BBYA_QUEEN");p:SetAttribute("BBYAAllAccess",true);p:SetAttribute("IsVIP",true)elseif not p:GetAttribute("BBYARole")then p:SetAttribute("BBYARole","GUEST")end end
Players.PlayerAdded:Connect(tagQueen);for _,p in ipairs(Players:GetPlayers())do tagQueen(p)end
Players.PlayerRemoving:Connect(function(p)lastEmote[p.UserId]=nil end)
print("[BBYA] v1.6 functional systems loaded: rate limits, teleport, sync, FX, Queen admin, announcements")