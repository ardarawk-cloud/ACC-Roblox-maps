-- AFTER SCHOOL CITY — V1.5 City Guide + Wayfinding
-- Client-only activity directory and selectable waypoint.
-- Does not alter rewards, quests, DataStore, BAG/economy, music, sports, or activity authority.

local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local VERSION = "1.5.0-city-guide-wayfinding-1"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local localeId = string.lower(LocalizationService.RobloxLocaleId or "en-us")
local language = string.sub(localeId, 1, 2) == "id" and "id" or "en"

local previous = playerGui:FindFirstChild("ASC_CityGuideV150")
if previous then
    previous:Destroy()
end

local ACTIVITIES = {
    {
        Id = "SKATE_LINE",
        Title = {en = "Skate Line", id = "Jalur Skate"},
        Area = {en = "Skatepark", id = "Skatepark"},
        Coins = 180,
        Rep = 55,
        Path = {"V110_FirstPlayableLoop", "SkateActivityStart"},
    },
    {
        Id = "POOL_LAPS",
        Title = {en = "Pool Laps", id = "Putaran Kolam"},
        Area = {en = "City Pool", id = "Kolam Kota"},
        Coins = 160,
        Rep = 50,
        Path = {"V110_FirstPlayableLoop", "PoolActivityStart"},
    },
    {
        Id = "CITY_DELIVERY",
        Title = {en = "City Delivery", id = "Antar Kota"},
        Area = {en = "City Route", id = "Rute Kota"},
        Coins = 220,
        Rep = 65,
        Path = {"V110_FirstPlayableLoop", "DeliveryActivityStart"},
    },
    {
        Id = "CAFE_RUSH",
        Title = {en = "Cafe Rush", id = "Cafe Rush"},
        Area = {en = "Cafe", id = "Kafe"},
        Coins = 130,
        Rep = 40,
        Path = {"V140_CityLifeExpansion", "CafeRush", "CAFE_RUSH_Start", "PromptPost"},
    },
    {
        Id = "ARCADE_CIRCUIT",
        Title = {en = "Arcade Circuit", id = "Sirkuit Arcade"},
        Area = {en = "Arcade", id = "Arcade"},
        Coins = 120,
        Rep = 35,
        Path = {"V140_CityLifeExpansion", "ArcadeCircuit", "ARCADE_CIRCUIT_Start", "PromptPost"},
    },
    {
        Id = "PARK_CLEANUP",
        Title = {en = "Park Cleanup", id = "Bersih-Bersih Taman"},
        Area = {en = "City Park", id = "Taman Kota"},
        Coins = 150,
        Rep = 45,
        Path = {"V140_CityLifeExpansion", "ParkCleanup", "PARK_CLEANUP_Start", "PromptPost"},
    },
    {
        Id = "STYLE_CHECK",
        Title = {en = "Style Check", id = "Cek Gaya"},
        Area = {en = "Style Shop", id = "Toko Style"},
        Coins = 125,
        Rep = 35,
        Path = {"V141_CityLifeExpansionBatch2", "StyleCheck", "STYLE_CHECK_Start", "PromptPost"},
    },
    {
        Id = "MUSIC_SESSION",
        Title = {en = "Music Session", id = "Sesi Musik"},
        Area = {en = "Music Shop", id = "Toko Musik"},
        Coins = 145,
        Rep = 45,
        Path = {"V141_CityLifeExpansionBatch2", "MusicSession", "MUSIC_SESSION_Start", "PromptPost"},
    },
    {
        Id = "HOBBY_BUILD",
        Title = {en = "Hobby Build", id = "Hobby Build"},
        Area = {en = "Hobby Shop", id = "Toko Hobi"},
        Coins = 135,
        Rep = 40,
        Path = {"V141_CityLifeExpansionBatch2", "HobbyBuild", "HOBBY_BUILD_Start", "PromptPost"},
    },
    {
        Id = "NEIGHBORHOOD_RUN",
        Title = {en = "Neighborhood Run", id = "Rute Lingkungan"},
        Area = {en = "Residential", id = "Perumahan"},
        Coins = 170,
        Rep = 50,
        Path = {"V141_CityLifeExpansionBatch2", "NeighborhoodRun", "NEIGHBORHOOD_RUN_Start", "PromptPost"},
    },
}

local T = language == "id" and {
    tab = "KOTA",
    heading = "PANDUAN AKTIVITAS",
    subheading = "Pilih aktivitas untuk pasang penunjuk arah.",
    close = "TUTUP",
    clear = "HAPUS ARAH",
    selected = "TUJUAN",
    loading = "Mencari titik mulai...",
    unavailable = "Titik mulai belum tersedia.",
    distance = "jarak",
    coins = "Koin",
    rep = "Rep",
} or {
    tab = "CITY",
    heading = "ACTIVITY GUIDE",
    subheading = "Choose an activity to place a waypoint.",
    close = "CLOSE",
    clear = "CLEAR WAYPOINT",
    selected = "WAYPOINT",
    loading = "Finding start marker...",
    unavailable = "Start marker is not available yet.",
    distance = "away",
    coins = "Coins",
    rep = "Rep",
}

local gui = Instance.new("ScreenGui")
gui.Name = "ASC_CityGuideV150"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 24
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui:SetAttribute("ASC_Version", VERSION)
gui:SetAttribute("ASC_Locale", localeId)
gui.Parent = playerGui

local tab = Instance.new("TextButton")
tab.Name = "CityGuideTab"
tab.AnchorPoint = Vector2.new(0, 0.5)
tab.Position = UDim2.new(0, 8, 0.52, 0)
tab.Size = UDim2.fromOffset(58, 34)
tab.BackgroundColor3 = Color3.fromRGB(29, 43, 64)
tab.BackgroundTransparency = 0.12
tab.BorderSizePixel = 0
tab.Font = Enum.Font.GothamBold
tab.TextSize = 10
tab.TextColor3 = Color3.fromRGB(226, 232, 240)
tab.Text = T.tab
tab.AutoButtonColor = true
tab.ZIndex = 50
tab.Parent = gui
local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 9)
tabCorner.Parent = tab
local tabStroke = Instance.new("UIStroke")
tabStroke.Thickness = 1
tabStroke.Transparency = 0.55
tabStroke.Color = Color3.fromRGB(147, 197, 253)
tabStroke.Parent = tab

local panel = Instance.new("Frame")
panel.Name = "GuidePanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(360, 460)
panel.BackgroundColor3 = Color3.fromRGB(14, 20, 31)
panel.BackgroundTransparency = 0.04
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 60
panel.Parent = gui
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = panel
local panelStroke = Instance.new("UIStroke")
panelStroke.Thickness = 1
panelStroke.Transparency = 0.38
panelStroke.Color = Color3.fromRGB(147, 197, 253)
panelStroke.Parent = panel

local heading = Instance.new("TextLabel")
heading.BackgroundTransparency = 1
heading.Position = UDim2.fromOffset(16, 12)
heading.Size = UDim2.new(1, -96, 0, 20)
heading.Font = Enum.Font.GothamBlack
heading.TextSize = 13
heading.TextXAlignment = Enum.TextXAlignment.Left
heading.TextColor3 = Color3.fromRGB(255, 255, 255)
heading.Text = T.heading
heading.ZIndex = 61
heading.Parent = panel

local subheading = Instance.new("TextLabel")
subheading.BackgroundTransparency = 1
subheading.Position = UDim2.fromOffset(16, 34)
subheading.Size = UDim2.new(1, -32, 0, 28)
subheading.Font = Enum.Font.GothamMedium
subheading.TextSize = 10
subheading.TextWrapped = true
subheading.TextXAlignment = Enum.TextXAlignment.Left
subheading.TextYAlignment = Enum.TextYAlignment.Top
subheading.TextColor3 = Color3.fromRGB(148, 163, 184)
subheading.Text = T.subheading
subheading.ZIndex = 61
subheading.Parent = panel

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -12, 0, 10)
close.Size = UDim2.fromOffset(66, 24)
close.BackgroundColor3 = Color3.fromRGB(35, 45, 62)
close.BackgroundTransparency = 0.25
close.BorderSizePixel = 0
close.Font = Enum.Font.GothamBold
close.TextSize = 9
close.TextColor3 = Color3.fromRGB(226, 232, 240)
close.Text = T.close
close.ZIndex = 62
close.Parent = panel
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = close

local selectedBar = Instance.new("Frame")
selectedBar.Name = "SelectedBar"
selectedBar.Position = UDim2.fromOffset(12, 67)
selectedBar.Size = UDim2.new(1, -24, 0, 49)
selectedBar.BackgroundColor3 = Color3.fromRGB(25, 37, 55)
selectedBar.BackgroundTransparency = 0.22
selectedBar.BorderSizePixel = 0
selectedBar.ZIndex = 61
selectedBar.Parent = panel
local selectedCorner = Instance.new("UICorner")
selectedCorner.CornerRadius = UDim.new(0, 9)
selectedCorner.Parent = selectedBar

local selectedText = Instance.new("TextLabel")
selectedText.BackgroundTransparency = 1
selectedText.Position = UDim2.fromOffset(10, 6)
selectedText.Size = UDim2.new(1, -112, 1, -12)
selectedText.Font = Enum.Font.GothamMedium
selectedText.TextSize = 10
selectedText.TextWrapped = true
selectedText.TextXAlignment = Enum.TextXAlignment.Left
selectedText.TextYAlignment = Enum.TextYAlignment.Center
selectedText.TextColor3 = Color3.fromRGB(203, 213, 225)
selectedText.Text = T.selected .. ": —"
selectedText.ZIndex = 62
selectedText.Parent = selectedBar

local clearButton = Instance.new("TextButton")
clearButton.AnchorPoint = Vector2.new(1, 0.5)
clearButton.Position = UDim2.new(1, -8, 0.5, 0)
clearButton.Size = UDim2.fromOffset(92, 28)
clearButton.BackgroundColor3 = Color3.fromRGB(54, 65, 83)
clearButton.BackgroundTransparency = 0.28
clearButton.BorderSizePixel = 0
clearButton.Font = Enum.Font.GothamBold
clearButton.TextSize = 8
clearButton.TextColor3 = Color3.fromRGB(226, 232, 240)
clearButton.Text = T.clear
clearButton.Visible = false
clearButton.ZIndex = 62
clearButton.Parent = selectedBar
local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 7)
clearCorner.Parent = clearButton

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "ActivityList"
scroll.Position = UDim2.fromOffset(12, 126)
scroll.Size = UDim2.new(1, -24, 1, -138)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.fromOffset(0, 0)
scroll.ZIndex = 61
scroll.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local root = Workspace:WaitForChild("AfterSchoolCity", 30)
local selectedActivity = nil
local selectedTarget = nil
local waypointGui = nil
local distanceAccumulator = 0
local activityButtons = {}

local function localized(value)
    if type(value) == "table" then
        return value[language] or value.en or ""
    end
    return tostring(value or "")
end

local function findTarget(activity)
    if not root or not root.Parent then
        root = Workspace:FindFirstChild("AfterSchoolCity")
    end
    if not root then
        return nil
    end

    local current = root
    for _, name in ipairs(activity.Path) do
        current = current and current:FindFirstChild(name)
        if not current then
            return nil
        end
    end

    if current:IsA("BasePart") then
        return current
    end

    if current:IsA("Model") then
        return current.PrimaryPart or current:FindFirstChildWhichIsA("BasePart", true)
    end

    return current:FindFirstChildWhichIsA("BasePart", true)
end

local function destroyWaypoint()
    if waypointGui then
        waypointGui:Destroy()
        waypointGui = nil
    end
    selectedActivity = nil
    selectedTarget = nil
    clearButton.Visible = false
    selectedText.Text = T.selected .. ": —"
    for _, button in pairs(activityButtons) do
        button.BackgroundColor3 = Color3.fromRGB(27, 36, 51)
    end
end

local function makeWaypoint(target, activity)
    if waypointGui then
        waypointGui:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ASC_LocalWaypointV150"
    billboard.Size = UDim2.fromOffset(180, 46)
    billboard.StudsOffset = Vector3.new(0, 4.8, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 650
    billboard.LightInfluence = 0
    billboard.Adornee = target
    billboard.Parent = gui

    local body = Instance.new("Frame")
    body.Size = UDim2.fromScale(1, 1)
    body.BackgroundColor3 = Color3.fromRGB(14, 20, 31)
    body.BackgroundTransparency = 0.12
    body.BorderSizePixel = 0
    body.Parent = billboard
    local bodyCorner = Instance.new("UICorner")
    bodyCorner.CornerRadius = UDim.new(0, 10)
    bodyCorner.Parent = body
    local bodyStroke = Instance.new("UIStroke")
    bodyStroke.Thickness = 1
    bodyStroke.Transparency = 0.3
    bodyStroke.Color = Color3.fromRGB(96, 165, 250)
    bodyStroke.Parent = body

    local label = Instance.new("TextLabel")
    label.Name = "WaypointText"
    label.Size = UDim2.new(1, -12, 1, -8)
    label.Position = UDim2.fromOffset(6, 4)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextWrapped = true
    label.TextColor3 = Color3.fromRGB(241, 245, 249)
    label.Text = localized(activity.Title)
    label.Parent = body

    waypointGui = billboard
end

local function setWaypoint(activity)
    selectedText.Text = T.loading
    local target = findTarget(activity)

    if not target then
        local deadline = os.clock() + 4
        repeat
            task.wait(0.25)
            target = findTarget(activity)
        until target or os.clock() >= deadline
    end

    if not target then
        selectedText.Text = T.unavailable
        return
    end

    selectedActivity = activity
    selectedTarget = target
    clearButton.Visible = true
    makeWaypoint(target, activity)

    for id, button in pairs(activityButtons) do
        button.BackgroundColor3 = id == activity.Id and Color3.fromRGB(38, 66, 98) or Color3.fromRGB(27, 36, 51)
    end
end

for index, activity in ipairs(ACTIVITIES) do
    local button = Instance.new("TextButton")
    button.Name = "Activity_" .. activity.Id
    button.Size = UDim2.new(1, -4, 0, 58)
    button.BackgroundColor3 = Color3.fromRGB(27, 36, 51)
    button.BackgroundTransparency = 0.18
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.LayoutOrder = index
    button.Text = ""
    button.ZIndex = 62
    button.Parent = scroll
    activityButtons[activity.Id] = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = button

    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Position = UDim2.fromOffset(12, 7)
    name.Size = UDim2.new(1, -24, 0, 19)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 11
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextColor3 = Color3.fromRGB(241, 245, 249)
    name.Text = localized(activity.Title)
    name.ZIndex = 63
    name.Parent = button

    local meta = Instance.new("TextLabel")
    meta.BackgroundTransparency = 1
    meta.Position = UDim2.fromOffset(12, 29)
    meta.Size = UDim2.new(1, -24, 0, 18)
    meta.Font = Enum.Font.GothamMedium
    meta.TextSize = 9
    meta.TextXAlignment = Enum.TextXAlignment.Left
    meta.TextColor3 = Color3.fromRGB(148, 163, 184)
    meta.Text = string.format(
        "%s  •  %d %s  •  +%d %s",
        localized(activity.Area),
        activity.Coins,
        T.coins,
        activity.Rep,
        T.rep
    )
    meta.ZIndex = 63
    meta.Parent = button

    button.Activated:Connect(function()
        setWaypoint(activity)
    end)
end

local function refreshSelectedDistance()
    if not selectedActivity or not selectedTarget or not selectedTarget.Parent then
        if selectedActivity then
            selectedTarget = findTarget(selectedActivity)
            if selectedTarget then
                makeWaypoint(selectedTarget, selectedActivity)
            else
                selectedText.Text = T.unavailable
                return
            end
        else
            return
        end
    end

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        selectedText.Text = string.format("%s: %s", T.selected, localized(selectedActivity.Title))
        return
    end

    local distance = math.floor((rootPart.Position - selectedTarget.Position).Magnitude + 0.5)
    selectedText.Text = string.format(
        "%s: %s  •  %d studs %s",
        T.selected,
        localized(selectedActivity.Title),
        distance,
        T.distance
    )

    if waypointGui then
        local label = waypointGui:FindFirstChild("Frame") and waypointGui.Frame:FindFirstChild("WaypointText")
        if not label then
            local body = waypointGui:FindFirstChildWhichIsA("Frame")
            label = body and body:FindFirstChild("WaypointText")
        end
        if label then
            label.Text = string.format("%s\n%d studs", localized(selectedActivity.Title), distance)
        end
    end
end

local function layoutPanel()
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local width = math.max(286, math.min(360, viewport.X - 24))
    local height = math.max(330, math.min(460, viewport.Y - 36))
    panel.Size = UDim2.fromOffset(width, height)
end

tab.Activated:Connect(function()
    panel.Visible = not panel.Visible
    layoutPanel()
end)

close.Activated:Connect(function()
    panel.Visible = false
end)

clearButton.Activated:Connect(function()
    destroyWaypoint()
end)

local cameraConnection = nil
local function bindCamera()
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
    local camera = Workspace.CurrentCamera
    if camera then
        cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutPanel)
    end
    layoutPanel()
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()

RunService.Heartbeat:Connect(function(dt)
    distanceAccumulator += dt
    if distanceAccumulator >= 0.25 then
        distanceAccumulator = 0
        refreshSelectedDistance()
    end
end)

gui.AncestryChanged:Connect(function(_, parent)
    if not parent and cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end
end)

print("[AFTER SCHOOL CITY] V1.5 City Guide + Wayfinding ready — 10 activities")
