-- WONDERPOCKET General Starter Inventory v1.0
local Players = game:GetService("Players")

local STARTER = {
    CarrotSeed = 3,
    BubbiBadge = 1,
}

local function ensureInventory(player)
    local inv = player:FindFirstChild("WP_Inventory") or Instance.new("Folder")
    inv.Name = "WP_Inventory"
    inv.Parent = player

    if not inv:GetAttribute("Initialized") then
        for itemId, amount in pairs(STARTER) do
            local value = Instance.new("IntValue")
            value.Name = itemId
            value.Value = amount
            value.Parent = inv
        end
        inv:SetAttribute("Initialized", true)
    end

    if player:GetAttribute("WP_Quest_Starter") == nil then
        player:SetAttribute("WP_Quest_Starter", "HARVEST_3")
    end
    return inv
end

Players.PlayerAdded:Connect(function(player)
    ensureInventory(player)
end)

for _, player in Players:GetPlayers() do ensureInventory(player) end

print("[WONDERPOCKET] Clean starter inventory loaded")
