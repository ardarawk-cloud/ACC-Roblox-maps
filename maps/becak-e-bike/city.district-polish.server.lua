-- BECAK E-BIKE district polish v1.2
-- Lightweight visual pass to reduce repeated box/blockout appearance across Nusakarya.
-- v1.2 adds arches, corner towers, gable crowns and side bays while preserving the v1.1 build marker.
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
    Pasar={accent=Color3.fromRGB(151,91,49),wall=Color3.fromRGB(184,151,111),roof=Color3.fromRGB(108,60,42),glass=Color3.fromRGB(90,118,118),awning=Color3.fromRGB(151,74,48)},
    Pusat={accent=Color3.fromRGB(47,86,79),wall=Color3.fromRGB(154,162,151),roof=Color3.fromRGB(54,64,67),glass=Color3.fromRGB(89,123,137),awning=Color3.fromRGB(45,100,84)},
    Terminal={accent=Color3.fromRGB(73,85,103),wall=Color3.fromRGB(157,151,139),roof=Color3.fromRGB(58,61,69),glass=Color3.fromRGB(89,108,127),awning=Color3.fromRGB(88,96,110)},
    Pantai={accent=Color3.fromRGB(55,111,119),wall=Color3.fromRGB(190,176,144),roof=Color3.fromRGB(72,95,91),glass=Color3.fromRGB(85,143,154),awning=Color3.fromRGB(67,133,139)},
}

local function districtFor(pos)
    if pos.X < -90 then return "Pasar" end
    if pos.X > 170 then return "Terminal" end
    if pos.Z > 90 then return "Pantai" end
    return "Pusat"
end

local function stableVariant(pos,modulo)
    local v=math.floor(math.abs(pos.X*0.73+pos.Z*1.17))
    return (v%modulo)+1
end

local buildingCount=0
local wedgeCount=0
local balconyCount=0
local materialBandCount=0
local streetNodeCount=0
local storefrontCount=0
local roofVariantCount=0
local recessFrameCount=0
local verticalFinCount=0
local archCount=0
local cornerTowerCount=0
local gableCount=0
local sideBayCount=0

local function addStorefront(f,cf,size,front,pal,district,variant)
    if size.X<20 or size.Y<14 then return end
    local groundY=-size.Y/2
    local width=math.clamp(size.X*0.62,11,24)
    local glassH=math.clamp(size.Y*0.2,3.2,5.5)
    local glassY=groundY+glassH/2+0.75
    local glass=part(f,"StorefrontGlass",Vector3.new(width,glassH,0.18),cf*CFrame.new(0,glassY,front-0.42),pal.glass,Enum.Material.Glass)
    glass.Transparency=0.28

    local mullions=variant==1 and 3 or (variant==2 and 4 or 2)
    for i=1,mullions-1 do
        local x=-width/2+(width/mullions)*i
        part(f,"StorefrontMullion",Vector3.new(0.16,glassH+0.35,0.22),cf*CFrame.new(x,glassY,front-0.53),pal.accent,Enum.Material.Metal)
    end

    local awningDepth=district=="Pasar" and 2.2 or (district=="Pantai" and 2.6 or 1.8)
    local awning=part(f,"StorefrontAwning",Vector3.new(width+1.1,0.28,awningDepth),cf*CFrame.new(0,groundY+glassH+1.35,front-awningDepth/2),pal.awning,Enum.Material.Fabric)
    awning.CFrame=awning.CFrame*CFrame.Angles(math.rad(-7),0,0)

    local doorW=math.clamp(width*0.22,2.8,4.4)
    local doorX=(variant==3 and width*0.25) or (variant==2 and -width*0.23) or 0
    local frameH=glassH+0.6
    part(f,"EntryFrameL",Vector3.new(0.28,frameH,0.75),cf*CFrame.new(doorX-doorW/2,glassY,front-0.6),pal.accent,Enum.Material.Brick)
    part(f,"EntryFrameR",Vector3.new(0.28,frameH,0.75),cf*CFrame.new(doorX+doorW/2,glassY,front-0.6),pal.accent,Enum.Material.Brick)
    part(f,"EntryFrameTop",Vector3.new(doorW+0.28,0.28,0.75),cf*CFrame.new(doorX,glassY+frameH/2,front-0.6),pal.accent,Enum.Material.Brick)
    recessFrameCount+=1

    if district=="Pasar" or district=="Pusat" then
        local signX=(variant%2==0) and -width/2-0.8 or width/2+0.8
        local post=cylinder(f,"BladeSignPost",Vector3.new(0.16,1.8,0.16),cf*CFrame.new(signX,groundY+glassH+2.1,front-1.1),pal.accent,Enum.Material.Metal)
        post.CFrame=post.CFrame*CFrame.Angles(0,math.rad(90),0)
        part(f,"BladeSign",Vector3.new(1.6,1.05,0.14),cf*CFrame.new(signX,groundY+glassH+2.1,front-1.9)*CFrame.Angles(0,math.rad(90),0),pal.awning,Enum.Material.SmoothPlastic)
    end
    storefrontCount+=1
end

local function addRoofVariation(f,cf,size,pal,variant)
    if size.X<22 or size.Y<15 then return end
    local roofY=size.Y/2
    if variant==1 then
        local w=math.min(size.X*0.34,14)
        wedge(f,"RoofVariantA_L",Vector3.new(w,3.0,5.4),cf*CFrame.new(-size.X*0.17,roofY+1.6,0)*CFrame.Angles(0,math.rad(180),0),pal.roof,Enum.Material.Slate)
        wedge(f,"RoofVariantA_R",Vector3.new(w,3.0,5.4),cf*CFrame.new(size.X*0.17,roofY+1.6,0),pal.roof,Enum.Material.Slate)
        wedgeCount+=2
    elseif variant==2 then
        cylinder(f,"RoofDrum",Vector3.new(5.0,1.3,5.0),cf*CFrame.new(size.X*0.18,roofY+1.0,0),pal.wall,Enum.Material.Concrete)
        sphere(f,"RoofCap",Vector3.new(4.7,2.4,4.7),cf*CFrame.new(size.X*0.18,roofY+2.4,0),pal.roof,Enum.Material.Slate)
    else
        local px=-math.min(size.X*0.22,8)
        for _,x in ipairs({px,-px}) do
            cylinder(f,"PergolaPost",Vector3.new(0.28,2.8,0.28),cf*CFrame.new(x,roofY+1.4,0),pal.accent,Enum.Material.Metal)
        end
        part(f,"PergolaBeam",Vector3.new(math.abs(px)*2+0.6,0.3,1.0),cf*CFrame.new(0,roofY+2.75,0),pal.roof,Enum.Material.Wood)
    end
    roofVariantCount+=1
end

local function addNonBoxForms(f,cf,size,front,pal,district,variant)
    local groundY=-size.Y/2
    local roofY=size.Y/2

    -- Cylindrical entry arcade gives the street edge a clear non-rectangular rhythm.
    if size.X>=24 and size.Y>=16 then
        local archW=math.clamp(size.X*0.22,4.5,7.0)
        local archX=(variant==2 and -size.X*0.22) or (variant==3 and size.X*0.22) or 0
        local columnH=math.clamp(size.Y*0.24,4.2,6.4)
        for _,sx in ipairs({-1,1}) do
            cylinder(f,"ArcadeColumn",Vector3.new(0.55,columnH,0.55),cf*CFrame.new(archX+sx*archW/2,groundY+columnH/2+0.35,front-1.1),pal.accent,Enum.Material.Concrete)
        end
        cylinder(f,"ArcadeArch",Vector3.new(archW+0.5,0.72,0.72),cf*CFrame.new(archX,groundY+columnH+0.25,front-1.1)*CFrame.Angles(0,math.rad(90),0),pal.wall,Enum.Material.Concrete)
        sphere(f,"ArcadeCrown",Vector3.new(archW*0.58,1.35,0.65),cf*CFrame.new(archX,groundY+columnH+0.55,front-1.1),pal.wall,Enum.Material.Concrete)
        archCount+=1
    end

    -- Sparse rounded corner tower breaks the most obvious 90-degree box silhouette.
    if size.X>=28 and size.Y>=19 and variant==2 then
        local side=(math.floor(math.abs(cf.Position.X*0.5+cf.Position.Z))%2==0) and 1 or -1
        local tx=side*(size.X/2-1.8)
        local towerH=math.min(size.Y*0.62,14)
        cylinder(f,"CornerTower",Vector3.new(4.2,towerH,4.2),cf*CFrame.new(tx,groundY+towerH/2+0.25,front-0.9),pal.wall,Enum.Material.Concrete)
        sphere(f,"CornerTowerCap",Vector3.new(4.45,2.0,4.45),cf*CFrame.new(tx,groundY+towerH+1.0,front-0.9),pal.roof,Enum.Material.Slate)
        cornerTowerCount+=1
    end

    -- Gable crown adds a triangular roof read to otherwise flat slabs.
    if size.X>=26 and size.Y>=17 and variant==1 then
        local gw=math.clamp(size.X*0.30,8,13)
        local gx=size.X*0.20
        wedge(f,"GableL",Vector3.new(gw/2,3.2,3.8),cf*CFrame.new(gx-gw*0.24,roofY+1.7,front+size.Z*0.25)*CFrame.Angles(0,math.rad(180),0),pal.roof,Enum.Material.Slate)
        wedge(f,"GableR",Vector3.new(gw/2,3.2,3.8),cf*CFrame.new(gx+gw*0.24,roofY+1.7,front+size.Z*0.25),pal.roof,Enum.Material.Slate)
        gableCount+=1
        wedgeCount+=2
    end

    -- Side facade bay prevents buildings from looking finished only on the front face.
    if size.Z>=16 and size.Y>=18 then
        local sideX=size.X/2+0.48
        local sideSign=(variant%2==0) and -1 or 1
        local bayH=math.clamp(size.Y*0.30,4.2,7.0)
        local bayY=groundY+bayH/2+1.0
        local bay=part(f,"SideGlassBay",Vector3.new(0.20,bayH,math.min(size.Z*0.42,8.5)),cf*CFrame.new(sideSign*sideX,bayY,0),pal.glass,Enum.Material.Glass)
        bay.Transparency=0.32
        for _,z in ipairs({-math.min(size.Z*0.15,3.2),math.min(size.Z*0.15,3.2)}) do
            cylinder(f,"SideBayPost",Vector3.new(0.25,bayH+0.4,0.25),cf*CFrame.new(sideSign*(sideX+0.12),bayY,z),pal.accent,Enum.Material.Metal)
        end
        sideBayCount+=1
    end
end

local function decorate(model,body)
    local size,cf=body.Size,body.CFrame
    if size.X<18 or size.Y<13 or size.Z<12 then return end
    local district=districtFor(cf.Position)
    local pal=palettes[district]
    local variant=stableVariant(cf.Position,3)
    local f=Instance.new("Folder")
    f.Name="DistrictDepthV12"
    f.Parent=model

    local front=-size.Z/2-0.62
    local groundY=-size.Y/2

    local bandH=math.clamp(size.Y*0.12,1.4,3.2)
    part(f,"DistrictBaseBand",Vector3.new(size.X*0.9,bandH,0.38),cf*CFrame.new(0,groundY+bandH/2+0.4,front),pal.wall,Enum.Material.Brick)
    part(f,"DistrictMidBand",Vector3.new(size.X*0.72,0.5,0.55),cf*CFrame.new(0,math.min(3.5,size.Y*0.2),front-0.05),pal.accent,Enum.Material.Metal)
    materialBandCount+=2

    addStorefront(f,cf,size,front,pal,district,variant)
    addRoofVariation(f,cf,size,pal,variant)
    addNonBoxForms(f,cf,size,front,pal,district,variant)

    if size.Y>=20 and size.X>=24 then
        local finY=math.max(2,size.Y*0.08)
        for _,x in ipairs({-size.X*0.34,size.X*0.34}) do
            part(f,"FacadeFin",Vector3.new(0.38,math.min(size.Y*0.52,13),0.9),cf*CFrame.new(x,finY,front-0.7),pal.accent,Enum.Material.Concrete)
            verticalFinCount+=1
        end
    end

    if size.X>=28 and size.Y>=20 then
        local balconyY=math.min(size.Y*0.18,5.5)
        local balconyW=math.min(size.X*0.38,15)
        part(f,"BalconySlab",Vector3.new(balconyW,0.35,2.25),cf*CFrame.new(0,balconyY,front-1.15),pal.wall,Enum.Material.Concrete)
        for _,x in ipairs({-balconyW/2,0,balconyW/2}) do
            cylinder(f,"BalconyRail",Vector3.new(0.28,3.0,0.28),cf*CFrame.new(x,balconyY+1.45,front-2.15),pal.accent,Enum.Material.Metal)
        end
        balconyCount+=1
    end

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
    for n=1,3 do
        local a=math.rad(angle+n*35)
        sphere(f,"NodeShrub",Vector3.new(1.35,1.1,1.35),CFrame.new(pos+Vector3.new(math.cos(a)*2.1,0.85,math.sin(a)*2.1)),Color3.fromRGB(55,112,62),Enum.Material.Grass)
    end
    streetNodeCount+=1
end

-- Keep the v1.1 marker for existing build compatibility; v1.2 has a separate enhancement marker.
world:SetAttribute("ACC_BecakCityDistrictPolish","v1.1")
world:SetAttribute("ACC_BecakCityDistrictEnhancement","v1.2")
world:SetAttribute("BecakDistrictMaterialDepth","ON")
world:SetAttribute("BecakDiagonalRoofSilhouettes","ON")
world:SetAttribute("BecakRoundedBalconyRhythm","ON")
world:SetAttribute("BecakDistrictStreetNodes","ON")
world:SetAttribute("BecakDistrictStorefrontIdentity","ON")
world:SetAttribute("BecakDistrictRoofVariation","ON")
world:SetAttribute("BecakFacadeRecessDepth","ON")
world:SetAttribute("BecakDistrictVerticalFins","ON")
world:SetAttribute("BecakNonBoxArchitecture","ON")
world:SetAttribute("BecakArcadeFacadePass","ON")
world:SetAttribute("BecakRoundedCornerTowerPass","ON")
world:SetAttribute("BecakGableRoofPass","ON")
world:SetAttribute("BecakSideFacadeBayPass","ON")
world:SetAttribute("BecakDistrictPolishBuildingCount",buildingCount)
world:SetAttribute("BecakDistrictPolishWedgeCount",wedgeCount)
world:SetAttribute("BecakDistrictPolishBalconyCount",balconyCount)
world:SetAttribute("BecakDistrictMaterialBandCount",materialBandCount)
world:SetAttribute("BecakDistrictStreetNodeCount",streetNodeCount)
world:SetAttribute("BecakDistrictStorefrontCount",storefrontCount)
world:SetAttribute("BecakDistrictRoofVariantCount",roofVariantCount)
world:SetAttribute("BecakFacadeRecessFrameCount",recessFrameCount)
world:SetAttribute("BecakDistrictVerticalFinCount",verticalFinCount)
world:SetAttribute("BecakDistrictArchCount",archCount)
world:SetAttribute("BecakDistrictCornerTowerCount",cornerTowerCount)
world:SetAttribute("BecakDistrictGableCount",gableCount)
world:SetAttribute("BecakDistrictSideBayCount",sideBayCount)