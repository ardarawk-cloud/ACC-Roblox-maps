-- BBYA SOCIAL HUB — FUNCTIONAL SYSTEMS v2.0
-- Premium-build-safe interaction backend. Navigation resolves live map anchors instead of legacy coordinates.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

local QUEEN_ID = 4271188557

local remotes = ReplicatedStorage:FindFirstChild("BBYA_Remotes") or Instance.new("Folder")
remotes.Name = "BBYA_Remotes"
remotes.Parent = ReplicatedStorage

local function remote(name)
 local r = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
 r.Name = name
 r.Parent = remotes
 return r
end

local DanceRemote = remote("Dance")
local SyncRemote = remote("SyncDance")
local TitleRemote = remote("SetTitle")
local FXRemote = remote("FX")
local TeleportRemote = remote("Teleport")
local AdminRemote = remote("QueenAdmin")
local NoticeRemote = remote("Notice")
local FeedbackRemote = remote("Feedback")

local lastEmote = {}
local cooldown = {}
local allowed = {dance=true,dance2=true,dance3=true,wave=true,cheer=true,laugh=true,point=true}

local function ready(player, key, seconds)
 local id = player.UserId .. ":" .. key
 local now = os.clock()
 if cooldown[id] and now - cooldown[id] < seconds then return false end
 cooldown[id] = now
 return true
end

local function feedback(player, text)
 FeedbackRemote:FireClient(player, text)
end

local function isQueen(player)
 return player and player.UserId == QUEEN_ID
end

local function isVIP(player)
 return player and (player:GetAttribute("IsVIP") == true or player:GetAttribute("BBYAAllAccess") == true or isQueen(player))
end

local function play(player, name)
 local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if not humanoid then return false end
 if name == "stop" then
  for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do track:Stop(.15) end
  lastEmote[player.UserId] = nil
  return true
 end
 if not allowed[name] then return false end
 lastEmote[player.UserId] = name
 return pcall(function() humanoid:PlayEmote(name) end)
end

DanceRemote.OnServerEvent:Connect(function(player, name)
 if typeof(name) ~= "string" or not ready(player,"dance",.15) then return end
 name = string.lower(name)
 if play(player,name) then
  feedback(player,name=="stop" and "Dance stopped" or ("Playing "..string.upper(name)))
 else
  feedback(player,"Emote unavailable on this avatar")
 end
end)

SyncRemote.OnServerEvent:Connect(function(player, userId)
 if typeof(userId) ~= "number" or not ready(player,"sync",.6) then return end
 local target = Players:GetPlayerByUserId(userId)
 local a = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local b = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
 if not a or not b or (a.Position-b.Position).Magnitude > 35 then
  feedback(player,"No dancer nearby")
  return
 end
 local name = lastEmote[target.UserId]
 if name and play(player,name) then feedback(player,"Synced with "..target.DisplayName)
 else feedback(player,"That player is not dancing") end
end)

-- Premium navigation ---------------------------------------------------------
local function anchor(name)
 return workspace:FindFirstChild(name, true)
end

local function targetFrom(name, localOffset)
 local a = anchor(name)
 if not a or not a:IsA("BasePart") then return nil end
 return a.CFrame * (localOffset or CFrame.new(0,4,0))
end

local function resolveSpot(code)
 code = string.upper(code)
 if code == "DANCE" then return targetFrom("Dance Floor", CFrame.new(0,4,0)) end
 if code == "VIP" then return targetFrom("Left VIP Platform", CFrame.new(0,4,4)) end
 if code == "BAR" then return targetFrom("BBYA Bar", CFrame.new(0,4,-8)) end
 if code == "PHOTO" then
  local a = anchor("Photo Wall")
  return a and a:IsA("BasePart") and (a.CFrame * CFrame.new(0,-a.Size.Y/2+2,-8)) or nil
 end
 if code == "CHILL" then return targetFrom("Chill Table", CFrame.new(0,3,8)) end
 if code == "DJ" then return targetFrom("DJ Booth", CFrame.new(0,4,10)) end
 if code == "POOL" or code == "ROOFTOP" then return targetFrom("Rooftop Pool", CFrame.new(0,4,24)) end
 if code == "SUPPORT" then
  local a = anchor("Support Celebration Screen")
  return a and a:IsA("BasePart") and (a.CFrame * CFrame.new(0,-10,8)) or targetFrom("BBYA Bar",CFrame.new(0,4,-8))
 end
 if code == "QUEEN" then return targetFrom("Queen Skybox Floor", CFrame.new(0,4,0)) end
 -- Legacy SALON button is intentionally redirected into the active social zone.
 if code == "SALON" then return targetFrom("Chill Table", CFrame.new(0,3,8)) end
 return nil
end

TeleportRemote.OnServerEvent:Connect(function(player, spot)
 if typeof(spot) ~= "string" or not ready(player,"tp",.35) then return end
 local code = string.upper(spot)
 if code == "QUEEN" and not (isQueen(player) or player:GetAttribute("BBYAAllAccess") == true) then
  feedback(player,"Queen Skybox is private")
  return
 end
 if code == "VIP" and workspace:GetAttribute("BBYAMonetizationConfigured") == true and not isVIP(player) then
  feedback(player,"VIP access required • open VIP / SAWER panel")
  return
 end
 local cf = resolveSpot(code)
 if cf and player.Character then
  player.Character:PivotTo(cf)
  feedback(player,"Moved to "..code)
 else
  feedback(player,"Area unavailable")
 end
end)

FXRemote.OnServerEvent:Connect(function(player, kind)
 if (kind~="glowstick" and kind~="confetti") or not ready(player,"fx",kind=="confetti" and 3 or .6) then return end
 local char = player.Character
 local root = char and char:FindFirstChild("HumanoidRootPart")
 if not root then return end
 if kind == "glowstick" then
  local existing = player.Backpack:FindFirstChild("BBYA Glowstick") or char:FindFirstChild("BBYA Glowstick")
  if existing then existing:Destroy(); feedback(player,"Glowstick removed"); return end
  local tool = Instance.new("Tool")
  tool.Name = "BBYA Glowstick"
  tool.RequiresHandle = true
  local handle = Instance.new("Part")
  handle.Name = "Handle"
  handle.Size = Vector3.new(.35,3,.35)
  handle.Material = Enum.Material.Neon
  handle.Color = Color3.fromRGB(255,70,200)
  handle.CanCollide = false
  handle.Parent = tool
  local light = Instance.new("PointLight")
  light.Range=10; light.Brightness=1; light.Color=handle.Color; light.Parent=handle
  tool.Parent = player.Backpack
  feedback(player,"Glowstick equipped")
 else
  for _=1,20 do
   local q=Instance.new("Part")
   q.Size=Vector3.new(.25,.25,.25)
   q.Material=Enum.Material.Neon
   q.Color=Color3.fromHSV(math.random(),.8,1)
   q.CanCollide=false
   q.CFrame=root.CFrame*CFrame.new(math.random(-4,4),math.random(2,7),math.random(-4,4))
   q.Parent=workspace
   q.AssemblyLinearVelocity=Vector3.new(math.random(-10,10),math.random(10,22),math.random(-10,10))
   Debris:AddItem(q,2.5)
  end
  feedback(player,"Confetti!")
 end
end)

TitleRemote.OnServerEvent:Connect(function(player,userId,title)
 if not isQueen(player) or typeof(userId)~="number" or typeof(title)~="string" then return end
 title=string.sub(title:gsub("[%c]",""),1,24)
 local target=Players:GetPlayerByUserId(userId)
 if not target then return end
 target:SetAttribute("BBYACustomTitle",title)
 local head=target.Character and target.Character:FindFirstChild("Head")
 if not head then return end
 local old=head:FindFirstChild("BBYACustomTitleTag")
 if old then old:Destroy() end
 if title=="" then return end
 local g=Instance.new("BillboardGui")
 g.Name="BBYACustomTitleTag";g.Size=UDim2.fromOffset(180,34);g.StudsOffset=Vector3.new(0,3.5,0);g.MaxDistance=45;g.Parent=head
 local lab=Instance.new("TextLabel")
 lab.BackgroundTransparency=1;lab.Size=UDim2.fromScale(1,1);lab.Font=Enum.Font.GothamBold;lab.Text=title;lab.TextColor3=Color3.fromRGB(255,180,235);lab.TextScaled=true;lab.Parent=g
end)

local function announce(text)
 text=string.sub(tostring(text or""):gsub("[%c]"," "),1,120)
 if text~="" then NoticeRemote:FireAllClients(text) end
end

AdminRemote.OnServerEvent:Connect(function(player,action,value)
 if not isQueen(player) or not ready(player,"admin",.25) then return end
 action=string.lower(tostring(action or""))
 if action=="announce" then announce(value)
 elseif action=="party" then workspace:SetAttribute("BBYAPartyMode",true);Lighting.ClockTime=22;announce("BBYA PARTY MODE ON")
 elseif action=="normal" then workspace:SetAttribute("BBYAPartyMode",false);Lighting.ClockTime=23.2;announce("BBYA normal mode")
 else
  local uid=tonumber(value)
  local target=uid and Players:GetPlayerByUserId(uid)
  if action=="kick" and target and target~=player then target:Kick("Removed by BBYA Queen")
  elseif action=="bring" and target and target.Character and player.Character then target.Character:PivotTo(player.Character:GetPivot()*CFrame.new(3,0,0))
  elseif action=="goto" and target and target.Character and player.Character then player.Character:PivotTo(target.Character:GetPivot()*CFrame.new(3,0,0))
  elseif action=="speed" then local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=math.clamp(tonumber(value) or 32,16,80) end
  elseif action=="speednormal" then local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid");if h then h.WalkSpeed=16 end end
 end
end)

local function tag(player)
 player:SetAttribute("BBYAQueen",isQueen(player))
 if isQueen(player) then
  player:SetAttribute("BBYARole","BBYA_QUEEN")
  player:SetAttribute("BBYAAllAccess",true)
  player:SetAttribute("IsVIP",true)
 elseif not player:GetAttribute("BBYARole") then
  player:SetAttribute("BBYARole","GUEST")
 end
end
Players.PlayerAdded:Connect(tag)
for _,player in ipairs(Players:GetPlayers()) do tag(player) end

workspace:SetAttribute("BBYAFunctionalSystems","2.0")
print("[BBYA] Functional Systems v2.0 loaded — premium anchor navigation active")
