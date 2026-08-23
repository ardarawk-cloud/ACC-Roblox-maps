-- BECAK E-BIKE city organic polish v1.3
-- Secondary Nusakarya visual pass: breaks box silhouettes with side depth, rounded accents and district landmarks.
-- Visual-only: no gameplay collision, touch or query surfaces are introduced.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BecakEBike", 30)
if not root then return end
local world = root:WaitForChild("Nusakarya", 30)
if not world then return end

local old = world:FindFirstChild("CityOrganicPolish")
if old then old:Destroy() end
local polish = Instance.new("Folder")
polish.Name = "CityOrganicPolish"
polish.Parent = world

local function part(parent,name,size,cf,color,material,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=true
    p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    if shape then p.Shape=shape end
    p.Parent=parent
    return p
end

local function sphere(parent,name,size,cf,color,material)
    return part(parent,name,size,cf,color,material or Enum.Material.SmoothPlastic,Enum.PartType.Ball)
end

local function cylinder(parent,name,size,cf,color,material)
    local p=part(parent,name,size,cf,color,material or Enum.Material.Concrete,Enum.PartType.Cylinder)
    p.CFrame=cf*CFrame.Angles(0,0,math.rad(90))
    return p
end

local function seedOf(name)
    local n=0
    for i=1,#name do n=(n*33+string.byte(name,i))%9973 end
    return n
end

local accentPalette={
    Color3.fromRGB(126,84,54),
    Color3.fromRGB(59,91,78),
    Color3.fromRGB(61,78,103),
    Color3.fromRGB(132,105,57),
    Color3.fromRGB(98,67,75),
}

local organicCount=0
local sideFacadeCount=0
local landmarkCount=0
local marketCount=0

local function sideFacade(model,body)
    local size,cf=body.Size,body.CFrame
    if size.Y<16 or size.Z<14 then return end
    local folder=Instance.new("Folder")
    folder.Name="OrganicSideFacade"
    folder.Parent=model
    local seed=seedOf(model.Name)
    local accent=accentPalette[(seed%#accentPalette)+1]
    local rows=math.clamp(math.floor(size.Y/13),1,4)
    local bays=math.clamp(math.floor(size.Z/14),1,4)
    local side=(seed%2==0) and 1 or -1
    local x=side*(size.X/2+0.24)
    for row=1,rows do
        local y=-size.Y/2+6.3+(row-1)*10.5
        if y<size.Y/2-1.8 then
            for bay=1,bays do
                local z=-size.Z/2+(bay-0.5)*(size.Z/bays)
                local win=part(folder,"SideWindow",Vector3.new(0.24,4.2,math.min(6.2,size.Z/bays*0.58)),cf*CFrame.new(x,y,z),Color3.fromRGB(70,104,113),Enum.Material.Glass)
                win.Transparency=0.25
                part(folder,"SideWindowCap",Vector3.new(0.42,0.35,math.min(7.0,size.Z/bays*0.68)),cf*CFrame.new(x+side*0.08,y+2.35,z),accent,Enum.Material.Metal)
            end
        end
    end
    local ribCount=math.clamp(math.floor(size.Z/18),1,3)
    for i=1,ribCount do
        local z=-size.Z/2+i*(size.Z/(ribCount+1))
        part(folder,"SidePilaster",Vector3.new(0.55,size.Y*0.78,0.65),cf*CFrame.new(x+side*0.13,0,z),Color3.fromRGB(91,84,72),Enum.Material.Brick)
    end
    sideFacadeCount+=1
    organicCount+=rows*bays+ribCount
end

local function roundedCorner(model,body)
    local size,cf=body.Size,body.CFrame
    if size.X<32 or size.Y<20 then return end
    local seed=seedOf(model.Name)
    if seed%3~=0 and model.Name~="Mall" and model.Name~="Hotel" then return end
    local folder=Instance.new("Folder")
    folder.Name="RoundedCornerAccent"
    folder.Parent=model
    local side=(seed%2==0) and 1 or -1
    local frontZ=-size.Z/2-0.55
    local x=side*(size.X/2-2.4)
    local towerH=math.min(size.Y*0.72,24)
    cylinder(folder,"CornerTower",Vector3.new(4.8,towerH,4.8),cf*CFrame.new(x,-size.Y/2+towerH/2+1.1,frontZ),Color3.fromRGB(105,96,82),Enum.Material.Concrete)
    sphere(folder,"CornerDome",Vector3.new(5.2,3.1,5.2),cf*CFrame.new(x,-size.Y/2+towerH+1.6,frontZ),Color3.fromRGB(76,83,78),Enum.Material.Metal)
    local ringY=-size.Y/2+towerH*0.56
    cylinder(folder,"TowerRing",Vector3.new(5.15,0.45,5.15),cf*CFrame.new(x,ringY,frontZ),Color3.fromRGB(61,61,58),Enum.Material.Metal)
    organicCount+=3
end

local function rooftopVariation(model,body)
    local size,cf=body.Size,body.CFrame
    if size.X<28 or size.Y<18 then return end
    local seed=seedOf(model.Name)
    local folder=Instance.new("Folder")
    folder.Name="OrganicRoofDetail"
    folder.Parent=model
    if seed%2==0 then
        local tank=cylinder(folder,"RoofWaterTank",Vector3.new(4.2,3.8,4.2),cf*CFrame.new(-size.X*0.18,size.Y/2+2.3,size.Z*0.12),Color3.fromRGB(54,63,65),Enum.Material.Metal)
        tank.Transparency=0.02
        cylinder(folder,"TankCap",Vector3.new(4.45,0.35,4.45),cf*CFrame.new(-size.X*0.18,size.Y/2+4.25,size.Z*0.12),Color3.fromRGB(40,45,47),Enum.Material.Metal)
        organicCount+=2
    else
        part(folder,"PergolaTop",Vector3.new(math.min(12,size.X*0.32),0.35,math.min(9,size.Z*0.32)),cf*CFrame.new(size.X*0.16,size.Y/2+3.0,0),Color3.fromRGB(102,79,57),Enum.Material.Wood)
        for _,dx in ipairs({-1,1}) do
            for _,dz in ipairs({-1,1}) do
                cylinder(folder,"PergolaPost",Vector3.new(0.45,5.4,0.45),cf*CFrame.new(size.X*0.16+dx*4.2,size.Y/2+0.4,dz*3.0),Color3.fromRGB(92,72,55),Enum.Material.Wood)
            end
        end
        organicCount+=5
    end
end

for _,obj in ipairs(world:GetChildren()) do
    if obj:IsA("Model") then
        local body=obj:FindFirstChild("Body")
        if body and body:IsA("BasePart") then
            sideFacade(obj,body)
            roundedCorner(obj,body)
            rooftopVariation(obj,body)
        end
    end
end

-- Sparse district anchors: visual-only circular forms to break the repeated rectangular street rhythm.
local anchors={
    {name="PasarPocketPlaza",pos=Vector3.new(-145,0,95),accent=Color3.fromRGB(147,92,55)},
    {name="PusatKotaPocketPlaza",pos=Vector3.new(145,0,-95),accent=Color3.fromRGB(53,91,78)},
}
for _,a in ipairs(anchors) do
    local f=Instance.new("Folder")
    f.Name=a.name
    f.Parent=polish
    cylinder(f,"PlazaRing",Vector3.new(12,0.55,12),CFrame.new(a.pos+Vector3.new(0,0.35,0)),Color3.fromRGB(114,105,91),Enum.Material.Cobblestone)
    cylinder(f,"PlanterBowl",Vector3.new(6.8,1.25,6.8),CFrame.new(a.pos+Vector3.new(0,0.75,0)),a.accent,Enum.Material.Brick)
    sphere(f,"PlanterGreen",Vector3.new(5.8,3.6,5.8),CFrame.new(a.pos+Vector3.new(0,2.3,0)),Color3.fromRGB(57,121,62),Enum.Material.Grass)
    local pole=cylinder(f,"DistrictPole",Vector3.new(0.55,9.5,0.55),CFrame.new(a.pos+Vector3.new(0,5.3,0)),Color3.fromRGB(48,51,52),Enum.Material.Metal)
    sphere(f,"DistrictLamp",Vector3.new(1.9,1.2,1.9),CFrame.new(a.pos+Vector3.new(0,10.1,0)),Color3.fromRGB(224,210,166),Enum.Material.Glass)
    landmarkCount+=1
    organicCount+=5
end

-- Lightweight market clusters use cylinders/umbrellas rather than box stalls.
local marketSpots={Vector3.new(-205,0,145),Vector3.new(-175,0,145),Vector3.new(185,0,-145)}
for i,pos in ipairs(marketSpots) do
    local f=Instance.new("Folder")
    f.Name="OrganicMarketCluster_"..i
    f.Parent=polish
    local pole=cylinder(f,"UmbrellaPole",Vector3.new(0.35,5.5,0.35),CFrame.new(pos+Vector3.new(0,3,0)),Color3.fromRGB(72,62,53),Enum.Material.Wood)
    local canopy=cylinder(f,"UmbrellaCanopy",Vector3.new(7.2,0.45,7.2),CFrame.new(pos+Vector3.new(0,5.9,0)),accentPalette[(i%#accentPalette)+1],Enum.Material.Fabric)
    canopy.CFrame=canopy.CFrame*CFrame.Angles(0,math.rad(i*17),0)
    cylinder(f,"ProduceBasket",Vector3.new(2.2,1.1,2.2),CFrame.new(pos+Vector3.new(2.8,0.7,1.2)),Color3.fromRGB(123,91,55),Enum.Material.Wood)
    sphere(f,"ProducePile",Vector3.new(1.8,1.3,1.8),CFrame.new(pos+Vector3.new(2.8,1.5,1.2)),Color3.fromRGB(133,76+20*i,49),Enum.Material.SmoothPlastic)
    marketCount+=1
    organicCount+=4
end

world:SetAttribute("ACC_BecakCityOrganicPolish","v1.3")
world:SetAttribute("BecakSideFacadeDepth","ON")
world:SetAttribute("BecakRoundedCornerArchitecture","ON")
world:SetAttribute("BecakOrganicRoofVariation","ON")
world:SetAttribute("BecakDistrictPocketLandmarks","ON")
world:SetAttribute("BecakOrganicMarketClusters","ON")
world:SetAttribute("BecakOrganicPolishPartCount",organicCount)
world:SetAttribute("BecakOrganicSideFacadeCount",sideFacadeCount)
world:SetAttribute("BecakOrganicLandmarkCount",landmarkCount)
world:SetAttribute("BecakOrganicMarketCount",marketCount)
