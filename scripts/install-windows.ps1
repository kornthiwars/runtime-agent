# Link pack skills + rules + Cursor hooks + model-rust into the outer workspace
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
$ModelSrc = Join-Path $PackRoot "model-rust"
$ModelDest = Join-Path $WorkspaceRoot "model-rust"
$SkillNamesFile = Join-Path $PackRoot "scripts\skill-names.txt"
$SkillNames = @(Get-Content -Path $SkillNamesFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -notmatch '^\s*#' })
if ($SkillNames.Count -eq 0) { throw "No skill names in $SkillNamesFile" }
if (-not (Test-Path (Join-Path $HooksSrc "hooks.windows.json"))) {
  throw "Missing cursor-hooks pack: $HooksSrc"
}
if (-not (Test-Path (Join-Path $ModelSrc "Cargo.toml"))) {
  throw "Missing model-rust pack: $ModelSrc"
}

New-Item -ItemType Directory -Force -Path $CursorRoot | Out-Null
# If skills was a whole-folder junction (e.g. to another pack), replace with a real dir
# of per-skill junctions — never mklink into the old pack tree.
Remove-PathForLink $SkillsDest
New-Item -ItemType Directory -Force -Path $SkillsDest | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $CursorRoot "plans") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $CursorRoot "features") | Out-Null

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

# Cursor agent hooks (copy OS-specific json + scripts; keep local state/)
New-Item -ItemType Directory -Force -Path $HooksDest | Out-Null
$StateDest = Join-Path $HooksDest "state"
New-Item -ItemType Directory -Force -Path $StateDest | Out-Null
Copy-Item -Force (Join-Path $HooksSrc "hooks.windows.json") $HooksJsonDest
Copy-Item -Force (Join-Path $HooksSrc "model-rust-auto.ps1") (Join-Path $HooksDest "model-rust-auto.ps1")
Copy-Item -Force (Join-Path $HooksSrc "model-rust-auto.sh") (Join-Path $HooksDest "model-rust-auto.sh")
Copy-Item -Force (Join-Path $HooksSrc "model-rust-auto.mjs") (Join-Path $HooksDest "model-rust-auto.mjs")
Copy-Item -Force (Join-Path $HooksSrc "state.gitignore") (Join-Path $StateDest ".gitignore")
Write-Host "Installed Cursor hooks -> $HooksJsonDest"

# model-rust junction at workspace root
Remove-PathForLink $ModelDest
cmd /c "mklink /J `"$ModelDest`" `"$ModelSrc`"" | Out-Null
Write-Host "Linked model-rust -> $ModelSrc"

Write-Host ""
Write-Host "OK skills:  $SkillsDest"
Write-Host "OK rules:   $RulesDest"
Write-Host "OK hooks:   $HooksJsonDest"
Write-Host "OK model:   $ModelDest"
Write-Host "No files written under USERPROFILE"
Write-Host ""
Write-Host "Next (once per machine):"
Write-Host "  1. Copy agent-skills\model-rust\.env.example -> .env and fill MONGODB_URI"
Write-Host "  2. cd agent-skills\model-rust ; cargo build"
Write-Host "  3. Open parent workspace in Cursor, restart once, check Hooks tab"
Write-Host "You can delete .cursor and re-run this script anytime."
