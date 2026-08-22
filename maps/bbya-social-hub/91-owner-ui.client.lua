-- BBYA SOCIAL HUB — OWNER UI COMPATIBILITY GUARD v6
-- Menu ownership moved to 56-dock-stability.client.lua (Command Menu v4).
-- This script now only keeps social/community panels readable on mobile and
-- removes the superseded duplicate menu if a stale session created it.

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=workspace.CurrentCamera

local function scaleFor(parent,name,value)
 local s=parent:FindFirstChild(name)
 if not s or not s:IsA("UIScale") then if s then s:Destroy() end;s=Instance.new("UIScale");s.Name=name;s.Parent=parent end
 s.Scale=value
end

local function lift(o)
 if not o or not o:IsA("GuiObject") then return end
 o.ZIndex=math.max(o.ZIndex,100)
 if o:IsA("ScrollingFrame") then o.Active=true;o.ScrollingEnabled=true;o.ScrollBarThickness=3 end
end

local function stabilize()
 local old=pg:FindFirstChild("BBYAUnifiedMenuUI");if old then old:Destroy() end
 camera=workspace.CurrentCamera or camera
 local vp=(camera and camera.ViewportSize) or Vector2.new(1280,720)
 local touch=UserInputService.TouchEnabled

 local social=pg:FindFirstChild("BBYASocialHangoutUI")
 if social then
  local sc=touch and math.clamp(math.min(vp.X/720,vp.Y/520),.56,.78) or .82
  for _,name in ipairs({"DancePanel","CarryPanel"}) do
   local p=social:FindFirstChild(name)
   if p and p:IsA("Frame") then
    p.AnchorPoint=Vector2.new(.5,.5);p.Position=UDim2.fromScale(.5,.55);p.Size=UDim2.fromOffset(390,390);p.ClipsDescendants=true;p.ZIndex=100
    scaleFor(p,"BBYAOwnerPanelScaleV6",sc)
    for _,d in ipairs(p:GetDescendants()) do lift(d) end
   end
  end
 end

 local clubUI=pg:FindFirstChild("BBYAClubUI")
 local shade=clubUI and clubUI:FindFirstChild("CommunityOverlay")
 local p=shade and shade:FindFirstChild("CommunityPanel")
 if p and p:IsA("Frame") then
  local sc=touch and math.clamp(math.min(vp.X/760,vp.Y/600),.58,.76) or .86
  p.AnchorPoint=Vector2.new(.5,.5);p.Position=UDim2.fromScale(.5,.54);p.Size=UDim2.fromOffset(560,480);p.ZIndex=81
  scaleFor(p,"BBYAOwnerCommunityScaleV6",sc)
 end
end

task.defer(stabilize)
pg.ChildAdded:Connect(function()task.defer(stabilize)end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()camera=workspace.CurrentCamera;task.defer(stabilize)end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(stabilize)end) end

print("[BBYA] Owner UI compatibility v6 online: duplicate menu retired / mobile panels stable")
