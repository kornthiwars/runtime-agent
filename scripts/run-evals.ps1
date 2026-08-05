# Structural pack evals: fixture schema + skill contract strings (not a live agent run)
$ErrorActionPreference = "Stop"
$PackRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Fixtures = Get-ChildItem (Join-Path $PackRoot "evals\fixtures\*.json")
if ($Fixtures.Count -eq 0) { throw "No fixtures in evals/fixtures" }

$failed = 0
$passed = 0

foreach ($f in $Fixtures) {
  $j = Get-Content -Raw $f.FullName | ConvertFrom-Json
  $id = $j.id
  if (-not $id -or -not $j.skill) {
    Write-Host "FAIL $(($f.Name)): missing id/skill"
    $failed++; continue
  }
  $skillPath = Join-Path $PackRoot "skills\$($j.skill)\SKILL.md"
  if (-not (Test-Path $skillPath)) {
    Write-Host "FAIL ${id}: missing skill $($j.skill)"
    $failed++; continue
  }
  $body = Get-Content -Raw $skillPath
  $ok = $true
  if ($j.skill_must_contain) {
    foreach ($needle in @($j.skill_must_contain)) {
      if ($body -notmatch [regex]::Escape([string]$needle)) {
        # allow case-insensitive fallback
        if ($body.IndexOf([string]$needle, [StringComparison]::OrdinalIgnoreCase) -lt 0) {
          Write-Host "FAIL ${id}: SKILL.md missing '$needle'"
          $ok = $false
        }
      }
    }
  }
  if ($ok) {
    Write-Host "PASS $id"
    $passed++
  } else {
    $failed++
  }
}

$total = $passed + $failed
$rate = if ($total -gt 0) { [math]::Round(100.0 * $passed / $total, 1) } else { 0 }
Write-Host ""
Write-Host "RESULT $passed/$total ($rate%)"
if ($rate -lt 95) { throw "Eval pass rate $rate% < 95%" }
if ($failed -gt 0) { exit 1 }
