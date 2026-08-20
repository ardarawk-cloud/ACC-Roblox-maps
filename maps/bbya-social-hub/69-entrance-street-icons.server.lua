-- BBYA SOCIAL HUB — ENTRANCE STREET + ICON CARS v1
-- Makes the spawn read as a venue on a real main road.
-- Includes two photo-icon sports-car slots; cloud mesh pipeline can replace fallback shells.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 30)
if not root then return end
local entrance = root:WaitForChild("Entrance", 30)
if not entrance then return end

task.wait(0.25)
local old = root:FindFirstChild("EntranceStreetScene")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "EntranceStreetScene"
out:SetAttribute("Pass", "ENTRANCE_STREET_ICONS_V1")
out:SetAttribute("PhotoSpot", true)
out:SetAttribute("CloudMeshReplacementTarget", true)
out.Parent = root

local C = {
    asphalt = Color3.fromRGB(31,32,34),
    curb = Color3.fromRGB(108,107,105),
    sidewalk = Color3.fromRGB(66,64,62),
    line = Color3.fromRGB(224,210,148),
    white = Color3.fromRGB(225,225,222),
    black = Color3.fromRGB(12,12,14),
    glass = Color3.fromRGB(35,45,55),
    red = Color3.fromRGB(180,18,32),
    blue = Color3.fromRGB(20,74,185),
    metal = Color3.fromRGB(45,46,49),
}

local function part(name,size,cf,color,material,transparency,collide,parent,className)
    local p = className=="WedgePart" and Instance.new("WedgePart") or Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Color=color or C.black
    p.Material=material or Enum.Material.SmoothPlastic
    p.Transparency=transparency or 0
    p.Anchored=true
    p.CanCollide=collide==true
    p.CanTouch=false
    p.CanQuery=true
    p.CastShadow=true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent or out
    return p
end

local function cylinder(name,size,cf,color,parent)
    local p=part(name,size,cf,color,Enum.Material.SmoothPlastic,0,false,parent)
    p.Shape=Enum.PartType.Cylinder
    return p
end

-- Main road parallel to the facade.
part("MainRoad",Vector3.new(190,1.2,30),CFrame.new(0,-.15,-82),C.asphalt,Enum.Material.Asphalt,0,true)
part("VenueSidewalk",Vector3.new(190,.65,9),CFrame.new(0,.65,-64.5),C.sidewalk,Enum.Material.Concrete,0,true)
part("VenueCurb",Vector3.new(190,.9,1.2),CFrame.new(0,.5,-69.1),C.curb,Enum.Material.Concrete,0,true)
part("OppositeCurb",Vector3.new(190,.9,1.2),CFrame.new(0,.5,-96.9),C.curb,Enum.Material.Concrete,0,true)

-- Centerline and edge markings. These are road markings, not decorative venue neon.
for _,x in ipairs({-78,-52,-26,0,26,52,78}) do
    part("CenterDash"..x,Vector3.new(13,.04,.28),CFrame.new(x,.48,-82),C.line,Enum.Material.SmoothPlastic,0,false)
end
part("RoadEdgeNear",Vector3.new(184,.04,.18),CFrame.new(0,.48,-72),C.white,Enum.Material.SmoothPlastic,0,false)
part("RoadEdgeFar",Vector3.new(184,.04,.18),CFrame.new(0,.48,-92),C.white,Enum.Material.SmoothPlastic,0,false)

-- Pedestrian approach from spawn/venue to the photo spot.
for i,x in ipairs({-8,-4,0,4,8}) do
    part("Crosswalk"..i,Vector3.new(2.2,.05,8),CFrame.new(x,.5,-72.7),C.white,Enum.Material.SmoothPlastic,0,false)
end

local function sportCar(name, pos, yaw, bodyColor)
    local m=Instance.new("Model")
    m.Name=name
    m:SetAttribute("FallbackGeometry", true)
    m:SetAttribute("ReplaceWithCloudMesh", true)
    m.Parent=out

    local baseCF=CFrame.new(pos)*CFrame.Angles(0,math.rad(yaw),0)
    -- Lower, wider proportions than a normal block car.
    part("Chassis",Vector3.new(10.8,.75,4.9),baseCF*CFrame.new(0,1.15,0),C.black,Enum.Material.Metal,0,false,m)
    part("BodyLower",Vector3.new(10.2,1.05,4.65),baseCF*CFrame.new(0,1.65,0),bodyColor,Enum.Material.SmoothPlastic,0,false,m)
    part("Hood",Vector3.new(3.5,.58,4.35),baseCF*CFrame.new(3.25,2.15,0)*CFrame.Angles(0,0,math.rad(-5)),bodyColor,Enum.Material.SmoothPlastic,0,false,m,"WedgePart")
    part("RearDeck",Vector3.new(2.7,.62,4.35),baseCF*CFrame.new(-3.7,2.1,0)*CFrame.Angles(0,math.rad(180),math.rad(-4)),bodyColor,Enum.Material.SmoothPlastic,0,false,m,"WedgePart")
    part("Cabin",Vector3.new(4.5,1.25,3.75),baseCF*CFrame.new(-.25,2.55,0),C.glass,Enum.Material.Glass,.18,false,m)
    part("Roof",Vector3.new(3.3,.25,3.45),baseCF*CFrame.new(-.55,3.25,0),bodyColor,Enum.Material.SmoothPlastic,0,false,m)
    -- Curved-feel nose via cylinders/low profile elements.
    cylinder("Nose",Vector3.new(4.1,4.4,4.4),baseCF*CFrame.new(5.05,1.72,0)*CFrame.Angles(0,math.rad(90),0),bodyColor,m)
    cylinder("Rear",Vector3.new(2.1,4.4,4.4),baseCF*CFrame.new(-5.05,1.72,0)*CFrame.Angles(0,math.rad(90),0),bodyColor,m)

    for _,sx in ipairs({-3.4,3.4}) do
        for _,sz in ipairs({-2.25,2.25}) do
            local wheel=cylinder("Wheel",Vector3.new(.72,1.55,1.55),baseCF*CFrame.new(sx,1.05,sz)*CFrame.Angles(math.rad(90),0,0),C.black,m)
            wheel.Material=Enum.Material.Rubber
            local rim=cylinder("Rim",Vector3.new(.76,.92,.92),baseCF*CFrame.new(sx,1.05,sz)*CFrame.Angles(math.rad(90),0,0),Color3.fromRGB(135,138,145),m)
            rim.Material=Enum.Material.Metal
        end
    end
    -- Head/tail light lenses.
    for _,z in ipairs({-1.45,1.45}) do
        part("Headlamp",Vector3.new(.16,.42,.88),baseCF*CFrame.new(5.55,1.9,z),C.white,Enum.Material.Glass,.08,false,m)
        part("TailLamp",Vector3.new(.16,.38,.78),baseCF*CFrame.new(-5.55,1.9,z),Color3.fromRGB(220,25,35),Enum.Material.Glass,.04,false,m)
    end
    return m
end

-- Cars face each other with the venue entrance centered between them.
local red=sportCar("CloudCarSlot_Red",Vector3.new(-31,1.0,-75.5),90,C.red)
local blue=sportCar("CloudCarSlot_Blue",Vector3.new(31,1.0,-75.5),-90,C.blue)
red:SetAttribute("DesiredCloudPrompt","premium exotic sports coupe, glossy red, realistic automotive proportions")
blue:SetAttribute("DesiredCloudPrompt","premium exotic sports coupe, glossy blue, realistic automotive proportions")

-- Warm street lamps frame the arrival without turning the street into a neon set.
for i,x in ipairs({-52,52}) do
    local pole=part("StreetPole"..i,Vector3.new(.35,10,.35),CFrame.new(x,5.5,-66),C.metal,Enum.Material.Metal,0,false)
    local lamp=part("StreetLamp"..i,Vector3.new(2.5,.45,1.1),CFrame.new(x,10.4,-66),Color3.fromRGB(235,218,188),Enum.Material.SmoothPlastic,0,false)
    local light=Instance.new("PointLight")
    light.Color=Color3.fromRGB(255,222,180)
    light.Brightness=1.8
    light.Range=24
    light.Shadows=true
    light.Parent=lamp
end

print("[BBYA] Entrance street v1 online: main asphalt road + red/blue photo cars")
