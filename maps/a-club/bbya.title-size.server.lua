-- BBYA overhead title size hotfix
local Players = game:GetService("Players")

local function shrink(character)
	local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 10)
	if not head then return end

	local function apply(tag)
		if not tag or not tag:IsA("BillboardGui") then return end
		tag.Size = UDim2.fromOffset(112, 20)
		tag.StudsOffset = Vector3.new(0, 2.65, 0)
		tag.MaxDistance = 36
		local label = tag:FindFirstChildOfClass("TextLabel")
		if label then
			label.TextScaled = false
			label.TextSize = 12
			label.TextStrokeTransparency = 0.6
		end
	end

	apply(head:FindFirstChild("BBYATitleTag"))
	head.ChildAdded:Connect(function(child)
		if child.Name == "BBYATitleTag" then
			task.defer(apply, child)
		end
	end)
end

local function hook(player)
	player.CharacterAdded:Connect(shrink)
	if player.Character then task.defer(shrink, player.Character) end
end

Players.PlayerAdded:Connect(hook)
for _, player in ipairs(Players:GetPlayers()) do hook(player) end

print("[BBYA] overhead title size reduced")
