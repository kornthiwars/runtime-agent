# Install git hooks for this pack repo (optional)
$ErrorActionPreference = "Stop"
$PackRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$HookSrc = Join-Path $PackRoot "scripts\hooks\pre-commit"
$HookDestDir = Join-Path $PackRoot ".git\hooks"
$HookDest = Join-Path $HookDestDir "pre-commit"
if (-not (Test-Path $HookDestDir)) { throw "Not a git repo: $PackRoot" }
Copy-Item -Force $HookSrc $HookDest
# Normalize LF for sh on Windows Git
$c = [IO.File]::ReadAllText($HookDest) -replace "`r`n", "`n"
[IO.File]::WriteAllText($HookDest, $c)
Write-Host "Installed pre-commit -> $HookDest"
