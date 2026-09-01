-- BBYA MUSIC UI TEST — COMPACT SECONDARY PANELS v6
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- MUSIC / MESSAGE / COMMUNITY stay large. Everything else uses the approved Dance/Carry footprint.
-- Panels use transparent glass. Long content uses touch-first vertical scroll.
-- v6 polish: native clickable Dance 212 list, compact title/margins, Support intro removed,
-- Support amount buttons get the full panel width, and the redundant BBYA menu entry is hidden.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local hubOriginal=setmetatable({}, {__mode="k"})
local menuHosts=setmetatable({}, {__mode="k"})

local function lower(v)return string.lower(tostring(v or "")) end
local function exemptName(name)
 local n=lower(name)
 if string.find(n,"music",1,true) then return true end
 if string.find(n,"message",1,true) then return true end
 if string.find(n,"community",1,true) then return true end
 if n=="comm" or n=="commpanel" or n=="commframe" or n=="commwindow" then return true end
 if string.match(n,"^comm[_%-]") or string.match(n,"[_%-]comm$") then return true end
 return false
end
local function hasExemptToken(obj)
 if exemptName(obj.Name) then return true end
 local p=obj.Parent
 for _=1,4 do
  if not p then break end
  if exemptName(p.Name) then return true end
  p=p.Parent
 end
 return false
end

local function viewport()
 camera=workspace.CurrentCamera or camera
 return camera and camera.ViewportSize or Vector2.new(1280,720)
end
local function compactSize()
 local vp=viewport()
 return math.clamp(math.floor(vp.X*.17),210,240),math.clamp(vp.Y-42,340,620)
end

local function isLargeBackdrop(obj,panel)
 if not obj:IsA("GuiObject") or obj==panel then return false end
 local a,p=obj.AbsoluteSize,panel.AbsoluteSize
 if p.X<=0 or p.Y<=0 then return false end
 return a.X>=p.X*.70 and a.Y>=p.Y*.45
end
local function applyGlass(panel)
 if not panel or not panel:IsA("GuiObject") then return end
 if panel:IsA("Frame") or panel:IsA("ScrollingFrame") then
  panel.BackgroundTransparency=math.max(panel.BackgroundTransparency,.42)
  panel:SetAttribute("BBYAGlassPanel","V6")
 end
 for _,d in ipairs(panel:GetDescendants()) do
  if (d:IsA("Frame") or d:IsA("ScrollingFrame")) and isLargeBackdrop(d,panel) then
   d.BackgroundTransparency=math.max(d.BackgroundTransparency,.52)
  end
 end
end
local function compactPanel(panel,authority)
 if not panel or not panel:IsA("GuiObject") or hasExemptToken(panel) then return end
 local w,h=compactSize()
 panel.AnchorPoint=Vector2.new(1,.5)
 panel.Position=UDim2.new(1,-12,.5,0)
 panel.Size=UDim2.fromOffset(w,h)
 panel.ClipsDescendants=true
 applyGlass(panel)
 panel:SetAttribute("BBYACompactSecondaryPanel",authority or "RIGHT_SLIM_V6")
end

local function findHubPageTitle(hub)
 for _,d in ipairs(hub:GetDescendants()) do
  if d:IsA("TextLabel") and d.Parent and d.Parent.Parent==hub then
   local t=string.upper(tostring(d.Text or ""))
   if t=="SUPPORT BBYA" or t=="SUPPORT" or t=="TRAVEL" or t=="MUSIC SYSTEM" then return d,t end
  end
 end
 return nil,nil
end
local function saveHub(hub)
 if hubOriginal[hub] then return end
 hubOriginal[hub]={AnchorPoint=hub.AnchorPoint,Position=hub.Position,Size=hub.Size,ClipsDescendants=hub.ClipsDescendants}
end
local function restoreHub(hub)
 local s=hubOriginal[hub]
 if not s then return end
 hub.AnchorPoint=s.AnchorPoint;hub.Position=s.Position;hub.Size=s.Size;hub.ClipsDescendants=s.ClipsDescendants
 hub:SetAttribute("BBYACompactSecondaryPanel",nil)
 applyGlass(hub)
end

local function patchSupportContent(hub)
 local intro=hub:FindFirstChild("SupportIntro",true)
 local gridCard=hub:FindFirstChild("SupportGrid",true)
 local scroller=hub:FindFirstChild("SupportScroller",true)
 if intro then intro.Visible=false;intro:SetAttribute("BBYASupportIntroRemoved","V6") end
 if gridCard and gridCard:IsA("GuiObject") then
  gridCard.Position=UDim2.fromOffset(0,0)
  gridCard.Size=UDim2.fromScale(1,1)
  gridCard.BackgroundTransparency=math.max(gridCard.BackgroundTransparency,.50)
 end
 if scroller and scroller:IsA("ScrollingFrame") then
  scroller.Position=UDim2.fromOffset(10,44)
  scroller.Size=UDim2.new(1,-20,1,-54)
  scroller.Active=true;scroller.ScrollingEnabled=true
  scroller.ScrollingDirection=Enum.ScrollingDirection.Y
  scroller.ScrollBarThickness=4
  local grid=scroller:FindFirstChildWhichIsA("UIGridLayout")
  if grid then
   grid.CellSize=UDim2.new(1,-6,0,58)
   grid.CellPadding=UDim2.new(0,0,0,8)
   task.defer(function()
    if scroller.Parent then scroller.CanvasSize=UDim2.fromOffset(0,math.max(scroller.AbsoluteSize.Y+2,grid.AbsoluteContentSize.Y+10)) end
   end)
  end
 end
end

local function patchHubPanel()
 local gui=pg:FindFirstChild("BBYAClubUI")
 local hub=gui and gui:FindFirstChild("HubPanel")
 if not hub then return end
 saveHub(hub);applyGlass(hub)
 local function apply()
  local title,t=findHubPageTitle(hub)
  if t=="MUSIC SYSTEM" then
   restoreHub(hub)
  elseif t=="SUPPORT BBYA" or t=="SUPPORT" then
   compactPanel(hub,"SUPPORT_RIGHT_SLIM_V6")
   if title then title.Text="SUPPORT";title.TextSize=17;title.TextWrapped=false end
   patchSupportContent(hub)
  elseif t=="TRAVEL" then
   compactPanel(hub,"TRAVEL_RIGHT_SLIM_V6")
  end
 end
 if not hub:GetAttribute("BBYACompactHubBoundV6") then
  hub:SetAttribute("BBYACompactHubBoundV6",true)
  hub:GetPropertyChangedSignal("Visible"):Connect(function()if hub.Visible then task.defer(apply);task.delay(.06,apply) end end)
  for _,d in ipairs(hub:GetDescendants()) do
   if d:IsA("TextLabel") then d:GetPropertyChangedSignal("Text"):Connect(function()task.defer(apply)end) end
  end
 end
 apply()
end

local function looksLikeVisualizer(frame)
 if not frame:IsA("Frame") then return false end
 local n=lower(frame.Name)
 if string.find(n,"equalizer",1,true) or string.find(n,"visualizer",1,true) or n=="wave" or n=="eqholder" then return true end
 local total,bars=0,0
 for _,c in ipairs(frame:GetChildren()) do
  if c:IsA("Frame") then total+=1;if c.AnchorPoint.Y>=.9 and c.Size.X.Scale>0 and c.Size.X.Scale<=.08 then bars+=1 end end
 end
 return total>=12 and bars>=math.floor(total*.75)
end
local function hideVisualizers(root)
 for _,d in ipairs(root:GetDescendants()) do if looksLikeVisualizer(d) then d.Visible=false;d:SetAttribute("BBYAVisualizerHidden","V6") end end
end

local function hideRedundantBrandButton()
 local gui=pg:FindFirstChild("BBYAClubUI")
 local dock=gui and gui:FindFirstChild("TopDock")
 if dock then
  for _,d in ipairs(dock:GetChildren()) do
   if d:IsA("TextButton") and string.upper(tostring(d.Text or ""))=="BBYA" then d.Visible=false;d.Active=false end
  end
 end
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local slot=menu and menu:FindFirstChild("Slot_BBYA",true)
 if slot and slot:IsA("GuiObject") then slot.Visible=false;slot:SetAttribute("BBYARedundantMenuSlotHidden","V6") end
end

local function menuSlot(obj)return obj:IsA("GuiObject") and string.sub(obj.Name or "",1,5)=="Slot_" end
local function ensureMenuScroll(drawer)
 if not drawer or not drawer:IsA("GuiObject") then return end
 compactPanel(drawer,"MAIN_MENU_RIGHT_SLIM_V6")
 local grid=drawer:FindFirstChildWhichIsA("UIGridLayout",true)
 local body=grid and grid.Parent
 if not body or not body:IsA("GuiObject") then return end
 local host=menuHosts[drawer]
 if not host or not host.Parent then
  for _,n in ipairs({"BBYAMainMenuScrollV4","BBYAMainMenuScrollV5","BBYAMainMenuScrollV6"}) do local o=drawer:FindFirstChild(n);if o then o:Destroy() end end
  host=Instance.new("ScrollingFrame");host.Name="BBYAMainMenuScrollV6"
  host.Position=UDim2.fromOffset(10,70);host.Size=UDim2.new(1,-20,1,-80)
  host.BackgroundTransparency=1;host.BorderSizePixel=0;host.ScrollBarThickness=4
  host.ScrollBarImageColor3=Color3.fromRGB(244,48,149);host.ScrollingDirection=Enum.ScrollingDirection.Y
  host.AutomaticCanvasSize=Enum.AutomaticSize.None;host.CanvasSize=UDim2.new();host.Active=true;host.ClipsDescendants=true;host.ZIndex=202;host.Parent=drawer
  local gl=Instance.new("UIGridLayout");gl.Name="CompactMenuGridV6";gl.CellSize=UDim2.new(.5,-4,0,46);gl.CellPadding=UDim2.fromOffset(7,7);gl.FillDirectionMaxCells=2;gl.SortOrder=Enum.SortOrder.LayoutOrder;gl.Parent=host
  gl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()if host.Parent then host.CanvasSize=UDim2.fromOffset(0,math.max(host.AbsoluteSize.Y+2,gl.AbsoluteContentSize.Y+8)) end end)
  menuHosts[drawer]=host
 end
 for _,d in ipairs(body:GetChildren()) do if menuSlot(d) then d.Parent=host end end
 for _,d in ipairs(drawer:GetDescendants()) do if d.Parent~=host and menuSlot(d) then d.Parent=host end end
 local brandSlot=host:FindFirstChild("Slot_BBYA")
 if brandSlot and brandSlot:IsA("GuiObject") then brandSlot.Visible=false end
 body.Visible=false
 local gl=host:FindFirstChild("CompactMenuGridV6")
 if gl and gl:IsA("UIGridLayout") then host.CanvasSize=UDim2.fromOffset(0,math.max(host.AbsoluteSize.Y+2,gl.AbsoluteContentSize.Y+8)) end
 drawer:SetAttribute("BBYAMainMenuBrowseMode","SCROLL")
end
local function patchCommandMenu()
 local gui=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=gui and gui:FindFirstChild("FeatureDrawer",true)
 if not drawer then return end
 ensureMenuScroll(drawer)
 if not drawer:GetAttribute("BBYAMainMenuScrollBoundV6") then
  drawer:SetAttribute("BBYAMainMenuScrollBoundV6",true)
  drawer:GetPropertyChangedSignal("Visible"):Connect(function()if drawer.Visible then task.defer(function()ensureMenuScroll(drawer)end);task.delay(.06,function()ensureMenuScroll(drawer)end) end end)
  drawer.DescendantAdded:Connect(function(d)if menuSlot(d) then task.defer(function()ensureMenuScroll(drawer)end) end end)
 end
end

local function polishDancePanel()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 local panel=gui and gui:FindFirstChild("DancePanel")
 if not panel then return end
 compactPanel(panel,"DANCE_RIGHT_SLIM_V6")
 panel:SetAttribute("BBYADanceCanvasAuthority","NATIVE_SCROLL_V7")
 panel:SetAttribute("BBYADanceBrowseMode","SCROLL")
 for _,d in ipairs(panel:GetChildren()) do
  if d:IsA("TextLabel") and string.find(string.upper(tostring(d.Text or "")),"DANCE",1,true) then
   d.Text="DANCE • 212";d.TextSize=15;d.TextWrapped=false;d.TextTruncate=Enum.TextTruncate.AtEnd
  end
 end
 local root=panel:FindFirstChild("BBYADanceCatalogV1")
 if root and root:IsA("GuiObject") then
  root.Position=UDim2.fromOffset(10,46);root.Size=UDim2.new(1,-20,1,-56)
  local list=root:FindFirstChild("DanceCatalogScroll")
  if list and list:IsA("ScrollingFrame") then
   list.Position=UDim2.fromOffset(0,98);list.Size=UDim2.new(1,0,1,-98);list.Visible=true;list.Active=true;list.ZIndex=80
  end
 end
 local carry=gui:FindFirstChild("CarryPanel")
 if carry then compactPanel(carry,"CARRY_RIGHT_SLIM_V6") end
end

local function patchNamedPanels(root)
 for _,d in ipairs(root:GetDescendants()) do
  if d:IsA("Frame") and (string.find(lower(d.Name),"panel",1,true) or d.Name=="FeatureDrawer") then
   applyGlass(d)
   if not hasExemptToken(d) and d.Name~="HubPanel" then
    local a=d.AbsoluteSize
    if d.Name=="DancePanel" or d.Name=="CarryPanel" or d.Name=="PartyStuffPanel" or d.Name=="FeatureDrawer" or a.X>=300 or a.Y>=300 then compactPanel(d) end
   end
  end
 end
end

local function applyAll()
 for _,g in ipairs(pg:GetChildren()) do if g:IsA("ScreenGui") then patchNamedPanels(g);hideVisualizers(g) end end
 polishDancePanel();patchHubPanel();patchCommandMenu();hideRedundantBrandButton()
end
local scheduled=false
local function schedule()
 if scheduled then return end
 scheduled=true
 task.delay(.10,function()scheduled=false;applyAll()end)
end
pg.ChildAdded:Connect(schedule)
pg.DescendantAdded:Connect(function(d)if d:IsA("Frame") or d:IsA("TextButton") or d:IsA("TextLabel") or d:IsA("ScrollingFrame") then schedule() end end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(schedule) end;schedule()end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(schedule) end
for i=1,14 do task.delay(i*.30,schedule) end
task.defer(schedule)
print("[BBYA TEST] Compact panels v6 online: native clickable Dance 212 + clean Support + glass + compact scroll menu")
