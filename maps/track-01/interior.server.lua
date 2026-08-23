local Workspace=game:GetService("Workspace")

-- TRACK 01 v2.5 interior-experience pass.
-- No audio assets are created or referenced here. This pass only upgrades physical
-- interior architecture, furniture, club fixtures and lighting.
local deadline=os.clock()+40
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_PROFILE_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local train=world and world:FindFirstChild("TrainCars")
local lightsFolder=root:FindFirstChild("DynamicLights")
if not (world and train and lightsFolder) then return end

local old=world:FindFirstChild("TRACK01_Interior_v25")
if old then old:Destroy() end
local interior=Instance.new("Folder")
interior.Name="TRACK01_Interior_v25"
interior.Parent=world
local car1Detail=Instance.new("Folder"); car1Detail.Name="Car01SocialDetail"; car1Detail.Parent=interior
local car2Detail=Instance.new("Folder"); car2Detail.Name="Car02BarDetail"; car2Detail.Parent=interior
local car3Detail=Instance.new("Folder"); car3Detail.Name="Car03DanceDetail"; car3Detail.Parent=interior
local car4Detail=Instance.new("Folder"); car4Detail.Name="Car04HeroDetail"; car4Detail.Parent=interior

local C={
    black=Color3.fromRGB(17,18,18),
    charcoal=Color3.fromRGB(28,29,29),
    steel=Color3.fromRGB(78,80,78),
    steel2=Color3.fromRGB(112,111,105),
    red=Color3.fromRGB(108,29,32),
    redDark=Color3.fromRGB(58,19,22),
    cream=Color3.fromRGB(172,153,117),
    warm=Color3.fromRGB(240,220,195),
    amber=Color3.fromRGB(241,161,79),
    signal=Color3.fromRGB(184,42,36),
    wood=Color3.fromRGB(74,53,40),
    upholstery=Color3.fromRGB(61,47,43),
    glass=Color3.fromRGB(31,44,48),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z)*CFrame.Angles(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
end
local function part(parent,name,size,frame,color,material,transparency,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color or C.steel
    p.Material=material or Enum.Material.Metal
    p.Anchored=true
    p.CanCollide=collide==true
    p.CanTouch=false
    p.CanQuery=true
    p.Transparency=transparency or 0
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end
local function cylinder(parent,name,size,frame,color,material,transparency,collide)
    local p=part(parent,name,size,frame,color,material,transparency,collide)
    p.Shape=Enum.PartType.Cylinder
    return p
end
local function pointLight(parent,color,brightness,range,shadows)
    local l=Instance.new("PointLight")
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Shadows=shadows==true
    l.Parent=parent
    return l
end
local function spotLight(parent,color,brightness,range,angle,face)
    local l=Instance.new("SpotLight")
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Angle=angle
    l.Face=face or Enum.NormalId.Bottom
    l.Shadows=false
    l.Parent=parent
    return l
end
local function surfaceText(target,face,text,textColor,bgColor,font)
    local gui=Instance.new("SurfaceGui")
    gui.Name="InteriorSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=44
    gui.LightInfluence=0.30
    gui.Parent=target
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bgColor or C.black
    label.BackgroundTransparency=0.08
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=textColor or C.cream
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=font or Enum.Font.RobotoMono
    label.Parent=gui
end

-- Common carriage details: waist handrail, old ventilation grilles and readable thresholds.
for _,spec in ipairs({{-58,1},{-5,2},{48,3},{101,4}}) do
    local z,idx=spec[1],spec[2]
    for _,x in ipairs({15.1,28.9}) do
        cylinder(interior,"InteriorHandrail",Vector3.new(38,0.24,0.24),cf(x,9.3,z,90,0,0),C.steel2,Enum.Material.Metal,0,false)
    end
    for _,dz in ipairs({-17,17}) do
        part(interior,"VentGrille",Vector3.new(4.8,0.18,2.2),cf(22,14.68,z+dz),C.charcoal,Enum.Material.Metal,0.05,false)
        for gx=-1.8,1.8,0.9 do
            part(interior,"VentSlat",Vector3.new(0.12,0.22,2.0),cf(22+gx,14.81,z+dz),C.black,Enum.Material.Metal,0,false)
        end
    end
    local floorStripe=part(interior,"DoorFloorMark",Vector3.new(5.8,0.05,1.0),cf(14.6,4.73,z+0.5),idx>=3 and C.signal or C.cream,Enum.Material.SmoothPlastic,0.18,false)
    floorStripe.CanQuery=false
end

-- CAR 01 / SOCIAL: warm waiting-car lounge, old railway racks and understated premium detailing.
for _,z in ipairs({-72,-60,-48}) do
    part(car1Detail,"SeatPlinth",Vector3.new(5.0,0.45,8.3),cf(26.5,5.35,z),C.black,Enum.Material.Metal,0,false)
    part(car1Detail,"SeatPiping",Vector3.new(5.0,0.18,8.1),cf(26.46,6.70,z),C.cream,Enum.Material.SmoothPlastic,0.42,false)
    cylinder(car1Detail,"TableRim",Vector3.new(0.18,3.95,3.95),cf(20.5,7.28,z,0,0,90),C.steel2,Enum.Material.Metal,0,false)
end
for _,z in ipairs({-74,-62,-50,-42}) do
    part(car1Detail,"LuggageRack",Vector3.new(5.2,0.24,6.0),cf(27.3,13.8,z),C.steel,Enum.Material.Metal,0,false)
    for dz=-2.4,2.4,2.4 do
        cylinder(car1Detail,"RackTube",Vector3.new(5.0,0.18,0.18),cf(27.3,13.95,z+dz,0,0,90),C.steel2,Enum.Material.Metal,0,false)
    end
end
for _,z in ipairs({-70,-58,-46}) do
    local sconce=part(car1Detail,"WallSconce",Vector3.new(0.35,1.0,2.2),cf(29.35,10.9,z),C.warm,Enum.Material.Neon,0.18,false)
    pointLight(sconce,C.warm,0.36,8,false)
end
local socialBoard=part(car1Detail,"SocialBoard",Vector3.new(0.18,3.0,10.5),cf(29.2,11.0,-38),C.black,Enum.Material.Metal,0,false)
surfaceText(socialBoard,Enum.NormalId.Left,"WAITING CAR\nSOCIAL  •  LOUNGE\nNEXT STOP: BAR",C.cream,C.black)

-- CAR 02 / BAR: more believable service bar with shelving, taps, fridge fronts and pendant pools.
for _,z in ipairs({-17,-9,-1,7}) do
    part(car2Detail,"BottleShelf",Vector3.new(0.55,0.22,6.4),cf(28.45,10.5,z),C.steel,Enum.Material.Metal,0,false)
    part(car2Detail,"BottleShelfLip",Vector3.new(0.20,0.25,6.4),cf(28.10,10.65,z),C.steel2,Enum.Material.Metal,0,false)
end
for _,z in ipairs({-14,-6,2,10}) do
    part(car2Detail,"FridgeDoor",Vector3.new(0.18,2.8,5.7),cf(28.5,6.45,z),C.charcoal,Enum.Material.Metal,0,false)
    part(car2Detail,"FridgeGlass",Vector3.new(0.10,2.0,4.8),cf(28.36,6.55,z),C.glass,Enum.Material.Glass,0.35,false)
    part(car2Detail,"FridgeHandle",Vector3.new(0.18,1.3,0.18),cf(28.18,6.5,z+2.0),C.steel2,Enum.Material.Metal,0,false)
end
for _,z in ipairs({-12,-4,4}) do
    cylinder(car2Detail,"BeerTapStem",Vector3.new(2.1,0.28,0.28),cf(24.0,9.8,z,0,0,90),C.steel2,Enum.Material.Metal,0,false)
    part(car2Detail,"BeerTapHead",Vector3.new(0.55,0.9,0.55),cf(24.0,10.75,z),C.black,Enum.Material.Metal,0,false)
end
for _,z in ipairs({-15,-5,5}) do
    local pendant=part(car2Detail,"BarPendant",Vector3.new(1.6,0.24,1.6),cf(23.2,13.5,z),C.amber,Enum.Material.Neon,0.16,false)
    spotLight(pendant,C.warm,0.55,10,70,Enum.NormalId.Bottom)
    cylinder(car2Detail,"PendantStem",Vector3.new(1.6,0.16,0.16),cf(23.2,14.35,z,0,0,90),C.black,Enum.Material.Metal,0,false)
end
part(car2Detail,"BarFootRail",Vector3.new(0.35,0.35,30),cf(22.9,5.15,-5),C.steel2,Enum.Material.Metal,0,false)
local barPlate=part(car2Detail,"BarServicePlate",Vector3.new(0.16,2.0,8.0),cf(29.0,13.7,10),C.black,Enum.Material.Metal,0,false)
surfaceText(barPlate,Enum.NormalId.Left,"BAR CAR\nSERVICE 01",C.amber,C.black)

-- CAR 03 / DANCE: clearer floor geometry, side benches, sub-bass silhouettes and controlled club lighting.
for _,z in ipairs({35,43,51,59}) do
    local tile=part(car3Detail,"DanceFloorPanel",Vector3.new(10.5,0.08,6.4),cf(22,4.77,z),((z/8)%2<1) and C.charcoal or Color3.fromRGB(39,39,37),Enum.Material.Metal,0,false)
    tile.CanQuery=false
    part(car3Detail,"FloorJoint",Vector3.new(10.6,0.10,0.14),cf(22,4.83,z+3.15),C.steel,Enum.Material.Metal,0.12,false)
end
for _,z in ipairs({36,60}) do
    part(car3Detail,"SideBenchSeat",Vector3.new(3.5,1.0,8.0),cf(27.2,5.9,z),C.upholstery,Enum.Material.Fabric,0,false)
    part(car3Detail,"SideBenchBack",Vector3.new(0.8,3.5,8.0),cf(28.55,7.5,z),Color3.fromRGB(52,41,38),Enum.Material.Fabric,0,false)
end
for _,x in ipairs({16.0,28.0}) do
    for _,z in ipairs({31,65}) do
        part(car3Detail,"SubBass",Vector3.new(3.2,3.8,3.0),cf(x,6.3,z),C.black,Enum.Material.Metal,0,false)
        cylinder(car3Detail,"SubDriver",Vector3.new(0.22,2.2,2.2),cf(x,6.3,z-1.55,0,90,0),Color3.fromRGB(29,29,29),Enum.Material.SmoothPlastic,0,false)
    end
end
for _,spec in ipairs({{18,38,C.amber},{26,46,C.signal},{18,54,C.signal},{26,62,C.amber}}) do
    local x,z,col=spec[1],spec[2],spec[3]
    local head=part(car3Detail,"DanceHead",Vector3.new(1.0,0.8,1.2),cf(x,14.2,z),C.black,Enum.Material.Metal,0,false)
    local s=spotLight(head,col,0.70,14,48,Enum.NormalId.Bottom)
    s.Name="PulseLight"
    head.Parent=lightsFolder
end
local danceBoard=part(car3Detail,"DanceBoard",Vector3.new(0.16,2.4,10.0),cf(29.15,11.8,68),C.black,Enum.Material.Metal,0,false)
surfaceText(danceBoard,Enum.NormalId.Left,"DANCE CAR\nLOCAL EXPRESS\nNEXT: END OF LINE",C.cream,C.black)

-- CAR 04 / END OF LINE: railway-control-room DJ booth with meters, signal levers and monitor stack.
part(car4Detail,"BoothBackplate",Vector3.new(12.2,4.2,0.28),cf(22,11.7,119.2),C.charcoal,Enum.Material.Metal,0,false)
for _,x in ipairs({18.4,20.8,23.2,25.6}) do
    local meter=part(car4Detail,"AnalogMeter",Vector3.new(1.65,1.65,0.18),cf(x,12.2,119.0),Color3.fromRGB(208,197,169),Enum.Material.SmoothPlastic,0,false)
    cylinder(car4Detail,"MeterNeedle",Vector3.new(0.10,0.85,0.10),cf(x,12.2,118.88,0,0,(x*13)%45-22),C.signal,Enum.Material.Metal,0,false)
end
for _,x in ipairs({18.6,21.0,23.4,25.8}) do
    cylinder(car4Detail,"SignalLever",Vector3.new(2.7,0.30,0.30),cf(x,9.1,114.9,0,0,70),C.steel2,Enum.Material.Metal,0,false)
    local cap=part(car4Detail,"LeverCap",Vector3.new(0.65,0.65,0.65),cf(x,10.3,114.5),((math.floor(x*10)%2)==0) and C.signal or C.amber,Enum.Material.SmoothPlastic,0,false)
    cap.Shape=Enum.PartType.Ball
end
for _,x in ipairs({19.2,24.8}) do
    local screen=part(car4Detail,"DJMonitor",Vector3.new(3.6,2.4,0.22),cf(x,12.6,116.2,0,0,(x<22) and -7 or 7),C.glass,Enum.Material.Glass,0.12,false)
    local glow=Instance.new("SurfaceLight")
    glow.Face=Enum.NormalId.Front
    glow.Color=Color3.fromRGB(113,146,154)
    glow.Brightness=0.18
    glow.Range=5
    glow.Parent=screen
end
part(car4Detail,"CableTrunkL",Vector3.new(0.45,0.45,14.0),cf(16.1,5.0,113),C.black,Enum.Material.Metal,0,false)
part(car4Detail,"CableTrunkR",Vector3.new(0.45,0.45,14.0),cf(27.9,5.0,113),C.black,Enum.Material.Metal,0,false)
for z=108,120,4 do
    part(car4Detail,"CableBridge",Vector3.new(11.5,0.16,0.35),cf(22,5.0,z),C.black,Enum.Material.Rubber,0,false)
end
local controlLabel=part(car4Detail,"ControlLabel",Vector3.new(8.8,1.5,0.18),cf(22,14.1,119.0),C.black,Enum.Material.Metal,0,false)
surfaceText(controlLabel,Enum.NormalId.Front,"END OF LINE  /  CONTROL 01",C.signal,C.black)

-- Rebalance interior readability without globally brightening the whole venue.
for _,carName in ipairs({"CAR_01_SOCIAL","CAR_02_BAR"}) do
    local car=train:FindFirstChild(carName)
    if car then
        for _,obj in ipairs(car:GetDescendants()) do
            if obj:IsA("PointLight") and obj.Name~="PulseLight" then
                obj.Brightness=math.max(obj.Brightness,0.78)
                obj.Range=math.max(obj.Range,11)
            end
        end
    end
end

root:SetAttribute("InteriorVersion","2.5.0")
Workspace:SetAttribute("ACC_TRACK01_INTERIOR_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.5.0")
print("[TRACK 01] interior experience ready v2.5.0")
