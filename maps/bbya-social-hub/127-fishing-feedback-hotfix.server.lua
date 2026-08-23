-- BBYA SOCIAL HUB — FISHING FEEDBACK + FISH ART v5
-- Screenshot fixes: rod storage, deep water, submerged schools, corrected rod grip.
-- V5 art pass replaces primitive catch silhouettes with species-specific collectible 3D builds.
-- No rarity/chance/progression math is changed here.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 35)
if not root then return end
local district = root:WaitForChild("PremiumFishingDistrictV2", 35)
if not district then return end

task.wait(2)

district:SetAttribute("FeedbackHotfix", "V5_ART")
district:SetAttribute("RodAutoStoredOutsideLake", true)
district:SetAttribute("DeepWaterVisual", true)
district:SetAttribute("AmbientFishHiddenBelowSurface", true)
district:SetAttribute("SpeciesSpecificCatchArtV5", true)
district:SetAttribute("FishingChanceMathUntouchedV5", true)

local LAKE_CENTER = Vector3.new(
    district:GetAttribute("LakeCenterX") or 0,
    0,
    district:GetAttribute("LakeCenterZ") or 790
)
local ACTIVE_RADIUS = 205
local ACTIVE_RADIUS_SQ = ACTIVE_RADIUS * ACTIVE_RADIUS

local function nearFishingDistrict(player)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local dx = hrp.Position.X - LAKE_CENTER.X
    local dz = hrp.Position.Z - LAKE_CENTER.Z
    return (dx * dx + dz * dz) <= ACTIVE_RADIUS_SQ
end

local function isFishingRod(item)
    return item and item:IsA("Tool") and item:GetAttribute("BBYAFishingRod") == true
end

local function fixRodGrip(tool)
    if not isFishingRod(tool) then return end
    -- Core v2 geometry grows from Handle toward +X. The old 68-degree grip made that
    -- long side point down through the avatar. Flip it 180 degrees so the tip points
    -- upward/forward while the reel remains near the hand.
    tool.Grip = CFrame.new(0, -0.45, 0) * CFrame.Angles(0, 0, math.rad(248))
    tool:SetAttribute("GripDirectionFixedV5", true)
end

local function clearFishingRodsFrom(container)
    if not container then return end
    for _, item in ipairs(container:GetChildren()) do
        if isFishingRod(item) then
            item:Destroy()
        end
    end
end

local function fixFishingRodsIn(container)
    if not container then return end
    for _, item in ipairs(container:GetChildren()) do
        if isFishingRod(item) then fixRodGrip(item) end
    end
end

local function storeRodOutsideLake(player)
    if nearFishingDistrict(player) then
        player:SetAttribute("BBYAFishingRodStored", false)
        fixFishingRodsIn(player.Character)
        fixFishingRodsIn(player:FindFirstChildOfClass("Backpack"))
        return
    end
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:UnequipTools() end
        clearFishingRodsFrom(char)
    end
    clearFishingRodsFrom(player:FindFirstChildOfClass("Backpack"))
    player:SetAttribute("BBYAFishingRodStored", true)
end

-- Make the original surface less transparent and substantially darken the body below it.
local lakeWater = district:FindFirstChild("LakeWater", true)
if lakeWater and lakeWater:IsA("BasePart") then
    lakeWater.Color = Color3.fromRGB(18, 58, 76)
    lakeWater.Transparency = 0.18
    lakeWater.Reflectance = 0.08
    lakeWater.Material = Enum.Material.Glass
    lakeWater:SetAttribute("DeepWaterSurfaceV394", true)
end

local deepWater = district:FindFirstChild("DeepWater", true)
if deepWater and deepWater:IsA("BasePart") then
    deepWater.Color = Color3.fromRGB(5, 22, 35)
    deepWater.Transparency = 0.08
    deepWater.Size = Vector3.new(deepWater.Size.X, 8.5, deepWater.Size.Z)
    deepWater.CFrame = CFrame.new(deepWater.Position.X, -3.65, deepWater.Position.Z)
    deepWater.Reflectance = 0.02
    deepWater.Material = Enum.Material.Glass
    deepWater:SetAttribute("DepthMetersVisual", 8.5)
end

local oldVolume = district:FindFirstChild("DeepLakeVolumeV394")
if oldVolume then oldVolume:Destroy() end
local volume = Instance.new("Part")
volume.Name = "DeepLakeVolumeV394"
volume.Shape = Enum.PartType.Ball
volume.Size = Vector3.new(214, 10.5, 132)
volume.CFrame = CFrame.new(LAKE_CENTER.X, -5.0, LAKE_CENTER.Z)
volume.Color = Color3.fromRGB(4, 18, 29)
volume.Material = Enum.Material.Glass
volume.Transparency = 0.15
volume.Reflectance = 0
volume.Anchored = true
volume.CanCollide = false
volume.CanTouch = false
volume.CanQuery = false
volume.CastShadow = false
volume.Parent = district

-- Keep ambient schools deep enough that they read as life below the surface, not fish lying on glass.
local upgrade = district:FindFirstChild("PremiumFishingUpgradeV3")
local schools = upgrade and upgrade:FindFirstChild("AmbientFishSchools", true)
if schools then
    local depthByName = {
        AzureSchool = -4.2,
        JadeSchool = -4.8,
        MoonSchool = -5.3,
        RareSchool = -4.5,
    }
    for _, school in ipairs(schools:GetChildren()) do
        if school:IsA("Model") and school:GetAttribute("BBYAFishSchool") == true then
            local targetY = depthByName[school.Name] or -4.6
            school:SetAttribute("CenterY", targetY)
            school:SetAttribute("SurfaceHiddenV394", true)
            for _, d in ipairs(school:GetDescendants()) do
                if d:IsA("BasePart") then d.Transparency = math.max(d.Transparency, 0.30) end
            end
        end
    end
end

-- =============================================================================
-- FISH ART V5 — SPECIES-SPECIFIC COLLECTIBLE SILHOUETTES
-- =============================================================================
local MAX_WEIGHT = {
    ["Moon Carp"]=2.4,["Azure Gourami"]=1.9,["Jade Peacock Bass"]=4.8,["Redtail Giant"]=8.5,
    ["Royal Koi"]=5.0,["Sapphire Barramundi"]=11.0,["Crimson Arowana"]=7.2,["Obsidian Ray"]=15.0,
    ["Golden Mahseer"]=18.0,["Aurora Arapaima"]=31.0,["Celestial Koi"]=10.0,["Phantom Leviathan"]=55.0,
}

local BASE_COLORS = {
    ["Moon Carp"]={Color3.fromRGB(151,171,181),Color3.fromRGB(216,230,232)},
    ["Azure Gourami"]={Color3.fromRGB(54,132,176),Color3.fromRGB(80,216,223)},
    ["Jade Peacock Bass"]={Color3.fromRGB(73,126,72),Color3.fromRGB(197,204,63)},
    ["Redtail Giant"]={Color3.fromRGB(58,65,73),Color3.fromRGB(220,61,59)},
    ["Royal Koi"]={Color3.fromRGB(236,233,220),Color3.fromRGB(231,104,55)},
    ["Sapphire Barramundi"]={Color3.fromRGB(92,125,154),Color3.fromRGB(174,218,230)},
    ["Crimson Arowana"]={Color3.fromRGB(176,43,58),Color3.fromRGB(247,142,79)},
    ["Obsidian Ray"]={Color3.fromRGB(31,29,40),Color3.fromRGB(111,81,151)},
    ["Golden Mahseer"]={Color3.fromRGB(165,116,40),Color3.fromRGB(245,204,88)},
    ["Aurora Arapaima"]={Color3.fromRGB(54,81,121),Color3.fromRGB(74,221,204)},
    ["Celestial Koi"]={Color3.fromRGB(235,234,222),Color3.fromRGB(240,193,74)},
    ["Phantom Leviathan"]={Color3.fromRGB(36,28,62),Color3.fromRGB(139,84,225)},
}

local MUTATION_COLORS = {
    GOLDEN=Color3.fromRGB(247,197,72),MOONLIT=Color3.fromRGB(149,190,255),LOTUS=Color3.fromRGB(239,112,178),
    CRYSTAL=Color3.fromRGB(94,226,237),SHADOW=Color3.fromRGB(103,70,164),AURORA=Color3.fromRGB(76,231,201),
    CELESTIAL=Color3.fromRGB(248,219,127),ABYSSAL=Color3.fromRGB(88,76,197),
}

local function makePart(model,name,size,localCF,color,material,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=model.PrimaryPart.CFrame*localCF
    p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    p.Shape=shape or Enum.PartType.Block
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=true
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p:SetAttribute("FishArtV5",true)
    p.Parent=model
    return p
end

local function ellipsoid(model,name,size,localCF,color,material)
    return makePart(model,name,size,localCF,color,material or Enum.Material.SmoothPlastic,Enum.PartType.Ball)
end

local function cylinder(model,name,size,localCF,color,material)
    return makePart(model,name,size,localCF,color,material or Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
end

local function wedge(model,name,size,localCF,color,material)
    local p=Instance.new("WedgePart")
    p.Name=name;p.Size=size;p.CFrame=model.PrimaryPart.CFrame*localCF;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=true
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p:SetAttribute("FishArtV5",true);p.Parent=model
    return p
end

local function mark(part,role)
    part:SetAttribute("FishArtRoleV5",role)
    return part
end

local function eye(model,x,y,z,scale)
    scale=scale or 1
    local e=mark(ellipsoid(model,"Eye",Vector3.new(.30,.30,.22)*scale,CFrame.new(x,y,z),Color3.fromRGB(8,9,11),Enum.Material.SmoothPlastic),"EYE")
    local g=mark(ellipsoid(model,"EyeGlint",Vector3.new(.10,.10,.08)*scale,CFrame.new(x+.06*scale,y+.06*scale,z+(z>0 and .11 or -.11)*scale),Color3.fromRGB(245,249,250),Enum.Material.Neon),"GLINT")
    return e,g
end

local function forkTail(model,x,height,depth,accent,tailParts)
    local top=mark(wedge(model,"TailUpper",Vector3.new(2.1,height,.32),CFrame.new(x,.55*height,0)*CFrame.Angles(0,math.rad(90),0),accent),"ACCENT")
    local bottom=mark(wedge(model,"TailLower",Vector3.new(2.1,height,.32),CFrame.new(x,-.55*height,0)*CFrame.Angles(math.rad(180),math.rad(90),0),accent),"ACCENT")
    table.insert(tailParts,{part=top,cf=CFrame.new(x,.55*height,0)*CFrame.Angles(0,math.rad(90),0)})
    table.insert(tailParts,{part=bottom,cf=CFrame.new(x,-.55*height,0)*CFrame.Angles(math.rad(180),math.rad(90),0)})
end

local function dorsal(model,x,y,length,height,accent,count)
    count=count or 1
    if count==1 then
        mark(wedge(model,"Dorsal",Vector3.new(length,height,.28),CFrame.new(x,y,0)*CFrame.Angles(0,math.rad(90),0),accent),"ACCENT")
    else
        for i=1,count do
            local xx=x+(i-(count+1)/2)*(length/count*.72)
            mark(wedge(model,"DorsalSpine"..i,Vector3.new(length/count+.15,height*(.72+.28*i/count),.20),CFrame.new(xx,y,0)*CFrame.Angles(0,math.rad(90),0),accent),"ACCENT")
        end
    end
end

local function sideFin(model,x,y,z,accent,flip)
    local cf=CFrame.new(x,y,z)*CFrame.Angles(math.rad(flip and 200 or -20),0,math.rad(flip and -12 or 12))
    mark(wedge(model,"PectoralFin",Vector3.new(1.4,.25,1.15),cf,accent),"ACCENT")
end

local function mouth(model,x,y,width)
    mark(ellipsoid(model,"Mouth",Vector3.new(.22,.30,width),CFrame.new(x,y,0),Color3.fromRGB(27,22,24),Enum.Material.SmoothPlastic),"MOUTH")
end

local function addScaleDots(model,startX,count,y,z,color,scale)
    for i=1,count do
        local x=startX-(i-1)*(.65*scale)
        mark(ellipsoid(model,"ScaleDetail",Vector3.new(.34,.26,.10)*scale,CFrame.new(x,y,z),color,Enum.Material.SmoothPlastic),"DETAIL")
    end
end

local function buildStandardFish(model,body,accent,scale,tailParts,variant)
    local long=variant=="BASS" and 5.8 or (variant=="BARRA" and 6.5 or 5.0)
    local high=variant=="BASS" and 2.75 or (variant=="BARRA" and 2.25 or 2.55)
    mark(ellipsoid(model,"Body",Vector3.new(long,high,1.85)*scale,CFrame.new(-.15,0,0),body),"BODY")
    mark(ellipsoid(model,"Head",Vector3.new(1.85,1.9,1.68)*scale,CFrame.new(long*.39*scale,0,0),body),"BODY")
    mouth(model,(long*.50+.32)*scale,-.08*scale,.62*scale)
    eye(model,(long*.42)*scale,.38*scale,-.77*scale,scale)
    eye(model,(long*.42)*scale,.38*scale,.77*scale,scale)
    forkTail(model,-long*.57*scale,1.25*scale,1.5*scale,accent,tailParts)
    dorsal(model,-.45*scale,high*.48*scale,2.25*scale,.85*scale,accent,variant=="BASS" and 5 or 1)
    sideFin(model,.65*scale,-.15*scale,.86*scale,accent,false)
    sideFin(model,.65*scale,-.15*scale,-.86*scale,accent,true)
    if variant=="BASS" then
        for i=1,3 do
            local x=(1.2-i*1.1)*scale
            mark(ellipsoid(model,"BassBand",Vector3.new(.34,2.05,1.90)*scale,CFrame.new(x,0,0),Color3.fromRGB(42,67,44),Enum.Material.SmoothPlastic),"DETAIL")
        end
    elseif variant=="BARRA" then
        mark(ellipsoid(model,"GillPlate",Vector3.new(.28,1.35,1.72)*scale,CFrame.new(1.8*scale,0,0),accent),"DETAIL")
    end
end

local function buildKoi(model,body,accent,scale,tailParts,celestial)
    mark(ellipsoid(model,"Body",Vector3.new(5.1,2.35,1.85)*scale,CFrame.new(-.2,0,0),body),"BODY")
    mark(ellipsoid(model,"Head",Vector3.new(1.6,1.65,1.58)*scale,CFrame.new(2.15*scale,.02,0),body),"BODY")
    mouth(model,2.92*scale,-.08*scale,.54*scale)
    eye(model,2.42*scale,.35*scale,-.68*scale,scale);eye(model,2.42*scale,.35*scale,.68*scale,scale)
    forkTail(model,-3.15*scale,1.55*scale,1.8*scale,accent,tailParts)
    dorsal(model,-.35*scale,1.12*scale,2.0*scale,.75*scale,accent,1)
    sideFin(model,.55*scale,-.20*scale,.82*scale,accent,false);sideFin(model,.55*scale,-.20*scale,-.82*scale,accent,true)
    for _,spec in ipairs({{1.2,.45},{.15,-.38},{-1.05,.32}}) do
        mark(ellipsoid(model,"KoiPatch",Vector3.new(1.15,.80,.10)*scale,CFrame.new(spec[1]*scale,spec[2]*scale,-.91*scale),accent,celestial and Enum.Material.Neon or Enum.Material.SmoothPlastic),"ACCENT")
        mark(ellipsoid(model,"KoiPatch",Vector3.new(1.15,.80,.10)*scale,CFrame.new(spec[1]*scale,spec[2]*scale,.91*scale),accent,celestial and Enum.Material.Neon or Enum.Material.SmoothPlastic),"ACCENT")
    end
    if celestial then
        for i=-2,2 do
            mark(ellipsoid(model,"CelestialPearl",Vector3.new(.23,.23,.23)*scale,CFrame.new(i*.72*scale,1.18*scale,0),accent,Enum.Material.Neon),"ACCENT")
        end
    end
end

local function buildGourami(model,body,accent,scale,tailParts)
    mark(ellipsoid(model,"Body",Vector3.new(4.25,3.25,1.45)*scale,CFrame.new(-.15,0,0),body),"BODY")
    mark(ellipsoid(model,"Head",Vector3.new(1.45,2.0,1.30)*scale,CFrame.new(1.8*scale,.05,0),body),"BODY")
    mouth(model,2.52*scale,-.05*scale,.46*scale)
    eye(model,2.02*scale,.47*scale,-.56*scale,scale);eye(model,2.02*scale,.47*scale,.56*scale,scale)
    forkTail(model,-2.65*scale,1.35*scale,1.4*scale,accent,tailParts)
    dorsal(model,-.35*scale,1.55*scale,2.15*scale,.68*scale,accent,1)
    mark(wedge(model,"AnalFin",Vector3.new(2.5,.75,.25)*scale,CFrame.new(-.45*scale,-1.50*scale,0)*CFrame.Angles(math.rad(180),math.rad(90),0),accent),"ACCENT")
    for _,z in ipairs({-.42,.42}) do
        mark(cylinder(model,"VentralFeelers",Vector3.new(2.8,.055,.055)*scale,CFrame.new(.65*scale,-1.6*scale,z*scale)*CFrame.Angles(0,0,math.rad(72)),accent),"ACCENT")
    end
end

local function buildCatfish(model,body,accent,scale,tailParts)
    mark(ellipsoid(model,"Body",Vector3.new(6.4,2.15,2.05)*scale,CFrame.new(-.7,0,0),body),"BODY")
    mark(ellipsoid(model,"BroadHead",Vector3.new(2.65,1.75,2.45)*scale,CFrame.new(2.15*scale,-.05,0),body),"BODY")
    mouth(model,3.50*scale,-.32*scale,.92*scale)
    eye(model,2.70*scale,.38*scale,-.92*scale,scale);eye(model,2.70*scale,.38*scale,.92*scale,scale)
    forkTail(model,-4.05*scale,1.45*scale,1.7*scale,accent,tailParts)
    dorsal(model,-.45*scale,1.05*scale,1.45*scale,.88*scale,body,1)
    for _,z in ipairs({-.78,-.42,.42,.78}) do
        local sign=z>0 and 1 or -1
        mark(cylinder(model,"Whisker",Vector3.new(2.55,.045,.045)*scale,CFrame.new(3.15*scale,-.28*scale,z*scale)*CFrame.Angles(0,math.rad(sign*26),math.rad(8)),Color3.fromRGB(118,124,126)),"DETAIL")
    end
end

local function buildArowana(model,body,accent,scale,tailParts,arapaima)
    local length=arapaima and 8.7 or 7.7
    local height=arapaima and 2.3 or 1.75
    mark(ellipsoid(model,"LongBody",Vector3.new(length,height,1.65)*scale,CFrame.new(-.55,0,0),body),"BODY")
    mark(ellipsoid(model,"Head",Vector3.new(2.05,height*.92,1.62)*scale,CFrame.new((length*.42)*scale,.10*scale,0),body),"BODY")
    mouth(model,(length*.54)*scale,.14*scale,.56*scale)
    eye(model,(length*.46)*scale,.36*scale,-.68*scale,scale);eye(model,(length*.46)*scale,.36*scale,.68*scale,scale)
    forkTail(model,-length*.58*scale,1.30*scale,1.55*scale,accent,tailParts)
    mark(wedge(model,"LongDorsal",Vector3.new(3.2,.62,.22)*scale,CFrame.new(-2.1*scale,height*.47*scale,0)*CFrame.Angles(0,math.rad(90),0),accent),"ACCENT")
    mark(wedge(model,"LongAnal",Vector3.new(3.0,.58,.22)*scale,CFrame.new(-2.1*scale,-height*.47*scale,0)*CFrame.Angles(math.rad(180),math.rad(90),0),accent),"ACCENT")
    for _,z in ipairs({-.78,.78}) do addScaleDots(model,2.25*scale,8,.12*scale,z*scale,arapaima and Color3.fromRGB(157,68,77) or accent,scale) end
end

local function buildRay(model,body,accent,scale,tailParts)
    mark(ellipsoid(model,"RayCore",Vector3.new(4.4,.82,4.35)*scale,CFrame.new(.15,0,0),body),"BODY")
    mark(wedge(model,"WingLeft",Vector3.new(4.8,.55,3.1)*scale,CFrame.new(-.15,0,2.7*scale)*CFrame.Angles(0,math.rad(180),0),body),"BODY")
    mark(wedge(model,"WingRight",Vector3.new(4.8,.55,3.1)*scale,CFrame.new(-.15,0,-2.7*scale),body),"BODY")
    mark(ellipsoid(model,"RaySnout",Vector3.new(1.5,.55,1.65)*scale,CFrame.new(2.4*scale,-.03,0),body),"BODY")
    eye(model,1.65*scale,.42*scale,-.72*scale,scale);eye(model,1.65*scale,.42*scale,.72*scale,scale)
    local tail=mark(cylinder(model,"RayTail",Vector3.new(6.2,.11,.11)*scale,CFrame.new(-4.4*scale,0,0),accent),"ACCENT")
    table.insert(tailParts,{part=tail,cf=CFrame.new(-4.4*scale,0,0)})
    mark(wedge(model,"RayStinger",Vector3.new(1.1,.38,.12)*scale,CFrame.new(-7.4*scale,0,0)*CFrame.Angles(0,math.rad(90),0),accent),"ACCENT")
end

local function buildLeviathan(model,body,accent,scale,tailParts)
    local positions={2.25,.9,-.55,-2.0,-3.45}
    for i,x in ipairs(positions) do
        local s=1-(i-1)*.08
        mark(ellipsoid(model,"LeviathanSegment"..i,Vector3.new(2.6,2.0*s,1.7*s)*scale,CFrame.new(x*scale,0,0),i==1 and body or Color3.fromRGB(math.max(20,body.R*255-5*i),math.max(18,body.G*255-3*i),math.max(34,body.B*255-2*i))),"BODY")
        if i>1 then
            dorsal(model,x*scale,1.0*s*scale,.75*scale,.80*s*scale,accent,1)
        end
    end
    mark(ellipsoid(model,"LeviathanHead",Vector3.new(2.7,2.25,2.0)*scale,CFrame.new(3.55*scale,.08,0),body),"BODY")
    mouth(model,4.85*scale,-.22*scale,.72*scale)
    eye(model,4.02*scale,.52*scale,-.82*scale,scale);eye(model,4.02*scale,.52*scale,.82*scale,scale)
    for _,z in ipairs({-.65,.65}) do
        mark(wedge(model,"Horn",Vector3.new(1.35,.42,.30)*scale,CFrame.new(3.9*scale,1.15*scale,z*scale)*CFrame.Angles(0,math.rad(90),math.rad(z>0 and 22 or -22)),accent,Enum.Material.Neon),"ACCENT")
    end
    forkTail(model,-5.0*scale,1.65*scale,1.9*scale,accent,tailParts)
end

local function applyMutationPalette(model,mutation,body,accent)
    local mutationColor=MUTATION_COLORS[mutation]
    for _,p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") and p:GetAttribute("FishArtV5") then
            local role=p:GetAttribute("FishArtRoleV5")
            if mutationColor and role~="EYE" and role~="GLINT" and role~="MOUTH" then
                if role=="ACCENT" then p.Color=mutationColor
                elseif role=="BODY" then p.Color=p.Color:Lerp(mutationColor,.22)
                elseif role=="DETAIL" then p.Color=p.Color:Lerp(mutationColor,.38) end
                if mutation=="CRYSTAL" and (role=="ACCENT" or role=="DETAIL") then p.Material=Enum.Material.Glass;p.Transparency=.12 end
                if mutation=="AURORA" or mutation=="CELESTIAL" or mutation=="ABYSSAL" then
                    if role=="ACCENT" then p.Material=Enum.Material.Neon end
                end
            end
        end
    end
end

local function rebuildCatchArt(model)
    if not model:IsA("Model") or not string.find(model.Name,"^Catch_") or model:GetAttribute("FishVisualV5") then return end
    task.spawn(function()
        local deadline=os.clock()+.9
        while model.Parent and os.clock()<deadline do
            if model.PrimaryPart and model:GetAttribute("FishName") and (model:GetAttribute("MutationV4") or model:GetAttribute("ProcessedProgressionV4")) then break end
            task.wait(.03)
        end
        if not model.Parent or not model.PrimaryPart then return end
        local fishName=model:GetAttribute("FishName")
        if type(fishName)~="string" or not BASE_COLORS[fishName] then return end
        local pivot=model:GetPivot()
        local weight=tonumber(model:GetAttribute("Weight")) or 1
        local maxWeight=MAX_WEIGHT[fishName] or math.max(weight,1)
        local ratio=math.clamp(weight/maxWeight,0,1.25)
        local scale=.78+.38*ratio
        local sizeGrade=model:GetAttribute("SizeGradeV4")
        if sizeGrade=="GIANT" then scale*=1.08 elseif sizeGrade=="TITAN" then scale*=1.16 end
        local colors=BASE_COLORS[fishName];local body,accent=colors[1],colors[2]

        local oldParts={}
        for _,d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then table.insert(oldParts,d) end end
        local rootPart=Instance.new("Part")
        rootPart.Name="FishRootV5";rootPart.Size=Vector3.new(.2,.2,.2);rootPart.CFrame=pivot;rootPart.Transparency=1;rootPart.Anchored=true
        rootPart.CanCollide=false;rootPart.CanTouch=false;rootPart.CanQuery=false;rootPart.Parent=model;model.PrimaryPart=rootPart
        for _,p in ipairs(oldParts) do if p~=rootPart and p.Parent then p:Destroy() end end

        local tailParts={}
        if fishName=="Moon Carp" then
            buildStandardFish(model,body,accent,scale,tailParts,"CARP")
        elseif fishName=="Azure Gourami" then
            buildGourami(model,body,accent,scale,tailParts)
        elseif fishName=="Jade Peacock Bass" then
            buildStandardFish(model,body,accent,scale,tailParts,"BASS")
        elseif fishName=="Redtail Giant" then
            buildCatfish(model,body,accent,scale,tailParts)
        elseif fishName=="Royal Koi" then
            buildKoi(model,body,accent,scale,tailParts,false)
        elseif fishName=="Sapphire Barramundi" then
            buildStandardFish(model,body,accent,scale,tailParts,"BARRA")
        elseif fishName=="Crimson Arowana" then
            buildArowana(model,body,accent,scale,tailParts,false)
        elseif fishName=="Obsidian Ray" then
            buildRay(model,body,accent,scale,tailParts)
        elseif fishName=="Golden Mahseer" then
            buildStandardFish(model,body,accent,scale*1.08,tailParts,"MAHSEER")
            for _,z in ipairs({-.90,.90}) do addScaleDots(model,1.4*scale,6,.15*scale,z*scale,accent,scale) end
        elseif fishName=="Aurora Arapaima" then
            buildArowana(model,body,accent,scale*1.10,tailParts,true)
        elseif fishName=="Celestial Koi" then
            buildKoi(model,body,accent,scale*1.08,tailParts,true)
        elseif fishName=="Phantom Leviathan" then
            buildLeviathan(model,body,accent,scale*1.12,tailParts)
        end

        local mutation=model:GetAttribute("MutationV4") or "NORMAL"
        applyMutationPalette(model,mutation,body,accent)
        model:SetAttribute("FishVisualV5",true)
        model:SetAttribute("SpeciesSilhouetteV5",fishName)
        model:SetAttribute("OldPrimitiveCatchArtRemovedV5",true)

        local rarity=model:GetAttribute("Rarity")
        if rarity=="LEGENDARY" or rarity=="MYTHIC" then
            local h=model:FindFirstChild("FishArtHighlightV5") or Instance.new("Highlight")
            h.Name="FishArtHighlightV5";h.FillColor=MUTATION_COLORS[mutation] or accent;h.FillTransparency=.90
            h.OutlineColor=MUTATION_COLORS[mutation] or accent;h.OutlineTransparency=.18;h.DepthMode=Enum.HighlightDepthMode.Occluded;h.Parent=model
        end

        -- A little tail life makes the reveal feel caught/alive instead of a frozen toy.
        task.spawn(function()
            local started=os.clock()
            while model.Parent and rootPart.Parent and os.clock()-started<4.0 do
                local t=os.clock()-started
                for idx,item in ipairs(tailParts) do
                    if item.part.Parent then
                        local yaw=math.sin(t*7+idx*.45)*math.rad(12)
                        item.part.CFrame=rootPart.CFrame*item.cf*CFrame.Angles(0,yaw,0)
                    end
                end
                task.wait(.055)
            end
        end)
    end)
end

district.ChildAdded:Connect(rebuildCatchArt)
for _,child in ipairs(district:GetChildren()) do rebuildCatchArt(child) end

local function setupPlayer(player)
    task.spawn(function()
        task.wait(1)
        storeRodOutsideLake(player)
    end)
    player.CharacterAdded:Connect(function(char)
        task.wait(1.2)
        storeRodOutsideLake(player)
        char.ChildAdded:Connect(function(item)
            if isFishingRod(item) then task.defer(fixRodGrip,item) end
        end)
    end)
    local backpack=player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack",8)
    if backpack then
        backpack.ChildAdded:Connect(function(item)
            if isFishingRod(item) then task.defer(fixRodGrip,item) end
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)

-- Authority guard: rod never travels back to club/mall and grip is corrected whenever it exists.
task.spawn(function()
    while task.wait(0.50) do
        for _, player in ipairs(Players:GetPlayers()) do
            if not nearFishingDistrict(player) then
                storeRodOutsideLake(player)
            else
                fixFishingRodsIn(player.Character)
                fixFishingRodsIn(player:FindFirstChildOfClass("Backpack"))
            end
        end
    end
end)

print("[BBYA] Fishing V5 art online: corrected rod grip + species-specific collectible catch silhouettes")
