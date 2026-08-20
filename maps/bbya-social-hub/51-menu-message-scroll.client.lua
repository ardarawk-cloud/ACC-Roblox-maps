-- BBYA SOCIAL HUB — MENU MESSAGE + SUPPORT SCROLL PATCH v1.2
-- Adds DJ Message to the persistent top dock, keeps Community inside the same dock,
-- and makes Support genuinely swipeable on touch devices.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local clubUI=pg:WaitForChild("BBYAClubUI",20)
local wallUI=pg:WaitForChild("BBYADJWallUI",20)
if not clubUI or not wallUI then return end

local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes")
local wallRemote=remotes:WaitForChild("DJWall")

local dock=clubUI:FindFirstChild("TopDock",true)
local supportScroller=clubUI:FindFirstChild("SupportScroller",true)
if not dock then return end

local function round(o,r)
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o
end
local function stroke(o,col,t,tr)
 local s=Instance.new("UIStroke");s.Color=col;s.Thickness=t or 1;s.Transparency=tr or .45;s.Parent=o
end
local function findDockButton(word)
 word=word:upper()
 for _,obj in ipairs(dock:GetChildren()) do
  if obj:IsA("TextButton") and tostring(obj.Text):upper():find(word,1,true) then return obj end
 end
end
local brand=findDockButton("BBYA")
local music=findDockButton("MUSIC")
local support=findDockButton("SUPPORT")
local travel=findDockButton("TRAVEL")

local message=dock:FindFirstChild("MessageTab")
if not message then
 message=Instance.new("TextButton")
 message.Name="MessageTab"
 message.Text="MESSAGE"
 message.BackgroundColor3=Color3.fromRGB(46,23,42)
 message.TextColor3=Color3.fromRGB(244,243,247)
 message.Font=Enum.Font.GothamSemibold
 message.TextSize=12
 message.BorderSizePixel=0
 message.AutoButtonColor=true
 message.Parent=dock
 round(message,9)
 stroke(message,Color3.fromRGB(247,55,158),1,.48)
end

for _,obj in ipairs(dock:GetChildren()) do
 if obj:IsA("Frame") then
  for _,d in ipairs(obj:GetDescendants()) do
   if d:IsA("TextLabel") and tostring(d.Text):upper():find("CLUB LIVE",1,true) then obj.Visible=false end
  end
 end
end

local wallShade
local wallPanel
for _,obj in ipairs(wallUI:GetChildren()) do
 if obj:IsA("Frame") then
  if obj.Size.X.Scale==1 and obj.Size.Y.Scale==1 then wallShade=obj
  elseif obj.Size.X.Offset>=300 then wallPanel=obj end
 end
end
local wallConfig={price=2,admin=false}
local waitingOpen=false

local function refreshComposerLabels()
 if not wallPanel then return end
 for _,obj in ipairs(wallPanel:GetDescendants()) do
  if obj:IsA("TextLabel") and tostring(obj.Text):find("ROBUX",1,true) then
   obj.Text=wallConfig.admin and "OWNER TEST" or tostring(wallConfig.price or 2).." ROBUX"
  elseif obj:IsA("TextButton") and tostring(obj.Text):find("DJ WALL",1,true) then
   obj.Text=wallConfig.admin and "TEST ON DJ WALL  •  FREE" or "SEND TO DJ WALL  •  "..tostring(wallConfig.price or 2).." R$"
  end
 end
end
local function openComposer()
 if not wallPanel then return end
 refreshComposerLabels()
 if wallShade then wallShade.Visible=true end
 wallPanel.Visible=true
 wallPanel.Position=UDim2.fromScale(.5,.53)
 message.BackgroundColor3=Color3.fromRGB(102,25,73)
end

wallRemote.OnClientEvent:Connect(function(action,data)
 if action=="config" and type(data)=="table" then
  wallConfig=data
  refreshComposerLabels()
  if waitingOpen then waitingOpen=false;openComposer() end
 end
end)
message.MouseButton1Click:Connect(function()
 waitingOpen=true
 wallRemote:FireServer("config")
 task.delay(.18,function()
  if waitingOpen then waitingOpen=false;openComposer() end
 end)
end)

local function layoutDock()
 local vp=camera.ViewportSize
 local community=dock:FindFirstChild("CommunityTab")
 local hasCommunity=community and community:IsA("TextButton")
 local w=math.clamp(vp.X-16,360,hasCommunity and 940 or 840)
 dock.Size=UDim2.fromOffset(w,52)
 local pad=6
 local gap=4
 local brandW=math.clamp(w*.115,46,76)
 local actionCount=hasCommunity and 5 or 4
 local rest=(w-pad*2-brandW-gap*actionCount)/actionCount
 local x=pad
 local function place(btn,width)
  if not btn then return end
  btn.Position=UDim2.fromOffset(x,6)
  btn.Size=UDim2.fromOffset(width,40)
  x+=width+gap
 end
 place(brand,brandW)
 place(music,rest)
 place(support,rest)
 place(travel,rest)
 place(message,rest)
 if hasCommunity then place(community,rest) end

 local compact=vp.X<760
 if music then music.Text=compact and "MUSIC" or "♫  MUSIC";music.TextSize=compact and 9 or 12 end
 if support then support.Text=compact and "SUPPORT" or "◇  SUPPORT";support.TextSize=compact and 9 or 12 end
 if travel then travel.Text=compact and "TRAVEL" or "⌖  TRAVEL";travel.TextSize=compact and 9 or 12 end
 message.Text=compact and "MESSAGE" or "✦  MESSAGE"
 message.TextSize=compact and 8 or 12
 if hasCommunity then
  community.Text=compact and "COMM" or "◆  COMMUNITY"
  community.TextSize=compact and 8 or 11
 end
end

local function fixSupportScroll()
 if not supportScroller then return end
 local grid=supportScroller:FindFirstChildWhichIsA("UIGridLayout")
 if not grid then return end
 supportScroller.Active=true
 supportScroller.ScrollingEnabled=true
 supportScroller.ScrollingDirection=Enum.ScrollingDirection.Y
 supportScroller.ElasticBehavior=Enum.ElasticBehavior.Always
 supportScroller.ScrollBarThickness=7
 supportScroller.ScrollBarImageColor3=Color3.fromRGB(32,190,215)
 supportScroller.ScrollBarImageTransparency=.06
 supportScroller.VerticalScrollBarInset=Enum.ScrollBarInset.Always
 supportScroller.ClipsDescendants=true

 local touch=UserInputService.TouchEnabled
 if touch then
  grid.CellSize=UDim2.new(1,-12,0,66)
  grid.CellPadding=UDim2.new(0,0,0,9)
 else
  grid.CellSize=UDim2.new(.48,-4,0,70)
  grid.CellPadding=UDim2.new(.04,0,0,10)
 end

 local function syncCanvas()
  task.defer(function()
   if not supportScroller.Parent then return end
   local contentH=grid.AbsoluteContentSize.Y+18
   supportScroller.CanvasSize=UDim2.fromOffset(0,math.max(contentH,supportScroller.AbsoluteSize.Y+2))
  end)
 end
 grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncCanvas)
 supportScroller:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncCanvas)
 syncCanvas()
end

layoutDock()
fixSupportScroll()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
 layoutDock()
 fixSupportScroll()
end)
dock.ChildAdded:Connect(function(child)
 if child.Name=="CommunityTab" then task.defer(layoutDock) end
end)

print("[BBYA] Message + Community responsive dock + touch-first Support scroll v1.2 online")
