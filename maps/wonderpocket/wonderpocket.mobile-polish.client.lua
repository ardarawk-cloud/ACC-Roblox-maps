local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local premium = playerGui:WaitForChild("WonderPocketPremiumUI", 20)
if not premium then return end

local dock = premium:FindFirstChild("BottomDock", true)
local panelNames = {"ShopPanel", "DexPanel", "BuildPanel", "SocialPanel"}
local panels = {}
for _, name in ipairs(panelNames) do
    local panel = premium:FindFirstChild(name, true)
    if panel and panel:IsA("GuiObject") then panels[#panels+1] = panel end
end

local toast
for _, child in ipairs(premium:GetChildren()) do
    if child:IsA("TextLabel") and child.Size.Y.Offset == 44 then
        toast = child
        break
    end
end

local shopPanel = premium:FindFirstChild("ShopPanel", true)
local shopContent = shopPanel and shopPanel:FindFirstChild("Content")
local shopGrid = shopContent and shopContent:FindFirstChildOfClass("UIGridLayout")

local function tutorialActive()
    return player:GetAttribute("WP_TutorialStarted") == true
        and player:GetAttribute("WP_OnboardingComplete") ~= true
end

local function anyPanelOpen()
    for _, panel in ipairs(panels) do
        if panel.Visible then return true end
    end
    return false
end

local function syncModalDock()
    if dock then dock.Visible = not anyPanelOpen() end
end

local function applyResponsiveLayout()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local shortScreen = camera.ViewportSize.Y <= 480

    for _, panel in ipairs(panels) do
        local constraint = panel:FindFirstChildOfClass("UISizeConstraint")
        if constraint then
            constraint.MinSize = shortScreen and Vector2.new(280, 300) or Vector2.new(300, 320)
        end
        if shortScreen then
            panel.Position = UDim2.fromScale(.5, .47)
        else
            panel.Position = UDim2.fromScale(.5, .49)
        end
    end

    if shopGrid then
        shopGrid.CellSize = shortScreen and UDim2.new(.5, -4, 0, 66) or UDim2.new(.5, -4, 0, 82)
    end

    if toast then
        toast.Position = tutorialActive()
            and UDim2.new(.5, 0, 0, 162)
            or UDim2.new(.5, 0, 0, 66)
    end

    syncModalDock()
end

for _, panel in ipairs(panels) do
    panel:GetPropertyChangedSignal("Visible"):Connect(syncModalDock)
end

for _, attribute in ipairs({"WP_TutorialStarted", "WP_OnboardingComplete"}) do
    player:GetAttributeChangedSignal(attribute):Connect(applyResponsiveLayout)
end

local cameraConnection
local function bindCamera()
    if cameraConnection then cameraConnection:Disconnect() end
    local camera = Workspace.CurrentCamera
    if camera then
        cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
    end
    applyResponsiveLayout()
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()

print("[WONDERPOCKET] Android short-screen modal/dock/toast polish loaded")
