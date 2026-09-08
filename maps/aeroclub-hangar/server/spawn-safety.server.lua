-- AEROCLUB HANGAR — SPAWN SAFETY v1
-- MAIN HANGAR safety authority: prevent freefall while static mesh loads.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local SAFE_POSITION = Vector3.new(0, 6, -305)
local SAFE_LOOK_AT = Vector3.new(0, 6, -150)
local SAFE_CFRAME = CFrame.lookAt(SAFE_POSITION, SAFE_LOOK_AT)
local FALL_LIMIT_Y = -20

Workspace:SetAttribute("AeroClubSpawnSafety", "V1_ACTIVE")

local floor = Workspace:FindFirstChild("AeroClubEmergencySpawnFloor")
if not floor then
    floor = Instance.new("Part")
    floor.Name = "AeroClubEmergencySpawnFloor"
    floor.Anchored = true
    floor.Transparency = 1
    floor.CanCollide = true
    floor.CanTouch = false
    floor.CanQuery = true
    floor.Size = Vector3.new(180, 4, 120)
    floor.CFrame = CFrame.new(0, -2, -275)
    floor.Parent = Workspace
end

local function placeCharacter(character)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root then return end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    root.CFrame = SAFE_CFRAME

    task.spawn(function()
        while character.Parent and root.Parent do
            if root.Position.Y < FALL_LIMIT_Y then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = SAFE_CFRAME
            end
            task.wait(0.35)
        end
    end)
end

local function bindPlayer(player)
    player.CharacterAdded:Connect(placeCharacter)
    if player.Character then
        task.spawn(placeCharacter, player.Character)
    end
end

Players.PlayerAdded:Connect(bindPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    bindPlayer(player)
end

print("[AEROCLUB] spawn safety active")
