-- BBYA MUSIC UI TEST — PANEL FUNCTION AUTHORITY v10
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Single authority for Dance 212, Support, Community, DJ Wall Message, Music glass,
-- Developer DJ sizing, and Party Stuff persistence. No image generation/assets.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local function viewport()
 camera=workspace.CurrentCamera or camera
 return camera and camera.ViewportSize or Vector2.new(1280,720)
end

local function rightSlimSize()
 local vp=viewport()
 return math.clamp(math.floor(vp.X*.18),220,270),math.clamp(vp.Y-18,390,700)
end

local function isDanceRow(o)
 return o:IsA("TextButton") and string.sub(o.Name or "",1,6)=="Dance_"
end

-- DANCE 212 ------------------------------------------------------------------
local function polishDance()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 if not panel then return end
 local w,h=rightSlimSize()
 panel.AnchorPoint=Vector2.new(1,.5)
 panel.Position=UDim2.new(1,-12,.5,0)
 panel.Size=UDim2.fromOffset(w,h)
 panel.ClipsDescendants=true
 panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.42)
 panel:SetAttribute("BBYADancePanelGeometry","RIGHT_TALL_V10")

 local root=panel:FindFirstChild("BBYADanceCatalogV1")
 local list=root and root:FindFirstChild("DanceCatalogScroll")
 if not root or not list or not list:IsA("ScrollingFrame") then return end
 root.Position=UDim2.fromOffset(10,44)
 root.Size=UDim2.new(1,-20,1,-50)
 list.Position=UDim2.fromOffset(0,94)
 list.Size=UDim2.new(1,0,1,-94)
 list.Visible=true
 list.Active=true
 list.ScrollingEnabled=true
 list.ScrollingDirection=Enum.ScrollingDirection.Y
 list.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
 list.AutomaticCanvasSize=Enum.AutomaticSize.None
 list.ScrollBarThickness=4
 list.ScrollBarImageColor3=Color3.fromRGB(244,48,149)
 list.ClipsDescendants=true
 list.ZIndex=80

 local count=0
 for _,b in ipairs(list:GetChildren()) do
  if isDanceRow(b) then
   count+=1
   b.Visible=true;b.Active=true;b.Selectable=true;b.AutoButtonColor=true
   b.ZIndex=88;b.Size=UDim2.new(1,-6,0,38);b.TextSize=9
   b.TextWrapped=false;b.TextTruncate=Enum.TextTruncate.AtEnd
  end
 end
 local layout=list:FindFirstChildWhichIsA("UIListLayout")
 local contentH=layout and layout.AbsoluteContentSize.Y+8 or 0
 list.CanvasSize=UDim2.fromOffset(0,math.max(contentH,list.AbsoluteSize.Y+2))
 root:SetAttribute("BBYADanceNativeScrollAuthority","V10")
 root:SetAttribute("BBYADanceVisibleRows",count)
 root:SetAttribute("BBYADanceBrowseMode","SCROLL")
end

-- SUPPORT --------------------------------------------------------------------
local supportBound=setmetatable({}, {__mode="k"})
local function findHubHeader(hub)
 for _,d in ipairs(hub:GetDescendants()) do
  if d:IsA("TextLabel") and d.Parent and d.Parent.Parent==hub then
   local u=string.upper(tostring(d.Text or ""))
   if u=="MUSIC SYSTEM" or u=="SUPPORT BBYA" or u=="SUPPORT" or u=="TRAVEL" then return d end
  end
 end
end

local function openSupport()
 local club=pg:FindFirstChild("BBYAClubUI")
 local hub=club and club:FindFirstChild("HubPanel")
 local grid=hub and hub:FindFirstChild("SupportGrid",true)
 local support=grid and grid.Parent
 local content=support and support.Parent
 if not hub or not support or not content then return end
 for _,c in ipairs(content:GetChildren()) do if c:IsA("GuiObject") then c.Visible=(c==support) end end
 local intro=hub:FindFirstChild("SupportIntro",true)
 if intro then intro.Visible=false end
 local title=findHubHeader(hub)
 if title then title.Text="SUPPORT";title.TextSize=17 end
 local w,h=rightSlimSize()
 hub.AnchorPoint=Vector2.new(1,.5);hub.Position=UDim2.new(1,-12,.5,0);hub.Size=UDim2.fromOffset(w,h)
 hub.ClipsDescendants=true;hub.BackgroundTransparency=math.max(hub.BackgroundTransparency,.50);hub.Visible=true
 grid.Position=UDim2.fromOffset(0,0);grid.Size=UDim2.fromScale(1,1);grid.BackgroundTransparency=math.max(grid.BackgroundTransparency,.48)
 local scroller=hub:FindFirstChild("SupportScroller",true)
 if scroller and scroller:IsA("ScrollingFrame") then
  scroller.Position=UDim2.fromOffset(10,44);scroller.Size=UDim2.new(1,-20,1,-54)
  scroller.Active=true;scroller.ScrollingEnabled=true;scroller.ScrollBarThickness=4
  local gl=scroller:FindFirstChildWhichIsA("UIGridLayout")
  if gl then
   gl.CellSize=UDim2.new(1,-6,0,58);gl.CellPadding=UDim2.new(0,0,0,8)
   scroller.CanvasSize=UDim2.fromOffset(0,math.max(scroller.AbsoluteSize.Y+2,gl.AbsoluteContentSize.Y+10))
  end
 end
 local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
 local remote=remotes and remotes:FindFirstChild("Support")
 if remote and remote:IsA("RemoteEvent") then remote:FireServer("list") end
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=menu and menu:FindFirstChild("FeatureDrawer",true)
 if drawer then drawer.Visible=false end
 hub:SetAttribute("BBYASupportDirectOpen","V10")
end

local function bindSupport()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 if not menu then return end
 for _,d in ipairs(menu:GetDescendants()) do
  if d:IsA("TextButton") and not supportBound[d] then
   local u=string.upper(tostring(d.Text or ""))
   if u=="SUPPORT" or string.find(u,"SUPPORT",1,true)==1 then
    supportBound[d]=true
    d.Activated:Connect(function()task.defer(openSupport);task.delay(.06,openSupport)end)
   end
  end
 end
end

-- COMMUNITY ------------------------------------------------------------------
local function polishCommunity()
 local club=pg:FindFirstChild("BBYAClubUI")
 local shade=club and club:FindFirstChild("CommunityOverlay",true)
 local panel=shade and shade:FindFirstChild("CommunityPanel",true)
 if not shade or not panel then return end
 local vp=viewport()
 local w=math.clamp(math.floor(vp.X*.32),390,500)
 local h=math.clamp(vp.Y-34,470,700)
 shade.BackgroundTransparency=1;shade.Active=false
 panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-12,.5,0);panel.Size=UDim2.fromOffset(w,h)
 panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.34);panel.ClipsDescendants=true
 panel:SetAttribute("BBYACommunityGeometry","READABLE_MEDIUM_V10")
 local scroller=panel:FindFirstChild("CommunityScroller",true)
 if scroller and scroller:IsA("ScrollingFrame") then
  scroller.Position=UDim2.fromOffset(12,78);scroller.Size=UDim2.new(1,-24,1,-90)
  scroller.ScrollBarThickness=4;scroller.Active=true;scroller.ScrollingEnabled=true
 end
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("TextLabel") or d:IsA("TextButton") then
   local u=string.upper(tostring(d.Text or ""))
   if u=="BBYA COMMUNITY" then d.TextSize=18
   elseif u=="DISCORD COMMUNITY" then d.TextSize=15
   elseif string.find(u,"JOIN FROM",1,true) then d.TextSize=13
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
 local w=math.clamp(math.floor(vp.X*.42),520,720)
 local h=math.clamp(vp.Y-24,500,760)

 for _,d in ipairs(gui:GetChildren()) do
  if d:IsA("Frame") and d~=panel and d.Size.X.Scale>=.95 and d.Size.Y.Scale>=.95 then
   d.BackgroundTransparency=1;d.Active=false
  end
 end
 panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-12,.5,0);panel.Size=UDim2.fromOffset(w,h)
 panel.ClipsDescendants=true;panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.24)
 panel:SetAttribute("BBYADJWallGeometry","PHONE_LARGE_V10")

 local header=panel:FindFirstChild("StickyHeader",true)
 local footer=panel:FindFirstChild("StickyFooter",true)
 local body=panel:FindFirstChild("ComposerBody",true)
 if header and header:IsA("GuiObject") then
  header.Position=UDim2.fromOffset(0,0);header.Size=UDim2.new(1,0,0,72);header.Visible=true;header.ZIndex=100
 end
 if footer and footer:IsA("GuiObject") then
  footer.AnchorPoint=Vector2.new(0,1);footer.Position=UDim2.new(0,0,1,0);footer.Size=UDim2.new(1,0,0,66)
  footer.Visible=true;footer.ZIndex=120;footer.BackgroundTransparency=math.max(footer.BackgroundTransparency,.10)
  for _,d in ipairs(footer:GetDescendants()) do
   if d:IsA("TextButton") then
    d.Visible=true;d.Active=true;d.Selectable=true;d.AutoButtonColor=true;d.ZIndex=125
   elseif d:IsA("GuiObject") then d.ZIndex=math.max(d.ZIndex,121) end
  end
 end
 if body and body:IsA("ScrollingFrame") then
  body.Position=UDim2.fromOffset(0,72);body.Size=UDim2.new(1,0,1,-138)
  body.Visible=true;body.Active=true;body.ScrollingEnabled=true;body.ScrollBarThickness=4;body.ZIndex=10
 end
end

-- MUSIC GLASS ----------------------------------------------------------------
local function polishMusic()
 local club=pg:FindFirstChild("BBYAClubUI")
 local hub=club and club:FindFirstChild("HubPanel")
 if not hub then return end
 local title=findHubHeader(hub)
 if not title or string.upper(tostring(title.Text or ""))~="MUSIC SYSTEM" then return end
 hub.BackgroundTransparency=math.max(hub.BackgroundTransparency,.62)
 local playerCard=hub:FindFirstChild("PlayerCard",true)
 local libraryCard=hub:FindFirstChild("LibraryCard",true)
 if playerCard and playerCard:IsA("GuiObject") then playerCard.BackgroundTransparency=math.max(playerCard.BackgroundTransparency,.34) end
 if libraryCard and libraryCard:IsA("GuiObject") then libraryCard.BackgroundTransparency=math.max(libraryCard.BackgroundTransparency,.34) end
 hub:SetAttribute("BBYAMusicBackdrop","GLASS_V10")
end

-- DEVELOPER DJ MIXER ---------------------------------------------------------
local function polishDeveloperDJ()
 local gui=pg:FindFirstChild("BBYADeveloperDJUI")
 local panel=gui and gui:FindFirstChild("DeveloperDJMixerPanel",true)
 if not panel then return end
 panel.AnchorPoint=Vector2.new(0,0)
 panel.Position=UDim2.fromScale(0,0)
 panel.Size=UDim2.fromScale(1,1)
 panel.ClipsDescendants=true
 panel:SetAttribute("BBYADeveloperDJGeometry","FULL_PHONE_SCREEN_V10")
end

-- PARTY STUFF ----------------------------------------------------------------
local partyWanted=false
local partyBound=setmetatable({}, {__mode="k"})
local function findParty()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=menu and menu:FindFirstChild("FeatureDrawer",true)
 local panel=menu and menu:FindFirstChild("PartyStuffPanel",true)
 return menu,drawer,panel
end

local function placeParty(panel)
 if not panel then return end
 local w,h=rightSlimSize()
 panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-12,.5,0);panel.Size=UDim2.fromOffset(w,h)
 panel.ZIndex=450;panel.Active=true;panel.ClipsDescendants=true;panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.36)
 for _,d in ipairs(panel:GetDescendants()) do
  if d:IsA("GuiObject") then
   d.ZIndex=math.max(d.ZIndex,451)
   if d:IsA("TextButton") then d.Active=true;d.Selectable=true;d.AutoButtonColor=true end
  end
 end
 panel:SetAttribute("BBYAPartyTouchAuthority","DETACHED_V10")
end

local function showParty()
 local menu,drawer,panel=findParty()
 if not menu or not panel then return end
 if panel.Parent~=menu then panel.Parent=menu end
 placeParty(panel)
 if drawer then drawer.Visible=false end
 panel.Visible=partyWanted
end

local function bindParty()
 local menu,drawer,panel=findParty()
 if not menu or not panel then return end
 if panel.Parent~=menu then panel.Parent=menu end
 placeParty(panel)

 for _,d in ipairs(menu:GetDescendants()) do
  if d:IsA("TextButton") and not partyBound[d] then
   local u=string.upper(tostring(d.Text or ""))
   if d.Name=="PartyStuffButton" or u=="PARTY STUFF" then
    partyBound[d]=true
    d.Activated:Connect(function()
     partyWanted=true
     if drawer then drawer.Visible=false end
     task.defer(showParty);task.delay(.06,showParty);task.delay(.18,showParty)
    end)
   elseif d.Name=="PartyBack" then
    partyBound[d]=true
    d.Activated:Connect(function()partyWanted=false;panel.Visible=false end)
   elseif d.Name=="Party_PUT_AWAY" or string.sub(d.Name or "",1,6)=="Party_" then
    partyBound[d]=true
    d.Activated:Connect(function()partyWanted=false;task.defer(function()if panel then panel.Visible=false end end)end)
   end
  end
 end
 if partyWanted then showParty() end
end

-- MASTER ---------------------------------------------------------------------
local function applyAll()
 polishDance()
 bindSupport()
 polishCommunity()
 polishMessage()
 polishMusic()
 polishDeveloperDJ()
 bindParty()
 if partyWanted then showParty() end
end

local pending=false
local function schedule()
 if pending then return end
 pending=true
 task.delay(.06,function()pending=false;applyAll()end)
end

pg.ChildAdded:Connect(schedule)
pg.DescendantAdded:Connect(function(d)
 if d:IsA("GuiObject") then schedule() end
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(schedule) end
 schedule()
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(schedule) end

task.spawn(function()
 while true do
  applyAll()
  task.wait(.60)
 end
end)

task.defer(applyAll)
print("[BBYA TEST] Panel function authority v10 online: full DJ + clickable Message footer + detached Party Stuff + Dance 212")
