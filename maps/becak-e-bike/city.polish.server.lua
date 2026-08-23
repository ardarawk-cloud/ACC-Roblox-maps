-- BECAK E-BIKE city polish v1.0
-- Dedicated Nusakarya visual pass: breaks up primitive/blockout silhouettes without touching gameplay collision.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BecakEBike", 30)
if not root then return end
local world = root:WaitForChild("Nusakarya", 30)
if not world then return end

local old = world:FindFirstChild("CityPolish")
if old then old:Destroy() end
local polish = Instance.new("Folder")
polish.Name = "CityPolish"
polish.Parent = world

local function visualPart(parent, name, size, cf, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    if shape then p.Shape = shape end
    p.Parent = parent
    return p
end

local function awning(parent, cf, width, color)
    local a = visualPart(parent,"Awning",Vector3.new(width,0.35,4.5),cf*CFrame.Angles(math.rad(-8),0,0),color,Enum.Material.Fabric)
    return a
end

local function facade(model)
    local body = model:FindFirstChild("Body")
    if not body or not body:IsA("BasePart") then return end
    local size, cf = body.Size, body.CFrame
    if size.X < 20 or size.Y < 14 then return end

    local detail = Instance.new("Folder")
    detail.Name = "FacadeDetail"
    detail.Parent = model

    -- Recessed dark plinth visually grounds buildings and removes toy-block appearance.
    visualPart(detail,"Plinth",Vector3.new(size.X*0.94,1.2,0.55),cf*CFrame.new(0,-size.Y/2+0.7,-size.Z/2-0.3),Color3.fromRGB(62,60,56),Enum.Material.Concrete)

    local floors = math.clamp(math.floor(size.Y/12),1,5)
    local cols = math.clamp(math.floor(size.X/13),2,8)
    local windowW = math.min(7.5,(size.X-6)/cols*0.62)
    for floor=1,floors do
        local y = -size.Y/2 + 6.5 + (floor-1)*10.5
        if y < size.Y/2-2 then
            for col=1,cols do
                local x = -size.X/2 + (col-0.5)*(size.X/cols)
                local win = visualPart(detail,"Window",Vector3.new(windowW,4.6,0.28),cf*CFrame.new(x,y,-size.Z/2-0.18),Color3.fromRGB(76,105,118),Enum.Material.Glass)
                win.Transparency = 0.22
                visualPart(detail,"WindowTop",Vector3.new(windowW+0.7,0.28,0.48),win.CFrame*CFrame.new(0,2.55,0),Color3.fromRGB(80,72,64),Enum.Material.Metal)
            end
        end
    end

    -- Entrance + canopy on public/commercial buildings and every third generic structure.
    local commercial = model.Name:find("Ruko") or model.Name=="Mall" or model.Name=="Hotel" or model.Name=="Terminal" or model.Name=="RumahSakit" or model.Name=="Sekolah" or model.Name=="Factory"
    local houseIndex = tonumber(model.Name:match("Rumah_(%d+)"))
    if commercial or (houseIndex and houseIndex%3==0) then
        visualPart(detail,"Entrance",Vector3.new(math.min(9,size.X*0.25),7,0.35),cf*CFrame.new(0,-size.Y/2+3.5,-size.Z/2-0.22),Color3.fromRGB(46,49,50),Enum.Material.Glass)
        awning(detail,cf*CFrame.new(0,-size.Y/2+8,-size.Z/2-2.0),math.min(16,size.X*0.48),Color3.fromRGB(112,75,54))
    end

    -- Roof lip softens the raw rectangular roof silhouette.
    visualPart(detail,"CorniceFront",Vector3.new(size.X+2.8,0.55,0.75),cf*CFrame.new(0,size.Y/2+0.65,-size.Z/2-0.35),Color3.fromRGB(72,70,66),Enum.Material.Concrete)
end

local buildingCount = 0
for _,obj in ipairs(world:GetChildren()) do
    if obj:IsA("Model") and obj:FindFirstChild("Body") then
        facade(obj)
        buildingCount += 1
    end
end

-- Streetscape: cylindrical trees, lamps and bollards. Visual-only so road access stays unchanged.
local streets = {
    {axis="x", fixed=-28, from=-500, to=500, step=70},
    {axis="x", fixed=28, from=-500, to=500, step=70},
    {axis="z", fixed=-28, from=-500, to=500, step=70},
    {axis="z", fixed=28, from=-500, to=500, step=70},
}
local streetCount = 0
for _,s in ipairs(streets) do
    for v=s.from,s.to,s.step do
        local x,z
        if s.axis=="x" then x,z=v,s.fixed else x,z=s.fixed,v end
        local trunk = visualPart(polish,"StreetTreeTrunk",Vector3.new(1.5,9,1.5),CFrame.new(x,4.7,z),Color3.fromRGB(104,75,48),Enum.Material.Wood,Enum.PartType.Cylinder)
        trunk.CFrame = CFrame.new(x,4.7,z)*CFrame.Angles(0,0,math.rad(90))
        visualPart(polish,"StreetTreeCrown",Vector3.new(8,8,8),CFrame.new(x,10,z),Color3.fromRGB(55,118,61),Enum.Material.Grass,Enum.PartType.Ball)
        visualPart(polish,"Bollard",Vector3.new(0.75,2.4,0.75),CFrame.new(x+5,1.35,z),Color3.fromRGB(48,52,54),Enum.Material.Metal,Enum.PartType.Cylinder)
        streetCount += 1
    end
end

world:SetAttribute("ACC_BecakCityPolish","v1.0")
world:SetAttribute("BecakAntiBlockoutFacades","ON")
world:SetAttribute("BecakCityPolishBuildingCount",buildingCount)
world:SetAttribute("BecakCityPolishStreetClusters",streetCount)
