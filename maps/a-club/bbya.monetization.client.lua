-- BBYA SOCIAL HUB — USER SAWER PANEL v2.0
-- Mobile-first supporter purchase panel.
-- Always visible to users; unconfigured product buttons are safely disabled until real Roblox IDs are supplied.

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local config = ReplicatedStorage:WaitForChild("BBYA_Monetization", 15)
if not config then return end

local gui = Instance.new("ScreenGui")
gui.Name = "BBYA_UserSawerPanel"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 40
gui.Parent = playerGui

local BG = Color3.fromRGB(13, 10, 21)
local CARD = Color3.fromRGB(29, 22, 39)
local CARD2 = Color3.fromRGB(41, 27, 52)
local PINK = Color3.fromRGB(255, 78, 201)
local CYAN = Color3.fromRGB(65, 215, 255)
local GOLD = Color3.fromRGB(255, 211, 92)
local WHITE = Color3.fromRGB(245, 240, 255)
local MUTED = Color3.fromRGB(160, 153, 178)
local DISABLED = Color3.fromRGB(70, 66, 78)

local function corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 12)
	c.Parent = obj
	return c
end

local function stroke(obj, color, transparency, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or PINK
	s.Transparency = transparency or 0.45
	s.Thickness = thickness or 1
	s.Parent = obj
	return s
end

local function textLabel(parent, text, size, color, font)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = size
	t.Text = text
	t.TextColor3 = color or WHITE
	t.Font = font or Enum.Font.Gotham
	t.TextSize = 13
	t.TextWrapped = true
	t.Parent = parent
	return t
end

-- Floating launcher intentionally lives at bottom-right, separate from music / supporter leaderboard controls.
local launcher = Instance.new("TextButton")
launcher.Name = "SawerLauncher"
launcher.AnchorPoint = Vector2.new(1, 1)
launcher.Position = UDim2.new(1, -14, 1, -72)
launcher.Size = UDim2.fromOffset(108, 42)
launcher.BackgroundColor3 = BG
launcher.Text = "SAWER  R$"
launcher.TextColor3 = GOLD
launcher.Font = Enum.Font.GothamBlack
launcher.TextSize = 14
launcher.AutoButtonColor = true
launcher.Parent = gui
corner(launcher, 13)
stroke(launcher, PINK, 0.2, 1.2)

local badge = Instance.new("Frame")
badge.Name = "LiveDot"
badge.Size = UDim2.fromOffset(7, 7)
badge.Position = UDim2.fromOffset(9, 8)
badge.BackgroundColor3 = PINK
badge.Parent = launcher
corner(badge, 99)

-- Main panel opens upward so it stays reachable on phones.
local panel = Instance.new("Frame")
panel.Name = "SawerPanel"
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -14, 1, -120)
panel.Size = UDim2.fromOffset(304, 430)
panel.BackgroundColor3 = BG
panel.BackgroundTransparency = 0.02
panel.Visible = false
panel.Parent = gui
corner(panel, 17)
stroke(panel, PINK, 0.35, 1.2)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 68)
header.BackgroundColor3 = Color3.fromRGB(22, 14, 32)
header.Parent = panel
corner(header, 17)

-- Flatten lower header corners visually.
local headerFill = Instance.new("Frame")
headerFill.Size = UDim2.new(1, 0, 0, 18)
headerFill.Position = UDim2.new(0, 0, 1, -18)
headerFill.BorderSizePixel = 0
headerFill.BackgroundColor3 = header.BackgroundColor3
headerFill.Parent = header

local title = textLabel(header, "SAWER BBYA", UDim2.new(1, -58, 0, 28), PINK, Enum.Font.GothamBlack)
title.Position = UDim2.fromOffset(16, 10)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = textLabel(header, "Support the club • repeatable Robux support", UDim2.new(1, -58, 0, 20), MUTED, Enum.Font.GothamMedium)
subtitle.Position = UDim2.fromOffset(16, 38)
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton")
close.Name = "Close"
close.Size = UDim2.fromOffset(34, 34)
close.Position = UDim2.new(1, -46, 0, 12)
close.BackgroundColor3 = CARD
close.Text = "×"
close.TextColor3 = WHITE
close.Font = Enum.Font.GothamBold
close.TextSize = 22
close.Parent = header
corner(close, 10)

local totalCard = Instance.new("Frame")
totalCard.Size = UDim2.new(1, -24, 0, 58)
totalCard.Position = UDim2.fromOffset(12, 80)
totalCard.BackgroundColor3 = CARD
totalCard.Parent = panel
corner(totalCard, 12)

local totalCaption = textLabel(totalCard, "TOTAL SAWER KAMU", UDim2.new(0.48, 0, 0, 20), MUTED, Enum.Font.GothamBold)
totalCaption.Position = UDim2.fromOffset(12, 8)
totalCaption.TextSize = 10
totalCaption.TextXAlignment = Enum.TextXAlignment.Left

local totalValue = textLabel(totalCard, "R$0", UDim2.new(0.48, 0, 0, 25), GOLD, Enum.Font.GothamBlack)
totalValue.Position = UDim2.fromOffset(12, 26)
totalValue.TextSize = 19
totalValue.TextXAlignment = Enum.TextXAlignment.Left

local latest = textLabel(totalCard, "LIVE SUPPORT\n—", UDim2.new(0.48, -12, 1, -12), CYAN, Enum.Font.GothamBold)
latest.Position = UDim2.new(0.52, 0, 0, 6)
latest.TextSize = 10
latest.TextXAlignment = Enum.TextXAlignment.Right
latest.TextYAlignment = Enum.TextYAlignment.Center

local choose = textLabel(panel, "PILIH NOMINAL", UDim2.new(1, -24, 0, 24), WHITE, Enum.Font.GothamBold)
choose.Position = UDim2.fromOffset(12, 149)
choose.TextSize = 12
choose.TextXAlignment = Enum.TextXAlignment.Left

local gridFrame = Instance.new("Frame")
gridFrame.Size = UDim2.new(1, -24, 0, 168)
gridFrame.Position = UDim2.fromOffset(12, 178)
gridFrame.BackgroundTransparency = 1
gridFrame.Parent = panel

local grid = Instance.new("UIGridLayout")
grid.CellPadding = UDim2.fromOffset(8, 8)
grid.CellSize = UDim2.new(0.5, -4, 0, 34)
grid.FillDirectionMaxCells = 2
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = gridFrame

local amounts = {5, 10, 25, 50, 100, 250, 500}
local productByAmount = {}
for _, amount in ipairs(amounts) do
	local value = config:FindFirstChild("Support_" .. amount)
	productByAmount[amount] = value and value:IsA("IntValue") and value.Value or 0
end

local configuredCount = 0
for _, productId in pairs(productByAmount) do
	if productId > 0 then configuredCount += 1 end
end

local transactionStatus = textLabel(panel, "", UDim2.new(1, -24, 0, 30), MUTED, Enum.Font.GothamMedium)
transactionStatus.Position = UDim2.fromOffset(12, 350)
transactionStatus.TextSize = 11
transactionStatus.TextXAlignment = Enum.TextXAlignment.Left

local purchaseBusy = false

local function setStatus(message, color)
	transactionStatus.Text = message
	transactionStatus.TextColor3 = color or MUTED
end

for index, amount in ipairs(amounts) do
	local productId = productByAmount[amount]
	local active = productId and productId > 0

	local button = Instance.new("TextButton")
	button.Name = "Sawer" .. amount
	button.LayoutOrder = index
	button.BackgroundColor3 = active and CARD2 or Color3.fromRGB(32, 30, 37)
	button.TextColor3 = active and WHITE or DISABLED
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Text = active and string.format("SAWER  R$%d", amount) or string.format("R$%d  •  BELUM AKTIF", amount)
	button.AutoButtonColor = active
	button.Active = active
	button.Parent = gridFrame
	corner(button, 9)
	if active then stroke(button, index % 2 == 0 and CYAN or PINK, 0.65, 1) end

	if active then
		button.Activated:Connect(function()
			if purchaseBusy then return end
			purchaseBusy = true
			setStatus(string.format("Membuka konfirmasi sawer R$%d...", amount), CYAN)
			local ok = pcall(function()
				MarketplaceService:PromptProductPurchase(player, productId)
			end)
			if not ok then
				setStatus("Tidak bisa membuka transaksi. Coba lagi.", PINK)
			end
			task.delay(1.2, function() purchaseBusy = false end)
		end)
	end
end

local info = textLabel(panel, "Saweran bersifat dukungan. Tidak memberi keuntungan gameplay.", UDim2.new(1, -24, 0, 38), MUTED, Enum.Font.Gotham)
info.Position = UDim2.fromOffset(12, 383)
info.TextSize = 10
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top

local function refreshTotal()
	local total = tonumber(player:GetAttribute("TotalDonated")) or 0
	totalValue.Text = "R$" .. tostring(total)
end
refreshTotal()

local previousTotal = tonumber(player:GetAttribute("TotalDonated")) or 0
player:GetAttributeChangedSignal("TotalDonated"):Connect(function()
	local now = tonumber(player:GetAttribute("TotalDonated")) or 0
	local delta = now - previousTotal
	previousTotal = now
	refreshTotal()
	if delta > 0 then
		setStatus(string.format("Terima kasih! Sawer +R$%d berhasil.", delta), GOLD)
		local original = launcher.Size
		TweenService:Create(launcher, TweenInfo.new(0.12), {Size = UDim2.fromOffset(118, 46)}):Play()
		task.delay(0.18, function()
			if launcher.Parent then TweenService:Create(launcher, TweenInfo.new(0.18), {Size = original}):Play() end
		end)
	end
end)

local function refreshLatest()
	local supporter = tostring(workspace:GetAttribute("BBYALastSupporter") or "")
	local amount = tonumber(workspace:GetAttribute("BBYALastSupportAmount")) or 0
	if supporter ~= "" and amount > 0 then
		latest.Text = string.format("LIVE SUPPORT\n%s  +R$%d", supporter, amount)
	else
		latest.Text = "LIVE SUPPORT\n—"
	end
end
refreshLatest()
workspace:GetAttributeChangedSignal("BBYALastSupporter"):Connect(refreshLatest)
workspace:GetAttributeChangedSignal("BBYALastSupportAmount"):Connect(refreshLatest)

if configuredCount == 0 then
	setStatus("Panel siap. ID Developer Product belum dipasang.", MUTED)
else
	setStatus(string.format("%d nominal sawer aktif.", configuredCount), CYAN)
end

local function setPanel(open)
	panel.Visible = open
	if open then refreshTotal(); refreshLatest() end
end

launcher.Activated:Connect(function()
	setPanel(not panel.Visible)
end)
close.Activated:Connect(function()
	setPanel(false)
end)

print("[BBYA SAWER] User Sawer Panel v2.0 loaded; configured products:", configuredCount)
