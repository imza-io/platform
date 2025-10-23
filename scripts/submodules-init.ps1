<#
  Initializes and updates all git submodules recursively.
  Usage: ./scripts/submodules-init.ps1
#>

Write-Host "Syncing submodule URLs..." -ForegroundColor Cyan
git submodule sync --recursive

Write-Host "Initializing and updating submodules..." -ForegroundColor Cyan
git submodule update --init --recursive

Write-Host "`nStatus:" -ForegroundColor Green
git submodule status --recursive

