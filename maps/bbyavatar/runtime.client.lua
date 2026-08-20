local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local root = ReplicatedStorage:WaitForChild("BBYAVATAR")
local openEvent = root:WaitForChild("OpenCatalog")

local gui = Instance.new("ScreenGui")
gui.Name = "BBYAVATAR_UI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromScale(0.86, 0.72)
frame.Visible = false
frame.BackgroundColor3 = Color3.fromRGB(20,20,24)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromScale(0.05, 0.05)
title.Size = UDim2.fromScale(0.7, 0.1)
title.Font = Enum.Font.GothamBlack
title.Text = "BBYAVATAR"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local category = Instance.new("TextLabel")
category.BackgroundTransparency = 1
category.Position = UDim2.fromScale(0.05, 0.17)
category.Size = UDim2.fromScale(0.7, 0.07)
category.Font = Enum.Font.GothamBold
category.Text = "FEATURED"
category.TextColor3 = Color3.fromRGB(210,210,220)
category.TextScaled = true
category.TextXAlignment = Enum.TextXAlignment.Left
category.Parent = frame

local body = Instance.new("TextLabel")
body.BackgroundTransparency = 1
body.Position = UDim2.fromScale(0.05, 0.30)
body.Size = UDim2.fromScale(0.9, 0.42)
body.Font = Enum.Font.Gotham
body.Text = "Full-look catalog is live.\n\nTry-on, saved looks, creator collections, and purchasable avatar items will activate as approved Roblox asset IDs are added."
body.TextWrapped = true
body.TextColor3 = Color3.fromRGB(235,235,240)
body.TextScaled = true
body.Parent = frame

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1,0)
close.Position = UDim2.fromScale(0.95,0.05)
close.Size = UDim2.fromScale(0.14,0.09)
close.Text = "CLOSE"
close.Font = Enum.Font.GothamBold
close.TextScaled = true
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 12)

close.Activated:Connect(function()
    frame.Visible = false
end)

openEvent.OnClientEvent:Connect(function(selectedCategory)
    category.Text = tostring(selectedCategory or "FEATURED")
    frame.Visible = true
end)
