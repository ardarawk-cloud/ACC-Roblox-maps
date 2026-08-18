local Players = game:GetService("Players")

local function getGate()
    local square = workspace:WaitForChild("WonderSquare_Premium", 20)
    if not square then return nil end
    return square:WaitForChild("Adventure Gate", 10)
end

local gate = getGate()
if gate and gate:IsA("BasePart") then
    local prompt = gate:FindFirstChild("WP_AdventureGatePrompt") or Instance.new("ProximityPrompt")
    prompt.Name = "WP_AdventureGatePrompt"
    prompt.ActionText = "Explore"
    prompt.ObjectText = "Treasure Island"
    prompt.HoldDuration = .3
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = gate

    prompt.Triggered:Connect(function(player)
        if player:GetAttribute("WP_DataLoaded") ~= true then return end
        if player:GetAttribute("WP_DataReadOnly") == true or player:GetAttribute("WP_DataLoadFailed") == true then return end

        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        player:SetAttribute("WP_ActiveAdventure", "TreasureIsland")
        player:SetAttribute("WP_AdventureStartedAt", os.time())
        player:SetAttribute("WP_TreasureProgress", 0)
        hrp.CFrame = CFrame.new(0, 44, -215)
    end)
else
    warn("[WONDERPOCKET] Adventure Gate part not found")
end

Players.PlayerRemoving:Connect(function(player)
    player:SetAttribute("WP_ActiveAdventure", nil)
end)

print("[WONDERPOCKET] Read-only guarded Wonder Square Adventure Gate activated")
