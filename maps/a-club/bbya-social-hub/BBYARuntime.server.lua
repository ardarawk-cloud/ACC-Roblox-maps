local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")

local Config = require(script.Parent.BBYAConfig)
local remotes = ReplicatedStorage:WaitForChild("BBYA"):WaitForChild("Remotes")

local buckets = {}
local totals = {}

local function getRole(player)
	return Config.Roles.UserRoles[player.UserId] or "PLAYER"
end

local function rank(role)
	return Config.Roles.Hierarchy[role] or 0
end

local function atLeast(player, required)
	return rank(getRole(player)) >= rank(required)
end

local function rateLimit(player, key, cooldown)
	local uid = player.UserId
	buckets[uid] = buckets[uid] or {}
	local now = os.clock()
	local last = buckets[uid][key] or 0
	if now - last < cooldown then return false end
	buckets[uid][key] = now
	return true
end

local music = SoundService:FindFirstChild("BBYA_MainMusic") or Instance.new("Sound")
music.Name = "BBYA_MainMusic"
music.Volume = Config.Music.DefaultVolume
music.Parent = SoundService

local function applyLighting(name)
	local preset = Config.Lighting[name]
	if not preset then return false end
	for property, value in pairs(preset) do
		pcall(function() Lighting[property] = value end)
	end
	return true
end

applyLighting("NORMAL_CLUB")

remotes.MusicCommand.OnServerEvent:Connect(function(player, command, payload)
	if not rateLimit(player, "Music", 0.25) then return end
	if not atLeast(player, "DJ") then return end
	if typeof(command) ~= "string" then return end

	if command == "PLAY" then
		music:Play()
	elseif command == "PAUSE" then
		music:Pause()
	elseif command == "STOP" then
		music:Stop()
	elseif command == "VOLUME" and typeof(payload) == "number" then
		music.Volume = math.clamp(payload, 0, 1)
	elseif command == "TRACK" and typeof(payload) == "number" and payload > 0 then
		music.SoundId = "rbxassetid://" .. payload
		music:Play()
	end
end)

remotes.LightingCommand.OnServerEvent:Connect(function(player, preset)
	if not rateLimit(player, "Lighting", 0.5) then return end
	if not atLeast(player, "ADMIN") and getRole(player) ~= "BBYA_QUEEN" then return end
	if typeof(preset) ~= "string" then return end
	applyLighting(preset)
end)

local destinations = {
	CLUB = true, ROOFTOP = true, POOL = true, BAR = true, SOCIAL = true,
	EVENTS = true, PHOTO = true, VIP = true, BBYA_QUEEN = true,
}

remotes.TeleportRequest.OnServerEvent:Connect(function(player, destination)
	if not rateLimit(player, "Teleport", 1) then return end
	if typeof(destination) ~= "string" or not destinations[destination] then return end
	if destination == "VIP" and not atLeast(player, "VIP") then return end
	if destination == "BBYA_QUEEN" and getRole(player) ~= "BBYA_QUEEN" and getRole(player) ~= "ACC_MASTER_OWNER" then return end

	local world = workspace:FindFirstChild("BBYA_WORLD")
	local nav = world and world:FindFirstChild("Navigation")
	local target = nav and nav:FindFirstChild(destination .. "_SPAWN")
	local character = player.Character
	if target and character then
		character:PivotTo(target.CFrame + Vector3.new(0, 3, 0))
	end
end)

local productToAmount = {}
for amount, productId in pairs(Config.SupportProducts) do
	if productId and productId > 0 then productToAmount[productId] = amount end
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local amount = productToAmount[receiptInfo.ProductId]
	if amount then
		totals[player.UserId] = (totals[player.UserId] or 0) + amount
		remotes.SupportEffect:FireAllClients(player.DisplayName, amount, totals[player.UserId])
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function bindQueenThrone()
	local world = workspace:FindFirstChild("BBYA_WORLD")
	local queen = world and world:FindFirstChild("Queen")
	local throne = queen and queen:FindFirstChild("QueenThrone", true)
	if not throne or not throne:IsA("Seat") then return end

	throne:GetPropertyChangedSignal("Occupant"):Connect(function()
		local humanoid = throne.Occupant
		local player = humanoid and Players:GetPlayerFromCharacter(humanoid.Parent)
		local active = player and (getRole(player) == "BBYA_QUEEN" or getRole(player) == "ACC_MASTER_OWNER")
		for _, obj in ipairs(queen:GetDescendants()) do
			if obj:GetAttribute("QueenReactive") == true then
				if obj:IsA("Light") or obj:IsA("ParticleEmitter") then
					obj.Enabled = active == true
				elseif obj:IsA("BasePart") then
					obj.Material = active and Enum.Material.Neon or Enum.Material.SmoothPlastic
				end
			end
		end
	end)
end

bindQueenThrone()

Players.PlayerRemoving:Connect(function(player)
	buckets[player.UserId] = nil
end)
