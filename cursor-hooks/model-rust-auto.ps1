# model-rust auto memory: stage Agent prompts, persist on stop.
# Fail open. Not every keystroke — every submitted Agent turn (min length).
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("beforeSubmitPrompt", "afterAgentResponse", "stop")]
  [string]$Event
)

$ErrorActionPreference = "Continue"

# Capture stdin immediately (Windows Cursor often redirects stdio; read OpenStandardInput).
$script:RawStdin = ""
try {
  $stdin = [Console]::OpenStandardInput()
  if ($null -ne $stdin) {
    $reader = New-Object System.IO.StreamReader($stdin, [Text.Encoding]::UTF8, $true, 1024, $true)
    $script:RawStdin = $reader.ReadToEnd()
    $reader.Dispose()
  }
} catch {
  $script:RawStdin = ""
}
if ([string]::IsNullOrWhiteSpace($script:RawStdin)) {
  try {
    $chunks = @($input)
    if ($chunks.Count -gt 0) { $script:RawStdin = [string]::Join("`n", $chunks) }
  } catch { }
}

$WorkspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$StateDir = Join-Path $PSScriptRoot "state"
$StatePath = Join-Path $StateDir "model-rust-pending.json"
$LogPath = Join-Path $StateDir "model-rust-auto.log"
$DisablePath = Join-Path $StateDir "model-rust-auto.off"
$BinDebug = Join-Path $WorkspaceRoot "agent-skills\model-rust\target\debug\model-rust.exe"
$BinRelease = Join-Path $WorkspaceRoot "agent-skills\model-rust\target\release\model-rust.exe"
$BinDebugAlt = Join-Path $WorkspaceRoot "model-rust\target\debug\model-rust.exe"
$BinReleaseAlt = Join-Path $WorkspaceRoot "model-rust\target\release\model-rust.exe"
$SkillPattern = '(?i)(^|\s)/(fix|make|feature|plan|ship|review|note|upgrades)\b'
$SkipPattern = '(?i)^(ok|okay|thanks|thank you|ยืนยัน|confirm|yes|y|no|n|ได้|ครับ|ค่ะ)\s*$'
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false
$MinPromptChars = 6

function Write-EmptyJson {
  param([string]$Json = "{}")
  [Console]::Out.Write($Json)
}

function Ensure-StateDir {
  if (-not (Test-Path $StateDir)) {
    New-Item -ItemType Directory -Force -Path $StateDir | Out-Null
  }
}

function Write-Log([string]$Message) {
  Ensure-StateDir
  $line = "{0} {1}" -f (Get-Date).ToString("o"), $Message
  [System.IO.File]::AppendAllText($LogPath, $line + [Environment]::NewLine, $Utf8NoBom)
}

function Write-JsonFile([string]$Path, $Object) {
  Ensure-StateDir
  $json = $Object | ConvertTo-Json -Depth 6 -Compress
  [System.IO.File]::WriteAllText($Path, $json, $Utf8NoBom)
}

function Read-StdinJson {
  $raw = $script:RawStdin
  if ($null -ne $raw) {
    $raw = $raw.TrimStart([char]0xFEFF)
    $idxObj = $raw.IndexOf('{')
    $idxArr = $raw.IndexOf('[')
    $idx = -1
    if ($idxObj -ge 0 -and $idxArr -ge 0) { $idx = [Math]::Min($idxObj, $idxArr) }
    elseif ($idxObj -ge 0) { $idx = $idxObj }
    elseif ($idxArr -ge 0) { $idx = $idxArr }
    if ($idx -gt 0) { $raw = $raw.Substring($idx) }
    $raw = $raw.Trim()
  }
  Write-Log ("STDIN bytes={0}" -f $(if ($null -eq $raw) { 0 } else { $raw.Length }))
  if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
  try { return ($raw | ConvertFrom-Json) } catch {
    Write-Log ("FAIL json-parse err={0}" -f $_.Exception.Message)
    return $null
  }
}

function Read-State {
  if (-not (Test-Path $StatePath)) { return $null }
  try {
    $raw = [System.IO.File]::ReadAllText($StatePath, $Utf8NoBom)
    return ($raw | ConvertFrom-Json)
  } catch { return $null }
}

function Write-State($obj) {
  Write-JsonFile -Path $StatePath -Object $obj
}

function Clear-State {
  if (Test-Path $StatePath) { Remove-Item -Force $StatePath -ErrorAction SilentlyContinue }
}

function Sanitize([string]$text, [int]$maxChars) {
  if ([string]::IsNullOrWhiteSpace($text)) { return "" }
  $lines = $text -split "`r?`n" | Where-Object {
    $_ -notmatch '(?i)(MONGODB_URI|password\s*=|api[_-]?key|secret\s*=|Bearer\s+[A-Za-z0-9\._\-]+)'
  } | ForEach-Object {
    $_ -replace '(?i)\b(?:mongodb(?:\+srv)?|postgres(?:ql)?|mysql|mariadb|redis|amqp|https?)://[^\s/"'']+:[^\s/"'']+@[^\s]+', '[REDACTED_URI]'
  }
  $joined = ($lines -join "`n").Trim()
  if ($joined.Length -le $maxChars) { return $joined }
  return ($joined.Substring(0, [Math]::Max(0, $maxChars - 1)) + "…")
}

function Infer-SkillTag([string]$prompt) {
  $m = [regex]::Match($prompt, $SkillPattern)
  if ($m.Success) { return $m.Groups[2].Value.ToLowerInvariant() }
  return "chat"
}

function Get-ProjectFromText([string]$text) {
  $m = [regex]::Match($text, 'MODEL-RUST-PROJECT:\s*([a-z0-9][a-z0-9-]*)', 'IgnoreCase')
  if ($m.Success) { return $m.Groups[1].Value.ToLowerInvariant() }
  return $null
}

function Should-Stage([string]$prompt) {
  $p = $prompt.Trim()
  if ($p.Length -lt $MinPromptChars) { return $false }
  if ($p -match $SkipPattern) { return $false }
  return $true
}

function Resolve-Binary {
  foreach ($p in @($BinRelease, $BinDebug, $BinReleaseAlt, $BinDebugAlt)) {
    if (Test-Path $p) { return $p }
  }
  return $null
}

function Auto-Disabled {
  if (Test-Path $DisablePath) { return $true }
  if ($env:MODEL_RUST_AUTO -eq "0") { return $true }
  return $false
}

function Get-PromptText($obj) {
  if ($null -eq $obj) { return "" }
  foreach ($key in @("prompt", "prompt_text", "text", "message", "content")) {
    if ($null -ne $obj.$key -and -not [string]::IsNullOrWhiteSpace([string]$obj.$key)) {
      return [string]$obj.$key
    }
  }
  return ""
}

$inputObj = Read-StdinJson

if (Auto-Disabled) {
  Write-Log "SKIP disabled event=$Event"
  if ($Event -eq "beforeSubmitPrompt") { Write-EmptyJson '{"continue":true}'; exit 0 }
  Write-EmptyJson "{}"; exit 0
}

switch ($Event) {
  "beforeSubmitPrompt" {
    $prompt = Get-PromptText $inputObj
    Write-Log ("IN beforeSubmitPrompt chars={0} hasJson={1}" -f $prompt.Trim().Length, ($null -ne $inputObj))
    if (Should-Stage $prompt) {
      $tag = Infer-SkillTag $prompt
      Write-State ([pscustomobject]@{
          prompt       = (Sanitize $prompt 2000)
          skill        = $tag
          response     = ""
          createdAtIso = (Get-Date).ToString("o")
          saved        = $false
        })
      Write-Log ("STAGE skill={0} chars={1}" -f $tag, $prompt.Trim().Length)
    } else {
      Clear-State
      Write-Log "SKIP short/ack prompt"
    }
    Write-EmptyJson '{"continue":true}'
    exit 0
  }

  "afterAgentResponse" {
    $text = ""
    if ($null -ne $inputObj -and $null -ne $inputObj.text) { $text = [string]$inputObj.text }
    $state = Read-State
    if ($null -ne $state -and -not [bool]$state.saved) {
      $state.response = (Sanitize $text 2000)
      $proj = Get-ProjectFromText $text
      if ($proj) { $state | Add-Member -NotePropertyName project -NotePropertyValue $proj -Force }
      Write-State $state
      $pLog = if ($state.project) { [string]$state.project } else { "-" }
      Write-Log ("RESP chars={0} project={1}" -f $text.Length, $pLog)
    }
    Write-EmptyJson "{}"
    exit 0
  }

  "stop" {
    $status = "completed"
    if ($null -ne $inputObj -and $null -ne $inputObj.status) { $status = [string]$inputObj.status }
    # Ignore loop_count — same as model-rust-auto.mjs (tool loops must still save).
    if ($status -ne "completed") {
      Write-Log ("SKIP stop status={0}" -f $status)
      Write-EmptyJson "{}"
      exit 0
    }

    $state = Read-State
    if ($null -eq $state -or [bool]$state.saved -or [string]::IsNullOrWhiteSpace($state.prompt)) {
      Write-Log "SKIP stop no-pending"
      Write-EmptyJson "{}"
      exit 0
    }

    $bin = Resolve-Binary
    if (-not $bin) {
      Write-Log "FAIL no-binary"
      Write-EmptyJson "{}"
      exit 0
    }

    $promptText = [string]$state.prompt
    $resp = [string]$state.response
    $skill = [string]$state.skill
    if ([string]::IsNullOrWhiteSpace($skill)) { $skill = "chat" }

    $summary = Sanitize $resp 200
    if ([string]::IsNullOrWhiteSpace($summary)) { $summary = "agent completed /$skill" }

    $body = Sanitize $resp 2000
    $project = $null
    if ($null -ne $state.project -and -not [string]::IsNullOrWhiteSpace([string]$state.project)) {
      $project = ([string]$state.project).Trim().ToLowerInvariant()
    }
    if (-not $project) { $project = Get-ProjectFromText $resp }

    $tmp = Join-Path $StateDir "model-rust-auto-add.json"
    $stub = [ordered]@{
      prompt  = $promptText
      summary = $summary
      body    = $body
      tags    = @($skill, "auto")
      source  = "chat"
      skill   = $skill
    }
    if ($project) { $stub.project = $project }
    Write-JsonFile -Path $tmp -Object $stub

    try {
      $crateRoot = (Resolve-Path (Join-Path (Split-Path $bin -Parent) "..\..")).Path
      Push-Location $crateRoot
      try {
        $out = & $bin add --json $tmp 2>&1 | Out-String
      } finally {
        Pop-Location
      }
      if ($LASTEXITCODE -eq 0) {
        Clear-State
        $pLog = if ($project) { $project } else { "-" }
        Write-Log ("SAVED ok project={0} out={1}" -f $pLog, ($out.Trim()))
      } else {
        Write-Log ("FAIL add exit={0} out={1}" -f $LASTEXITCODE, ($out.Trim()))
      }
    } catch {
      Write-Log ("FAIL add exception={0}" -f $_.Exception.Message)
    } finally {
      if (Test-Path $tmp) { Remove-Item -Force $tmp -ErrorAction SilentlyContinue }
    }

    Write-EmptyJson "{}"
    exit 0
  }
}

Write-EmptyJson "{}"
exit 0
