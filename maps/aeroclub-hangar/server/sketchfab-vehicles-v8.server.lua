-- HANGAR — OWNER VEHICLE LAYOUT v8.0
-- Deterministic correction after owner visual FAIL on v31.
-- No generic auto-heading from bounding boxes. Cars calibrate from semantic wheel/brake hierarchy;
-- one known semantic-poor asset uses an explicit manual fallback profile.
-- Environment/procedural jet is destroyed before owner jet loads. No invisible jet body walls.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local JET_ASSET_ID = 135410789803386
local PATROL_MCLAREN_ASSET_ID = 128438812070025
local PATROL_PORSCHE_ASSET_ID = 108398505977253
local CAR01_ASSET_ID = 99964942308635
local CAR02_ASSET_ID = 108661587054557
local CAR03_ASSET_ID = 131735423260822
local CAR04_ASSET_ID = 101563967954162
local CAR05_ASSET_ID = 78379824687949
local CAR06_ASSET_ID = 121928928437649
local CAR07_ASSET_ID = 96591438161153
local CAR08_ASSET_ID = 89838081528043
local CAR09_ASSET_ID = 126546467150154
local CAR10_ASSET_ID = 101888640433519
local CAR11_ASSET_ID = 90377117635780

local FLOOR_Y = 0.40
local CAR_WHEELBASE = 11.25
local PATROL_WHEELBASE = 11.50

-- Central entrance / future helicopter lane intentionally remains EMPTY.
-- Patrol pair is pushed to the two sides and faces outdoor (+Z), like a welcome/guard display.
local placements = {
    {name="PrivateJetSketchfab", asset=JET_ASSET_ID, kind="jet", pos=Vector3.new(0,FLOOR_Y,-58), targetLength=118, manualYaw=-90, zone="JET"},

    {name="Patrol_McLarenF1LM", asset=PATROL_MCLAREN_ASSET_ID, kind="car", pos=Vector3.new(-125,FLOOR_Y,165), wheelbase=PATROL_WHEELBASE, zone="WELCOME_LEFT"},
    {name="Patrol_PorscheCarreraGT", asset=PATROL_PORSCHE_ASSET_ID, kind="car", pos=Vector3.new(125,FLOOR_Y,165), wheelbase=PATROL_WHEELBASE, zone="WELCOME_RIGHT"},

    {name="NissanR34Brian", asset=CAR01_ASSET_ID, kind="car", pos=Vector3.new(-125,FLOOR_Y,110), wheelbase=CAR_WHEELBASE, zone="LEFT_ROW"},
    {name="ToyotaSupraMK4", asset=CAR03_ASSET_ID, kind="car", pos=Vector3.new(-125,FLOOR_Y,70), wheelbase=CAR_WHEELBASE, zone="LEFT_ROW"},
    {name="MitsubishiEclipse1995", asset=CAR05_ASSET_ID, kind="car", pos=Vector3.new(-125,FLOOR_Y,30), wheelbase=CAR_WHEELBASE, zone="LEFT_ROW"},
    {name="MitsubishiEclipseSpyder", asset=CAR07_ASSET_ID, kind="car", pos=Vector3.new(-125,FLOOR_Y,-10), manualFallback=true, fallbackLength=17.5, manualYaw=180, zone="LEFT_ROW"},
    {name="NissanSkylineR34CWest", asset=CAR09_ASSET_ID, kind="car", pos=Vector3.new(-125,FLOOR_Y,-50), wheelbase=CAR_WHEELBASE, zone="LEFT_ROW"},
    {name="DeLoreanDMC12", asset=CAR11_ASSET_ID, kind="car", pos=Vector3.new(-125,FLOOR_Y,-90), wheelbase=CAR_WHEELBASE, zone="LEFT_ROW"},

    {name="DodgeChargerRT1970", asset=CAR02_ASSET_ID, kind="car", pos=Vector3.new(125,FLOOR_Y,110), wheelbase=CAR_WHEELBASE, zone="RIGHT_ROW"},
    {name="LamborghiniMurcielago", asset=CAR04_ASSET_ID, kind="car", pos=Vector3.new(125,FLOOR_Y,70), wheelbase=CAR_WHEELBASE, zone="RIGHT_ROW"},
    {name="HondaS2000", asset=CAR06_ASSET_ID, kind="car", pos=Vector3.new(125,FLOOR_Y,30), wheelbase=CAR_WHEELBASE, zone="RIGHT_ROW"},
    {name="SubaruBRZRocketBunny", asset=CAR08_ASSET_ID, kind="car", pos=Vector3.new(125,FLOOR_Y,-10), wheelbase=CAR_WHEELBASE, zone="RIGHT_ROW"},
    {name="ChevyCamaroSS", asset=CAR10_ASSET_ID, kind="car", pos=Vector3.new(125,FLOOR_Y,-50), wheelbase=CAR_WHEELBASE, zone="RIGHT_ROW"},
}

Workspace:SetAttribute("HangarSketchfabVehicles","BOOTING_OWNER_LAYOUT_V8")
Workspace:SetAttribute("HangarFleetLayout","V8_SEMANTIC_WHEEL_CALIBRATED_SIDE_ROWS")
Workspace:SetAttribute("HangarScalePolicy","WHEELBASE_CALIBRATED_PER_ASSET")
Workspace:SetAttribute("HangarOrientationPolicy","SEMANTIC_FRONT_REAR_HIERARCHY_FACE_PLUS_Z")
Workspace:SetAttribute("HangarGroundingPolicy","SEMANTIC_WHEEL_BOTTOM")
Workspace:SetAttribute("HangarJetPolicy","ONE_OWNER_JET_MANUAL_YAW_NO_GHOST_COLLISION")
Workspace:SetAttribute("HangarEntrancePolicy","CENTER_LANE_CLEAR_FOR_GUESTS_AND_FUTURE_HELICOPTER")
Workspace:SetAttribute("HangarFurniturePolicy","NO_TABLE_SOFA_CHAIR")
Workspace:SetAttribute("HangarRequestedCarCount",13)

local deadline=os.clock()+35
while os.clock()<deadline and Workspace:GetAttribute("HangarEnvironmentReady")~=true do task.wait(0.25) end
local environment=Workspace:FindFirstChild("Environment")
if not environment or Workspace:GetAttribute("HangarEnvironmentReady")~=true then
    Workspace:SetAttribute("HangarSketchfabVehicles","ENVIRONMENT_NOT_READY")
    return
end

local function lower(s) return string.lower(s or "") end
local function containsAny(s, words)
    for _,w in ipairs(words) do if string.find(s,w,1,true) then return true end end
    return false
end

-- Furniture remains forbidden by owner instruction.
for _,d in ipairs(environment:GetDescendants()) do
    local n=lower(d.Name)
    local remove=containsAny(n,{"sofa","couch","chair","coffee_table","coffee table","lounge_table","lounge table"})
    if remove and (d:IsA("Model") or d:IsA("BasePart")) then d:Destroy() end
end

-- Destroy, do not hide, every procedural/environment jet component and old procedural car component.
-- This fixes the visually doubled / 'gancet' jet instead of stacking another jet over it.
local exactLegacyJetNames = {
    JetPlaneMesh=true, JetGlassAndTrimMesh=true, JetEngineMesh=true, JetLandingGearMesh=true,
    JetVIPLoungeMesh=true, JetWingStagesMesh=true, JetVIPFloor=true, JetLeftWingStage=true, JetRightWingStage=true,
    SketchfabJetBodyProxy=true,
}
local destroyList={}
for _,d in ipairs(environment:GetDescendants()) do
    local n=d.Name
    local legacyJet=exactLegacyJetNames[n]==true
        or string.sub(n,1,3)=="Jet" and (d:IsA("BasePart") or d:IsA("Model"))
    local legacyCar=string.sub(n,1,10)=="ClassicCar" or string.sub(n,1,8)=="Hypercar"
    if legacyJet or legacyCar then table.insert(destroyList,d) end
end
for _,d in ipairs(destroyList) do if d and d.Parent then d:Destroy() end end

for _,oldName in ipairs({"SketchfabVehicleDisplayV1","HangarShowcaseFleetV2","HangarOwnerQCStagingV3","HangarOwnerQCStagingV31","HangarOwnerFleetV4","HangarOwnerFleetV5","HangarOwnerFleetV6","HangarOwnerFleetV7","HangarOwnerFleetV8"}) do
    local old=environment:FindFirstChild(oldName)
    if old then old:Destroy() end
end

local collisionRoot=environment:FindFirstChild("Collision")
if not collisionRoot then collisionRoot=Instance.new("Folder"); collisionRoot.Name="Collision"; collisionRoot.Parent=environment end
for _,child in ipairs(collisionRoot:GetChildren()) do
    local n=child.Name
    if child:GetAttribute("HangarFleetCollision")==true
        or child:GetAttribute("HangarDanceSurface")==true
        or string.sub(n,1,3)=="Jet"
        or string.sub(n,1,10)=="ClassicCar"
        or string.sub(n,1,8)=="Hypercar"
        or string.find(n,"_DisplayCollision",1,true)
        or string.find(n,"_DanceDeck",1,true) then
        child:Destroy()
    end
end

local replacement=Instance.new("Model")
replacement.Name="HangarOwnerFleetV8"
replacement:SetAttribute("DisplayOnly",true)
replacement:SetAttribute("Source","OWNER_APPROVED_ROBLOX_ASSETS_FROM_DRIVE_GLB")
replacement.Parent=environment

local function sanitize(model)
    local count=0
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Sound") then d:Destroy()
        elseif d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then d:Destroy()
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then d.Enabled=false
        elseif d:IsA("BasePart") then
            count+=1
            d.Anchored=true; d.CanCollide=false; d.CanTouch=false; d.CanQuery=true; d.Massless=true; d.CastShadow=true
        end
    end
    return count
end

local function semanticPath(part, root)
    local names={lower(part.Name)}
    local p=part.Parent
    while p and p~=root do
        table.insert(names,lower(p.Name))
        p=p.Parent
    end
    return table.concat(names,"/")
end

local function orientedBottomY(part)
    local cf=part.CFrame
    local half=part.Size*0.5
    local yExtent=math.abs(cf.RightVector.Y)*half.X + math.abs(cf.UpVector.Y)*half.Y + math.abs(cf.LookVector.Y)*half.Z
    return part.Position.Y-yExtent
end

local function collectSemantic(model)
    local frontParts={}
    local rearParts={}
    local wheelParts={}
    local allParts={}

    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            table.insert(allParts,d)
            local path=semanticPath(d,model)
            local wheelish=containsAny(path,{"wheel","tire","tyre","rim","caliper","calliper","brake_caliper"})
            local frontish=containsAny(path,{"front","_lf","lf_","_rf","rf_","headlight","headlamp"})
            local rearish=containsAny(path,{"rear","_lr","lr_","_rr","rr_","taillight","tail_light"})
            if wheelish then table.insert(wheelParts,d) end
            if wheelish and frontish then table.insert(frontParts,d) end
            if wheelish and rearish then table.insert(rearParts,d) end
        end
    end
    return allParts,wheelParts,frontParts,rearParts
end

local function averageLocal(model,parts)
    if #parts==0 then return nil end
    local pivot=model:GetPivot()
    local sum=Vector3.zero
    for _,p in ipairs(parts) do sum+=pivot:PointToObjectSpace(p.Position) end
    return sum/#parts
end

local function semanticWheelVector(model)
    local _,_,frontParts,rearParts=collectSemantic(model)
    if #frontParts<1 or #rearParts<1 then return nil,0,0 end
    local f=averageLocal(model,frontParts)
    local r=averageLocal(model,rearParts)
    if not f or not r then return nil,#frontParts,#rearParts end
    return f-r,#frontParts,#rearParts
end

local function ensureWheelAxisHorizontal(model)
    local v=semanticWheelVector(model)
    if not v then return false,"NO_SEMANTIC_WHEEL_AXIS" end
    local horizontal=Vector3.new(v.X,0,v.Z)
    if horizontal.Magnitude>=math.abs(v.Y)*0.55 then return true,"ALREADY_HORIZONTAL" end

    -- Some source GLBs are authored Z-up. If semantic front/rear is vertical after import,
    -- rotate exactly 90 degrees around X, based on semantic axle direction, then re-measure.
    local pitch=(v.Y>=0) and math.rad(90) or math.rad(-90)
    model:PivotTo(model:GetPivot()*CFrame.Angles(pitch,0,0))
    return true,"SEMANTIC_Z_UP_CORRECTED"
end

local function faceOutdoorFromWheels(model)
    local v,fc,rc=semanticWheelVector(model)
    if not v then return false,"NO_FRONT_REAR",fc,rc end
    local horizontal=Vector3.new(v.X,0,v.Z)
    if horizontal.Magnitude<0.01 then return false,"VERTICAL_FRONT_REAR",fc,rc end
    local dir=horizontal.Unit
    local yaw=-math.atan2(dir.X,dir.Z)
    local pivot=model:GetPivot()
    model:PivotTo(CFrame.new(pivot.Position)*CFrame.Angles(0,yaw,0))
    return true,"SEMANTIC_FRONT_REAR",fc,rc
end

local function scaleByWheelbase(model,targetWheelbase)
    local v=semanticWheelVector(model)
    if not v then return false,"NO_WHEELBASE" end
    local horizontal=Vector3.new(v.X,0,v.Z).Magnitude
    if horizontal<0.01 then return false,"WHEELBASE_TOO_SMALL" end
    local factor=targetWheelbase/horizontal
    if factor<0.05 or factor>100 then return false,"WHEELBASE_FACTOR_REJECTED" end
    model:ScaleTo(model:GetScale()*factor)
    return true,factor
end

local function scaleByLengthFallback(model,targetLength)
    local _,size=model:GetBoundingBox()
    local horizontal=math.max(size.X,size.Z)
    if horizontal<0.01 then return false,"BAD_BOUNDS" end
    local factor=targetLength/horizontal
    if factor<0.05 or factor>100 then return false,"LENGTH_FACTOR_REJECTED" end
    model:ScaleTo(model:GetScale()*factor)
    return true,factor
end

local function groundOnWheels(model,targetY)
    local allParts,wheelParts=collectSemantic(model)
    local use=(#wheelParts>0) and wheelParts or allParts
    if #use==0 then return false,"NO_GROUND_PARTS" end
    local bottom=math.huge
    for _,p in ipairs(use) do bottom=math.min(bottom,orientedBottomY(p)) end
    if bottom==math.huge then return false,"NO_GROUND_BOTTOM" end
    model:PivotTo(model:GetPivot()+Vector3.new(0,targetY+0.05-bottom,0))
    return true,(#wheelParts>0 and "WHEEL_BOTTOM" or "ALL_PART_BOTTOM")
end

local function makeDanceDeck(name,model)
    local boxCF,boxSize=model:GetBoundingBox()
    local p=Instance.new("Part")
    p.Name=name; p.Anchored=true; p.Transparency=1; p.CanCollide=true; p.CanTouch=false; p.CanQuery=false
    p.Size=Vector3.new(math.max(4.2,boxSize.X*0.56),0.18,math.max(4.2,boxSize.Z*0.56))
    p.CFrame=CFrame.new(boxCF.Position.X,boxCF.Position.Y+boxSize.Y*0.39,boxCF.Position.Z)*(boxCF-boxCF.Position)
    p:SetAttribute("HangarFleetCollision",true); p:SetAttribute("HangarDanceSurface",true)
    p.Parent=collisionRoot
end

local function placeJet(model,spec)
    local _,size=model:GetBoundingBox()
    local horizontal=math.max(size.X,size.Z)
    if horizontal<0.01 then error("JET_BAD_BOUNDS") end
    local factor=spec.targetLength/horizontal
    model:ScaleTo(model:GetScale()*factor)
    model:PivotTo(CFrame.new(spec.pos.X,0,spec.pos.Z)*CFrame.Angles(0,math.rad(spec.manualYaw),0))
    local _,_,_,_=collectSemantic(model)
    local allParts={}
    for _,d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then table.insert(allParts,d) end end
    if #allParts==0 then error("JET_NO_PARTS") end
    local bottom=math.huge
    for _,p in ipairs(allParts) do bottom=math.min(bottom,orientedBottomY(p)) end
    model:PivotTo(model:GetPivot()+Vector3.new(0,spec.pos.Y+0.10-bottom,0))
    model:SetAttribute("Calibration","JET_MANUAL_YAW_MINUS_90_BOUNDING_LENGTH")
    model:SetAttribute("NoInvisibleBodyCollision",true)
end

local function placeCar(model,spec)
    local correction="NONE"
    local semanticOK=not spec.manualFallback

    if semanticOK then
        local ok,why=ensureWheelAxisHorizontal(model)
        if not ok then semanticOK=false else correction=why end
    end

    if semanticOK then
        local ok,why=scaleByWheelbase(model,spec.wheelbase)
        if not ok then semanticOK=false else model:SetAttribute("ScaleCalibration","WHEELBASE_"..tostring(spec.wheelbase)) end
    end

    if semanticOK then
        local ok,why,fc,rc=faceOutdoorFromWheels(model)
        if not ok then semanticOK=false else
            model:SetAttribute("HeadingCalibration",why)
            model:SetAttribute("SemanticFrontParts",fc)
            model:SetAttribute("SemanticRearParts",rc)
        end
    end

    if not semanticOK then
        local ok,why=scaleByLengthFallback(model,spec.fallbackLength or 17.5)
        if not ok then error(spec.name..":"..why) end
        local yaw=math.rad(spec.manualYaw or 180)
        model:PivotTo(CFrame.new(model:GetPivot().Position)*CFrame.Angles(0,yaw,0))
        model:SetAttribute("ScaleCalibration","MANUAL_FALLBACK_LENGTH")
        model:SetAttribute("HeadingCalibration","MANUAL_FALLBACK_YAW_"..tostring(spec.manualYaw or 180))
    end

    -- Translation happens after calibration; no generic pivot guessing.
    local pivot=model:GetPivot()
    model:PivotTo(CFrame.new(spec.pos.X,pivot.Position.Y,spec.pos.Z)*(pivot-pivot.Position))
    local grounded,groundWhy=groundOnWheels(model,spec.pos.Y)
    if not grounded then error(spec.name..":"..groundWhy) end
    model:SetAttribute("GroundCalibration",groundWhy)
    model:SetAttribute("UprightCorrection",correction)
    makeDanceDeck(spec.name.."_DanceDeck",model)
end

local loadedNames={}
local failedNames={}
local jetLoaded=false
local function loadOne(spec)
    local ok,loaded=pcall(InsertService.LoadAsset,InsertService,spec.asset)
    if not ok or not loaded then table.insert(failedNames,spec.name..":LOAD_FAIL"); return false end
    loaded.Name=spec.name
    loaded:SetAttribute("RobloxAssetId",spec.asset)
    loaded:SetAttribute("DisplayOnly",true)
    loaded:SetAttribute("ShowcaseZone",spec.zone)
    local partCount=sanitize(loaded)
    if partCount<1 then loaded:Destroy(); table.insert(failedNames,spec.name..":NO_PARTS"); return false end
    loaded.Parent=replacement

    local placed,err=pcall(function()
        if spec.kind=="jet" then placeJet(loaded,spec) else placeCar(loaded,spec) end
    end)
    if not placed then
        loaded:Destroy(); table.insert(failedNames,spec.name..":PLACE_FAIL:"..tostring(err)); warn("[HANGAR V8]",spec.name,err); return false
    end

    table.insert(loadedNames,spec.name)
    if spec.kind=="jet" then jetLoaded=true end
    return true
end

for _,spec in ipairs(placements) do loadOne(spec) end

Workspace:SetAttribute("HangarSketchfabVehicles",#failedNames==0 and "READY_OWNER_LAYOUT_V8" or "READY_OWNER_LAYOUT_V8_PARTIAL")
Workspace:SetAttribute("HangarVehicleCountReal",#loadedNames)
Workspace:SetAttribute("HangarVehicleFailures",table.concat(failedNames,"|"))
Workspace:SetAttribute("HangarJetLoadedExactOwnerAsset",jetLoaded)
Workspace:SetAttribute("HangarDuplicateJetFix","ENVIRONMENT_JET_COMPONENTS_DESTROYED_NOT_HIDDEN")
Workspace:SetAttribute("HangarGhostWallFix","ZERO_RUNTIME_JET_COLLIDERS")
Workspace:SetAttribute("HangarPatrolWelcome","SIDE_POSITIONS_X_PLUS_MINUS_125_Z165_CENTER_LANE_CLEAR")
print("[HANGAR V8] loaded",#loadedNames,"failed",#failedNames,"jetExact",jetLoaded)
