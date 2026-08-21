-- BBYA SOCIAL HUB — MOBILE UI POLISH v5
-- Vertical thumb-sized DANCE/CARRY controls on the extreme left edge + compact drawers.
-- Also removes the redundant BBYA top-dock tab.

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

 local vp=(workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280,720)
 local size=42
 local left=3
 local baseBottom=math.clamp(math.floor(vp.Y*.22),150,184)

 local function style(b)
  b.AnchorPoint=Vector2.new(0,1)
  b.Size=UDim2.fromOffset(size,size)
  b.TextSize=8
  b.Font=Enum.Font.GothamBlack
  b.ZIndex=70
  local c=b:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
  c.CornerRadius=UDim.new(0,10);c.Parent=b
 end
 style(dance);style(carry)

 -- Vertical stack requested by owner: DANCE above CARRY, both nearly touching left screen edge.
 dance.Position=UDim2.new(0,left,1,-baseBottom-size-6)
 carry.Position=UDim2.new(0,left,1,-baseBottom)

 local panelW=math.clamp(math.floor(vp.X*.38),246,300)
 local panelH=math.clamp(math.floor(vp.Y*.43),220,286)
 for _,name in ipairs({"DancePanel","CarryPanel"}) do
  local p=gui:FindFirstChild(name)
  if p and p:IsA("Frame") then
   p.AnchorPoint=Vector2.new(0,1)
   p.Position=UDim2.new(0,left,1,-baseBottom-size-12)
   p.Size=UDim2.fromOffset(panelW,panelH)
   p.ClipsDescendants=true
   local c=p:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
   c.CornerRadius=UDim.new(0,12);c.Parent=p
  end
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
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 camera=workspace.CurrentCamera
 task.defer(applyAll)
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyAll) end

task.spawn(function()
 for _=1,40 do task.wait(.35);applyAll() end
end)

print("[BBYA] Mobile UI polish v5 online: vertical left-edge DANCE/CARRY")
