Param(
  [switch]$Aspire,
  [switch]$Pull
)

$ErrorActionPreference = 'Stop'

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { return $false } else { return $true }
}

if (-not (Assert-Command docker)) {
  throw "Docker bulunamadı. Lütfen Docker Desktop kurun ve tekrar deneyin."
}

$rootDir = (Split-Path $PSScriptRoot -Parent)
$composeDir = Join-Path $rootDir "deploy/observability/elastic"

# Resolve project name from root .env or environment
$projectName = $env:COMPOSE_PROJECT_NAME
$rootEnv = Join-Path "deploy" ".env"
if (Test-Path $rootEnv) {
  foreach ($line in Get-Content $rootEnv) {
    if ($line -match '^\s*COMPOSE_PROJECT_NAME\s*=\s*(.+)\s*$') { $projectName = $Matches[1].Trim(); break }
  }
}
if (-not $projectName) { $projectName = "imzaio" }

Write-Host "Starting Elastic APM stack... (Aspire=$Aspire, Pull=$Pull)" -ForegroundColor Cyan

pushd $composeDir | Out-Null

$files = @('-f','docker-compose.yml')
if ($Aspire) { $files += @('-f','docker-compose.override.aspire.yml') }

if ($Pull) { docker compose @files --project-name $projectName --env-file ../../.env pull }
docker compose @files --project-name $projectName --env-file ../../.env up -d

popd | Out-Null

Write-Host "Elastic APM stack is up." -ForegroundColor Green
