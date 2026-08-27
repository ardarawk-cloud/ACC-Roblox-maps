$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Stable workflow entrypoint. Keep workflow references fixed while the audit
# implementation evolves behind this wrapper.
$impl = Join-Path $PSScriptRoot 'after-school-city-spatial-audit-v3.ps1'
if(-not (Test-Path $impl)){ throw "ASC spatial audit implementation missing: $impl" }
& $impl
