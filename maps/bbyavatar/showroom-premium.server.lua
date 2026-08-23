-- BBYAVATAR premium gallery architecture v4.1
-- Strictly aligned to runtime v4.0. No legacy storefronts, no entrance blockers.

local Workspace=game:GetService("Workspace")
local root=Workspace:WaitForChild("BBYAVATAR_SHOWROOM",15)
if not root then warn("[BBYAVATAR] premium layer skipped: core missing") return end

local old=root:FindFirstChild("PremiumArchitecture")
if old then old:Destroy() end
local premium=Instance.new("Folder");premium.Name="PremiumArchitecture";premium.Parent=root

local parts=0;local lights=0
local function p(name,size,cf,color,material,transparency)
    local x=Instance.new("Part")
    x.Name=name;x.Size=size;x.CFrame=cf;x.Anchored=true
    x.Color=color;x.Material=material or Enum.Material.SmoothPlastic
    x.Transparency=transparency or 0;x.TopSurface=Enum.SurfaceType.Smooth;x.BottomSurface=Enum.SurfaceType.Smooth
    x.Parent=premium;parts+=1;return x
end
local function glow(parent,color,brightness,range)
    local l=Instance.new("SurfaceLight");l.Face=Enum.NormalId.Bottom;l.Color=color;l.Brightness=brightness;l.Range=range;l.Angle=110;l.Shadows=false;l.Parent=parent;lights+=1
end

local charcoal=Color3.fromRGB(37,38,43)
local graphite=Color3.fromRGB(68,69,75)
local brass=Color3.fromRGB(160,137,91)
local ivory=Color3.fromRGB(225,222,214)
local glass=Color3.fromRGB(196,202,210)

-- Ceiling coffers match the 24-stud gallery shell. Geometry stays below the ceiling plane.
for _,z in ipairs({55,25,-5,-35,-65}) do
    p("CeilingCross",Vector3.new(164,.35,.7),CFrame.new(0,23.25,z),graphite,Enum.Material.Metal)
end
for _,x in ipairs({-72,-36,0,36,72}) do
    p("CeilingLong",Vector3.new(.7,.35,154),CFrame.new(x,23.25,-1),graphite,Enum.Material.Metal)
end

-- Only four soft architectural luminaires; runtime already owns the main lighting grid.
for _,pos in ipairs({{-36,22,45},{36,22,45},{-36,22,-42},{36,22,-42}}) do
    local lamp=p("GallerySoftLight",Vector3.new(10,.18,2.2),CFrame.new(pos[1],pos[2],pos[3]),Color3.fromRGB(255,242,217),Enum.Material.Neon)
    lamp.CanCollide=false;glow(lamp,Color3.fromRGB(255,239,216),.32,12)
end

-- Thin brass reveal around every collection alcove; adds luxury without adding signage.
local alcoves={{-55,48},{55,48},{-55,14},{55,14},{-55,-20},{55,-20},{-55,-54},{55,-54}}
for i,pos in ipairs(alcoves) do
    local x,z=pos[1],pos[2]
    p("AlcoveTop_"..i,Vector3.new(42.5,.28,.35),CFrame.new(x,11.4,z-11.05),brass,Enum.Material.Metal)
    p("AlcoveL_"..i,Vector3.new(.28,11,.35),CFrame.new(x-21.1,5.9,z-11.05),brass,Enum.Material.Metal)
    p("AlcoveR_"..i,Vector3.new(.28,11,.35),CFrame.new(x+21.1,5.9,z-11.05),brass,Enum.Material.Metal)
end

-- Low glass dividers make gallery bays feel intentional while keeping sightlines open.
for _,pos in ipairs({{-30,31},{30,31},{-30,-3},{30,-3},{-30,-37},{30,-37}}) do
    local g=p("GalleryDivider",Vector3.new(12,4,.18),CFrame.new(pos[1],2.7,pos[2]),glass,Enum.Material.Glass,.72)
    g.CanCollide=false;g.Reflectance=.06
end

-- Minimal benches placed outside the runway; useful as social dwell points with no center clutter.
for _,pos in ipairs({{-28,61},{28,61},{-28,-71},{28,-71}}) do
    local seat=p("GalleryBench",Vector3.new(10,.7,2.8),CFrame.new(pos[1],1.15,pos[2]),charcoal,Enum.Material.Wood)
    seat:SetAttribute("SocialDwell",true)
    p("BenchBase",Vector3.new(8,.55,1.8),CFrame.new(pos[1],.55,pos[2]),graphite,Enum.Material.Metal)
end

-- Entry wings match runtime v4 utility pads at +/-73,70.
for _,x in ipairs({-73,73}) do
    p("UtilityCanopy",Vector3.new(24,.35,10),CFrame.new(x,8.3,70),charcoal,Enum.Material.Metal)
    local trim=p("UtilityTrim",Vector3.new(20,.16,.45),CFrame.new(x,7.9,65.2),brass,Enum.Material.Neon)
    trim.CanCollide=false
end

-- Featured stage receives a restrained arch, not another billboard.
p("FeaturedArchTop",Vector3.new(30,.4,.5),CFrame.new(0,12.2,-78),brass,Enum.Material.Metal)
p("FeaturedArchL",Vector3.new(.4,12,.5),CFrame.new(-15,6.2,-78),brass,Enum.Material.Metal)
p("FeaturedArchR",Vector3.new(.4,12,.5),CFrame.new(15,6.2,-78),brass,Enum.Material.Metal)

-- Mobile QC contract used by future automated checks.
root:SetAttribute("VisualRevision","PREMIUM_GALLERY_V4_1")
root:SetAttribute("PremiumArchitectureParts",parts)
root:SetAttribute("PremiumDynamicLights",lights)
root:SetAttribute("PremiumEntranceClear",true)
root:SetAttribute("PremiumLegacyGeometry",false)
root:SetAttribute("PremiumMobileBudget",parts<=80 and lights<=4)
print(string.format("[BBYAVATAR] premium gallery v4.1 ready • %d parts • %d lights",parts,lights))