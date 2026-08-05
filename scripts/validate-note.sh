#!/usr/bin/env bash
set -euo pipefail
PATH_IN="${1:-}"
[[ -n "$PATH_IN" && -f "$PATH_IN" ]] || { echo "Usage: validate-note.sh <note.md>"; exit 1; }
fm="$(awk 'BEGIN{p=0} /^---$/{p++; next} p==1{print} p==2{exit}' "$PATH_IN")"
for key in kind: project: title: created:; do
  echo "$fm" | grep -q "$key" || { echo "Frontmatter missing: $key"; exit 1; }
done
echo "$fm" | grep -Eq 'kind:[[:space:]]*(decision|constraint|exception|gotcha)' \
  || { echo "kind must be decision|constraint|exception|gotcha"; exit 1; }
echo "OK note: $PATH_IN"
