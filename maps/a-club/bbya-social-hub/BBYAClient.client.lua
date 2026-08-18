local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BBYA"):WaitForChild("Remotes")
local currentDance

local function travel(destination)
	remotes.TeleportRequest:FireServer(destination)
end

local function animator()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	return humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
end

local function stopDance()
	if currentDance then
		currentDance:Stop(0.15)
		currentDance:Destroy()
		currentDance = nil
	end
end

local function playDance(animationId)
	if typeof(animationId) ~= "number" or animationId <= 0 then return end
	stopDance()
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. animationId
	currentDance = animator():LoadAnimation(animation)
	currentDance.Priority = Enum.AnimationPriority.Action
	currentDance.Looped = true
	currentDance:Play(0.15)
end

remotes.SupportEffect.OnClientEvent:Connect(function(displayName, amount, total)
	print(string.format("%s supported BBYA: %d | total %d", displayName, amount, total))
end)

_G.BBYA = _G.BBYA or {}
_G.BBYA.Travel = travel
_G.BBYA.PlayDance = playDance
_G.BBYA.StopDance = stopDance
