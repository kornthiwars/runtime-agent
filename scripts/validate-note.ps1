# Validate a /note markdown file has required frontmatter
param(
  [Parameter(Mandatory = $true)][string]$Path
)
$ErrorActionPreference = "Stop"
if (-not (Test-Path $Path)) { throw "File not found: $Path" }
$raw = Get-Content -Raw $Path
if ($raw -notmatch '(?s)^---\r?\n(.*?)\r?\n---') {
  throw "Missing YAML frontmatter"
}
$fm = $Matches[1]
foreach ($key in @('kind:', 'project:', 'title:', 'created:')) {
  if ($fm -notmatch [regex]::Escape($key)) {
    throw "Frontmatter missing key marker: $key"
  }
}
if ($fm -notmatch 'kind:\s*(decision|constraint|exception|gotcha)') {
  throw "kind must be decision|constraint|exception|gotcha"
}
$detail = if ($raw -match '(?s)## Detail\r?\n(.*?)(\r?\n## |\z)') { $Matches[1] } else { "" }
$bullets = ([regex]::Matches($detail, '(?m)^\s*-\s+')).Count
if ($bullets -gt 12) {
  Write-Warning "Detail has $bullets bullets (prefer 3-7; soft cap 12)"
}
Write-Host "OK note: $Path"
