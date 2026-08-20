-- BBYA SOCIAL HUB — FLOOR 1 FRONT-OF-HOUSE PREMIUM PASS v1
-- Deterministic architecture/furniture for reception, photo area, salon/look studio and entrance-to-club transition.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD")
local floor1 = root:WaitForChild("Floor1Core", 20)
if not floor1 then
    warn("[BBYA Floor1 Front] Floor1Core unavailable")
    return
end

local old = root:FindFirstChild("Floor1FrontPremium")
if old then old:Destroy() end
local out = Instance.new("Model")
out.Name = "Floor1FrontPremium"
out.Parent = root

local C = {
    black = Color3.fromRGB(8,8,11),
    charcoal = Color3.fromRGB(20,19,24),
    graphite = Color3.fromRGB(38,36,42),
    metal = Color3.fromRGB(58,55,62),
    marble = Color3.fromRGB(118,111,120),
    wood = Color3.fromRGB(78,59,48),
    fabric = Color3.fromRGB(48,41,50),
    fabric2 = Color3.fromRGB(72,56,68),
    glass = Color3.fromRGB(96,105,116),
    pink = Color3.fromRGB(255,38,155),
    cyan = Color3.fromRGB(0,205,235),
    warm = Color3.fromRGB(255,199,145),
    white = Color3.fromRGB(238,234,241),
    green = Color3.fromRGB(61,86,66),
}

local function part(name,size,cf,color,material,transparency,parent,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Color=color or C.graphite
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

local function cylinder(name,size,cf,color,material,transparency,parent)
    local p=part(name,size,cf,color,material,transparency,parent,false)
    p.Shape=Enum.PartType.Cylinder
    return p
end

local function neon(name,size,cf,color,parent)
    local p=part(name,size,cf,color or C.pink,Enum.Material.Neon,0,parent,false)
    p.CastShadow=false
    return p
end

local function model(name,parent)
    local m=Instance.new("Model")
    m.Name=name
    m.Parent=parent or out
    return m
end

local function point(parent,color,brightness,range)
    local l=Instance.new("PointLight")
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Shadows=true
    l.Parent=parent
    return l
end

local function spot(parent,color,brightness,range,angle,face)
    local l=Instance.new("SpotLight")
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Angle=angle
    l.Face=face or Enum.NormalId.Bottom
    l.Shadows=true
    l.Parent=parent
    return l
end

local function surfaceText(partObj,textValue,color,font)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.AlwaysOnTop=false
    gui.LightInfluence=.35
    gui.PixelsPerStud=60
    gui.Parent=partObj
    local label=Instance.new("TextLabel")
    label.BackgroundTransparency=1
    label.Size=UDim2.fromScale(1,1)
    label.Text=textValue
    label.TextColor3=color or C.white
    label.Font=font or Enum.Font.GothamBlack
    label.TextScaled=true
    label.Parent=gui
    return label
end

-- Remove primitive front-zone props from Floor1Core while retaining structural floors/walls.
for _,zoneName in ipairs({"02_Reception","03_PhotoArea","04_SalonLookStudio"}) do
    local zone=floor1:FindFirstChild(zoneName)
    if zone then
        for _,obj in ipairs(zone:GetChildren()) do
            if obj:IsA("BasePart") and not obj.Name:match("Floor") then
                obj:Destroy()
            end
        end
    end
end
local centerSight=floor1:FindFirstChild("CenterSightline")
if centerSight then centerSight:Destroy() end

-- RECEPTION -------------------------------------------------------------------
local reception=model("Reception")
part("ReceptionInsetWall",Vector3.new(25.5,9.3,.65),CFrame.new(0,5.25,-19.95),C.charcoal,Enum.Material.Metal,0,reception,false)
part("ReceptionStonePanel",Vector3.new(14.5,5.5,.22),CFrame.new(0,5.45,-20.34),Color3.fromRGB(47,44,50),Enum.Material.Marble,0,reception,false)
for i,x in ipairs({-11.5,-8.6,-5.7,5.7,8.6,11.5}) do
    part("WallSlat"..i,Vector3.new(.32,7.5,.18),CFrame.new(x,5.25,-20.35),C.wood,Enum.Material.WoodPlanks,0,reception,false)
end
local logoPlate=part("ReceptionLogoPlate",Vector3.new(11.5,2.35,.16),CFrame.new(0,6.0,-20.47),C.black,Enum.Material.Glass,.06,reception,false)
local logo=surfaceText(logoPlate,"BBYA",C.white,Enum.Font.GothamBlack)
local logoStroke=Instance.new("UIStroke")
logoStroke.Color=C.pink
logoStroke.Thickness=2
logoStroke.Transparency=.25
logoStroke.Parent=logo

-- Curved-feel desk built from center body + angled wings.
part("DeskCore",Vector3.new(12.5,2.7,3.5),CFrame.new(0,2.25,-25.0),C.charcoal,Enum.Material.Metal,0,reception,true)
part("DeskWingL",Vector3.new(5.2,2.7,3.5),CFrame.new(-8.2,2.25,-24.25)*CFrame.Angles(0,math.rad(-13),0),C.charcoal,Enum.Material.Metal,0,reception,true)
part("DeskWingR",Vector3.new(5.2,2.7,3.5),CFrame.new(8.2,2.25,-24.25)*CFrame.Angles(0,math.rad(13),0),C.charcoal,Enum.Material.Metal,0,reception,true)
part("DeskTop",Vector3.new(13.1,.24,3.95),CFrame.new(0,3.68,-25.0),C.marble,Enum.Material.Marble,0,reception,false)
part("DeskTopL",Vector3.new(5.45,.24,3.95),CFrame.new(-8.2,3.68,-24.25)*CFrame.Angles(0,math.rad(-13),0),C.marble,Enum.Material.Marble,0,reception,false)
part("DeskTopR",Vector3.new(5.45,.24,3.95),CFrame.new(8.2,3.68,-24.25)*CFrame.Angles(0,math.rad(13),0),C.marble,Enum.Material.Marble,0,reception,false)
local underDesk=neon("ReceptionUnderGlow",Vector3.new(11.3,.08,.08),CFrame.new(0,1.18,-26.79),C.warm,reception)
point(underDesk,C.warm,.45,7)

-- Desk terminals and small lamps.
for i,x in ipairs({-4.1,4.1}) do
    local stand=part("TerminalStand"..i,Vector3.new(.22,1.1,.22),CFrame.new(x,4.25,-24.5),C.metal,Enum.Material.Metal,0,reception,false)
    part("Terminal"..i,Vector3.new(2.2,1.35,.16),CFrame.new(x,4.85,-24.45)*CFrame.Angles(math.rad(-8),0,0),C.black,Enum.Material.Glass,.04,reception,false)
    point(stand,C.warm,.22,4)
end

-- Queue stanchions: thin and believable, leaving center passage open.
for i,pos in ipairs({Vector3.new(-9,1.1,-30),Vector3.new(-3,1.1,-30),Vector3.new(3,1.1,-30),Vector3.new(9,1.1,-30)}) do
    local s=model("Stanchion"..i,reception)
    cylinder("Base",Vector3.new(.16,1.45,1.45),CFrame.new(pos.X,.18,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,0,s)
    cylinder("Pole",Vector3.new(2.2,.16,.16),CFrame.new(pos.X,1.25,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,0,s)
    cylinder("Cap",Vector3.new(.18,.40,.40),CFrame.new(pos.X,2.36,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.marble,Enum.Material.Metal,0,s)
end
part("QueueRopeL",Vector3.new(5.7,.08,.08),CFrame.new(-6,2.18,-30),C.pink,Enum.Material.Fabric,0,reception,false)
part("QueueRopeR",Vector3.new(5.7,.08,.08),CFrame.new(6,2.18,-30),C.pink,Enum.Material.Fabric,0,reception,false)

-- Warm ceiling feature over reception.
for i,x in ipairs({-9,-3,3,9}) do
    part("ReceptionCeilingSlat"..i,Vector3.new(4.5,.28,7.8),CFrame.new(x,13.2,-25),Color3.fromRGB(27,24,29),Enum.Material.WoodPlanks,0,reception,false)
    local down=cylinder("ReceptionDownlight"..i,Vector3.new(.28,.82,.82),CFrame.new(x,12.8,-25)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,reception)
    spot(down,C.warm,1.25,22,58)
end

-- PHOTO AREA ------------------------------------------------------------------
local photo=model("PhotoAreaPremium")
part("PhotoInsetFloor",Vector3.new(23.5,.12,17.5),CFrame.new(-39,.96,-25),Color3.fromRGB(31,29,35),Enum.Material.SmoothPlastic,0,photo,true)
-- Backdrop layers and dimensional frame.
part("PhotoWall",Vector3.new(.65,11.5,18),CFrame.new(-50.0,5.9,-25),C.charcoal,Enum.Material.Metal,0,photo,false)
part("PhotoInnerPanel",Vector3.new(.18,8.5,13.8),CFrame.new(-49.62,5.55,-25),Color3.fromRGB(18,16,22),Enum.Material.Glass,.05,photo,false)
neon("PhotoEdgeTop",Vector3.new(.12,.12,13.8),CFrame.new(-49.45,9.82,-25),C.pink,photo)
neon("PhotoEdgeBottom",Vector3.new(.12,.12,13.8),CFrame.new(-49.45,1.28,-25),C.cyan,photo)
-- Vertical light columns flank the backdrop.
for i,z in ipairs({-32.4,-17.6}) do
    local col=neon("PhotoLightColumn"..i,Vector3.new(.18,7.6,.18),CFrame.new(-49.28,5.55,z),i==1 and C.cyan or C.pink,photo)
    point(col,col.Color,.6,9)
end
local photoSign=part("PhotoSign",Vector3.new(.16,3.0,8.0),CFrame.new(-49.22,5.7,-25)*CFrame.Angles(0,math.rad(90),0),C.black,Enum.Material.Glass,.05,photo,false)
surfaceText(photoSign,"BBYA\nNIGHT MODE",C.white,Enum.Font.GothamBlack)

-- Camera pedestal / phone stand detail.
local cam=model("CameraPedestal",photo)
cylinder("Base",Vector3.new(.18,2.2,2.2),CFrame.new(-34,.2,-25)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,cam)
cylinder("Stem",Vector3.new(3.5,.18,.18),CFrame.new(-34,2.05,-25)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,0,cam)
part("CameraBody",Vector3.new(.9,.65,1.2),CFrame.new(-34,3.8,-25),C.black,Enum.Material.Metal,0,cam,false)
cylinder("Lens",Vector3.new(.50,.55,.55),CFrame.new(-34.52,3.8,-25)*CFrame.Angles(0,math.rad(90),0),Color3.fromRGB(28,32,39),Enum.Material.Glass,.05,cam)

-- Small waiting bench at photo area edge.
part("PhotoBenchSeat",Vector3.new(7,.65,2.3),CFrame.new(-40,1.35,-34),C.fabric,Enum.Material.Fabric,0,photo,true)
part("PhotoBenchBack",Vector3.new(7,2.0,.55),CFrame.new(-40,2.35,-35),C.fabric2,Enum.Material.Fabric,0,photo,false)

-- SALON / LOOK STUDIO ---------------------------------------------------------
local salon=model("SalonLookStudioPremium")
part("SalonInsetFloor",Vector3.new(25.5,.12,21.5),CFrame.new(-38,.96,-4),Color3.fromRGB(36,32,38),Enum.Material.SmoothPlastic,0,salon,true)
part("SalonBackFeature",Vector3.new(23.5,9.5,.60),CFrame.new(-38,5.35,6.15),C.charcoal,Enum.Material.Metal,0,salon,false)
-- Warm slatted wall treatment.
for i,x in ipairs({-48,-45.5,-43,-40.5,-38,-35.5,-33,-30.5,-28}) do
    part("SalonSlat"..i,Vector3.new(.55,7.6,.20),CFrame.new(i,5.25,5.78),C.wood,Enum.Material.WoodPlanks,0,salon,false)
end

local function salonStation(index,z)
    local m=model("SalonStation"..index,salon)
    -- Vanity console.
    part("Console",Vector3.new(5.6,.45,1.75),CFrame.new(-47.5,2.35,z),C.marble,Enum.Material.Marble,0,m,false)
    part("DrawerBody",Vector3.new(4.9,1.25,1.45),CFrame.new(-47.5,1.5,z),C.charcoal,Enum.Material.Metal,0,m,false)
    -- Tall mirror with glowing perimeter.
    local mirror=part("Mirror",Vector3.new(.16,5.6,4.15),CFrame.new(-49.0,5.6,z)*CFrame.Angles(0,math.rad(90),0),C.glass,Enum.Material.Glass,.20,m,false)
    mirror.Reflectance=.35
    neon("MirrorTop",Vector3.new(.08,.08,4.15),CFrame.new(-48.90,8.38,z),C.warm,m)
    neon("MirrorBottom",Vector3.new(.08,.08,4.15),CFrame.new(-48.90,2.82,z),C.warm,m)
    neon("MirrorLeft",Vector3.new(.08,5.55,.08),CFrame.new(-48.90,5.6,z-2.05),C.warm,m)
    neon("MirrorRight",Vector3.new(.08,5.55,.08),CFrame.new(-48.90,5.6,z+2.05),C.warm,m)
    -- Chair: pedestal + upholstered bucket silhouette.
    cylinder("ChairBase",Vector3.new(.18,2.5,2.5),CFrame.new(-42.8,.2,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,m)
    cylinder("ChairStem",Vector3.new(1.5,.22,.22),CFrame.new(-42.8,1.0,z)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,0,m)
    part("ChairSeat",Vector3.new(3.0,.8,2.7),CFrame.new(-42.8,1.95,z),C.fabric,Enum.Material.Fabric,0,m,true)
    part("ChairBack",Vector3.new(3.0,2.6,.65),CFrame.new(-42.8,3.25,z+1.05)*CFrame.Angles(math.rad(-8),0,0),C.fabric2,Enum.Material.Fabric,0,m,false)
    part("ArmL",Vector3.new(.55,1.1,2.2),CFrame.new(-44.1,2.55,z),C.fabric2,Enum.Material.Fabric,0,m,false)
    part("ArmR",Vector3.new(.55,1.1,2.2),CFrame.new(-41.5,2.55,z),C.fabric2,Enum.Material.Fabric,0,m,false)
end
for i,z in ipairs({-10,-3,4}) do salonStation(i,z) end

-- Product shelf wall opposite chairs.
for row,y in ipairs({2.3,4.7,7.1}) do
    part("ProductShelf"..row,Vector3.new(.40,.18,17.5),CFrame.new(-28.4,y,-3.0),C.black,Enum.Material.Metal,0,salon,false)
    local strip=neon("ProductShelfLight"..row,Vector3.new(.08,.06,16.8),CFrame.new(-28.18,y-.05,-3.0),C.warm,salon)
    point(strip,C.warm,.20,4)
    for i=1,8 do
        local z=-10+(i-1)*2.0
        local col=(i%3==0) and C.pink or ((i%2==0) and C.cyan or C.white)
        cylinder("Product"..row.."_"..i,Vector3.new(.58,.30,.30),CFrame.new(-28.05,y+.45,z)*CFrame.Angles(0,0,math.rad(90)),col,Enum.Material.Glass,.12,salon)
    end
end

-- TRANSITION COURT ------------------------------------------------------------
local transition=model("EntranceToClubTransition")
-- Dark polished runner anchors the sightline without neon stripe.
local runner=part("Runner",Vector3.new(22,.10,15.5),CFrame.new(0,1.05,-11.5),Color3.fromRGB(27,25,31),Enum.Material.SmoothPlastic,0,transition,false)
runner.Reflectance=.06
-- Ceiling fins draw people toward the main room.
for i,z in ipairs({-17,-14,-11,-8,-5}) do
    part("CeilingFin"..i,Vector3.new(19,.28,1.05),CFrame.new(0,14.2,z),Color3.fromRGB(24,22,27),Enum.Material.WoodPlanks,0,transition,false)
    local lamp=cylinder("FinLight"..i,Vector3.new(.24,.72,.72),CFrame.new(0,13.85,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,transition)
    spot(lamp,(i%2==0) and C.warm or C.white,.75,17,48)
end
-- Side portals frame the reveal into the club.
part("PortalL",Vector3.new(1.2,10.8,2.2),CFrame.new(-13.5,6.3,-5.0),C.black,Enum.Material.Metal,0,transition,false)
part("PortalR",Vector3.new(1.2,10.8,2.2),CFrame.new(13.5,6.3,-5.0),C.black,Enum.Material.Metal,0,transition,false)
part("PortalTop",Vector3.new(28.2,1.0,2.2),CFrame.new(0,11.2,-5.0),C.black,Enum.Material.Metal,0,transition,false)
neon("PortalAccentL",Vector3.new(.10,7.6,.10),CFrame.new(-12.84,6.25,-6.12),C.cyan,transition)
neon("PortalAccentR",Vector3.new(.10,7.6,.10),CFrame.new(12.84,6.25,-6.12),C.pink,transition)

-- Architectural planters at transition edges.
local function planter(name,pos)
    local m=model(name,out)
    cylinder("Pot",Vector3.new(1.55,2.3,2.3),CFrame.new(pos.X,1.3,pos.Z)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(31,29,34),Enum.Material.Slate,0,m)
    part("Stem",Vector3.new(.24,3.7,.24),CFrame.new(pos.X,3.7,pos.Z),C.green,Enum.Material.SmoothPlastic,0,m,false)
    for i=1,5 do
        local a=math.rad((i-1)*72)
        part("Leaf"..i,Vector3.new(.18,2.0,.62),CFrame.new(pos.X+math.cos(a)*.72,4.9,pos.Z+math.sin(a)*.72)*CFrame.Angles(math.rad(18),-a,0),Color3.fromRGB(58,90,66),Enum.Material.SmoothPlastic,0,m,false)
    end
end
planter("FrontPlanterL",Vector3.new(-16,.5,-9))
planter("FrontPlanterR",Vector3.new(16,.5,-9))

-- Keep front spaces slightly warmer than the main dance room.
Lighting.EnvironmentDiffuseScale=math.max(Lighting.EnvironmentDiffuseScale,.35)

print("[BBYA] Floor 1 front premium pass loaded: reception, photo studio, salon and club transition upgraded")
