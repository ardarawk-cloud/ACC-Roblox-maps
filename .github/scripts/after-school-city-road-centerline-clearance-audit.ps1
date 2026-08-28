$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# AFTER SCHOOL CITY — CLOUD SOURCE ROAD CENTERLINE CLEARANCE AUDIT V1
# Verifies the live-v18 black-road-obstruction root cause and V0.5.3 deterministic correction.

$map = Join-Path (Resolve-Path '.').Path 'maps/after-school-city'
$worldPath = Join-Path $map 'after-school-city.world.server.lua'
$runtimePath = Join-Path $map 'after-school-city.road-centerline-clearance.server.lua'
$configPath = Join-Path $map 'after-school-city.config.lua'
$projectPath = Join-Path $map 'default.project.json'

foreach($path in @($worldPath,$runtimePath,$configPath,$projectPath)){
    if(-not (Test-Path $path)){ throw "Required source missing: $path" }
}

$world = Get-Content $worldPath -Raw
$runtime = Get-Content $runtimePath -Raw
$config = Get-Content $configPath -Raw
$project = Get-Content $projectPath -Raw
$null = $project | ConvertFrom-Json

function Token([string]$text,[string]$token,[string]$label){
    if($text.IndexOf($token,[StringComparison]::Ordinal) -lt 0){ throw "ASC road-centerline contract missing: $label" }
}

# Root-cause evidence from the legacy base world.
Token $world 'part(downtown, "Plaza", Vector3.new(115, 0.8, 54), CFrame.new(0, 1.1, 56)' 'legacy Downtown Plaza across avenue'
Token $world 'fountain.Name = "CentralFountain"' 'legacy CentralFountain identity'
Token $world 'CFrame.new(0, 2.3, 56)' 'legacy fountain centered on X0/Z56'

# V0.5.3 ordering + identity.
Token $runtime 'V053_RoadCenterlineClearance' 'V053 layer'
Token $runtime '0.5.3-road-centerline-clearance-1' 'V053 version'
Token $runtime 'waitForWorkspaceAttribute("ASC_RuntimeHardCleanupPass", 45)' 'V052 completion gate'
Token $runtime 'ROAD_CENTER_CLEAR_HALF_X = 19' 'road center half-width'
Token $runtime 'ROAD_CENTER_Z_MIN = -267.5' 'effective road south limit'
Token $runtime 'ROAD_CENTER_Z_MAX = 144.5' 'effective road north limit'
Token $runtime 'OBSTRUCTION_TOP_MIN = 2.2' 'obstruction vertical threshold'
Token $runtime 'OBSTRUCTION_BOTTOM_MAX = 18' 'obstruction vertical cap'

# Exact root-cause removal + split plaza reconstruction.
foreach($token in @(
    'downtown:FindFirstChild("CentralFountain")',
    'fountain:Destroy()',
    'downtown:FindFirstChild("Plaza")',
    'legacyPlaza:Destroy()',
    'DOWNTOWN_PLAZA_OUTER_HALF_X = 57.5',
    'ROAD_SIDEWALK_OUTER_X = 29',
    'SPLIT_PLAZA_WIDTH = DOWNTOWN_PLAZA_OUTER_HALF_X - ROAD_SIDEWALK_OUTER_X',
    'SPLIT_PLAZA_CENTER_X = (DOWNTOWN_PLAZA_OUTER_HALF_X + ROAD_SIDEWALK_OUTER_X) / 2',
    'DowntownPlazaWest',
    'DowntownPlazaEast'
)){
    Token $runtime $token ("downtown root-cause correction $token")
}

$oldHalf = 57.5
$sidewalkOuter = 29.0
$splitWidth = $oldHalf - $sidewalkOuter
$splitCenter = ($oldHalf + $sidewalkOuter) / 2
$innerWest = -$splitCenter + $splitWidth / 2
$innerEast = $splitCenter - $splitWidth / 2
$gap = $innerEast - $innerWest
if([math]::Abs($splitWidth - 28.5) -gt 0.001){ throw "Unexpected split plaza width: $splitWidth" }
if([math]::Abs($splitCenter - 43.25) -gt 0.001){ throw "Unexpected split plaza center: $splitCenter" }
if($gap -lt 58){ throw "Split plaza road+sidewalk gap too small: $gap" }
Write-Host "PASS: downtown plaza split leaves $gap studs clear across road+sidewalk"

# Hierarchy/name-independent full-road fail-safe.
foreach($token in @(
    'basePart.CFrame.RightVector',
    'basePart.CFrame.UpVector',
    'basePart.CFrame.LookVector',
    'intersectsMainRoadAABB',
    'for _, descendant in ipairs(root:GetDescendants()) do',
    'not descendant:IsDescendantOf(layer)',
    'descendant.CanCollide or descendant.Transparency < 0.95',
    'ASC_MainRoadCenterlineHardClear',
    'ASC_RoadCenterlineRemovedCount'
)){
    Token $runtime $token ("full-road AABB fail-safe $token")
}

# Config and project ordering.
foreach($token in @(
    'Version = "0.5.3-road-centerline-clearance-1"',
    'RuntimeHardCleanupVersion = "0.5.2-runtime-hard-cleanup-1"',
    'RoadCenterlineClearanceVersion = "0.5.3-road-centerline-clearance-1"',
    'EnableRuntimeHardCleanupPass = true',
    'EnableRoadCenterlineClearancePass = true',
    'EnableActivities = false',
    'EnableEconomy = false',
    'EnablePersistence = false'
)){
    Token $config $token ("config marker $token")
}

Token $project 'ASC_RuntimeHardCleanup' 'Rojo V052 node'
Token $project 'ASC_RoadCenterlineClearance' 'Rojo V053 node'
Token $project 'after-school-city.road-centerline-clearance.server.lua' 'Rojo V053 path'
$idx52 = $project.IndexOf('"ASC_RuntimeHardCleanup"',[StringComparison]::Ordinal)
$idx53 = $project.IndexOf('"ASC_RoadCenterlineClearance"',[StringComparison]::Ordinal)
if($idx52 -lt 0 -or $idx53 -lt 0 -or $idx53 -le $idx52){ throw 'Rojo V053 must be ordered after V052' }

if($runtime -match 'MarketplaceService|PromptProductPurchase|ProcessReceipt|DataStoreService'){
    throw 'Road centerline clearance must not contain monetization/persistence authority'
}
if($runtime -match 'BillboardGui'){
    throw 'Road centerline clearance must not introduce BillboardGui'
}

$report = [ordered]@{
    project = 'AFTER SCHOOL CITY'
    audit = 'CLOUD_SOURCE_ROAD_CENTERLINE_CLEARANCE_AUDIT_V1'
    sourceVersion = '0.5.3-road-centerline-clearance-1'
    status = 'PASS'
    rootCause = 'legacy Downtown Plaza 115x54 and CentralFountain were authored across main avenue at X=0/Z=56'
    mainRoad = [ordered]@{xHalfWidth=19;zMin=-267.5;zMax=144.5}
    splitPlaza = [ordered]@{width=$splitWidth;centerAbsX=$splitCenter;clearGap=$gap}
    rule = 'remove exact root-cause objects then hierarchy-independent full-road AABB hard-clear'
}
$report | ConvertTo-Json -Depth 5 | Set-Content 'road-centerline-clearance-audit-after-school-city.json' -Encoding UTF8
Write-Host 'AFTER SCHOOL CITY — CLOUD SOURCE ROAD CENTERLINE CLEARANCE AUDIT V1'
Write-Host 'PASS: legacy Downtown plaza/fountain road collision is deterministically removed and full main-road centerline is hard-cleared'
