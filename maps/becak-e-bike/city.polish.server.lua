-- BECAK E-BIKE city polish v1.1
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

local function visualWedge(parent, name, size, cf, color, material)
    local p = Instance.new("WedgePart")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.Color = color
    p.Material = material or Enum.Material.Slate
    p.Parent = parent
    return p
end

local function awning(parent, cf, width, color)
    return visualPart(parent,"Awning",Vector3.new(width,0.35,4.5),cf*CFrame.Angles(math.rad(-8),0,0),color,Enum.Material.Fabric)
end

local roofPalette = {
    Color3.fromRGB(112,72,51),
    Color3.fromRGB(88,76,66),
    Color3.fromRGB(93,55,46),
    Color3.fromRGB(70,78,73),
}

local function addRoofSilhouette(detail, model, body)
    local size, cf = body.Size, body.CFrame
    local seed = 0
    for i=1,#model.Name do seed += string.byte(model.Name,i) end
    local roofColor = roofPalette[(seed % #roofPalette)+1]
    local roofY = size.Y/2 + 1.2

    if model.Name:find("Rumah_") then
        -- Two opposed wedges create a readable pitched roof silhouette instead of another flat box.
        local halfX = size.X/2 + 0.8
        local depth = size.Z + 2.2
        visualWedge(detail,"RoofSlopeA",Vector3.new(halfX,4.6,depth),cf*CFrame.new(-halfX/2,roofY,-0.1)*CFrame.Angles(0,math.rad(90),0),roofColor,Enum.Material.Slate)
        visualWedge(detail,"RoofSlopeB",Vector3.new(halfX,4.6,depth),cf*CFrame.new(halfX/2,roofY,-0.1)*CFrame.Angles(0,math.rad(-90),0),roofColor,Enum.Material.Slate)
        visualPart(detail,"RoofRidge",Vector3.new(0.45,0.45,depth+0.3),cf*CFrame.new(0,roofY+2.2,-0.1),Color3.fromRGB(72,61,54),Enum.Material.Metal)
    elseif model.Name:find("Ruko") then
        -- Commercial parapet + stepped sign band adds depth while keeping the original roof lightweight.
        visualPart(detail,"ParapetFront",Vector3.new(size.X+2.2,2.2,0.55),cf*CFrame.new(0,size.Y/2+1.35,-size.Z/2-0.3),roofColor,Enum.Material.Concrete)
        local bandW = math.min(size.X*0.62,22)
        visualPart(detail,"SignBand",Vector3.new(bandW,1.8,0.28),cf*CFrame.new(0,size.Y/2-1.4,-size.Z/2-0.55),Color3.fromRGB(49,53,54),Enum.Material.Metal)
    else
        -- Large civic/commercial blocks get rooftop masses at different heights to break the single cuboid silhouette.
        if size.X >= 32 then
            local capW = math.min(size.X*0.42,24)
            local capD = math.min(size.Z*0.40,18)
            visualPart(detail,"RoofServiceCore",Vector3.new(capW,3.2,capD),cf*CFrame.new(size.X*0.16,size.Y/2+2.0,0),Color3.fromRGB(94,96,91),Enum.Material.Concrete)
            visualPart(detail,"RoofVent",Vector3.new(2.2,2.8,2.2),cf*CFrame.new(-size.X*0.22,size.Y/2+1.7,0),Color3.fromRGB(61,66,68),Enum.Material.Metal)
        end
    end
end

local function facade(model)
    local body = model:FindFirstChild("Body")
    if not body or not body:IsA("BasePart") then return false end
    local size, cf = body.Size, body.CFrame
    if size.X < 20 or size.Y < 14 then return false end

    local previous = model:FindFirstChild("FacadeDetail")
    if previous then previous:Destroy() end
    local detail = Instance.new("Folder")
    detail.Name = "FacadeDetail"
    detail.Parent = model

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
                if floor > 1 and col % 2 == 0 and size.X >= 28 then
                    visualPart(detail,"BalconySlab",Vector3.new(windowW+1.8,0.35,2.2),win.CFrame*CFrame.new(0,-2.7,-1.0),Color3.fromRGB(98,96,88),Enum.Material.Concrete)
                    visualPart(detail,"BalconyRail",Vector3.new(windowW+1.5,1.0,0.18),win.CFrame*CFrame.new(0,-2.1,-2.0),Color3.fromRGB(55,59,60),Enum.Material.Metal)
                end
            end
        end
    end

    local commercial = model.Name:find("Ruko") or model.Name=="Mall" or model.Name=="Hotel" or model.Name=="Terminal" or model.Name=="RumahSakit" or model.Name=="Sekolah" or model.Name=="Factory"
    local houseIndex = tonumber(model.Name:match("Rumah_(%d+)"))
    if commercial or (houseIndex and houseIndex%3==0) then
        visualPart(detail,"Entrance",Vector3.new(math.min(9,size.X*0.25),7,0.35),cf*CFrame.new(0,-size.Y/2+3.5,-size.Z/2-0.22),Color3.fromRGB(46,49,50),Enum.Material.Glass)
        awning(detail,cf*CFrame.new(0,-size.Y/2+8,-size.Z/2-2.0),math.min(16,size.X*0.48),Color3.fromRGB(112,75,54))
        if commercial then
            -- Side pilasters make storefronts read as framed architecture rather than painted rectangles.
            local entryW = math.min(12,size.X*0.34)
            visualPart(detail,"EntryPierL",Vector3.new(0.7,8.4,0.65),cf*CFrame.new(-entryW/2,-size.Y/2+4.2,-size.Z/2-0.35),Color3.fromRGB(86,79,69),Enum.Material.Brick)
            visualPart(detail,"EntryPierR",Vector3.new(0.7,8.4,0.65),cf*CFrame.new(entryW/2,-size.Y/2+4.2,-size.Z/2-0.35),Color3.fromRGB(86,79,69),Enum.Material.Brick)
        end
    end

    visualPart(detail,"CorniceFront",Vector3.new(size.X+2.8,0.55,0.75),cf*CFrame.new(0,size.Y/2+0.65,-size.Z/2-0.35),Color3.fromRGB(72,70,66),Enum.Material.Concrete)
    addRoofSilhouette(detail,model,body)
    return true
end

local buildingCount = 0
for _,obj in ipairs(world:GetChildren()) do
    if obj:IsA("Model") and obj:FindFirstChild("Body") and facade(obj) then
        buildingCount += 1
    end
end

-- Streetscape: varied rounded vegetation + cylindrical street furniture. Visual-only so road access stays unchanged.
local streets = {
    {axis="x", fixed=-28, from=-500, to=500, step=70},
    {axis="x", fixed=28, from=-500, to=500, step=70},
    {axis="z", fixed=-28, from=-500, to=500, step=70},
    {axis="z", fixed=28, from=-500, to=500, step=70},
}
local streetCount = 0
for laneIndex,s in ipairs(streets) do
    local sequence = 0
    for v=s.from,s.to,s.step do
        sequence += 1
        local x,z
        if s.axis=="x" then x,z=v,s.fixed else x,z=s.fixed,v end
        local height = 8.0 + ((sequence+laneIndex)%3)*1.2
        local crown = 7.0 + ((sequence*2+laneIndex)%3)
        local trunk = visualPart(polish,"StreetTreeTrunk",Vector3.new(1.35,height,1.35),CFrame.new(x,height/2+0.2,z),Color3.fromRGB(104,75,48),Enum.Material.Wood,Enum.PartType.Cylinder)
        trunk.CFrame = CFrame.new(x,height/2+0.2,z)*CFrame.Angles(0,0,math.rad(90))
        visualPart(polish,"StreetTreeCrown",Vector3.new(crown,crown*0.9,crown),CFrame.new(x,height+2.4,z),Color3.fromRGB(55+(sequence%2)*8,112+(laneIndex%2)*10,58),Enum.Material.Grass,Enum.PartType.Ball)
        if sequence % 2 == 0 then
            visualPart(polish,"Shrub",Vector3.new(3.6,2.4,3.6),CFrame.new(x+3.2,1.2,z),Color3.fromRGB(63,126,64),Enum.Material.Grass,Enum.PartType.Ball)
        end
        visualPart(polish,"Bollard",Vector3.new(0.75,2.4,0.75),CFrame.new(x+5,1.35,z),Color3.fromRGB(48,52,54),Enum.Material.Metal,Enum.PartType.Cylinder)
        streetCount += 1
    end
end

world:SetAttribute("ACC_BecakCityPolish","v1.1")
world:SetAttribute("BecakAntiBlockoutFacades","ON")
world:SetAttribute("BecakPitchedRoofSilhouettes","ON")
world:SetAttribute("BecakFacadeDepthPass","ON")
world:SetAttribute("BecakVariedVegetation","ON")
world:SetAttribute("BecakCityPolishBuildingCount",buildingCount)
world:SetAttribute("BecakCityPolishStreetClusters",streetCount)
