local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local premium = playerGui:WaitForChild("WonderPocketPremiumUI", 20)
if not premium then return end

local dock = premium:FindFirstChild("BottomDock", true)
if not dock or not dock:IsA("GuiObject") then return end

local panelNames = {"ShopPanel", "DexPanel", "BuildPanel", "SocialPanel"}
local panels = {}
for _, name in ipairs(panelNames) do
    local panel = premium:FindFirstChild(name, true)
    if panel and panel:IsA("GuiObject") then panels[#panels+1] = panel end
end

local dockButtons = {}
for _, child in ipairs(dock:GetChildren()) do
    if child:IsA("TextButton") and table.find({"SHOP", "DEX", "BUILD", "SOCIAL"}, child.Text) then
        dockButtons[#dockButtons+1] = child
    end
end

local oldMenu = dock:FindFirstChild("CompactMenuButton")
if oldMenu then oldMenu:Destroy() end

local menu = Instance.new("TextButton")
menu.Name = "CompactMenuButton"
menu.Size = UDim2.fromOffset(96, 34)
menu.BackgroundColor3 = Color3.fromRGB(54,78,150)
menu.TextColor3 = Color3.new(1,1,1)
menu.Text = "MENU"
menu.Font = Enum.Font.GothamBold
menu.TextSize = 12
menu.Visible = false
menu.Parent = dock
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 13)
corner.Parent = menu

local dockConstraint = dock:FindFirstChildOfClass("UISizeConstraint")
local expanded = false

local function shortLandscape()
    local camera = Workspace.CurrentCamera
    if not camera then return false end
    local size = camera.ViewportSize
    return size.Y <= 480 and size.X > size.Y
end

local function anyPanelOpen()
    for _, panel in ipairs(panels) do
        if panel.Visible then return true end
    end
    return false
end

local function setDockButtonsVisible(visible)
    for _, button in ipairs(dockButtons) do
        if button.Parent then button.Visible = visible end
    end
end

local function apply()
    local compact = shortLandscape()
    local blocked = player:GetAttribute("WP_BuildActive") == true or anyPanelOpen()

    if not compact then
        expanded = false
        menu.Visible = false
        setDockButtonsVisible(true)
        dock.Size = UDim2.new(1,-20,0,60)
        dock.Position = UDim2.new(.5,0,1,-12)
        if dockConstraint then dockConstraint.MaxSize = Vector2.new(390,60) end
        return
    end

    if blocked then
        expanded = false
        menu.Visible = false
        setDockButtonsVisible(false)
        dock.Visible = false
        return
    end

    dock.Visible = true
    dock.Position = UDim2.new(.5,0,1,-8)

    if expanded then
        menu.Visible = false
        setDockButtonsVisible(true)
        dock.Size = UDim2.new(1,-28,0,46)
        if dockConstraint then dockConstraint.MaxSize = Vector2.new(330,46) end
        for _, button in ipairs(dockButtons) do
            button.Size = UDim2.new(.23,0,0,36)
            button.TextSize = 11
        end
    else
        setDockButtonsVisible(false)
        menu.Visible = true
        menu.Size = UDim2.fromOffset(96,34)
        menu.TextSize = 12
        dock.Size = UDim2.fromOffset(112,42)
        if dockConstraint then dockConstraint.MaxSize = Vector2.new(112,42) end
    end
end

menu.Activated:Connect(function()
    expanded = not expanded
    apply()
end)

for _, panel in ipairs(panels) do
    panel:GetPropertyChangedSignal("Visible"):Connect(function()
        if panel.Visible then expanded = false end
        apply()
    end)
end

player:GetAttributeChangedSignal("WP_BuildActive"):Connect(function()
    if player:GetAttribute("WP_BuildActive") == true then expanded = false end
    apply()
end)

local cameraConnection
local function bindCamera()
    if cameraConnection then cameraConnection:Disconnect() end
    local camera = Workspace.CurrentCamera
    if camera then
        cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(apply)
    end
    apply()
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()

print("[WONDERPOCKET] Android compact MENU dock ready")
