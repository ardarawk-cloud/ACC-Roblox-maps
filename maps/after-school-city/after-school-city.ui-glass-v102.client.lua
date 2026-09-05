-- AFTER SCHOOL CITY — V1.0.2 glass HUD + Roblox topbar safe-offset pass
-- Presentation-only. Does not alter gameplay, rewards, persistence, environment, music, or dedication authority.

local Players = game:GetService("Players")

local UI_VERSION = "1.0.2-ui-glass-safe-offset-bag-1"
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("ASC_GameplayHUD", 20)
if not hud then
    warn("[ASC V1.0.2] ASC_GameplayHUD unavailable")
    return
end

hud:SetAttribute("ASC_UIVisualPass", UI_VERSION)

local function viewportSafeOffset()
    local camera = workspace.CurrentCamera
    local width = camera and camera.ViewportSize.X or 1280
    return math.clamp(math.floor(width * 0.045), 48, 78)
end

local function enforceMinimumTransparency(object, minimum)
    if not object or not object:IsA("GuiObject") then
        return
    end
    local ok = pcall(function()
        if object.BackgroundTransparency < minimum then
            object.BackgroundTransparency = minimum
        end
    end)
    if not ok then
        return
    end
    object:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
        if object.BackgroundTransparency < minimum then
            object.BackgroundTransparency = minimum
        end
    end)
end

local function alignTopPanels()
    local offset = viewportSafeOffset()
    local card = hud:FindFirstChild("StatusCard")
    if card then
        card.Position = UDim2.new(0.5, offset, 0, 18)
    end
    local missionPanel = hud:FindFirstChild("MissionPanel")
    if missionPanel then
        missionPanel.Position = UDim2.new(0.5, offset, 0, 101)
    end

    local bagPanel = hud:FindFirstChild("BagPanel")
    if bagPanel then
        local camera = workspace.CurrentCamera
        local viewportWidth = camera and camera.ViewportSize.X or 1280
        local panelWidth = bagPanel.AbsoluteSize.X > 0 and bagPanel.AbsoluteSize.X or bagPanel.Size.X.Offset
        local maxOffset = math.max(0, ((viewportWidth - panelWidth) * 0.5) - 12)
        bagPanel.Position = UDim2.new(0.5, math.min(offset, maxOffset), 0, 101)
    end
end

local card = hud:FindFirstChild("StatusCard")
local missionPanel = hud:FindFirstChild("MissionPanel")
local creditsPanel = hud:FindFirstChild("CreditsPanel")
local bagPanel = hud:FindFirstChild("BagPanel")
local toastFrame = hud:FindFirstChild("Toast")
local dialogueFrame = hud:FindFirstChild("Dialogue")

enforceMinimumTransparency(card, 0.48)
enforceMinimumTransparency(missionPanel, 0.46)
enforceMinimumTransparency(creditsPanel, 0.42)
enforceMinimumTransparency(bagPanel, 0.46)
enforceMinimumTransparency(toastFrame, 0.46)
enforceMinimumTransparency(dialogueFrame, 0.46)

for _, descendant in ipairs(hud:GetDescendants()) do
    if descendant:IsA("TextButton") then
        enforceMinimumTransparency(descendant, 0.40)
    elseif descendant:IsA("UIStroke") then
        descendant.Transparency = math.max(descendant.Transparency, 0.70)
    end
end

alignTopPanels()

local camera = workspace.CurrentCamera
if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(alignTopPanels)
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera = workspace.CurrentCamera
    alignTopPanels()
    if camera then
        camera:GetPropertyChangedSignal("ViewportSize"):Connect(alignTopPanels)
    end
end)

print("[ASC V1.0.2] Glass HUD + topbar safe offset + BAG ready", UI_VERSION)
