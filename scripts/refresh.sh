#!/usr/bin/env bash
# Refresh estack in both tools so Claude Code and Codex pick up the latest
# committed plugin version.
#
# Claude Code installs estack as a cached snapshot, so it needs an explicit
# reinstall to see changes, and a restart afterward to apply them (Claude Code
# loads plugins at startup; `claude plugin install` only refreshes the cache).
#
# The refresh registers this clone as each tool's local marketplace. Claude
# installs the tracked source plugin directly; Codex installs its composed host
# package under .generated/. In an open Codex app session, use Cmd+K / Ctrl+K ->
# Force Reload Skills; if the update still does not appear, start a new thread
# or restart Codex.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="estack"
MARKETPLACE="estack"

"$REPO_DIR/scripts/build-plugins.sh"

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
  claude plugin uninstall "estack-fable@$MARKETPLACE" || true
  claude plugin uninstall "$PLUGIN@$MARKETPLACE" || true
  claude plugin marketplace remove "$MARKETPLACE" || true
  claude plugin marketplace add "$REPO_DIR"
  claude plugin install "$PLUGIN@$MARKETPLACE"
  echo
  echo "Claude Code: reinstalled estack. Restart Claude Code to apply."
else
  echo "Claude Code: 'claude' not on PATH; skipped."
fi
