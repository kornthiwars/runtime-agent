#!/usr/bin/env bash
# Link pack skills + rules + Cursor hooks into the outer workspace
# (never $HOME/.cursor). Safe to re-run after deleting ../.cursor.

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
mapfile -t SkillNames < <(grep -v '^\s*#' "$SkillNamesFile" | sed '/^\s*$/d')
if [[ ${#SkillNames[@]} -eq 0 ]]; then
  echo "No skill names in $SkillNamesFile" >&2
  exit 1
fi
if [[ ! -f "$HooksSrc/hooks.unix.json" ]]; then
  echo "Missing cursor-hooks pack: $HooksSrc" >&2
  exit 1
fi

# If skills was a whole-folder symlink (e.g. to another pack), replace with a
# real dir of per-skill links — never ln into the old pack tree.
rm -rf "$SkillsDest"
mkdir -p "$CursorRoot" "$SkillsDest" "$CursorRoot/plans" "$CursorRoot/features"

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

# Cursor agent hooks
mkdir -p "$HooksDest/state"
cp -f "$HooksSrc/hooks.unix.json" "$HooksJsonDest"
cp -f "$HooksSrc/state.gitignore" "$HooksDest/state/.gitignore"
echo "Installed Cursor hooks -> $HooksJsonDest"

echo ""
echo "OK skills:  $SkillsDest"
echo "OK rules:   $RulesDest"
echo "OK hooks:   $HooksJsonDest"
echo "No files written under \$HOME/.cursor (user skills)"
echo ""
echo "Next: Open parent workspace in Cursor, restart once, check Hooks tab (empty is OK)."
echo "You can delete .cursor and re-run this script anytime."
