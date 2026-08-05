#!/usr/bin/env bash
set -euo pipefail
PATH_IN="${1:-}"
[[ -n "$PATH_IN" && -f "$PATH_IN" ]] || { echo "Usage: validate-plan.sh <file.plan.md>"; exit 1; }
raw="$(cat "$PATH_IN")"
echo "$raw" | head -n1 | grep -q '^---$' || { echo "Missing YAML frontmatter"; exit 1; }
fm="$(awk 'BEGIN{p=0} /^---$/{p++; next} p==1{print} p==2{exit}' "$PATH_IN")"
for key in name: overview: todos: isProject:; do
  echo "$fm" | grep -q "$key" || { echo "Frontmatter missing: $key"; exit 1; }
done
echo "$fm" | grep -Eq 'status:[[:space:]]*(pending|in_progress|completed|cancelled)' \
  || { echo "No todo status found"; exit 1; }
echo "OK plan: $PATH_IN"
