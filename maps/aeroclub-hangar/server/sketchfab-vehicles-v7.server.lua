-- HANGAR — OWNER VEHICLE LAYOUT v7.0
-- Measured runtime correction: preserve exact owner meshes, normalize real display scale,
-- detect each vehicle's actual nose direction from mesh/node names, ground from real wheel geometry,
-- remove flat import-helper pads, keep zero jet ghost-wall collision, and use only thin car dance decks.
-- No generated images. No tables/sofas/chairs. Lasers unchanged.

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
local OUTDOOR_DIR = Vector3.new(0,0,1)

-- 24-26 studs keeps the cars clearly larger than avatar scale without turning them into oversized props.
-- All cars face the hangar opening (+Z). Patrol pair becomes the welcome display at the front.
local placements = {
    {name="PrivateJetSketchfab", asset=JET_ASSET_ID, target=118, pos=Vector3.new(0,FLOOR_Y,-58), kind="jet", zone="JET", face="OUTDOOR"},

    {name="Patrol_McLarenF1LM", asset=PATROL_MCLAREN_ASSET_ID, target=25, pos=Vector3.new(-60,FLOOR_Y,170), kind="car", zone="WELCOME_LEFT", face="OUTDOOR"},
    {name="Patrol_PorscheCarreraGT", asset=PATROL_PORSCHE_ASSET_ID, target=25, pos=Vector3.new(60,FLOOR_Y,170), kind="car", zone="WELCOME_RIGHT", face="OUTDOOR"},

    {name="NissanR34Brian", asset=CAR01_ASSET_ID, target=25, pos=Vector3.new(-95,FLOOR_Y,112), kind="car", zone="LEFT_ROW", face="OUTDOOR"},
    {name="ToyotaSupraMK4", asset=CAR03_ASSET_ID, target=25, pos=Vector3.new(-95,FLOOR_Y,72), kind="car", zone="LEFT_ROW", face="OUTDOOR"},
    {name="MitsubishiEclipse1995", asset=CAR05_ASSET_ID, target=24, pos=Vector3.new(-95,FLOOR_Y,32), kind="car", zone="LEFT_ROW", face="OUTDOOR"},
    {name="MitsubishiEclipseSpyder", asset=CAR07_ASSET_ID, target=24, pos=Vector3.new(-95,FLOOR_Y,-8), kind="car", zone="LEFT_ROW", face="OUTDOOR"},
    {name="NissanSkylineR34CWest", asset=CAR09_ASSET_ID, target=25, pos=Vector3.new(-95,FLOOR_Y,-48), kind="car", zone="LEFT_ROW", face="OUTDOOR"},
    {name="DeLoreanDMC12", asset=CAR11_ASSET_ID, target=25, pos=Vector3.new(-95,FLOOR_Y,-88), kind="car", zone="LEFT_ROW", face="OUTDOOR"},

    {name="DodgeChargerRT1970", asset=CAR02_ASSET_ID, target=26, pos=Vector3.new(95,FLOOR_Y,112), kind="car", zone="RIGHT_ROW", face="OUTDOOR"},
    {name="LamborghiniMurcielago", asset=CAR04_ASSET_ID, target=25, pos=Vector3.new(95,FLOOR_Y,72), kind="car", zone="RIGHT_ROW", face="OUTDOOR"},
    {name="HondaS2000", asset=CAR06_ASSET_ID, target=24, pos=Vector3.new(95,FLOOR_Y,32), kind="car", zone="RIGHT_ROW", face="OUTDOOR"},
    {name="SubaruBRZRocketBunny", asset=CAR08_ASSET_ID, target=24, pos=Vector3.new(95,FLOOR_Y,-8), kind="car", zone="RIGHT_ROW", face="OUTDOOR"},
    {name="ChevyCamaroSS", asset=CAR10_ASSET_ID, target=26, pos=Vector3.new(95,FLOOR_Y,-48), kind="car", zone="RIGHT_ROW", face="OUTDOOR"},
}

Workspace:SetAttribute("HangarSketchfabVehicles","BOOTING_OWNER_LAYOUT_V7")
Workspace:SetAttribute("HangarFleetLayout","V7_MEASURED_TWO_SIDE_ROWS_PATROL_WELCOME")
Workspace:SetAttribute("HangarCarScalePolicy","MEASURED_24_TO_26_STUD_DISPLAY")
Workspace:SetAttribute("HangarOrientationPolicy","AUTO_NOSE_DETECT_FACE_OUTDOOR_PLUS_Z")
Workspace:SetAttribute("HangarGroundingPolicy","ORIENTED_WHEEL_BOTTOM_WITH_VISIBLE_FALLBACK")
Workspace:SetAttribute("HangarImportCleanup","REMOVE_FLAT_HELPER_PADS")
Workspace:SetAttribute("HangarJetCollisionPolicy","ZERO_INVISIBLE_JET_COLLISION_OWNER_QC")
Workspace:SetAttribute("HangarCarCollisionPolicy","THIN_TOP_DANCE_DECK_ONLY")
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

for _,oldName in ipairs({"SketchfabVehicleDisplayV1","HangarShowcaseFleetV2","HangarOwnerQCStagingV3","HangarOwnerQCStagingV31","HangarOwnerFleetV4","HangarOwnerFleetV5","HangarOwnerFleetV6","HangarOwnerFleetV7"}) do
    local old=environment:FindFirstChild(oldName)
    if old then old:Destroy() end
end

local collisionRoot=environment:FindFirstChild("Collision")
if not collisionRoot then collisionRoot=Instance.new("Folder"); collisionRoot.Name="Collision"; collisionRoot.Parent=environment end
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
replacement.Name="HangarOwnerFleetV7"
replacement:SetAttribute("DisplayOnly",true)
replacement:SetAttribute("Source","OWNER_DRIVE_GLB_GENERIC_ASSETS")
replacement.Parent=environment

local function orientedBottomY(p)
    local cf=p.CFrame
    local s=p.Size*0.5
    local half=math.abs(cf.RightVector.Y)*s.X + math.abs(cf.UpVector.Y)*s.Y + math.abs(cf.LookVector.Y)*s.Z
    return p.Position.Y-half
end

local function sanitize(model)
    local parts=0
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Sound") then d:Destroy()
        elseif d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then d:Destroy()
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then d.Enabled=false
        elseif d:IsA("BasePart") then
            parts+=1
            d.Anchored=true; d.CanCollide=false; d.CanTouch=false; d.CanQuery=true; d.Massless=true; d.CastShadow=true
        end
    end
    return parts
end

local function purgeFlatHelperPads(model)
    local _,boxSize=model:GetBoundingBox()
    local horizontal=math.max(boxSize.X,boxSize.Z)
    local h=math.max(boxSize.Y,0.01)
    local removed=0
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            local maxXZ=math.max(d.Size.X,d.Size.Z)
            local minXZ=math.min(d.Size.X,d.Size.Z)
            local flat=d.Size.Y < h*0.055
            local wide=maxXZ > horizontal*0.56 and minXZ > horizontal*0.24
            local n=string.lower(d.Name)
            local helperName=string.find(n,"ground",1,true) or string.find(n,"shadow",1,true) or string.find(n,"displaybase",1,true) or string.find(n,"display_base",1,true)
            if (flat and wide) or helperName then
                d:Destroy(); removed+=1
            end
        end
    end
    return removed
end

local function headingVector(model,kind)
    local pivot=model:GetPivot()
    local fronts={}
    local rears={}
    local frontWords = kind=="jet" and {"nose","cockpit","windshield","windscreen","front"} or {"front","headlight","headlamp","grille","grill","hood","bonnet","radiator"}
    local rearWords = kind=="jet" and {"tail","rudder","rear"} or {"rear","taillight","tail_light","trunk","boot","exhaust"}

    local function matches(n,words)
        for _,w in ipairs(words) do if string.find(n,w,1,true) then return true end end
        return false
    end

    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            local n=string.lower(d.Name)
            local lp=pivot:PointToObjectSpace(d.Position)
            if matches(n,frontWords) then table.insert(fronts,lp) end
            if matches(n,rearWords) then table.insert(rears,lp) end
        end
    end

    local function avg(t)
        local v=Vector3.zero
        for _,p in ipairs(t) do v+=p end
        return #t>0 and v/#t or nil
    end

    local f=avg(fronts)
    local r=avg(rears)
    local v=nil
    local source="FALLBACK"
    if f and r then v=f-r; source="FRONT_REAR_NAMES"
    elseif f then v=Vector3.new(f.X,0,f.Z); source="FRONT_NAMES"
    elseif r then v=-Vector3.new(r.X,0,r.Z); source="REAR_NAMES" end

    if v and Vector3.new(v.X,0,v.Z).Magnitude>0.05 then
        return Vector3.new(v.X,0,v.Z).Unit,source
    end

    -- Sketchfab fallback: choose the model's long horizontal local axis, direction +Z/+X.
    local _,sz=model:GetBoundingBox()
    if sz.Z>=sz.X then return Vector3.new(0,0,1),source end
    return Vector3.new(1,0,0),source
end

local function alignFrontToOutdoor(model,frontLocal,targetPos)
    local yaw=-math.atan2(frontLocal.X,frontLocal.Z)
    model:PivotTo(CFrame.new(targetPos.X,0,targetPos.Z)*CFrame.Angles(0,yaw,0))
end

local function groundModel(model,targetY)
    local wheelBottoms={}
    local allBottoms={}
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            local b=orientedBottomY(d)
            table.insert(allBottoms,b)
            local n=string.lower(d.Name)
            if string.find(n,"wheel",1,true) or string.find(n,"tire",1,true) or string.find(n,"tyre",1,true) or string.find(n,"rim",1,true) then
                table.insert(wheelBottoms,b)
            end
        end
    end
    local ground=nil
    if #wheelBottoms>=2 then
        table.sort(wheelBottoms)
        local take=math.min(4,#wheelBottoms)
        local sum=0
        for i=1,take do sum+=wheelBottoms[i] end
        ground=sum/take
    elseif #allBottoms>0 then
        table.sort(allBottoms)
        ground=allBottoms[1]
    end
    if not ground then return false end
    model:PivotTo(model:GetPivot()+Vector3.new(0,targetY+0.05-ground,0))
    return true
end

local function makeDanceDeck(name,model)
    local boxCF,boxSize=model:GetBoundingBox()
    local p=Instance.new("Part")
    p.Name=name; p.Anchored=true; p.Transparency=1; p.CanCollide=true; p.CanTouch=false; p.CanQuery=false
    p.Size=Vector3.new(math.max(4.5,boxSize.X*0.58),0.18,math.max(4.5,boxSize.Z*0.58))
    p.CFrame=CFrame.new(boxCF.Position.X,boxCF.Position.Y+boxSize.Y*0.40,boxCF.Position.Z)*(boxCF-boxCF.Position)
    p:SetAttribute("HangarFleetCollision",true); p:SetAttribute("HangarDanceSurface",true); p.Parent=collisionRoot
end

local function normalizeAndPlace(model,spec)
    if spec.kind=="car" then purgeFlatHelperPads(model) end
    local _,size=model:GetBoundingBox()
    local horizontal=math.max(size.X,size.Z)
    if horizontal<=0.01 then error("invalid bounds "..spec.name) end
    local scale=spec.target/horizontal
    if scale<0.001 or scale>500 then error("unsafe scale "..spec.name) end
    model:ScaleTo(model:GetScale()*scale)

    local front,source=headingVector(model,spec.kind)
    alignFrontToOutdoor(model,front,spec.pos)
    model:SetAttribute("HeadingSource",source)
    model:SetAttribute("HeadingPolicy","FACE_OUTDOOR_PLUS_Z")

    if not groundModel(model,spec.pos.Y) then error("ground failed "..spec.name) end
    if spec.kind=="car" then makeDanceDeck(spec.name.."_DanceDeck",model) end
end

local loadedNames={}
local failedNames={}
local jetLoaded=false
local function loadOne(spec)
    local ok,loaded=pcall(InsertService.LoadAsset,InsertService,spec.asset)
    if not ok or not loaded then table.insert(failedNames,spec.name..":LOAD_FAIL"); return false end
    loaded.Name=spec.name; loaded:SetAttribute("RobloxAssetId",spec.asset); loaded:SetAttribute("DisplayOnly",true); loaded:SetAttribute("ShowcaseZone",spec.zone)
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

-- Remove all procedural vehicle fragments from the environment, including their collision.
for _,d in ipairs(environment:GetDescendants()) do
    if d:IsA("BasePart") and not d:IsDescendantOf(replacement) then
        local n=d.Name
        local legacyJet=string.sub(n,1,3)=="Jet"
        local legacyCar=string.sub(n,1,10)=="ClassicCar" or string.sub(n,1,8)=="Hypercar"
        if legacyCar or (jetLoaded and legacyJet) then
            d.Transparency=1; d.CastShadow=false; d.CanCollide=false; d.CanTouch=false; d.CanQuery=false
        end
    end
end

Workspace:SetAttribute("HangarSketchfabVehicles",#failedNames==0 and "READY_OWNER_LAYOUT_V7" or "READY_OWNER_LAYOUT_V7_PARTIAL")
Workspace:SetAttribute("HangarVehicleCountReal",#loadedNames)
Workspace:SetAttribute("HangarVehicleFailures",table.concat(failedNames,"|"))
Workspace:SetAttribute("HangarJetLoadedExactOwnerAsset",jetLoaded)
Workspace:SetAttribute("HangarGhostWallFix","ALL_LEGACY_JET_COLLIDERS_PURGED_ZERO_JET_PROXY")
Workspace:SetAttribute("HangarPatrolWelcome","X_PLUS_MINUS_60_Z170_FACE_OUT")
print("[HANGAR V7] loaded",#loadedNames,"failed",#failedNames,"jetExact",jetLoaded)
