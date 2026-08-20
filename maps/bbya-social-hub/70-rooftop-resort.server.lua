-- BBYA SOCIAL HUB — ROOFTOP RESORT REDESIGN v2
-- Warm hospitality rooftop: true recessed Terrain-water pool, timber decks,
-- shaded cabanas, sunset lounge, greenery and warm practical lighting. NO neon.

local Workspace = game:GetService("Workspace")
local Terrain = Workspace.Terrain
local root = Workspace:WaitForChild("BBYA_ZERO_BUILD",30)
if not root then return end
local upper = root:WaitForChild("UpperLevels",30)
if not upper then return end
local roof = upper:WaitForChild("R_Rooftop",30)
if not roof then return end

task.wait(.45)
for _,child in ipairs(roof:GetChildren()) do child:Destroy() end
roof:SetAttribute("Pass","ROOFTOP_RESORT_V2")
roof:SetAttribute("NoNeon",true)
roof:SetAttribute("RealTerrainWaterPool",true)
roof:SetAttribute("PoolHasRecessedBasin",true)
roof:SetAttribute("DesignLanguage","natural stone + timber + greenery + warm practical lights")

local C={
    concrete=Color3.fromRGB(92,88,84),
    dark=Color3.fromRGB(48,47,47),
    wood=Color3.fromRGB(108,78,56),
    woodDark=Color3.fromRGB(66,48,38),
    stone=Color3.fromRGB(121,117,109),
    poolStone=Color3.fromRGB(76,90,92),
    fabric=Color3.fromRGB(220,211,198),
    fabricDark=Color3.fromRGB(96,82,74),
    metal=Color3.fromRGB(55,56,58),
    glass=Color3.fromRGB(125,161,174),
    leaf=Color3.fromRGB(61,104,67),
    warm=Color3.fromRGB(255,214,166),
    fire=Color3.fromRGB(255,145,72),
}

local function part(name,size,cf,color,material,transparency,collide,parent)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Color=color or C.concrete
    p.Material=material or Enum.Material.SmoothPlastic
    p.Transparency=transparency or 0
    p.Anchored=true
    p.CanCollide=collide~=false
    p.CanTouch=false
    p.CanQuery=true
    p.CastShadow=true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent or roof
    return p
end

local function cylinder(name,size,cf,color,material,parent,collide)
    local p=part(name,size,cf,color,material,0,collide,parent)
    p.Shape=Enum.PartType.Cylinder
    return p
end

local function model(name,parent)
    local m=Instance.new("Model")
    m.Name=name
    m.Parent=parent or roof
    return m
end

local function warmLight(parent,brightness,range)
    local l=Instance.new("PointLight")
    l.Color=C.warm
    l.Brightness=brightness or 1.2
    l.Range=range or 17
    l.Shadows=true
    l.Parent=parent
    return l
end

-- -----------------------------------------------------------------------------
-- STRUCTURAL ROOF WITH A REAL POOL VOID
-- Do not place one solid slab below the pool; the opening lets avatars enter water.
-- -----------------------------------------------------------------------------
part("RoofWest",Vector3.new(32.6,1.2,92),CFrame.new(-45.7,44.35,0),C.dark,Enum.Material.Concrete,0,true)
part("RoofEast",Vector3.new(32.6,1.2,92),CFrame.new(45.7,44.35,0),C.dark,Enum.Material.Concrete,0,true)
part("RoofSouth",Vector3.new(58.8,1.2,41.8),CFrame.new(0,44.35,-25.1),C.dark,Enum.Material.Concrete,0,true)
part("RoofNorth",Vector3.new(58.8,1.2,17.8),CFrame.new(0,44.35,37.1),C.dark,Enum.Material.Concrete,0,true)

-- Pool coping / stone terrace pieces surround the hole rather than covering it.
part("PoolDeckW",Vector3.new(9.5,.45,40),CFrame.new(-34.2,45.15,12),C.stone,Enum.Material.Limestone,0,true)
part("PoolDeckE",Vector3.new(9.5,.45,40),CFrame.new(34.2,45.15,12),C.stone,Enum.Material.Limestone,0,true)
part("PoolDeckS",Vector3.new(58.5,.45,8),CFrame.new(0,45.15,-8),C.stone,Enum.Material.Limestone,0,true)
part("PoolDeckN",Vector3.new(58.5,.45,8),CFrame.new(0,45.15,32),C.stone,Enum.Material.Limestone,0,true)
part("SunsetDeck",Vector3.new(112,.42,18),CFrame.new(0,45.15,-36),C.wood,Enum.Material.WoodPlanks,0,true)
part("GardenDeckL",Vector3.new(19,.42,52),CFrame.new(-50,45.15,8),C.woodDark,Enum.Material.WoodPlanks,0,true)
part("GardenDeckR",Vector3.new(19,.42,52),CFrame.new(50,45.15,8),C.woodDark,Enum.Material.WoodPlanks,0,true)

-- Frameless outer safety glass.
for _,d in ipairs({
    {"North",Vector3.new(118,5,.35),CFrame.new(0,47.7,45.1)},
    {"South",Vector3.new(118,5,.35),CFrame.new(0,47.7,-45.1)},
    {"West",Vector3.new(.35,5,90),CFrame.new(-59.1,47.7,0)},
    {"East",Vector3.new(.35,5,90),CFrame.new(59.1,47.7,0)},
}) do
    local g=part("GlassRail"..d[1],d[2],d[3],C.glass,Enum.Material.Glass,.58,true)
    g.Reflectance=.08
end

-- -----------------------------------------------------------------------------
-- TRUE RECESSED POOL
-- Terrain Water supplies Roblox swimming physics. Water surface sits just below coping.
-- -----------------------------------------------------------------------------
local pool=model("RooftopPool")
local cleanupCenter=Vector3.new(0,44.2,12)
Terrain:FillBlock(CFrame.new(cleanupCenter),Vector3.new(58,7.5,32),Enum.Material.Air)

local waterCenter=Vector3.new(0,43.55,12)
local waterSize=Vector3.new(56,3.2,30)
Terrain:FillBlock(CFrame.new(waterCenter),waterSize,Enum.Material.Water)

part("PoolBasinFloor",Vector3.new(58,.55,32),CFrame.new(0,41.55,12),C.poolStone,Enum.Material.Slate,0,true,pool)
part("PoolWallN",Vector3.new(58,3.9,.7),CFrame.new(0,43.45,27.5),C.stone,Enum.Material.Limestone,0,true,pool)
part("PoolWallS",Vector3.new(58,3.9,.7),CFrame.new(0,43.45,-3.5),C.stone,Enum.Material.Limestone,0,true,pool)
part("PoolWallW",Vector3.new(.7,3.9,30),CFrame.new(-28.7,43.45,12),C.stone,Enum.Material.Limestone,0,true,pool)
part("PoolWallE",Vector3.new(.7,3.9,30),CFrame.new(28.7,43.45,12),C.stone,Enum.Material.Limestone,0,true,pool)

-- Infinity/view edge is transparent and below the deck line.
local infinity=part("InfinityGlass",Vector3.new(54,2.6,.28),CFrame.new(0,43.8,-3.86),C.glass,Enum.Material.Glass,.72,false,pool)
infinity.Reflectance=.12

-- Entry stairs descend into the north-west corner of the pool.
for i,data in ipairs({
    {y=44.72,z=24.7},
    {y=44.05,z=22.7},
    {y=43.38,z=20.7},
    {y=42.71,z=18.7},
}) do
    part("PoolStep"..i,Vector3.new(12,.55,2.1),CFrame.new(-20,data.y,data.z),C.stone,Enum.Material.Limestone,0,true,pool)
end
part("ShallowSunShelf",Vector3.new(13,.5,8.8),CFrame.new(-20,42.35,14.2),Color3.fromRGB(104,116,115),Enum.Material.Slate,0,true,pool)

-- -----------------------------------------------------------------------------
-- SHADED CABANAS
-- -----------------------------------------------------------------------------
local function pergola(name,x,z,yaw)
    local m=model(name)
    local cf=CFrame.new(x,45.45,z)*CFrame.Angles(0,math.rad(yaw or 0),0)
    for _,sx in ipairs({-6.1,6.1}) do
        for _,sz in ipairs({-4.2,4.2}) do
            part("Post",Vector3.new(.48,8,.48),cf*CFrame.new(sx,4,sz),C.woodDark,Enum.Material.WoodPlanks,0,true,m)
        end
    end
    for _,sz in ipairs({-4.2,4.2}) do
        part("TopBeam",Vector3.new(13,.55,.55),cf*CFrame.new(0,8,sz),C.woodDark,Enum.Material.WoodPlanks,0,true,m)
    end
    for _,sx in ipairs({-5.4,-3.6,-1.8,0,1.8,3.6,5.4}) do
        part("ShadeSlat",Vector3.new(.34,.26,9.2),cf*CFrame.new(sx,8.18,0),C.wood,Enum.Material.WoodPlanks,0,true,m)
    end
    part("DaybedBase",Vector3.new(10,.7,5.7),cf*CFrame.new(0,.75,0),C.woodDark,Enum.Material.WoodPlanks,0,true,m)
    part("DaybedCushion",Vector3.new(9.5,.65,5.2),cf*CFrame.new(0,1.45,0),C.fabric,Enum.Material.Fabric,0,true,m)
    part("DaybedBack",Vector3.new(9.5,2.4,.55),cf*CFrame.new(0,2.55,2.45)*CFrame.Angles(math.rad(-10),0,0),C.fabricDark,Enum.Material.Fabric,0,true,m)
    local pendant=cylinder("Pendant",Vector3.new(.7,1.05,1.05),cf*CFrame.new(0,6.7,0)*CFrame.Angles(0,0,math.rad(90)),C.warm,Enum.Material.Glass,m,false)
    warmLight(pendant,1.4,15)
end
pergola("CabanaWest",-48,21,90)
pergola("CabanaEast",48,21,-90)

-- -----------------------------------------------------------------------------
-- ROOFTOP BAR
-- -----------------------------------------------------------------------------
local bar=model("RooftopBar")
part("BarBody",Vector3.new(34,3.2,7),CFrame.new(0,46.8,-24),C.concrete,Enum.Material.Concrete,0,true,bar)
part("BarTop",Vector3.new(35,.38,7.8),CFrame.new(0,48.55,-24),Color3.fromRGB(125,122,116),Enum.Material.Marble,0,true,bar)
part("BarBackWall",Vector3.new(34,8,.55),CFrame.new(0,49.1,-30),C.woodDark,Enum.Material.WoodPlanks,0,true,bar)
for _,x in ipairs({-13,-6.5,0,6.5,13}) do
    part("Shelf"..x,Vector3.new(5.2,.22,1.1),CFrame.new(x,50.1,-29.55),C.wood,Enum.Material.WoodPlanks,0,true,bar)
    local lamp=cylinder("BarPendant"..x,Vector3.new(.5,.8,.8),CFrame.new(x,53.1,-24)*CFrame.Angles(0,0,math.rad(90)),C.warm,Enum.Material.Glass,bar,false)
    warmLight(lamp,1.1,12)
end
for _,x in ipairs({-13,-8,-3,3,8,13}) do
    local s=model("BarStool"..x,bar)
    cylinder("Seat",Vector3.new(.6,2.6,2.6),CFrame.new(x,46.7,-18.9)*CFrame.Angles(0,0,math.rad(90)),C.fabricDark,Enum.Material.Fabric,s,true)
    cylinder("Stem",Vector3.new(2.3,.28,.28),CFrame.new(x,45.5,-18.9)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,s,true)
    cylinder("Foot",Vector3.new(.18,2.3,2.3),CFrame.new(x,44.4,-18.9)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,s,true)
end

-- -----------------------------------------------------------------------------
-- SUNSET LOUNGE
-- -----------------------------------------------------------------------------
local function loungeGroup(name,x,z)
    local m=model(name)
    cylinder("Table",Vector3.new(.45,3.2,3.2),CFrame.new(x,46.1,z)*CFrame.Angles(0,0,math.rad(90)),C.stone,Enum.Material.Marble,m,true)
    for i,a in ipairs({0,120,240}) do
        local rad=math.rad(a)
        local px=x+math.cos(rad)*4.2
        local pz=z+math.sin(rad)*4.2
        local cf=CFrame.lookAt(Vector3.new(px,45.7,pz),Vector3.new(x,45.7,z))
        cylinder("ChairSeat"..i,Vector3.new(.65,3,3),cf*CFrame.Angles(0,0,math.rad(90)),C.fabric,Enum.Material.Fabric,m,true)
        part("ChairBack"..i,Vector3.new(3,2.3,.5),cf*CFrame.new(0,1.2,1.25)*CFrame.Angles(math.rad(-12),0,0),C.fabricDark,Enum.Material.Fabric,0,true,m)
    end
end
loungeGroup("SunsetLoungeL",-32,-35)
loungeGroup("SunsetLoungeR",32,-35)

-- -----------------------------------------------------------------------------
-- LANDSCAPE
-- -----------------------------------------------------------------------------
local function planter(name,pos,scale)
    scale=scale or 1
    local m=model(name)
    cylinder("Pot",Vector3.new(2.6*scale,3*scale,3*scale),CFrame.new(pos.X,46.7,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.concrete,Enum.Material.Concrete,m,true)
    cylinder("Trunk",Vector3.new(4.2*scale,.45*scale,.45*scale),CFrame.new(pos.X,48.5,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.woodDark,Enum.Material.Wood,m,false)
    for i=1,7 do
        local a=math.rad((i-1)*(360/7))
        local leaf=part("Leaf"..i,Vector3.new(.45*scale,2.4*scale,.9*scale),CFrame.new(pos.X+math.cos(a)*1.15*scale,50.6,pos.Z+math.sin(a)*1.15*scale)*CFrame.Angles(math.rad(18),-a,0),C.leaf,Enum.Material.SmoothPlastic,0,false,m)
        leaf.CanQuery=false
    end
end
for i,pos in ipairs({Vector3.new(-53,0,-29),Vector3.new(-53,0,3),Vector3.new(-53,0,37),Vector3.new(53,0,-29),Vector3.new(53,0,3),Vector3.new(53,0,37)}) do
    planter("Planter"..i,pos,1)
end

-- Fire bowl is a warm focal point, not a neon effect.
local fireBase=cylinder("FireBowl",Vector3.new(1.1,5.2,5.2),CFrame.new(0,46,-37)*CFrame.Angles(0,0,math.rad(90)),C.dark,Enum.Material.Concrete,roof,true)
local fire=Instance.new("Fire")
fire.Color=C.fire
fire.SecondaryColor=Color3.fromRGB(255,205,105)
fire.Heat=5
fire.Size=4
fire.Parent=fireBase
local fireLight=Instance.new("PointLight")
fireLight.Color=C.fire
fireLight.Brightness=1.5
fireLight.Range=18
fireLight.Shadows=true
fireLight.Parent=fireBase

local arrival=part("RooftopArrival",Vector3.new(8,.25,8),CFrame.new(43,45.25,-28),C.dark,Enum.Material.Concrete,1,true)
arrival.CanQuery=false

print("[BBYA] Rooftop resort v2 online: recessed Terrain-water pool + warm hospitality terrace + NO neon")
