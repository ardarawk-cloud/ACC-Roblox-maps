$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$map=Join-Path (Resolve-Path '.').Path 'maps/after-school-city'
$interiorPath=Join-Path $map 'after-school-city.school-interior.server.lua'
$configPath=Join-Path $map 'after-school-city.config.lua'
$projectPath=Join-Path $map 'default.project.json'
if(-not (Test-Path $interiorPath)){throw 'School interior source missing'}
$interior=Get-Content $interiorPath -Raw
$config=Get-Content $configPath -Raw
$project=Get-Content $projectPath -Raw
$null=$project|ConvertFrom-Json

function Token([string]$text,[string]$token,[string]$label){if($text.IndexOf($token,[StringComparison]::Ordinal)-lt 0){throw "ASC school interior contract missing: $label"}}
function NumberAfter([string]$text,[string]$name){$m=[regex]::Match($text,[regex]::Escape($name)+'\s*=\s*([0-9.]+)');if(-not $m.Success){throw "Numeric contract missing: $name"};return [double]$m.Groups[1].Value}

Token $interior 'V070_SchoolInterior' 'interior layer'
Token $interior '0.7.0-school-interior-1' 'version'
Token $interior 'waitForWorkspaceAttribute("ASC_PremiumExteriorPass", 45)' 'V0.6 completion gate'
foreach($token in @('MainBuilding','LeftWing','RightWing','ASC_InteriorVoid','ASC_ExteriorEnvelopePreserved','InteriorShell')){Token $interior $token $token}
foreach($token in @('WELCOME / MAIN HALL','CLASSROOM A','CLASSROOM B','HallLockers','LIBRARY','CANTEEN','TEACHER / ADMIN','MUSIC CLUB','ART CLUB','SchoolToilets')){Token $interior $token $token}
foreach($token in @('ASC_SchoolInteriorAccessible','ASC_SchoolExteriorEnvelopePreserved','ASC_SchoolInteriorPartCount','ASC_SchoolInteriorLightCount')){Token $interior $token $token}

$parts=NumberAfter $interior 'INTERIOR_PART_BUDGET'
$lights=NumberAfter $interior 'INTERIOR_LIGHT_BUDGET'
$brightness=NumberAfter $interior 'INTERIOR_LIGHT_MAX_BRIGHTNESS'
$range=NumberAfter $interior 'INTERIOR_LIGHT_MAX_RANGE'
if($parts -gt 240){throw "Interior part budget too high: $parts"}
if($lights -gt 10){throw "Interior light budget too high: $lights"}
if($brightness -gt 0.22){throw "Interior light brightness too high: $brightness"}
if($range -gt 10){throw "Interior light range too high: $range"}

foreach($forbidden in @('MarketplaceService','PromptProductPurchase','ProcessReceipt','DataStoreService','NorthSouthRoad','Shop_STYLE','Shop_MUSIC','Shop_HOBBY','BillboardGui')){if($interior -match [regex]::Escape($forbidden)){throw "Forbidden V0.7 scope token: $forbidden"}}

foreach($token in @('Version = "0.7.0-school-interior-1"','SchoolInteriorVersion = "0.7.0-school-interior-1"','EnableSchoolInteriorPass = true','EnableActivities = false','EnableEconomy = false','EnablePersistence = false','EnablePersonalRoom = false','EnableClubs = false')){Token $config $token $token}
Token $project 'ASC_SchoolInterior' 'Rojo node'
Token $project 'after-school-city.school-interior.server.lua' 'Rojo source'
$idx060=$project.IndexOf('ASC_PremiumExterior',[StringComparison]::Ordinal)
$idx070=$project.IndexOf('ASC_SchoolInterior',[StringComparison]::Ordinal)
if($idx060 -lt 0 -or $idx070 -lt 0 -or $idx070 -le $idx060){throw 'Rojo ordering invalid: V0.7 must follow V0.6'}

$report=[ordered]@{project='AFTER SCHOOL CITY';audit='SCHOOL_INTERIOR_AUDIT_V1';sourceVersion='0.7.0-school-interior-1';status='PASS';partBudget=$parts;lightBudget=$lights;accessible=$true;exteriorEnvelopePreserved=$true;gameplayAuthorityEnabled=$false}
$report|ConvertTo-Json -Depth 4|Set-Content 'school-interior-audit-after-school-city.json' -Encoding UTF8
Write-Host "PASS: AFTER SCHOOL CITY V0.7 school interior contract; parts<=$parts lights<=$lights"
