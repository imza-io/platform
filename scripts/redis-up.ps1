<#
  Starts a local Redis server via Docker Compose on localhost:6379
  Usage: ./scripts/redis-up.ps1
#>

Write-Host "Starting Redis (Docker) on localhost:6379 ..." -ForegroundColor Cyan

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { return $false } else { return $true }
}

if (-not (Assert-Command docker)) {
  throw "Docker bulunamadı. Lütfen Docker Desktop kurun ve tekrar deneyin."
}

$rootDir = (Split-Path $PSScriptRoot -Parent)
$composeDir = Join-Path $rootDir "deploy/redis"

# Resolve project name from root .env or environment
$projectName = $env:COMPOSE_PROJECT_NAME
$rootEnv = Join-Path $rootDir "deploy/.env"
if (Test-Path $rootEnv) {
  foreach ($line in Get-Content $rootEnv) {
    if ($line -match '^\s*COMPOSE_PROJECT_NAME\s*=\s*(.+)\s*$') { $projectName = $Matches[1].Trim(); break }
  }
}
if (-not $projectName) { $projectName = "imzaio" }

## Ensure TLS certs exist before starting
$tlsDir = Join-Path $composeDir "tls"
$required = @("ca.crt","redis.crt","redis.key") | ForEach-Object { Join-Path $tlsDir $_ }
$missing = $required | Where-Object { -not (Test-Path $_) }
if ($missing.Count -gt 0) {
  Write-Error ("TLS sertifikaları eksik:\n" + ($missing -join "`n") + "\nÖnce ./scripts/redis-gencerts.ps1 ile üretin.")
  exit 1
}

pushd $composeDir | Out-Null
docker compose --project-name $projectName --env-file ../.env up -d
popd | Out-Null

$port = ((Get-Content $rootEnv | ForEach-Object { if ($_ -match '^\s*REDIS_TLS_PORT\s*=\s*(.+)') { $Matches[1].Trim() } }) -join '')
if (-not $port) { $port = 6379 }
Write-Host "Redis (TLS) started on localhost:$port" -ForegroundColor Green
Write-Host "Test (redis-cli): redis-cli --tls -h localhost -p $port --cacert \"$tlsDir\ca.crt\" -a <PAROLA> PING" -ForegroundColor DarkGray

# OS-specific CA import hints
if ($IsWindows) {
  Write-Host "Windows CA import (Admin): ./scripts/redis-import-ca.ps1 -Scope LocalMachine" -ForegroundColor DarkGray
  Write-Host "Windows CA import (User):  ./scripts/redis-import-ca.ps1" -ForegroundColor DarkGray
}
elseif ($IsMacOS) {
  Write-Host "macOS CA import:       ./scripts/redis-import-ca-macos.sh" -ForegroundColor DarkGray
}
elseif ($IsLinux) {
  Write-Host "Linux CA import:       ./scripts/redis-import-ca-linux.sh" -ForegroundColor DarkGray
}
else {
  Write-Host "Import CA into your OS trust store before connecting." -ForegroundColor DarkGray
}

Write-Host "Docs: docs/deployment/redis-tls.md" -ForegroundColor DarkGray
