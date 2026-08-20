local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:FindFirstChild("ACC_MountainCarry") or Instance.new("RemoteEvent")
remote.Name = "ACC_MountainCarry"
remote.Parent = ReplicatedStorage

local active = {}

local function clearCarry(carrier)
    local data = active[carrier]
    if not data then return end
    if data.weld and data.weld.Parent then data.weld:Destroy() end
    if data.targetHumanoid then
        data.targetHumanoid.PlatformStand = false
        data.targetHumanoid.AutoRotate = true
    end
    active[carrier] = nil
end

remote.OnServerEvent:Connect(function(player, action, targetUserId)
    if action == "drop" then
        clearCarry(player)
        return
    end
    if action ~= "carry" then return end

    local target = Players:GetPlayerByUserId(tonumber(targetUserId) or 0)
    if not target or target == player then return end

    local c1, c2 = player.Character, target.Character
    local hrp1 = c1 and c1:FindFirstChild("HumanoidRootPart")
    local hrp2 = c2 and c2:FindFirstChild("HumanoidRootPart")
    local hum2 = c2 and c2:FindFirstChildOfClass("Humanoid")
    if not hrp1 or not hrp2 or not hum2 or hum2.Health <= 0 then return end
    if (hrp1.Position - hrp2.Position).Magnitude > 10 then return end

    clearCarry(player)
    hum2.PlatformStand = true
    hum2.AutoRotate = false
    hrp2.CFrame = hrp1.CFrame * CFrame.new(1.4, 0.8, 1.2)

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp1
    weld.Part1 = hrp2
    weld.Parent = hrp1
    active[player] = { weld = weld, targetHumanoid = hum2, target = target }
end)

Players.PlayerRemoving:Connect(function(player)
    clearCarry(player)
    for carrier, data in pairs(active) do
        if data.target == player then clearCarry(carrier) end
    end
end)
