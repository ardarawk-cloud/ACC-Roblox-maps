local FurnitureAssets = {}

FurnitureAssets.Order = {"StarLamp","BunnyChair","ToyChest","CloudBed","RainbowSofa","MiniAquarium"}
FurnitureAssets.Definitions = {
    StarLamp={DisplayName="Star Lamp",Footprint=Vector3.new(1.5,4,1.5)},
    BunnyChair={DisplayName="Bunny Chair",Footprint=Vector3.new(2.5,3,2.5)},
    ToyChest={DisplayName="Toy Chest",Footprint=Vector3.new(3,2,2)},
    CloudBed={DisplayName="Cloud Bed",Footprint=Vector3.new(6,2,4)},
    RainbowSofa={DisplayName="Rainbow Sofa",Footprint=Vector3.new(6,2.5,2.5)},
    MiniAquarium={DisplayName="Mini Aquarium",Footprint=Vector3.new(4,3,2)},
}

local function part(model,name,size,position,color,material,shape)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=CFrame.new(position)
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.CastShadow=true
    p.Color=color
    p.Material=material or Enum.Material.SmoothPlastic
    if shape then p.Shape=shape end
    p:SetAttribute("WP_BaseColorR",color.R)
    p:SetAttribute("WP_BaseColorG",color.G)
    p:SetAttribute("WP_BaseColorB",color.B)
    p:SetAttribute("WP_BaseTransparency",p.Transparency)
    p.Parent=model
    return p
end

local function root(model,itemId)
    local p=Instance.new("Part")
    p.Name="Root"
    p.Size=Vector3.new(.2,.2,.2)
    p.CFrame=CFrame.new()
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=false
    p.Transparency=1
    p.CastShadow=false
    p:SetAttribute("WP_FurnitureRoot",true)
    p.Parent=model
    model.PrimaryPart=p
    model:SetAttribute("WP_ItemId",itemId)
    return p
end

local function ball(model,name,size,position,color,material)
    return part(model,name,size,position,color,material,Enum.PartType.Ball)
end

local function buildStarLamp(model)
    part(model,"Base",Vector3.new(1.25,.22,1.25),Vector3.new(0,-1.88,0),Color3.fromRGB(93,102,126),Enum.Material.Metal)
    part(model,"Pole",Vector3.new(.18,2.55,.18),Vector3.new(0,-.55,0),Color3.fromRGB(125,134,157),Enum.Material.Metal)
    local glow=ball(model,"Glow",Vector3.new(.86,.86,.86),Vector3.new(0,1.02,0),Color3.fromRGB(255,222,92),Enum.Material.Neon)
    glow.Transparency=.05
    glow:SetAttribute("WP_BaseTransparency",glow.Transparency)
    for i=0,4 do
        local a=math.rad(i*72-90)
        ball(model,"StarPoint"..i,Vector3.new(.42,.42,.28),Vector3.new(math.cos(a)*.52,1.02+math.sin(a)*.52,0),Color3.fromRGB(255,232,118),Enum.Material.Neon)
    end
    part(model,"ShadeRing",Vector3.new(1.28,.12,1.28),Vector3.new(0,.55,0),Color3.fromRGB(255,246,207),Enum.Material.Glass)
end

local function buildBunnyChair(model)
    local pink=Color3.fromRGB(244,207,226)
    part(model,"Seat",Vector3.new(2.05,.38,1.8),Vector3.new(0,-.65,.12),pink)
    part(model,"Back",Vector3.new(2.05,1.45,.34),Vector3.new(0,.18,-.7),pink)
    part(model,"LegL",Vector3.new(.34,1.0,.34),Vector3.new(-.72,-1.15,-.48),Color3.fromRGB(211,169,194))
    part(model,"LegR",Vector3.new(.34,1.0,.34),Vector3.new(.72,-1.15,-.48),Color3.fromRGB(211,169,194))
    part(model,"FrontLegL",Vector3.new(.34,1.0,.34),Vector3.new(-.72,-1.15,.62),Color3.fromRGB(211,169,194))
    part(model,"FrontLegR",Vector3.new(.34,1.0,.34),Vector3.new(.72,-1.15,.62),Color3.fromRGB(211,169,194))
    part(model,"EarL",Vector3.new(.42,1.12,.3),Vector3.new(-.55,1.05,-.7),pink)
    part(model,"EarR",Vector3.new(.42,1.12,.3),Vector3.new(.55,1.05,-.7),pink)
    ball(model,"Tail",Vector3.new(.48,.48,.48),Vector3.new(0,-.2,-1.0),Color3.fromRGB(255,242,248))
end

local function buildToyChest(model)
    local wood=Color3.fromRGB(176,111,64)
    part(model,"Chest",Vector3.new(2.7,1.25,1.7),Vector3.new(0,-.32,0),wood,Enum.Material.Wood)
    part(model,"Lid",Vector3.new(2.85,.34,1.82),Vector3.new(0,.46,0),Color3.fromRGB(132,77,47),Enum.Material.Wood)
    part(model,"BandL",Vector3.new(.18,1.62,1.85),Vector3.new(-.9,.02,0),Color3.fromRGB(90,100,116),Enum.Material.Metal)
    part(model,"BandR",Vector3.new(.18,1.62,1.85),Vector3.new(.9,.02,0),Color3.fromRGB(90,100,116),Enum.Material.Metal)
    part(model,"Lock",Vector3.new(.4,.42,.14),Vector3.new(0,-.1,.92),Color3.fromRGB(245,199,71),Enum.Material.Metal)
    ball(model,"ToyBall",Vector3.new(.5,.5,.5),Vector3.new(.65,.82,0),Color3.fromRGB(105,190,255))
end

local function buildCloudBed(model)
    part(model,"Frame",Vector3.new(5.6,.36,3.45),Vector3.new(0,-.82,.1),Color3.fromRGB(193,216,249))
    part(model,"Mattress",Vector3.new(5.25,.42,3.12),Vector3.new(0,-.48,.1),Color3.fromRGB(250,252,255),Enum.Material.Fabric)
    part(model,"Blanket",Vector3.new(3.1,.16,3.0),Vector3.new(1.0,-.18,.1),Color3.fromRGB(178,215,255),Enum.Material.Fabric)
    part(model,"PillowL",Vector3.new(1.25,.28,1.1),Vector3.new(-1.7,-.18,-.75),Color3.fromRGB(255,255,255),Enum.Material.Fabric)
    part(model,"PillowR",Vector3.new(1.25,.28,1.1),Vector3.new(-.3,-.18,-.75),Color3.fromRGB(255,255,255),Enum.Material.Fabric)
    ball(model,"CloudL",Vector3.new(1.35,1.05,.72),Vector3.new(-1.75,.35,-1.45),Color3.fromRGB(242,248,255))
    ball(model,"CloudM",Vector3.new(1.7,1.3,.8),Vector3.new(-.6,.5,-1.5),Color3.fromRGB(242,248,255))
    ball(model,"CloudR",Vector3.new(1.35,1.05,.72),Vector3.new(.65,.35,-1.45),Color3.fromRGB(242,248,255))
end

local function buildRainbowSofa(model)
    part(model,"Base",Vector3.new(5.55,.62,2.05),Vector3.new(0,-.68,.12),Color3.fromRGB(243,151,177),Enum.Material.Fabric)
    part(model,"Back",Vector3.new(5.4,1.28,.36),Vector3.new(0,.2,-.83),Color3.fromRGB(145,183,247),Enum.Material.Fabric)
    part(model,"ArmL",Vector3.new(.5,1.25,2.0),Vector3.new(-2.55,-.15,.1),Color3.fromRGB(255,190,207),Enum.Material.Fabric)
    part(model,"ArmR",Vector3.new(.5,1.25,2.0),Vector3.new(2.55,-.15,.1),Color3.fromRGB(255,190,207),Enum.Material.Fabric)
    local colors={Color3.fromRGB(255,219,100),Color3.fromRGB(111,211,166),Color3.fromRGB(176,141,246)}
    for i=1,3 do
        part(model,"Cushion"..i,Vector3.new(1.55,.25,1.55),Vector3.new((i-2)*1.65,-.2,.15),colors[i],Enum.Material.Fabric)
    end
    ball(model,"Pillow",Vector3.new(.72,.72,.38),Vector3.new(1.9,.38,-.55),Color3.fromRGB(255,244,174),Enum.Material.Fabric)
end

local function buildMiniAquarium(model)
    part(model,"Base",Vector3.new(3.7,.28,1.75),Vector3.new(0,-1.34,0),Color3.fromRGB(67,77,99),Enum.Material.Metal)
    part(model,"Top",Vector3.new(3.7,.22,1.75),Vector3.new(0,1.32,0),Color3.fromRGB(67,77,99),Enum.Material.Metal)
    local glass=part(model,"Tank",Vector3.new(3.45,2.35,1.52),Vector3.new(0,0,0),Color3.fromRGB(187,232,255),Enum.Material.Glass)
    glass.Transparency=.5
    glass:SetAttribute("WP_BaseTransparency",glass.Transparency)
    local water=part(model,"Water",Vector3.new(3.25,1.75,1.34),Vector3.new(0,-.15,0),Color3.fromRGB(72,181,230),Enum.Material.Glass)
    water.Transparency=.35
    water:SetAttribute("WP_BaseTransparency",water.Transparency)
    ball(model,"FishA",Vector3.new(.48,.3,.22),Vector3.new(.72,.15,.72),Color3.fromRGB(255,150,72))
    ball(model,"FishB",Vector3.new(.4,.26,.2),Vector3.new(-.7,-.35,.72),Color3.fromRGB(255,220,95))
    part(model,"PlantA",Vector3.new(.16,.95,.16),Vector3.new(-1.1,-.72,0),Color3.fromRGB(66,170,95))
    part(model,"PlantB",Vector3.new(.16,.72,.16),Vector3.new(-.78,-.82,.2),Color3.fromRGB(78,191,111))
    ball(model,"Rock",Vector3.new(.55,.35,.42),Vector3.new(.65,-1.02,.25),Color3.fromRGB(131,127,121))
end

local builders={
    StarLamp=buildStarLamp,
    BunnyChair=buildBunnyChair,
    ToyChest=buildToyChest,
    CloudBed=buildCloudBed,
    RainbowSofa=buildRainbowSofa,
    MiniAquarium=buildMiniAquarium,
}

function FurnitureAssets.IsKnown(itemId)
    return FurnitureAssets.Definitions[tostring(itemId)]~=nil
end

function FurnitureAssets.GetDisplayName(itemId)
    local d=FurnitureAssets.Definitions[tostring(itemId)]
    return d and d.DisplayName or tostring(itemId)
end

function FurnitureAssets.Create(itemId)
    itemId=tostring(itemId)
    local builder=builders[itemId]
    if not builder then return nil end
    local model=Instance.new("Model")
    model.Name=itemId
    root(model,itemId)
    builder(model)
    return model
end

function FurnitureAssets.SetGhostState(model,valid)
    if not model then return end
    local tint=valid and Color3.fromRGB(95,224,255) or Color3.fromRGB(255,104,118)
    for _,obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name~="Root" then
            obj.Color=tint
            obj.Material=Enum.Material.ForceField
            obj.Transparency=.35
            obj.CanCollide=false
            obj.CanTouch=false
            obj.CanQuery=false
        end
    end
end

function FurnitureAssets.RestoreAppearance(model)
    if not model then return end
    for _,obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name~="Root" then
            local r=obj:GetAttribute("WP_BaseColorR")
            local g=obj:GetAttribute("WP_BaseColorG")
            local b=obj:GetAttribute("WP_BaseColorB")
            if r and g and b then obj.Color=Color3.new(r,g,b) end
            obj.Transparency=tonumber(obj:GetAttribute("WP_BaseTransparency")) or 0
            obj.CanCollide=false
            obj.CanTouch=false
            obj.CanQuery=false
        end
    end
end

return FurnitureAssets
