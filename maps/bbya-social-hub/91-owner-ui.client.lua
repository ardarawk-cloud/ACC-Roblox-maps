-- BBYA SOCIAL HUB — OWNER STABLE UI v5
-- Single authority for DANCE/CARRY placement, BBYA dock visibility, and FREECAM launcher sizing.
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local applying=false
local bound={}

local enforceAll

local function scaleFor(parent,name,value)
 local s=parent:FindFirstChild(name)
 if not s or not s:IsA("UIScale") then
  if s then s:Destroy() end
  s=Instance.new("UIScale");s.Name=name;s.Parent=parent
 end
 s.Scale=value
end

local function launcher(gui,wanted)
 for _,obj in ipairs(gui:GetChildren()) do
  if obj:IsA("TextButton") and string.upper(obj.Text or "")==wanted then return obj end
 end
end

local function bindGuard(obj,property)
 local key=tostring(obj)..":"..property
 if bound[key] then return end
 bound[key]=true
 obj:GetPropertyChangedSignal(property):Connect(function()
  if not applying then task.defer(function()if not applying then enforceAll() end end) end
 end)
end

local function liftDrawerObject(d)
 if not d or not d:IsA("GuiObject") then return end
 d.ZIndex=math.max(d.ZIndex,51)
 if d:IsA("ScrollingFrame") then
  d.ScrollBarThickness=2
  d.ScrollingEnabled=true
  d.Active=true
 end
end

local function bindDynamicDrawer(panel)
 if panel:GetAttribute("BBYADynamicZGuardV5")==true then return end
 panel:SetAttribute("BBYADynamicZGuardV5",true)
 panel.DescendantAdded:Connect(function(d)
  task.defer(function()if d and d.Parent then liftDrawerObject(d) end end)
 end)
 panel:GetPropertyChangedSignal("Visible"):Connect(function()
  if panel.Visible then task.defer(function()for _,d in ipairs(panel:GetDescendants()) do liftDrawerObject(d) end end) end
 end)
end

local function metrics()
 camera=workspace.CurrentCamera or camera
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local compact=UserInputService.TouchEnabled or vp.Y<850
 local size=compact and 44 or 48
 local lower=math.clamp(math.floor(vp.Y*.22),154,188)
 return vp,compact,size,lower
end

local function enforceSocial()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 if not gui then return end
 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 local dance=launcher(gui,"DANCE")
 local carry=launcher(gui,"CARRY")
 if not dance or not carry then return end
 local vp,phone,size,lower=metrics()
 local left=8
 for _,b in ipairs({dance,carry}) do
  b.AnchorPoint=Vector2.new(0,1);b.Size=UDim2.fromOffset(size,size);b.TextSize=phone and 8 or 9;b.ZIndex=90
  local c=b:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");c.CornerRadius=UDim.new(0,10);c.Parent=b
  b:SetAttribute("BBYAStableLayout",true)
 end
 dance.Position=UDim2.new(0,left,1,-lower-size-8)
 carry.Position=UDim2.new(0,left,1,-lower)
 dance:SetAttribute("BBYAFeatures","9_DANCES+WAVE+CHEER+LAUGH+POINT+STOP")
 carry:SetAttribute("BBYAFeatures","NEARBY_SELECT+CONSENT+ACCEPT_DECLINE+CANCEL+DROP")
 local drawerScale=phone and math.clamp(vp.X/720,.50,.64) or .76
 for _,name in ipairs({"DancePanel","CarryPanel"}) do
  local p=gui:FindFirstChild(name)
  if p and p:IsA("Frame") then
   p.AnchorPoint=Vector2.new(0,1);p.Size=UDim2.fromOffset(390,390);p.Position=UDim2.new(0,left+size+10,1,-lower+size);p.ClipsDescendants=true;p.ZIndex=50
   scaleFor(p,"BBYAOwnerStableScale",drawerScale)
   p:SetAttribute("BBYAStableLayout",true)
   for _,d in ipairs(p:GetDescendants()) do liftDrawerObject(d) end
   bindDynamicDrawer(p)
   bindGuard(p,"Position");bindGuard(p,"Size")
  end
 end
 bindGuard(dance,"Position");bindGuard(dance,"Size");bindGuard(carry,"Position");bindGuard(carry,"Size")
end

local function enforceFreecam()
 local gui=pg:FindFirstChild("BBYAFreecamUI")
 if not gui then return end
 local toggle=gui:FindFirstChild("FreecamToggle")
 if not toggle or not toggle:IsA("TextButton") then return end
 local _,phone,size,lower=metrics()
 toggle.AnchorPoint=Vector2.new(1,1)
 toggle.Position=UDim2.new(1,-8,1,-lower)
 toggle.Size=UDim2.fromOffset(size,size)
 toggle.TextSize=phone and 7 or 8
 toggle.ZIndex=90
 toggle:SetAttribute("BBYAMatchedSocialButton",true)
 local controls=gui:FindFirstChild("MobileControls")
 if controls and controls:IsA("Frame") then
  controls.AnchorPoint=Vector2.new(1,1)
  controls.Position=UDim2.new(1,-8,1,-lower-size-10)
  controls.ZIndex=88
 end
 bindGuard(toggle,"Position");bindGuard(toggle,"Size")
end

local function enforceCommunity()
 local gui=pg:FindFirstChild("BBYAClubUI");if not gui then return end
 local shade=gui:FindFirstChild("CommunityOverlay");if not shade or not shade:IsA("Frame") then return end
 local panel=shade:FindFirstChild("CommunityPanel");if not panel or not panel:IsA("Frame") then return end
 local vp,phone=metrics()
 panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53);panel.Size=UDim2.fromOffset(560,480);panel.ClipsDescendants=true;panel.ZIndex=81
 scaleFor(panel,"BBYAOwnerCommunityScale",phone and ((vp.Y<650) and .60 or .66) or .82)
 local body=panel:FindFirstChild("CommunityScroller")
 if body and body:IsA("ScrollingFrame") then body.Position=UDim2.fromOffset(14,82);body.Size=UDim2.new(1,-28,1,-94);body.ScrollBarThickness=3;body.ScrollingEnabled=true;body.ClipsDescendants=true end
end

local function enforceDock()
 local gui=pg:FindFirstChild("BBYAClubUI");if not gui then return end
 local dock=gui:FindFirstChild("TopDock");if not dock then return end
 local touch=UserInputService.TouchEnabled
 local topY=touch and 36 or 14
 dock.Position=UDim2.new(dock.Position.X.Scale,dock.Position.X.Offset,0,topY)
 for _,obj in ipairs(dock:GetChildren()) do
  if obj:IsA("TextButton") and string.upper((obj.Text or ""):gsub("%s+",""))=="BBYA" then
   obj.Visible=true;obj.Active=true;obj.Selectable=true;obj.ZIndex=96
   obj:SetAttribute("BBYABrandVisibleV5",true)
   bindGuard(obj,"Visible")
  end
 end
 bindGuard(dock,"Position")
end

enforceAll=function()
 if applying then return end
 applying=true
 pcall(enforceSocial);pcall(enforceFreecam);pcall(enforceCommunity);pcall(enforceDock)
 applying=false
end

task.defer(enforceAll)
pg.ChildAdded:Connect(function()task.defer(enforceAll)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 task.defer(enforceAll)
 if camera and not camera:GetAttribute("BBYAOwnerViewportBoundV5") then
  camera:SetAttribute("BBYAOwnerViewportBoundV5",true)
  camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(enforceAll)end)
 end
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(enforceAll)end) end
print("[BBYA] Owner Stable UI v5: raised dock / BBYA visible / Freecam matched / social drawers stable")
