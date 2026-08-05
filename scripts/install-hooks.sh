#!/usr/bin/env bash
set -euo pipefail
PACK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cp "$PACK_ROOT/scripts/hooks/pre-commit" "$PACK_ROOT/.git/hooks/pre-commit"
chmod +x "$PACK_ROOT/.git/hooks/pre-commit"
echo "Installed pre-commit"
