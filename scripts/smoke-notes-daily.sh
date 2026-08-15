#!/usr/bin/env bash
# Smoke: notes-daily fills Result on afterAgentResponse without stop.
set -euo pipefail
PackRoot="$(cd "$(dirname "$0")/.." && pwd)"
HookSrc="$PackRoot/cursor-hooks/notes-daily.sh"
[[ -f "$HookSrc" ]] || { echo "Missing $HookSrc" >&2; exit 1; }

stamp="$(date +%Y%m%d%H%M%S)"
root="${TMPDIR:-/tmp}/notes-daily-smoke-$stamp"
mkdir -p "$root/.cursor/hooks/state" "$root/.cursor/notes/daily"
cp -f "$HookSrc" "$root/.cursor/hooks/notes-daily.sh"
chmod +x "$root/.cursor/hooks/notes-daily.sh"

invoke() {
  local ev="$1" json="$2"
  printf '%s' "$json" | (cd "$root" && bash .cursor/hooks/notes-daily.sh "$ev") >/dev/null
}

ws="$root"
invoke beforeSubmitPrompt "$(printf '{"hook_event_name":"beforeSubmitPrompt","prompt":"smoke-notes-daily","workspace_roots":["%s"]}' "$ws")"
invoke afterAgentResponse "$(printf '{"hook_event_name":"afterAgentResponse","text":"OUTCOME: smoke-ok\\nSTATUS: READY","workspace_roots":["%s"]}' "$ws")"

daily="$root/.cursor/notes/daily/$(date +%Y-%m-%d).md"
[[ -f "$daily" ]] || { echo "missing daily" >&2; exit 1; }
if grep -q 'notes-daily:pending' "$daily"; then
  echo "pending still present after afterAgentResponse" >&2
  exit 1
fi
grep -q 'OUTCOME: smoke-ok' "$daily" || { echo "OUTCOME missing" >&2; exit 1; }
grep -q 'smoke-notes-daily' "$daily" || { echo "prompt missing" >&2; exit 1; }

echo "OK smoke-notes-daily (Result filled without stop)"
rm -rf "$root"
