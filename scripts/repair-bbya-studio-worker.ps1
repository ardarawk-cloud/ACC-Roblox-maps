# BBYA Studio Worker interactive-session repair
# Run ONCE from an elevated PowerShell window logged in as Administrator on the BBYA EC2 host.
# Purpose: remove the GitHub Actions runner service (Session 0) and run it interactively in the Administrator desktop session so Roblox Studio/MCP can create a real GUI window.

$ErrorActionPreference = 'Stop'

$RunnerDir = 'C:\actions-runner'
$TaskName = 'BBYA-STUDIO-WORKER-INTERACTIVE'
$ServiceName = 'actions.runner.ardarawk-cloud-ACC-Roblox-maps.BBYA-STUDIO-WORKER'
$RunCmd = Join-Path $RunnerDir 'run.cmd'
$SvcCmd = Join-Path $RunnerDir 'svc.cmd'

function Require-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run this script from PowerShell as Administrator.'
    }
}

Require-Admin

if (-not (Test-Path $RunCmd)) { throw "Runner run.cmd not found: $RunCmd" }

Write-Host '[1/5] Stopping old Session-0 runner service...'
$svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($svc) {
    if ($svc.Status -ne 'Stopped') {
        Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
    if (Test-Path $SvcCmd) {
        Push-Location $RunnerDir
        try { & $SvcCmd uninstall | Out-Host } catch { Write-Warning $_.Exception.Message }
        Pop-Location
    } else {
        sc.exe delete $ServiceName | Out-Host
    }
}

Write-Host '[2/5] Removing stale interactive task...'
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

Write-Host '[3/5] Creating interactive Administrator task...'
$action = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "/c cd /d $RunnerDir && run.cmd"
$principal = New-ScheduledTaskPrincipal -UserId 'Administrator' -LogonType Interactive -RunLevel Highest
$trigger = New-ScheduledTaskTrigger -AtLogOn -User 'Administrator'
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -RestartCount 999 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit ([TimeSpan]::Zero)

Register-ScheduledTask -TaskName $TaskName -Action $action -Principal $principal -Trigger $trigger -Settings $settings -Force | Out-Null

Write-Host '[4/5] Starting interactive runner now...'
Start-ScheduledTask -TaskName $TaskName
Start-Sleep -Seconds 5

Write-Host '[5/5] Verifying session placement...'
$runner = Get-CimInstance Win32_Process | Where-Object { $_.Name -match 'Runner.Listener|cmd.exe' -and $_.CommandLine -match 'actions-runner|run\.cmd' }
$studio = Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue
$quser = (quser 2>&1 | Out-String).Trim()

Write-Host '--- QUSER ---'
Write-Host $quser
Write-Host '--- RUNNER ---'
$runner | Select-Object ProcessId,Name,CommandLine | Format-Table -AutoSize
Write-Host '--- STUDIO ---'
if ($studio) {
    $studio | Select-Object Id,SessionId,MainWindowHandle,MainWindowTitle | Format-Table -AutoSize
} else {
    Write-Host 'Roblox Studio not running yet (expected until next visual/MCP audit).'
}

Write-Host ''
Write-Host 'BBYA interactive runner repair installed.'
Write-Host 'The GitHub runner should now execute jobs inside the Administrator desktop session instead of Windows Session 0.'
