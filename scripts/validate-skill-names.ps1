# Validate scripts/skill-names.txt against skills/*/SKILL.md
$ErrorActionPreference = "Stop"
$PackRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$NamesFile = Join-Path $PackRoot "scripts\skill-names.txt"
$SkillsDir = Join-Path $PackRoot "skills"
$listed = @(Get-Content $NamesFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -notmatch '^\s*#' })
$failed = $false

foreach ($name in $listed) {
  $skill = Join-Path $SkillsDir "$name\SKILL.md"
  if (-not (Test-Path $skill)) {
    Write-Host "MISSING SKILL.md for listed name: $name"
    $failed = $true
  }
}

$dirs = Get-ChildItem $SkillsDir -Directory | Select-Object -ExpandProperty Name
foreach ($d in $dirs) {
  if ($d -eq 'README.md') { continue }
  if ($listed -notcontains $d) {
    if (Test-Path (Join-Path $SkillsDir "$d\SKILL.md")) {
      Write-Host "ORPHAN skill folder not in skill-names.txt: $d"
      $failed = $true
    }
  }
}

if ($failed) { exit 1 }
Write-Host "OK skill-names.txt ($($listed.Count) skills)"
