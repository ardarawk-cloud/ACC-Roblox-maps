-- BBYA SOCIAL HUB — FLOOR 1 ULTRA PREMIUM REFINEMENT v2
-- Architectural micro-detail + hospitality-grade furniture/equipment pass.
-- Targets Main Club, Editorial Photo Room and BBYA Look Lab only.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 20)
if not root then return end

local club = root:WaitForChild("MainClubRealism", 20)
local front = root:WaitForChild("Floor1FrontPremium", 20)
local luxury = root:WaitForChild("Floor1LuxuryFinish", 20)
if not club or not front or not luxury then
    warn("[BBYA Ultra Premium] prerequisite Floor 1 passes unavailable")
    return
end

local old = root:FindFirstChild("Floor1UltraPremium")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "Floor1UltraPremium"
out:SetAttribute("Pass", "ULTRA_PREMIUM_V2")
out.Parent = root

local clubOut = Instance.new("Folder")
clubOut.Name = "MainClubRefinement"
clubOut.Parent = out
local photoOut = Instance.new("Folder")
photoOut.Name = "EditorialPhotoRefinement"
photoOut.Parent = out
local labOut = Instance.new("Folder")
labOut.Name = "LookLabRefinement"
labOut.Parent = out

local C = {
    black = Color3.fromRGB(7,7,9),
    ink = Color3.fromRGB(13,12,16),
    charcoal = Color3.fromRGB(23,22,27),
    graphite = Color3.fromRGB(43,41,47),
    bronze = Color3.fromRGB(132,94,61),
    brass = Color3.fromRGB(183,139,83),
    champagne = Color3.fromRGB(213,177,128),
    marble = Color3.fromRGB(128,122,132),
    stone = Color3.fromRGB(77,73,81),
    fabric = Color3.fromRGB(39,35,42),
    plum = Color3.fromRGB(67,47,63),
    taupe = Color3.fromRGB(88,76,79),
    glass = Color3.fromRGB(82,91,103),
    warm = Color3.fromRGB(255,207,161),
    white = Color3.fromRGB(238,235,240),
    rose = Color3.fromRGB(225,59,139),
    cyan = Color3.fromRGB(37,177,198),
    green = Color3.fromRGB(76,92,77),
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

local function cylinder(name,size,cf,color,material,transparency,parent,collide)
    local p=part(name,size,cf,color,material,transparency,parent,collide)
    p.Shape=Enum.PartType.Cylinder
    return p
end

local function ball(name,size,cf,color,material,transparency,parent,collide)
    local p=part(name,size,cf,color,material,transparency,parent,collide)
    p.Shape=Enum.PartType.Ball
    return p
end

local function model(name,parent)
    local m=Instance.new("Model")
    m.Name=name
    m.Parent=parent or out
    return m
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

local function spotLight(parent,face,color,brightness,range,angle,shadows)
    local l=Instance.new("SpotLight")
    l.Face=face
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Angle=angle
    l.Shadows=shadows==true
    l.Parent=parent
    return l
end

local function textPlate(parent,name,size,cf,textValue,color)
    local plate=part(name,size,cf,C.black,Enum.Material.Glass,.06,parent,false)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.AlwaysOnTop=false
    gui.LightInfluence=.35
    gui.PixelsPerStud=75
    gui.Parent=plate
    local label=Instance.new("TextLabel")
    label.BackgroundTransparency=1
    label.Size=UDim2.fromScale(1,1)
    label.Text=textValue
    label.TextColor3=color or C.white
    label.Font=Enum.Font.GothamBold
    label.TextScaled=true
    label.Parent=gui
    return plate
end

-- MAIN CLUB -------------------------------------------------------------------
-- Replace the remaining primitive bar stools from the earlier realism pass.
local furniture = club:FindFirstChild("Furniture")
if furniture then
    for _,obj in ipairs(furniture:GetChildren()) do
        if obj.Name:match("^BarStool_") then obj:Destroy() end
    end
end

local clubArch=model("ClubArchitecture",clubOut)

-- Recessed perimeter light coves: warm and low, giving the room depth without RGB-strip overload.
for i,z in ipairs({-4,9,22,35}) do
    part("LeftCoveRecess"..i,Vector3.new(.42,5.6,8.2),CFrame.new(-49.25,8.0,z),C.ink,Enum.Material.Slate,0,clubArch,false)
    local l=part("LeftCoveLight"..i,Vector3.new(.08,4.8,6.9),CFrame.new(-49.00,8.0,z),C.warm,Enum.Material.Neon,.35,clubArch,false)
    pointLight(l,C.warm,.14,7,false)
    part("RightCoveRecess"..i,Vector3.new(.42,5.6,8.2),CFrame.new(50.25,8.0,z),C.ink,Enum.Material.Slate,0,clubArch,false)
    local r=part("RightCoveLight"..i,Vector3.new(.08,4.8,6.9),CFrame.new(50.00,8.0,z),C.warm,Enum.Material.Neon,.35,clubArch,false)
    pointLight(r,C.warm,.14,7,false)
end

-- A continuous bronze datum line makes the wall treatment read as one designed venue.
part("LeftBronzeDatum",Vector3.new(.07,.10,39),CFrame.new(-48.92,11.05,14),C.brass,Enum.Material.Metal,0,clubArch,false)
part("RightBronzeDatum",Vector3.new(.07,.10,39),CFrame.new(49.92,11.05,14),C.brass,Enum.Material.Metal,0,clubArch,false)

-- Ceiling perimeter shadow-gap frame around the dance room.
part("CeilingShadowFront",Vector3.new(67,.20,.42),CFrame.new(3,18.92,-7.0),C.black,Enum.Material.Metal,0,clubArch,false)
part("CeilingShadowRear",Vector3.new(67,.20,.42),CFrame.new(3,18.92,34.0),C.black,Enum.Material.Metal,0,clubArch,false)
part("CeilingShadowL",Vector3.new(.42,.20,41),CFrame.new(-30.2,18.92,13.5),C.black,Enum.Material.Metal,0,clubArch,false)
part("CeilingShadowR",Vector3.new(.42,.20,41),CFrame.new(36.2,18.92,13.5),C.black,Enum.Material.Metal,0,clubArch,false)

-- Hospitality-grade bar stools: pedestal + upholstered round seat + curved segmented back.
local barSeating=model("BarSeating",clubOut)
local function premiumStool(index,z)
    local m=model("PremiumBarStool"..index,barSeating)
    cylinder("Foot",Vector3.new(.16,2.05,2.05),CFrame.new(29.7,.20,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,m,false)
    cylinder("Stem",Vector3.new(2.05,.20,.20),CFrame.new(29.7,1.32,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,m,false)
    cylinder("Seat",Vector3.new(.54,2.45,2.45),CFrame.new(29.7,2.55,z)*CFrame.Angles(0,0,math.rad(90)),index%2==0 and C.plum or C.fabric,Enum.Material.Fabric,0,m,true)
    -- three narrow facets give the back a curved club-chair silhouette.
    part("BackCenter",Vector3.new(.44,2.25,1.55),CFrame.new(28.62,3.48,z),C.taupe,Enum.Material.Fabric,0,m,false)
    part("BackWingA",Vector3.new(.40,1.95,1.08),CFrame.new(28.74,3.40,z-1.03)*CFrame.Angles(0,math.rad(28),0),C.taupe,Enum.Material.Fabric,0,m,false)
    part("BackWingB",Vector3.new(.40,1.95,1.08),CFrame.new(28.74,3.40,z+1.03)*CFrame.Angles(0,math.rad(-28),0),C.taupe,Enum.Material.Fabric,0,m,false)
    cylinder("FootRing",Vector3.new(.08,1.35,1.35),CFrame.new(29.7,1.08,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,m,false)
end
for i,z in ipairs({1,6,11,16,21}) do premiumStool(i,z) end

-- Bar operations detail: POS, service rail, ice wells, hanging stemware.
local barOps=model("BarOperations",clubOut)
for i,z in ipairs({4.0,17.7}) do
    part("POSBase"..i,Vector3.new(1.1,.28,1.2),CFrame.new(34.6,4.55,z),C.black,Enum.Material.Metal,0,barOps,false)
    local screen=part("POSScreen"..i,Vector3.new(.20,1.45,2.0),CFrame.new(34.2,5.18,z)*CFrame.Angles(0,math.rad(90),math.rad(-6)),C.glass,Enum.Material.Glass,.08,barOps,false)
    local glow=Instance.new("SurfaceLight")
    glow.Face=Enum.NormalId.Right
    glow.Color=C.warm
    glow.Brightness=.25
    glow.Range=3
    glow.Parent=screen
end
for i,z in ipairs({7.5,12.0,16.5}) do
    part("IceWell"..i,Vector3.new(2.2,.20,2.9),CFrame.new(34.9,4.48,z),Color3.fromRGB(46,50,56),Enum.Material.Metal,0,barOps,false)
    part("IceInset"..i,Vector3.new(1.72,.10,2.40),CFrame.new(34.9,4.59,z),Color3.fromRGB(158,174,183),Enum.Material.Glass,.28,barOps,false)
end
part("ServiceRail",Vector3.new(.18,.18,23.5),CFrame.new(32.53,4.47,11),C.brass,Enum.Material.Metal,0,barOps,false)
for i,z in ipairs({2.2,5.0,7.8,10.6,13.4,16.2,19.0}) do
    cylinder("Stemware"..i,Vector3.new(.12,.46,.46),CFrame.new(49.8,11.25,z)*CFrame.Angles(0,0,math.rad(90)),C.glass,Enum.Material.Glass,.35,barOps,false)
    part("Stem"..i,Vector3.new(.05,.65,.05),CFrame.new(49.8,10.83,z),C.glass,Enum.Material.Glass,.30,barOps,false)
end

-- VIP bottle-service detail, intentionally sparse so it reads expensive rather than cluttered.
local service=model("VIPBottleService",clubOut)
for bay,z in ipairs({0,14,28}) do
    local x=-37.4
    local bucket=cylinder("ChampagneBucket"..bay,Vector3.new(1.20,1.35,1.35),CFrame.new(x,2.15,z+1.25)*CFrame.Angles(0,0,math.rad(90)),C.marble,Enum.Material.Metal,0,service,false)
    bucket.Reflectance=.18
    cylinder("Bottle"..bay,Vector3.new(1.85,.36,.36),CFrame.new(x,3.10,z+1.25)*CFrame.Angles(0,0,math.rad(72)),Color3.fromRGB(69,92,75),Enum.Material.Glass,.08,service,false)
    ball("Ice"..bay,Vector3.new(.34,.34,.34),CFrame.new(x-.18,2.82,z+1.02),Color3.fromRGB(190,210,220),Enum.Material.Glass,.35,service,false)
    cylinder("GlassA"..bay,Vector3.new(.46,.36,.36),CFrame.new(x-.72,1.92,z-.55)*CFrame.Angles(0,0,math.rad(90)),C.glass,Enum.Material.Glass,.35,service,false)
    cylinder("GlassB"..bay,Vector3.new(.46,.36,.36),CFrame.new(x+.70,1.92,z-.45)*CFrame.Angles(0,0,math.rad(90)),C.glass,Enum.Material.Glass,.35,service,false)
end

-- DJ/stage depth: side reveal fins and overhead architectural header, no giant new screen.
local djFrame=model("DJStageFrame",clubOut)
part("DJHeader",Vector3.new(31,.55,1.00),CFrame.new(3,15.15,44.9),C.charcoal,Enum.Material.Metal,0,djFrame,false)
part("DJHeaderReveal",Vector3.new(25,.08,.08),CFrame.new(3,14.82,44.34),C.brass,Enum.Material.Metal,0,djFrame,false)
for i,x in ipairs({-16.8,-12.8,18.8,22.8}) do
    part("StageFin"..i,Vector3.new(.42,8.8,1.15),CFrame.new(x,9.35,45.0),C.graphite,Enum.Material.Metal,0,djFrame,false)
end

-- EDITORIAL PHOTO ROOM ---------------------------------------------------------
local photo = front:FindFirstChild("PhotoAreaPremium")
if photo then
    local rig=model("EditorialRig",photoOut)
    -- overhead studio rail and three adjustable heads
    part("OverheadRail",Vector3.new(15,.16,.22),CFrame.new(-41.5,11.7,-25),C.black,Enum.Material.Metal,0,rig,false)
    for i,z in ipairs({-30,-25,-20}) do
        part("Drop"..i,Vector3.new(.10,1.35,.10),CFrame.new(-41.5,10.95,z),C.graphite,Enum.Material.Metal,0,rig,false)
        local head=cylinder("Head"..i,Vector3.new(.55,.90,.90),CFrame.new(-41.5,10.20,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,rig,false)
        spotLight(head,Enum.NormalId.Bottom,i==2 and C.warm or C.white,.70,18,42,true)
    end

    -- Styling/makeup console gives the photo room a functional prep corner.
    local prep=model("PhotoPrepConsole",photoOut)
    part("Cabinet",Vector3.new(5.6,2.05,1.6),CFrame.new(-42.0,2.05,-16.8),C.charcoal,Enum.Material.Metal,0,prep,true)
    part("StoneTop",Vector3.new(6.0,.20,1.9),CFrame.new(-42.0,3.18,-16.8),C.marble,Enum.Material.Marble,0,prep,false)
    local mirror=part("PrepMirror",Vector3.new(5.8,3.5,.12),CFrame.new(-42.0,5.45,-17.72),C.glass,Enum.Material.Glass,.20,prep,false)
    mirror.Reflectance=.38
    for _,x in ipairs({-44.35,-42.0,-39.65}) do
        local bulb=ball("Bulb"..tostring(x),Vector3.new(.32,.32,.32),CFrame.new(x,7.0,-17.60),C.warm,Enum.Material.Neon,.08,prep,false)
        pointLight(bulb,C.warm,.15,3,false)
    end
    -- floor posing marks, subtle brass, useful without looking like a debug grid
    for i,z in ipairs({-29,-25,-21}) do
        cylinder("PoseMark"..i,Vector3.new(.03,1.3,1.3),CFrame.new(-44.8,1.12,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,rig,false)
    end

    -- Equipment cart: compact and intentional.
    local cart=model("EquipmentCart",photoOut)
    part("CartBody",Vector3.new(2.6,2.0,3.6),CFrame.new(-31.8,1.95,-32.3),C.charcoal,Enum.Material.Metal,0,cart,true)
    part("CartTop",Vector3.new(2.85,.14,3.85),CFrame.new(-31.8,3.02,-32.3),C.stone,Enum.Material.Marble,0,cart,false)
    for _,off in ipairs({-1.1,1.1}) do
        cylinder("WheelA"..off,Vector3.new(.30,.72,.72),CFrame.new(-32.85,.70,-32.3+off)*CFrame.Angles(0,math.rad(90),0),C.black,Enum.Material.SmoothPlastic,0,cart,false)
        cylinder("WheelB"..off,Vector3.new(.30,.72,.72),CFrame.new(-30.75,.70,-32.3+off)*CFrame.Angles(0,math.rad(90),0),C.black,Enum.Material.SmoothPlastic,0,cart,false)
    end
end

-- LOOK LAB --------------------------------------------------------------------
local salon = front:FindFirstChild("SalonLookStudioPremium")
if salon then
    local lab=model("LookLabFacilities",labOut)

    -- Premium wash station at the quieter end of the lab.
    local wash=model("WashStation",lab)
    part("WashCabinet",Vector3.new(5.4,2.3,4.1),CFrame.new(-34.2,2.05,4.0),C.charcoal,Enum.Material.Metal,0,wash,true)
    local basin=cylinder("Basin",Vector3.new(.72,3.4,3.4),CFrame.new(-34.2,3.38,4.0)*CFrame.Angles(0,0,math.rad(90)),C.marble,Enum.Material.Marble,0,wash,false)
    basin.Reflectance=.08
    cylinder("BasinInset",Vector3.new(.74,2.55,2.55),CFrame.new(-34.2,3.52,4.0)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(45,46,50),Enum.Material.SmoothPlastic,0,wash,false)
    cylinder("FaucetArc",Vector3.new(1.25,.18,.18),CFrame.new(-34.2,4.40,5.15)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,wash,false)

    -- Client waiting ottomans: rounded, low, and separated from the styling stations.
    local waiting=model("WaitingArea",lab)
    for i,z in ipairs({-10.0,-6.5}) do
        cylinder("Ottoman"..i,Vector3.new(.92,3.2,3.2),CFrame.new(-31.5,1.48,z)*CFrame.Angles(0,0,math.rad(90)),i==1 and C.plum or C.taupe,Enum.Material.Fabric,0,waiting,true)
        cylinder("Plinth"..i,Vector3.new(.16,2.7,2.7),CFrame.new(-31.5,.96,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,waiting,false)
    end

    -- Mobile stylist trolley with drawers and tool cups.
    local trolley=model("StylistTrolley",lab)
    part("TrolleyBody",Vector3.new(2.25,2.75,2.8),CFrame.new(-39.0,2.10,5.0),C.black,Enum.Material.Metal,0,trolley,true)
    for row=1,3 do
        part("Drawer"..row,Vector3.new(1.95,.58,2.45),CFrame.new(-38.82,1.35+(row-1)*.68,5.0),C.charcoal,Enum.Material.Metal,0,trolley,false)
        part("Handle"..row,Vector3.new(.10,.08,.75),CFrame.new(-37.81,1.35+(row-1)*.68,5.0),C.brass,Enum.Material.Metal,0,trolley,false)
    end
    for _,z in ipairs({4.4,5.0,5.6}) do
        cylinder("ToolCup"..z,Vector3.new(.70,.55,.55),CFrame.new(-39.0,3.82,z)*CFrame.Angles(0,0,math.rad(90)),C.graphite,Enum.Material.Metal,0,trolley,false)
    end

    -- Towel/display cabinet and styling product niche.
    local storage=model("TowelCabinet",lab)
    part("Cabinet",Vector3.new(.80,7.0,5.3),CFrame.new(-28.7,5.0,5.0),C.ink,Enum.Material.Metal,0,storage,false)
    part("GlassDoor",Vector3.new(.12,6.4,4.7),CFrame.new(-28.22,5.0,5.0),C.glass,Enum.Material.Glass,.48,storage,false)
    for row=1,4 do
        part("Shelf"..row,Vector3.new(.26,.10,4.25),CFrame.new(-28.28,2.3+(row-1)*1.55,5.0),C.brass,Enum.Material.Metal,0,storage,false)
        for n=1,3 do
            cylinder("Towel"..row.."_"..n,Vector3.new(.62,.55,.55),CFrame.new(-28.05,2.70+(row-1)*1.55,3.8+(n-1)*1.2)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(196,190,194),Enum.Material.Fabric,0,storage,false)
        end
    end

    -- Floating ceiling island visually groups the lab rather than leaving lights suspended in empty space.
    local ceiling=model("LookLabCeilingIsland",lab)
    part("Island",Vector3.new(18,.38,9.6),CFrame.new(-38,12.45,-3),Color3.fromRGB(20,19,23),Enum.Material.Slate,0,ceiling,false)
    part("BronzeEdgeL",Vector3.new(.08,.12,8.8),CFrame.new(-46.86,12.20,-3),C.brass,Enum.Material.Metal,0,ceiling,false)
    part("BronzeEdgeR",Vector3.new(.08,.12,8.8),CFrame.new(-29.14,12.20,-3),C.brass,Enum.Material.Metal,0,ceiling,false)
    for i,x in ipairs({-45,-41.5,-38,-34.5,-31}) do
        local can=cylinder("Downlight"..i,Vector3.new(.40,.66,.66),CFrame.new(x,12.03,-3)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,ceiling,false)
        spotLight(can,Enum.NormalId.Bottom,C.warm,.80,16,42,true)
    end
end

print("[BBYA] ULTRA PREMIUM v2 loaded: hospitality club detail, editorial rig, full-service Look Lab")
