#!/usr/bin/env bash
# Install estack for OpenAI Codex through the plugin marketplace.
#
# Older estack installs linked each skill into ~/.agents/skills. Codex now
# loads estack as a plugin, so this script removes only the legacy symlinks it
# owns and leaves unrelated personal skills untouched.
set -euo pipefail
shopt -s nullglob

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_DIR/plugins/estack/skills"
LEGACY_DST="${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"
PLUGIN="estack"
MARKETPLACE="estack"

cleanup_legacy_links() {
  if [ ! -d "$LEGACY_DST" ]; then
    return
  fi

  removed=0
  for skill in "$SRC"/*/; do
    name="$(basename "$skill")"
    target="$LEGACY_DST/$name"
    src="${skill%/}"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
      rm "$target"
      echo "removed legacy link: $target"
      removed=$((removed + 1))
    fi
  done

  if [ "$removed" -eq 0 ]; then
    echo "Codex: no legacy estack skill symlinks found in $LEGACY_DST."
  else
    echo "Codex: removed $removed legacy estack skill symlink(s) from $LEGACY_DST."
  fi
}

ensure_marketplace() {
  marketplace_type="$(
    codex plugin marketplace list --json \
      | python3 -c 'import json, sys
name = sys.argv[1]
for marketplace in json.load(sys.stdin).get("marketplaces", []):
    if marketplace.get("name") == name:
        print(marketplace.get("marketplaceSource", {}).get("sourceType", "unknown"))
        break
' "$MARKETPLACE"
  )"

  if [ -z "$marketplace_type" ]; then
    codex plugin marketplace add "$REPO_DIR"
    marketplace_type="$(
      codex plugin marketplace list --json \
        | python3 -c 'import json, sys
name = sys.argv[1]
for marketplace in json.load(sys.stdin).get("marketplaces", []):
    if marketplace.get("name") == name:
        print(marketplace.get("marketplaceSource", {}).get("sourceType", "unknown"))
        break
' "$MARKETPLACE"
    )"
  fi

  if [ "$marketplace_type" = "git" ]; then
    codex plugin marketplace upgrade "$MARKETPLACE"
  else
    echo "Codex: marketplace '$MARKETPLACE' is ${marketplace_type:-unknown}; skipping Git-only marketplace upgrade."
  fi
}

if [ ! -d "$SRC" ]; then
  echo "error: no skills directory at '$SRC'; run this from inside the estack repo" >&2
  exit 1
fi

cleanup_legacy_links

if command -v codex >/dev/null 2>&1; then
  ensure_marketplace
  codex plugin add "$PLUGIN@$MARKETPLACE"
  echo
  echo "Codex: installed/refreshed $PLUGIN@$MARKETPLACE."
  echo "Codex app: use Cmd+K / Ctrl+K -> Force Reload Skills, or start a new thread."
else
  echo "Codex: 'codex' not on PATH; skipped plugin install."
fi
