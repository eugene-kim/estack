#!/usr/bin/env bash
# Install estack skills for OpenAI Codex.
#
# Codex discovers skills as directories containing a SKILL.md, under
# ~/.agents/skills (personal) or .agents/skills (per-repo). This script
# symlinks every skill in this repo's skills/ into your personal Codex
# skills directory so `euge-mode` and the rest are available everywhere.
#
# Re-running is safe: estack-owned symlinks are refreshed, a foreign symlink
# or a non-symlink directory/file with the same name is left untouched (it warns).
set -euo pipefail
shopt -s nullglob   # an empty/missing skills/ yields zero iterations, not a literal "*"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO_DIR/skills"
DST="${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"

if [ -e "$DST" ] && [ ! -d "$DST" ]; then
  echo "error: destination '$DST' exists but is not a directory" >&2
  exit 1
fi
mkdir -p "$DST"

linked=0
for skill in "$SRC"/*/; do
  name="$(basename "$skill")"
  target="$DST/$name"
  src="${skill%/}"
  if [ -L "$target" ]; then
    # Only reclaim a symlink we own (points back into this repo's skills/).
    if [ "$(readlink "$target")" != "$src" ]; then
      echo "skip: $target is a symlink to somewhere else; leaving it alone"
      continue
    fi
    rm "$target"
  elif [ -e "$target" ]; then
    echo "skip: $target exists and is not a symlink; leaving it alone"
    continue
  fi
  ln -s "$src" "$target"
  echo "linked: $name"
  linked=$((linked + 1))
done

if [ "$linked" -eq 0 ] && [ ! -d "$SRC" ]; then
  echo "error: no skills/ directory at '$SRC'; run this from inside the estack repo" >&2
  exit 1
fi

echo
echo "Done. estack skills are linked into $DST"
echo "The orchestrating skill is 'euge-mode'. Ask Codex to use it, e.g.:"
echo "  \"use euge-mode: <your task>\""
echo
echo "Note: Codex has no plugin 'subagent' concept like Claude Code's euge-agent."
echo "Where a skill says subagent_type: \"euge-agent\", use a general-purpose"
echo "subagent and have it read the euge-mode skill first."
