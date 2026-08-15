# Notes daily auto: append every user prompt to .cursor/notes/daily/YYYY-MM-DD.md
# Fail-open: always exit 0 and emit valid JSON for Cursor.
# Disable: NOTES_DAILY_AUTO=0 or .cursor/hooks/state/notes-daily.off
#
# IMPORTANT: Keep this file ASCII-only in source literals. Windows PowerShell 5
# on Thai CP874 mis-parses UTF-8 scripts without BOM and corrupts unicode punct.

$ErrorActionPreference = "Continue"
$Utf8 = New-Object System.Text.UTF8Encoding $false

function Write-HookOut([string]$Json) {
  [Console]::Out.WriteLine($Json)
}

function Read-Utf8([string]$Path) {
  return [System.IO.File]::ReadAllText($Path, $Utf8)
}

function Write-Utf8([string]$Path, [string]$Content) {
  [System.IO.File]::WriteAllText($Path, $Content, $Utf8)
}

function Append-Utf8([string]$Path, [string]$Content) {
  [System.IO.File]::AppendAllText($Path, $Content, $Utf8)
}

function Write-DebugLog([string]$Message) {
  try {
    $dir = Join-Path (Get-Location).Path ".cursor\hooks\state"
    if (-not (Test-Path -LiteralPath $dir)) {
      New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $path = Join-Path $dir "notes-daily.debug.log"
    Append-Utf8 $path ("$(Get-Date -Format o) $Message`r`n")
  } catch {}
}

function ConvertFrom-JsonBytes([byte[]]$bytes) {
  if (-not $bytes -or $bytes.Length -eq 0) { return $null }
  # Cursor sends UTF-8 JSON. Never decode with Encoding.Default (CP874 on Thai
  # Windows) -- that succeeds as JSON but turns Thai into mojibake.
  if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
    $raw = [Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2)
    try { return (ConvertFrom-Json -InputObject $raw) } catch { return $null }
  }
  if ($bytes.Length -ge 4 -and $bytes[0] -ne 0 -and $bytes[1] -eq 0 -and $bytes[3] -eq 0) {
    $raw = [Text.Encoding]::Unicode.GetString($bytes)
    try { return (ConvertFrom-Json -InputObject $raw) } catch {}
  }
  $offset = 0
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $offset = 3
  }
  $raw = $Utf8.GetString($bytes, $offset, $bytes.Length - $offset).Trim().Trim([char]0)
  try {
    $obj = ConvertFrom-Json -InputObject $raw
    # Prefer field text sliced from raw UTF-8 JSON (avoids rare PS serializer issues).
    foreach ($field in @("prompt", "prompt_text", "text", "user_prompt", "response", "message", "content")) {
      $fromRaw = Get-JsonStringField $raw $field
      if (-not [string]::IsNullOrWhiteSpace($fromRaw)) {
        try { $obj | Add-Member -NotePropertyName $field -NotePropertyValue $fromRaw -Force } catch {}
      }
    }
    return $obj
  } catch { return $null }
}

function Repair-Utf8Mojibake([string]$text) {
  if ([string]::IsNullOrEmpty($text)) { return $text }

  # Thai Windows: UTF-8 bytes decoded with CP874 (Encoding.Default) leave
  # real Thai letters mixed with euro/C1 controls.
  if (($text -match '[\u0E00-\u0E7F]') -and ($text -match '[\u0080-\u009F\u20AC]')) {
    try {
      $cp874 = [Text.Encoding]::GetEncoding(874)
      $recovered = $Utf8.GetString($cp874.GetBytes($text))
      if (
        $recovered -match '[\u0E00-\u0E7F]{3,}' -and
        $recovered.Length -lt $text.Length -and
        $recovered -notmatch '[\u0080-\u009F\u20AC]'
      ) {
        return $recovered
      }
    } catch {}
  }

  # Classic UTF-8-as-Windows-1252 (Latin mojibake). Build pattern in ASCII source.
  $latinMojibake = ([string][char]0x00E0) + '[' + [char]0x00B8 + [char]0x00B9 + ']|' + [char]0x00E2 + [char]0x20AC
  if ($text -match $latinMojibake) {
    try {
      $latin1 = [Text.Encoding]::GetEncoding(1252)
      $recovered = $Utf8.GetString($latin1.GetBytes($text))
      if ($recovered -match '[\u0E00-\u0E7F]{3,}' -and $recovered.Length -le $text.Length) {
        return $recovered
      }
    } catch {}
  }
  return $text
}

function Get-JsonStringField([string]$raw, [string]$field) {
  if ([string]::IsNullOrEmpty($raw) -or [string]::IsNullOrEmpty($field)) { return $null }
  $pat = '"' + [regex]::Escape($field) + '"\s*:\s*"((?:\\.|[^"\\])*)"'
  $m = [regex]::Match($raw, $pat)
  if (-not $m.Success) { return $null }
  $s = $m.Groups[1].Value
  $s = $s.Replace('\\"', '"').Replace('\\n', "`n").Replace('\\r', "`r").Replace('\\t', "`t").Replace('\\\\', '\')
  $s = [regex]::Replace($s, '\\u([0-9a-fA-F]{4})', {
      param($match)
      [char][Convert]::ToInt32($match.Groups[1].Value, 16)
    })
  return $s
}

function Get-Payload {
  # Cursor redirects JSON to stdin. On Windows, the first read can race and see
  # an empty pipe; wait briefly for bytes, then decode with encoding fallbacks.
  $bytes = $null
  try {
    $stdin = [Console]::OpenStandardInput()
    $ms = New-Object System.IO.MemoryStream
    $buf = New-Object byte[] 8192
    $deadline = [DateTime]::UtcNow.AddMilliseconds(2500)
    $got = $false
    while ([DateTime]::UtcNow -lt $deadline) {
      $remaining = [int][Math]::Max(50, ($deadline - [DateTime]::UtcNow).TotalMilliseconds)
      $async = $stdin.BeginRead($buf, 0, $buf.Length, $null, $null)
      if (-not $async.AsyncWaitHandle.WaitOne($remaining)) {
        try { $stdin.EndRead($async) | Out-Null } catch {}
        if ($got) { break }
        continue
      }
      $n = $stdin.EndRead($async)
      if ($n -le 0) {
        if ($got) { break }
        Start-Sleep -Milliseconds 40
        continue
      }
      $ms.Write($buf, 0, $n)
      $got = $true
      $probe = $Utf8.GetString($ms.ToArray()).Trim()
      if ($probe.StartsWith('{') -and $probe.EndsWith('}')) {
        try { $null = $probe | ConvertFrom-Json; break } catch {}
      }
    }
    $bytes = $ms.ToArray()
  } catch {
    Write-DebugLog ("OpenStandardInput failed: " + $_.Exception.Message)
  }

  $payload = ConvertFrom-JsonBytes $bytes
  if ($payload) {
    Write-DebugLog ("payload ok via bytes len=" + $bytes.Length)
    return $payload
  }

  try {
    [Console]::InputEncoding = $Utf8
    $raw = [Console]::In.ReadToEnd()
    if (-not [string]::IsNullOrWhiteSpace($raw)) {
      try {
        $payload = $raw | ConvertFrom-Json
        Write-DebugLog ("payload ok via Console.In chars=" + $raw.Length)
        return $payload
      } catch {
        Write-DebugLog ("Console.In JSON parse fail chars=" + $raw.Length)
      }
    }
  } catch {
    Write-DebugLog ("Console.In failed: " + $_.Exception.Message)
  }

  Write-DebugLog ("payload missing bytes=" + $(if ($bytes) { $bytes.Length } else { 0 }))
  return $null
}

function Normalize-WorkspacePath([string]$Path) {
  if ([string]::IsNullOrWhiteSpace($Path)) { return $Path }
  $p = $Path.Trim()
  # Cursor on Windows sends roots like "/c:/Users/..." which break Join-Path
  if ($p -match '^/([A-Za-z]):[/\\](.*)$') {
    $p = $Matches[1] + ':\' + (($Matches[2] -replace '/', '\'))
  }
  elseif ($p -match '^file:///([A-Za-z]):/(.*)$') {
    $p = $Matches[1] + ':\' + (($Matches[2] -replace '/', '\'))
  }
  try { return [System.IO.Path]::GetFullPath($p) } catch { return $p }
}

function Test-Disabled([string]$WorkspaceRoot) {
  if ($env:NOTES_DAILY_AUTO -eq "0") { return $true }
  $off = Join-Path $WorkspaceRoot ".cursor\hooks\state\notes-daily.off"
  return (Test-Path -LiteralPath $off)
}

function Get-WorkspaceRoot($payload) {
  if ($payload -and $payload.workspace_roots -and $payload.workspace_roots.Count -gt 0) {
    return Normalize-WorkspacePath ([string]$payload.workspace_roots[0])
  }
  $cwd = (Get-Location).Path
  if (Test-Path (Join-Path $cwd ".cursor")) { return $cwd }
  $parent = Split-Path $cwd -Parent
  if (Test-Path (Join-Path $parent ".cursor")) { return $parent }
  return $cwd
}

function Resolve-NotesWorkspace([string]$WorkspaceRoot) {
  $WorkspaceRoot = Normalize-WorkspacePath $WorkspaceRoot
  # Cursor often binds project hooks to the nested pack git root (agent-skills),
  # while install puts notes under the parent workspace (Skills). Prefer parent.
  $packHook = Join-Path $WorkspaceRoot "cursor-hooks\notes-daily.ps1"
  $parent = Split-Path $WorkspaceRoot -Parent
  $parentNotes = Join-Path $parent ".cursor\notes"
  if ((Test-Path -LiteralPath $packHook) -and (Test-Path -LiteralPath $parentNotes)) {
    return $parent
  }
  return $WorkspaceRoot
}

function Redact-Text([string]$text) {
  if ([string]::IsNullOrEmpty($text)) { return $text }
  $t = $text
  $t = [regex]::Replace($t, '(?i)(mongodb(\+srv)?://)[^\s]+', '$1***')
  $t = [regex]::Replace($t, '(?i)\b(api[_-]?key|token|secret|password)\s*[=:]\s*\S+', '$1=***')
  $t = [regex]::Replace($t, '(?i)Bearer\s+\S+', 'Bearer ***')
  $t = [regex]::Replace($t, '(?is)-----BEGIN [^-]*PRIVATE KEY-----.*?-----END [^-]*PRIVATE KEY-----', '[REDACTED_PRIVATE_KEY]')
  return $t
}

function Get-PromptText($payload) {
  foreach ($k in @("prompt", "prompt_text", "text", "user_prompt")) {
    if ($payload.PSObject.Properties.Name -contains $k) {
      $v = [string]$payload.$k
      if (-not [string]::IsNullOrWhiteSpace($v)) { return $v }
    }
  }
  return ""
}

function Get-ThaiConfirmWord {
  # Build "confirm" Thai synonym from codepoints (ASCII-safe source)
  return (-join @(
      [char]0x0E22, [char]0x0E37, [char]0x0E19,
      [char]0x0E22, [char]0x0E31, [char]0x0E19
    ))
}

function Infer-Skill([string]$prompt) {
  if ($prompt -match '(?m)^/(fix|make|plan|feature|review|ship|note|upgrades)\b') {
    return $Matches[1]
  }
  $thaiConfirm = Get-ThaiConfirmWord
  if ($prompt -match ("^(ok|yes|$([regex]::Escape($thaiConfirm))|confirm)\s*$")) {
    return "ack"
  }
  return "chat"
}

function Ensure-DailyFile([string]$path, [string]$date) {
  $dir = Split-Path $path -Parent
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  if (-not (Test-Path -LiteralPath $path)) {
    $starter = @"
# Daily - $date

## Context
- Focus: -
- Projects: -

## Prompts

## Outcomes
- Done: -
- Open: -

## Problems linked
- -

"@
    Write-Utf8 $path $starter
  }
}

function Get-NextIndex([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { return 1 }
  $content = Read-Utf8 $path
  if ([string]::IsNullOrEmpty($content)) { return 1 }
  # Accept ASCII "|", middle-dot, or any non-digit junk left by old CP874 writes
  $matches = [regex]::Matches($content, '(?m)^### (\d+)\b')
  if ($matches.Count -eq 0) { return 1 }
  $max = 0
  foreach ($m in $matches) {
    $n = [int]$m.Groups[1].Value
    if ($n -gt $max) { $max = $n }
  }
  return $max + 1
}

function Get-LastResponsePath([string]$workspace) {
  return (Join-Path $workspace ".cursor\hooks\state\notes-daily.last-response.txt")
}

function Save-LastResponse([string]$workspace, [string]$text) {
  if ([string]::IsNullOrWhiteSpace($text)) { return }
  $dir = Join-Path $workspace ".cursor\hooks\state"
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  Write-Utf8 (Get-LastResponsePath $workspace) $text
}

function Read-LastResponse([string]$workspace) {
  $path = Get-LastResponsePath $workspace
  if (-not (Test-Path -LiteralPath $path)) { return "" }
  try { return (Read-Utf8 $path) } catch { return "" }
}

function Clear-LastResponse([string]$workspace) {
  $path = Get-LastResponsePath $workspace
  if (Test-Path -LiteralPath $path) {
    Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
  }
}

function Trim-ResultLine([string]$line) {
  if ([string]::IsNullOrWhiteSpace($line)) { return "" }
  $line = $line.Trim()
  if ($line.Length -gt 200) { return $line.Substring(0, 197) + "..." }
  return $line
}

function Select-CleanLines([string]$text) {
  $t = $text -replace '\\r\\n', "`n" -replace '\\n', "`n" -replace '\\r', "`n"
  $t = $t -replace "`r`n", "`n" -replace "`r", "`n"
  return @(
    $t -split "`n" |
      ForEach-Object { $_.Trim() } |
      Where-Object {
        $_ -ne "" -and
        $_ -notmatch '^```' -and
        $_ -notmatch '^\|[-: ]+\|$' -and
        $_ -notmatch '^REPORT\s*$'
      }
  )
}

function Summarize-FromOutcome([string[]]$lines, [int]$maxLines) {
  $start = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^OUTCOME\s*:') { $start = $i; break }
  }
  if ($start -lt 0) { return $null }
  $chunk = New-Object System.Collections.Generic.List[string]
  for ($i = $start; $i -lt $lines.Count -and $chunk.Count -lt $maxLines; $i++) {
    $ln = $lines[$i]
    # Stop at next major skill block header
    if ($i -gt $start -and $ln -match '^(STATUS|OBJECTIVE|CHANGES|NEXT|EVIDENCE|VERIFY|MODE|RISK|ENTERPRISE|BLAST_RADIUS|ROLLBACK|FINDINGS|GIT|DIFF)\s*:') {
      break
    }
    if ($i -gt $start -and $ln -match '^#{1,3}\s') { break }
    $trim = Trim-ResultLine $ln
    if ($trim) { [void]$chunk.Add($trim) }
  }
  if ($chunk.Count -eq 0) { return $null }
  return ($chunk -join "`n")
}

function Summarize-FromReport([string[]]$lines, [int]$maxLines) {
  $keys = @('STATUS', 'OBJECTIVE', 'CHANGES', 'NEXT', 'VERIFY')
  $picked = New-Object System.Collections.Generic.List[string]
  foreach ($key in $keys) {
    if ($picked.Count -ge $maxLines) { break }
    foreach ($ln in $lines) {
      if ($ln -match ("^" + $key + "\s*:\s*(.+)$")) {
        $val = $Matches[1].Trim()
        $emDash = [string][char]0x2014
        if ($val -eq "" -or $val -eq "-" -or $val -eq $emDash) { break }
        $trim = Trim-ResultLine ($key + ': ' + $val)
        if ($trim) { [void]$picked.Add($trim) }
        break
      }
    }
  }
  if ($picked.Count -eq 0) { return $null }
  return ($picked -join "`n")
}

function Summarize-ResultText([string]$text, [int]$maxLines = 6) {
  if ([string]::IsNullOrWhiteSpace($text)) { return "" }
  $t = Repair-Utf8Mojibake (Redact-Text $text)
  $lines = @(Select-CleanLines $t)
  if ($lines.Count -eq 0) { return "" }

  $fromOutcome = Summarize-FromOutcome $lines $maxLines
  if ($fromOutcome) { return $fromOutcome }

  $fromReport = Summarize-FromReport $lines $maxLines
  if ($fromReport) { return $fromReport }

  # Chat / freeform: prefer the end of the reply (closing summary), not the opener.
  $take = @($lines | Select-Object -Last $maxLines)
  $out = foreach ($line in $take) { Trim-ResultLine $line }
  $out = @($out | Where-Object { $_ })
  return ($out -join "`n")
}

function Format-ResultBlock([string]$body) {
  $body = ($body -replace "`r`n", "`n" -replace "`r", "`n").Trim()
  if ([string]::IsNullOrWhiteSpace($body)) { return "**Result:** completed" }
  if ($body -match "`n") {
    return "**Result:**`n$body"
  }
  return "**Result:** $body"
}

function Append-Prompt([string]$workspace, [string]$prompt) {
  $date = Get-Date -Format "yyyy-MM-dd"
  $time = Get-Date -Format "HH:mm"
  $daily = Join-Path $workspace ".cursor\notes\daily\$date.md"
  Ensure-DailyFile $daily $date
  Complete-Pending $workspace "continued"
  Clear-LastResponse $workspace
  $idx = Get-NextIndex $daily
  $nn = "{0:D2}" -f $idx
  $skill = Infer-Skill $prompt
  $safe = Redact-Text $prompt
  $block = @"

### $nn | $time | $skill
**Prompt:**
$safe

**Result:** -
<!-- notes-daily:pending -->
"@
  Append-Utf8 $daily $block
}

function Complete-Pending([string]$workspace, [string]$statusOrSummary) {
  $date = Get-Date -Format "yyyy-MM-dd"
  $daily = Join-Path $workspace ".cursor\notes\daily\$date.md"
  if (-not (Test-Path -LiteralPath $daily)) { return }
  $content = Read-Utf8 $daily
  if ($content -notmatch '<!-- notes-daily:pending -->') { return }
  $body = if ([string]::IsNullOrWhiteSpace($statusOrSummary)) { "completed" } else { $statusOrSummary }
  $resultBlock = Format-ResultBlock $body
  # Match any Result placeholder (ASCII "-", em dash, or CP874 garbage)
  $pattern = '(?s)\*\*Result:\*\*[^\r\n]*\r?\n<!-- notes-daily:pending -->'
  $matches = [regex]::Matches($content, $pattern)
  if ($matches.Count -eq 0) { return }
  $m = $matches[$matches.Count - 1]
  $content = $content.Remove($m.Index, $m.Length).Insert($m.Index, $resultBlock)
  Write-Utf8 $daily $content
}

try {
  # Prefer CLI event arg (hooks.json) so stop still works if stdin JSON fails.
  $event = "beforeSubmitPrompt"
  if ($args.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace([string]$args[0])) {
    $event = [string]$args[0]
  }

  $payload = Get-Payload
  if ($payload -and $payload.hook_event_name) {
    $event = [string]$payload.hook_event_name
  }

  $ws = Resolve-NotesWorkspace (Get-WorkspaceRoot $payload)
  if (Test-Disabled $ws) {
    if ($event -eq "beforeSubmitPrompt") { Write-HookOut '{"continue":true}' }
    else { Write-HookOut "{}" }
    exit 0
  }

  if ($event -eq "afterAgentResponse") {
    $text = ""
    if ($payload) {
      foreach ($k in @("text", "response", "message", "content")) {
        if ($payload.PSObject.Properties.Name -contains $k) {
          $v = [string]$payload.$k
          if (-not [string]::IsNullOrWhiteSpace($v)) { $text = $v; break }
        }
      }
    }
    $text = Repair-Utf8Mojibake $text
    Save-LastResponse $ws $text
    Write-DebugLog ("afterAgentResponse chars=" + $(if ($text) { $text.Length } else { 0 }))
    Write-HookOut "{}"
    exit 0
  }

  if ($event -eq "stop") {
    $status = "completed"
    if ($payload -and $payload.status) { $status = [string]$payload.status }
    $summary = Summarize-ResultText (Read-LastResponse $ws) 6
    if ([string]::IsNullOrWhiteSpace($summary)) { $summary = $status }
    elseif ($status -ne "completed") { $summary = "$status`n$summary" }
    Complete-Pending $ws $summary
    Clear-LastResponse $ws
    Write-HookOut "{}"
    exit 0
  }

  $prompt = ""
  if ($payload) { $prompt = Get-PromptText $payload }
  $prompt = Repair-Utf8Mojibake $prompt
  if (-not [string]::IsNullOrWhiteSpace($prompt)) {
    Append-Prompt $ws $prompt
  } else {
    Write-DebugLog "beforeSubmitPrompt with empty prompt (payload missing or no prompt field)"
  }
  Write-HookOut '{"continue":true}'
  exit 0
}
catch {
  Write-DebugLog ("top-level catch: " + $_.Exception.Message)
  try {
    if ($event -eq "beforeSubmitPrompt") { Write-HookOut '{"continue":true}' }
    else { Write-HookOut "{}" }
  } catch {}
  exit 0
}
