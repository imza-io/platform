Param(
  [string]$KibanaUrl = "http://localhost:5601"
)

Write-Host "Kibana provisioning starting... ($KibanaUrl)"

function Wait-ForKibana {
  $max = 60
  for ($i=0; $i -lt $max; $i++) {
    try {
      $resp = Invoke-RestMethod -Method GET -Uri "$KibanaUrl/api/status" -TimeoutSec 5 -ErrorAction Stop
      if ($resp.status.overall.state -in @('available','degraded')) {
        Write-Host "Kibana is up: $($resp.status.overall.state)"
        return
      }
    } catch {
      # ignore
    }
    Start-Sleep -Seconds 3
  }
  throw "Kibana not ready at $KibanaUrl"
}

function New-DataView {
  param(
    [string]$Title,
    [string]$Name,
    [string]$TimeField='@timestamp'
  )
  $body = @{ data_view = @{ title = $Title; name = $Name; timeFieldName = $TimeField } } | ConvertTo-Json -Depth 5
  $headers = @{ 'kbn-xsrf' = 'true'; 'Content-Type' = 'application/json' }
  try {
    $res = Invoke-RestMethod -Method POST -Uri "$KibanaUrl/api/data_views/data_view" -Headers $headers -Body $body -ErrorAction Stop
    Write-Host "Created data view '$Name' ($Title) -> $($res.data_view.id)"
    return $res.data_view.id
  } catch {
    # If already exists, Kibana returns 409; try get by title
    try {
      $list = Invoke-RestMethod -Method GET -Uri "$KibanaUrl/api/data_views/data_view" -Headers @{ 'kbn-xsrf'='true' } -ErrorAction Stop
      $existing = $list.data_views | Where-Object { $_.title -eq $Title }
      if ($existing) {
        Write-Host "Data view '$Name' already exists -> $($existing.id)"
        return $existing.id
      }
    } catch {}
    throw
  }
}

function Set-DefaultDataView {
  param([string]$Id)
  $headers = @{ 'kbn-xsrf' = 'true'; 'Content-Type' = 'application/json' }
  $body = @{ data_view_id = $Id } | ConvertTo-Json
  Invoke-RestMethod -Method POST -Uri "$KibanaUrl/api/data_views/default" -Headers $headers -Body $body | Out-Null
  Write-Host "Default data view set -> $Id"
}

Wait-ForKibana

$tracesId = New-DataView -Title 'traces-apm*' -Name 'APM Traces'
$metricsId = New-DataView -Title 'metrics-apm*' -Name 'APM Metrics'
$logsId   = New-DataView -Title 'logs-apm*'   -Name 'APM Logs'

if ($tracesId) { Set-DefaultDataView -Id $tracesId }

Write-Host "Kibana provisioning completed."

