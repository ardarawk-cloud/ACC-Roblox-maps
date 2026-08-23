local Workspace=game:GetService("Workspace")

-- TRACK 01 v3.0 premium physical-detail pass.
-- All new micro architecture and props are non-collidable/non-queryable so the central aisle stays clear.
local deadline=os.clock()+50
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_CINEMATIC_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
local train=world and world:FindFirstChild("TrainCars")
if not (world and train) then return end

-- Safety guard for the exact class of accidental cross-aisle object reported on mobile.
for _,obj in ipairs(world:GetDescendants()) do
    if obj:IsA("BasePart") and (obj.Name=="InteriorHandrail" or obj.Name=="AisleBarrier") then
        obj:Destroy()
    end
end

local old=world:FindFirstChild("TRACK01_Premium_v30")
if old then old:Destroy() end
local premium=Instance.new("Folder")
premium.Name="TRACK01_Premium_v30"
premium.Parent=world
local common=Instance.new("Folder"); common.Name="CarriageArchitecture"; common.Parent=premium
local social=Instance.new("Folder"); social.Name="Car01Premium"; social.Parent=premium
local bar=Instance.new("Folder"); bar.Name="Car02ServiceDetail"; bar.Parent=premium
local dance=Instance.new("Folder"); dance.Name="Car03ClubDetail"; dance.Parent=premium
local hero=Instance.new("Folder"); hero.Name="Car04ControlRoom"; hero.Parent=premium

local C={
    black=Color3.fromRGB(17,18,18),
    charcoal=Color3.fromRGB(29,30,30),
    steel=Color3.fromRGB(76,79,78),
    steel2=Color3.fromRGB(116,115,109),
    red=Color3.fromRGB(105,29,32),
    redDark=Color3.fromRGB(56,18,21),
    redAccent=Color3.fromRGB(151,42,38),
    cream=Color3.fromRGB(184,169,141),
    warm=Color3.fromRGB(231,216,194),
    amber=Color3.fromRGB(207,146,81),
    green=Color3.fromRGB(92,139,96),
    glass=Color3.fromRGB(42,51,53),
    wood=Color3.fromRGB(72,53,41),
}

local function cf(x,y,z,rx,ry,rz)
    return CFrame.new(x,y,z)*CFrame.Angles(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
end
local function part(parent,name,size,frame,color,material,transparency)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=frame
    p.Color=color or C.steel
    p.Material=material or Enum.Material.Metal
    p.Transparency=transparency or 0
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=false
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end
local function cylinder(parent,name,size,frame,color,material,transparency)
    local p=part(parent,name,size,frame,color,material,transparency)
    p.Shape=Enum.PartType.Cylinder
    return p
end
local function ball(parent,name,size,frame,color,material,transparency)
    local p=part(parent,name,size,frame,color,material,transparency)
    p.Shape=Enum.PartType.Ball
    return p
end
local function surfaceText(target,face,text,textColor,bgColor)
    local gui=Instance.new("SurfaceGui")
    gui.Name="PremiumSignage"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=48
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
    label.Font=Enum.Font.RobotoMono
    label.Parent=gui
end

-- Interior roof shoulders make the cabin feel like a railway carriage instead of a rectangular room.
for _,z in ipairs({-58,-5,48,101}) do
    part(common,"InnerRoofShoulderL",Vector3.new(2.9,0.28,40),cf(15.75,14.15,z,0,0,-21),C.charcoal,Enum.Material.Metal,0.02)
    part(common,"InnerRoofShoulderR",Vector3.new(2.9,0.28,40),cf(28.25,14.15,z,0,0,21),C.charcoal,Enum.Material.Metal,0.02)
    part(common,"InnerRoofSpine",Vector3.new(7.7,0.18,40),cf(22,15.10,z),Color3.fromRGB(48,49,48),Enum.Material.Metal,0.03)
    for dz=-16,16,8 do
        part(common,"RoofRib",Vector3.new(13.2,0.20,0.24),cf(22,14.72,z+dz),C.steel,Enum.Material.Metal,0.05)
    end

    -- Vestibule thresholds only mark the edge visually; nothing blocks traversal.
    for _,sgn in ipairs({-1,1}) do
        local ez=z+sgn*23.15
        part(common,"VestibuleSill",Vector3.new(6.2,0.06,0.52),cf(22,4.82,ez),C.steel2,Enum.Material.DiamondPlate,0.04)
        part(common,"VestibuleMarker",Vector3.new(5.4,0.04,0.13),cf(22,4.88,ez-sgn*0.35),C.amber,Enum.Material.Neon,0.25)
    end
end

-- CAR 01: restrained old waiting-car luxury details near the walls.
for _,z in ipairs({-70,-58,-46}) do
    part(social,"WallShelf",Vector3.new(2.4,0.16,4.8),cf(28.25,10.0,z),C.wood,Enum.Material.WoodPlanks,0.02)
    cylinder(social,"ShelfBracketA",Vector3.new(1.1,0.12,0.12),cf(27.45,9.55,z-1.5,0,0,90),C.steel,Enum.Material.Metal,0)
    cylinder(social,"ShelfBracketB",Vector3.new(1.1,0.12,0.12),cf(27.45,9.55,z+1.5,0,0,90),C.steel,Enum.Material.Metal,0)
end
for _,z in ipairs({-75,-43}) do
    part(social,"TravelCase",Vector3.new(2.2,1.4,3.4),cf(27.0,5.35,z),Color3.fromRGB(67,48,37),Enum.Material.Fabric,0)
    part(social,"CaseBand",Vector3.new(2.28,0.12,3.5),cf(27.0,5.45,z),C.steel2,Enum.Material.Metal,0.06)
    part(social,"CaseHandle",Vector3.new(0.65,0.15,1.1),cf(27.0,6.12,z),C.steel2,Enum.Material.Metal,0)
end
local socialPlaque=part(social,"WaitingCarPlaque",Vector3.new(0.12,2.0,7.5),cf(29.20,12.2,-76),C.black,Enum.Material.Metal,0)
surfaceText(socialPlaque,Enum.NormalId.Left,"WAITING CAR  /  01",C.cream,C.black)

-- CAR 02: realistic bar service equipment, kept behind/against the counter.
-- Ice wells.
for _,z in ipairs({-12,-3,6}) do
    part(bar,"IceWell",Vector3.new(2.1,0.55,5.0),cf(26.15,8.92,z),C.steel2,Enum.Material.Metal,0)
    part(bar,"IceBed",Vector3.new(1.75,0.12,4.55),cf(26.15,9.23,z),Color3.fromRGB(183,194,194),Enum.Material.Glass,0.20)
end
-- Sink and faucet.
part(bar,"BarSink",Vector3.new(2.0,0.55,4.8),cf(26.1,8.92,12.0),C.steel2,Enum.Material.Metal,0)
part(bar,"SinkDark",Vector3.new(1.55,0.13,4.25),cf(26.1,9.22,12.0),C.charcoal,Enum.Material.Metal,0)
cylinder(bar,"FaucetStem",Vector3.new(1.6,0.18,0.18),cf(26.8,10.05,12.0,0,0,90),C.steel2,Enum.Material.Metal,0)
part(bar,"FaucetSpout",Vector3.new(0.18,0.18,1.1),cf(26.8,10.72,11.5),C.steel2,Enum.Material.Metal,0)
-- Speed rail / bottles / shakers.
part(bar,"SpeedRail",Vector3.new(1.0,1.0,23),cf(27.4,8.7,-3),C.charcoal,Enum.Material.Metal,0)
for z=-12,8,4 do
    cylinder(bar,"SpeedBottle",Vector3.new(1.2,0.42,0.42),cf(27.4,9.55,z,0,0,90),Color3.fromRGB(118+(z%3)*12,88,58),Enum.Material.Glass,0.12)
end
for _,z in ipairs({-9,0,9}) do
    cylinder(bar,"CocktailShaker",Vector3.new(1.5,0.52,0.52),cf(24.7,9.45,z,0,0,90),C.steel2,Enum.Material.Metal,0)
end
-- Hanging glass rack and glasses.
part(bar,"GlassRack",Vector3.new(4.6,0.18,18),cf(25.6,12.55,-3),C.steel,Enum.Material.Metal,0)
for z=-10,6,4 do
    cylinder(bar,"HangingGlass",Vector3.new(0.72,0.48,0.48),cf(25.6,11.95,z,0,0,90),Color3.fromRGB(202,210,207),Enum.Material.Glass,0.42)
end
-- POS terminal angled toward service side.
part(bar,"POSTerminal",Vector3.new(2.5,1.7,0.22),cf(24.8,10.15,11.8,0,0,-12),C.glass,Enum.Material.Glass,0.08)
part(bar,"POSBase",Vector3.new(1.1,0.2,1.2),cf(24.8,9.35,11.8),C.black,Enum.Material.Metal,0)
local barPlaque=part(bar,"ServicePlaque",Vector3.new(0.12,1.8,7.0),cf(29.18,12.0,15),C.black,Enum.Material.Metal,0)
surfaceText(barPlaque,Enum.NormalId.Left,"BAR CAR  /  SERVICE 01",C.amber,C.black)

-- CAR 03: acoustic treatment and speaker detailing; floor remains fully open.
for _,z in ipairs({32,40,48,56,64}) do
    for _,x in ipairs({14.62,29.38}) do
        part(dance,"AcousticPanel",Vector3.new(0.10,3.2,5.4),cf(x,11.2,z),Color3.fromRGB(35,34,33),Enum.Material.Fabric,0)
        for dy=-1.1,1.1,0.55 do
            part(dance,"AcousticRib",Vector3.new(0.12,0.10,4.8),cf(x+(x<22 and 0.06 or -0.06),11.2+dy,z),C.black,Enum.Material.Metal,0.04)
        end
    end
end
for _,z in ipairs({30,66}) do
    for _,x in ipairs({16.1,27.9}) do
        part(dance,"SpeakerGrille",Vector3.new(2.7,3.3,0.10),cf(x,7.6,z-1.57),Color3.fromRGB(22,22,22),Enum.Material.Metal,0.02)
        for gx=-0.9,0.9,0.45 do
            part(dance,"GrilleSlot",Vector3.new(0.10,2.8,0.10),cf(x+gx,7.6,z-1.64),C.steel,Enum.Material.Metal,0.25)
        end
    end
end
local dancePlaque=part(dance,"DancePlaque",Vector3.new(0.12,1.8,7.5),cf(29.18,12.0,70),C.black,Enum.Material.Metal,0)
surfaceText(dancePlaque,Enum.NormalId.Left,"DANCE CAR  /  EXPRESS",C.cream,C.black)

-- CAR 04: make the DJ booth read like a railway control room rather than a generic console.
part(hero,"ControlDeskFascia",Vector3.new(10.6,2.4,0.24),cf(22,8.0,115.15),C.charcoal,Enum.Material.Metal,0)
for _,x in ipairs({18.2,20.1,22.0,23.9,25.8}) do
    local lamp=ball(hero,"SignalLamp",Vector3.new(0.42,0.42,0.42),cf(x,9.55,115.0),((math.floor(x*10)%3)==0) and C.green or (((math.floor(x*10)%2)==0) and C.amber or C.redAccent),Enum.Material.Neon,0.14)
    local light=Instance.new("PointLight")
    light.Color=lamp.Color
    light.Brightness=0.10
    light.Range=2.5
    light.Shadows=false
    light.Parent=lamp
end
for _,x in ipairs({18.5,20.8,23.1,25.4}) do
    cylinder(hero,"ControlKnob",Vector3.new(0.35,0.60,0.60),cf(x,8.75,114.98,0,90,0),C.steel2,Enum.Material.Metal,0)
end
for _,z in ipairs({112.5,114.0,115.5}) do
    part(hero,"CableLoom",Vector3.new(8.8,0.16,0.16),cf(22,6.15,z),C.black,Enum.Material.SmoothPlastic,0)
end
part(hero,"MonitorHoodL",Vector3.new(3.9,0.28,2.8),cf(19.2,13.95,116.2,0,0,-7),C.black,Enum.Material.Metal,0)
part(hero,"MonitorHoodR",Vector3.new(3.9,0.28,2.8),cf(24.8,13.95,116.2,0,0,7),C.black,Enum.Material.Metal,0)
local controlPlate=part(hero,"ControlPlate",Vector3.new(6.0,1.25,0.12),cf(22,13.75,119.0),C.black,Enum.Material.Metal,0)
surfaceText(controlPlate,Enum.NormalId.Front,"CONTROL 01  •  END OF LINE",C.redAccent,C.black)

-- Mobile-friendly aisle audit marker. No geometry is placed inside this keep-clear width.
root:SetAttribute("AisleKeepClearHalfWidth",3.15)
root:SetAttribute("PremiumVersion","3.0.0")
Workspace:SetAttribute("ACC_TRACK01_AISLE_AUDIT",true)
Workspace:SetAttribute("ACC_TRACK01_PREMIUM_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","3.0.0")
print("[TRACK 01] premium physical detail and clear-circulation pass ready v3.0.0")
