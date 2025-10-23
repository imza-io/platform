<#
  Serves the MkDocs documentation locally with live-reload.
  Usage: ./scripts/docs-serve.ps1
#>

Write-Host "Starting MkDocs dev server..." -ForegroundColor Cyan

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { return $false } else { return $true }
}

function Ensure-DocsDeps() {
  if (-not (Assert-Command python)) {
    throw "Python bulunamadı. Lütfen Python 3 kurun ve PATH'e ekleyin."
  }

  $needInstall = $false
  if (-not (Assert-Command mkdocs)) { $needInstall = $true }

  # Check PlantUML plugin availability
  & python -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('plantuml_markdown') else 1)"
  if ($LASTEXITCODE -ne 0) { $needInstall = $true }

  if ($needInstall) {
    Write-Host "Installing MkDocs deps from docs/requirements.txt..." -ForegroundColor Yellow
    python -m pip install --upgrade pip
    python -m pip install -r docs/requirements.txt
  }
}

Ensure-DocsDeps

if (-not (Assert-Command mkdocs)) {
  throw "mkdocs komutu bulunamadı. Kurulum başarısız görünüyor."
}

# Prefer local PlantUML server if reachable
$useLocal = $false
try {
  $resp = Invoke-WebRequest -Uri "http://localhost:8080/" -UseBasicParsing -TimeoutSec 2
  if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 500) { $useLocal = $true }
} catch {}

if ($useLocal -and (Test-Path "mkdocs.local.yml")) {
  Write-Host "Using local PlantUML server (mkdocs.local.yml)" -ForegroundColor Cyan
  mkdocs serve -f mkdocs.local.yml
} else {
  mkdocs serve
}
