<#
  Scans documentation files for non-UTF8 encodings and optionally converts to UTF-8.
  Usage:
    - List problems:   ./scripts/docs-encoding-scan.ps1 -Root docs
    - Fix in-place:    ./scripts/docs-encoding-scan.ps1 -Root docs -Fix [-CodePage 1254]
  Notes:
    - Default fallback code page is 1254 (Turkish). You can try 1252 if needed.
#>

Param(
  [string]$Root = "docs",
  [string[]]$Extensions = @(".md", ".mdx", ".markdown"),
  [switch]$Fix,
  [int]$CodePage = 1254
)

$ErrorActionPreference = 'Stop'

function Get-Files($root, $exts) {
  Get-ChildItem -Path $root -Recurse -File | Where-Object { $exts -contains ([System.IO.Path]::GetExtension($_.FullName).ToLower()) }
}

function Test-Utf8Strict([byte[]]$bytes) {
  $enc = [System.Text.UTF8Encoding]::new($false, $true)
  try {
    $null = $enc.GetString($bytes)
    return $true
  } catch {
    return $false
  }
}

function Convert-ToUtf8([string]$path, [int]$cp) {
  $bytes = [System.IO.File]::ReadAllBytes($path)
  if (Test-Utf8Strict $bytes) { return $false }
  $srcEnc = [System.Text.Encoding]::GetEncoding($cp)
  $text = $srcEnc.GetString($bytes)
  [System.IO.File]::WriteAllText($path, $text, [System.Text.Encoding]::UTF8)
  return $true
}

$files = Get-Files $Root $Extensions
if (-not $files) { Write-Host "No files found under '$Root'"; exit 0 }

$problems = @()
foreach ($f in $files) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  if (-not (Test-Utf8Strict $bytes)) { $problems += $f.FullName }
}

if ($problems.Count -eq 0) {
  Write-Host "All files under '$Root' are valid UTF-8." -ForegroundColor Green
  exit 0
}

Write-Host "Non-UTF8 files detected (count=$($problems.Count)):" -ForegroundColor Yellow
$problems | ForEach-Object { Write-Host " - $_" }

if ($Fix) {
  Write-Host "Converting to UTF-8 using code page $CodePage..." -ForegroundColor Cyan
  foreach ($p in $problems) {
    $changed = Convert-ToUtf8 -path $p -cp $CodePage
    if ($changed) { Write-Host "Fixed: $p" -ForegroundColor Green } else { Write-Host "Skipped (already UTF-8): $p" }
  }
}

