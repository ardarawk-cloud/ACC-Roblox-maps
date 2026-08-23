-- BBYA SOCIAL HUB — COMMAND MENU AUTHORITY v6
-- One compact launcher; original feature buttons are preserved and reparented into a side drawer.
-- v6 keeps gameplay center clear: MENU drawer + normal feature panels dock LEFT of MENU, never below it.
-- Bottom-right jump controls remain unobstructed. Critical consent modals are intentionally not moved.

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local clubUI=pg:WaitForChild("BBYAClubUI",30)
if not clubUI then return end
local dock=clubUI:WaitForChild("TopDock",30)
if not dock then return end

for _,name in ipairs({"BBYAUnifiedMenuUI","BBYACommandMenuUI"}) do local old=pg:FindFirstChild(name);if old then old:Destroy() end end

local C={
 bg=Color3.fromRGB(9,10,14),panel=Color3.fromRGB(16,17,23),card=Color3.fromRGB(27,28,37),
 white=Color3.fromRGB(246,246,249),muted=Color3.fromRGB(152,155,168),line=Color3.fromRGB(72,75,89),
 pink=Color3.fromRGB(234,46,163),cyan=Color3.fromRGB(38,194,222),gold=Color3.fromRGB(220,171,92),purple=Color3.fromRGB(145,84,255),
}
local function corner(o,r)local x=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o;return x end
local function stroke(o,c,tr)local x=o:FindFirstChild("CommandStroke") or Instance.new("UIStroke");x.Name="CommandStroke";x.Color=c or C.line;x.Thickness=1;x.Transparency=tr or .45;x.Parent=o;return x end
local function label(parent,text,pos,size,font,ts,color,align)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=color or C.white
 l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.ZIndex=204;l.Parent=parent;return l
end

local menuGui=Instance.new("ScreenGui")
menuGui.Name="BBYACommandMenuUI";menuGui.ResetOnSpawn=false;menuGui.IgnoreGuiInset=true;menuGui.DisplayOrder=220;menuGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;menuGui.Parent=pg
menuGui:SetAttribute("BBYACommandMenuAuthority","V6_MENU_SIDE_DOCK")

local menuButton=Instance.new("TextButton")
menuButton.Name="MenuButton";menuButton.AnchorPoint=Vector2.new(1,0);menuButton.Size=UDim2.fromOffset(74,36);menuButton.Position=UDim2.new(1,-12,0,8)
menuButton.BackgroundColor3=Color3.fromRGB(18,18,25);menuButton.BorderSizePixel=0;menuButton.Text="MENU";menuButton.TextColor3=C.white;menuButton.Font=Enum.Font.GothamBold;menuButton.TextSize=10;menuButton.ZIndex=210;menuButton.Parent=menuGui
corner(menuButton,10);stroke(menuButton,C.pink,.28)

local SIDE_RIGHT_OFFSET=96
local SIDE_TOP=8

local drawer=Instance.new("Frame")
drawer.Name="FeatureDrawer";drawer.AnchorPoint=Vector2.new(1,0);drawer.Position=UDim2.new(1,-SIDE_RIGHT_OFFSET,0,SIDE_TOP);drawer.Size=UDim2.fromOffset(320,308)
drawer.BackgroundColor3=C.bg;drawer.BackgroundTransparency=.025;drawer.BorderSizePixel=0;drawer.Visible=false;drawer.ZIndex=201;drawer.Parent=menuGui
corner(drawer,15);stroke(drawer,C.line,.18)

local header=Instance.new("Frame");header.Position=UDim2.fromOffset(10,10);header.Size=UDim2.new(1,-20,0,52);header.BackgroundColor3=C.panel;header.BorderSizePixel=0;header.ZIndex=202;header.Parent=drawer;corner(header,11);stroke(header,C.line,.58)
label(header,"BBYA MENU",UDim2.fromOffset(12,5),UDim2.new(1,-24,0,22),Enum.Font.GothamBlack,14,C.white)
label(header,"ALL FEATURES",UDim2.fromOffset(12,26),UDim2.new(1,-24,0,16),Enum.Font.GothamBold,8,C.muted)

local body=Instance.new("Frame");body.Position=UDim2.fromOffset(10,70);body.Size=UDim2.new(1,-20,1,-80);body.BackgroundTransparency=1;body.ZIndex=202;body.Parent=drawer
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(7,7);grid.CellSize=UDim2.new(.5,-4,0,40);grid.FillDirectionMaxCells=2;grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=body

local specList={{"BBYA",1,C.pink},{"MUSIC",2,C.pink},{"SUPPORT",3,C.cyan},{"TRAVEL",4,C.gold},{"MESSAGE",5,C.purple},{"COMMUNITY",6,C.cyan},{"DANCE",7,C.pink},{"CARRY",8,C.cyan},{"FREECAM",9,C.purple}}
local slots={}
for _,spec in ipairs(specList) do
 local slot=Instance.new("Frame");slot.Name="Slot_"..spec[1];slot.LayoutOrder=spec[2];slot.BackgroundColor3=C.card;slot.BorderSizePixel=0;slot.ZIndex=202;slot.Parent=body;corner(slot,9);stroke(slot,spec[3],.68)
 local waitLabel=label(slot,spec[1],UDim2.fromScale(0,0),UDim2.fromScale(1,1),Enum.Font.GothamBold,8,C.muted,Enum.TextXAlignment.Center)
 slots[spec[1]]={frame=slot,accent=spec[3],placeholder=waitLabel,button=nil}
end

local function classifyDockButton(btn)
 local t=string.upper(tostring(btn.Text or ""))
 if t:find("BBYA",1,true) then return "BBYA" end
 if t:find("SUPPORT",1,true) then return "SUPPORT" end
 if t:find("TRAVEL",1,true) then return "TRAVEL" end
 if t:find("MESSAGE",1,true) or btn.Name=="MessageTab" then return "MESSAGE" end
 if t:find("COMM",1,true) or btn.Name=="CommunityTab" then return "COMMUNITY" end
 if t:find("MUSIC",1,true) or t=="CLUB" or t=="UNDERGROUND" or t=="FUNKOT" then return "MUSIC" end
 return nil
end

local rebinding=false
local attached={}
local observed={}
local panelBound={}
local scanAndAttach
local dockKnownPanels
local docking=false

local function dockPanel(panel)
 if not panel or not panel:IsA("GuiObject") or not panel.Visible then return end
 docking=true
 panel.AnchorPoint=Vector2.new(1,0)
 panel.Position=UDim2.new(1,-SIDE_RIGHT_OFFSET,0,SIDE_TOP)
 panel:SetAttribute("BBYAMenuSideDock","LEFT_OF_MENU_V1")
 docking=false
 if not panelBound[panel] then
  panelBound[panel]=true
  panel:GetPropertyChangedSignal("Visible"):Connect(function()
   if panel.Visible then task.defer(function()dockPanel(panel)end);task.delay(.05,function()dockPanel(panel)end) end
  end)
  panel:GetPropertyChangedSignal("Position"):Connect(function()
   if not docking and panel.Visible then task.defer(function()dockPanel(panel)end) end
  end)
  panel:GetPropertyChangedSignal("AnchorPoint"):Connect(function()
   if not docking and panel.Visible then task.defer(function()dockPanel(panel)end) end
  end)
 end
end

local function findNamed(root,name)return root and root:FindFirstChild(name,true) or nil end

dockKnownPanels=function()
 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 dockPanel(findNamed(social,"DancePanel"))
 dockPanel(findNamed(social,"CarryPanel"))
 dockPanel(findNamed(clubUI,"HubPanel"))
 dockPanel(findNamed(clubUI,"CommunityPanel"))
 local wall=pg:FindFirstChild("BBYADJWallUI")
 dockPanel(findNamed(wall,"DJWallComposerPanel"))
 local musicLayer=clubUI:FindFirstChild("BBYACompactMusicLayerV7",true)
 dockPanel(findNamed(musicLayer,"CompactMusicCardV7"))
 dockPanel(findNamed(musicLayer,"PlaylistDrawerV7"))
 local roleGui=pg:FindFirstChild("BBYARolePanelUI")
 dockPanel(findNamed(roleGui,"RolePanel"))
end

local function closeDrawer()
 drawer.Visible=false;menuButton.Text="MENU"
 task.defer(dockKnownPanels);task.delay(.05,dockKnownPanels);task.delay(.15,dockKnownPanels)
end
local function enforceButton(id,btn)
 local slot=slots[id]
 if not slot or not btn or not btn:IsA("TextButton") then return end
 rebinding=true
 if btn.Parent~=slot.frame then btn.Parent=slot.frame end
 slot.button=btn;slot.placeholder.Visible=false;attached[btn]=id
 btn.AnchorPoint=Vector2.new(0,0);btn.Position=UDim2.fromScale(0,0);btn.Size=UDim2.fromScale(1,1);btn.Visible=true;btn.Active=true;btn.Selectable=true
 btn.BackgroundColor3=C.card;btn.BackgroundTransparency=0;btn.BorderSizePixel=0;btn.TextColor3=C.white;btn.Font=Enum.Font.GothamBold;btn.TextSize=8;btn.ZIndex=206
 corner(btn,9);stroke(btn,slot.accent,.73);btn:SetAttribute("BBYACommandMenuItem",true);btn:SetAttribute("BBYACommandMenuId",id)
 rebinding=false
 if not btn:GetAttribute("BBYACommandMenuGuardV6") then
  btn:SetAttribute("BBYACommandMenuGuardV6",true)
  btn.Activated:Connect(closeDrawer)
  btn.AncestryChanged:Connect(function(_,parent)if not rebinding and parent~=slot.frame then task.defer(scanAndAttach) end end)
  for _,prop in ipairs({"Position","Size","Visible"}) do
   btn:GetPropertyChangedSignal(prop):Connect(function()if not rebinding then task.defer(function()enforceButton(id,btn)end) end end)
  end
 end
end

local function observe(container)
 if not container or observed[container] then return end
 observed[container]=true
 container.DescendantAdded:Connect(function(d)
  if d:IsA("TextButton") then task.defer(scanAndAttach) end
  task.defer(dockKnownPanels);task.delay(.05,dockKnownPanels)
 end)
end

scanAndAttach=function()
 if rebinding or not menuGui.Parent then return end
 dock.Visible=false
 for _,obj in ipairs(dock:GetChildren()) do if obj:IsA("TextButton") then local id=classifyDockButton(obj);if id then enforceButton(id,obj) end end end
 for id,slot in pairs(slots) do if slot.button and slot.button.Parent~=slot.frame then enforceButton(id,slot.button) end end
 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 if social then
  observe(social)
  for _,obj in ipairs(social:GetChildren()) do if obj:IsA("TextButton") then local t=string.upper(tostring(obj.Text or ""));if t=="DANCE" then enforceButton("DANCE",obj) elseif t=="CARRY" then enforceButton("CARRY",obj) end end end
 end
 local free=pg:FindFirstChild("BBYAFreecamUI")
 if free then observe(free);local b=free:FindFirstChild("FreecamToggle");if b and b:IsA("TextButton") then enforceButton("FREECAM",b) end end
 observe(clubUI)
 local wall=pg:FindFirstChild("BBYADJWallUI");if wall then observe(wall) end
 local roleGui=pg:FindFirstChild("BBYARolePanelUI");if roleGui then observe(roleGui) end
 dockKnownPanels()
end

local function layout()
 camera=workspace.CurrentCamera or camera
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local touch=UserInputService.TouchEnabled
 menuButton.Position=UDim2.new(1,-12,0,8)
 local w=touch and math.clamp(math.floor(vp.X*.30),296,330) or math.clamp(math.floor(vp.X*.25),304,340)
 local h=(vp.Y<620) and 286 or 308
 drawer.AnchorPoint=Vector2.new(1,0);drawer.Position=UDim2.new(1,-SIDE_RIGHT_OFFSET,0,SIDE_TOP);drawer.Size=UDim2.fromOffset(w,h)
 grid.CellSize=UDim2.new(.5,-4,0,h<300 and 36 or 40)
 task.defer(dockKnownPanels);task.delay(.05,dockKnownPanels)
end

menuButton.Activated:Connect(function()
 drawer.Visible=not drawer.Visible;menuButton.Text=drawer.Visible and "CLOSE" or "MENU";scanAndAttach();layout()
end)
dock:GetPropertyChangedSignal("Visible"):Connect(function()if dock.Visible then dock.Visible=false end end)
dock.ChildAdded:Connect(function(d)if d:IsA("TextButton") then task.defer(scanAndAttach) end end)
observe(dock);observe(clubUI)
pg.ChildAdded:Connect(function(child)observe(child);task.defer(scanAndAttach);task.delay(.08,dockKnownPanels) end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(layout)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(layout)end) end

task.defer(function()scanAndAttach();layout();dockKnownPanels()end)
task.delay(.5,function()scanAndAttach();layout();dockKnownPanels()end)

print("[BBYA] Command Menu v6 online: MENU + normal feature panels dock left of MENU / center gameplay + jump zone clear")