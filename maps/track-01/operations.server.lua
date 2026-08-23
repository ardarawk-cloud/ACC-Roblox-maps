local Workspace=game:GetService("Workspace")

-- TRACK 01 v2.7 operational-realism pass.
-- Adds physical club functions inside the old station without changing audio or using assets.
local deadline=os.clock()+50
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_ATMOSPHERE_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local architecture=world and world:FindFirstChild("Architecture")
if not (world and architecture) then return end

local old=world:FindFirstChild("TRACK01_Operations_v27")
if old then old:Destroy() end
local ops=Instance.new("Folder")
ops.Name="TRACK01_Operations_v27"
ops.Parent=world
local security=Instance.new("Folder"); security.Name="SecurityCheckIn"; security.Parent=ops
local lockers=Instance.new("Folder"); lockers.Name="LockerBank"; lockers.Parent=ops
local facilities=Instance.new("Folder"); facilities.Name="Facilities"; facilities.Parent=ops
local wayfinding=Instance.new("Folder"); wayfinding.Name="Wayfinding"; wayfinding.Parent=ops

local C={
    black=Color3.fromRGB(17,18,18),
    charcoal=Color3.fromRGB(29,30,30),
    steel=Color3.fromRGB(74,76,74),
    steel2=Color3.fromRGB(105,105,100),
    rust=Color3.fromRGB(88,47,36),
    red=Color3.fromRGB(111,31,34),
    cream=Color3.fromRGB(172,153,117),
    warm=Color3.fromRGB(240,219,193),
    amber=Color3.fromRGB(241,161,79),
    green=Color3.fromRGB(79,116,81),
    concrete=Color3.fromRGB(74,71,66),
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
local function pointLight(parent,color,brightness,range)
    local l=Instance.new("PointLight")
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Shadows=false
    l.Parent=parent
    return l
end
local function surfaceText(target,face,text,textColor,bgColor,font)
    local gui=Instance.new("SurfaceGui")
    gui.Name="OpsSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=44
    gui.LightInfluence=0.25
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

-- Security/check-in: open enough to preserve movement through the station hall.
for _,x in ipairs({-46,-32}) do
    part(security,"SecurityArchPost",Vector3.new(0.65,8.0,0.65),cf(x,5.0,-88),C.charcoal,Enum.Material.Metal,0,true)
end
part(security,"SecurityArchTop",Vector3.new(14.7,0.65,0.65),cf(-39,9.0,-88),C.charcoal,Enum.Material.Metal,0,true)
local checkSign=part(security,"CheckInSign",Vector3.new(11.5,2.2,0.26),cf(-39,7.7,-87.6),C.black,Enum.Material.Metal,0,false)
surfaceText(checkSign,Enum.NormalId.Front,"SECURITY  /  CHECK-IN",C.cream,C.black,Enum.Font.GothamBold)
for _,x in ipairs({-50,-28}) do
    local desk=part(security,"SecurityDesk",Vector3.new(8.0,3.3,2.4),cf(x,2.8,-96),C.charcoal,Enum.Material.Metal,0,true)
    part(security,"DeskTop",Vector3.new(8.4,0.28,2.8),cf(x,4.55,-96),C.steel2,Enum.Material.Metal,0,false)
    local lamp=part(security,"DeskLamp",Vector3.new(1.1,0.18,1.1),cf(x,5.2,-96),C.warm,Enum.Material.Neon,0.18,false)
    pointLight(lamp,C.warm,0.26,6)
end

-- Queue rails leading toward the ticket counter; narrow, old-station style.
for _,x in ipairs({-62,-54,-46}) do
    cylinder(security,"QueuePost",Vector3.new(3.5,0.30,0.30),cf(x,3.0,-120,0,0,90),C.steel,Enum.Material.Metal,0,true)
    cylinder(security,"QueuePost",Vector3.new(3.5,0.30,0.30),cf(x,3.0,-127,0,0,90),C.steel,Enum.Material.Metal,0,true)
end
for _,z in ipairs({-120,-127}) do
    part(security,"QueueRail",Vector3.new(16.0,0.22,0.22),cf(-54,4.5,z),C.steel2,Enum.Material.Metal,0,false)
end

-- Locker bank along the left/back side of the hall.
for row=0,1 do
    for col=0,5 do
        local x=-68.2
        local y=4.3+row*5.1
        local z=-128+col*5.0
        part(lockers,"LockerBody",Vector3.new(2.0,4.6,4.4),cf(x,y,z),Color3.fromRGB(58,61,59),Enum.Material.Metal,0,true)
        part(lockers,"LockerDoor",Vector3.new(0.14,4.0,3.8),cf(-67.1,y,z),Color3.fromRGB(68,71,68),Enum.Material.Metal,0,false)
        part(lockers,"LockerVent",Vector3.new(0.10,0.18,2.0),cf(-67.0,y+1.35,z),C.black,Enum.Material.Metal,0,false)
        part(lockers,"LockerHandle",Vector3.new(0.12,0.75,0.18),cf(-66.95,y,z+1.35),C.steel2,Enum.Material.Metal,0,false)
    end
end
local lockerSign=part(lockers,"LockerSign",Vector3.new(0.24,2.6,12.0),cf(-66.8,10.8,-115),C.black,Enum.Material.Metal,0,false)
surfaceText(lockerSign,Enum.NormalId.Right,"LOCKERS  01–12",C.amber,C.black)

-- Back-wall facility doors: TOILETS and OPERATIONS.
for _,spec in ipairs({{-24,"TOILETS"},{-51,"OPERATIONS"}}) do
    local x,label=spec[1],spec[2]
    part(facilities,"FacilityDoor",Vector3.new(8.0,8.5,0.35),cf(x,5.3,-148.8),C.charcoal,Enum.Material.Metal,0,true)
    part(facilities,"DoorKick",Vector3.new(7.2,1.4,0.14),cf(x,2.1,-148.55),C.steel,Enum.Material.DiamondPlate,0,false)
    cylinder(facilities,"DoorHandle",Vector3.new(0.18,0.75,0.75),cf(x+2.7,5.2,-148.45,0,90,0),C.steel2,Enum.Material.Metal,0,false)
    local sign=part(facilities,"FacilitySign",Vector3.new(7.4,1.8,0.16),cf(x,10.2,-148.5),C.black,Enum.Material.Metal,0,false)
    surfaceText(sign,Enum.NormalId.Front,label,C.cream,C.black,Enum.Font.GothamBold)
end

-- Practical safety details make the venue feel operated rather than abandoned and empty.
for _,spec in ipairs({{-8,-101},{-8,-132},{-67,-92}}) do
    local x,z=spec[1],spec[2]
    cylinder(facilities,"Extinguisher",Vector3.new(2.4,0.70,0.70),cf(x,2.4,z,0,0,90),Color3.fromRGB(138,38,34),Enum.Material.Metal,0,false)
    part(facilities,"ExtinguisherBracket",Vector3.new(0.22,2.6,1.6),cf(x-0.4,2.5,z),C.black,Enum.Material.Metal,0,false)
end
local firstAid=part(facilities,"FirstAidCabinet",Vector3.new(0.45,3.2,3.2),cf(-5.5,7.0,-115,0,90,0),Color3.fromRGB(221,218,203),Enum.Material.Metal,0,false)
surfaceText(firstAid,Enum.NormalId.Front,"+",Color3.fromRGB(66,115,74),Color3.fromRGB(221,218,203),Enum.Font.GothamBlack)

-- Physical wayfinding sequence from hall to platform/yard.
local hallWay=part(wayfinding,"HallWayfinder",Vector3.new(18.0,5.5,0.36),cf(-7.0,10.6,-91,0,90,0),C.black,Enum.Material.Metal,0,false)
surfaceText(hallWay,Enum.NormalId.Front,"PLATFORM 01  →\nCAR 01–04  →\nTHE YARD  ↗",C.cream,C.black,Enum.Font.RobotoMono)
local platformWay=part(wayfinding,"PlatformWayfinder",Vector3.new(0.28,4.0,15.0),cf(-8.6,9.0,-60),C.black,Enum.Material.Metal,0,false)
surfaceText(platformWay,Enum.NormalId.Right,"BOARDING\nCAR 01  SOCIAL\nCAR 02  BAR\nCAR 03  DANCE\nCAR 04  END OF LINE",C.cream,C.black,Enum.Font.RobotoMono)

-- Low guide lights through the hall toward the platform; no global brightness increase.
for _,z in ipairs({-111,-101,-91,-81,-71}) do
    for _,x in ipairs({-16,-8}) do
        local guide=part(wayfinding,"FloorGuide",Vector3.new(1.6,0.08,0.22),cf(x,1.08,z),C.amber,Enum.Material.Neon,0.28,false)
        pointLight(guide,C.amber,0.10,3)
    end
end

root:SetAttribute("OperationsVersion","2.7.0")
Workspace:SetAttribute("ACC_TRACK01_OPERATIONS_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.7.0")
print("[TRACK 01] operational realism ready v2.7.0")
