local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local root = ReplicatedStorage:WaitForChild("BBYAVATAR")
local remotes = root:WaitForChild("Remotes")
local catalogRequest = remotes:WaitForChild("CatalogRequest")

local CatalogClient = {}

function CatalogClient.FetchLooks()
    local response = catalogRequest:InvokeServer("LIST_LOOKS")
    if not response or not response.ok then
        warn("[BBYAVATAR] Failed to load catalog")
        return {}
    end
    return response.looks or {}
end

function CatalogClient.FetchLook(lookId)
    local response = catalogRequest:InvokeServer("GET_LOOK", {lookId = lookId})
    if not response or not response.ok then
        return nil, response and response.error or "REQUEST_FAILED"
    end
    return response.look
end

-- UI is intentionally generated in a later build phase so the data layer can
-- be tested independently before try-on / purchase controls are connected.
local looks = CatalogClient.FetchLooks()
print(string.format("[BBYAVATAR] Catalog client ready for %s; %d enabled looks", player.Name, #looks))

return CatalogClient
