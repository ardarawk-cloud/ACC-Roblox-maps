-- BBYA Social Hub v1.3 functional interaction systems
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Debris=game:GetService("Debris")

local QUEEN_ID=4271188557
local remotes=ReplicatedStorage:FindFirstChild("BBYA_Remotes") or Instance.new("Folder")
remotes.Name="BBYA_Remotes";remotes.Parent=ReplicatedStorage

local function remote(name)
 local r=remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
 r.Name=name;r.Parent=remotes;return r
end
local DanceRemote=remote("Dance")
local SyncRemote=remote("SyncDance")
local TitleRemote=remote("SetTitle")
local FXRemote=remote("FX")
local TeleportRemote=remote("Teleport")
local lastEmote={}

local allowedEmotes={dance=true,dance2=true,dance3=true,wave=true,cheer=true,laugh=true,point=true}
local teleportSpots={
 DANCE=CFrame.new(0,5,0),
 VIP=CFrame.new(-30,8,8),
 BAR=CFrame.new(-31,6,24),
 PHOTO=CFrame.new(31,6,25),
 CHILL=CFrame.new(31,6,-30),
}

local function playEmote(player,name)
 if not allowedEmotes[name] then return end
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if not hum then return end
 lastEmote[player.UserId]=name
 pcall(function() hum:PlayEmote(name) end)
end

DanceRemote.OnServerEvent:Connect(function(player,name)
 if typeof(name)~="string" then return end
 playEmote(player,string.lower(name))
end)

SyncRemote.OnServerEvent:Connect(function(player,targetUserId)
 if typeof(targetUserId)~="number" then return end
 local target=Players:GetPlayerByUserId(targetUserId)
 if not target then return end
 local name=lastEmote[target.UserId]
 if name then playEmote(player,name) end
end)

TitleRemote.OnServerEvent:Connect(function(player,targetUserId,title)
 if player.UserId~=QUEEN_ID then return end
 if typeof(targetUserId)~="number" or typeof(title)~="string" then return end
 title=string.sub(title,1,24)
 local target=Players:GetPlayerByUserId(targetUserId)
 if not target then return end
 target:SetAttribute("BBYACustomTitle",title)
 local char=target.Character;local head=char and char:FindFirstChild("Head")
 if head then
  local old=head:FindFirstChild("BBYACustomTitleTag");if old then old:Destroy() end
  local gui=Instance.new("BillboardGui");gui.Name="BBYACustomTitleTag";gui.Size=UDim2.fromOffset(180,34);gui.StudsOffset=Vector3.new(0,3.5,0);gui.MaxDistance=45;gui.Parent=head
  local lab=Instance.new("TextLabel");lab.BackgroundTransparency=1;lab.Size=UDim2.fromScale(1,1);lab.Font=Enum.Font.GothamBold;lab.Text=title;lab.TextColor3=Color3.fromRGB(255,180,235);lab.TextStrokeTransparency=.35;lab.TextScaled=true;lab.Parent=gui
 end
end)

TeleportRemote.OnServerEvent:Connect(function(player,spot)
 if typeof(spot)~="string" then return end
 local cf=teleportSpots[string.upper(spot)]
 if cf and player.Character then player.Character:PivotTo(cf) end
end)

FXRemote.OnServerEvent:Connect(function(player,kind)
 if kind~="glowstick" and kind~="confetti" then return end
 local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");if not root then return end
 if kind=="glowstick" then
  if player.Backpack:FindFirstChild("BBYA Glowstick") or char:FindFirstChild("BBYA Glowstick") then return end
  local tool=Instance.new("Tool");tool.Name="BBYA Glowstick";tool.RequiresHandle=true
  local h=Instance.new("Part");h.Name="Handle";h.Size=Vector3.new(.35,3,.35);h.Material=Enum.Material.Neon;h.Color=Color3.fromRGB(255,70,200);h.CanCollide=false;h.Parent=tool
  local light=Instance.new("PointLight");light.Range=10;light.Brightness=1;light.Color=h.Color;light.Parent=h
  tool.Parent=player.Backpack
 else
  for i=1,28 do
   local p=Instance.new("Part");p.Size=Vector3.new(.25,.25,.25);p.Material=Enum.Material.Neon;p.Color=Color3.fromHSV(math.random(),.8,1);p.CanCollide=false;p.CFrame=root.CFrame*CFrame.new(math.random(-4,4),math.random(2,7),math.random(-4,4));p.Parent=workspace;p.AssemblyLinearVelocity=Vector3.new(math.random(-10,10),math.random(10,22),math.random(-10,10));Debris:AddItem(p,2.5)
  end
 end
end)

Players.PlayerRemoving:Connect(function(p)lastEmote[p.UserId]=nil end)
print("[BBYA] v1.3 functional interaction server loaded")