-- BBYA SOCIAL HUB — AFK ACTIVITY REPORTER v1
-- Reports legitimate local activity at low frequency. No simulated input and no anti-idle behavior.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BBYAClubRemotes", 30)
if not remotes then return end
local activityRemote = remotes:WaitForChild("AFKActivity", 30)
if not activityRemote or not activityRemote:IsA("RemoteEvent") then return end

local REPORT_INTERVAL_SECONDS = 20
local MOVEMENT_POLL_SECONDS = 1
local lastSentAt = 0

local GAMEPAD_INPUTS = {
    [Enum.UserInputType.Gamepad1] = true,
    [Enum.UserInputType.Gamepad2] = true,
    [Enum.UserInputType.Gamepad3] = true,
    [Enum.UserInputType.Gamepad4] = true,
    [Enum.UserInputType.Gamepad5] = true,
    [Enum.UserInputType.Gamepad6] = true,
    [Enum.UserInputType.Gamepad7] = true,
    [Enum.UserInputType.Gamepad8] = true,
}

local function isMeaningfulInput(input)
    if not input then return false end
    local inputType = input.UserInputType
    return inputType == Enum.UserInputType.Keyboard
        or inputType == Enum.UserInputType.Touch
        or inputType == Enum.UserInputType.MouseButton1
        or inputType == Enum.UserInputType.MouseButton2
        or inputType == Enum.UserInputType.MouseButton3
        or inputType == Enum.UserInputType.MouseMovement
        or inputType == Enum.UserInputType.MouseWheel
        or GAMEPAD_INPUTS[inputType] == true
end

local function reportActivity(force)
    local now = os.clock()
    if not force and now - lastSentAt < REPORT_INTERVAL_SECONDS then return end
    lastSentAt = now
    activityRemote:FireServer()
end

local function onMeaningfulInput(input)
    if not isMeaningfulInput(input) then return end
    -- If the replicated server state already says AFK, the first real input reports immediately.
    reportActivity(player:GetAttribute("BBYAAFK") == true)
end

UserInputService.InputBegan:Connect(function(input)
    onMeaningfulInput(input)
end)

UserInputService.InputChanged:Connect(function(input)
    onMeaningfulInput(input)
end)

local function hasLocalMovementIntent()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0.05
end

task.spawn(function()
    while task.wait(MOVEMENT_POLL_SECONDS) do
        if hasLocalMovementIntent() then
            reportActivity(player:GetAttribute("BBYAAFK") == true)
        end
    end
end)

print(string.format("[BBYA] AFK activity reporter v1 online: active reports throttled to %ds", REPORT_INTERVAL_SECONDS))
