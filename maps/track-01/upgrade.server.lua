local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- TRACK 01 v2 visual/venue pass.
-- This script intentionally waits for the stable v1 runtime so the upgrade can be
-- layered without disturbing the proven spawn, safety boundaries, and base layout.
local deadline = os.clock() + 25
repeat
    task.wait(0.15)
until Workspace:GetAttribute("ACC_TRACK01_READY") or os.clock() > deadline

local root = Workspace:FindFirstChild("ACC_TRACK01")
if not root then
    warn("[TRACK 01 UPGRADE] Base runtime missing")
    return
end

local world = root:FindFirstChild("World")
local train = world and world:FindFirstChild("TrainCars")
local props = world and world:FindFirstChild("Props")
local architecture = world and world:FindFirstChild("Architecture")
local railway = world and world:FindFirstChild("Railway")
local lightsFolder = root:FindFirstChild("DynamicLights")
if not (world and train and props and architecture and railway and lightsFolder) then
    warn("[TRACK 01 UPGRADE] Required folders missing")
    return
end

root:SetAttribute("UpgradeVersion", "2.0.0")
root:SetAttribute("ArtDirection", "Faded rusty-red railway / abandoned industrial nightlife")

local C = {
    fadedRed = Color3.fromRGB(112, 37, 31),
    fadedRed2 = Color3.fromRGB(126, 44, 35),
    darkRed = Color3.fromRGB(71, 27, 25),
    oxide = Color3.fromRGB(136, 68, 42),
    oxide2 = Color3.fromRGB(101, 50, 34),
    deepRust = Color3.fromRGB(72, 39, 31),
    grime = Color3.fromRGB(34, 32, 29),
    soot = Color3.fromRGB(24, 24, 23),
    agedSteel = Color3.fromRGB(77, 77, 73),
    dullSteel = Color3.fromRGB(102, 99, 91),
    warm = Color3.fromRGB(255, 190, 111),
    amber = Color3.fromRGB(255, 151, 62),
    signalRed = Color3.fromRGB(190, 43, 33),
    cream = Color3.fromRGB(176, 157, 119),
    oldWood = Color3.fromRGB(74, 54, 39),
    oldWood2 = Color3.fromRGB(92, 67, 47),
    glassDark = Color3.fromRGB(48, 61, 65),
    concrete = Color3.fromRGB(77, 73, 66),
    plaster = Color3.fromRGB(123, 115, 101),
    vegetation = Color3.fromRGB(64, 76, 48),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z) * CFrame.Angles(math.rad(rx or 0), math.rad(ry or 0), math.rad(rz or 0))
end

local function part(parent,name,size,frame,color,material,transparency,collide,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color or C.agedSteel
    p.Material=material or Enum.Material.Metal
    p.Anchored=true
    p.CanCollide=collide == true
    p.CanTouch=false
    p.CanQuery=true
    p.Transparency=transparency or 0
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    if shape then p.Shape=shape end
    p.Parent=parent
    return p
end

local function cylinder(parent,name,size,frame,color,material,collide)
    return part(parent,name,size,frame,color,material,0,collide,Enum.PartType.Cylinder)
end

local function ball(parent,name,size,frame,color,material)
    return part(parent,name,size,frame,color,material,0,false,Enum.PartType.Ball)
end

local function surfaceText(target,face,text,textColor,bgColor,font)
    local gui=Instance.new("SurfaceGui")
    gui.Name="UpgradeSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=42
    gui.LightInfluence=0.25
    gui.Parent=target
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bgColor or C.soot
    label.BackgroundTransparency=0.08
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=textColor or C.cream
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=font or Enum.Font.GothamBold
    label.Parent=gui
    return label
end

local function pointLight(parent,color,brightness,range,shadows)
    local l=Instance.new("PointLight")
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Shadows=shadows ~= false
    l.Parent=parent
    return l
end

local function spotLight(parent,color,brightness,range,angle)
    local l=Instance.new("SpotLight")
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Angle=angle
    l.Face=Enum.NormalId.Bottom
    l.Shadows=true
    l.Parent=parent
    return l
end

local upgrade=Instance.new("Folder")
upgrade.Name="TRACK01_Upgrade_v2"
upgrade.Parent=world
local trainDetails=Instance.new("Folder")
trainDetails.Name="RustyTrainDetails"
trainDetails.Parent=upgrade
local stationDetails=Instance.new("Folder")
stationDetails.Name="StationDetails"
stationDetails.Parent=upgrade
local platformDetails=Instance.new("Folder")
platformDetails.Name="PlatformDetails"
platformDetails.Parent=upgrade
local yardDetails=Instance.new("Folder")
yardDetails.Name="YardDetails"
yardDetails.Parent=upgrade
local atmosphereDetails=Instance.new("Folder")
atmosphereDetails.Name="AtmosphereDetails"
atmosphereDetails.Parent=upgrade

-- Slightly dirtier, warmer night grade; still readable on mobile.
Lighting.Brightness=1.55
Lighting.Ambient=Color3.fromRGB(32,35,38)
Lighting.OutdoorAmbient=Color3.fromRGB(42,43,44)
Lighting.EnvironmentSpecularScale=0.42
local baseCC=Lighting:FindFirstChild("TRACK01_Color")
if baseCC and baseCC:IsA("ColorCorrectionEffect") then
    baseCC.Contrast=0.18
    baseCC.Saturation=-0.18
    baseCC.TintColor=Color3.fromRGB(229,211,192)
end
local baseAtmos=Lighting:FindFirstChild("TRACK01_Atmosphere")
if baseAtmos and baseAtmos:IsA("Atmosphere") then
    baseAtmos.Density=0.34
    baseAtmos.Haze=2.05
    baseAtmos.Decay=Color3.fromRGB(69,66,64)
end

local function carIndex(folder)
    return tonumber(string.match(folder.Name,"CAR_(%d%d)")) or 0
end

local sidePatchData={
    {-20,5.6,3.6,2.1},{-14,7.2,2.0,1.3},{-8,5.7,4.8,1.0},{-2,7.3,2.7,1.7},
    {5,5.9,3.4,1.4},{11,7.0,2.4,1.2},{17,5.8,3.0,1.8},{21,7.1,1.7,1.0}
}

local function weatherCar(car)
    local idx=carIndex(car)
    local centerZ=({[1]=-58,[2]=-5,[3]=48,[4]=101})[idx]
    if not centerZ then return end

    for _,obj in ipairs(car:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj.Name=="LowerBody" then
                obj.Color=(idx%2==0) and C.fadedRed2 or C.fadedRed
                obj.Material=Enum.Material.CorrodedMetal
            elseif obj.Name=="EndSideL" or obj.Name=="EndSideR" then
                obj.Color=C.darkRed
                obj.Material=Enum.Material.CorrodedMetal
            elseif obj.Name=="UpperRail" then
                obj.Color=C.darkRed
                obj.Material=Enum.Material.CorrodedMetal
            elseif obj.Name=="Stripe" then
                obj.Color=C.cream
                obj.Material=Enum.Material.CorrodedMetal
            elseif obj.Name=="WindowSill" or obj.Name=="WindowTop" or string.find(obj.Name,"DoorFrame") or obj.Name=="DoorHeader" then
                obj.Color=C.dullSteel
                obj.Material=Enum.Material.CorrodedMetal
            elseif obj.Name=="Bogie" then
                obj.Color=C.soot
                obj.Material=Enum.Material.CorrodedMetal
            elseif obj.Name=="Wheel" or obj.Name=="Hub" or string.find(obj.Name,"Coupler") then
                obj.Color=C.deepRust
                obj.Material=Enum.Material.CorrodedMetal
            elseif obj.Name=="RoofBand" then
                obj.Color=Color3.fromRGB(54,54,51)
                obj.Material=Enum.Material.CorrodedMetal
            end
        end
    end

    -- Lower grime skirt gives each carriage a used, oily railway base.
    for _,sx in ipairs({-1,1}) do
        local x=22+sx*8.57
        part(trainDetails,"GrimeSkirt",Vector3.new(0.16,1.25,46.5),cf(x,4.95,centerZ),C.grime,Enum.Material.CorrodedMetal,0.08,false)
        part(trainDetails,"FadedCreamLine",Vector3.new(0.12,0.34,45),cf(x,8.55,centerZ),C.cream,Enum.Material.CorrodedMetal,0.22,false)
        for pIndex,d in ipairs(sidePatchData) do
            local z,y,w,h=d[1],d[2],d[3],d[4]
            local offset=(idx-2.5)*0.18 + (sx*0.16)
            local patchColor=((pIndex+idx)%3==0) and C.deepRust or (((pIndex+idx)%2==0) and C.oxide or C.oxide2)
            part(trainDetails,"RustPatch",Vector3.new(0.13,h,w),cf(x+sx*0.03,y+offset,centerZ+z,0,(pIndex*13)%21-10,0),patchColor,Enum.Material.CorrodedMetal,0.08,false)
            if pIndex%2==0 then
                part(trainDetails,"RustDrip",Vector3.new(0.14,2.2,0.22),cf(x+sx*0.04,y-1.45,centerZ+z+w*0.18),C.deepRust,Enum.Material.CorrodedMetal,0.16,false)
            end
        end
        -- Structural ribs break the large side surface into believable railway panels.
        for dz=-21,21,7 do
            part(trainDetails,"BodyRib",Vector3.new(0.17,8.2,0.26),cf(x,9.0,centerZ+dz),C.darkRed,Enum.Material.CorrodedMetal,0.02,false)
        end
    end

    -- Roof age: dark seams plus irregular oxide bands.
    for dz=-19,19,9.5 do
        part(trainDetails,"RoofOxide",Vector3.new(5.0,0.12,2.0),cf(22+(dz%19)*0.07,17.42,centerZ+dz,0,0,(idx*7+dz)%18-9),C.oxide2,Enum.Material.CorrodedMetal,0.18,false)
    end

    -- Old carriage classification plate and faded depot stencil.
    local classPlate=part(trainDetails,"OldCarPlate",Vector3.new(0.13,2.2,7.2),cf(30.62,7.0,centerZ+13,0,90,0),C.darkRed,Enum.Material.CorrodedMetal,0,false)
    surfaceText(classPlate,Enum.NormalId.Front,string.format("TRK-01 / %02d",idx),C.cream,C.darkRed,Enum.Font.RobotoMono)

    -- Rivet rows are deliberately sparse to avoid mobile-heavy micro geometry.
    for _,z in ipairs({-18,-6,6,18}) do
        for _,sx in ipairs({-1,1}) do
            ball(trainDetails,"Rivet",Vector3.new(0.24,0.24,0.24),cf(22+sx*8.68,8.95,centerZ+z),C.deepRust,Enum.Material.CorrodedMetal)
        end
    end
end

for _,car in ipairs(train:GetChildren()) do
    if car:IsA("Folder") then weatherCar(car) end
end

-- Platform 01: old railway furniture, faded warning paint, puddles and readable landmark signage.
local function bench(parent,x,z,rot)
    for _,dz in ipairs({-2.6,0,2.6}) do
        part(parent,"BenchSlat",Vector3.new(1.1,0.5,4.7),cf(x,4.5,z+dz,0,rot or 0,0),C.oldWood2,Enum.Material.WoodPlanks,0,false)
    end
    for _,dz in ipairs({-2.9,2.9}) do
        cylinder(parent,"BenchLeg",Vector3.new(3.2,0.45,0.45),cf(x,2.85,z+dz,0,0,90),C.agedSteel,Enum.Material.CorrodedMetal,true)
    end
end

bench(platformDetails,-3,-31,0)
bench(platformDetails,-3,74,0)

for z=-126,132,22 do
    local faded=(math.abs(z)%44==0) and 0.40 or 0.18
    part(platformDetails,"FadedSafetyMark",Vector3.new(1.2,0.05,8.5),cf(11.7,2.91,z),C.cream,Enum.Material.Concrete,faded,false)
end

for _,spec in ipairs({
    {-7,2.9,-65,8.5,0.035,5.8,-9},
    {5,2.9,12,10.5,0.035,4.4,7},
    {-2,2.9,104,7.8,0.035,5.0,-4},
    {-52,0.65,48,11,0.035,6.5,11},
}) do
    local x,y,z,sx,sy,sz,ry=table.unpack(spec)
    part(platformDetails,"OldPuddle",Vector3.new(sx,sy,sz),cf(x,y,z,0,ry,0),Color3.fromRGB(36,45,47),Enum.Material.Glass,0.48,false)
end

local platformSign=part(platformDetails,"Platform01Sign",Vector3.new(18,4.2,0.55),cf(-3.7,10.6,10),C.soot,Enum.Material.CorrodedMetal,0,false)
surfaceText(platformSign,Enum.NormalId.Front,"PLATFORM 01",C.cream,C.soot,Enum.Font.GothamBlack)
part(platformDetails,"SignBracketL",Vector3.new(0.5,5.2,0.5),cf(-10.5,13.1,10),C.agedSteel,Enum.Material.CorrodedMetal,0,false)
part(platformDetails,"SignBracketR",Vector3.new(0.5,5.2,0.5),cf(3.0,13.1,10),C.agedSteel,Enum.Material.CorrodedMetal,0,false)

-- Old luggage trolley adds a curved-wheel silhouette instead of more box furniture.
part(platformDetails,"TrolleyDeck",Vector3.new(6.5,0.45,10),cf(-4,3.55,126),C.oldWood,Enum.Material.WoodPlanks,0,true)
for _,z in ipairs({122.5,129.5}) do
    for _,x in ipairs({-6.3,-1.7}) do
        cylinder(platformDetails,"TrolleyWheel",Vector3.new(0.65,2.4,2.4),cf(x,2.7,z),C.deepRust,Enum.Material.CorrodedMetal,true)
    end
end
part(platformDetails,"TrolleyHandle",Vector3.new(0.45,5.5,0.45),cf(-7.2,6.0,130,0,0,-16),C.agedSteel,Enum.Material.CorrodedMetal,0,false)

-- Station decay pass: patched plaster, ticket grille, dangling conduit and old poster frames.
for _,spec in ipairs({
    {-72.0,8.2,-132,0.10,7.0,13.0,C.plaster},
    {-72.0,5.8,-101,0.10,5.5,10.0,Color3.fromRGB(102,91,78)},
    {-39,3.0,-149.0,14.0,5.0,0.12,Color3.fromRGB(91,82,72)},
}) do
    local x,y,z,sx,sy,sz,col=table.unpack(spec)
    part(stationDetails,"PeelingPlaster",Vector3.new(sx,sy,sz),cf(x,y,z),col,Enum.Material.Concrete,0.09,false)
end

for x=-64,-44,2.5 do
    part(stationDetails,"TicketGrilleV",Vector3.new(0.16,5.0,0.16),cf(x,7.0,-132.2),C.agedSteel,Enum.Material.CorrodedMetal,0,false)
end
for y=5.1,9.0,1.3 do
    part(stationDetails,"TicketGrilleH",Vector3.new(22,0.16,0.16),cf(-54,y,-132.2),C.agedSteel,Enum.Material.CorrodedMetal,0,false)
end

for _,x in ipairs({-62,-16}) do
    local poster=part(stationDetails,"PosterFrame",Vector3.new(8.5,10.5,0.35),cf(x,8.0,-76.95),C.deepRust,Enum.Material.CorrodedMetal,0,false)
    surfaceText(poster,Enum.NormalId.Front,(x==-62) and "TONIGHT\nLAST TRAIN\n04:00" or "TRACK 01\nNO DESTINATION",C.cream,C.soot,Enum.Font.RobotoMono)
end

-- Hanging electrical conduit creates silhouettes under the canopy.
for z=-104,116,44 do
    part(stationDetails,"ConduitDrop",Vector3.new(0.3,3.5,0.3),cf(-1.5,13.0,z,0,0,5),C.deepRust,Enum.Material.CorrodedMetal,0,false)
    local bulb=ball(stationDetails,"CageBulb",Vector3.new(1.15,1.15,1.15),cf(-1.7,11.0,z),C.warm,Enum.Material.Neon)
    local l=pointLight(bulb,C.warm,0.9,13,true)
    l.Name="AmbientUpgradeLight"
end

-- Natural decay: weeds around ballast and wall edges using thin stems + small leaf clusters.
local weedPositions={
    {9,0.8,-126},{35,0.7,-94},{8,0.8,-38},{36,0.8,17},{8,0.8,88},{36,0.8,148},
    {-74,0.9,24},{-72,0.9,103},{-12,0.9,158}
}
for i,pos in ipairs(weedPositions) do
    local x,y,z=pos[1],pos[2],pos[3]
    cylinder(atmosphereDetails,"WeedStem",Vector3.new(2.6,0.18,0.18),cf(x,y+1.2,z,0,0,90),C.vegetation,Enum.Material.SmoothPlastic,false)
    for j=-1,1 do
        ball(atmosphereDetails,"WeedLeaf",Vector3.new(0.65,0.35,1.25),cf(x+j*0.28,y+1.4+j*0.25,z+j*0.4,0,i*17+j*28,j*24),Color3.fromRGB(58+j*4,71+j*3,44),Enum.Material.SmoothPlastic)
    end
end

-- Car 01: warmer waiting-car furniture and standing lamps.
local car1=train:FindFirstChild("CAR_01_SOCIAL")
if car1 then
    for _,z in ipairs({-76,-52}) do
        local stem=cylinder(trainDetails,"Car01LampStem",Vector3.new(5.5,0.28,0.28),cf(17.4,8.0,z,0,0,90),C.dullSteel,Enum.Material.CorrodedMetal,false)
        local shade=part(trainDetails,"Car01LampShade",Vector3.new(1.9,1.0,1.9),cf(17.4,10.8,z),C.warm,Enum.Material.Neon,0.15,false)
        pointLight(shade,C.warm,0.55,8,false)
    end
end

-- Car 02: usable visual bar stools and brass foot rail.
local car2=train:FindFirstChild("CAR_02_BAR")
if car2 then
    for z=-17,8,5 do
        cylinder(trainDetails,"BarStoolSeat",Vector3.new(0.6,2.8,2.8),cf(21.9,7.2,z,0,0,90),Color3.fromRGB(64,46,38),Enum.Material.SmoothPlastic,true)
        cylinder(trainDetails,"BarStoolStem",Vector3.new(3.0,0.35,0.35),cf(21.9,5.55,z,0,0,90),C.deepRust,Enum.Material.CorrodedMetal,true)
        cylinder(trainDetails,"BarStoolFoot",Vector3.new(0.32,2.0,2.0),cf(21.9,4.35,z,0,0,90),C.dullSteel,Enum.Material.CorrodedMetal,false)
    end
    part(trainDetails,"BarFootRail",Vector3.new(0.38,0.38,30),cf(22.9,5.2,-5),Color3.fromRGB(126,96,54),Enum.Material.Metal,0,false)
end

-- Car 03: dark dance floor strips and industrial cable runs.
local car3=train:FindFirstChild("CAR_03_DANCE")
if car3 then
    for z=31,65,4.25 do
        part(trainDetails,"DanceFloorStrip",Vector3.new(12.5,0.05,1.8),cf(22,4.73,z),((math.floor(z)%2)==0) and C.darkRed or C.soot,Enum.Material.Metal,0.08,false)
    end
    for _,x in ipairs({17.0,27.0}) do
        part(trainDetails,"DanceCableRun",Vector3.new(0.28,0.28,36),cf(x,14.0,48),C.deepRust,Enum.Material.CorrodedMetal,0,false)
    end
end

-- Car 04: hero room receives extra aged control hardware and asymmetrical light bars.
local car4=train:FindFirstChild("CAR_04_END_OF_LINE")
if car4 then
    for _,x in ipairs({18.6,20.3,23.7,25.4}) do
        local button=ball(trainDetails,"DJControlLamp",Vector3.new(0.45,0.45,0.45),cf(x,10.65,116.0),(x<22) and C.amber or C.signalRed,Enum.Material.Neon)
        pointLight(button,button.Color,0.22,4,false)
    end
    for _,z in ipairs({84,93,102,111}) do
        local fixture=part(trainDetails,"HeroSideLight",Vector3.new(0.3,3.6,0.3),cf((z%2==0) and 15.0 or 29.0,11.2,z),C.signalRed,Enum.Material.Neon,0,false)
        local l=pointLight(fixture,C.signalRed,0.72,10,false)
        l.Name="PulseLight"
        fixture.Parent=lightsFolder
    end
    local floorMark=part(trainDetails,"EndFloorStencil",Vector3.new(10.5,0.05,3.0),cf(22,4.75,108),C.soot,Enum.Material.Metal,0,false)
    surfaceText(floorMark,Enum.NormalId.Top,"END OF LINE",C.cream,C.soot,Enum.Font.GothamBlack)
end

-- THE YARD v2: string lights, fire barrel, photo wall, lounge stools and a service fence.
local photoWall=part(yardDetails,"PhotoWall",Vector3.new(1.0,12,30),cf(-76.0,6.0,76),C.darkRed,Enum.Material.CorrodedMetal,0,true)
surfaceText(photoWall,Enum.NormalId.Right,"TRACK 01\nNO DESTINATION\nJUST THE NIGHT",C.cream,C.darkRed,Enum.Font.GothamBlack)

for z=33,101,17 do
    cylinder(yardDetails,"YardStool",Vector3.new(0.65,3.6,3.6),cf(-27,3.1,z,0,0,90),C.oldWood,Enum.Material.WoodPlanks,true)
    cylinder(yardDetails,"YardStoolStem",Vector3.new(2.6,0.38,0.38),cf(-27,1.7,z,0,0,90),C.deepRust,Enum.Material.CorrodedMetal,true)
end

for _,x in ipairs({-72,-55,-38,-21}) do
    part(yardDetails,"FencePost",Vector3.new(0.55,9,0.55),cf(x,4.5,114),C.deepRust,Enum.Material.CorrodedMetal,0,true)
end
for y=2.0,7.5,1.8 do
    part(yardDetails,"FenceRail",Vector3.new(52,0.18,0.18),cf(-46.5,y,114),C.dullSteel,Enum.Material.CorrodedMetal,0,false)
end

-- String light poles and sag illusion using staggered bulbs.
for _,x in ipairs({-69,-30}) do
    part(yardDetails,"StringPole",Vector3.new(0.6,15,0.6),cf(x,7.5,44),C.deepRust,Enum.Material.CorrodedMetal,0,true)
    part(yardDetails,"StringPole",Vector3.new(0.6,15,0.6),cf(x,7.5,92),C.deepRust,Enum.Material.CorrodedMetal,0,true)
end
for i=0,8 do
    local t=i/8
    local x=-69+39*t
    local sag=12.5-(1-math.abs(t-0.5)*2)*2.1
    for _,z in ipairs({44,92}) do
        local bulb=ball(yardDetails,"StringBulb",Vector3.new(0.6,0.6,0.6),cf(x,sag,z),C.warm,Enum.Material.Neon)
        pointLight(bulb,C.warm,0.28,6,false)
    end
end

-- Fire barrel: warm landmark for the outdoor social zone.
local fireBarrel=cylinder(yardDetails,"FireBarrel",Vector3.new(4.8,3.2,3.2),cf(-60,2.7,107,0,0,90),C.deepRust,Enum.Material.CorrodedMetal,true)
local fireCore=ball(yardDetails,"FireGlow",Vector3.new(1.3,1.3,1.3),cf(-60,5.0,107),C.amber,Enum.Material.Neon)
pointLight(fireCore,C.amber,1.5,18,true)
local smoke=Instance.new("Smoke")
smoke.Color=Color3.fromRGB(91,86,79)
smoke.Opacity=0.14
smoke.RiseVelocity=2.6
smoke.Size=6
smoke.Parent=fireCore

-- Low track mist around the retired train, subtle enough not to hide navigation.
for _,z in ipairs({-79,-24,31,86,127}) do
    local vent=part(atmosphereDetails,"TrackMistVent",Vector3.new(0.4,0.4,0.4),cf(34,0.55,z),C.soot,Enum.Material.SmoothPlastic,1,false)
    local s=Instance.new("Smoke")
    s.Color=Color3.fromRGB(91,91,87)
    s.Opacity=0.065
    s.RiseVelocity=0.45
    s.Size=7
    s.Parent=vent
end

-- Selective lamp flicker: infrequent, shared, and cheap. It reinforces age without making the venue unreadable.
local flickerCandidates={}
for _,obj in ipairs(root:GetDescendants()) do
    if obj:IsA("PointLight") and (obj.Name=="AmbientUpgradeLight" or obj.Name=="PointLight") then
        if #flickerCandidates<7 then table.insert(flickerCandidates,obj) end
    end
end

task.spawn(function()
    local index=1
    while root.Parent do
        task.wait(5.5 + (index%3)*1.7)
        local l=flickerCandidates[index]
        if l and l.Parent then
            local base=l.Brightness
            l.Brightness=base*0.18
            task.wait(0.07)
            l.Brightness=base
            task.wait(0.05)
            l.Brightness=base*0.45
            task.wait(0.06)
            l.Brightness=base
        end
        index=index%math.max(1,#flickerCandidates)+1
    end
end)

Workspace:SetAttribute("ACC_TRACK01_UPGRADE_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.0.0")
print("[TRACK 01] Rusty Red venue upgrade ready v2.0.0")
