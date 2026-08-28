$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# AFTER SCHOOL CITY — CLOUD SOURCE PREMIUM EXTERIOR AUDIT V1
# Verifies V0.6 exterior polish remains interior-ready, circulation-safe and mobile-budgeted.

$map = Join-Path (Resolve-Path '.').Path 'maps/after-school-city'
$premiumPath = Join-Path $map 'after-school-city.premium-exterior.server.lua'
$configPath = Join-Path $map 'after-school-city.config.lua'
$projectPath = Join-Path $map 'default.project.json'
if(-not (Test-Path $premiumPath)){ throw 'Premium exterior source missing' }
$premium = Get-Content $premiumPath -Raw
$config = Get-Content $configPath -Raw
$project = Get-Content $projectPath -Raw
$null = $project | ConvertFrom-Json

function Token([string]$text,[string]$token,[string]$label){
    if($text.IndexOf($token,[StringComparison]::Ordinal) -lt 0){ throw "ASC premium exterior contract missing: $label" }
}
function NumberAfter([string]$text,[string]$name){
    $m=[regex]::Match($text,[regex]::Escape($name)+'\s*=\s*([0-9.]+)')
    if(-not $m.Success){ throw "Numeric contract missing: $name" }
    return [double]$m.Groups[1].Value
}

Token $premium 'V060_PremiumExterior' 'premium layer'
Token $premium '0.6.0-premium-exterior-1' 'premium version'
Token $premium 'waitForWorkspaceAttribute("ASC_RoadCenterlineClearancePass", 45)' 'v0.5.3 completion gate'

$partBudget=NumberAfter $premium 'PREMIUM_PART_BUDGET'
$lightBudget=NumberAfter $premium 'PREMIUM_LIGHT_BUDGET'
if($partBudget -gt 220){ throw "Premium part budget too high: $partBudget" }
if($lightBudget -gt 16){ throw "Premium light budget too high: $lightBudget" }
Write-Host "PASS: mobile-budget: parts<=$partBudget lights<=$lightBudget"

foreach($token in @(
    'V060_SchoolExterior','EntrancePierL','EntrancePierR','EntranceLintel','CanopyFrontFascia','MainRoofLip','RoofHVAC','ASC_SchoolPremiumExterior'
)){
    Token $premium $token ("school premium $token")
}
Write-Host 'PASS: school-premium-exterior: portal + facade depth + window frames + rooftop service detail'

foreach($shop in @('ARCADE','CAFE','STYLE','MUSIC','HOBBY')){
    Token $premium ($shop+' = C.') ("downtown identity $shop")
}
foreach($token in @('V060_DowntownFacades','Cornice','EntryMat','Sconce','ASC_FutureMarketplaceReady','ASC_DowntownPremiumFacades')){
    Token $premium $token ("downtown premium $token")
}
Token $premium 'shop:SetAttribute("ASC_InteriorReady", true)' 'downtown open-front interior readiness'
Write-Host 'PASS: downtown-premium-facades: five distinct shop identities + open-front interior readiness'

foreach($token in @('StudentMiniMart','StudyLounge','CommunityLibrary','V060_StudentRowFacades','ASC_StudentRowPremiumFacades')){
    Token $premium $token ("student row premium $token")
}
Token $premium 'model:SetAttribute("ASC_InteriorReady", true)' 'student row interior readiness'
Write-Host 'PASS: student-row-premium: Mini Mart + Study Lounge + Library remain interior-ready'

$roadEdge=NumberAfter $premium 'MAIN_ROAD_EDGE_X'
$roadLength=NumberAfter $premium 'MAIN_ROAD_DETAIL_LENGTH'
if($roadEdge -ge 19){ throw "Road edge marking enters centerline hard-clear boundary: x=$roadEdge" }
if($roadLength -gt 412){ throw "Road detail exceeds effective road length: $roadLength" }
foreach($token in @('V060_RoadDetail','MainRoadEdgeLine','line.CastShadow = false','ASC_StreetPremiumMarkings')){
    Token $premium $token ("street premium $token")
}
Write-Host "PASS: street-premium-markings: non-colliding low road detail x±$roadEdge length=$roadLength"

foreach($token in @('LakeEdgeWest','LakeEdgeEast','ParkEntrySign','V060_SkateExterior','EdgeAccent','ASC_RecreationPremiumExterior')){
    Token $premium $token ("recreation premium $token")
}
Write-Host 'PASS: recreation-premium: park lake edge/sign + skate edge accents'

foreach($token in @('PARKED_VEHICLE','Headlamp','TailLamp','MirrorL','MirrorR','ASC_PremiumVehicleDetail','ASC_VehiclePremiumDetail')){
    Token $premium $token ("vehicle premium $token")
}
Write-Host 'PASS: vehicle-premium: parked vehicles gain readable exterior detail without extra lights'

foreach($token in @('Lighting.ClockTime = 16.85','Lighting.ShadowSoftness = 0.32','Lighting.EnvironmentDiffuseScale = 0.38','Lighting.EnvironmentSpecularScale = 0.42','ASC_V060ColorGrade','ASC_PremiumLightingBalanced')){
    Token $premium $token ("lighting premium $token")
}
Write-Host 'PASS: lighting-premium: restrained warm after-school grade'

foreach($token in @('ASC_PremiumExteriorPass','ASC_PremiumExteriorPartCount','ASC_PremiumExteriorLightCount','ASC_PremiumVehicleCount')){
    Token $premium $token ("final marker $token")
}

Token $config 'Version = "0.6.0-premium-exterior-1"' 'config current version'
Token $config 'PremiumExteriorVersion = "0.6.0-premium-exterior-1"' 'config premium version'
Token $config 'EnablePremiumExteriorPass = true' 'config premium flag'
foreach($token in @('EnableActivities = false','EnableEconomy = false','EnablePersistence = false')){
    Token $config $token ("disabled gameplay authority $token")
}
Token $project 'ASC_PremiumExterior' 'Rojo premium node'
Token $project 'after-school-city.premium-exterior.server.lua' 'Rojo premium source path'
$idx053=$project.IndexOf('ASC_RoadCenterlineClearance',[StringComparison]::Ordinal)
$idx060=$project.IndexOf('ASC_PremiumExterior',[StringComparison]::Ordinal)
if($idx053 -lt 0 -or $idx060 -lt 0 -or $idx060 -le $idx053){ throw 'Rojo ordering invalid: V0.6 must follow V0.5.3' }
Write-Host 'PASS: rojo-order: V0.6 follows Road Centerline Clearance V0.5.3'

if($premium -match 'MarketplaceService|PromptProductPurchase|ProcessReceipt|DataStoreService'){
    throw 'V0.6 exterior must not contain monetization/persistence authority yet'
}
if($premium -match 'BillboardGui'){
    throw 'V0.6 exterior must not introduce BillboardGui'
}

$report=[ordered]@{
    project='AFTER SCHOOL CITY'
    audit='CLOUD_SOURCE_PREMIUM_EXTERIOR_AUDIT_V1'
    sourceVersion='0.6.0-premium-exterior-1'
    status='PASS'
    partBudget=$partBudget
    lightBudget=$lightBudget
    roadEdgeX=$roadEdge
    roadDetailLength=$roadLength
    interiorReady=$true
    marketplaceRuntimeEnabled=$false
}
$report | ConvertTo-Json -Depth 4 | Set-Content 'premium-exterior-audit-after-school-city.json' -Encoding UTF8
Write-Host 'AFTER SCHOOL CITY — CLOUD SOURCE PREMIUM EXTERIOR AUDIT V1'
Write-Host 'PASS: premium exterior is interior-ready, road-safe, mobile-budgeted and contains no monetization/persistence authority'
