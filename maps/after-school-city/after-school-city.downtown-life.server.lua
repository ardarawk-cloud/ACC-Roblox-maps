-- AFTER SCHOOL CITY — Downtown Life Pass v0.3
-- Converts the v0.2 storefront blocks into open, decorated shells for walk-in exploration.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC DowntownLife] AfterSchoolCity root missing")
    return
end

local districts = root:WaitForChild("Districts", 10)
local downtown = districts and districts:WaitForChild("Downtown", 10)
if not downtown then
    warn("[ASC DowntownLife] Downtown missing")
    return
end

if downtown:FindFirstChild("V03_DowntownLife") then
    return
end

local layer = Instance.new("Model")
layer.Name = "V03_DowntownLife"
layer:SetAttribute("ASC_Layer", "DOWNTOWN_LIFE")
layer:SetAttribute("ASC_Version", "0.3-city-life-pass-1")
layer.Parent = downtown

local C = {
    dark = Color3.fromRGB(31, 35, 42),
    charcoal = Color3.fromRGB(48, 52, 60),
    white = Color3.fromRGB(235, 238, 242),
    concrete = Color3.fromRGB(198, 202, 208),
    glass = Color3.fromRGB(88, 139, 172),
    blue = Color3.fromRGB(59, 102, 151),
    gold = Color3.fromRGB(242, 180, 65),
    teal = Color3.fromRGB(58, 133, 126),
    purple = Color3.fromRGB(124, 91, 150),
    red = Color3.fromRGB(174, 72, 68),
    wood = Color3.fromRGB(135, 96, 66),
    metal = Color3.fromRGB(86, 92, 101),
}

local function part(parent, name, size, cf, color, material, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color or C.white
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function textPlate(parent, text, size, cf, color, textColor)
    local plate = part(parent, "LabelPlate", size, cf, color or C.dark, Enum.Material.SmoothPlastic)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.PixelsPerStud = 32
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.Parent = plate
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor or C.white
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = gui
    return plate
end

local function shelf(parent, pos, width, height, color)
    part(parent, "ShelfBack", Vector3.new(width, height, 1), CFrame.new(pos), color or C.dark, Enum.Material.Wood)
    for y = 2, height - 2, 3.5 do
        part(parent, "Shelf", Vector3.new(width, 0.35, 3.5), CFrame.new(pos.X, pos.Y - height / 2 + y, pos.Z + 1), C.wood, Enum.Material.Wood)
    end
end

local function tableSet(parent, pos)
    part(parent, "Table", Vector3.new(6, 0.7, 6), CFrame.new(pos + Vector3.new(0, 3.2, 0)), C.wood, Enum.Material.Wood)
    part(parent, "TableLeg", Vector3.new(0.8, 3, 0.8), CFrame.new(pos + Vector3.new(0, 1.5, 0)), C.metal, Enum.Material.Metal)
    for _, off in ipairs({Vector3.new(0, 1.7, -4), Vector3.new(0, 1.7, 4), Vector3.new(-4, 1.7, 0), Vector3.new(4, 1.7, 0)}) do
        part(parent, "Chair", Vector3.new(2.6, 0.6, 2.6), CFrame.new(pos + off), C.charcoal, Enum.Material.SmoothPlastic)
    end
end

local function cabinet(parent, pos, accent)
    part(parent, "CabinetBody", Vector3.new(5, 8, 4), CFrame.new(pos), C.dark, Enum.Material.Metal)
    local screen = part(parent, "CabinetScreen", Vector3.new(3.8, 3, 0.35), CFrame.new(pos.X, pos.Y + 1.1, pos.Z - 2.15), accent, Enum.Material.Neon)
    screen.CanCollide = false
    part(parent, "ControlPanel", Vector3.new(4, 0.6, 2.2), CFrame.new(pos.X, pos.Y - 1.2, pos.Z - 2), C.charcoal, Enum.Material.Metal)
end

local shopNames = {"ARCADE", "CAFE", "STYLE", "MUSIC", "HOBBY"}
local shopXs = {-90, -45, 0, 45, 90}

for i, name in ipairs(shopNames) do
    local shop = downtown:FindFirstChild("Shop_" .. name)
    if shop then
        local oldBuilding = shop:FindFirstChild("Building")
        local oldStorefront = shop:FindFirstChild("Storefront")
        local h = oldBuilding and oldBuilding.Size.Y or 30
        local x = oldBuilding and oldBuilding.Position.X or shopXs[i]

        if oldBuilding then
            oldBuilding.Transparency = 1
            oldBuilding.CanCollide = false
            oldBuilding.CanTouch = false
            oldBuilding.CanQuery = false
        end
        if oldStorefront then
            oldStorefront.Transparency = 1
            oldStorefront.CanCollide = false
            oldStorefront.CanTouch = false
            oldStorefront.CanQuery = false
        end

        local interior = Instance.new("Model")
        interior.Name = "V03_Interior"
        interior:SetAttribute("ASC_Enterable", true)
        interior:SetAttribute("ASC_ShopType", name)
        interior.Parent = shop

        -- Open-front shell within the same footprint as the old block.
        part(interior, "Floor", Vector3.new(32, 0.6, 38), CFrame.new(x, 1.4, -56), Color3.fromRGB(181, 179, 172), Enum.Material.Concrete)
        part(interior, "BackWall", Vector3.new(32, h - 2, 1.2), CFrame.new(x, h / 2 + 1, -75.2), C.white, Enum.Material.Concrete)
        part(interior, "WallL", Vector3.new(1.2, h - 2, 38), CFrame.new(x - 16, h / 2 + 1, -56), C.white, Enum.Material.Concrete)
        part(interior, "WallR", Vector3.new(1.2, h - 2, 38), CFrame.new(x + 16, h / 2 + 1, -56), C.white, Enum.Material.Concrete)
        part(interior, "Ceiling", Vector3.new(32, 0.8, 38), CFrame.new(x, h, -56), C.dark, Enum.Material.Metal)
        part(interior, "Threshold", Vector3.new(32, 0.5, 4), CFrame.new(x, 1.35, -36.5), C.concrete, Enum.Material.Concrete)

        -- Two front posts preserve a shopfront frame while leaving a wide walk-in opening.
        part(interior, "FrontPostL", Vector3.new(1.3, 11, 1.3), CFrame.new(x - 15.3, 6.5, -36.8), C.dark, Enum.Material.Metal)
        part(interior, "FrontPostR", Vector3.new(1.3, 11, 1.3), CFrame.new(x + 15.3, 6.5, -36.8), C.dark, Enum.Material.Metal)

        if name == "ARCADE" then
            for row = 0, 1 do
                for col = 0, 2 do
                    cabinet(interior, Vector3.new(x - 10 + col * 10, 5.4, -49 - row * 13), (col % 2 == 0) and C.gold or C.blue)
                end
            end
            textPlate(interior, "PLAY ZONE", Vector3.new(18, 4, 0.6), CFrame.new(x, 12, -74.4), C.dark, C.gold)
        elseif name == "CAFE" then
            part(interior, "CafeCounter", Vector3.new(25, 4, 4), CFrame.new(x, 3.5, -70), C.wood, Enum.Material.Wood)
            part(interior, "CafeCounterTop", Vector3.new(26, 0.5, 5), CFrame.new(x, 5.7, -70), C.dark, Enum.Material.Slate)
            tableSet(interior, Vector3.new(x - 8, 1.5, -50))
            tableSet(interior, Vector3.new(x + 8, 1.5, -50))
            textPlate(interior, "AFTER CLASS CAFE", Vector3.new(22, 4, 0.6), CFrame.new(x, 12, -74.4), C.teal, C.white)
        elseif name == "STYLE" then
            for _, dx in ipairs({-9, 9}) do
                part(interior, "ClothingRack", Vector3.new(2, 7, 16), CFrame.new(x + dx, 5, -57), C.metal, Enum.Material.Metal)
                for z = -63, -51, 4 do
                    part(interior, "Display", Vector3.new(5, 3, 1), CFrame.new(x + dx, 5.5, z), (z % 2 == 0) and C.purple or C.gold, Enum.Material.Fabric)
                end
            end
            part(interior, "Mirror", Vector3.new(9, 12, 0.3), CFrame.new(x, 7.5, -74.4), C.glass, Enum.Material.Glass, 0.1).CanCollide = false
        elseif name == "MUSIC" then
            shelf(interior, Vector3.new(x - 10, 7, -74), 10, 10, C.charcoal)
            shelf(interior, Vector3.new(x + 10, 7, -74), 10, 10, C.charcoal)
            part(interior, "ListeningTable", Vector3.new(18, 3.5, 7), CFrame.new(x, 3.2, -54), C.wood, Enum.Material.Wood)
            for _, dx in ipairs({-6, 0, 6}) do
                local pad = part(interior, "HeadphoneStand", Vector3.new(1, 5, 1), CFrame.new(x + dx, 6.2, -54), C.metal, Enum.Material.Metal)
                pad.CanCollide = false
            end
            textPlate(interior, "LISTEN • JAM • CREATE", Vector3.new(23, 4, 0.6), CFrame.new(x, 12, -74.4), C.blue, C.white)
        elseif name == "HOBBY" then
            shelf(interior, Vector3.new(x - 10, 7, -74), 10, 10, C.charcoal)
            shelf(interior, Vector3.new(x + 10, 7, -74), 10, 10, C.charcoal)
            part(interior, "HobbyTable", Vector3.new(20, 1, 10), CFrame.new(x, 4.2, -55), C.wood, Enum.Material.Wood)
            for _, dx in ipairs({-6, 0, 6}) do
                part(interior, "ProjectBox", Vector3.new(4, 2, 4), CFrame.new(x + dx, 5.7, -55), (dx == 0 and C.gold) or C.blue, Enum.Material.SmoothPlastic)
            end
            textPlate(interior, "MAKE SOMETHING", Vector3.new(21, 4, 0.6), CFrame.new(x, 12, -74.4), C.red, C.white)
        end

        -- Warm interior strip lighting, restrained for mobile.
        for _, lx in ipairs({x - 9, x + 9}) do
            local lamp = part(interior, "CeilingLight", Vector3.new(12, 0.35, 1.2), CFrame.new(lx, h - 0.6, -57), Color3.fromRGB(255, 228, 170), Enum.Material.Neon)
            lamp.CanCollide = false
            local light = Instance.new("PointLight")
            light.Brightness = 0.6
            light.Range = 15
            light.Color = Color3.fromRGB(255, 225, 178)
            light.Shadows = false
            light.Parent = lamp
        end
    end
end

-- Downtown street-edge props make the plaza feel occupied rather than empty.
for _, x in ipairs({-105, -68, -22, 22, 68, 105}) do
    part(layer, "Bollard", Vector3.new(1, 3, 1), CFrame.new(x, 2.8, -28), C.metal, Enum.Material.Metal)
end

local vending = part(layer, "VendingMachine", Vector3.new(5, 8, 3), CFrame.new(108, 5.3, 42), C.blue, Enum.Material.Metal)
local glow = part(layer, "VendingGlow", Vector3.new(3.7, 4, 0.2), CFrame.new(108, 6, 40.4), C.gold, Enum.Material.Neon)
glow.CanCollide = false
vending:SetAttribute("ASC_Prop", "VENDING_MACHINE")

for _, pos in ipairs({Vector3.new(-92, 1.5, 55), Vector3.new(92, 1.5, 55)}) do
    local planter = part(layer, "Planter", Vector3.new(10, 2, 5), CFrame.new(pos + Vector3.new(0, 1, 0)), Color3.fromRGB(116, 104, 88), Enum.Material.Concrete)
    local bush = part(layer, "Bush", Vector3.new(8, 4, 4), CFrame.new(pos + Vector3.new(0, 3.5, 0)), Color3.fromRGB(75, 126, 78), Enum.Material.Grass)
    bush.Shape = Enum.PartType.Ball
    bush.CanCollide = false
    planter:SetAttribute("ASC_StreetProp", true)
end

downtown:SetAttribute("ASC_DowntownLifePass", "0.3")
Workspace:SetAttribute("ASC_DowntownLifePass", "0.3-city-life-pass-1")
print("[AFTER SCHOOL CITY] Downtown Life Pass v0.3 initialized")