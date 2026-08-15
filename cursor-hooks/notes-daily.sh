#!/usr/bin/env bash
# Notes daily auto — append every user prompt to .cursor/notes/daily/YYYY-MM-DD.md
# Fail-open. Disable: NOTES_DAILY_AUTO=0 or .cursor/hooks/state/notes-daily.off
set +e

emit() { printf '%s\n' "$1"; }

PAYLOAD="$(cat || true)"
EVENT="${1:-beforeSubmitPrompt}"
if command -v python3 >/dev/null 2>&1; then
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

# Cursor on Windows may send "/c:/Users/..." — normalize for Git Bash / MSYS
if [[ "$WS" =~ ^/([A-Za-z]):/(.*)$ ]]; then
  WS="/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
elif [[ "$WS" =~ ^/([A-Za-z]):\\(.*)$ ]]; then
  WS="/${BASH_REMATCH[1]}/${BASH_REMATCH[2]//\\//}"
fi

# Prefer parent workspace notes when hooks bind to nested pack git root
if [[ -f "$WS/cursor-hooks/notes-daily.sh" && -d "$(dirname "$WS")/.cursor/notes" ]]; then
  WS="$(dirname "$WS")"
fi

if [[ "${NOTES_DAILY_AUTO:-1}" == "0" ]] || [[ -f "$WS/.cursor/hooks/state/notes-daily.off" ]]; then
  if [[ "$EVENT" == "stop" ]]; then emit "{}"; else emit '{"continue":true}'; fi
  exit 0
fi

DATE="$(date +%Y-%m-%d)"
TIME="$(date +%H:%M)"
DAILY="$WS/.cursor/notes/daily/$DATE.md"
mkdir -p "$(dirname "$DAILY")"

LAST_RESP="$WS/.cursor/hooks/state/notes-daily.last-response.txt"
mkdir -p "$(dirname "$LAST_RESP")"

redact() {
  python3 -c "
import re,sys
t=sys.stdin.read()
t=re.sub(r'(?i)(mongodb(\+srv)?://)\S+', r'\1***', t)
t=re.sub(r'(?i)\b(api[_-]?key|token|secret|password)\s*[=:]\s*\S+', r'\1=***', t)
t=re.sub(r'(?i)Bearer\s+\S+', 'Bearer ***', t)
t=re.sub(r'(?is)-----BEGIN [^-]*PRIVATE KEY-----.*?-----END [^-]*PRIVATE KEY-----', '[REDACTED_PRIVATE_KEY]', t)
sys.stdout.write(t)
" 2>/dev/null || cat
}

summarize3() {
  python3 -c "
import re,sys
t=sys.stdin.read()
lines=[ln.strip() for ln in t.replace('\r\n','\n').split('\n') if ln.strip() and not ln.strip().startswith('\`\`\`')]
out=[]
for ln in lines[:3]:
  out.append(ln[:137]+'...' if len(ln)>140 else ln)
sys.stdout.write('\n'.join(out))
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
    SUMMARY="$(redact < "$LAST_RESP" | summarize3)"
    rm -f "$LAST_RESP"
  fi
  if [[ -z "$SUMMARY" ]]; then SUMMARY="$STATUS"; fi
  if [[ -f "$DAILY" ]] && grep -q 'notes-daily:pending' "$DAILY" 2>/dev/null; then
    SUMMARY_B64="$(printf '%s' "$SUMMARY" | python3 -c "import sys,base64; print(base64.b64encode(sys.stdin.buffer.read()).decode())" 2>/dev/null || true)"
    python3 -c "
from pathlib import Path
import re, base64
p=Path(r'''$DAILY''')
t=p.read_text(encoding='utf-8')
summary=base64.b64decode('$SUMMARY_B64').decode('utf-8') if '$SUMMARY_B64' else '''$STATUS'''
block='**Result:**\\n'+summary if '\\n' in summary else '**Result:** '+summary
matches=list(re.finditer(r'\*\*Result:\*\*[^\n]*\n<!-- notes-daily:pending -->', t))
if matches:
 m=matches[-1]
 t=t[:m.start()]+block+t[m.end():]
 p.write_text(t, encoding='utf-8')
" 2>/dev/null || true
  fi
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

# close previous pending as continued
if [[ -f "$DAILY" ]] && grep -q 'notes-daily:pending' "$DAILY" 2>/dev/null; then
  python3 -c "
from pathlib import Path
import re
p=Path(r'''$DAILY''')
t=p.read_text(encoding='utf-8')
matches=list(re.finditer(r'\*\*Result:\*\*[^\n]*\n<!-- notes-daily:pending -->', t))
if matches:
 m=matches[-1]
 t=t[:m.start()]+'**Result:** continued'+t[m.end():]
 p.write_text(t, encoding='utf-8')
" 2>/dev/null || true
fi

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
  SKILL="$(printf '%s' "$PROMPT" | sed -E 's|^/([a-z]+).*|\1|I' | tr '[:upper:]' '[:lower:]')"
elif printf '%s' "$PROMPT" | grep -Eiq '^(ok|yes|confirm)[[:space:]]*$'; then
  SKILL="ack"
elif printf '%s' "$PROMPT" | python3 -c "import sys; t=sys.stdin.read().strip(); sys.exit(0 if t=='\u0e22\u0e37\u0e19\u0e22\u0e31\u0e19' else 1)" 2>/dev/null; then
  SKILL="ack"
fi

SAFE="$(printf '%s' "$PROMPT" | redact)"

{
  printf '\n### %s | %s | %s\n' "$NN" "$TIME" "$SKILL"
  printf '**Prompt:**\n%s\n\n' "$SAFE"
  printf '**Result:** -\n<!-- notes-daily:pending -->\n'
} >> "$DAILY"

emit '{"continue":true}'
exit 0
