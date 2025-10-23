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

mkdocs serve
