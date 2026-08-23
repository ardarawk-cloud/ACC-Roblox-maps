-- BBYA SOCIAL HUB — FISHING GATE + SATISFACTION v6 CLIENT
-- Fishing UI stays completely off in Pasar Malam and becomes available only after the lake gate.
-- Also adds compact action-button feedback without adding new permanent panels.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("BBYAFishingUI", 35)
if not gui then return end

local remotes = ReplicatedStorage:WaitForChild("BBYAFishingRemotes", 30)
local stateRemote = remotes and remotes:WaitForChild("State", 10)

local LAKE_CENTER = Vector3.new(0, 0, 790)
local GATE_Z = 687.5
local EXIT_Z = 684.5
local ACTIVE_RADIUS = 225
local ACTIVE_RADIUS_SQ = ACTIVE_RADIUS * ACTIVE_RADIUS

local gateEntered = false
local action = gui:FindFirstChild("Action", true)
local actionScale

local function resolveAction()
    if not action or not action.Parent then
        action = gui:FindFirstChild("Action", true)
    end
    if action and not actionScale then
        actionScale = action:FindFirstChild("FishingActionScaleV394") or action:FindFirstChildOfClass("UIScale")
        if not actionScale then
            actionScale = Instance.new("UIScale")
            actionScale.Name = "FishingActionSatisfactionV6"
            actionScale.Parent = action
        end
    end
    return action
end

local function inLakeDistrict(pos)
    local dx = pos.X - LAKE_CENTER.X
    local dz = pos.Z - LAKE_CENTER.Z
    return dx * dx + dz * dz <= ACTIVE_RADIUS_SQ
end

local function shouldEnable()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        gateEntered = false
        return false
    end

    local pos = hrp.Position
    local inside = inLakeDistrict(pos)

    -- Crossing to the lake side of the physical BBYA LAKESIDE gate arms fishing mode.
    if inside and pos.Z >= GATE_Z then
        gateEntered = true
    end

    -- Returning through the gate or leaving the district disarms it completely.
    if not inside or pos.Z <= EXIT_Z then
        gateEntered = false
    end

    return gateEntered and inside and pos.Z >= GATE_Z
end

local function closeTransientFishingPanels()
    -- Base fishing UI creates its modal shade/sheet as top-level high-Z children.
    -- Hide only high-Z modal children; the detached round Action button uses Z45 and remains untouched.
    for _, child in ipairs(gui:GetChildren()) do
        if (child:IsA("Frame") or child:IsA("TextButton")) and child.ZIndex >= 50 then
            child.Visible = false
        end
    end
end

-- The original v1 UI owns a wide radius. This render-step is the final authority so that
-- no fishing UI can flash on while the player is still walking through Pasar Malam.
pcall(function() RunService:UnbindFromRenderStep("BBYAFishingGateAuthorityV6") end)
RunService:BindToRenderStep("BBYAFishingGateAuthorityV6", Enum.RenderPriority.Last.Value, function()
    local active = shouldEnable()
    if gui.Enabled ~= active then
        gui.Enabled = active
        if not active then
            closeTransientFishingPanels()
            player:SetAttribute("BBYAFishingPanelGateV6", false)
        else
            player:SetAttribute("BBYAFishingPanelGateV6", true)
        end
    end
end)

local pulseSerial = 0
local function pulse(scaleTo, duration)
    local btn = resolveAction()
    if not btn or not actionScale then return end

    pulseSerial += 1
    local serial = pulseSerial
    TweenService:Create(actionScale, TweenInfo.new(duration or .10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = scaleTo or 1.10}):Play()
    task.delay(duration or .10, function()
        if serial ~= pulseSerial or not actionScale.Parent then return end
        TweenService:Create(actionScale, TweenInfo.new(.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end)
end

if stateRemote then
    stateRemote.OnClientEvent:Connect(function(kind)
        if not gui.Enabled then return end
        if kind == "Bite" then
            pulse(1.14, .08)
        elseif kind == "Fight" then
            pulse(1.08, .08)
        elseif kind == "Catch" then
            pulse(1.18, .09)
        elseif kind == "Escaped" then
            pulse(.94, .07)
        end
    end)
end

gui:SetAttribute("GateAuthorityV6", true)
gui:SetAttribute("GateZV6", GATE_Z)
gui:SetAttribute("MarketSideUIBlockedV6", true)
gui:SetAttribute("NoNewPermanentPanelV6", true)

print("[BBYA] Fishing Gate v6 client online: UI begins after lake gate + compact action feedback")
