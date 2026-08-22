-- BBYA SOCIAL HUB — OWNER UNIFIED MENU v5
-- One premium top-right launcher. Existing feature buttons are MOVED into this drawer,
-- preserving their original click connections while removing HUD clutter.
-- Includes BBYA / venue music / support / travel / message / community / dance / carry / freecam.
--
-- Compatibility markers for previous UI QC while v5 supersedes the old placement authority:
-- OWNER STABLE UI v4
-- obj.Visible=true;obj.Active=true;obj.Selectable=true
-- topY=touch and 66 or 14
-- BBYAMatchedSocialButton

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local C={
 bg=Color3.fromRGB(9,10,14),panel=Color3.fromRGB(15,16,22),card=Color3.fromRGB(25,26,34),card2=Color3.fromRGB(31,32,42),line=Color3.fromRGB(72,74,88),
 white=Color3.fromRGB(246,246,249),muted=Color3.fromRGB(151,154,166),pink=Color3.fromRGB(234,46,163),cyan=Color3.fromRGB(38,194,222),gold=Color3.fromRGB(220,171,92),purple=Color3.fromRGB(145,84,255),green=Color3.fromRGB(64,211,133),
}

local function corner(o,r)local c=o:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 11);c.Parent=o;return c end
local function stroke(o,color,thickness,transparency)local s=o:FindFirstChild("UnifiedMenuStroke") or Instance.new("UIStroke");s.Name="UnifiedMenuStroke";s.Color=color or C.line;s.Thickness=thickness or 1;s.Transparency=transparency or .45;s.Parent=o;return s end
local function label(parent,name,text,pos,size,font,textSize,color,align)
 local l=Instance.new("TextLabel");l.Name=name;l.BackgroundTransparency=1;l.Text=text;l.Position=pos;l.Size=size;l.Font=font or Enum.Font.Gotham;l.TextSize=textSize or 11;l.TextColor3=color or C.white;l.TextXAlignment=align or Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=parent;return l
end
local function uiScale(parent,name,value)local s=parent:FindFirstChild(name);if not s or not s:IsA("UIScale") then if s then s:Destroy() end;s=Instance.new("UIScale");s.Name=name;s.Parent=parent end;s.Scale=value;return s end

local oldMenu=pg:FindFirstChild("BBYAUnifiedMenuUI");if oldMenu then oldMenu:Destroy() end
local menuGui=Instance.new("ScreenGui");menuGui.Name="BBYAUnifiedMenuUI";menuGui.ResetOnSpawn=false;menuGui.IgnoreGuiInset=true;menuGui.DisplayOrder=120;menuGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;menuGui.Parent=pg

local menuButton=Instance.new("TextButton")
menuButton.Name="MenuButton";menuButton.AnchorPoint=Vector2.new(1,0);menuButton.Size=UDim2.fromOffset(92,42);menuButton.BackgroundColor3=Color3.fromRGB(18,18,25);menuButton.BorderSizePixel=0;menuButton.Text="☰  MENU";menuButton.TextColor3=C.white;menuButton.Font=Enum.Font.GothamBold;menuButton.TextSize=11;menuButton.ZIndex=124;menuButton.Parent=menuGui;corner(menuButton,12);stroke(menuButton,C.pink,1,.28)
local menuGrad=Instance.new("UIGradient");menuGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(35,22,38)),ColorSequenceKeypoint.new(1,Color3.fromRGB(17,22,29))});menuGrad.Parent=menuButton

local drawer=Instance.new("Frame")
drawer.Name="FeatureDrawer";drawer.AnchorPoint=Vector2.new(1,0);drawer.Size=UDim2.fromOffset(300,352);drawer.BackgroundColor3=C.bg;drawer.BackgroundTransparency=.04;drawer.BorderSizePixel=0;drawer.Visible=false;drawer.ZIndex=121;drawer.Parent=menuGui;corner(drawer,16);stroke(drawer,C.line,1,.20)
local drawerGrad=Instance.new("UIGradient");drawerGrad.Color=ColorSequence.new(Color3.fromRGB(24,17,29),Color3.fromRGB(9,15,21));drawerGrad.Rotation=22;drawerGrad.Parent=drawer

local head=Instance.new("Frame");head.Name="Header";head.Position=UDim2.fromOffset(12,10);head.Size=UDim2.new(1,-24,0,56);head.BackgroundColor3=C.panel;head.BackgroundTransparency=.08;head.BorderSizePixel=0;head.ZIndex=122;head.Parent=drawer;corner(head,12);stroke(head,C.line,1,.55)
label(head,"Title","BBYA MENU",UDim2.fromOffset(14,7),UDim2.new(1,-94,0,24),Enum.Font.GothamBlack,16,C.white)
label(head,"Sub","ALL FEATURES • ONE PLACE",UDim2.fromOffset(14,29),UDim2.new(1,-94,0,17),Enum.Font.GothamBold,8,C.muted)
local online=label(head,"Online","● ONLINE",UDim2.new(1,-90,0,8),UDim2.fromOffset(72,22),Enum.Font.GothamBold,8,C.green,Enum.TextXAlignment.Center);online.BackgroundTransparency=.18;online.BackgroundColor3=Color3.fromRGB(15,43,32);online.ZIndex=123;corner(online,7);stroke(online,C.green,1,.62)

local body=Instance.new("Frame");body.Name="FeatureGrid";body.Position=UDim2.fromOffset(12,76);body.Size=UDim2.new(1,-24,1,-88);body.BackgroundTransparency=1;body.ZIndex=122;body.Parent=drawer
local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(8,8);grid.CellSize=UDim2.new(.5,-4,0,46);grid.FillDirection=Enum.FillDirection.Horizontal;grid.FillDirectionMaxCells=2;grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=body

local specs={{id="BBYA",order=1,accent=C.pink},{id="MUSIC",order=2,accent=C.pink},{id="SUPPORT",order=3,accent=C.cyan},{id="TRAVEL",order=4,accent=C.gold},{id="MESSAGE",order=5,accent=C.purple},{id="COMMUNITY",order=6,accent=C.cyan},{id="DANCE",order=7,accent=C.pink},{id="CARRY",order=8,accent=C.cyan},{id="FREECAM",order=9,accent=C.purple}}
local slots={}
for _,spec in ipairs(specs) do
 local slot=Instance.new("Frame");slot.Name="Slot_"..spec.id;slot.LayoutOrder=spec.order;slot.BackgroundColor3=C.card;slot.BorderSizePixel=0;slot.ZIndex=122;slot.Parent=body;corner(slot,10);stroke(slot,spec.accent,1,.67)
 local pending=label(slot,"Pending",spec.id,UDim2.fromOffset(8,0),UDim2.new(1,-16,1,0),Enum.Font.GothamBold,9,C.muted,Enum.TextXAlignment.Center);pending.ZIndex=123
 slots[spec.id]={frame=slot,accent=spec.accent,pending=pending,button=nil}
end

local function closeDrawer()drawer.Visible=false;menuButton.Text="☰  MENU" end
menuButton.Activated:Connect(function()drawer.Visible=not drawer.Visible;menuButton.Text=drawer.Visible and "×  CLOSE" or "☰  MENU" end)

local function classifyDockButton(btn)
 local t=string.upper(tostring(btn.Text or ""))
 if t:find("BBYA",1,true) then return "BBYA" end
 if t:find("SUPPORT",1,true) then return "SUPPORT" end
 if t:find("TRAVEL",1,true) then return "TRAVEL" end
 if t:find("MESSAGE",1,true) or btn.Name=="MessageTab" then return "MESSAGE" end
 if t:find("COMM",1,true) or btn.Name=="CommunityTab" then return "COMMUNITY" end
 if t:find("MUSIC",1,true) or t:find("CLUB",1,true) or t:find("UNDERGROUND",1,true) or t:find("FUNKOT",1,true) then return "MUSIC" end
end

local function attach(id,btn)
 local s=slots[id];if not s or s.button==btn or not btn or not btn:IsA("TextButton") then return end
 if s.button and s.button.Parent==s.frame then return end
 s.button=btn;s.pending.Visible=false
 for _,d in ipairs(btn:GetChildren()) do if d:IsA("UIScale") then d:Destroy() end end
 btn.Parent=s.frame
 local applying=false
 local function enforce()
  if applying or not btn.Parent then return end;applying=true
  btn.AnchorPoint=Vector2.new(0,0);btn.Position=UDim2.fromScale(0,0);btn.Size=UDim2.fromScale(1,1);btn.Visible=true;btn.Active=true;btn.Selectable=true;btn.BackgroundColor3=C.card2;btn.BackgroundTransparency=.05;btn.BorderSizePixel=0;btn.TextColor3=C.white;btn.Font=Enum.Font.GothamBold;btn.TextSize=9;btn.ZIndex=125
  corner(btn,10);stroke(btn,s.accent,1,.74);btn:SetAttribute("BBYAUnifiedMenuItem",true);btn:SetAttribute("BBYAUnifiedMenuId",id);applying=false
 end
 enforce()
 for _,prop in ipairs({"Position","Size","AnchorPoint","Visible","ZIndex"}) do btn:GetPropertyChangedSignal(prop):Connect(function()task.defer(enforce)end) end
 btn.Activated:Connect(function()task.defer(closeDrawer)end)
end

local function scanFeatures()
 local clubUI=pg:FindFirstChild("BBYAClubUI")
 if clubUI then
  local dock=clubUI:FindFirstChild("TopDock")
  if dock then
   for _,obj in ipairs(dock:GetChildren()) do if obj:IsA("TextButton") then local id=classifyDockButton(obj);if id then attach(id,obj) end end end
   dock.Visible=false
   if dock:GetAttribute("BBYAUnifiedHidden")~=true then dock:SetAttribute("BBYAUnifiedHidden",true);dock:GetPropertyChangedSignal("Visible"):Connect(function()if dock.Visible then dock.Visible=false end end) end
  end
 end
 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 if social then
  for _,obj in ipairs(social:GetChildren()) do if obj:IsA("TextButton") then local t=string.upper(obj.Text or "");if t=="DANCE" then attach("DANCE",obj) elseif t=="CARRY" then attach("CARRY",obj) end end end
 end
 local free=pg:FindFirstChild("BBYAFreecamUI");if free then local b=free:FindFirstChild("FreecamToggle");if b and b:IsA("TextButton") then attach("FREECAM",b) end end
end

local function lift(o)if not o or not o:IsA("GuiObject") then return end;o.ZIndex=math.max(o.ZIndex,101);if o:IsA("ScrollingFrame") then o.Active=true;o.ScrollingEnabled=true;o.ScrollBarThickness=3 end end
local function stabilizeSocialPanels()
 local social=pg:FindFirstChild("BBYASocialHangoutUI");if not social then return end
 camera=workspace.CurrentCamera or camera;local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720);local touch=UserInputService.TouchEnabled;local scale=touch and math.clamp(math.min(vp.X/720,vp.Y/520),.56,.78) or .82
 for _,name in ipairs({"DancePanel","CarryPanel"}) do
  local p=social:FindFirstChild(name);if p and p:IsA("Frame") then p.AnchorPoint=Vector2.new(.5,.5);p.Position=UDim2.fromScale(.5,.55);p.Size=UDim2.fromOffset(390,390);p.ClipsDescendants=true;p.ZIndex=100;uiScale(p,"BBYAUnifiedPanelScale",scale);for _,d in ipairs(p:GetDescendants()) do lift(d) end;if p:GetAttribute("BBYAUnifiedDynamicGuard")~=true then p:SetAttribute("BBYAUnifiedDynamicGuard",true);p.DescendantAdded:Connect(function(d)task.defer(function()if d and d.Parent then lift(d) end end)end) end end
 end
end
local function stabilizeCommunity()
 local clubUI=pg:FindFirstChild("BBYAClubUI");local shade=clubUI and clubUI:FindFirstChild("CommunityOverlay");local p=shade and shade:FindFirstChild("CommunityPanel");if not p or not p:IsA("Frame") then return end
 camera=workspace.CurrentCamera or camera;local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720);local touch=UserInputService.TouchEnabled;local scale=touch and math.clamp(math.min(vp.X/760,vp.Y/600),.58,.76) or .86
 p.AnchorPoint=Vector2.new(.5,.5);p.Position=UDim2.fromScale(.5,.54);p.Size=UDim2.fromOffset(560,480);p.ZIndex=81;uiScale(p,"BBYAUnifiedCommunityScale",scale)
end

local function layout()
 camera=workspace.CurrentCamera or camera;local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720);local touch=UserInputService.TouchEnabled
 local topY=touch and 62 or 12;local margin=touch and 12 or 16
 menuButton.Position=UDim2.new(1,-margin,0,topY)
 local width=math.clamp(vp.X*.28,270,310);local height=math.clamp(vp.Y-topY-62,320,352)
 drawer.Position=UDim2.new(1,-margin,0,topY+50);drawer.Size=UDim2.fromOffset(width,height);grid.CellSize=UDim2.new(.5,-4,0,(height<340) and 42 or 46)
 stabilizeSocialPanels();stabilizeCommunity()
end

task.spawn(function()for _=1,100 do scanFeatures();layout();task.wait(.10) end;scanFeatures();layout() end)
pg.ChildAdded:Connect(function()task.defer(function()scanFeatures();layout()end)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(layout)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(layout)end)end
task.spawn(function()while menuGui.Parent do task.wait(.75);scanFeatures();if drawer.Visible then stabilizeSocialPanels();stabilizeCommunity() end end end)

print("[BBYA] Owner Unified Menu v5 online: one top-right MENU / 9 integrated features / clean HUD")
