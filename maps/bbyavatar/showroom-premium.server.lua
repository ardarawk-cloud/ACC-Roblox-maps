-- BBYAVATAR premium showroom architecture v1.
-- Static, low-part visual polish layered after runtime.server.lua.
-- No BillboardGui, no per-frame loops, and a restrained light budget for mobile safety.

local premium = Instance.new("Folder")
premium.Name = "PremiumArchitecture"
premium.Parent = root

local premiumPartCount = 0
local dynamicLightCount = 0

local function premiumPart(name, size, cf, material, color, transparency)
    local p = part(premium, name, size, cf, material, color)
    p.Transparency = transparency or 0
    premiumPartCount += 1
    return p
end

local function addStripLight(parent, face, color, brightness, range)
    local light = Instance.new("SurfaceLight")
    light.Name = "ArchitecturalGlow"
    light.Face = face or Enum.NormalId.Bottom
    light.Color = color or Color3.fromRGB(220, 226, 255)
    light.Brightness = brightness or 0.45
    light.Range = range or 10
    light.Angle = 120
    light.Shadows = false
    light.Parent = parent
    dynamicLightCount += 1
end

local charcoal = Color3.fromRGB(27, 29, 36)
local graphite = Color3.fromRGB(48, 51, 62)
local metal = Color3.fromRGB(92, 96, 110)
local warmMetal = Color3.fromRGB(130, 113, 83)
local glow = Color3.fromRGB(130, 145, 210)
local glass = Color3.fromRGB(180, 191, 214)

-- Ceiling grid: gives the room architectural depth without enclosing the entire roof.
for _, z in ipairs({52, 27, 2, -23, -48}) do
    premiumPart("CeilingCrossBeam", Vector3.new(180, 0.65, 1.1), CFrame.new(0, 30.2, z), Enum.Material.Metal, graphite)
end
for _, x in ipairs({-83, -46, 0, 46, 83}) do
    premiumPart("CeilingLongBeam", Vector3.new(1.1, 0.65, 138), CFrame.new(x, 30.2, -4), Enum.Material.Metal, graphite)
end

-- Restrained luminous rails over the runway; Neon does most visual work, only a few real lights are used.
for _, x in ipairs({-10, 10}) do
    local rail = premiumPart("RunwayCeilingGlow", Vector3.new(0.35, 0.25, 102), CFrame.new(x, 29.7, 3), Enum.Material.Neon, glow)
    addStripLight(rail, Enum.NormalId.Bottom, Color3.fromRGB(190, 202, 255), 0.38, 11)
end

-- Boutique storefront framing + glass. These turn each category platform into a readable shop bay.
local boutiquePositions = {
    {-66,38},{66,38},{-66,8},{66,8},{-66,-22},{66,-22},{-66,-52},{66,-52}
}
for index, pos in ipairs(boutiquePositions) do
    local x, z = pos[1], pos[2]
    premiumPart("StoreFrameL_"..index, Vector3.new(0.7, 10, 0.7), CFrame.new(x-16.2, 5.2, z+0.5), Enum.Material.Metal, metal)
    premiumPart("StoreFrameR_"..index, Vector3.new(0.7, 10, 0.7), CFrame.new(x+16.2, 5.2, z+0.5), Enum.Material.Metal, metal)
    premiumPart("StoreFrameTop_"..index, Vector3.new(33, 0.7, 0.7), CFrame.new(x, 10, z+0.5), Enum.Material.Metal, metal)

    local glassL = premiumPart("StoreGlassL_"..index, Vector3.new(8.2, 7.2, 0.25), CFrame.new(x-11.7, 5.1, z+0.85), Enum.Material.Glass, glass, 0.72)
    local glassR = premiumPart("StoreGlassR_"..index, Vector3.new(8.2, 7.2, 0.25), CFrame.new(x+11.7, 5.1, z+0.85), Enum.Material.Glass, glass, 0.72)
    glassL.CanCollide = false
    glassR.CanCollide = false

    -- Low clothing rails make mannequin bays read like merchandising displays rather than empty platforms.
    for _, offset in ipairs({-8.5, 8.5}) do
        premiumPart("MerchRailTop_"..index, Vector3.new(5.5, 0.28, 0.28), CFrame.new(x+offset, 4.3, z-2.8), Enum.Material.Metal, warmMetal)
        premiumPart("MerchRailLeg_"..index, Vector3.new(0.25, 3.3, 0.25), CFrame.new(x+offset-2.55, 2.75, z-2.8), Enum.Material.Metal, warmMetal)
        premiumPart("MerchRailLeg_"..index, Vector3.new(0.25, 3.3, 0.25), CFrame.new(x+offset+2.55, 2.75, z-2.8), Enum.Material.Metal, warmMetal)
    end
end

-- Floor inlays visually separate browsing lanes while remaining collision-free.
for _, x in ipairs({-38, 38}) do
    local inlay = premiumPart("AisleInlay", Vector3.new(0.22, 0.05, 116), CFrame.new(x, 0.56, 0), Enum.Material.Neon, Color3.fromRGB(82, 91, 130))
    inlay.CanCollide = false
end

-- Avatar Studio mirror wall.
for _, x in ipairs({-40, -34, -28}) do
    local mirror = premiumPart("AvatarMirror", Vector3.new(5, 8.5, 0.35), CFrame.new(x, 5.2, 49.25), Enum.Material.Glass, Color3.fromRGB(195, 205, 224), 0.48)
    mirror.Reflectance = 0.14
    mirror.CanCollide = false
    premiumPart("MirrorBase", Vector3.new(5.5, 0.35, 0.7), CFrame.new(x, 0.95, 49.25), Enum.Material.Metal, metal)
end

-- Photo Studio cyclorama: simple three-surface infinity-style set plus two soft light columns.
premiumPart("PhotoBackdrop", Vector3.new(21, 11, 0.55), CFrame.new(34, 6.2, 49.2), Enum.Material.SmoothPlastic, Color3.fromRGB(226, 224, 231))
premiumPart("PhotoFloor", Vector3.new(21, 0.3, 13), CFrame.new(34, 0.8, 55.5), Enum.Material.SmoothPlastic, Color3.fromRGB(221, 219, 226))
for _, x in ipairs({26.2, 41.8}) do
    local column = premiumPart("PhotoSoftbox", Vector3.new(1.2, 7.5, 1.2), CFrame.new(x, 5, 55), Enum.Material.Neon, Color3.fromRGB(236, 232, 245))
    addStripLight(column, x < 34 and Enum.NormalId.Right or Enum.NormalId.Left, Color3.fromRGB(255, 241, 232), 0.55, 9)
end

-- Featured plinths give the central stage a luxury retail silhouette.
for _, x in ipairs({-10, 0, 10}) do
    local plinth = premiumPart("FeaturedPlinth", Vector3.new(7, 1.8, 7), CFrame.new(x, 1.55, -50), Enum.Material.Marble, Color3.fromRGB(219, 218, 224))
    plinth:SetAttribute("DisplayPurpose", "FeaturedLook")
end

-- Community wall receives a physical frame instead of floating signage treatment.
premiumPart("CommunityFrameTop", Vector3.new(33, 0.55, 0.65), CFrame.new(0, 11.15, 42), Enum.Material.Metal, warmMetal)
premiumPart("CommunityFrameL", Vector3.new(0.55, 10.5, 0.65), CFrame.new(-15.8, 6, 42), Enum.Material.Metal, warmMetal)
premiumPart("CommunityFrameR", Vector3.new(0.55, 10.5, 0.65), CFrame.new(15.8, 6, 42), Enum.Material.Metal, warmMetal)

-- Entrance plinths reinforce brand arrival without oversized screen-space text.
for _, x in ipairs({-22, 22}) do
    premiumPart("EntrancePlinth", Vector3.new(5.5, 3.4, 5.5), CFrame.new(x, 2.2, 65), Enum.Material.Marble, Color3.fromRGB(48, 50, 58))
    local cap = premiumPart("EntranceGlowCap", Vector3.new(5.1, 0.22, 5.1), CFrame.new(x, 3.95, 65), Enum.Material.Neon, Color3.fromRGB(101, 115, 170))
    cap.CanCollide = false
end

root:SetAttribute("VisualRevision", "PREMIUM_ARCH_V1")
root:SetAttribute("PremiumArchitectureParts", premiumPartCount)
root:SetAttribute("PremiumDynamicLights", dynamicLightCount)
root:SetAttribute("PremiumMobileBudget", dynamicLightCount <= 6 and premiumPartCount <= 140)

print(string.format("[BBYAVATAR] Premium showroom v1 ready • %d parts • %d lights", premiumPartCount, dynamicLightCount))