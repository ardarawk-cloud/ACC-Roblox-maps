-- BBYA SOCIAL HUB — COMMAND MENU AUTHORITY v4
-- The old six-tab dock was repeatedly restoring scattered HUD buttons. This script
-- now owns the HUD: one small MENU launcher at the extreme top-right, with the
-- ORIGINAL feature buttons reparented into the drawer so their existing events survive.

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local clubUI=pg:WaitForChild("BBYAClubUI",30)
if not clubUI then return end
local dock=clubUI:WaitForChild("TopDock",30)
if not dock then return end

-- Kill the superseded experimental menu if it exists.
local superseded=pg:FindFirstChild("BBYAUnifiedMenuUI")
if superseded then superseded:Destroy() end
local old=pg:FindFirstChild("BBYACommandMenuUI")
if old then old:Destroy() end

local C={
 bg=Color3.fromRGB(9,10,14), panel=Color3.fromRGB(16,17,23), card=Color3.fromRGB(27,28,37),
 white=Color3.fromRGB(246,246,249), muted=Color3.fromRGB(152,155,168), line=Color3.fromRGB(72,75,89),
 pink=Color3.fromRGB(234,46,163), cyan=Color3.fromRGB(38,194,222), gold=Color3.fromRGB(220,171,92), purple=Color3.fromRGB(145,84,255),
}
local function corner(o,r)local x=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");x.CornerRadius=UDim.new(0,r or 10);x.Parent=o;return x end
local function stroke(o,c,tr)local x=o:FindFirstChild("CommandStroke") or Instance.new("UIStroke");x.Name="CommandStroke";x.Color=c or C.line;x.Thickness=1;x.Transparency=tr or .45;x.Parent=o;return x end
local function label(parent,text,pos,size,font,ts,color,align)
 local l=Instance.new("TextLabel");l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=ts or 10;l.TextColor3=color or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.ZIndex=204;l.Parent=parent;return l
end

local menuGui=Instance.new("ScreenGui")
menuGui.Name="BBYACommandMenuUI";menuGui.ResetOnSpawn=false;menuGui.IgnoreGuiInset=true;menuGui.DisplayOrder=220;menuGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;menuGui.Parent=pg

local menuButton=Instance.new("TextButton")
menuButton.Name="MenuButton";menuButton.AnchorPoint=Vector2.new(1,0);menuButton.Size=UDim2.fromOffset(78,38);menuButton.Position=UDim2.new(1,-6,0,6)
menuButton.BackgroundColor3=Color3.fromRGB(18,18,25);menuButton.BorderSizePixel=0;menuButton.Text="MENU";menuButton.TextColor3=C.white;menuButton.Font=Enum.Font.GothamBold;menuButton.TextSize=10;menuButton.ZIndex=210;menuButton.Parent=menuGui;corner(menuButton,10);stroke(menuButton,C.pink,.28)

local drawer=Instance.new("Frame")
drawer.Name="FeatureDrawer";drawer.AnchorPoint=Vector2.new(1,0);drawer.Position=UDim2.new(1,-6,0,50);drawer.Size=UDim2.fromOffset(282,304)
drawer.BackgroundColor3=C.bg;drawer.BackgroundTransparency=.03;drawer.BorderSizePixel=0;drawer.Visible=false;drawer.ZIndex=201;drawer.Parent=menuGui;corner(drawer,15);stroke(drawer,C.line,.20)

local header=Instance.new("Frame");header.Position=UDim2.fromOffset(10,10);header.Size=UDim2.new(1,-20,0,52);header.BackgroundColor3=C.panel;header.BorderSizePixel=0;header.ZIndex=202;header.Parent=drawer;corner(header,11);stroke(header,C.line,.58)
label(header,"BBYA MENU",UDim2.fromOffset(12,5),UDim2.new(1,-24,0,22),Enum.Font.GothamBlack,14,C.white)
label(header,"ALL FEATURES",UDim2.fromOffset(12,26),UDim2.new(1,-24,0,16),Enum.Font.GothamBold,8,C.muted)

local body=Instance.new("Frame");body.Position=UDim2.fromOffset(10,70);body.Size=UDim2.new(1,-20,1,-80);body.BackgroundTransparency=1;body.ZIndex=202;body.Parent=drawer
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(7,7);grid.CellSize=UDim2.new(.5,-4,0,40);grid.FillDirectionMaxCells=2;grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=body

local specList={
 {"BBYA",1,C.pink},{"MUSIC",2,C.pink},{"SUPPORT",3,C.cyan},{"TRAVEL",4,C.gold},{"MESSAGE",5,C.purple},
 {"COMMUNITY",6,C.cyan},{"DANCE",7,C.pink},{"CARRY",8,C.cyan},{"FREECAM",9,C.purple},
}
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

local attached={}
local function attach(id,btn)
 local slot=slots[id]
 if not slot or not btn or not btn:IsA("TextButton") then return end
 if attached[btn]~=id then
  attached[btn]=id;slot.button=btn;slot.placeholder.Visible=false;btn.Parent=slot.frame
  btn.Activated:Connect(function()drawer.Visible=false;menuButton.Text="MENU" end)
 end
 btn.AnchorPoint=Vector2.new(0,0);btn.Position=UDim2.fromScale(0,0);btn.Size=UDim2.fromScale(1,1)
 btn.Visible=true;btn.Active=true;btn.Selectable=true;btn.BackgroundColor3=C.card;btn.BackgroundTransparency=0;btn.BorderSizePixel=0
 btn.TextColor3=C.white;btn.Font=Enum.Font.GothamBold;btn.TextSize=8;btn.ZIndex=206;corner(btn,9);stroke(btn,slot.accent,.73)
 btn:SetAttribute("BBYACommandMenuItem",true);btn:SetAttribute("BBYACommandMenuId",id)
end

local function scanAndAttach()
 -- Hide the legacy dock container itself. Its buttons are moved into our drawer.
 dock.Visible=false
 for _,obj in ipairs(dock:GetChildren()) do
  if obj:IsA("TextButton") then local id=classifyDockButton(obj);if id then attach(id,obj) end end
 end
 -- Buttons already reparented on a previous pass still need their layout reasserted.
 for id,slot in pairs(slots) do if slot.button and slot.button.Parent then attach(id,slot.button) end end

 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 if social then
  for _,obj in ipairs(social:GetChildren()) do
   if obj:IsA("TextButton") then
    local t=string.upper(tostring(obj.Text or ""));if t=="DANCE" then attach("DANCE",obj) elseif t=="CARRY" then attach("CARRY",obj) end
   end
  end
 end
 local free=pg:FindFirstChild("BBYAFreecamUI")
 if free then local b=free:FindFirstChild("FreecamToggle");if b and b:IsA("TextButton") then attach("FREECAM",b) end end
end

local function layout()
 camera=workspace.CurrentCamera or camera
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 -- Extreme top-right as requested; no central dock.
 menuButton.Position=UDim2.new(1,-6,0,6)
 local w=math.clamp(math.floor(vp.X*.25),250,282)
 local h=math.clamp(math.floor(vp.Y*.45),276,304)
 drawer.Position=UDim2.new(1,-6,0,50);drawer.Size=UDim2.fromOffset(w,h)
 grid.CellSize=UDim2.new(.5,-4,0,h<292 and 36 or 40)
end

menuButton.Activated:Connect(function()
 drawer.Visible=not drawer.Visible;menuButton.Text=drawer.Visible and "CLOSE" or "MENU";scanAndAttach()
end)

-- If a legacy script tries to restore TopDock, immediately hide it again.
dock:GetPropertyChangedSignal("Visible"):Connect(function()if dock.Visible then dock.Visible=false end end)
pg.ChildAdded:Connect(function()task.defer(scanAndAttach)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(layout)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(layout)end) end

task.spawn(function()
 while menuGui.Parent do
  scanAndAttach();layout();task.wait(.18)
 end
end)

print("[BBYA] Command Menu v4 online: single extreme top-right MENU / legacy dock suppressed / 9 original features preserved")
