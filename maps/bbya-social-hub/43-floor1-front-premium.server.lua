-- BBYA SOCIAL HUB — FLOOR 1 FRONT-OF-HOUSE PREMIUM PASS v2
-- Reception + club transition only. Salon / Look Lab / Photo Studio live in the Mall.

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
out:SetAttribute("Pass","FRONT_OF_HOUSE_PREMIUM_V2")
out:SetAttribute("ClubOnly",true)
out:SetAttribute("SalonInMall",true)
out:SetAttribute("PhotoStudioInMall",true)
out.Parent = root

local C = {
    black = Color3.fromRGB(8,8,11),
    charcoal = Color3.fromRGB(20,19,24),
    graphite = Color3.fromRGB(38,36,42),
    metal = Color3.fromRGB(58,55,62),
    marble = Color3.fromRGB(118,111,120),
    wood = Color3.fromRGB(78,59,48),
    fabric = Color3.fromRGB(48,41,50),
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

-- Retire the old core side-room generators themselves, not only their decorations.
for _,zoneName in ipairs({"03_PhotoArea","04_SalonLookStudio"}) do
    local zone=floor1:FindFirstChild(zoneName)
    if zone then zone:Destroy() end
end

-- Reception stays; replace only its primitive props.
local receptionCore=floor1:FindFirstChild("02_Reception")
if receptionCore then
    for _,obj in ipairs(receptionCore:GetChildren()) do
        if obj:IsA("BasePart") and not obj.Name:match("Floor") then obj:Destroy() end
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

part("DeskCore",Vector3.new(12.5,2.7,3.5),CFrame.new(0,2.25,-25.0),C.charcoal,Enum.Material.Metal,0,reception,true)
part("DeskWingL",Vector3.new(5.2,2.7,3.5),CFrame.new(-8.2,2.25,-24.25)*CFrame.Angles(0,math.rad(-13),0),C.charcoal,Enum.Material.Metal,0,reception,true)
part("DeskWingR",Vector3.new(5.2,2.7,3.5),CFrame.new(8.2,2.25,-24.25)*CFrame.Angles(0,math.rad(13),0),C.charcoal,Enum.Material.Metal,0,reception,true)
part("DeskTop",Vector3.new(13.1,.24,3.95),CFrame.new(0,3.68,-25.0),C.marble,Enum.Material.Marble,0,reception,false)
part("DeskTopL",Vector3.new(5.45,.24,3.95),CFrame.new(-8.2,3.68,-24.25)*CFrame.Angles(0,math.rad(-13),0),C.marble,Enum.Material.Marble,0,reception,false)
part("DeskTopR",Vector3.new(5.45,.24,3.95),CFrame.new(8.2,3.68,-24.25)*CFrame.Angles(0,math.rad(13),0),C.marble,Enum.Material.Marble,0,reception,false)
local underDesk=neon("ReceptionUnderGlow",Vector3.new(11.3,.08,.08),CFrame.new(0,1.18,-26.79),C.warm,reception)
point(underDesk,C.warm,.45,7)

for i,x in ipairs({-4.1,4.1}) do
    local stand=part("TerminalStand"..i,Vector3.new(.22,1.1,.22),CFrame.new(x,4.25,-24.5),C.metal,Enum.Material.Metal,0,reception,false)
    part("Terminal"..i,Vector3.new(2.2,1.35,.16),CFrame.new(x,4.85,-24.45)*CFrame.Angles(math.rad(-8),0,0),C.black,Enum.Material.Glass,.04,reception,false)
    point(stand,C.warm,.22,4)
end

for i,pos in ipairs({Vector3.new(-9,1.1,-30),Vector3.new(-3,1.1,-30),Vector3.new(3,1.1,-30),Vector3.new(9,1.1,-30)}) do
    local s=model("Stanchion"..i,reception)
    cylinder("Base",Vector3.new(.16,1.45,1.45),CFrame.new(pos.X,.18,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,0,s)
    cylinder("Pole",Vector3.new(2.2,.16,.16),CFrame.new(pos.X,1.25,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.metal,Enum.Material.Metal,0,s)
    cylinder("Cap",Vector3.new(.18,.40,.40),CFrame.new(pos.X,2.36,pos.Z)*CFrame.Angles(0,0,math.rad(90)),C.marble,Enum.Material.Metal,0,s)
end
part("QueueRopeL",Vector3.new(5.7,.08,.08),CFrame.new(-6,2.18,-30),C.pink,Enum.Material.Fabric,0,reception,false)
part("QueueRopeR",Vector3.new(5.7,.08,.08),CFrame.new(6,2.18,-30),C.pink,Enum.Material.Fabric,0,reception,false)

for i,x in ipairs({-9,-3,3,9}) do
    part("ReceptionCeilingSlat"..i,Vector3.new(4.5,.28,7.8),CFrame.new(x,13.2,-25),Color3.fromRGB(27,24,29),Enum.Material.WoodPlanks,0,reception,false)
    local down=cylinder("ReceptionDownlight"..i,Vector3.new(.28,.82,.82),CFrame.new(x,12.8,-25)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,reception)
    spot(down,C.warm,1.25,22,58)
end

-- CLUB TRANSITION -------------------------------------------------------------
local transition=model("EntranceToClubTransition")
local runner=part("Runner",Vector3.new(22,.10,15.5),CFrame.new(0,1.05,-11.5),Color3.fromRGB(27,25,31),Enum.Material.SmoothPlastic,0,transition,false)
runner.Reflectance=.06
for i,z in ipairs({-17,-14,-11,-8,-5}) do
    part("CeilingFin"..i,Vector3.new(19,.28,1.05),CFrame.new(0,14.2,z),Color3.fromRGB(24,22,27),Enum.Material.WoodPlanks,0,transition,false)
    local lamp=cylinder("FinLight"..i,Vector3.new(.24,.72,.72),CFrame.new(0,13.85,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,transition)
    spot(lamp,(i%2==0) and C.warm or C.white,.75,17,48)
end
part("PortalL",Vector3.new(1.2,10.8,2.2),CFrame.new(-13.5,6.3,-5.0),C.black,Enum.Material.Metal,0,transition,false)
part("PortalR",Vector3.new(1.2,10.8,2.2),CFrame.new(13.5,6.3,-5.0),C.black,Enum.Material.Metal,0,transition,false)
part("PortalTop",Vector3.new(28.2,1.0,2.2),CFrame.new(0,11.2,-5.0),C.black,Enum.Material.Metal,0,transition,false)
neon("PortalAccentL",Vector3.new(.10,7.6,.10),CFrame.new(-12.84,6.25,-6.12),C.cyan,transition)
neon("PortalAccentR",Vector3.new(.10,7.6,.10),CFrame.new(12.84,6.25,-6.12),C.pink,transition)

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

Lighting.EnvironmentDiffuseScale=math.max(Lighting.EnvironmentDiffuseScale,.35)
print("[BBYA] Floor 1 front v2 loaded: reception + pure-club transition; salon/photo retired to Mall")
