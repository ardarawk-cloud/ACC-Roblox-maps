-- BBYA SOCIAL HUB — MONETIZATION CLIENT v1.0
-- Hidden automatically until real VIP / Developer Product IDs are configured by the server.

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local config = ReplicatedStorage:WaitForChild("BBYA_Monetization", 15)
if not config then return end

local vipId = config:FindFirstChild("VIPGamePassId") and config.VIPGamePassId.Value or 0
local support = {}
for _, child in ipairs(config:GetChildren()) do
	local amount = tonumber(string.match(child.Name, "^Support_(%d+)$"))
	if amount and child:IsA("IntValue") and child.Value > 0 then
		table.insert(support, {amount = amount, productId = child.Value})
	end
end
table.sort(support, function(a, b) return a.amount < b.amount end)

if vipId <= 0 and #support == 0 then
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "BBYAMonetizationUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 35
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
	c.Parent = obj
end

local function stroke(obj, color, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Transparency = transparency or 0.35
	s.Thickness = 1
	s.Parent = obj
end

local launcher = Instance.new("TextButton")
launcher.Name = "SupportLauncher"
launcher.AnchorPoint = Vector2.new(1, 0)
launcher.Position = UDim2.new(1, -14, 0, 94)
launcher.Size = UDim2.fromOffset(112, 34)
launcher.BackgroundColor3 = Color3.fromRGB(24, 14, 34)
launcher.TextColor3 = Color3.fromRGB(255, 205, 85)
launcher.Font = Enum.Font.GothamBold
launcher.TextSize = 14
launcher.Text = "VIP • SUPPORT"
launcher.Parent = gui
corner(launcher, 10)
stroke(launcher, Color3.fromRGB(255, 85, 200), 0.25)

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -14, 0, 134)
panel.Size = UDim2.fromOffset(240, 0)
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.BackgroundColor3 = Color3.fromRGB(14, 11, 23)
panel.BackgroundTransparency = 0.04
panel.Visible = false
panel.Parent = gui
corner(panel, 14)
stroke(panel, Color3.fromRGB(120, 90, 190), 0.35)

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 12)
pad.PaddingBottom = UDim.new(0, 12)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = panel

local title = Instance.new("TextLabel")
title.LayoutOrder = 1
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "BBYA SOCIAL HUB"
title.TextColor3 = Color3.fromRGB(255, 105, 215)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.Parent = panel

local status = Instance.new("TextLabel")
status.LayoutOrder = 2
status.Size = UDim2.new(1, 0, 0, 26)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(220, 215, 235)
status.Font = Enum.Font.GothamMedium
status.TextSize = 13
status.TextWrapped = true
status.Parent = panel

local function refreshStatus()
	status.Text = player:GetAttribute("IsVIP") and "VIP ACCESS • ACTIVE" or "Guest access"
	status.TextColor3 = player:GetAttribute("IsVIP") and Color3.fromRGB(255, 215, 90) or Color3.fromRGB(220, 215, 235)
end
refreshStatus()
player:GetAttributeChangedSignal("IsVIP"):Connect(refreshStatus)

if vipId > 0 then
	local vip = Instance.new("TextButton")
	vip.LayoutOrder = 3
	vip.Size = UDim2.new(1, 0, 0, 42)
	vip.BackgroundColor3 = Color3.fromRGB(98, 55, 24)
	vip.TextColor3 = Color3.fromRGB(255, 225, 130)
	vip.Font = Enum.Font.GothamBold
	vip.TextSize = 15
	vip.Text = "VIP ACCESS • 10 ROBUX"
	vip.Parent = panel
	corner(vip, 10)
	vip.MouseButton1Click:Connect(function()
		if player:GetAttribute("IsVIP") then return end
		pcall(function()
			MarketplaceService:PromptGamePassPurchase(player, vipId)
		end)
	end)
end

if #support > 0 then
	local supportTitle = Instance.new("TextLabel")
	supportTitle.LayoutOrder = 10
	supportTitle.Size = UDim2.new(1, 0, 0, 25)
	supportTitle.BackgroundTransparency = 1
	supportTitle.Text = "SAWERAN / SUPPORT"
	supportTitle.TextColor3 = Color3.fromRGB(85, 210, 255)
	supportTitle.Font = Enum.Font.GothamBold
	supportTitle.TextSize = 13
	supportTitle.Parent = panel

	for i, item in ipairs(support) do
		local button = Instance.new("TextButton")
		button.LayoutOrder = 10 + i
		button.Size = UDim2.new(1, 0, 0, 38)
		button.BackgroundColor3 = Color3.fromRGB(38, 25, 50)
		button.TextColor3 = Color3.fromRGB(245, 235, 255)
		button.Font = Enum.Font.GothamBold
		button.TextSize = 14
		button.Text = string.format("SUPPORT  R$%d", item.amount)
		button.Parent = panel
		corner(button, 9)
		button.MouseButton1Click:Connect(function()
			pcall(function()
				MarketplaceService:PromptProductPurchase(player, item.productId)
			end)
		end)
	end
end

local note = Instance.new("TextLabel")
note.LayoutOrder = 99
note.Size = UDim2.new(1, 0, 0, 38)
note.BackgroundTransparency = 1
note.Text = "Support helps develop BBYA. No gameplay advantage."
note.TextColor3 = Color3.fromRGB(155, 150, 175)
note.Font = Enum.Font.Gotham
note.TextSize = 11
note.TextWrapped = true
note.Parent = panel

launcher.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

print("[BBYA MONETIZATION CLIENT] v1.0 loaded")
