# pre-commit (Windows): match pack-ci — no bash/python3 required
$ErrorActionPreference = "Stop"
$PackRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $PackRoot

& .\scripts\validate-skill-names.ps1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& .\scripts\run-evals.ps1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& .\scripts\run-behavior-evals.ps1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& .\scripts\smoke-notes-daily.ps1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

exit 0
