-- BBYA Social Hub runtime v0.2
-- ACC technical master layer / BBYA Queen gameplay layer

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local BBYA_QUEEN_USER_ID = 4271188557

local function findPlayer(query)
	if not query or query == "" then return nil end
	query = string.lower(query)
	for _, player in ipairs(Players:GetPlayers()) do
		if string.sub(string.lower(player.Name), 1, #query) == query
			or string.sub(string.lower(player.DisplayName), 1, #query) == query then
			return player
		end
	end
	return nil
end

local function markQueen(player)
	local isQueen = player.UserId == BBYA_QUEEN_USER_ID
	player:SetAttribute("BBYARole", isQueen and "BBYA_QUEEN" or "PLAYER")
	player:SetAttribute("BBYAQueen", isQueen)

	-- Queen always bypasses paid/VIP access checks inside BBYA.
	if isQueen then
		player:SetAttribute("IsVIP", true)
		player:SetAttribute("BBYAAllAccess", true)
	end
end

local function addQueenTag(character)
	local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 10)
	if not head or head:FindFirstChild("BBYAQueenTag") then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = "BBYAQueenTag"
	gui.Size = UDim2.fromOffset(220, 58)
	gui.StudsOffset = Vector3.new(0, 3.4, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 120
	gui.Parent = head

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.fromScale(1, 0.58)
	title.Font = Enum.Font.GothamBold
	title.Text = "👑 RATU BBYA 👑"
	title.TextColor3 = Color3.fromRGB(255, 220, 90)
	title.TextStrokeTransparency = 0.25
	title.TextScaled = true
	title.Parent = gui

	local sub = Instance.new("TextLabel")
	sub.Name = "Subtitle"
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.fromScale(0, 0.58)
	sub.Size = UDim2.fromScale(1, 0.42)
	sub.Font = Enum.Font.GothamMedium
	sub.Text = "OWNER • ALL ACCESS"
	sub.TextColor3 = Color3.fromRGB(255, 255, 255)
	sub.TextStrokeTransparency = 0.45
	sub.TextScaled = true
	sub.Parent = gui
end

local function handleQueenCommand(player, message)
	if player.UserId ~= BBYA_QUEEN_USER_ID then return end
	if string.sub(message, 1, 1) ~= "!" then return end

	local args = string.split(message, " ")
	local command = string.lower(args[1])

	if command == "!kick" then
		local target = findPlayer(args[2])
		if target and target ~= player then
			target:Kick("Removed by BBYA Queen")
		end

	elseif command == "!bring" then
		local target = findPlayer(args[2])
		if target and target.Character and player.Character then
			target.Character:PivotTo(player.Character:GetPivot() * CFrame.new(3, 0, 0))
		end

	elseif command == "!goto" then
		local target = findPlayer(args[2])
		if target and target.Character and player.Character then
			player.Character:PivotTo(target.Character:GetPivot() * CFrame.new(3, 0, 0))
		end

	elseif command == "!speed" then
		local speed = math.clamp(tonumber(args[2]) or 32, 16, 80)
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.WalkSpeed = speed end

	elseif command == "!normal" then
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.WalkSpeed = 16 end

	elseif command == "!day" then
		Lighting.ClockTime = 14
		Lighting.Brightness = 2

	elseif command == "!night" then
		Lighting.ClockTime = 22
		Lighting.Brightness = 1.5
	end
end

Players.PlayerAdded:Connect(function(player)
	markQueen(player)

	if player.UserId == BBYA_QUEEN_USER_ID then
		player.CharacterAdded:Connect(function(character)
			task.wait(1)
			addQueenTag(character)
		end)

		player.Chatted:Connect(function(message)
			handleQueenCommand(player, message)
		end)
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	markQueen(player)
	if player.UserId == BBYA_QUEEN_USER_ID then
		if player.Character then addQueenTag(player.Character) end
		player.CharacterAdded:Connect(function(character)
			task.wait(1)
			addQueenTag(character)
		end)
		player.Chatted:Connect(function(message)
			handleQueenCommand(player, message)
		end)
	end
end

print("[BBYA] Runtime v0.2 loaded. Queen UserId:", BBYA_QUEEN_USER_ID)
