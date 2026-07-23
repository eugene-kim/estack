#!/usr/bin/env bash
# Refresh estack in both tools so Claude Code and Codex pick up the latest
# committed plugin version.
#
# Claude Code installs estack as a cached snapshot, so it needs an explicit
# reinstall to see changes — and a restart afterward to apply them (Claude Code
# loads plugins at startup; `claude plugin install` only refreshes the cache).
#
# Codex installs estack through its plugin marketplace. If the marketplace is a
# Git source, this script upgrades the marketplace snapshot before installing.
# If the marketplace is local, there is no snapshot to upgrade, so install is
# enough. In an open Codex app session, use Cmd+K / Ctrl+K -> Force Reload
# Skills; if the update still doesn't appear, start a new thread or restart
# Codex.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="estack"
MARKETPLACE="estack"
CLAUDE_PLUGINS=("estack" "estack-fable")

# --- Codex: remove legacy skill symlinks, then install/update the plugin ---
# Skip the Codex step when its CLI is missing or not runnable (e.g. a stale
# launcher pointing at a moved app bundle) so the Claude Code refresh below
# still runs. command -v alone is not enough: a broken shim is on PATH but
# fails when invoked, so probe it with a cheap `codex --version`.
if command -v codex >/dev/null 2>&1 && codex --version >/dev/null 2>&1; then
  "$REPO_DIR/scripts/install-codex.sh"
else
  echo "Codex: 'codex' CLI missing or not runnable; skipped." >&2
fi

# --- Home instructions: per-app override files (live symlink / generated) ---
echo
"$REPO_DIR/scripts/install-home-instructions.sh"

# --- Claude Code: reinstall the cached snapshot ---
echo
if command -v claude >/dev/null 2>&1; then
  for plugin in "${CLAUDE_PLUGINS[@]}"; do
    claude plugin uninstall "$plugin@$MARKETPLACE" || true
  done
  claude plugin marketplace update "$MARKETPLACE" || claude plugin marketplace add "$REPO_DIR"
  for plugin in "${CLAUDE_PLUGINS[@]}"; do
    claude plugin install "$plugin@$MARKETPLACE"
  done
  echo
  echo "Claude Code: reinstalled estack and estack-fable — restart Claude Code to apply."
else
  echo "Claude Code: 'claude' not on PATH; skipped."
fi
