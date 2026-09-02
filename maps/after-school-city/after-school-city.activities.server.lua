-- AFTER SCHOOL CITY — V1.1 First Playable Loop
-- Server-authoritative activity layer: Skate Line, Pool Laps, City Delivery.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local GameplayService = require(ServerScriptService:WaitForChild("ASC_GameplayService"))
local ActivityConfig = require(ReplicatedStorage:WaitForChild("ASCActivityConfig"))

local VERSION = ActivityConfig.Version
local active = {}
local root = Workspace:WaitForChild("AfterSchoolCity", 30)
if not root then return end

local remotes = ReplicatedStorage:WaitForChild("ASC_Remotes")
local activityState = remotes:FindFirstChild("ActivityState") or Instance.new("RemoteEvent")
activityState.Name = "ActivityState"
activityState.Parent = remotes

local layer = root:FindFirstChild("V110_FirstPlayableLoop") or Instance.new("Model")
layer.Name = "V110_FirstPlayableLoop"
layer:SetAttribute("ASC_Version", VERSION)
layer.Parent = root

local function marker(name, position, label, activityId)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = true
    p.Transparency = 0.35
    p.Material = Enum.Material.Neon
    p.Color = Color3.fromRGB(91, 151, 214)
    p.Size = Vector3.new(5, 0.35, 5)
    p.CFrame = CFrame.new(position)
    p.Parent = layer

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ActivityPrompt"
    prompt.ActionText = "START"
    prompt.ObjectText = label
    prompt.HoldDuration = 0.25
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt:SetAttribute("ASCActivityId", activityId)
    prompt.Parent = p
    return p, prompt
end

local function findDescendant(name)
    for _, d in ipairs(root:GetDescendants()) do
        if d.Name == name then return d end
    end
end

local function skatePoints()
    local bankA = findDescendant("BankA")
    local manual = findDescendant("ManualPad")
    local bankB = findDescendant("BankB")
    return {
        bankA and bankA.Position or Vector3.new(207, 3.2, 25),
        manual and manual.Position or Vector3.new(235, 2.2, 30),
        bankB and bankB.Position or Vector3.new(263, 3.2, -25),
    }
end

local function poolPoints()
    local floor = findDescendant("PoolFloor")
    local center = floor and floor.Position or Vector3.new(15, 1.5, -210)
    local sx = floor and floor.Size.X * 0.28 or 34
    local sz = floor and floor.Size.Z * 0.28 or 20
    return {
        center + Vector3.new(-sx, 3.2, 0),
        center + Vector3.new(0, 3.2, -sz),
        center + Vector3.new(sx, 3.2, 0),
        center + Vector3.new(0, 3.2, sz),
    }
end

local function deliveryTarget()
    local residential = root:FindFirstChild("Districts") and root.Districts:FindFirstChild("Residential")
    if residential then
        for _, d in ipairs(residential:GetDescendants()) do
            if d.Name == "Mailbox" and d:IsA("BasePart") then
                return d.Position
            end
        end
    end
    return Vector3.new(-198, 6.5, 11)
end

local skateStart, skatePrompt = marker("SkateActivityStart", Vector3.new(235, 2.0, 58), "SKATE LINE", "SKATE_LINE")
local poolFloor = findDescendant("PoolFloor")
local poolStartPos = poolFloor and (poolFloor.Position + Vector3.new(poolFloor.Size.X * 0.5 + 6, 5, 0)) or Vector3.new(82, 4, -210)
local poolStart, poolPrompt = marker("PoolActivityStart", poolStartPos, "POOL LAPS", "POOL_LAPS")
local deliveryStart, deliveryPrompt = marker("DeliveryActivityStart", Vector3.new(72, 2.0, 28), "CITY DELIVERY", "CITY_DELIVERY")

local function payload(player, state, extra)
    extra = extra or {}
    extra.State = state
    activityState:FireClient(player, extra)
end

local function finish(player, activityId)
    local session = active[player]
    if not session or session.Id ~= activityId then return end
    local cfg = ActivityConfig.Activities[activityId]
    active[player] = nil
    GameplayService.Award(player, cfg.RewardCoins, cfg.RewardRep, cfg.Title .. " complete")
    payload(player, "COMPLETE", {
        ActivityId = activityId,
        RewardCoins = cfg.RewardCoins,
        RewardRep = cfg.RewardRep,
    })
end

local function startActivity(player, activityId, checkpoints)
    if player:GetAttribute("ASC_ProfileReady") ~= true then
        payload(player, "BLOCKED", {ActivityId = activityId, Reason = "PROFILE_NOT_READY"})
        return
    end
    if active[player] then
        payload(player, "BLOCKED", {ActivityId = activityId, Reason = "BUSY"})
        return
    end
    local cfg = ActivityConfig.Activities[activityId]
    local canUse, remaining = GameplayService.CanUseCooldown(player, "ACTIVITY_" .. activityId, cfg.CooldownSeconds)
    if not canUse then
        payload(player, "BLOCKED", {ActivityId = activityId, Reason = "COOLDOWN", Remaining = math.ceil(remaining)})
        return
    end
    active[player] = {
        Id = activityId,
        Checkpoints = checkpoints,
        Step = 1,
        Deadline = os.clock() + cfg.TimeLimitSeconds,
    }
    payload(player, "STARTED", {
        ActivityId = activityId,
        Step = 1,
        Total = #checkpoints,
        Remaining = cfg.TimeLimitSeconds,
    })
end

skatePrompt.Triggered:Connect(function(player)
    startActivity(player, "SKATE_LINE", skatePoints())
end)

poolPrompt.Triggered:Connect(function(player)
    startActivity(player, "POOL_LAPS", poolPoints())
end)

deliveryPrompt.Triggered:Connect(function(player)
    startActivity(player, "CITY_DELIVERY", {deliveryTarget()})
end)

local function playerRoot(player)
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart"), character and character:FindFirstChildOfClass("Humanoid")
end

local function loop()
    while true do
        local now = os.clock()
        for player, session in pairs(active) do
            if player.Parent ~= Players then
                active[player] = nil
            else
                local cfg = ActivityConfig.Activities[session.Id]
                if now >= session.Deadline then
                    active[player] = nil
                    payload(player, "FAILED", {ActivityId = session.Id, Reason = "TIME"})
                else
                    local rootPart, humanoid = playerRoot(player)
                    local target = session.Checkpoints[session.Step]
                    if rootPart and target then
                        local near = (rootPart.Position - target).Magnitude <= cfg.Radius
                        local swimOk = true
                        if cfg.RequireSwimming then
                            swimOk = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Swimming
                        end
                        if near and swimOk then
                            session.Step += 1
                            if session.Step > #session.Checkpoints then
                                finish(player, session.Id)
                            else
                                payload(player, "PROGRESS", {
                                    ActivityId = session.Id,
                                    Step = session.Step,
                                    Total = #session.Checkpoints,
                                    Remaining = math.max(0, math.ceil(session.Deadline - now)),
                                })
                            end
                        elseif math.floor(now * 2) % 4 == 0 then
                            payload(player, "TICK", {
                                ActivityId = session.Id,
                                Step = session.Step,
                                Total = #session.Checkpoints,
                                Remaining = math.max(0, math.ceil(session.Deadline - now)),
                            })
                        end
                    end
                end
            end
        end
        task.wait(0.25)
    end
end

Players.PlayerRemoving:Connect(function(player)
    active[player] = nil
end)

Workspace:SetAttribute("ASC_FirstPlayableLoopVersion", VERSION)
Workspace:SetAttribute("ASC_FirstPlayableLoopReady", true)
task.spawn(loop)
print("[AFTER SCHOOL CITY] V1.1 First Playable Loop ready", VERSION)
