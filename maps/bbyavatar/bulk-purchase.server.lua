-- BBYAVATAR Bulk Purchase Gateway v2
-- Server-authoritative purchase conversion for Style Board.
-- Client-supplied IDs are never trusted: every ID must already exist in the player's
-- persistent Saved Picks. PROMPT validates avatar assets and skips owned items.
-- VERIFY re-checks ownership server-side after Roblox closes the bulk purchase prompt.

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
local PROMPT_COOLDOWN = 4
local VERIFY_COOLDOWN = 1
local MAX_ASSET_ID = 9007199254740991
local lastRequestAt = {}
local inFlight = {}

local function cleanId(value)
    local id = tonumber(value)
    if not id or id ~= math.floor(id) or id <= 0 or id > MAX_ASSET_ID then return nil end
    return id
end

local function normalizeIds(rawIds)
    if typeof(rawIds) ~= "table" then return {} end
    local ids, seen = {}, {}
    for _, raw in ipairs(rawIds) do
        local id = cleanId(raw)
        if id and not seen[id] then
            seen[id] = true
            table.insert(ids, id)
            if #ids >= MAX_ITEMS then break end
        end
    end
    return ids
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

local function filterSaved(ids, allowed)
    local out, rejected = {}, 0
    for _, id in ipairs(ids) do
        if allowed[id] then table.insert(out, id) else rejected += 1 end
    end
    return out, rejected
end

local function verifyOwned(player, ids)
    local owned, unresolved = 0, 0
    for _, id in ipairs(ids) do
        local ok, result = pcall(function()
            return MarketplaceService:PlayerOwnsAssetAsync(player, id)
        end)
        if ok and result then owned += 1 elseif not ok then unresolved += 1 end
    end
    return owned, unresolved
end

request.OnServerInvoke = function(player, action, rawIds)
    if action ~= "PROMPT" and action ~= "VERIFY" then return {ok=false, code="INVALID_ACTION"} end
    local ids = normalizeIds(rawIds)
    if #ids == 0 then return {ok=false, code="EMPTY"} end

    local userId = player.UserId
    local now = os.clock()
    local byAction = lastRequestAt[userId]
    if not byAction then byAction = {}; lastRequestAt[userId] = byAction end
    local gap = action == "PROMPT" and PROMPT_COOLDOWN or VERIFY_COOLDOWN
    if now - (byAction[action] or 0) < gap or inFlight[userId] then return {ok=false, code="THROTTLED"} end
    byAction[action] = now
    inFlight[userId] = true

    local allowed, readCode = savedSet(player)
    if not allowed then inFlight[userId] = nil; return {ok=false, code=readCode} end
    local eligible, rejected = filterSaved(ids, allowed)
    if #eligible == 0 then inFlight[userId] = nil; return {ok=false, code="NO_AUTHORIZED_ITEMS", invalid=rejected} end

    if action == "VERIFY" then
        local owned, unresolved = verifyOwned(player, eligible)
        inFlight[userId] = nil
        return {
            ok = unresolved == 0,
            code = unresolved == 0 and "VERIFIED" or "VERIFY_PARTIAL",
            expected = #eligible,
            owned = owned,
            unresolved = unresolved,
            complete = unresolved == 0 and owned == #eligible,
        }
    end

    local lineItems, promptedIds = {}, {}
    local skippedOwned, skippedInvalid = 0, rejected
    for _, id in ipairs(eligible) do
        local ownsOk, owns = pcall(function()
            return MarketplaceService:PlayerOwnsAssetAsync(player, id)
        end)
        if ownsOk and owns then
            skippedOwned += 1
        else
            local infoOk, info = pcall(function()
                return MarketplaceService:GetProductInfoAsync(id, Enum.InfoType.Asset)
            end)
            local creatorType = infoOk and typeof(info) == "table" and info.AssetTypeId
            if infoOk and typeof(info) == "table" and tonumber(info.AssetId or id) == id and creatorType ~= nil then
                table.insert(lineItems, {Type=Enum.MarketplaceProductType.AvatarAsset, Id=tostring(id)})
                table.insert(promptedIds, id)
            else
                skippedInvalid += 1
            end
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
    if not promptOk then return {ok=false, code="PROMPT_FAILED", detail=tostring(promptErr):sub(1,120)} end
    return {ok=true, code="PROMPTED", count=#lineItems, ids=promptedIds, owned=skippedOwned, invalid=skippedInvalid}
end

Players.PlayerRemoving:Connect(function(player)
    lastRequestAt[player.UserId] = nil
    inFlight[player.UserId] = nil
end)

root:SetAttribute("BulkPurchaseGateway", "SERVER_VALIDATED_SAVED_PICKS_V2_VERIFY")
root:SetAttribute("BulkPurchaseMaxItems", MAX_ITEMS)
root:SetAttribute("BulkPurchaseClientAuthority", false)
root:SetAttribute("BulkPurchaseOwnershipVerification", true)
print("[BBYAVATAR] Server-authoritative bulk purchase gateway v2 + ownership verify ready")