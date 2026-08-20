-- BBYA SOCIAL HUB — FLOOR 1 TRUE LUXURY FINISH v1
-- Final material/furniture pass for Main Club, Editorial Photo Room and Look Lab.
-- Roblox-native deterministic geometry: no third-party runtime asset dependency.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 20)
if not root then return end

local club = root:WaitForChild("MainClubRealism", 20)
local front = root:WaitForChild("Floor1FrontPremium", 20)
if not club or not front then
    warn("[BBYA Luxury Finish] required Floor 1 passes unavailable")
    return
end

local old = root:FindFirstChild("Floor1LuxuryFinish")
if old then old:Destroy() end

local out = Instance.new("Model")
out.Name = "Floor1LuxuryFinish"
out:SetAttribute("Pass", "TRUE_LUXURY_V1")
out.Parent = root

local clubFinish = Instance.new("Folder")
clubFinish.Name = "MainClub"
clubFinish.Parent = out
local photoFinish = Instance.new("Folder")
photoFinish.Name = "EditorialPhotoRoom"
photoFinish.Parent = out
local salonFinish = Instance.new("Folder")
salonFinish.Name = "LookLab"
salonFinish.Parent = out

local C = {
    black = Color3.fromRGB(8,8,10),
    ink = Color3.fromRGB(14,13,17),
    charcoal = Color3.fromRGB(25,23,28),
    graphite = Color3.fromRGB(42,39,45),
    bronze = Color3.fromRGB(142,103,68),
    brass = Color3.fromRGB(184,139,84),
    stone = Color3.fromRGB(91,86,93),
    marble = Color3.fromRGB(132,126,134),
    fabric = Color3.fromRGB(39,34,41),
    plum = Color3.fromRGB(67,47,63),
    taupe = Color3.fromRGB(89,75,78),
    glass = Color3.fromRGB(80,87,96),
    warm = Color3.fromRGB(255,204,157),
    warm2 = Color3.fromRGB(236,174,116),
    white = Color3.fromRGB(236,232,237),
    pink = Color3.fromRGB(244,48,149),
    cyan = Color3.fromRGB(31,184,207),
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

local function wedge(name,size,cf,color,material,parent,collide)
    local p=Instance.new("WedgePart")
    p.Name=name
    p.Size=size
    p.CFrame=cf
    p.Color=color or C.graphite
    p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true
    p.CanCollide=collide==true
    p.CanTouch=false
    p.CanQuery=true
    p.CastShadow=true
    p.Parent=parent or out
    return p
end

local function cylinder(name,size,cf,color,material,transparency,parent,collide)
    local p=part(name,size,cf,color,material,transparency,parent,collide)
    p.Shape=Enum.PartType.Cylinder
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

local function textPanel(parent,name,size,cf,textValue,textColor)
    local plate=part(name,size,cf,C.black,Enum.Material.Glass,.05,parent,false)
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.AlwaysOnTop=false
    gui.LightInfluence=.35
    gui.PixelsPerStud=70
    gui.Parent=plate
    local label=Instance.new("TextLabel")
    label.BackgroundTransparency=1
    label.Size=UDim2.fromScale(1,1)
    label.Text=textValue
    label.TextColor3=textColor or C.white
    label.Font=Enum.Font.GothamBold
    label.TextScaled=true
    label.Parent=gui
    return plate
end

-- CLEAN OUT THE VISUALLY CHEAP FURNITURE THAT THIS PASS REPLACES --------------
local furniture = club:FindFirstChild("Furniture")
if furniture then
    for _,obj in ipairs(furniture:GetChildren()) do
        if obj.Name:match("^VIPBay_")
            or obj.Name:match("^Sofa_")
            or obj.Name:match("^Table_")
            or obj.Name:match("^RearCocktail_") then
            obj:Destroy()
        end
    end
end

local photo = front:FindFirstChild("PhotoAreaPremium")
if photo then
    for _,name in ipairs({"PhotoBenchSeat","PhotoBenchBack","CameraPedestal"}) do
        local obj=photo:FindFirstChild(name)
        if obj then obj:Destroy() end
    end
end

local salon = front:FindFirstChild("SalonLookStudioPremium")
if salon then
    for _,obj in ipairs(salon:GetChildren()) do
        if obj.Name:match("^SalonStation")
            or obj.Name:match("^SalonSlat")
            or obj.Name:match("^ProductShelf")
            or obj.Name:match("^ProductShelfLight")
            or obj.Name:match("^Product%d") then
            obj:Destroy()
        end
    end
end

-- MAIN CLUB: BUILT-IN VIP LOUNGES, NO LOOSE BLOCK-CHAIR CLUTTER ----------------
local vip = model("BuiltInVIP",clubFinish)

local function cocktailTable(parent,name,x,z,diameter)
    local m=model(name,parent)
    cylinder("Foot",Vector3.new(.14,diameter*.58,diameter*.58),CFrame.new(x,.22,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,m,false)
    cylinder("Stem",Vector3.new(1.15,.20,.20),CFrame.new(x,.92,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,m,false)
    local top=cylinder("StoneTop",Vector3.new(.18,diameter,diameter),CFrame.new(x,1.58,z)*CFrame.Angles(0,0,math.rad(90)),C.marble,Enum.Material.Marble,0,m,false)
    top.Reflectance=.08
    local lamp=cylinder("TableLamp",Vector3.new(.48,.70,.70),CFrame.new(x,2.02,z)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(56,43,43),Enum.Material.Fabric,0,m,false)
    pointLight(lamp,C.warm,.32,6,true)
end

local function banquetteBay(index,z)
    local m=model("BanquetteBay"..index,vip)
    -- architectural plinth / wall panel makes the booth feel built into the room
    part("Plinth",Vector3.new(13.8,.28,10.6),CFrame.new(-39.0,1.03,z),Color3.fromRGB(28,26,31),Enum.Material.Slate,0,m,true)
    part("WallPanel",Vector3.new(.48,7.2,9.0),CFrame.new(-48.0,5.0,z),C.ink,Enum.Material.Slate,0,m,false)
    part("BronzeReveal",Vector3.new(.08,5.5,7.7),CFrame.new(-47.72,5.0,z),C.bronze,Enum.Material.Metal,0,m,false)

    -- continuous hotel-style banquette rather than separate armchairs
    part("SeatBase",Vector3.new(4.2,.54,7.3),CFrame.new(-44.55,1.22,z),C.black,Enum.Material.Metal,0,m,false)
    for n=1,3 do
        local zz=z-2.35+(n-1)*2.35
        part("SeatCushion"..n,Vector3.new(3.65,.72,2.12),CFrame.new(-44.15,1.72,zz),index==2 and C.plum or C.fabric,Enum.Material.Fabric,0,m,true)
        part("BackCushion"..n,Vector3.new(.72,2.65,2.05),CFrame.new(-46.15,2.90,zz)*CFrame.Angles(0,0,math.rad(-5)),index==2 and Color3.fromRGB(76,54,70) or Color3.fromRGB(50,43,51),Enum.Material.Fabric,0,m,false)
    end
    -- angled privacy wings visually close the booth without blocking the aisle
    wedge("WingFront",Vector3.new(3.8,3.2,1.0),CFrame.new(-44.8,2.55,z-4.18)*CFrame.Angles(0,math.rad(90),0),C.plum,Enum.Material.Fabric,m,false)
    wedge("WingRear",Vector3.new(3.8,3.2,1.0),CFrame.new(-44.8,2.55,z+4.18)*CFrame.Angles(0,math.rad(-90),0),C.plum,Enum.Material.Fabric,m,false)

    -- smoked-glass divider with brass cap on dance-floor side
    part("Divider",Vector3.new(.12,2.15,8.0),CFrame.new(-32.8,2.12,z),C.glass,Enum.Material.Glass,.52,m,false)
    part("DividerCap",Vector3.new(.18,.12,8.0),CFrame.new(-32.8,3.23,z),C.brass,Enum.Material.Metal,0,m,false)
    cocktailTable(m,"LowTable",-37.4,z,3.2)
end

banquetteBay(1,0)
banquetteBay(2,14)
banquetteBay(3,28)

-- Rear standing ledge keeps stage perimeter social without random tiny tables.
local rear = model("RearSocialRail",clubFinish)
for i,x in ipairs({-14,-6,12,20}) do
    cylinder("Base"..i,Vector3.new(.13,1.35,1.35),CFrame.new(x,.18,35.6)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,rear,false)
    cylinder("Stem"..i,Vector3.new(2.35,.16,.16),CFrame.new(x,1.42,35.6)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,rear,false)
    cylinder("Top"..i,Vector3.new(.14,2.45,2.45),CFrame.new(x,2.68,35.6)*CFrame.Angles(0,0,math.rad(90)),C.stone,Enum.Material.Marble,0,rear,false)
end

-- Stage fascia: dark acoustic/subwoofer grille rhythm + restrained bronze reveal.
local stageFinish = model("StageFascia",clubFinish)
part("FasciaBase",Vector3.new(57.4,1.55,.34),CFrame.new(3,2.20,37.16),C.black,Enum.Material.Metal,0,stageFinish,false)
for i=1,12 do
    local x=-22.3+(i-1)*4.6
    part("Grille"..i,Vector3.new(3.55,.92,.10),CFrame.new(x,2.18,36.95),Color3.fromRGB(25,24,28),Enum.Material.Fabric,0,stageFinish,false)
end
part("BronzeStageReveal",Vector3.new(49.8,.07,.08),CFrame.new(3,3.02,36.90),C.brass,Enum.Material.Metal,0,stageFinish,false)

-- DJ booth couture front: vertical metal lamellae and discreet logo plaque.
local boothFinish = model("DJBoothCouture",clubFinish)
for i=1,9 do
    local x=-5.0+(i-1)*2.0
    part("Lamella"..i,Vector3.new(.16,2.15,.12),CFrame.new(x,4.82,29.31),i==5 and C.brass or C.graphite,Enum.Material.Metal,0,boothFinish,false)
end
textPanel(boothFinish,"BoothMark",Vector3.new(4.5,1.05,.10),CFrame.new(3,5.25,29.23),"BBYA",C.white)

-- EDITORIAL PHOTO ROOM ---------------------------------------------------------
if photo then
    local editorial=model("EditorialSet",photoFinish)

    -- matte infinity-style set surface; architectural, not neon-box backdrop
    part("BackdropMatte",Vector3.new(.22,8.6,13.5),CFrame.new(-49.25,5.55,-25),Color3.fromRGB(25,22,28),Enum.Material.Slate,0,editorial,false)
    part("BackdropFloor",Vector3.new(7.6,.10,13.5),CFrame.new(-45.4,1.04,-25),Color3.fromRGB(25,22,28),Enum.Material.SmoothPlastic,0,editorial,true)
    -- stepped cove masks the hard wall/floor seam
    wedge("CoveLower",Vector3.new(2.8,1.55,13.5),CFrame.new(-48.0,1.80,-25)*CFrame.Angles(0,0,math.rad(-90)),Color3.fromRGB(25,22,28),Enum.Material.SmoothPlastic,editorial,false)

    textPanel(editorial,"EditorialMark",Vector3.new(.10,2.15,6.3),CFrame.new(-49.08,8.05,-25)*CFrame.Angles(0,math.rad(90),0),"BBYA  EDITORIAL",C.white)

    -- professional softboxes on slim stands, facing the set
    local function softbox(name,z,color)
        local m=model(name,editorial)
        cylinder("Foot",Vector3.new(.12,1.8,1.8),CFrame.new(-35.2,.16,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,m,false)
        part("Stand",Vector3.new(.14,5.8,.14),CFrame.new(-35.2,3.05,z),C.graphite,Enum.Material.Metal,0,m,false)
        local box=part("Softbox",Vector3.new(.24,3.4,4.2),CFrame.new(-35.5,6.3,z),Color3.fromRGB(215,208,214),Enum.Material.Fabric,0,m,false)
        spotLight(box,Enum.NormalId.Left,color,1.15,22,62,true)
        part("SoftboxRim",Vector3.new(.28,3.75,4.55),CFrame.new(-35.72,6.3,z),C.black,Enum.Material.Metal,.35,m,false)
    end
    softbox("KeyLight",-31.2,C.warm)
    softbox("FillLight",-18.8,Color3.fromRGB(205,220,230))

    -- real camera tripod silhouette
    local cam=model("EditorialCamera",editorial)
    for i,off in ipairs({-0.9,0,0.9}) do
        part("TripodLeg"..i,Vector3.new(.11,3.4,.11),CFrame.new(-32.8+off*.55,1.75,-25+off)*CFrame.Angles(math.rad(off*8),0,math.rad(off*9)),C.graphite,Enum.Material.Metal,0,cam,false)
    end
    part("TripodHead",Vector3.new(.8,.35,.8),CFrame.new(-32.8,3.55,-25),C.black,Enum.Material.Metal,0,cam,false)
    part("CameraBody",Vector3.new(1.25,.95,1.55),CFrame.new(-33.1,4.25,-25),C.black,Enum.Material.Metal,0,cam,false)
    cylinder("Lens",Vector3.new(.72,.72,.72),CFrame.new(-33.85,4.25,-25),Color3.fromRGB(27,34,42),Enum.Material.Glass,.05,cam,false)

    -- waiting chaise instead of two raw bench blocks
    local chaise=model("EditorialChaise",editorial)
    part("Plinth",Vector3.new(8.6,.28,3.1),CFrame.new(-40.0,1.03,-34.0),C.black,Enum.Material.Metal,0,chaise,false)
    for i=1,3 do
        part("Cushion"..i,Vector3.new(2.5,.68,2.65),CFrame.new(-42.6+(i-1)*2.6,1.55,-34.0),i==2 and C.plum or C.fabric,Enum.Material.Fabric,0,chaise,true)
    end
    part("Back",Vector3.new(8.0,2.25,.60),CFrame.new(-40.0,2.60,-35.25)*CFrame.Angles(math.rad(-6),0,0),C.taupe,Enum.Material.Fabric,0,chaise,false)
    cylinder("SideTable",Vector3.new(.16,2.0,2.0),CFrame.new(-34.7,1.60,-34.0)*CFrame.Angles(0,0,math.rad(90)),C.marble,Enum.Material.Marble,0,chaise,false)
    local tableLamp=cylinder("SideLamp",Vector3.new(.40,.62,.62),CFrame.new(-34.7,2.05,-34.0)*CFrame.Angles(0,0,math.rad(90)),C.plum,Enum.Material.Fabric,0,chaise,false)
    pointLight(tableLamp,C.warm,.28,5,true)
end

-- LOOK LAB / SALON -------------------------------------------------------------
if salon then
    local lab=model("LuxuryLookLab",salonFinish)

    -- replace wood-slat wallpaper with framed stone + bronze vertical reveals
    part("BackStone",Vector3.new(22.5,8.2,.18),CFrame.new(-38,5.3,5.78),Color3.fromRGB(51,47,53),Enum.Material.Marble,0,lab,false)
    for i,x in ipairs({-47.5,-43,-38,-33,-28.5}) do
        part("BackReveal"..i,Vector3.new(.10,7.0,.08),CFrame.new(x,5.3,5.64),C.brass,Enum.Material.Metal,0,lab,false)
    end
    textPanel(lab,"LookLabMark",Vector3.new(8.0,1.35,.10),CFrame.new(-38,8.10,5.60),"BBYA  LOOK LAB",C.white)

    local function vanity(index,z)
        local m=model("Vanity"..index,lab)
        -- floating console and drawer line
        part("Console",Vector3.new(4.9,.30,1.65),CFrame.new(-47.0,2.35,z),C.marble,Enum.Material.Marble,0,m,false)
        part("Drawer",Vector3.new(4.35,.95,1.38),CFrame.new(-47.0,1.72,z),C.charcoal,Enum.Material.Metal,0,m,false)
        part("DrawerReveal",Vector3.new(.06,.06,3.4),CFrame.new(-46.25,1.78,z),C.brass,Enum.Material.Metal,0,m,false)

        -- large mirror with warm perimeter
        local mirror=part("Mirror",Vector3.new(.14,5.7,4.5),CFrame.new(-49.0,5.65,z)*CFrame.Angles(0,math.rad(90),0),C.glass,Enum.Material.Glass,.17,m,false)
        mirror.Reflectance=.42
        for _,spec in ipairs({
            {"Top",Vector3.new(.08,.08,4.45),CFrame.new(-48.90,8.50,z)},
            {"Bottom",Vector3.new(.08,.08,4.45),CFrame.new(-48.90,2.80,z)},
            {"Left",Vector3.new(.08,5.65,.08),CFrame.new(-48.90,5.65,z-2.22)},
            {"Right",Vector3.new(.08,5.65,.08),CFrame.new(-48.90,5.65,z+2.22)},
        }) do
            local light=part("Mirror"..spec[1],spec[2],spec[3],C.warm,Enum.Material.Neon,.10,m,false)
            pointLight(light,C.warm,.16,4,false)
        end

        -- barrel-back salon chair: round shell reads much less blocky
        local chair=model("Chair",m)
        cylinder("PedestalFoot",Vector3.new(.16,2.55,2.55),CFrame.new(-42.0,.20,z)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,chair,false)
        cylinder("PedestalStem",Vector3.new(1.35,.20,.20),CFrame.new(-42.0,.95,z)*CFrame.Angles(0,0,math.rad(90)),C.brass,Enum.Material.Metal,0,chair,false)
        cylinder("Seat",Vector3.new(.68,3.1,3.1),CFrame.new(-42.0,1.82,z)*CFrame.Angles(0,0,math.rad(90)),C.fabric,Enum.Material.Fabric,0,chair,true)
        cylinder("BackShell",Vector3.new(.62,3.45,3.45),CFrame.new(-42.45,3.10,z),C.plum,Enum.Material.Fabric,0,chair,false)
        part("BackCut",Vector3.new(.38,2.0,2.25),CFrame.new(-41.98,2.75,z),Color3.fromRGB(53,42,52),Enum.Material.Fabric,0,chair,false)
    end

    vanity(1,-10)
    vanity(2,-3)
    vanity(3,4)

    -- illuminated retail/product cabinets opposite the vanities
    for bay,z in ipairs({-9,-3,3}) do
        local cab=model("ProductCabinet"..bay,lab)
        part("Case",Vector3.new(.70,6.4,4.8),CFrame.new(-28.55,4.65,z),C.ink,Enum.Material.Metal,0,cab,false)
        part("GlassFront",Vector3.new(.12,5.75,4.2),CFrame.new(-28.13,4.65,z),C.glass,Enum.Material.Glass,.48,cab,false)
        for row=1,3 do
            local y=2.65+(row-1)*1.75
            part("Shelf"..row,Vector3.new(.32,.10,3.8),CFrame.new(-28.20,y,z),C.brass,Enum.Material.Metal,0,cab,false)
            for item=1,4 do
                local zz=z-1.25+(item-1)*.83
                local color=((row+item)%3==0) and C.pink or (((row+item)%2==0) and C.warm2 or C.white)
                cylinder("Bottle"..row.."_"..item,Vector3.new(.54,.24,.24),CFrame.new(-28.02,y+.38,zz)*CFrame.Angles(0,0,math.rad(90)),color,Enum.Material.Glass,.08,cab,false)
            end
        end
    end

    -- central styling island / accessories counter
    local island=model("StylingIsland",lab)
    part("Body",Vector3.new(5.4,2.15,6.2),CFrame.new(-35.4,2.08,-3.0),C.charcoal,Enum.Material.Metal,0,island,true)
    part("Top",Vector3.new(5.8,.22,6.6),CFrame.new(-35.4,3.26,-3.0),C.marble,Enum.Material.Marble,0,island,false)
    part("BronzeBand",Vector3.new(5.55,.12,6.30),CFrame.new(-35.4,2.62,-3.0),C.brass,Enum.Material.Metal,.38,island,false)
    for i=1,4 do
        cylinder("Display"..i,Vector3.new(.50,.26,.26),CFrame.new(-36.8+(i-1)*.95,3.62,-3.0),i%2==0 and C.pink or C.warm2,Enum.Material.Glass,.08,island,false)
    end

    -- ceiling track: focused warm pools, no RGB arcade look
    local track=model("CeilingTrack",lab)
    part("Track",Vector3.new(18,.15,.18),CFrame.new(-38,11.9,-3),C.black,Enum.Material.Metal,0,track,false)
    for i,x in ipairs({-46,-42,-38,-34,-30}) do
        local can=cylinder("Spot"..i,Vector3.new(.46,.72,.72),CFrame.new(x,11.55,-3)*CFrame.Angles(0,0,math.rad(90)),C.black,Enum.Material.Metal,0,track,false)
        spotLight(can,Enum.NormalId.Bottom,C.warm,1.05,18,46,true)
    end
end

print("[BBYA] TRUE LUXURY v1 loaded: built-in club VIP, editorial photo room, luxury look lab")
