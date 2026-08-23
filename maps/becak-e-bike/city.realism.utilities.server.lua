-- BECAK E-BIKE city realism utilities v1.5
-- Lightweight realism pass for Nusakarya: utility poles/wires, road markings and architectural micro-depth.
-- Dedicated to maps/becak-e-bike. All generated geometry is anchored, visual-only and non-collision.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BecakEBike", 30)
if not root then return end
local world = root:WaitForChild("Nusakarya", 30)
if not world then return end

local old = world:FindFirstChild("CityRealismUtilities")
if old then old:Destroy() end
local folder = Instance.new("Folder")
folder.Name = "CityRealismUtilities"
folder.Parent = world

local function setup(p, color, material)
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    return p
end

local function part(name, size, cf, color, material)
    local p = setup(Instance.new("Part"), color, material)
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Parent = folder
    return p
end

local function cylinder(name, height, radius, cf, color, material)
    local p = part(name, Vector3.new(height, radius * 2, radius * 2), cf * CFrame.Angles(0, 0, math.rad(90)), color, material)
    p.Shape = Enum.PartType.Cylinder
    return p
end

local function wedge(name, size, cf, color, material)
    local p = setup(Instance.new("WedgePart"), color, material)
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Parent = folder
    return p
end

local utilityPoleCount = 0
local utilityWireCount = 0
local roadDetailCount = 0
local facadeDetailCount = 0
local chamferCount = 0

local function addPole(position, axis)
    local model = Instance.new("Model")
    model.Name = "UtilityPole"
    model.Parent = folder

    local pole = setup(Instance.new("Part"), Color3.fromRGB(70, 67, 61), Enum.Material.Wood)
    pole.Name = "Pole"
    pole.Shape = Enum.PartType.Cylinder
    pole.Size = Vector3.new(0.8, 11.5, 0.8)
    pole.CFrame = CFrame.new(position + Vector3.new(0, 5.75, 0))
    pole.Parent = model

    local arm = setup(Instance.new("Part"), Color3.fromRGB(69, 72, 75), Enum.Material.Metal)
    arm.Name = "CrossArm"
    arm.Size = axis == "X" and Vector3.new(4.6, 0.26, 0.26) or Vector3.new(0.26, 0.26, 4.6)
    arm.CFrame = CFrame.new(position + Vector3.new(0, 10.25, 0))
    arm.Parent = model

    local attachments = {}
    for i, offset in ipairs({-1.55, 0, 1.55}) do
        local insulator = setup(Instance.new("Part"), Color3.fromRGB(170, 166, 150), Enum.Material.Ceramic)
        insulator.Name = "Insulator"
        insulator.Shape = Enum.PartType.Ball
        insulator.Size = Vector3.new(0.28, 0.28, 0.28)
        local delta = axis == "X" and Vector3.new(offset, 0.23, 0) or Vector3.new(0, 0.23, offset)
        insulator.CFrame = arm.CFrame + delta
        insulator.Parent = model
        local att = Instance.new("Attachment")
        att.Name = "WireAttachment" .. i
        att.Parent = insulator
        attachments[i] = att
    end

    utilityPoleCount += 1
    return attachments
end

local function connectPoles(a, b)
    for i = 1, math.min(#a, #b) do
        local beam = Instance.new("Beam")
        beam.Name = "UtilityWire"
        beam.Attachment0 = a[i]
        beam.Attachment1 = b[i]
        beam.Width0 = 0.045
        beam.Width1 = 0.045
        beam.FaceCamera = true
        beam.LightInfluence = 1
        beam.Color = ColorSequence.new(Color3.fromRGB(45, 47, 48))
        beam.CurveSize0 = -0.65
        beam.CurveSize1 = 0.65
        beam.Parent = folder
        utilityWireCount += 1
    end
end

local function utilityLine(points, axis)
    local previous
    for _, pos in ipairs(points) do
        local current = addPole(pos, axis)
        if previous then connectPoles(previous, current) end
        previous = current
    end
end

-- Sparse utility corridors: enough to make the skyline believable without filling mobile clients with wires.
local eastWest = {}
for x = -430, 430, 86 do
    table.insert(eastWest, Vector3.new(x, 0.7, 31))
end
utilityLine(eastWest, "X")

local northSouth = {}
for z = -430, 430, 86 do
    table.insert(northSouth, Vector3.new(31, 0.7, z))
end
utilityLine(northSouth, "Z")

-- Realistic road surface cues: zebra crossings, parking bays and edge reflectors.
local function zebra(center, alongX)
    for i = -4, 4 do
        local offset = i * 2.35
        local size = alongX and Vector3.new(1.35, 0.035, 7.5) or Vector3.new(7.5, 0.035, 1.35)
        local pos = alongX and Vector3.new(center.X + offset, 0.49, center.Z) or Vector3.new(center.X, 0.49, center.Z + offset)
        local stripe = part("ZebraStripe", size, CFrame.new(pos), Color3.fromRGB(224, 224, 216), Enum.Material.SmoothPlastic)
        stripe.CastShadow = false
        roadDetailCount += 1
    end
end

zebra(Vector3.new(-80, 0, 0), true)
zebra(Vector3.new(90, 0, 0), true)
zebra(Vector3.new(0, 0, -90), false)
zebra(Vector3.new(0, 0, 90), false)

for x = -360, 360, 72 do
    for _, z in ipairs({-17.6, 17.6}) do
        local mark = part("ParkingBayMark", Vector3.new(11, 0.03, 0.22), CFrame.new(x, 0.5, z), Color3.fromRGB(205, 205, 195), Enum.Material.SmoothPlastic)
        mark.CastShadow = false
        roadDetailCount += 1
    end
end

for z = -360, 360, 72 do
    for _, x in ipairs({-17.6, 17.6}) do
        local mark = part("ParkingBayMark", Vector3.new(0.22, 0.03, 11), CFrame.new(x, 0.5, z), Color3.fromRGB(205, 205, 195), Enum.Material.SmoothPlastic)
        mark.CastShadow = false
        roadDetailCount += 1
    end
end

-- Add restrained architectural micro-depth to the blockout buildings produced by runtime.server.lua.
for _, model in ipairs(world:GetChildren()) do
    if model:IsA("Model") then
        local body = model:FindFirstChild("Body")
        if body and body:IsA("BasePart") then
            local size = body.Size
            local cf = body.CFrame
            if size.X >= 20 and size.Y >= 16 and size.Z >= 14 then
                local front = -size.Z / 2 - 0.82
                local groundY = -size.Y / 2
                local accent = body.Color:Lerp(Color3.fromRGB(52, 55, 58), 0.38)
                local trim = body.Color:Lerp(Color3.fromRGB(235, 230, 216), 0.32)

                -- Deep shadow reveal below eaves and around the ground floor prevents flat-cardboard facades.
                local shadowBand = part("FacadeShadowReveal", Vector3.new(size.X * 0.78, 0.24, 0.34), cf * CFrame.new(0, math.min(size.Y * 0.22, 5.4), front), accent, Enum.Material.Concrete)
                shadowBand.CastShadow = false
                facadeDetailCount += 1

                local sillY = groundY + math.clamp(size.Y * 0.42, 6.2, 10.5)
                for _, x in ipairs({-size.X * 0.27, 0, size.X * 0.27}) do
                    if math.abs(x) < size.X / 2 - 3 then
                        local sill = part("WindowSill", Vector3.new(math.clamp(size.X * 0.15, 3.6, 6.5), 0.16, 0.62), cf * CFrame.new(x, sillY, front - 0.12), trim, Enum.Material.Concrete)
                        sill.CastShadow = true
                        facadeDetailCount += 1
                    end
                end

                -- Sparse chamfer wedges soften hard 90-degree corners without changing collision.
                local variant = math.floor(math.abs(cf.Position.X * 0.31 + cf.Position.Z * 0.57)) % 3
                if size.X >= 30 and size.Y >= 20 and variant == 0 then
                    local h = math.min(size.Y * 0.56, 13)
                    local side = (math.floor(math.abs(cf.Position.X + cf.Position.Z)) % 2 == 0) and 1 or -1
                    local wx = side * (size.X / 2 + 0.16)
                    wedge("CornerChamfer", Vector3.new(2.2, h, 2.2), cf * CFrame.new(wx, -size.Y / 2 + h / 2 + 0.35, front + 1.2) * CFrame.Angles(0, side > 0 and math.rad(45) or math.rad(-135), 0), body.Color, Enum.Material.Concrete)
                    chamferCount += 1
                end

                -- Rooftop antenna/service detail gives large slabs a believable skyline scale cue.
                if size.Y >= 28 then
                    local roofY = size.Y / 2 + 1.1
                    local antennaX = math.clamp(size.X * 0.22, 4, 11)
                    local mast = cylinder("RoofAntennaMast", 3.2, 0.10, cf * CFrame.new(antennaX, roofY + 1.6, 0), Color3.fromRGB(80, 83, 85), Enum.Material.Metal)
                    mast.CastShadow = false
                    local cap = part("RoofAntennaCap", Vector3.new(0.46, 0.16, 0.46), cf * CFrame.new(antennaX, roofY + 3.15, 0), Color3.fromRGB(105, 110, 112), Enum.Material.Metal)
                    cap.CastShadow = false
                    facadeDetailCount += 2
                end
            end
        end
    end
end

Workspace:SetAttribute("ACC_BecakCityRealismUtilities", "v1.5")
Workspace:SetAttribute("BecakUtilityPoleNetwork", "ON")
Workspace:SetAttribute("BecakOverheadWireNetwork", "ON")
Workspace:SetAttribute("BecakRealisticRoadMarkings", "ON")
Workspace:SetAttribute("BecakFacadeMicroDepth", "ON")
Workspace:SetAttribute("BecakCornerChamferPass", "ON")
Workspace:SetAttribute("BecakUtilityPoleCount", utilityPoleCount)
Workspace:SetAttribute("BecakUtilityWireCount", utilityWireCount)
Workspace:SetAttribute("BecakRealismRoadDetailCount", roadDetailCount)
Workspace:SetAttribute("BecakRealismFacadeDetailCount", facadeDetailCount)
Workspace:SetAttribute("BecakRealismChamferCount", chamferCount)
