<#
  Generates self-signed TLS certificates for Redis under deploy/redis/tls using OpenSSL.
  - CA: ca.crt/ca.key
  - Server: redis.crt/redis.key for CN=localhost with SANs (DNS:localhost, IP:127.0.0.1)
  Usage: ./scripts/redis-gencerts.ps1
#>

param(
  [int]$Days = 365
)

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { return $false } else { return $true }
}

if (-not (Assert-Command openssl)) {
  throw "OpenSSL bulunamadı. Windows için: ./scripts/openssl-install.ps1; macOS: ./scripts/openssl-install-macos.sh; Linux: ./scripts/openssl-install-linux.sh"
}

$rootDir = (Split-Path $PSScriptRoot -Parent)
$tlsDir = Join-Path $rootDir "deploy/redis/tls"

New-Item -ItemType Directory -Force -Path $tlsDir | Out-Null

$caKey = Join-Path $tlsDir "ca.key"
$caCrt = Join-Path $tlsDir "ca.crt"
$srvKey = Join-Path $tlsDir "redis.key"
$srvCsr = Join-Path $tlsDir "redis.csr"
$srvCrt = Join-Path $tlsDir "redis.crt"
$srl    = Join-Path $tlsDir "ca.srl"
$ext    = Join-Path $tlsDir "v3.ext"

@"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
"@ | Set-Content -NoNewline -Path $ext

Write-Host "[1/3] Creating CA..." -ForegroundColor Cyan
openssl req -x509 -newkey rsa:4096 -keyout "$caKey" -out "$caCrt" -days $Days -nodes -subj "/CN=imzaio-redis-ca" | Out-Null

Write-Host "[2/3] Creating server key/csr (CN=localhost)..." -ForegroundColor Cyan
openssl req -newkey rsa:4096 -keyout "$srvKey" -out "$srvCsr" -nodes -subj "/CN=localhost" | Out-Null

Write-Host "[3/3] Signing server cert with CA (SANs)..." -ForegroundColor Cyan
openssl x509 -req -in "$srvCsr" -CA "$caCrt" -CAkey "$caKey" -CAcreateserial -out "$srvCrt" -days $Days -extfile "$ext" | Out-Null

Remove-Item -ErrorAction SilentlyContinue "$srvCsr"

Write-Host "Certificates ready in: $tlsDir" -ForegroundColor Green
Write-Host "Files: ca.crt, ca.key, redis.crt, redis.key" -ForegroundColor Green

# Post-generation hints
if ($IsWindows) {
  Write-Host "Next: Import CA (Windows): ./scripts/redis-import-ca.ps1 -Scope LocalMachine (Admin)" -ForegroundColor DarkGray
  Write-Host "Or current user: ./scripts/redis-import-ca.ps1" -ForegroundColor DarkGray
}
elseif ($IsMacOS) {
  Write-Host "Next: Import CA (macOS): ./scripts/redis-import-ca-macos.sh" -ForegroundColor DarkGray
}
elseif ($IsLinux) {
  Write-Host "Next: Import CA (Linux): ./scripts/redis-import-ca-linux.sh" -ForegroundColor DarkGray
}
else {
  Write-Host "Import the CA into your OS trust store before connecting over TLS." -ForegroundColor DarkGray
}
Write-Host "Then start Redis (TLS): ./scripts/redis-up.ps1" -ForegroundColor DarkGray
