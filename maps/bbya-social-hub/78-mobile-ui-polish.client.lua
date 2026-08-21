-- BBYA SOCIAL HUB — MOBILE UI POLISH v4
-- Thumb-sized DANCE/CARRY controls + safe panels + redundant BBYA dock tab removal.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local function findLauncher(gui,label)
 for _,obj in ipairs(gui:GetChildren()) do
  if obj:IsA("TextButton") and string.upper(obj.Text or "")==label then return obj end
 end
end

local function polishSocial()
 local gui=pg:FindFirstChild("BBYASocialHangoutUI")
 if not gui then return end
 local dance=findLauncher(gui,"DANCE")
 local carry=findLauncher(gui,"CARRY")
 if not dance or not carry then return end

 local function styleLauncher(b)
  b.Size=UDim2.fromOffset(48,48)
  b.TextSize=9
  b.Font=Enum.Font.GothamBlack
  b.ZIndex=46
  for _,c in ipairs(b:GetChildren()) do
   if c:IsA("UICorner") then c.CornerRadius=UDim.new(0,12) end
  end
 end
 styleLauncher(dance);styleLauncher(carry)

 local function layout()
  camera=workspace.CurrentCamera or camera
  local vp=camera and camera.ViewportSize or Vector2.new(1280,720)
  -- Keep the two thumb targets directly above the native left movement control.
  local bottom=math.clamp(math.floor(vp.Y*.205),138,172)
  dance.Position=UDim2.new(0,8,1,-bottom)
  carry.Position=UDim2.new(0,62,1,-bottom)

  local panelW=math.clamp(math.floor(vp.X*.48),300,360)
  local panelH=math.clamp(vp.Y-bottom-74,270,340)
  for _,name in ipairs({"DancePanel","CarryPanel"}) do
   local p=gui:FindFirstChild(name)
   if p and p:IsA("Frame") then
    p.AnchorPoint=Vector2.new(0,1)
    p.Position=UDim2.new(0,8,1,-bottom-8)
    p.Size=UDim2.fromOffset(panelW,panelH)
    p.ClipsDescendants=true
   end
  end
 end
 layout()
 if camera and not gui:GetAttribute("BBYAMobileViewportHook") then
  gui:SetAttribute("BBYAMobileViewportHook",true)
  camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
 end
end

local function polishDock()
 local gui=pg:FindFirstChild("BBYAClubUI")
 if not gui then return end
 local dock=gui:FindFirstChild("TopDock")
 if not dock or not dock:IsA("Frame") then return end
 local brand
 for _,obj in ipairs(dock:GetChildren()) do
  if obj:IsA("TextButton") and string.upper((obj.Text or ""):gsub("%s+",""))=="BBYA" then brand=obj break end
 end
 if not brand then return end
 local shift=math.max(70,brand.Size.X.Offset+6)
 brand.Visible=false;brand.Active=false;brand.Selectable=false
 for _,obj in ipairs(dock:GetChildren()) do
  if obj~=brand and obj:IsA("GuiObject") and not obj:GetAttribute("BBYABrandGapRemoved") then
   if obj.Position.X.Scale==0 and obj.Position.X.Offset>brand.Position.X.Offset then
    obj.Position=UDim2.new(obj.Position.X.Scale,obj.Position.X.Offset-shift,obj.Position.Y.Scale,obj.Position.Y.Offset)
    obj:SetAttribute("BBYABrandGapRemoved",true)
   end
  end
 end
 if not dock:GetAttribute("BBYABrandWidthRemoved") and dock.Size.X.Offset>shift+300 then
  dock.Size=UDim2.new(dock.Size.X.Scale,dock.Size.X.Offset-shift,dock.Size.Y.Scale,dock.Size.Y.Offset)
  dock:SetAttribute("BBYABrandWidthRemoved",true)
 end
end

local function applyAll()
 pcall(polishSocial)
 pcall(polishDock)
end

applyAll()
pg.ChildAdded:Connect(function()task.defer(applyAll)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(applyAll)end)
-- Community/MESSAGE tabs can be injected after the base dock; re-run briefly so they inherit the shifted dock.
task.spawn(function()
 for _=1,20 do task.wait(.75);applyAll() end
end)

print("[BBYA] Mobile UI polish v4 online: compact thumb DANCE/CARRY + redundant BBYA tab removed")
