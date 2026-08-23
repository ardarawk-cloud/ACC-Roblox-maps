-- BECAK E-BIKE city polish v1.4
-- Dedicated Nusakarya visual pass: breaks up primitive/blockout silhouettes without touching gameplay collision.
-- v1.4 adds sparse facade micro-details, corrected round-prop proportions and roadside drainage cues on top of v1.3 realism depth.

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
local storefrontPalette = {
    Color3.fromRGB(106,64,45),
    Color3.fromRGB(49,83,68),
    Color3.fromRGB(48,72,94),
    Color3.fromRGB(124,87,43),
    Color3.fromRGB(88,58,78),
}

local function nameSeed(name)
    local seed = 0
    for i=1,#name do seed += string.byte(name,i) end
    return seed
end

local realismDetailCount = 0
local organicCrownCount = 0
local lightingDetailCount = 0
local facadeMicroDetailCount = 0
local drainageDetailCount = 0
local correctedRoundPropCount = 0

local function addRoofSilhouette(detail, model, body)
    local size, cf = body.Size, body.CFrame
    local seed = nameSeed(model.Name)
    local roofColor = roofPalette[(seed % #roofPalette)+1]
    local roofY = size.Y/2 + 1.2

    if model.Name:find("Rumah_") then
        local halfX = size.X/2 + 0.8
        local depth = size.Z + 2.2
        visualWedge(detail,"RoofSlopeA",Vector3.new(halfX,4.6,depth),cf*CFrame.new(-halfX/2,roofY,-0.1)*CFrame.Angles(0,math.rad(90),0),roofColor,Enum.Material.Slate)
        visualWedge(detail,"RoofSlopeB",Vector3.new(halfX,4.6,depth),cf*CFrame.new(halfX/2,roofY,-0.1)*CFrame.Angles(0,math.rad(-90),0),roofColor,Enum.Material.Slate)
        visualPart(detail,"RoofRidge",Vector3.new(0.45,0.45,depth+0.3),cf*CFrame.new(0,roofY+2.2,-0.1),Color3.fromRGB(72,61,54),Enum.Material.Metal)
        visualPart(detail,"RoofEaveFront",Vector3.new(size.X+2.4,0.22,1.05),cf*CFrame.new(0,size.Y/2+0.35,-size.Z/2-0.65),roofColor,Enum.Material.Wood)
        visualPart(detail,"RoofEaveRear",Vector3.new(size.X+2.4,0.22,1.05),cf*CFrame.new(0,size.Y/2+0.35,size.Z/2+0.65),roofColor,Enum.Material.Wood)
        realismDetailCount += 2
    elseif model.Name:find("Ruko") then
        visualPart(detail,"ParapetFront",Vector3.new(size.X+2.2,2.2,0.55),cf*CFrame.new(0,size.Y/2+1.35,-size.Z/2-0.3),roofColor,Enum.Material.Concrete)
        local bandW = math.min(size.X*0.62,22)
        visualPart(detail,"SignBand",Vector3.new(bandW,1.8,0.28),cf*CFrame.new(0,size.Y/2-1.4,-size.Z/2-0.55),Color3.fromRGB(49,53,54),Enum.Material.Metal)
        visualPart(detail,"ParapetCap",Vector3.new(size.X+2.8,0.28,0.9),cf*CFrame.new(0,size.Y/2+2.5,-size.Z/2-0.35),Color3.fromRGB(75,70,64),Enum.Material.Concrete)
        realismDetailCount += 1
    elseif size.X >= 32 then
        local capW = math.min(size.X*0.42,24)
        local capD = math.min(size.Z*0.40,18)
        visualPart(detail,"RoofServiceCore",Vector3.new(capW,3.2,capD),cf*CFrame.new(size.X*0.16,size.Y/2+2.0,0),Color3.fromRGB(94,96,91),Enum.Material.Concrete)
        visualPart(detail,"RoofVent",Vector3.new(2.2,2.8,2.2),cf*CFrame.new(-size.X*0.22,size.Y/2+1.7,0),Color3.fromRGB(61,66,68),Enum.Material.Metal)
        local tank = visualPart(detail,"RoofWaterTank",Vector3.new(3.5,3.0,3.0),cf*CFrame.new(-size.X*0.10,size.Y/2+2.15,size.Z*0.18),Color3.fromRGB(80,87,88),Enum.Material.Metal,Enum.PartType.Cylinder)
        tank.CFrame = cf*CFrame.new(-size.X*0.10,size.Y/2+2.15,size.Z*0.18)*CFrame.Angles(0,0,math.rad(90))
        correctedRoundPropCount += 1
        realismDetailCount += 1
    end
end

local function addStorefrontIdentity(detail, model, body)
    local size, cf = body.Size, body.CFrame
    local seed = nameSeed(model.Name)
    local accent = storefrontPalette[(seed % #storefrontPalette)+1]
    local commercial = model.Name:find("Ruko") or model.Name=="Mall" or model.Name=="Hotel" or model.Name=="Terminal" or model.Name=="RumahSakit" or model.Name=="Sekolah" or model.Name=="Factory"
    if not commercial then return end

    local frontage = math.min(size.X*0.76, 28)
    local canopyWidth = math.max(10, frontage)
    local canopy = awning(detail,cf*CFrame.new(0,-size.Y/2+8.4,-size.Z/2-2.15),canopyWidth,accent)
    canopy.Name = "StorefrontCanopy"

    local bladeX = math.min(size.X/2-2.2, 11)
    visualPart(detail,"BladeSign",Vector3.new(0.5,4.8,2.8),cf*CFrame.new(bladeX,-size.Y/2+10.5,-size.Z/2-1.65),accent,Enum.Material.Metal)

    local pillarOffset = math.min(size.X*0.31, 10)
    for _,x in ipairs({-pillarOffset,pillarOffset}) do
        local col = visualPart(detail,"RoundEntryColumn",Vector3.new(8.6,1.15,1.15),cf*CFrame.new(x,-size.Y/2+4.3,-size.Z/2-0.8),Color3.fromRGB(78,75,68),Enum.Material.Concrete,Enum.PartType.Cylinder)
        col.CFrame = cf*CFrame.new(x,-size.Y/2+4.3,-size.Z/2-0.8)*CFrame.Angles(0,0,math.rad(90))
        correctedRoundPropCount += 1
    end

    local panelCount = math.clamp(math.floor(frontage/7),2,4)
    for i=1,panelCount do
        local x = -frontage/2 + (i-0.5)*(frontage/panelCount)
        local glass = visualPart(detail,"StoreGlass",Vector3.new(frontage/panelCount-0.65,5.4,0.22),cf*CFrame.new(x,-size.Y/2+4.0,-size.Z/2-0.5),Color3.fromRGB(65,103,111),Enum.Material.Glass)
        glass.Transparency = 0.28
        visualPart(detail,"StoreMullion",Vector3.new(0.18,5.7,0.32),glass.CFrame*CFrame.new((frontage/panelCount)/2,0,0),Color3.fromRGB(47,49,48),Enum.Material.Metal)
    end
end

local function addFacadeMicroRealism(detail, model, body)
    local size, cf = body.Size, body.CFrame
    local seed = nameSeed(model.Name)
    if size.X < 22 or size.Y < 15 then return end

    local side = (seed % 2 == 0) and -1 or 1
    local frontZ = -size.Z/2 - 0.58
    local x = side * math.max(3.2, math.min(size.X/2-2.0, size.X*0.34))

    local pipeH = math.clamp(size.Y*0.62, 7, 15)
    local pipe = visualPart(detail,"RainwaterPipe",Vector3.new(pipeH,0.26,0.26),cf*CFrame.new(x,-size.Y/2+pipeH/2+1.0,frontZ),Color3.fromRGB(74,76,74),Enum.Material.Metal,Enum.PartType.Cylinder)
    pipe.CFrame = cf*CFrame.new(x,-size.Y/2+pipeH/2+1.0,frontZ)*CFrame.Angles(0,0,math.rad(90))
    facadeMicroDetailCount += 1
    correctedRoundPropCount += 1

    if seed % 3 == 0 then
        local acY = math.min(size.Y/2-3.0, -size.Y/2+9.0)
        visualPart(detail,"ACCondenser",Vector3.new(3.0,2.1,0.72),cf*CFrame.new(-x*0.72,acY,frontZ-0.10),Color3.fromRGB(154,157,153),Enum.Material.Metal)
        local fan = visualPart(detail,"ACFan",Vector3.new(0.18,1.25,1.25),cf*CFrame.new(-x*0.72,acY,frontZ-0.52),Color3.fromRGB(68,72,73),Enum.Material.Metal,Enum.PartType.Cylinder)
        fan.CFrame = cf*CFrame.new(-x*0.72,acY,frontZ-0.52)*CFrame.Angles(0,math.rad(90),0)
        facadeMicroDetailCount += 2
        correctedRoundPropCount += 1
    end

    if size.Y >= 19 and seed % 2 == 1 then
        local browW = math.clamp(size.X*0.28,6,11)
        visualPart(detail,"FacadeRainBrow",Vector3.new(browW,0.24,1.15),cf*CFrame.new(-x*0.35,math.min(size.Y*0.16,4.0),frontZ-0.40),Color3.fromRGB(105,101,92),Enum.Material.Concrete)
        facadeMicroDetailCount += 1
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
    visualPart(detail,"GroundFloorMaterialBand",Vector3.new(size.X*0.90,3.0,0.34),cf*CFrame.new(0,-size.Y/2+2.0,-size.Z/2-0.36),Color3.fromRGB(111,93,74),Enum.Material.Brick)
    realismDetailCount += 1

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
                visualPart(detail,"WindowSill",Vector3.new(windowW+0.85,0.24,0.72),win.CFrame*CFrame.new(0,-2.55,-0.12),Color3.fromRGB(101,95,85),Enum.Material.Concrete)
                if floor==1 or col%2==1 then
                    visualPart(detail,"WindowRevealL",Vector3.new(0.22,5.05,0.52),win.CFrame*CFrame.new(-windowW/2-0.26,0,-0.12),Color3.fromRGB(96,90,81),Enum.Material.Concrete)
                    visualPart(detail,"WindowRevealR",Vector3.new(0.22,5.05,0.52),win.CFrame*CFrame.new(windowW/2+0.26,0,-0.12),Color3.fromRGB(96,90,81),Enum.Material.Concrete)
                    realismDetailCount += 2
                end
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
        if not commercial then
            awning(detail,cf*CFrame.new(0,-size.Y/2+8,-size.Z/2-2.0),math.min(16,size.X*0.48),Color3.fromRGB(112,75,54))
        end
        if commercial then
            local entryW = math.min(12,size.X*0.34)
            visualPart(detail,"EntryPierL",Vector3.new(0.7,8.4,0.65),cf*CFrame.new(-entryW/2,-size.Y/2+4.2,-size.Z/2-0.35),Color3.fromRGB(86,79,69),Enum.Material.Brick)
            visualPart(detail,"EntryPierR",Vector3.new(0.7,8.4,0.65),cf*CFrame.new(entryW/2,-size.Y/2+4.2,-size.Z/2-0.35),Color3.fromRGB(86,79,69),Enum.Material.Brick)
        end
    end

    visualPart(detail,"CorniceFront",Vector3.new(size.X+2.8,0.55,0.75),cf*CFrame.new(0,size.Y/2+0.65,-size.Z/2-0.35),Color3.fromRGB(72,70,66),Enum.Material.Concrete)
    addRoofSilhouette(detail,model,body)
    addStorefrontIdentity(detail,model,body)
    addFacadeMicroRealism(detail,model,body)
    return true
end

local buildingCount = 0
for _,obj in ipairs(world:GetChildren()) do
    if obj:IsA("Model") and obj:FindFirstChild("Body") and facade(obj) then buildingCount += 1 end
end

local streets = {
    {axis="x", fixed=-28, from=-500, to=500, step=70},
    {axis="x", fixed=28, from=-500, to=500, step=70},
    {axis="z", fixed=-28, from=-500, to=500, step=70},
    {axis="z", fixed=28, from=-500, to=500, step=70},
}
local streetCount = 0
local furnitureCount = 0
for laneIndex,s in ipairs(streets) do
    local sequence = 0
    for v=s.from,s.to,s.step do
        sequence += 1
        local x,z
        if s.axis=="x" then x,z=v,s.fixed else x,z=s.fixed,v end
        local height = 8.0 + ((sequence+laneIndex)%3)*1.2
        local crown = 7.0 + ((sequence*2+laneIndex)%3)
        local trunk = visualPart(polish,"StreetTreeTrunk",Vector3.new(height,1.35,1.35),CFrame.new(x,height/2+0.2,z),Color3.fromRGB(104,75,48),Enum.Material.Wood,Enum.PartType.Cylinder)
        trunk.CFrame = CFrame.new(x,height/2+0.2,z)*CFrame.Angles(0,0,math.rad(90))
        correctedRoundPropCount += 1
        visualPart(polish,"StreetTreeCrown",Vector3.new(crown,crown*0.9,crown),CFrame.new(x,height+2.4,z),Color3.fromRGB(55+(sequence%2)*8,112+(laneIndex%2)*10,58),Enum.Material.Grass,Enum.PartType.Ball)
        if sequence % 3 == 0 then
            visualPart(polish,"StreetTreeCrownSideA",Vector3.new(crown*0.62,crown*0.58,crown*0.62),CFrame.new(x-2.3,height+1.7,z+1.3),Color3.fromRGB(48,105,55),Enum.Material.Grass,Enum.PartType.Ball)
            visualPart(polish,"StreetTreeCrownSideB",Vector3.new(crown*0.58,crown*0.54,crown*0.58),CFrame.new(x+2.0,height+2.0,z-1.4),Color3.fromRGB(64,122,61),Enum.Material.Grass,Enum.PartType.Ball)
            organicCrownCount += 2
        end
        if sequence % 2 == 0 then
            visualPart(polish,"Shrub",Vector3.new(3.6,2.4,3.6),CFrame.new(x+3.2,1.2,z),Color3.fromRGB(63,126,64),Enum.Material.Grass,Enum.PartType.Ball)
        end
        local bollard = visualPart(polish,"Bollard",Vector3.new(2.4,0.75,0.75),CFrame.new(x+5,1.35,z),Color3.fromRGB(48,52,54),Enum.Material.Metal,Enum.PartType.Cylinder)
        bollard.CFrame = CFrame.new(x+5,1.35,z)*CFrame.Angles(0,0,math.rad(90))
        correctedRoundPropCount += 1

        if sequence % 3 == 0 then
            local drainX,drainZ=x,z
            if s.axis=="x" then drainZ = z + ((laneIndex%2==0) and 5.6 or -5.6) else drainX = x + ((laneIndex%2==0) and 5.6 or -5.6) end
            local drainSize = s.axis=="x" and Vector3.new(4.2,0.12,1.05) or Vector3.new(1.05,0.12,4.2)
            visualPart(polish,"StormDrain",drainSize,CFrame.new(drainX,0.12,drainZ),Color3.fromRGB(55,58,59),Enum.Material.DiamondPlate)
            drainageDetailCount += 1
        end

        if sequence % 2 == 1 then
            local lampX = x-4.5
            local pole = visualPart(polish,"LampPole",Vector3.new(8.8,0.45,0.45),CFrame.new(lampX,4.6,z),Color3.fromRGB(46,49,50),Enum.Material.Metal,Enum.PartType.Cylinder)
            pole.CFrame = CFrame.new(lampX,4.6,z)*CFrame.Angles(0,0,math.rad(90))
            local arm = visualPart(polish,"LampArm",Vector3.new(3.2,0.28,0.28),CFrame.new(lampX+1.25,8.7,z),Color3.fromRGB(46,49,50),Enum.Material.Metal,Enum.PartType.Cylinder)
            arm.CFrame = CFrame.new(lampX+1.25,8.7,z)*CFrame.Angles(0,0,math.rad(55))
            correctedRoundPropCount += 2
            visualPart(polish,"LampHead",Vector3.new(1.65,0.65,1.65),CFrame.new(lampX+2.3,9.45,z),Color3.fromRGB(212,205,170),Enum.Material.Glass,Enum.PartType.Ball)
            lightingDetailCount += 2
            local planter = visualPart(polish,"RoundPlanter",Vector3.new(1.2,3.4,3.4),CFrame.new(x+4.2,0.7,z+3.0),Color3.fromRGB(90,73,58),Enum.Material.Brick,Enum.PartType.Cylinder)
            planter.CFrame = CFrame.new(x+4.2,0.7,z+3.0)*CFrame.Angles(0,0,math.rad(90))
            correctedRoundPropCount += 1
            visualPart(polish,"PlanterCrown",Vector3.new(3.0,2.2,3.0),CFrame.new(x+4.2,1.9,z+3.0),Color3.fromRGB(55,118,61),Enum.Material.Grass,Enum.PartType.Ball)
            furnitureCount += 2
        end
        streetCount += 1
    end
end

-- Compatibility marker retained for the current dedicated builder; enhancement marker carries the visual revision.
world:SetAttribute("ACC_BecakCityPolish","v1.0")
world:SetAttribute("BecakCityPolishEnhancement","v1.4")
world:SetAttribute("BecakAntiBlockoutFacades","ON")
world:SetAttribute("BecakPitchedRoofSilhouettes","ON")
world:SetAttribute("BecakFacadeDepthPass","ON")
world:SetAttribute("BecakStorefrontIdentityPass","ON")
world:SetAttribute("BecakRoundedStreetFurniture","ON")
world:SetAttribute("BecakVariedVegetation","ON")
world:SetAttribute("BecakInsetWindowTrim","ON")
world:SetAttribute("BecakRoofEaveDetail","ON")
world:SetAttribute("BecakFacadeMaterialLayering","ON")
world:SetAttribute("BecakOrganicTreeCrownLayering","ON")
world:SetAttribute("BecakRealisticStreetLighting","ON")
world:SetAttribute("BecakFacadeMicroDetails","ON")
world:SetAttribute("BecakRoadsideDrainageDetails","ON")
world:SetAttribute("BecakCorrectedRoundPropProportions","ON")
world:SetAttribute("BecakCityPolishBuildingCount",buildingCount)
world:SetAttribute("BecakCityPolishStreetClusters",streetCount)
world:SetAttribute("BecakCityPolishFurnitureCount",furnitureCount)
world:SetAttribute("BecakCityRealismDetailCount",realismDetailCount)
world:SetAttribute("BecakCityOrganicCrownCount",organicCrownCount)
world:SetAttribute("BecakCityLightingDetailCount",lightingDetailCount)
world:SetAttribute("BecakFacadeMicroDetailCount",facadeMicroDetailCount)
world:SetAttribute("BecakDrainageDetailCount",drainageDetailCount)
world:SetAttribute("BecakCorrectedRoundPropCount",correctedRoundPropCount)
