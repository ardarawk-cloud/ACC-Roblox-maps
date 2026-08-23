-- BBYA SOCIAL HUB — COMPACT SECONDARY PANELS v1
-- Late, event-driven layout authority for SUPPORT / TRAVEL / MESSAGE.
-- Keeps existing purchase, teleport and DJ-wall remotes intact; only compacts presentation.

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local clubUI=pg:WaitForChild("BBYAClubUI",30)
if not clubUI then return end
local hub=clubUI:WaitForChild("HubPanel",30)
if not hub then return end

local C={
 panel=Color3.fromRGB(10,10,14),card=Color3.fromRGB(25,24,31),line=Color3.fromRGB(70,68,80),
 white=Color3.fromRGB(245,244,248),muted=Color3.fromRGB(158,156,168),pink=Color3.fromRGB(247,55,158),
 cyan=Color3.fromRGB(32,190,215),gold=Color3.fromRGB(215,169,96),
}

local function viewport()
 camera=workspace.CurrentCamera or camera
 return (camera and camera.ViewportSize) or Vector2.new(1280,720)
end

local function findSupport()
 local intro=hub:FindFirstChild("SupportIntro",true)
 return intro and intro.Parent or nil
end
local function findTravel()
 local scroller=hub:FindFirstChild("TravelDestinationScroller",true)
 if scroller then return scroller.Parent end
 for _,d in ipairs(hub:GetDescendants()) do
  if d:IsA("TextLabel") and (d.Text=="MOVE THROUGH BBYA" or d.Text=="TRAVEL") then
   local p=d.Parent
   if p and p:IsA("Frame") then return p end
  end
 end
end
local function findHeader()
 for _,f in ipairs(hub:GetChildren()) do
  if f:IsA("Frame") then
   for _,d in ipairs(f:GetChildren()) do
    if d:IsA("TextButton") and (d.Text=="×" or d.Text=="X") then return f end
   end
  end
 end
end

local applyingHub=false
local function compactHubShell(content)
 if applyingHub then return end
 applyingHub=true
 local vp=viewport()
 local w=math.clamp(math.floor(vp.X*.44),420,560)
 local h=math.clamp(math.floor(vp.Y*.56),310,390)
 hub.AnchorPoint=Vector2.new(.5,.5)
 hub.Position=UDim2.fromScale(.5,.52)
 hub.Size=UDim2.fromOffset(w,h)
 hub.BackgroundColor3=C.panel
 hub.BackgroundTransparency=.25
 hub.ClipsDescendants=true
 local header=findHeader()
 if header then header.Position=UDim2.fromOffset(14,8);header.Size=UDim2.new(1,-28,0,48) end
 if content then content.Position=UDim2.fromOffset(14,62);content.Size=UDim2.new(1,-28,1,-74) end
 for _,d in ipairs(hub:GetChildren()) do
  if d:IsA("Frame") and d~=content and d~=header and d.Size.Y.Offset<=3 then
   d.Position=UDim2.fromOffset(14,58);d.Size=UDim2.new(1,-28,0,1);d.BackgroundTransparency=.55
  end
 end
 applyingHub=false
end

local supportGridGuard=false
local function applySupport()
 local support=findSupport()
 if not support or not support.Visible or not hub.Visible then return end
 local content=support.Parent
 compactHubShell(content)
 support.Position=UDim2.fromScale(0,0);support.Size=UDim2.fromScale(1,1);support.BackgroundTransparency=1
 local intro=support:FindFirstChild("SupportIntro",true)
 local gridCard=support:FindFirstChild("SupportGrid",true)
 local scroller=support:FindFirstChild("SupportScroller",true)
 if intro then
  intro.Position=UDim2.fromOffset(0,0);intro.Size=UDim2.new(1,0,0,78);intro.BackgroundTransparency=.30
  for _,d in ipairs(intro:GetChildren()) do
   if d:IsA("TextLabel") then
    local up=string.upper(d.Text or "")
    if up:find("SUPPORT BBYA",1,true) then
     d.Position=UDim2.fromOffset(14,8);d.Size=UDim2.new(1,-28,0,24);d.TextSize=15
    elseif up:find("COMMUNITY FUNDS",1,true) then
     d.Visible=false
    else
     d.Position=UDim2.fromOffset(14,32);d.Size=UDim2.new(1,-28,0,34);d.Text="Support BBYA upgrades and community. Choose an amount below.";d.TextSize=9;d.TextWrapped=true;d.Visible=true
    end
   end
  end
 end
 if gridCard then
  gridCard.Position=UDim2.fromOffset(0,86);gridCard.Size=UDim2.new(1,0,1,-86);gridCard.BackgroundTransparency=.30
  for _,d in ipairs(gridCard:GetChildren()) do
   if d:IsA("TextLabel") and string.upper(d.Text or ""):find("CHOOSE AMOUNT",1,true) then
    d.Position=UDim2.fromOffset(12,7);d.Size=UDim2.new(1,-24,0,20);d.TextSize=11
   end
  end
 end
 if scroller then
  scroller.Position=UDim2.fromOffset(12,32);scroller.Size=UDim2.new(1,-24,1,-40);scroller.ScrollBarThickness=3;scroller.BackgroundTransparency=1
  local grid=scroller:FindFirstChildWhichIsA("UIGridLayout")
  if grid and not supportGridGuard then
   supportGridGuard=true
   local narrow=hub.AbsoluteSize.X<450
   grid.FillDirectionMaxCells=narrow and 1 or 2
   grid.CellSize=narrow and UDim2.new(1,-4,0,44) or UDim2.new(.5,-5,0,44)
   grid.CellPadding=UDim2.fromOffset(7,7)
   scroller.CanvasSize=UDim2.fromOffset(0,math.max(0,grid.AbsoluteContentSize.Y+10))
   supportGridGuard=false
  end
  for _,d in ipairs(scroller:GetChildren()) do
   if d:IsA("TextButton") then d.BackgroundTransparency=.15;d.TextSize=10 end
  end
 end
 hub:SetAttribute("BBYACompactPage","SUPPORT")
end

local travelGridGuard=false
local function applyTravel()
 local travel=findTravel()
 if not travel or not travel.Visible or not hub.Visible then return end
 local content=travel.Parent
 compactHubShell(content)
 travel.Position=UDim2.fromScale(0,0);travel.Size=UDim2.fromScale(1,1);travel.BackgroundTransparency=1
 local topLabels={}
 for _,d in ipairs(travel:GetChildren()) do if d:IsA("TextLabel") then table.insert(topLabels,d) end end
 table.sort(topLabels,function(a,b)return a.Position.Y.Offset<b.Position.Y.Offset end)
 if topLabels[1] then topLabels[1].Text="TRAVEL";topLabels[1].Position=UDim2.fromOffset(0,0);topLabels[1].Size=UDim2.new(1,0,0,20);topLabels[1].TextSize=14 end
 if topLabels[2] then topLabels[2].Text="Choose destination • permanent unlocks stay unlocked.";topLabels[2].Position=UDim2.fromOffset(0,21);topLabels[2].Size=UDim2.new(1,0,0,17);topLabels[2].TextSize=8 end
 local scroller=travel:FindFirstChild("TravelDestinationScroller")
 if scroller and scroller:IsA("ScrollingFrame") then
  scroller.Position=UDim2.fromOffset(0,42);scroller.Size=UDim2.new(1,0,1,-42);scroller.ScrollBarThickness=3;scroller.BackgroundTransparency=1
  local grid=scroller:FindFirstChildWhichIsA("UIGridLayout")
  if grid and not travelGridGuard then
   travelGridGuard=true
   local twoCols=hub.AbsoluteSize.X>=450
   grid.FillDirectionMaxCells=twoCols and 2 or 1
   grid.CellSize=twoCols and UDim2.new(.5,-5,0,58) or UDim2.new(1,-4,0,58)
   grid.CellPadding=UDim2.fromOffset(7,7)
   local pad=scroller:FindFirstChildWhichIsA("UIPadding")
   if pad then pad.PaddingTop=UDim.new(0,2);pad.PaddingBottom=UDim.new(0,12);pad.PaddingLeft=UDim.new(0,2);pad.PaddingRight=UDim.new(0,4) end
   scroller.CanvasSize=UDim2.fromOffset(0,math.max(0,grid.AbsoluteContentSize.Y+18))
   travelGridGuard=false
  end
  for _,card in ipairs(scroller:GetChildren()) do
   if card:IsA("Frame") then
    card.BackgroundTransparency=.24
    for _,d in ipairs(card:GetDescendants()) do
     if d:IsA("TextButton") then d.BackgroundTransparency=.14;d.TextSize=8 end
     if d:IsA("TextLabel") and d.TextSize>11 then d.TextSize=10 end
    end
   end
  end
 end
 hub:SetAttribute("BBYACompactPage","TRAVEL")
end

local messageGuard=false
local function applyMessage()
 if messageGuard then return end
 local wallUI=pg:FindFirstChild("BBYADJWallUI")
 if not wallUI then return end
 local panel=wallUI:FindFirstChild("DJWallComposerPanel",true)
 if not panel or not panel:IsA("Frame") or not panel.Visible then return end
 messageGuard=true
 local vp=viewport()
 local w=math.clamp(math.floor(vp.X*.39),360,470)
 local h=math.clamp(math.floor(vp.Y*.55),320,380)
 panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.52);panel.Size=UDim2.fromOffset(w,h);panel.BackgroundTransparency=.24
 local shade
 for _,d in ipairs(wallUI:GetChildren()) do if d:IsA("Frame") and d.Size.X.Scale==1 and d.Size.Y.Scale==1 then shade=d;break end end
 if shade then shade.BackgroundTransparency=.62 end
 local header=panel:FindFirstChild("StickyHeader")
 local footer=panel:FindFirstChild("StickyFooter")
 local body=panel:FindFirstChild("ComposerBody")
 if header then
  header.Size=UDim2.new(1,0,0,58);header.BackgroundTransparency=.22
  local labels={}
  for _,d in ipairs(header:GetChildren()) do if d:IsA("TextLabel") then table.insert(labels,d) end end
  table.sort(labels,function(a,b)return a.Position.Y.Offset<b.Position.Y.Offset end)
  if labels[1] then labels[1].Position=UDim2.fromOffset(16,7);labels[1].Size=UDim2.new(1,-62,0,24);labels[1].TextSize=15 end
  if labels[2] then labels[2].Position=UDim2.fromOffset(16,31);labels[2].Size=UDim2.new(1,-62,0,16);labels[2].TextSize=8 end
  for _,d in ipairs(header:GetChildren()) do if d:IsA("TextButton") and (d.Text=="×" or d.Text=="X") then d.Position=UDim2.new(1,-44,0,8);d.Size=UDim2.fromOffset(34,34) end end
 end
 if footer then
  footer.Size=UDim2.new(1,0,0,56);footer.BackgroundTransparency=.20
  for _,d in ipairs(footer:GetChildren()) do if d:IsA("TextButton") then d.Position=UDim2.fromOffset(14,10);d.Size=UDim2.new(1,-28,0,36);d.TextSize=10;d.BackgroundTransparency=.12 end end
 end
 if body then body.Position=UDim2.fromOffset(0,58);body.Size=UDim2.new(1,0,1,-114);body.ScrollBarThickness=3 end
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("Frame") and d~=header and d~=footer and d~=body and d.BackgroundTransparency<.20 then d.BackgroundTransparency=.20 end
  if d:IsA("TextButton") and d.BackgroundTransparency<.12 then d.BackgroundTransparency=.12 end
  if d:IsA("TextBox") then d.BackgroundTransparency=.18 end
 end
 panel:SetAttribute("BBYACompactMessage","V1")
 messageGuard=false
end

local function applyVisible()
 local support=findSupport();local travel=findTravel()
 if support and support.Visible and hub.Visible then applySupport()
 elseif travel and travel.Visible and hub.Visible then applyTravel() end
 applyMessage()
end

local bound={}
local function bind(obj,prop)
 if not obj or bound[obj] then return end
 bound[obj]=true
 if prop then obj:GetPropertyChangedSignal(prop):Connect(function()task.defer(applyVisible);task.delay(.04,applyVisible)end) end
end

local function bindAll()
 local support=findSupport();local travel=findTravel()
 bind(hub,"Visible");bind(support,"Visible");bind(travel,"Visible")
 local ss=support and support:FindFirstChild("SupportScroller",true);bind(ss,"AbsoluteSize")
 local ts=travel and travel:FindFirstChild("TravelDestinationScroller",true);bind(ts,"AbsoluteSize")
 local wallUI=pg:FindFirstChild("BBYADJWallUI");local mp=wallUI and wallUI:FindFirstChild("DJWallComposerPanel",true);bind(mp,"Visible")
end

pg.ChildAdded:Connect(function()task.defer(function()bindAll();applyVisible()end)end)
hub.DescendantAdded:Connect(function()task.defer(function()bindAll();applyVisible()end)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(applyVisible)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(applyVisible)end) end

task.defer(function()bindAll();applyVisible()end)
task.delay(1,function()bindAll();applyVisible()end)
task.delay(2,function()bindAll();applyVisible()end)

print("[BBYA] Compact Secondary Panels v1: SUPPORT / TRAVEL / MESSAGE compact + translucent")
