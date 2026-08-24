-- BBYA SOCIAL HUB — TRAVEL UI PATCH v13
-- Mobile-first travel authority. The ENTIRE destination card is tappable.
-- Uses server acknowledgement and a timeout reset instead of silently doing nothing.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local StarterGui=game:GetService("StarterGui")

local player=Players.LocalPlayer
local camera=workspace.CurrentCamera
local remotes=ReplicatedStorage:WaitForChild("BBYAClubRemotes",30)
local remote=remotes:WaitForChild("Teleport",30)
local result=remotes:WaitForChild("TravelResult",30)
local gui=player:WaitForChild("PlayerGui"):WaitForChild("BBYAClubUI",30)
if not gui or not remote or not result then return end
local hubPanel=gui:WaitForChild("HubPanel",20)

local function findTravel()
 for _,d in ipairs(gui:GetDescendants()) do
  if d:IsA("TextLabel") and d.Text=="MOVE THROUGH BBYA" then return d.Parent end
 end
 return nil
end

local travel=nil
local deadline=os.clock()+20
repeat
 travel=findTravel()
 if travel then break end
 task.wait(.15)
until os.clock()>=deadline
if not travel then warn("[BBYA Travel v13] travel frame not found after 20s");return end

travel.ClipsDescendants=true
travel.ZIndex=70

-- Remove all previous destination grids/scrollers so exactly one touch authority remains.
for _,child in ipairs(travel:GetChildren()) do
 if child:IsA("Frame") and child:FindFirstChildOfClass("UIGridLayout") then child:Destroy() end
 if child:IsA("ScrollingFrame") and child.Name=="TravelDestinationScroller" then child:Destroy() end
end
for _,d in ipairs(travel:GetDescendants()) do
 if d:IsA("TextLabel") and (d.Text:find("Only destinations") or d.Text:find("Paid destinations") or d.Text:find("Tap tujuan")) then
  d.Text="Tap seluruh kartu tujuan • FREE langsung pindah • ONE-TIME pakai access pass permanen."
  d.TextSize=9
  d.ZIndex=72
 end
end

local holder=Instance.new("ScrollingFrame")
holder.Name="TravelDestinationScroller"
holder.Position=UDim2.fromOffset(0,50)
holder.Size=UDim2.new(1,0,1,-50)
holder.BackgroundTransparency=1
holder.BorderSizePixel=0
holder.ScrollBarThickness=5
holder.ScrollBarImageTransparency=.08
holder.AutomaticCanvasSize=Enum.AutomaticSize.None
holder.CanvasSize=UDim2.fromOffset(0,0)
holder.ScrollingDirection=Enum.ScrollingDirection.Y
holder.ElasticBehavior=Enum.ElasticBehavior.Always
holder.ScrollingEnabled=true
holder.Active=true
holder.Selectable=false
holder.ClipsDescendants=true
holder.ZIndex=80
holder.Parent=travel

local grid=Instance.new("UIGridLayout")
grid.CellPadding=UDim2.fromOffset(7,7)
grid.SortOrder=Enum.SortOrder.LayoutOrder
grid.FillDirection=Enum.FillDirection.Horizontal
grid.FillDirectionMaxCells=1
grid.HorizontalAlignment=Enum.HorizontalAlignment.Left
grid.VerticalAlignment=Enum.VerticalAlignment.Top
grid.Parent=holder

local pad=Instance.new("UIPadding")
pad.PaddingTop=UDim.new(0,2)
pad.PaddingBottom=UDim.new(0,116)
pad.PaddingLeft=UDim.new(0,2)
pad.PaddingRight=UDim.new(0,4)
pad.Parent=holder

local C={
 card=Color3.fromRGB(27,24,31),white=Color3.fromRGB(244,243,247),muted=Color3.fromRGB(160,156,166),
 pink=Color3.fromRGB(247,55,158),cyan=Color3.fromRGB(32,190,215),gold=Color3.fromRGB(215,169,96),
 purple=Color3.fromRGB(145,78,255),mall=Color3.fromRGB(228,145,65),market=Color3.fromRGB(230,82,55),
 restroom=Color3.fromRGB(92,194,204),working=Color3.fromRGB(53,46,59),ok=Color3.fromRGB(35,72,52),
 fail=Color3.fromRGB(72,39,45)
}

local destinations={
 {"ARRIVAL","Arrival","FREE",nil,C.cyan},
 {"PHOTO STUDIO","Photo","MALL L2 • FREE",nil,C.cyan},
 {"LOOK LAB","LookLab","MALL L2 • FREE",nil,C.cyan},
 {"MAIN CLUB","MainClub","FREE",nil,C.pink},
 {"TOILET / RESTROOM","Toilet","SHARED • FREE",nil,C.restroom},
 {"VIP LEVEL","VIP","ONE-TIME",5,C.gold},
 {"SKATEPARK","Skatepark","ONE-TIME",5,C.gold},
 {"ROOFTOP","Rooftop","ONE-TIME",10,C.gold},
 {"UNDERGROUND","Basement","ONE-TIME",20,C.gold},
 {"FUNKOT CLUB","Funkot","ONE-TIME",10,C.purple},
 {"BBYA MALL","Mall","ONE-TIME",10,C.mall},
 {"PASAR MALAM","NightMarket","ONE-TIME",10,C.market},
}

local function corner(o,r)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 9);c.Parent=o end
local function stroke(o,c)local s=Instance.new("UIStroke");s.Color=c;s.Thickness=1;s.Transparency=.48;s.Parent=o end
local function label(parent,value,pos,size,font,ts,color,align)
 local l=Instance.new("TextLabel")
 l.BackgroundTransparency=1
 l.Text=value
 l.Position=pos
 l.Size=size
 l.Font=font
 l.TextSize=ts
 l.TextColor3=color
 l.TextXAlignment=align or Enum.TextXAlignment.Left
 l.TextYAlignment=Enum.TextYAlignment.Center
 l.ZIndex=84
 l.Parent=parent
 return l
end

local cards={}
local statusLabels={}
local metaByKey={}
local pendingKey=nil
local pendingToken=0

local function restoreCard(key)
 local card=cards[key]
 local status=statusLabels[key]
 local d=metaByKey[key]
 if not card or not card.Parent or not d then return end
 card.BackgroundColor3=C.card
 if status then status.Text=d[4] and "UNLOCK / GO  ›" or "GO  ›";status.TextColor3=C.white end
end

local function requestDestination(key)
 if pendingKey then return end
 local card=cards[key]
 local status=statusLabels[key]
 if not card then return end
 pendingKey=key
 pendingToken+=1
 local token=pendingToken
 card.BackgroundColor3=C.working
 if status then status.Text="WORKING…";status.TextColor3=C.white end
 remote:FireServer(key)

 -- Never leave mobile UI stuck forever if a server result is lost.
 task.delay(6,function()
  if token~=pendingToken or pendingKey~=key then return end
  pendingKey=nil
  if card and card.Parent then
   card.BackgroundColor3=C.fail
   if status then status.Text="TRY AGAIN" end
   task.delay(1.1,function()restoreCard(key)end)
  end
 end)
end

for i,d in ipairs(destinations) do
 local card=Instance.new("TextButton")
 card.Name="Travel_"..d[2]
 card.Text=""
 card.BackgroundColor3=C.card
 card.BorderSizePixel=0
 card.LayoutOrder=i
 card.AutoButtonColor=true
 card.Active=true
 card.Selectable=false
 card.ZIndex=82
 card.Parent=holder
 corner(card,10)
 stroke(card,d[5])

 local bar=Instance.new("Frame")
 bar.Size=UDim2.new(0,4,1,-14)
 bar.Position=UDim2.fromOffset(7,7)
 bar.BackgroundColor3=d[5]
 bar.BorderSizePixel=0
 bar.Active=false
 bar.ZIndex=83
 bar.Parent=card
 corner(bar,3)

 label(card,d[1],UDim2.fromOffset(19,7),UDim2.new(.56,-16,0,22),Enum.Font.GothamBold,11,C.white)
 local meta=d[4] and string.format("%s • %d R$",d[3],d[4]) or d[3]
 label(card,meta,UDim2.fromOffset(19,30),UDim2.new(.58,-16,0,18),Enum.Font.GothamBold,8,d[4] and C.gold or C.muted)
 local status=label(card,d[4] and "UNLOCK / GO  ›" or "GO  ›",UDim2.new(.61,0,0,12),UDim2.new(.36,-12,0,32),Enum.Font.GothamBold,9,C.white,Enum.TextXAlignment.Right)
 status.ZIndex=84

 cards[d[2]]=card
 statusLabels[d[2]]=status
 metaByKey[d[2]]=d

 local function fire()
  requestDestination(d[2])
 end
 -- Activated is the primary cross-device event. MouseButton1Click is an explicit mobile fallback.
 card.Activated:Connect(fire)
 card.MouseButton1Click:Connect(fire)
end

result.OnClientEvent:Connect(function(ok,key,msg)
 key=tostring(key or "")
 if key=="" then return end
 pendingToken+=1
 if pendingKey==key then pendingKey=nil end
 local card=cards[key]
 local status=statusLabels[key]
 if card then
  card.BackgroundColor3=ok and C.ok or C.fail
  if status then status.Text=ok and "READY" or "TRY AGAIN" end
 end
 if ok then
  task.delay(.12,function()if hubPanel then hubPanel.Visible=false end end)
 else
  task.delay(1.2,function()restoreCard(key)end)
 end
end)

local function updateCanvas()
 task.defer(function()
  if holder.Parent then holder.CanvasSize=UDim2.fromOffset(0,math.max(0,grid.AbsoluteContentSize.Y+124)) end
 end)
end

local function applyLayout()
 camera=workspace.CurrentCamera or camera
 local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
 local touch=UserInputService.TouchEnabled or vp.X<900
 local cols=touch and 1 or 2
 grid.FillDirectionMaxCells=cols
 local usable=math.max(260,holder.AbsoluteSize.X-8)
 local cellW=touch and usable or math.floor((usable-7)/2)
 grid.CellSize=UDim2.fromOffset(cellW,touch and 66 or 72)
 pad.PaddingBottom=UDim.new(0,touch and 128 or 30)
 updateCanvas()
end

grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyLayout)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(applyLayout)end)

local backpackWas=true
local backpackHidden=false
local function travelIsOpen()return travel.Visible and (not hubPanel or hubPanel.Visible) end
local function syncBackpack()
 local open=travelIsOpen()
 if open and not backpackHidden then
  pcall(function()backpackWas=StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)end)
  pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)end)
  backpackHidden=true
 elseif not open and backpackHidden then
  pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,backpackWas)end)
  backpackHidden=false
 end
end

travel:GetPropertyChangedSignal("Visible"):Connect(function()task.defer(syncBackpack)end)
if hubPanel then hubPanel:GetPropertyChangedSignal("Visible"):Connect(function()task.defer(syncBackpack)end) end

task.defer(function()applyLayout();updateCanvas();syncBackpack()end)
print("[BBYA] Travel UI v13 online: full-card mobile touch + server ack + timeout reset")
