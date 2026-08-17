#!/usr/bin/env bash
# Install git hooks for this pack repo (optional)
set -euo pipefail
PACK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GIT_DIR="$PACK_ROOT/.git"
if [[ ! -e "$GIT_DIR" ]]; then
  echo "Not a git repo: $PACK_ROOT" >&2
  exit 1
fi
if [[ ! -d "$GIT_DIR" ]]; then
  echo ".git is not a directory (worktree/submodule?) — install hooks manually into the real git dir" >&2
  exit 1
fi
HOOK_SRC="$PACK_ROOT/scripts/hooks/pre-commit"
HOOK_SRC_PS1="$PACK_ROOT/scripts/hooks/pre-commit.ps1"
HOOK_DEST_DIR="$PACK_ROOT/.git/hooks"
HOOK_DEST="$HOOK_DEST_DIR/pre-commit"
if [[ ! -d "$HOOK_DEST_DIR" ]]; then
  echo "Missing hooks dir: $HOOK_DEST_DIR" >&2
  exit 1
fi
if [[ -f "$HOOK_DEST" ]]; then
  echo "WARNING: overwriting existing $HOOK_DEST"
fi
cp "$HOOK_SRC" "$HOOK_DEST"
chmod +x "$HOOK_DEST"
if [[ -f "$HOOK_SRC_PS1" ]]; then
  cp "$HOOK_SRC_PS1" "$HOOK_DEST_DIR/pre-commit.ps1"
fi
echo "Installed pre-commit -> $HOOK_DEST"
