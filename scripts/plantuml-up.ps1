<#
  Starts a local PlantUML server via Docker Compose on http://localhost:8080
  Usage: ./scripts/plantuml-up.ps1
#>

Write-Host "Starting PlantUML server (Docker) on http://localhost:8080 ..." -ForegroundColor Cyan

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { return $false } else { return $true }
}

if (-not (Assert-Command docker)) {
  throw "Docker bulunamadı. Lütfen Docker Desktop kurun ve tekrar deneyin."
}

$rootDir = (Split-Path $PSScriptRoot -Parent)
$composeDir = Join-Path $rootDir "deploy/plantuml"

# Resolve project name from root .env or environment
$projectName = $env:COMPOSE_PROJECT_NAME
$rootEnv = Join-Path "deploy" ".env"
if (Test-Path $rootEnv) {
  foreach ($line in Get-Content $rootEnv) {
    if ($line -match '^\s*COMPOSE_PROJECT_NAME\s*=\s*(.+)\s*$') { $projectName = $Matches[1].Trim(); break }
  }
}
if (-not $projectName) { $projectName = "imzaio" }

pushd $composeDir | Out-Null
docker compose --project-name $projectName up -d
popd | Out-Null

Write-Host "PlantUML server started. Test: http://localhost:8080" -ForegroundColor Green
