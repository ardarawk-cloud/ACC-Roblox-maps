-- BBYA SOCIAL HUB — FISHING FEEDBACK HOTFIX v394 CLIENT
-- Screenshot feedback: main fishing action is a compact round control near lower-right,
-- left/up from Roblox jump control. BAG / ROD / SHOP remain simple and unchanged.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("BBYAFishingUI", 35)
if not gui then return end

local hud = gui:WaitForChild("HUD", 10)
if not hud then return end
local action = hud:WaitForChild("Action", 10)
if not action or not action:IsA("TextButton") then return end

-- Keep the original connected button; only move/re-style it so all existing CAST/STRIKE/REEL
-- event wiring stays untouched.
action.Parent = gui
action.AnchorPoint = Vector2.new(.5, .5)
action.ZIndex = math.max(action.ZIndex, 45)
action.TextWrapped = false

local corner = action:FindFirstChildOfClass("UICorner")
if not corner then
    corner = Instance.new("UICorner")
    corner.Parent = action
end
corner.CornerRadius = UDim.new(1, 0)

local stroke = action:FindFirstChildOfClass("UIStroke")
if stroke then
    stroke.Thickness = 1.2
    stroke.Transparency = .12
end

local scale = action:FindFirstChild("FishingActionScaleV394")
if not scale then
    scale = Instance.new("UIScale")
    scale.Name = "FishingActionScaleV394"
    scale.Parent = action
end

local camera = Workspace.CurrentCamera
local function applyLayout()
    camera = Workspace.CurrentCamera or camera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local portrait = viewport.Y > viewport.X

    if portrait then
        -- Portrait: sit above Roblox jump and comfortably inside thumb reach.
        action.Size = UDim2.fromOffset(72, 72)
        action.Position = UDim2.new(1, -92, 1, -205)
        action.TextSize = 14
        scale.Scale = 1
    elseif viewport.X < 900 then
        -- Small landscape phone.
        action.Size = UDim2.fromOffset(72, 72)
        action.Position = UDim2.new(1, -170, 1, -145)
        action.TextSize = 14
        scale.Scale = 1
    else
        -- Matches the requested red-box region: left/up from the default jump control.
        action.Size = UDim2.fromOffset(78, 78)
        action.Position = UDim2.new(1, -185, 1, -150)
        action.TextSize = 15
        scale.Scale = 1
    end
end

applyLayout()
if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout)
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera = Workspace.CurrentCamera
    applyLayout()
end)

-- Keep only the action floating on the right. The compact nav remains where v1 placed it.
hud:SetAttribute("ActionDetachedV394", true)
gui:SetAttribute("RoundFishingActionV394", true)

print("[BBYA] Fishing feedback UI v394 online: round lower-right action control")
