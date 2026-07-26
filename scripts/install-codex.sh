#!/usr/bin/env bash
# Install estack for OpenAI Codex through the plugin marketplace.
#
# Older estack installs linked each skill into ~/.agents/skills. Codex now
# loads estack as a plugin, so this script removes only the legacy symlinks it
# owns and leaves unrelated personal skills untouched.
set -euo pipefail
shopt -s nullglob

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED_SRC="$REPO_DIR/plugins/estack/skills"
CODEX_SRC="$REPO_DIR/plugins/estack/skills-codex"
LEGACY_DST="${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"
PLUGIN="estack"
MARKETPLACE="estack"

cleanup_legacy_links() {
  if [ ! -d "$LEGACY_DST" ]; then
    return
  fi

  removed=0
  for src_dir in "$SHARED_SRC" "$CODEX_SRC"; do
    for skill in "$src_dir"/*/; do
      name="$(basename "$skill")"
      target="$LEGACY_DST/$name"
      src="${skill%/}"
      legacy_target="$LEGACY_DST/ek-$name"
      legacy_src="$src_dir/ek-$name"

      if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
        rm "$target"
        echo "removed legacy link: $target"
        removed=$((removed + 1))
      fi

      # Skill names no longer use the old ek- prefix. Remove only links that
      # point to the matching pre-migration path in this estack clone.
      if [ -L "$legacy_target" ] && [ "$(readlink "$legacy_target")" = "$legacy_src" ]; then
        rm "$legacy_target"
        echo "removed legacy link: $legacy_target"
        removed=$((removed + 1))
      fi
    done
  done

  if [ "$removed" -eq 0 ]; then
    echo "Codex: no legacy estack skill symlinks found in $LEGACY_DST."
  else
    echo "Codex: removed $removed legacy estack skill symlink(s) from $LEGACY_DST."
  fi
}

register_local_marketplace() {
  codex plugin marketplace remove "$MARKETPLACE" || true
  codex plugin marketplace add "$REPO_DIR"
  echo "Codex: registered this clone as the local '$MARKETPLACE' marketplace."
}

clear_legacy_fable_hook_state() {
  local config="${CODEX_HOME:-$HOME/.codex}/config.toml"
  local header="[hooks.state.\"$PLUGIN@$MARKETPLACE:hooks/hooks.json:session_start:0:0\"]"
  local temporary

  if [ ! -f "$config" ] || ! grep -Fqx -- "$header" "$config"; then
    return
  fi

  temporary="$(mktemp "${config}.XXXXXX")"
  awk -v header="$header" '
    $0 == header { skipping = 1; next }
    skipping && /^\[/ { skipping = 0 }
    !skipping { print }
  ' "$config" > "$temporary"
  mv "$temporary" "$config"
  echo "Codex: removed obsolete estack Fable hook state."
}

if [ ! -d "$SHARED_SRC" ] || [ ! -d "$CODEX_SRC" ]; then
  echo "error: estack source skill directories are missing" >&2
  exit 1
fi

"$REPO_DIR/scripts/build-plugins.sh"
cleanup_legacy_links

if command -v codex >/dev/null 2>&1; then
  # Codex can retain a removed plugin hook in its local state after `plugin add`.
  # Reinstall from scratch so the active hook set matches the source plugin.
  codex plugin remove "$PLUGIN@$MARKETPLACE" || true
  clear_legacy_fable_hook_state
  register_local_marketplace
  codex plugin add "$PLUGIN@$MARKETPLACE"
  echo
  echo "Codex: installed/refreshed $PLUGIN@$MARKETPLACE."
  echo "Codex app: use Cmd+K / Ctrl+K -> Force Reload Skills, or start a new thread."
else
  echo "Codex: 'codex' not on PATH; skipped plugin install."
fi
