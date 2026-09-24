-- BBYA SOCIAL HUB — FISH / ROD SATISFACTION v8 SERVER
-- Fishing-only additive polish over V5/V6. No probability, progression, economy, audio, travel,
-- monetization, mall, club, or global Lighting authority is changed here.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("BBYA_ZERO_BUILD", 35)
if not root then return end
local district = root:WaitForChild("PremiumFishingDistrictV2", 35)
if not district then return end

district:SetAttribute("FishingSatisfactionPass", "V8")
district:SetAttribute("FishAnatomyPolishV8", true)
district:SetAttribute("RodConstructionV8", true)
district:SetAttribute("CatchTrophyPlateV8", true)
district:SetAttribute("ChanceMathUntouchedV8", true)
district:SetAttribute("EconomyUntouchedV8", true)

local function weld(handle, part)
    part.Anchored = false
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    local w = Instance.new("WeldConstraint")
    w.Part0 = handle
    w.Part1 = part
    w.Parent = part
end

local function rodPart(folder, handle, name, size, localCF, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = handle.CFrame * localCF
    p.Color = color
    p.Material = material or Enum.Material.Metal
    p.Shape = shape or Enum.PartType.Block
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CastShadow = true
    p:SetAttribute("RodConstructionV8", true)
    p.Parent = folder
    weld(handle, p)
    return p
end

local function rodWedge(folder, handle, name, size, localCF, color, material)
    local p = Instance.new("WedgePart")
    p.Name = name
    p.Size = size
    p.CFrame = handle.CFrame * localCF
    p.Color = color
    p.Material = material or Enum.Material.Metal
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CastShadow = true
    p:SetAttribute("RodConstructionV8", true)
    p.Parent = folder
    weld(handle, p)
    return p
end

local function isFishingRod(item)
    return item and item:IsA("Tool") and item:GetAttribute("BBYAFishingRod") == true
end

local function addStyleSignature(folder, handle, skin, accent, dark)
    if skin == "Pearl Tide" then
        rodWedge(folder, handle, "WaveGuardL", Vector3.new(.72,.18,.56), CFrame.new(.36,-.56,.56)*CFrame.Angles(0,math.rad(180),math.rad(12)), accent, Enum.Material.Metal)
        rodWedge(folder, handle, "WaveGuardR", Vector3.new(.72,.18,.56), CFrame.new(.36,-.56,-.56)*CFrame.Angles(math.rad(180),0,math.rad(-12)), accent, Enum.Material.Metal)
    elseif skin == "Sakura Koi" then
        rodWedge(folder, handle, "KoiReelFinL", Vector3.new(.90,.20,.64), CFrame.new(.18,-.46,.62)*CFrame.Angles(0,math.rad(180),math.rad(18)), accent, Enum.Material.SmoothPlastic)
        rodWedge(folder, handle, "KoiReelFinR", Vector3.new(.90,.20,.64), CFrame.new(.18,-.46,-.62)*CFrame.Angles(math.rad(180),0,math.rad(-18)), accent, Enum.Material.SmoothPlastic)
    elseif skin == "Neon Circuit" then
        for i,x in ipairs({1.75,2.75,3.75,4.75}) do
            rodPart(folder,handle,"CircuitRail"..i,Vector3.new(.62,.055,.055),CFrame.new(x,.24,0),accent,Enum.Material.Neon,Enum.PartType.Cylinder)
        end
    elseif skin == "Crimson Dragon" then
        for i,x in ipairs({1.65,2.55,3.45}) do
            rodWedge(folder,handle,"DragonRidge"..i,Vector3.new(.58,.62,.16),CFrame.new(x,.34,0)*CFrame.Angles(0,math.rad(90),0),accent,i==3 and Enum.Material.Neon or Enum.Material.Metal)
        end
    elseif skin == "Celestial Moon" then
        rodWedge(folder,handle,"MoonGuardL",Vector3.new(.82,.22,.52),CFrame.new(.16,-.52,.52)*CFrame.Angles(0,math.rad(180),math.rad(28)),accent,Enum.Material.Metal)
        rodWedge(folder,handle,"MoonGuardR",Vector3.new(.82,.22,.52),CFrame.new(.16,-.52,-.52)*CFrame.Angles(math.rad(180),0,math.rad(-28)),accent,Enum.Material.Metal)
        rodPart(folder,handle,"MoonCore",Vector3.new(.30,.30,.30),CFrame.new(.36,-.50,0),accent,Enum.Material.Neon,Enum.PartType.Ball)
    elseif skin == "Poseidon Crown" then
        for i,z in ipairs({-.26,0,.26}) do
            rodPart(folder,handle,"TridentProng"..i,Vector3.new(.74,.075,.075),CFrame.new(7.72,.10,z)*CFrame.Angles(0,0,math.rad(z==0 and 0 or (z>0 and 8 or -8))),accent,Enum.Material.Metal,Enum.PartType.Cylinder)
        end
    elseif skin == "Phantom Leviathan" then
        for i,x in ipairs({1.75,2.55,3.35,4.15}) do
            rodWedge(folder,handle,"LeviathanRib"..i,Vector3.new(.48,.56,.18),CFrame.new(x,.31,0)*CFrame.Angles(0,math.rad(90),0),accent,i>=3 and Enum.Material.Neon or Enum.Material.Metal)
        end
    elseif skin == "BBYA Royal" then
        rodPart(folder,handle,"RoyalPommel",Vector3.new(.42,.58,.58),CFrame.new(-1.55,0,0),accent,Enum.Material.Metal,Enum.PartType.Cylinder)
        for i,z in ipairs({-.34,0,.34}) do
            rodWedge(folder,handle,"RoyalCrown"..i,Vector3.new(.42,.54,.16),CFrame.new(.10,-.16,z)*CFrame.Angles(0,math.rad(90),0),accent,Enum.Material.Metal)
        end
        rodPart(folder,handle,"RoyalJewel",Vector3.new(.25,.25,.25),CFrame.new(.34,-.50,0),accent,Enum.Material.Neon,Enum.PartType.Ball)
    else
        rodPart(folder,handle,"CarbonBraceA",Vector3.new(.42,.34,.34),CFrame.new(1.55,0,0),dark,Enum.Material.Metal,Enum.PartType.Cylinder)
        rodPart(folder,handle,"CarbonBraceB",Vector3.new(.34,.28,.28),CFrame.new(3.25,0,0),accent,Enum.Material.Metal,Enum.PartType.Cylinder)
    end
end

local function polishRod(tool)
    if not isFishingRod(tool) then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle or not handle:IsA("BasePart") then return end

    local skin = tostring(tool:GetAttribute("RodSkin") or "Graphite Core")
    local rarity = tostring(tool:GetAttribute("RodSkinRarity") or "COMMON")
    local old = tool:FindFirstChild("RodSatisfactionV8")
    if old and old:GetAttribute("Skin") == skin then return end
    if old then old:Destroy() end

    local folder = Instance.new("Folder")
    folder.Name = "RodSatisfactionV8"
    folder:SetAttribute("Skin", skin)
    folder:SetAttribute("Rarity", rarity)
    folder.Parent = tool

    local tip = tool:FindFirstChild("TipSegment")
    local body = tool:FindFirstChild("RodSegment1")
    local accent = tip and tip:IsA("BasePart") and tip.Color or Color3.fromRGB(226,188,95)
    local dark = body and body:IsA("BasePart") and body.Color or Color3.fromRGB(37,41,48)

    -- Mechanical silhouette: reel seat + spool + bail + foregrip. V6 remains grip authority.
    rodPart(folder,handle,"ReelSeat",Vector3.new(.72,.16,.26),CFrame.new(.28,-.26,0),dark,Enum.Material.Metal)
    rodPart(folder,handle,"SpoolOuter",Vector3.new(.22,1.18,1.18),CFrame.new(.34,-.55,0),accent,Enum.Material.Metal,Enum.PartType.Cylinder)
    rodPart(folder,handle,"SpoolInner",Vector3.new(.27,.72,.72),CFrame.new(.34,-.55,0),dark,Enum.Material.Metal,Enum.PartType.Cylinder)
    rodPart(folder,handle,"LineRoller",Vector3.new(.20,.20,.20),CFrame.new(.52,-.08,.46),accent,Enum.Material.Metal,Enum.PartType.Ball)
    rodPart(folder,handle,"BailArmL",Vector3.new(.08,.72,.08),CFrame.new(.48,-.22,.48)*CFrame.Angles(0,0,math.rad(28)),accent,Enum.Material.Metal,Enum.PartType.Cylinder)
    rodPart(folder,handle,"BailArmR",Vector3.new(.08,.72,.08),CFrame.new(.48,-.22,-.48)*CFrame.Angles(0,0,math.rad(28)),accent,Enum.Material.Metal,Enum.PartType.Cylinder)
    rodPart(folder,handle,"ForeGrip",Vector3.new(.68,.38,.38),CFrame.new(1.05,0,0),dark:Lerp(accent,.18),Enum.Material.Fabric,Enum.PartType.Cylinder)
    rodPart(folder,handle,"ForeGripRing",Vector3.new(.12,.44,.44),CFrame.new(1.40,0,0),accent,Enum.Material.Metal,Enum.PartType.Cylinder)

    addStyleSignature(folder, handle, skin, accent, dark)

    if rarity == "LEGENDARY" or rarity == "MYTHIC" then
        local core = rodPart(folder,handle,"TrophyCoreV8",Vector3.new(.22,.22,.22),CFrame.new(5.65,.22,0),accent,Enum.Material.Neon,Enum.PartType.Ball)
        local light = Instance.new("PointLight")
        light.Color = accent
        light.Brightness = rarity == "MYTHIC" and .22 or .12
        light.Range = rarity == "MYTHIC" and 3.2 or 2.2
        light.Shadows = false
        light.Parent = core
    end

    tool:SetAttribute("RodConstructionV8", true)
    tool:SetAttribute("RodSilhouetteV8", skin)
end

local function polishRods(container)
    if not container then return end
    for _, item in ipairs(container:GetChildren()) do
        if isFishingRod(item) then polishRod(item) end
    end
end

-- =============================================================================
-- FISH ANATOMY V8
-- Adds silhouette connectors, gill plates, lateral line and trophy hierarchy above V5/V6.
-- =============================================================================
local PROFILES = {
    ["Moon Carp"]={gill=1.55,side=.94,tail=-2.45,lineX=1.05,lineStep=.62},
    ["Azure Gourami"]={gill=1.32,side=.74,tail=-2.10,lineX=.90,lineStep=.52},
    ["Jade Peacock Bass"]={gill=1.70,side=.98,tail=-2.62,lineX=1.05,lineStep=.68},
    ["Redtail Giant"]={gill=1.72,side=1.18,tail=-3.28,lineX=.95,lineStep=.80},
    ["Royal Koi"]={gill=1.62,side=.96,tail=-2.55,lineX=.95,lineStep=.62},
    ["Sapphire Barramundi"]={gill=1.96,side=.90,tail=-3.02,lineX=1.18,lineStep=.72},
    ["Crimson Arowana"]={gill=2.42,side=.86,tail=-3.65,lineX=1.60,lineStep=.82},
    ["Golden Mahseer"]={gill=1.82,side=.94,tail=-2.72,lineX=1.05,lineStep=.67},
    ["Aurora Arapaima"]={gill=2.70,side=.89,tail=-4.08,lineX=1.90,lineStep=.88},
    ["Celestial Koi"]={gill=1.62,side=.96,tail=-2.55,lineX=.95,lineStep=.62},
}

local function fishPart(folder, model, name, size, localCF, color, material, shape)
    if not model.PrimaryPart then return nil end
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = model.PrimaryPart.CFrame * localCF
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Shape = shape or Enum.PartType.Block
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p:SetAttribute("FishAnatomyV8", true)
    p.Parent = folder
    return p
end

local function fishWedge(folder, model, name, size, localCF, color, material)
    if not model.PrimaryPart then return nil end
    local p = Instance.new("WedgePart")
    p.Name = name
    p.Size = size
    p.CFrame = model.PrimaryPart.CFrame * localCF
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p:SetAttribute("FishAnatomyV8", true)
    p.Parent = folder
    return p
end

local function bodyColors(model)
    local body = model:FindFirstChild("Body", true)
        or model:FindFirstChild("LongBody", true)
        or model:FindFirstChild("RayCore", true)
        or model:FindFirstChild("LeviathanSegment1", true)
    local accent = model:FindFirstChild("Dorsal", true)
        or model:FindFirstChild("TailUpper", true)
        or model:FindFirstChild("TailTop", true)
        or model:FindFirstChild("RayStinger", true)
    local base = body and body:IsA("BasePart") and body.Color or Color3.fromRGB(112,138,148)
    local acc = accent and accent:IsA("BasePart") and accent.Color or Color3.fromRGB(218,191,108)
    return base, acc
end

local function scaleFromModel(model, fishName)
    local profile = PROFILES[fishName]
    local body = model:FindFirstChild("Body", true)
        or model:FindFirstChild("LongBody", true)
        or model:FindFirstChild("RayCore", true)
        or model:FindFirstChild("LeviathanSegment1", true)
    if not body or not body:IsA("BasePart") then return 1 end
    local reference = 5.0
    if fishName == "Azure Gourami" then reference = 4.25
    elseif fishName == "Jade Peacock Bass" then reference = 5.8
    elseif fishName == "Redtail Giant" then reference = 6.4
    elseif fishName == "Royal Koi" or fishName == "Celestial Koi" then reference = 5.1
    elseif fishName == "Sapphire Barramundi" then reference = 6.5
    elseif fishName == "Crimson Arowana" then reference = 7.7
    elseif fishName == "Golden Mahseer" then reference = 6.5
    elseif fishName == "Aurora Arapaima" then reference = 8.7
    elseif fishName == "Obsidian Ray" then reference = 4.4
    elseif fishName == "Phantom Leviathan" then reference = 2.6
    end
    return math.clamp(body.Size.X / reference, .65, 2.2)
end

local function addStandardAnatomy(folder, model, fishName, s, base, accent)
    local p = PROFILES[fishName]
    if not p then return end

    fishPart(folder,model,"TailRootV8",Vector3.new(.78,.88,.92)*s,CFrame.new(p.tail*s,0,0),base,Enum.Material.SmoothPlastic,Enum.PartType.Ball)

    for _,z in ipairs({-p.side,p.side}) do
        fishPart(folder,model,"GillPlateV8",Vector3.new(.22,.92,.66)*s,CFrame.new(p.gill*s,.02*s,z*s),base:Lerp(accent,.22),Enum.Material.Metal,Enum.PartType.Ball)
        for i=1,5 do
            local x=(p.lineX-(i-1)*p.lineStep)*s
            fishPart(folder,model,"LateralScaleV8",Vector3.new(.38,.16,.08)*s,CFrame.new(x,.03*s,z*s),base:Lerp(accent,.35),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
        end
    end

    fishPart(folder,model,"ChestVolumeV8",Vector3.new(1.22,1.12,1.22)*s,CFrame.new((p.gill-.55)*s,-.12*s,0),base,Enum.Material.SmoothPlastic,Enum.PartType.Ball)

    if fishName == "Moon Carp" or fishName == "Royal Koi" or fishName == "Celestial Koi" or fishName == "Golden Mahseer" then
        fishPart(folder,model,"LipVolumeV8",Vector3.new(.42,.30,.72)*s,CFrame.new((p.gill+1.18)*s,-.15*s,0),base:Lerp(accent,.18),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    elseif fishName == "Sapphire Barramundi" or fishName == "Jade Peacock Bass" then
        fishPart(folder,model,"JawHingeV8",Vector3.new(.52,.40,.92)*s,CFrame.new((p.gill+1.00)*s,-.34*s,0),base:Lerp(Color3.new(0,0,0),.18),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    elseif fishName == "Redtail Giant" then
        fishPart(folder,model,"SkullPlateV8",Vector3.new(1.34,.32,1.74)*s,CFrame.new((p.gill+.48)*s,.48*s,0),base:Lerp(accent,.12),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    elseif fishName == "Crimson Arowana" or fishName == "Aurora Arapaima" then
        fishPart(folder,model,"ScaleShoulderV8",Vector3.new(.44,1.18,1.48)*s,CFrame.new((p.gill-.18)*s,.02*s,0),accent,Enum.Material.Metal,Enum.PartType.Ball)
    end
end

local function addRayAnatomy(folder, model, s, base, accent)
    fishPart(folder,model,"RayShoulderV8",Vector3.new(2.35,.58,2.55)*s,CFrame.new(.95*s,.03*s,0),base,Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    fishPart(folder,model,"RayMouthV8",Vector3.new(.54,.16,1.05)*s,CFrame.new(1.48*s,-.48*s,0),Color3.fromRGB(34,28,36),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    fishPart(folder,model,"RayTailRootV8",Vector3.new(1.18,.25,.32)*s,CFrame.new(-2.45*s,0,0),accent,Enum.Material.SmoothPlastic,Enum.PartType.Cylinder)
    for _,z in ipairs({-1.15,1.15}) do
        fishPart(folder,model,"RaySpiracleV8",Vector3.new(.26,.16,.34)*s,CFrame.new(.95*s,.42*s,z*s),Color3.fromRGB(24,22,30),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    end
end

local function addLeviathanAnatomy(folder, model, s, base, accent)
    fishPart(folder,model,"LeviathanCheekV8",Vector3.new(1.25,1.12,1.72)*s,CFrame.new(3.05*s,-.12*s,0),base:Lerp(accent,.12),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    fishPart(folder,model,"LeviathanJawHingeV8",Vector3.new(.62,.74,1.62)*s,CFrame.new(3.82*s,-.58*s,0),Color3.fromRGB(25,18,37),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
    fishPart(folder,model,"LeviathanBrowV8",Vector3.new(.88,.30,1.85)*s,CFrame.new(3.74*s,.80*s,0),accent,Enum.Material.Metal,Enum.PartType.Ball)
    for i,x in ipairs({1.55,.45,-.65,-1.75,-2.85}) do
        fishWedge(folder,model,"LeviathanBackRidgeV8_"..i,Vector3.new(.58,.78,.20)*s,CFrame.new(x*s,1.02*s,0)*CFrame.Angles(0,math.rad(90),0),accent,i>=4 and Enum.Material.Neon or Enum.Material.Metal)
    end
end

local function addTrophyHierarchy(folder, model, s, rarity, accent)
    if rarity == "LEGENDARY" then
        for i,x in ipairs({.90,-.15,-1.20}) do
            fishPart(folder,model,"LegendPlateV8_"..i,Vector3.new(.40,.24,.12)*s,CFrame.new(x*s,.68*s,.78*s),accent,Enum.Material.Metal,Enum.PartType.Ball)
        end
    elseif rarity == "MYTHIC" then
        for i,x in ipairs({1.20,.25,-.70,-1.65}) do
            local p=fishPart(folder,model,"MythicPlateV8_"..i,Vector3.new(.44,.28,.13)*s,CFrame.new(x*s,.72*s,.80*s),accent,Enum.Material.Neon,Enum.PartType.Ball)
            if p then p.Transparency=.05 end
        end
    end
end

local rarityColors = {
    COMMON=Color3.fromRGB(196,202,207),
    UNCOMMON=Color3.fromRGB(96,213,131),
    RARE=Color3.fromRGB(74,161,242),
    EPIC=Color3.fromRGB(177,102,236),
    LEGENDARY=Color3.fromRGB(246,188,72),
    MYTHIC=Color3.fromRGB(244,99,173),
}

local function addTrophyPlate(model, fishName, rarity, s)
    if not model.PrimaryPart or model.PrimaryPart:FindFirstChild("CatchTrophyPlateV8") then return end

    local variant = tostring(model:GetAttribute("VariantNameV4") or fishName)
    local mutation = tostring(model:GetAttribute("MutationV4") or "NORMAL")
    local sizeGrade = tostring(model:GetAttribute("SizeGradeV4") or "")
    local weight = tonumber(model:GetAttribute("Weight")) or 0
    local color = rarityColors[rarity] or Color3.fromRGB(225,188,89)

    local bill = Instance.new("BillboardGui")
    bill.Name = "CatchTrophyPlateV8"
    bill.Size = UDim2.fromOffset(250,62)
    bill.StudsOffsetWorldSpace = Vector3.new(0,3.0*s,0)
    bill.MaxDistance = 72
    bill.AlwaysOnTop = false
    bill.LightInfluence = .15
    bill.Parent = model.PrimaryPart

    local card = Instance.new("Frame")
    card.Size = UDim2.fromScale(1,1)
    card.BackgroundColor3 = Color3.fromRGB(14,17,21)
    card.BackgroundTransparency = .12
    card.BorderSizePixel = 0
    card.Parent = bill
    local corner = Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,9); corner.Parent=card
    local stroke = Instance.new("UIStroke"); stroke.Color=color; stroke.Transparency=.24; stroke.Thickness=1.2; stroke.Parent=card

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency=1
    title.Position=UDim2.fromOffset(10,6)
    title.Size=UDim2.new(1,-20,0,23)
    title.Font=Enum.Font.GothamBlack
    title.TextSize=14
    title.TextColor3=Color3.fromRGB(245,246,247)
    title.TextXAlignment=Enum.TextXAlignment.Left
    title.TextTruncate=Enum.TextTruncate.AtEnd
    title.Text=variant
    title.Parent=card

    local meta = Instance.new("TextLabel")
    meta.BackgroundTransparency=1
    meta.Position=UDim2.fromOffset(10,31)
    meta.Size=UDim2.new(1,-20,0,20)
    meta.Font=Enum.Font.GothamBold
    meta.TextSize=10
    meta.TextColor3=color
    meta.TextXAlignment=Enum.TextXAlignment.Left
    local tags={}
    table.insert(tags,rarity)
    if sizeGrade~="" and sizeGrade~="NORMAL" then table.insert(tags,sizeGrade) end
    if mutation~="" and mutation~="NORMAL" then table.insert(tags,mutation) end
    table.insert(tags,string.format("%.2f kg",weight))
    meta.Text=table.concat(tags,"  •  ")
    meta.Parent=card
end

local function decorateCatch(model)
    if not model:IsA("Model") or not string.find(model.Name,"^Catch_") or model:GetAttribute("FishAnatomyV8") then return end
    task.spawn(function()
        local deadline=os.clock()+1.8
        while model.Parent and os.clock()<deadline do
            if model.PrimaryPart and model:GetAttribute("FishVisualV5")==true and model:GetAttribute("FishAnatomyV6")==true then break end
            task.wait(.04)
        end
        if not model.Parent or not model.PrimaryPart or model:GetAttribute("FishVisualV5")~=true then return end

        local fishName=model:GetAttribute("FishName")
        if type(fishName)~="string" then return end

        -- Progression sets ProcessedProgressionV4 early, then fills mutation/variant metadata.
        -- Wait for those presentation attributes so the trophy plate cannot race back to base fish text.
        local waitProgress=os.clock()+.70
        while model.Parent and os.clock()<waitProgress do
            if model:GetAttribute("VariantNameV4") or model:GetAttribute("MutationV4") then break end
            task.wait(.035)
        end
        if not model.Parent then return end

        local old=model:FindFirstChild("FishSatisfactionV8")
        if old then old:Destroy() end
        local folder=Instance.new("Folder")
        folder.Name="FishSatisfactionV8"
        folder.Parent=model

        local s=scaleFromModel(model,fishName)
        local base,accent=bodyColors(model)
        local rarity=tostring(model:GetAttribute("Rarity") or "COMMON")

        if fishName=="Obsidian Ray" then
            addRayAnatomy(folder,model,s,base,accent)
        elseif fishName=="Phantom Leviathan" then
            addLeviathanAnatomy(folder,model,s,base,accent)
        else
            addStandardAnatomy(folder,model,fishName,s,base,accent)
        end

        addTrophyHierarchy(folder,model,s,rarity,accent)
        addTrophyPlate(model,fishName,rarity,s)

        model:SetAttribute("FishAnatomyV8",true)
        model:SetAttribute("CollectibleSilhouetteV8",fishName)
        model:SetAttribute("TrophyPresentationV8",true)
    end)
end

district.ChildAdded:Connect(decorateCatch)
for _,child in ipairs(district:GetChildren()) do decorateCatch(child) end

local hooked=setmetatable({}, {__mode="k"})
local function hookContainer(container)
    if not container or hooked[container] then return end
    hooked[container]=true
    polishRods(container)
    container.ChildAdded:Connect(function(item)
        if isFishingRod(item) then
            task.delay(.10,function()
                if item.Parent then polishRod(item) end
            end)
        end
    end)
end

local function setupPlayer(player)
    task.spawn(function()
        local backpack=player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack",8)
        hookContainer(backpack)
        if player.Character then hookContainer(player.Character) end
    end)
    player.CharacterAdded:Connect(function(char)
        task.wait(.7)
        hookContainer(char)
    end)
end

for _,player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)

task.spawn(function()
    while task.wait(.75) do
        for _,player in ipairs(Players:GetPlayers()) do
            if player:GetAttribute("BBYAFishingGateSideV6")==true then
                polishRods(player.Character)
                polishRods(player:FindFirstChildOfClass("Backpack"))
            end
        end
    end
end)

print("[BBYA] Fishing Satisfaction v8 server online: collectible fish anatomy + differentiated rod construction + trophy plate; chance/economy untouched")
