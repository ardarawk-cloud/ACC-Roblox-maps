-- Hangar Exclusive Club — FULL MESH v8
-- Universe 10745364913 / Place 76001567401911
-- Runtime goal: visible architecture, aircraft and club fixtures are MeshParts.
-- V7 remains the safe fallback until ALL critical meshes are ready.

local AssetService = game:GetService("AssetService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local WIDTH = 360
local DEPTH = 280
local WALL_H = 88
local CROWN_H = 126
local BACK_Z = 92
local FRONT_Z = BACK_Z - DEPTH
local CENTER_Z = (BACK_Z + FRONT_Z) / 2
local ROOT_CF = CFrame.new(0, 0, CENTER_Z)

Workspace:SetAttribute("HangarFullMeshV8Target", true)
Workspace:SetAttribute("HangarFullMeshV8Ready", false)
Workspace:SetAttribute("HangarRuntimeVisualMode", "V8_FULL_MESH_BUILDING")

local function addTri(mesh, a, b, c, doubleSided)
    local va = mesh:AddVertex(a)
    local vb = mesh:AddVertex(b)
    local vc = mesh:AddVertex(c)
    mesh:AddTriangle(va, vb, vc)
    if doubleSided then
        mesh:AddTriangle(vc, vb, va)
    end
end

local function addQuad(mesh, a, b, c, d, doubleSided)
    local va = mesh:AddVertex(a)
    local vb = mesh:AddVertex(b)
    local vc = mesh:AddVertex(c)
    local vd = mesh:AddVertex(d)
    mesh:AddTriangle(va, vb, vc)
    mesh:AddTriangle(va, vc, vd)
    if doubleSided then
        mesh:AddTriangle(vc, vb, va)
        mesh:AddTriangle(vd, vc, va)
    end
end

local function addBox(mesh, cf, size, doubleSided)
    local hx, hy, hz = size.X/2, size.Y/2, size.Z/2
    local p = {
        cf:PointToWorldSpace(Vector3.new(-hx,-hy,-hz)),
        cf:PointToWorldSpace(Vector3.new( hx,-hy,-hz)),
        cf:PointToWorldSpace(Vector3.new( hx, hy,-hz)),
        cf:PointToWorldSpace(Vector3.new(-hx, hy,-hz)),
        cf:PointToWorldSpace(Vector3.new(-hx,-hy, hz)),
        cf:PointToWorldSpace(Vector3.new( hx,-hy, hz)),
        cf:PointToWorldSpace(Vector3.new( hx, hy, hz)),
        cf:PointToWorldSpace(Vector3.new(-hx, hy, hz)),
    }
    addQuad(mesh,p[1],p[2],p[3],p[4],doubleSided)
    addQuad(mesh,p[6],p[5],p[8],p[7],doubleSided)
    addQuad(mesh,p[5],p[1],p[4],p[8],doubleSided)
    addQuad(mesh,p[2],p[6],p[7],p[3],doubleSided)
    addQuad(mesh,p[4],p[3],p[7],p[8],doubleSided)
    addQuad(mesh,p[5],p[6],p[2],p[1],doubleSided)
end

local function addEllipsoid(mesh, cf, radius, rings, segments)
    rings = rings or 12
    segments = segments or 24
    local ids = {}
    for r=0,rings do
        ids[r] = {}
        local phi = -math.pi/2 + (r/rings)*math.pi
        local cp, sp = math.cos(phi), math.sin(phi)
        for s=0,segments-1 do
            local theta = (s/segments)*math.pi*2
            local p = Vector3.new(
                math.cos(theta)*cp*radius.X,
                sp*radius.Y,
                math.sin(theta)*cp*radius.Z
            )
            ids[r][s] = mesh:AddVertex(cf:PointToWorldSpace(p))
        end
    end
    for r=0,rings-1 do
        for s=0,segments-1 do
            local n=(s+1)%segments
            local a,b,c,d=ids[r][s],ids[r][n],ids[r+1][n],ids[r+1][s]
            mesh:AddTriangle(a,b,c)
            mesh:AddTriangle(a,c,d)
        end
    end
end

local function meshPart(parent, name, cf, color, material, builder)
    local editable
    local okCreate, createErr = pcall(function()
        editable = AssetService:CreateEditableMesh()
    end)
    if not okCreate or not editable then
        warn("[HANGAR V8] CreateEditableMesh failed", name, createErr)
        return nil
    end

    local okBuild, buildErr = pcall(builder, editable)
    if not okBuild then
        editable:Destroy()
        warn("[HANGAR V8] geometry build failed", name, buildErr)
        return nil
    end

    local result
    local okPart, partErr = pcall(function()
        result = AssetService:CreateMeshPartAsync(Content.fromObject(editable), {
            CollisionFidelity = Enum.CollisionFidelity.Box,
            RenderFidelity = Enum.RenderFidelity.Precise,
        })
    end)
    editable:Destroy()
    if not okPart or not result then
        warn("[HANGAR V8] CreateMeshPartAsync failed", name, partErr)
        return nil
    end

    result.Name = name
    result.Anchored = true
    result.CanCollide = false
    result.CanTouch = false
    result.CanQuery = true
    result.CastShadow = true
    result.CFrame = cf
    result.Color = color
    result.Material = material
    result.Parent = parent
    return result
end

local map = Workspace:WaitForChild("Map")
task.wait(4)

local old = map:FindFirstChild("HangarFullMeshV8")
if old then old:Destroy() end
local buildRoot = Instance.new("Folder")
buildRoot.Name = "HangarFullMeshV8_BUILDING"
buildRoot.Parent = map

local steel = Color3.fromRGB(58,62,72)
local darkSteel = Color3.fromRGB(21,24,30)
local concrete = Color3.fromRGB(75,76,80)
local silver = Color3.fromRGB(220,224,231)
local stageDark = Color3.fromRGB(22,24,29)

-- ARCHITECTURE: one real mesh shell, all interior faces double-sided.
local shell = meshPart(buildRoot, "Mesh_HangarShell_FULL", ROOT_CF, steel, Enum.Material.Metal, function(mesh)
    addBox(mesh, CFrame.new(0,-1.5,0), Vector3.new(WIDTH,3,DEPTH), true)
    addBox(mesh, CFrame.new(-WIDTH/2, WALL_H/2, 0), Vector3.new(5,WALL_H,DEPTH), true)
    addBox(mesh, CFrame.new(WIDTH/2, WALL_H/2, 0), Vector3.new(5,WALL_H,DEPTH), true)
    addBox(mesh, CFrame.new(0,WALL_H/2,DEPTH/2), Vector3.new(WIDTH,WALL_H,5), true)
    addBox(mesh, CFrame.new(0,WALL_H-10,-DEPTH/2), Vector3.new(WIDTH,20,5), true)

    local bands=32
    for i=0,bands-1 do
        local t0=i/bands
        local t1=(i+1)/bands
        local x0=-WIDTH/2+t0*WIDTH
        local x1=-WIDTH/2+t1*WIDTH
        local y0=WALL_H+math.sin(t0*math.pi)*(CROWN_H-WALL_H)
        local y1=WALL_H+math.sin(t1*math.pi)*(CROWN_H-WALL_H)
        addQuad(mesh,
            Vector3.new(x0,y0,-DEPTH/2-2),
            Vector3.new(x1,y1,-DEPTH/2-2),
            Vector3.new(x1,y1, DEPTH/2+2),
            Vector3.new(x0,y0, DEPTH/2+2),
            true
        )
    end
end)

-- PORTAL/TRUSS SYSTEM: real mesh steel ribs.
local ribs = meshPart(buildRoot, "Mesh_HangarTrusses_FULL", ROOT_CF, darkSteel, Enum.Material.Metal, function(mesh)
    local ribCount=13
    local segments=20
    for r=0,ribCount-1 do
        local z=-DEPTH/2+12+(r/(ribCount-1))*(DEPTH-24)
        addBox(mesh,CFrame.new(-WIDTH/2+10,WALL_H/2,z),Vector3.new(5,WALL_H,5),true)
        addBox(mesh,CFrame.new( WIDTH/2-10,WALL_H/2,z),Vector3.new(5,WALL_H,5),true)
        for s=0,segments-1 do
            local t0=s/segments
            local t1=(s+1)/segments
            local x0=-WIDTH/2+10+t0*(WIDTH-20)
            local x1=-WIDTH/2+10+t1*(WIDTH-20)
            local y0=WALL_H+math.sin(t0*math.pi)*(CROWN_H-WALL_H)-5
            local y1=WALL_H+math.sin(t1*math.pi)*(CROWN_H-WALL_H)-5
            local a=Vector3.new(x0,y0,z)
            local b=Vector3.new(x1,y1,z)
            local mid=(a+b)/2
            addBox(mesh,CFrame.lookAt(mid,b),Vector3.new(4,4,(b-a).Magnitude+0.7),true)
        end
    end
end)

-- CLUB MASSING as a single mesh: stage, booth, VIP decks, bars, cages.
local clubMesh = meshPart(buildRoot, "Mesh_ClubArchitecture_FULL", ROOT_CF, stageDark, Enum.Material.Metal, function(mesh)
    local function wcf(cf) return ROOT_CF:ToObjectSpace(cf) end
    addBox(mesh,wcf(CFrame.new(0,3,67)),Vector3.new(116,6,34),true)
    addBox(mesh,wcf(CFrame.new(0,9,58)),Vector3.new(38,10,8),true)
    for _,side in ipairs({-1,1}) do
        local x=side*132
        addBox(mesh,wcf(CFrame.new(x,18,18)),Vector3.new(54,4,76),true)
        addBox(mesh,wcf(CFrame.new(x+side*27,31,18)),Vector3.new(4,28,76),true)
        addBox(mesh,wcf(CFrame.new(side*126,4,-48)),Vector3.new(52,7,13),true)
        for i=0,7 do
            addBox(mesh,wcf(CFrame.new(x-side*28,24,-12+i*10)),Vector3.new(2.2,12,2.2),true)
        end
        addBox(mesh,wcf(CFrame.new(x-side*28,30,18)),Vector3.new(2.2,2.2,76),true)
    end
end)

-- HERO AIRCRAFT: each is an actual MeshPart built from curved mesh + wing geometry.
local function buildJet(name, worldCf, accent)
    return meshPart(buildRoot,name,worldCf,silver,Enum.Material.Metal,function(mesh)
        addEllipsoid(mesh,CFrame.Angles(math.rad(90),0,0),Vector3.new(7.8,37,8.2),12,26)
        addBox(mesh,CFrame.new(0,-1,3),Vector3.new(72,2.1,19),true)
        addBox(mesh,CFrame.new(0,4,30),Vector3.new(34,1.7,12),true)
        addBox(mesh,CFrame.new(0,11,34),Vector3.new(2.8,22,14),true)
        addBox(mesh,CFrame.new(-10,-2,19),Vector3.new(6,6,13),true)
        addBox(mesh,CFrame.new(10,-2,19),Vector3.new(6,6,13),true)
    end)
end

local jetA = buildJet("Mesh_PrivateJet_A_FULL",CFrame.new(-98,11,41)*CFrame.Angles(0,math.rad(-7),0))
local jetB = buildJet("Mesh_PrivateJet_B_FULL",CFrame.new(98,11,41)*CFrame.Angles(0,math.rad(7),0))

local heli = meshPart(buildRoot,"Mesh_Helicopter_FULL",CFrame.new(138,13,-34)*CFrame.Angles(0,math.rad(-18),0),Color3.fromRGB(28,31,37),Enum.Material.Metal,function(mesh)
    addEllipsoid(mesh,CFrame.identity,Vector3.new(13,9.5,18),10,22)
    addBox(mesh,CFrame.new(0,1,27),Vector3.new(5,5,40),true)
    addBox(mesh,CFrame.new(0,12,0),Vector3.new(78,0.8,2.5),true)
    addBox(mesh,CFrame.new(0,12,0),Vector3.new(2.5,0.8,78),true)
    addBox(mesh,CFrame.new(0,3,48),Vector3.new(26,0.8,2.2),true)
end)

-- Visible light fixture mesh. Light emitters themselves are invisible helper parts.
local fixtureMesh = meshPart(buildRoot,"Mesh_IndustrialFixtures_FULL",ROOT_CF,Color3.fromRGB(225,230,238),Enum.Material.Metal,function(mesh)
    for _,zWorld in ipairs({-145,-95,-45,5,45}) do
        for _,x in ipairs({-135,-90,-45,0,45,90,135}) do
            local localCf=ROOT_CF:ToObjectSpace(CFrame.new(x,78,zWorld))
            addBox(mesh,localCf,Vector3.new(8,1.4,5.5),true)
        end
    end
end)

local critical = {shell,ribs,clubMesh,jetA,jetB,heli,fixtureMesh}
for _,p in ipairs(critical) do
    if not p then
        buildRoot:Destroy()
        Workspace:SetAttribute("HangarFullMeshV8Ready",false)
        Workspace:SetAttribute("HangarRuntimeVisualMode","V8_FULL_MESH_FAILED_KEEP_V7")
        warn("[HANGAR V8] critical mesh failed; V7 retained")
        return
    end
end

-- SUCCESS: remove visible V7 shell only after full mesh is complete.
local v7 = map:FindFirstChild("HangarV7EnclosedInterior")
if v7 then v7:Destroy() end
local legacyRescue = map:FindFirstChild("HangarXLVisualRescue")
if legacyRescue then legacyRescue:Destroy() end
local legacyMesh = map:FindFirstChild("FullMeshV2")
if legacyMesh then legacyMesh:Destroy() end

buildRoot.Name = "HangarFullMeshV8"

-- Invisible collision envelope; visuals remain 100% mesh.
local collision = Instance.new("Folder")
collision.Name = "HangarCollisionV8"
collision.Parent = map
local function collider(name,size,cf)
    local p=Instance.new("Part")
    p.Name=name
    p.Anchored=true
    p.CanCollide=true
    p.CanTouch=false
    p.CanQuery=true
    p.Transparency=1
    p.Size=size
    p.CFrame=cf
    p.Parent=collision
end
collider("Floor",Vector3.new(WIDTH,3,DEPTH),CFrame.new(0,-1.5,CENTER_Z))
collider("LeftWall",Vector3.new(5,WALL_H,DEPTH),CFrame.new(-WIDTH/2,WALL_H/2,CENTER_Z))
collider("RightWall",Vector3.new(5,WALL_H,DEPTH),CFrame.new(WIDTH/2,WALL_H/2,CENTER_Z))
collider("BackWall",Vector3.new(WIDTH,WALL_H,5),CFrame.new(0,WALL_H/2,BACK_Z))

-- Interior visibility lights, physically anchored to the mesh ceiling grid.
local lightSources=Instance.new("Folder")
lightSources.Name="HangarLightSourcesV8"
lightSources.Parent=map
for _,z in ipairs({-145,-95,-45,5,45}) do
    for _,x in ipairs({-135,-90,-45,0,45,90,135}) do
        local holder=Instance.new("Part")
        holder.Name="LightSource"
        holder.Anchored=true
        holder.CanCollide=false
        holder.CanTouch=false
        holder.CanQuery=false
        holder.Transparency=1
        holder.Size=Vector3.one
        holder.CFrame=CFrame.new(x,77.5,z)
        holder.Parent=lightSources
        local pl=Instance.new("PointLight")
        pl.Color=Color3.fromRGB(220,228,242)
        pl.Brightness=2.15
        pl.Range=70
        pl.Shadows=false
        pl.Parent=holder
    end
end

-- Warm stage washes; no giant white overexposure.
for i,x in ipairs({-72,-36,0,36,72}) do
    local holder=Instance.new("Part")
    holder.Name="StageWash_"..i
    holder.Anchored=true
    holder.CanCollide=false
    holder.CanTouch=false
    holder.CanQuery=false
    holder.Transparency=1
    holder.Size=Vector3.one
    holder.CFrame=CFrame.new(x,58,12)
    holder.Parent=lightSources
    local sp=Instance.new("SpotLight")
    sp.Face=Enum.NormalId.Front
    sp.Angle=72
    sp.Range=125
    sp.Brightness=3.8
    sp.Color=Color3.fromRGB(238,224,215)
    sp.Shadows=false
    sp.Parent=holder
end

-- Branding on a mesh-backed sign plane.
local signPart=meshPart(buildRoot,"Mesh_HangarSign_FULL",CFrame.new(0,53,89),Color3.fromRGB(235,239,246),Enum.Material.Neon,function(mesh)
    addBox(mesh,CFrame.identity,Vector3.new(92,18,1.2),true)
end)
if signPart then
    local gui=Instance.new("SurfaceGui")
    gui.Face=Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=24
    gui.Parent=signPart
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundTransparency=1
    label.Text="HANGAR\nEXCLUSIVE CLUB"
    label.TextColor3=Color3.fromRGB(16,18,23)
    label.TextScaled=true
    label.Font=Enum.Font.GothamBold
    label.Parent=gui
end

local spawn=Workspace:FindFirstChild("HangarSpawn")
if spawn and spawn:IsA("SpawnLocation") then
    spawn.Transparency=1
    spawn.Material=Enum.Material.SmoothPlastic
    spawn.CanCollide=false
end

Lighting.Brightness=2.6
Lighting.ExposureCompensation=0.42
Lighting.Ambient=Color3.fromRGB(64,68,80)
Lighting.OutdoorAmbient=Color3.fromRGB(30,33,42)
Lighting.EnvironmentDiffuseScale=0.55
Lighting.EnvironmentSpecularScale=0.9

Workspace:SetAttribute("HangarFullMeshV8Ready",true)
Workspace:SetAttribute("HangarRuntimeVisualMode","V8_FULL_MESH_HANGAR")
Workspace:SetAttribute("HangarScaleClass","AIRCRAFT_HANGAR_XL")
Workspace:SetAttribute("HangarVisibleGeometry","MESHPART_ONLY")
print("[HANGAR V8] FULL MESH READY",WIDTH,DEPTH,CROWN_H)
