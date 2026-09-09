-- HANGAR — OWNER VEHICLE LAYOUT v4.0
-- Exact owner direction: keep the same jet art, rotate it to face the hangar opening, enlarge it, and add visible landing-gear wheels.
-- Only 2 patrol cars are allowed in front of the donor statues.
-- All other approved GLB cars are arranged inside/under/around the jet as the club furniture; no tables/sofas/chairs.
-- Oversize Dodge Charger FF8 72 MB is intentionally excluded because Roblox Asset API rejects >50 MB request bodies.
-- No generated images.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local JET_ASSET_ID = 135410789803386 -- HANGAR_JET_ASSET_ID
local PATROL_MCLAREN_ASSET_ID = 128438812070025 -- HANGAR_PATROL_MCLAREN_ASSET_ID
local PATROL_PORSCHE_ASSET_ID = 108398505977253 -- HANGAR_PATROL_PORSCHE_ASSET_ID

local CAR01_ASSET_ID = 99964942308635 -- HANGAR_CAR01_NISSAN_R34_BRIAN
local CAR02_ASSET_ID = 108661587054557 -- HANGAR_CAR02_DODGE_CHARGER_1970
local CAR03_ASSET_ID = 131735423260822 -- HANGAR_CAR03_TOYOTA_SUPRA_MK4
local CAR04_ASSET_ID = 101563967954162 -- HANGAR_CAR04_LAMBORGHINI_MURCIELAGO
local CAR05_ASSET_ID = 78379824687949 -- HANGAR_CAR05_MITSUBISHI_ECLIPSE_1995
local CAR06_ASSET_ID = 121928928437649 -- HANGAR_CAR06_HONDA_S2000
local CAR07_ASSET_ID = 96591438161153 -- HANGAR_CAR07_ECLIPSE_SPYDER
local CAR08_ASSET_ID = 89838081528043 -- HANGAR_CAR08_SUBARU_BRZ
local CAR09_ASSET_ID = 126546467150154 -- HANGAR_CAR09_NISSAN_SKYLINE_CWEST
local CAR10_ASSET_ID = 101888640433519 -- HANGAR_CAR10_CHEVY_CAMARO
local CAR11_ASSET_ID = 90377117635780 -- HANGAR_CAR11_DELOREAN

local FLOOR_Y = 0.40
local DONOR_Y = 0.30

local placements = {
    {name="PrivateJetSketchfab", asset=JET_ASSET_ID, target=118, pos=Vector3.new(0, FLOOR_Y, -58), yaw=-90, kind="jet", zone="JET"},
    {name="Patrol_McLarenF1LM", asset=PATROL_MCLAREN_ASSET_ID, target=18.5, pos=Vector3.new(-38, DONOR_Y, 258), yaw=12, kind="car", zone="DONOR_FRONT"},
    {name="Patrol_PorscheCarreraGT", asset=PATROL_PORSCHE_ASSET_ID, target=18.5, pos=Vector3.new(38, DONOR_Y, 258), yaw=-12, kind="car", zone="DONOR_FRONT"},
    {name="NissanR34Brian", asset=CAR01_ASSET_ID, target=18.5, pos=Vector3.new(-62, FLOOR_Y, -5), yaw=-8, kind="car", zone="JET_FLOOR"},
    {name="DodgeChargerRT1970", asset=CAR02_ASSET_ID, target=19.0, pos=Vector3.new(62, FLOOR_Y, -5), yaw=8, kind="car", zone="JET_FLOOR"},
    {name="ToyotaSupraMK4", asset=CAR03_ASSET_ID, target=18.5, pos=Vector3.new(-62, FLOOR_Y, -35), yaw=-4, kind="car", zone="JET_FLOOR"},
    {name="LamborghiniMurcielago", asset=CAR04_ASSET_ID, target=18.5, pos=Vector3.new(62, FLOOR_Y, -35), yaw=4, kind="car", zone="JET_FLOOR"},
    {name="MitsubishiEclipse1995", asset=CAR05_ASSET_ID, target=18.0, pos=Vector3.new(-62, FLOOR_Y, -65), yaw=0, kind="car", zone="UNDER_WING"},
    {name="HondaS2000", asset=CAR06_ASSET_ID, target=18.0, pos=Vector3.new(62, FLOOR_Y, -65), yaw=0, kind="car", zone="UNDER_WING"},
    {name="MitsubishiEclipseSpyder", asset=CAR07_ASSET_ID, target=18.0, pos=Vector3.new(-62, FLOOR_Y, -95), yaw=4, kind="car", zone="JET_FLOOR"},
    {name="SubaruBRZRocketBunny", asset=CAR08_ASSET_ID, target=18.0, pos=Vector3.new(62, FLOOR_Y, -95), yaw=-4, kind="car", zone="JET_FLOOR"},
    {name="NissanSkylineR34CWest", asset=CAR09_ASSET_ID, target=18.5, pos=Vector3.new(-36, FLOOR_Y, -132), yaw=8, kind="car", zone="JET_REAR"},
    {name="ChevyCamaroSS", asset=CAR10_ASSET_ID, target=19.0, pos=Vector3.new(0, FLOOR_Y, -138), yaw=0, kind="car", zone="JET_REAR"},
    {name="DeLoreanDMC12", asset=CAR11_ASSET_ID, target=18.5, pos=Vector3.new(36, FLOOR_Y, -132), yaw=-8, kind="car", zone="JET_REAR"},
}

Workspace:SetAttribute("HangarSketchfabVehicles", "BOOTING_OWNER_LAYOUT_V4")
Workspace:SetAttribute("HangarFleetLayout", "FULL_FLEET_2_PATROL_FRONT_11_JET_FLOOR")
Workspace:SetAttribute("HangarJetOrientation", "NOSE_TO_OUTDOOR_PLUS_Z")
Workspace:SetAttribute("HangarJetTargetStuds", 118)
Workspace:SetAttribute("HangarFurniturePolicy", "NO_TABLE_SOFA_CHAIR")
Workspace:SetAttribute("HangarDanceOnCars", true)
Workspace:SetAttribute("HangarOversizeDodgeFF8", "SKIPPED_OWNER_APPROVED_API_50MB_LIMIT")
Workspace:SetAttribute("HangarRequestedCarCount", 13)

local deadline = os.clock() + 35
while os.clock() < deadline and Workspace:GetAttribute("HangarEnvironmentReady") ~= true do task.wait(0.25) end
local environment = Workspace:FindFirstChild("Environment")
if not environment or Workspace:GetAttribute("HangarEnvironmentReady") ~= true then Workspace:SetAttribute("HangarSketchfabVehicles", "ENVIRONMENT_NOT_READY"); return end

for _, d in ipairs(environment:GetDescendants()) do
    local n = string.lower(d.Name)
    local remove = string.find(n,"sofa",1,true) or string.find(n,"couch",1,true) or string.find(n,"chair",1,true) or string.find(n,"coffee_table",1,true) or string.find(n,"coffee table",1,true) or string.find(n,"lounge_table",1,true) or string.find(n,"lounge table",1,true)
    if remove and (d:IsA("Model") or d:IsA("BasePart")) then d:Destroy() end
end

for _, oldName in ipairs({"SketchfabVehicleDisplayV1","HangarShowcaseFleetV2","HangarOwnerQCStagingV3","HangarOwnerQCStagingV31","HangarOwnerFleetV4"}) do local old=environment:FindFirstChild(oldName); if old then old:Destroy() end end
local replacement=Instance.new("Model"); replacement.Name="HangarOwnerFleetV4"; replacement:SetAttribute("DisplayOnly",true); replacement:SetAttribute("Source","OWNER_DRIVE_GLB"); replacement.Parent=environment

local collisionRoot=environment:FindFirstChild("Collision"); if not collisionRoot then collisionRoot=Instance.new("Folder"); collisionRoot.Name="Collision"; collisionRoot.Parent=environment end
for _,child in ipairs(collisionRoot:GetChildren()) do if child:GetAttribute("HangarFleetCollision")==true or child:GetAttribute("HangarDanceSurface")==true or string.find(child.Name,"_DisplayCollision",1,true) then child:Destroy() end end
for _,name in ipairs({"ClassicCarLeftAProxy","ClassicCarLeftBProxy","HypercarRightAProxy","HypercarRightBProxy","SketchfabJetBodyProxy"}) do local old=collisionRoot:FindFirstChild(name); if old then old:Destroy() end end

local function sanitize(model)
    local parts=0
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Sound") then d:Destroy()
        elseif d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then d:Destroy()
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then d.Enabled=false
        elseif d:IsA("BasePart") then parts+=1; d.Anchored=true; d.CanCollide=false; d.CanTouch=false; d.CanQuery=true; d.Massless=true; d.CastShadow=true end
    end
    return parts
end

local function makeInvisibleCollision(name,cf,size,danceSurface)
    local p=Instance.new("Part"); p.Name=name; p.Anchored=true; p.Transparency=1; p.CanCollide=true; p.CanTouch=false; p.CanQuery=false; p.Size=size; p.CFrame=cf; p:SetAttribute("HangarFleetCollision",true); if danceSurface then p:SetAttribute("HangarDanceSurface",true) end; p.Parent=collisionRoot
end

local function makeWheel(parent,name,position,lateral,diameter,width)
    local tire=Instance.new("Part"); tire.Name=name.."_Tire"; tire.Shape=Enum.PartType.Cylinder; tire.Material=Enum.Material.Rubber; tire.Color=Color3.fromRGB(18,18,18); tire.Anchored=true; tire.CanCollide=false; tire.CanTouch=false; tire.CanQuery=true; tire.Size=Vector3.new(width,diameter,diameter); tire.CFrame=CFrame.fromMatrix(position,lateral.Unit,Vector3.yAxis); tire.Parent=parent
    local rim=Instance.new("Part"); rim.Name=name.."_Rim"; rim.Shape=Enum.PartType.Cylinder; rim.Material=Enum.Material.Metal; rim.Color=Color3.fromRGB(120,125,132); rim.Anchored=true; rim.CanCollide=false; rim.CanTouch=false; rim.CanQuery=true; rim.Size=Vector3.new(width+0.05,diameter*0.48,diameter*0.48); rim.CFrame=tire.CFrame; rim.Parent=parent
end

local function addJetLandingGearVisual(boxCF,boxSize)
    local gear=Instance.new("Model"); gear.Name="JetLandingGearWheelFill"; gear:SetAttribute("OwnerRequestedWheelFill",true); gear.Parent=replacement
    local longX=boxSize.X>=boxSize.Z; local long=math.max(boxSize.X,boxSize.Z); local short=math.min(boxSize.X,boxSize.Z); local forward=longX and boxCF.RightVector or boxCF.LookVector; local lateral=longX and boxCF.LookVector or boxCF.RightVector
    local center=Vector3.new(boxCF.Position.X,FLOOR_Y+1.15,boxCF.Position.Z); local wheelDiameter=2.3; local wheelWidth=0.75; local nose=center+forward*(long*0.31); local main=center-forward*(long*0.10); local spread=math.max(5.5,short*0.15)
    makeWheel(gear,"NoseL",nose-lateral*0.62,lateral,wheelDiameter*0.78,wheelWidth*0.75); makeWheel(gear,"NoseR",nose+lateral*0.62,lateral,wheelDiameter*0.78,wheelWidth*0.75); makeWheel(gear,"MainL",main-lateral*spread,lateral,wheelDiameter,wheelWidth); makeWheel(gear,"MainR",main+lateral*spread,lateral,wheelDiameter,wheelWidth)
end

local function normalizeAndPlace(model,spec)
    local _,size=model:GetBoundingBox(); local horizontal=math.max(size.X,size.Z); if horizontal<=0.01 then error("invalid bounds "..spec.name) end; local scale=spec.target/horizontal; if scale<0.001 or scale>500 then error("unsafe scale "..spec.name) end
    model:ScaleTo(model:GetScale()*scale); model:PivotTo(CFrame.new(spec.pos.X,0,spec.pos.Z)*CFrame.Angles(0,math.rad(spec.yaw),0))
    local boxCF,boxSize=model:GetBoundingBox(); local bottomY=boxCF.Position.Y-boxSize.Y*0.5; local clearance=spec.kind=="jet" and 2.15 or 0; model:PivotTo(model:GetPivot()+Vector3.new(0,spec.pos.Y+clearance-bottomY,0)); boxCF,boxSize=model:GetBoundingBox(); local rotationOnly=boxCF-boxCF.Position
    if spec.kind=="car" then
        local bodyH=math.max(2.1,boxSize.Y*0.50); local bodySize=Vector3.new(math.max(4,boxSize.X*0.84),bodyH,math.max(4,boxSize.Z*0.84)); makeInvisibleCollision(spec.name.."_DisplayCollision",CFrame.new(boxCF.Position.X,spec.pos.Y+bodyH*0.5,boxCF.Position.Z)*rotationOnly,bodySize,false)
        local deckSize=Vector3.new(math.max(4,boxSize.X*0.72),0.45,math.max(4,boxSize.Z*0.72)); local deckY=boxCF.Position.Y+boxSize.Y*0.44; makeInvisibleCollision(spec.name.."_DanceDeck",CFrame.new(boxCF.Position.X,deckY,boxCF.Position.Z)*rotationOnly,deckSize,true)
    else
        local long=math.max(boxSize.X,boxSize.Z); local xLong=boxSize.X>=boxSize.Z; local fuselageLength=long*0.72; local fuselageWidth=math.max(8,math.min(boxSize.X,boxSize.Z)*0.18); local bs=xLong and Vector3.new(fuselageLength,math.max(7,boxSize.Y*0.46),fuselageWidth) or Vector3.new(fuselageWidth,math.max(7,boxSize.Y*0.46),fuselageLength); makeInvisibleCollision("SketchfabJetBodyProxy",CFrame.new(boxCF.Position.X,FLOOR_Y+2.15+bs.Y*0.5,boxCF.Position.Z)*rotationOnly,bs,false); addJetLandingGearVisual(boxCF,boxSize)
    end
end

local loadedNames={}; local failedNames={}; local jetLoaded=false
local function loadOne(spec)
    if spec.asset<=0 then table.insert(failedNames,spec.name..":MISSING_ASSET"); return false end
    local ok,loaded=pcall(InsertService.LoadAsset,InsertService,spec.asset); if not ok or not loaded then table.insert(failedNames,spec.name..":LOAD_FAIL"); return false end
    loaded.Name=spec.name; loaded:SetAttribute("RobloxAssetId",spec.asset); loaded:SetAttribute("DisplayOnly",true); loaded:SetAttribute("ShowcaseZone",spec.zone or "JET"); local partCount=sanitize(loaded); if partCount<1 then loaded:Destroy(); table.insert(failedNames,spec.name..":NO_PARTS"); return false end
    loaded.Parent=replacement; local placed,placeErr=pcall(normalizeAndPlace,loaded,spec); if not placed then loaded:Destroy(); table.insert(failedNames,spec.name..":PLACE_FAIL"); warn(placeErr); return false end; table.insert(loadedNames,spec.name); if spec.kind=="jet" then jetLoaded=true end; return true
end

for _,spec in ipairs(placements) do loadOne(spec) end

local hideCars={ClassicCarLeftA=true,ClassicCarLeftB=true,HypercarRightA=true,HypercarRightB=true}
for _,d in ipairs(environment:GetDescendants()) do if d:IsA("MeshPart") and hideCars[d.Name] and not d:IsDescendantOf(replacement) then d.Transparency=1; d.CastShadow=false; d.CanCollide=false; d.CanQuery=false end end
if jetLoaded then
    local hideJet={JetPlaneMesh=true,JetGlassAndTrimMesh=true,JetEngineMesh=true,JetLandingGearMesh=true,JetVIPLoungeMesh=true}
    for _,d in ipairs(environment:GetDescendants()) do if d:IsA("MeshPart") and hideJet[d.Name] and not d:IsDescendantOf(replacement) then d.Transparency=1; d.CastShadow=false; d.CanCollide=false; d.CanQuery=false end end
end

Workspace:SetAttribute("HangarSketchfabVehicles", #failedNames==0 and "READY_OWNER_LAYOUT_V4" or "READY_OWNER_LAYOUT_V4_PARTIAL")
Workspace:SetAttribute("HangarVehicleCountReal", #loadedNames)
Workspace:SetAttribute("HangarVehicleFailures", table.concat(failedNames,"|"))
Workspace:SetAttribute("HangarJetLoadedExactOwnerAsset", jetLoaded)
print("[HANGAR V4] loaded",#loadedNames,"failed",#failedNames,"jetExact",jetLoaded)
