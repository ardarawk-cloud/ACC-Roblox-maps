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

local healthPanel
local healthConstraint

local function bindHealthGui(gui)
    if not gui or gui.Name ~= "WP_ClosedTestHealth" then return end
    healthPanel = nil
    healthConstraint = nil
    for _, child in ipairs(gui:GetChildren()) do
        if child:IsA("TextLabel") then
            healthPanel = child
            healthConstraint = child:FindFirstChildOfClass("UISizeConstraint")
            break
        end
    end
end

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
    local viewportHeight = camera.ViewportSize.Y
    local shortScreen = viewportHeight <= 480

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

    if healthPanel and healthPanel.Parent then
        healthPanel.TextSize = shortScreen and 10 or 12
        if healthConstraint then
            if shortScreen then
                healthConstraint.MinSize = Vector2.new(260, 220)
                healthConstraint.MaxSize = Vector2.new(340, math.max(220, viewportHeight - 128))
            else
                healthConstraint.MinSize = Vector2.new(285, 340)
                healthConstraint.MaxSize = Vector2.new(350, 460)
            end
        end
    end

    syncModalDock()
end

for _, panel in ipairs(panels) do
    panel:GetPropertyChangedSignal("Visible"):Connect(syncModalDock)
end

for _, attribute in ipairs({"WP_TutorialStarted", "WP_OnboardingComplete"}) do
    player:GetAttributeChangedSignal(attribute):Connect(applyResponsiveLayout)
end

playerGui.ChildAdded:Connect(function(child)
    if child.Name == "WP_ClosedTestHealth" then
        task.defer(function()
            bindHealthGui(child)
            applyResponsiveLayout()
        end)
    end
end)

bindHealthGui(playerGui:FindFirstChild("WP_ClosedTestHealth"))

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

print("[WONDERPOCKET] Android short-screen modal/dock/toast/health polish loaded")
