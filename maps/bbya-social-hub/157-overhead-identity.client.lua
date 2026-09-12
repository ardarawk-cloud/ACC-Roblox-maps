-- BBYA SOCIAL HUB — OVERHEAD IDENTITY CLIENT FALLBACK v2
-- Client-resident fallback for the overhead name/role tag.
-- The server progression authority remains canonical for levels, roles and titles;
-- this renderer only guarantees that those replicated values are visibly rendered.

local Players=game:GetService("Players")

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

local function render(player)
 local character=player.Character
 local head=character and character:FindFirstChild("Head")
 if not head then return false end

 -- The older server tag can remain as a data-side fallback, but hide it on this
 -- client so two labels never stack on top of one another.
 local serverTag=head:FindFirstChild("BBYAIdentityTag")
 if serverTag and serverTag:IsA("BillboardGui") then serverTag.Enabled=false end

 local old=head:FindFirstChild("BBYAIdentityTagClient")
 if old then old:Destroy() end

 local role=effectiveRole(player)
 local level=tonumber(player:GetAttribute("BBYALevel")) or 1
 local rank=tostring(player:GetAttribute("BBYARank") or "NEWBIE")
 local statusText=role or string.format("LV %d • %s",level,rank)
 local statusColor=role and (ROLE_COLORS[role] or RANK_COLORS.NEWBBIE) or (RANK_COLORS[rank] or RANK_COLORS.NEWBIE)
 if not statusColor then statusColor=RANK_COLORS.NEWBIE end

 local custom=nil
 if player:GetAttribute("BBYACustomTitleEquipped")==true then
  local t=player:GetAttribute("BBYACustomTitle")
  if type(t)=="string" and t~="" then custom=t end
 end
 local customColor=parseHex(player:GetAttribute("BBYACustomTitleColorHex")) or Color3.fromRGB(245,245,247)

 local gui=Instance.new("BillboardGui")
 gui.Name="BBYAIdentityTagClient"
 gui.Adornee=head
 gui.Size=UDim2.fromOffset(240,custom and 68 or 52)
 gui.StudsOffset=Vector3.new(0,2.85,0)
 gui.AlwaysOnTop=true
 gui.LightInfluence=0
 gui.MaxDistance=140
 gui.Enabled=true
 gui.Parent=head

 local holder=Instance.new("Frame")
 holder.BackgroundTransparency=1
 holder.Size=UDim2.fromScale(1,1)
 holder.Parent=gui

 local name=Instance.new("TextLabel")
 name.BackgroundTransparency=1
 name.Position=UDim2.fromOffset(0,2)
 name.Size=UDim2.new(1,0,0,20)
 name.Text=player.DisplayName
 name.TextColor3=Color3.fromRGB(250,250,252)
 name.TextStrokeColor3=Color3.fromRGB(0,0,0)
 name.TextStrokeTransparency=.32
 name.Font=Enum.Font.GothamBold
 name.TextSize=14
 name.TextXAlignment=Enum.TextXAlignment.Center
 name.Parent=holder

 local status=Instance.new("TextLabel")
 status.BackgroundTransparency=1
 status.Position=UDim2.fromOffset(0,22)
 status.Size=UDim2.new(1,0,0,17)
 status.Text=statusText
 status.TextColor3=statusColor
 status.TextStrokeColor3=Color3.fromRGB(0,0,0)
 status.TextStrokeTransparency=.36
 status.Font=Enum.Font.GothamBold
 status.TextSize=11
 status.TextXAlignment=Enum.TextXAlignment.Center
 status.Parent=holder

 if custom then
  local title=Instance.new("TextLabel")
  title.BackgroundTransparency=1
  title.Position=UDim2.fromOffset(0,39)
  title.Size=UDim2.new(1,0,0,17)
  title.Text=custom
  title.TextColor3=customColor
  title.TextStrokeColor3=Color3.fromRGB(0,0,0)
  title.TextStrokeTransparency=.36
  title.Font=Enum.Font.GothamBold
  title.TextSize=11
  title.TextXAlignment=Enum.TextXAlignment.Center
  title.Parent=holder
 end

 return true
end

local function scheduleRender(player,character)
 task.spawn(function()
  if character then character:WaitForChild("Head",10) end
  for _,delaySeconds in ipairs({0,.25,1,2.5}) do
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
Players.PlayerRemoving:Connect(function(player)bound[player]=nil end)

-- Self-heal protects against avatar reloads and late server/UI cleanup passes.
task.spawn(function()
 while task.wait(2) do
  for _,player in ipairs(Players:GetPlayers()) do
   local character=player.Character
   local head=character and character:FindFirstChild("Head")
   local clientTag=head and head:FindFirstChild("BBYAIdentityTagClient")
   if head and (not clientTag or not clientTag:IsA("BillboardGui") or not clientTag.Enabled) then
    render(player)
   else
    local serverTag=head and head:FindFirstChild("BBYAIdentityTag")
    if serverTag and serverTag:IsA("BillboardGui") and serverTag.Enabled then serverTag.Enabled=false end
   end
  end
 end
end)

print("[BBYA] overhead identity client fallback v2 online")
