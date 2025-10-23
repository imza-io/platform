<#
  Vendors C4-PlantUML files into docs/_assets/plantuml to enable fully offline rendering.
  Usage: ./scripts/c4-vendor.ps1

  Downloads:
    - C4.puml
    - C4_Context.puml
    - C4_Container.puml
    - C4_Component.puml
#>

param(
  [string] $DestDir = "docs/_assets/plantuml"
)

function Ensure-Dir($p) { if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null } }

Ensure-Dir $DestDir

$base = 'https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master'
$files = @('C4.puml','C4_Context.puml','C4_Container.puml','C4_Component.puml')

foreach ($f in $files) {
  $url = "$base/$f"
  $dst = Join-Path $DestDir $f
  try {
    Write-Host "Downloading $url -> $dst" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $dst -UseBasicParsing
  } catch {
    Write-Warning "Failed to download url: $($_.Exception.Message)"
  }
}

Write-Host "Done. Rebuild docs with local PlantUML server for stable rendering." -ForegroundColor Green

