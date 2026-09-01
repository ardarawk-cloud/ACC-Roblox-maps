-- BBYA MUSIC UI TEST — MENU-ONLY DANCE VISUAL AUTHORITY v4
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Owns ONLY main feature menu geometry + vertical scrolling.
-- Exactly one scroll host. Copies DancePanel Size AND UIScale.

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
local function danceMetrics()
 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 local dance=social and social:FindFirstChild("DancePanel")
 if not dance then return nil,1 end
 local s=dance:FindFirstChild("BBYAViewportScaleV1") or dance:FindFirstChildWhichIsA("UIScale")
 return dance,s and s.Scale or 1
end
local function applyScale(target,value)
 local s=target:FindFirstChild("BBYAMatchDanceScaleV4")
 if not s then s=Instance.new("UIScale");s.Name="BBYAMatchDanceScaleV4";s.Parent=target end
 s.Scale=value
end
local function getSingleHost(drawer)
 local keep=nil
 for _,d in ipairs(drawer:GetChildren()) do
  if d:IsA("ScrollingFrame") and string.sub(d.Name or "",1,22)=="BBYAMainMenuScrollOnly" then
   if not keep then keep=d else d:Destroy() end
  end
 end
 if not keep then
  keep=Instance.new("ScrollingFrame");keep.Parent=drawer
 end
 keep.Name="BBYAMainMenuScrollOnlyV4"
 keep.Position=UDim2.fromOffset(10,72);keep.Size=UDim2.new(1,-20,1,-84)
 keep.BackgroundTransparency=1;keep.BorderSizePixel=0;keep.Active=true;keep.ScrollingEnabled=true
 keep.ScrollingDirection=Enum.ScrollingDirection.Y;keep.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
 keep.ScrollBarThickness=4;keep.ScrollBarImageColor3=Color3.fromRGB(244,48,149)
 keep.AutomaticCanvasSize=Enum.AutomaticSize.None;keep.ClipsDescendants=true;keep.ZIndex=250
 local layouts={}
 for _,c in ipairs(keep:GetChildren()) do if c:IsA("UIListLayout") then table.insert(layouts,c) end end
 local layout=layouts[1]
 for i=2,#layouts do layouts[i]:Destroy() end
 if not layout then layout=Instance.new("UIListLayout");layout.Parent=keep end
 layout.Name="CompactMenuListV4";layout.FillDirection=Enum.FillDirection.Vertical;layout.HorizontalAlignment=Enum.HorizontalAlignment.Center;layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Padding=UDim.new(0,8)
 if not keep:FindFirstChildWhichIsA("UIPadding") then
  local pad=Instance.new("UIPadding");pad.PaddingTop=UDim.new(0,2);pad.PaddingBottom=UDim.new(0,6);pad.PaddingLeft=UDim.new(0,1);pad.PaddingRight=UDim.new(0,1);pad.Parent=keep
 end
 return keep,layout
end

local applying=false
local function applyMenu()
 if applying then return end;applying=true
 local gui=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=gui and gui:FindFirstChild("FeatureDrawer",true)
 if not drawer or not drawer:IsA("GuiObject") then applying=false;return end
 local dance,scale=danceMetrics()
 drawer.AnchorPoint=Vector2.new(1,.5);drawer.Position=UDim2.new(1,-12,.5,0)
 if dance then drawer.AnchorPoint=dance.AnchorPoint;drawer.Position=dance.Position;drawer.Size=dance.Size else local w,h=fallbackSize();drawer.Size=UDim2.fromOffset(w,h) end
 applyScale(drawer,scale)
 drawer.ClipsDescendants=true;drawer.Active=true
 drawer.BackgroundTransparency=math.max(drawer.BackgroundTransparency,.42)
 drawer:SetAttribute("BBYAMainMenuAuthority","MATCH_DANCE_SIZE_SCALE_SCROLL_V4")

 local host,layout=getSingleHost(drawer)
 local sourceParents={}
 local slots={}
 for _,d in ipairs(drawer:GetDescendants()) do if isSlot(d) then table.insert(slots,d) end end
 for _,d in ipairs(slots) do
  if d.Parent~=host then sourceParents[d.Parent]=true;d.Parent=host end
 end
 for _,d in ipairs(host:GetChildren()) do
  if isSlot(d) then
   d.Size=UDim2.new(1,-4,0,48);d.Visible=(d.Name~="Slot_BBYA");d.Active=true;d.ZIndex=251
   for _,x in ipairs(d:GetDescendants()) do
    if x:IsA("TextButton") then x.Active=true;x.Selectable=true;x.ZIndex=252 elseif x:IsA("TextLabel") then x.ZIndex=252 end
   end
  end
 end
 for p in pairs(sourceParents) do if p and p.Parent and p:IsA("GuiObject") and p~=drawer and p~=host then p.Visible=false end end
 host.Visible=true
 task.defer(function()if host.Parent and layout.Parent then host.CanvasSize=UDim2.fromOffset(0,math.max(host.AbsoluteSize.Y/math.max(scale,.01)+2,layout.AbsoluteContentSize.Y+10)) end end)
 applying=false
end

pg.ChildAdded:Connect(function(child)if child.Name=="BBYACommandMenuUI" or child.Name=="BBYASocialHangoutUI" then task.defer(applyMenu);task.delay(.2,applyMenu) end end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyMenu) end;task.defer(applyMenu)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyMenu) end
for i=1,8 do task.delay(i*.25,applyMenu) end
task.spawn(function()while true do task.wait(.75);applyMenu() end end)
task.defer(applyMenu)
print("[BBYA TEST] Main menu v4 online: one host + exact Dance visual scale")
