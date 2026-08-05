#!/usr/bin/env bash
set -euo pipefail
PACK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIX_DIR="$PACK_ROOT/evals/fixtures"
passed=0
failed=0

shopt -s nullglob
files=("$FIX_DIR"/*.json)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No fixtures"; exit 1
fi

for f in "${files[@]}"; do
  id="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['id'])" "$f")"
  skill="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['skill'])" "$f")"
  skill_path="$PACK_ROOT/skills/$skill/SKILL.md"
  if [[ ! -f "$skill_path" ]]; then
    echo "FAIL $id: missing skill $skill"; failed=$((failed+1)); continue
  fi
  ok=1
  while IFS= read -r needle; do
    [[ -z "$needle" ]] && continue
    if ! grep -Fqi -- "$needle" "$skill_path"; then
      echo "FAIL $id: SKILL.md missing '$needle'"
      ok=0
    fi
  done < <(python3 -c "import json,sys; d=json.load(open(sys.argv[1]));
print('\n'.join(d.get('skill_must_contain') or []))" "$f")
  if [[ $ok -eq 1 ]]; then
    echo "PASS $id"; passed=$((passed+1))
  else
    failed=$((failed+1))
  fi
done

total=$((passed+failed))
rate=$(python3 -c "print(round(100.0*$passed/$total,1) if $total else 0)")
echo ""
echo "RESULT $passed/$total ($rate%)"
python3 -c "import sys; sys.exit(0 if $rate >= 95 and $failed == 0 else 1)"
