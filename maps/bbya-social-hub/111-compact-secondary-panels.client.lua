-- BBYA SOCIAL HUB — DJ LIVE READINESS BRIDGE v5
-- DJ / MENU INTEROP ONLY.
-- Main BBYACommandMenuUI remains the single visible DJ LIVE launcher.
-- Developer DJ v3/v4 remains the single full-screen console authority.
-- This bridge only prevents early clicks before the console is ready, hides the
-- legacy standalone fallback button, and restores MENU after the DJ console closes.
-- Music Suite / audio / playlists / venue routing are intentionally untouched.

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local NAME = "BBYADJLiveReadinessBridgeV5"
local old = pg:FindFirstChild(NAME)
if old then old:Destroy() end

local marker = Instance.new("ScreenGui")
marker.Name = NAME
marker.ResetOnSpawn = false
marker.IgnoreGuiInset = true
marker.DisplayOrder = 1
marker.Parent = pg

local panelBound = setmetatable({}, {__mode = "k"})
local launcherBound = setmetatable({}, {__mode = "k"})

local function commandMenu()
    return pg:FindFirstChild("BBYACommandMenuUI")
end

local function menuParts()
    local menu = commandMenu()
    if not menu then return nil, nil, nil end
    local drawer = menu:FindFirstChild("FeatureDrawer", true)
    local menuButton = menu:FindFirstChild("MenuButton", true)
    local list = drawer and drawer:FindFirstChild("FeatureList", true)
    return drawer, menuButton, list
end

local function developerPanel()
    local gui = pg:FindFirstChild("BBYADeveloperDJUI")
    local panel = gui and gui:FindFirstChild("DeveloperDJMixerPanel", true)
    if panel and panel:IsA("GuiObject") then
        return panel
    end
    return nil
end

local function mainDJButton()
    local _, _, list = menuParts()
    if not list then return nil end

    for _, d in ipairs(list:GetDescendants()) do
        if d:IsA("TextButton") then
            local text = string.upper(tostring(d.Text or ""))
            if text == "DJ LIVE" or text:find("DJ LIVE", 1, true) == 1 then
                return d
            end
        end
    end
    return nil
end

local function suppressStandaloneFallback()
    local gui = pg:FindFirstChild("BBYADeveloperDJUI")
    if not gui then return end

    for _, d in ipairs(gui:GetDescendants()) do
        if d.Name == "FallbackDJButton" and d:IsA("GuiButton") then
            d.Visible = false
            d.Active = false
            d.AutoButtonColor = false
            d.Selectable = false
            pcall(function() d.Interactable = false end)
            d:SetAttribute("BBYARetiredStandaloneDJLauncher", true)
        end
    end
end

local function setLauncherReady(button, ready)
    if not button or not button.Parent then return end

    button:SetAttribute("BBYADJConsoleReady", ready)
    button.Active = ready
    button.Selectable = ready
    button.AutoButtonColor = ready
    pcall(function() button.Interactable = ready end)

    if ready then
        button.Text = "DJ LIVE"
        button.TextTransparency = 0
    else
        button.Text = "DJ LIVE • LOADING"
        button.TextTransparency = 0.18
    end
end

local function bindPanel(panel)
    if not panel or panelBound[panel] then return end
    panelBound[panel] = true

    panel:GetPropertyChangedSignal("Visible"):Connect(function()
        local drawer, menuButton = menuParts()
        if panel.Visible then
            if drawer and drawer:IsA("GuiObject") then drawer.Visible = false end
            if menuButton and menuButton:IsA("GuiButton") then
                menuButton.Visible = false
                menuButton.Text = "MENU"
            end
        else
            if menuButton and menuButton:IsA("GuiButton") then
                menuButton.Visible = true
                menuButton.Text = "MENU"
            end
        end
    end)
end

local function bindLauncher(button)
    if not button or launcherBound[button] then return end
    launcherBound[button] = true
    button:SetAttribute("BBYADJLauncherAuthority", "COMMAND_MENU_KERNEL")
end

local function rescan()
    suppressStandaloneFallback()

    local button = mainDJButton()
    local panel = developerPanel()

    if panel then bindPanel(panel) end
    if button then
        bindLauncher(button)
        setLauncherReady(button, panel ~= nil)
    end
end

pg.DescendantAdded:Connect(function(desc)
    if desc.Name == "BBYACommandMenuUI"
        or desc.Name == "FeatureDrawer"
        or desc.Name == "FeatureList"
        or desc.Name == "BBYADeveloperDJUI"
        or desc.Name == "DeveloperDJMixerPanel"
        or desc.Name == "FallbackDJButton"
        or (desc:IsA("TextButton") and string.find(string.upper(tostring(desc.Text or "")), "DJ LIVE", 1, true))
    then
        task.defer(rescan)
    end
end)

pg.DescendantRemoving:Connect(function(desc)
    if desc.Name == "BBYADeveloperDJUI" or desc.Name == "DeveloperDJMixerPanel" then
        task.defer(rescan)
    end
end)

task.spawn(function()
    local deadline = os.clock() + 35
    repeat
        rescan()
        task.wait(0.20)
    until os.clock() >= deadline
end)

task.defer(rescan)

print("[BBYA] DJ LIVE READINESS BRIDGE v5 online — command-menu launcher + developer console, Music untouched")
