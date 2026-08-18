-- BBYA Social Hub runtime v0.3
-- ACC technical master layer / BBYA Queen gameplay layer

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local BBYA_QUEEN_USER_ID = 4271188557
local CLUB_COLORS = {
	Color3.fromRGB(255, 55, 170),
	Color3.fromRGB(155, 70, 255),
	Color3.fromRGB(45, 190, 255),
	Color3.fromRGB(255, 90, 220),
}

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
	title.BackgroundTransparency = 1
	title.Size = UDim2.fromScale(1, 0.58)
	title.Font = Enum.Font.GothamBold
	title.Text = "👑 RATU BBYA 👑"
	title.TextColor3 = Color3.fromRGB(255, 220, 90)
	title.TextStrokeTransparency = 0.25
	title.TextScaled = true
	title.Parent = gui
	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.fromScale(0, 0.58)
	sub.Size = UDim2.fromScale(1, 0.42)
	sub.Font = Enum.Font.GothamMedium
	sub.Text = "OWNER • ALL ACCESS"
	sub.TextColor3 = Color3.new(1,1,1)
	sub.TextStrokeTransparency = 0.45
	sub.TextScaled = true
	sub.Parent = gui
end

local function addBBYASign(part, text, offset)
	if not part or part:FindFirstChild("BBYASign") then return end
	local gui = Instance.new("BillboardGui")
	gui.Name = "BBYASign"
	gui.Size = UDim2.fromOffset(500, 110)
	gui.StudsOffset = offset or Vector3.new(0, 8, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 220
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 90, 210)
	label.TextStrokeColor3 = Color3.fromRGB(45, 5, 65)
	label.TextStrokeTransparency = 0.15
	label.TextScaled = true
	label.Parent = gui
end

local function setupMapIdentity()
	local spawn = workspace:FindFirstChild("A CLUB Entrance Spawn")
	if spawn then spawn.Name = "BBYA Social Hub Entrance Spawn" end
	addBBYASign(workspace:FindFirstChild("Entrance Arch Top"), "BBYA SOCIAL HUB", Vector3.new(0, 5, 0))
	addBBYASign(workspace:FindFirstChild("DJ Booth"), "BBYA • 24/7", Vector3.new(0, 6, 0))
	addBBYASign(workspace:FindFirstChild("Rooftop Bar"), "BBYA ROOFTOP", Vector3.new(0, 6, 0))
end

local clubParts = {}
local function setupClubLighting()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and (string.find(obj.Name, "Dance Light") or string.find(obj.Name, "Ceiling Light Strip")) then
			table.insert(clubParts, obj)
			obj.Material = Enum.Material.Neon
		end
	end
	task.spawn(function()
		local index = 1
		while true do
			index = index % #CLUB_COLORS + 1
			for i, part in ipairs(clubParts) do
				local color = CLUB_COLORS[((index + i - 2) % #CLUB_COLORS) + 1]
				TweenService:Create(part, TweenInfo.new(0.7), {Color = color}):Play()
			end
			task.wait(0.8)
		end
	end)
end

local function setNightMode()
	Lighting.ClockTime = 21.5
	Lighting.Brightness = 1.8
	Lighting.Ambient = Color3.fromRGB(35, 22, 55)
	Lighting.OutdoorAmbient = Color3.fromRGB(15, 18, 40)
end

local function handleQueenCommand(player, message)
	if player.UserId ~= BBYA_QUEEN_USER_ID or string.sub(message, 1, 1) ~= "!" then return end
	local args = string.split(message, " ")
	local command = string.lower(args[1])
	if command == "!kick" then
		local target = findPlayer(args[2]); if target and target ~= player then target:Kick("Removed by BBYA Queen") end
	elseif command == "!bring" then
		local target = findPlayer(args[2]); if target and target.Character and player.Character then target.Character:PivotTo(player.Character:GetPivot() * CFrame.new(3,0,0)) end
	elseif command == "!goto" then
		local target = findPlayer(args[2]); if target and target.Character and player.Character then player.Character:PivotTo(target.Character:GetPivot() * CFrame.new(3,0,0)) end
	elseif command == "!speed" then
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if humanoid then humanoid.WalkSpeed = math.clamp(tonumber(args[2]) or 32,16,80) end
	elseif command == "!normal" then
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if humanoid then humanoid.WalkSpeed = 16 end
	elseif command == "!day" then
		Lighting.ClockTime = 14; Lighting.Brightness = 2
	elseif command == "!night" then
		setNightMode()
	end
end

local function setupPlayer(player)
	markQueen(player)
	if player.UserId == BBYA_QUEEN_USER_ID then
		player.CharacterAdded:Connect(function(character) task.wait(1); addQueenTag(character) end)
		player.Chatted:Connect(function(message) handleQueenCommand(player, message) end)
		if player.Character then addQueenTag(player.Character) end
	end
end

setupMapIdentity()
setNightMode()
setupClubLighting()
Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end

print("[BBYA] Social Hub runtime v0.3 loaded")