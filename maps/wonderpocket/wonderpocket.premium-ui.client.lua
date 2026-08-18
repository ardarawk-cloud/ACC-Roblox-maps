local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "WonderPocketPremiumUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 16)
    c.Parent = parent
end

local function stroke(parent, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.7
    s.Parent = parent
end

local dock = Instance.new("Frame")
dock.Name = "BottomDock"
dock.AnchorPoint = Vector2.new(0.5,1)
dock.Position = UDim2.new(0.5,0,1,-14)
dock.Size = UDim2.fromOffset(390,64)
dock.BackgroundColor3 = Color3.fromRGB(25,31,65)
dock.BackgroundTransparency = 0.08
dock.Parent = gui
corner(dock,22); stroke(dock,1.5,0.55)

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0,8)
layout.Parent = dock

local panels = {}
local activePanel

local function makePanel(name, title)
    local panel = Instance.new("Frame")
    panel.Name = name
    panel.AnchorPoint = Vector2.new(0.5,0.5)
    panel.Position = UDim2.fromScale(0.5,0.5)
    panel.Size = UDim2.fromOffset(420,430)
    panel.BackgroundColor3 = Color3.fromRGB(248,250,255)
    panel.Visible = false
    panel.Parent = gui
    corner(panel,24); stroke(panel,2,0.8)

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1,-76,0,58)
    header.Position = UDim2.fromOffset(22,10)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.Text = title
    header.TextColor3 = Color3.fromRGB(35,44,85)
    header.TextSize = 25
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = panel

    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(42,42)
    close.Position = UDim2.new(1,-54,0,14)
    close.BackgroundColor3 = Color3.fromRGB(235,238,248)
    close.Text = "×"
    close.TextSize = 28
    close.Font = Enum.Font.GothamBold
    close.TextColor3 = Color3.fromRGB(65,70,100)
    close.Parent = panel
    corner(close,14)
    close.Activated:Connect(function() panel.Visible=false; activePanel=nil end)

    panels[name] = panel
    return panel
end

local shopPanel = makePanel("ShopPanel","Wonder Shop")
local dexPanel = makePanel("DexPanel","WonderDex")
local buildPanel = makePanel("BuildPanel","Decorate")
local socialPanel = makePanel("SocialPanel","Friends & Gifts")

local catalog = {
    {"Star Lamp",125,"StarLamp"}, {"Bunny Chair",180,"BunnyChair"},
    {"Toy Chest",220,"ToyChest"}, {"Cloud Bed",325,"CloudBed"},
    {"Rainbow Sofa",450,"RainbowSofa"}, {"Mini Aquarium",550,"MiniAquarium"},
}

local remotes = ReplicatedStorage:WaitForChild("WonderPocket_Remotes",8)
local shopRemote = remotes and remotes:FindFirstChild("Shop")
local placementRemote = remotes and remotes:FindFirstChild("Placement")
local socialRemote = remotes and remotes:FindFirstChild("Social")

local grid = Instance.new("UIGridLayout")
grid.CellPadding = UDim2.fromOffset(10,10)
grid.CellSize = UDim2.fromOffset(180,88)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
grid.Parent = shopPanel
shopPanel.PaddingTop = UDim.new(0,75)

for _,item in ipairs(catalog) do
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = Color3.fromRGB(235,244,255)
    b.Text = item[1] .. "\n" .. tostring(item[2]) .. " Coins"
    b.TextColor3 = Color3.fromRGB(40,55,100)
    b.TextSize = 17
    b.Font = Enum.Font.GothamSemibold
    b.Parent = shopPanel
    corner(b,16)
    b.Activated:Connect(function()
        if shopRemote then shopRemote:FireServer("BUY",item[3]) end
    end)
end

local dexText = Instance.new("TextLabel")
dexText.Position = UDim2.fromOffset(24,82)
dexText.Size = UDim2.new(1,-48,1,-110)
dexText.BackgroundTransparency = 1
dexText.TextXAlignment = Enum.TextXAlignment.Left
dexText.TextYAlignment = Enum.TextYAlignment.Top
dexText.Font = Enum.Font.GothamMedium
dexText.TextSize = 18
dexText.TextColor3 = Color3.fromRGB(50,60,95)
dexText.TextWrapped = true
dexText.Text = "WONDIES\nBubbi  ✓\nFlamo  ?\nMossy  ?\nLumi  ?\nZappy  ?\nPuffy  ?\n\nPLANTS\nCarrot  ✓\nStrawberry  ?\nSunflower  ?\n\nFURNITURE\nCollect and decorate to complete your WonderDex."
dexText.Parent = dexPanel

local buildHint = Instance.new("TextLabel")
buildHint.Position = UDim2.fromOffset(24,90)
buildHint.Size = UDim2.new(1,-48,0,120)
buildHint.BackgroundTransparency = 1
buildHint.TextWrapped = true
buildHint.Font = Enum.Font.GothamMedium
buildHint.TextSize = 18
buildHint.TextColor3 = Color3.fromRGB(55,62,95)
buildHint.Text = "Select owned furniture, move the translucent preview, rotate it, then confirm placement. Placement snaps cleanly to your Pocket World grid."
buildHint.Parent = buildPanel

local socialText = Instance.new("TextLabel")
socialText.Position = UDim2.fromOffset(24,82)
socialText.Size = UDim2.new(1,-48,0,100)
socialText.BackgroundTransparency = 1
socialText.TextWrapped = true
socialText.Font = Enum.Font.GothamMedium
socialText.TextSize = 18
socialText.TextColor3 = Color3.fromRGB(55,62,95)
socialText.Text = "Visit friends in this server or send a Surprise. Gifts are cosmetic social moments only."
socialText.Parent = socialPanel

local giftNames = {"Balloon","IceCream","Flower","Fireworks"}
for i,name in ipairs(giftNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(170,52)
    b.Position = UDim2.fromOffset(25 + ((i-1)%2)*190,205 + math.floor((i-1)/2)*66)
    b.BackgroundColor3 = Color3.fromRGB(240,232,255)
    b.Text = name
    b.Font = Enum.Font.GothamSemibold
    b.TextColor3 = Color3.fromRGB(65,52,100)
    b.TextSize = 17
    b.Parent = socialPanel
    corner(b,15)
    b.Activated:Connect(function()
        if socialRemote then socialRemote:FireServer("GIFT_NEAREST",name) end
    end)
end

local buttons = {
    {"SHOP","ShopPanel"},{"DEX","DexPanel"},{"BUILD","BuildPanel"},{"SOCIAL","SocialPanel"}
}
for _,entry in ipairs(buttons) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(86,46)
    b.BackgroundColor3 = Color3.fromRGB(54,78,150)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = entry[1]
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Parent = dock
    corner(b,15)
    b.Activated:Connect(function()
        if activePanel and activePanel ~= panels[entry[2]] then activePanel.Visible=false end
        local panel = panels[entry[2]]
        panel.Visible = not panel.Visible
        activePanel = panel.Visible and panel or nil
        if panel.Visible then
            panel.Size = UDim2.fromOffset(390,400)
            TweenService:Create(panel,TweenInfo.new(.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(420,430)}):Play()
        end
    end)
end

print("[WONDERPOCKET] Premium mobile UI loaded")
