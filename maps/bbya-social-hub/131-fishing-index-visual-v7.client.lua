-- BBYA MUSIC UI TEST — CLEAN PANEL AUTHORITY v11
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- One geometry authority for Dance, Carry, Support, Travel, Community, Message, Music and DJ Live.
-- Party Stuff is intentionally NOT owned here; 108-party-stuff-menu.client.lua owns Party.

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local function vp()
 camera=workspace.CurrentCamera or camera
 return camera and camera.ViewportSize or Vector2.new(1280,720)
end

local function compactSize()
 local v=vp()
 return math.clamp(math.floor(v.X*.19),270,320),math.clamp(math.floor(v.Y*.72),470,560)
end

local function rightCompact(panel)
 if not panel then return end
 local w,h=compactSize()
 panel.AnchorPoint=Vector2.new(1,.5)
 panel.Position=UDim2.new(1,-12,.5,0)
 panel.Size=UDim2.fromOffset(w,h)
 panel.ClipsDescendants=true
end

local function hideWave(root)
 if not root then return end
 for _,d in ipairs(root:GetDescendants()) do
  if d:IsA("TextLabel") then
   local u=string.upper(tostring(d.Text or ""))
   if string.find(u,"LIVE WAVE",1,true) or string.find(u,"EQUALIZER",1,true) then
    local p=d.Parent
    if p and p:IsA("GuiObject") then p.Visible=false else d.Visible=false end
   end
  end
 end
end

-- DANCE ----------------------------------------------------------------------
local function isDanceRow(o)
 return o:IsA("TextButton") and string.sub(o.Name or "",1,6)=="Dance_"
end

local function polishDance()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 if not panel then return end
 rightCompact(panel)
 panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.42)
 panel:SetAttribute("BBYADancePanelGeometry","RIGHT_COMPACT_V11")
 local root=panel:FindFirstChild("BBYADanceCatalogV1")
 local list=root and root:FindFirstChild("DanceCatalogScroll")
 if not root or not list or not list:IsA("ScrollingFrame") then return end
 root.Position=UDim2.fromOffset(10,44)
 root.Size=UDim2.new(1,-20,1,-50)
 list.Position=UDim2.fromOffset(0,94)
 list.Size=UDim2.new(1,0,1,-94)
 list.Visible=true;list.Active=true;list.ScrollingEnabled=true
 list.ScrollingDirection=Enum.ScrollingDirection.Y
 list.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
 list.AutomaticCanvasSize=Enum.AutomaticSize.None
 list.ScrollBarThickness=4
 list.ClipsDescendants=true
 local count=0
 for _,b in ipairs(list:GetChildren()) do
  if isDanceRow(b) then
   count+=1;b.Visible=true;b.Active=true;b.Selectable=true;b.AutoButtonColor=true
   b.Size=UDim2.new(1,-6,0,38);b.TextSize=9;b.TextWrapped=false;b.TextTruncate=Enum.TextTruncate.AtEnd
  end
 end
 local layout=list:FindFirstChildWhichIsA("UIListLayout")
 local contentH=layout and layout.AbsoluteContentSize.Y+8 or 0
 list.CanvasSize=UDim2.fromOffset(0,math.max(contentH,list.AbsoluteSize.Y+2))
 root:SetAttribute("BBYADanceNativeScrollAuthority","V11")
 root:SetAttribute("BBYADanceVisibleRows",count)
end

-- CARRY ----------------------------------------------------------------------
local carryHelpers={}
local function clearCarryHelpers()
 for _,o in ipairs(carryHelpers) do if o and o.Parent then o:Destroy() end end
 table.clear(carryHelpers)
end
local function carryHelper(o)table.insert(carryHelpers,o);o:SetAttribute("BBYACarryV11",true);return o end
local function rootOf(plr)local ch=plr.Character;return ch and ch:FindFirstChild("HumanoidRootPart")end

local function initialCarry(panel)
 local hasBase=false
 for _,d in ipairs(panel:GetChildren()) do if d:GetAttribute("CarryDynamic")==true then hasBase=true break end end
 if hasBase then clearCarryHelpers();return end
 if #carryHelpers>0 then return end
 local remoteFolder=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
 local remote=remoteFolder and remoteFolder:FindFirstChild("SocialHangout")
 local mine=rootOf(player)
 local title=carryHelper(Instance.new("TextLabel"));title.BackgroundTransparency=1;title.Position=UDim2.fromOffset(18,54);title.Size=UDim2.new(1,-36,0,24);title.Text="Nearby players • consent required";title.TextColor3=Color3.fromRGB(166,160,172);title.Font=Enum.Font.Gotham;title.TextSize=10;title.Parent=panel
 if not mine then return end
 local near={}
 for _,p in ipairs(Players:GetPlayers()) do
  if p~=player then local r=rootOf(p);if r then local dist=(mine.Position-r.Position).Magnitude;if dist<=18 then table.insert(near,{p=p,dist=dist}) end end end
 end
 table.sort(near,function(a,b)return a.dist<b.dist end)
 if #near==0 then
  local empty=carryHelper(Instance.new("TextLabel"));empty.BackgroundTransparency=1;empty.Position=UDim2.fromOffset(18,92);empty.Size=UDim2.new(1,-36,0,44);empty.Text="No player within carry range.";empty.TextColor3=Color3.fromRGB(166,160,172);empty.Font=Enum.Font.GothamMedium;empty.TextSize=11;empty.TextWrapped=true;empty.Parent=panel
  return
 end
 local scroll=carryHelper(Instance.new("ScrollingFrame"));scroll.Position=UDim2.fromOffset(16,84);scroll.Size=UDim2.new(1,-32,1,-100);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=3;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Active=true;scroll.Parent=panel
 local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.Parent=scroll
 for _,item in ipairs(near) do
  local b=Instance.new("TextButton");b.Size=UDim2.new(1,-4,0,44);b.BackgroundColor3=Color3.fromRGB(39,34,45);b.BorderSizePixel=0;b.Text=string.format("  %s • %.0f studs",item.p.DisplayName,item.dist);b.TextXAlignment=Enum.TextXAlignment.Left;b.TextColor3=Color3.fromRGB(246,244,248);b.Font=Enum.Font.GothamSemibold;b.TextSize=11;b.Parent=scroll
  local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=b
  b.Activated:Connect(function()if remote then remote:FireServer("requestCarry",item.p.UserId) end end)
 end
end

local function polishCarry()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("CarryPanel")
 if not panel then return end
 rightCompact(panel)
 panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.42)
 panel:SetAttribute("BBYACarryPanelGeometry","RIGHT_COMPACT_V11")
 if panel.Visible then initialCarry(panel) else clearCarryHelpers() end
end

-- HUB: SUPPORT / TRAVEL / MUSIC ---------------------------------------------
local function hubParts()
 local club=pg:FindFirstChild("BBYAClubUI")
 local hub=club and club:FindFirstChild("HubPanel")
 if not hub then return end
 local content=nil
 for _,c in ipairs(hub:GetChildren()) do
  if c:IsA("Frame") and c.BackgroundTransparency==1 and c.Position.Y.Offset>=80 then content=c break end
 end
 if not content then
  for _,d in ipairs(hub:GetDescendants()) do if d:IsA("Frame") and d:FindFirstChild("SupportGrid") then content=d.Parent break end end
 end
 return club,hub,content
end

local function activeHubPage(content)
 if not content then return nil end
 for _,c in ipairs(content:GetChildren()) do if c:IsA("GuiObject") and c.Visible then return c end end
end

local function hubTitle(hub)
 for _,d in ipairs(hub:GetDescendants()) do
  if d:IsA("TextLabel") then
   local u=string.upper(tostring(d.Text or ""))
   if u=="MUSIC SYSTEM" or u=="SUPPORT" or u=="SUPPORT BBYA" or u=="TRAVEL" then return d end
  end
 end
end

local function openSupport()
 local club,hub,content=hubParts()
 if not hub or not content then return end
 local support=content:FindFirstChild("SupportGrid",true)
 support=support and support.Parent
 if not support then return end
 for _,c in ipairs(content:GetChildren()) do if c:IsA("GuiObject") then c.Visible=(c==support) end end
 local intro=hub:FindFirstChild("SupportIntro",true);if intro then intro.Visible=false end
 local t=hubTitle(hub);if t then t.Text="SUPPORT";t.TextSize=18 end
 hub.Visible=true
 local remotes=ReplicatedStorage:FindFirstChild("BBYAClubRemotes")
 local r=remotes and remotes:FindFirstChild("Support");if r and r:IsA("RemoteEvent") then r:FireServer("list") end
end

local supportBound=setmetatable({}, {__mode="k"})
local function bindSupport()
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 if not menu then return end
 for _,d in ipairs(menu:GetDescendants()) do
  if d:IsA("TextButton") and not supportBound[d] then
   local u=string.upper(tostring(d.Text or ""))
   if u=="SUPPORT" then supportBound[d]=true;d.Activated:Connect(function()task.defer(openSupport);task.delay(.05,openSupport)end) end
  end
 end
end

local function polishHub()
 local club,hub,content=hubParts()
 if not hub or not content or not hub.Visible then return end
 local active=activeHubPage(content)
 if not active then return end
 local name=string.upper(active.Name or "")
 local title=hubTitle(hub);local text=title and string.upper(tostring(title.Text or "")) or ""
 local isMusic=(name=="MUSIC" or text=="MUSIC SYSTEM")
 local isSupport=(name=="SUPPORT" or active:FindFirstChild("SupportGrid",true)~=nil or text=="SUPPORT")
 local isTravel=(name=="TRAVEL" or active:FindFirstChild("TravelDestinationScroller",true)~=nil or text=="TRAVEL")
 if isMusic then
  local v=vp();hub.AnchorPoint=Vector2.new(.5,.5);hub.Position=UDim2.fromScale(.5,.53);hub.Size=UDim2.fromOffset(math.clamp(v.X-100,720,980),math.clamp(v.Y-38,500,680));hub.BackgroundTransparency=math.max(hub.BackgroundTransparency,.62)
  local pc=hub:FindFirstChild("PlayerCard",true);local lc=hub:FindFirstChild("LibraryCard",true)
  if pc and pc:IsA("GuiObject") then pc.BackgroundTransparency=math.max(pc.BackgroundTransparency,.34) end
  if lc and lc:IsA("GuiObject") then lc.BackgroundTransparency=math.max(lc.BackgroundTransparency,.34) end
 elseif isSupport or isTravel then
  rightCompact(hub);hub.BackgroundTransparency=math.max(hub.BackgroundTransparency,.48);hideWave(hub)
  if isSupport then
   local intro=hub:FindFirstChild("SupportIntro",true);if intro then intro.Visible=false end
   local grid=hub:FindFirstChild("SupportGrid",true)
   if grid and grid:IsA("GuiObject") then grid.Position=UDim2.fromOffset(0,0);grid.Size=UDim2.fromScale(1,1);grid.BackgroundTransparency=math.max(grid.BackgroundTransparency,.50) end
   local sc=hub:FindFirstChild("SupportScroller",true)
   if sc and sc:IsA("ScrollingFrame") then sc.Active=true;sc.ScrollingEnabled=true;sc.ScrollBarThickness=4 end
  end
 end
end

-- COMMUNITY ------------------------------------------------------------------
local function polishCommunity()
 local club=pg:FindFirstChild("BBYAClubUI")
 local shade=club and club:FindFirstChild("CommunityOverlay",true)
 local panel=shade and shade:FindFirstChild("CommunityPanel",true)
 if not shade or not panel then return end
 local v=vp();local w=math.clamp(math.floor(v.X*.31),400,500);local h=math.clamp(math.floor(v.Y*.78),500,620)
 shade.BackgroundTransparency=1;shade.Active=false
 panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-12,.5,0);panel.Size=UDim2.fromOffset(w,h);panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.34);panel.ClipsDescendants=true
 hideWave(panel)
end

-- MESSAGE --------------------------------------------------------------------
local function polishMessage()
 local gui=pg:FindFirstChild("BBYADJWallUI")
 local panel=gui and gui:FindFirstChild("DJWallComposerPanel",true)
 if not panel then return end
 local v=vp();local w=math.clamp(math.floor(v.X*.42),520,720);local h=math.clamp(v.Y-24,500,760)
 for _,d in ipairs(gui:GetChildren()) do if d:IsA("Frame") and d~=panel and d.Size.X.Scale>=.95 and d.Size.Y.Scale>=.95 then d.BackgroundTransparency=1;d.Active=false end end
 panel.AnchorPoint=Vector2.new(1,.5);panel.Position=UDim2.new(1,-12,.5,0);panel.Size=UDim2.fromOffset(w,h);panel.ClipsDescendants=true;panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.24)
 local footer=panel:FindFirstChild("StickyFooter",true)
 if footer and footer:IsA("GuiObject") then footer.Visible=true;footer.ZIndex=120;for _,d in ipairs(footer:GetDescendants()) do if d:IsA("TextButton") then d.Visible=true;d.Active=true;d.Selectable=true;d.ZIndex=125 end end end
end

-- DJ LIVE --------------------------------------------------------------------
local function polishDJ()
 local gui=pg:FindFirstChild("BBYADeveloperDJUI")
 local panel=gui and gui:FindFirstChild("DeveloperDJMixerPanel",true)
 if not panel then return end
 panel.AnchorPoint=Vector2.new(0,0);panel.Position=UDim2.fromScale(0,0);panel.Size=UDim2.fromScale(1,1);panel.ClipsDescendants=true
 panel:SetAttribute("BBYADeveloperDJGeometry","FULL_PHONE_SCREEN_V11")
end

local function apply()
 polishDance();polishCarry();bindSupport();polishHub();polishCommunity();polishMessage();polishDJ()
end

local pending=false
local function schedule()
 if pending then return end;pending=true
 task.delay(.05,function()pending=false;apply()end)
end
pg.ChildAdded:Connect(schedule)
pg.DescendantAdded:Connect(function(d)if d:IsA("GuiObject") then schedule() end end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;schedule()end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(schedule) end

task.spawn(function()while true do apply();task.wait(.45) end end)
task.defer(apply)
print("[BBYA TEST] Clean panel authority v11 online: DJ locked full-screen; secondary panels compact; Party isolated")
