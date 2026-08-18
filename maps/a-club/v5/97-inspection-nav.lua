-- BBYA V5.2 CODED INSPECTION NAVIGATION
-- QC-only navigation helper. Uses explicit safe landings; never derives teleports from furniture or zone centers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local old = ReplicatedStorage:FindFirstChild("BBYA_V5_InspectionNav")
if old then old:Destroy() end

local nav = Instance.new("RemoteEvent")
nav.Name = "BBYA_V5_InspectionNav"
nav.Parent = ReplicatedStorage

local TARGETS = {
    A1 = CFrame.new(0, 3, 176) * CFrame.Angles(0, math.rad(180), 0),
    A2 = CFrame.new(0, 3, 139) * CFrame.Angles(0, math.rad(180), 0),
    A3 = CFrame.new(0, 3, 106) * CFrame.Angles(0, math.rad(180), 0),
    A4 = CFrame.new(0, 3, 14) * CFrame.Angles(0, math.rad(180), 0),
    A5 = CFrame.new(-72, 3, 60),
    A6 = CFrame.new(72, 3, 60),

    B1 = CFrame.new(-70, 3, -17),
    B2 = CFrame.new(70, 3, -17),
    B3 = CFrame.new(72, 3, 96),

    C1 = CFrame.new(-70, 21, -17),
    C2 = CFrame.new(70, 21, -17),
    C3 = CFrame.new(0, 21, -62),

    D1 = CFrame.new(0, 39, 96) * CFrame.Angles(0, math.rad(180), 0),
    D2 = CFrame.new(0, 39, -43),
    D3 = CFrame.new(-58, 39, 43),
    D4 = CFrame.new(58, 39, 43),
    D5 = CFrame.new(-62, 39, -40),
    D6 = CFrame.new(0, 39, 108) * CFrame.Angles(0, math.rad(180), 0),

    S1 = CFrame.new(-75, 3, 109),
}

local cooldown = {}
nav.OnServerEvent:Connect(function(player, code)
    code = tostring(code or ""):upper()
    local target = TARGETS[code]
    if not target then return end

    local now = os.clock()
    if cooldown[player] and now - cooldown[player] < 0.45 then return end
    cooldown[player] = now

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not rootPart then return end

    character:PivotTo(target)
    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    player:SetAttribute("BBYALastInspectionTeleport", code)
end)

Players.PlayerRemoving:Connect(function(player)
    cooldown[player] = nil
end)

workspace:SetAttribute("BBYAV5InspectionNav", "CODED_SAFE_LANDINGS")
