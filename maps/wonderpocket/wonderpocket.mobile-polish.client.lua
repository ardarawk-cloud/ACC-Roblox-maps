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

local healthButton
local healthPanel
local healthConstraint
local tutorialCard
local tutorialConstraint
local tutorialKicker
local tutorialObjective
local coreTop

local function findBuildControls()
    for _, instance in ipairs(premium:GetDescendants()) do
        if instance:IsA("TextButton") and instance.Text == "ROTATE" then
            local parent = instance.Parent
            if parent and parent:IsA("GuiObject") then
                local hasPlace, hasCancel = false, false
                for _, sibling in ipairs(parent:GetChildren()) do
                    if sibling:IsA("TextButton") then
                        if sibling.Text == "PLACE" then hasPlace = true end
                        if sibling.Text == "CANCEL" then hasCancel = true end
                    end
                end
                if hasPlace and hasCancel then return parent end
            end
        end
    end
    return nil
end

local buildControls = findBuildControls()

local function bindCoreHud(gui)
    if not gui or gui.Name ~= "WONDERPOCKET_UI" then return end
    coreTop = gui:FindFirstChild("TopBar")
end

local function bindHealthGui(gui)
    if not gui or gui.Name ~= "WP_ClosedTestHealth" then return end
    healthButton = nil
    healthPanel = nil
    healthConstraint = nil
    for _, child in ipairs(gui:GetChildren()) do
        if child:IsA("TextButton") then
            healthButton = child
        elseif child:IsA("TextLabel") then
            healthPanel = child
            healthConstraint = child:FindFirstChildOfClass("UISizeConstraint")
        end
    end
end

local function bindTutorialGui(gui)
    if not gui or gui.Name ~= "WP_TutorialObjective" then return end
    tutorialCard = gui:FindFirstChild("ObjectiveCard")
    tutorialConstraint = tutorialCard and tutorialCard:FindFirstChildOfClass("UISizeConstraint") or nil
    tutorialKicker = nil
    tutorialObjective = nil
    if tutorialCard then
        for _, child in ipairs(tutorialCard:GetChildren()) do
            if child:IsA("TextLabel") then
                if child.Position.Y.Offset <= 12 then tutorialKicker = child
                else tutorialObjective = child end
            end
        end
    end
end

local function tutorialActive()
    return player:GetAttribute("WP_TutorialStarted") == true
        and player:GetAttribute("WP_OnboardingComplete") ~= true
end

local function buildActive()
    return player:GetAttribute("WP_BuildActive") == true
end

local function anyPanelOpen()
    for _, panel in ipairs(panels) do
        if panel.Visible then return true end
    end
    return false
end

local function syncModalDock()
    local placing = buildActive()
    if dock then dock.Visible = not anyPanelOpen() and not placing end
    if coreTop then coreTop.Visible = not placing end
    if healthButton then healthButton.Visible = not placing end
    if placing and healthPanel then healthPanel.Visible = false end
end

local function applyResponsiveLayout()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local viewportHeight = camera.ViewportSize.Y
    local shortScreen = viewportHeight <= 480
    local placing = buildActive()

    for _, panel in ipairs(panels) do
        local constraint = panel:FindFirstChildOfClass("UISizeConstraint")
        if constraint then
            constraint.MinSize = shortScreen and Vector2.new(280, 300) or Vector2.new(300, 320)
        end
        panel.Position = shortScreen and UDim2.fromScale(.5, .47) or UDim2.fromScale(.5, .49)
    end

    if shopGrid then
        shopGrid.CellSize = shortScreen and UDim2.new(.5, -4, 0, 66) or UDim2.new(.5, -4, 0, 82)
    end

    if dock and dock.Parent then
        local dockConstraint = dock:FindFirstChildOfClass("UISizeConstraint")
        if shortScreen then
            dock.Size = UDim2.new(1,-28,0,46)
            dock.Position = UDim2.new(.5,0,1,-8)
            if dockConstraint then dockConstraint.MaxSize = Vector2.new(330,46) end
            for _, child in ipairs(dock:GetChildren()) do
                if child:IsA("TextButton") then
                    child.Size = UDim2.new(.23,0,0,36)
                    child.TextSize = 11
                end
            end
        else
            dock.Size = UDim2.new(1,-20,0,60)
            dock.Position = UDim2.new(.5,0,1,-12)
            if dockConstraint then dockConstraint.MaxSize = Vector2.new(390,60) end
            for _, child in ipairs(dock:GetChildren()) do
                if child:IsA("TextButton") then
                    child.Size = UDim2.new(.23,0,0,44)
                    child.TextSize = 13
                end
            end
        end
    end

    if toast then
        toast.Position = tutorialActive()
            and UDim2.new(.5, 0, 0, shortScreen and 136 or 162)
            or UDim2.new(.5, 0, 0, 66)
    end

    if buildControls and buildControls.Parent then
        local controlsConstraint = buildControls:FindFirstChildOfClass("UISizeConstraint")
        if shortScreen then
            buildControls.Position = UDim2.new(.5, 0, 1, -12)
            buildControls.Size = UDim2.new(1, -32, 0, 44)
            if controlsConstraint then controlsConstraint.MaxSize = Vector2.new(286, 44) end
            for _, child in ipairs(buildControls:GetChildren()) do
                if child:IsA("TextButton") then
                    child.Size = UDim2.new(.31, 0, 0, 40)
                    child.TextSize = 12
                end
            end
        else
            buildControls.Position = UDim2.new(.5, 0, 1, -80)
            buildControls.Size = UDim2.new(1, -24, 0, 54)
            if controlsConstraint then controlsConstraint.MaxSize = Vector2.new(360, 54) end
            for _, child in ipairs(buildControls:GetChildren()) do
                if child:IsA("TextButton") then
                    child.Size = UDim2.new(.31, 0, 0, 50)
                    child.TextSize = 14
                end
            end
        end
    end

    if tutorialCard and tutorialCard.Parent then
        if shortScreen then
            tutorialCard.Position = UDim2.fromOffset(10, 64)
            tutorialCard.Size = UDim2.fromOffset(placing and 258 or 282, placing and 58 or 66)
            if tutorialConstraint then
                tutorialConstraint.MinSize = Vector2.new(220, placing and 58 or 66)
                tutorialConstraint.MaxSize = Vector2.new(placing and 258 or 282, placing and 58 or 66)
            end
            if tutorialKicker then
                tutorialKicker.Position = UDim2.fromOffset(12, 5)
                tutorialKicker.Size = UDim2.new(1, -24, 0, 15)
                tutorialKicker.TextSize = 9
            end
            if tutorialObjective then
                tutorialObjective.Position = UDim2.fromOffset(12, 21)
                tutorialObjective.Size = UDim2.new(1, -24, 1, -25)
                tutorialObjective.TextSize = placing and 11 or 12
            end
        else
            tutorialCard.Position = UDim2.fromOffset(12, 70)
            tutorialCard.Size = UDim2.new(1, -24, 0, 84)
            if tutorialConstraint then
                tutorialConstraint.MinSize = Vector2.new(250, 84)
                tutorialConstraint.MaxSize = Vector2.new(320, 84)
            end
            if tutorialKicker then
                tutorialKicker.Position = UDim2.fromOffset(14, 8)
                tutorialKicker.Size = UDim2.new(1, -28, 0, 20)
                tutorialKicker.TextSize = 11
            end
            if tutorialObjective then
                tutorialObjective.Position = UDim2.fromOffset(14, 29)
                tutorialObjective.Size = UDim2.new(1, -28, 0, 43)
                tutorialObjective.TextSize = 15
            end
        end
    end

    if healthButton and healthButton.Parent then
        if shortScreen then
            healthButton.Size = UDim2.fromOffset(64, 28)
            healthButton.Position = UDim2.new(1, -8, 0, 52)
            healthButton.TextSize = 11
        else
            healthButton.Size = UDim2.fromOffset(82, 34)
            healthButton.Position = UDim2.new(1, -10, 0, 72)
            healthButton.TextSize = 13
        end
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

for _, attribute in ipairs({"WP_TutorialStarted", "WP_OnboardingComplete", "WP_BuildActive"}) do
    player:GetAttributeChangedSignal(attribute):Connect(applyResponsiveLayout)
end

playerGui.ChildAdded:Connect(function(child)
    if child.Name == "WP_ClosedTestHealth" then
        task.defer(function()
            bindHealthGui(child)
            applyResponsiveLayout()
        end)
    elseif child.Name == "WP_TutorialObjective" then
        task.defer(function()
            bindTutorialGui(child)
            applyResponsiveLayout()
        end)
    elseif child.Name == "WONDERPOCKET_UI" then
        task.defer(function()
            bindCoreHud(child)
            applyResponsiveLayout()
        end)
    end
end)

bindCoreHud(playerGui:FindFirstChild("WONDERPOCKET_UI"))
bindHealthGui(playerGui:FindFirstChild("WP_ClosedTestHealth"))
bindTutorialGui(playerGui:FindFirstChild("WP_TutorialObjective"))

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

print("[WONDERPOCKET] Android gameplay-first compact HUD + focused placement UI loaded")
