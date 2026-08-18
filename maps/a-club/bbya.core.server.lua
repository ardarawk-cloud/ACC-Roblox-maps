-- BBYA SOCIAL HUB — CLEAN FUNCTIONAL CORE v3.0
-- Persistence / level / leaderstats / title tags only.
-- IMPORTANT: this core NEVER builds venue geometry or duplicate interaction systems.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local QUEEN_USER_ID = 4271188557
local profileStore = DataStoreService:GetDataStore("BBYA_Profile_v1")
local profiles = {}

local function defaultProfile()
 return {Level=1, XP=0, Likes=0, Donated=0, HasLiked=false}
end

local function rankFor(player, profile)
 if player.UserId == QUEEN_USER_ID then return "♛ BBYA QUEEN" end
 local level = profile.Level or 1
 local donated = player:GetAttribute("TotalDonated") or profile.Donated or 0
 if level >= 25 and donated >= 1000 then return "ROYAL ELITE" end
 if level >= 15 and donated >= 500 then return "NIGHT ARISTOCRAT" end
 if level >= 8 and donated >= 100 then return "ARISTOCRAT" end
 if level >= 20 then return "NIGHT ICON" end
 if level >= 8 then return "SOCIALITE" end
 if level >= 3 then return "REGULAR" end
 return "NEWBIE"
end

local function applyTitle(player, character)
 local head = character:FindFirstChild("Head") or character:WaitForChild("Head",10)
 if not head then return end
 local old = head:FindFirstChild("BBYATitleTag")
 if old then old:Destroy() end

 local profile = profiles[player.UserId] or defaultProfile()
 local gui = Instance.new("BillboardGui")
 gui.Name = "BBYATitleTag"
 gui.Size = UDim2.fromOffset(94,18)
 gui.StudsOffset = Vector3.new(0,2.65,0)
 gui.MaxDistance = 30
 gui.AlwaysOnTop = false
 gui.Parent = head

 local label = Instance.new("TextLabel")
 label.BackgroundTransparency = 1
 label.Size = UDim2.fromScale(1,1)
 label.Text = rankFor(player,profile)
 label.TextColor3 = player.UserId == QUEEN_USER_ID and Color3.fromRGB(255,215,90) or Color3.fromRGB(255,135,225)
 label.TextStrokeTransparency = .45
 label.Font = Enum.Font.GothamBold
 label.TextSize = 10
 label.TextScaled = false
 label.Parent = gui
end

local function save(player)
 local profile = profiles[player.UserId]
 if not profile then return end
 profile.Donated = player:GetAttribute("TotalDonated") or profile.Donated or 0
 profile.Level = player:GetAttribute("BBYALevel") or profile.Level or 1
 pcall(function()
  profileStore:SetAsync("u"..player.UserId,profile)
 end)
end

local function setup(player)
 if profiles[player.UserId] then return end
 local profile = defaultProfile()
 pcall(function()
  local saved = profileStore:GetAsync("u"..player.UserId)
  if type(saved)=="table" then
   for k,v in pairs(saved) do profile[k]=v end
  end
 end)
 profiles[player.UserId]=profile

 local queen = player.UserId == QUEEN_USER_ID
 player:SetAttribute("BBYAQueen",queen)
 if queen then
  player:SetAttribute("BBYARole","BBYA_QUEEN")
  player:SetAttribute("BBYAAllAccess",true)
  player:SetAttribute("IsVIP",true)
 elseif not player:GetAttribute("BBYARole") then
  player:SetAttribute("BBYARole","GUEST")
 end

 player:SetAttribute("BBYALevel",profile.Level or 1)
 player:SetAttribute("BBYALikes",profile.Likes or 0)

 local oldStats = player:FindFirstChild("leaderstats")
 if oldStats then oldStats:Destroy() end
 local stats = Instance.new("Folder")
 stats.Name="leaderstats"
 stats.Parent=player
 local level = Instance.new("IntValue");level.Name="Level";level.Value=profile.Level or 1;level.Parent=stats
 local likes = Instance.new("IntValue");likes.Name="Likes";likes.Value=profile.Likes or 0;likes.Parent=stats
 local donated = Instance.new("IntValue");donated.Name="Donated";donated.Value=player:GetAttribute("TotalDonated") or profile.Donated or 0;donated.Parent=stats

 local function refreshTitle()
  if player.Character then applyTitle(player,player.Character) end
 end
 player.CharacterAdded:Connect(function(character) task.wait(.8);applyTitle(player,character) end)
 if player.Character then task.defer(applyTitle,player,player.Character) end

 player:GetAttributeChangedSignal("TotalDonated"):Connect(function()
  donated.Value = player:GetAttribute("TotalDonated") or 0
  profile.Donated = donated.Value
  refreshTitle()
 end)

 player:GetAttributeChangedSignal("BBYALevel"):Connect(function()
  local value=player:GetAttribute("BBYALevel") or 1
  profile.Level=value
  level.Value=value
  refreshTitle()
 end)

 -- Social activity progression: one XP minute while present, five XP per level.
 task.spawn(function()
  while player.Parent do
   task.wait(60)
   if not player.Parent then break end
   profile.XP=(profile.XP or 0)+1
   local newLevel=math.floor(profile.XP/5)+1
   if newLevel ~= (profile.Level or 1) then
    profile.Level=newLevel
    player:SetAttribute("BBYALevel",newLevel)
   end
  end
 end)
end

Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player)
 save(player)
 profiles[player.UserId]=nil
end)
for _,player in ipairs(Players:GetPlayers()) do setup(player) end

game:BindToClose(function()
 for _,player in ipairs(Players:GetPlayers()) do save(player) end
end)

workspace:SetAttribute("BBYACleanCore","3.0")
print("[BBYA] Clean Functional Core v3.0 loaded — no legacy visual builder")
