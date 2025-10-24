<#
  Stops the local Redis server started via docker compose.
  Usage: ./scripts/redis-down.ps1
#>

Write-Host "Stopping Redis..." -ForegroundColor Cyan

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { return $false } else { return $true }
}

if (-not (Assert-Command docker)) {
  throw "Docker bulunamadı. Docker Desktop kurulu mu?"
}

$rootDir = (Split-Path $PSScriptRoot -Parent)
$composeDir = Join-Path $rootDir "deploy/redis"

# Resolve project name from root .env or environment
$projectName = $env:COMPOSE_PROJECT_NAME
$rootEnv = Join-Path $"deploy" ".env"
if (Test-Path $rootEnv) {
  foreach ($line in Get-Content $rootEnv) {
    if ($line -match '^\s*COMPOSE_PROJECT_NAME\s*=\s*(.+)\s*$') { $projectName = $Matches[1].Trim(); break }
  }
}
if (-not $projectName) { $projectName = "imzaio" }

pushd $composeDir | Out-Null
docker compose --project-name $projectName down
popd | Out-Null

Write-Host "Redis stopped." -ForegroundColor Green
