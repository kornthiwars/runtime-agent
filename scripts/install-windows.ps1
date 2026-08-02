# Link pack skills + rules into the outer workspace .cursor (never USERPROFILE)

$ErrorActionPreference = "Stop"

function Remove-PathForLink([string]$Path) {
  if (-not (Test-Path $Path)) { return }
  $item = Get-Item $Path -Force
  if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
    cmd /c "rmdir `"$Path`""
  } elseif ($item.PSIsContainer) {
    Remove-Item -Recurse -Force $Path
  } else {
    Remove-Item -Force $Path
  }
}

$PackRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$WorkspaceRoot = Split-Path -Parent $PackRoot
$SkillsSrc = Join-Path $PackRoot "skills"
$SkillsDest = Join-Path $WorkspaceRoot ".cursor\skills"
$RulesSrc = Join-Path $PackRoot "rules"
$RulesDest = Join-Path $WorkspaceRoot ".cursor\rules"
$SkillNames = @("fix", "make", "plan", "feature", "review", "ship", "note")

New-Item -ItemType Directory -Force -Path $SkillsDest | Out-Null

foreach ($name in $SkillNames) {
  $src = Join-Path $SkillsSrc $name
  $dest = Join-Path $SkillsDest $name
  if (-not (Test-Path (Join-Path $src "SKILL.md"))) {
    throw "Missing SKILL.md: $src"
  }
  Remove-PathForLink $dest
  cmd /c "mklink /J `"$dest`" `"$src`"" | Out-Null
  Write-Host "Linked skill $name"
}

$ruleFiles = Get-ChildItem -Path $RulesSrc -Filter "*.mdc" -File -ErrorAction Stop
if ($ruleFiles.Count -eq 0) {
  throw "No .mdc rules in $RulesSrc"
}
Remove-PathForLink $RulesDest
cmd /c "mklink /J `"$RulesDest`" `"$RulesSrc`"" | Out-Null
Write-Host "Linked rules ($($ruleFiles.Count) .mdc)"

Write-Host ""
Write-Host "OK skills: $SkillsDest"
Write-Host "  -> $SkillsSrc"
Write-Host "OK rules:  $RulesDest"
Write-Host "  -> $RulesSrc"
Write-Host "No files written under USERPROFILE"
Write-Host "Open Skills (parent) as workspace, restart Cursor, type / in Agent"
