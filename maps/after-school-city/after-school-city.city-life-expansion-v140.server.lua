-- AFTER SCHOOL CITY — V1.4 City Life Expansion / Batch 1
-- Adds three low-risk repeatable after-school activities to decorative city areas:
-- Cafe Rush, Arcade Circuit, and Park Cleanup.
-- Reuses the existing GameplayService reward/cooldown authority.
-- No DataStore schema, economy catalog, BAG, music, quest chain, monetization, or sports authority changes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local GameplayService = require(ServerScriptService:WaitForChild("ASC_GameplayService"))

local VERSION = "1.4.0-city-life-expansion-batch1"

local root = Workspace:WaitForChild("AfterSchoolCity", 30)
if not root then
    warn("[ASC V140] AfterSchoolCity root missing")
    return
end

if root:GetAttribute("ASC_CityLifeExpansionV140") == VERSION then
    return
end

local districts = root:WaitForChild("Districts", 20)
local downtown = districts and districts:FindFirstChild("Downtown")
local park = districts and districts:FindFirstChild("Park")
if not downtown then
    warn("[ASC V140] Downtown missing")
    return
end

local existing = root:FindFirstChild("V140_CityLifeExpansion")
if existing then
    existing:Destroy()
end

local layer = Instance.new("Model")
layer.Name = "V140_CityLifeExpansion"
layer:SetAttribute("ASC_Layer", "CITY_LIFE_EXPANSION")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local active = {}

local C = {
    navy = Color3.fromRGB(35, 49, 72),
    cream = Color3.fromRGB(235, 229, 214),
    gold = Color3.fromRGB(225, 170, 73),
    teal = Color3.fromRGB(64, 145, 133),
    purple = Color3.fromRGB(130, 94, 158),
    green = Color3.fromRGB(83, 142, 91),
    metal = Color3.fromRGB(78, 84, 94),
    dark = Color3.fromRGB(31, 35, 43),
    white = Color3.fromRGB(242, 246, 250),
}

local ACTIVITIES = {
    CAFE_RUSH = {
        Title = "Cafe Rush",
        CooldownSeconds = 90,
        RewardCoins = 130,
        RewardRep = 40,
        Speaker = "CAFE CREW",
        StartText = "Three quick tasks: take the order, prep the drink, then serve it.",
        CompleteText = "Rush cleared. Nice work.",
        Steps = {"TAKE ORDER", "PREP DRINK", "SERVE ORDER"},
    },
    ARCADE_CIRCUIT = {
        Title = "Arcade Circuit",
        CooldownSeconds = 90,
        RewardCoins = 120,
        RewardRep = 35,
        Speaker = "ARCADE HOST",
        StartText = "Clear all three machines in order.",
        CompleteText = "Circuit complete. High score run finished.",
        Steps = {"MACHINE 1", "MACHINE 2", "MACHINE 3"},
    },
    PARK_CLEANUP = {
        Title = "Park Cleanup",
        CooldownSeconds = 105,
        RewardCoins = 150,
        RewardRep = 45,
        Speaker = "PARK VOLUNTEER",
        StartText = "Pick up two litter spots, then finish at the recycle point.",
        CompleteText = "Park route cleared. Thanks for helping the city.",
        Steps = {"PICK UP", "PICK UP", "RECYCLE"},
    },
}

local function visualPart(parent, name, size, cf, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function makeBillboard(parent, text, color)
    local gui = Instance.new("BillboardGui")
    gui.Name = "ActivityLabel"
    gui.Size = UDim2.fromOffset(150, 30)
    gui.StudsOffset = Vector3.new(0, 3.6, 0)
    gui.AlwaysOnTop = false
    gui.MaxDistance = 34
    gui.LightInfluence = 0.2
    gui.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = C.dark
    label.BackgroundTransparency = 0.28
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = color or C.white
    label.Text = text
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = label
end

local function makePrompt(parent, name, actionText, objectText)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = name
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    prompt.HoldDuration = 0.18
    prompt.MaxActivationDistance = 9
    prompt.RequiresLineOfSight = false
    prompt.Parent = parent
    return prompt
end

local function groundAt(position)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {layer}
    params.IgnoreWater = false

    local result = Workspace:Raycast(position + Vector3.new(0, 24, 0), Vector3.new(0, -60, 0), params)
    if result then
        return result.Position
    end
    return Vector3.new(position.X, 1.5, position.Z)
end

local function shopFront(shop, lateral)
    if shop then
        local cf, size = shop:GetBoundingBox()
        return groundAt(cf.Position + cf.RightVector * (lateral or 0) + cf.LookVector * (-(size.Z * 0.5 + 5)))
    end
    return nil
end

local function makeStartStation(parent, activityId, pos, color)
    local model = Instance.new("Model")
    model.Name = activityId .. "_Start"
    model.Parent = parent

    local base = visualPart(
        model,
        "Base",
        Vector3.new(4.8, 0.35, 4.8),
        CFrame.new(pos + Vector3.new(0, 0.18, 0)),
        color,
        Enum.Material.SmoothPlastic
    )
    base.Transparency = 0.08

    local post = visualPart(
        model,
        "Post",
        Vector3.new(0.45, 3.4, 0.45),
        CFrame.new(pos + Vector3.new(0, 1.85, 0)),
        C.metal,
        Enum.Material.Metal
    )

    local sign = visualPart(
        model,
        "Sign",
        Vector3.new(4.6, 1.25, 0.35),
        CFrame.new(pos + Vector3.new(0, 3.2, 0)),
        C.dark,
        Enum.Material.Metal
    )
    makeBillboard(sign, ACTIVITIES[activityId].Title, color)

    local prompt = makePrompt(post, "StartPrompt", "START", ACTIVITIES[activityId].Title)
    prompt:SetAttribute("ASC_V140_ActivityId", activityId)
    return prompt
end

local function makeStepStation(parent, activityId, stepIndex, pos, color)
    local model = Instance.new("Model")
    model.Name = string.format("%s_Step_%d", activityId, stepIndex)
    model.Parent = parent

    local pad = visualPart(
        model,
        "TaskPad",
        Vector3.new(3.2, 0.22, 3.2),
        CFrame.new(pos + Vector3.new(0, 0.12, 0)),
        color,
        Enum.Material.SmoothPlastic
    )
    pad.Transparency = 0.18

    local promptRoot = visualPart(
        model,
        "PromptRoot",
        Vector3.new(0.8, 1.2, 0.8),
        CFrame.new(pos + Vector3.new(0, 0.9, 0)),
        C.dark,
        Enum.Material.SmoothPlastic
    )
    promptRoot.Transparency = 0.45

    local prompt = makePrompt(
        promptRoot,
        "StepPrompt",
        ACTIVITIES[activityId].Steps[stepIndex],
        ACTIVITIES[activityId].Title
    )
    prompt:SetAttribute("ASC_V140_ActivityId", activityId)
    prompt:SetAttribute("ASC_V140_Step", stepIndex)
    return prompt
end

local function sessionText(activityId, step)
    local cfg = ACTIVITIES[activityId]
    local taskName = cfg.Steps[step]
    return string.format("%s — Step %d/%d: %s", cfg.Title, step, #cfg.Steps, taskName)
end

local function startActivity(player, activityId)
    local cfg = ACTIVITIES[activityId]
    if not cfg then
        return
    end

    if player:GetAttribute("ASC_ProfileReady") ~= true then
        GameplayService.ShowDialogue(player, cfg.Speaker, "Your profile is still loading.")
        return
    end

    if active[player] then
        local current = ACTIVITIES[active[player].ActivityId]
        GameplayService.ShowDialogue(player, current and current.Speaker or "CITY", "Finish your current city activity first.")
        return
    end

    local allowed, remaining = GameplayService.CanUseCooldown(
        player,
        "V140_" .. activityId,
        cfg.CooldownSeconds
    )
    if not allowed then
        GameplayService.ShowDialogue(
            player,
            cfg.Speaker,
            string.format("%s is ready again in %ds.", cfg.Title, math.ceil(remaining))
        )
        return
    end

    active[player] = {
        ActivityId = activityId,
        Step = 1,
        StartedAt = os.clock(),
    }

    player:SetAttribute("ASC_V140_ActiveActivity", activityId)
    player:SetAttribute("ASC_V140_ActivityStep", 1)
    GameplayService.ShowDialogue(player, cfg.Speaker, cfg.StartText .. " " .. sessionText(activityId, 1))
end

local function handleStep(player, activityId, stepIndex)
    local session = active[player]
    local cfg = ACTIVITIES[activityId]
    if not cfg then
        return
    end

    if not session then
        GameplayService.ShowDialogue(player, cfg.Speaker, "Start this activity at its START marker first.")
        return
    end

    if session.ActivityId ~= activityId then
        GameplayService.ShowDialogue(player, cfg.Speaker, "Finish your current city activity first.")
        return
    end

    if stepIndex ~= session.Step then
        GameplayService.ShowDialogue(player, cfg.Speaker, sessionText(activityId, session.Step))
        return
    end

    session.Step += 1

    if session.Step > #cfg.Steps then
        active[player] = nil
        player:SetAttribute("ASC_V140_ActiveActivity", nil)
        player:SetAttribute("ASC_V140_ActivityStep", nil)
        GameplayService.Award(player, cfg.RewardCoins, cfg.RewardRep, cfg.Title .. " complete")
        GameplayService.ShowDialogue(player, cfg.Speaker, cfg.CompleteText)
        return
    end

    player:SetAttribute("ASC_V140_ActivityStep", session.Step)
    GameplayService.ShowDialogue(player, cfg.Speaker, sessionText(activityId, session.Step))
end

-- ---------------------------------------------------------------------------
-- CAFE RUSH — activates the decorative Downtown CAFE frontage.
-- ---------------------------------------------------------------------------
local cafeGroup = Instance.new("Model")
cafeGroup.Name = "CafeRush"
cafeGroup.Parent = layer

local cafeShop = downtown:FindFirstChild("Shop_CAFE")
local cafeStartPos = shopFront(cafeShop, 0) or Vector3.new(-45, 1.5, -31)
local cafeStart = makeStartStation(cafeGroup, "CAFE_RUSH", cafeStartPos, C.gold)
local cafeOffsets = {
    Vector3.new(-7, 0, 0),
    Vector3.new(0, 0, -5),
    Vector3.new(7, 0, 0),
}
local cafeSteps = {}
for i, offset in ipairs(cafeOffsets) do
    cafeSteps[i] = makeStepStation(cafeGroup, "CAFE_RUSH", i, groundAt(cafeStartPos + offset), C.gold)
end

-- ---------------------------------------------------------------------------
-- ARCADE CIRCUIT — activates the decorative Downtown ARCADE frontage.
-- ---------------------------------------------------------------------------
local arcadeGroup = Instance.new("Model")
arcadeGroup.Name = "ArcadeCircuit"
arcadeGroup.Parent = layer

local arcadeShop = downtown:FindFirstChild("Shop_ARCADE")
local arcadeStartPos = shopFront(arcadeShop, 0) or Vector3.new(-90, 1.5, -31)
local arcadeStart = makeStartStation(arcadeGroup, "ARCADE_CIRCUIT", arcadeStartPos, C.purple)
local arcadeOffsets = {
    Vector3.new(-7, 0, 0),
    Vector3.new(0, 0, -5),
    Vector3.new(7, 0, 0),
}
local arcadeSteps = {}
for i, offset in ipairs(arcadeOffsets) do
    arcadeSteps[i] = makeStepStation(arcadeGroup, "ARCADE_CIRCUIT", i, groundAt(arcadeStartPos + offset), C.purple)
end

-- ---------------------------------------------------------------------------
-- PARK CLEANUP — activates existing V03 park paths without changing the park map.
-- ---------------------------------------------------------------------------
local parkGroup = Instance.new("Model")
parkGroup.Name = "ParkCleanup"
parkGroup.Parent = layer

local parkLife = park and park:FindFirstChild("V03_ParkLife")
local pathNorth = parkLife and parkLife:FindFirstChild("PathNorth")
local pathSouth = parkLife and parkLife:FindFirstChild("PathSouth")
local pathEast = parkLife and parkLife:FindFirstChild("PathEast")
local pathWest = parkLife and parkLife:FindFirstChild("PathWest")

local function partTop(part, fallback)
    if part and part:IsA("BasePart") then
        return part.Position + Vector3.new(0, part.Size.Y * 0.5 + 0.08, 0)
    end
    return fallback
end

local parkStartPos = partTop(pathWest, Vector3.new(-55, 1.5, -210))
local parkStart = makeStartStation(parkGroup, "PARK_CLEANUP", parkStartPos, C.green)
local parkPositions = {
    partTop(pathNorth, Vector3.new(15, 1.5, -248)),
    partTop(pathEast, Vector3.new(80, 1.5, -210)),
    partTop(pathSouth, Vector3.new(15, 1.5, -172)),
}
local parkSteps = {}
for i, pos in ipairs(parkPositions) do
    parkSteps[i] = makeStepStation(parkGroup, "PARK_CLEANUP", i, pos, C.green)
end

cafeStart.Triggered:Connect(function(player)
    startActivity(player, "CAFE_RUSH")
end)
arcadeStart.Triggered:Connect(function(player)
    startActivity(player, "ARCADE_CIRCUIT")
end)
parkStart.Triggered:Connect(function(player)
    startActivity(player, "PARK_CLEANUP")
end)

for i, prompt in ipairs(cafeSteps) do
    local stepIndex = i
    prompt.Triggered:Connect(function(player)
        handleStep(player, "CAFE_RUSH", stepIndex)
    end)
end
for i, prompt in ipairs(arcadeSteps) do
    local stepIndex = i
    prompt.Triggered:Connect(function(player)
        handleStep(player, "ARCADE_CIRCUIT", stepIndex)
    end)
end
for i, prompt in ipairs(parkSteps) do
    local stepIndex = i
    prompt.Triggered:Connect(function(player)
        handleStep(player, "PARK_CLEANUP", stepIndex)
    end)
end

Players.PlayerRemoving:Connect(function(player)
    active[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
    player:SetAttribute("ASC_CityLifeExpansionVersion", VERSION)
end
Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("ASC_CityLifeExpansionVersion", VERSION)
end)

layer:SetAttribute("ASC_V140_CafeRush", true)
layer:SetAttribute("ASC_V140_ArcadeCircuit", true)
layer:SetAttribute("ASC_V140_ParkCleanup", true)
layer:SetAttribute("ASC_V140_ActivityCount", 3)
root:SetAttribute("ASC_CityLifeExpansionV140", VERSION)
Workspace:SetAttribute("ASC_CityLifeExpansionV140", VERSION)

print("[AFTER SCHOOL CITY] V1.4 City Life Expansion Batch 1 ready — Cafe Rush + Arcade Circuit + Park Cleanup")
