#!/usr/bin/env bash
# Install estack skills for OpenAI Codex.
#
# Codex discovers skills as directories containing a SKILL.md, under
# ~/.agents/skills (personal) or .agents/skills (per-repo). This script
# symlinks every skill in this repo's skills/ into your personal Codex
# skills directory so `euge-mode` and the rest are available everywhere.
#
# Re-running is safe: existing estack symlinks are refreshed, and a
# non-symlink directory with the same name is left untouched (it warns).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_DIR/skills"
DST="${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"

mkdir -p "$DST"

for skill in "$SRC"/*/; do
  name="$(basename "$skill")"
  target="$DST/$name"
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    echo "skip: $target exists and is not a symlink; leaving it alone"
    continue
  fi
  ln -s "${skill%/}" "$target"
  echo "linked: $name"
done

echo
echo "Done. estack skills are linked into $DST"
echo "The orchestrating skill is 'euge-mode'. Ask Codex to use it, e.g.:"
echo "  \"use euge-mode: <your task>\""
echo
echo "Note: Codex has no plugin 'subagent' concept like Claude Code's euge-agent."
echo "Where a skill says subagent_type: \"euge-agent\", use a general-purpose"
echo "subagent and have it read the euge-mode skill first."
