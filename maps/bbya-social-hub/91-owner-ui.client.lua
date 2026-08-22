-- BBYA SOCIAL HUB — OWNER STABLE UI v1
-- Single authority for DANCE/CARRY placement. Event-driven: no startup polling races.
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera
local applying=false
local bound={}

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
  if not applying then task.defer(function() if not applying then enforceAll() end end) end
 end)
end

function enforceSocial()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 if not gui then return end
 local dance=launcher(gui,"DANCE")
 local carry=launcher(gui,"CARRY")
 if not dance or not carry then return end
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local phone=UserInputService.TouchEnabled or vp.Y<850
 local size=phone and 40 or 46
 local left=6
 local lower=math.clamp(math.floor(vp.Y*.22),150,182)
 for _,b in ipairs({dance,carry}) do
  b.AnchorPoint=Vector2.new(0,1);b.Size=UDim2.fromOffset(size,size);b.TextSize=phone and 8 or 9;b.ZIndex=90
  local c=b:FindFirstChildOfClass("UICorner") or Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=b
  b:SetAttribute("BBYAStableLayout",true)
 end
 dance.Position=UDim2.new(0,left,1,-lower-size-6)
 carry.Position=UDim2.new(0,left,1,-lower)
 dance:SetAttribute("BBYAFeatures","9_DANCES+WAVE+CHEER+LAUGH+POINT+STOP")
 carry:SetAttribute("BBYAFeatures","NEARBY_SELECT+CONSENT+ACCEPT_DECLINE+CANCEL+DROP")
 local drawerScale=phone and math.clamp(vp.X/780,.46,.56) or .72
 for _,name in ipairs({"DancePanel","CarryPanel"}) do
  local p=gui:FindFirstChild(name)
  if p and p:IsA("Frame") then
   p.AnchorPoint=Vector2.new(0,1);p.Size=UDim2.fromOffset(390,390);p.Position=UDim2.new(0,left+size+8,1,-lower+size);p.ClipsDescendants=true;p.ZIndex=80
   scaleFor(p,"BBYAOwnerStableScale",drawerScale)
   p:SetAttribute("BBYAStableLayout",true)
   for _,d in ipairs(p:GetDescendants()) do if d:IsA("ScrollingFrame") then d.ScrollBarThickness=2 end end
   bindGuard(p,"Position");bindGuard(p,"Size")
  end
 end
 bindGuard(dance,"Position");bindGuard(dance,"Size");bindGuard(carry,"Position");bindGuard(carry,"Size")
end

function enforceCommunity()
 local gui=pg:FindFirstChild("BBYAClubUI");if not gui then return end
 local shade=gui:FindFirstChild("CommunityOverlay");if not shade or not shade:IsA("Frame") then return end
 local panel=shade:FindFirstChild("CommunityPanel");if not panel or not panel:IsA("Frame") then return end
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local phone=UserInputService.TouchEnabled or vp.Y<850
 panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.53);panel.Size=UDim2.fromOffset(560,480);panel.ClipsDescendants=true;panel.ZIndex=81
 scaleFor(panel,"BBYAOwnerCommunityScale",phone and ((vp.Y<650) and .60 or .66) or .82)
 local body=panel:FindFirstChild("CommunityScroller")
 if body and body:IsA("ScrollingFrame") then body.Position=UDim2.fromOffset(14,82);body.Size=UDim2.new(1,-28,1,-94);body.ScrollBarThickness=3;body.ScrollingEnabled=true;body.ClipsDescendants=true end
end

function enforceDock()
 local gui=pg:FindFirstChild("BBYAClubUI");if not gui then return end
 local dock=gui:FindFirstChild("TopDock");if not dock then return end
 for _,obj in ipairs(dock:GetChildren()) do
  if obj:IsA("TextButton") and string.upper((obj.Text or ""):gsub("%s+",""))=="BBYA" then obj.Visible=false;obj.Active=false;obj.Selectable=false end
 end
end

function enforceAll()
 if applying then return end
 applying=true
 pcall(enforceSocial);pcall(enforceCommunity);pcall(enforceDock)
 applying=false
end

task.defer(enforceAll)
pg.ChildAdded:Connect(function()task.defer(enforceAll)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 task.defer(enforceAll)
 if camera and not camera:GetAttribute("BBYAOwnerViewportBound") then
  camera:SetAttribute("BBYAOwnerViewportBound",true)
  camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(enforceAll)end)
 end
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(enforceAll)end) end
print("[BBYA] Owner Stable UI v1: deterministic Dance/Carry + full feature drawers")
