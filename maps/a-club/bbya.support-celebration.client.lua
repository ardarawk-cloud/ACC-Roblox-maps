-- BBYA SOCIAL HUB — SUPPORT CELEBRATION CLIENT v1.0
-- Premium, short global toast when a real Developer Product support receipt is granted.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "BBYA_SupportCelebration"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 45
gui.Parent = player:WaitForChild("PlayerGui")

local BG = Color3.fromRGB(10,8,17)
local PINK = Color3.fromRGB(255,66,202)
local CYAN = Color3.fromRGB(55,220,255)
local GOLD = Color3.fromRGB(255,205,82)
local WHITE = Color3.fromRGB(247,244,252)
local MUTED = Color3.fromRGB(175,164,188)

local card = Instance.new("Frame")
card.Name = "SupportToast"
card.AnchorPoint = Vector2.new(.5,0)
card.Position = UDim2.new(.5,0,0,-110)
card.Size = UDim2.fromOffset(390,92)
card.BackgroundColor3 = BG
card.BackgroundTransparency = .04
card.Visible = false
card.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,18)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Color = PINK
stroke.Transparency = .25
stroke.Thickness = 1.2
stroke.Parent = card

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1,0,0,5)
glow.BackgroundColor3 = PINK
glow.BorderSizePixel = 0
glow.Parent = card
local gc = Instance.new("UICorner")
gc.CornerRadius = UDim.new(0,18)
gc.Parent = glow
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new(CYAN,PINK)
grad.Parent = glow

local icon = Instance.new("TextLabel")
icon.Size = UDim2.fromOffset(58,58)
icon.Position = UDim2.fromOffset(14,18)
icon.BackgroundTransparency = 1
icon.Text = "♥"
icon.TextColor3 = GOLD
icon.Font = Enum.Font.GothamBlack
icon.TextSize = 35
icon.Parent = card

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-90,0,28)
title.Position = UDim2.fromOffset(72,15)
title.BackgroundTransparency = 1
title.Text = "SUPPORT THE NIGHT"
title.TextColor3 = GOLD
title.Font = Enum.Font.GothamBlack
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = card

local body = Instance.new("TextLabel")
body.Size = UDim2.new(1,-90,0,34)
body.Position = UDim2.fromOffset(72,40)
body.BackgroundTransparency = 1
body.Text = ""
body.TextColor3 = WHITE
body.Font = Enum.Font.GothamBold
body.TextSize = 13
body.TextWrapped = true
body.TextXAlignment = Enum.TextXAlignment.Left
body.Parent = card

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1,-90,0,14)
footer.Position = UDim2.fromOffset(72,70)
footer.BackgroundTransparency = 1
footer.Text = "BBYA SOCIAL HUB"
footer.TextColor3 = MUTED
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = card

local token = 0
local function showCelebration()
 local name = workspace:GetAttribute("BBYALastSupporter")
 local amount = tonumber(workspace:GetAttribute("BBYALastSupportAmount") or 0)
 if not name or amount <= 0 then return end
 token += 1
 local mine = token
 body.Text = string.format("%s just dropped R$%d support ♥", tostring(name), amount)
 card.Visible = true
 card.Position = UDim2.new(.5,0,0,-110)
 card.BackgroundTransparency = .04
 title.TextTransparency = 0
 body.TextTransparency = 0
 footer.TextTransparency = 0
 icon.TextTransparency = 0
 TweenService:Create(card,TweenInfo.new(.38,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=UDim2.new(.5,0,0,54)}):Play()
 task.delay(3.2,function()
  if mine ~= token then return end
  TweenService:Create(card,TweenInfo.new(.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(.5,0,0,-110),BackgroundTransparency=.3}):Play()
  task.wait(.32)
  if mine == token then card.Visible=false end
 end)
end

workspace:GetAttributeChangedSignal("BBYALastSupportAmount"):Connect(showCelebration)

local function responsive()
 local cam=workspace.CurrentCamera
 if not cam then return end
 local v=cam.ViewportSize
 if v.X < 600 then
  card.Size=UDim2.new(1,-24,0,88)
 else
  card.Size=UDim2.fromOffset(390,92)
 end
end
responsive()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end

print("[BBYA] Support Celebration Client v1.0 loaded")
