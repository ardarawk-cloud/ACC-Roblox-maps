-- BBYA SOCIAL HUB — STREET FRONTAGE
-- Makes the venue read like a premium roadside club: asphalt road, curb, sidewalk, crossing and street lights.

local function streetPart(name,size,cf,color,material)
    return part(A1,name,size,cf,color,material or Enum.Material.Concrete,0,true)
end

-- Main road runs horizontally across the full club frontage.
streetPart("FRONT ASPHALT ROAD",Vector3.new(270,1,26),CFrame.new(0,-.15,-97),Color3.fromRGB(24,25,28),Enum.Material.Asphalt)

-- Sidewalk and curb directly in front of the arrival plaza.
streetPart("FRONT SIDEWALK",Vector3.new(210,.7,9),CFrame.new(0,.25,-79.8),Color3.fromRGB(86,84,87),Enum.Material.Concrete)
streetPart("FRONT CURB",Vector3.new(210,1.1,1.5),CFrame.new(0,.28,-84.7),Color3.fromRGB(122,120,122),Enum.Material.Concrete)

-- Opposite curb gives the road a believable city-street edge instead of fading into void.
streetPart("OPPOSITE CURB",Vector3.new(270,1,1.4),CFrame.new(0,.05,-110.2),Color3.fromRGB(92,91,94),Enum.Material.Concrete)
streetPart("OPPOSITE WALK",Vector3.new(270,.5,7),CFrame.new(0,-.05,-114.2),Color3.fromRGB(54,54,58),Enum.Material.Concrete)

-- Center dashed road markings.
for x=-120,120,24 do
    streetPart("ROAD CENTER DASH "..x,Vector3.new(12,.08,.45),CFrame.new(x,.39,-97),Color3.fromRGB(229,205,92),Enum.Material.Neon)
end

-- Road edge markings.
streetPart("ROAD EDGE LINE CLUB",Vector3.new(250,.08,.28),CFrame.new(0,.39,-85.8),Color3.fromRGB(225,225,225),Enum.Material.Neon)
streetPart("ROAD EDGE LINE FAR",Vector3.new(250,.08,.28),CFrame.new(0,.39,-108.2),Color3.fromRGB(225,225,225),Enum.Material.Neon)

-- Pedestrian crossing aligned with the main entrance/center approach.
for x=-10,10,4 do
    streetPart("CROSSWALK "..x,Vector3.new(2.2,.09,14),CFrame.new(x,.4,-97),Color3.fromRGB(220,220,220),Enum.Material.SmoothPlastic)
end

-- Small drop-off apron so the entrance feels connected to the street.
streetPart("DROP OFF APRON",Vector3.new(42,.45,8),CFrame.new(0,.45,-75),Color3.fromRGB(48,47,52),Enum.Material.Concrete)
neon(A1,"DROP OFF EDGE L",Vector3.new(15,.12,.12),CFrame.new(-13,.75,-79.2),C.pink)
neon(A1,"DROP OFF EDGE R",Vector3.new(15,.12,.12),CFrame.new(13,.75,-79.2),C.cyan)

-- Restrained roadside lighting. No giant signs; BBYA branding remains on the building only.
for _,x in ipairs({-88,-44,44,88}) do
    streetPart("STREET LAMP POLE "..x,Vector3.new(.7,12,.7),CFrame.new(x,6,-81.8),Color3.fromRGB(36,37,42),Enum.Material.Metal)
    streetPart("STREET LAMP ARM "..x,Vector3.new(4,.45,.45),CFrame.new(x+(x<0 and 1.8 or -1.8),11.7,-81.8),Color3.fromRGB(36,37,42),Enum.Material.Metal)
    local lamp=light(A1,"STREET LAMP LIGHT "..x,Vector3.new(x,11.2,-83),C.warm,1.1,18)
    lamp.Parent:SetAttribute("BBYAStreetLight",true)
end

-- Keep the player spawn on the venue side of the curb, not in the road.
local arrivalSpawn=workspace:FindFirstChild("BBYA ARRIVAL SPAWN",true)
if arrivalSpawn and arrivalSpawn:IsA("SpawnLocation") then
    arrivalSpawn.CFrame=CFrame.new(0,1.4,-70)*CFrame.Angles(0,math.rad(180),0)
end

workspace:SetAttribute("BBYAStreetFrontage","ROADSIDE_CLUB_V1")
workspace:SetAttribute("BBYAAsphaltRoad",true)
workspace:SetAttribute("BBYACrosswalk",true)
