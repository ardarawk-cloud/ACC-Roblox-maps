-- Hangar Exclusive Club — FULL MESH authority v2.0
-- Universe 10745364913 / Place 76001567401911
-- Reference scale lock: aircraft hangar, not miniature.

local AssetService = game:GetService("AssetService")
local Workspace = game:GetService("Workspace")

local MAP = Workspace:WaitForChild("Map")
local Architecture = MAP:WaitForChild("Architecture")
local Vehicles = MAP:WaitForChild("Vehicles")
local Furniture = MAP:WaitForChild("Furniture")

local WIDTH = 360
local DEPTH = 280
local WALL_H = 88
local CROWN_H = 126
local FLOOR_Y = 0
local BACK_Z = 92
local FRONT_Z = BACK_Z - DEPTH

Workspace:SetAttribute("HangarFullMeshTarget", true)
Workspace:SetAttribute("HangarWidthStuds", WIDTH)
Workspace:SetAttribute("HangarDepthStuds", DEPTH)
Workspace:SetAttribute("HangarWallHeightStuds", WALL_H)
Workspace:SetAttribute("HangarCrownHeightStuds", CROWN_H)

local function clearLegacy(container, prefixes)
    for _, child in ipairs(container:GetChildren()) do
        for _, prefix in ipairs(prefixes) do
            if child.Name:sub(1, #prefix) == prefix then
                child:Destroy()
                break
            end
        end
    end
end

local function addTri(mesh, a, b, c)
    local va = mesh:AddVertex(a)
    local vb = mesh:AddVertex(b)
    local vc = mesh:AddVertex(c)
    mesh:AddTriangle(va, vb, vc)
end

local function addQuad(mesh, a, b, c, d, doubleSided)
    addTri(mesh, a, b, c)
    addTri(mesh, a, c, d)
    if doubleSided then
        addTri(mesh, c, b, a)
        addTri(mesh, d, c, a)
    end
end

local function addBox(mesh, cf, size)
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
    addQuad(mesh,p[1],p[2],p[3],p[4],false)
    addQuad(mesh,p[6],p[5],p[8],p[7],false)
    addQuad(mesh,p[5],p[1],p[4],p[8],false)
    addQuad(mesh,p[2],p[6],p[7],p[3],false)
    addQuad(mesh,p[4],p[3],p[7],p[8],false)
    addQuad(mesh,p[5],p[6],p[2],p[1],false)
end

local function addEllipsoid(mesh, cf, radius, rings, segments)
    rings = rings or 10
    segments = segments or 18
    local ids = {}
    for r = 0, rings do
        ids[r] = {}
        local v = r / rings
        local phi = -math.pi/2 + v*math.pi
        local cp, sp = math.cos(phi), math.sin(phi)
        for s = 0, segments-1 do
            local theta = (s/segments)*math.pi*2
            local localP = Vector3.new(
                math.cos(theta)*cp*radius.X,
                sp*radius.Y,
                math.sin(theta)*cp*radius.Z
            )
            ids[r][s] = mesh:AddVertex(cf:PointToWorldSpace(localP))
        end
    end
    for r = 0, rings-1 do
        for s = 0, segments-1 do
            local n = (s+1)%segments
            local a,b,c,d = ids[r][s],ids[r][n],ids[r+1][n],ids[r+1][s]
            mesh:AddTriangle(a,b,c)
            mesh:AddTriangle(a,c,d)
        end
    end
end

local function createMeshPart(parent, name, color, material, collision, builder)
    local okMesh, meshOrErr = pcall(function()
        local mesh = AssetService:CreateEditableMesh()
        if not mesh then error("CreateEditableMesh returned nil") end
        builder(mesh)
        return mesh
    end)
    if not okMesh then
        warn("[HANGAR FULL MESH] build failed", name, meshOrErr)
        return nil
    end
    local mesh = meshOrErr
    local okPart, partOrErr = pcall(function()
        return AssetService:CreateMeshPartAsync(Content.fromObject(mesh), {
            CollisionFidelity = collision or Enum.CollisionFidelity.Hull,
            RenderFidelity = Enum.RenderFidelity.Precise,
        })
    end)
    if not okPart then
        mesh:Destroy()
        warn("[HANGAR FULL MESH] meshpart failed", name, partOrErr)
        return nil
    end
    local p = partOrErr
    p.Name = name
    p.Anchored = true
    p.Color = color
    p.Material = material
    p.CastShadow = true
    p.Parent = parent
    mesh:Destroy()
    return p
end

local generated = Instance.new("Folder")
generated.Name = "FullMeshV2"
generated.Parent = MAP

-- One large shell mesh: floor + side/back walls + curved aircraft-hangar roof.
local shell = createMeshPart(generated, "Mesh_HangarArchitecture_FULL", Color3.fromRGB(42,44,50), Enum.Material.Metal, Enum.CollisionFidelity.PreciseConvexDecomposition, function(mesh)
    addBox(mesh, CFrame.new(0,FLOOR_Y-1,BACK_Z-DEPTH/2), Vector3.new(WIDTH,2,DEPTH))
    addBox(mesh, CFrame.new(-WIDTH/2+1.5,WALL_H/2,BACK_Z-DEPTH/2), Vector3.new(3,WALL_H,DEPTH))
    addBox(mesh, CFrame.new(WIDTH/2-1.5,WALL_H/2,BACK_Z-DEPTH/2), Vector3.new(3,WALL_H,DEPTH))
    addBox(mesh, CFrame.new(0,WALL_H/2,BACK_Z-1.5), Vector3.new(WIDTH,WALL_H,3))

    local roofSteps = 32
    local z0,z1 = FRONT_Z,BACK_Z
    for i=0,roofSteps-1 do
        local t0=i/roofSteps
        local t1=(i+1)/roofSteps
        local x0=-WIDTH/2 + t0*WIDTH
        local x1=-WIDTH/2 + t1*WIDTH
        local y0=WALL_H + math.sin(t0*math.pi)*(CROWN_H-WALL_H)
        local y1=WALL_H + math.sin(t1*math.pi)*(CROWN_H-WALL_H)
        addQuad(mesh,Vector3.new(x0,y0,z0),Vector3.new(x1,y1,z0),Vector3.new(x1,y1,z1),Vector3.new(x0,y0,z1),true)
    end
end)

-- Ribbed steel arches matching the reference image.
local ribs = createMeshPart(generated, "Mesh_HangarRoofTrusses_FULL", Color3.fromRGB(18,20,25), Enum.Material.Metal, Enum.CollisionFidelity.Hull, function(mesh)
    local ribCount = 13
    local roofSteps = 18
    for r=0,ribCount-1 do
        local z = FRONT_Z + 18 + (r/(ribCount-1))*(DEPTH-36)
        for i=0,roofSteps-1 do
            local t0=i/roofSteps
            local t1=(i+1)/roofSteps
            local x0=-WIDTH/2+10+t0*(WIDTH-20)
            local x1=-WIDTH/2+10+t1*(WIDTH-20)
            local y0=WALL_H+math.sin(t0*math.pi)*(CROWN_H-WALL_H)-3
            local y1=WALL_H+math.sin(t1*math.pi)*(CROWN_H-WALL_H)-3
            local a=Vector3.new(x0,y0,z)
            local b=Vector3.new(x1,y1,z)
            local mid=(a+b)/2
            local len=(b-a).Magnitude
            local cf=CFrame.lookAt(mid,b)*CFrame.Angles(0,math.rad(90),0)
            addBox(mesh,cf,Vector3.new(len,2.6,2.6))
        end
    end
end)

-- Two realistic-scale business-jet meshes positioned as hero objects behind the crowd.
local function jetBuilder(origin, yaw)
    return function(mesh)
        local base=CFrame.new(origin)*CFrame.Angles(0,math.rad(yaw),0)
        addEllipsoid(mesh,base*CFrame.Angles(math.rad(90),0,0),Vector3.new(7.5,32,8),10,20)
        addBox(mesh,base*CFrame.new(0,0,2),Vector3.new(58,1.6,16))
        addBox(mesh,base*CFrame.new(0,7,27),Vector3.new(30,1.2,9))
        addBox(mesh,base*CFrame.new(0,11,30),Vector3.new(2,18,10))
        addBox(mesh,base*CFrame.new(-9,-2,18),Vector3.new(5,5,11))
        addBox(mesh,base*CFrame.new(9,-2,18),Vector3.new(5,5,11))
    end
end
createMeshPart(generated,"Mesh_PrivateJet_A_FULL",Color3.fromRGB(225,228,232),Enum.Material.Metal,Enum.CollisionFidelity.Hull,jetBuilder(Vector3.new(-92,12,54),-8))
createMeshPart(generated,"Mesh_PrivateJet_B_FULL",Color3.fromRGB(226,226,230),Enum.Material.Metal,Enum.CollisionFidelity.Hull,jetBuilder(Vector3.new(92,12,54),8))

-- Helicopter mesh at the right VIP edge.
createMeshPart(generated,"Mesh_Helicopter_FULL",Color3.fromRGB(24,26,31),Enum.Material.Metal,Enum.CollisionFidelity.Hull,function(mesh)
    local base=CFrame.new(136,13,-16)*CFrame.Angles(0,math.rad(-18),0)
    addEllipsoid(mesh,base,Vector3.new(12,9,18),8,18)
    addBox(mesh,base*CFrame.new(0,1,26),Vector3.new(5,5,38))
    addBox(mesh,base*CFrame.new(0,12,0),Vector3.new(76,0.6,2.2))
    addBox(mesh,base*CFrame.new(0,12,0),Vector3.new(2.2,0.6,76))
    addBox(mesh,base*CFrame.new(0,3,46),Vector3.new(24,0.5,1.8))
end)

-- Stage / DJ cage / bars / side VIP cages as mesh geometry.
createMeshPart(generated,"Mesh_ClubFurniture_FULL",Color3.fromRGB(28,29,34),Enum.Material.Metal,Enum.CollisionFidelity.PreciseConvexDecomposition,function(mesh)
    addBox(mesh,CFrame.new(0,3,70),Vector3.new(102,6,30))
    addBox(mesh,CFrame.new(0,11,63),Vector3.new(32,12,6))
    addBox(mesh,CFrame.new(-132,5,15),Vector3.new(42,10,10))
    addBox(mesh,CFrame.new(132,5,15),Vector3.new(42,10,10))
    addBox(mesh,CFrame.new(-132,16,32),Vector3.new(46,3,50))
    addBox(mesh,CFrame.new(132,16,32),Vector3.new(46,3,50))
    for side=-1,1,2 do
        local x=side*132
        for i=0,5 do
            addBox(mesh,CFrame.new(x,8+i*4,32),Vector3.new(2.2,2.2,50))
        end
        for j=0,6 do
            addBox(mesh,CFrame.new(x,18,8+j*8),Vector3.new(46,2.2,2.2))
        end
    end
end)

if shell and ribs then
    clearLegacy(Architecture,{"Mesh_Hangar","RoofTruss_","Apron"})
    clearLegacy(Vehicles,{"Mesh_PrivateJet","Mesh_Helicopter"})
    clearLegacy(Furniture,{"Stage","DJBooth","Mesh_BarCounter","Mesh_LeatherSofa_","Mesh_MetalFencing_"})
    Workspace:SetAttribute("HangarFullMeshReady", true)
    Workspace:SetAttribute("HangarScaleClass", "AIRCRAFT_HANGAR_XL")
    print("[HANGAR FULL MESH] v2 READY", WIDTH, DEPTH, CROWN_H)
else
    Workspace:SetAttribute("HangarFullMeshReady", false)
    warn("[HANGAR FULL MESH] v2 unavailable; legacy foundation retained")
end
