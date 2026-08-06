# Behavior pack evals: golden needles in SKILL.md (not a live agent run)
$ErrorActionPreference = "Stop"
$PackRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Fixtures = Get-ChildItem (Join-Path $PackRoot "evals\behavior\*.json")
if ($Fixtures.Count -eq 0) { throw "No fixtures in evals/behavior" }

function Test-BodyHas([string]$Body, [string]$Needle) {
  if ([string]::IsNullOrEmpty($Needle)) { return $true }
  if ($Body -match [regex]::Escape($Needle)) { return $true }
  return ($Body.IndexOf($Needle, [StringComparison]::OrdinalIgnoreCase) -ge 0)
}

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

  if ($j.must_gate) {
    foreach ($needle in @($j.must_gate)) {
      if (-not (Test-BodyHas $body ([string]$needle))) {
        Write-Host "FAIL ${id}: must_gate missing '$needle'"
        $ok = $false
      }
    }
  }

  if ($j.expect_out_any) {
    $any = $false
    foreach ($needle in @($j.expect_out_any)) {
      if (Test-BodyHas $body ([string]$needle)) { $any = $true; break }
    }
    if (-not $any) {
      Write-Host "FAIL ${id}: expect_out_any none of [$($j.expect_out_any -join ', ')]"
      $ok = $false
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
Write-Host "BEHAVIOR RESULT $passed/$total ($rate%)"
if ($rate -lt 95) { throw "Behavior eval pass rate $rate% < 95%" }
if ($failed -gt 0) { exit 1 }
