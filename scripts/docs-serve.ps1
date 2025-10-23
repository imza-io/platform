<#
  Serves the MkDocs documentation locally with live-reload.
  Usage: ./scripts/docs-serve.ps1
#>

Write-Host "Starting MkDocs dev server..." -ForegroundColor Cyan

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { throw "Komut bulunamadı: $cmd. Lütfen kurulumu yapın." }
}

Assert-Command python
Assert-Command mkdocs

mkdocs serve

