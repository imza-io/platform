Param(
  [string]$KibanaUrl = "http://localhost:5601",
  [string]$ServiceName = "",
  [string]$WebhookUrl = "",
  [int]$ErrorThresholdCount = 10,
  [int]$LatencyThresholdMs = 1000,
  [string]$Window = "5m",
  [string]$Interval = "1m",
  [string]$EmailConnectorId = "",
  [string[]]$EmailTo = @()
)

Write-Host "Kibana alerts provisioning... ($KibanaUrl)"

function Wait-ForKibana {
  $max = 60
  for ($i=0; $i -lt $max; $i++) {
    try {
      $resp = Invoke-RestMethod -Method GET -Uri "$KibanaUrl/api/status" -TimeoutSec 5 -ErrorAction Stop
      if ($resp.status.overall.state -in @('available','degraded')) { return }
    } catch {}
    Start-Sleep -Seconds 3
  }
  throw "Kibana not ready at $KibanaUrl"
}

function New-WebhookConnector {
  param([string]$Url)
  if (-not $Url) { return $null }
  $payload = @{ 
    name = "Generic Webhook";
    connector_type_id = ".webhook";
    config = @{ url = $Url; method = "post"; hasAuth = $false };
    secrets = @{ }
  } | ConvertTo-Json -Depth 6
  $headers = @{ 'kbn-xsrf'='true'; 'Content-Type'='application/json' }
  try {
    $res = Invoke-RestMethod -Method POST -Uri "$KibanaUrl/api/actions/connector" -Headers $headers -Body $payload -ErrorAction Stop
    return $res.id
  } catch {
    Write-Warning "Failed to create webhook connector: $($_.Exception.Message)"
    return $null
  }
}

function New-EsQueryRule {
  param(
    [string]$Name,
    [string]$IndexPattern,
    [string]$Kql,
    [string]$Window,
    [string]$Interval,
    [int]$Threshold,
    [string]$ConnectorId,
    [string]$BodyTemplate
  )

  $params = @{ index = @($IndexPattern); timeField = "@timestamp"; esQuery = @{ query = $Kql; language = 'kuery' }; size = 100; threshold = @($Threshold); thresholdComparator = ">" } 
  $rule = @{ 
    name = $Name; rule_type_id = ".es-query"; consumer = "alerts"; 
    params = $params; schedule = @{ interval = $Interval }; tags = @("apm","otel","auto"); 
    notify_when = "onActionGroupChange"
  }
  if ($ConnectorId) {
    $rule.actions = @(@{ group = "query matched"; id = $ConnectorId; params = @{ body = $BodyTemplate } })
  } else {
    $rule.actions = @()
  }
  if ($EmailConnectorId -and $EmailTo -and $EmailTo.Count -gt 0) {
    $emailParams = @{ to = $EmailTo; subject = $Name; message = $BodyTemplate }
    $rule.actions += @(@{ group = "query matched"; id = $EmailConnectorId; params = $emailParams })
  }
  $rule.throttle = $Window
  $headers = @{ 'kbn-xsrf'='true'; 'Content-Type'='application/json' }
  $body = $rule | ConvertTo-Json -Depth 10
  try {
    $res = Invoke-RestMethod -Method POST -Uri "$KibanaUrl/api/alerting/rule" -Headers $headers -Body $body -ErrorAction Stop
    Write-Host "Created rule: $($res.name) -> $($res.id)"
  } catch {
    Write-Warning "Failed to create rule '$Name': $($_.Exception.Message)"
  }
}

Wait-ForKibana

$connectorId = $null
if ($WebhookUrl) { $connectorId = New-WebhookConnector -Url $WebhookUrl }

# Error count alert (failures over window)
$svcFilter = if ($ServiceName) { " and service.name : \"$ServiceName\"" } else { "" }
$errorKql = "event.outcome : failure$svcFilter"
$errorBody = "APM Error count exceeded. Service: {{context.rule.name}}. Matches: {{state.matches}}"
New-EsQueryRule -Name "APM Error Count$([string]::IsNullOrEmpty($ServiceName) ? '' : " ($ServiceName)")" `
  -IndexPattern "traces-apm*" -Kql $errorKql -Window $Window -Interval $Interval -Threshold $ErrorThresholdCount -ConnectorId $connectorId -BodyTemplate $errorBody

# Latency threshold alert (transactions over threshold)
$durationUs = $LatencyThresholdMs * 1000
$latencyKql = "transaction.duration.us >= $durationUs$svcFilter"
$latencyBody = "APM Latency exceeded ${LatencyThresholdMs}ms. Rule: {{context.rule.name}}."
New-EsQueryRule -Name "APM Latency >= ${LatencyThresholdMs}ms$([string]::IsNullOrEmpty($ServiceName) ? '' : " ($ServiceName)")" `
  -IndexPattern "traces-apm*" -Kql $latencyKql -Window $Window -Interval $Interval -Threshold 0 -ConnectorId $connectorId -BodyTemplate $latencyBody

Write-Host "Kibana alerts provisioning completed."
