#!/usr/bin/env bash
set -euo pipefail
PACK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAMES_FILE="$PACK_ROOT/scripts/skill-names.txt"
SKILLS_DIR="$PACK_ROOT/skills"
failed=0

# bash 3.2-safe (macOS /bin/bash): no mapfile
listed=()
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ''|\#*) continue ;;
  esac
  listed+=("$line")
done < <(grep -v '^\s*#' "$NAMES_FILE" | sed '/^\s*$/d' | sed 's/\r$//')

for name in "${listed[@]}"; do
  if [[ ! -f "$SKILLS_DIR/$name/SKILL.md" ]]; then
    echo "MISSING SKILL.md for listed name: $name"
    failed=1
  fi
done

for dir in "$SKILLS_DIR"/*/; do
  d="$(basename "$dir")"
  [[ -f "$SKILLS_DIR/$d/SKILL.md" ]] || continue
  if ! printf '%s\n' "${listed[@]}" | grep -qx "$d"; then
    echo "ORPHAN skill folder not in skill-names.txt: $d"
    failed=1
  fi
done

if [[ $failed -eq 0 ]]; then
  echo "OK skill-names.txt (${#listed[@]} skills)"
else
  exit 1
fi
