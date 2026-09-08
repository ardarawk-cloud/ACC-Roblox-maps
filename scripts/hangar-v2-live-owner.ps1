$ErrorActionPreference='Stop'

$liveUniverse='10745364913'
$livePlace='76001567401911'
$liveCreator='8878884630'
$key=$env:ROBLOX_KEY
if([string]::IsNullOrWhiteSpace($key)){throw 'ROBLOX_KEY missing'}

$project='maps/aeroclub-hangar/default.project.json'
$runtime='maps/aeroclub-hangar/server/visual-bootstrap-v2_0.server.lua'
$generator='scripts/hangar-v2-realism-glb.js'

$p=[IO.File]::ReadAllText($project)
foreach($m in @('HangarEnvironmentRealismV2_0','HangarRealtimeWITAV1_1')){if($p -notmatch [regex]::Escape($m)){throw "project marker missing $m"}}
$r=[IO.File]::ReadAllText($runtime)
foreach($m in @('V2_0_ENVIRONMENT_REALISM_REBUILD','HANGAR_V20_REALISM_MODEL_ASSET_ID','READY_V2_REALISM_OWNER_QC')){if($r -notmatch [regex]::Escape($m)){throw "runtime marker missing $m"}}

$glb=Join-Path $env:RUNNER_TEMP 'hangar-v2-realism-live.glb'
node $generator $glb
if($LASTEXITCODE -ne 0 -or -not(Test-Path $glb)){throw 'GLB build failed'}
$glbBytes=(Get-Item $glb).Length
if($glbBytes -lt 450000){throw "GLB too small $glbBytes"}
$glbSha=(Get-FileHash $glb -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "HANGAR_V2_GLB_OK bytes=$glbBytes sha=$glbSha"

$req=@{assetType='Model';displayName='HANGAR v2 Environment Realism';description='HANGAR v2 environment realism rebuild';creationContext=@{creator=@{userId=[int64]$liveCreator}}}|ConvertTo-Json -Depth 8 -Compress
$rf=Join-Path $env:RUNNER_TEMP 'hangar-v2-asset-request.json'
[IO.File]::WriteAllText($rf,$req,(New-Object Text.UTF8Encoding($false)))
$raw=& curl.exe --silent --show-error --location --request POST --header "x-api-key: $key" --form "request=<$rf;type=application/json" --form "fileContent=@$glb;type=model/gltf-binary" 'https://apis.roblox.com/assets/v1/assets'
Remove-Item $rf -Force -ErrorAction SilentlyContinue
if($LASTEXITCODE -ne 0){throw 'asset upload request failed'}
$created=$raw|ConvertFrom-Json
if(-not $created.path){throw "asset upload rejected $raw"}
$opId=([string]$created.path)-replace '^operations/',''
$assetId=$null;$moderation=$null
for($i=0;$i -lt 100;$i++){
  Start-Sleep -Seconds 4
  $opRaw=& curl.exe --silent --show-error --location --header "x-api-key: $key" "https://apis.roblox.com/assets/v1/operations/$opId"
  try{$op=$opRaw|ConvertFrom-Json}catch{continue}
  if($op.done){
    if($op.error){throw ($op.error|ConvertTo-Json -Compress -Depth 8)}
    $assetId=[string]$op.response.assetId
    $moderation=[string]$op.response.moderationResult.moderationState
    break
  }
}
if($assetId -notmatch '^\d+$'){throw 'no valid asset id'}
Write-Host "HANGAR_V2_ASSET_OK asset=$assetId moderation=$moderation creator=$liveCreator"

$grantBody=@{subjectType='Universe';subjectId=$liveUniverse;action='Use';requests=@(@{assetId=[int64]$assetId;grantToDependencies=$true})}|ConvertTo-Json -Depth 8 -Compress
$grant=Invoke-RestMethod -Method Patch -Uri 'https://apis.roblox.com/asset-permissions-api/v1/assets/permissions' -Headers @{'x-api-key'=$key} -ContentType 'application/json' -Body $grantBody
$success=@($grant.successAssetIds|ForEach-Object{[string]$_})
if($success -notcontains $assetId){throw "asset grant failed $($grant|ConvertTo-Json -Compress -Depth 8)"}
Write-Host "HANGAR_V2_GRANT_OK asset=$assetId universe=$liveUniverse"

$text=[IO.File]::ReadAllText($runtime)
$pattern='local MODEL_ASSET_ID = \d+ -- HANGAR_V20_REALISM_MODEL_ASSET_ID'
if($text -notmatch $pattern){throw 'runtime asset marker missing'}
$text=[regex]::Replace($text,$pattern,"local MODEL_ASSET_ID = $assetId -- HANGAR_V20_REALISM_MODEL_ASSET_ID")
[IO.File]::WriteAllText($runtime,$text,(New-Object Text.UTF8Encoding($false)))

$cmd=Get-Command rojo -ErrorAction SilentlyContinue
if($cmd){$rojo=$cmd.Source}else{
  $d=Join-Path $env:RUNNER_TEMP 'hangar-v2-rojo';$z=Join-Path $env:RUNNER_TEMP 'hangar-v2-rojo.zip'
  if(Test-Path $d){Remove-Item $d -Recurse -Force}
  Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/rojo-rbx/rojo/releases/download/v7.7.0/rojo-7.7.0-windows-x86_64.zip' -OutFile $z
  Expand-Archive $z $d -Force
  $rojo=(Get-ChildItem $d -Filter rojo.exe -Recurse|Select-Object -First 1).FullName
}
if([string]::IsNullOrWhiteSpace($rojo)){throw 'rojo missing'}

$place=Join-Path $env:RUNNER_TEMP 'hangar-v2-realism-live.rbxlx'
& $rojo build $project -o $place
if($LASTEXITCODE -ne 0){throw 'Rojo build failed'}
$xml=[IO.File]::ReadAllText($place)
foreach($m in @('HangarEnvironmentRealismV2_0','HangarRealtimeWITAV1_1',$assetId,'READY_V2_REALISM_OWNER_QC')){if($xml -notmatch [regex]::Escape([string]$m)){throw "built place missing $m"}}
$placeBytes=(Get-Item $place).Length
$placeSha=(Get-FileHash $place -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "HANGAR_V2_PLACE_OK bytes=$placeBytes sha=$placeSha"

$publishUrl="https://apis.roblox.com/universes/v1/$liveUniverse/places/$livePlace/versions?versionType=Published"
$version=$null
for($i=1;$i -le 6;$i++){
  try{
    $resp=Invoke-WebRequest -UseBasicParsing -Method Post -Uri $publishUrl -Headers @{'x-api-key'=$key} -ContentType 'application/xml' -InFile $place
    $version=[int](($resp.Content|ConvertFrom-Json).versionNumber)
    break
  }catch{Write-Warning "publish attempt $i failed $($_.Exception.Message)";Start-Sleep -Seconds ([math]::Min(30,3*$i))}
}
if(-not $version){throw 'publish failed'}

$restartUrl="https://apis.roblox.com/cloud/v2/universes/$liveUniverse`:restartServers"
Invoke-WebRequest -UseBasicParsing -Method Post -Uri $restartUrl -Headers @{'x-api-key'=$key} -ContentType 'application/json' -Body '{}'|Out-Null
Write-Host "HANGAR_V2_LIVE_OK version=$version asset=$assetId"

"HANGAR_LIVE_VERSION=$version"|Out-File $env:GITHUB_ENV -Encoding utf8 -Append
"HANGAR_MODEL_ASSET_ID=$assetId"|Out-File $env:GITHUB_ENV -Encoding utf8 -Append
"HANGAR_MODEL_MODERATION=$moderation"|Out-File $env:GITHUB_ENV -Encoding utf8 -Append
"HANGAR_GLB_BYTES=$glbBytes"|Out-File $env:GITHUB_ENV -Encoding utf8 -Append
"HANGAR_GLB_SHA256=$glbSha"|Out-File $env:GITHUB_ENV -Encoding utf8 -Append
"HANGAR_PLACE_BYTES=$placeBytes"|Out-File $env:GITHUB_ENV -Encoding utf8 -Append
"HANGAR_PLACE_SHA256=$placeSha"|Out-File $env:GITHUB_ENV -Encoding utf8 -Append
