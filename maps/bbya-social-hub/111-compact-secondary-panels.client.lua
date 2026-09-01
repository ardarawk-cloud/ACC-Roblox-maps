-- BBYA MUSIC UI TEST — DJ LAUNCHER ADAPTER v1
-- TEST TARGET ONLY: Universe 10762005984 / Place 124607344716828
-- One-time module adapter only. It does NOT resize panels or own shell geometry.

local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local bound=false

local function attach()
 if bound then return true end
 local menu=pg:FindFirstChild("BBYACommandMenuUI")
 local dj=pg:FindFirstChild("BBYADeveloperDJUI")
 if not menu or not dj then return false end
 local list=menu:FindFirstChild("FeatureList",true)
 local drawer=menu:FindFirstChild("FeatureDrawer",true)
 local menuButton=menu:FindFirstChild("MenuButton",true)
 local panel=dj:FindFirstChild("DeveloperDJMixerPanel",true)
 local b=dj:FindFirstChild("FallbackDJButton",true) or dj:FindFirstChild("DeveloperDJMenuButton",true)
 if not list or not panel or not b or not b:IsA("TextButton") then return false end

 bound=true
 b.Parent=list
 b.LayoutOrder=9
 b.AnchorPoint=Vector2.new(0,0)
 b.Position=UDim2.new()
 b.Size=UDim2.new(1,-4,0,44)
 b.BackgroundColor3=Color3.fromRGB(29,29,39)
 b.BackgroundTransparency=0
 b.Text="DJ LIVE"
 b.TextColor3=Color3.fromRGB(246,246,249)
 b.Font=Enum.Font.GothamBold
 b.TextSize=10
 b.ZIndex=204
 local oldCorner=b:FindFirstChildOfClass("UICorner")
 if not oldCorner then local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,9);c.Parent=b end

 b.Activated:Connect(function()
  if drawer then drawer.Visible=false end
  if menuButton then menuButton.Text="MENU" end
 end)
 panel:GetPropertyChangedSignal("Visible"):Connect(function()
  if menuButton then menuButton.Visible=not panel.Visible end
  if panel.Visible and drawer then drawer.Visible=false end
 end)
 if menuButton then menuButton.Visible=not panel.Visible end
 print("[BBYA TEST] DJ launcher adopted into UI Kernel FeatureList")
 return true
end

task.defer(attach)
for i=1,8 do task.delay(i*.25,attach) end
pg.ChildAdded:Connect(function(child)
 if child.Name=="BBYACommandMenuUI" or child.Name=="BBYADeveloperDJUI" then task.defer(attach) end
end)
