$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# AFTER SCHOOL CITY — CLOUD SOURCE RUNTIME HARD CLEANUP AUDIT V1
# Regression check for the V0.5.2 component inside the current map version.

$map = Join-Path (Resolve-Path '.').Path 'maps/after-school-city'
$runtimePath = Join-Path $map 'after-school-city.runtime-hard-cleanup.server.lua'
$configPath = Join-Path $map 'after-school-city.config.lua'
$projectPath = Join-Path $map 'default.project.json'
if(-not (Test-Path $runtimePath)){ throw 'Runtime hard cleanup source missing' }
$runtime = Get-Content $runtimePath -Raw
$config = Get-Content $configPath -Raw
$project = Get-Content $projectPath -Raw
$null = $project | ConvertFrom-Json

function Token([string]$text,[string]$token,[string]$label){
    if($text.IndexOf($token,[StringComparison]::Ordinal) -lt 0){ throw "ASC runtime hard cleanup contract missing: $label" }
}

Token $runtime 'V052_RuntimeHardCleanup' 'runtime hard cleanup layer'
Token $runtime '0.5.2-runtime-hard-cleanup-1' 'runtime hard cleanup version'
Token $runtime 'waitForWorkspaceAttribute("ASC_RuntimeReconcilePass", 45)' 'v0.5.1 completion gate'
Token $runtime 'for _, descendant in ipairs(root:GetDescendants()) do' 'global recursive scan'

foreach($token in @('VendingMachine','VendingGlow','SkateSign')){
    Token $runtime $token ("global prototype purge $token")
}

foreach($token in @(
    'SCHOOL_AXIS_HARD_X = 12',
    'SCHOOL_AXIS_HARD_Z_MIN = 149',
    'SCHOOL_AXIS_HARD_Z_MAX = 169',
    'SCHOOL_AXIS_OBSTRUCTION_TOP_MIN = 2.2',
    'SCHOOL_AXIS_OBSTRUCTION_BOTTOM_MAX = 8',
    'namedBlocker',
    'descendant.CanCollide'
)){
    Token $runtime $token ("school arrival hard-clear $token")
}

foreach($token in @(
    'MINI_MART_EAST',
    'xMin = -163, xMax = -144, zMin = 96, zMax = 121',
    'STUDY_LOUNGE_EAST',
    'xMin = -163, xMax = -144, zMin = 148, zMax = 184',
    'CITY_LIBRARY_WEST',
    'xMin = 144, xMax = 163, zMin = 97, zMax = 127',
    'treeLike(descendant)'
)){
    Token $runtime $token ("student row envelope $token")
}

foreach($token in @(
    'SHOP_INTERIOR_WIDTH = 22',
    'SHOP_PROP_X_LIMIT = 8.5',
    'obj.Size.X > SHOP_INTERIOR_WIDTH',
    'downtown:FindFirstChild("Shop_" .. shopName)',
    'for _, shopName in ipairs({"ARCADE", "CAFE", "STYLE", "MUSIC", "HOBBY"}) do'
)){
    Token $runtime $token ("downtown hard clamp $token")
}

foreach($token in @(
    'collectDistinctTextPlates("AFTER SCHOOL SKATE")',
    'SKATE_SIGN_WIDTH = 26',
    'SKATE_SIGN_HEIGHT = 3.6',
    'collectDistinctTextPlates("DOWNTOWN  ↓")',
    'DOWNTOWN_SIGN_WIDTH = 10',
    'DOWNTOWN_SIGN_HEIGHT = 2.6',
    'DOWNTOWN_SIGN_X = 40',
    'DOWNTOWN_SIGN_Z = 160'
)){
    Token $runtime $token ("sign dedupe $token")
}

foreach($token in @(
    'EXTERIOR_LIGHT_BRIGHTNESS_MAX = 0.38',
    'EXTERIOR_LIGHT_RANGE_MAX = 14',
    'ASC_SchoolAxisGroundObstructionsPurged',
    'ASC_StudentRowEntranceEnvelopesClear',
    'ASC_DowntownInteriorHardClamped',
    'ASC_SkateSignDeduplicated',
    'ASC_DowntownWayfindingDeduplicated',
    'ASC_RuntimeHardCleanupPass'
)){
    Token $runtime $token ("final hard cleanup marker $token")
}

Token $config 'RuntimeHardCleanupVersion = "0.5.2-runtime-hard-cleanup-1"' 'config hard cleanup component version'
Token $config 'EnableRuntimeHardCleanupPass = true' 'config hard cleanup flag'
Token $project 'ASC_RuntimeHardCleanup' 'Rojo hard cleanup node'
Token $project 'after-school-city.runtime-hard-cleanup.server.lua' 'Rojo hard cleanup path'

if($runtime -match 'MarketplaceService|PromptProductPurchase|ProcessReceipt|DataStoreService'){
    throw 'Runtime hard cleanup must not contain monetization/persistence authority'
}
if($runtime -match 'BillboardGui'){
    throw 'Runtime hard cleanup must not introduce BillboardGui'
}

$report = [ordered]@{
    project = 'AFTER SCHOOL CITY'
    audit = 'CLOUD_SOURCE_RUNTIME_HARD_CLEANUP_AUDIT_V1'
    sourceVersion = '0.5.2-runtime-hard-cleanup-1'
    status = 'PASS'
    mode = 'COMPONENT_REGRESSION_CHECK'
    schoolAxis = [ordered]@{xHalfWidth=12;zMin=149;zMax=169}
    studentRowEnvelopeCount = 3
    shopInteriorWidth = 22
    shopPropXLimit = 8.5
    skateSign = '26x3.6'
    downtownWayfinding = '10x2.6 @ x40/z160'
    lightCap = [ordered]@{brightness=0.38;range=14}
}
$report | ConvertTo-Json -Depth 5 | Set-Content 'runtime-hard-cleanup-audit-after-school-city.json' -Encoding UTF8
Write-Host 'AFTER SCHOOL CITY — CLOUD SOURCE RUNTIME HARD CLEANUP AUDIT V1'
Write-Host 'PASS: V0.5.2 hard-cleanup component remains intact inside current map version'
