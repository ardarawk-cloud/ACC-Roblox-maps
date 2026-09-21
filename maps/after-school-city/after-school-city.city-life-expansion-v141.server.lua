-- AFTER SCHOOL CITY — V1.4 City Life Expansion / Batch 2
-- Activates remaining Downtown shopfronts plus Residential with repeatable city activities.
-- Reuses existing GameplayService reward/cooldown authority.
-- No DataStore schema, economy/BAG catalog, music player, quest chain, sports, dedication,
-- monetization, or prior V1.4 Batch 1 authority changes.

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local GameplayService = require(ServerScriptService:WaitForChild("ASC_GameplayService"))

local VERSION = "1.4.1-city-life-expansion-batch2"

local root = Workspace:WaitForChild("AfterSchoolCity", 30)
if not root then
    warn("[ASC V141] AfterSchoolCity root missing")
    return
end

if root:GetAttribute("ASC_CityLifeExpansionV141") == VERSION then
    return
end

local districts = root:WaitForChild("Districts", 20)
local downtown = districts and districts:FindFirstChild("Downtown")
local residential = districts and districts:FindFirstChild("Residential")

if not downtown or not residential then
    warn("[ASC V141] Required Downtown/Residential district missing")
    return
end

local previous = root:FindFirstChild("V141_CityLifeExpansionBatch2")
if previous then
    previous:Destroy()
end

local layer = Instance.new("Model")
layer.Name = "V141_CityLifeExpansionBatch2"
layer:SetAttribute("ASC_Layer", "CITY_LIFE_EXPANSION_BATCH2")
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local active = {}

local C = {
    white = Color3.fromRGB(242, 246, 250),
    dark = Color3.fromRGB(31, 35, 43),
    metal = Color3.fromRGB(78, 84, 94),
    blue = Color3.fromRGB(67, 120, 182),
    gold = Color3.fromRGB(225, 170, 73),
    teal = Color3.fromRGB(64, 145, 133),
    purple = Color3.fromRGB(130, 94, 158),
    pink = Color3.fromRGB(190, 103, 137),
    green = Color3.fromRGB(83, 142, 91),
}

local ACTIVITIES = {
    STYLE_CHECK = {
        Title = "Style Check",
        CooldownSeconds = 90,
        RewardCoins = 125,
        RewardRep = 35,
        Speaker = "STYLE CREW",
        StartText = "Build a quick after-school look: pick, check, then shoot.",
        CompleteText = "Style check complete.",
        Steps = {"PICK LOOK", "MIRROR CHECK", "PHOTO SPOT"},
    },
    MUSIC_SESSION = {
        Title = "Music Session",
        CooldownSeconds = 100,
        RewardCoins = 145,
        RewardRep = 45,
        Speaker = "MUSIC CREW",
        StartText = "Run a short music session: choose, mix, then perform.",
        CompleteText = "Session complete. Clean run.",
        Steps = {"CHOOSE TRACK", "MIX DESK", "PERFORM"},
    },
    HOBBY_BUILD = {
        Title = "Hobby Build",
        CooldownSeconds = 100,
        RewardCoins = 135,
        RewardRep = 40,
        Speaker = "HOBBY CREW",
        StartText = "Pick a kit, build it, then show the finished piece.",
        CompleteText = "Build complete. Nice work.",
        Steps = {"PICK KIT", "BUILD", "DISPLAY"},
    },
    NEIGHBORHOOD_RUN = {
        Title = "Neighborhood Run",
        CooldownSeconds = 115,
        RewardCoins = 170,
        RewardRep = 50,
        Speaker = "NEIGHBORHOOD",
        StartText = "Make the residential delivery loop and visit all three stops.",
        CompleteText = "Neighborhood route complete.",
        Steps = {"DELIVERY 1", "DELIVERY 2", "DELIVERY 3"},
    },
}

local function visualPart(parent, name, size, cf, color, material, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.white
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function makeBillboard(parent, text, accent)
    local gui = Instance.new("BillboardGui")
    gui.Name = "ActivityLabel"
    gui.Size = UDim2.fromOffset(150, 30)
    gui.StudsOffset = Vector3.new(0, 3.5, 0)
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
    label.TextColor3 = accent or C.white
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

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {layer}
rayParams.IgnoreWater = false

local function groundAt(position)
    local result = Workspace:Raycast(
        position + Vector3.new(0, 24, 0),
        Vector3.new(0, -60, 0),
        rayParams
    )
    if result then
        return result.Position + Vector3.new(0, 0.04, 0)
    end
    return Vector3.new(position.X, 1.5, position.Z)
end

local function shopFront(shop, lateral)
    if shop then
        local cf, size = shop:GetBoundingBox()
        local raw = cf.Position
            + cf.RightVector * (lateral or 0)
            + cf.LookVector * (-(size.Z * 0.5 + 5))
        return groundAt(raw)
    end
    return nil
end

local function makeStartStation(parent, activityId, pos, color)
    local cfg = ACTIVITIES[activityId]
    local model = Instance.new("Model")
    model.Name = activityId .. "_Start"
    model.Parent = parent

    local pad = visualPart(
        model,
        "StartPad",
        Vector3.new(4.6, 0.28, 4.6),
        CFrame.new(pos + Vector3.new(0, 0.15, 0)),
        color,
        Enum.Material.SmoothPlastic,
        0.1
    )

    local post = visualPart(
        model,
        "PromptPost",
        Vector3.new(0.45, 3.2, 0.45),
        CFrame.new(pos + Vector3.new(0, 1.7, 0)),
        C.metal,
        Enum.Material.Metal
    )

    local sign = visualPart(
        model,
        "Sign",
        Vector3.new(4.5, 1.15, 0.35),
        CFrame.new(pos + Vector3.new(0, 3.0, 0)),
        C.dark,
        Enum.Material.Metal
    )
    makeBillboard(sign, cfg.Title, color)

    local prompt = makePrompt(post, "StartPrompt", "START", cfg.Title)
    prompt:SetAttribute("ASC_V141_ActivityId", activityId)
    return prompt
end

local function makeStepStation(parent, activityId, stepIndex, pos, color)
    local cfg = ACTIVITIES[activityId]
    local model = Instance.new("Model")
    model.Name = string.format("%s_Step_%d", activityId, stepIndex)
    model.Parent = parent

    visualPart(
        model,
        "TaskPad",
        Vector3.new(3.1, 0.2, 3.1),
        CFrame.new(pos + Vector3.new(0, 0.11, 0)),
        color,
        Enum.Material.SmoothPlastic,
        0.18
    )

    local promptRoot = visualPart(
        model,
        "PromptRoot",
        Vector3.new(0.75, 1.15, 0.75),
        CFrame.new(pos + Vector3.new(0, 0.82, 0)),
        C.dark,
        Enum.Material.SmoothPlastic,
        0.48
    )

    local prompt = makePrompt(
        promptRoot,
        "StepPrompt",
        cfg.Steps[stepIndex],
        cfg.Title
    )
    prompt:SetAttribute("ASC_V141_ActivityId", activityId)
    prompt:SetAttribute("ASC_V141_Step", stepIndex)
    return prompt
end

local function sessionText(activityId, step)
    local cfg = ACTIVITIES[activityId]
    return string.format(
        "%s — Step %d/%d: %s",
        cfg.Title,
        step,
        #cfg.Steps,
        cfg.Steps[step]
    )
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

    if player:GetAttribute("ASC_V140_ActiveActivity") ~= nil then
        GameplayService.ShowDialogue(player, cfg.Speaker, "Finish your current city activity first.")
        return
    end

    if active[player] then
        local current = ACTIVITIES[active[player].ActivityId]
        GameplayService.ShowDialogue(
            player,
            current and current.Speaker or "CITY",
            "Finish your current city activity first."
        )
        return
    end

    local allowed, remaining = GameplayService.CanUseCooldown(
        player,
        "V141_" .. activityId,
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

    player:SetAttribute("ASC_V141_ActiveActivity", activityId)
    player:SetAttribute("ASC_V141_ActivityStep", 1)
    GameplayService.ShowDialogue(
        player,
        cfg.Speaker,
        cfg.StartText .. " " .. sessionText(activityId, 1)
    )
end

local function handleStep(player, activityId, stepIndex)
    local cfg = ACTIVITIES[activityId]
    local session = active[player]
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
        player:SetAttribute("ASC_V141_ActiveActivity", nil)
        player:SetAttribute("ASC_V141_ActivityStep", nil)
        GameplayService.Award(
            player,
            cfg.RewardCoins,
            cfg.RewardRep,
            cfg.Title .. " complete"
        )
        GameplayService.ShowDialogue(player, cfg.Speaker, cfg.CompleteText)
        return
    end

    player:SetAttribute("ASC_V141_ActivityStep", session.Step)
    GameplayService.ShowDialogue(player, cfg.Speaker, sessionText(activityId, session.Step))
end

local function connectActivity(activityId, parent, startPos, stepPositions, color)
    local startPrompt = makeStartStation(parent, activityId, startPos, color)
    startPrompt.Triggered:Connect(function(player)
        startActivity(player, activityId)
    end)

    for i, position in ipairs(stepPositions) do
        local stepIndex = i
        local prompt = makeStepStation(parent, activityId, stepIndex, position, color)
        prompt.Triggered:Connect(function(player)
            handleStep(player, activityId, stepIndex)
        end)
    end
end

-- STYLE SHOP
local styleGroup = Instance.new("Model")
styleGroup.Name = "StyleCheck"
styleGroup.Parent = layer
local styleStart = shopFront(downtown:FindFirstChild("Shop_STYLE"), 0) or groundAt(Vector3.new(0, 1.5, -28))
connectActivity(
    "STYLE_CHECK",
    styleGroup,
    styleStart,
    {
        groundAt(styleStart + Vector3.new(-7, 0, 0)),
        groundAt(styleStart + Vector3.new(0, 0, -5)),
        groundAt(styleStart + Vector3.new(7, 0, 0)),
    },
    C.pink
)

-- MUSIC SHOP
local musicGroup = Instance.new("Model")
musicGroup.Name = "MusicSession"
musicGroup.Parent = layer
local musicStart = shopFront(downtown:FindFirstChild("Shop_MUSIC"), 0) or groundAt(Vector3.new(45, 1.5, -28))
connectActivity(
    "MUSIC_SESSION",
    musicGroup,
    musicStart,
    {
        groundAt(musicStart + Vector3.new(-7, 0, 0)),
        groundAt(musicStart + Vector3.new(0, 0, -5)),
        groundAt(musicStart + Vector3.new(7, 0, 0)),
    },
    C.blue
)

-- HOBBY SHOP
local hobbyGroup = Instance.new("Model")
hobbyGroup.Name = "HobbyBuild"
hobbyGroup.Parent = layer
local hobbyStart = shopFront(downtown:FindFirstChild("Shop_HOBBY"), 0) or groundAt(Vector3.new(90, 1.5, -28))
connectActivity(
    "HOBBY_BUILD",
    hobbyGroup,
    hobbyStart,
    {
        groundAt(hobbyStart + Vector3.new(-7, 0, 0)),
        groundAt(hobbyStart + Vector3.new(0, 0, -5)),
        groundAt(hobbyStart + Vector3.new(7, 0, 0)),
    },
    C.teal
)

-- RESIDENTIAL / NEIGHBORHOOD
local neighborhoodGroup = Instance.new("Model")
neighborhoodGroup.Name = "NeighborhoodRun"
neighborhoodGroup.Parent = layer

local residentialWalk = residential:FindFirstChild("ResidentialWalk")
local neighborhoodStart = residentialWalk
    and groundAt(residentialWalk.Position + Vector3.new(46, 0, 0))
    or groundAt(Vector3.new(-189, 1.5, 28))

local mailboxPositions = {}
local residentialLife = residential:FindFirstChild("V03_ResidentialLife")
if residentialLife then
    for _, obj in ipairs(residentialLife:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name == "Mailbox" then
            table.insert(mailboxPositions, groundAt(obj.Position + Vector3.new(0, 0, 4)))
        end
    end
end

table.sort(mailboxPositions, function(a, b)
    return a.Z < b.Z
end)

if #mailboxPositions < 3 then
    mailboxPositions = {
        groundAt(Vector3.new(-198, 1.5, -37)),
        groundAt(Vector3.new(-198, 1.5, 11)),
        groundAt(Vector3.new(-198, 1.5, 59)),
    }
end

connectActivity(
    "NEIGHBORHOOD_RUN",
    neighborhoodGroup,
    neighborhoodStart,
    {mailboxPositions[1], mailboxPositions[2], mailboxPositions[3]},
    C.green
)

Players.PlayerRemoving:Connect(function(player)
    active[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
    player:SetAttribute("ASC_CityLifeExpansionBatch2Version", VERSION)
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("ASC_CityLifeExpansionBatch2Version", VERSION)
end)

layer:SetAttribute("ASC_V141_StyleCheck", true)
layer:SetAttribute("ASC_V141_MusicSession", true)
layer:SetAttribute("ASC_V141_HobbyBuild", true)
layer:SetAttribute("ASC_V141_NeighborhoodRun", true)
layer:SetAttribute("ASC_V141_ActivityCount", 4)

root:SetAttribute("ASC_CityLifeExpansionV141", VERSION)
Workspace:SetAttribute("ASC_CityLifeExpansionV141", VERSION)

print("[AFTER SCHOOL CITY] V1.4 City Life Expansion Batch 2 ready — Style + Music + Hobby + Neighborhood")
