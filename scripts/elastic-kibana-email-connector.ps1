Param(
  [string]$KibanaUrl = "http://localhost:5601",
  [string]$Name = "SMTP Email",
  [string]$From,
  [string]$Host,
  [int]$Port = 587,
  [switch]$Secure,
  [string]$User,
  [string]$Password,
  [string[]]$To
)

$ErrorActionPreference = 'Stop'

if (-not $From -or -not $Host -or -not $User -or -not $Password -or -not $To) {
  throw "Gerekli parametreler: -From -Host -User -Password -To <liste>"
}

function Wait-ForKibana {
  for ($i=0; $i -lt 60; $i++) {
    try { $resp = Invoke-RestMethod "$KibanaUrl/api/status" -TimeoutSec 5; if ($resp.status.overall.state) { return } } catch {}
    Start-Sleep -Seconds 2
  }
  throw "Kibana not ready at $KibanaUrl"
}

Wait-ForKibana

$headers = @{ 'kbn-xsrf'='true'; 'Content-Type'='application/json' }
$secure = [bool]$Secure

$payload = @{
  name = $Name
  connector_type_id = ".email"
  config = @{
    from = $From
    service = "other"
    host = $Host
    port = $Port
    secure = $secure
  }
  secrets = @{
    user = $User
    password = $Password
  }
} | ConvertTo-Json -Depth 6

$res = Invoke-RestMethod -Method POST -Uri "$KibanaUrl/api/actions/connector" -Headers $headers -Body $payload
Write-Host "Email connector created: $($res.id)"
Write-Host "Use this connector id with alerts and specify -EmailTo: $($To -join ',')"

