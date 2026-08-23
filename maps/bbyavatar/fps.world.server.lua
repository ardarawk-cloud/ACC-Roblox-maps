-- BBYAVATAR FPS prototype world v0.2
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")

local function clearWorld()
    for _, child in ipairs(Workspace:GetChildren()) do
        if not child:IsA("Terrain") and not child:IsA("Camera") then
            child:Destroy()
        end
    end
end

local function part(name, size, cf, color, material, parent, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = collide ~= false
    p.CanTouch = collide ~= false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Color = color or Color3.fromRGB(90,94,100)
    p.Material = material or Enum.Material.Concrete
    p.Parent = parent or Workspace
    return p
end

local function team(name, color)
    local t = Teams:FindFirstChild(name) or Instance.new("Team")
    t.Name = name
    t.TeamColor = color
    t.AutoAssignable = false
    t.Parent = Teams
    return t
end

local function spawn(name, cf, brickColor, teamColor)
    local s = Instance.new("SpawnLocation")
    s.Name = name
    s.Size = Vector3.new(12,1,12)
    s.CFrame = cf
    s.Anchored = true
    s.Neutral = false
    s.TeamColor = teamColor
    s.BrickColor = brickColor
    s.Material = Enum.Material.Metal
    s.Transparency = 0.22
    s.Parent = Workspace
    return s
end

local function sign(name, cf, label, color, parent)
    local plate = part(name,Vector3.new(0.8,7,22),cf,Color3.fromRGB(28,31,36),Enum.Material.Metal,parent,true)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Right
    gui.LightInfluence = 0
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 28
    gui.Parent = plate
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.Text = label
    text.TextColor3 = color
    text.Font = Enum.Font.GothamBlack
    text.TextScaled = true
    text.Parent = gui
    return plate
end

local function lightStrip(name, size, cf, color, parent)
    local p = part(name,size,cf,color,Enum.Material.Neon,parent,false)
    p.CastShadow = false
    return p
end

clearWorld()
Workspace.FallenPartsDestroyHeight = -120
pcall(function() Workspace.StreamingEnabled = true end)
pcall(function() Lighting.Technology = Enum.Technology.Future end)

Lighting.Brightness = 2.15
Lighting.ClockTime = 16.6
Lighting.EnvironmentDiffuseScale = 0.58
Lighting.EnvironmentSpecularScale = 0.78
Lighting.GlobalShadows = true
Lighting.OutdoorAmbient = Color3.fromRGB(108,114,124)
Lighting.Ambient = Color3.fromRGB(53,58,67)

for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("Atmosphere") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") then
        effect:Destroy()
    end
end

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.27
atmosphere.Offset = 0.18
atmosphere.Color = Color3.fromRGB(192,199,209)
atmosphere.Decay = Color3.fromRGB(88,98,112)
atmosphere.Glare = 0.11
atmosphere.Haze = 1.15
atmosphere.Parent = Lighting

local cc = Instance.new("ColorCorrectionEffect")
cc.Brightness = -0.025
cc.Contrast = 0.105
cc.Saturation = -0.1
cc.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.22
bloom.Size = 28
bloom.Threshold = 1.1
bloom.Parent = Lighting

local rays = Instance.new("SunRaysEffect")
rays.Intensity = 0.035
rays.Spread = 0.65
rays.Parent = Lighting

local alpha = team("ALPHA",BrickColor.new("Bright blue"))
local bravo = team("BRAVO",BrickColor.new("Bright red"))

local map = Instance.new("Folder")
map.Name = "FPS_URBAN_BLOCK"
map.Parent = Workspace

local C_CONCRETE = Color3.fromRGB(72,76,82)
local C_DARK = Color3.fromRGB(41,44,49)
local C_METAL = Color3.fromRGB(78,83,90)
local C_ASPHALT = Color3.fromRGB(47,49,52)
local C_ALPHA = Color3.fromRGB(70,158,255)
local C_BRAVO = Color3.fromRGB(245,85,76)

part("Ground",Vector3.new(440,4,320),CFrame.new(0,-2,0),Color3.fromRGB(55,57,60),Enum.Material.Asphalt,map,true)

-- perimeter and skyline shell
part("NorthWall",Vector3.new(440,30,4),CFrame.new(0,13,-160),C_DARK,Enum.Material.Concrete,map,true)
part("SouthWall",Vector3.new(440,30,4),CFrame.new(0,13,160),C_DARK,Enum.Material.Concrete,map,true)
part("WestWall",Vector3.new(4,30,320),CFrame.new(-220,13,0),C_DARK,Enum.Material.Concrete,map,true)
part("EastWall",Vector3.new(4,30,320),CFrame.new(220,13,0),C_DARK,Enum.Material.Concrete,map,true)

-- roads and lane network
for _, z in ipairs({-92,0,92}) do
    part("Road_"..z,Vector3.new(430,0.5,42),CFrame.new(0,0.05,z),C_ASPHALT,Enum.Material.Asphalt,map,true)
    for x=-190,190,24 do
        part("RoadMark",Vector3.new(10,0.05,0.65),CFrame.new(x,0.34,z),Color3.fromRGB(184,184,170),Enum.Material.SmoothPlastic,map,false)
    end
end
for _, x in ipairs({-132,0,132}) do
    part("Lane_"..x,Vector3.new(42,0.55,310),CFrame.new(x,0.08,0),Color3.fromRGB(48,50,53),Enum.Material.Asphalt,map,true)
    for z=-136,136,24 do
        part("LaneMark",Vector3.new(0.65,0.05,10),CFrame.new(x,0.37,z),Color3.fromRGB(184,184,170),Enum.Material.SmoothPlastic,map,false)
    end
end

-- sidewalks around center
for _, z in ipairs({-54,54}) do
    part("WarehouseSidewalk",Vector3.new(128,0.7,7),CFrame.new(0,0.38,z),Color3.fromRGB(94,96,99),Enum.Material.Concrete,map,true)
end
for _, x in ipairs({-64,64}) do
    part("WarehouseSidewalk",Vector3.new(7,0.7,108),CFrame.new(x,0.38,0),Color3.fromRGB(94,96,99),Enum.Material.Concrete,map,true)
end

-- central warehouse: four attack lanes
part("WarehouseFloor",Vector3.new(112,1,92),CFrame.new(0,0.5,0),Color3.fromRGB(69,72,77),Enum.Material.Concrete,map,true)
local wallColor = Color3.fromRGB(80,85,92)
for _, z in ipairs({-46,46}) do
    part("WarehouseWall",Vector3.new(43,22,4),CFrame.new(-34.5,11,z),wallColor,Enum.Material.Metal,map,true)
    part("WarehouseWall",Vector3.new(43,22,4),CFrame.new(34.5,11,z),wallColor,Enum.Material.Metal,map,true)
    part("WarehouseHeader",Vector3.new(26,7,4),CFrame.new(0,18.5,z),wallColor,Enum.Material.Metal,map,true)
end
for _, x in ipairs({-56,56}) do
    part("WarehouseWall",Vector3.new(4,22,34),CFrame.new(x,11,-29),wallColor,Enum.Material.Metal,map,true)
    part("WarehouseWall",Vector3.new(4,22,34),CFrame.new(x,11,29),wallColor,Enum.Material.Metal,map,true)
    part("WarehouseHeader",Vector3.new(4,7,24),CFrame.new(x,18.5,0),wallColor,Enum.Material.Metal,map,true)
end
part("WarehouseRoofA",Vector3.new(56,1,92),CFrame.new(-28,22.5,0),Color3.fromRGB(51,55,61),Enum.Material.Metal,map,true)
part("WarehouseRoofB",Vector3.new(56,1,92),CFrame.new(28,22.5,0),Color3.fromRGB(51,55,61),Enum.Material.Metal,map,true)
lightStrip("WarehouseRoofStrip",Vector3.new(1,0.2,80),CFrame.new(0,22.0,0),Color3.fromRGB(198,208,222),map)

-- warehouse interior pillars and cover
for _, x in ipairs({-36,0,36}) do
    for _, z in ipairs({-26,26}) do
        part("WarehousePillar",Vector3.new(3,20,3),CFrame.new(x,10,z),C_METAL,Enum.Material.Metal,map,true)
    end
end
for _, data in ipairs({
    {-26,3,-12,18,6,5},{26,3,14,18,6,5},{-8,3,28,10,6,14},{10,3,-28,10,6,14}
}) do
    part("WarehouseCover",Vector3.new(data[4],data[5],data[6]),CFrame.new(data[1],data[2],data[3]),Color3.fromRGB(90,95,102),Enum.Material.Metal,map,true)
end

-- exterior cover rows
local coverPositions = {
    Vector3.new(-170,3,-112),Vector3.new(-145,3,-72),Vector3.new(-172,3,42),Vector3.new(-150,3,108),
    Vector3.new(170,3,-112),Vector3.new(145,3,-72),Vector3.new(172,3,42),Vector3.new(150,3,108),
    Vector3.new(-82,3,-108),Vector3.new(82,3,-108),Vector3.new(-84,3,108),Vector3.new(84,3,108),
    Vector3.new(-28,3,-16),Vector3.new(28,3,18),Vector3.new(-24,3,26),Vector3.new(26,3,-30),
}
for i,pos in ipairs(coverPositions) do
    local long = i%3 == 0
    part("Cover_"..i,long and Vector3.new(20,6,5) or Vector3.new(9,6,12),CFrame.new(pos),Color3.fromRGB(91,96,103),Enum.Material.Metal,map,true)
end

-- modular barricades for spawn safety and lane breaks
local function barricade(x,z,rot,color)
    local cf = CFrame.new(x,2.2,z)*CFrame.Angles(0,math.rad(rot or 0),0)
    part("Barricade",Vector3.new(12,4.4,1.4),cf,color or Color3.fromRGB(88,91,96),Enum.Material.Metal,map,true)
    lightStrip("BarricadeTrim",Vector3.new(10,0.18,1.5),cf*CFrame.new(0,1.2,0),Color3.fromRGB(150,158,169),map)
end
for _, z in ipairs({-72,-18,36,92}) do barricade(-182,z,0,C_ALPHA) end
for _, z in ipairs({-92,-36,18,72}) do barricade(182,z,0,C_BRAVO) end
for _, x in ipairs({-112,-72,72,112}) do barricade(x,-132,90,nil) end
for _, x in ipairs({-112,-72,72,112}) do barricade(x,132,90,nil) end

-- container stacks
local function container(x,y,z,rot,color)
    local c = part("Container",Vector3.new(28,8,10),CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(rot or 0),0),color,Enum.Material.Metal,map,true)
    for k=-1,1 do
        part("ContainerRib",Vector3.new(0.35,7.2,9.5),c.CFrame*CFrame.new(k*8,0,0),Color3.fromRGB(48,52,58),Enum.Material.Metal,map,false)
    end
    return c
end
container(-105,4,-62,0,Color3.fromRGB(88,105,116))
container(-105,12,-62,0,Color3.fromRGB(116,83,67))
container(108,4,64,0,Color3.fromRGB(101,108,77))
container(108,12,64,0,Color3.fromRGB(77,92,111))
container(-92,4,72,90,Color3.fromRGB(105,79,77))
container(92,4,-72,90,Color3.fromRGB(78,96,102))

-- elevated flank catwalks with rails
for _, x in ipairs({-188,188}) do
    part("Catwalk",Vector3.new(16,1,170),CFrame.new(x,14,0),Color3.fromRGB(70,74,80),Enum.Material.DiamondPlate,map,true)
    for _, railX in ipairs({x-7.4,x+7.4}) do
        part("CatwalkRail",Vector3.new(0.4,3,170),CFrame.new(railX,15.5,0),Color3.fromRGB(98,103,111),Enum.Material.Metal,map,false)
    end
    for _, z in ipairs({-76,76}) do
        part("Ramp",Vector3.new(16,1,68),CFrame.new(x,7,z)*CFrame.Angles(math.rad(z>0 and -12 or 12),0,0),Color3.fromRGB(70,74,80),Enum.Material.Metal,map,true)
    end
end

-- office blocks create occlusion and long-range lanes
for _, x in ipairs({-102,102}) do
    for _, z in ipairs({-118,118}) do
        part("Office",Vector3.new(54,18,32),CFrame.new(x,9,z),Color3.fromRGB(73,77,84),Enum.Material.Concrete,map,true)
        part("OfficeRoof",Vector3.new(58,1,36),CFrame.new(x,18.5,z),Color3.fromRGB(42,45,50),Enum.Material.Metal,map,true)
        for _, dz in ipairs({-10,0,10}) do
            lightStrip("OfficeWindow",Vector3.new(0.15,5,5),CFrame.new(x + (x<0 and 27.08 or -27.08),10,z+dz),Color3.fromRGB(125,156,177),map)
        end
    end
end

-- team spawn staging structures
part("AlphaSpawnWall",Vector3.new(7,16,104),CFrame.new(-207,8,0),Color3.fromRGB(48,62,78),Enum.Material.Concrete,map,true)
part("BravoSpawnWall",Vector3.new(7,16,104),CFrame.new(207,8,0),Color3.fromRGB(77,49,49),Enum.Material.Concrete,map,true)
lightStrip("AlphaBaseLight",Vector3.new(0.3,8,84),CFrame.new(-203.3,9,0),C_ALPHA,map)
lightStrip("BravoBaseLight",Vector3.new(0.3,8,84),CFrame.new(203.3,9,0),C_BRAVO,map)
sign("AlphaSign",CFrame.new(-210,7,-60),"ALPHA",C_ALPHA,map)
sign("BravoSign",CFrame.new(210,7,60)*CFrame.Angles(0,math.rad(180),0),"BRAVO",C_BRAVO,map)

-- utility props
for _, data in ipairs({
    {-120,-34},{-120,38},{120,-38},{120,34},{-64,-122},{64,122},{-64,122},{64,-122}
}) do
    local x,z = data[1],data[2]
    part("UtilityCrate",Vector3.new(6,4,6),CFrame.new(x,2,z),Color3.fromRGB(79,84,91),Enum.Material.Metal,map,true)
    part("UtilityCrate",Vector3.new(5.2,3.4,5.2),CFrame.new(x,5.7,z),Color3.fromRGB(88,94,102),Enum.Material.Metal,map,true)
end

-- lamps
for _, x in ipairs({-180,-60,60,180}) do
    for _, z in ipairs({-135,135}) do
        local pole = part("LampPole",Vector3.new(1,18,1),CFrame.new(x,9,z),Color3.fromRGB(38,40,45),Enum.Material.Metal,map,true)
        local lamp = Instance.new("PointLight")
        lamp.Brightness = 1.2
        lamp.Range = 34
        lamp.Shadows = true
        lamp.Color = Color3.fromRGB(219,226,235)
        lamp.Parent = pole
    end
end
for _, x in ipairs({-40,0,40}) do
    local fixture = lightStrip("WarehouseLight",Vector3.new(12,0.25,1),CFrame.new(x,20.5,0),Color3.fromRGB(215,223,235),map)
    local lamp = Instance.new("PointLight")
    lamp.Brightness = 0.9
    lamp.Range = 28
    lamp.Shadows = true
    lamp.Parent = fixture
end

spawn("AlphaSpawn1",CFrame.new(-194,1.2,-45),BrickColor.new("Bright blue"),alpha.TeamColor)
spawn("AlphaSpawn2",CFrame.new(-194,1.2,45),BrickColor.new("Bright blue"),alpha.TeamColor)
spawn("BravoSpawn1",CFrame.new(194,1.2,-45),BrickColor.new("Bright red"),bravo.TeamColor)
spawn("BravoSpawn2",CFrame.new(194,1.2,45),BrickColor.new("Bright red"),bravo.TeamColor)

local marker = Instance.new("StringValue")
marker.Name = "BBYAVATAR_FPS_BUILD"
marker.Value = "FPS-PROTOTYPE-0.2"
marker.Parent = Workspace

print("[BBYAVATAR FPS] Urban Block world v0.2 ready")
