$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($env:ROBLOX_API_KEY)) {
    throw 'ROBLOX_OPEN_CLOUD_MASTER_V2 is unavailable'
}

$ids = @(
    '86006580589828','125820152354579','133947654553749','95691778643767','130313438027284',
    '75712054983357','88943191512256','91809948844354','108578144206183','89763491889927',
    '96924419000406','132460784559824','122720606049274','70777592375726','98308711398889',
    '95839337053281','135587255285184','104136707299013','131597067752690','73502975968958',
    '101289385838814','102043858565172','79235704240751','103710801320668','102227106442067'
)

$headers = @{
    'x-api-key' = $env:ROBLOX_API_KEY
    'Accept' = 'application/json'
}

$results = @()
foreach ($id in $ids) {
    $row = [ordered]@{
        assetId = $id
        http = 0
        assetType = ''
        displayName = ''
        description = ''
        moderationResult = $null
        creationContext = $null
        error = ''
    }

    try {
        $data = Invoke-RestMethod -Method Get -Uri ("https://apis.roblox.com/assets/v1/assets/{0}" -f $id) -Headers $headers -TimeoutSec 15
        $row.http = 200
        $row.assetType = [string]$data.assetType
        $row.displayName = [string]$data.displayName
        $row.description = [string]$data.description
        $row.moderationResult = $data.moderationResult
        $row.creationContext = $data.creationContext
    }
    catch {
        $status = 0
        try { $status = [int]$_.Exception.Response.StatusCode } catch {}
        $row.http = $status
        $row.error = [string]$_.Exception.Message
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            $row.error = [string]$_.ErrorDetails.Message
        }
    }

    $results += [pscustomobject]$row
    Write-Host ("ASSET {0} HTTP={1} TYPE={2} NAME={3}" -f $id, $row.http, $row.assetType, $row.displayName)
}

$payload = [ordered]@{
    count = $results.Count
    results = $results
}
$payload | ConvertTo-Json -Depth 12 | Set-Content 'bbya-music-id-metadata-audit.json' -Encoding utf8

$ok = @($results | Where-Object { $_.http -eq 200 }).Count
$lines = @(
    '# BBYA Music ID Metadata Audit',
    '',
    ("HTTP 200: **{0}/{1}**" -f $ok, $results.Count),
    '',
    '| # | Asset ID | HTTP | Type | Name |',
    '|---:|---|---:|---|---|'
)
for ($i = 0; $i -lt $results.Count; $i++) {
    $r = $results[$i]
    $safeName = ([string]$r.displayName).Replace('|','\|').Replace("`r",' ').Replace("`n",' ')
    $lines += ("| {0} | {1} | {2} | {3} | {4} |" -f ($i + 1), $r.assetId, $r.http, $r.assetType, $safeName)
}
$lines | Set-Content 'bbya-music-id-metadata-audit.md' -Encoding utf8

Write-Host ("METADATA_AUDIT_COMPLETE http200={0}/{1}" -f $ok, $results.Count)
