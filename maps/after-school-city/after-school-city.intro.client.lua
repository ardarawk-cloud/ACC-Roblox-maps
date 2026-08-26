-- AFTER SCHOOL CITY — dedication intro popup v1.1 compact
-- Mobile-first client-only welcome card shown when a player joins.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("ASCDedicationIntro") then
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "ASCDedicationIntro"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 1000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local backdrop = Instance.new("Frame")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
backdrop.BackgroundTransparency = 1
backdrop.BorderSizePixel = 0
backdrop.ZIndex = 1
backdrop.Parent = gui

local card = Instance.new("Frame")
card.Name = "Card"
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.5)
card.Size = UDim2.new(0.76, 0, 0, 278)
card.BackgroundColor3 = Color3.fromRGB(17, 23, 34)
card.BackgroundTransparency = 1
card.BorderSizePixel = 0
card.ZIndex = 2
card.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(270, 250)
sizeConstraint.MaxSize = Vector2.new(540, 300)
sizeConstraint.Parent = card

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 198, 76)
stroke.Thickness = 2
stroke.Transparency = 1
stroke.Parent = card

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(19, 30, 48)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 15, 24)),
})
gradient.Rotation = 90
gradient.Parent = card

local accent = Instance.new("Frame")
accent.Name = "Accent"
accent.AnchorPoint = Vector2.new(0.5, 0)
accent.Position = UDim2.fromScale(0.5, 0)
accent.Size = UDim2.new(0.30, 0, 0, 4)
accent.BackgroundColor3 = Color3.fromRGB(255, 198, 76)
accent.BackgroundTransparency = 1
accent.BorderSizePixel = 0
accent.ZIndex = 3
accent.Parent = card

local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(1, 0)
accentCorner.Parent = accent

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 21)
padding.PaddingBottom = UDim.new(0, 18)
padding.PaddingLeft = UDim.new(0, 22)
padding.PaddingRight = UDim.new(0, 22)
padding.Parent = card

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.Parent = card

local function label(name, text, height, textSize, font, color, transparency)
    local item = Instance.new("TextLabel")
    item.Name = name
    item.Size = UDim2.new(1, 0, 0, height)
    item.BackgroundTransparency = 1
    item.Text = text
    item.TextColor3 = color
    item.TextTransparency = transparency or 1
    item.TextSize = textSize
    item.Font = font
    item.TextWrapped = true
    item.TextXAlignment = Enum.TextXAlignment.Center
    item.TextYAlignment = Enum.TextYAlignment.Center
    item.ZIndex = 3
    item.Parent = card
    return item
end

local kicker = label(
    "Kicker",
    "AFTER SCHOOL CITY",
    20,
    14,
    Enum.Font.GothamBold,
    Color3.fromRGB(118, 192, 255)
)
kicker.LayoutOrder = 1

local dedication = label(
    "Dedication",
    "A GAME MADE FOR",
    20,
    12,
    Enum.Font.GothamMedium,
    Color3.fromRGB(204, 210, 220)
)
dedication.LayoutOrder = 2

local nameLabel = label(
    "Name",
    "PUTU AZYA PUTRI\nBINTANG HARDAJAYA",
    58,
    23,
    Enum.Font.GothamBlack,
    Color3.fromRGB(255, 255, 255)
)
nameLabel.LayoutOrder = 3

local message = label(
    "Message",
    "This game was made especially for you.",
    34,
    14,
    Enum.Font.Gotham,
    Color3.fromRGB(220, 226, 236)
)
message.LayoutOrder = 4

local fromDad = label(
    "FromDad",
    "WITH LOVE, DAD",
    24,
    14,
    Enum.Font.GothamBold,
    Color3.fromRGB(255, 198, 76)
)
fromDad.LayoutOrder = 5

local spacer = Instance.new("Frame")
spacer.Name = "Spacer"
spacer.Size = UDim2.new(1, 0, 0, 2)
spacer.BackgroundTransparency = 1
spacer.LayoutOrder = 6
spacer.Parent = card

local enterButton = Instance.new("TextButton")
enterButton.Name = "EnterButton"
enterButton.Size = UDim2.new(1, 0, 0, 40)
enterButton.BackgroundColor3 = Color3.fromRGB(255, 198, 76)
enterButton.BackgroundTransparency = 1
enterButton.BorderSizePixel = 0
enterButton.Text = "ENTER THE CITY"
enterButton.TextColor3 = Color3.fromRGB(14, 18, 26)
enterButton.TextTransparency = 1
enterButton.TextSize = 14
enterButton.Font = Enum.Font.GothamBold
enterButton.AutoButtonColor = true
enterButton.LayoutOrder = 7
enterButton.ZIndex = 4
enterButton.Parent = card

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = enterButton

local scale = Instance.new("UIScale")
scale.Scale = 0.94
scale.Parent = card

local tweenIn = TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
TweenService:Create(backdrop, tweenIn, {BackgroundTransparency = 0.36}):Play()
TweenService:Create(card, tweenIn, {BackgroundTransparency = 0.04}):Play()
TweenService:Create(scale, tweenIn, {Scale = 1}):Play()
TweenService:Create(stroke, tweenIn, {Transparency = 0.15}):Play()
TweenService:Create(accent, tweenIn, {BackgroundTransparency = 0}):Play()

for _, object in ipairs({kicker, dedication, nameLabel, message, fromDad}) do
    TweenService:Create(object, tweenIn, {TextTransparency = 0}):Play()
end
TweenService:Create(enterButton, tweenIn, {BackgroundTransparency = 0, TextTransparency = 0}):Play()

local closing = false
enterButton.Activated:Connect(function()
    if closing then
        return
    end
    closing = true
    enterButton.Active = false

    local tweenOut = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(backdrop, tweenOut, {BackgroundTransparency = 1}):Play()
    TweenService:Create(card, tweenOut, {BackgroundTransparency = 1}):Play()
    TweenService:Create(scale, tweenOut, {Scale = 0.97}):Play()
    TweenService:Create(stroke, tweenOut, {Transparency = 1}):Play()
    TweenService:Create(accent, tweenOut, {BackgroundTransparency = 1}):Play()

    for _, object in ipairs({kicker, dedication, nameLabel, message, fromDad}) do
        TweenService:Create(object, tweenOut, {TextTransparency = 1}):Play()
    end
    local buttonTween = TweenService:Create(enterButton, tweenOut, {BackgroundTransparency = 1, TextTransparency = 1})
    buttonTween:Play()
    buttonTween.Completed:Wait()
    gui:Destroy()
end)
