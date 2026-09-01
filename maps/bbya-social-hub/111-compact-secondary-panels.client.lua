-- BBYA MUSIC UI TEST — MENU ABSOLUTE VISUAL MATCH v6
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Dance is READ-ONLY. Menu copies only Dance.AbsoluteSize (final on-screen pixels).
-- Menu keeps its own right dock and owns exactly one vertical scroll host.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local SIDE_RIGHT_OFFSET=96
local SIDE_TOP=8

local function isSlot(o)
 return o:IsA("GuiObject") and string.sub(o.Name or "",1,5)=="Slot_"
end

local function danceVisualSize()
 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 local dance=social and social:FindFirstChild("DancePanel")
 if not dance or not dance:IsA("GuiObject") then return nil end
 local a=dance.AbsoluteSize
 if a.X<40 or a.Y<40 then return nil end
 return Vector2.new(math.floor(a.X+.5),math.floor(a.Y+.5))
end

local function clearOldMenuScales(drawer)
 for _,name in ipairs({"BBYAMatchDanceScaleV4","BBYAMatchDanceScaleV5","BBYAMatchDanceScaleV6"}) do
  local s=drawer:FindFirstChild(name)
  if s and s:IsA("UIScale") then s:Destroy() end
 end
end

local function getSingleHost(drawer)
 local keep=nil
 for _,d in ipairs(drawer:GetChildren()) do
  if d:IsA("ScrollingFrame") and string.sub(d.Name or "",1,22)=="BBYAMainMenuScrollOnly" then
   if not keep then keep=d else d:Destroy() end
  end
 end
 if not keep then keep=Instance.new("ScrollingFrame");keep.Parent=drawer end
 keep.Name="BBYAMainMenuScrollOnlyV6"
 keep.Position=UDim2.fromOffset(10,72)
 keep.Size=UDim2.new(1,-20,1,-84)
 keep.BackgroundTransparency=1
 keep.BorderSizePixel=0
 keep.Active=true
 keep.ScrollingEnabled=true
 keep.ScrollingDirection=Enum.ScrollingDirection.Y
 keep.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
 keep.ScrollBarThickness=4
 keep.ScrollBarImageColor3=Color3.fromRGB(244,48,149)
 keep.AutomaticCanvasSize=Enum.AutomaticSize.None
 keep.ClipsDescendants=true
 keep.ZIndex=250

 local layout=keep:FindFirstChild("CompactMenuListV6")
 if not layout or not layout:IsA("UIListLayout") then
  for _,c in ipairs(keep:GetChildren()) do if c:IsA("UIListLayout") then c:Destroy() end end
  layout=Instance.new("UIListLayout")
  layout.Name="CompactMenuListV6"
  layout.Parent=keep
 end
 layout.FillDirection=Enum.FillDirection.Vertical
 layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
 layout.SortOrder=Enum.SortOrder.LayoutOrder
 layout.Padding=UDim.new(0,8)

 local pad=keep:FindFirstChildWhichIsA("UIPadding")
 if not pad then pad=Instance.new("UIPadding");pad.Parent=keep end
 pad.PaddingTop=UDim.new(0,2);pad.PaddingBottom=UDim.new(0,6)
 pad.PaddingLeft=UDim.new(0,1);pad.PaddingRight=UDim.new(0,1)
 return keep,layout
end

local applying=false
local function applyMenu()
 if applying then return end
 applying=true
 local gui=pg:FindFirstChild("BBYACommandMenuUI")
 local drawer=gui and gui:FindFirstChild("FeatureDrawer",true)
 if not drawer or not drawer:IsA("GuiObject") then applying=false;return end

 clearOldMenuScales(drawer)
 drawer.AnchorPoint=Vector2.new(1,0)
 drawer.Position=UDim2.new(1,-SIDE_RIGHT_OFFSET,0,SIDE_TOP)
 local visual=danceVisualSize()
 if visual then drawer.Size=UDim2.fromOffset(visual.X,visual.Y) end
 drawer.ClipsDescendants=true
 drawer.Active=true
 drawer.BackgroundTransparency=math.max(drawer.BackgroundTransparency,.42)
 drawer:SetAttribute("BBYAMainMenuAuthority","DANCE_ABSOLUTE_PIXELS_V6")

 local host,layout=getSingleHost(drawer)
 local slots={}
 for _,d in ipairs(drawer:GetDescendants()) do if isSlot(d) then table.insert(slots,d) end end
 for _,d in ipairs(slots) do if d.Parent~=host then d.Parent=host end end
 for _,d in ipairs(host:GetChildren()) do
  if isSlot(d) then
   d.Size=UDim2.new(1,-4,0,48)
   d.Visible=(d.Name~="Slot_BBYA")
   d.Active=true;d.ZIndex=251
   for _,x in ipairs(d:GetDescendants()) do
    if x:IsA("TextButton") then x.Active=true;x.Selectable=true;x.ZIndex=252
    elseif x:IsA("TextLabel") then x.ZIndex=252 end
   end
  end
 end
 task.defer(function()
  if host.Parent and layout.Parent then
   host.CanvasSize=UDim2.fromOffset(0,math.max(host.AbsoluteSize.Y+2,layout.AbsoluteContentSize.Y+10))
  end
 end)
 applying=false
end

pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYACommandMenuUI" or child.Name=="BBYASocialHangoutUI" then task.defer(applyMenu);task.delay(.2,applyMenu) end
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyMenu) end
 task.defer(applyMenu)
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyMenu) end
for i=1,8 do task.delay(i*.25,applyMenu) end
task.spawn(function()while true do task.wait(.5);applyMenu() end end)
task.defer(applyMenu)
print("[BBYA TEST] Menu v6: Dance READ-ONLY, absolute visual pixels, right dock")
