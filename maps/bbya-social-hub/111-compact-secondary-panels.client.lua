-- BBYA MUSIC UI TEST — MENU-ONLY DANCE-SIZE AUTHORITY v3
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Owns ONLY main feature menu geometry + vertical scrolling.
-- Geometry copies DancePanel exactly when available.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local function fallbackSize()
 camera=workspace.CurrentCamera or camera
 local v=camera and camera.ViewportSize or Vector2.new(1280,720)
 return math.clamp(math.floor(v.X*.19),270,320),math.clamp(math.floor(v.Y*.72),470,560)
end
local function isSlot(o)return o:IsA("GuiObject") and string.sub(o.Name or "",1,5)=="Slot_" end

local function applyMenu()
 local gui=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=gui and gui:FindFirstChild("FeatureDrawer",true)
 if not drawer or not drawer:IsA("GuiObject") then return end

 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 local dance=social and social:FindFirstChild("DancePanel")
 drawer.AnchorPoint=Vector2.new(1,.5)
 drawer.Position=UDim2.new(1,-12,.5,0)
 if dance then
  drawer.AnchorPoint=dance.AnchorPoint
  drawer.Position=dance.Position
  drawer.Size=dance.Size
 else
  local w,h=fallbackSize();drawer.Size=UDim2.fromOffset(w,h)
 end
 drawer.ClipsDescendants=true;drawer.Active=true
 if drawer:IsA("Frame") or drawer:IsA("ScrollingFrame") then drawer.BackgroundTransparency=math.max(drawer.BackgroundTransparency,.42) end
 drawer:SetAttribute("BBYAMainMenuAuthority","MATCH_DANCE_SCROLL_V3")

 local host=drawer:FindFirstChild("BBYAMainMenuScrollOnlyV2") or drawer:FindFirstChild("BBYAMainMenuScrollOnlyV1")
 if host and host.Name~="BBYAMainMenuScrollOnlyV3" then host.Name="BBYAMainMenuScrollOnlyV3" end
 if not host then
  host=Instance.new("ScrollingFrame")
  host.Name="BBYAMainMenuScrollOnlyV3"
  host.Position=UDim2.fromOffset(10,72)
  host.Size=UDim2.new(1,-20,1,-84)
  host.BackgroundTransparency=1;host.BorderSizePixel=0
  host.Active=true;host.ScrollingEnabled=true;host.ScrollingDirection=Enum.ScrollingDirection.Y
  host.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable;host.ScrollBarThickness=4
  host.ScrollBarImageColor3=Color3.fromRGB(244,48,149)
  host.AutomaticCanvasSize=Enum.AutomaticSize.None;host.CanvasSize=UDim2.new();host.ClipsDescendants=true;host.ZIndex=250;host.Parent=drawer
  local layout=Instance.new("UIListLayout");layout.Name="CompactMenuListV3";layout.FillDirection=Enum.FillDirection.Vertical;layout.HorizontalAlignment=Enum.HorizontalAlignment.Center;layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Padding=UDim.new(0,8);layout.Parent=host
  local pad=Instance.new("UIPadding");pad.PaddingTop=UDim.new(0,2);pad.PaddingBottom=UDim.new(0,6);pad.PaddingLeft=UDim.new(0,1);pad.PaddingRight=UDim.new(0,1);pad.Parent=host
 end
 local layout=host:FindFirstChildWhichIsA("UIListLayout");if layout then layout.Name="CompactMenuListV3" end

 local sourceParents={}
 for _,d in ipairs(drawer:GetDescendants()) do
  if isSlot(d) and d.Parent~=host then sourceParents[d.Parent]=true;d.Parent=host end
 end
 for _,d in ipairs(host:GetChildren()) do
  if isSlot(d) then
   d.Size=UDim2.new(1,-4,0,48);d.Visible=(d.Name~="Slot_BBYA");d.Active=true;d.ZIndex=math.max(d.ZIndex,251)
   for _,x in ipairs(d:GetDescendants()) do
    if x:IsA("TextButton") then x.Active=true;x.Selectable=true;x.ZIndex=math.max(x.ZIndex,252)
    elseif x:IsA("TextLabel") then x.ZIndex=math.max(x.ZIndex,252) end
   end
  end
 end
 for p in pairs(sourceParents) do if p and p.Parent and p:IsA("GuiObject") and p~=drawer and p~=host then p.Visible=false end end
 host.Visible=true
 if layout then task.defer(function()if host.Parent then host.CanvasSize=UDim2.fromOffset(0,math.max(host.AbsoluteSize.Y+2,layout.AbsoluteContentSize.Y+10)) end end) end

 if not drawer:GetAttribute("BBYAMainMenuBoundV3") then
  drawer:SetAttribute("BBYAMainMenuBoundV3",true)
  drawer:GetPropertyChangedSignal("Visible"):Connect(function()if drawer.Visible then task.defer(applyMenu);task.delay(.06,applyMenu) end end)
  drawer.DescendantAdded:Connect(function(d)if isSlot(d) then task.defer(applyMenu) end end)
 end
end

pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYACommandMenuUI" or child.Name=="BBYASocialHangoutUI" then task.defer(applyMenu);task.delay(.2,applyMenu) end
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyMenu) end;task.defer(applyMenu)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyMenu) end
for i=1,8 do task.delay(i*.25,applyMenu) end
task.defer(applyMenu)
print("[BBYA TEST] Main menu v3 online: exact DancePanel geometry + scroll")
