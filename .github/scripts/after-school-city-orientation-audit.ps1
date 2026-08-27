$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# AFTER SCHOOL CITY — CLOUD SOURCE ORIENTATION AUDIT V1
# Verifies road -> frontage -> entrance -> signage logic from source/effective late-pass contracts.

$map = Join-Path (Resolve-Path '.').Path 'maps/after-school-city'
function Src([string]$file) {
    $p = Join-Path $map $file
    if(-not (Test-Path $p)){ throw "ASC orientation source missing: $file" }
    Get-Content $p -Raw
}

$world = Src 'after-school-city.world.server.lua'
$school = Src 'after-school-city.school-life.server.lua'
$street = Src 'after-school-city.street-life.server.lua'
$cleanup = Src 'after-school-city.spatial-cleanup.server.lua'
$circ = Src 'after-school-city.circulation-sanitize.server.lua'
$fix = Src 'after-school-city.source-spatial-fix.server.lua'
$orient = Src 'after-school-city.orientation-correction.server.lua'
$config = Src 'after-school-city.config.lua'
$project = Src 'default.project.json'

$num='-?(?:\d+(?:\.\d*)?|\.\d+)'
$inv=[Globalization.CultureInfo]::InvariantCulture
function N([string]$s){ [double]::Parse($s,[Globalization.NumberStyles]::Float,$inv) }
function Token([string]$text,[string]$token,[string]$label){
    if($text.IndexOf($token,[StringComparison]::Ordinal) -lt 0){ throw "ASC orientation contract missing: $label" }
}
function Need([string]$text,[string]$pattern,[string]$label){
    $m=[regex]::Match($text,$pattern,[Text.RegularExpressions.RegexOptions]::Singleline)
    if(-not $m.Success){ throw "ASC orientation parser contract missing: $label" }
    $m
}
function Const([string]$name){
    $m=Need $orient ('local\s+'+[regex]::Escape($name)+'\s*=\s*('+$num+')') $name
    N $m.Groups[1].Value
}

$findings=[System.Collections.Generic.List[object]]::new()
$checks=[System.Collections.Generic.List[object]]::new()
function Pass([string]$rule,[string]$detail){
    $checks.Add([pscustomobject]@{Rule=$rule;Status='PASS';Detail=$detail})|Out-Null
}
function Fail([string]$rule,[string]$detail){
    $checks.Add([pscustomobject]@{Rule=$rule;Status='FAIL';Detail=$detail})|Out-Null
    $findings.Add([pscustomobject]@{Severity='ERROR';Rule=$rule;Detail=$detail})|Out-Null
}
function Require([bool]$condition,[string]$rule,[string]$ok,[string]$bad){
    if($condition){Pass $rule $ok}else{Fail $rule $bad}
}

# Ordered source contract.
Token $orient 'root:WaitForChild("V046_SourceSpatialFix", 20)' 'v0.4.7 waits for v0.4.6'
Token $orient 'layer.Name = "V047_OrientationCorrection"' 'v0.4.7 layer'
Token $orient 'ASC_OrientationCorrectionPass' 'v0.4.7 completion marker'
Token $config 'Version = "0.4.7-orientation-correction-1"' 'v0.4.7 config version'
Token $config 'EnableOrientationCorrectionPass = true' 'v0.4.7 config flag'
Token $config 'Spawn = Vector3.new(0, 2.2, 157)' 'front spawn config'
Token $project 'ASC_OrientationCorrection' 'v0.4.7 Rojo node'
Token $project 'after-school-city.orientation-correction.server.lua' 'v0.4.7 Rojo path'

# School road/frontage geometry.
$roadSizeZ=Const 'MAIN_ROAD_SIZE_Z'
$roadCenterZ=Const 'MAIN_ROAD_CENTER_Z'
$schoolCenterZ=Const 'SCHOOL_MAIN_CENTER_Z'
$schoolDepth=Const 'SCHOOL_MAIN_DEPTH'
$plazaZ=Const 'SCHOOL_FRONT_PLAZA_Z'
$plazaDepth=Const 'SCHOOL_FRONT_PLAZA_DEPTH'
$gateZ=Const 'SCHOOL_GATE_Z'
$crosswalkZ=Const 'SCHOOL_CROSSWALK_Z'
$spawnZ=Const 'SCHOOL_SPAWN_Z'
$clearX=Const 'SCHOOL_FRONT_CLEAR_X'
$clearMin=Const 'SCHOOL_FRONT_CLEAR_Z_MIN'
$clearMax=Const 'SCHOOL_FRONT_CLEAR_Z_MAX'

$roadNorth=$roadCenterZ+$roadSizeZ/2
$schoolSouth=$schoolCenterZ-$schoolDepth/2
$plazaSouth=$plazaZ-$plazaDepth/2
$plazaNorth=$plazaZ+$plazaDepth/2
$approachGap=$schoolSouth-$roadNorth

Require ($approachGap -ge 30) 'school-road-approach-gap' ("road north edge {0:N1}, school south face {1:N1}, gap {2:N1} studs"-f $roadNorth,$schoolSouth,$approachGap) ("school approach gap only {0:N1} studs"-f $approachGap)
Require (($crosswalkZ+5) -le $roadNorth) 'school-crosswalk-on-road' ("crosswalk north edge {0:N1} <= road edge {1:N1}"-f ($crosswalkZ+5),$roadNorth) 'crosswalk extends beyond effective road'
Require (($gateZ -gt $roadNorth) -and ($gateZ -lt $plazaSouth)) 'school-gate-transition' ("gate Z={0:N1} sits between road edge {1:N1} and plaza edge {2:N1}"-f $gateZ,$roadNorth,$plazaSouth) 'gate is not between road and arrival plaza'
Require ([math]::Abs($plazaNorth-$schoolSouth) -le 0.6) 'school-plaza-meets-facade' ("plaza north edge {0:N1} meets façade {1:N1}"-f $plazaNorth,$schoolSouth) 'front plaza does not terminate at school façade'
Require (($spawnZ -ge $plazaSouth) -and ($spawnZ -le $plazaNorth)) 'school-spawn-in-front-apron' ("spawn Z={0:N1} lies inside front plaza"-f $spawnZ) 'spawn is not inside corrected front plaza'
Require (($clearMin -le $gateZ) -and ($clearMax -ge $schoolSouth) -and ($clearX -ge 60)) 'school-front-clear-zone' ("clear zone x±{0:N0}, z={1:N0}..{2:N0} covers gate through façade"-f $clearX,$clearMin,$clearMax) 'front clear zone does not cover the full arrival sequence'

# School entrance/sign normals.
Token $orient 'school:SetAttribute("ASC_EntranceFaces", "SOUTH")' 'school entrance south'
Token $orient 'setSurfaceFace(schoolSign, Enum.NormalId.Front)' 'school sign south normal'
Token $orient 'gateGui.Face = Enum.NormalId.Front' 'gate sign south normal'
Token $orient 'spawn.CFrame = CFrame.new(0, 2.2, SCHOOL_SPAWN_Z) * CFrame.Angles(0, math.rad(180), 0)' 'spawn faces school'
Token $orient 'math.abs(p.X) <= SCHOOL_FRONT_CLEAR_X and p.Z >= SCHOOL_FRONT_CLEAR_Z_MIN and p.Z <= SCHOOL_FRONT_CLEAR_Z_MAX' 'corridor front-apron cleanup'
Token $orient 'math.abs(probe.Position.Z - 150) <= 2' 'legacy front streetlight cleanup'
Token $orient 'offsetModel(busStop, Vector3.new(-78 - roof.Position.X, 0, 0))' 'bus shelter clears plaza edge'
Pass 'school-frontage-direction' 'Main school entrance + school sign + gate face SOUTH toward the public avenue; spawn faces NORTH toward the school.'

# Downtown: base geometry places storefront at Z=-35.7 / shop center Z=-56, so nearest plaza/road is NORTH (+Z).
Token $world 'window(shop, "Storefront", Vector3.new(24, 10, 0.65), CFrame.new(x, 6.5, -35.7))' 'downtown storefront north side'
Token $orient 'shop:SetAttribute("ASC_EntranceFaces", "NORTH")' 'downtown entrance north'
Token $orient 'setSurfaceFace(storeSign, Enum.NormalId.Back)' 'downtown store sign north normal'
Token $orient 'descendant.Face = Enum.NormalId.Back' 'interior back-wall labels face inward/north'
Token $fix 'SHOP_LAYOUT' 'v0.4.6 effective downtown positions retained'
Pass 'downtown-frontage-direction' 'ARCADE / CAFE / STYLE / MUSIC / HOBBY open fronts and signs face NORTH toward plaza/road.'

# Residential: center house is removed. House at Z=-48 already fronts +Z; house at Z=+48 must front -Z.
Token $orient 'southHouse:SetAttribute("ASC_EntranceFaces", "NORTH")' 'Townhouse_1 north-facing'
Token $orient 'northHouse:SetAttribute("ASC_EntranceFaces", "SOUTH")' 'Townhouse_3 south-facing'
Token $orient 'local mirroredZ = 2 * TOWNHOUSE_3_CENTER_Z - child.Position.Z' 'Townhouse_3 door/window mirror'
$house3Center=Const 'TOWNHOUSE_3_CENTER_Z'
$baseDoorOffset=17.3
$oldDoorZ=$house3Center+$baseDoorOffset
$newDoorZ=2*$house3Center-$oldDoorZ
$roadNorthEdge=20.0
$oldDistance=[math]::Abs($oldDoorZ-$roadNorthEdge)
$newDistance=[math]::Abs($newDoorZ-$roadNorthEdge)
Require ($newDistance -lt $oldDistance) 'townhouse-3-door-nearest-road' ("door mirrored from Z={0:N1} to Z={1:N1}; road-edge distance improves {2:N1}->{3:N1}"-f $oldDoorZ,$newDoorZ,$oldDistance,$newDistance) 'Townhouse_3 correction does not move its door toward EastWestRoad'

# Student Row: v0.4.1 rotates west-side buildings east and east-side library west toward side streets.
Token $cleanup 'StudentMiniMart = {z = 108, yaw = 90}' 'MiniMart east-facing transform'
Token $cleanup 'StudyLounge = {z = 166, yaw = 90}' 'StudyLounge east-facing transform'
Token $cleanup 'CommunityLibrary = {z = 112, yaw = -90}' 'Library west-facing transform'
Token $orient 'StudentMiniMart = "EAST"' 'MiniMart orientation contract'
Token $orient 'StudyLounge = "EAST"' 'StudyLounge orientation contract'
Token $orient 'CommunityLibrary = "WEST"' 'Library orientation contract'
Token $orient 'plate.Name == "Sign"' 'Student Row sign selection'
Token $orient 'descendant.Face = Enum.NormalId.Back' 'Student Row signs outward'
Pass 'student-row-frontage-direction' 'StudentMiniMart + StudyLounge face EAST; CommunityLibrary faces WEST; signs follow the street-facing rotations.'

# Other school-side buildings already have intentional orientations.
Token $school 'local canteenX, canteenZ = -132, 222' 'canteen placement'
Token $school 'CFrame.new(canteenX, 10, canteenZ - 16.2)' 'canteen sign south side'
Token $orient 'canteen:SetAttribute("ASC_EntranceFaces", "SOUTH")' 'canteen south orientation'
Token $circ 'club:SetAttribute("ASC_EntranceFaces", "WEST")' 'Club Hub west entrance'
Token $circ 'gui.Face = Enum.NormalId.Left' 'Club Hub west sign normal'
Pass 'campus-secondary-frontage' 'Student Canteen faces SOUTH; Club Hub entrance/sign face WEST toward its internal pedestrian access.'

$status=if($findings.Count-eq 0){'PASS'}else{'FAIL'}
$report=[ordered]@{
    project='AFTER SCHOOL CITY'
    audit='CLOUD_SOURCE_ORIENTATION_AUDIT_V1'
    sourceVersion='0.4.7-orientation-correction-1'
    status=$status
    geometry=[ordered]@{
        mainRoadNorthEdge=$roadNorth
        schoolSouthFace=$schoolSouth
        approachGap=$approachGap
        frontPlazaSouth=$plazaSouth
        frontPlazaNorth=$plazaNorth
        gateZ=$gateZ
        crosswalkZ=$crosswalkZ
        spawnZ=$spawnZ
        townhouse3CorrectedDoorZ=$newDoorZ
    }
    checks=@($checks)
    findings=@($findings)
}
$report|ConvertTo-Json -Depth 8|Set-Content 'orientation-audit-after-school-city.json' -Encoding UTF8

Write-Host 'AFTER SCHOOL CITY — CLOUD SOURCE ORIENTATION AUDIT V1'
foreach($c in $checks){ Write-Host ("{0}: {1}: {2}" -f $c.Status,$c.Rule,$c.Detail) }
if($findings.Count-gt 0){ throw "ASC orientation audit FAIL: $($findings.Count) issue(s)" }
Write-Host 'PASS: road -> frontage -> entrance -> signage orientation contracts are consistent'
