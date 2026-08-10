#!/usr/bin/env bash
# Compose host-specific estack packages from shared and host-only source files.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$REPO_DIR/plugins/estack"
OUTPUT="$REPO_DIR/.generated"
CLAUDE_OUTPUT="$OUTPUT/claude/estack"
CODEX_OUTPUT="$OUTPUT/codex/estack"

rm -rf "$OUTPUT"
mkdir -p \
  "$CLAUDE_OUTPUT/.claude-plugin" \
  "$CLAUDE_OUTPUT/claude/hooks" \
  "$CLAUDE_OUTPUT/claude/scripts" \
  "$CLAUDE_OUTPUT/skills" \
  "$CLAUDE_OUTPUT/skills-claude" \
  "$CODEX_OUTPUT/.codex-plugin" \
  "$CODEX_OUTPUT/skills"

cp "$SOURCE/.claude-plugin/plugin.json" "$CLAUDE_OUTPUT/.claude-plugin/plugin.json"
cp "$SOURCE/.codex-plugin/plugin.json" "$CODEX_OUTPUT/.codex-plugin/plugin.json"

cp -R "$SOURCE/skills/." "$CLAUDE_OUTPUT/skills/"
cp -R "$SOURCE/skills/." "$CODEX_OUTPUT/skills/"
cp -R "$SOURCE/skills-claude/." "$CLAUDE_OUTPUT/skills-claude/"
cp -R "$SOURCE/skills-codex/." "$CODEX_OUTPUT/skills/"
cp -R "$SOURCE/claude/hooks/." "$CLAUDE_OUTPUT/claude/hooks/"
cp "$SOURCE/claude/scripts/"*.py "$CLAUDE_OUTPUT/claude/scripts/"
cp "$SOURCE/claude/fable-lead.md" "$CLAUDE_OUTPUT/claude/fable-lead.md"

echo "Built Claude package: $CLAUDE_OUTPUT"
echo "Built Codex package:  $CODEX_OUTPUT"
