<#
  Installs OpenSSL on Windows using winget or Chocolatey.
  Usage: ./scripts/openssl-install.ps1 [-AddToPath]
#>

param(
  [switch]$AddToPath
)

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { return $false } else { return $true }
}

Write-Host "Checking package managers..." -ForegroundColor Cyan
$haveWinget = Assert-Command winget
$haveChoco  = Assert-Command choco

if (-not $haveWinget -and -not $haveChoco) {
  Write-Warning "Neither winget nor choco found. Install winget or Chocolatey first."
  Write-Host "- winget: Microsoft Store 'App Installer'" -ForegroundColor DarkGray
  Write-Host "- choco: https://chocolatey.org/install" -ForegroundColor DarkGray
  exit 1
}

if ($haveWinget) {
  Write-Host "Installing OpenSSL via winget (ShiningLight.OpenSSL.Light)..." -ForegroundColor Cyan
  # Shining Light Productions official package
  winget install -e --id ShiningLight.OpenSSL.Light --accept-package-agreements --accept-source-agreements
}
elseif ($haveChoco) {
  Write-Host "Installing OpenSSL via Chocolatey (openssl-light)..." -ForegroundColor Cyan
  choco install openssl-light -y
}

# Try to locate OpenSSL binary
$candidateDirs = @(
  "C:\\Program Files\\OpenSSL-Win64\\bin",
  "C:\\Program Files (x86)\\OpenSSL-Win32\\bin"
)

$foundBin = $candidateDirs | Where-Object { Test-Path (Join-Path $_ "openssl.exe") } | Select-Object -First 1

if ($foundBin) {
  Write-Host "OpenSSL found at: $foundBin" -ForegroundColor Green
  if ($AddToPath) {
    if (-not ($env:PATH -split ';' | Where-Object { $_ -ieq $foundBin })) {
      Write-Host "Adding to PATH for current session..." -ForegroundColor Cyan
      $env:PATH = "$foundBin;" + $env:PATH
    }
    Write-Host "Note: To persist PATH, add it manually in System Environment Variables." -ForegroundColor DarkGray
  } else {
    Write-Host "Tip: Re-run with -AddToPath to add to PATH for this session." -ForegroundColor DarkGray
  }
}
else {
  Write-Warning "OpenSSL install completed, but openssl.exe not found in default locations. Restart your shell and try 'openssl version'."
}

