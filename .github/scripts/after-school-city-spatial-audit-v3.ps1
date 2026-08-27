$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# AFTER SCHOOL CITY — CLOUD SOURCE SPATIAL AUDIT V3
# Fail-closed source parser + effective X/Z AABB clearance model.

$map = Join-Path (Resolve-Path '.').Path 'maps/after-school-city'
function Src([string]$file) {
    $p = Join-Path $map $file
    if(-not (Test-Path $p)){ throw "ASC source missing: $file" }
    Get-Content $p -Raw
}

$world=Src 'after-school-city.world.server.lua'
$school=Src 'after-school-city.school-life.server.lua'
$city=Src 'after-school-city.city-life.server.lua'
$street=Src 'after-school-city.street-life.server.lua'
$cleanup=Src 'after-school-city.spatial-cleanup.server.lua'
$realign=Src 'after-school-city.structural-realignment.server.lua'
$layout=Src 'after-school-city.layout-correction.server.lua'
$circ=Src 'after-school-city.circulation-sanitize.server.lua'
$clearance=Src 'after-school-city.clearance-sanitize.server.lua'
$fix=Src 'after-school-city.source-spatial-fix.server.lua'
$config=Src 'after-school-city.config.lua'
$project=Src 'default.project.json'

$num='-?(?:\d+(?:\.\d*)?|\.\d+)'
$inv=[Globalization.CultureInfo]::InvariantCulture
function N([string]$s){ [double]::Parse($s,[Globalization.NumberStyles]::Float,$inv) }
function Need([string]$text,[string]$pattern,[string]$label){
    $m=[regex]::Match($text,$pattern,[Text.RegularExpressions.RegexOptions]::Singleline)
    if(-not $m.Success){ throw "ASC spatial parser contract missing: $label" }
    $m
}
function Token([string]$text,[string]$token,[string]$label){
    if($text.IndexOf($token,[StringComparison]::Ordinal) -lt 0){ throw "ASC source contract missing: $label" }
}

$boxes=[System.Collections.Generic.List[object]]::new()
$findings=[System.Collections.Generic.List[object]]::new()
$notes=[System.Collections.Generic.List[string]]::new()
function Box([string]$name,[string]$kind,[double]$x,[double]$z,[double]$sx,[double]$sz,[string]$source,[string]$group=''){
    $sx=[math]::Abs($sx); $sz=[math]::Abs($sz)
    $boxes.Add([pscustomobject]@{Name=$name;Kind=$kind;X=$x;Z=$z;SX=$sx;SZ=$sz;XMin=$x-$sx/2;XMax=$x+$sx/2;ZMin=$z-$sz/2;ZMax=$z+$sz/2;Source=$source;Group=$group})|Out-Null
}
function Hit($a,$b){ ($a.XMin -lt $b.XMax) -and ($a.XMax -gt $b.XMin) -and ($a.ZMin -lt $b.ZMax) -and ($a.ZMax -gt $b.ZMin) }
function Gap($a,$b){
    $dx=[math]::Max([math]::Max($b.XMin-$a.XMax,$a.XMin-$b.XMax),0)
    $dz=[math]::Max([math]::Max($b.ZMin-$a.ZMax,$a.ZMin-$b.ZMax),0)
    [math]::Sqrt($dx*$dx+$dz*$dz)
}
function Fail([string]$rule,$a,$b,[string]$detail){
    $findings.Add([pscustomobject]@{Severity='ERROR';Rule=$rule;A=$a.Name;B=$b.Name;Detail=$detail})|Out-Null
}
function LiteralPart([string]$text,[string]$name,[string]$kind,[string]$source,[string]$group=''){
    $e=[regex]::Escape($name)
    $p='part\([^\r\n]+,\s*"'+$e+'"\s*,\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)\s*,\s*CFrame\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)'
    $m=Need $text $p "$source/$name"
    Box $name $kind (N $m.Groups[4].Value) (N $m.Groups[6].Value) (N $m.Groups[1].Value) (N $m.Groups[3].Value) $source $group
}

# Ordered late-pass contract.
Token $cleanup 'root:WaitForChild("V04_StreetLife", 20)' 'v0.4.1 order'
Token $realign 'root:WaitForChild("V041_SpatialCleanup", 20)' 'v0.4.2 order'
Token $layout 'root:WaitForChild("V042_StructuralRealignment", 20)' 'v0.4.3 order'
Token $circ 'root:WaitForChild("V043_LayoutCorrection", 20)' 'v0.4.4 order'
Token $clearance 'root:WaitForChild("V044_CirculationSanitize", 20)' 'v0.4.5 order'
Token $fix 'root:WaitForChild("V045_ClearanceSanitize", 20)' 'v0.4.6 order'
Token $config 'Version = "0.4.6-source-spatial-audit-fix-1"' 'v0.4.6 config'
Token $config 'EnableSourceSpatialFixPass = true' 'v0.4.6 flag'
Token $project 'ASC_SourceSpatialFix' 'v0.4.6 Rojo wiring'

# Roads parsed from generator / effective override source.
LiteralPart $world 'EastWestRoad' 'road' 'world'
$m=Need $realign ('nsRoad\.Size\s*=\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\).*?nsRoad\.CFrame\s*=\s*CFrame\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)') 'effective NorthSouthRoad'
Box 'NorthSouthRoad' 'road' (N $m.Groups[4].Value) (N $m.Groups[6].Value) (N $m.Groups[1].Value) (N $m.Groups[3].Value) 'v0.4.2'
$m=Need $cleanup ('schoolSportsRoad\.Size\s*=\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\).*?schoolSportsRoad\.CFrame\s*=\s*CFrame\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)') 'effective SchoolSportsRoad'
Box 'SchoolSportsRoad' 'road' (N $m.Groups[4].Value) (N $m.Groups[6].Value) (N $m.Groups[1].Value) (N $m.Groups[3].Value) 'v0.4.1'
Token $street 'for _, x in ipairs({-126, 126}) do' 'side-street centers'
Token $street 'Vector3.new(28, 0.6, 190), CFrame.new(x, 1.05, 98)' 'side-street geometry'
Box 'SideStreetWest' 'road' -126 98 28 190 'v0.4'; Box 'SideStreetEast' 'road' 126 98 28 190 'v0.4'
Token $street 'for _, z in ipairs({62, 132}) do' 'cross-street centers'; Token $cleanup 'child.Position.Z > 100' 'Z132 cross-street removal'
Box 'CrossStreet62' 'road' 0 62 280 24 'v0.4/v0.4.1'

# Walkable/access envelopes.
$m=Need $realign ('walk\.Size\s*=\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\).*?walk\.CFrame\s*=\s*CFrame\.new\(x,\s*('+$num+')\s*,\s*('+$num+')\s*\)') 'effective NS sidewalks'
$wsx=N $m.Groups[1].Value; $wsz=N $m.Groups[3].Value; $wz=N $m.Groups[5].Value
Box 'NS_Sidewalk_W' 'path' -24.5 $wz $wsx $wsz 'v0.4.2'; Box 'NS_Sidewalk_E' 'path' 24.5 $wz $wsx $wsz 'v0.4.2'
LiteralPart $world 'EW_Sidewalk_N' 'path' 'world'; LiteralPart $world 'EW_Sidewalk_S' 'path' 'world'
foreach($x in @(-143.5,-108.5,108.5,143.5)){ Box "SideStreetWalk$x" 'path' $x 98 7 190 'v0.4' }
Box 'CrossWalkN62' 'path' 0 47 280 6 'v0.4'; Box 'CrossWalkS62' 'path' 0 77 280 6 'v0.4'
foreach($p in @('PathNorth','PathSouth','PathWest','PathEast')){ LiteralPart $city $p 'path' 'v0.3-city-life' }

# School core and sports.
foreach($b in @('MainBuilding','LeftWing','RightWing')){ LiteralPart $world $b 'building' 'world' 'school-core' }
LiteralPart $world 'BasketballCourt' 'court' 'world'

# v0.4.6 shop contract is parsed, while base depth/Z remains sourced from world.
$m=Need $world ('part\(shop,\s*"Building",\s*Vector3\.new\(\s*34\s*,\s*h\s*,\s*('+$num+')\s*\),\s*CFrame\.new\(x,\s*h\s*/\s*2\s*\+\s*1,\s*('+$num+')\s*\)') 'shop base depth/Z'
$shopDepth=N $m.Groups[1].Value; $shopZ=N $m.Groups[2].Value
$shopRx='\{name\s*=\s*"(Shop_[^"]+)",\s*x\s*=\s*('+$num+'),\s*width\s*=\s*('+$num+')\}'
$shops=[regex]::Matches($fix,$shopRx)
if($shops.Count -ne 5){ throw "SHOP_LAYOUT expected 5 entries, got $($shops.Count)" }
foreach($s in $shops){ Box $s.Groups[1].Value 'building' (N $s.Groups[2].Value) $shopZ (N $s.Groups[3].Value) $shopDepth 'v0.4.6' }

# Other effective building footprints, guarded by source markers.
Token $layout 'centerHouse:Destroy()' 'center townhouse removal'; Box 'Townhouse_1' 'building' -235 -48 70 34 'world/v0.4.3'; Box 'Townhouse_3' 'building' -235 48 70 34 'world/v0.4.3'
$m=Need $school ('local\s+canteenX,\s*canteenZ\s*=\s*('+$num+')\s*,\s*('+$num+').*?part\(canteen,\s*"Floor",\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)') 'StudentCanteen'
Box 'StudentCanteen' 'building' (N $m.Groups[1].Value) (N $m.Groups[2].Value) (N $m.Groups[3].Value) (N $m.Groups[5].Value) 'v0.3-school'
Token $circ 'oldClub:Destroy()' 'old ClubHub removal'
$m=Need $circ ('local\s+cx,\s*cz\s*=\s*('+$num+')\s*,\s*('+$num+').*?local\s+width,\s*depth,\s*height\s*=\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')') 'ClubHubV044'
Box 'ClubHubV044' 'building' (N $m.Groups[1].Value) (N $m.Groups[2].Value) (N $m.Groups[3].Value) (N $m.Groups[4].Value) 'v0.4.4'
Token $cleanup 'StudentMiniMart = {z = 108, yaw = 90}' 'MiniMart effective transform'; Token $cleanup 'StudyLounge = {z = 166, yaw = 90}' 'StudyLounge effective transform'; Token $cleanup 'CommunityLibrary = {z = 112, yaw = -90}' 'Library effective transform'
Token $layout 'youth:Destroy()' 'YouthStudio removal'; Token $cleanup 'if bakery then bakery:Destroy() end' 'Bakery removal'; Token $cleanup 'if tech then tech:Destroy() end' 'Tech removal'
Box 'StudentMiniMart' 'building' -176 108 34 48 'v0.4.1'; Box 'StudyLounge' 'building' -176 166 34 48 'v0.4.1'; Box 'CommunityLibrary' 'building' 176 112 36 52 'v0.4.1'

# Effective parking + cars parsed directly from v0.4.1.
$lotRx='parkingLot\(parking,\s*"([^"]+)",\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\),\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)\)'
$lots=[regex]::Matches($cleanup,$lotRx); if($lots.Count -ne 3){ throw "Expected 3 effective parking lots, got $($lots.Count)" }
foreach($l in $lots){ Box $l.Groups[1].Value 'parking' (N $l.Groups[2].Value) (N $l.Groups[4].Value) (N $l.Groups[5].Value) (N $l.Groups[7].Value) 'v0.4.1' }
$carRx='parkedCar\(parking,\s*"([^"]+)",\s*Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\),\s*('+$num+')\s*,'
$cars=[regex]::Matches($cleanup,$carRx); if($cars.Count -ne 6){ throw "Expected 6 effective cars, got $($cars.Count)" }
foreach($c in $cars){ $yaw=N $c.Groups[5].Value; $sx=9.5; $sz=17.0; if(([math]::Abs($yaw)%180)-eq 90){$q=$sx;$sx=$sz;$sz=$q}; Box $c.Groups[1].Value 'vehicle' (N $c.Groups[2].Value) (N $c.Groups[4].Value) $sx $sz 'v0.4.1' }
$m=Need $fix ('local\s+BUS_TARGET_X\s*=\s*('+$num+').*?local\s+BUS_TARGET_Z\s*=\s*('+$num+')') 'bus v0.4.6 target'
Box 'SchoolBusParked' 'vehicle' (N $m.Groups[1].Value) (N $m.Groups[2].Value) 30 11 'v0.4.6'

# Trees: parse six park source vectors, then apply exact relocation table.
$pm=Need $world 'for\s+_,\s*pos\s+in\s+ipairs\(\{(.*?)\}\)\s+do\s*\r?\n\s*tree\(landscaping,\s*pos,\s*0\.9\)' 'park tree list'
$pv=[regex]::Matches($pm.Groups[1].Value,'Vector3\.new\(\s*('+$num+')\s*,\s*('+$num+')\s*,\s*('+$num+')\s*\)'); if($pv.Count -ne 6){ throw "Expected 6 park trees, got $($pv.Count)" }
$rrx='\{fromX\s*=\s*('+$num+'),\s*fromZ\s*=\s*('+$num+'),\s*toX\s*=\s*('+$num+'),\s*toZ\s*=\s*('+$num+')\}'
$rr=[regex]::Matches($fix,$rrx); if($rr.Count -ne 2){ throw "Expected 2 park relocations, got $($rr.Count)" }
$rel=@{}; foreach($r in $rr){ $rel["$($r.Groups[1].Value),$($r.Groups[2].Value)"]=[pscustomobject]@{X=N $r.Groups[3].Value;Z=N $r.Groups[4].Value} }
$i=0; foreach($v in $pv){ $i++; $x=N $v.Groups[1].Value; $z=N $v.Groups[3].Value; $k="$($v.Groups[1].Value),$($v.Groups[3].Value)"; if($rel.ContainsKey($k)){$x=$rel[$k].X;$z=$rel[$k].Z}; Box "ParkTree$i" 'tree' $x $z 1.62 1.62 'world+v0.4.6' }
foreach($z in @(96.0,162.0)){ foreach($x in @(-66.0,66.0)){ Box "CorridorTree$x/$z" 'tree' $x $z 1.26 1.26 'v0.4.1' } }
$st=@(
    [pscustomobject]@{X=-151.0;Z=107.0},[pscustomobject]@{X=-151.0;Z=157.0},[pscustomobject]@{X=151.0;Z=111.0},
    [pscustomobject]@{X=-197.0;Z=84.0},[pscustomobject]@{X=197.0;Z=84.0}
)
Token $layout 'obj.Position.X > 145 and obj.Position.Z > 145' 'east sports-edge tree cleanup'
foreach($t in $st){ Box "StreetTree$($t.X)/$($t.Z)" 'tree' $t.X $t.Z 1.296 1.296 'v0.4/v0.4.3' }
foreach($z in @(-67.0,67.0)){ foreach($x in @(-292.0,-178.0)){ Box "ResidentialTree$x/$z" 'tree' $x $z 1.44 1.44 'world' } }
Token $clearance 'return pos.Z >= 214 and pos.Z <= 286 and math.abs(pos.X) <= 116' 'school tree hard-clear zone'; $notes.Add('v0.4.5 removes all tree-like geometry inside school x±116 / z214..286.')|Out-Null
Token $clearance 'math.abs(obj.Position.Z) <= 24' 'residential hedge sanitize'; foreach($z in @(-65.0,-49.0,-33.0,31.0,47.0,63.0)){ Box "ResidentialHedge$z" 'hedge' -174 $z 8 4 'v0.3/v0.4.5' }

$roads=@($boxes|Where-Object Kind -eq 'road'); $paths=@($boxes|Where-Object Kind -eq 'path'); $buildings=@($boxes|Where-Object Kind -eq 'building'); $trees=@($boxes|Where-Object Kind -eq 'tree'); $hedges=@($boxes|Where-Object Kind -eq 'hedge'); $vehicles=@($boxes|Where-Object Kind -eq 'vehicle'); $courts=@($boxes|Where-Object Kind -eq 'court'); $parking=@($boxes|Where-Object Kind -eq 'parking')

foreach($b in $buildings){
    foreach($r in $roads){$d=Gap $b $r;if(Hit $b $r){Fail 'building-road-overlap' $b $r 'AABB overlap'}elseif($d-lt 1){Fail 'building-road-clearance' $b $r ("{0:N2} studs < 1"-f $d)}}
    foreach($p in $paths){$d=Gap $b $p;if(Hit $b $p){Fail 'building-path-overlap' $b $p 'AABB overlap'}elseif($d-lt 1){Fail 'building-path-clearance' $b $p ("{0:N2} studs < 1"-f $d)}}
}
for($i=0;$i-lt$buildings.Count;$i++){for($j=$i+1;$j-lt$buildings.Count;$j++){ $a=$buildings[$i];$b=$buildings[$j];if($a.Group-and$a.Group-eq$b.Group){continue};if(Hit $a $b){Fail 'building-building-overlap' $a $b 'AABB overlap'} }}
foreach($o in ($trees+$hedges)){foreach($r in $roads){if(Hit $o $r){Fail "$($o.Kind)-road-overlap" $o $r 'AABB overlap'}};foreach($p in $paths){if(Hit $o $p){Fail "$($o.Kind)-path-overlap" $o $p 'AABB overlap'}}}
foreach($v in $vehicles){
    foreach($r in $roads){$d=Gap $v $r;if(Hit $v $r){Fail 'vehicle-road-overlap' $v $r 'AABB overlap'}elseif($d-lt 4){Fail 'vehicle-road-clearance' $v $r ("{0:N2} studs < 4"-f $d)}}
    foreach($b in $buildings){$d=Gap $v $b;if((Hit $v $b)-or($d-lt 4)){Fail 'vehicle-building-clearance' $v $b ("{0:N2} studs < 4"-f $d)}}
    foreach($t in $trees){$d=Gap $v $t;if((Hit $v $t)-or($d-lt 6)){Fail 'tree-vehicle-clearance' $t $v ("{0:N2} studs < 6"-f $d)}}
}
Box 'SchoolMainDoorCirculation' 'zone' 0 250 232 72 'policy';$door=$boxes[$boxes.Count-1];foreach($o in ($trees+$hedges+$vehicles)){if(Hit $o $door){Fail 'school-entrance-circulation' $o $door 'object enters x±116 / z214..286'}}
foreach($c in $courts){foreach($b in $buildings){if($b.Group-eq'school-core'){continue};$d=Gap $c $b;if((Hit $c $b)-or($d-lt 6)){Fail 'sports-court-building-clearance' $b $c ("{0:N2} studs < 6"-f $d)}}}
foreach($p in $parking){foreach($b in $buildings){if(Hit $p $b){Fail 'parking-building-overlap' $p $b 'AABB overlap'}};foreach($r in $roads){if(Hit $p $r){Fail 'parking-road-overlap' $p $r 'AABB overlap'}}}

$counts=@{};foreach($b in $boxes){if(-not $counts.ContainsKey($b.Kind)){$counts[$b.Kind]=0};$counts[$b.Kind]++}
$status=if($findings.Count-eq 0){'PASS'}else{'FAIL'}
[ordered]@{project='AFTER SCHOOL CITY';audit='CLOUD_SOURCE_SPATIAL_AUDIT_V3';sourceVersion='0.4.6-source-spatial-audit-fix-1';status=$status;counts=$counts;notes=@($notes);findings=@($findings);geometry=@($boxes)}|ConvertTo-Json -Depth 8|Set-Content 'spatial-audit-after-school-city.json' -Encoding UTF8
Write-Host 'AFTER SCHOOL CITY — CLOUD SOURCE SPATIAL AUDIT V3'
Write-Host ("Geometry: "+(($counts.GetEnumerator()|Sort-Object Name|ForEach-Object{"$($_.Name)=$($_.Value)"})-join ', '))
if($findings.Count-gt 0){foreach($f in $findings){Write-Host "ERROR: $($f.Rule): $($f.A) <-> $($f.B): $($f.Detail)"};throw "ASC spatial audit FAIL: $($findings.Count) conflict(s)"}
Write-Host 'PASS: no modeled collision/clearance conflicts after effective v0.4.6 source corrections'
