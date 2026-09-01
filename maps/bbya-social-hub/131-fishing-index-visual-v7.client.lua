-- BBYA MUSIC UI TEST — DANCE NATIVE SCROLL AUTHORITY v8
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- 92-freecam.client.lua owns the 212 catalog and every dance button/click callback.
-- v8 keeps native dance callbacks, gives the approved compact panel a little more height,
-- removes Community/Message full-screen dark backdrops, compacts both panels, and makes
-- Party Stuff fully own the drawer while open so menu controls cannot steal touch input.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local boundList
local boundRoot
local syncing=false

local function isDanceRow(o)
 return o:IsA("TextButton") and string.sub(o.Name or "",1,6)=="Dance_"
end

local function cleanupLegacyHosts(root)
 for _,name in ipairs({"DanceDirectPageHostV4","DanceDirectScrollHostV5","DanceDirectScrollHostV6","DanceDirectScrollHostV7"}) do
  local old=root:FindFirstChild(name)
  if old then old:Destroy() end
 end
end

local function syncRows(resetScroll)
 if syncing or not boundList or not boundList.Parent then return end
 syncing=true
 boundList.Visible=true
 boundList.Active=true
 boundList.ScrollingEnabled=true
 boundList.ScrollingDirection=Enum.ScrollingDirection.Y
 boundList.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
 boundList.ScrollBarThickness=4
 boundList.ScrollBarImageColor3=Color3.fromRGB(244,48,149)
 boundList.AutomaticCanvasSize=Enum.AutomaticSize.None
 boundList.ClipsDescendants=true
 boundList.ZIndex=80

 local layout=boundList:FindFirstChildWhichIsA("UIListLayout")
 local count=0
 for _,b in ipairs(boundList:GetChildren()) do
  if isDanceRow(b) then
   count+=1
   b.Visible=true
   b.Active=true
   b.Selectable=true
   b.AutoButtonColor=true
   b.ZIndex=88
   b.Size=UDim2.new(1,-6,0,38)
   b.TextWrapped=false
   b.TextTruncate=Enum.TextTruncate.AtEnd
   b.TextSize=9
   b.BackgroundTransparency=.14
  end
 end

 local contentH=0
 if layout then contentH=layout.AbsoluteContentSize.Y+8 end
 boundList.CanvasSize=UDim2.fromOffset(0,math.max(contentH,boundList.AbsoluteSize.Y+2))
 if resetScroll then boundList.CanvasPosition=Vector2.new(0,0) end
 if boundRoot then
  boundRoot:SetAttribute("BBYADanceNativeScrollAuthority","V8")
  boundRoot:SetAttribute("BBYADanceVisibleRows",count)
  boundRoot:SetAttribute("BBYADanceBrowseMode","SCROLL")
 end
 syncing=false
end

local scheduled=false
local resetWanted=false
local function schedule(resetScroll)
 resetWanted=resetWanted or resetScroll==true
 if scheduled then return end
 scheduled=true
 task.delay(.06,function()
  scheduled=false
  local r=resetWanted
  resetWanted=false
  syncRows(r)
 end)
end

local function bind(root,list)
 if boundList==list and boundRoot==root then schedule(false);return end
 boundRoot=root
 boundList=list
 cleanupLegacyHosts(root)
 list.Visible=true
 list.ChildAdded:Connect(function(child)
  if isDanceRow(child) then schedule(false) end
 end)
 list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()schedule(false)end)
 local layout=list:FindFirstChildWhichIsA("UIListLayout")
 if layout then layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()schedule(false)end) end
 schedule(true)
 print("[BBYA TEST] Dance native scroll v8 bound: source buttons remain clickable")
end

local function viewport()
 camera=workspace.CurrentCamera or camera
 return camera and camera.ViewportSize or Vector2.new(1280,720)
end

local function approvedCompactSize()
 local vp=viewport()
 local w=math.clamp(math.floor(vp.X*.17),210,240)
 local h=math.clamp(vp.Y-18,380,680)
 return w,h
end

local layoutBusy=setmetatable({}, {__mode="k"})
local function setCompactSize(panel,tag)
 if not panel or not panel:IsA("GuiObject") or layoutBusy[panel] then return end
 local w,h=approvedCompactSize()
 layoutBusy[panel]=true
 panel.Size=UDim2.fromOffset(w,h)
 panel.ClipsDescendants=true
 if panel:IsA("Frame") or panel:IsA("ScrollingFrame") then
  panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.42)
 end
 panel:SetAttribute("BBYAApprovedCompactV8",tag or "COMPACT")
 layoutBusy[panel]=nil
end

local function polishDanceGeometry()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 if not panel then return end
 setCompactSize(panel,"DANCE_TALLER")
 local root=panel:FindFirstChild("BBYADanceCatalogV1")
 if root and root:IsA("GuiObject") then
  root.Position=UDim2.fromOffset(10,44)
  root.Size=UDim2.new(1,-20,1,-50)
  local list=root:FindFirstChild("DanceCatalogScroll")
  if list and list:IsA("ScrollingFrame") then
   list.Position=UDim2.fromOffset(0,94)
   list.Size=UDim2.new(1,0,1,-94)
   list.Visible=true
   list.Active=true
  end
 end
end

local function capText(root)
 for _,d in ipairs(root:GetDescendants()) do
  if d:IsA("TextLabel") or d:IsA("TextButton") then
   local t=string.upper(tostring(d.Text or ""))
   if t=="BBYA COMMUNITY" or t=="DJ WALL MESSAGE" or t=="DJ WALL" then
    d.TextSize=math.min(d.TextSize,14)
   elseif string.find(t,"OFFICIAL COMMUNITY",1,true) then
    d.TextSize=math.min(d.TextSize,8)
   elseif d.TextSize>11 then
    d.TextSize=10
   end
  end
 end
end

local function polishCommunity()
 local clubUI=pg:FindFirstChild("BBYAClubUI")
 local shade=clubUI and clubUI:FindFirstChild("CommunityOverlay",true)
 local panel=shade and shade:FindFirstChild("CommunityPanel",true)
 if not shade or not panel then return end
 shade.BackgroundTransparency=1
 shade:SetAttribute("BBYACommunityBackdrop","CLEAR_V8")
 setCompactSize(panel,"COMMUNITY")
 capText(panel)
 local scroller=panel:FindFirstChild("CommunityScroller",true)
 if scroller and scroller:IsA("ScrollingFrame") then
  scroller.Position=UDim2.fromOffset(8,62)
  scroller.Size=UDim2.new(1,-16,1,-70)
  scroller.ScrollBarThickness=3
  scroller.Active=true
  scroller.ScrollingEnabled=true
 end
 -- Compact the header without rewriting Community content; the body remains scrollable.
 for _,d in ipairs(panel:GetChildren()) do
  if d:IsA("Frame") and d~=scroller and d.AbsoluteSize.Y>=60 then
   local hasClose=d:FindFirstChildWhichIsA("TextButton")~=nil
   if hasClose then d.Size=UDim2.new(1,0,0,56) end
  end
 end
end

local function polishMessage()
 local gui=pg:FindFirstChild("BBYADJWallUI")
 local panel=gui and gui:FindFirstChild("DJWallComposerPanel",true)
 if not gui or not panel then return end
 -- Remove the phone-sized dark shade while keeping the native TextBox/keyboard behavior unchanged.
 for _,d in ipairs(gui:GetChildren()) do
  if d:IsA("Frame") and d~=panel and d.Size.X.Scale>=.95 and d.Size.Y.Scale>=.95 then
   d.BackgroundTransparency=1
   d:SetAttribute("BBYAMessageBackdrop","CLEAR_V8")
  end
 end
 setCompactSize(panel,"MESSAGE")
 capText(panel)
 local header=panel:FindFirstChild("StickyHeader",true)
 local footer=panel:FindFirstChild("StickyFooter",true)
 local body=panel:FindFirstChild("ComposerBody",true)
 if header and header:IsA("GuiObject") then header.Size=UDim2.new(1,0,0,58) end
 if footer and footer:IsA("GuiObject") then footer.Size=UDim2.new(1,0,0,58) end
 if body and body:IsA("ScrollingFrame") then
  body.Position=UDim2.fromOffset(0,58)
  body.Size=UDim2.new(1,0,1,-116)
  body.ScrollBarThickness=3
  body.Active=true
  body.ScrollingEnabled=true
 end
end

local partyBound=setmetatable({}, {__mode="k"})
local partyGuard=false
local function syncPartyPanel(panel)
 if not panel or not panel.Parent or partyGuard then return end
 local drawer=panel.Parent
 partyGuard=true
 if panel.Visible then
  -- Party Stuff temporarily owns the whole compact drawer. Hidden menu widgets cannot intercept touch.
  for _,d in ipairs(drawer:GetChildren()) do
   if d:IsA("GuiObject") and d~=panel then
    if d:GetAttribute("BBYAPartyOldVisibleV8")==nil then d:SetAttribute("BBYAPartyOldVisibleV8",d.Visible) end
    d.Visible=false
   end
  end
  panel.AnchorPoint=Vector2.new(0,0)
  panel.Position=UDim2.fromOffset(0,0)
  panel.Size=UDim2.fromScale(1,1)
  panel.ZIndex=400
  panel.Active=true
  panel.ClipsDescendants=true
  panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.42)
  for _,d in ipairs(panel:GetDescendants()) do
   if d:IsA("GuiObject") then
    d.ZIndex=math.max(d.ZIndex,401)
    if d:IsA("TextButton") then d.Active=true;d.Selectable=true end
   end
  end
  panel:SetAttribute("BBYAPartyTouchAuthority","V8_FULL_DRAWER")
 else
  for _,d in ipairs(drawer:GetChildren()) do
   if d:IsA("GuiObject") and d~=panel then
    local old=d:GetAttribute("BBYAPartyOldVisibleV8")
    if old~=nil then d.Visible=old;d:SetAttribute("BBYAPartyOldVisibleV8",nil) end
   end
  end
 end
 partyGuard=false
end

local function polishParty()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=menu and menu:FindFirstChild("FeatureDrawer",true)
 local panel=drawer and drawer:FindFirstChild("PartyStuffPanel",true)
 if not panel then return end
 if not partyBound[panel] then
  partyBound[panel]=true
  panel:GetPropertyChangedSignal("Visible"):Connect(function()
   task.defer(function()syncPartyPanel(panel)end)
   task.delay(.05,function()syncPartyPanel(panel)end)
  end)
  panel:GetPropertyChangedSignal("Position"):Connect(function()if panel.Visible then task.defer(function()syncPartyPanel(panel)end) end end)
  panel:GetPropertyChangedSignal("Size"):Connect(function()if panel.Visible then task.defer(function()syncPartyPanel(panel)end) end end)
 end
 syncPartyPanel(panel)
end

local function findUI()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 local root=panel and panel:FindFirstChild("BBYADanceCatalogV1")
 local list=root and root:FindFirstChild("DanceCatalogScroll")
 if root and list and list:IsA("ScrollingFrame") then bind(root,list) end
 polishDanceGeometry()
 polishCommunity()
 polishMessage()
 polishParty()
 return root~=nil and list~=nil
end

local uiScheduled=false
local function scheduleUI()
 if uiScheduled then return end
 uiScheduled=true
 task.delay(.08,function()
  uiScheduled=false
  findUI()
 end)
end

task.spawn(function()
 for _=1,180 do
  findUI()
  task.wait(.18)
 end
end)

pg.DescendantAdded:Connect(function(d)
 if d.Name=="DanceCatalogScroll" or isDanceRow(d) or d.Name=="CommunityPanel" or d.Name=="DJWallComposerPanel" or d.Name=="PartyStuffPanel" then
  scheduleUI()
 end
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 scheduleUI()
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(scheduleUI) end
