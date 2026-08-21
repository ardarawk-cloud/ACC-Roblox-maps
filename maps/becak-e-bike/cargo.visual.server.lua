-- BECAK E-BIKE — cargo payload visualizer v1.30
-- Mirrors the existing CargoDestination state into lightweight, non-colliding crate visuals on the player's becak.
-- Visual-only: does not own payout, job state, physics, or persistence.

local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')

local root = Workspace:WaitForChild('BecakEBike', 20)
if not root then return end
local vehicles = root:WaitForChild('Vehicles', 20)
if not vehicles then return end

local PAYLOAD_NAME = 'CargoPayloadVisual'
local CRATE_COUNT = 3

local function findBecak(player)
    for _, model in ipairs(vehicles:GetChildren()) do
        if model:IsA('Model') and model:GetAttribute('OwnerUserId') == player.UserId then
            return model
        end
    end
end

local function clearPayload(model)
    if not model then return end
    local old = model:FindFirstChild(PAYLOAD_NAME)
    if old then old:Destroy() end
    model:SetAttribute('CargoVisualLoaded', false)
end

local function addCrate(folder, chassis, index, offset)
    local crate = Instance.new('Part')
    crate.Name = 'CargoCrate_' .. index
    crate.Size = Vector3.new(2.2, 1.65, 2.25)
    crate.CFrame = chassis.CFrame * CFrame.new(offset)
    crate.Anchored = false
    crate.CanCollide = false
    crate.CanTouch = false
    crate.CanQuery = false
    crate.Massless = true
    crate.Material = Enum.Material.WoodPlanks
    crate.Color = Color3.fromRGB(156, 111, 67)
    crate.TopSurface = Enum.SurfaceType.Smooth
    crate.BottomSurface = Enum.SurfaceType.Smooth
    crate.Parent = folder

    local weld = Instance.new('WeldConstraint')
    weld.Part0 = chassis
    weld.Part1 = crate
    weld.Parent = crate

    return crate
end

local function buildPayload(model, destination)
    if not model then return end
    clearPayload(model)

    local chassis = model:FindFirstChild('Chassis') or model.PrimaryPart
    if not chassis or not chassis:IsA('BasePart') then return end

    local folder = Instance.new('Folder')
    folder.Name = PAYLOAD_NAME
    folder.Parent = model

    -- Keep payload centered and low so it does not affect camera readability or mobile driving visibility.
    local offsets = {
        Vector3.new(-1.35, 1.55, -1.8),
        Vector3.new(1.35, 1.55, -1.8),
        Vector3.new(0, 3.25, -1.8),
    }
    for i = 1, CRATE_COUNT do
        addCrate(folder, chassis, i, offsets[i])
    end

    local tagAnchor = folder:FindFirstChild('CargoCrate_3')
    if tagAnchor then
        local gui = Instance.new('BillboardGui')
        gui.Name = 'CargoDestinationTag'
        gui.Size = UDim2.fromOffset(150, 34)
        gui.StudsOffset = Vector3.new(0, 1.8, 0)
        gui.AlwaysOnTop = false
        gui.MaxDistance = 55
        gui.LightInfluence = 0.35
        gui.Parent = tagAnchor

        local text = Instance.new('TextLabel')
        text.Size = UDim2.fromScale(1, 1)
        text.BackgroundTransparency = 0.2
        text.BackgroundColor3 = Color3.fromRGB(19, 24, 22)
        text.TextColor3 = Color3.fromRGB(245, 244, 235)
        text.TextSize = 11
        text.TextWrapped = true
        text.Font = Enum.Font.GothamBold
        text.Text = 'CARGO • ' .. tostring(destination)
        text.Parent = gui

        local corner = Instance.new('UICorner')
        corner.CornerRadius = UDim.new(0, 7)
        corner.Parent = text
    end

    model:SetAttribute('CargoVisualLoaded', true)
end

local function syncPlayer(player)
    local destination = player:GetAttribute('CargoDestination')
    local model = findBecak(player)
    if not model then return end
    if type(destination) == 'string' and destination ~= '' then
        buildPayload(model, destination)
    else
        clearPayload(model)
    end
end

local watchers = {}
local function hookPlayer(player)
    if watchers[player] then return end
    watchers[player] = player:GetAttributeChangedSignal('CargoDestination'):Connect(function()
        syncPlayer(player)
    end)
    task.delay(2, function()
        if player.Parent then syncPlayer(player) end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do hookPlayer(player) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function(player)
    local conn = watchers[player]
    if conn then conn:Disconnect() end
    watchers[player] = nil
end)

vehicles.ChildAdded:Connect(function(model)
    task.defer(function()
        if not model:IsA('Model') then return end
        local ownerId = model:GetAttribute('OwnerUserId')
        if not ownerId then return end
        local player = Players:GetPlayerByUserId(ownerId)
        if player then syncPlayer(player) end
    end)
end)

Workspace:SetAttribute('ACC_BecakCargoVisual', 'v1.30')
Workspace:SetAttribute('BecakCargoVisualCrates', CRATE_COUNT)
Workspace:SetAttribute('BecakCargoVisualCollision', 'OFF')
print('[BECAK E-BIKE] cargo payload visualizer v1.30 ready')
