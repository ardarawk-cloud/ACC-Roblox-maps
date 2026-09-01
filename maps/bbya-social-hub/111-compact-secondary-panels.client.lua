-- BBYA MUSIC UI TEST — DANCE LIST CANVAS HOTFIX v1
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- Temporary use of the compact-secondary slot while validating the 212 Dance catalog.
-- Keeps filtered rows visible after switching category/search by forcing automatic Y canvas.

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local function attach()
 local gui=pg:WaitForChild("BBYASocialHangoutUI",45)
 if not gui then return end
 local panel=gui:WaitForChild("DancePanel",20)
 if not panel then return end
 local root=panel:WaitForChild("BBYADanceCatalogV1",20)
 if not root then return end
 local list=root:WaitForChild("DanceCatalogScroll",10)
 local status=root:WaitForChild("DanceStatus",10)
 if not list or not status then return end
 local layout=list:FindFirstChildOfClass("UIListLayout")

 local function repair()
  if not list.Parent then return end
  list.Visible=true
  list.Active=true
  list.ScrollingEnabled=true
  list.AutomaticCanvasSize=Enum.AutomaticSize.Y
  list.CanvasSize=UDim2.new()
  list.CanvasPosition=Vector2.new(0,0)
  list.ScrollBarThickness=3
  for _,child in ipairs(list:GetChildren()) do
   if child:IsA("TextButton") then
    child.Visible=true
    child.ZIndex=54
   end
  end
 end

 local function settle()
  repair()
  task.defer(repair)
  task.delay(.03,repair)
  task.delay(.10,repair)
 end

 status:GetPropertyChangedSignal("Text"):Connect(settle)
 root.DescendantAdded:Connect(function(d)
  if d:IsA("TextButton") and d.Parent==list then task.defer(repair) end
 end)
 panel:GetPropertyChangedSignal("Visible"):Connect(function()
  if panel.Visible then settle() end
 end)
 if layout then layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()task.defer(repair)end) end

 local acc=0
 RunService.Heartbeat:Connect(function(dt)
  if not panel.Parent then return end
  if not panel.Visible then return end
  acc+=dt
  if acc<.15 then return end
  acc=0
  repair()
 end)

 panel:SetAttribute("BBYADanceCanvasHotfix","V1")
 settle()
 print("[BBYA TEST] Dance list canvas hotfix v1 active")
end

task.spawn(attach)
