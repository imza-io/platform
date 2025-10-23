<#
  Builds the MkDocs site into the 'site' directory.
  Usage: ./scripts/docs-build.ps1
#>

Write-Host "Building MkDocs site..." -ForegroundColor Cyan

function Assert-Command($cmd) {
  $null = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $?) { throw "Komut bulunamadı: $cmd. Lütfen kurulumu yapın." }
}

Assert-Command python
Assert-Command mkdocs

mkdocs build --clean

