#!/usr/bin/env bash
# Install estack as a local Cursor Agent Plugin.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$REPO_DIR/.generated/cursor/estack"
TARGET_DIR="$HOME/.cursor/plugins/local"
TARGET="$TARGET_DIR/estack"

[[ -f "$SOURCE/plugin.json" ]] || "$REPO_DIR/scripts/build-plugins.sh"
mkdir -p "$TARGET_DIR"

if [[ -L "$TARGET" ]]; then
  current="$(readlink "$TARGET")"
  if [[ "$current" != "$SOURCE" ]]; then
    echo "Cursor: refusing to replace unrelated symlink: $TARGET -> $current" >&2
    exit 1
  fi
elif [[ -e "$TARGET" ]]; then
  echo "Cursor: refusing to replace existing path: $TARGET" >&2
  exit 1
else
  ln -s "$SOURCE" "$TARGET"
fi

echo "Cursor: installed estack at $TARGET"
echo "Cursor: run 'Developer: Reload Window' to apply the update."
