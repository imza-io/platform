<#
  Adds a product repository as a git submodule under products/<Name>.
  Usage:
    ./scripts/submodule-add.ps1 -Name api -Url git@github.com:org/api.git -Branch main

  Note: This script does not commit changes. After it runs, review and commit
  .gitmodules and the products/<Name> entry from the root repository.
#>

param(
  [Parameter(Mandatory = $true)] [string] $Name,
  [Parameter(Mandatory = $true)] [string] $Url,
  [string] $Branch = "main",
  [string] $BasePath = "products"
)

$path = Join-Path -Path $BasePath -ChildPath $Name

if (-not (Test-Path $BasePath)) {
  New-Item -ItemType Directory -Path $BasePath | Out-Null
}

Write-Host "Adding submodule '$Name' from $Url to $path (branch $Branch)..." -ForegroundColor Cyan

$args = @("submodule", "add", "-b", $Branch, $Url, $path)
$proc = Start-Process -FilePath "git" -ArgumentList $args -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -ne 0) {
  throw "git submodule add failed with exit code $($proc.ExitCode)"
}

# Persist desired branch in .gitmodules for newer git versions
git config -f .gitmodules "submodule.$path.branch" $Branch | Out-Null

Write-Host "Submodule added. Review and commit changes when ready:" -ForegroundColor Green
Write-Host "  git add .gitmodules $path" -ForegroundColor DarkGray
Write-Host "  git commit -m \"Add $Name submodule ($Branch)\"" -ForegroundColor DarkGray

