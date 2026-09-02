-- AFTER SCHOOL CITY — V1.2 School Life Foundation
-- Server-authoritative campus NPC interactions, persistent quest progression,
-- and two light repeatable school activities using the existing reward/cooldown authority.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local ASCConfig = require(ReplicatedStorage:WaitForChild("ASCConfig"))
local SchoolLifeConfig = require(ReplicatedStorage:WaitForChild("ASCSchoolLifeConfig"))
local GameplayService = require(ServerScriptService:WaitForChild("ASC_GameplayService"))

if not (ASCConfig.Flags and ASCConfig.Flags.EnableClubs) then
    warn("[ASC V1.2] School Life disabled by ASCConfig")
    return
end

local function waitForAttribute(instance, name, timeoutSeconds)
    local deadline = os.clock() + (timeoutSeconds or 45)
    repeat
        if instance:GetAttribute(name) ~= nil then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline
    return false
end

local root = Workspace:WaitForChild("AfterSchoolCity", 30)
if not root then
    warn("[ASC V1.2] AfterSchoolCity root missing")
    return
end

local districts = root:WaitForChild("Districts", 20)
local school = districts and districts:WaitForChild("SchoolDistrict", 20)
if not school then
    warn("[ASC V1.2] SchoolDistrict missing")
    return
end

if not waitForAttribute(Workspace, "ASC_SchoolInteriorPass", 45) then
    warn("[ASC V1.2] School interior readiness timeout")
    return
end

if school:FindFirstChild("V120_SchoolLifeGameplay") then
    return
end

local interior = school:WaitForChild("V070_SchoolInterior", 20)
if not interior then
    warn("[ASC V1.2] V070_SchoolInterior missing")
    return
end

local mainInterior = interior:FindFirstChild("MainBuildingInterior")
local classroomA = mainInterior and mainInterior:FindFirstChild("CLASSROOM_A")
local teacherDesk = classroomA and classroomA:FindFirstChild("TeacherDesk")
local leftInterior = interior:FindFirstChild("LeftWingInterior")
local canteenCounter = leftInterior and leftInterior:FindFirstChild("CanteenCounter")
local rightInterior = interior:FindFirstChild("RightWingInterior")
local clubTable = rightInterior and rightInterior:FindFirstChild("ClubTable")

if not (teacherDesk and canteenCounter and clubTable) then
    warn("[ASC V1.2] Required school gameplay anchors missing")
    return
end

local layer = Instance.new("Model")
layer.Name = "V120_SchoolLifeGameplay"
layer:SetAttribute("ASC_Layer", "SCHOOL_LIFE_GAMEPLAY")
layer:SetAttribute("ASC_Version", SchoolLifeConfig.Version)
layer.Parent = school

local C = {
    navy = Color3.fromRGB(35, 49, 72),
    blue = Color3.fromRGB(67, 120, 182),
    gold = Color3.fromRGB(225, 170, 73),
    teal = Color3.fromRGB(64, 145, 133),
    purple = Color3.fromRGB(130, 94, 158),
    skin = Color3.fromRGB(222, 178, 143),
    dark = Color3.fromRGB(38, 42, 49),
    white = Color3.fromRGB(235, 239, 244),
}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {layer}
rayParams.IgnoreWater = false

local function groundPointNear(anchor, xOffset, zOffset)
    local probe = anchor.CFrame * CFrame.new(xOffset or 0, 12, zOffset or -5)
    local result = Workspace:Raycast(probe.Position, Vector3.new(0, -35, 0), rayParams)
    if result then
        return result.Position + Vector3.new(0, 0.05, 0)
    end
    local fallback = anchor.CFrame * CFrame.new(xOffset or 0, 0, zOffset or -5)
    return Vector3.new(fallback.Position.X, math.max(ASCConfig.World.GroundY + 0.05, fallback.Position.Y - 3), fallback.Position.Z)
end

local function visualPart(parent, name, size, cf, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.Material = Enum.Material.SmoothPlastic
    p.Color = color
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function createNpc(key, anchor, xOffset, zOffset, shirtColor)
    local info = SchoolLifeConfig.NPCs[key]
    local base = groundPointNear(anchor, xOffset, zOffset)
    local rotation = anchor.CFrame - anchor.Position

    local model = Instance.new("Model")
    model.Name = "NPC_" .. key
    model:SetAttribute("ASCSchoolNPC", key)
    model:SetAttribute("ASCDisplayName", info.DisplayName)
    model.Parent = layer

    local rootPart = visualPart(model, "InteractionRoot", Vector3.new(1, 1, 1), CFrame.new(base + Vector3.new(0, 3, 0)) * rotation, C.white)
    rootPart.Transparency = 1

    visualPart(model, "Torso", Vector3.new(2.4, 3, 1.2), CFrame.new(base + Vector3.new(0, 3.15, 0)) * rotation, shirtColor)
    visualPart(model, "Head", Vector3.new(2, 2, 2), CFrame.new(base + Vector3.new(0, 5.65, 0)) * rotation, C.skin)
    visualPart(model, "Hair", Vector3.new(2.08, 0.55, 2.08), CFrame.new(base + Vector3.new(0, 6.45, 0)) * rotation, C.dark)
    visualPart(model, "LegL", Vector3.new(0.9, 2.5, 1), CFrame.new(base + Vector3.new(-0.62, 1.25, 0)) * rotation, C.dark)
    visualPart(model, "LegR", Vector3.new(0.9, 2.5, 1), CFrame.new(base + Vector3.new(0.62, 1.25, 0)) * rotation, C.dark)

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "SchoolInteract"
    prompt.ActionText = "INTERACT"
    prompt.ObjectText = info.DisplayName
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    prompt.HoldDuration = 0.15
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt:SetAttribute("ASCSchoolPromptId", info.PromptId)
    prompt.Parent = rootPart

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Nameplate"
    billboard.Size = UDim2.fromOffset(150, 30)
    billboard.StudsOffset = Vector3.new(0, 4.2, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0.15
    billboard.MaxDistance = 80
    billboard.Parent = rootPart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(18, 24, 36)
    label.BackgroundTransparency = 0.35
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(242, 246, 250)
    label.Text = info.DisplayName
    label.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = label

    model.PrimaryPart = rootPart
    return prompt
end

local teacherPrompt = createNpc("Teacher", teacherDesk, 0, -5.5, C.blue)
local canteenPrompt = createNpc("Canteen", canteenCounter, 0, -5.2, C.gold)
local clubPrompt = createNpc("Club", clubTable, 0, -5.2, C.purple)

local Q = SchoolLifeConfig.QuestIds

local function currentQuest(player)
    local state = GameplayService.GetState(player)
    if not state.Ready then
        return nil, false
    end
    return state.Quest and state.Quest.Id or nil, true
end

local function finishCurrentFirst(player)
    GameplayService.ShowDialogue(player, "SCHOOL", "Finish your current mission first, then come back to campus.")
end

teacherPrompt.Triggered:Connect(function(player)
    local questId, ready = currentQuest(player)
    if not ready then
        GameplayService.ShowDialogue(player, "MS. MAYA", "Your profile is still loading.")
        return
    end

    if questId == Q.Teacher then
        GameplayService.ShowDialogue(player, "MS. MAYA", "Check-in complete. Please help at the canteen next.")
        GameplayService.CompleteQuest(player, Q.Teacher)
    elseif questId == Q.Canteen or questId == Q.Club or questId == nil then
        GameplayService.ShowDialogue(player, "MS. MAYA", "Good to see you. Your current school task is on the Mission panel.")
    else
        finishCurrentFirst(player)
    end
end)

canteenPrompt.Triggered:Connect(function(player)
    local questId, ready = currentQuest(player)
    if not ready then
        GameplayService.ShowDialogue(player, "MR. BUDI", "Your profile is still loading.")
        return
    end

    if questId == Q.Canteen then
        GameplayService.ShowDialogue(player, "MR. BUDI", "Thanks for helping. The Club Room is your next stop.")
        GameplayService.CompleteQuest(player, Q.Canteen)
        return
    end

    if questId == Q.Club or questId == nil then
        local cfg = SchoolLifeConfig.Repeatables.CANTEEN_SHIFT
        local allowed, remaining = GameplayService.CanUseCooldown(player, "V120_CANTEEN_SHIFT", cfg.CooldownSeconds)
        if not allowed then
            GameplayService.ShowDialogue(player, "MR. BUDI", string.format("Next canteen shift is ready in %ds.", math.ceil(remaining)))
            return
        end
        GameplayService.Award(player, cfg.RewardCoins, cfg.RewardRep, "Canteen Shift")
        GameplayService.ShowDialogue(player, "MR. BUDI", "Shift complete. Thanks for helping the school.")
        return
    end

    finishCurrentFirst(player)
end)

clubPrompt.Triggered:Connect(function(player)
    local questId, ready = currentQuest(player)
    if not ready then
        GameplayService.ShowDialogue(player, "NAYA", "Your profile is still loading.")
        return
    end

    if questId == Q.Club then
        GameplayService.ShowDialogue(player, "NAYA", "Welcome to Club Time. You can come back here to practice again.")
        GameplayService.CompleteQuest(player, Q.Club)
        return
    end

    if questId == nil then
        local cfg = SchoolLifeConfig.Repeatables.CLUB_PRACTICE
        local allowed, remaining = GameplayService.CanUseCooldown(player, "V120_CLUB_PRACTICE", cfg.CooldownSeconds)
        if not allowed then
            GameplayService.ShowDialogue(player, "NAYA", string.format("Practice is ready again in %ds.", math.ceil(remaining)))
            return
        end
        GameplayService.Award(player, cfg.RewardCoins, cfg.RewardRep, "Club Practice")
        GameplayService.ShowDialogue(player, "NAYA", "Practice complete. Nice work.")
        return
    end

    finishCurrentFirst(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    player:SetAttribute("ASC_SchoolLifeVersion", SchoolLifeConfig.Version)
end
Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("ASC_SchoolLifeVersion", SchoolLifeConfig.Version)
end)

school:SetAttribute("ASC_SchoolLifeGameplayReady", true)
school:SetAttribute("ASC_SchoolLifeGameplayVersion", SchoolLifeConfig.Version)
Workspace:SetAttribute("ASC_SchoolLifeGameplayReady", true)
Workspace:SetAttribute("ASC_SchoolLifeGameplayVersion", SchoolLifeConfig.Version)

print("[AFTER SCHOOL CITY] V1.2 School Life Foundation ready " .. SchoolLifeConfig.Version)
