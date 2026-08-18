-- BBYA SOCIAL HUB — LIVE MOBILE UI FIX v4.7
-- Real-device fix: touch detection, scaled panels, non-overlapping launchers.

local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local Workspace=game:GetService("Workspace")

local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local camera=Workspace.CurrentCamera

local function ensureScale(frame,name)
 local s=frame:FindFirstChild(name)
 if not s then s=Instance.new("UIScale");s.Name=name;s.Parent=frame end
 return s
end

local function isTouch()
 local v=camera and camera.ViewportSize or Vector2.new(1280,720)
 return UserInputService.TouchEnabled or v.Y < 760
end

local function tuneDance()
 local gui=pg:FindFirstChild("BBYA_DanceStudio")
 if not gui then return end
 local dock=gui:FindFirstChild("Dock")
 local panel=gui:FindFirstChild("DancePanel")
 if not panel or not dock then return end
 if isTouch() then
  local ps=ensureScale(panel,"BBYA_LiveTouchScale")
  ps.Scale=.72
  panel.AnchorPoint=Vector2.new(.5,.5)
  panel.Position=UDim2.new(.5,18,.5,0)
  panel.Size=UDim2.fromOffset(620,500)
  local ds=ensureScale(dock,"BBYA_LiveTouchScale")
  ds.Scale=.86
  dock.AnchorPoint=Vector2.new(0,.5)
  dock.Position=UDim2.new(0,8,.5,0)
  dock.Size=UDim2.fromOffset(58,286)
 else
  local ps=panel:FindFirstChild("BBYA_LiveTouchScale");if ps then ps.Scale=1 end
  local ds=dock:FindFirstChild("BBYA_LiveTouchScale");if ds then ds.Scale=1 end
 end
end

local function tuneSawer()
 local gui=pg:FindFirstChild("BBYA_UserSawerPanel")
 if not gui then return end
 local panel=gui:FindFirstChild("SawerPanel")
 local launcher=gui:FindFirstChild("SawerLauncher")
 if isTouch() then
  if panel then
   local s=ensureScale(panel,"BBYA_LiveTouchScale");s.Scale=.72
   panel.AnchorPoint=Vector2.new(1,1)
   panel.Position=UDim2.new(1,-18,1,-126)
  end
  if launcher and launcher:IsA("TextButton") then
   launcher.Size=UDim2.fromOffset(88,36)
   launcher.Position=UDim2.new(1,-105,1,-116)
   launcher.TextSize=12
  end
 else
  if panel then local s=panel:FindFirstChild("BBYA_LiveTouchScale");if s then s.Scale=1 end end
 end
end

local function tuneTopRight()
 for _,guiName in ipairs({"BBYA_MusicPanel","BBYA_SupportPanel"}) do
  local gui=pg:FindFirstChild(guiName)
  if gui and isTouch() then
   local panel=gui:FindFirstChild("Panel")
   if panel then
    local s=ensureScale(panel,"BBYA_LiveTouchScale")
    s.Scale=.82
    panel.Position=UDim2.new(1,-8,0,54)
   end
  end
 end
end

local function apply()
 tuneDance();tuneSawer();tuneTopRight()
 Workspace:SetAttribute("BBYAMobileLiveFix",isTouch() and "TOUCH_4.7" or "DESKTOP_4.7")
end

task.spawn(function()
 for _=1,20 do
  apply()
  task.wait(.35)
 end
end)

pg.ChildAdded:Connect(function()
 task.delay(.15,apply)
end)
if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(apply) end

print("[BBYA] Live Mobile UI Fix v4.7 loaded")
