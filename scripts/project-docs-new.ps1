<#
  Scaffolds a new project documentation folder under docs/projects/<Name>.
  Usage:
    ./scripts/project-docs-new.ps1 -Name my-project -Title "My Project" -Owner "Jane Doe"

  Notes:
    - Does not modify mkdocs.yml nav automatically; add entries manually.
    - Copies templates from docs/projects/_project-template.md and _release-template.md.
#>

param(
  [Parameter(Mandatory = $true)] [string] $Name,
  [string] $Title,
  [string] $Owner
)

$base = Join-Path "docs/projects" $Name
$releases = Join-Path $base "releases"

if (Test-Path $base) {
  throw "Project docs already exists: $base"
}

New-Item -ItemType Directory -Path $base | Out-Null
New-Item -ItemType Directory -Path $releases | Out-Null

$projectTpl = "docs/projects/_project-template.md"
$releaseTpl = "docs/projects/_release-template.md"

if (-not (Test-Path $projectTpl)) { throw "Template missing: $projectTpl" }
if (-not (Test-Path $releaseTpl)) { throw "Template missing: $releaseTpl" }

$indexPath = Join-Path $base "index.md"
(Get-Content $projectTpl -Raw) \
  -replace "<Proje Adı>", ($Title ? $Title : $Name) \
  | Set-Content $indexPath -Encoding UTF8

$firstRelease = Join-Path $releases "0.0.0-template.md"
Copy-Item $releaseTpl $firstRelease

if ($Owner) {
  # Append owner note to index
  Add-Content $indexPath "`n> Not: Sahip — $Owner"
}

Write-Host "Created project docs at $base" -ForegroundColor Green
Write-Host "Remember to add to mkdocs.yml nav under 'Projeler'." -ForegroundColor Yellow

