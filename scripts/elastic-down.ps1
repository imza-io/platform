Param(
  [switch]$Aspire,
  [switch]$Volumes
)

$ErrorActionPreference = 'Stop'

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { return $false } else { return $true }
}

if (-not (Assert-Command docker)) {
  throw "Docker bulunamadı. Docker Desktop kurulu mu?"
}

$rootDir = (Split-Path $PSScriptRoot -Parent)
$composeDir = Join-Path $rootDir "deploy/observability/elastic"

# Resolve project name
$projectName = $env:COMPOSE_PROJECT_NAME
$rootEnv = Join-Path $rootDir "deploy/.env"
if (Test-Path $rootEnv) {
  foreach ($line in Get-Content $rootEnv) {
    if ($line -match '^\s*COMPOSE_PROJECT_NAME\s*=\s*(.+)\s*$') { $projectName = $Matches[1].Trim(); break }
  }
}
if (-not $projectName) { $projectName = "imzaio" }

Write-Host "Stopping Elastic APM stack... (Aspire=$Aspire, Volumes=$Volumes)" -ForegroundColor Cyan

pushd $composeDir | Out-Null

$files = @('-f','docker-compose.yml')
if ($Aspire) { $files += @('-f','docker-compose.override.aspire.yml') }

$downArgs = @('down')
if ($Volumes) { $downArgs += '-v' }

docker compose @files --project-name $projectName @downArgs

popd | Out-Null

Write-Host "Elastic APM stack is down." -ForegroundColor Green
