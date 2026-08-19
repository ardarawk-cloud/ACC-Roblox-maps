local Players=game:GetService("Players")
local player=Players.LocalPlayer
local gui=player:WaitForChild("PlayerGui"):WaitForChild("BBYAClubUI")
local menu=gui:WaitForChild("ClubMenu")
local cam=workspace.CurrentCamera

local function clamp(v,a,b)return math.max(a,math.min(b,v))end
local function apply()
 local vp=cam and cam.ViewportSize or Vector2.new(1280,720)
 local width=clamp(math.floor(vp.X*0.39),286,330)
 local top=54
 local bottom=18
 local height=clamp(vp.Y-top-bottom,330,520)
 menu.AnchorPoint=Vector2.new(1,0)
 menu.Position=UDim2.fromOffset(vp.X-10,top)
 menu.Size=UDim2.fromOffset(width,height)
 menu.ClipsDescendants=true
 for _,o in ipairs(menu:GetDescendants()) do
  if o:IsA("ScrollingFrame") then
   o.AutomaticCanvasSize=Enum.AutomaticSize.Y
   o.CanvasSize=UDim2.new()
   o.ScrollingDirection=Enum.ScrollingDirection.Y
   o.ScrollBarThickness=3
   o.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable
  end
 end
end
apply()
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(apply) end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 cam=workspace.CurrentCamera
 apply()
 if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(apply) end
end)
