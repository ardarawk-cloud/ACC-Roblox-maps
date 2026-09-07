-- Hangar Exclusive Club — VISUAL RESCUE v1.0
-- Runtime evidence fix: v5 looked unchanged and was far too dark on mobile.
-- This authority NEVER claims fallback parts are FULL MESH. If EditableMesh works,
-- it keeps the full-mesh result. If it is blocked at runtime, it replaces the
-- miniature legacy foundation with an unmistakably aircraft-scale XL hangar.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local WIDTH = 360
local DEPTH = 280
local WALL_H = 88
local CROWN_H = 126
local BACK_Z = 92
local FRONT_Z = BACK_Z - DEPTH
local CENTER_Z = (BACK_Z + FRONT_Z) / 2

local function ensureFolder(parent, name)
    local old = parent:FindFirstChild(name)
    if old and old:IsA("Folder") then return old end
    if old then old:Destroy() end
    local f = Instance.new("Folder")
    f.Name = name
    f.Parent = parent
    return f
end

local function p(parent, name, size, cf, color, material, collide, transparency)
    local x = Instance.new("Part")
    x.Name = name
    x.Anchored = true
    x.CanCollide = collide ~= false
    x.CastShadow = true
    x.Size = size
    x.CFrame = cf
    x.Color = color
    x.Material = material or Enum.Material.Metal
    x.Transparency = transparency or 0
    x.TopSurface = Enum.SurfaceType.Smooth
    x.BottomSurface = Enum.SurfaceType.Smooth
    x.Parent = parent
    return x
end

local function neon(parent, name, size, cf, color)
    local x = p(parent, name, size, cf, color, Enum.Material.Neon, false, 0)
    x.CastShadow = false
    return x
end

local function destroyLegacy()
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    local a = map:FindFirstChild("Architecture")
    local v = map:FindFirstChild("Vehicles")
    local f = map:FindFirstChild("Furniture")
    if a then
        for _, child in ipairs(a:GetChildren()) do
            if child.Name:match("^Mesh_Hangar") or child.Name:match("^RoofTruss_") or child.Name == "Apron" then
                child:Destroy()
            end
        end
    end
    if v then
        for _, child in ipairs(v:GetChildren()) do
            if child.Name:match("^Mesh_PrivateJet") or child.Name:match("^Mesh_Helicopter") then child:Destroy() end
        end
    end
    if f then
        for _, child in ipairs(f:GetChildren()) do
            if child.Name == "Stage" or child.Name:match("^DJBooth") or child.Name:match("^Mesh_BarCounter") or child.Name:match("^Mesh_LeatherSofa_") or child.Name:match("^Mesh_MetalFencing_") then
                child:Destroy()
            end
        end
    end
end

-- Bright nightclub exposure: dark atmosphere without black silhouettes.
Lighting.ClockTime = 0.35
Lighting.Brightness = 3.2
Lighting.ExposureCompensation = 0.72
Lighting.Ambient = Color3.fromRGB(78, 82, 96)
Lighting.OutdoorAmbient = Color3.fromRGB(34, 38, 50)
Lighting.EnvironmentDiffuseScale = 0.58
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true

local cc = Lighting:FindFirstChild("HangarVisibilityGrade") or Instance.new("ColorCorrectionEffect")
cc.Name = "HangarVisibilityGrade"
cc.Brightness = 0.08
cc.Contrast = 0.08
cc.Saturation = 0.05
cc.TintColor = Color3.fromRGB(232, 238, 255)
cc.Parent = Lighting

local bloom = Lighting:FindFirstChild("HangarBloom") or Instance.new("BloomEffect")
bloom.Name = "HangarBloom"
bloom.Intensity = 0.22
bloom.Size = 28
bloom.Threshold = 1.25
bloom.Parent = Lighting

-- Give the full-mesh authority a chance to finish first.
task.wait(3)

local map = Workspace:WaitForChild("Map")
local rescue = map:FindFirstChild("HangarXLVisualRescue")
if rescue then rescue:Destroy() end
rescue = Instance.new("Folder")
rescue.Name = "HangarXLVisualRescue"
rescue.Parent = map

local meshReady = Workspace:GetAttribute("HangarFullMeshReady") == true
Workspace:SetAttribute("HangarRuntimeVisualRescue", true)
Workspace:SetAttribute("HangarRuntimeVisualMode", meshReady and "FULL_MESH_PLUS_LIGHT_RESCUE" or "XL_STRUCTURAL_FALLBACK_MESH_API_BLOCKED")

-- Room visibility lighting is required in BOTH modes.
local lights = ensureFolder(rescue, "InteriorVisibilityLights")
local rows = {-128, -68, -8, 52}
local cols = {-120, -60, 0, 60, 120}
for ri, z in ipairs(rows) do
    for ci, x in ipairs(cols) do
        local fixture = p(lights, string.format("CeilingFlood_%02d_%02d", ri, ci), Vector3.new(6, 1, 6), CFrame.new(x, 72, z), Color3.fromRGB(210, 218, 232), Enum.Material.Metal, false, 0)
        local light = Instance.new("PointLight")
        light.Name = "RoomFill"
        light.Color = (ri >= 3) and Color3.fromRGB(255, 225, 205) or Color3.fromRGB(205, 220, 255)
        light.Brightness = 2.35
        light.Range = 78
        light.Shadows = false
        light.Parent = fixture
    end
end

-- Strong front stage/readability fills.
for i, x in ipairs({-72,-36,0,36,72}) do
    local housing = p(lights, "StageWhite_"..i, Vector3.new(4,3,4), CFrame.new(x, 56, 15), Color3.fromRGB(30,32,38), Enum.Material.Metal, false, 0)
    local spot = Instance.new("SpotLight")
    spot.Face = Enum.NormalId.Front
    spot.Angle = 72
    spot.Range = 120
    spot.Brightness = 5.2
    spot.Color = Color3.fromRGB(235, 238, 255)
    spot.Shadows = false
    spot.Parent = housing
end

if meshReady then
    print("[HANGAR VISUAL RESCUE] full mesh detected; lighting rescue applied")
    return
end

-- EditableMesh did not materialize. Do NOT retain the tiny v1 shell.
destroyLegacy()

local structure = ensureFolder(rescue, "XLStructureFallback")
local steel = Color3.fromRGB(43, 47, 56)
local darkSteel = Color3.fromRGB(22, 25, 31)
local concrete = Color3.fromRGB(62, 64, 70)

-- Aircraft-hangar floor and tall side/back envelope.
p(structure, "HangarFloor_XL", Vector3.new(WIDTH, 2, DEPTH), CFrame.new(0, -1, CENTER_Z), concrete, Enum.Material.Concrete, true, 0)
p(structure, "BackWall_XL", Vector3.new(WIDTH, WALL_H, 4), CFrame.new(0, WALL_H/2, BACK_Z), steel, Enum.Material.Metal, true, 0)
p(structure, "LeftWall_XL", Vector3.new(4, WALL_H, DEPTH), CFrame.new(-WIDTH/2, WALL_H/2, CENTER_Z), steel, Enum.Material.Metal, true, 0)
p(structure, "RightWall_XL", Vector3.new(4, WALL_H, DEPTH), CFrame.new(WIDTH/2, WALL_H/2, CENTER_Z), steel, Enum.Material.Metal, true, 0)

-- 13 tall steel portal frames. These are intentionally huge to establish scale.
for i = 0, 12 do
    local z = FRONT_Z + 12 + (i/12) * (DEPTH-24)
    p(structure, "PortalL_"..i, Vector3.new(4, WALL_H, 4), CFrame.new(-WIDTH/2+8, WALL_H/2, z), darkSteel, Enum.Material.Metal, false, 0)
    p(structure, "PortalR_"..i, Vector3.new(4, WALL_H, 4), CFrame.new(WIDTH/2-8, WALL_H/2, z), darkSteel, Enum.Material.Metal, false, 0)
    -- segmented curved roof profile
    local segments = 16
    for s=0,segments-1 do
        local t0=s/segments
        local t1=(s+1)/segments
        local x0=-WIDTH/2+8+t0*(WIDTH-16)
        local x1=-WIDTH/2+8+t1*(WIDTH-16)
        local y0=WALL_H + math.sin(t0*math.pi)*(CROWN_H-WALL_H)
        local y1=WALL_H + math.sin(t1*math.pi)*(CROWN_H-WALL_H)
        local a=Vector3.new(x0,y0,z)
        local b=Vector3.new(x1,y1,z)
        local mid=(a+b)/2
        local len=(b-a).Magnitude
        local beam=p(structure,string.format("RoofRib_%02d_%02d",i,s),Vector3.new(3,3,len),CFrame.lookAt(mid,b),darkSteel,Enum.Material.Metal,false,0)
        beam.CFrame = CFrame.lookAt(mid,b)
    end
end

-- Roof panels with gentle pitched/arched silhouette; much higher than v1.
local roofBands = 18
for s=0,roofBands-1 do
    local t0=s/roofBands
    local t1=(s+1)/roofBands
    local x0=-WIDTH/2+t0*WIDTH
    local x1=-WIDTH/2+t1*WIDTH
    local xm=(x0+x1)/2
    local y0=WALL_H+math.sin(t0*math.pi)*(CROWN_H-WALL_H)
    local y1=WALL_H+math.sin(t1*math.pi)*(CROWN_H-WALL_H)
    local ym=(y0+y1)/2
    local span=math.sqrt((x1-x0)^2+(y1-y0)^2)
    local angle=math.atan2(y1-y0,x1-x0)
    p(structure,"RoofPanel_"..s,Vector3.new(span+1,2.2,DEPTH),CFrame.new(xm,ym,CENTER_Z)*CFrame.Angles(0,0,angle),Color3.fromRGB(52,56,65),Enum.Material.Metal,false,0)
end

-- Hero stage and giant back wall branding plane.
p(structure,"MainStage_XL",Vector3.new(112,6,32),CFrame.new(0,3,68),Color3.fromRGB(24,25,30),Enum.Material.Metal,true,0)
p(structure,"DJBooth_XL",Vector3.new(36,10,8),CFrame.new(0,9,60),Color3.fromRGB(15,17,22),Enum.Material.Metal,true,0)
neon(structure,"DJBoothEdge",Vector3.new(30,1.2,0.8),CFrame.new(0,10,55.6),Color3.fromRGB(0,225,255))
local sign=neon(structure,"HangarSign",Vector3.new(82,16,1),CFrame.new(0,49,89.5),Color3.fromRGB(215,225,255))
local sg=Instance.new("SurfaceGui")
sg.Face=Enum.NormalId.Front
sg.AlwaysOnTop=false
sg.Parent=sign
local label=Instance.new("TextLabel")
label.Size=UDim2.fromScale(1,1)
label.BackgroundTransparency=1
label.Text="HANGAR\nEXCLUSIVE CLUB"
label.TextColor3=Color3.fromRGB(15,18,24)
label.TextScaled=true
label.Font=Enum.Font.GothamBold
label.Parent=sg

-- Elevated side VIP decks/cages like the supplied reference.
for _, side in ipairs({-1,1}) do
    local x=side*132
    p(structure,"VIPDeck_"..side,Vector3.new(54,4,72),CFrame.new(x,17,22),Color3.fromRGB(30,32,38),Enum.Material.Metal,true,0)
    for k=0,7 do
        local z=-10+k*10
        p(structure,string.format("VIPRailPost_%d_%02d",side,k),Vector3.new(2,12,2),CFrame.new(x-side*28,24,z),Color3.fromRGB(76,80,90),Enum.Material.Metal,false,0)
    end
    p(structure,"VIPRailTop_"..side,Vector3.new(2,2,72),CFrame.new(x-side*28,30,22),Color3.fromRGB(76,80,90),Enum.Material.Metal,false,0)
end

-- Large bright bars on both sides.
for _, side in ipairs({-1,1}) do
    local x=side*126
    p(structure,"BarCounter_"..side,Vector3.new(50,6,12),CFrame.new(x,4,-42),Color3.fromRGB(55,45,39),Enum.Material.WoodPlanks,true,0)
    neon(structure,"BarGlow_"..side,Vector3.new(46,1,0.8),CFrame.new(x,5.2,-48.4),Color3.fromRGB(255,190,110))
end

-- Two unmistakably aircraft-sized jet silhouettes as fallback visual anchors.
local function fallbackJet(prefix, x, z, yaw)
    local model=Instance.new("Model")
    model.Name=prefix
    model.Parent=structure
    local cf=CFrame.new(x,10,z)*CFrame.Angles(0,math.rad(yaw),0)
    p(model,"Body",Vector3.new(15,14,82),cf,Color3.fromRGB(222,225,231),Enum.Material.Metal,false,0)
    p(model,"Wing",Vector3.new(74,2.2,20),cf*CFrame.new(0,-1,4),Color3.fromRGB(198,202,210),Enum.Material.Metal,false,0)
    p(model,"TailWing",Vector3.new(34,2,12),cf*CFrame.new(0,3,31),Color3.fromRGB(198,202,210),Enum.Material.Metal,false,0)
    p(model,"TailFin",Vector3.new(3,20,14),cf*CFrame.new(0,10,34),Color3.fromRGB(68,72,82),Enum.Material.Metal,false,0)
    local cockpit=p(model,"Cockpit",Vector3.new(12,7,12),cf*CFrame.new(0,4,-39),Color3.fromRGB(45,95,120),Enum.Material.Glass,false,0.2)
    cockpit.Reflectance=0.05
end
fallbackJet("Jet_A_XL_Fallback",-95,42,-7)
fallbackJet("Jet_B_XL_Fallback",95,42,7)

Workspace:SetAttribute("HangarScaleClass","AIRCRAFT_HANGAR_XL")
Workspace:SetAttribute("HangarFallbackReason","FULL_MESH_RUNTIME_UNAVAILABLE")
print("[HANGAR VISUAL RESCUE] XL fallback built because FullMeshReady=false", WIDTH, DEPTH, CROWN_H)
