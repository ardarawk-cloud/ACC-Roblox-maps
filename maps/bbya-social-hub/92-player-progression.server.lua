-- BBYA SOCIAL HUB — PLAYER PROGRESSION + IDENTITY v2
-- Persistent social level based on time spent in BBYA. Queen BBYA overrides visitor rank display.
local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")

local store=DataStoreService:GetDataStore("BBYA_SOCIAL_LEVEL_V1")
local QUEEN_USERNAME="nadmo97"
local LEVEL_MINUTES=10
local sessionMinutes={}
local loadedMinutes={}

local COLORS={
 Newbie=Color3.fromRGB(245,245,247),
 Regular=Color3.fromRGB(247,55,158),
 Socialite=Color3.fromRGB(59,157,255),
 Aristokrat=Color3.fromRGB(73,214,129),
 Monarch=Color3.fromRGB(235,184,74),
 GreatMonarch=Color3.fromRGB(255,205,82),
 Queen=Color3.fromRGB(255,113,196),
}

local function rankFor(level)
 if level>=50 then return "GREAT MONARCH",COLORS.GreatMonarch,true end
 if level>=40 then return "MONARCH",COLORS.Monarch,false end
 if level>=30 then return "ARISTOKRAT",COLORS.Aristokrat,false end
 if level>=20 then return "SOCIALITE",COLORS.Socialite,false end
 if level>=10 then return "REGULAR",COLORS.Regular,false end
 return "NEWBIE",COLORS.Newbie,false
end

local function isQueen(player)
 return player and string.lower(player.Name)==QUEEN_USERNAME
end

local function levelFromMinutes(minutes)
 return math.max(1,math.floor(math.max(0,minutes)/LEVEL_MINUTES)+1)
end

local function clearTag(character)
 local head=character and character:FindFirstChild("Head")
 local old=head and head:FindFirstChild("BBYAIdentityTag")
 if old then old:Destroy() end
end

local function makeTag(player)
 local character=player.Character
 local head=character and character:FindFirstChild("Head")
 if not head then return end
 clearTag(character)

 local level=player:GetAttribute("BBYALevel") or 1
 local rank,color,crown=rankFor(level)
 local queen=isQueen(player)
 if queen then rank="QUEEN BBYA";color=COLORS.Queen;crown=true end

 local gui=Instance.new("BillboardGui")
 gui.Name="BBYAIdentityTag"
 gui.Adornee=head
 gui.Size=UDim2.fromOffset(220,54)
 gui.StudsOffset=Vector3.new(0,2.75,0)
 gui.AlwaysOnTop=true
 gui.MaxDistance=72
 gui.LightInfluence=0
 gui.Parent=head

 local holder=Instance.new("Frame")
 holder.Size=UDim2.fromScale(1,1)
 holder.BackgroundTransparency=1
 holder.Parent=gui

 if crown then
  local c=Instance.new("TextLabel")
  c.Name="Crown"
  c.BackgroundTransparency=1
  c.Position=UDim2.fromOffset(0,-4)
  c.Size=UDim2.new(1,0,0,20)
  c.Text=queen and "♕" or "♛"
  c.TextColor3=queen and Color3.fromRGB(255,190,225) or Color3.fromRGB(255,208,84)
  c.TextStrokeTransparency=.35
  c.Font=Enum.Font.GothamBlack
  c.TextSize=18
  c.Parent=holder
 end

 local name=Instance.new("TextLabel")
 name.BackgroundTransparency=1
 name.Position=UDim2.fromOffset(0,crown and 13 or 5)
 name.Size=UDim2.new(1,0,0,18)
 name.Text=player.DisplayName
 name.TextColor3=Color3.fromRGB(248,248,250)
 name.TextStrokeTransparency=.45
 name.Font=Enum.Font.GothamSemibold
 name.TextSize=13
 name.Parent=holder

 local title=Instance.new("TextLabel")
 title.BackgroundTransparency=1
 title.Position=UDim2.fromOffset(0,crown and 30 or 22)
 title.Size=UDim2.new(1,0,0,16)
 title.Text=queen and "QUEEN BBYA • OWNER" or string.format("LV %d • %s",level,rank)
 title.TextColor3=color
 title.TextStrokeTransparency=.45
 title.Font=Enum.Font.GothamBold
 title.TextSize=11
 title.Parent=holder
end

local function applyIdentity(player)
 local total=(loadedMinutes[player.UserId] or 0)+(sessionMinutes[player.UserId] or 0)
 local level=levelFromMinutes(total)
 player:SetAttribute("BBYALevel",level)
 local rank=select(1,rankFor(level))
 player:SetAttribute("BBYARank",rank)
 if isQueen(player) then
  player:SetAttribute("BBYAAdmin",true)
  player:SetAttribute("BBYAOwner",true)
  -- Legacy compatibility only: older systems may still read BBYACoOwner.
  player:SetAttribute("BBYACoOwner",true)
  player:SetAttribute("BBYAQueen",true)
  player:SetAttribute("BBYAVIPBypass",true)
  player:SetAttribute("BBYARooftopBypass",true)
  player:SetAttribute("BBYASecretRoomBypass",true)
  player:SetAttribute("BBYATravelBypass",true)
 end
 makeTag(player)
end

local function loadPlayer(player)
 local value=0
 local ok,data=pcall(function()return store:GetAsync("u_"..player.UserId)end)
 if ok and type(data)=="number" then value=math.max(0,math.floor(data)) end
 loadedMinutes[player.UserId]=value
 sessionMinutes[player.UserId]=0
 applyIdentity(player)
 player.CharacterAdded:Connect(function(char)
  char:WaitForChild("Head",10)
  task.wait(.4)
  applyIdentity(player)
 end)
end

local function savePlayer(player)
 local uid=player.UserId
 local total=(loadedMinutes[uid] or 0)+(sessionMinutes[uid] or 0)
 pcall(function()store:SetAsync("u_"..uid,total)end)
 loadedMinutes[uid]=total
 sessionMinutes[uid]=0
end

for _,p in ipairs(Players:GetPlayers()) do task.spawn(loadPlayer,p) end
Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(function(p)savePlayer(p);loadedMinutes[p.UserId]=nil;sessionMinutes[p.UserId]=nil end)

task.spawn(function()
 while task.wait(60) do
  for _,p in ipairs(Players:GetPlayers()) do
   sessionMinutes[p.UserId]=(sessionMinutes[p.UserId] or 0)+1
   applyIdentity(p)
   if sessionMinutes[p.UserId]%5==0 then task.spawn(savePlayer,p) end
  end
 end
end)

game:BindToClose(function()
 for _,p in ipairs(Players:GetPlayers()) do savePlayer(p) end
end)

print("[BBYA] Player progression v2 online: Queen BBYA OWNER + persistent visitor levels")
