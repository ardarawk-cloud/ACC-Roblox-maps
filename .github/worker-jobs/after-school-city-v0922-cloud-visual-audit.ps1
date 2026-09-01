$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class ASCWin {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd,int nCmdShow);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd,out RECT rect);
  public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
}
"@

$artifactId='9778112640'
$sourceCommit='76362800d3133ffc01ca776ee5efe16f51e3a49a'
$expectedBytes=152275
$expectedSha='7cae13389e82524aae6c2a235327ae80f5b5e03d97e62e3413cd85912063c29f'
$repo=$env:GITHUB_REPOSITORY
$token=$env:GH_TOKEN
if(-not $repo -or -not $token){throw 'GitHub workflow environment missing'}
$headers=@{Authorization="Bearer $token";Accept='application/vnd.github+json';'X-GitHub-Api-Version'='2022-11-28';'User-Agent'='ASC-Cloud-Visual-Audit'}

$zip=Join-Path $env:RUNNER_TEMP 'asc-v0922-qc.zip'
$out=Join-Path $env:RUNNER_TEMP 'asc-v0922-qc'
if(Test-Path $out){Remove-Item $out -Recurse -Force}
Invoke-WebRequest -UseBasicParsing -Headers $headers -Uri "https://api.github.com/repos/$repo/actions/artifacts/$artifactId/zip" -MaximumRedirection 10 -OutFile $zip
Expand-Archive $zip $out -Force
$places=@(Get-ChildItem $out -Filter '*.rbxl' -File -Recurse)
if($places.Count -ne 1){throw "Expected one RBXL, got $($places.Count)"}
$place=$places[0]
$bytes=$place.Length
$hash=(Get-FileHash $place.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
if($bytes -ne $expectedBytes){throw "RBXL byte mismatch expected=$expectedBytes actual=$bytes"}
if($hash -ne $expectedSha){throw "RBXL SHA mismatch expected=$expectedSha actual=$hash"}
Write-Host "EXACT_QC_ARTIFACT_OK id=$artifactId source=$sourceCommit bytes=$bytes sha=$hash"

$roots=@((Join-Path $env:LOCALAPPDATA 'Roblox\Versions'),'C:\Program Files\Roblox\Versions','C:\Program Files (x86)\Roblox\Versions')
$exe=$null
foreach($r in $roots){
  if(Test-Path $r){
    $c=Get-ChildItem $r -Filter RobloxStudioBeta.exe -File -Recurse -ErrorAction SilentlyContinue|Sort-Object LastWriteTime -Descending|Select-Object -First 1
    if($c){$exe=$c.FullName;break}
  }
}
if(-not $exe){throw 'RobloxStudioBeta.exe not found on cloud worker'}
Start-Process -FilePath $exe -ArgumentList @("`"$($place.FullName)`"") | Out-Null
Start-Sleep -Seconds 20
$proc=Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue|Where-Object {$_.MainWindowHandle -ne 0}|Sort-Object StartTime -Descending|Select-Object -First 1
if(-not $proc){throw 'Roblox Studio window unavailable'}
$hwnd=[IntPtr]$proc.MainWindowHandle
[ASCWin]::ShowWindow($hwnd,9)|Out-Null
[ASCWin]::SetForegroundWindow($hwnd)|Out-Null
Start-Sleep -Seconds 2
[System.Windows.Forms.SendKeys]::SendWait('+{F5}')
Start-Sleep -Seconds 2
[ASCWin]::SetForegroundWindow($hwnd)|Out-Null
[System.Windows.Forms.SendKeys]::SendWait('{F5}')
Start-Sleep -Seconds 12

$rootUI=[System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$editCond=New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::AutomationIdProperty,'commandBarScriptEditor')
$runCond=New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::AutomationIdProperty,'multiLineRunButtonContainer.commandBarRunButton')
$edit=$rootUI.FindFirst([System.Windows.Automation.TreeScope]::Descendants,$editCond)
$run=$rootUI.FindFirst([System.Windows.Automation.TreeScope]::Descendants,$runCond)
if(-not $edit -or -not $run){throw 'Studio command bar controls unavailable'}
$vp=$edit.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern)
$ip=$run.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)

function Aim([string]$needle){
  $safe=$needle.Replace("'","\\'")
  $code=@"
local Players=game:GetService('Players')
local root=workspace:FindFirstChild('AfterSchoolCity')
print('[ASC_CLOUD_AUDIT] ROOT='..tostring(root~=nil)..' TARGET=$safe')
local plate=nil;local sg=nil
if root then
  for _,g in ipairs(root:GetDescendants()) do
    if g:IsA('SurfaceGui') then
      for _,o in ipairs(g:GetDescendants()) do
        if o:IsA('TextLabel') and string.find(string.upper(o.Text or ''),string.upper('$safe'),1,true) then
          local p=g.Adornee or g.Parent
          if p and p:IsA('BasePart') then plate=p;sg=g;break end
        end
      end
    end
    if plate then break end
  end
end
print('[ASC_CLOUD_AUDIT] FOUND='..tostring(plate~=nil)..' PART='..tostring(plate and plate:GetFullName() or 'nil'))
local plr=Players:GetPlayers()[1]
if plate and plr and plr.Character then
  local hrp=plr.Character:FindFirstChild('HumanoidRootPart')
  if hrp then
    local normals={[Enum.NormalId.Front]=Vector3.new(0,0,-1),[Enum.NormalId.Back]=Vector3.new(0,0,1),[Enum.NormalId.Right]=Vector3.new(1,0,0),[Enum.NormalId.Left]=Vector3.new(-1,0,0),[Enum.NormalId.Top]=Vector3.new(0,1,0),[Enum.NormalId.Bottom]=Vector3.new(0,-1,0)}
    local n=plate.CFrame:VectorToWorldSpace(normals[sg.Face] or Vector3.new(0,0,-1)).Unit
    local pos=plate.Position+n*20+Vector3.new(0,-1.5,0)
    hrp.CFrame=CFrame.lookAt(pos,plate.Position)
  end
end
"@
  $vp.SetValue($code)
  Start-Sleep -Milliseconds 300
  $ip.Invoke()
  Start-Sleep -Seconds 3
}

function Capture([string]$key){
  $r=New-Object ASCWin+RECT
  [ASCWin]::GetWindowRect($hwnd,[ref]$r)|Out-Null
  $w=$r.Right-$r.Left;$h=$r.Bottom-$r.Top
  if($w -lt 300 -or $h -lt 200){throw "Invalid Studio window $w x $h"}
  $bmp=New-Object System.Drawing.Bitmap($w,$h)
  $g=[System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($r.Left,$r.Top,0,0,(New-Object System.Drawing.Size($w,$h)))
  $tw=1100;$th=[int]($h*$tw/$w)
  $small=New-Object System.Drawing.Bitmap($tw,$th)
  $g2=[System.Drawing.Graphics]::FromImage($small)
  $g2.DrawImage($bmp,0,0,$tw,$th)
  $jpg=Join-Path $env:GITHUB_WORKSPACE "asc-v0922-cloud-$key.jpg"
  $codec=[System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|Where-Object {$_.MimeType -eq 'image/jpeg'}|Select-Object -First 1
  $ep=New-Object System.Drawing.Imaging.EncoderParameters(1)
  $ep.Param[0]=New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality,[long]72)
  $small.Save($jpg,$codec,$ep)
  $g.Dispose();$g2.Dispose();$bmp.Dispose();$small.Dispose()
  return $jpg
}

$targets=@(
  @{Key='city-park';Text='CITY PARK'},
  @{Key='school';Text='AFTER SCHOOL ACADEMY'},
  @{Key='canteen';Text='STUDENT CANTEEN'},
  @{Key='skate';Text='SKATE'}
)
$captures=@{}
foreach($t in $targets){
  [ASCWin]::SetForegroundWindow($hwnd)|Out-Null
  Aim $t.Text
  $captures[$t.Key]=Capture $t.Key
}

function PutFile([string]$path,[byte[]]$data,[string]$message){
  $api="https://api.github.com/repos/$repo/contents/$path"
  $sha=$null
  try{$sha=(Invoke-RestMethod -Method Get -Uri $api -Headers $headers).sha}catch{if($_.Exception.Response.StatusCode.value__ -ne 404){throw}}
  $body=@{message=$message;content=[Convert]::ToBase64String($data);branch='main'}
  if($sha){$body.sha=$sha}
  Invoke-RestMethod -Method Put -Uri $api -Headers $headers -Body ($body|ConvertTo-Json) -ContentType 'application/json'|Out-Null
}
foreach($k in $captures.Keys){PutFile "deploy-status/asc-v0922-cloud-$k.jpg" ([IO.File]::ReadAllBytes($captures[$k])) "Record ASC V0.9.2.2 cloud $k [skip ci]"}
$status=@{status='CLOUD_STUDIO_CAPTURED';sourceCommit=$sourceCommit;qcArtifactId=[int64]$artifactId;rbxlBytes=[int64]$expectedBytes;rbxlSha256=$expectedSha;capturedAt=(Get-Date -Format o);targets=@('CITY PARK','AFTER SCHOOL ACADEMY','STUDENT CANTEEN','SKATE')}|ConvertTo-Json -Depth 5
PutFile 'deploy-status/asc-v0922-cloud-visual.json' ([Text.Encoding]::UTF8.GetBytes($status)) 'Record ASC V0.9.2.2 cloud visual status [skip ci]'

[ASCWin]::SetForegroundWindow($hwnd)|Out-Null
[System.Windows.Forms.SendKeys]::SendWait('+{F5}')
Start-Sleep -Seconds 2
Write-Host 'ASC_CLOUD_VISUAL_CAPTURE_COMPLETE'
