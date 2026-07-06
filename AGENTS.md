# estack

This repo is a personal Claude Code and Codex plugin scaffold.

Skills must work in both Claude Code and Codex. Tool-specific features are
allowed only when paired with a fallback that gives the other tool equivalent
behavior.

## Current shape

The skill set is intentionally empty. `plugins/estack/skills/` is kept with a
`.gitkeep` so new skills can be added as real needs come up.

Keep plugin and refresh machinery working:

- `plugins/estack/.claude-plugin/plugin.json`
- `plugins/estack/.codex-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `.agents/plugins/marketplace.json`
- `scripts/refresh.sh`
- `scripts/install-codex.sh`
- `scripts/install-home-instructions.sh`

## Adding skills

When asked to add a skill, create `plugins/estack/skills/<skill-name>/SKILL.md`.
Keep the skill small. Do not recreate the old bundled suite unless the user asks
for a specific skill because the need has come up again.

## Default landing flow

This repo is managed by one person. When the user asks for a change and is happy
with the result, commit it, run `scripts/refresh.sh`, and push `main` by default.
Skip that only when the user explicitly asks to hold the diff locally, use a
branch or PR, or avoid refreshing.
