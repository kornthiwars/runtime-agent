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

check_needles() {
  local skill_path="$1"
  local label="$2"
  local id="$3"
  local ok_ref="$4"
  shift 4
  local needle
  for needle in "$@"; do
    [[ -z "$needle" ]] && continue
    if ! grep -Fqi -- "$needle" "$skill_path"; then
      echo "FAIL $id: $label missing '$needle'"
      eval "$ok_ref=0"
    fi
  done
}

for f in "${files[@]}"; do
  id="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['id'])" "$f")"
  skill="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['skill'])" "$f")"
  path_rel="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('path') or '')" "$f")"
  if [[ -n "$path_rel" ]]; then
    body_path="$PACK_ROOT/$path_rel"
    body_label="$path_rel"
  else
    body_path="$PACK_ROOT/skills/$skill/SKILL.md"
    body_label="SKILL.md"
  fi
  if [[ ! -f "$body_path" ]]; then
    echo "FAIL $id: missing $body_label"; failed=$((failed+1)); continue
  fi
  ok=1

  must=()
  while IFS= read -r line || [ -n "$line" ]; do must+=("$line"); done < <(python3 -c "import json,sys; d=json.load(open(sys.argv[1]));
print('\n'.join(d.get('skill_must_contain') or []))" "$f")
  check_needles "$body_path" "$body_label" "$id" ok "${must[@]:-}"

  statuses=()
  while IFS= read -r line || [ -n "$line" ]; do statuses+=("$line"); done < <(python3 -c "import json,sys; d=json.load(open(sys.argv[1]));
v=d.get('expect_status') or [];
print('\n'.join(v if isinstance(v,list) else [v]))" "$f")
  check_needles "$body_path" "expect_status" "$id" ok "${statuses[@]:-}"

  hint="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1]));
print(d.get('expect_redirect_hint') or '')" "$f")"
  if [[ -n "$hint" ]] && ! grep -Fqi -- "$hint" "$body_path"; then
    echo "FAIL $id: expect_redirect_hint missing '$hint'"
    ok=0
  fi

  depth="$(python3 -c "import json,sys; d=json.load(open(sys.argv[1]));
print(d.get('expect_depth') or '')" "$f")"
  if [[ -n "$depth" ]] && ! grep -Fqi -- "$depth" "$body_path"; then
    echo "FAIL $id: expect_depth missing '$depth'"
    ok=0
  fi

  verdicts=()
  while IFS= read -r line || [ -n "$line" ]; do verdicts+=("$line"); done < <(python3 -c "import json,sys; d=json.load(open(sys.argv[1]));
v=d.get('expect_verdict_any') or [];
print('\n'.join(v if isinstance(v,list) else [v]))" "$f")
  if [[ ${#verdicts[@]} -gt 0 && -n "${verdicts[0]:-}" ]]; then
    any=0
    for needle in "${verdicts[@]}"; do
      [[ -z "$needle" ]] && continue
      if grep -Fqi -- "$needle" "$body_path"; then any=1; break; fi
    done
    if [[ $any -eq 0 ]]; then
      echo "FAIL $id: expect_verdict_any none matched"
      ok=0
    fi
  fi

  forbidden=()
  while IFS= read -r line || [ -n "$line" ]; do forbidden+=("$line"); done < <(python3 -c "import json,sys; d=json.load(open(sys.argv[1]));
v=d.get('forbidden_actions') or [];
print('\n'.join(v if isinstance(v,list) else [v]))" "$f")
  check_needles "$body_path" "forbidden_actions" "$id" ok "${forbidden[@]:-}"

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
