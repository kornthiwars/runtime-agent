#!/usr/bin/env bash
set -euo pipefail
PACK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIX_DIR="$PACK_ROOT/evals/behavior"
passed=0
failed=0

shopt -s nullglob
files=("$FIX_DIR"/*.json)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No behavior fixtures"; exit 1
fi

for f in "${files[@]}"; do
  id="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['id'])" "$f")"
  skill="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['skill'])" "$f")"
  skill_path="$PACK_ROOT/skills/$skill/SKILL.md"
  if [[ ! -f "$skill_path" ]]; then
    echo "FAIL $id: missing skill $skill"; failed=$((failed+1)); continue
  fi
  ok=1

  gates=()
  while IFS= read -r line || [ -n "$line" ]; do gates+=("$line"); done < <(python3 -c "import json,sys; d=json.load(open(sys.argv[1]));
print('\n'.join(d.get('must_gate') or []))" "$f")
  for needle in "${gates[@]:-}"; do
    [[ -z "$needle" ]] && continue
    if ! grep -Fqi -- "$needle" "$skill_path"; then
      echo "FAIL $id: must_gate missing '$needle'"
      ok=0
    fi
  done

  outs=()
  while IFS= read -r line || [ -n "$line" ]; do outs+=("$line"); done < <(python3 -c "import json,sys; d=json.load(open(sys.argv[1]));
v=d.get('expect_out_any') or [];
print('\n'.join(v if isinstance(v,list) else [v]))" "$f")
  if [[ ${#outs[@]} -gt 0 && -n "${outs[0]:-}" ]]; then
    any=0
    for needle in "${outs[@]}"; do
      [[ -z "$needle" ]] && continue
      if grep -Fqi -- "$needle" "$skill_path"; then any=1; break; fi
    done
    if [[ $any -eq 0 ]]; then
      echo "FAIL $id: expect_out_any none matched"
      ok=0
    fi
  fi

  if [[ $ok -eq 1 ]]; then
    echo "PASS $id"; passed=$((passed+1))
  else
    failed=$((failed+1))
  fi
done

total=$((passed+failed))
rate=$(python3 -c "print(round(100.0*$passed/$total,1) if $total else 0)")
echo ""
echo "BEHAVIOR RESULT $passed/$total ($rate%)"
python3 -c "import sys; sys.exit(0 if $rate >= 95 and $failed == 0 else 1)"
