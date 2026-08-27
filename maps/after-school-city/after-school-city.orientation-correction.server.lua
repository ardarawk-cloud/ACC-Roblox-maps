-- AFTER SCHOOL CITY — Orientation Correction v0.4.7
-- Cloud-source orientation correction after v0.4.6 spatial stabilization.
-- Fixes frontage/door/signage logic against the nearest road and pedestrian approach.
-- Placement/presentation only: no economy, persistence, monetization or gameplay authority.

local Workspace = game:GetService("Workspace")

local root = Workspace:WaitForChild("AfterSchoolCity", 20)
if not root then
    warn("[ASC OrientationCorrection] AfterSchoolCity root missing")
    return
end

root:WaitForChild("V046_SourceSpatialFix", 20)

if root:FindFirstChild("V047_OrientationCorrection") then
    return
end

local districts = root:WaitForChild("Districts", 10)
local roads = root:WaitForChild("RoadsAndPaths", 10)
local furniture = root:FindFirstChild("StreetFurniture")
local landmarks = root:FindFirstChild("Landmarks")

local layer = Instance.new("Model")
layer.Name = "V047_OrientationCorrection"
layer:SetAttribute("ASC_Layer", "ORIENTATION_CORRECTION")
layer:SetAttribute("ASC_Version", "0.4.7-orientation-correction-1")
layer.Parent = root

-- =========================================================
-- CLOUD ORIENTATION CONTRACT
-- Literal values are intentional so CI can verify frontage geometry directly.
-- =========================================================
local MAIN_ROAD_SIZE_Z = 412
local MAIN_ROAD_CENTER_Z = -61.5
local SCHOOL_MAIN_CENTER_Z = 202
local SCHOOL_MAIN_DEPTH = 45
local SCHOOL_FRONT_PLAZA_Z = 164.5
local SCHOOL_FRONT_PLAZA_DEPTH = 30
local SCHOOL_FRONT_WALK_Z = 162.5
local SCHOOL_FRONT_WALK_DEPTH = 34
local SCHOOL_GATE_Z = 148
local SCHOOL_GATE_SIGN_Z = 146.3
local SCHOOL_CROSSWALK_Z = 138
local SCHOOL_SPAWN_Z = 157
local SCHOOL_FRONT_CLEAR_X = 63
local SCHOOL_FRONT_CLEAR_Z_MIN = 145
local SCHOOL_FRONT_CLEAR_Z_MAX = 180
local TOWNHOUSE_3_CENTER_Z = 48

local SCHOOL_FRONT_TARGETS = {
    EntranceCanopy = 177,
    ColumnL = 173,
    ColumnR = 173,
    EntranceGlassL = 179.2,
    EntranceGlassR = 179.2,
    SchoolSign = 179.2,
    MainWindow = 179.3,
    MainWindowUpper = 179.3,
    WingWindow = 178.9,
    EntryStep1 = 172,
    EntryStep2 = 176,
}

local STUDENT_ROW_ORIENTATION = {
    StudentMiniMart = "EAST",
    StudyLounge = "EAST",
    CommunityLibrary = "WEST",
}

local function part(parent, name, size, cf, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function movePartZ(p, targetZ)
    if p and p:IsA("BasePart") then
        p.CFrame = p.CFrame + Vector3.new(0, 0, targetZ - p.Position.Z)
    end
end

local function offsetModel(model, delta)
    if not model then
        return
    end
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CFrame = descendant.CFrame + delta
        end
    end
end

local function setSurfaceFace(partObject, face)
    if not partObject then
        return
    end
    for _, child in ipairs(partObject:GetChildren()) do
        if child:IsA("SurfaceGui") then
            child.Face = face
        end
    end
end

local function findTextPlate(model, exactText)
    if not model then
        return nil
    end
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("TextLabel") and descendant.Text == exactText then
            local gui = descendant.Parent
            local plate = gui and gui.Parent
            if gui and gui:IsA("SurfaceGui") and plate and plate:IsA("BasePart") then
                return plate, gui
            end
        end
    end
    return nil
end

-- =========================================================
-- A. MAIN SCHOOL APPROACH / ROAD TERMINUS
-- v0.4.2 shortened the public avenue before the school but left the old north-facing
-- campus entrance in place. Shorten only the final avenue segment enough to create
-- a real south-side arrival apron between the road and the existing school shell.
-- =========================================================
local nsRoad = roads:FindFirstChild("NorthSouthRoad")
if nsRoad and nsRoad:IsA("BasePart") then
    nsRoad.Size = Vector3.new(nsRoad.Size.X, nsRoad.Size.Y, MAIN_ROAD_SIZE_Z)
    nsRoad.CFrame = CFrame.new(nsRoad.Position.X, nsRoad.Position.Y, MAIN_ROAD_CENTER_Z)
    nsRoad:SetAttribute("ASC_OrientationClearance", true)
    nsRoad:SetAttribute("ASC_NorthEdge", MAIN_ROAD_CENTER_Z + MAIN_ROAD_SIZE_Z / 2)
end

for _, name in ipairs({"NS_Sidewalk_W", "NS_Sidewalk_E"}) do
    local walk = roads:FindFirstChild(name)
    if walk and walk:IsA("BasePart") then
        walk.Size = Vector3.new(walk.Size.X, walk.Size.Y, MAIN_ROAD_SIZE_Z)
        walk.CFrame = CFrame.new(walk.Position.X, walk.Position.Y, MAIN_ROAD_CENTER_Z)
        walk:SetAttribute("ASC_OrientationClearance", true)
    end
end

-- Remove markings that belonged to the previous, longer road terminus.
for _, child in ipairs(roads:GetChildren()) do
    if child:IsA("BasePart") and child.Name == "NS_LaneDash" and child.Position.Z > 140 then
        child:Destroy()
    end
end

local structural = root:FindFirstChild("V042_StructuralRealignment")
if structural then
    for _, child in ipairs(structural:GetChildren()) do
        if child:IsA("BasePart") and child.Name == "CampusCrosswalkStripe" then
            child:Destroy()
        end
    end
end

for i = -4, 4 do
    local stripe = part(layer, "CampusCrosswalkStripeV047", Vector3.new(1.8, 0.08, 10), CFrame.new(i * 3.3, 1.46, SCHOOL_CROSSWALK_Z), Color3.fromRGB(240, 242, 245), Enum.Material.SmoothPlastic)
    stripe.CanCollide = false
end

-- =========================================================
-- B. SCHOOL FRONTAGE NOW FACES SOUTH TOWARD THE PUBLIC AVENUE
-- Keep the school massing where it is; mirror only its façade/entrance elements
-- to the south face. The old north plaza becomes a legitimate rear courtyard.
-- =========================================================
local school = districts:FindFirstChild("SchoolDistrict")
if school then
    local frontPlaza = school:FindFirstChild("FrontPlaza")
    if frontPlaza and frontPlaza:IsA("BasePart") then
        frontPlaza.Size = Vector3.new(frontPlaza.Size.X, frontPlaza.Size.Y, SCHOOL_FRONT_PLAZA_DEPTH)
        frontPlaza.CFrame = CFrame.new(0, frontPlaza.Position.Y, SCHOOL_FRONT_PLAZA_Z)
        frontPlaza:SetAttribute("ASC_Frontage", "SOUTH")
    end

    local frontWalk = school:FindFirstChild("FrontWalk")
    if frontWalk and frontWalk:IsA("BasePart") then
        frontWalk.Size = Vector3.new(frontWalk.Size.X, frontWalk.Size.Y, SCHOOL_FRONT_WALK_DEPTH)
        frontWalk.CFrame = CFrame.new(0, frontWalk.Position.Y, SCHOOL_FRONT_WALK_Z)
        frontWalk:SetAttribute("ASC_StopsAtSouthEntrance", true)
    end

    for _, child in ipairs(school:GetChildren()) do
        if child:IsA("BasePart") then
            local targetZ = SCHOOL_FRONT_TARGETS[child.Name]
            if targetZ then
                movePartZ(child, targetZ)
            end
        end
    end

    local schoolSign = school:FindFirstChild("SchoolSign")
    if schoolSign and schoolSign:IsA("BasePart") then
        setSurfaceFace(schoolSign, Enum.NormalId.Front)
        schoolSign:SetAttribute("ASC_SignFaces", "SOUTH")
    end

    school:SetAttribute("ASC_EntranceFaces", "SOUTH")
    school:SetAttribute("ASC_MainSouthFaceZ", SCHOOL_MAIN_CENTER_Z - SCHOOL_MAIN_DEPTH / 2)

    local schoolLife = school:FindFirstChild("V03_SchoolLife")
    if schoolLife then
        for _, name in ipairs({"GatePostL", "GatePostR", "GateBeam"}) do
            movePartZ(schoolLife:FindFirstChild(name), SCHOOL_GATE_Z)
        end

        local gatePlate, gateGui = findTextPlate(schoolLife, "AFTER SCHOOL ACADEMY")
        if gatePlate and gateGui then
            movePartZ(gatePlate, SCHOOL_GATE_SIGN_Z)
            gateGui.Face = Enum.NormalId.Front
            gatePlate:SetAttribute("ASC_SignFaces", "SOUTH")
        end

        -- Keep wayfinding out of the actual entrance apron.
        local downtownPlate = findTextPlate(schoolLife, "DOWNTOWN  ↓")
        if downtownPlate then
            downtownPlate.CFrame = downtownPlate.CFrame + Vector3.new(42, 0, 0)
            downtownPlate:SetAttribute("ASC_OrientationRelocated", true)
        end

        local canteen = schoolLife:FindFirstChild("StudentCanteen")
        if canteen then
            canteen:SetAttribute("ASC_EntranceFaces", "SOUTH")
        end
    end
end

-- Clear only obsolete corridor furniture occupying the new measured school apron.
local spatial = root:FindFirstChild("V041_SpatialCleanup")
local corridor = spatial and spatial:FindFirstChild("V041_SchoolDowntownCorridor")
if corridor then
    for _, obj in ipairs(corridor:GetChildren()) do
        if obj:IsA("BasePart") then
            local p = obj.Position
            if math.abs(p.X) <= SCHOOL_FRONT_CLEAR_X and p.Z >= SCHOOL_FRONT_CLEAR_Z_MIN and p.Z <= SCHOOL_FRONT_CLEAR_Z_MAX then
                obj:Destroy()
            end
        end
    end
end

-- The v0.2 pair of street lights at X=±30 / Z=150 would sit inside the new apron.
if furniture then
    for _, obj in ipairs(furniture:GetChildren()) do
        if obj:IsA("Model") and obj.Name == "StreetLight" then
            local probe = obj:FindFirstChild("Pole", true)
            if probe and probe:IsA("BasePart") and math.abs(probe.Position.X) <= 40 and math.abs(probe.Position.Z - 150) <= 2 then
                obj:Destroy()
            end
        end
    end

    -- Move the bus shelter just outside the west edge of the arrival plaza.
    local busStop = furniture:FindFirstChild("SchoolBusStop")
    local roof = busStop and busStop:FindFirstChild("Roof", true)
    if busStop and roof and roof:IsA("BasePart") then
        offsetModel(busStop, Vector3.new(-78 - roof.Position.X, 0, 0))
        busStop:SetAttribute("ASC_OrientationRelocated", true)
    end
end

-- Spawn inside the front campus apron and face north toward the corrected school façade.
if landmarks then
    local spawn = landmarks:FindFirstChild("AfterSchoolSpawn")
    if spawn and spawn:IsA("SpawnLocation") then
        spawn.CFrame = CFrame.new(0, 2.2, SCHOOL_SPAWN_Z) * CFrame.Angles(0, math.rad(180), 0)
        spawn:SetAttribute("ASC_FacesSchool", true)
    end
end

-- =========================================================
-- C. DOWNTOWN STOREFRONTS / SIGNS FACE THE STREET AND PLAZA
-- Storefront geometry is already on the north side (toward Z=0/plaza), but the
-- old SurfaceGui normals faced through the plates. Back = local +Z on these plates.
-- =========================================================
local downtown = districts:FindFirstChild("Downtown")
if downtown then
    for _, name in ipairs({"ARCADE", "CAFE", "STYLE", "MUSIC", "HOBBY"}) do
        local shop = downtown:FindFirstChild("Shop_" .. name)
        if shop then
            shop:SetAttribute("ASC_EntranceFaces", "NORTH")
            local storeSign = shop:FindFirstChild("StoreSign")
            if storeSign and storeSign:IsA("BasePart") then
                setSurfaceFace(storeSign, Enum.NormalId.Back)
                storeSign:SetAttribute("ASC_SignFaces", "NORTH")
            end

            local interior = shop:FindFirstChild("V03_Interior")
            if interior then
                for _, descendant in ipairs(interior:GetDescendants()) do
                    if descendant:IsA("SurfaceGui") then
                        local plate = descendant.Parent
                        if plate and plate:IsA("BasePart") and plate.Name == "LabelPlate" then
                            descendant.Face = Enum.NormalId.Back
                        end
                    end
                end
            end
        end
    end
end

-- =========================================================
-- D. RESIDENTIAL DOOR AT THE NORTH HOUSE MUST FACE THE ROAD
-- Townhouse_1 at Z=-48 already faces north (+Z) toward EastWestRoad.
-- Townhouse_3 at Z=+48 was also built +Z-facing, which points away from the road.
-- Mirror only its door/windows across its own centerline.
-- =========================================================
local residential = districts:FindFirstChild("Residential")
if residential then
    local southHouse = residential:FindFirstChild("Townhouse_1")
    if southHouse then
        southHouse:SetAttribute("ASC_EntranceFaces", "NORTH")
    end

    local northHouse = residential:FindFirstChild("Townhouse_3")
    if northHouse then
        for _, child in ipairs(northHouse:GetChildren()) do
            if child:IsA("BasePart") and (child.Name == "Door" or child.Name == "Window") then
                local mirroredZ = 2 * TOWNHOUSE_3_CENTER_Z - child.Position.Z
                movePartZ(child, mirroredZ)
            end
        end
        northHouse:SetAttribute("ASC_EntranceFaces", "SOUTH")
        northHouse:SetAttribute("ASC_DoorFacesNearestRoad", true)
    end
end

-- =========================================================
-- E. STUDENT ROW SIGNS FOLLOW THE STREET-FACING ROTATIONS FROM v0.4.1
-- Buildings were correctly yawed ±90° by SpatialCleanup, but their sign GUI normals
-- still pointed into the sign plates. Flip only those SurfaceGui normals outward.
-- =========================================================
local streetLife = root:FindFirstChild("V04_StreetLife")
local infill = streetLife and streetLife:FindFirstChild("StudentRowInfill")
if infill then
    for modelName, direction in pairs(STUDENT_ROW_ORIENTATION) do
        local building = infill:FindFirstChild(modelName)
        if building then
            building:SetAttribute("ASC_EntranceFaces", direction)
            building:SetAttribute("ASC_DoorFacesNearestRoad", true)
            for _, descendant in ipairs(building:GetDescendants()) do
                if descendant:IsA("SurfaceGui") then
                    local plate = descendant.Parent
                    if plate and plate:IsA("BasePart") and plate.Name == "Sign" then
                        descendant.Face = Enum.NormalId.Back
                        plate:SetAttribute("ASC_SignFacesStreet", true)
                    end
                end
            end
        end
    end
end

-- Club Hub v0.4.4 is intentionally west-facing and already uses Left-face signage.
local circulation = root:FindFirstChild("V044_CirculationSanitize")
local club = circulation and circulation:FindFirstChild("ClubHubV044")
if club then
    club:SetAttribute("ASC_DoorFacesNearestWalk", true)
end

root:SetAttribute("ASC_OrientationCorrectionPass", "0.4.7-orientation-correction-1")
root:SetAttribute("ASC_SchoolEntranceFacesRoad", true)
root:SetAttribute("ASC_DowntownSignsFaceStreet", true)
root:SetAttribute("ASC_ResidentialDoorsFaceRoad", true)
root:SetAttribute("ASC_StudentRowSignsFaceStreet", true)
Workspace:SetAttribute("ASC_OrientationCorrectionPass", "0.4.7-orientation-correction-1")

print("[AFTER SCHOOL CITY] Orientation Correction v0.4.7 initialized")
