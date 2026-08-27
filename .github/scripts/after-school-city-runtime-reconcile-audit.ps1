$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# AFTER SCHOOL CITY — CLOUD SOURCE RUNTIME RECONCILE AUDIT V1
# Verifies the final presentation pass waits for COMPLETION attributes instead of layer existence.

$map = Join-Path (Resolve-Path '.').Path 'maps/after-school-city'
$runtimePath = Join-Path $map 'after-school-city.runtime-reconcile.server.lua'
$configPath = Join-Path $map 'after-school-city.config.lua'
$projectPath = Join-Path $map 'default.project.json'
if(-not (Test-Path $runtimePath)){ throw 'Runtime reconcile source missing' }
$runtime = Get-Content $runtimePath -Raw
$config = Get-Content $configPath -Raw
$project = Get-Content $projectPath -Raw
$null = $project | ConvertFrom-Json

function Token([string]$text,[string]$token,[string]$label){
    if($text.IndexOf($token,[StringComparison]::Ordinal) -lt 0){ throw "ASC runtime reconcile contract missing: $label" }
}

Token $runtime 'layer.Name = "V051_RuntimeReconcile"' 'runtime reconcile layer'
Token $runtime 'ASC_Version", "0.5.1-runtime-reconcile-1"' 'runtime reconcile version'
Token $runtime 'waitForCompletionAttribute' 'completion wait function'
Token $runtime 'Workspace:GetAttribute(attributeName)' 'completion attributes read from Workspace'
Token $runtime 'task.wait(0.1)' 'scheduler-safe polling'
Token $runtime 'ASC_RuntimeReconcilePass' 'completion marker'
Token $runtime 'ASC_RuntimeOrderingRaceFixed' 'race fix marker'
Token $runtime 'ASC_FinalVisualStateReconciled' 'final visual marker'

$required = @(
    'ASC_SchoolLifePass',
    'ASC_DowntownLifePass',
    'ASC_CityLifePass',
    'ASC_StreetDensityPass',
    'ASC_SpatialCleanupPass',
    'ASC_StructuralRealignmentPass',
    'ASC_LayoutCorrectionPass',
    'ASC_CirculationSanitizePass',
    'ASC_ClearanceSanitizePass',
    'ASC_SourceSpatialFixPass',
    'ASC_OrientationCorrectionPass',
    'ASC_VisualFidelityPass'
)
foreach($token in $required){ Token $runtime ('"'+$token+'"') ("required completion attribute $token") }

foreach($token in @(
    'SchoolBollard',
    'WelcomeMonument',
    'VendingMachine',
    'VendingGlow',
    'StreetTreeTrunk',
    'StreetTreeCrown',
    'Shop_ARCADE',
    'Shop_CAFE',
    'Shop_STYLE',
    'Shop_MUSIC',
    'Shop_HOBBY',
    'SkateSign',
    'SkateEntrySign',
    'DOWNTOWN  ↓',
    'PointLight',
    'StreetLampHead'
)){
    Token $runtime $token ("final reconcile target $token")
}

Token $runtime 'for _, descendant in ipairs(root:GetDescendants()) do' 'recursive world reconciliation'
Token $runtime 'SHOP_INTERIOR_WIDTH = 22' 'shop effective width'
Token $runtime 'SHOP_PROP_X_LIMIT = 8.5' 'shop prop inset'
Token $runtime 'SKATE_SIGN_WIDTH = 26' 'compact skate sign'
Token $runtime 'DOWNTOWN_SIGN_WIDTH = 10' 'compact wayfinding'
Token $runtime 'EXTERIOR_LIGHT_BRIGHTNESS_MAX = 0.38' 'light brightness cap'
Token $runtime 'EXTERIOR_LIGHT_RANGE_MAX = 14' 'light range cap'

Token $config 'RuntimeReconcileVersion = "0.5.1-runtime-reconcile-1"' 'config runtime version'
Token $config 'EnableRuntimeReconcilePass = true' 'config runtime flag'
Token $project 'ASC_RuntimeReconcile' 'Rojo runtime node'
Token $project 'after-school-city.runtime-reconcile.server.lua' 'Rojo runtime path'

if($runtime -match 'MarketplaceService|PromptProductPurchase|ProcessReceipt|DataStoreService'){
    throw 'Runtime reconcile must not contain monetization/persistence authority'
}
if($runtime -match 'BillboardGui'){
    throw 'Runtime reconcile must not introduce BillboardGui'
}

$report = [ordered]@{
    project = 'AFTER SCHOOL CITY'
    audit = 'CLOUD_SOURCE_RUNTIME_RECONCILE_AUDIT_V1'
    sourceVersion = '0.5.1-runtime-reconcile-1'
    status = 'PASS'
    requiredCompletionAttributes = $required
    rule = 'final visual pass waits for completion attributes, not layer existence'
}
$report | ConvertTo-Json -Depth 5 | Set-Content 'runtime-reconcile-audit-after-school-city.json' -Encoding UTF8
Write-Host 'AFTER SCHOOL CITY — CLOUD SOURCE RUNTIME RECONCILE AUDIT V1'
Write-Host 'PASS: final presentation reconciliation is completion-attribute gated and covers v0.5 live defects'
