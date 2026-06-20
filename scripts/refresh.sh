#!/usr/bin/env bash
# Refresh estack in both tools so Claude Code and Codex pick up local repo edits.
#
# Claude Code installs estack as a cached snapshot, so it needs an explicit
# reinstall to see changes — and a restart afterward to apply them (Claude Code
# loads plugins at startup; `claude plugin install` only refreshes the cache).
#
# Codex reads skills live through the symlinks created by install-codex.sh, so
# edits to existing skills need nothing. This script still (re)links so newly
# added skills appear, and prunes symlinks for skills you've deleted.
set -euo pipefail
shopt -s nullglob

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="estack"
MARKETPLACE="estack"

# --- Codex: prune symlinks for deleted skills, then (re)link current ones ---
SKILLS_SRC="$REPO_DIR/plugins/estack/skills"
CODEX_SKILLS_DIR="${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"
if [ -d "$CODEX_SKILLS_DIR" ]; then
  for link in "$CODEX_SKILLS_DIR"/*; do
    [ -L "$link" ] || continue
    # Only touch symlinks we own (pointing into this repo's skills/) that are
    # now dangling because the skill was deleted.
    case "$(readlink "$link")" in
      "$SKILLS_SRC"/*)
        if [ ! -e "$link" ]; then
          rm "$link"
          echo "codex: pruned deleted skill $(basename "$link")"
        fi
        ;;
    esac
  done
fi
"$REPO_DIR/scripts/install-codex.sh"

# --- Home instructions: per-app override files (live symlink / generated) ---
echo
"$REPO_DIR/scripts/install-home-instructions.sh"

# --- Claude Code: reinstall the cached snapshot ---
echo
if command -v claude >/dev/null 2>&1; then
  claude plugin uninstall "$PLUGIN@$MARKETPLACE" || true
  claude plugin marketplace update "$MARKETPLACE"
  claude plugin install "$PLUGIN@$MARKETPLACE"
  echo
  echo "Claude Code: reinstalled $PLUGIN@$MARKETPLACE — restart Claude Code to apply."
else
  echo "Claude Code: 'claude' not on PATH; skipped."
fi
