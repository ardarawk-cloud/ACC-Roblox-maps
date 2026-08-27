$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# AFTER SCHOOL CITY — CLOUD SOURCE VISUAL FIDELITY AUDIT V1
# Screenshot-derived gate: entrance clearance, prototype prop cleanup, sign scale,
# shop-shell reconciliation and exterior-light normalization.

$map = Join-Path (Resolve-Path '.').Path 'maps/after-school-city'
function Src([string]$file) {
    $p = Join-Path $map $file
    if(-not (Test-Path $p)){ throw "ASC visual source missing: $file" }
    Get-Content $p -Raw
}

$world = Src 'after-school-city.world.server.lua'
$school = Src 'after-school-city.school-life.server.lua'
$downtown = Src 'after-school-city.downtown-life.server.lua'
$city = Src 'after-school-city.city-life.server.lua'
$street = Src 'after-school-city.street-life.server.lua'
$fix = Src 'after-school-city.source-spatial-fix.server.lua'
$orient = Src 'after-school-city.orientation-correction.server.lua'
$visual = Src 'after-school-city.visual-fidelity.server.lua'
$config = Src 'after-school-city.config.lua'
$project = Src 'default.project.json'

$num='-?(?:\d+(?:\.\d*)?|\.\d+)'
$inv=[Globalization.CultureInfo]::InvariantCulture
function N([string]$s){ [double]::Parse($s,[Globalization.NumberStyles]::Float,$inv) }
function Need([string]$text,[string]$pattern,[string]$label){
    $m=[regex]::Match($text,$pattern,[Text.RegularExpressions.RegexOptions]::Singleline)
    if(-not $m.Success){ throw "ASC visual parser contract missing: $label" }
    $m
}
function Token([string]$text,[string]$token,[string]$label){
    if($text.IndexOf($token,[StringComparison]::Ordinal) -lt 0){ throw "ASC visual contract missing: $label" }
}
function Const([string]$name){
    $m=Need $visual ('local\s+'+[regex]::Escape($name)+'\s*=\s*('+$num+')') $name
    N $m.Groups[1].Value
}

$checks=[System.Collections.Generic.List[object]]::new()
$findings=[System.Collections.Generic.List[object]]::new()
function Pass([string]$rule,[string]$detail){$checks.Add([pscustomobject]@{Rule=$rule;Status='PASS';Detail=$detail})|Out-Null}
function Fail([string]$rule,[string]$detail){$checks.Add([pscustomobject]@{Rule=$rule;Status='FAIL';Detail=$detail})|Out-Null;$findings.Add([pscustomobject]@{Severity='ERROR';Rule=$rule;Detail=$detail})|Out-Null}
function Require([bool]$condition,[string]$rule,[string]$ok,[string]$bad){if($condition){Pass $rule $ok}else{Fail $rule $bad}}

# Ordered v0.5 contract.
Token $visual 'root:WaitForChild("V047_OrientationCorrection", 20)' 'v0.5 waits for verified orientation layer'
Token $visual 'layer.Name = "V050_VisualFidelity"' 'v0.5 visual layer'
Token $visual 'ASC_VisualFidelityPass' 'v0.5 completion marker'
Token $config 'Version = "0.5.0-visual-fidelity-1"' 'v0.5 config version'
Token $config 'OrientationBaseVersion = "0.4.7-orientation-correction-1"' 'orientation base compatibility lock'
Token $config 'EnableVisualFidelityPass = true' 'v0.5 config flag'
Token $project 'ASC_VisualFidelity' 'v0.5 Rojo node'
Token $project 'after-school-city.visual-fidelity.server.lua' 'v0.5 Rojo path'

# Confirm screenshot defects exist in legacy source and are explicitly corrected late.
Token $city '"SchoolBollard"' 'legacy school bollards exist'
Token $city '"VendingMachine"' 'legacy corridor vending exists'
Token $downtown '"VendingMachine"' 'legacy downtown vending exists'
Token $world 'local skateSign = part(skate, "SkateSign", Vector3.new(34, 8, 1)' 'legacy skate sign source'
Token $world '"WelcomeMonument"' 'legacy welcome monument source'
Token $school '"DOWNTOWN  ↓"' 'legacy school wayfinding source'
Token $visual 'obj.Name == "SchoolBollard"' 'school-axis bollard removal'
Token $visual 'descendant.Name == "VendingMachine" or descendant.Name == "VendingGlow"' 'prototype vending removal'
Token $visual 'oldSign:Destroy()' 'legacy skate sign destruction'
Token $visual 'welcome.CFrame = CFrame.new(-82, 4.2, 268)' 'welcome monument moved off movement axis'
Token $visual 'downtownPlate:SetAttribute("ASC_CompactWayfinding", true)' 'compact downtown wayfinding'

# Numeric sign/light/shop contracts.
$shopWidth=Const 'SHOP_INTERIOR_WIDTH'
$propLimit=Const 'SHOP_PROP_X_LIMIT'
$shopSignW=Const 'SHOP_SIGN_WIDTH'
$shopSignH=Const 'SHOP_SIGN_HEIGHT'
$skateW=Const 'SKATE_SIGN_WIDTH'
$skateH=Const 'SKATE_SIGN_HEIGHT'
$skateZ=Const 'SKATE_SIGN_Z'
$downW=Const 'DOWNTOWN_SIGN_WIDTH'
$downH=Const 'DOWNTOWN_SIGN_HEIGHT'
$downX=Const 'DOWNTOWN_SIGN_X'
$downZ=Const 'DOWNTOWN_SIGN_Z'
$lightB=Const 'EXTERIOR_LIGHT_BRIGHTNESS_MAX'
$lightR=Const 'EXTERIOR_LIGHT_RANGE_MAX'
$axisX=Const 'SCHOOL_AXIS_CLEAR_X'
$axisZMin=Const 'SCHOOL_AXIS_CLEAR_Z_MIN'
$axisZMax=Const 'SCHOOL_AXIS_CLEAR_Z_MAX'

Require ($shopWidth -le 24 -and $shopWidth -ge 18) 'downtown-shell-width' ("effective interior width {0:N1} <= 24-stud shop footprint"-f $shopWidth) 'downtown interior shell exceeds effective shop footprint'
Require ($propLimit -le (($shopWidth/2)-2)) 'downtown-prop-inset' ("props clamped to x±{0:N1} inside half-width {1:N1}"-f $propLimit,($shopWidth/2)) 'downtown props are not sufficiently inset from side walls'
Require ($shopSignW -le 20 -and $shopSignH -le 4) 'downtown-sign-scale' ("store signs {0:N1}x{1:N1} studs"-f $shopSignW,$shopSignH) 'downtown store signs exceed compact scale'
Require ($skateW -le 30 -and $skateH -le 4.5) 'skate-sign-scale' ("compact skate sign {0:N1}x{1:N1} at Z={2:N1}"-f $skateW,$skateH,$skateZ) 'skate sign is still wall-sized'
Require ($skateZ -ge 55 -and $skateZ -le 70) 'skate-sign-placement' ("skate entry sign Z={0:N1} stays near park edge"-f $skateZ) 'skate sign is outside intended park-edge band'
Require ($downW -le 11 -and $downH -le 3) 'wayfinding-scale' ("downtown wayfinding {0:N1}x{1:N1} at X={2:N1}/Z={3:N1}"-f $downW,$downH,$downX,$downZ) 'school wayfinding remains oversized'
Require ([math]::Abs($downX) -ge 30) 'wayfinding-off-axis' ("wayfinding X={0:N1} stays outside central school axis"-f $downX) 'wayfinding sits on the central arrival axis'
Require ($lightB -le 0.4 -and $lightR -le 14) 'exterior-light-budget' ("PointLight cap brightness={0:N2}, range={1:N0}"-f $lightB,$lightR) 'exterior light cap is too bright/long-range'
Require ($axisX -ge 12 -and $axisZMin -le 176 -and $axisZMax -ge 176) 'school-axis-bollard-clearance' ("clears legacy bollards inside x±{0:N0}, z={1:N0}..{2:N0}"-f $axisX,$axisZMin,$axisZMax) 'school axis cleanup does not cover old bollard row'

# Shop spacing: v0.4.6 centers have minimum 28-stud separation; v0.5 shell must preserve positive gap.
$shopRx='\{name\s*=\s*"Shop_[^"]+",\s*x\s*=\s*('+$num+'),\s*width\s*=\s*('+$num+')\}'
$shopMatches=[regex]::Matches($fix,$shopRx)
if($shopMatches.Count -ne 5){throw "Expected 5 v0.4.6 shop centers, got $($shopMatches.Count)"}
$centers=@($shopMatches|ForEach-Object{N $_.Groups[1].Value}|Sort-Object)
$minGap=[double]::PositiveInfinity
for($i=1;$i-lt$centers.Count;$i++){
    $gap=($centers[$i]-$centers[$i-1])-$shopWidth
    if($gap-lt$minGap){$minGap=$gap}
}
Require ($minGap -ge 4) 'downtown-interior-neighbor-gap' ("minimum effective interior gap {0:N1} studs"-f $minGap) 'effective downtown interiors still overlap or crowd adjacent shops'

# Student Row tree/door evidence and correction targets.
foreach($token in @(
    '{x = -151, z = 107}',
    '{x = -151, z = 157}',
    '{x = 151, z = 111}'
)) { Token $visual $token "student-row clear target $token" }
Token $street 'Vector3.new(-151, 1.5, 107)' 'legacy Mini Mart entrance tree'
Token $street 'Vector3.new(-151, 1.5, 157)' 'legacy Study Lounge entrance tree'
Token $street 'Vector3.new(151, 1.5, 111)' 'legacy Library entrance tree'
Token $visual 'nearXZ(obj, target.x, target.z, 2.2)' 'tree target tolerance'
Pass 'student-row-door-clearance' 'Known street trees directly in Mini Mart / Study Lounge / Library approach zones are removed by exact coordinate contract.'

# Downtown shell reconciliation and readable text.
foreach($token in @(
    'obj.Name == "Floor" or obj.Name == "BackWall" or obj.Name == "Ceiling" or obj.Name == "Threshold"',
    'obj.Name == "WallL"',
    'obj.Name == "WallR"',
    'obj.Name == "FrontPostL"',
    'obj.Name == "FrontPostR"',
    'label.TextScaled = true'
)) { Token $visual $token "downtown reconciliation $token" }
Pass 'downtown-runtime-shell' 'Legacy 32-stud interior shells are clamped inside the 24-stud effective shop buildings and storefront labels are TextScaled.'

# External lamp body normalization prevents glowing white rectangles while retaining PointLights.
Token $visual 'descendant.Name == "Lamp" or descendant.Name == "LampHead" or descendant.Name == "StreetLampHead"' 'external lamp-head selection'
Token $visual 'descendant.Material = Enum.Material.SmoothPlastic' 'external lamp material normalization'
Token $visual 'descendant.Shadows = false' 'light shadow normalization'
Pass 'floating-light-blocks' 'Exterior lamp heads become compact warm SmoothPlastic fixtures with restrained PointLight budgets.'

# Hard safety lock for visual layer.
if($visual -match 'MarketplaceService|PromptProductPurchase|ProcessReceipt|DataStoreService'){
    Fail 'visual-layer-authority' 'visual fidelity layer contains forbidden monetization/persistence authority'
}else{
    Pass 'visual-layer-authority' 'visual fidelity layer contains no economy/monetization/persistence authority'
}
if($visual -match 'BillboardGui'){
    Fail 'visual-layer-billboard' 'visual fidelity layer reintroduces BillboardGui'
}else{
    Pass 'visual-layer-billboard' 'no BillboardGui in visual fidelity layer'
}

$status=if($findings.Count-eq 0){'PASS'}else{'FAIL'}
$report=[ordered]@{
    project='AFTER SCHOOL CITY'
    audit='CLOUD_SOURCE_VISUAL_FIDELITY_AUDIT_V1'
    sourceVersion='0.5.0-visual-fidelity-1'
    status=$status
    metrics=[ordered]@{
        shopInteriorWidth=$shopWidth
        shopPropXLimit=$propLimit
        minimumShopInteriorGap=$minGap
        shopSignWidth=$shopSignW
        shopSignHeight=$shopSignH
        skateSignWidth=$skateW
        skateSignHeight=$skateH
        downtownSignWidth=$downW
        downtownSignHeight=$downH
        lightBrightnessMax=$lightB
        lightRangeMax=$lightR
    }
    checks=@($checks)
    findings=@($findings)
}
$report|ConvertTo-Json -Depth 8|Set-Content 'visual-fidelity-audit-after-school-city.json' -Encoding UTF8

Write-Host 'AFTER SCHOOL CITY — CLOUD SOURCE VISUAL FIDELITY AUDIT V1'
foreach($c in $checks){Write-Host ("{0}: {1}: {2}"-f $c.Status,$c.Rule,$c.Detail)}
if($findings.Count-gt 0){throw "ASC visual fidelity audit FAIL: $($findings.Count) issue(s)"}
Write-Host 'PASS: live-v16 screenshot defects are covered by deterministic v0.5 source contracts'
