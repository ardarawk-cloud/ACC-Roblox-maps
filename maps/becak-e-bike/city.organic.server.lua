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
    cylinder(f,"DistrictPole",Vector3.new(0.55,9.5,0.55),CFrame.new(a.pos+Vector3.new(0,5.3,0)),Color3.fromRGB(48,51,52),Enum.Material.Metal)
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
    cylinder(f,"UmbrellaPole",Vector3.new(0.35,5.5,0.35),CFrame.new(pos+Vector3.new(0,3,0)),Color3.fromRGB(72,62,53),Enum.Material.Wood)
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

-- v1.4 enhancement: add depth layers and curved street accents without increasing gameplay collision.
-- This deliberately reuses the v1.3 compatibility marker above so existing build/publish validation remains safe.
local depthCount=0
local arcadeCount=0
local rooflineCount=0

local function addFacadeDepth(model,body)
    local size,cf=body.Size,body.CFrame
    if size.X<24 or size.Y<16 then return end
    local f=Instance.new("Folder")
    f.Name="OrganicDepthV14"
    f.Parent=model
    local seed=seedOf(model.Name)
    local accent=accentPalette[(seed%#accentPalette)+1]
    local front=-size.Z/2-0.78

    -- Deep entrance canopy: cylinder nose + thin slab creates a less blocky street frontage.
    local canopyWidth=math.clamp(size.X*0.34,8,18)
    part(f,"EntryCanopySlab",Vector3.new(canopyWidth,0.32,2.8),cf*CFrame.new(0,-size.Y/2+8.8,front-1.2),accent,Enum.Material.Metal)
    local nose=cylinder(f,"EntryCanopyNose",Vector3.new(0.9,canopyWidth,0.9),cf*CFrame.new(0,-size.Y/2+8.65,front-2.55),accent,Enum.Material.Metal)
    nose.CFrame=cf*CFrame.new(0,-size.Y/2+8.65,front-2.55)*CFrame.Angles(0,math.rad(90),0)

    -- Vertical fins cast real shadow and visually split the original rectangular body.
    local fins=math.clamp(math.floor(size.X/18),2,4)
    for i=1,fins do
        local x=-size.X/2+i*(size.X/(fins+1))
        part(f,"FacadeFin",Vector3.new(0.5,math.min(size.Y*0.64,22),1.25),cf*CFrame.new(x,1.0,front+0.2),Color3.fromRGB(78,73,66),Enum.Material.Concrete)
        depthCount+=1
    end

    -- Small rounded planters soften the ground line and hide hard box corners.
    for _,side in ipairs({-1,1}) do
        local px=side*math.min(size.X/2-2.5,12)
        cylinder(f,"EntryPlanter",Vector3.new(2.5,1.0,2.5),cf*CFrame.new(px,-size.Y/2+0.6,front-1.55),Color3.fromRGB(91,72,55),Enum.Material.Brick)
        sphere(f,"EntryPlant",Vector3.new(2.1,2.4,2.1),cf*CFrame.new(px,-size.Y/2+2.0,front-1.55),Color3.fromRGB(55,119,60),Enum.Material.Grass)
        depthCount+=2
    end

    -- Commercial/public buildings receive a shallow arcade rhythm using round columns.
    local commercial=model.Name:find("Ruko") or model.Name=="Mall" or model.Name=="Hotel" or model.Name=="Terminal" or model.Name=="RumahSakit" or model.Name=="Sekolah"
    if commercial then
        local span=math.min(size.X*0.62,24)
        for _,x in ipairs({-span/2,0,span/2}) do
            local col=cylinder(f,"ArcadeColumn",Vector3.new(0.85,7.5,0.85),cf*CFrame.new(x,-size.Y/2+3.8,front-0.55),Color3.fromRGB(96,90,79),Enum.Material.Concrete)
            col.CFrame=cf*CFrame.new(x,-size.Y/2+3.8,front-0.55)*CFrame.Angles(0,0,math.rad(90))
        end
        part(f,"ArcadeBeam",Vector3.new(span+2.5,0.65,1.0),cf*CFrame.new(0,-size.Y/2+7.75,front-0.55),accent,Enum.Material.Brick)
        arcadeCount+=1
        depthCount+=4
    end

    -- Roofline ornaments vary per building and prevent a flat repeated skyline.
    local roofY=size.Y/2+1.7
    if seed%3==0 then
        for _,x in ipairs({-size.X*0.22,size.X*0.22}) do
            sphere(f,"RoofFinial",Vector3.new(1.5,1.8,1.5),cf*CFrame.new(x,roofY,0),accent,Enum.Material.Metal)
            depthCount+=1
        end
    elseif seed%3==1 then
        local screenW=math.min(size.X*0.4,16)
        part(f,"RoofScreen",Vector3.new(screenW,2.2,0.45),cf*CFrame.new(0,roofY,0),Color3.fromRGB(77,82,80),Enum.Material.Metal)
        for _,x in ipairs({-screenW/2,screenW/2}) do
            cylinder(f,"RoofScreenPost",Vector3.new(0.35,2.8,0.35),cf*CFrame.new(x,roofY,0),Color3.fromRGB(55,58,59),Enum.Material.Metal)
            depthCount+=1
        end
        depthCount+=1
    else
        local cap=cylinder(f,"RoofRoundCap",Vector3.new(5.0,0.65,5.0),cf*CFrame.new(size.X*0.18,roofY,0),accent,Enum.Material.Metal)
        cap.CFrame=cap.CFrame*CFrame.Angles(0,math.rad(seed%45),0)
        depthCount+=1
    end
    rooflineCount+=1
end

for _,obj in ipairs(world:GetChildren()) do
    if obj:IsA("Model") then
        local body=obj:FindFirstChild("Body")
        if body and body:IsA("BasePart") then addFacadeDepth(obj,body) end
    end
end

-- Curved roadside micro-landmarks make long straight roads read as a city, not a blockout grid.
local microLandmarks={
    Vector3.new(-280,0,30),Vector3.new(-70,0,-30),Vector3.new(70,0,30),Vector3.new(280,0,-30),
}
for i,pos in ipairs(microLandmarks) do
    local f=Instance.new("Folder")
    f.Name="RoadsideOrganicNode_"..i
    f.Parent=polish
    cylinder(f,"RoundBase",Vector3.new(4.4,0.55,4.4),CFrame.new(pos+Vector3.new(0,0.3,0)),Color3.fromRGB(102,93,79),Enum.Material.Cobblestone)
    cylinder(f,"SlimPole",Vector3.new(0.38,6.5,0.38),CFrame.new(pos+Vector3.new(0,3.6,0)),Color3.fromRGB(48,51,52),Enum.Material.Metal)
    sphere(f,"GlowHead",Vector3.new(1.25,1.05,1.25),CFrame.new(pos+Vector3.new(0,7.0,0)),Color3.fromRGB(224,208,165),Enum.Material.Glass)
    for j=1,3 do
        local angle=(j/3)*math.pi*2
        sphere(f,"ShrubOrb",Vector3.new(1.55,1.25,1.55),CFrame.new(pos+Vector3.new(math.cos(angle)*2.3,0.85,math.sin(angle)*2.3)),Color3.fromRGB(57,118+((i+j)%2)*8,61),Enum.Material.Grass)
    end
    depthCount+=6
end

world:SetAttribute("ACC_BecakCityOrganicEnhancement","v1.4")
world:SetAttribute("BecakFacadeDepthLayering","ON")
world:SetAttribute("BecakRoundedEntranceCanopies","ON")
world:SetAttribute("BecakArcadeStreetRhythm","ON")
world:SetAttribute("BecakVariableRoofline","ON")
world:SetAttribute("BecakOrganicRoadsideNodes","ON")
world:SetAttribute("BecakOrganicDepthPartCount",depthCount)
world:SetAttribute("BecakOrganicArcadeCount",arcadeCount)
world:SetAttribute("BecakOrganicRooflineCount",rooflineCount)
