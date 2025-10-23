<#
  Stops the local PlantUML server started via docker compose.
  Usage: ./scripts/plantuml-down.ps1
#>

Write-Host "Stopping PlantUML server..." -ForegroundColor Cyan

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { return $false } else { return $true }
}

if (-not (Assert-Command docker)) {
  throw "Docker bulunamadı. Docker Desktop kurulu mu?"
}

$rootDir = (Split-Path $PSScriptRoot -Parent)
$composeDir = Join-Path $rootDir "deploy/plantuml"

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

Write-Host "PlantUML server stopped." -ForegroundColor Green
