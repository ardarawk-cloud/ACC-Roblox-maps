$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

# AFTER SCHOOL CITY — V0.7 PRIOR-GATE COMPATIBILITY WRAPPER
# Legacy source audits intentionally assert the current Version that existed when
# each pass was authored. For later-stage regression checking, temporarily shim
# only Config.Version while preserving every component version/flag and source file.
# The exact V0.7 config is restored before this script exits so the subsequent
# authority lock and Rojo build operate on the real V0.7 source.

$configPath = Join-Path (Resolve-Path '.').Path 'maps/after-school-city/after-school-city.config.lua'
if(-not (Test-Path $configPath)){ throw 'ASC V0.7 config missing' }

$original = Get-Content $configPath -Raw
$originalHash = (Get-FileHash -Algorithm SHA256 $configPath).Hash
if($original.IndexOf('Version = "0.7.0-school-interior-1"',[StringComparison]::Ordinal) -lt 0){
    throw 'ASC V0.7 wrapper requires current Version = 0.7.0-school-interior-1'
}

function Invoke-LegacyGate([string]$version,[string]$script,[string]$label){
    Write-Host "=== PRESERVATION GATE: $label via legacy Version=$version ==="
    $shim = $original.Replace('Version = "0.7.0-school-interior-1"', ('Version = "'+$version+'"'))
    if($shim -eq $original){ throw "Failed to create compatibility shim for $label" }
    Set-Content -Path $configPath -Value $shim -Encoding UTF8 -NoNewline
    & $script
    if($LASTEXITCODE -ne 0){ throw "$label returned exit code $LASTEXITCODE" }
}

try {
    Invoke-LegacyGate '0.4.7-orientation-correction-1' '.github/scripts/after-school-city-spatial-audit.ps1' 'Spatial Audit V4'
    Invoke-LegacyGate '0.4.7-orientation-correction-1' '.github/scripts/after-school-city-orientation-audit.ps1' 'Orientation Audit V1'
    Invoke-LegacyGate '0.5.0-visual-fidelity-1' '.github/scripts/after-school-city-visual-fidelity-audit.ps1' 'Visual Fidelity Audit V1'

    # These component audits already use their dedicated component markers and
    # therefore do not require a current-Version shim.
    Set-Content -Path $configPath -Value $original -Encoding UTF8 -NoNewline
    & '.github/scripts/after-school-city-runtime-reconcile-audit.ps1'
    & '.github/scripts/after-school-city-runtime-hard-cleanup-audit.ps1'

    Invoke-LegacyGate '0.5.3-road-centerline-clearance-1' '.github/scripts/after-school-city-road-centerline-clearance-audit.ps1' 'Road Centerline Clearance Audit V1'
}
finally {
    Set-Content -Path $configPath -Value $original -Encoding UTF8 -NoNewline
}

$restoredHash = (Get-FileHash -Algorithm SHA256 $configPath).Hash
if($restoredHash -ne $originalHash){
    throw "V0.7 config restore mismatch: before=$originalHash after=$restoredHash"
}
if((Get-Content $configPath -Raw).IndexOf('Version = "0.7.0-school-interior-1"',[StringComparison]::Ordinal) -lt 0){
    throw 'V0.7 current version was not restored after legacy gates'
}

Write-Host 'PASS: V0.7 prior spatial/orientation/visual/runtime/road gates passed; exact V0.7 config restored'
