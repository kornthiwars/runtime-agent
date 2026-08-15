# Install git hooks for this pack repo (optional)
$ErrorActionPreference = "Stop"
$PackRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$GitDir = Join-Path $PackRoot ".git"
if (-not (Test-Path $GitDir)) { throw "Not a git repo: $PackRoot" }
if (-not (Get-Item $GitDir).PSIsContainer) {
  throw ".git is not a directory (worktree/submodule?) — install hooks manually into the real git dir"
}
$HookSrc = Join-Path $PackRoot "scripts\hooks\pre-commit"
$HookSrcPs1 = Join-Path $PackRoot "scripts\hooks\pre-commit.ps1"
$HookDestDir = Join-Path $PackRoot ".git\hooks"
$HookDest = Join-Path $HookDestDir "pre-commit"
if (-not (Test-Path $HookDestDir)) { throw "Missing hooks dir: $HookDestDir" }
if (Test-Path $HookDest) {
  Write-Host "WARNING: overwriting existing $HookDest"
}
Copy-Item -Force $HookSrc $HookDest
if (Test-Path $HookSrcPs1) {
  Copy-Item -Force $HookSrcPs1 (Join-Path $HookDestDir "pre-commit.ps1")
}
# Normalize LF for sh on Windows Git
$c = [IO.File]::ReadAllText($HookDest) -replace "`r`n", "`n"
[IO.File]::WriteAllText($HookDest, $c)
Write-Host "Installed pre-commit -> $HookDest (Windows uses PowerShell runners via pre-commit.ps1)"
