-- BBYAVATAR Bulk Purchase Gateway v1
-- Server-authoritative purchase conversion for Style Board.
-- Client-supplied IDs are never trusted: every ID must already exist in the player's
-- persistent Saved Picks, must resolve as a Roblox avatar asset, and must not already be owned.

local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local savedStore = DataStoreService:GetDataStore("BBYAVATAR_SavedPicks_v1")
local request = rem:FindFirstChild("BulkPurchaseRequest")
if not request then
    request = Instance.new("RemoteFunction")
    request.Name = "BulkPurchaseRequest"
    request.Parent = rem
end

local MAX_ITEMS = 6
local REQUEST_COOLDOWN = 4
local MAX_ASSET_ID = 9007199254740991
local lastRequestAt = {}
local inFlight = {}

local function cleanId(value)
    local id = tonumber(value)
    if not id or id ~= math.floor(id) or id <= 0 or id > MAX_ASSET_ID then return nil end
    return id
end

local function savedSet(player)
    local ok, value = pcall(function()
        return savedStore:GetAsync("u:" .. tostring(player.UserId))
    end)
    if not ok then return nil, "SAVED_PICKS_READ_FAILED" end
    local source = typeof(value) == "table" and value.ids or value
    if typeof(source) ~= "table" then source = {} end
    local set = {}
    for _, raw in ipairs(source) do
        local id = cleanId(raw)
        if id then set[id] = true end
    end
    return set
end

request.OnServerInvoke = function(player, rawIds)
    if typeof(rawIds) ~= "table" then return {ok=false, code="INVALID_REQUEST"} end
    local userId = player.UserId
    local now = os.clock()
    if now - (lastRequestAt[userId] or 0) < REQUEST_COOLDOWN or inFlight[userId] then
        return {ok=false, code="THROTTLED"}
    end
    lastRequestAt[userId] = now
    inFlight[userId] = true

    local ids, seen = {}, {}
    for _, raw in ipairs(rawIds) do
        local id = cleanId(raw)
        if id and not seen[id] then
            seen[id] = true
            table.insert(ids, id)
            if #ids >= MAX_ITEMS then break end
        end
    end
    if #ids == 0 then inFlight[userId] = nil; return {ok=false, code="EMPTY"} end

    local allowed, readCode = savedSet(player)
    if not allowed then inFlight[userId] = nil; return {ok=false, code=readCode} end

    local lineItems = {}
    local skippedOwned, skippedInvalid = 0, 0
    for _, id in ipairs(ids) do
        if allowed[id] then
            local ownsOk, owns = pcall(function()
                return MarketplaceService:PlayerOwnsAssetAsync(player, id)
            end)
            if ownsOk and owns then
                skippedOwned += 1
            else
                local infoOk, info = pcall(function()
                    return MarketplaceService:GetProductInfoAsync(id, Enum.InfoType.Asset)
                end)
                if infoOk and typeof(info) == "table" and tonumber(info.AssetId or id) == id then
                    table.insert(lineItems, {Type=Enum.MarketplaceProductType.AvatarAsset, Id=tostring(id)})
                else
                    skippedInvalid += 1
                end
            end
        else
            skippedInvalid += 1
        end
    end

    if #lineItems == 0 then
        inFlight[userId] = nil
        return {ok=false, code=(skippedOwned > 0 and "ALL_OWNED" or "NO_VALID_ITEMS"), owned=skippedOwned, invalid=skippedInvalid}
    end

    local promptOk, promptErr = pcall(function()
        MarketplaceService:PromptBulkPurchase(player, lineItems, {})
    end)
    inFlight[userId] = nil
    if not promptOk then
        return {ok=false, code="PROMPT_FAILED", detail=tostring(promptErr):sub(1,120)}
    end
    return {ok=true, code="PROMPTED", count=#lineItems, owned=skippedOwned, invalid=skippedInvalid}
end

Players.PlayerRemoving:Connect(function(player)
    lastRequestAt[player.UserId] = nil
    inFlight[player.UserId] = nil
end)

root:SetAttribute("BulkPurchaseGateway", "SERVER_VALIDATED_SAVED_PICKS_V1")
root:SetAttribute("BulkPurchaseMaxItems", MAX_ITEMS)
root:SetAttribute("BulkPurchaseClientAuthority", false)
print("[BBYAVATAR] Server-authoritative bulk purchase gateway v1 ready")