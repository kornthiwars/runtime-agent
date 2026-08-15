#!/usr/bin/env bash
# Notes daily auto — append every user prompt to .cursor/notes/daily/YYYY-MM-DD.md
# Fail-open. Disable: NOTES_DAILY_AUTO=0 or .cursor/hooks/state/notes-daily.off
set +e

emit() { printf '%s\n' "$1"; }

PAYLOAD="$(cat || true)"
EVENT="${1:-beforeSubmitPrompt}"
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"
if command -v python3 >/dev/null 2>&1 && python3 -c "import sys" >/dev/null 2>&1; then
  DETECTED="$(printf '%s' "$PAYLOAD" | python3 -c "import sys,json
try:
 d=json.load(sys.stdin)
 print(d.get('hook_event_name') or '')
except Exception:
 print('')" 2>/dev/null || true)"
  if [[ -n "$DETECTED" ]]; then EVENT="$DETECTED"; fi
fi

WS="$(pwd)"
if [[ -d "$WS/.cursor" ]]; then
  :
elif [[ -d "$(dirname "$WS")/.cursor" ]]; then
  WS="$(dirname "$WS")"
fi
if command -v python3 >/dev/null 2>&1; then
  WR="$(printf '%s' "$PAYLOAD" | python3 -c "import sys,json
try:
 d=json.load(sys.stdin)
 roots=d.get('workspace_roots') or []
 print(roots[0] if roots else '')
except Exception:
 print('')" 2>/dev/null || true)"
  if [[ -n "$WR" ]]; then WS="$WR"; fi
fi

# Normalize file:// and Windows-style roots for Git Bash / MSYS
WS="${WS#file://}"
WS="${WS#file:}"
if [[ "$WS" =~ ^/([A-Za-z]):/(.*)$ ]]; then
  WS="/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
elif [[ "$WS" =~ ^/([A-Za-z]):\\(.*)$ ]]; then
  WS="/${BASH_REMATCH[1]}/${BASH_REMATCH[2]//\\//}"
elif [[ "$WS" =~ ^([A-Za-z]):[\\/](.*)$ ]]; then
  WS="/${BASH_REMATCH[1]}/${BASH_REMATCH[2]//\\//}"
fi

HOOK_WS="$WS"
# Prefer parent workspace notes when hooks bind to nested pack git root
if [[ -f "$WS/cursor-hooks/notes-daily.sh" && -d "$(dirname "$WS")/.cursor/notes" ]]; then
  WS="$(dirname "$WS")"
fi

is_disabled() {
  [[ "${NOTES_DAILY_AUTO:-1}" == "0" ]] && return 0
  local roots=("$WS" "$HOOK_WS" "$(dirname "$WS")" "$(dirname "$HOOK_WS")")
  local r off
  for r in "${roots[@]}"; do
    [[ -n "$r" ]] || continue
    off="$r/.cursor/hooks/state/notes-daily.off"
    [[ -f "$off" ]] && return 0
  done
  [[ -n "$HOOK_DIR" && -f "$HOOK_DIR/state/notes-daily.off" ]] && return 0
  return 1
}

if is_disabled; then
  if [[ "$EVENT" == "beforeSubmitPrompt" ]]; then emit '{"continue":true}'; else emit "{}"; fi
  exit 0
fi

DATE="$(date +%Y-%m-%d)"
TIME="$(date +%H:%M)"
DAILY="$WS/.cursor/notes/daily/$DATE.md"
mkdir -p "$(dirname "$DAILY")"

LAST_RESP="$WS/.cursor/hooks/state/notes-daily.last-response.txt"
mkdir -p "$(dirname "$LAST_RESP")"

redact() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import re,sys
t=sys.stdin.read()
t=re.sub(r'(?i)(mongodb(\+srv)?://)\S+', r'\1***', t)
t=re.sub(r'(?i)\b(api[_-]?key|token|secret|password)\s*[=:]\s*\S+', r'\1=***', t)
t=re.sub(r'(?i)Bearer\s+\S+', 'Bearer ***', t)
t=re.sub(r'(?is)-----BEGIN [^-]*PRIVATE KEY-----.*?-----END [^-]*PRIVATE KEY-----', '[REDACTED_PRIVATE_KEY]', t)
sys.stdout.write(t)
" 2>/dev/null && return
  fi
  # No python3: scrub common secret shapes in sed; never pass-through raw (|| cat).
  sed -E \
    -e 's#(mongodb(\+srv)?://)[^[:space:]]+#\1***#Ig' \
    -e 's#\b((api[_-]?key|token|secret|password)[[:space:]]*[=:][[:space:]]*)[^[:space:]]+#\1***#Ig' \
    -e 's#Bearer[[:space:]]+[^[:space:]]+#Bearer ***#Ig'
}

summarize6() {
  python3 -c "
import re,sys
t=sys.stdin.read()
for a,b in [('\\\\r\\\\n','\n'),('\\\\n','\n'),('\\\\r','\n'),('\r\n','\n'),('\r','\n')]:
 t=t.replace(a,b)
lines=[]
for ln in t.split('\n'):
 ln=ln.strip()
 if (not ln or ln=='REPORT' or ln.startswith('\`\`\`')
     or re.match(r'^\|[-: ]+\|\$', ln) or re.match(r'^#{1,3}\s', ln)):
  continue
 lines.append(ln)

def trim(s, n=200):
 return s if len(s)<=n else s[:n-3]+'...'

def from_outcome(lines, max_lines=6):
 start=next((i for i,l in enumerate(lines) if re.match(r'^OUTCOME\s*:', l)), None)
 if start is None: return None
 stop=re.compile(r'^(STATUS|OBJECTIVE|CHANGES|NEXT|EVIDENCE|VERIFY|MODE|RISK|ENTERPRISE|BLAST_RADIUS|ROLLBACK|FINDINGS|GIT|DIFF)\s*:')
 out=[]
 for i in range(start, len(lines)):
  if i>start and (stop.match(lines[i]) or re.match(r'^#{1,3}\s', lines[i])):
   break
  out.append(trim(lines[i]))
  if len(out)>=max_lines: break
 return '\n'.join(out) if out else None

def from_report(lines, max_lines=6):
 keys=['STATUS','OBJECTIVE','CHANGES','NEXT','VERIFY']
 out=[]
 for key in keys:
  if len(out)>=max_lines: break
  # Prefer last match so closing REPORT wins over earlier prose.
  for ln in reversed(lines):
   m=re.match(r'^%s\s*:\s*(.+)$'%key, ln)
   if m:
    val=m.group(1).strip()
    if val and val not in ('-', '\u2014'):
     out.append(trim('%s: %s'%(key,val)))
    break
 return '\n'.join(out) if out else None

s=from_outcome(lines) or from_report(lines)
if not s:
 take=lines[-6:] if len(lines)>6 else lines
 s='\n'.join(trim(x) for x in take)
sys.stdout.write(s)
" 2>/dev/null || true
}

if [[ "$EVENT" == "afterAgentResponse" ]]; then
  TEXT="$(printf '%s' "$PAYLOAD" | python3 -c "import sys,json
try:
 d=json.load(sys.stdin)
 for k in ('text','response','message','content'):
  v=d.get(k)
  if isinstance(v,str) and v.strip():
   print(v); break
except Exception:
 pass" 2>/dev/null || true)"
  if [[ -n "$TEXT" ]]; then
    printf '%s' "$TEXT" | redact > "$LAST_RESP"
    # Fill Result early so a missing Cursor stop does not leave pending.
    SUMMARY="$(printf '%s' "$TEXT" | redact | summarize6)"
    if [[ -n "$SUMMARY" ]]; then
      YDAY="$(date -d 'yesterday' +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null || true)"
      for DAYFILE in "$DAILY" "$WS/.cursor/notes/daily/$YDAY.md"; do
        [[ -n "$DAYFILE" && -f "$DAYFILE" ]] || continue
        grep -q 'notes-daily:pending' "$DAYFILE" 2>/dev/null || continue
        SUMMARY_B64="$(printf '%s' "$SUMMARY" | python3 -c "import sys,base64; print(base64.b64encode(sys.stdin.buffer.read()).decode())" 2>/dev/null || true)"
        DAY_ESC="${DAYFILE//\\/\\\\}"
        python3 -c "
from pathlib import Path
import re, base64
p=Path(r'''$DAY_ESC''')
t=p.read_text(encoding='utf-8')
summary=base64.b64decode('$SUMMARY_B64').decode('utf-8') if '$SUMMARY_B64' else ''
if not summary: raise SystemExit(0)
block='**Result:**\\n'+summary if '\\n' in summary else '**Result:** '+summary
matches=list(re.finditer(r'\*\*Result:\*\*[^\n]*\n<!-- notes-daily:pending -->', t))
if matches:
 m=matches[-1]
 t=t[:m.start()]+block+t[m.end():]
 p.write_text(t, encoding='utf-8')
" 2>/dev/null || true
      done
    fi
  fi
  emit "{}"
  exit 0
fi

if [[ "$EVENT" == "stop" ]]; then
  STATUS="$(printf '%s' "$PAYLOAD" | python3 -c "import sys,json
try:
 print(json.load(sys.stdin).get('status') or 'completed')
except Exception:
 print('completed')" 2>/dev/null || echo completed)"
  SUMMARY=""
  if [[ -f "$LAST_RESP" ]]; then
    SUMMARY="$(redact < "$LAST_RESP" | summarize6)"
    rm -f "$LAST_RESP"
  fi
  if [[ -z "$SUMMARY" ]]; then SUMMARY="$STATUS"; fi
  if [[ "$STATUS" != "completed" && "$SUMMARY" != "$STATUS" ]]; then
    SUMMARY="$STATUS"$'\n'"$SUMMARY"
  fi
  YDAY="$(date -d 'yesterday' +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null || true)"
  for DAYFILE in "$DAILY" "$WS/.cursor/notes/daily/$YDAY.md"; do
    [[ -n "$DAYFILE" && -f "$DAYFILE" ]] || continue
    grep -q 'notes-daily:pending' "$DAYFILE" 2>/dev/null || continue
    SUMMARY_B64="$(printf '%s' "$SUMMARY" | python3 -c "import sys,base64; print(base64.b64encode(sys.stdin.buffer.read()).decode())" 2>/dev/null || true)"
    DAY_ESC="${DAYFILE//\\/\\\\}"
    python3 -c "
from pathlib import Path
import re, base64
p=Path(r'''$DAY_ESC''')
t=p.read_text(encoding='utf-8')
summary=base64.b64decode('$SUMMARY_B64').decode('utf-8') if '$SUMMARY_B64' else '''$STATUS'''
block='**Result:**\\n'+summary if '\\n' in summary else '**Result:** '+summary
matches=list(re.finditer(r'\*\*Result:\*\*[^\n]*\n<!-- notes-daily:pending -->', t))
if matches:
 m=matches[-1]
 t=t[:m.start()]+block+t[m.end():]
 p.write_text(t, encoding='utf-8')
" 2>/dev/null || true
  done
  emit "{}"
  exit 0
fi

PROMPT="$(printf '%s' "$PAYLOAD" | python3 -c "import sys,json
try:
 d=json.load(sys.stdin)
 for k in ('prompt','prompt_text','text','user_prompt'):
  v=d.get(k)
  if isinstance(v,str) and v.strip():
   print(v); break
except Exception:
 pass" 2>/dev/null || true)"

if [[ -z "$PROMPT" ]]; then
  emit '{"continue":true}'
  exit 0
fi

# close previous pending as continued; drop stale last-response (parity with ps1)
rm -f "$LAST_RESP"
YDAY="$(date -d 'yesterday' +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d 2>/dev/null || true)"
for DAYFILE in "$DAILY" "$WS/.cursor/notes/daily/$YDAY.md"; do
  [[ -n "$DAYFILE" && -f "$DAYFILE" ]] || continue
  grep -q 'notes-daily:pending' "$DAYFILE" 2>/dev/null || continue
  DAY_ESC="${DAYFILE//\\/\\\\}"
  python3 -c "
from pathlib import Path
import re
p=Path(r'''$DAY_ESC''')
t=p.read_text(encoding='utf-8')
matches=list(re.finditer(r'\*\*Result:\*\*[^\n]*\n<!-- notes-daily:pending -->', t))
if matches:
 m=matches[-1]
 t=t[:m.start()]+'**Result:** continued'+t[m.end():]
 p.write_text(t, encoding='utf-8')
" 2>/dev/null || true
done

if [[ ! -f "$DAILY" ]]; then
  cat > "$DAILY" <<EOF
# Daily - $DATE

## Context
- Focus: -
- Projects: -

## Prompts

## Outcomes
- Done: -
- Open: -

## Problems linked
- -

EOF
fi

IDX="$(grep -E '^### [0-9]+' "$DAILY" 2>/dev/null | sed -E 's/^### ([0-9]+).*/\1/' | sort -n | tail -1)"
IDX="${IDX:-0}"
IDX=$((IDX + 1))
NN="$(printf '%02d' "$IDX")"

SKILL="chat"
if printf '%s' "$PROMPT" | grep -Eiq '^/(fix|make|plan|feature|review|ship|note|upgrades)(\b|$)'; then
  SKILL="$(printf '%s' "$PROMPT" | sed -E 's|^/([A-Za-z]+).*|\1|' | tr '[:upper:]' '[:lower:]')"
elif printf '%s' "$PROMPT" | grep -Eiq '^(yes|confirm)[[:space:]]*$'; then
  SKILL="ack"
elif printf '%s' "$PROMPT" | python3 -c "import sys; t=sys.stdin.read().strip(); sys.exit(0 if t=='\u0e22\u0e37\u0e19\u0e22\u0e31\u0e19' else 1)" 2>/dev/null; then
  SKILL="ack"
fi

SAFE="$(printf '%s' "$PROMPT" | redact)"
ENTRY_B64="$(printf '### %s | %s | %s\n**Prompt:**\n%s\n\n**Result:** -\n<!-- notes-daily:pending -->\n' "$NN" "$TIME" "$SKILL" "$SAFE" | python3 -c "import sys,base64; print(base64.b64encode(sys.stdin.buffer.read()).decode())" 2>/dev/null || true)"

if [[ -n "$ENTRY_B64" ]]; then
  python3 -c "
from pathlib import Path
import re, base64
p=Path(r'''$DAILY''')
t=p.read_text(encoding='utf-8')
entry=base64.b64decode('$ENTRY_B64').decode('utf-8')
# Repair: move ### entries that landed below ## Outcomes
om=re.search(r'(?m)^## Outcomes\s*\$', t)
fm=re.search(r'(?m)^### \d+\b', t)
if om and fm and fm.start() > om.start():
 entries=list(re.finditer(r'(?ms)^### \d+\b.*?(?=^### \d+\b|\Z)', t))
 if entries:
  body='\n\n'.join(e.group(0).rstrip() for e in entries)
  without=t
  for e in reversed(entries):
   without=without[:e.start()]+without[e.end():]
  without=re.sub(r'\n{3,}', '\n\n', without).rstrip()+'\n\n'
  t=without
# Insert before Outcomes / Problems linked
m=re.search(r'(?m)^## (Outcomes|Problems linked)\s*\$', t)
ins=m.start() if m else len(t)
block=entry if entry.endswith('\n') else entry+'\n'
if ins>0 and not t[:ins].endswith('\n'):
 block='\n'+block
t=t[:ins]+block+('\n' if not block.endswith('\n') else '')+t[ins:]
p.write_text(t, encoding='utf-8')
" 2>/dev/null || {
    printf '\n%s' "$(printf '%s' "$ENTRY_B64" | python3 -c "import sys,base64; sys.stdout.buffer.write(base64.b64decode(sys.stdin.read()))" 2>/dev/null)" >> "$DAILY"
  }
else
  {
    printf '\n### %s | %s | %s\n' "$NN" "$TIME" "$SKILL"
    printf '**Prompt:**\n%s\n\n' "$SAFE"
    printf '**Result:** -\n<!-- notes-daily:pending -->\n'
  } >> "$DAILY"
fi

emit '{"continue":true}'
exit 0
