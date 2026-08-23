-- BECAK E-BIKE district polish v1.0
-- Lightweight visual pass to reduce repeated box/blockout appearance across Nusakarya.
-- All generated geometry is visual-only and never participates in vehicle collision/query/touch.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BecakEBike",30)
if not root then return end
local world = root:WaitForChild("Nusakarya",30)
if not world then return end

local old = world:FindFirstChild("CityDistrictPolish")
if old then old:Destroy() end
local polish = Instance.new("Folder")
polish.Name = "CityDistrictPolish"
polish.Parent = world

local function setup(p,color,material)
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=true
    p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    return p
end

local function part(parent,name,size,cf,color,material)
    local p=setup(Instance.new("Part"),color,material)
    p.Name=name p.Size=size p.CFrame=cf p.Parent=parent
    return p
end

local function wedge(parent,name,size,cf,color,material)
    local p=setup(Instance.new("WedgePart"),color,material)
    p.Name=name p.Size=size p.CFrame=cf p.Parent=parent
    return p
end

local function cylinder(parent,name,size,cf,color,material)
    local p=part(parent,name,size,cf,color,material)
    p.Shape=Enum.PartType.Cylinder
    p.CFrame=cf*CFrame.Angles(0,0,math.rad(90))
    return p
end

local function sphere(parent,name,size,cf,color,material)
    local p=part(parent,name,size,cf,color,material)
    p.Shape=Enum.PartType.Ball
    return p
end

local palettes={
    Pasar={accent=Color3.fromRGB(151,91,49),wall=Color3.fromRGB(184,151,111),roof=Color3.fromRGB(108,60,42)},
    Pusat={accent=Color3.fromRGB(47,86,79),wall=Color3.fromRGB(154,162,151),roof=Color3.fromRGB(54,64,67)},
    Terminal={accent=Color3.fromRGB(73,85,103),wall=Color3.fromRGB(157,151,139),roof=Color3.fromRGB(58,61,69)},
    Pantai={accent=Color3.fromRGB(55,111,119),wall=Color3.fromRGB(190,176,144),roof=Color3.fromRGB(72,95,91)},
}

local function districtFor(pos)
    if pos.X < -90 then return "Pasar" end
    if pos.X > 170 then return "Terminal" end
    if pos.Z > 90 then return "Pantai" end
    return "Pusat"
end

local buildingCount=0
local wedgeCount=0
local balconyCount=0
local materialBandCount=0
local streetNodeCount=0

local function decorate(model,body)
    local size,cf=body.Size,body.CFrame
    if size.X<18 or size.Y<13 or size.Z<12 then return end
    local district=districtFor(cf.Position)
    local pal=palettes[district]
    local f=Instance.new("Folder")
    f.Name="DistrictDepthV10"
    f.Parent=model

    local front=-size.Z/2-0.62
    local groundY=-size.Y/2

    -- Material/color bands stop large facades reading as one flat rectangular slab.
    local bandH=math.clamp(size.Y*0.12,1.4,3.2)
    part(f,"DistrictBaseBand",Vector3.new(size.X*0.9,bandH,0.38),cf*CFrame.new(0,groundY+bandH/2+0.4,front),pal.wall,Enum.Material.Brick)
    part(f,"DistrictMidBand",Vector3.new(size.X*0.72,0.5,0.55),cf*CFrame.new(0,math.min(3.5,size.Y*0.2),front-0.05),pal.accent,Enum.Material.Metal)
    materialBandCount+=2

    -- Paired wedge roof brows create actual diagonal silhouettes without costly meshes.
    if size.X>=24 and size.Y>=16 then
        local browW=math.min(size.X*0.28,12)
        local y=size.Y/2+1.45
        local xoff=math.min(size.X*0.2,9)
        wedge(f,"RoofBrowL",Vector3.new(browW,2.6,4.6),cf*CFrame.new(-xoff,y,-size.Z*0.08)*CFrame.Angles(0,math.rad(180),0),pal.roof,Enum.Material.Slate)
        wedge(f,"RoofBrowR",Vector3.new(browW,2.6,4.6),cf*CFrame.new(xoff,y,-size.Z*0.08),pal.roof,Enum.Material.Slate)
        wedgeCount+=2
    end

    -- Rounded balcony rhythm: thin slab + cylindrical rails, sparse enough for mobile.
    if size.X>=28 and size.Y>=20 then
        local balconyY=math.min(size.Y*0.18,5.5)
        local balconyW=math.min(size.X*0.38,15)
        part(f,"BalconySlab",Vector3.new(balconyW,0.35,2.25),cf*CFrame.new(0,balconyY,front-1.15),pal.wall,Enum.Material.Concrete)
        for _,x in ipairs({-balconyW/2,0,balconyW/2}) do
            cylinder(f,"BalconyRail",Vector3.new(0.28,3.0,0.28),cf*CFrame.new(x,balconyY+1.45,front-2.15),pal.accent,Enum.Material.Metal)
        end
        balconyCount+=1
    end

    -- Small circular corner cap softens hard 90-degree corners at street level.
    local side=(math.floor(math.abs(cf.Position.X+cf.Position.Z))%2==0) and 1 or -1
    local cx=side*(size.X/2-1.4)
    cylinder(f,"CornerPlinth",Vector3.new(2.8,0.65,2.8),cf*CFrame.new(cx,groundY+0.45,front-0.6),pal.accent,Enum.Material.Brick)
    sphere(f,"CornerShrub",Vector3.new(2.15,2.0,2.15),cf*CFrame.new(cx,groundY+1.65,front-0.6),Color3.fromRGB(58,116,63),Enum.Material.Grass)

    buildingCount+=1
end

for _,obj in ipairs(world:GetChildren()) do
    if obj:IsA("Model") then
        local body=obj:FindFirstChild("Body")
        if body and body:IsA("BasePart") then decorate(obj,body) end
    end
end

-- Sparse angled street nodes add diagonals and circular forms along long straight corridors.
local nodes={
    {Vector3.new(-235,0,-34),"Pasar",-18},
    {Vector3.new(-115,0,34),"Pasar",18},
    {Vector3.new(115,0,-34),"Pusat",-18},
    {Vector3.new(235,0,34),"Terminal",18},
}
for i,data in ipairs(nodes) do
    local pos,district,angle=data[1],data[2],data[3]
    local pal=palettes[district]
    local f=Instance.new("Folder") f.Name="DistrictStreetNode_"..i f.Parent=polish
    cylinder(f,"NodeBase",Vector3.new(4.8,0.5,4.8),CFrame.new(pos+Vector3.new(0,0.3,0)),pal.wall,Enum.Material.Cobblestone)
    local mast=cylinder(f,"AngledMast",Vector3.new(0.34,7.2,0.34),CFrame.new(pos+Vector3.new(0,4,0)),pal.roof,Enum.Material.Metal)
    mast.CFrame=mast.CFrame*CFrame.Angles(0,0,math.rad(angle))
    sphere(f,"NodeLamp",Vector3.new(1.2,1.0,1.2),CFrame.new(pos+Vector3.new(math.sin(math.rad(angle))*1.5,7.4,0)),Color3.fromRGB(225,210,168),Enum.Material.Glass)
    streetNodeCount+=1
end

world:SetAttribute("ACC_BecakCityDistrictPolish","v1.0")
world:SetAttribute("BecakDistrictMaterialDepth","ON")
world:SetAttribute("BecakDiagonalRoofSilhouettes","ON")
world:SetAttribute("BecakRoundedBalconyRhythm","ON")
world:SetAttribute("BecakDistrictStreetNodes","ON")
world:SetAttribute("BecakDistrictPolishBuildingCount",buildingCount)
world:SetAttribute("BecakDistrictPolishWedgeCount",wedgeCount)
world:SetAttribute("BecakDistrictPolishBalconyCount",balconyCount)
world:SetAttribute("BecakDistrictMaterialBandCount",materialBandCount)
world:SetAttribute("BecakDistrictStreetNodeCount",streetNodeCount)
