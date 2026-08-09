# Structural pack evals: fixture schema + skill required strings (not a live agent run)
$ErrorActionPreference = "Stop"
$PackRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Fixtures = Get-ChildItem (Join-Path $PackRoot "evals\fixtures\*.json")
if ($Fixtures.Count -eq 0) { throw "No fixtures in evals/fixtures" }

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
  if ($j.path) {
    $bodyPath = Join-Path $PackRoot ([string]$j.path)
    $bodyLabel = [string]$j.path
  } else {
    $bodyPath = Join-Path $PackRoot "skills\$($j.skill)\SKILL.md"
    $bodyLabel = "SKILL.md"
  }
  if (-not (Test-Path $bodyPath)) {
    Write-Host "FAIL ${id}: missing $bodyLabel"
    $failed++; continue
  }
  $body = Get-Content -Raw $bodyPath
  $ok = $true

  if ($j.skill_must_contain) {
    foreach ($needle in @($j.skill_must_contain)) {
      if (-not (Test-BodyHas $body ([string]$needle))) {
        Write-Host "FAIL ${id}: $bodyLabel missing '$needle'"
        $ok = $false
      }
    }
  }

  if ($j.expect_status) {
    foreach ($needle in @($j.expect_status)) {
      if (-not (Test-BodyHas $body ([string]$needle))) {
        Write-Host "FAIL ${id}: expect_status missing '$needle'"
        $ok = $false
      }
    }
  }

  if ($j.expect_redirect_hint) {
    $hint = [string]$j.expect_redirect_hint
    if (-not (Test-BodyHas $body $hint)) {
      Write-Host "FAIL ${id}: expect_redirect_hint missing '$hint'"
      $ok = $false
    }
  }

  if ($j.expect_depth) {
    $depth = [string]$j.expect_depth
    if (-not (Test-BodyHas $body $depth)) {
      Write-Host "FAIL ${id}: expect_depth missing '$depth'"
      $ok = $false
    }
  }

  if ($j.expect_verdict_any) {
    $any = $false
    foreach ($needle in @($j.expect_verdict_any)) {
      if (Test-BodyHas $body ([string]$needle)) { $any = $true; break }
    }
    if (-not $any) {
      Write-Host "FAIL ${id}: expect_verdict_any none of [$($j.expect_verdict_any -join ', ')]"
      $ok = $false
    }
  }

  # Structural: forbidden_actions must be documented as required strings in the body
  if ($j.forbidden_actions) {
    foreach ($needle in @($j.forbidden_actions)) {
      if (-not (Test-BodyHas $body ([string]$needle))) {
        Write-Host "FAIL ${id}: forbidden_actions missing '$needle'"
        $ok = $false
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
