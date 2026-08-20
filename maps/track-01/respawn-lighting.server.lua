local Workspace=game:GetService("Workspace")

-- TRACK 01 v2.3.1 spawn visibility hotfix.
-- Keeps the abandoned station mood while making the respawn hall readable on mobile.
local deadline=os.clock()+30
repeat task.wait(0.15) until Workspace:GetAttribute("ACC_TRACK01_DEPTH_READY") or os.clock()>deadline

local root=Workspace:FindFirstChild("ACC_TRACK01")
if not root then return end
local world=root:FindFirstChild("World")
if not world then return end
local spawn=root:FindFirstChild("TRACK01_SPAWN",true)
if not (spawn and spawn:IsA("BasePart")) then
    warn("[TRACK 01] Spawn lighting: TRACK01_SPAWN missing")
    return
end

local old=world:FindFirstChild("RespawnLighting_v231")
if old then old:Destroy() end

local folder=Instance.new("Folder")
folder.Name="RespawnLighting_v231"
folder.Parent=world

local C={
    fixture=Color3.fromRGB(37,39,39),
    cage=Color3.fromRGB(84,85,80),
    warm=Color3.fromRGB(242,222,195),
    amber=Color3.fromRGB(255,176,92),
    emergency=Color3.fromRGB(190,48,39),
}

local function part(name,size,cframe,color,material,transparency)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.CFrame=cframe
    p.Color=color
    p.Material=material or Enum.Material.Metal
    p.Anchored=true
    p.CanCollide=false
    p.CanTouch=false
    p.CanQuery=true
    p.Transparency=transparency or 0
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=folder
    return p
end

local function point(parent,color,brightness,range,shadows)
    local l=Instance.new("PointLight")
    l.Color=color
    l.Brightness=brightness
    l.Range=range
    l.Shadows=shadows~=false
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

local origin=spawn.CFrame

-- Four old industrial ceiling fixtures around the spawn zone.
-- They overlap gently so the player avatar and nearby signs remain readable.
local ceilingOffsets={
    Vector3.new(-9,10,-7),
    Vector3.new(9,10,-7),
    Vector3.new(-9,10,8),
    Vector3.new(9,10,8),
}
for i,offset in ipairs(ceilingOffsets) do
    local fixture=part("RespawnCeilingFixture",Vector3.new(3.0,0.42,1.8),origin*CFrame.new(offset),C.fixture,Enum.Material.Metal,0)
    local diffuser=part("RespawnDiffuser",Vector3.new(2.35,0.16,1.25),fixture.CFrame*CFrame.new(0,-0.30,0),C.warm,Enum.Material.Neon,0.10)
    point(diffuser,C.warm,1.05,17,true)
    spot(diffuser,C.warm,0.70,18,82,Enum.NormalId.Bottom)
    -- Sparse cage bars preserve the old-station fixture silhouette.
    for x=-0.9,0.9,0.9 do
        part("FixtureCage",Vector3.new(0.10,0.55,1.55),fixture.CFrame*CFrame.new(x,-0.15,0),C.cage,Enum.Material.Metal,0)
    end
end

-- Low wall / column lights toward the platform exit provide directional depth.
local wallOffsets={
    {Vector3.new(-17,4.8,13),Enum.NormalId.Right},
    {Vector3.new(17,4.8,13),Enum.NormalId.Left},
}
for _,spec in ipairs(wallOffsets) do
    local offset,face=spec[1],spec[2]
    local housing=part("RespawnWallLamp",Vector3.new(0.7,2.2,1.4),origin*CFrame.new(offset),C.fixture,Enum.Material.Metal,0)
    local lens=part("RespawnWallLens",Vector3.new(0.18,1.45,0.95),housing.CFrame*CFrame.new((face==Enum.NormalId.Right) and 0.44 or -0.44,0,0),C.amber,Enum.Material.Neon,0.08)
    local l=Instance.new("SurfaceLight")
    l.Face=face
    l.Color=C.amber
    l.Brightness=0.80
    l.Range=14
    l.Angle=100
    l.Shadows=true
    l.Parent=lens
end

-- A brighter but still warm pool immediately above the actual respawn point.
local spawnHalo=part("RespawnHaloFixture",Vector3.new(4.2,0.32,4.2),origin*CFrame.new(0,10.3,0),C.fixture,Enum.Material.Metal,0)
local haloLens=part("RespawnHaloLens",Vector3.new(3.5,0.13,3.5),spawnHalo.CFrame*CFrame.new(0,-0.25,0),C.warm,Enum.Material.Neon,0.18)
point(haloLens,C.warm,1.35,20,true)
spot(haloLens,C.warm,0.95,21,88,Enum.NormalId.Bottom)

-- Small emergency marker toward PLATFORM 01; not enough to tint the whole hall red.
local emergency=part("RespawnEmergencyLamp",Vector3.new(0.65,1.25,0.65),origin*CFrame.new(0,5.5,17.5),C.emergency,Enum.Material.Neon,0.05)
point(emergency,C.emergency,0.32,7,false)

root:SetAttribute("RespawnLightingVersion","2.3.1")
Workspace:SetAttribute("ACC_TRACK01_RESPAWN_LIGHT_READY",true)
Workspace:SetAttribute("ACC_TRACK01_VERSION","2.3.1")
print("[TRACK 01] respawn hall lighting ready v2.3.1")
