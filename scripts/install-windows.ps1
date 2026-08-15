# Link pack skills + rules + Cursor hooks into the outer workspace
# (never USERPROFILE). Safe to re-run after deleting ../.cursor.

$ErrorActionPreference = "Stop"

function Remove-PathForLink([string]$Path) {
  if (-not (Test-Path $Path)) { return }
  $item = Get-Item $Path -Force
  if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
    if ($item.PSIsContainer) {
      cmd /c "rmdir `"$Path`""
    } else {
      cmd /c "del `"$Path`""
    }
  } elseif ($item.PSIsContainer) {
    Remove-Item -Recurse -Force $Path
  } else {
    Remove-Item -Force $Path
  }
}

$PackRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$WorkspaceRoot = Split-Path -Parent $PackRoot
$CursorRoot = Join-Path $WorkspaceRoot ".cursor"
$SkillsSrc = Join-Path $PackRoot "skills"
$SkillsDest = Join-Path $CursorRoot "skills"
$RulesSrc = Join-Path $PackRoot "rules"
$RulesDest = Join-Path $CursorRoot "rules"
$HooksSrc = Join-Path $PackRoot "cursor-hooks"
$HooksDest = Join-Path $CursorRoot "hooks"
$HooksJsonDest = Join-Path $CursorRoot "hooks.json"
$SkillNamesFile = Join-Path $PackRoot "scripts\skill-names.txt"
$SkillNames = @(Get-Content -Path $SkillNamesFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -notmatch '^\s*#' })
if ($SkillNames.Count -eq 0) { throw "No skill names in $SkillNamesFile" }
if (-not (Test-Path (Join-Path $HooksSrc "hooks.windows.json"))) {
  throw "Missing cursor-hooks pack: $HooksSrc"
}

New-Item -ItemType Directory -Force -Path $CursorRoot | Out-Null
# If skills was a whole-folder junction (e.g. to another pack), replace with a real dir
# of per-skill junctions — never mklink into the old pack tree.
Remove-PathForLink $SkillsDest
New-Item -ItemType Directory -Force -Path $SkillsDest | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $CursorRoot "plans") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $CursorRoot "features") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $CursorRoot "notes\daily") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $CursorRoot "notes\projects") | Out-Null

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

# Cursor agent hooks — install to parent workspace AND pack root.
# Cursor binds project hooks to the nested git folder (agent-skills/.cursor/hooks.json)
# even when the opened workspace is the parent Skills folder.
function Install-Hooks([string]$CursorRoot, [string]$HooksSrc) {
  $HooksDest = Join-Path $CursorRoot "hooks"
  $HooksJsonDest = Join-Path $CursorRoot "hooks.json"
  New-Item -ItemType Directory -Force -Path $HooksDest | Out-Null
  $StateDest = Join-Path $HooksDest "state"
  New-Item -ItemType Directory -Force -Path $StateDest | Out-Null
  Copy-Item -Force (Join-Path $HooksSrc "hooks.windows.json") $HooksJsonDest
  Copy-Item -Force (Join-Path $HooksSrc "state.gitignore") (Join-Path $StateDest ".gitignore")
  Copy-Item -Force (Join-Path $HooksSrc "notes-daily.ps1") (Join-Path $HooksDest "notes-daily.ps1")
  Copy-Item -Force (Join-Path $HooksSrc "notes-daily.sh") (Join-Path $HooksDest "notes-daily.sh")
  Write-Host "Installed Cursor hooks -> $HooksJsonDest"
}

Install-Hooks $CursorRoot $HooksSrc
Install-Hooks (Join-Path $PackRoot ".cursor") $HooksSrc
Write-Host "(notes-daily auto on; disable: NOTES_DAILY_AUTO=0 or .cursor/hooks/state/notes-daily.off)"

Write-Host ""
Write-Host "OK skills:  $SkillsDest"
Write-Host "OK rules:   $RulesDest"
Write-Host "OK hooks:   $HooksJsonDest + $(Join-Path $PackRoot '.cursor\hooks.json')"
Write-Host "OK notes:   $(Join-Path $CursorRoot 'notes')"
Write-Host "No files written under USERPROFILE"
Write-Host ""
Write-Host "Next: Open parent workspace in Cursor, restart once, check Hooks tab (empty is OK)."
Write-Host "Notes: .cursor/notes/daily + .cursor/notes/projects (problems via /note)."
Write-Host "You can delete .cursor and re-run this script anytime."
