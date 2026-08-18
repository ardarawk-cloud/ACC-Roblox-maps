-- BBYA SOCIAL HUB — PREMIUM DANCE STUDIO UI v3.0
-- Benchmark direction: premium neon club HUD, mobile-first, no duplicate music controller.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BBYA_Remotes")
local Dance = remotes:WaitForChild("Dance")
local Sync = remotes:WaitForChild("SyncDance")
local FX = remotes:WaitForChild("FX")
local TP = remotes:WaitForChild("Teleport")
local Feedback = remotes:WaitForChild("Feedback")

local gui = Instance.new("ScreenGui")
gui.Name = "BBYA_DanceStudio"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 28
gui.Parent = player:WaitForChild("PlayerGui")

local BG = Color3.fromRGB(10, 8, 17)
local CARD = Color3.fromRGB(27, 20, 37)
local CARD2 = Color3.fromRGB(38, 27, 53)
local PINK = Color3.fromRGB(255, 66, 202)
local PURPLE = Color3.fromRGB(153, 73, 255)
local CYAN = Color3.fromRGB(55, 220, 255)
local GOLD = Color3.fromRGB(255, 205, 82)
local WHITE = Color3.fromRGB(247, 244, 252)
local MUTED = Color3.fromRGB(170, 159, 184)

local function corner(o, r)
 local c = Instance.new("UICorner")
 c.CornerRadius = UDim.new(0, r or 10)
 c.Parent = o
end

local function stroke(o, color, trans, thick)
 local s = Instance.new("UIStroke")
 s.Color = color or PINK
 s.Transparency = trans or .55
 s.Thickness = thick or 1
 s.Parent = o
end

local function gradient(o, a, b, rot)
 local g = Instance.new("UIGradient")
 g.Color = ColorSequence.new(a, b)
 g.Rotation = rot or 0
 g.Parent = o
 return g
end

local toast = Instance.new("TextLabel")
toast.AnchorPoint = Vector2.new(.5, 0)
toast.Position = UDim2.new(.5, 0, 0, 56)
toast.Size = UDim2.fromOffset(330, 40)
toast.BackgroundColor3 = BG
toast.BackgroundTransparency = .05
toast.TextColor3 = WHITE
toast.Font = Enum.Font.GothamBold
toast.TextSize = 13
toast.Visible = false
toast.ZIndex = 50
toast.Parent = gui
corner(toast, 12)
stroke(toast, PINK, .4, 1)
local toastToken = 0
local function notify(text)
 toastToken += 1
 local mine = toastToken
 toast.Text = tostring(text)
 toast.Visible = true
 toast.TextTransparency = 0
 toast.BackgroundTransparency = .05
 task.delay(2.2, function()
  if mine == toastToken and toast.Parent then
   TweenService:Create(toast, TweenInfo.new(.25), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
   task.wait(.26)
   if mine == toastToken then toast.Visible = false end
  end
 end)
end
Feedback.OnClientEvent:Connect(notify)

-- LEFT DOCK --------------------------------------------------
local dock = Instance.new("Frame")
dock.Name = "Dock"
dock.AnchorPoint = Vector2.new(0, .5)
dock.Position = UDim2.new(0, 12, .5, 0)
dock.Size = UDim2.fromOffset(72, 338)
dock.BackgroundColor3 = BG
dock.BackgroundTransparency = .06
dock.Parent = gui
corner(dock, 18)
stroke(dock, PURPLE, .58, 1)

local dockLayout = Instance.new("UIListLayout")
dockLayout.Padding = UDim.new(0, 8)
dockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
dockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
dockLayout.Parent = dock

local function dockButton(icon, label, accent)
 local b = Instance.new("TextButton")
 b.Size = UDim2.fromOffset(56, 48)
 b.BackgroundColor3 = CARD
 b.Text = icon .. "\n" .. label
 b.TextColor3 = accent or WHITE
 b.Font = Enum.Font.GothamBold
 b.TextSize = 10
 b.TextWrapped = true
 b.Parent = dock
 corner(b, 12)
 return b
end

local danceOpen = dockButton("✦", "DANCE", PINK)
local vipButton = dockButton("♛", "VIP", GOLD)
local photoButton = dockButton("◉", "PHOTO", CYAN)
local poolButton = dockButton("≈", "POOL", CYAN)
local barButton = dockButton("◆", "BAR", PINK)
local chillButton = dockButton("…", "CHILL", MUTED)

-- MAIN DANCE PANEL -------------------------------------------
local panel = Instance.new("Frame")
panel.Name = "DancePanel"
panel.AnchorPoint = Vector2.new(0, .5)
panel.Position = UDim2.new(0, 94, .5, 0)
panel.Size = UDim2.fromOffset(620, 500)
panel.BackgroundColor3 = BG
panel.BackgroundTransparency = .02
panel.Visible = false
panel.ClipsDescendants = true
panel.Parent = gui
corner(panel, 22)
stroke(panel, PINK, .32, 1.2)

local topGlow = Instance.new("Frame")
topGlow.Size = UDim2.new(1, 0, 0, 5)
topGlow.BackgroundColor3 = PINK
topGlow.BorderSizePixel = 0
topGlow.Parent = panel
gradient(topGlow, CYAN, PINK, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 0, 32)
title.Position = UDim2.fromOffset(18, 14)
title.BackgroundTransparency = 1
title.Text = "DANCE STUDIO"
title.TextColor3 = WHITE
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -110, 0, 20)
sub.Position = UDim2.fromOffset(18, 46)
sub.BackgroundTransparency = 1
sub.Text = "Pick a vibe • sync with friends • own the floor"
sub.TextColor3 = MUTED
sub.Font = Enum.Font.Gotham
sub.TextSize = 11
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Parent = panel

local liveBadge = Instance.new("TextLabel")
liveBadge.Size = UDim2.fromOffset(64, 24)
liveBadge.Position = UDim2.new(1, -104, 0, 17)
liveBadge.BackgroundColor3 = Color3.fromRGB(50, 22, 58)
liveBadge.Text = "● LIVE"
liveBadge.TextColor3 = PINK
liveBadge.Font = Enum.Font.GothamBold
liveBadge.TextSize = 10
liveBadge.Parent = panel
corner(liveBadge, 8)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -38, 0, 14)
close.BackgroundColor3 = CARD
close.Text = "×"
close.TextColor3 = WHITE
close.TextSize = 22
close.Parent = panel
corner(close, 9)

local profile = Instance.new("Frame")
profile.Size = UDim2.new(1, -28, 0, 54)
profile.Position = UDim2.fromOffset(14, 76)
profile.BackgroundColor3 = CARD
profile.Parent = panel
corner(profile, 14)
stroke(profile, PURPLE, .7, 1)

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.fromOffset(40, 40)
avatar.Position = UDim2.fromOffset(8, 7)
avatar.BackgroundColor3 = CARD2
avatar.Parent = profile
corner(avatar, 20)
task.spawn(function()
 local ok, url = pcall(function()
  return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
 end)
 if ok then avatar.Image = url end
end)

local profileText = Instance.new("TextLabel")
profileText.Size = UDim2.new(1, -180, 1, 0)
profileText.Position = UDim2.fromOffset(58, 0)
profileText.BackgroundTransparency = 1
profileText.Text = player.DisplayName .. "\nBBYA DANCER"
profileText.TextColor3 = WHITE
profileText.Font = Enum.Font.GothamBold
profileText.TextSize = 12
profileText.TextXAlignment = Enum.TextXAlignment.Left
profileText.Parent = profile

local donated = Instance.new("TextLabel")
donated.AnchorPoint = Vector2.new(1, .5)
donated.Position = UDim2.new(1, -12, .5, 0)
donated.Size = UDim2.fromOffset(150, 34)
donated.BackgroundTransparency = 1
donated.TextColor3 = GOLD
donated.Font = Enum.Font.GothamBold
donated.TextSize = 11
donated.TextXAlignment = Enum.TextXAlignment.Right
donated.Parent = profile
local function refreshDonated()
 donated.Text = string.format("SUPPORT  R$%d", player:GetAttribute("TotalDonated") or 0)
end
refreshDonated()
player:GetAttributeChangedSignal("TotalDonated"):Connect(refreshDonated)

local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -28, 0, 38)
search.Position = UDim2.fromOffset(14, 140)
search.BackgroundColor3 = CARD
search.PlaceholderText = "Search dance..."
search.Text = ""
search.TextColor3 = WHITE
search.PlaceholderColor3 = MUTED
search.Font = Enum.Font.Gotham
search.TextSize = 12
search.ClearTextOnFocus = false
search.Parent = panel
corner(search, 11)

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -28, 0, 34)
tabs.Position = UDim2.fromOffset(14, 186)
tabs.BackgroundTransparency = 1
tabs.Parent = panel
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 7)
tabLayout.Parent = tabs

local activeCategory = "ALL"
local tabButtons = {}
local function makeTab(name, width)
 local b = Instance.new("TextButton")
 b.Size = UDim2.fromOffset(width, 32)
 b.BackgroundColor3 = CARD
 b.Text = name
 b.TextColor3 = WHITE
 b.Font = Enum.Font.GothamBold
 b.TextSize = 10
 b.Parent = tabs
 corner(b, 10)
 tabButtons[name] = b
 return b
end
for _, t in ipairs({{"ALL",62},{"VIBES",76},{"SOCIAL",76},{"HYPE",70},{"FAV",62}}) do makeTab(t[1],t[2]) end

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -28, 1, -310)
scroll.Position = UDim2.fromOffset(14, 230)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = panel
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(.333, -8, 0, 96)
grid.CellPadding = UDim2.fromOffset(8, 8)
grid.Parent = scroll

local danceDefs = {
 {id="dance", name="BBYA VIBES", cat="VIBES", icon="✦"},
 {id="dance2", name="NEON GROOVE", cat="VIBES", icon="≈"},
 {id="dance3", name="MIDNIGHT FLOW", cat="VIBES", icon="◇"},
 {id="wave", name="HELLO CLUB", cat="SOCIAL", icon="◉"},
 {id="cheer", name="HYPE CROWD", cat="HYPE", icon="▲"},
 {id="laugh", name="GOOD VIBES", cat="SOCIAL", icon="☻"},
 {id="point", name="POINT DROP", cat="HYPE", icon="➤"},
}
local favorite = {dance=true, dance2=true}
local cards = {}
local activeDance = nil
local autoDance = false
local autoToken = 0

local function danceCard(def)
 local b = Instance.new("TextButton")
 b.Name = "Dance_" .. def.id
 b.BackgroundColor3 = CARD
 b.Text = ""
 b.Parent = scroll
 corner(b, 13)
 stroke(b, Color3.fromRGB(90, 70, 108), .75, 1)
 local icon = Instance.new("TextLabel")
 icon.Size = UDim2.new(1, 0, 0, 48)
 icon.BackgroundTransparency = 1
 icon.Text = def.icon
 icon.TextColor3 = def.cat == "HYPE" and CYAN or PINK
 icon.Font = Enum.Font.GothamBlack
 icon.TextSize = 26
 icon.Parent = b
 local name = Instance.new("TextLabel")
 name.Size = UDim2.new(1, -10, 0, 22)
 name.Position = UDim2.fromOffset(5, 48)
 name.BackgroundTransparency = 1
 name.Text = def.name
 name.TextColor3 = WHITE
 name.Font = Enum.Font.GothamBold
 name.TextSize = 10
 name.TextWrapped = true
 name.Parent = b
 local meta = Instance.new("TextLabel")
 meta.Size = UDim2.new(1, -10, 0, 16)
 meta.Position = UDim2.fromOffset(5, 72)
 meta.BackgroundTransparency = 1
 meta.Text = def.cat
 meta.TextColor3 = MUTED
 meta.Font = Enum.Font.Gotham
 meta.TextSize = 9
 meta.Parent = b
 b.Activated:Connect(function()
  activeDance = def.id
  Dance:FireServer(def.id)
  notify("Playing " .. def.name)
  for _, c in pairs(cards) do c.BackgroundColor3 = CARD end
  b.BackgroundColor3 = Color3.fromRGB(58, 28, 70)
 end)
 cards[def.id] = b
 return b
end
for _, def in ipairs(danceDefs) do danceCard(def) end

local function applyFilter()
 local q = string.lower(search.Text or "")
 for _, def in ipairs(danceDefs) do
  local byCat = activeCategory == "ALL" or def.cat == activeCategory or (activeCategory == "FAV" and favorite[def.id])
  local byText = q == "" or string.find(string.lower(def.name), q, 1, true) or string.find(string.lower(def.cat), q, 1, true)
  cards[def.id].Visible = byCat and byText
 end
 for name, b in pairs(tabButtons) do
  b.BackgroundColor3 = name == activeCategory and Color3.fromRGB(60, 28, 70) or CARD
  b.TextColor3 = name == activeCategory and PINK or WHITE
 end
end
for name, b in pairs(tabButtons) do
 b.Activated:Connect(function() activeCategory = name; applyFilter() end)
end
search:GetPropertyChangedSignal("Text"):Connect(applyFilter)
applyFilter()

-- QUICK DANCE BAR --------------------------------------------
local quick = Instance.new("Frame")
quick.Size = UDim2.new(1, -28, 0, 60)
quick.Position = UDim2.new(0, 14, 1, -72)
quick.BackgroundColor3 = CARD
quick.Parent = panel
corner(quick, 14)
stroke(quick, PURPLE, .7, 1)

local qLayout = Instance.new("UIListLayout")
qLayout.FillDirection = Enum.FillDirection.Horizontal
qLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
qLayout.VerticalAlignment = Enum.VerticalAlignment.Center
qLayout.Padding = UDim.new(0, 7)
qLayout.Parent = quick

local function quickBtn(text, width, accent, cb)
 local b = Instance.new("TextButton")
 b.Size = UDim2.fromOffset(width or 72, 40)
 b.BackgroundColor3 = accent and Color3.fromRGB(58, 28, 70) or CARD2
 b.Text = text
 b.TextColor3 = accent and PINK or WHITE
 b.Font = Enum.Font.GothamBold
 b.TextSize = 10
 b.TextWrapped = true
 b.Parent = quick
 corner(b, 10)
 b.Activated:Connect(cb)
 return b
end

quickBtn("STOP", 64, false, function()
 autoDance = false; autoToken += 1; activeDance = nil; Dance:FireServer("stop"); notify("Dance stopped")
 for _, c in pairs(cards) do c.BackgroundColor3 = CARD end
end)

quickBtn("SYNC\nNEAR", 74, false, function()
 local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root then return end
 local best, dist = nil, 35
 for _, p in ipairs(Players:GetPlayers()) do
  if p ~= player then
   local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
   if pr then
    local d = (pr.Position - root.Position).Magnitude
    if d < dist then dist = d; best = p end
   end
  end
 end
 if best then Sync:FireServer(best.UserId) else notify("No dancer nearby") end
end)

local autoBtn
autoBtn = quickBtn("AUTO\nOFF", 72, true, function()
 autoDance = not autoDance
 autoToken += 1
 local mine = autoToken
 autoBtn.Text = autoDance and "AUTO\nON" or "AUTO\nOFF"
 notify(autoDance and "Auto Dance ON" or "Auto Dance OFF")
 if autoDance then
  task.spawn(function()
   local seq = {"dance", "dance2", "dance3"}
   local i = 1
   while autoDance and mine == autoToken and gui.Parent do
    activeDance = seq[i]
    Dance:FireServer(activeDance)
    i = i % #seq + 1
    task.wait(8)
   end
  end)
 end
end)

quickBtn("GLOW", 66, false, function() FX:FireServer("glowstick") end)
quickBtn("CONFETTI", 78, false, function() FX:FireServer("confetti") end)

-- DOCK / NAVIGATION ------------------------------------------
danceOpen.Activated:Connect(function() panel.Visible = not panel.Visible end)
close.Activated:Connect(function() panel.Visible = false end)
vipButton.Activated:Connect(function() TP:FireServer("VIP") end)
photoButton.Activated:Connect(function() TP:FireServer("PHOTO") end)
poolButton.Activated:Connect(function() TP:FireServer("POOL") end)
barButton.Activated:Connect(function() TP:FireServer("BAR") end)
chillButton.Activated:Connect(function() TP:FireServer("CHILL") end)

-- MOBILE ADAPTATION ------------------------------------------
local camera = workspace.CurrentCamera
local function layout()
 local v = camera.ViewportSize
 local mobile = v.X < 760
 if mobile then
  dock.Size = UDim2.fromOffset(58, 286)
  dock.Position = UDim2.new(0, 7, .5, 0)
  for _, child in ipairs(dock:GetChildren()) do
   if child:IsA("TextButton") then child.Size = UDim2.fromOffset(44, 38); child.TextSize = 8 end
  end
  panel.AnchorPoint = Vector2.new(.5, .5)
  panel.Position = UDim2.new(.5, 24, .5, 0)
  panel.Size = UDim2.new(1, -90, 1, -70)
  grid.CellSize = UDim2.new(.5, -5, 0, 88)
  quick.Size = UDim2.new(1, -20, 0, 54)
  quick.Position = UDim2.new(0, 10, 1, -64)
  for _, child in ipairs(quick:GetChildren()) do
   if child:IsA("TextButton") then child.Size = UDim2.fromOffset(54, 36); child.TextSize = 8 end
  end
 else
  dock.Size = UDim2.fromOffset(72, 338)
  dock.Position = UDim2.new(0, 12, .5, 0)
  for _, child in ipairs(dock:GetChildren()) do
   if child:IsA("TextButton") then child.Size = UDim2.fromOffset(56, 48); child.TextSize = 10 end
  end
  panel.AnchorPoint = Vector2.new(0, .5)
  panel.Position = UDim2.new(0, 94, .5, 0)
  panel.Size = UDim2.fromOffset(620, 500)
  grid.CellSize = UDim2.new(.333, -8, 0, 96)
  quick.Size = UDim2.new(1, -28, 0, 60)
  quick.Position = UDim2.new(0, 14, 1, -72)
 end
end
layout()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)

print("[BBYA] Premium Dance Studio UI v3.0 loaded")
