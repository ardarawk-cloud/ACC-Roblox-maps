-- AEROCLUB HANGAR — ClientSettings v1.0
-- Local-only visual/privacy preferences. Server remains authoritative.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local settings = {
    DisableLasers = false,
    DisableCarry = false,
    HideTitles = false,
}

local function lightingEquipment()
    return workspace:FindFirstChild("LightingEquipment")
end

local function applyLasers()
    local root = lightingEquipment()
    local lasers = root and root:FindFirstChild("Lasers")
    if not lasers then return end
    for _, d in ipairs(lasers:GetDescendants()) do
        if d:IsA("Beam") or d:IsA("SpotLight") or d:IsA("PointLight") or d:IsA("SurfaceLight") then
            d.Enabled = not settings.DisableLasers
        elseif d:IsA("BasePart") and d:GetAttribute("LaserVisual") == true then
            d.LocalTransparencyModifier = settings.DisableLasers and 1 or 0
        end
    end
end

local function applyTitles()
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            local head = other.Character:FindFirstChild("Head")
            local tag = head and head:FindFirstChild("TitleBillboard")
            if tag and tag:IsA("BillboardGui") then tag.Enabled = not settings.HideTitles end
        end
    end
end

local function bindButton(button, callback)
    if not button or not button:IsA("GuiButton") then return end
    button.Activated:Connect(callback)
end

local function hookUI()
    local gui = player:WaitForChild("PlayerGui")
    local main = gui:FindFirstChild("MainHUD")
    if not main then return end
    local frame = main:FindFirstChild("FrameSettings", true)
    if not frame then return end

    bindButton(frame:FindFirstChild("LaserToggle", true), function()
        settings.DisableLasers = not settings.DisableLasers
        applyLasers()
    end)
    bindButton(frame:FindFirstChild("HideTitleToggle", true), function()
        settings.HideTitles = not settings.HideTitles
        applyTitles()
    end)
    bindButton(frame:FindFirstChild("DisableCarryToggle", true), function()
        settings.DisableCarry = not settings.DisableCarry
        player:SetAttribute("DisableCarry", settings.DisableCarry)
    end)
end

Players.PlayerAdded:Connect(function(other)
    other.CharacterAdded:Connect(function()
        task.wait(1)
        applyTitles()
    end)
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    applyLasers()
    applyTitles()
end)

player.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "MainHUD" then task.defer(hookUI) end
end)

task.defer(hookUI)
print("[AEROCLUB] ClientSettings v1.0 ready")
