-- WONDERPOCKET General Inventory Mirror v1.2
local Players = game:GetService("Players")

local function waitForData(player)
    local deadline = os.clock() + 20
    while player.Parent and os.clock() < deadline do
        if player:GetAttribute("WP_DataLoaded") == true then return true end
        task.wait(.25)
    end
    return false
end

local function ensureValue(parent, name, value)
    local obj = parent:FindFirstChild(name)
    if not obj or not obj:IsA("IntValue") then
        if obj then obj:Destroy() end
        obj = Instance.new("IntValue")
        obj.Name = name
        obj.Parent = parent
    end
    obj.Value = math.max(0, math.floor(tonumber(value) or 0))
    return obj
end

local function setup(player)
    if not waitForData(player) then return end

    local inv = player:FindFirstChild("WP_Inventory") or Instance.new("Folder")
    inv.Name = "WP_Inventory"
    inv.Parent = player

    local carrot = ensureValue(inv, "CarrotSeed", player:GetAttribute("CarrotSeed"))
    local badge = ensureValue(inv, "BubbiBadge", 1)
    inv:SetAttribute("Initialized", true)
    inv:SetAttribute("AuthoritativeSource", "PlayerAttributes/MainData")

    player:GetAttributeChangedSignal("CarrotSeed"):Connect(function()
        if carrot.Parent then
            carrot.Value = math.max(0, math.floor(tonumber(player:GetAttribute("CarrotSeed")) or 0))
        end
    end)

    badge.Value = 1
end

Players.PlayerAdded:Connect(function(player) task.spawn(setup, player) end)
for _, player in Players:GetPlayers() do task.spawn(setup, player) end

print("[WONDERPOCKET] Canonical inventory mirror loaded")
