-- HANGAR — OWNER VEHICLE LAYOUT v6.0
-- Owner QC: no ghost walls around jet, no floating cars, organized two-side fleet, patrol welcome pair at hangar front.
-- Exact approved owner assets only. No generated images. No tables/sofas/chairs. Lasers unchanged.

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
local PATROL_Y = 0.40

-- Runtime front/outdoor is +Z. Patrols form a welcome pair facing outward.
-- Main owner fleet is distributed in clean left/right rows so neither side of the jet is empty.
local placements = {
    {name="PrivateJetSketchfab", asset=JET_ASSET_ID, target=118, pos=Vector3.new(0,FLOOR_Y,-58), yaw=-90, kind="jet", zone="JET"},

    {name="Patrol_McLarenF1LM", asset=PATROL_MCLAREN_ASSET_ID, target=29, pos=Vector3.new(-58,PATROL_Y,170), yaw=0, kind="car", zone="WELCOME_LEFT"},
    {name="Patrol_PorscheCarreraGT", asset=PATROL_PORSCHE_ASSET_ID, target=29, pos=Vector3.new(58,PATROL_Y,170), yaw=0, kind="car", zone="WELCOME_RIGHT"},

    {name="NissanR34Brian", asset=CAR01_ASSET_ID, target=29, pos=Vector3.new(-92,FLOOR_Y,95), yaw=0, kind="car", zone="LEFT_ROW"},
    {name="ToyotaSupraMK4", asset=CAR03_ASSET_ID, target=29, pos=Vector3.new(-92,FLOOR_Y,50), yaw=0, kind="car", zone="LEFT_ROW"},
    {name="MitsubishiEclipse1995", asset=CAR05_ASSET_ID, target=28, pos=Vector3.new(-92,FLOOR_Y,5), yaw=0, kind="car", zone="LEFT_ROW"},
    {name="MitsubishiEclipseSpyder", asset=CAR07_ASSET_ID, target=28, pos=Vector3.new(-92,FLOOR_Y,-40), yaw=0, kind="car", zone="LEFT_ROW"},
    {name="NissanSkylineR34CWest", asset=CAR09_ASSET_ID, target=29, pos=Vector3.new(-92,FLOOR_Y,-85), yaw=0, kind="car", zone="LEFT_ROW"},
    {name="DeLoreanDMC12", asset=CAR11_ASSET_ID, target=29, pos=Vector3.new(-92,FLOOR_Y,-130), yaw=0, kind="car", zone="LEFT_ROW"},

    {name="DodgeChargerRT1970", asset=CAR02_ASSET_ID, target=30, pos=Vector3.new(92,FLOOR_Y,95), yaw=0, kind="car", zone="RIGHT_ROW"},
    {name="LamborghiniMurcielago", asset=CAR04_ASSET_ID, target=29, pos=Vector3.new(92,FLOOR_Y,50), yaw=0, kind="car", zone="RIGHT_ROW"},
    {name="HondaS2000", asset=CAR06_ASSET_ID, target=28, pos=Vector3.new(92,FLOOR_Y,5), yaw=0, kind="car", zone="RIGHT_ROW"},
    {name="SubaruBRZRocketBunny", asset=CAR08_ASSET_ID, target=28, pos=Vector3.new(92,FLOOR_Y,-40), yaw=0, kind="car", zone="RIGHT_ROW"},
    {name="ChevyCamaroSS", asset=CAR10_ASSET_ID, target=30, pos=Vector3.new(92,FLOOR_Y,-85), yaw=0, kind="car", zone="RIGHT_ROW"},
}

Workspace:SetAttribute("HangarSketchfabVehicles","BOOTING_OWNER_LAYOUT_V6")
Workspace:SetAttribute("HangarFleetLayout","V6_TWO_SIDE_ROWS_PATROL_WELCOME")
Workspace:SetAttribute("HangarCarScalePolicy","BIGBOY_REAL_SCALE_28_TO_30_STUDS")
Workspace:SetAttribute("HangarJetOrientation","OWNER_EXACT_KEEP_V5")
Workspace:SetAttribute("HangarJetCollisionPolicy","ZERO_INVISIBLE_JET_COLLISION_OWNER_QC")
Workspace:SetAttribute("HangarCarCollisionPolicy","THIN_TOP_DANCE_DECK_ONLY")
Workspace:SetAttribute("HangarGroundingPolicy","WHEEL_AWARE_AUTO_GROUND")
Workspace:SetAttribute("HangarFurniturePolicy","NO_TABLE_SOFA_CHAIR")
Workspace:SetAttribute("HangarRequestedCarCount",13)

local deadline=os.clock()+35
while os.clock()<deadline and Workspace:GetAttribute("HangarEnvironmentReady")~=true do task.wait(0.25) end
local environment=Workspace:FindFirstChild("Environment")
if not environment or Workspace:GetAttribute("HangarEnvironmentReady")~=true then
    Workspace:SetAttribute("HangarSketchfabVehicles","ENVIRONMENT_NOT_READY")
    return
end

for _,d in ipairs(environment:GetDescendants()) do
    local n=string.lower(d.Name)
    local remove=string.find(n,"sofa",1,true) or string.find(n,"couch",1,true) or string.find(n,"chair",1,true) or string.find(n,"coffee_table",1,true) or string.find(n,"coffee table",1,true) or string.find(n,"lounge_table",1,true) or string.find(n,"lounge table",1,true)
    if remove and (d:IsA("Model") or d:IsA("BasePart")) then d:Destroy() end
end

for _,oldName in ipairs({"SketchfabVehicleDisplayV1","HangarShowcaseFleetV2","HangarOwnerQCStagingV3","HangarOwnerQCStagingV31","HangarOwnerFleetV4","HangarOwnerFleetV5","HangarOwnerFleetV6"}) do
    local old=environment:FindFirstChild(oldName)
    if old then old:Destroy() end
end

local collisionRoot=environment:FindFirstChild("Collision")
if not collisionRoot then collisionRoot=Instance.new("Folder"); collisionRoot.Name="Collision"; collisionRoot.Parent=environment end

-- Delete every legacy vehicle/jet proxy and every prior runtime fleet collision.
-- Keep only real hangar/floor/gate/baggage collision from the environment authority.
for _,child in ipairs(collisionRoot:GetChildren()) do
    local n=child.Name
    local remove = child:GetAttribute("HangarFleetCollision")==true
        or child:GetAttribute("HangarDanceSurface")==true
        or string.sub(n,1,3)=="Jet"
        or string.sub(n,1,10)=="ClassicCar"
        or string.sub(n,1,8)=="Hypercar"
        or string.find(n,"_DisplayCollision",1,true)
        or string.find(n,"_DanceDeck",1,true)
    if remove then child:Destroy() end
end

local replacement=Instance.new("Model")
replacement.Name="HangarOwnerFleetV6"
replacement:SetAttribute("DisplayOnly",true)
replacement:SetAttribute("Source","OWNER_DRIVE_GLB_GENERIC_ASSETS")
replacement.Parent=environment

local function sanitize(model)
    local parts=0
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Sound") then d:Destroy()
        elseif d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then d:Destroy()
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then d.Enabled=false
        elseif d:IsA("BasePart") then
            parts+=1
            d.Anchored=true
            d.CanCollide=false
            d.CanTouch=false
            d.CanQuery=true
            d.Massless=true
            d.CastShadow=true
        end
    end
    return parts
end

local function makeDanceDeck(name,cf,size)
    local p=Instance.new("Part")
    p.Name=name
    p.Anchored=true
    p.Transparency=1
    p.CanCollide=true
    p.CanTouch=false
    p.CanQuery=false
    p.Size=size
    p.CFrame=cf
    p:SetAttribute("HangarFleetCollision",true)
    p:SetAttribute("HangarDanceSurface",true)
    p.Parent=collisionRoot
end

local function getGroundBottom(model)
    local wheelBottoms={}
    local allBottoms={}
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            local bottom=d.Position.Y-d.Size.Y*0.5
            table.insert(allBottoms,bottom)
            local n=string.lower(d.Name)
            if string.find(n,"wheel",1,true) or string.find(n,"tire",1,true) or string.find(n,"tyre",1,true) or string.find(n,"rim",1,true) then
                table.insert(wheelBottoms,bottom)
            end
        end
    end
    if #wheelBottoms>=2 then
        table.sort(wheelBottoms)
        return wheelBottoms[1]
    end
    table.sort(allBottoms)
    if #allBottoms==0 then return nil end
    local idx=math.max(1,math.floor(#allBottoms*0.08))
    return allBottoms[idx]
end

local function normalizeAndPlace(model,spec)
    local _,size=model:GetBoundingBox()
    local horizontal=math.max(size.X,size.Z)
    if horizontal<=0.01 then error("invalid bounds "..spec.name) end
    local scale=spec.target/horizontal
    if scale<0.001 or scale>500 then error("unsafe scale "..spec.name) end
    model:ScaleTo(model:GetScale()*scale)

    if spec.kind=="jet" then
        -- Keep owner-approved jet orientation. No invisible jet collision is created in v6.
        model:PivotTo(CFrame.new(spec.pos.X,0,spec.pos.Z)*CFrame.Angles(0,math.rad(spec.yaw),0))
        local boxCF,boxSize=model:GetBoundingBox()
        local bottomY=boxCF.Position.Y-boxSize.Y*0.5
        model:PivotTo(model:GetPivot()+Vector3.new(0,spec.pos.Y+2.15-bottomY,0))
        return
    end

    -- Normalize every car so its long axis runs front/back through the hangar instead of sideways/random.
    local _,preSize=model:GetBoundingBox()
    local axisFix=(preSize.X>preSize.Z) and 90 or 0
    model:PivotTo(CFrame.new(spec.pos.X,0,spec.pos.Z)*CFrame.Angles(0,math.rad(spec.yaw+axisFix),0))

    -- Wheel-aware grounding prevents the floating-car problem from outlier helper meshes.
    local groundBottom=getGroundBottom(model)
    if not groundBottom then error("no ground candidate "..spec.name) end
    model:PivotTo(model:GetPivot()+Vector3.new(0,spec.pos.Y+0.08-groundBottom,0))

    -- Only a thin top deck remains collidable so players can stand/dance on cars without ghost body walls.
    local boxCF,boxSize=model:GetBoundingBox()
    local deckY=boxCF.Position.Y+boxSize.Y*0.39
    local deckSize=Vector3.new(math.max(5,boxSize.X*0.62),0.22,math.max(5,boxSize.Z*0.62))
    makeDanceDeck(spec.name.."_DanceDeck",CFrame.new(boxCF.Position.X,deckY,boxCF.Position.Z)*(boxCF-boxCF.Position),deckSize)
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
    local placed,err=pcall(normalizeAndPlace,loaded,spec)
    if not placed then loaded:Destroy(); table.insert(failedNames,spec.name..":PLACE_FAIL"); warn(err); return false end
    table.insert(loadedNames,spec.name)
    if spec.kind=="jet" then jetLoaded=true end
    return true
end

for _,spec in ipairs(placements) do loadOne(spec) end

-- Force-hide every procedural jet/car fragment from the base environment.
for _,d in ipairs(environment:GetDescendants()) do
    if d:IsA("BasePart") and not d:IsDescendantOf(replacement) then
        local n=d.Name
        local legacyJet=string.sub(n,1,3)=="Jet"
        local legacyCar=string.sub(n,1,10)=="ClassicCar" or string.sub(n,1,8)=="Hypercar"
        if legacyCar or (jetLoaded and legacyJet) then
            d.Transparency=1
            d.CastShadow=false
            d.CanCollide=false
            d.CanTouch=false
            d.CanQuery=false
        end
    end
end

Workspace:SetAttribute("HangarSketchfabVehicles",#failedNames==0 and "READY_OWNER_LAYOUT_V6" or "READY_OWNER_LAYOUT_V6_PARTIAL")
Workspace:SetAttribute("HangarVehicleCountReal",#loadedNames)
Workspace:SetAttribute("HangarVehicleFailures",table.concat(failedNames,"|"))
Workspace:SetAttribute("HangarJetLoadedExactOwnerAsset",jetLoaded)
Workspace:SetAttribute("HangarGhostWallFix","LEGACY_JET_COLLIDERS_PURGED")
Workspace:SetAttribute("HangarPatrolWelcome","X_PLUS_MINUS_58_Z170_FACE_OUT")
print("[HANGAR V6] loaded",#loadedNames,"failed",#failedNames,"jetExact",jetLoaded)
