-- BBYA SOCIAL HUB — OVERHEAD IDENTITY CLIENT v3
-- Reliable client-side overhead identity authority.
-- BillboardGuis live in PlayerGui (not inside character descendants), so late character cleanup passes
-- cannot remove the visible name/role label. Server progression remains canonical for role/level/title data.

local Players=game:GetService("Players")
local localPlayer=Players.LocalPlayer
local playerGui=localPlayer:WaitForChild("PlayerGui")

local ROLE_COLORS={
 OWNER=Color3.fromRGB(255,113,196),
 ["CO OWNER"]=Color3.fromRGB(255,151,78),
 ADMIN=Color3.fromRGB(73,207,235),
 MODERATOR=Color3.fromRGB(116,222,173),
 CREW=Color3.fromRGB(103,230,174),
 VIP=Color3.fromRGB(235,184,74),
 DJ=Color3.fromRGB(174,104,255),
 LEAD=Color3.fromRGB(255,98,87),
 MEDIA=Color3.fromRGB(69,172,255),
}

local RANK_COLORS={
 NEWBIE=Color3.fromRGB(245,245,247),
 REGULAR=Color3.fromRGB(247,55,158),
 SOCIALITE=Color3.fromRGB(59,157,255),
 ARISTOKRAT=Color3.fromRGB(73,214,129),
 MONARCH=Color3.fromRGB(235,184,74),
 ["GREAT MONARCH"]=Color3.fromRGB(255,205,82),
}

local watchedAttributes={
 "BBYALevel","BBYARank","BBYAManagedRole","BBYAOwner","BBYACoOwner","BBYAAdmin","BBYAModerator",
 "BBYACustomTitle","BBYACustomTitleColorHex","BBYACustomTitleEquipped",
}

local bound={}

local function guiName(player)
 return "BBYAOverhead_"..tostring(player.UserId)
end

local function parseHex(value)
 local s=string.upper(tostring(value or "")):gsub("%s+","")
 if not s:match("^#%x%x%x%x%x%x$") then return nil end
 return Color3.fromRGB(tonumber(s:sub(2,3),16),tonumber(s:sub(4,5),16),tonumber(s:sub(6,7),16))
end

local function effectiveRole(player)
 if player:GetAttribute("BBYAOwner")==true then return "OWNER" end
 if player:GetAttribute("BBYACoOwner")==true then return "CO OWNER" end
 if player:GetAttribute("BBYAAdmin")==true then return "ADMIN" end
 if player:GetAttribute("BBYAModerator")==true then return "MODERATOR" end
 local role=player:GetAttribute("BBYAManagedRole")
 if type(role)=="string" and role~="" and role~="NONE" then
  if role=="COOWNER" then return "CO OWNER" end
  return role
 end
 return nil
end

local function removeGui(player)
 local old=playerGui:FindFirstChild(guiName(player))
 if old then old:Destroy() end
end

local function buildGui(player,head)
 removeGui(player)

 local role=effectiveRole(player)
 local level=tonumber(player:GetAttribute("BBYALevel")) or 1
 local rank=tostring(player:GetAttribute("BBYARank") or "NEWBIE")
 local statusText=role or string.format("LV %d • %s",level,rank)
 local statusColor=role and (ROLE_COLORS[role] or RANK_COLORS.NEWBIE) or (RANK_COLORS[rank] or RANK_COLORS.NEWBIE)

 local custom=nil
 if player:GetAttribute("BBYACustomTitleEquipped")==true then
  local value=player:GetAttribute("BBYACustomTitle")
  if type(value)=="string" and value~="" then custom=value end
 end
 local customColor=parseHex(player:GetAttribute("BBYACustomTitleColorHex")) or Color3.fromRGB(245,245,247)

 local gui=Instance.new("BillboardGui")
 gui.Name=guiName(player)
 gui.Adornee=head
 gui.Size=UDim2.fromOffset(250,custom and 70 or 54)
 gui.StudsOffset=Vector3.new(0,2.95,0)
 gui.AlwaysOnTop=true
 gui.LightInfluence=0
 gui.MaxDistance=150
 gui.Enabled=true
 gui.ResetOnSpawn=false
 gui.Parent=playerGui

 local holder=Instance.new("Frame")
 holder.BackgroundTransparency=1
 holder.Size=UDim2.fromScale(1,1)
 holder.Parent=gui

 local nameLabel=Instance.new("TextLabel")
 nameLabel.Name="DisplayName"
 nameLabel.BackgroundTransparency=1
 nameLabel.Position=UDim2.fromOffset(0,1)
 nameLabel.Size=UDim2.new(1,0,0,21)
 nameLabel.Text=player.DisplayName
 nameLabel.TextColor3=Color3.fromRGB(250,250,252)
 nameLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
 nameLabel.TextStrokeTransparency=.22
 nameLabel.Font=Enum.Font.GothamBold
 nameLabel.TextSize=15
 nameLabel.TextXAlignment=Enum.TextXAlignment.Center
 nameLabel.Parent=holder

 local status=Instance.new("TextLabel")
 status.Name="Status"
 status.BackgroundTransparency=1
 status.Position=UDim2.fromOffset(0,22)
 status.Size=UDim2.new(1,0,0,18)
 status.Text=statusText
 status.TextColor3=statusColor
 status.TextStrokeColor3=Color3.fromRGB(0,0,0)
 status.TextStrokeTransparency=.30
 status.Font=Enum.Font.GothamBold
 status.TextSize=11
 status.TextXAlignment=Enum.TextXAlignment.Center
 status.Parent=holder

 if custom then
  local title=Instance.new("TextLabel")
  title.Name="CustomTitle"
  title.BackgroundTransparency=1
  title.Position=UDim2.fromOffset(0,40)
  title.Size=UDim2.new(1,0,0,18)
  title.Text=custom
  title.TextColor3=customColor
  title.TextStrokeColor3=Color3.fromRGB(0,0,0)
  title.TextStrokeTransparency=.30
  title.Font=Enum.Font.GothamBold
  title.TextSize=11
  title.TextXAlignment=Enum.TextXAlignment.Center
  title.Parent=holder
 end

 return gui
end

local function render(player)
 if not player or player.Parent~=Players then return false end
 local character=player.Character
 local head=character and character:FindFirstChild("Head")
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 if not head or not humanoid then return false end

 -- Avoid stacked Roblox/server nameplates. v3 is the visible client authority.
 pcall(function()
  humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
 end)
 local serverTag=head:FindFirstChild("BBYAIdentityTag")
 if serverTag and serverTag:IsA("BillboardGui") then serverTag.Enabled=false end

 local gui=playerGui:FindFirstChild(guiName(player))
 if not gui or not gui:IsA("BillboardGui") or gui.Adornee~=head then
  gui=buildGui(player,head)
 else
  gui.Enabled=true
  local holder=gui:FindFirstChildOfClass("Frame")
  local nameLabel=holder and holder:FindFirstChild("DisplayName")
  local status=holder and holder:FindFirstChild("Status")
  if nameLabel and nameLabel:IsA("TextLabel") then nameLabel.Text=player.DisplayName end
  if status and status:IsA("TextLabel") then
   local role=effectiveRole(player)
   local level=tonumber(player:GetAttribute("BBYALevel")) or 1
   local rank=tostring(player:GetAttribute("BBYARank") or "NEWBIE")
   status.Text=role or string.format("LV %d • %s",level,rank)
   status.TextColor3=role and (ROLE_COLORS[role] or RANK_COLORS.NEWBIE) or (RANK_COLORS[rank] or RANK_COLORS.NEWBIE)
  end
  -- Title presence can change the layout; rebuild when title equip state changes.
  local shouldHaveTitle=player:GetAttribute("BBYACustomTitleEquipped")==true and type(player:GetAttribute("BBYACustomTitle"))=="string" and player:GetAttribute("BBYACustomTitle")~=""
  local hasTitle=holder and holder:FindFirstChild("CustomTitle")~=nil
  if shouldHaveTitle~=hasTitle then gui=buildGui(player,head) end
 end
 return true
end

local function scheduleRender(player,character)
 task.spawn(function()
  if character then
   character:WaitForChild("Humanoid",10)
   character:WaitForChild("Head",10)
  end
  for _,delaySeconds in ipairs({0,.15,.5,1.5,3}) do
   if delaySeconds>0 then task.wait(delaySeconds) end
   if not player.Parent then return end
   if character and player.Character~=character then return end
   if render(player) then return end
  end
 end)
end

local function bind(player)
 if bound[player] then return end
 bound[player]=true
 player.CharacterAdded:Connect(function(character)scheduleRender(player,character)end)
 player.CharacterAppearanceLoaded:Connect(function(character)scheduleRender(player,character)end)
 player:GetPropertyChangedSignal("DisplayName"):Connect(function()task.defer(render,player)end)
 for _,attribute in ipairs(watchedAttributes) do
  player:GetAttributeChangedSignal(attribute):Connect(function()task.defer(render,player)end)
 end
 if player.Character then scheduleRender(player,player.Character) end
end

for _,player in ipairs(Players:GetPlayers()) do bind(player) end
Players.PlayerAdded:Connect(bind)
Players.PlayerRemoving:Connect(function(player)
 bound[player]=nil
 removeGui(player)
end)

-- Self-heal continuously: late avatar swaps, character cleaners, and server-tag rebuilds cannot blank the overhead name.
task.spawn(function()
 while task.wait(1.5) do
  for _,player in ipairs(Players:GetPlayers()) do
   render(player)
  end
 end
end)

print("[BBYA] overhead identity v3 online: PlayerGui-resident self-healing avatar names")
