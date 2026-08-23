-- BBYA SOCIAL HUB — COMPACT SECONDARY PANELS v3
-- CONTENT/SIZE ONLY. Command Menu v7 is the sole position authority.
-- SUPPORT / TRAVEL / MESSAGE reuse the compact MENU dimensions without fighting AnchorPoint/Position.
-- Existing purchase, teleport and DJ-wall remotes remain untouched.

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local clubUI=pg:WaitForChild("BBYAClubUI",30)
if not clubUI then return end
local hub=clubUI:WaitForChild("HubPanel",30)
if not hub then return end

local C={panel=Color3.fromRGB(9,10,14)}

local function viewport()
 camera=workspace.CurrentCamera or camera
 return (camera and camera.ViewportSize) or Vector2.new(1280,720)
end

local function menuDrawer()
 local menuGui=pg:FindFirstChild("BBYACommandMenuUI")
 return menuGui and menuGui:FindFirstChild("FeatureDrawer") or nil
end

local function masterSize()
 local drawer=menuDrawer()
 if drawer and drawer:IsA("Frame") and drawer.Size.X.Offset>0 and drawer.Size.Y.Offset>0 then
  return drawer.Size.X.Offset,drawer.Size.Y.Offset
 end
 local vp=viewport()
 local touch=UserInputService.TouchEnabled
 local w=touch and math.clamp(math.floor(vp.X*.30),296,330) or math.clamp(math.floor(vp.X*.25),304,340)
 local h=(vp.Y<620) and 286 or 308
 return w,h
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

local function setHeader(page)
 local header=findHeader()
 if not header then return end
 header.Visible=true
 header.Position=UDim2.fromOffset(10,10)
 header.Size=UDim2.new(1,-20,0,52)
 header.BackgroundColor3=Color3.fromRGB(16,17,23)
 header.BackgroundTransparency=.25
 local labels={}
 for _,d in ipairs(header:GetChildren()) do
  if d:IsA("TextLabel") then table.insert(labels,d) end
  if d:IsA("TextButton") and (d.Text=="×" or d.Text=="X") then
   d.Position=UDim2.new(1,-42,0,8);d.Size=UDim2.fromOffset(32,32);d.TextSize=17;d.BackgroundTransparency=.18
  end
 end
 table.sort(labels,function(a,b)return a.Position.Y.Offset<b.Position.Y.Offset end)
 local title=(page=="SUPPORT") and "SUPPORT BBYA" or "TRAVEL"
 local sub=(page=="SUPPORT") and "Choose an amount" or "Choose destination"
 if labels[1] then labels[1].Text=title;labels[1].Position=UDim2.fromOffset(12,5);labels[1].Size=UDim2.new(1,-58,0,22);labels[1].TextSize=14;labels[1].Visible=true end
 if labels[2] then labels[2].Text=sub;labels[2].Position=UDim2.fromOffset(12,26);labels[2].Size=UDim2.new(1,-58,0,16);labels[2].TextSize=8;labels[2].Visible=true end
 for i=3,#labels do labels[i].Visible=false end
end

local applyingHub=false
local function compactHubShell(content,page)
 if applyingHub then return end
 applyingHub=true
 local w,h=masterSize()
 -- IMPORTANT: no AnchorPoint/Position writes here. Command Menu v7 owns placement.
 hub.Size=UDim2.fromOffset(w,h)
 hub.BackgroundColor3=C.panel
 hub.BackgroundTransparency=.34
 hub.ClipsDescendants=true
 hub:SetAttribute("BBYAPositionAuthority","COMMAND_MENU_V7")
 hub:SetAttribute("BBYASecondaryLayoutAuthority","V3_CONTENT_ONLY")
 setHeader(page)
 if content then
  content.Position=UDim2.fromOffset(10,70)
  content.Size=UDim2.new(1,-20,1,-80)
  content.BackgroundTransparency=1
  for _,child in ipairs(content:GetChildren()) do
   if child:IsA("Frame") then child.Visible=(child==findSupport() and page=="SUPPORT") or (child==findTravel() and page=="TRAVEL") end
  end
 end
 for _,d in ipairs(hub:GetChildren()) do
  if d:IsA("Frame") and d~=content and d~=findHeader() and d.Size.Y.Offset<=4 then d.Visible=false end
 end
 applyingHub=false
end

local supportGridGuard=false
local function applySupport()
 local support=findSupport()
 if not support or not support.Visible or not hub.Visible then return end
 local content=support.Parent
 compactHubShell(content,"SUPPORT")
 support.Visible=true;support.Position=UDim2.fromScale(0,0);support.Size=UDim2.fromScale(1,1);support.BackgroundTransparency=1
 local intro=support:FindFirstChild("SupportIntro",true)
 local gridCard=support:FindFirstChild("SupportGrid",true)
 local scroller=support:FindFirstChild("SupportScroller",true)
 if intro then intro.Visible=false end
 if gridCard then
  gridCard.Visible=true;gridCard.Position=UDim2.fromScale(0,0);gridCard.Size=UDim2.fromScale(1,1);gridCard.BackgroundTransparency=.30
  for _,d in ipairs(gridCard:GetChildren()) do
   if d:IsA("TextLabel") and string.upper(d.Text or ""):find("CHOOSE AMOUNT",1,true) then
    d.Position=UDim2.fromOffset(10,5);d.Size=UDim2.new(1,-20,0,18);d.TextSize=10;d.Visible=true
   end
  end
 end
 if scroller then
  scroller.Position=UDim2.fromOffset(8,28);scroller.Size=UDim2.new(1,-16,1,-34);scroller.ScrollBarThickness=3;scroller.BackgroundTransparency=1
  local grid=scroller:FindFirstChildWhichIsA("UIGridLayout")
  if grid and not supportGridGuard then
   supportGridGuard=true
   grid.FillDirectionMaxCells=2;grid.CellSize=UDim2.new(.5,-4,0,40);grid.CellPadding=UDim2.fromOffset(6,6)
   scroller.CanvasSize=UDim2.fromOffset(0,math.max(0,grid.AbsoluteContentSize.Y+8))
   supportGridGuard=false
  end
  for _,d in ipairs(scroller:GetChildren()) do if d:IsA("TextButton") then d.BackgroundTransparency=.22;d.TextSize=9 end end
 end
 hub:SetAttribute("BBYACompactPage","SUPPORT_MENU_SIZE")
end

local travelGridGuard=false
local function applyTravel()
 local travel=findTravel()
 if not travel or not travel.Visible or not hub.Visible then return end
 local content=travel.Parent
 compactHubShell(content,"TRAVEL")
 travel.Visible=true;travel.Position=UDim2.fromScale(0,0);travel.Size=UDim2.fromScale(1,1);travel.BackgroundTransparency=1
 for _,d in ipairs(travel:GetChildren()) do if d:IsA("TextLabel") then d.Visible=false end end
 local scroller=travel:FindFirstChild("TravelDestinationScroller")
 if scroller and scroller:IsA("ScrollingFrame") then
  scroller.Position=UDim2.fromScale(0,0);scroller.Size=UDim2.fromScale(1,1);scroller.ScrollBarThickness=3;scroller.BackgroundTransparency=1
  local grid=scroller:FindFirstChildWhichIsA("UIGridLayout")
  if grid and not travelGridGuard then
   travelGridGuard=true
   grid.FillDirectionMaxCells=2;grid.CellSize=UDim2.new(.5,-4,0,48);grid.CellPadding=UDim2.fromOffset(6,6)
   local pad=scroller:FindFirstChildWhichIsA("UIPadding")
   if pad then pad.PaddingTop=UDim.new(0,2);pad.PaddingBottom=UDim.new(0,10);pad.PaddingLeft=UDim.new(0,2);pad.PaddingRight=UDim.new(0,4) end
   scroller.CanvasSize=UDim2.fromOffset(0,math.max(0,grid.AbsoluteContentSize.Y+14))
   travelGridGuard=false
  end
  for _,card in ipairs(scroller:GetChildren()) do
   if card:IsA("Frame") then
    card.BackgroundTransparency=.28
    for _,d in ipairs(card:GetDescendants()) do
     if d:IsA("TextButton") then d.BackgroundTransparency=.20;d.TextSize=7;d.Size=UDim2.new(.40,0,0,30) end
     if d:IsA("TextLabel") then d.TextSize=math.min(d.TextSize,8) end
    end
   end
  end
 end
 hub:SetAttribute("BBYACompactPage","TRAVEL_MENU_SIZE")
end

local messageGuard=false
local function applyMessage()
 if messageGuard then return end
 local wallUI=pg:FindFirstChild("BBYADJWallUI")
 if not wallUI then return end
 local panel=wallUI:FindFirstChild("DJWallComposerPanel",true)
 if not panel or not panel:IsA("Frame") or not panel.Visible then return end
 messageGuard=true
 local w,h=masterSize()
 wallUI.IgnoreGuiInset=true
 -- IMPORTANT: no AnchorPoint/Position writes here. Command Menu v7 owns placement.
 panel.Size=UDim2.fromOffset(w,h);panel.BackgroundTransparency=.34
 panel:SetAttribute("BBYAPositionAuthority","COMMAND_MENU_V7")
 local shade
 for _,d in ipairs(wallUI:GetChildren()) do if d:IsA("Frame") and d.Size.X.Scale==1 and d.Size.Y.Scale==1 then shade=d;break end end
 if shade then shade.BackgroundTransparency=.70 end
 local header=panel:FindFirstChild("StickyHeader")
 local footer=panel:FindFirstChild("StickyFooter")
 local body=panel:FindFirstChild("ComposerBody")
 if header then
  header.Size=UDim2.new(1,0,0,52);header.BackgroundTransparency=.25
  local labels={}
  for _,d in ipairs(header:GetChildren()) do if d:IsA("TextLabel") then table.insert(labels,d) end end
  table.sort(labels,function(a,b)return a.Position.Y.Offset<b.Position.Y.Offset end)
  if labels[1] then labels[1].Position=UDim2.fromOffset(12,5);labels[1].Size=UDim2.new(1,-54,0,22);labels[1].TextSize=14 end
  if labels[2] then labels[2].Position=UDim2.fromOffset(12,26);labels[2].Size=UDim2.new(1,-54,0,16);labels[2].TextSize=8 end
  for _,d in ipairs(header:GetChildren()) do if d:IsA("TextButton") and (d.Text=="×" or d.Text=="X") then d.Position=UDim2.new(1,-42,0,8);d.Size=UDim2.fromOffset(32,32);d.TextSize=17 end end
 end
 if footer then
  footer.Size=UDim2.new(1,0,0,52);footer.BackgroundTransparency=.25
  for _,d in ipairs(footer:GetChildren()) do if d:IsA("TextButton") then d.Position=UDim2.fromOffset(10,8);d.Size=UDim2.new(1,-20,0,36);d.TextSize=9;d.BackgroundTransparency=.18 end end
 end
 if body then
  body.Position=UDim2.fromOffset(0,52);body.Size=UDim2.new(1,0,1,-104);body.ScrollBarThickness=3
  local content=body:FindFirstChild("BodyContent")
  if content then
   content.Size=UDim2.new(1,0,0,258)
   local pricePill,filterPill,catsHolder,preview
   local momentTitle,writeTitle,countLabel
   local box=content:FindFirstChildWhichIsA("TextBox")
   for _,child in ipairs(content:GetChildren()) do
    if child:IsA("Frame") then
     local t=""
     for _,x in ipairs(child:GetDescendants()) do if x:IsA("TextLabel") then t=t.." "..string.upper(x.Text or "") end end
     if t:find("ROBUX",1,true) or t:find("OWNER TEST",1,true) then pricePill=child
     elseif t:find("ROBLOX FILTER",1,true) then filterPill=child
     elseif child:FindFirstChildWhichIsA("TextButton") then catsHolder=child
     else preview=child end
    elseif child:IsA("TextLabel") then
     local t=string.upper(child.Text or "")
     if t:find("PILIH MOMEN",1,true) then momentTitle=child
     elseif t:find("TULIS PESAN",1,true) then writeTitle=child
     elseif t:find(" / ",1,true) then countLabel=child end
    end
   end
   if pricePill then pricePill.Position=UDim2.fromOffset(10,8);pricePill.Size=UDim2.new(.48,-3,0,30) end
   if filterPill then filterPill.Position=UDim2.new(.5,3,0,8);filterPill.Size=UDim2.new(.48,-13,0,30) end
   if momentTitle then momentTitle.Position=UDim2.fromOffset(10,44);momentTitle.Size=UDim2.new(1,-20,0,16);momentTitle.TextSize=8 end
   if catsHolder then catsHolder.Position=UDim2.fromOffset(10,63);catsHolder.Size=UDim2.new(1,-20,0,34);for _,b in ipairs(catsHolder:GetChildren()) do if b:IsA("TextButton") then b.TextSize=7 end end end
   if writeTitle then writeTitle.Position=UDim2.fromOffset(10,106);writeTitle.Size=UDim2.new(1,-20,0,16);writeTitle.TextSize=8 end
   if box then box.Position=UDim2.fromOffset(10,126);box.Size=UDim2.new(1,-20,0,64);box.TextSize=9 end
   if countLabel then countLabel.Position=UDim2.new(1,-80,0,191);countLabel.Size=UDim2.fromOffset(70,16);countLabel.TextSize=8 end
   if preview then preview.Position=UDim2.fromOffset(10,214);preview.Size=UDim2.new(1,-20,0,38) end
   body.CanvasSize=UDim2.fromOffset(0,258)
  end
 end
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("Frame") and d~=header and d~=footer and d~=body and d.BackgroundTransparency<.24 then d.BackgroundTransparency=.24 end
  if d:IsA("TextButton") and d.BackgroundTransparency<.18 then d.BackgroundTransparency=.18 end
  if d:IsA("TextBox") then d.BackgroundTransparency=.24 end
 end
 panel:SetAttribute("BBYACompactMessage","V3_CONTENT_ONLY")
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
 if not obj then return end
 local key=tostring(obj)..":"..tostring(prop)
 if bound[key] then return end
 bound[key]=true
 if prop then obj:GetPropertyChangedSignal(prop):Connect(function()task.defer(applyVisible);task.delay(.03,applyVisible)end) end
end

local function bindAll()
 local support=findSupport();local travel=findTravel();local drawer=menuDrawer()
 bind(hub,"Visible");bind(support,"Visible");bind(travel,"Visible")
 bind(drawer,"Size")
 local wallUI=pg:FindFirstChild("BBYADJWallUI")
 local mp=wallUI and wallUI:FindFirstChild("DJWallComposerPanel",true)
 bind(mp,"Visible")
end

pg.ChildAdded:Connect(function()task.defer(function()bindAll();applyVisible()end)end)
hub.DescendantAdded:Connect(function()task.defer(function()bindAll();applyVisible()end)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(applyVisible)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(applyVisible)end) end

task.defer(function()bindAll();applyVisible()end)
task.delay(.5,function()bindAll();applyVisible()end)
task.delay(1.5,function()bindAll();applyVisible()end)

print("[BBYA] Compact Secondary Panels v3: compact content/size only; Command Menu v7 owns all panel placement")
