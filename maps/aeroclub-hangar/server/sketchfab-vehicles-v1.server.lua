-- HANGAR — OWNER QC STAGING v3.1
-- Owner lock: only 2 patrol cars in front of donor statues. Oversize Dodge skipped by owner due Roblox 50 MB upload limit.
-- Jet enlarged/repositioned; visible landing-gear wheels added so aircraft does not read as floating.
-- No generated images. No extra car fleet until owner approves this layout.

local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local JET_ASSET_ID = 135410789803386 -- HANGAR_SKETCHFAB_JET_ASSET_ID
local PATROL_MCLAREN_ASSET_ID = 128438812070025 -- HANGAR_PATROL_MCLAREN_ASSET_ID
local PATROL_PORSCHE_ASSET_ID = 0 -- HANGAR_PATROL_PORSCHE_ASSET_ID

local OUTDOOR_SURFACE_Y = 0.30
local INDOOR_SURFACE_Y = 0.40

local placements = {
    {name="PrivateJetSketchfab", asset=JET_ASSET_ID, target=118, pos=Vector3.new(0, INDOOR_SURFACE_Y, -58), yaw=0, kind="jet", zone="JET"},
    {name="Patrol_McLarenF1LM", asset=PATROL_MCLAREN_ASSET_ID, target=18.5, pos=Vector3.new(-38, OUTDOOR_SURFACE_Y, 258), yaw=12, kind="car", zone="DONOR_FRONT"},
    {name="Patrol_PorscheCarreraGT", asset=PATROL_PORSCHE_ASSET_ID, target=18.5, pos=Vector3.new(38, OUTDOOR_SURFACE_Y, 258), yaw=-12, kind="car", zone="DONOR_FRONT"},
}

Workspace:SetAttribute("HangarSketchfabVehicles", "BOOTING_OWNER_QC_STAGING_V31")
Workspace:SetAttribute("HangarSketchfabSource", "OWNER_DRIVE_GLB_STAGING")
Workspace:SetAttribute("HangarVehicleScaleAuthority", "OWNER_QC_V31")
Workspace:SetAttribute("HangarFleetLayout", "PATROL_FRONT_2_ONLY")
Workspace:SetAttribute("HangarFleetRequestedCarCount", 2)
Workspace:SetAttribute("HangarJetTargetStuds", 118)
Workspace:SetAttribute("HangarFurniturePolicy", "NO_TABLE_SOFA_CHAIR")
Workspace:SetAttribute("HangarOversizeDodge", "SKIPPED_OWNER_APPROVED_50MB_LIMIT")

local deadline = os.clock() + 35
while os.clock() < deadline and Workspace:GetAttribute("HangarEnvironmentReady") ~= true do task.wait(0.25) end

local environment = Workspace:FindFirstChild("Environment")
if not environment or Workspace:GetAttribute("HangarEnvironmentReady") ~= true then
    Workspace:SetAttribute("HangarSketchfabVehicles", "ENVIRONMENT_NOT_READY")
    return
end

for _, d in ipairs(environment:GetDescendants()) do
    local n = string.lower(d.Name)
    local remove = string.find(n,"sofa",1,true) or string.find(n,"couch",1,true) or string.find(n,"chair",1,true)
        or string.find(n,"coffee_table",1,true) or string.find(n,"coffee table",1,true)
        or string.find(n,"lounge_table",1,true) or string.find(n,"lounge table",1,true)
    if remove and (d:IsA("Model") or d:IsA("BasePart")) then d:Destroy() end
end

for _, oldName in ipairs({"SketchfabVehicleDisplayV1","HangarShowcaseFleetV2","HangarOwnerQCStagingV3","HangarOwnerQCStagingV31"}) do
    local old = environment:FindFirstChild(oldName)
    if old then old:Destroy() end
end

local replacement = Instance.new("Model")
replacement.Name = "HangarOwnerQCStagingV31"
replacement:SetAttribute("DisplayOnly", true)
replacement:SetAttribute("Source", "OWNER_DRIVE_GLB_STAGING")
replacement.Parent = environment

local collisionRoot = environment:FindFirstChild("Collision")
if not collisionRoot then
    collisionRoot = Instance.new("Folder")
    collisionRoot.Name = "Collision"
    collisionRoot.Parent = environment
end
for _, child in ipairs(collisionRoot:GetChildren()) do
    if child:GetAttribute("HangarFleetCollision") == true or child:GetAttribute("HangarDanceSurface") == true or string.find(child.Name,"_DisplayCollision",1,true) then child:Destroy() end
end
for _, name in ipairs({"ClassicCarLeftAProxy","ClassicCarLeftBProxy","HypercarRightAProxy","HypercarRightBProxy","SketchfabJetBodyProxy"}) do
    local old = collisionRoot:FindFirstChild(name)
    if old then old:Destroy() end
end

local function sanitize(model)
    local parts = 0
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Sound") then d:Destroy()
        elseif d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then d:Destroy()
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then d.Enabled=false
        elseif d:IsA("BasePart") then
            parts += 1
            d.Anchored=true; d.CanCollide=false; d.CanTouch=false; d.CanQuery=true; d.Massless=true; d.CastShadow=true
        end
    end
    return parts
end

local function blocker(name, cf, size, dance)
    local p=Instance.new("Part")
    p.Name=name; p.Anchored=true; p.Transparency=1; p.CanCollide=true; p.CanTouch=false; p.CanQuery=false; p.Size=size; p.CFrame=cf
    p:SetAttribute("HangarFleetCollision",true)
    if dance then p:SetAttribute("HangarDanceSurface",true) end
    p.Parent=collisionRoot
    return p
end

local function wheel(parent,name,pos,lateral,diameter,width)
    local tire=Instance.new("Part")
    tire.Name=name.."_Tire"; tire.Shape=Enum.PartType.Cylinder; tire.Material=Enum.Material.Rubber; tire.Color=Color3.fromRGB(18,18,18)
    tire.Anchored=true; tire.CanCollide=false; tire.CanTouch=false; tire.CanQuery=true; tire.Size=Vector3.new(width,diameter,diameter)
    tire.CFrame=CFrame.fromMatrix(pos,lateral.Unit,Vector3.yAxis); tire.Parent=parent
    local rim=Instance.new("Part")
    rim.Name=name.."_Rim"; rim.Shape=Enum.PartType.Cylinder; rim.Material=Enum.Material.Metal; rim.Color=Color3.fromRGB(120,125,132)
    rim.Anchored=true; rim.CanCollide=false; rim.CanTouch=false; rim.CanQuery=true; rim.Size=Vector3.new(width+0.05,diameter*0.48,diameter*0.48); rim.CFrame=tire.CFrame; rim.Parent=parent
end

local function addJetGear(boxCF,boxSize)
    local gear=Instance.new("Model"); gear.Name="JetLandingGearWheelFill"; gear:SetAttribute("OwnerRequestedWheelFill",true); gear.Parent=replacement
    local longX=boxSize.X>=boxSize.Z
    local long=math.max(boxSize.X,boxSize.Z); local short=math.min(boxSize.X,boxSize.Z)
    local forward=longX and boxCF.RightVector or boxCF.LookVector; local lateral=longX and boxCF.LookVector or boxCF.RightVector
    local center=Vector3.new(boxCF.Position.X,INDOOR_SURFACE_Y+1.15,boxCF.Position.Z)
    local nose=center+forward*(long*0.31); local main=center-forward*(long*0.10); local spread=math.max(5.5,short*0.15)
    wheel(gear,"NoseL",nose-lateral*0.62,lateral,1.8,0.56); wheel(gear,"NoseR",nose+lateral*0.62,lateral,1.8,0.56)
    wheel(gear,"MainL",main-lateral*spread,lateral,2.3,0.75); wheel(gear,"MainR",main+lateral*spread,lateral,2.3,0.75)
end

local function place(model,spec)
    local _,size=model:GetBoundingBox(); local horizontal=math.max(size.X,size.Z)
    if horizontal<=0.01 then error("invalid bounds "..spec.name) end
    model:ScaleTo(model:GetScale()*(spec.target/horizontal))
    model:PivotTo(CFrame.new(spec.pos.X,0,spec.pos.Z)*CFrame.Angles(0,math.rad(spec.yaw),0))
    local boxCF,boxSize=model:GetBoundingBox(); local bottomY=boxCF.Position.Y-boxSize.Y*0.5; local clearance=spec.kind=="jet" and 2.15 or 0
    model:PivotTo(model:GetPivot()+Vector3.new(0,spec.pos.Y+clearance-bottomY,0))
    boxCF,boxSize=model:GetBoundingBox(); local rot=boxCF-boxCF.Position
    if spec.kind=="car" then
        local bodyH=math.max(2.1,boxSize.Y*0.50)
        blocker(spec.name.."_DisplayCollision",CFrame.new(boxCF.Position.X,spec.pos.Y+bodyH*0.5,boxCF.Position.Z)*rot,Vector3.new(math.max(4,boxSize.X*0.84),bodyH,math.max(4,boxSize.Z*0.84)),false)
        blocker(spec.name.."_DanceDeck",CFrame.new(boxCF.Position.X,boxCF.Position.Y+boxSize.Y*0.44,boxCF.Position.Z)*rot,Vector3.new(math.max(4,boxSize.X*0.72),0.45,math.max(4,boxSize.Z*0.72)),true)
    else
        local long=math.max(boxSize.X,boxSize.Z); local xLong=boxSize.X>=boxSize.Z
        local fw=long*0.72; local sw=math.max(8,math.min(boxSize.X,boxSize.Z)*0.18)
        local bs=xLong and Vector3.new(fw,math.max(7,boxSize.Y*0.46),sw) or Vector3.new(sw,math.max(7,boxSize.Y*0.46),fw)
        blocker("SketchfabJetBodyProxy",CFrame.new(boxCF.Position.X,INDOOR_SURFACE_Y+2.15+bs.Y*0.5,boxCF.Position.Z)*rot,bs,false)
        addJetGear(boxCF,boxSize)
    end
end

local function loadOne(spec)
    if spec.asset<=0 then error("asset id missing "..spec.name) end
    local ok,loaded=pcall(InsertService.LoadAsset,InsertService,spec.asset)
    if not ok or not loaded then error("LoadAsset failed "..spec.name) end
    loaded.Name=spec.name; loaded:SetAttribute("RobloxAssetId",spec.asset); loaded:SetAttribute("DisplayOnly",true); loaded:SetAttribute("ShowcaseZone",spec.zone)
    if sanitize(loaded)<1 then loaded:Destroy(); error("no renderable parts "..spec.name) end
    loaded.Parent=replacement; place(loaded,spec)
end

local ok,err=pcall(function() for _,spec in ipairs(placements) do loadOne(spec) end end)
if not ok then
    replacement:Destroy()
    for _,child in ipairs(collisionRoot:GetChildren()) do if child:GetAttribute("HangarFleetCollision")==true then child:Destroy() end end
    Workspace:SetAttribute("HangarSketchfabVehicles","OWNER_QC_STAGING_LOAD_FAILED")
    warn("[HANGAR STAGING] load failed",err)
    return
end

local hideNames={JetPlaneMesh=true,JetGlassAndTrimMesh=true,JetEngineMesh=true,JetLandingGearMesh=true,JetVIPLoungeMesh=true,ClassicCarLeftA=true,ClassicCarLeftB=true,HypercarRightA=true,HypercarRightB=true}
for _,d in ipairs(environment:GetDescendants()) do
    if d:IsA("MeshPart") and hideNames[d.Name] and not d:IsDescendantOf(replacement) then d.Transparency=1; d.CastShadow=false; d.CanCollide=false; d.CanQuery=false end
end

Workspace:SetAttribute("HangarSketchfabVehicles","READY_OWNER_QC_STAGING_V31")
Workspace:SetAttribute("HangarProceduralVehicles","HIDDEN_OWNER_STAGING_SWAP")
Workspace:SetAttribute("HangarVehicleArt","OWNER_DRIVE_2_PATROL_PLUS_JET_V31")
Workspace:SetAttribute("HangarVehicleCountReal",3)
Workspace:SetAttribute("HangarDanceOnCars",true)
print("[HANGAR STAGING] BIG JET + 2 PATROL FRONT READY",JET_ASSET_ID)
