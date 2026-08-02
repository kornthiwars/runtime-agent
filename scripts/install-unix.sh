#!/usr/bin/env bash
# Link pack skills + rules into the outer workspace .cursor (never $HOME/.cursor)
# macOS / Linux — uses symlinks (ln -sfn)

set -euo pipefail

PackRoot="$(cd "$(dirname "$0")/.." && pwd)"
WorkspaceRoot="$(cd "$PackRoot/.." && pwd)"
SkillsSrc="$PackRoot/skills"
SkillsDest="$WorkspaceRoot/.cursor/skills"
RulesSrc="$PackRoot/rules"
RulesDest="$WorkspaceRoot/.cursor/rules"
SkillNames=(fix make plan feature review ship note upgrades)

mkdir -p "$SkillsDest"

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

echo ""
echo "OK skills: $SkillsDest"
echo "  -> $SkillsSrc"
echo "OK rules:  $RulesDest"
echo "  -> $RulesSrc"
echo "No files written under \$HOME/.cursor (user skills)"
echo "Open Skills (parent) as workspace, restart Cursor, type / in Agent"
