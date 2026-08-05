# Validate a Cursor-format .plan.md has required frontmatter keys
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
foreach ($key in @('name:', 'overview:', 'todos:', 'isProject:')) {
  if ($fm -notmatch [regex]::Escape($key)) {
    throw "Frontmatter missing key marker: $key"
  }
}
if ($fm -notmatch 'status:\s*(pending|in_progress|completed|cancelled)') {
  throw "No todo status found (pending|in_progress|completed|cancelled)"
}
Write-Host "OK plan: $Path"
