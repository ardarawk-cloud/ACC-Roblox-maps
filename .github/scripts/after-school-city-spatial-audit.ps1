$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# AFTER SCHOOL CITY — Cloud Source Spatial Audit v2
# Reads runtime-generating Lua source, reconstructs effective X/Z AABBs after
# the late correction chain, then fails before Rojo build on unsafe placement.

$repo = (Resolve-Path '.').Path
$map = Join-Path $repo 'maps/after-school-city'

function Read-Source([string]$name) {
    $path = Join-Path $map $name
    if (-not (Test-Path $path)) { throw "Required ASC source missing: $name" }
    return Get-Content $path -Raw
}

$world = Read-Source 'after-school-city.world.server.lua'
$school = Read-Source 'after-school-city.school-life.server.lua'
$city = Read-Source 'after-school-city.city-life.server.lua'
$street = Read-Source 'after-school-city.street-life.server.lua'
$cleanup = Read-Source 'after-school-city.spatial-cleanup.server.lua'
$realign = Read-Source 'after-school-city.structural-realignment.server.lua'
$layout = Read-Source 'after-school-city.layout-correction.server.lua'
$circ = Read-Source 'after-school-city.circulation-sanitize.server.lua'
$clearance = Read-Source 'after-school-city.clearance-sanitize.server.lua'
$fix = Read-Source 'after-school-city.source-spatial-fix.server.lua'
$project = Read-Source 'default.project.json'
$config = Read-Source 'after-school-city.config.lua'

$culture = [Globalization.CultureInfo]::InvariantCulture
$num = '-?(?:\d+(?:\.\d*)?|\.\d+)'

function D([string]$value) {
    return [double]::Parse($value, [Globalization.NumberStyles]::Float, $culture)
}

function Require-Match([string]$text, [string]$pattern, [string]$label) {
    $m = [regex]::Match($text, $pattern, [Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $m.Success) { throw "ASC spatial parser contract missing: $label" }
    return $m
}

function Require-Token([string]$text, [string]$token, [string]$label) {
    if ($text.IndexOf($token, [StringComparison]::Ordinal) -lt 0) {
        throw "ASC spatial source contract missing: $label"
    }
}

$boxes = [System.Collections.Generic.List[object]]::new()
$findings = [System.Collections.Generic.List[object]]::new()
$notes = [System.Collections.Generic.List[string]]::new()

function Add-Box(
    [string]$name, [string]$kind,
    [double]$x, [double]$z, [double]$sx, [double]$sz,
    [string]$source, [string]$group = '', [string]$note = ''
) {
    $boxes.Add([pscustomobject]@{
        Name=$name; Kind=$kind; X=$x; Z=$z; SX=[math]::Abs($sx); SZ=[math]::Abs($sz)
        XMin=$x-[math]::Abs($sx)/2; XMax=$x+[math]::Abs($sx)/2
        ZMin=$z-[math]::Abs($sz)/2; ZMax=$z+[math]::Abs($sz)/2
        Source=$source; Group=$group; Note=$note
    }) | Out-Null
}

function Add-Finding([string]$rule, $a, $b, [string]$detail) {
    $findings.Add([pscustomobject]@{Severity='ERROR'; Rule=$rule; A=$a.Name; B=$b.Name; Detail=$detail}) | Out-Null
}

function Test-Overlap($a, $b) {
    return ($a.XMin -lt $b.XMax -and $a.XMax -gt $b.XMin -and $a.ZMin -lt $b.ZMax -and $a.ZMax -gt $b.ZMin)
}

function Get-Separation($a, $b) {
    $dx = [math]::Max([math]::Max($b.XMin - $a.XMax, $a.XMin - $b.XMax), 0)
    $dz = [math]::Max([math]::Max($b.ZMin - $a.ZMax, $a.ZMin - $b.ZMax), 0)
    return [math]::Sqrt($dx*$dx + $dz*$dz)
}

function Add-LiteralPart([string]$text, [string]$partName, [string]$kind, [string]$sourceName, [string]$group='') {
    $escaped = [regex]::Escape($partName)
    $pattern = 'part\([^\r\n]+,\s*"' + $escaped + '"\s*,\s*Vector3\.new\(\s*(' + $num + ')\s*,\s*(' + $num + ')\s*,\s*(' + $num + ')\s*\)\s*,\s*CFrame\.new\(\s*(' + $num + ')\s*,\s*(' + $num + ')\s*,\s*(' + $num + ')\s*\)'
    $m = Require-Match $text $pattern "$sourceName:$partName"
    Add-Box $partName $kind (D $m.Groups[4].Value) (D $m.Groups[6].Value) (D $m.Groups[1].Value) (D $m.Groups[3].Value) $sourceName $group
}

# -------------------------------------------------------------------------
# Pass-chain and v0.4.6 source locks.
# -------------------------------------------------------------------------
Require-Token $cleanup 'root:WaitForChild("V04_StreetLife", 20)' 'v0.4.1 waits for street layer'
Require-Token $realign 'root:WaitForChild("V041_SpatialCleanup", 20)' 'v0.4.2 waits for spatial cleanup'
Require-Token $layout 'root:WaitForChild("V042_StructuralRealignment", 20)' 'v0.4.3 waits for structural realignment'
Require-Token $circ 'root:WaitForChild("V043_LayoutCorrection", 20)' 'v0.4.4 waits for layout correction'
Require-Token $clearance 'root:WaitForChild("V044_CirculationSanitize", 20)' 'v0.4.5 waits for circulation sanitize'
Require-Token $fix 'root:WaitForChild("V045_ClearanceSanitize", 20)' 'v0.4.6 waits for clearance sanitize'
Require-Token $project 'ASC_SourceSpatialFix' 'Rojo wires v0.4.6 source spatial fix'
Require-Token $config '0.4.6-source-spatial-audit-fix-1' 'config version v0.4.6'
Require-Token $config 'EnableSourceSpatialFixPass = true' 'v0.4.6 config flag'

# -------------------------------------------------------------------------
# Effective road geometry: parse original + source overrides.
# -------------------------------------------------------------------------
Add-LiteralPart $world 'EastWestRoad' 'road' 'world'

$m = Require-Match $realign ('nsRoad\.Size\s*=\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\).*?nsRoad\.CFrame\s*=\s*CFrame\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)') 'NorthSouthRoad effective override'
Add-Box 'NorthSouthRoad' 'road' (D $m.Groups[4].Value) (D $m.Groups[6].Value) (D $m.Groups[1].Value) (D $m.Groups[3].Value) 'structural-realignment' '' 'effective v0.4.2 override'

$m = Require-Match $cleanup ('schoolSportsRoad\.Size\s*=\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\).*?schoolSportsRoad\.CFrame\s*=\s*CFrame\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)') 'SchoolSportsRoad effective override'
Add-Box 'SchoolSportsRoad' 'road' (D $m.Groups[4].Value) (D $m.Groups[6].Value) (D $m.Groups[1].Value) (D $m.Groups[3].Value) 'spatial-cleanup' '' 'effective v0.4.1 override'

Require-Token $street 'for _, x in ipairs({-126, 126}) do' 'secondary side-street centers'
Require-Token $street 'Vector3.new(28, 0.6, 190), CFrame.new(x, 1.05, 98)' 'secondary side-street footprint'
foreach($x in @(-126.0,126.0)) { Add-Box "SideStreet@$x" 'road' $x 98 28 190 'street-life' }

Require-Token $street 'for _, z in ipairs({62, 132}) do' 'cross-street centers'
Require-Token $cleanup 'child.Position.Z > 100' 'v0.4.1 removes Z=132 cross street'
Add-Box 'CrossStreet@62' 'road' 0 62 280 24 'street-life' '' 'Z=132 removed by v0.4.1'

# Sidewalks / public access envelopes.
$m = Require-Match $realign ('walk\.Size\s*=\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\).*?walk\.CFrame\s*=\s*CFrame\.new\(x,\s*('+$num+')\s*,\s*('+$num+')\s*\)') 'NS sidewalk effective override'
$nsWalkSX=D $m.Groups[1].Value; $nsWalkSZ=D $m.Groups[3].Value; $nsWalkZ=D $m.Groups[5].Value
Add-Box 'NS_Sidewalk_W' 'path' -24.5 $nsWalkZ $nsWalkSX $nsWalkSZ 'structural-realignment'
Add-Box 'NS_Sidewalk_E' 'path' 24.5 $nsWalkZ $nsWalkSX $nsWalkSZ 'structural-realignment'
Add-LiteralPart $world 'EW_Sidewalk_N' 'path' 'world'
Add-LiteralPart $world 'EW_Sidewalk_S' 'path' 'world'
foreach($x in @(-143.5,-108.5,108.5,143.5)) { Add-Box "SideStreetSidewalk@$x" 'path' $x 98 7 190 'street-life' }
Add-Box 'CrossSidewalkN@62' 'path' 0 47 280 6 'street-life'
Add-Box 'CrossSidewalkS@62' 'path' 0 77 280 6 'street-life'

foreach($name in @('PathNorth','PathSouth','PathWest','PathEast')) { Add-LiteralPart $city $name 'path' 'city-life' }

# -------------------------------------------------------------------------
# Effective buildings.
# -------------------------------------------------------------------------
foreach($name in @('MainBuilding','LeftWing','RightWing')) { Add-LiteralPart $world $name 'building' 'world' 'school-core' }

# Base shop depth/Z must still be generated from world source; v0.4.6 supplies
# effective X/width. This keeps audit coupled to both generator and correction.
$m = Require-Match $world ('part\(shop,\s*"Building",\s*Vector3\.new\(\s*34\s*,\s*h\s*,\s*('+$num+')\s*\),\s*CFrame\.new\(x,\s*h\s*/\s*2\s*\+\s*1,\s*('+$num+')\s*\)') 'downtown shop base depth/Z'
$shopDepth = D $m.Groups[1].Value; $shopZ = D $m.Groups[2].Value
$shopMatches = [regex]::Matches($fix, '\{name\s*=\s*"(Shop_[^"]+)",\s*x\s*=\s*('+$num+'),\s*width\s*=\s*('+$num+')\}')
if($shopMatches.Count -ne 5) { throw "ASC v0.4.6 SHOP_LAYOUT must contain exactly 5 entries; got $($shopMatches.Count)" }
foreach($sm in $shopMatches) {
    Add-Box $sm.Groups[1].Value 'building' (D $sm.Groups[2].Value) $shopZ (D $sm.Groups[3].Value) $shopDepth 'source-spatial-fix'
}

# Residential Townhouse_2 is deliberately destroyed by v0.4.3.
Require-Token $layout 'centerHouse = residential:FindFirstChild("Townhouse_2")' 'Townhouse_2 lookup'
Require-Token $layout 'centerHouse:Destroy()' 'Townhouse_2 destroy'
Add-Box 'Townhouse_1' 'building' -235 -48 70 34 'world'
Add-Box 'Townhouse_3' 'building' -235 48 70 34 'world'

# Student canteen literal source footprint.
$m = Require-Match $school ('local\s+canteenX,\s*canteenZ\s*=\s*('+$num+')\s*,\s*('+$num+').*?part\(canteen,\s*"Floor",\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)') 'StudentCanteen geometry'
Add-Box 'StudentCanteen' 'building' (D $m.Groups[1].Value) (D $m.Groups[2].Value) (D $m.Groups[3].Value) (D $m.Groups[5].Value) 'school-life'

# Old v0.3 ClubHub is destroyed; v0.4.4 compact replacement is effective.
Require-Token $circ 'oldClub:Destroy()' 'old ClubHub destroy'
$m = Require-Match $circ ('local\s+cx,\s*cz\s*=\s*('+$num+')\s*,\s*('+$num+').*?local\s+width,\s*depth,\s*height\s*=\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')') 'ClubHubV044 geometry'
Add-Box 'ClubHubV044' 'building' (D $m.Groups[1].Value) (D $m.Groups[2].Value) (D $m.Groups[3].Value) (D $m.Groups[4].Value) 'circulation-sanitize'

# Student Row effective v0.4.1 footprints after 90-degree turns.
Require-Token $cleanup 'StudentMiniMart = {z = 108, yaw = 90}' 'StudentMiniMart effective placement'
Require-Token $cleanup 'StudyLounge = {z = 166, yaw = 90}' 'StudyLounge effective placement'
Require-Token $cleanup 'CommunityLibrary = {z = 112, yaw = -90}' 'CommunityLibrary effective placement'
Require-Token $layout 'youth:Destroy()' 'YouthStudio removal'
Require-Token $cleanup 'if bakery then bakery:Destroy() end' 'CornerBakery removal'
Require-Token $cleanup 'if tech then tech:Destroy() end' 'CornerTech removal'
Add-Box 'StudentMiniMart' 'building' -176 108 34 48 'spatial-cleanup'
Add-Box 'StudyLounge' 'building' -176 166 34 48 'spatial-cleanup'
Add-Box 'CommunityLibrary' 'building' 176 112 36 52 'spatial-cleanup'

Add-LiteralPart $world 'BasketballCourt' 'court' 'world'

# -------------------------------------------------------------------------
# Parking and effective parked vehicles.
# -------------------------------------------------------------------------
$lotPattern = 'parkingLot\(parking,\s*"([^"]+)",\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\),\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)\)'
$lotMatches = [regex]::Matches($cleanup, $lotPattern)
if($lotMatches.Count -ne 3) { throw "Expected 3 effective parking lots in v0.4.1, got $($lotMatches.Count)" }
foreach($lm in $lotMatches) { Add-Box $lm.Groups[1].Value 'parking' (D $lm.Groups[2].Value) (D $lm.Groups[4].Value) (D $lm.Groups[5].Value) (D $lm.Groups[7].Value) 'spatial-cleanup' }

$carPattern = 'parkedCar\(parking,\s*"([^"]+)",\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\),\s*('+$num+')\s*,'
$carMatches = [regex]::Matches($cleanup, $carPattern)
if($carMatches.Count -ne 6) { throw "Expected 6 effective parked cars in v0.4.1, got $($carMatches.Count)" }
foreach($cm in $carMatches) {
    $yaw = D $cm.Groups[5].Value; $sx=9.5; $sz=17.0
    if(([math]::Abs($yaw) % 180) -eq 90) { $tmp=$sx; $sx=$sz; $sz=$tmp }
    Add-Box $cm.Groups[1].Value 'vehicle' (D $cm.Groups[2].Value) (D $cm.Groups[4].Value) $sx $sz 'spatial-cleanup'
}

$m = Require-Match $fix ('local\s+BUS_TARGET_X\s*=\s*('+$num+').*?local\s+BUS_TARGET_Z\s*=\s*('+$num+')') 'v0.4.6 bus target'
Add-Box 'SchoolBusParked' 'vehicle' (D $m.Groups[1].Value) (D $m.Groups[2].Value) 30 11 'source-spatial-fix' '' 'yaw=90 effective footprint'

# -------------------------------------------------------------------------
# Effective trees and hedges.
# -------------------------------------------------------------------------
# Six original park trees are source literals in one list. Apply v0.4.6 exact
# relocation table to the two unsafe entries before adding their trunk AABBs.
$parkBlock = Require-Match $world 'for\s+_,\s*pos\s+in\s+ipairs\(\{(.*?)\}\)\s+do\s*\r?\n\s*tree\(landscaping,\s*pos,\s*0\.9\)' 'park tree source list'
$parkVectors = [regex]::Matches($parkBlock.Groups[1].Value, 'Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)')
if($parkVectors.Count -ne 6) { throw "Expected 6 world park trees, got $($parkVectors.Count)" }

$relocations = @{}
$relocPattern = '\{fromX\s*=\s*('+$num+'),\s*fromZ\s*=\s*('+$num+'),\s*toX\s*=\s*('+$num+'),\s*toZ\s*=\s*('+$num+')\}'
$relocMatches = [regex]::Matches($fix, $relocPattern)
if($relocMatches.Count -ne 2) { throw "Expected 2 v0.4.6 park tree relocations, got $($relocMatches.Count)" }
foreach($rm in $relocMatches) { $relocations["$($rm.Groups[1].Value),$($rm.Groups[2].Value)"] = @((D $rm.Groups[3].Value),(D $rm.Groups[4].Value)) }

$i=0
foreach($vm in $parkVectors) {
    $i++
    $x=D $vm.Groups[1].Value; $z=D $vm.Groups[3].Value
    $key="$($vm.Groups[1].Value),$($vm.Groups[3].Value)"
    if($relocations.ContainsKey($key)) { $x=$relocations[$key][0]; $z=$relocations[$key][1] }
    Add-Box "ParkTree#$i" 'tree' $x $z 1.62 1.62 'world+v0.4.6' # trunk only; crowns are CanCollide=false
}

# v0.4.1 corridor trees.
foreach($z in @(96.0,162.0)) {
    foreach($x in @(-66.0,66.0)) { Add-Box "CorridorTree@$x,$z" 'tree' $x $z 1.26 1.26 'spatial-cleanup' }
}

# Street-density block trees. Layout v0.4.3 removes the +151,+161 tree parts.
$streetTrees = @(
    @(-151.0,107.0), @(-151.0,157.0), @(151.0,111.0),
    @(-197.0,84.0), @(197.0,84.0)
)
foreach($p in $streetTrees) { Add-Box "StreetTree@$($p[0]),$($p[1])" 'tree' $p[0] $p[1] 1.296 1.296 'street-life/layout-effective' }

# Residential legacy trees.
foreach($z in @(-67.0,67.0)) { foreach($x in @(-292.0,-178.0)) { Add-Box "ResidentialTree@$x,$z" 'tree' $x $z 1.44 1.44 'world' } }

# The original school-front trees are intentionally excluded: v0.4.5 hard-clears
# all tree-like geometry in X +/-116, Z=214..286.
Require-Token $clearance 'return pos.Z >= 214 and pos.Z <= 286 and math.abs(pos.X) <= 116' 'school entrance hard-clear envelope'
$notes.Add('School-front source trees are excluded after the v0.4.5 x±116 / z214..286 destructive sanitize.') | Out-Null

# Effective residential hedges: v0.4.5 removes |Z|<=24.
Require-Token $clearance 'math.abs(obj.Position.Z) <= 24' 'residential hedge road sanitize'
foreach($z in @(-65.0,-49.0,-33.0,31.0,47.0,63.0)) { Add-Box "ResidentialHedge@$z" 'hedge' -174 $z 8 4 'city-life/v0.4.5-effective' }

# -------------------------------------------------------------------------
# Collision + clearance rules.
# -------------------------------------------------------------------------
$roads = @($boxes | Where-Object Kind -eq 'road')
$paths = @($boxes | Where-Object Kind -eq 'path')
$buildings = @($boxes | Where-Object Kind -eq 'building')
$trees = @($boxes | Where-Object Kind -eq 'tree')
$hedges = @($boxes | Where-Object Kind -eq 'hedge')
$vehicles = @($boxes | Where-Object Kind -eq 'vehicle')
$courts = @($boxes | Where-Object Kind -eq 'court')
$parkings = @($boxes | Where-Object Kind -eq 'parking')

foreach($b in $buildings) {
    foreach($r in $roads) {
        $d=Get-Separation $b $r
        if(Test-Overlap $b $r) { Add-Finding 'building-road-overlap' $b $r 'AABB overlap' }
        elseif($d -lt 1.0) { Add-Finding 'building-road-clearance' $b $r ("clearance {0:N2} < 1.0" -f $d) }
    }
    foreach($p in $paths) {
        $d=Get-Separation $b $p
        if(Test-Overlap $b $p) { Add-Finding 'building-path-overlap' $b $p 'AABB overlap' }
        elseif($d -lt 1.0) { Add-Finding 'building-path-clearance' $b $p ("clearance {0:N2} < 1.0" -f $d) }
    }
}

for($i=0;$i -lt $buildings.Count;$i++) {
    for($j=$i+1;$j -lt $buildings.Count;$j++) {
        $a=$buildings[$i]; $b=$buildings[$j]
        if($a.Group -and $a.Group -eq $b.Group) { continue }
        if(Test-Overlap $a $b) { Add-Finding 'building-building-overlap' $a $b 'AABB overlap' }
    }
}

foreach($obj in @($trees)+@($hedges)) {
    foreach($r in $roads) { if(Test-Overlap $obj $r) { Add-Finding "$($obj.Kind)-road-overlap" $obj $r 'AABB overlap' } }
    foreach($p in $paths) { if(Test-Overlap $obj $p) { Add-Finding "$($obj.Kind)-path-overlap" $obj $p 'AABB overlap' } }
}

foreach($v in $vehicles) {
    foreach($r in $roads) {
        $d=Get-Separation $v $r
        if(Test-Overlap $v $r) { Add-Finding 'vehicle-road-overlap' $v $r 'vehicle enters road envelope' }
        elseif($d -lt 4.0) { Add-Finding 'vehicle-road-clearance' $v $r ("clearance {0:N2} < 4.0" -f $d) }
    }
    foreach($b in $buildings) {
        $d=Get-Separation $v $b
        if(Test-Overlap $v $b -or $d -lt 4.0) { Add-Finding 'vehicle-building-clearance' $v $b ("clearance {0:N2} < 4.0" -f $d) }
    }
    foreach($t in $trees) {
        $d=Get-Separation $v $t
        if(Test-Overlap $v $t -or $d -lt 6.0) { Add-Finding 'tree-vehicle-clearance' $t $v ("clearance {0:N2} < 6.0" -f $d) }
    }
}

# Hard entrance circulation zone: no tree, hedge or vehicle.
Add-Box 'SchoolMainDoorCirculation' 'zone' 0 250 232 72 'policy'
$doorZone = $boxes[$boxes.Count-1]
foreach($obj in @($trees)+@($hedges)+@($vehicles)) {
    if(Test-Overlap $obj $doorZone) { Add-Finding 'school-entrance-circulation' $obj $doorZone 'object enters hard-clear x±116 / z214..286 envelope' }
}

foreach($court in $courts) {
    foreach($b in $buildings) {
        if($b.Group -eq 'school-core') { continue }
        $d=Get-Separation $court $b
        if(Test-Overlap $court $b -or $d -lt 6.0) { Add-Finding 'sports-court-building-clearance' $b $court ("clearance {0:N2} < 6.0" -f $d) }
    }
}

foreach($lot in $parkings) {
    foreach($b in $buildings) { if(Test-Overlap $lot $b) { Add-Finding 'parking-building-overlap' $lot $b 'AABB overlap' } }
    foreach($r in $roads) { if(Test-Overlap $lot $r) { Add-Finding 'parking-road-overlap' $lot $r 'AABB overlap' } }
}

# -------------------------------------------------------------------------
# Emit machine-readable report and fail closed.
# -------------------------------------------------------------------------
$counts = @{}
foreach($b in $boxes) { if(-not $counts.ContainsKey($b.Kind)){$counts[$b.Kind]=0}; $counts[$b.Kind]++ }
$status = if($findings.Count -eq 0){'PASS'}else{'FAIL'}
$report = [ordered]@{
    project='AFTER SCHOOL CITY'
    audit='CLOUD_SOURCE_SPATIAL_AUDIT_V2'
    sourceVersion='0.4.6-source-spatial-audit-fix-1'
    status=$status
    counts=$counts
    notes=@($notes)
    findings=@($findings)
    geometry=@($boxes)
}
$report | ConvertTo-Json -Depth 8 | Set-Content 'spatial-audit-after-school-city.json' -Encoding UTF8

Write-Host 'AFTER SCHOOL CITY — CLOUD SOURCE SPATIAL AUDIT V2'
Write-Host ("Geometry: " + (($counts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join ', '))
foreach($n in $notes){ Write-Host "NOTE: $n" }
if($findings.Count -gt 0) {
    foreach($f in $findings){ Write-Host "ERROR: $($f.Rule): $($f.A) <-> $($f.B): $($f.Detail)" }
    throw "AFTER SCHOOL CITY spatial audit FAIL: $($findings.Count) conflict(s)"
}
Write-Host 'PASS: no modeled collision/clearance conflicts after effective v0.4.6 source corrections'
