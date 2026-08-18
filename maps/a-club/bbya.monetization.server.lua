-- BBYA SOCIAL HUB — MONETIZATION BACKEND v1.0
-- VIP = one-time Game Pass (price configured in Roblox Creator Dashboard; target plan: 10 Robux).
-- Support/saweran = repeatable Developer Products.
-- IMPORTANT: replace the 0 IDs below with real Roblox IDs before monetization UI activates.

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QUEEN_USER_ID = 4271188557

-- Real IDs are intentionally not invented.
local VIP_GAMEPASS_ID = 0
local SUPPORT_PRODUCTS = {
	[5] = 0,
	[10] = 0,
	[25] = 0,
	[50] = 0,
	[100] = 0,
	[250] = 0,
	[500] = 0,
}

local donationStore = DataStoreService:GetDataStore("BBYA_Donations_v2")
local supporterStore = DataStoreService:GetOrderedDataStore("BBYA_TopSupporters_v1")

local configFolder = ReplicatedStorage:FindFirstChild("BBYA_Monetization") or Instance.new("Folder")
configFolder.Name = "BBYA_Monetization"
configFolder.Parent = ReplicatedStorage

local function intValue(name, value)
	local obj = configFolder:FindFirstChild(name) or Instance.new("IntValue")
	obj.Name = name
	obj.Value = value or 0
	obj.Parent = configFolder
	return obj
end

intValue("VIPGamePassId", VIP_GAMEPASS_ID)
for amount, productId in pairs(SUPPORT_PRODUCTS) do
	intValue("Support_" .. amount, productId)
end

local productToAmount = {}
for amount, productId in pairs(SUPPORT_PRODUCTS) do
	if type(productId) == "number" and productId > 0 then
		productToAmount[productId] = amount
	end
end

local configured = VIP_GAMEPASS_ID > 0 or next(productToAmount) ~= nil
workspace:SetAttribute("BBYAMonetizationConfigured", configured)
workspace:SetAttribute("BBYAVIPTargetPrice", 10)

local function loadDonationProfile(player)
	local key = "u" .. player.UserId
	local success, data = pcall(function()
		return donationStore:GetAsync(key)
	end)
	if success and type(data) == "table" then
		player:SetAttribute("TotalDonated", tonumber(data.Total) or 0)
	else
		player:SetAttribute("TotalDonated", player:GetAttribute("TotalDonated") or 0)
	end
end

local function checkVIP(player)
	if player.UserId == QUEEN_USER_ID then
		player:SetAttribute("IsVIP", true)
		player:SetAttribute("BBYAAllAccess", true)
		return
	end

	if VIP_GAMEPASS_ID <= 0 then
		if player:GetAttribute("IsVIP") == nil then player:SetAttribute("IsVIP", false) end
		return
	end

	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, VIP_GAMEPASS_ID)
	end)
	player:SetAttribute("IsVIP", ok and owns == true)
	if ok and owns then
		player:SetAttribute("BBYARole", player:GetAttribute("BBYARole") == "GUEST" and "VIP" or (player:GetAttribute("BBYARole") or "VIP"))
	end
end

local function setupPlayer(player)
	if player:GetAttribute("TotalDonated") == nil then player:SetAttribute("TotalDonated", 0) end
	task.spawn(loadDonationProfile, player)
	task.spawn(checkVIP, player)
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if VIP_GAMEPASS_ID > 0 and passId == VIP_GAMEPASS_ID and purchased then
		player:SetAttribute("IsVIP", true)
		if player:GetAttribute("BBYARole") == "GUEST" then player:SetAttribute("BBYARole", "VIP") end
	end
end)

-- ProcessReceipt must be defined in exactly one active server script.
-- No other active BBYA runtime owns ProcessReceipt after this backend is installed.
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local amount = productToAmount[receiptInfo.ProductId]
	if not amount then
		-- Unknown receipt: don't grant it here. This allows future non-BBYA products to be handled deliberately.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local purchaseId = tostring(receiptInfo.PurchaseId)
	local key = "u" .. player.UserId
	local grantedNow = false
	local newTotal = player:GetAttribute("TotalDonated") or 0

	local success, updated = pcall(function()
		return donationStore:UpdateAsync(key, function(data)
			data = type(data) == "table" and data or {Total = 0, Receipts = {}}
			data.Total = tonumber(data.Total) or 0
			data.Receipts = type(data.Receipts) == "table" and data.Receipts or {}

			if data.Receipts[purchaseId] then
				return data
			end

			data.Total += amount
			data.Receipts[purchaseId] = os.time()
			grantedNow = true
			return data
		end)
	end)

	if not success or type(updated) ~= "table" then
		warn("[BBYA MONETIZATION] receipt save failed", receiptInfo.PurchaseId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	newTotal = tonumber(updated.Total) or newTotal
	player:SetAttribute("TotalDonated", newTotal)

	pcall(function()
		supporterStore:SetAsync("u" .. player.UserId, newTotal)
	end)

	if grantedNow then
		workspace:SetAttribute("BBYALastSupporter", player.DisplayName)
		workspace:SetAttribute("BBYALastSupportAmount", amount)
		workspace:SetAttribute("BBYALastSupportTotal", newTotal)
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

print(string.format("[BBYA MONETIZATION] v1.0 loaded — VIP ID %s; %d support products configured", VIP_GAMEPASS_ID > 0 and tostring(VIP_GAMEPASS_ID) or "PENDING", (function() local n=0 for _ in pairs(productToAmount) do n+=1 end return n end)()))
