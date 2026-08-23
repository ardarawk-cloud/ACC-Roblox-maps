-- BBYAVATAR premium showroom architecture v2.0
-- Aligned to the clean-entrance runtime. No center-spawn blockers, no overlapping legacy utility set.

local Workspace = game:GetService("Workspace")
local root = Workspace:WaitForChild("BBYAVATAR_SHOWROOM", 15)
if not root then
    warn("[BBYAVATAR] Premium showroom skipped: core showroom missing")
    return
end

local oldPremium = root:FindFirstChild("PremiumArchitecture")
if oldPremium then oldPremium:Destroy() end

local premium = Instance.new("Folder")
premium.Name = "PremiumArchitecture"
premium.Parent = root

local premiumPartCount = 0
local dynamicLightCount = 0

local function part(parent,name,size,cf,material,color)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
    p.Material=material or Enum.Material.SmoothPlastic
    p.Color=color or Color3.fromRGB(32,34,42)
    p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent
    return p
end

local function premiumPart(name,size,cf,material,color,transparency)
    local p=part(premium,name,size,cf,material,color)
    p.Transparency=transparency or 0
    premiumPartCount+=1
    return p
end

local function addStripLight(parent,face,color,brightness,range)
    local light=Instance.new("SurfaceLight")
    light.Name="ArchitecturalGlow";light.Face=face or Enum.NormalId.Bottom
    light.Color=color or Color3.fromRGB(220,226,255);light.Brightness=brightness or 0.4
    light.Range=range or 10;light.Angle=120;light.Shadows=false;light.Parent=parent
    dynamicLightCount+=1
end

local graphite=Color3.fromRGB(62,65,76)
local metal=Color3.fromRGB(104,108,122)
local warmMetal=Color3.fromRGB(138,119,86)
local glow=Color3.fromRGB(135,150,214)
local glass=Color3.fromRGB(190,201,222)

-- Architectural ceiling rhythm. The front 20 studs remain visually open above spawn.
for _,z in ipairs({44,18,-8,-34,-58}) do
    premiumPart("CeilingCrossBeam",Vector3.new(180,0.6,1),CFrame.new(0,29.5,z),Enum.Material.Metal,graphite)
end
for _,x in ipairs({-83,-46,0,46,83}) do
    premiumPart("CeilingLongBeam",Vector3.new(1,0.6,132),CFrame.new(x,29.5,-5),Enum.Material.Metal,graphite)
end
for _,x in ipairs({-9,9}) do
    local rail=premiumPart("RunwayCeilingGlow",Vector3.new(0.3,0.2,92),CFrame.new(x,29,0),Enum.Material.Neon,glow)
    addStripLight(rail,Enum.NormalId.Bottom,Color3.fromRGB(202,211,255),0.3,9)
end

-- Boutique frames stay shallow so category signage and mannequins remain readable from the runway.
local boutiquePositions={{-66,38},{66,38},{-66,8},{66,8},{-66,-22},{66,-22},{-66,-52},{66,-52}}
for index,pos in ipairs(boutiquePositions) do
    local x,z=pos[1],pos[2]
    premiumPart("StoreFrameL_"..index,Vector3.new(0.6,9,0.6),CFrame.new(x-15.2,5,z+0.2),Enum.Material.Metal,metal)
    premiumPart("StoreFrameR_"..index,Vector3.new(0.6,9,0.6),CFrame.new(x+15.2,5,z+0.2),Enum.Material.Metal,metal)
    premiumPart("StoreFrameTop_"..index,Vector3.new(31,0.6,0.6),CFrame.new(x,9.2,z+0.2),Enum.Material.Metal,metal)
    local glassL=premiumPart("StoreGlassL_"..index,Vector3.new(7.2,6.6,0.2),CFrame.new(x-10.5,4.8,z+0.55),Enum.Material.Glass,glass,0.78)
    local glassR=premiumPart("StoreGlassR_"..index,Vector3.new(7.2,6.6,0.2),CFrame.new(x+10.5,4.8,z+0.55),Enum.Material.Glass,glass,0.78)
    glassL.CanCollide=false;glassR.CanCollide=false
    for _,offset in ipairs({-8,8}) do
        premiumPart("MerchRailTop_"..index,Vector3.new(5,0.24,0.24),CFrame.new(x+offset,4,z-2.5),Enum.Material.Metal,warmMetal)
        premiumPart("MerchRailLeg_"..index,Vector3.new(0.22,3,0.22),CFrame.new(x+offset-2.25,2.55,z-2.5),Enum.Material.Metal,warmMetal)
        premiumPart("MerchRailLeg_"..index,Vector3.new(0.22,3,0.22),CFrame.new(x+offset+2.25,2.55,z-2.5),Enum.Material.Metal,warmMetal)
    end
end

for _,x in ipairs({-38,38}) do
    local inlay=premiumPart("AisleInlay",Vector3.new(0.18,0.04,110),CFrame.new(x,0.56,-1),Enum.Material.Neon,Color3.fromRGB(91,102,143))
    inlay.CanCollide=false
end

-- Utility architecture follows runtime v3.4: studios are at the far entrance wings.
for _,x in ipairs({-87,-82,-77}) do
    local mirror=premiumPart("AvatarMirror",Vector3.new(4.2,7.5,0.25),CFrame.new(x,4.8,55.2),Enum.Material.Glass,Color3.fromRGB(201,211,229),0.55)
    mirror.Reflectance=0.12;mirror.CanCollide=false
    premiumPart("MirrorBase",Vector3.new(4.6,0.3,0.6),CFrame.new(x,1.05,55.2),Enum.Material.Metal,metal)
end
premiumPart("PhotoBackdrop",Vector3.new(19,9.5,0.45),CFrame.new(82,5.7,55.15),Enum.Material.SmoothPlastic,Color3.fromRGB(232,230,236))
premiumPart("PhotoFloor",Vector3.new(19,0.25,11),CFrame.new(82,0.82,61),Enum.Material.SmoothPlastic,Color3.fromRGB(226,224,231))
for _,x in ipairs({75,89}) do
    local column=premiumPart("PhotoSoftbox",Vector3.new(1,6.5,1),CFrame.new(x,4.6,61),Enum.Material.Neon,Color3.fromRGB(240,237,246))
    addStripLight(column,x<82 and Enum.NormalId.Right or Enum.NormalId.Left,Color3.fromRGB(255,246,238),0.42,8)
end

-- Featured zone remains the focal destination at the end of the runway.
for _,x in ipairs({-10,0,10}) do
    local plinth=premiumPart("FeaturedPlinth",Vector3.new(6.5,1.5,6.5),CFrame.new(x,1.4,-50),Enum.Material.Marble,Color3.fromRGB(224,223,228))
    plinth:SetAttribute("DisplayPurpose","FeaturedLook")
end

-- Community frame follows the deep-wall location; nothing large is allowed in the spawn corridor.
premiumPart("CommunityFrameTop",Vector3.new(30,0.5,0.55),CFrame.new(0,8.25,-70.4),Enum.Material.Metal,warmMetal)
premiumPart("CommunityFrameL",Vector3.new(0.5,6.5,0.55),CFrame.new(-14.2,5,-70.4),Enum.Material.Metal,warmMetal)
premiumPart("CommunityFrameR",Vector3.new(0.5,6.5,0.55),CFrame.new(14.2,5,-70.4),Enum.Material.Metal,warmMetal)

-- Spawn corridor guard: no premium geometry inside x +/-12, z 52..76 below 12 studs.
root:SetAttribute("VisualRevision","PREMIUM_ARCH_V2_CLEAN_SIGHTLINE")
root:SetAttribute("PremiumArchitectureParts",premiumPartCount)
root:SetAttribute("PremiumDynamicLights",dynamicLightCount)
root:SetAttribute("PremiumMobileBudget",dynamicLightCount<=6 and premiumPartCount<=130)
root:SetAttribute("PremiumEntranceClear",true)
print(string.format("[BBYAVATAR] Premium showroom v2 ready • %d parts • %d lights • entrance clear",premiumPartCount,dynamicLightCount))