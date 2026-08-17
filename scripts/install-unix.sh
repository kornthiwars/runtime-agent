#!/usr/bin/env bash
# Link pack skills + rules + Cursor hooks into the outer workspace
# (never $HOME/.cursor). Re-run is safe when parent .cursor already belongs
# to this pack. Another skill pack → refuse unless --force.

set -euo pipefail

PackRoot="$(cd "$(dirname "$0")/.." && pwd)"
WorkspaceRoot="$(cd "$PackRoot/.." && pwd)"
CursorRoot="$WorkspaceRoot/.cursor"
SkillsSrc="$PackRoot/skills"
SkillsDest="$CursorRoot/skills"
RulesSrc="$PackRoot/rules"
RulesDest="$CursorRoot/rules"
HooksSrc="$PackRoot/cursor-hooks"
HooksDest="$CursorRoot/hooks"
HooksJsonDest="$CursorRoot/hooks.json"
SkillNamesFile="$PackRoot/scripts/skill-names.txt"
SkillNames=()
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ''|\#*) continue ;;
  esac
  SkillNames+=("$line")
done < <(grep -v '^\s*#' "$SkillNamesFile" | sed '/^\s*$/d')
if [[ ${#SkillNames[@]} -eq 0 ]]; then
  echo "No skill names in $SkillNamesFile" >&2
  exit 1
fi
if [[ ! -f "$HooksSrc/hooks.unix.json" ]]; then
  echo "Missing cursor-hooks pack: $HooksSrc" >&2
  exit 1
fi

ForceInstall=0
if [[ "${RUNTIME_AGENT_FORCE_INSTALL:-}" == "1" ]]; then
  ForceInstall=1
fi
for _arg in "$@"; do
  case "$_arg" in
    --force) ForceInstall=1 ;;
  esac
done

is_pack_skill_name() {
  local n="$1" s
  for s in "${SkillNames[@]}"; do
    [[ "$s" == "$n" ]] && return 0
  done
  return 1
}

# Occupied when parent skills/rules contain another pack (e.g. nested clone
# inside a product workspace). Same-pack reinstall (our skill names / our
# .mdc files only) is allowed.
cursor_occupied_by_other_pack() {
  local child base
  shopt -s nullglob
  if [[ -L "$SkillsDest" || -e "$SkillsDest" ]]; then
    if [[ -d "$SkillsDest" ]]; then
      for child in "$SkillsDest"/*; do
        [[ -e "$child" || -L "$child" ]] || continue
        if [[ -e "$child/SKILL.md" ]]; then
          base="$(basename "$child")"
          if ! is_pack_skill_name "$base"; then
            return 0
          fi
        fi
      done
    else
      return 0
    fi
  fi
  if [[ -L "$RulesDest" || -e "$RulesDest" ]]; then
    if [[ -d "$RulesDest" ]]; then
      for child in "$RulesDest"/*.mdc; do
        [[ -e "$child" || -L "$child" ]] || continue
        base="$(basename "$child")"
        if [[ ! -f "$RulesSrc/$base" ]]; then
          return 0
        fi
      done
    else
      return 0
    fi
  fi
  return 1
}

if cursor_occupied_by_other_pack; then
  if [[ "$ForceInstall" -ne 1 ]]; then
    echo "ERROR: parent .cursor/skills or .cursor/rules looks like another skill pack (not runtime-agent)." >&2
    echo "Refusing to overwrite. Clone as Skills/runtime-agent in its own workspace," >&2
    echo "or re-run with --force / RUNTIME_AGENT_FORCE_INSTALL=1 (destructive)." >&2
    exit 1
  fi
  echo "WARNING: --force: replacing another pack's .cursor/skills and .cursor/rules with runtime-agent." >&2
fi

# If skills was a whole-folder symlink (e.g. to another pack), replace with a
# real dir of per-skill links — never ln into the old pack tree.
rm -rf "$SkillsDest"
mkdir -p "$CursorRoot" "$SkillsDest" "$CursorRoot/plans" "$CursorRoot/features" \
  "$CursorRoot/notes/daily" "$CursorRoot/notes/projects"

for name in "${SkillNames[@]}"; do
  src="$SkillsSrc/$name"
  dest="$SkillsDest/$name"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "Missing SKILL.md: $src" >&2
    exit 1
  fi
  rm -rf "$dest"
  ln -sfn "$src" "$dest"
  echo "Linked skill $name"
done

shopt -s nullglob
ruleFiles=("$RulesSrc"/*.mdc)
if [[ ${#ruleFiles[@]} -eq 0 ]]; then
  echo "No .mdc rules in $RulesSrc" >&2
  exit 1
fi
rm -rf "$RulesDest"
ln -sfn "$RulesSrc" "$RulesDest"
echo "Linked rules (${#ruleFiles[@]} .mdc)"

# Cursor agent hooks — parent workspace AND pack root (Cursor binds to nested git folder)
merge_hooks_json() {
  local pack_json="$1"
  local dest_json="$2"
  if [[ ! -f "$dest_json" ]]; then
    cp -f "$pack_json" "$dest_json"
    return
  fi
  python3 - "$pack_json" "$dest_json" <<'PY'
import json, sys
pack_path, dest_path = sys.argv[1], sys.argv[2]
with open(pack_path, encoding='utf-8') as f:
    pack = json.load(f)
with open(dest_path, encoding='utf-8') as f:
    existing = json.load(f)
if 'hooks' not in existing or not isinstance(existing.get('hooks'), dict):
    existing['hooks'] = {}
if 'version' in pack:
    existing['version'] = pack['version']
for event, pack_cmds in (pack.get('hooks') or {}).items():
    existing_cmds = list(existing['hooks'].get(event) or [])
    kept = [
        c for c in existing_cmds
        if 'notes-daily.ps1' not in str((c or {}).get('command', ''))
        and 'notes-daily.sh' not in str((c or {}).get('command', ''))
    ]
    existing['hooks'][event] = kept + list(pack_cmds or [])
with open(dest_path, 'w', encoding='utf-8') as f:
    json.dump(existing, f, indent=2)
    f.write('\n')
PY
}

install_hooks() {
  local cursor_root="$1"
  mkdir -p "$cursor_root/hooks/state"
  merge_hooks_json "$HooksSrc/hooks.unix.json" "$cursor_root/hooks.json"
  cp -f "$HooksSrc/state.gitignore" "$cursor_root/hooks/state/.gitignore"
  cp -f "$HooksSrc/notes-daily.sh" "$cursor_root/hooks/notes-daily.sh"
  cp -f "$HooksSrc/notes-daily.ps1" "$cursor_root/hooks/notes-daily.ps1"
  chmod +x "$cursor_root/hooks/notes-daily.sh" || true
  echo "Installed Cursor hooks -> $cursor_root/hooks.json (notes-daily merged; other hooks kept)"
}

install_hooks "$CursorRoot"
install_hooks "$PackRoot/.cursor"
echo "(notes-daily auto on; disable: NOTES_DAILY_AUTO=0 or .cursor/hooks/state/notes-daily.off)"

echo ""
echo "OK skills:  $SkillsDest"
echo "OK rules:   $RulesDest"
echo "OK hooks:   $HooksJsonDest + $PackRoot/.cursor/hooks.json"
echo "OK notes:   $CursorRoot/notes"
echo "No files written under \$HOME/.cursor (user skills)"
echo ""
echo "Next: Open parent workspace in Cursor, restart once, confirm Hooks tab lists notes-daily."
echo "Notes: .cursor/notes/daily + .cursor/notes/projects (problems via /note)."
echo "You can delete .cursor and re-run this script anytime."
