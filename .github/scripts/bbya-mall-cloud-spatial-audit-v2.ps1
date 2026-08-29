$ErrorActionPreference='Stop'
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class BBYAMallNative {
 [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd,out RECT r);
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd,int cmd);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
}
'@

$repo=(Get-Location).Path
$map=Join-Path $repo 'maps/bbya-social-hub'
$out=Join-Path $env:RUNNER_TEMP 'bbya-mall-spatial-audit-v2'
Remove-Item $out -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $out | Out-Null
$utf8=New-Object System.Text.UTF8Encoding($false)

function Get-StudioProcess {
 Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue | Where-Object {$_.MainWindowHandle -ne 0} | Sort-Object StartTime -Descending | Select-Object -First 1
}
function Get-StudioRoot {
 $p=Get-StudioProcess
 if(-not $p){return $null}
 $p.Refresh(); $h=[IntPtr]$p.MainWindowHandle
 if($h -eq [IntPtr]::Zero){return $null}
 try{return [System.Windows.Automation.AutomationElement]::FromHandle($h)}catch{return $null}
}
function Find-ByAutomationId($root,[string]$id){
 if(-not $root){return $null}
 $c=New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::AutomationIdProperty,$id)
 try{return $root.FindFirst([System.Windows.Automation.TreeScope]::Descendants,$c)}catch{return $null}
}
function Get-CommandBar {
 $root=Get-StudioRoot
 if(-not $root){return @($null,$null,$null)}
 return @($root,(Find-ByAutomationId $root 'commandBarScriptEditor'),(Find-ByAutomationId $root 'multiLineRunButtonContainer.commandBarRunButton'))
}
function Invoke-DesktopButton([string]$name){
 $desktop=[System.Windows.Automation.AutomationElement]::RootElement
 $c=New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty,$name)
 $b=$desktop.FindFirst([System.Windows.Automation.TreeScope]::Descendants,$c)
 if($b){try{$b.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke();Start-Sleep -Milliseconds 600;return $true}catch{}}
 return $false
}
function Dismiss-StudioDialogs {
 [void](Invoke-DesktopButton 'Always Continue')
 [void](Invoke-DesktopButton 'Continue')
}
function Ensure-CommandBar {
 for($try=0;$try -lt 12;$try++){
  $pair=Get-CommandBar
  if($pair[1] -and $pair[2]){Write-Host '[MALL_CLOUD_UI]|COMMAND_BAR_VISIBLE';return $pair}
  $root=$pair[0]
  if(-not $root){Start-Sleep -Seconds 1;continue}
  Dismiss-StudioDialogs
  $viewCond=New-Object System.Windows.Automation.AndCondition(
   (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty,[System.Windows.Automation.ControlType]::MenuItem)),
   (New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty,'View')))
  $view=$null
  try{$view=$root.FindFirst([System.Windows.Automation.TreeScope]::Descendants,$viewCond)}catch{}
  if($view){
   try{$view.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke()}catch{try{$view.GetCurrentPattern([System.Windows.Automation.ExpandCollapsePattern]::Pattern).Expand()}catch{}}
   Start-Sleep -Milliseconds 700
   $desktop=[System.Windows.Automation.AutomationElement]::RootElement
   $menuCond=New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty,[System.Windows.Automation.ControlType]::MenuItem)
   $items=$desktop.FindAll([System.Windows.Automation.TreeScope]::Descendants,$menuCond)
   $names=New-Object System.Collections.Generic.List[string]
   $cmdItem=$null
   for($i=0;$i -lt $items.Count;$i++){
    $it=$items.Item($i)
    try{
     $n=$it.Current.Name
     if($n){$names.Add($n)}
     if($n -match '^Command\s*Bar$'){$cmdItem=$it;break}
    }catch{}
   }
   if($cmdItem){
    Write-Host '[MALL_CLOUD_UI]|VIEW_COMMAND_BAR_FOUND'
    try{$cmdItem.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke()}catch{try{$cmdItem.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern).Select()}catch{}}
    Start-Sleep -Seconds 2
   } else {
    Write-Host ('[MALL_CLOUD_UI]|VIEW_ITEMS|'+(($names|Select-Object -Unique) -join ' | '))
   }
  }
  Start-Sleep -Seconds 1
 }
 throw 'Studio Command Bar could not be exposed from View menu'
}
function Run-StudioCommand([string]$code){
 $pair=Ensure-CommandBar
 $edit=$pair[1];$run=$pair[2]
 $vp=$edit.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern)
 $ip=$run.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
 $vp.SetValue($code)
 Start-Sleep -Milliseconds 300
 $ip.Invoke()
}
function Recent-StudioLines([string]$pattern){
 $lines=@()
 $logs=Get-ChildItem 'C:\Users\Administrator\AppData\Local\Roblox\logs' -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 8
 foreach($f in $logs){
  $m=Select-String -Path $f.FullName -Pattern $pattern -ErrorAction SilentlyContinue
  foreach($x in $m){$lines+=$x.Line}
 }
 return $lines
}

# Exact canonical Mall audit build.
$toolDir=Join-Path $env:RUNNER_TEMP 'bbya-rojo-7.7.0'
New-Item -ItemType Directory -Force -Path $toolDir | Out-Null
$rojo=Join-Path $toolDir 'rojo.exe'
if(-not (Test-Path $rojo)){
 $zip=Join-Path $env:RUNNER_TEMP 'rojo-7.7.0-windows-x86_64.zip'
 Invoke-WebRequest -Uri 'https://github.com/rojo-rbx/rojo/releases/download/v7.7.0/rojo-7.7.0-windows-x86_64.zip' -OutFile $zip
 Expand-Archive -LiteralPath $zip -DestinationPath $toolDir -Force
}
if((& $rojo --version) -notmatch '7\.7\.0'){throw 'Rojo 7.7.0 required'}

$runtime=Join-Path $map '__mall-spatial-audit-v2'
$auth=Join-Path $runtime 'authorities'
Remove-Item $runtime -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $auth | Out-Null
$files=[ordered]@{
 ActiveRearMallV1='94-mall.server.lua'
 MallLiveUpgradeV2='95-mall-live-upgrade.server.lua'
 ActiveMallPolishV1='94-mall-polish.server.lua'
 MallRobuxCommerceV1='133-mall-robux-commerce.server.lua'
 MallSafeSecurityOverrideV1='97-mall-safe-security-override.server.lua'
 MallSpatialBoundaryAuthorityV1='137-mall-spatial-boundary-authority-v1.server.lua'
}
foreach($name in $files.Keys){
 $src=Join-Path $map $files[$name]
 if(-not(Test-Path $src)){throw "Missing audit source: $src"}
 $text=Get-Content $src -Raw
 if($name -eq 'ActiveRearMallV1'){$text=$text.Replace('Enum.Material.Tile','Enum.Material.CeramicTiles')}
 if($name -eq 'MallLiveUpgradeV2'){
  $text=$text.Replace("local boards={}`r`n {screen","local boards={`r`n {screen")
  $text=$text.Replace("local boards={}`n {screen","local boards={`n {screen")
 }
 [IO.File]::WriteAllText((Join-Path $auth ($name+'.lua')),$text+"`r`nreturn true`r`n",$utf8)
}
$runner=@'
print("[MALL_SPATIAL_AUDIT_BEGIN]")
local SS=game:GetService("ServerStorage")
local W=game:GetService("Workspace")
local mods=SS:WaitForChild("MallSpatialAuditAuthorities")
local old=W:FindFirstChild("BBYA_ZERO_BUILD")
if old then old:Destroy() end
local root=Instance.new("Folder");root.Name="BBYA_ZERO_BUILD";root.Parent=W
local order={"ActiveRearMallV1","MallLiveUpgradeV2","ActiveMallPolishV1","MallRobuxCommerceV1","MallSafeSecurityOverrideV1","MallSpatialBoundaryAuthorityV1"}
for _,name in ipairs(order) do
 local ok,res=pcall(require,mods:WaitForChild(name))
 print("[MALL_SPATIAL_AUTH]|"..name.."|"..tostring(ok).."|"..tostring(res))
 assert(ok,res)
end
local mall=assert(root:FindFirstChild("BBYAMall"),"BBYAMall missing")
local authority=assert(mall:FindFirstChild("MallSpatialBoundaryAuthorityV1"),"spatial authority missing")
assert(authority:GetAttribute("TenantCountChecked")==12,"not all tenants inspected")
assert(authority:GetAttribute("OversizeViolations")==0,"oversized tenant geometry")
assert(authority:GetAttribute("SpatialQCReady")==true,"spatial authority not ready")
local names={"Tenant_luma","Tenant_stride","Tenant_byte","Tenant_daily","Tenant_mono","Tenant_muse","Tenant_north","Tenant_street","Tenant_page","Tenant_glow","Tenant_sound","Tenant_fit"}
local margin=.08;local eps=.012;local checked=0;local violations=0
local function extents(rel,size)
 local h=size*.5;local r,u,l=rel.RightVector,rel.UpVector,rel.LookVector
 return math.abs(r.X)*h.X+math.abs(u.X)*h.Y+math.abs(l.X)*h.Z,math.abs(r.Z)*h.X+math.abs(u.Z)*h.Y+math.abs(l.Z)*h.Z
end
for _,tenantName in ipairs(names) do
 local tenant=assert(mall:FindFirstChild(tenantName),"missing "..tenantName)
 local floor=assert(tenant:FindFirstChild("Floor"),"missing Floor "..tenantName)
 local gallery=assert(tenant:FindFirstChild("PremiumRetailGalleryV6"),"missing gallery "..tenantName)
 local hx=floor.Size.X*.5-margin;local hz=floor.Size.Z*.5-margin
 for _,d in ipairs(gallery:GetDescendants()) do
  if d:IsA("BasePart") then
   checked+=1
   local rel=floor.CFrame:ToObjectSpace(d.CFrame);local ex,ez=extents(rel,d.Size);local p=rel.Position
   if math.abs(p.X)+ex>hx+eps or math.abs(p.Z)+ez>hz+eps then
    violations+=1
    warn(string.format("[MALL_SPATIAL_QC_FAIL]|%s|%s|p=%.3f,%.3f|e=%.3f,%.3f|lim=%.3f,%.3f",tenantName,d.Name,p.X,p.Z,ex,ez,hx,hz))
   end
  end
 end
end
assert(checked>0,"no gallery parts checked")
assert(violations==0,"remaining tenant offside violations: "..violations)
local cf,sz=mall:GetBoundingBox()
print(string.format("[MALL_SPATIAL_QC_PASS]|checked=%d|corrected=%s|pos=%.1f,%.1f,%.1f|size=%.1f,%.1f,%.1f",checked,tostring(authority:GetAttribute("OffsideCorrections")),cf.Position.X,cf.Position.Y,cf.Position.Z,sz.X,sz.Y,sz.Z))
print("[MALL_SPATIAL_AUDIT_DONE]")
return true
'@
[IO.File]::WriteAllText((Join-Path $runtime 'runner.lua'),$runner,$utf8)
$project=Get-Content (Join-Path $map 'default.project.json') -Raw | ConvertFrom-Json
$storage=[pscustomobject][ordered]@{'$className'='ServerStorage';MallSpatialAuditAuthorities=[pscustomobject][ordered]@{'$path'='__mall-spatial-audit-v2/authorities'};MallSpatialAuditRunnerV2=[pscustomobject][ordered]@{'$path'='__mall-spatial-audit-v2/runner.lua'}}
$project.tree|Add-Member -NotePropertyName ServerStorage -NotePropertyValue $storage -Force
$auditProject=Join-Path $map '__mall-spatial-audit-v2.project.json'
[IO.File]::WriteAllText($auditProject,($project|ConvertTo-Json -Depth 100),$utf8)
$place=Join-Path $env:RUNNER_TEMP 'bbya-mall-spatial-audit-v2.rbxl'
& $rojo build $auditProject -o $place
if($LASTEXITCODE -ne 0 -or -not(Test-Path $place)){throw 'Mall spatial audit Rojo build failed'}
Write-Host "[MALL_CLOUD_BUILD]|$place|$((Get-Item $place).Length)"

# One Studio session for command execution + geometry + GPU evidence.
Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue|Stop-Process -Force -ErrorAction SilentlyContinue
$candidates=@()
foreach($base in @((Join-Path $env:LOCALAPPDATA 'Roblox\Versions'),'C:\Program Files\Roblox\Versions','C:\Program Files (x86)\Roblox\Versions')){if(Test-Path $base){$candidates+=Get-ChildItem $base -Filter RobloxStudioBeta.exe -File -Recurse -ErrorAction SilentlyContinue}}
$studio=$candidates|Sort-Object LastWriteTime -Descending|Select-Object -First 1
if(-not $studio){throw 'RobloxStudioBeta.exe not found'}
$p=Start-Process $studio.FullName -ArgumentList @($place) -PassThru
Write-Host "[MALL_CLOUD_STUDIO]|pid=$($p.Id)"
$root=$null
for($i=0;$i -lt 90;$i++){
 Start-Sleep -Milliseconds 750
 $root=Get-StudioRoot
 if($root){
  $viewCond=New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::NameProperty,'View')
  try{if($root.FindFirst([System.Windows.Automation.TreeScope]::Descendants,$viewCond)){break}}catch{}
 }
}
if(-not $root){throw 'Studio main UI not ready'}
Dismiss-StudioDialogs
$pair=Ensure-CommandBar
Run-StudioCommand 'local ok,res=pcall(require,game:GetService("ServerStorage"):WaitForChild("MallSpatialAuditRunnerV2"));print("[MALL_SPATIAL_WRAPPER]|"..tostring(ok).."|"..tostring(res));if not ok then warn(res) end'

$pass=$false
for($i=0;$i -lt 45;$i++){
 Start-Sleep -Seconds 1
 $lines=Recent-StudioLines 'MALL_SPATIAL_'
 if($lines|Where-Object{$_ -match '\[MALL_SPATIAL_AUDIT_DONE\]'}){$pass=$true;break}
 if($lines|Where-Object{$_ -match '\[MALL_SPATIAL_QC_FAIL\]'}){break}
}
$geom=Recent-StudioLines 'MALL_(SPATIAL|BOUNDS)'
@("source=$env:GITHUB_SHA")+$geom|Set-Content (Join-Path $out 'geometry.txt')
if(-not $pass){$geom|Select-Object -Last 80|ForEach-Object{Write-Host $_};throw 'Mall spatial Studio audit did not reach PASS completion'}
if(-not($geom|Where-Object{$_ -match '\[MALL_SPATIAL_QC_PASS\]'})){throw 'MALL_SPATIAL_QC_PASS missing'}
if($geom|Where-Object{$_ -match '\[MALL_SPATIAL_QC_FAIL\]|\[MALL_BOUNDS_OVERSIZE\]'}){throw 'Mall spatial violation marker found'}

# Seven real GPU views after geometry PASS.
$p=Get-StudioProcess
if(-not $p){throw 'Studio disappeared before capture'}
$hwnd=[IntPtr]$p.MainWindowHandle
[BBYAMallNative]::ShowWindow($hwnd,3)|Out-Null
[BBYAMallNative]::SetForegroundWindow($hwnd)|Out-Null
$views=@(
 @{n='01-entrance-atrium';p='0,13,286';t='0,12,365'},
 @{n='02-l1-left';p='-8,9,330';t='-66,8,348'},
 @{n='03-l1-right';p='8,9,365';t='66,8,380'},
 @{n='04-l1-rear';p='0,10,417';t='66,8,400'},
 @{n='05-l2-right';p='2,23,348';t='68,20,370'},
 @{n='06-upper-atrium';p='0,38,330';t='0,22,382'},
 @{n='07-overview';p='0,72,280';t='0,22,365'}
)
$hashes=@()
foreach($v in $views){
 Run-StudioCommand "local c=workspace.CurrentCamera;c.CameraType=Enum.CameraType.Scriptable;c.FieldOfView=68;c.CFrame=CFrame.lookAt(Vector3.new($($v.p)),Vector3.new($($v.t)));c.Focus=CFrame.new(Vector3.new($($v.t)));print('[MALL_SPATIAL_VIEW]|$($v.n)')"
 Start-Sleep -Milliseconds 1400
 $p=Get-StudioProcess;$hwnd=[IntPtr]$p.MainWindowHandle
 $r=New-Object BBYAMallNative+RECT
 if(-not[BBYAMallNative]::GetWindowRect($hwnd,[ref]$r)){throw 'GetWindowRect failed'}
 $w=$r.Right-$r.Left;$h=$r.Bottom-$r.Top
 if($w -lt 640 -or $h -lt 360){throw "Bad Studio window ${w}x${h}"}
 $bmp=New-Object System.Drawing.Bitmap($w,$h);$g=[System.Drawing.Graphics]::FromImage($bmp)
 $g.CopyFromScreen($r.Left,$r.Top,0,0,(New-Object System.Drawing.Size($w,$h)))
 $path=Join-Path $out ($v.n+'.png');$bmp.Save($path,[System.Drawing.Imaging.ImageFormat]::Png);$g.Dispose();$bmp.Dispose()
 $len=(Get-Item $path).Length;if($len -lt 50000){throw "Suspicious capture $($v.n): $len"}
 $hash=(Get-FileHash $path -Algorithm SHA256).Hash;$hashes+=$hash
 Write-Host "[MALL_CLOUD_CAPTURE]|$($v.n)|bytes=$len|sha=$hash"
}
if(($hashes|Select-Object -Unique).Count -lt 5){throw 'GPU captures insufficiently unique'}
Write-Host '[MALL_CLOUD_SPATIAL_AUDIT_V2_PASS]'
"OUTDIR=$out"|Out-File $env:GITHUB_ENV -Append
