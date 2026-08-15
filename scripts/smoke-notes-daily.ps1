# Smoke: notes-daily beforeSubmitPrompt -> afterAgentResponse fills Result (no pending).
# Not a live Cursor run — drives notes-daily.ps1 with synthetic stdin JSON.
$ErrorActionPreference = "Stop"
$PackRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$HookSrc = Join-Path $PackRoot "cursor-hooks\notes-daily.ps1"
if (-not (Test-Path -LiteralPath $HookSrc)) { throw "Missing $HookSrc" }

$utf8 = New-Object System.Text.UTF8Encoding $false
$stamp = Get-Date -Format "yyyyMMddHHmmss"
$root = Join-Path $env:TEMP "notes-daily-smoke-$stamp"
New-Item -ItemType Directory -Force -Path "$root\.cursor\hooks\state", "$root\.cursor\notes\daily" | Out-Null
Copy-Item -Force $HookSrc "$root\.cursor\hooks\notes-daily.ps1"

function Invoke-Hook([string]$Event, $Obj) {
  $json = $Obj | ConvertTo-Json -Compress -Depth 8
  $tmp = Join-Path $env:TEMP ("nds-" + [guid]::NewGuid().ToString("n").Substring(0, 8) + ".json")
  [IO.File]::WriteAllText($tmp, $json, $utf8)
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "powershell"
  $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$root\.cursor\hooks\notes-daily.ps1`" $Event"
  $psi.WorkingDirectory = $root
  $psi.RedirectStandardInput = $true
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.UseShellExecute = $false
  $p = [Diagnostics.Process]::Start($psi)
  $bytes = [IO.File]::ReadAllBytes($tmp)
  $p.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
  $p.StandardInput.Close()
  $null = $p.StandardOutput.ReadToEnd()
  $err = $p.StandardError.ReadToEnd()
  if (-not $p.WaitForExit(25000)) { $p.Kill(); throw "timeout $Event" }
  Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
  if ($err) { throw "stderr ${Event}: $err" }
}

$ws = ($root -replace "\\", "/")
Invoke-Hook beforeSubmitPrompt @{
  hook_event_name = "beforeSubmitPrompt"
  prompt = "smoke-notes-daily"
  workspace_roots = @($ws)
}
Invoke-Hook afterAgentResponse @{
  hook_event_name = "afterAgentResponse"
  text = "OUTCOME: smoke-ok`nSTATUS: READY"
  workspace_roots = @($ws)
}
# Intentionally skip stop — Result must already be filled.

$dailyPath = Join-Path $root (".cursor\notes\daily\" + (Get-Date -Format "yyyy-MM-dd") + ".md")
if (-not (Test-Path -LiteralPath $dailyPath)) { throw "missing daily $dailyPath" }
$text = [IO.File]::ReadAllText($dailyPath, $utf8)
if ($text -match "notes-daily:pending") { throw "pending marker still present after afterAgentResponse" }
if ($text -notmatch "OUTCOME: smoke-ok") { throw "OUTCOME missing in Result" }
if ($text -notmatch "smoke-notes-daily") { throw "prompt missing" }

Write-Host "OK smoke-notes-daily (Result filled without stop)"
Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
