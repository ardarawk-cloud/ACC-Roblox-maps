-- BBYA MUSIC UI TEST — DANCE + PANEL UX AUTHORITY v9
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Keeps the native 212 dance callbacks, fixes Support routing, restores readable COMM,
-- keeps Party Stuff open above the menu, makes Music glassier, and restores DJ Wall
-- to a usable phone-sized composer without a full-screen dark backdrop.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

-- DANCE 212 ------------------------------------------------------------------
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

 local contentH=layout and (layout.AbsoluteContentSize.Y+8) or 0
 boundList.CanvasSize=UDim2.fromOffset(0,math.max(contentH,boundList.AbsoluteSize.Y+2))
 if resetScroll then boundList.CanvasPosition=Vector2.new(0,0) end
 if boundRoot then
  boundRoot:SetAttribute("BBYADanceNativeScrollAuthority","V9")
  boundRoot:SetAttribute("BBYADanceVisibleRows",count)
  boundRoot:SetAttribute("BBYADanceBrowseMode","SCROLL")
 end
 syncing=false
end

local scheduled=false
local resetWanted=false
local function scheduleDance(resetScroll)
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

local function bindDance(root,list)
 if boundList==list and boundRoot==root then scheduleDance(false);return end
 boundRoot=root
 boundList=list
 cleanupLegacyHosts(root)
 list.Visible=true
 list.ChildAdded:Connect(function(child)if isDanceRow(child) then scheduleDance(false) end end)
 list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()scheduleDance(false)end)
 local layout=list:FindFirstChildWhichIsA("UIListLayout")
 if layout then layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()scheduleDance(false)end) end
 scheduleDance(true)
 print("[BBYA TEST] Dance 212 native scroll v9 bound")
end

local function viewport()
 camera=workspace.CurrentCamera or camera
 return camera and camera.ViewportSize or Vector2.new(1280,720)
end

local function danceSize()
 local vp=viewport()
 return math.clamp(math.floor(vp.X*.17),210,240),math.clamp(vp.Y-18,390,680)
end

local function polishDance()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 if not panel then return end
 local w,h=danceSize()
 panel.AnchorPoint=Vector2.new(1,.5)
 panel.Position=UDim2.new(1,-12,.5,0)
 panel.Size=UDim2.fromOffset(w,h)
 panel.ClipsDescendants=true
 panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.42)
 panel:SetAttribute("BBYADancePanelGeometry","RIGHT_TALL_V9")
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
   bindDance(root,list)
  end
 end
end

-- SUPPORT --------------------------------------------------------------------
local supportBound=setmetatable({}, {__mode="k"})

local function findHubHeaderLabel(hub,wantSub)
 for _,d in ipairs(hub:GetDescendants()) do
  if d:IsA("TextLabel") and d.Parent and d.Parent.Parent==hub then
   local u=string.upper(tostring(d.Text or ""))
   if not wantSub then
    if u=="MUSIC SYSTEM" or u=="SUPPORT BBYA" or u=="SUPPORT" or u=="TRAVEL" then return d end
   else
    if string.find(u,"MAIN WESTERN",1,true) or string.find(u,"COMMUNITY SUPPORT",1,true) or string.find(u,"QUICK ACCESS",1,true) or string.find(u,"VENUE-AWARE",1,true) then return d end
   end
  end
 end
 return nil
end

local function openSupport()
 local clubUI=pg:FindFirstChild("BBYAClubUI")
 local hub=clubUI and clubUI:FindFirstChild("HubPanel")
 if not hub then return end
 local gridCard=hub:FindFirstChild("SupportGrid",true)
 local supportFrame=gridCard and gridCard.Parent
 local content=supportFrame and supportFrame.Parent
 if not supportFrame or not content then return end

 for _,c in ipairs(content:GetChildren()) do
  if c:IsA("GuiObject") then c.Visible=(c==supportFrame) end
 end
 hub.Visible=true
 local title=findHubHeaderLabel(hub,false)
 local sub=findHubHeaderLabel(hub,true)
 if title then title.Text="SUPPORT" end
 if sub then sub.Text="Community support • scroll to choose an amount" end

 local w,h=danceSize()
 hub.AnchorPoint=Vector2.new(1,.5)
 hub.Position=UDim2.new(1,-12,.5,0)
 hub.Size=UDim2.fromOffset(w,h)
 hub.ClipsDescendants=true
 hub.BackgroundTransparency=math.max(hub.BackgroundTransparency,.52)
 hub:SetAttribute("BBYASupportDirectOpen","V9")

 local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
 local remote=remotes and remotes:FindFirstChild("Support")
 if remote and remote:IsA("RemoteEvent") then remote:FireServer("list") end

 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=menu and menu:FindFirstChild("FeatureDrawer",true)
 if drawer and drawer:IsA("GuiObject") then drawer.Visible=false end
end

local function bindSupportButtons()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 if not menu then return end
 for _,d in ipairs(menu:GetDescendants()) do
  if d:IsA("TextButton") then
   local u=string.upper(tostring(d.Text or ""))
   if u=="SUPPORT" or string.find(u,"SUPPORT",1,true)==1 then
    if not supportBound[d] then
     supportBound[d]=true
     d.Activated:Connect(function()
      task.defer(openSupport)
      task.delay(.06,openSupport)
     end)
    end
   end
  end
 end
end

-- COMMUNITY ------------------------------------------------------------------
local function polishCommunity()
 local clubUI=pg:FindFirstChild("BBYAClubUI")
 local shade=clubUI and clubUI:FindFirstChild("CommunityOverlay",true)
 local panel=shade and shade:FindFirstChild("CommunityPanel",true)
 if not shade or not panel then return end
 local vp=viewport()
 local w=math.clamp(math.floor(vp.X*.29),340,430)
 local h=math.clamp(vp.Y-40,460,650)

 shade.BackgroundTransparency=1
 shade.Active=false
 shade:SetAttribute("BBYACommunityBackdrop","CLEAR_V9")
 panel.AnchorPoint=Vector2.new(1,.5)
 panel.Position=UDim2.new(1,-12,.5,0)
 panel.Size=UDim2.fromOffset(w,h)
 panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.34)
 panel.ClipsDescendants=true
 panel:SetAttribute("BBYACommunityGeometry","READABLE_MEDIUM_V9")

 local scroller=panel:FindFirstChild("CommunityScroller",true)
 if scroller and scroller:IsA("ScrollingFrame") then
  scroller.Position=UDim2.fromOffset(12,80)
  scroller.Size=UDim2.new(1,-24,1,-92)
  scroller.ScrollBarThickness=4
  scroller.Active=true
  scroller.ScrollingEnabled=true
 end

 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("TextLabel") or d:IsA("TextButton") then
   local u=string.upper(tostring(d.Text or ""))
   if u=="BBYA COMMUNITY" then d.TextSize=18
   elseif u=="DISCORD COMMUNITY" then d.TextSize=15
   elseif string.find(u,"JOIN FROM",1,true) then d.TextSize=13
   elseif string.find(u,"OFFICIAL COMMUNITY HUB",1,true) then d.TextSize=9
   elseif d.TextSize<10 then d.TextSize=10 end
  end
 end
end

-- DJ WALL MESSAGE ------------------------------------------------------------
local function polishMessage()
 local gui=pg:FindFirstChild("BBYADJWallUI")
 local panel=gui and gui:FindFirstChild("DJWallComposerPanel",true)
 if not gui or not panel then return end
 local vp=viewport()
 local w=math.clamp(math.floor(vp.X*.30),360,440)
 local h=math.clamp(vp.Y-28,500,680)

 for _,d in ipairs(gui:GetChildren()) do
  if d:IsA("Frame") and d~=panel and d.Size.X.Scale>=.95 and d.Size.Y.Scale>=.95 then
   d.BackgroundTransparency=1
   d.Active=false
   d:SetAttribute("BBYAMessageBackdrop","CLEAR_V9")
  end
 end

 panel.AnchorPoint=Vector2.new(1,.5)
 panel.Position=UDim2.new(1,-12,.5,0)
 panel.Size=UDim2.fromOffset(w,h)
 panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.24)
 panel.ClipsDescendants=true
 panel:SetAttribute("BBYADJWallGeometry","PHONE_SCREEN_V9")

 local header=panel:FindFirstChild("StickyHeader",true)
 local footer=panel:FindFirstChild("StickyFooter",true)
 local body=panel:FindFirstChild("ComposerBody",true)
 if header and header:IsA("GuiObject") then header.Size=UDim2.new(1,0,0,72) end
 if footer and footer:IsA("GuiObject") then footer.Size=UDim2.new(1,0,0,66) end
 if body and body:IsA("ScrollingFrame") then
  body.Position=UDim2.fromOffset(0,72)
  body.Size=UDim2.new(1,0,1,-138)
  body.ScrollBarThickness=4
  body.Active=true
  body.ScrollingEnabled=true
 end
end

-- MUSIC GLASS ----------------------------------------------------------------
local function polishMusicBackdrop()
 local clubUI=pg:FindFirstChild("BBYAClubUI")
 local hub=clubUI and clubUI:FindFirstChild("HubPanel")
 if not hub then return end
 local title=findHubHeaderLabel(hub,false)
 local u=title and string.upper(tostring(title.Text or "")) or ""
 if u~="MUSIC SYSTEM" then return end
 hub.BackgroundTransparency=math.max(hub.BackgroundTransparency,.62)
 local playerCard=hub:FindFirstChild("PlayerCard",true)
 local libraryCard=hub:FindFirstChild("LibraryCard",true)
 if playerCard and playerCard:IsA("GuiObject") then playerCard.BackgroundTransparency=math.max(playerCard.BackgroundTransparency,.34) end
 if libraryCard and libraryCard:IsA("GuiObject") then libraryCard.BackgroundTransparency=math.max(libraryCard.BackgroundTransparency,.34) end
 hub:SetAttribute("BBYAMusicBackdrop","GLASS_V9")
end

-- PARTY STUFF ----------------------------------------------------------------
local partyWanted=false
local partyBound=setmetatable({}, {__mode="k"})
local partyOld=setmetatable({}, {__mode="k"})

local function restorePartyDrawer(drawer,panel)
 local saved=partyOld[drawer]
 if saved then
  for obj,vis in pairs(saved) do
   if obj and obj.Parent==drawer and obj~=panel then obj.Visible=vis end
  end
  partyOld[drawer]=nil
 end
end

local function showParty()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=menu and menu:FindFirstChild("FeatureDrawer",true)
 local panel=drawer and drawer:FindFirstChild("PartyStuffPanel",true)
 if not drawer or not panel then return end

 if not partyWanted then
  restorePartyDrawer(drawer,panel)
  return
 end

 if not partyOld[drawer] then
  local saved={}
  for _,d in ipairs(drawer:GetChildren()) do
   if d:IsA("GuiObject") and d~=panel then saved[d]=d.Visible end
  end
  partyOld[drawer]=saved
 end

 drawer.Visible=true
 for _,d in ipairs(drawer:GetChildren()) do
  if d:IsA("GuiObject") and d~=panel then d.Visible=false end
 end
 panel.Visible=true
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
 panel:SetAttribute("BBYAPartyTouchAuthority","V9_STICKY_DRAWER")
end

local function bindParty()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=menu and menu:FindFirstChild("FeatureDrawer",true)
 local panel=drawer and drawer:FindFirstChild("PartyStuffPanel",true)
 if not menu or not drawer or not panel then return end

 for _,d in ipairs(menu:GetDescendants()) do
  if d:IsA("TextButton") and not partyBound[d] then
   local u=string.upper(tostring(d.Text or ""))
   if d.Name=="PartyStuffButton" or u=="PARTY STUFF" then
    partyBound[d]=true
    d.Activated:Connect(function()
     partyWanted=true
     task.defer(showParty)
     task.delay(.08,showParty)
     task.delay(.22,showParty)
    end)
   elseif d.Name=="PartyBack" or d.Name=="Party_PUT_AWAY" or string.sub(d.Name or "",1,6)=="Party_" then
    partyBound[d]=true
    d.Activated:Connect(function()
     partyWanted=false
     task.defer(function()restorePartyDrawer(drawer,panel)end)
    end)
   end
  end
 end

 if partyWanted then showParty() end
end

-- MASTER LOOP ----------------------------------------------------------------
local function findUI()
 polishDance()
 bindSupportButtons()
 polishCommunity()
 polishMessage()
 polishMusicBackdrop()
 bindParty()
 if partyWanted then showParty() end
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
 for _=1,220 do
  findUI()
  task.wait(.18)
 end
end)

pg.DescendantAdded:Connect(function(d)
 if d.Name=="DanceCatalogScroll" or isDanceRow(d) or d.Name=="CommunityPanel" or d.Name=="DJWallComposerPanel" or d.Name=="PartyStuffPanel" or d:IsA("TextButton") then
  scheduleUI()
 end
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 scheduleUI()
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(scheduleUI) end

print("[BBYA TEST] Panel UX v9 online: Support fixed / readable COMM / sticky Party / Music glass / DJ phone-size")
