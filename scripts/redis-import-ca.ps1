<#
  Imports the Redis CA certificate into Windows Trusted Root store.
  Usage:
    - Current user: ./scripts/redis-import-ca.ps1
    - Local machine: ./scripts/redis-import-ca.ps1 -Scope LocalMachine (run as Administrator)
#>

param(
  [ValidateSet('CurrentUser','LocalMachine')]
  [string]$Scope = 'CurrentUser'
)

function Assert-Admin {
  $current = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  return $current.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$rootDir = (Split-Path $PSScriptRoot -Parent)
$caPath = Join-Path $rootDir "deploy/redis/tls/ca.crt"

if (-not (Test-Path $caPath)) {
  throw "CA bulunamadı: $caPath. Önce ./scripts/redis-gencerts.ps1 çalıştırın."
}

if ($Scope -eq 'LocalMachine' -and -not (Assert-Admin)) {
  throw "LocalMachine deposuna import için PowerShell'i Yönetici olarak çalıştırın."
}

$store = if ($Scope -eq 'LocalMachine') { 'Cert:\LocalMachine\Root' } else { 'Cert:\CurrentUser\Root' }
Write-Host "Importing CA into $store ..." -ForegroundColor Cyan

$result = Import-Certificate -FilePath $caPath -CertStoreLocation $store -ErrorAction Stop

Write-Host "Imported: $($result.Certificate.Subject)" -ForegroundColor Green
Write-Host "Done. You may need to restart apps using TLS." -ForegroundColor DarkGray

